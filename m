From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 07/11] netlink: implement memory mapped sendmsg()
Date: Mon, 20 Aug 2012 08:18:48 +0200
Message-ID: <1345443532-3707-8-git-send-email-kaber@trash.net>
References: <1345443532-3707-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Florian.Westphal@Sophos.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345443532-3707-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for mmap'ed sendmsg() to netlink.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netlink/af_netlink.c |  132 +++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 126 insertions(+), 6 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 3810911..65867fd 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -183,6 +183,11 @@ static bool netlink_skb_is_mmaped(const struct sk_buff *skb)
 	return NETLINK_CB(skb).flags & NETLINK_SKB_MMAPED;
 }
 
+static bool netlink_tx_is_mmaped(struct sock *sk)
+{
+	return nlk_sk(sk)->tx_ring.pg_vec != NULL;
+}
+
 static __pure struct page *pgvec_to_page(const void *addr)
 {
 	if (is_vmalloc_addr(addr))
@@ -505,6 +510,9 @@ static unsigned int netlink_poll(struct file *file, struct socket *sock,
 	struct netlink_sock *nlk = nlk_sk(sk);
 	unsigned int mask;
 
+	if (nlk->cb != NULL && nlk->rx_ring.pg_vec != NULL)
+		netlink_dump(sk);
+
 	mask = datagram_poll(file, sock, wait);
 
 	spin_lock_bh(&sk->sk_receive_queue.lock);
@@ -550,10 +558,108 @@ static void netlink_ring_setup_skb(struct sk_buff *skb, struct sock *sk,
 	NETLINK_CB(skb).flags |= NETLINK_SKB_MMAPED;
 	NETLINK_CB(skb).sk = sk;
 }
+
+static int netlink_mmap_sendmsg(struct sock *sk, struct msghdr *msg,
+				u32 dst_pid, u32 dst_group,
+				struct sock_iocb *siocb)
+{
+	struct netlink_sock *nlk = nlk_sk(sk);
+	struct netlink_ring *ring;
+	struct nl_mmap_hdr *hdr;
+	struct sk_buff *skb;
+	unsigned int maxlen;
+	bool excl = true;
+	int err = 0, len = 0;
+
+	/* Netlink messages are validated by the receiver before processing.
+	 * In order to avoid userspace changing the contents of the message
+	 * after validation, the socket and the ring may only be used by a
+	 * single process, otherwise we fall back to copying.
+	 */
+	if (atomic_long_read(&sk->sk_socket->file->f_count) > 2 ||
+	    atomic_read(&nlk->mapped) > 1)
+		excl = false;
+
+	mutex_lock(&nlk->pg_vec_lock);
+
+	ring   = &nlk->tx_ring;
+	maxlen = ring->frame_size - NL_MMAP_HDRLEN;
+
+	do {
+		hdr = netlink_current_frame(ring, NL_MMAP_STATUS_VALID);
+		if (hdr == NULL) {
+			if (!(msg->msg_flags & MSG_DONTWAIT) &&
+			    atomic_read(&nlk->tx_ring.pending))
+				schedule();
+			continue;
+		}
+		if (hdr->nm_len > maxlen) {
+			err = -EINVAL;
+			goto out;
+		}
+
+		netlink_frame_flush_dcache(hdr);
+
+		if (likely(dst_pid == 0 && dst_group == 0 && excl)) {
+			skb = alloc_skb_head(GFP_KERNEL);
+			if (skb == NULL) {
+				err = -ENOBUFS;
+				goto out;
+			}
+			sock_hold(sk);
+			netlink_ring_setup_skb(skb, sk, ring, hdr);
+			NETLINK_CB(skb).flags |= NETLINK_SKB_TX;
+			__skb_put(skb, hdr->nm_len);
+			netlink_set_status(hdr, NL_MMAP_STATUS_RESERVED);
+			atomic_inc(&ring->pending);
+		} else {
+			skb = alloc_skb(hdr->nm_len, GFP_KERNEL);
+			if (skb == NULL) {
+				err = -ENOBUFS;
+				goto out;
+			}
+			__skb_put(skb, hdr->nm_len);
+			memcpy(skb->data, (void *)hdr + NL_MMAP_HDRLEN, hdr->nm_len);
+			netlink_set_status(hdr, NL_MMAP_STATUS_UNUSED);
+		}
+
+		netlink_increment_head(ring);
+
+		NETLINK_CB(skb).pid	  = nlk->pid;
+		NETLINK_CB(skb).dst_group = dst_group;
+		NETLINK_CB(skb).creds	  = siocb->scm->creds;
+
+		err = security_netlink_send(sk, skb);
+		if (err) {
+			kfree_skb(skb);
+			goto out;
+		}
+
+		if (unlikely(dst_group)) {
+			atomic_inc(&skb->users);
+			netlink_broadcast(sk, skb, dst_pid, dst_group, GFP_KERNEL);
+		}
+		err = netlink_unicast(sk, skb, dst_pid, msg->msg_flags & MSG_DONTWAIT);
+		if (err < 0)
+			goto out;
+		len += err;
+
+	} while (hdr != NULL ||
+		 (!(msg->msg_flags & MSG_DONTWAIT) &&
+		  atomic_read(&nlk->tx_ring.pending)));
+
+	if (len > 0)
+		err = len;
+out:
+	mutex_unlock(&nlk->pg_vec_lock);
+	return err;
+}
 #else /* CONFIG_NETLINK_MMAP */
 #define netlink_skb_is_mmaped(skb)	false
+#define netlink_tx_is_mmaped(sk)	false
 #define netlink_mmap			sock_no_mmap
 #define netlink_poll			datagram_poll
+#define netlink_mmap_sendmsg(sk, msg, dst_pid, dst_group, siocb)	0
 #endif /* CONFIG_NETLINK_MMAP */
 
 static void netlink_destroy_callback(struct netlink_callback *cb)
@@ -584,11 +690,16 @@ static void netlink_skb_destructor(struct sk_buff *skb)
 		hdr = netlink_mmap_hdr(skb);
 		sk = NETLINK_CB(skb).sk;
 
-		if (!(NETLINK_CB(skb).flags & NETLINK_SKB_DELIVERED)) {
-			hdr->nm_len = 0;
-			netlink_set_status(hdr, NL_MMAP_STATUS_VALID);
+		if (NETLINK_CB(skb).flags & NETLINK_SKB_TX) {
+			netlink_set_status(hdr, NL_MMAP_STATUS_UNUSED);
+			ring = &nlk_sk(sk)->tx_ring;
+		} else {
+			if (!(NETLINK_CB(skb).flags & NETLINK_SKB_DELIVERED)) {
+				hdr->nm_len = 0;
+				netlink_set_status(hdr, NL_MMAP_STATUS_VALID);
+			}
+			ring = &nlk_sk(sk)->rx_ring;
 		}
-		ring = &nlk_sk(sk)->rx_ring;
 
 		WARN_ON(atomic_read(&ring->pending) == 0);
 		atomic_dec(&ring->pending);
@@ -1285,8 +1396,9 @@ int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
 
 	nlk = nlk_sk(sk);
 
-	if (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
-	    test_bit(NETLINK_CONGESTED, &nlk->state)) {
+	if ((atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
+	     test_bit(NETLINK_CONGESTED, &nlk->state)) &&
+	    !netlink_skb_is_mmaped(skb)) {
 		DECLARE_WAITQUEUE(wait, current);
 		if (!*timeo) {
 			if (!ssk || netlink_is_kernel(ssk))
@@ -1346,6 +1458,8 @@ static struct sk_buff *netlink_trim(struct sk_buff *skb, gfp_t allocation)
 	int delta;
 
 	WARN_ON(skb->sk != NULL);
+	if (netlink_skb_is_mmaped(skb))
+		return skb;
 
 	delta = skb->end - skb->tail;
 	if (delta * 2 < skb->truesize)
@@ -1869,6 +1983,12 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			goto out;
 	}
 
+	if (netlink_tx_is_mmaped(sk) &&
+	    msg->msg_iov->iov_base == NULL) {
+		err = netlink_mmap_sendmsg(sk, msg, dst_pid, dst_group, siocb);
+		goto out;
+	}
+
 	err = -EMSGSIZE;
 	if (len > sk->sk_sndbuf - 32)
 		goto out;
-- 
1.7.7.6

