From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/36] netfilter: conntrack: use get_random_once for conntrack hash seed
Date: Mon,  9 May 2016 20:46:24 +0200
Message-ID: <1462819614-5402-7-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

As earlier commit removed accessed to the hash from other files we can
also make it static.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h |  2 --
 net/netfilter/nf_conntrack_core.c    | 26 +++-----------------------
 2 files changed, 3 insertions(+), 25 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index fde4068..dd78bea 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -289,8 +289,6 @@ struct kernel_param;
 int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp);
 extern unsigned int nf_conntrack_htable_size;
 extern unsigned int nf_conntrack_max;
-extern unsigned int nf_conntrack_hash_rnd;
-void init_nf_conntrack_hash_rnd(void);
 
 struct nf_conn *nf_ct_tmpl_alloc(struct net *net,
 				 const struct nf_conntrack_zone *zone,
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index a53c009..1fd0ff1 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -142,13 +142,14 @@ EXPORT_SYMBOL_GPL(nf_conntrack_max);
 DEFINE_PER_CPU(struct nf_conn, nf_conntrack_untracked);
 EXPORT_PER_CPU_SYMBOL(nf_conntrack_untracked);
 
-unsigned int nf_conntrack_hash_rnd __read_mostly;
-EXPORT_SYMBOL_GPL(nf_conntrack_hash_rnd);
+static unsigned int nf_conntrack_hash_rnd __read_mostly;
 
 static u32 hash_conntrack_raw(const struct nf_conntrack_tuple *tuple)
 {
 	unsigned int n;
 
+	get_random_once(&nf_conntrack_hash_rnd, sizeof(nf_conntrack_hash_rnd));
+
 	/* The direction must be ignored, so we hash everything up to the
 	 * destination ports (which is a multiple of 4) and treat the last
 	 * three bytes manually.
@@ -815,21 +816,6 @@ restart:
 	return dropped;
 }
 
-void init_nf_conntrack_hash_rnd(void)
-{
-	unsigned int rand;
-
-	/*
-	 * Why not initialize nf_conntrack_rnd in a "init()" function ?
-	 * Because there isn't enough entropy when system initializing,
-	 * and we initialize it as late as possible.
-	 */
-	do {
-		get_random_bytes(&rand, sizeof(rand));
-	} while (!rand);
-	cmpxchg(&nf_conntrack_hash_rnd, 0, rand);
-}
-
 static struct nf_conn *
 __nf_conntrack_alloc(struct net *net,
 		     const struct nf_conntrack_zone *zone,
@@ -839,12 +825,6 @@ __nf_conntrack_alloc(struct net *net,
 {
 	struct nf_conn *ct;
 
-	if (unlikely(!nf_conntrack_hash_rnd)) {
-		init_nf_conntrack_hash_rnd();
-		/* recompute the hash as nf_conntrack_hash_rnd is initialized */
-		hash = hash_conntrack_raw(orig);
-	}
-
 	/* We don't want any race condition at early drop stage */
 	atomic_inc(&net->ct.count);
 
-- 
2.1.4

