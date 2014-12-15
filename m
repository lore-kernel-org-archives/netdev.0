From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 9/9] netlink: Lockless lookup with RCU grace period in socket release
Date: Mon, 15 Dec 2014 13:51:11 +0100
Message-ID: <b33deb0e9b5637617b7769d10c1c11ac56dbcc4c.1418647641.git.tgraf@suug.ch>
References: <cover.1418647641.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, kernel@vger.kernel.org,
	herbert@gondor.apana.org.au, paulmck@linux.vnet.ibm.com,
	edumazet@google.com, john.r.fastabend@intel.com,
	josh@joshtriplett.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38920 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbaLOMvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 07:51:19 -0500
In-Reply-To: <cover.1418647641.git.tgraf@suug.ch>
In-Reply-To: <cover.1418647641.git.tgraf@suug.ch>
References: <cover.1418647641.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Defers the release of the socket reference using call_rcu() to
allow using an RCU read-side protected call to rhashtable_lookup()

This restores behaviour and performance gains as previously
introduced by e341694 ("netlink: Convert netlink_lookup() to use
RCU protected hash table") without the side effect of severely
delayed socket destruction.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/netlink/af_netlink.c | 32 ++++++++++++++++----------------
 net/netlink/af_netlink.h |  1 +
 2 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index b38b148..4ad23f9 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -97,12 +97,12 @@ static int netlink_dump(struct sock *sk);
 static void netlink_skb_destructor(struct sk_buff *skb);
 
 /* nl_table locking explained:
- * Lookup and traversal are protected with nl_sk_hash_lock or nl_table_lock
- * combined with an RCU read-side lock. Insertion and removal are protected
- * with nl_sk_hash_lock while using RCU list modification primitives and may
- * run in parallel to nl_table_lock protected lookups. Destruction of the
- * Netlink socket may only occur *after* nl_table_lock has been acquired
- * either during or after the socket has been removed from the list.
+ * Lookup and traversal are protected with an RCU read-side lock. Insertion
+ * and removal are protected with nl_sk_hash_lock while using RCU list
+ * modification primitives and may run in parallel to RCU protected lookups.
+ * Destruction of the Netlink socket may only occur *after* nl_table_lock has
+ * been acquired * either during or after the socket has been removed from
+ * the list and after an RCU grace period.
  */
 DEFINE_RWLOCK(nl_table_lock);
 EXPORT_SYMBOL_GPL(nl_table_lock);
@@ -1023,13 +1023,11 @@ static struct sock *netlink_lookup(struct net *net, int protocol, u32 portid)
 	struct netlink_table *table = &nl_table[protocol];
 	struct sock *sk;
 
-	read_lock(&nl_table_lock);
 	rcu_read_lock();
 	sk = __netlink_lookup(table, portid, net);
 	if (sk)
 		sock_hold(sk);
 	rcu_read_unlock();
-	read_unlock(&nl_table_lock);
 
 	return sk;
 }
@@ -1201,6 +1199,13 @@ out_module:
 	goto out;
 }
 
+static void deferred_put_nlk_sk(struct rcu_head *head)
+{
+	struct netlink_sock *nlk = container_of(head, struct netlink_sock, rcu);
+
+	sock_put(&nlk->sk);
+}
+
 static int netlink_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
@@ -1261,7 +1266,7 @@ static int netlink_release(struct socket *sock)
 	local_bh_disable();
 	sock_prot_inuse_add(sock_net(sk), &netlink_proto, -1);
 	local_bh_enable();
-	sock_put(sk);
+	call_rcu(&nlk->rcu, deferred_put_nlk_sk);
 	return 0;
 }
 
@@ -1276,7 +1281,6 @@ static int netlink_autobind(struct socket *sock)
 
 retry:
 	cond_resched();
-	netlink_table_grab();
 	rcu_read_lock();
 	if (__netlink_lookup(table, portid, net)) {
 		/* Bind collision, search negative portid values. */
@@ -1284,11 +1288,9 @@ retry:
 		if (rover > -4097)
 			rover = -4097;
 		rcu_read_unlock();
-		netlink_table_ungrab();
 		goto retry;
 	}
 	rcu_read_unlock();
-	netlink_table_ungrab();
 
 	err = netlink_insert(sk, net, portid);
 	if (err == -EADDRINUSE)
@@ -2922,9 +2924,8 @@ static struct sock *netlink_seq_socket_idx(struct seq_file *seq, loff_t pos)
 }
 
 static void *netlink_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(nl_table_lock) __acquires(RCU)
+	__acquires(RCU)
 {
-	read_lock(&nl_table_lock);
 	rcu_read_lock();
 	return *pos ? netlink_seq_socket_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 }
@@ -2976,10 +2977,9 @@ static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void netlink_seq_stop(struct seq_file *seq, void *v)
-	__releases(RCU) __releases(nl_table_lock)
+	__releases(RCU)
 {
 	rcu_read_unlock();
-	read_unlock(&nl_table_lock);
 }
 
 
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index b20a173..ab539c5 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -50,6 +50,7 @@ struct netlink_sock {
 #endif /* CONFIG_NETLINK_MMAP */
 
 	struct rhash_head	node;
+	struct rcu_head		rcu;
 };
 
 static inline struct netlink_sock *nlk_sk(struct sock *sk)
-- 
1.9.3
