From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/3] Revert "netfilter: avoid get_random_bytes calls"
Date: Wed,  8 Jan 2014 20:13:22 +0100
Message-ID: <1389208404-3956-2-git-send-email-pablo@netfilter.org>
References: <1389208404-3956-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54773 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756115AbaAHTNn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 14:13:43 -0500
In-Reply-To: <1389208404-3956-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit a42b99a6e329654d376b330de057eff87686d890.

Hannes Frederic Sowa reported some problems with this patch, more specifically
that prandom_u32() may not be ready at boot time, see:

http://marc.info/?l=linux-netdev&m=138896532403533&w=2

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c |    8 ++++++++
 net/netfilter/nft_hash.c      |    2 +-
 net/netfilter/xt_RATEEST.c    |    2 +-
 net/netfilter/xt_connlimit.c  |    2 +-
 net/netfilter/xt_hashlimit.c  |    2 +-
 net/netfilter/xt_recent.c     |    2 +-
 6 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 7d4254b..3c4b69e 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -28,6 +28,8 @@
 #include <linux/proc_fs.h>
 #include <linux/security.h>
 #include <linux/list.h>
+#include <linux/jhash.h>
+#include <linux/random.h>
 #include <linux/slab.h>
 #include <net/sock.h>
 #include <net/netfilter/nf_log.h>
@@ -73,6 +75,7 @@ struct nfulnl_instance {
 };
 
 #define INSTANCE_BUCKETS	16
+static unsigned int hash_init;
 
 static int nfnl_log_net_id __read_mostly;
 
@@ -1063,6 +1066,11 @@ static int __init nfnetlink_log_init(void)
 {
 	int status = -ENOMEM;
 
+	/* it's not really all that important to have a random value, so
+	 * we can do this from the init function, even if there hasn't
+	 * been that much entropy yet */
+	get_random_bytes(&hash_init, sizeof(hash_init));
+
 	netlink_register_notifier(&nfulnl_rtnl_notifier);
 	status = nfnetlink_subsys_register(&nfulnl_subsys);
 	if (status < 0) {
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 6aae699..3d3f8fc 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -164,7 +164,7 @@ static int nft_hash_init(const struct nft_set *set,
 	unsigned int cnt, i;
 
 	if (unlikely(!nft_hash_rnd_initted)) {
-		nft_hash_rnd = prandom_u32();
+		get_random_bytes(&nft_hash_rnd, 4);
 		nft_hash_rnd_initted = true;
 	}
 
diff --git a/net/netfilter/xt_RATEEST.c b/net/netfilter/xt_RATEEST.c
index 190854b..370adf6 100644
--- a/net/netfilter/xt_RATEEST.c
+++ b/net/netfilter/xt_RATEEST.c
@@ -100,7 +100,7 @@ static int xt_rateest_tg_checkentry(const struct xt_tgchk_param *par)
 	int ret;
 
 	if (unlikely(!rnd_inited)) {
-		jhash_rnd = prandom_u32();
+		get_random_bytes(&jhash_rnd, sizeof(jhash_rnd));
 		rnd_inited = true;
 	}
 
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 7671e82..c40b269 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -229,7 +229,7 @@ static int connlimit_mt_check(const struct xt_mtchk_param *par)
 		u_int32_t rand;
 
 		do {
-			rand = prandom_u32();
+			get_random_bytes(&rand, sizeof(rand));
 		} while (!rand);
 		cmpxchg(&connlimit_rnd, 0, rand);
 	}
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index d819f62..a3910fc 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -177,7 +177,7 @@ dsthash_alloc_init(struct xt_hashlimit_htable *ht,
 	/* initialize hash with random val at the time we allocate
 	 * the first hashtable entry */
 	if (unlikely(!ht->rnd_initialized)) {
-		ht->rnd = prandom_u32();
+		get_random_bytes(&ht->rnd, sizeof(ht->rnd));
 		ht->rnd_initialized = true;
 	}
 
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index bfdc29f..1e657cf 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -334,7 +334,7 @@ static int recent_mt_check(const struct xt_mtchk_param *par,
 	size_t sz;
 
 	if (unlikely(!hash_rnd_inited)) {
-		hash_rnd = prandom_u32();
+		get_random_bytes(&hash_rnd, sizeof(hash_rnd));
 		hash_rnd_inited = true;
 	}
 	if (info->check_set & ~XT_RECENT_VALID_FLAGS) {
-- 
1.7.10.4
