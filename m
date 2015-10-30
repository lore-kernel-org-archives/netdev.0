From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next PATCH v2] RDS: convert bind hash table to re-sizable hashtable
Date: Fri, 30 Oct 2015 08:49:10 -0700
Message-ID: <1446220150-3622-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>,
	Santosh Shilimkar <ssantosh@kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To further improve the RDS connection scalabilty on massive systems
where number of sockets grows into tens of thousands  of sockets, there
is a need of larger bind hashtable. Pre-allocated 8K or 16K table is
not very flexible in terms of memory utilisation. The rhashtable
infrastructure gives us the flexibility to grow the hashtbable based
on use and also comes up with inbuilt efficient bucket(chain) handling.

Reviewed-by: David Miller <davem@davemloft.net>
Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
v2: Dropped empty new line from rds_add_bound()  (David Miller)

 net/rds/af_rds.c |  10 ++++-
 net/rds/bind.c   | 125 +++++++++++++++++++------------------------------------
 net/rds/rds.h    |   7 +++-
 3 files changed, 56 insertions(+), 86 deletions(-)

diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index 384ea1e..b5476aeb 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -573,6 +573,7 @@ static void rds_exit(void)
 	rds_threads_exit();
 	rds_stats_exit();
 	rds_page_exit();
+	rds_bind_lock_destroy();
 	rds_info_deregister_func(RDS_INFO_SOCKETS, rds_sock_info);
 	rds_info_deregister_func(RDS_INFO_RECV_MESSAGES, rds_sock_inc_info);
 }
@@ -582,11 +583,14 @@ static int rds_init(void)
 {
 	int ret;
 
-	rds_bind_lock_init();
+	ret = rds_bind_lock_init();
+	if (ret)
+		goto out;
 
 	ret = rds_conn_init();
 	if (ret)
-		goto out;
+		goto out_bind;
+
 	ret = rds_threads_init();
 	if (ret)
 		goto out_conn;
@@ -620,6 +624,8 @@ out_conn:
 	rds_conn_exit();
 	rds_cong_exit();
 	rds_page_exit();
+out_bind:
+	rds_bind_lock_destroy();
 out:
 	return ret;
 }
diff --git a/net/rds/bind.c b/net/rds/bind.c
index 6192566..b22ea95 100644
--- a/net/rds/bind.c
+++ b/net/rds/bind.c
@@ -38,54 +38,17 @@
 #include <linux/ratelimit.h>
 #include "rds.h"
 
