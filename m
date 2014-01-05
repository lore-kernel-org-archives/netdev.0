From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/12] netfilter: avoid get_random_bytes calls
Date: Mon,  6 Jan 2014 00:12:55 +0100
Message-ID: <1388963586-5049-2-git-send-email-pablo@netfilter.org>
References: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

All these users need an initial seed value for jhash, prandom is
perfectly fine.  This avoids draining the entropy pool where
its not strictly required.

nfnetlink_log did not use the random value at all.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c |    8 --------
 net/netfilter/nft_hash.c      |    2 +-
 net/netfilter/xt_RATEEST.c    |    2 +-
 net/netfilter/xt_connlimit.c  |    2 +-
 net/netfilter/xt_hashlimit.c  |    2 +-
 net/netfilter/xt_recent.c     |    2 +-
 6 files changed, 5 insertions(+), 13 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 3c4b69e..7d4254b 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -28,8 +28,6 @@
 #include <linux/proc_fs.h>
 #include <linux/security.h>
 #include <linux/list.h>
-#include <linux/jhash.h>
-#include <linux/random.h>
 #include <linux/slab.h>
 #include <net/sock.h>
 #include <net/netfilter/nf_log.h>
@@ -75,7 +73,6 @@ struct nfulnl_instance {
 };
 
 #define INSTANCE_BUCKETS	16
-static unsigned int hash_init;
 
 static int nfnl_log_net_id __read_mostly;
 
@@ -1066,11 +1063,6 @@ static int __init nfnetlink_log_init(void)
 {
 	int status = -ENOMEM;
 
-	/* it's not really all that important to have a random value, so
-	 * we can do this from the init function, even if there hasn't
-	 * been that much entropy yet */
-	get_random_bytes(&hash_init, sizeof(hash_init));
-
 	netlink_register_notifier(&nfulnl_rtnl_notifier);
 	status = nfnetlink_subsys_register(&nfulnl_subsys);
 	if (status < 0) {
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 3d3f8fc..6aae699 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -164,7 +164,7 @@ static int nft_hash_init(const struct nft_set *set,
 	unsigned int cnt, i;
 
 	if (unlikely(!nft_hash_rnd_initted)) {
-		get_random_bytes(&nft_hash_rnd, 4);
+		nft_hash_rnd = prandom_u32();
 		nft_hash_rnd_initted = true;
 	}
 
diff --git a/net/netfilter/xt_RATEEST.c b/net/netfilter/xt_RATEEST.c
index 370adf6..190854b 100644
--- a/net/netfilter/xt_RATEEST.c
+++ b/net/netfilter/xt_RATEEST.c
@@ -100,7 +100,7 @@ static int xt_rateest_tg_checkentry(const struct xt_tgchk_param *par)
 	int ret;
 
 	if (unlikely(!rnd_inited)) {
-		get_random_bytes(&jhash_rnd, sizeof(jhash_rnd));
+		jhash_rnd = prandom_u32();
 		rnd_inited = true;
 	}
 
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index c40b269..7671e82 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -229,7 +229,7 @@ static int connlimit_mt_check(const struct xt_mtchk_param *par)
 		u_int32_t rand;
 
 		do {
-			get_random_bytes(&rand, sizeof(rand));
+			rand = prandom_u32();
 		} while (!rand);
 		cmpxchg(&connlimit_rnd, 0, rand);
 	}
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 9ff035c..a83a35c 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -177,7 +177,7 @@ dsthash_alloc_init(struct xt_hashlimit_htable *ht,
 	/* initialize hash with random val at the time we allocate
 	 * the first hashtable entry */
 	if (unlikely(!ht->rnd_initialized)) {
-		get_random_bytes(&ht->rnd, sizeof(ht->rnd));
+		ht->rnd = prandom_u32();
 		ht->rnd_initialized = true;
 	}
 
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 1e657cf..bfdc29f 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -334,7 +334,7 @@ static int recent_mt_check(const struct xt_mtchk_param *par,
 	size_t sz;
 
 	if (unlikely(!hash_rnd_inited)) {
-		get_random_bytes(&hash_rnd, sizeof(hash_rnd));
+		hash_rnd = prandom_u32();
 		hash_rnd_inited = true;
 	}
 	if (info->check_set & ~XT_RECENT_VALID_FLAGS) {
-- 
1.7.10.4

