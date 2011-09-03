From: kaber@trash.net
Subject: [PATCH 09/11] netlink: implement memory mapped recvmsg()
Date: Sat,  3 Sep 2011 19:26:09 +0200
Message-ID: <1315070771-18576-10-git-send-email-kaber@trash.net>
References: <1315070771-18576-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56163 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753355Ab1ICR0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2011 13:26:20 -0400
In-Reply-To: <1315070771-18576-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Add support for memory mapped recvmsg() to netlink. When the kernel wants
to send a message to userspace, it uses a special skb allocation function
that looks up the receiving socket and, in case the socket uses memory
mapped I/O, allocates an skb without a data area and sets the data pointer
to point to the data area of the ring frame. Message construction than
proceeds as normally, once completed the ownership of the ring frame is
transfered to userspace by setting the status to NL_MMAP_STATUS_VALID.

When memory mapped I/O can't be used because the required size exceeds
the frame size or the sending subsystem doesn't support memory mapped
I/O, the skb is queued to the socket receive queue and the frame status
is set to NL_MMAP_STATUS_COPY to instruct userspace to invoke recvmsg()
to receive the queued message.

Unlike with regular socket I/O, userspace normally doesn't invoke
recvmsg(), so flow control of dumps happens in netlink_poll() under
the assumption that poll() is usually only invoked when all pending
frames have been processed.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netlink.h  |    2 +
 net/netlink/af_netlink.c |  207 ++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 182 insertions(+), 27 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 955adc1..2bef899 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -223,6 +223,8 @@ extern void __netlink_clear_multicast_users(struct sock *sk, unsigned int group)
 extern void netlink_clear_multicast_users(struct sock *sk, unsigned int group);
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_has_listeners(struct sock *sk, unsigned int group);
+extern struct sk_buff *netlink_alloc_skb(struct sock *ssk, unsigned int size,
+					 u32 dst_pid, gfp_t gfp_mask);
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 pid, int nonblock);
 extern int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, __u32 pid,
 			     __u32 group, gfp_t allocation);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 9b6400f..2f4745d 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -176,12 +176,40 @@ static struct hlist_head *nl_pid_hashfn(struct nl_pid_hash *hash, u32 pid)
 	return &hash->table[jhash_1word(pid, hash->rnd) & hash->mask];
 }
 
+static void netlink_overrun(struct sock *sk)
+{
+	struct netlink_sock *nlk = nlk_sk(sk);
+
+	if (!(nlk->flags & NETLINK_RECV_NO_ENOBUFS)) {
+		if (!test_and_set_bit(NETLINK_CONGESTED, &nlk_sk(sk)->state)) {
+			sk->sk_err = ENOBUFS;
+			sk->sk_error_report(sk);
+		}
+	}
+	atomic_inc(&sk->sk_drops);
+}
+
+static inline void netlink_rcv_wake(struct sock *sk)
+{
+	struct netlink_sock *nlk = nlk_sk(sk);
+
+	if (skb_queue_empty(&sk->sk_receive_queue))
+		clear_bit(NETLINK_CONGESTED, &nlk->state);
+	if (!test_bit(NETLINK_CONGESTED, &nlk->state))
+		wake_up_interruptible(&nlk->wait);
+}
+
 #ifdef CONFIG_NETLINK_MMAP
 static bool netlink_skb_is_mmaped(const struct sk_buff *skb)
 {
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
@@ -508,6 +536,22 @@ static unsigned int netlink_poll(struct file *file, struct socket *sock,
 	struct sock *sk = sock->sk;
 	struct netlink_sock *nlk = nlk_sk(sk);
 	unsigned int mask;
+	int err;
+
+	if (nlk->rx_ring.pg_vec != NULL) {
+		/* Memory mapped sockets don't call recvmsg(), so flow control
+		 * is performed here under the assumption that the entire ring
+		 * has been processed before invoking poll().
+		 */
+		if (nlk->cb != NULL) {
+			err = netlink_dump(sk);
+			if (err < 0) {
+				sk->sk_err = err;
+				sk->sk_error_report(sk);
+			}
+		}
+		netlink_rcv_wake(sk);
+	}
 
 	mask = datagram_poll(file, sock, wait);
 
@@ -649,8 +693,53 @@ out:
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
+		netlink_overrun(sk);
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
@@ -661,7 +750,14 @@ static void netlink_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	unsigned int len = skb->len;
 
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
 }
 
@@ -1309,19 +1405,6 @@ static int netlink_getname(struct socket *sock, struct sockaddr *addr,
 	return 0;
 }
 
-static void netlink_overrun(struct sock *sk)
-{
-	struct netlink_sock *nlk = nlk_sk(sk);
-
-	if (!(nlk->flags & NETLINK_RECV_NO_ENOBUFS)) {
-		if (!test_and_set_bit(NETLINK_CONGESTED, &nlk_sk(sk)->state)) {
-			sk->sk_err = ENOBUFS;
-			sk->sk_error_report(sk);
-		}
-	}
-	atomic_inc(&sk->sk_drops);
-}
-
 static struct sock *netlink_getsockbypid(struct sock *ssk, u32 pid)
 {
 	struct sock *sock;
@@ -1450,16 +1533,6 @@ static inline struct sk_buff *netlink_trim(struct sk_buff *skb,
 	return skb;
 }
 
-static inline void netlink_rcv_wake(struct sock *sk)
-{
-	struct netlink_sock *nlk = nlk_sk(sk);
-
-	if (skb_queue_empty(&sk->sk_receive_queue))
-		clear_bit(NETLINK_CONGESTED, &nlk->state);
-	if (!test_bit(NETLINK_CONGESTED, &nlk->state))
-		wake_up_interruptible(&nlk->wait);
-}
-
 static inline int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb)
 {
 	int ret;
@@ -1512,6 +1585,69 @@ retry:
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
+	netlink_overrun(sk);
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
@@ -2278,9 +2414,13 @@ static int netlink_dump(struct sock *sk)
 
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
 
@@ -2337,11 +2477,23 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
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
 	cb->dump = dump;
 	cb->done = done;
 	cb->nlh = nlh;
 	cb->min_dump_alloc = min_dump_alloc;
-	atomic_inc(&skb->users);
 	cb->skb = skb;
 
 	sk = netlink_lookup(sock_net(ssk), ssk->sk_protocol, NETLINK_CB(skb).pid);
@@ -2386,7 +2538,8 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 	if (err)
 		payload += nlmsg_len(nlh);
 
-	skb = nlmsg_new(payload, GFP_KERNEL);
+	skb = netlink_alloc_skb(in_skb->sk, nlmsg_total_size(payload),
+				NETLINK_CB(in_skb).pid, GFP_KERNEL);
 	if (!skb) {
 		struct sock *sk;
 
-- 
1.7.4.4
