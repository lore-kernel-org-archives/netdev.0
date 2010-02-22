From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/3] af_key: locking change
Date: Mon, 22 Feb 2010 09:57:19 -0800
Message-ID: <20100222175742.761539214@vyatta.com>
References: <20100222175716.900955428@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46598 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752641Ab0BVR7H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2010 12:59:07 -0500
Content-Disposition: inline; filename=pfkey-rcu.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of custom locking that was using wait queue, lock, and atomic
to basically build a queued mutex.  Use RCU for read side.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/key/af_key.c	2010-02-22 09:19:03.242742827 -0800
+++ b/net/key/af_key.c	2010-02-22 09:22:53.921492802 -0800
@@ -41,9 +41,7 @@ struct netns_pfkey {
 	struct hlist_head table;
 	atomic_t socks_nr;
 };
-static DECLARE_WAIT_QUEUE_HEAD(pfkey_table_wait);
-static DEFINE_RWLOCK(pfkey_table_lock);
-static atomic_t pfkey_table_users = ATOMIC_INIT(0);
+static DEFINE_MUTEX(pfkey_mutex);
 
 struct pfkey_sock {
 	/* struct sock must be the first member of struct pfkey_sock */
@@ -108,50 +106,6 @@ static void pfkey_sock_destruct(struct s
 	atomic_dec(&net_pfkey->socks_nr);
 }
 
-static void pfkey_table_grab(void)
-{
-	write_lock_bh(&pfkey_table_lock);
-
-	if (atomic_read(&pfkey_table_users)) {
-		DECLARE_WAITQUEUE(wait, current);
-
-		add_wait_queue_exclusive(&pfkey_table_wait, &wait);
-		for(;;) {
-			set_current_state(TASK_UNINTERRUPTIBLE);
-			if (atomic_read(&pfkey_table_users) == 0)
-				break;
-			write_unlock_bh(&pfkey_table_lock);
-			schedule();
-			write_lock_bh(&pfkey_table_lock);
-		}
-
-		__set_current_state(TASK_RUNNING);
-		remove_wait_queue(&pfkey_table_wait, &wait);
-	}
-}
-
-static __inline__ void pfkey_table_ungrab(void)
-{
-	write_unlock_bh(&pfkey_table_lock);
-	wake_up(&pfkey_table_wait);
-}
-
-static __inline__ void pfkey_lock_table(void)
-{
-	/* read_lock() synchronizes us to pfkey_table_grab */
-
-	read_lock(&pfkey_table_lock);
-	atomic_inc(&pfkey_table_users);
-	read_unlock(&pfkey_table_lock);
-}
-
-static __inline__ void pfkey_unlock_table(void)
-{
-	if (atomic_dec_and_test(&pfkey_table_users))
-		wake_up(&pfkey_table_wait);
-}
-
-
 static const struct proto_ops pfkey_ops;
 
 static void pfkey_insert(struct sock *sk)
@@ -159,16 +113,16 @@ static void pfkey_insert(struct sock *sk
 	struct net *net = sock_net(sk);
 	struct netns_pfkey *net_pfkey = net_generic(net, pfkey_net_id);
 
-	pfkey_table_grab();
-	sk_add_node(sk, &net_pfkey->table);
-	pfkey_table_ungrab();
+	mutex_lock(&pfkey_mutex);
+	sk_add_node_rcu(sk, &net_pfkey->table);
+	mutex_unlock(&pfkey_mutex);
 }
 
 static void pfkey_remove(struct sock *sk)
 {
-	pfkey_table_grab();
-	sk_del_node_init(sk);
-	pfkey_table_ungrab();
+	mutex_lock(&pfkey_mutex);
+	sk_del_node_init_rcu(sk);
+	mutex_unlock(&pfkey_mutex);
 }
 
 static struct proto key_proto = {
@@ -223,6 +177,8 @@ static int pfkey_release(struct socket *
 	sock_orphan(sk);
 	sock->sk = NULL;
 	skb_queue_purge(&sk->sk_write_queue);
+
+	synchronize_rcu();
 	sock_put(sk);
 
 	return 0;
@@ -277,8 +233,8 @@ static int pfkey_broadcast(struct sk_buf
 	if (!skb)
 		return -ENOMEM;
 
-	pfkey_lock_table();
-	sk_for_each(sk, node, &net_pfkey->table) {
+	rcu_read_lock();
+	sk_for_each_rcu(sk, node, &net_pfkey->table) {
 		struct pfkey_sock *pfk = pfkey_sk(sk);
 		int err2;
 
@@ -309,7 +265,7 @@ static int pfkey_broadcast(struct sk_buf
 		if ((broadcast_flags & BROADCAST_REGISTERED) && err)
 			err = err2;
 	}
-	pfkey_unlock_table();
+	rcu_read_unlock();
 
 	if (one_sk != NULL)
 		err = pfkey_broadcast_one(skb, &skb2, allocation, one_sk);
@@ -3702,8 +3658,8 @@ static void *pfkey_seq_start(struct seq_
 	struct net *net = seq_file_net(f);
 	struct netns_pfkey *net_pfkey = net_generic(net, pfkey_net_id);
 
-	read_lock(&pfkey_table_lock);
-	return seq_hlist_start_head(&net_pfkey->table, *ppos);
+	rcu_read_lock();
+	return seq_hlist_start_head_rcu(&net_pfkey->table, *ppos);
 }
 
 static void *pfkey_seq_next(struct seq_file *f, void *v, loff_t *ppos)
@@ -3711,12 +3667,12 @@ static void *pfkey_seq_next(struct seq_f
 	struct net *net = seq_file_net(f);
 	struct netns_pfkey *net_pfkey = net_generic(net, pfkey_net_id);
 
-	return seq_hlist_next(v, &net_pfkey->table, ppos);
+	return seq_hlist_next_rcu(v, &net_pfkey->table, ppos);
 }
 
 static void pfkey_seq_stop(struct seq_file *f, void *v)
 {
-	read_unlock(&pfkey_table_lock);
+	rcu_read_unlock();
 }
 
 static const struct seq_operations pfkey_seq_ops = {

-- 

