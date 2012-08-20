From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 08/11] netlink: implement memory mapped recvmsg()
Date: Mon, 20 Aug 2012 08:18:49 +0200
Message-ID: <1345443532-3707-9-git-send-email-kaber@trash.net>
References: <1345443532-3707-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Florian.Westphal@Sophos.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345443532-3707-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netlink.h  |    2 +
 net/netlink/af_netlink.c |  145 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 143 insertions(+), 4 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 98754e8..144ef3a 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -232,6 +232,8 @@ extern void __netlink_clear_multicast_users(struct sock *sk, unsigned int group)
 extern void netlink_clear_multicast_users(struct sock *sk, unsigned int group);
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_has_listeners(struct sock *sk, unsigned int group);
+extern struct sk_buff *netlink_alloc_skb(struct sock *ssk, unsigned int size,
+					 u32 dst_pid, gfp_t gfp_mask);
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 pid, int nonblock);
 extern int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, __u32 pid,
 			     __u32 group, gfp_t allocation);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 65867fd..c42a601 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -183,6 +183,11 @@ static bool netlink_skb_is_mmaped(const struct sk_buff *skb)
 	return NETLINK_CB(skb).flags & NETLINK_SKB_MMAPED;
 }
 
+static bool netlink_rx_is_mmaped(struct sock *sk)
+{
+	return nlk_sk(sk)->rx_ring.pg_vec != NULL;
+}
+
 static bool netlink_tx_is_mmaped(struct sock *sk)
 {
 	return nlk_sk(sk)->tx_ring.pg_vec != NULL;
@@ -654,8 +659,54 @@ out:
 	mutex_unlock(&nlk->pg_vec_lock);
 	return err;
 }
+
+static void netlink_queue_mmaped_skb(struct sock *sk, struct sk_buff *skb)
+{
+	struct nl_mmap_hdr *hdr;
+
+	hdr = netlink_mmap_hdr(skb);
+	hdr->nm_len	= skb->len;
+	hdr->nm_group	= NETLINK_CB(skb).dst_group;
+	hdr->nm_pid	= NETLINK_CB(skb).creds.pid;
+	hdr->nm_uid	= NETLINK_CB(skb).creds.uid;
+	hdr->nm_gid	= NETLINK_CB(skb).creds.gid;
+	netlink_frame_flush_dcache(hdr);
+	netlink_set_status(hdr, NL_MMAP_STATUS_VALID);
+
+	NETLINK_CB(skb).flags |= NETLINK_SKB_DELIVERED;
+	kfree_skb(skb);
+}
+
+static void netlink_ring_set_copied(struct sock *sk, struct sk_buff *skb)
+{
+	struct netlink_sock *nlk = nlk_sk(sk);
+	struct netlink_ring *ring = &nlk->rx_ring;
+	struct nl_mmap_hdr *hdr;
+
+	spin_lock_bh(&sk->sk_receive_queue.lock);
+	hdr = netlink_current_frame(ring, NL_MMAP_STATUS_UNUSED);
+	if (hdr == NULL) {
+		spin_unlock_bh(&sk->sk_receive_queue.lock);
+		kfree_skb(skb);
+		sk->sk_err = ENOBUFS;
+		sk->sk_error_report(sk);
+		return;
+	}
+	netlink_increment_head(ring);
+	__skb_queue_tail(&sk->sk_receive_queue, skb);
+	spin_unlock_bh(&sk->sk_receive_queue.lock);
+
+	hdr->nm_len	= skb->len;
+	hdr->nm_group	= NETLINK_CB(skb).dst_group;
+	hdr->nm_pid	= NETLINK_CB(skb).creds.pid;
+	hdr->nm_uid	= NETLINK_CB(skb).creds.uid;
+	hdr->nm_gid	= NETLINK_CB(skb).creds.gid;
+	netlink_set_status(hdr, NL_MMAP_STATUS_COPY);
+}
+
 #else /* CONFIG_NETLINK_MMAP */
 #define netlink_skb_is_mmaped(skb)	false
+#define netlink_rx_is_mmaped(sk)	false
 #define netlink_tx_is_mmaped(sk)	false
 #define netlink_mmap			sock_no_mmap
 #define netlink_poll			datagram_poll
@@ -1434,7 +1485,14 @@ static int __netlink_sendskb(struct sock *sk, struct sk_buff *skb)
 {
 	int len = skb->len;
 
-	skb_queue_tail(&sk->sk_receive_queue, skb);
+#ifdef CONFIG_NETLINK_MMAP
+	if (netlink_skb_is_mmaped(skb))
+		netlink_queue_mmaped_skb(sk, skb);
+	else if (netlink_rx_is_mmaped(sk))
+		netlink_ring_set_copied(sk, skb);
+	else
+#endif /* CONFIG_NETLINK_MMAP */
+		skb_queue_tail(&sk->sk_receive_queue, skb);
 	sk->sk_data_ready(sk, len);
 	return len;
 }
