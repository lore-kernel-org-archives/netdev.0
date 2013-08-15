From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH] netlink: Eliminate kmalloc in netlink dump operation.
Date: Thu, 15 Aug 2013 15:31:06 -0700
Message-ID: <1376605866-6808-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:60660 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751406Ab3HOWbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 18:31:11 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so1337859pde.23
        for <netdev@vger.kernel.org>; Thu, 15 Aug 2013 15:31:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch stores struct netlink_callback in netlink_sock
to avoid allocating and freeing it on every netlink dump msg.
Only one dump operation is allowed for a given socket at a time
therefore we can safely convert cb pointer to cb struct inside
netlink_sock.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/netlink/af_netlink.c |   97 ++++++++++++++++++++--------------------------
 net/netlink/af_netlink.h |    3 +-
 2 files changed, 44 insertions(+), 56 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 6273772..a17dda1 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -595,7 +595,7 @@ static unsigned int netlink_poll(struct file *file, struct socket *sock,
 		 * for dumps is performed here. A dump is allowed to continue
 		 * if at least half the ring is unused.
 		 */
-		while (nlk->cb != NULL && netlink_dump_space(nlk)) {
+		while (nlk->cb_running && netlink_dump_space(nlk)) {
 			err = netlink_dump(sk);
 			if (err < 0) {
 				sk->sk_err = err;
@@ -802,18 +802,6 @@ static void netlink_ring_set_copied(struct sock *sk, struct sk_buff *skb)
 #define netlink_mmap_sendmsg(sk, msg, dst_portid, dst_group, siocb)	0
 #endif /* CONFIG_NETLINK_MMAP */
 
-static void netlink_destroy_callback(struct netlink_callback *cb)
-{
-	kfree_skb(cb->skb);
-	kfree(cb);
-}
-
-static void netlink_consume_callback(struct netlink_callback *cb)
-{
-	consume_skb(cb->skb);
-	kfree(cb);
-}
-
 static void netlink_skb_destructor(struct sk_buff *skb)
 {
 #ifdef CONFIG_NETLINK_MMAP
@@ -872,12 +860,12 @@ static void netlink_sock_destruct(struct sock *sk)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
 
-	if (nlk->cb) {
-		if (nlk->cb->done)
-			nlk->cb->done(nlk->cb);
+	if (nlk->cb_running) {
+		if (nlk->cb.done)
+			nlk->cb.done(&nlk->cb);
 
-		module_put(nlk->cb->module);
-		netlink_destroy_callback(nlk->cb);
+		module_put(nlk->cb.module);
+		kfree_skb(nlk->cb.skb);
 	}
 
 	skb_queue_purge(&sk->sk_receive_queue);
@@ -2350,7 +2338,8 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 
 	skb_free_datagram(sk, skb);
 
-	if (nlk->cb && atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf / 2) {
+	if (nlk->cb_running &&
+	    atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf / 2) {
 		ret = netlink_dump(sk);
 		if (ret) {
 			sk->sk_err = ret;
@@ -2566,13 +2555,12 @@ static int netlink_dump(struct sock *sk)
 	int alloc_size;
 
 	mutex_lock(nlk->cb_mutex);
-
-	cb = nlk->cb;
-	if (cb == NULL) {
+	if (!nlk->cb_running) {
 		err = -EINVAL;
 		goto errout_skb;
 	}
 
+	cb = &nlk->cb;
 	alloc_size = max_t(int, cb->min_dump_alloc, NLMSG_GOODSIZE);
 
 	if (!netlink_rx_is_mmaped(sk) &&
@@ -2610,11 +2598,11 @@ static int netlink_dump(struct sock *sk)
 
 	if (cb->done)
 		cb->done(cb);
-	nlk->cb = NULL;
-	mutex_unlock(nlk->cb_mutex);
 
+	nlk->cb_running = false;
+	mutex_unlock(nlk->cb_mutex);
 	module_put(cb->module);
-	netlink_consume_callback(cb);
+	consume_skb(cb->skb);
 	return 0;
 
 errout_skb:
@@ -2632,59 +2620,51 @@ int __netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	struct netlink_sock *nlk;
 	int ret;
 
-	cb = kzalloc(sizeof(*cb), GFP_KERNEL);
-	if (cb == NULL)
-		return -ENOBUFS;
-
 	/* Memory mapped dump requests need to be copied to avoid looping
 	 * on the pending state in netlink_mmap_sendmsg() while the CB hold
 	 * a reference to the skb.
 	 */
 	if (netlink_skb_is_mmaped(skb)) {
 		skb = skb_copy(skb, GFP_KERNEL);
-		if (skb == NULL) {
-			kfree(cb);
+		if (skb == NULL)
 			return -ENOBUFS;
-		}
 	} else
 		atomic_inc(&skb->users);
 
-	cb->dump = control->dump;
-	cb->done = control->done;
-	cb->nlh = nlh;
-	cb->data = control->data;
-	cb->module = control->module;
-	cb->min_dump_alloc = control->min_dump_alloc;
-	cb->skb = skb;
-
 	sk = netlink_lookup(sock_net(ssk), ssk->sk_protocol, NETLINK_CB(skb).portid);
 	if (sk == NULL) {
-		netlink_destroy_callback(cb);
-		return -ECONNREFUSED;
+		ret = -ECONNREFUSED;
+		goto error_free;
 	}
-	nlk = nlk_sk(sk);
 
+	nlk = nlk_sk(sk);
 	mutex_lock(nlk->cb_mutex);
 	/* A dump is in progress... */
-	if (nlk->cb) {
-		mutex_unlock(nlk->cb_mutex);
-		netlink_destroy_callback(cb);
+	if (nlk->cb_running) {
 		ret = -EBUSY;
-		goto out;
+		goto error_unlock;
 	}
 	/* add reference of module which cb->dump belongs to */
-	if (!try_module_get(cb->module)) {
-		mutex_unlock(nlk->cb_mutex);
-		netlink_destroy_callback(cb);
+	if (!try_module_get(control->module)) {
 		ret = -EPROTONOSUPPORT;
-		goto out;
+		goto error_unlock;
 	}
 
-	nlk->cb = cb;
+	cb = &nlk->cb;
+	memset(cb, 0, sizeof(*cb));
+	cb->dump = control->dump;
+	cb->done = control->done;
+	cb->nlh = nlh;
+	cb->data = control->data;
+	cb->module = control->module;
+	cb->min_dump_alloc = control->min_dump_alloc;
+	cb->skb = skb;
+
+	nlk->cb_running = true;
+
 	mutex_unlock(nlk->cb_mutex);
 
 	ret = netlink_dump(sk);
-out:
 	sock_put(sk);
 
 	if (ret)
@@ -2694,6 +2674,13 @@ out:
 	 * signal not to send ACK even if it was requested.
 	 */
 	return -EINTR;
+
+error_unlock:
+	sock_put(sk);
+	mutex_unlock(nlk->cb_mutex);
+error_free:
+	kfree_skb(skb);
+	return ret;
 }
 EXPORT_SYMBOL(__netlink_dump_start);
 
@@ -2916,14 +2903,14 @@ static int netlink_seq_show(struct seq_file *seq, void *v)
 		struct sock *s = v;
 		struct netlink_sock *nlk = nlk_sk(s);
 
-		seq_printf(seq, "%pK %-3d %-6u %08x %-8d %-8d %pK %-8d %-8d %-8lu\n",
+		seq_printf(seq, "%pK %-3d %-6u %08x %-8d %-8d %d %-8d %-8d %-8lu\n",
 			   s,
 			   s->sk_protocol,
 			   nlk->portid,
 			   nlk->groups ? (u32)nlk->groups[0] : 0,
 			   sk_rmem_alloc_get(s),
 			   sk_wmem_alloc_get(s),
-			   nlk->cb,
+			   nlk->cb_running,
 			   atomic_read(&s->sk_refcnt),
 			   atomic_read(&s->sk_drops),
 			   sock_i_ino(s)
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index eaa88d1..acbd774 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -32,7 +32,8 @@ struct netlink_sock {
 	unsigned long		*groups;
 	unsigned long		state;
 	wait_queue_head_t	wait;
-	struct netlink_callback	*cb;
+	bool			cb_running;
+	struct netlink_callback	cb;
 	struct mutex		*cb_mutex;
 	struct mutex		cb_def_mutex;
 	void			(*netlink_rcv)(struct sk_buff *skb);
-- 
1.7.1
