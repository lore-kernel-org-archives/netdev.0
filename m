From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v2] netfilter: fix the race when initializing nf_ct_expect_hash_rnd
Date: Wed,  5 Jan 2011 22:23:23 +0800
Message-ID: <1294237403-15616-1-git-send-email-xiaosuo@gmail.com>
Cc: netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since nf_ct_expect_dst_hash() may be called without nf_conntrack_lock
locked, nf_ct_expect_hash_rnd should be initialized in the atomic way.

In this patch, we use nf_conntrack_hash_rnd instead of
nf_ct_expect_hash_rnd.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
v2: use nf_conntrack_hash_rnd.
 include/net/netfilter/nf_conntrack.h |    2 ++
 net/netfilter/nf_conntrack_core.c    |   30 +++++++++++++++++-------------
 net/netfilter/nf_conntrack_expect.c  |   10 +++-------
 3 files changed, 22 insertions(+), 20 deletions(-)
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index caf17db..d85cff1 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -298,6 +298,8 @@ static inline int nf_ct_is_untracked(const struct nf_conn *ct)
 extern int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp);
 extern unsigned int nf_conntrack_htable_size;
 extern unsigned int nf_conntrack_max;
+extern unsigned int nf_conntrack_hash_rnd;
+void init_nf_conntrack_hash_rnd(void);
 
 #define NF_CT_STAT_INC(net, count)	\
 	__this_cpu_inc((net)->ct.stat->count)
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 27a5ea6..e615119 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -65,7 +65,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_max);
 DEFINE_PER_CPU(struct nf_conn, nf_conntrack_untracked);
 EXPORT_PER_CPU_SYMBOL(nf_conntrack_untracked);
 
-static unsigned int nf_conntrack_hash_rnd __read_mostly;
+unsigned int nf_conntrack_hash_rnd __read_mostly;
 
 static u32 hash_conntrack_raw(const struct nf_conntrack_tuple *tuple, u16 zone)
 {
@@ -596,6 +596,21 @@ static noinline int early_drop(struct net *net, unsigned int hash)
 	return dropped;
 }
 
+void init_nf_conntrack_hash_rnd(void)
+{
+	unsigned int rand;
+
+	/*
+	 * Why not initialize nf_conntrack_rnd in a "init()" function ?
+	 * Because there isn't enough entropy when system initializing,
+	 * and we initialize it as late as possible.
+	 */
+	do {
+		get_random_bytes(&rand, sizeof(rand));
+	} while (!rand);
+	cmpxchg(&nf_conntrack_hash_rnd, 0, rand);
+}
+
 static struct nf_conn *
 __nf_conntrack_alloc(struct net *net, u16 zone,
 		     const struct nf_conntrack_tuple *orig,
@@ -605,18 +620,7 @@ __nf_conntrack_alloc(struct net *net, u16 zone,
 	struct nf_conn *ct;
 
 	if (unlikely(!nf_conntrack_hash_rnd)) {
-		unsigned int rand;
-
-		/*
-		 * Why not initialize nf_conntrack_rnd in a "init()" function ?
-		 * Because there isn't enough entropy when system initializing,
-		 * and we initialize it as late as possible.
-		 */
-		do {
-			get_random_bytes(&rand, sizeof(rand));
-		} while (!rand);
-		cmpxchg(&nf_conntrack_hash_rnd, 0, rand);
-
+		init_nf_conntrack_hash_rnd();
 		/* recompute the hash as nf_conntrack_hash_rnd is initialized */
 		hash = hash_conntrack_raw(orig, zone);
 	}
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 46e8966..a20fb0b 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -32,9 +32,7 @@
 unsigned int nf_ct_expect_hsize __read_mostly;
 EXPORT_SYMBOL_GPL(nf_ct_expect_hsize);
 
-static unsigned int nf_ct_expect_hash_rnd __read_mostly;
 unsigned int nf_ct_expect_max __read_mostly;
-static int nf_ct_expect_hash_rnd_initted __read_mostly;
 
 static struct kmem_cache *nf_ct_expect_cachep __read_mostly;
 
@@ -77,15 +75,13 @@ static unsigned int nf_ct_expect_dst_hash(const struct nf_conntrack_tuple *tuple
 {
 	unsigned int hash;
 
-	if (unlikely(!nf_ct_expect_hash_rnd_initted)) {
-		get_random_bytes(&nf_ct_expect_hash_rnd,
-				 sizeof(nf_ct_expect_hash_rnd));
-		nf_ct_expect_hash_rnd_initted = 1;
+	if (unlikely(!nf_conntrack_hash_rnd)) {
+		init_nf_conntrack_hash_rnd();
 	}
 
 	hash = jhash2(tuple->dst.u3.all, ARRAY_SIZE(tuple->dst.u3.all),
 		      (((tuple->dst.protonum ^ tuple->src.l3num) << 16) |
-		       (__force __u16)tuple->dst.u.all) ^ nf_ct_expect_hash_rnd);
+		       (__force __u16)tuple->dst.u.all) ^ nf_conntrack_hash_rnd);
 	return ((u64)hash * nf_ct_expect_hsize) >> 32;
 }
 