-struct bind_bucket {
-	rwlock_t                lock;
-	struct hlist_head	head;
+static struct rhashtable bind_hash_table;
+
+static struct rhashtable_params ht_parms = {
+	.nelem_hint = 768,
+	.key_len = sizeof(u64),
+	.key_offset = offsetof(struct rds_sock, rs_bound_key),
+	.head_offset = offsetof(struct rds_sock, rs_bound_node),
+	.max_size = 16384,
+	.min_size = 1024,
 };
 
-#define BIND_HASH_SIZE 1024
-static struct bind_bucket bind_hash_table[BIND_HASH_SIZE];
-
-static struct bind_bucket *hash_to_bucket(__be32 addr, __be16 port)
-{
-	return bind_hash_table + (jhash_2words((u32)addr, (u32)port, 0) &
-				  (BIND_HASH_SIZE - 1));
-}
-
-/* must hold either read or write lock (write lock for insert != NULL) */
-static struct rds_sock *rds_bind_lookup(struct bind_bucket *bucket,
-					__be32 addr, __be16 port,
-					struct rds_sock *insert)
-{
-	struct rds_sock *rs;
-	struct hlist_head *head = &bucket->head;
-	u64 cmp;
-	u64 needle = ((u64)be32_to_cpu(addr) << 32) | be16_to_cpu(port);
-
-	hlist_for_each_entry(rs, head, rs_bound_node) {
-		cmp = ((u64)be32_to_cpu(rs->rs_bound_addr) << 32) |
-		      be16_to_cpu(rs->rs_bound_port);
-
-		if (cmp == needle) {
-			rds_sock_addref(rs);
-			return rs;
-		}
-	}
-
-	if (insert) {
-		/*
-		 * make sure our addr and port are set before
-		 * we are added to the list.
-		 */
-		insert->rs_bound_addr = addr;
-		insert->rs_bound_port = port;
-		rds_sock_addref(insert);
-
-		hlist_add_head(&insert->rs_bound_node, head);
-	}
-	return NULL;
-}
-
 /*
  * Return the rds_sock bound at the given local address.
  *
@@ -94,18 +57,14 @@ static struct rds_sock *rds_bind_lookup(struct bind_bucket *bucket,
  */
 struct rds_sock *rds_find_bound(__be32 addr, __be16 port)
 {
+	u64 key = ((u64)addr << 32) | port;
 	struct rds_sock *rs;
-	unsigned long flags;
-	struct bind_bucket *bucket = hash_to_bucket(addr, port);
-
-	read_lock_irqsave(&bucket->lock, flags);
-	rs = rds_bind_lookup(bucket, addr, port, NULL);
-	read_unlock_irqrestore(&bucket->lock, flags);
 
-	if (rs && sock_flag(rds_rs_to_sk(rs), SOCK_DEAD)) {
-		rds_sock_put(rs);
+	rs = rhashtable_lookup_fast(&bind_hash_table, &key, ht_parms);
+	if (rs && !sock_flag(rds_rs_to_sk(rs), SOCK_DEAD))
+		rds_sock_addref(rs);
+	else
 		rs = NULL;
-	}
 
 	rdsdebug("returning rs %p for %pI4:%u\n", rs, &addr,
 		ntohs(port));
@@ -116,10 +75,9 @@ struct rds_sock *rds_find_bound(__be32 addr, __be16 port)
 /* returns -ve errno or +ve port */
 static int rds_add_bound(struct rds_sock *rs, __be32 addr, __be16 *port)
 {
-	unsigned long flags;
 	int ret = -EADDRINUSE;
 	u16 rover, last;
-	struct bind_bucket *bucket;
+	u64 key;
 
 	if (*port != 0) {
 		rover = be16_to_cpu(*port);
@@ -130,22 +88,29 @@ static int rds_add_bound(struct rds_sock *rs, __be32 addr, __be16 *port)
 	}
 
 	do {
-		struct rds_sock *rrs;
 		if (rover == 0)
 			rover++;
 
-		bucket = hash_to_bucket(addr, cpu_to_be16(rover));
-		write_lock_irqsave(&bucket->lock, flags);
-		rrs = rds_bind_lookup(bucket, addr, cpu_to_be16(rover), rs);
-		write_unlock_irqrestore(&bucket->lock, flags);
-		if (!rrs) {
+		key = ((u64)addr << 32) | cpu_to_be16(rover);
+		if (rhashtable_lookup_fast(&bind_hash_table, &key, ht_parms))
+			continue;
+
+		rs->rs_bound_key = key;
+		rs->rs_bound_addr = addr;
+		rs->rs_bound_port = cpu_to_be16(rover);
+		rs->rs_bound_node.next = NULL;
+		rds_sock_addref(rs);
+		if (!rhashtable_insert_fast(&bind_hash_table,
+					    &rs->rs_bound_node, ht_parms)) {
 			*port = rs->rs_bound_port;
 			ret = 0;
 			rdsdebug("rs %p binding to %pI4:%d\n",
 			  rs, &addr, (int)ntohs(*port));
 			break;
 		} else {
-			rds_sock_put(rrs);
+			rds_sock_put(rs);
+			ret = -ENOMEM;
+			break;
 		}
 	} while (rover++ != last);
 
@@ -154,23 +119,17 @@ static int rds_add_bound(struct rds_sock *rs, __be32 addr, __be16 *port)
 
 void rds_remove_bound(struct rds_sock *rs)
 {
-	unsigned long flags;
-	struct bind_bucket *bucket =
-		hash_to_bucket(rs->rs_bound_addr, rs->rs_bound_port);
-
-	write_lock_irqsave(&bucket->lock, flags);
 
-	if (rs->rs_bound_addr) {
-		rdsdebug("rs %p unbinding from %pI4:%d\n",
-		  rs, &rs->rs_bound_addr,
-		  ntohs(rs->rs_bound_port));
+	if (!rs->rs_bound_addr)
+		return;
 
-		hlist_del_init(&rs->rs_bound_node);
-		rds_sock_put(rs);
-		rs->rs_bound_addr = 0;
-	}
+	rdsdebug("rs %p unbinding from %pI4:%d\n",
+		 rs, &rs->rs_bound_addr,
+		 ntohs(rs->rs_bound_port));
 
-	write_unlock_irqrestore(&bucket->lock, flags);
+	rhashtable_remove_fast(&bind_hash_table, &rs->rs_bound_node, ht_parms);
+	rds_sock_put(rs);
+	rs->rs_bound_addr = 0;
 }
 
 int rds_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
@@ -224,10 +183,12 @@ out:
 	return ret;
 }
 
-void rds_bind_lock_init(void)
+void rds_bind_lock_destroy(void)
 {
-	int i;
+	rhashtable_destroy(&bind_hash_table);
+}
 
-	for (i = 0; i < BIND_HASH_SIZE; i++)
-		rwlock_init(&bind_hash_table[i].lock);
+int rds_bind_lock_init(void)
+{
+	return rhashtable_init(&bind_hash_table, &ht_parms);
 }
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 543c308..0e2797b 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -7,6 +7,7 @@
 #include <rdma/rdma_cm.h>
 #include <linux/mutex.h>
 #include <linux/rds.h>
+#include <linux/rhashtable.h>
 
 #include "info.h"
 
@@ -474,7 +475,8 @@ struct rds_sock {
 	 * bound_addr used for both incoming and outgoing, no INADDR_ANY
 	 * support.
 	 */
-	struct hlist_node	rs_bound_node;
+	struct rhash_head	rs_bound_node;
+	u64			rs_bound_key;
 	__be32			rs_bound_addr;
 	__be32			rs_conn_addr;
 	__be16			rs_bound_port;
@@ -605,7 +607,8 @@ extern wait_queue_head_t rds_poll_waitq;
 int rds_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len);
 void rds_remove_bound(struct rds_sock *rs);
 struct rds_sock *rds_find_bound(__be32 addr, __be16 port);
-void rds_bind_lock_init(void);
+int rds_bind_lock_init(void);
+void rds_bind_lock_destroy(void);
 
 /* cong.c */
 int rds_cong_get_maps(struct rds_connection *conn);
-- 
1.9.1