@@ -1543,6 +1601,68 @@ retry:
 }
 EXPORT_SYMBOL(netlink_unicast);
 
+struct sk_buff *netlink_alloc_skb(struct sock *ssk, unsigned int size,
+				  u32 dst_pid, gfp_t gfp_mask)
+{
+#ifdef CONFIG_NETLINK_MMAP
+	struct sock *sk = NULL;
+	struct sk_buff *skb;
+	struct netlink_ring *ring;
+	struct nl_mmap_hdr *hdr;
+	unsigned int maxlen;
+
+	sk = netlink_getsockbypid(ssk, dst_pid);
+	if (IS_ERR(sk))
+		goto out;
+
+	ring = &nlk_sk(sk)->rx_ring;
+	/* fast-path without atomic ops for common case: non-mmaped receiver */
+	if (ring->pg_vec == NULL)
+		goto out_put;
+
+	skb = alloc_skb_head(gfp_mask);
+	if (skb == NULL)
+		goto err1;
+
+	spin_lock_bh(&sk->sk_receive_queue.lock);
+	/* check again under lock */
+	if (ring->pg_vec == NULL)
+		goto out_free;
+
+	maxlen = ring->frame_size - NL_MMAP_HDRLEN;
+	if (maxlen < size)
+		goto out_free;
+
+	netlink_forward_ring(ring);
+	hdr = netlink_current_frame(ring, NL_MMAP_STATUS_UNUSED);
+	if (hdr == NULL)
+		goto err2;
+	netlink_ring_setup_skb(skb, sk, ring, hdr);
+	netlink_set_status(hdr, NL_MMAP_STATUS_RESERVED);
+	atomic_inc(&ring->pending);
+	netlink_increment_head(ring);
+
+	spin_unlock_bh(&sk->sk_receive_queue.lock);
+	return skb;
+
+err2:
+	kfree_skb(skb);
+	spin_unlock_bh(&sk->sk_receive_queue.lock);
+err1:
+	sock_put(sk);
+	return NULL;
+
+out_free:
+	kfree_skb(skb);
+	spin_unlock_bh(&sk->sk_receive_queue.lock);
+out_put:
+	sock_put(sk);
+out:
+#endif
+	return alloc_skb(size, gfp_mask);
+}
+EXPORT_SYMBOL_GPL(netlink_alloc_skb);
+
 int netlink_has_listeners(struct sock *sk, unsigned int group)
 {
 	int res = 0;
@@ -2328,9 +2448,13 @@ static int netlink_dump(struct sock *sk)
 
 	alloc_size = max_t(int, cb->min_dump_alloc, NLMSG_GOODSIZE);
 
-	skb = sock_rmalloc(sk, alloc_size, 0, GFP_KERNEL);
+	if (!netlink_rx_is_mmaped(sk) &&
+	    atomic_read(&sk->sk_rmem_alloc) >= sk->sk_rcvbuf)
+		goto errout_skb;
+	skb = netlink_alloc_skb(sk, alloc_size, nlk->pid, GFP_KERNEL);
 	if (!skb)
 		goto errout_skb;
+	netlink_skb_set_owner_r(skb, sk);
 
 	len = cb->dump(skb, cb);
 
@@ -2384,12 +2508,24 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	if (cb == NULL)
 		return -ENOBUFS;
 
+	/* Memory mapped dump requests need to be copied to avoid looping
+	 * on the pending state in netlink_mmap_sendmsg() while the cb holds
+	 * a reference to the skb.
+	 */
+	if (netlink_skb_is_mmaped(skb)) {
+		skb = skb_copy(skb, GFP_KERNEL);
+		if (skb == NULL) {
+			kfree(cb);
+			return -ENOBUFS;
+		}
+	} else
+		atomic_inc(&skb->users);
+
 	cb->dump = control->dump;
 	cb->done = control->done;
 	cb->nlh = nlh;
 	cb->data = control->data;
 	cb->min_dump_alloc = control->min_dump_alloc;
-	atomic_inc(&skb->users);
 	cb->skb = skb;
 
 	sk = netlink_lookup(sock_net(ssk), ssk->sk_protocol, NETLINK_CB(skb).pid);
@@ -2434,7 +2570,8 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 	if (err)
 		payload += nlmsg_len(nlh);
 
-	skb = nlmsg_new(payload, GFP_KERNEL);
+	skb = netlink_alloc_skb(in_skb->sk, nlmsg_total_size(payload),
+				NETLINK_CB(in_skb).pid, GFP_KERNEL);
 	if (!skb) {
 		struct sock *sk;
 
-- 
1.7.7.6

