From: Patrick McHardy <kaber@trash.net>
Subject: [NETLINK]: af_netlink.c checkpatch cleanups
Date: Tue, 04 Dec 2007 09:07:04 +0100
Message-ID: <47550AA8.3030608@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000505010601020605080302"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56482 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbXLDIHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 03:07:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000505010601020605080302
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------000505010601020605080302
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETLINK]: af_netlink.c checkpatch cleanups

Fix large number of checkpatch errors.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c2bb1653e4e92e11e045fcb12ba9ec6a73436685
tree bcdeda2bc99d68df298cdb7f7292ae97de686dbf
parent fc0458d3911bfc3a603a2f833a2ef514ad3cac0b
author Patrick McHardy <kaber@trash.net> Mon, 19 Nov 2007 12:42:59 +0100
committer Patrick McHardy <kaber@trash.net> Mon, 19 Nov 2007 12:42:59 +0100

 net/netlink/af_netlink.c |   81 ++++++++++++++++++++++++----------------------
 1 files changed, 43 insertions(+), 38 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index de3988b..1ae4024 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -156,7 +156,7 @@ static void netlink_sock_destruct(struct sock *sk)
 	skb_queue_purge(&sk->sk_receive_queue);
 
 	if (!sock_flag(sk, SOCK_DEAD)) {
-		printk("Freeing alive netlink socket %p\n", sk);
+		printk(KERN_ERR "Freeing alive netlink socket %p\n", sk);
 		return;
 	}
 	BUG_TRAP(!atomic_read(&sk->sk_rmem_alloc));
@@ -164,8 +164,8 @@ static void netlink_sock_destruct(struct sock *sk)
 	BUG_TRAP(!nlk_sk(sk)->groups);
 }
 
-/* This lock without WQ_FLAG_EXCLUSIVE is good on UP and it is _very_ bad on SMP.
- * Look, when several writers sleep and reader wakes them up, all but one
+/* This lock without WQ_FLAG_EXCLUSIVE is good on UP and it is _very_ bad on
+ * SMP. Look, when several writers sleep and reader wakes them up, all but one
  * immediately hit write lock and grab all the cpus. Exclusive sleep solves
  * this, _but_ remember, it adds useless work on UP machines.
  */
@@ -178,7 +178,7 @@ static void netlink_table_grab(void)
 		DECLARE_WAITQUEUE(wait, current);
 
 		add_wait_queue_exclusive(&nl_table_wait, &wait);
-		for(;;) {
+		for (;;) {
 			set_current_state(TASK_UNINTERRUPTIBLE);
 			if (atomic_read(&nl_table_users) == 0)
 				break;
@@ -192,13 +192,13 @@ static void netlink_table_grab(void)
 	}
 }
 
-static __inline__ void netlink_table_ungrab(void)
+static inline void netlink_table_ungrab(void)
 {
 	write_unlock_irq(&nl_table_lock);
 	wake_up(&nl_table_wait);
 }
 
-static __inline__ void
+static inline void
 netlink_lock_table(void)
 {
 	/* read_lock() synchronizes us to netlink_table_grab */
@@ -208,14 +208,15 @@ netlink_lock_table(void)
 	read_unlock(&nl_table_lock);
 }
 
-static __inline__ void
+static inline void
 netlink_unlock_table(void)
 {
 	if (atomic_dec_and_test(&nl_table_users))
 		wake_up(&nl_table_wait);
 }
 
-static __inline__ struct sock *netlink_lookup(struct net *net, int protocol, u32 pid)
+static inline struct sock *netlink_lookup(struct net *net, int protocol,
+					  u32 pid)
 {
 	struct nl_pid_hash *hash = &nl_table[protocol].hash;
 	struct hlist_head *head;
@@ -428,7 +429,7 @@ static int netlink_create(struct net *net, struct socket *sock, int protocol)
 	if (sock->type != SOCK_RAW && sock->type != SOCK_DGRAM)
 		return -ESOCKTNOSUPPORT;
 
-	if (protocol<0 || protocol >= MAX_LINKS)
+	if (protocol < 0 || protocol >= MAX_LINKS)
 		return -EPROTONOSUPPORT;
 
 	netlink_lock_table();
@@ -445,7 +446,8 @@ static int netlink_create(struct net *net, struct socket *sock, int protocol)
 	cb_mutex = nl_table[protocol].cb_mutex;
 	netlink_unlock_table();
 
-	if ((err = __netlink_create(net, sock, cb_mutex, protocol)) < 0)
+	err = __netlink_create(net, sock, cb_mutex, protocol);
+	if (err < 0)
 		goto out_module;
 
 	nlk = nlk_sk(sock->sk);
@@ -590,7 +592,7 @@ static int netlink_realloc_groups(struct sock *sk)
 		err = -ENOMEM;
 		goto out_unlock;
 	}
