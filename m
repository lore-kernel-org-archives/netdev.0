From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] netlink: convert DIY reader/writer to mutex and RCU
Date: Mon, 8 Mar 2010 13:32:11 -0800
Message-ID: <20100308133211.4f157e2d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34229 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753798Ab0CHVc2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Mar 2010 16:32:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The netlink table locking was open coded of reader/writer
sleeping lock.  Change to using mutex and RCU which makes
code clearer, shorter, and simpler.

The genetlink code is simplified because it is allowable
to acquire mutex with RCU lock.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/linux/netlink.h  |    3 
 include/net/sock.h       |    2 
 net/netlink/af_netlink.c |  146 ++++++++++++++---------------------------------
 net/netlink/genetlink.c  |    4 -
 4 files changed, 47 insertions(+), 108 deletions(-)

--- a/net/netlink/af_netlink.c	2010-03-08 09:07:15.104547875 -0800
+++ b/net/netlink/af_netlink.c	2010-03-08 11:02:01.263297712 -0800
@@ -128,15 +128,11 @@ struct netlink_table {
 };
 
 static struct netlink_table *nl_table;
-
-static DECLARE_WAIT_QUEUE_HEAD(nl_table_wait);
+static DEFINE_MUTEX(nltable_mutex);
 
 static int netlink_dump(struct sock *sk);
 static void netlink_destroy_callback(struct netlink_callback *cb);
 
-static DEFINE_RWLOCK(nl_table_lock);
-static atomic_t nl_table_users = ATOMIC_INIT(0);
-
 static ATOMIC_NOTIFIER_HEAD(netlink_chain);
 
 static u32 netlink_group_mask(u32 group)
@@ -171,61 +167,6 @@ static void netlink_sock_destruct(struct
 	WARN_ON(nlk_sk(sk)->groups);
 }
 
