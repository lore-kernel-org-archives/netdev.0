From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [RFC] netlink: get rid of nl_table_lock
Date: Sat, 3 Jan 2015 11:02:11 -0800
Message-ID: <20150103110211.18b11f0f@urahara>
References: <cover.1420230585.git.tgraf@suug.ch>
	<daae84cd33bfde8518b849176e25dcf3eea8014b.1420230585.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	paulmck@linux.vnet.ibm.com, edumazet@google.com,
	john.r.fastabend@intel.com, josh@joshtriplett.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <daae84cd33bfde8518b849176e25dcf3eea8014b.1420230585.git.tgraf@suug.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As a follow on to Thomas's patch I think this would complete the
transistion to RCU for netlink.
Compile tested only.



This patch gets rid of the reader/writer nl_table_lock and replaces it
with exclusively using RCU for reading, and a mutex for writing.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/include/net/sock.h	2015-01-01 10:05:35.805253771 -0800
+++ b/include/net/sock.h	2015-01-03 10:45:29.661737618 -0800
@@ -666,6 +666,8 @@ static inline void sk_add_bind_node(stru
 	hlist_for_each_entry_safe(__sk, tmp, list, sk_node)
 #define sk_for_each_bound(__sk, list) \
 	hlist_for_each_entry(__sk, list, sk_bind_node)
+#define sk_for_each_bound_rcu(__sk, list) \
+	hlist_for_each_entry_rcu(__sk, list, sk_bind_node)
 
 /**
  * sk_nulls_for_each_entry_offset - iterate over a list at a given struct offset
--- a/net/netlink/af_netlink.c	2015-01-03 10:04:37.738319202 -0800
+++ b/net/netlink/af_netlink.c	2015-01-03 10:53:29.568387253 -0800
@@ -100,15 +100,14 @@ static void netlink_skb_destructor(struc
  * Lookup and traversal are protected with an RCU read-side lock. Insertion
  * and removal are protected with nl_sk_hash_lock while using RCU list
  * modification primitives and may run in parallel to RCU protected lookups.
- * Destruction of the Netlink socket may only occur *after* nl_table_lock has
+ * Destruction of the Netlink socket may only occur *after* nl_table_mutex has
  * been acquired * either during or after the socket has been removed from
  * the list and after an RCU grace period.
  */
-DEFINE_RWLOCK(nl_table_lock);
-EXPORT_SYMBOL_GPL(nl_table_lock);
-static atomic_t nl_table_users = ATOMIC_INIT(0);
+static DEFINE_MUTEX(nl_table_mutex);
 
-#define nl_deref_protected(X) rcu_dereference_protected(X, lockdep_is_held(&nl_table_lock));
+#define nl_deref_protected(X) \
+	rcu_dereference_protected(X, lockdep_is_held(&nl_table_mutex))
 
 /* Protects netlink socket hash table mutations */
 DEFINE_MUTEX(nl_sk_hash_lock);
@@ -118,7 +117,8 @@ EXPORT_SYMBOL_GPL(nl_sk_hash_lock);
 static int lockdep_nl_sk_hash_is_held(void *parent)
 {
 	if (debug_locks)
-		return lockdep_is_held(&nl_sk_hash_lock) || lockdep_is_held(&nl_table_lock);
+		return lockdep_is_held(&nl_sk_hash_lock) ||
+			lockdep_is_held(&nl_table_mutex);
 	return 1;
 }
 #endif
@@ -925,59 +925,14 @@ static void netlink_sock_destruct(struct
 	WARN_ON(nlk_sk(sk)->groups);
 }
 
-/* This lock without WQ_FLAG_EXCLUSIVE is good on UP and it is _very_ bad on
- * SMP. Look, when several writers sleep and reader wakes them up, all but one
- * immediately hit write lock and grab all the cpus. Exclusive sleep solves
- * this, _but_ remember, it adds useless work on UP machines.
- */
-
 void netlink_table_grab(void)
-	__acquires(nl_table_lock)
 {
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
+	mutex_lock(&nl_table_mutex);
 }
 
 void netlink_table_ungrab(void)
-	__releases(nl_table_lock)
-{
-	write_unlock_irq(&nl_table_lock);
-	wake_up(&nl_table_wait);
-}
-
-static inline void
-netlink_lock_table(void)
 {
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
+	mutex_unlock(&nl_table_mutex);
 }
 
 struct netlink_compare_arg
@@ -1151,12 +1106,12 @@ static int netlink_create(struct net *ne
 	if (protocol < 0 || protocol >= MAX_LINKS)
 		return -EPROTONOSUPPORT;
 
-	netlink_lock_table();
+	mutex_lock(&nl_table_mutex);
 #ifdef CONFIG_MODULES
 	if (!nl_table[protocol].registered) {
-		netlink_unlock_table();
+		mutex_unlock(&nl_table_mutex);
 		request_module("net-pf-%d-proto-%d", PF_NETLINK, protocol);
-		netlink_lock_table();
+		mutex_lock(&nl_table_mutex);
 	}
 #endif
 	if (nl_table[protocol].registered &&
@@ -1167,7 +1122,7 @@ static int netlink_create(struct net *ne
 	cb_mutex = nl_table[protocol].cb_mutex;
 	bind = nl_table[protocol].bind;
 	unbind = nl_table[protocol].unbind;
-	netlink_unlock_table();
+	mutex_unlock(&nl_table_mutex);
 
 	if (err < 0)
 		goto out;
@@ -1982,17 +1937,13 @@ int netlink_broadcast_filtered(struct so
 	info.tx_filter = filter;
 	info.tx_data = filter_data;
 
-	/* While we sleep in clone, do not allow to change socket list */
-
-	netlink_lock_table();
-
-	sk_for_each_bound(sk, &nl_table[ssk->sk_protocol].mc_list)
+	rcu_read_lock();
+	sk_for_each_bound_rcu(sk, &nl_table[ssk->sk_protocol].mc_list)
 		do_one_broadcast(sk, &info);
+	rcu_read_unlock();
 
 	consume_skb(skb);
 
-	netlink_unlock_table();
-
 	if (info.delivery_failure) {
 		kfree_skb(info.skb2);
 		return -ENOBUFS;
@@ -2071,12 +2022,11 @@ int netlink_set_err(struct sock *ssk, u3
 	/* sk->sk_err wants a positive error value */
 	info.code = -code;
 
-	read_lock(&nl_table_lock);
-
-	sk_for_each_bound(sk, &nl_table[ssk->sk_protocol].mc_list)
+	rcu_read_lock();
+	sk_for_each_bound_rcu(sk, &nl_table[ssk->sk_protocol].mc_list)
 		ret += do_one_set_err(sk, &info);
+	rcu_read_unlock();
 
-	read_unlock(&nl_table_lock);
 	return ret;
 }
 EXPORT_SYMBOL(netlink_set_err);
--- a/net/netlink/diag.c	2014-08-09 08:39:57.756179454 -0700
+++ b/net/netlink/diag.c	2015-01-03 10:57:31.113791535 -0800
@@ -136,7 +136,7 @@ static int __netlink_diag_dump(struct sk
 		}
 	}
 
-	sk_for_each_bound(sk, &tbl->mc_list) {
+	sk_for_each_bound_rcu(sk, &tbl->mc_list) {
 		if (sk_hashed(sk))
 			continue;
 		if (!net_eq(sock_net(sk), net))
@@ -171,7 +171,7 @@ static int netlink_diag_dump(struct sk_b
 	req = nlmsg_data(cb->nlh);
 
 	mutex_lock(&nl_sk_hash_lock);
-	read_lock(&nl_table_lock);
+	rcu_read_lock();
 
 	if (req->sdiag_protocol == NDIAG_PROTO_ALL) {
 		int i;
@@ -183,7 +183,7 @@ static int netlink_diag_dump(struct sk_b
 		}
 	} else {
 		if (req->sdiag_protocol >= MAX_LINKS) {
-			read_unlock(&nl_table_lock);
+			rcu_read_unlock();
 			mutex_unlock(&nl_sk_hash_lock);
 			return -ENOENT;
 		}
@@ -191,7 +191,7 @@ static int netlink_diag_dump(struct sk_b
 		__netlink_diag_dump(skb, cb, req->sdiag_protocol, s_num);
 	}
 
-	read_unlock(&nl_table_lock);
+	rcu_read_unlock();
 	mutex_unlock(&nl_sk_hash_lock);
 
 	return skb->len;