-	memset((char*)new_groups + NLGRPSZ(nlk->ngroups), 0,
+	memset((char *)new_groups + NLGRPSZ(nlk->ngroups), 0,
 	       NLGRPSZ(groups) - NLGRPSZ(nlk->ngroups));
 
 	nlk->groups = new_groups;
@@ -600,7 +602,8 @@ static int netlink_realloc_groups(struct sock *sk)
 	return err;
 }
 
-static int netlink_bind(struct socket *sock, struct sockaddr *addr, int addr_len)
+static int netlink_bind(struct socket *sock, struct sockaddr *addr,
+			int addr_len)
 {
 	struct sock *sk = sock->sk;
 	struct net *net = sk->sk_net;
@@ -651,7 +654,7 @@ static int netlink_connect(struct socket *sock, struct sockaddr *addr,
 	int err = 0;
 	struct sock *sk = sock->sk;
 	struct netlink_sock *nlk = nlk_sk(sk);
-	struct sockaddr_nl *nladdr=(struct sockaddr_nl*)addr;
+	struct sockaddr_nl *nladdr = (struct sockaddr_nl *)addr;
 
 	if (addr->sa_family == AF_UNSPEC) {
 		sk->sk_state	= NETLINK_UNCONNECTED;
@@ -678,11 +681,12 @@ static int netlink_connect(struct socket *sock, struct sockaddr *addr,
 	return err;
 }
 
-static int netlink_getname(struct socket *sock, struct sockaddr *addr, int *addr_len, int peer)
+static int netlink_getname(struct socket *sock, struct sockaddr *addr,
+			   int *addr_len, int peer)
 {
 	struct sock *sk = sock->sk;
 	struct netlink_sock *nlk = nlk_sk(sk);
-	struct sockaddr_nl *nladdr=(struct sockaddr_nl *)addr;
+	struct sockaddr_nl *nladdr = (struct sockaddr_nl *)addr;
 
 	nladdr->nl_family = AF_NETLINK;
 	nladdr->nl_pad = 0;
@@ -885,6 +889,7 @@ retry:
 
 	return netlink_sendskb(sk, skb);
 }
+EXPORT_SYMBOL(netlink_unicast);
 
 int netlink_has_listeners(struct sock *sk, unsigned int group)
 {
@@ -905,7 +910,8 @@ int netlink_has_listeners(struct sock *sk, unsigned int group)
 }
 EXPORT_SYMBOL_GPL(netlink_has_listeners);
 
-static __inline__ int netlink_broadcast_deliver(struct sock *sk, struct sk_buff *skb)
+static inline int netlink_broadcast_deliver(struct sock *sk,
+					    struct sk_buff *skb)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
 
@@ -1026,6 +1032,7 @@ int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 pid,
 		return -ENOBUFS;
 	return -ESRCH;
 }
+EXPORT_SYMBOL(netlink_broadcast);
 
 struct netlink_set_err_data {
 	struct sock *exclude_sk;
@@ -1182,7 +1189,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
 	struct netlink_sock *nlk = nlk_sk(sk);
-	struct sockaddr_nl *addr=msg->msg_name;
+	struct sockaddr_nl *addr = msg->msg_name;
 	u32 dst_pid;
 	u32 dst_group;
 	struct sk_buff *skb;
@@ -1221,7 +1228,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		goto out;
 	err = -ENOBUFS;
 	skb = alloc_skb(len, GFP_KERNEL);
-	if (skb==NULL)
+	if (skb == NULL)
 		goto out;
 
 	NETLINK_CB(skb).pid	= nlk->pid;
@@ -1237,7 +1244,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	 */
 
 	err = -EFAULT;
-	if (memcpy_fromiovec(skb_put(skb,len), msg->msg_iov, len)) {
+	if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
 		kfree_skb(skb);
 		goto out;
 	}
@@ -1276,8 +1283,8 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 
 	copied = 0;
 
-	skb = skb_recv_datagram(sk,flags,noblock,&err);
-	if (skb==NULL)
+	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	if (skb == NULL)
 		goto out;
 
 	msg->msg_namelen = 0;
@@ -1292,7 +1299,7 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
 
 	if (msg->msg_name) {
-		struct sockaddr_nl *addr = (struct sockaddr_nl*)msg->msg_name;
+		struct sockaddr_nl *addr = (struct sockaddr_nl *)msg->msg_name;
 		addr->nl_family = AF_NETLINK;
 		addr->nl_pad    = 0;
 		addr->nl_pid	= NETLINK_CB(skb).pid;
@@ -1344,7 +1351,7 @@ netlink_kernel_create(struct net *net, int unit, unsigned int groups,
 
 	BUG_ON(!nl_table);
 
-	if (unit<0 || unit>=MAX_LINKS)
+	if (unit < 0 || unit >= MAX_LINKS)
 		return NULL;
 
 	if (sock_create_lite(PF_NETLINK, SOCK_DGRAM, unit, &sock))
@@ -1390,6 +1397,7 @@ out_sock_release:
 	sock_release(sock);
 	return NULL;
 }
+EXPORT_SYMBOL(netlink_kernel_create);
 
 /**
  * netlink_change_ngroups - change number of multicast groups
@@ -1461,6 +1469,7 @@ void netlink_set_nonroot(int protocol, unsigned int flags)
 	if ((unsigned int)protocol < MAX_LINKS)
 		nl_table[protocol].nl_nonroot = flags;
 }
+EXPORT_SYMBOL(netlink_set_nonroot);
 
 static void netlink_destroy_callback(struct netlink_callback *cb)
 {
@@ -1529,8 +1538,9 @@ errout:
 
 int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 		       struct nlmsghdr *nlh,
-		       int (*dump)(struct sk_buff *skb, struct netlink_callback*),
-		       int (*done)(struct netlink_callback*))
+		       int (*dump)(struct sk_buff *skb,
+				   struct netlink_callback *),
+		       int (*done)(struct netlink_callback *))
 {
 	struct netlink_callback *cb;
 	struct sock *sk;
@@ -1571,6 +1581,7 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	 */
 	return -EINTR;
 }
+EXPORT_SYMBOL(netlink_dump_start);
 
 void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 {
@@ -1605,6 +1616,7 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 	memcpy(&errmsg->msg, nlh, err ? nlh->nlmsg_len : sizeof(*nlh));
 	netlink_unicast(in_skb->sk, skb, NETLINK_CB(in_skb).pid, MSG_DONTWAIT);
 }
+EXPORT_SYMBOL(netlink_ack);
 
 int netlink_rcv_skb(struct sk_buff *skb, int (*cb)(struct sk_buff *,
 						     struct nlmsghdr *))
@@ -1638,7 +1650,7 @@ ack:
 			netlink_ack(skb, nlh, err);
 
 skip:
-	        msglen = NLMSG_ALIGN(nlh->nlmsg_len);
+		msglen = NLMSG_ALIGN(nlh->nlmsg_len);
 		if (msglen > skb->len)
 			msglen = skb->len;
 		skb_pull(skb, msglen);
@@ -1646,6 +1658,7 @@ skip:
 
 	return 0;
 }
+EXPORT_SYMBOL(netlink_rcv_skb);
 
 /**
  * nlmsg_notify - send a notification netlink message
@@ -1678,6 +1691,7 @@ int nlmsg_notify(struct sock *sk, struct sk_buff *skb, u32 pid,
 
 	return err;
 }
+EXPORT_SYMBOL(nlmsg_notify);
 
 #ifdef CONFIG_PROC_FS
 struct nl_seq_iter {
@@ -1694,7 +1708,7 @@ static struct sock *netlink_seq_socket_idx(struct seq_file *seq, loff_t pos)
 	struct hlist_node *node;
 	loff_t off = 0;
 
-	for (i=0; i<MAX_LINKS; i++) {
+	for (i = 0; i < MAX_LINKS; i++) {
 		struct nl_pid_hash *hash = &nl_table[i].hash;
 
 		for (j = 0; j <= hash->mask; j++) {
@@ -1839,11 +1853,13 @@ int netlink_register_notifier(struct notifier_block *nb)
 {
 	return atomic_notifier_chain_register(&netlink_chain, nb);
 }
+EXPORT_SYMBOL(netlink_register_notifier);
 
 int netlink_unregister_notifier(struct notifier_block *nb)
 {
 	return atomic_notifier_chain_unregister(&netlink_chain, nb);
 }
+EXPORT_SYMBOL(netlink_unregister_notifier);
 
 static const struct proto_ops netlink_ops = {
 	.family =	PF_NETLINK,
@@ -1948,14 +1964,3 @@ panic:
 }
 
 core_initcall(netlink_proto_init);
-
-EXPORT_SYMBOL(netlink_ack);
-EXPORT_SYMBOL(netlink_rcv_skb);
-EXPORT_SYMBOL(netlink_broadcast);
-EXPORT_SYMBOL(netlink_dump_start);
-EXPORT_SYMBOL(netlink_kernel_create);
-EXPORT_SYMBOL(netlink_register_notifier);
-EXPORT_SYMBOL(netlink_set_nonroot);
-EXPORT_SYMBOL(netlink_unicast);
-EXPORT_SYMBOL(netlink_unregister_notifier);
-EXPORT_SYMBOL(nlmsg_notify);

--------------000505010601020605080302--
