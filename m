From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH v3 04/14] RDS: Use per-bucket rw lock for bind hash-table
Date: Mon,  5 Oct 2015 10:56:27 -0700
Message-ID: <1444067797-14101-5-git-send-email-santosh.shilimkar@oracle.com>
References: <1444067797-14101-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444067797-14101-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One global lock protecting hash-tables with 1024 buckets isn't
efficient and it shows up in a massive systems with truck
loads of RDS sockets serving multiple databases. The
perf data clearly highlights the contention on the rw
lock in these massive workloads.

When the contention gets worse, the code gets into a state where
it decides to back off on the lock. So while it has disabled interrupts,
it sits and backs off on this lock get. This causes the system to
become sluggish and eventually all sorts of bad things happen.

The simple fix is to move the lock into the hash bucket and
use per-bucket lock to improve the scalability.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/af_rds.c |  2 ++
 net/rds/bind.c   | 47 ++++++++++++++++++++++++++++++++---------------
 net/rds/rds.h    |  1 +
 3 files changed, 35 insertions(+), 15 deletions(-)

diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index dc08766..384ea1e 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -582,6 +582,8 @@ static int rds_init(void)
 {
 	int ret;
 
+	rds_bind_lock_init();
+
 	ret = rds_conn_init();
 	if (ret)
 		goto out;
diff --git a/net/rds/bind.c b/net/rds/bind.c
index 166c605..bc6b93e 100644
--- a/net/rds/bind.c
+++ b/net/rds/bind.c
@@ -38,22 +38,27 @@
 #include <linux/ratelimit.h>
 #include "rds.h"
 
+struct bind_bucket {
+	rwlock_t                lock;
+	struct hlist_head	head;
+};
+
 #define BIND_HASH_SIZE 1024
-static struct hlist_head bind_hash_table[BIND_HASH_SIZE];
-static DEFINE_RWLOCK(rds_bind_lock);
+static struct bind_bucket bind_hash_table[BIND_HASH_SIZE];
 
-static struct hlist_head *hash_to_bucket(__be32 addr, __be16 port)
+static struct bind_bucket *hash_to_bucket(__be32 addr, __be16 port)
 {
 	return bind_hash_table + (jhash_2words((u32)addr, (u32)port, 0) &
 				  (BIND_HASH_SIZE - 1));
 }
 
 /* must hold either read or write lock (write lock for insert != NULL) */
-static struct rds_sock *rds_bind_lookup(__be32 addr, __be16 port,
+static struct rds_sock *rds_bind_lookup(struct bind_bucket *bucket,
+					__be32 addr, __be16 port,
 					struct rds_sock *insert)
 {
 	struct rds_sock *rs;
-	struct hlist_head *head = hash_to_bucket(addr, port);
+	struct hlist_head *head = &bucket->head;
 	u64 cmp;
 	u64 needle = ((u64)be32_to_cpu(addr) << 32) | be16_to_cpu(port);
 
@@ -91,10 +96,11 @@ struct rds_sock *rds_find_bound(__be32 addr, __be16 port)
 {
 	struct rds_sock *rs;
 	unsigned long flags;
+	struct bind_bucket *bucket = hash_to_bucket(addr, port);
 
-	read_lock_irqsave(&rds_bind_lock, flags);
-	rs = rds_bind_lookup(addr, port, NULL);
-	read_unlock_irqrestore(&rds_bind_lock, flags);
+	read_lock_irqsave(&bucket->lock, flags);
+	rs = rds_bind_lookup(bucket, addr, port, NULL);
+	read_unlock_irqrestore(&bucket->lock, flags);
 
 	if (rs && sock_flag(rds_rs_to_sk(rs), SOCK_DEAD)) {
 		rds_sock_put(rs);
@@ -113,6 +119,7 @@ static int rds_add_bound(struct rds_sock *rs, __be32 addr, __be16 *port)
 	unsigned long flags;
 	int ret = -EADDRINUSE;
 	u16 rover, last;
+	struct bind_bucket *bucket;
 
 	if (*port != 0) {
 		rover = be16_to_cpu(*port);
@@ -122,13 +129,15 @@ static int rds_add_bound(struct rds_sock *rs, __be32 addr, __be16 *port)
 		last = rover - 1;
 	}
 
-	write_lock_irqsave(&rds_bind_lock, flags);
-
 	do {
 		struct rds_sock *rrs;
 		if (rover == 0)
 			rover++;
-		rrs = rds_bind_lookup(addr, cpu_to_be16(rover), rs);
+
+		bucket = hash_to_bucket(addr, cpu_to_be16(rover));
+		write_lock_irqsave(&bucket->lock, flags);
+		rrs = rds_bind_lookup(bucket, addr, cpu_to_be16(rover), rs);
+		write_unlock_irqrestore(&bucket->lock, flags);
 		if (!rrs) {
 			*port = rs->rs_bound_port;
 			ret = 0;
@@ -140,16 +149,16 @@ static int rds_add_bound(struct rds_sock *rs, __be32 addr, __be16 *port)
 		}
 	} while (rover++ != last);
 
-	write_unlock_irqrestore(&rds_bind_lock, flags);
-
 	return ret;
 }
 
 void rds_remove_bound(struct rds_sock *rs)
 {
 	unsigned long flags;
+	struct bind_bucket *bucket =
+		hash_to_bucket(rs->rs_bound_addr, rs->rs_bound_port);
 
-	write_lock_irqsave(&rds_bind_lock, flags);
+	write_lock_irqsave(&bucket->lock, flags);
 
 	if (rs->rs_bound_addr) {
 		rdsdebug("rs %p unbinding from %pI4:%d\n",
@@ -161,7 +170,7 @@ void rds_remove_bound(struct rds_sock *rs)
 		rs->rs_bound_addr = 0;
 	}
 
-	write_unlock_irqrestore(&rds_bind_lock, flags);
+	write_unlock_irqrestore(&bucket->lock, flags);
 }
 
 int rds_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
@@ -207,3 +216,11 @@ out:
 	release_sock(sk);
 	return ret;
 }
+
+void rds_bind_lock_init(void)
+{
+	int i;
+
+	for (i = 0; i < BIND_HASH_SIZE; i++)
+		rwlock_init(&bind_hash_table[i].lock);
+}
diff --git a/net/rds/rds.h b/net/rds/rds.h
index afb4048..121fb81 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -603,6 +603,7 @@ extern wait_queue_head_t rds_poll_waitq;
 int rds_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len);
 void rds_remove_bound(struct rds_sock *rs);
 struct rds_sock *rds_find_bound(__be32 addr, __be16 port);
+void rds_bind_lock_init(void);
 
 /* cong.c */
 int rds_cong_get_maps(struct rds_connection *conn);
-- 
1.9.1