-/* This lock without WQ_FLAG_EXCLUSIVE is good on UP and it is _very_ bad on
- * SMP. Look, when several writers sleep and reader wakes them up, all but one
- * immediately hit write lock and grab all the cpus. Exclusive sleep solves
- * this, _but_ remember, it adds useless work on UP machines.
- */
-
-void netlink_table_grab(void)
-	__acquires(nl_table_lock)
-{
-	might_sleep();
-
-	write_lock_irq(&nl_table_lock);
-
-	if (atomic_read(&nl_table_users)) {
-		DECLARE_WAITQUEUE(wait, current);
-
-		add_wait_queue_exclusive(&nl_table_wait, &wait);
-		for (;;) {
-			set_current_state(TASK_UNINTERRUPTIBLE);
-			if (atomic_read(&nl_table_users) == 0)
-				break;
-			write_unlock_irq(&nl_table_lock);
-			schedule();
-			write_lock_irq(&nl_table_lock);
-		}
-
-		__set_current_state(TASK_RUNNING);
-		remove_wait_queue(&nl_table_wait, &wait);
-	}
-}
-
-void netlink_table_ungrab(void)
-	__releases(nl_table_lock)
-{
-	write_unlock_irq(&nl_table_lock);
-	wake_up(&nl_table_wait);
-}
-
-static inline void
-netlink_lock_table(void)
-{
-	/* read_lock() synchronizes us to netlink_table_grab */
-
-	read_lock(&nl_table_lock);
-	atomic_inc(&nl_table_users);
-	read_unlock(&nl_table_lock);
-}
-
-static inline void
-netlink_unlock_table(void)
-{
-	if (atomic_dec_and_test(&nl_table_users))
-		wake_up(&nl_table_wait);
-}
-
 static inline struct sock *netlink_lookup(struct net *net, int protocol,
 					  u32 pid)
 {
@@ -234,9 +175,9 @@ static inline struct sock *netlink_looku
 	struct sock *sk;
 	struct hlist_node *node;
 
-	read_lock(&nl_table_lock);
+	rcu_read_lock();
 	head = nl_pid_hashfn(hash, pid);
-	sk_for_each(sk, node, head) {
+	sk_for_each_rcu(sk, node, head) {
 		if (net_eq(sock_net(sk), net) && (nlk_sk(sk)->pid == pid)) {
 			sock_hold(sk);
 			goto found;
@@ -244,7 +185,7 @@ static inline struct sock *netlink_looku
 	}
 	sk = NULL;
 found:
-	read_unlock(&nl_table_lock);
+	rcu_read_unlock();
 	return sk;
 }
 
@@ -353,7 +294,7 @@ static int netlink_insert(struct sock *s
 	struct hlist_node *node;
 	int len;
 
-	netlink_table_grab();
+	mutex_lock(&nltable_mutex);
 	head = nl_pid_hashfn(hash, pid);
 	len = 0;
 	sk_for_each(osk, node, head) {
@@ -380,18 +321,18 @@ static int netlink_insert(struct sock *s
 	err = 0;
 
 err:
-	netlink_table_ungrab();
+	mutex_unlock(&nltable_mutex);
 	return err;
 }
 
 static void netlink_remove(struct sock *sk)
 {
-	netlink_table_grab();
+	mutex_lock(&nltable_mutex);
 	if (sk_del_node_init(sk))
 		nl_table[sk->sk_protocol].hash.entries--;
 	if (nlk_sk(sk)->subscriptions)
 		__sk_del_bind_node(sk);
-	netlink_table_ungrab();
+	mutex_unlock(&nltable_mutex);
 }
 
 static struct proto netlink_proto = {
@@ -444,12 +385,14 @@ static int netlink_create(struct net *ne
 	if (protocol < 0 || protocol >= MAX_LINKS)
 		return -EPROTONOSUPPORT;
 
-	netlink_lock_table();
+	mutex_lock(&nltable_mutex);
 #ifdef CONFIG_MODULES
 	if (!nl_table[protocol].registered) {
-		netlink_unlock_table();
+		mutex_unlock(&nltable_mutex);
+
 		request_module("net-pf-%d-proto-%d", PF_NETLINK, protocol);
-		netlink_lock_table();
+
+		mutex_lock(&nltable_mutex);
 	}
 #endif
 	if (nl_table[protocol].registered &&
@@ -458,7 +401,7 @@ static int netlink_create(struct net *ne
 	else
 		err = -EPROTONOSUPPORT;
 	cb_mutex = nl_table[protocol].cb_mutex;
-	netlink_unlock_table();
+	mutex_unlock(&nltable_mutex);
 
 	if (err < 0)
 		goto out;
@@ -515,7 +458,7 @@ static int netlink_release(struct socket
 
 	module_put(nlk->module);
 
-	netlink_table_grab();
+	mutex_lock(&nltable_mutex);
 	if (netlink_is_kernel(sk)) {
 		BUG_ON(nl_table[sk->sk_protocol].registered == 0);
 		if (--nl_table[sk->sk_protocol].registered == 0) {
@@ -525,7 +468,7 @@ static int netlink_release(struct socket
 		}
 	} else if (nlk->subscriptions)
 		netlink_update_listeners(sk);
-	netlink_table_ungrab();
+	mutex_unlock(&nltable_mutex);
 
 	kfree(nlk->groups);
 	nlk->groups = NULL;
@@ -533,6 +476,8 @@ static int netlink_release(struct socket
 	local_bh_disable();
 	sock_prot_inuse_add(sock_net(sk), &netlink_proto, -1);
 	local_bh_enable();
+
+	synchronize_rcu();
 	sock_put(sk);
 	return 0;
 }
@@ -551,7 +496,7 @@ static int netlink_autobind(struct socke
 
 retry:
 	cond_resched();
-	netlink_table_grab();
+	mutex_lock(&nltable_mutex);
 	head = nl_pid_hashfn(hash, pid);
 	sk_for_each(osk, node, head) {
 		if (!net_eq(sock_net(osk), net))
@@ -561,11 +506,11 @@ retry:
 			pid = rover--;
 			if (rover > -4097)
 				rover = -4097;
-			netlink_table_ungrab();
+			mutex_unlock(&nltable_mutex);
 			goto retry;
 		}
 	}
-	netlink_table_ungrab();
+	mutex_unlock(&nltable_mutex);
 
 	err = netlink_insert(sk, net, pid);
 	if (err == -EADDRINUSE)
@@ -603,7 +548,7 @@ static int netlink_realloc_groups(struct
 	unsigned long *new_groups;
 	int err = 0;
 
-	netlink_table_grab();
+	mutex_lock(&nltable_mutex);
 
 	groups = nl_table[sk->sk_protocol].groups;
 	if (!nl_table[sk->sk_protocol].registered) {
@@ -625,7 +570,7 @@ static int netlink_realloc_groups(struct
 	nlk->groups = new_groups;
 	nlk->ngroups = groups;
  out_unlock:
-	netlink_table_ungrab();
+	mutex_unlock(&nltable_mutex);
 	return err;
 }
 
@@ -664,13 +609,13 @@ static int netlink_bind(struct socket *s
 	if (!nladdr->nl_groups && (nlk->groups == NULL || !(u32)nlk->groups[0]))
 		return 0;
 
-	netlink_table_grab();
+	mutex_lock(&nltable_mutex);
 	netlink_update_subscriptions(sk, nlk->subscriptions +
 					 hweight32(nladdr->nl_groups) -
 					 hweight32(nlk->groups[0]));
 	nlk->groups[0] = (nlk->groups[0] & ~0xffffffffUL) | nladdr->nl_groups;
 	netlink_update_listeners(sk);
-	netlink_table_ungrab();
+	mutex_unlock(&nltable_mutex);
 
 	return 0;
 }
@@ -1059,15 +1004,12 @@ int netlink_broadcast(struct sock *ssk, 
 
 	/* While we sleep in clone, do not allow to change socket list */
 
-	netlink_lock_table();
-
-	sk_for_each_bound(sk, node, &nl_table[ssk->sk_protocol].mc_list)
+	rcu_read_lock();
+	sk_for_each_bound_rcu(sk, node, &nl_table[ssk->sk_protocol].mc_list)
 		do_one_broadcast(sk, &info);
+	rcu_read_unlock();
 
 	kfree_skb(skb);
-
-	netlink_unlock_table();
-
 	kfree_skb(info.skb2);
 
 	if (info.delivery_failure)
@@ -1129,12 +1071,12 @@ void netlink_set_err(struct sock *ssk, u
 	/* sk->sk_err wants a positive error value */
 	info.code = -code;
 
-	read_lock(&nl_table_lock);
+	rcu_read_lock();
 
-	sk_for_each_bound(sk, node, &nl_table[ssk->sk_protocol].mc_list)
+	sk_for_each_bound_rcu(sk, node, &nl_table[ssk->sk_protocol].mc_list)
 		do_one_set_err(sk, &info);
 
-	read_unlock(&nl_table_lock);
+	rcu_read_unlock();
 }
 EXPORT_SYMBOL(netlink_set_err);
 
@@ -1187,10 +1129,10 @@ static int netlink_setsockopt(struct soc
 			return err;
 		if (!val || val - 1 >= nlk->ngroups)
 			return -EINVAL;
-		netlink_table_grab();
+		mutex_lock(&nltable_mutex);
 		netlink_update_socket_mc(nlk, val,
 					 optname == NETLINK_ADD_MEMBERSHIP);
-		netlink_table_ungrab();
+		mutex_unlock(&nltable_mutex);
 		err = 0;
 		break;
 	}
@@ -1515,7 +1457,7 @@ netlink_kernel_create(struct net *net, i
 	nlk = nlk_sk(sk);
 	nlk->flags |= NETLINK_KERNEL_SOCKET;
 
-	netlink_table_grab();
+	mutex_lock(&nltable_mutex);
 	if (!nl_table[unit].registered) {
 		nl_table[unit].groups = groups;
 		nl_table[unit].listeners = listeners;
@@ -1526,7 +1468,7 @@ netlink_kernel_create(struct net *net, i
 		kfree(listeners);
 		nl_table[unit].registered++;
 	}
-	netlink_table_ungrab();
+	mutex_unlock(&nltable_mutex);
 	return sk;
 
 out_sock_release:
@@ -1557,7 +1499,7 @@ static void netlink_free_old_listeners(s
 	kfree(lrh->ptr);
 }
 
-int __netlink_change_ngroups(struct sock *sk, unsigned int groups)
+static int __netlink_change_ngroups(struct sock *sk, unsigned int groups)
 {
 	unsigned long *listeners, *old = NULL;
 	struct listeners_rcu_head *old_rcu_head;
@@ -1608,14 +1550,14 @@ int netlink_change_ngroups(struct sock *
 {
 	int err;
 
-	netlink_table_grab();
+	mutex_lock(&nltable_mutex);
 	err = __netlink_change_ngroups(sk, groups);
-	netlink_table_ungrab();
+	mutex_unlock(&nltable_mutex);
 
 	return err;
 }
 
-void __netlink_clear_multicast_users(struct sock *ksk, unsigned int group)
+static void __netlink_clear_multicast_users(struct sock *ksk, unsigned int group)
 {
 	struct sock *sk;
 	struct hlist_node *node;
@@ -1635,9 +1577,9 @@ void __netlink_clear_multicast_users(str
  */
 void netlink_clear_multicast_users(struct sock *ksk, unsigned int group)
 {
-	netlink_table_grab();
+	mutex_lock(&nltable_mutex);
 	__netlink_clear_multicast_users(ksk, group);
-	netlink_table_ungrab();
+	mutex_unlock(&nltable_mutex);
 }
 
 void netlink_set_nonroot(int protocol, unsigned int flags)
@@ -1902,7 +1844,7 @@ static struct sock *netlink_seq_socket_i
 		struct nl_pid_hash *hash = &nl_table[i].hash;
 
 		for (j = 0; j <= hash->mask; j++) {
-			sk_for_each(s, node, &hash->table[j]) {
+			sk_for_each_rcu(s, node, &hash->table[j]) {
 				if (sock_net(s) != seq_file_net(seq))
 					continue;
 				if (off == pos) {
@@ -1918,9 +1860,9 @@ static struct sock *netlink_seq_socket_i
 }
 
 static void *netlink_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(nl_table_lock)
+	__acquires(RCU)
 {
-	read_lock(&nl_table_lock);
+	rcu_read_lock();
 	return *pos ? netlink_seq_socket_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 }
 
@@ -1967,9 +1909,9 @@ static void *netlink_seq_next(struct seq
 }
 
 static void netlink_seq_stop(struct seq_file *seq, void *v)
-	__releases(nl_table_lock)
+	__releases(RCU)
 {
-	read_unlock(&nl_table_lock);
+	rcu_read_unlock();
 }
 
 
--- a/include/net/sock.h	2010-03-08 10:52:34.113924084 -0800
+++ b/include/net/sock.h	2010-03-08 10:52:50.222986495 -0800
@@ -507,6 +507,8 @@ static __inline__ void sk_add_bind_node(
 	hlist_for_each_entry_safe(__sk, node, tmp, list, sk_node)
 #define sk_for_each_bound(__sk, node, list) \
 	hlist_for_each_entry(__sk, node, list, sk_bind_node)
+#define sk_for_each_bound_rcu(__sk, node, list) \
+	hlist_for_each_entry_rcu(__sk, node, list, sk_bind_node)
 
 /* Sock flags */
 enum sock_flags {
--- a/include/linux/netlink.h	2010-03-08 10:56:35.314235687 -0800
+++ b/include/linux/netlink.h	2010-03-08 11:04:33.414547616 -0800
@@ -170,18 +170,13 @@ struct netlink_skb_parms {
 #define NETLINK_CREDS(skb)	(&NETLINK_CB((skb)).creds)
 
 
-extern void netlink_table_grab(void);
-extern void netlink_table_ungrab(void);
-
 extern struct sock *netlink_kernel_create(struct net *net,
 					  int unit,unsigned int groups,
 					  void (*input)(struct sk_buff *skb),
 					  struct mutex *cb_mutex,
 					  struct module *module);
 extern void netlink_kernel_release(struct sock *sk);
-extern int __netlink_change_ngroups(struct sock *sk, unsigned int groups);
 extern int netlink_change_ngroups(struct sock *sk, unsigned int groups);
-extern void __netlink_clear_multicast_users(struct sock *sk, unsigned int group);
 extern void netlink_clear_multicast_users(struct sock *sk, unsigned int group);
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_has_listeners(struct sock *sk, unsigned int group);
--- a/net/netlink/genetlink.c	2010-03-08 10:56:02.194547526 -0800
+++ b/net/netlink/genetlink.c	2010-03-08 11:01:05.865177057 -0800
@@ -168,10 +168,9 @@ int genl_register_mc_group(struct genl_f
 	if (family->netnsok) {
 		struct net *net;
 
-		netlink_table_grab();
 		rcu_read_lock();
 		for_each_net_rcu(net) {
-			err = __netlink_change_ngroups(net->genl_sock,
+			err = netlink_change_ngroups(net->genl_sock,
 					mc_groups_longs * BITS_PER_LONG);
 			if (err) {
 				/*
@@ -181,12 +180,10 @@ int genl_register_mc_group(struct genl_f
 				 * increased on some sockets which is ok.
 				 */
 				rcu_read_unlock();
-				netlink_table_ungrab();
 				goto out;
 			}
 		}
 		rcu_read_unlock();
-		netlink_table_ungrab();
 	} else {
 		err = netlink_change_ngroups(init_net.genl_sock,
 					     mc_groups_longs * BITS_PER_LONG);
@@ -212,12 +209,10 @@ static void __genl_unregister_mc_group(s
 	struct net *net;
 	BUG_ON(grp->family != family);
 
-	netlink_table_grab();
 	rcu_read_lock();
 	for_each_net_rcu(net)
-		__netlink_clear_multicast_users(net->genl_sock, grp->id);
+		netlink_clear_multicast_users(net->genl_sock, grp->id);
 	rcu_read_unlock();
-	netlink_table_ungrab();
 
 	clear_bit(grp->id, mc_groups);
 	list_del(&grp->list);
