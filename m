From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH v2 02/14] RDS: make socket bind/release locking scheme simple and more efficient
Date: Wed, 30 Sep 2015 13:24:21 -0400
Message-ID: <1443633873-13359-3-git-send-email-santosh.shilimkar@oracle.com>
References: <1443633873-13359-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-rdma@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443633873-13359-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RDS bind and release locking scheme is very inefficient. It
uses RCU for maintaining the bind hash-table which is great but
it also needs to hold spinlock for [add/remove]_bound(). So
overall usecase, the hash-table concurrent speedup doesn't pay off.
In fact blocking nature of synchronize_rcu() makes the RDS
socket shutdown too slow which hurts RDS performance since
connection shutdown and re-connect happens quite often to
maintain the RC part of the protocol.

So we make the locking scheme simpler and more efficient by
replacing spin_locks with reader/writer locks and getting rid
off rcu for bind hash-table.

In subsequent patch, we also covert the global lock with per-bucket
lock to reduce the global lock contention.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/af_rds.c |  6 ------
 net/rds/bind.c   | 35 +++++++++++++++--------------------
 2 files changed, 15 insertions(+), 26 deletions(-)

diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index a2f28a6..dc08766 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -72,13 +72,7 @@ static int rds_release(struct socket *sock)
 	rds_clear_recv_queue(rs);
 	rds_cong_remove_socket(rs);
 
-	/*
-	 * the binding lookup hash uses rcu, we need to
-	 * make sure we synchronize_rcu before we free our
-	 * entry
-	 */
 	rds_remove_bound(rs);
-	synchronize_rcu();
 
 	rds_send_drop_to(rs, NULL);
 	rds_rdma_drop_keys(rs);
diff --git a/net/rds/bind.c b/net/rds/bind.c
index dd666fb..01989e2 100644
--- a/net/rds/bind.c
+++ b/net/rds/bind.c
@@ -40,7 +40,7 @@
 
 #define BIND_HASH_SIZE 1024
 static struct hlist_head bind_hash_table[BIND_HASH_SIZE];
-static DEFINE_SPINLOCK(rds_bind_lock);
+static DEFINE_RWLOCK(rds_bind_lock);
 
 static struct hlist_head *hash_to_bucket(__be32 addr, __be16 port)
 {
@@ -48,6 +48,7 @@ static struct hlist_head *hash_to_bucket(__be32 addr, __be16 port)
 				  (BIND_HASH_SIZE - 1));
 }
 
+/* must hold either read or write lock (write lock for insert != NULL) */
 static struct rds_sock *rds_bind_lookup(__be32 addr, __be16 port,
 					struct rds_sock *insert)
 {
@@ -56,30 +57,24 @@ static struct rds_sock *rds_bind_lookup(__be32 addr, __be16 port,
 	u64 cmp;
 	u64 needle = ((u64)be32_to_cpu(addr) << 32) | be16_to_cpu(port);
 
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(rs, head, rs_bound_node) {
+	hlist_for_each_entry(rs, head, rs_bound_node) {
 		cmp = ((u64)be32_to_cpu(rs->rs_bound_addr) << 32) |
 		      be16_to_cpu(rs->rs_bound_port);
 
-		if (cmp == needle) {
-			rcu_read_unlock();
+		if (cmp == needle)
 			return rs;
-		}
 	}
-	rcu_read_unlock();
 
 	if (insert) {
 		/*
 		 * make sure our addr and port are set before
-		 * we are added to the list, other people
-		 * in rcu will find us as soon as the
-		 * hlist_add_head_rcu is done
+		 * we are added to the list.
 		 */
 		insert->rs_bound_addr = addr;
 		insert->rs_bound_port = port;
 		rds_sock_addref(insert);
 
-		hlist_add_head_rcu(&insert->rs_bound_node, head);
+		hlist_add_head(&insert->rs_bound_node, head);
 	}
 	return NULL;
 }
@@ -93,8 +88,11 @@ static struct rds_sock *rds_bind_lookup(__be32 addr, __be16 port,
 struct rds_sock *rds_find_bound(__be32 addr, __be16 port)
 {
 	struct rds_sock *rs;
+	unsigned long flags;
 
+	read_lock_irqsave(&rds_bind_lock, flags);
 	rs = rds_bind_lookup(addr, port, NULL);
+	read_unlock_irqrestore(&rds_bind_lock, flags);
 
 	if (rs && !sock_flag(rds_rs_to_sk(rs), SOCK_DEAD))
 		rds_sock_addref(rs);
@@ -103,6 +101,7 @@ struct rds_sock *rds_find_bound(__be32 addr, __be16 port)
 
 	rdsdebug("returning rs %p for %pI4:%u\n", rs, &addr,
 		ntohs(port));
+
 	return rs;
 }
 
@@ -121,7 +120,7 @@ static int rds_add_bound(struct rds_sock *rs, __be32 addr, __be16 *port)
 		last = rover - 1;
 	}
 
-	spin_lock_irqsave(&rds_bind_lock, flags);
+	write_lock_irqsave(&rds_bind_lock, flags);
 
 	do {
 		if (rover == 0)
@@ -135,7 +134,7 @@ static int rds_add_bound(struct rds_sock *rs, __be32 addr, __be16 *port)
 		}
 	} while (rover++ != last);
 
-	spin_unlock_irqrestore(&rds_bind_lock, flags);
+	write_unlock_irqrestore(&rds_bind_lock, flags);
 
 	return ret;
 }
@@ -144,19 +143,19 @@ void rds_remove_bound(struct rds_sock *rs)
 {
 	unsigned long flags;
 
-	spin_lock_irqsave(&rds_bind_lock, flags);
+	write_lock_irqsave(&rds_bind_lock, flags);
 
 	if (rs->rs_bound_addr) {
 		rdsdebug("rs %p unbinding from %pI4:%d\n",
 		  rs, &rs->rs_bound_addr,
 		  ntohs(rs->rs_bound_port));
 
-		hlist_del_init_rcu(&rs->rs_bound_node);
+		hlist_del_init(&rs->rs_bound_node);
 		rds_sock_put(rs);
 		rs->rs_bound_addr = 0;
 	}
 
-	spin_unlock_irqrestore(&rds_bind_lock, flags);
+	write_unlock_irqrestore(&rds_bind_lock, flags);
 }
 
 int rds_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
@@ -200,9 +199,5 @@ int rds_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 
 out:
 	release_sock(sk);
-
-	/* we might have called rds_remove_bound on error */
-	if (ret)
-		synchronize_rcu();
 	return ret;
 }
-- 
1.9.1
