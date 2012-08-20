From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 06/11] netlink: add mmap'ed netlink helper functions
Date: Mon, 20 Aug 2012 08:18:47 +0200
Message-ID: <1345443532-3707-7-git-send-email-kaber@trash.net>
References: <1345443532-3707-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Florian.Westphal@Sophos.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36025 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752425Ab2HTGS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 02:18:58 -0400
In-Reply-To: <1345443532-3707-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add helper functions for looking up mmap'ed frame headers, reading and writing
their status, allocating skbs with mmap'ed data areas and a poll function.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netlink.h  |    8 ++
 net/netlink/af_netlink.c |  185 +++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 191 insertions(+), 2 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 3600461..98754e8 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -193,10 +193,18 @@ static inline struct nlmsghdr *nlmsg_hdr(const struct sk_buff *skb)
 	return (struct nlmsghdr *)skb->data;
 }
 
+enum netlink_skb_flags {
+	NETLINK_SKB_MMAPED	= 0x1,		/* Packet data is mmapped */
+	NETLINK_SKB_TX		= 0x2,		/* Packet was sent by userspace */
+	NETLINK_SKB_DELIVERED	= 0x4,		/* Packet was delivered */
+};
+
 struct netlink_skb_parms {
 	struct ucred		creds;		/* Skb credentials	*/
 	__u32			pid;
 	__u32			dst_group;
+	__u32			flags;
+	struct sock		*sk;		/* socket owning mmaped ring */
 };
 
 #define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index e20a918..3810911 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -56,6 +56,7 @@
 #include <linux/audit.h>
 #include <linux/mutex.h>
 #include <linux/vmalloc.h>
+#include <asm/cacheflush.h>
 
 #include <net/net_namespace.h>
 #include <net/sock.h>
@@ -159,6 +160,7 @@ static struct netlink_table *nl_table;
 static DECLARE_WAIT_QUEUE_HEAD(nl_table_wait);
 
 static int netlink_dump(struct sock *sk);
+static void netlink_skb_destructor(struct sk_buff *skb);
 
 static DEFINE_RWLOCK(nl_table_lock);
 static atomic_t nl_table_users = ATOMIC_INIT(0);
@@ -176,6 +178,11 @@ static inline struct hlist_head *nl_pid_hashfn(struct nl_pid_hash *hash, u32 pid
 }
 
 #ifdef CONFIG_NETLINK_MMAP
+static bool netlink_skb_is_mmaped(const struct sk_buff *skb)
+{
+	return NETLINK_CB(skb).flags & NETLINK_SKB_MMAPED;
+}
+
 static __pure struct page *pgvec_to_page(const void *addr)
 {
 	if (is_vmalloc_addr(addr))
@@ -399,8 +406,154 @@ out:
 	mutex_unlock(&nlk->pg_vec_lock);
 	return 0;
 }
