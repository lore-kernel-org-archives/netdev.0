From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 9/9] netlink: Lockless lookup with RCU grace period in socket release
Date: Fri,  2 Jan 2015 23:00:22 +0100
Message-ID: <daae84cd33bfde8518b849176e25dcf3eea8014b.1420230585.git.tgraf@suug.ch>
References: <cover.1420230585.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au, paulmck@linux.vnet.ibm.com,
	edumazet@google.com, john.r.fastabend@intel.com,
	josh@joshtriplett.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1420230585.git.tgraf@suug.ch>
In-Reply-To: <cover.1420230585.git.tgraf@suug.ch>
References: <cover.1420230585.git.tgraf@suug.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
index 738c3bf..298e1df 100644
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
@@ -1003,13 +1003,11 @@ static struct sock *netlink_lookup(struct net *net, int protocol, u32 portid)
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
@@ -1183,6 +1181,13 @@ out_module:
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
@@ -1248,7 +1253,7 @@ static int netlink_release(struct socket *sock)
 	local_bh_disable();
 	sock_prot_inuse_add(sock_net(sk), &netlink_proto, -1);
 	local_bh_enable();
-	sock_put(sk);
+	call_rcu(&nlk->rcu, deferred_put_nlk_sk);
 	return 0;
 }
 
@@ -1263,7 +1268,6 @@ static int netlink_autobind(struct socket *sock)
 
 retry:
 	cond_resched();
-	netlink_table_grab();
 	rcu_read_lock();
 	if (__netlink_lookup(table, portid, net)) {
 		/* Bind collision, search negative portid values. */
@@ -1271,11 +1275,9 @@ retry:
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
@@ -2910,9 +2912,8 @@ static struct sock *netlink_seq_socket_idx(struct seq_file *seq, loff_t pos)
 }
 
 static void *netlink_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(nl_table_lock) __acquires(RCU)
+	__acquires(RCU)
 {
-	read_lock(&nl_table_lock);
 	rcu_read_lock();
 	return *pos ? netlink_seq_socket_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 }
@@ -2964,10 +2965,9 @@ static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void netlink_seq_stop(struct seq_file *seq, void *v)
-	__releases(RCU) __releases(nl_table_lock)
+	__releases(RCU)
 {
 	rcu_read_unlock();
-	read_unlock(&nl_table_lock);
 }
 
 
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index f123a88..fd96fa7 100644
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