+
+static void netlink_frame_flush_dcache(const struct nl_mmap_hdr *hdr)
+{
+#if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE == 1
+	struct page *p_start, *p_end;
+
+	/* First page is flushed through netlink_{get,set}_status */
+	p_start = pgvec_to_page(hdr + PAGE_SIZE);
+	p_end   = pgvec_to_page((void *)hdr + NL_MMAP_MSG_HDRLEN + hdr->nm_len - 1);
+	while (p_start <= p_end) {
+		flush_dcache_page(p_start);
+		p_start++;
+	}
+#endif
+}
+
+static enum nl_mmap_status netlink_get_status(const struct nl_mmap_hdr *hdr)
+{
+	smp_rmb();
+	flush_dcache_page(pgvec_to_page(hdr));
+	return hdr->nm_status;
+}
+
+static void netlink_set_status(struct nl_mmap_hdr *hdr,
+			       enum nl_mmap_status status)
+{
+	hdr->nm_status = status;
+	flush_dcache_page(pgvec_to_page(hdr));
+	smp_wmb();
+}
+
+static struct nl_mmap_hdr *
+__netlink_lookup_frame(const struct netlink_ring *ring, unsigned int pos)
+{
+	unsigned int pg_vec_pos, frame_off;
+
+	pg_vec_pos = pos / ring->frames_per_block;
+	frame_off  = pos % ring->frames_per_block;
+
+	return ring->pg_vec[pg_vec_pos] + (frame_off * ring->frame_size);
+}
+
+static struct nl_mmap_hdr *
+netlink_lookup_frame(const struct netlink_ring *ring, unsigned int pos,
+		     enum nl_mmap_status status)
+{
+	struct nl_mmap_hdr *hdr;
+
+	hdr = __netlink_lookup_frame(ring, pos);
+	if (netlink_get_status(hdr) != status)
+		return NULL;
+
+	return hdr;
+}
+
+static struct nl_mmap_hdr *
+netlink_current_frame(const struct netlink_ring *ring,
+		      enum nl_mmap_status status)
+{
+	return netlink_lookup_frame(ring, ring->head, status);
+}
+
+static struct nl_mmap_hdr *
+netlink_previous_frame(const struct netlink_ring *ring,
+		       enum nl_mmap_status status)
+{
+	unsigned int prev;
+
+	prev = ring->head ? ring->head - 1 : ring->frame_max;
+	return netlink_lookup_frame(ring, prev, status);
+}
+
+static void netlink_increment_head(struct netlink_ring *ring)
+{
+	ring->head = ring->head != ring->frame_max ? ring->head + 1 : 0;
+}
+
+static void netlink_forward_ring(struct netlink_ring *ring)
+{
+	unsigned int head = ring->head, pos = head;
+	const struct nl_mmap_hdr *hdr;
+
+	do {
+		hdr = __netlink_lookup_frame(ring, pos);
+		if (hdr->nm_status == NL_MMAP_STATUS_UNUSED)
+			break;
+		if (hdr->nm_status != NL_MMAP_STATUS_SKIP)
+			break;
+		netlink_increment_head(ring);
+	} while (ring->head != head);
+}
+
+static unsigned int netlink_poll(struct file *file, struct socket *sock,
+				 poll_table *wait)
+{
+	struct sock *sk = sock->sk;
+	struct netlink_sock *nlk = nlk_sk(sk);
+	unsigned int mask;
+
+	mask = datagram_poll(file, sock, wait);
+
+	spin_lock_bh(&sk->sk_receive_queue.lock);
+	if (nlk->rx_ring.pg_vec) {
+		netlink_forward_ring(&nlk->rx_ring);
+		if (!netlink_previous_frame(&nlk->rx_ring, NL_MMAP_STATUS_UNUSED))
+			mask |= POLLIN | POLLRDNORM;
+	}
+	spin_unlock_bh(&sk->sk_receive_queue.lock);
+
+	spin_lock_bh(&sk->sk_write_queue.lock);
+	if (nlk->tx_ring.pg_vec) {
+		if (netlink_current_frame(&nlk->tx_ring, NL_MMAP_STATUS_UNUSED))
+			mask |= POLLOUT | POLLWRNORM;
+	}
+	spin_unlock_bh(&sk->sk_write_queue.lock);
+
+	return mask;
+}
+
+static struct nl_mmap_hdr *netlink_mmap_hdr(struct sk_buff *skb)
+{
+	return (struct nl_mmap_hdr *)(skb->head - NL_MMAP_HDRLEN);
+}
+
+static void netlink_ring_setup_skb(struct sk_buff *skb, struct sock *sk,
+				   struct netlink_ring *ring,
+				   struct nl_mmap_hdr *hdr)
+{
+	unsigned int size;
+	void *data;
+
+	size = ring->frame_size - NL_MMAP_HDRLEN;
+	data = (void *)hdr + NL_MMAP_HDRLEN;
+
+	skb->head	= data;
+	skb->data	= data;
+	skb_reset_tail_pointer(skb);
+	skb->end	= skb->tail + size;
+	skb->len	= 0;
+
+	skb->destructor	= netlink_skb_destructor;
+	NETLINK_CB(skb).flags |= NETLINK_SKB_MMAPED;
+	NETLINK_CB(skb).sk = sk;
+}
 #else /* CONFIG_NETLINK_MMAP */
+#define netlink_skb_is_mmaped(skb)	false
 #define netlink_mmap			sock_no_mmap
+#define netlink_poll			datagram_poll
 #endif /* CONFIG_NETLINK_MMAP */
 
 static void netlink_destroy_callback(struct netlink_callback *cb)
@@ -417,7 +570,35 @@ static void netlink_consume_callback(struct netlink_callback *cb)
 
 static void netlink_skb_destructor(struct sk_buff *skb)
 {
-	sock_rfree(skb);
+#ifdef CONFIG_NETLINK_MMAP
+	struct nl_mmap_hdr *hdr;
+	struct netlink_ring *ring;
+	struct sock *sk;
+
+	/* If a packet from the kernel to userspace was freed because of an
+	 * error without being delivered to userspace, the kernel must reset
+	 * the status. In the direction userspace to kernel, the status is
+	 * always reset here after the packet was processed and freed.
+	 */
+	if (netlink_skb_is_mmaped(skb)) {
+		hdr = netlink_mmap_hdr(skb);
+		sk = NETLINK_CB(skb).sk;
+
+		if (!(NETLINK_CB(skb).flags & NETLINK_SKB_DELIVERED)) {
+			hdr->nm_len = 0;
+			netlink_set_status(hdr, NL_MMAP_STATUS_VALID);
+		}
+		ring = &nlk_sk(sk)->rx_ring;
+
+		WARN_ON(atomic_read(&ring->pending) == 0);
+		atomic_dec(&ring->pending);
+		sock_put(sk);
+
+		skb->data = NULL;
+	}
+#endif
+	if (skb->sk != NULL)
+		sock_rfree(skb);
 }
 
 static void netlink_skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
@@ -2400,7 +2581,7 @@ static const struct proto_ops netlink_ops = {
 	.socketpair =	sock_no_socketpair,
 	.accept =	sock_no_accept,
 	.getname =	netlink_getname,
-	.poll =		datagram_poll,
+	.poll =		netlink_poll,
 	.ioctl =	sock_no_ioctl,
 	.listen =	sock_no_listen,
 	.shutdown =	sock_no_shutdown,
-- 
1.7.7.6
