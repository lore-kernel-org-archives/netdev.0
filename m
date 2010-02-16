From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/62: xtables: do not grab random bytes at __init
Date: Tue, 16 Feb 2010 15:55:23 +0100 (MET)
Message-ID: <20100216145521.2796.10647.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51942 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755491Ab0BPOzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:55:24 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 5191d50192ec1281e51cbcb5248cb2667ff4d896
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Mon Jan 4 16:27:25 2010 +0100

    netfilter: xtables: do not grab random bytes at __init
    
    "It is deliberately not done in the init function, since we might not
    have sufficient random while booting."
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index f28f6a5..12dcd70 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -28,6 +28,7 @@ MODULE_ALIAS("ip6t_NFQUEUE");
 MODULE_ALIAS("arpt_NFQUEUE");
 
 static u32 jhash_initval __read_mostly;
+static bool rnd_inited __read_mostly;
 
 static unsigned int
 nfqueue_tg(struct sk_buff *skb, const struct xt_target_param *par)
@@ -90,6 +91,10 @@ static bool nfqueue_tg_v1_check(const struct xt_tgchk_param *par)
 	const struct xt_NFQ_info_v1 *info = par->targinfo;
 	u32 maxid;
 
+	if (unlikely(!rnd_inited)) {
+		get_random_bytes(&jhash_initval, sizeof(jhash_initval));
+		rnd_inited = true;
+	}
 	if (info->queues_total == 0) {
 		pr_err("NFQUEUE: number of total queues is 0\n");
 		return false;
@@ -135,7 +140,6 @@ static struct xt_target nfqueue_tg_reg[] __read_mostly = {
 
 static int __init nfqueue_tg_init(void)
 {
-	get_random_bytes(&jhash_initval, sizeof(jhash_initval));
 	return xt_register_targets(nfqueue_tg_reg, ARRAY_SIZE(nfqueue_tg_reg));
 }
 
diff --git a/net/netfilter/xt_RATEEST.c b/net/netfilter/xt_RATEEST.c
index d80b819..87ae97e 100644
--- a/net/netfilter/xt_RATEEST.c
+++ b/net/netfilter/xt_RATEEST.c
@@ -23,6 +23,7 @@ static DEFINE_MUTEX(xt_rateest_mutex);
 #define RATEEST_HSIZE	16
 static struct hlist_head rateest_hash[RATEEST_HSIZE] __read_mostly;
 static unsigned int jhash_rnd __read_mostly;
+static bool rnd_inited __read_mostly;
 
 static unsigned int xt_rateest_hash(const char *name)
 {
@@ -93,6 +94,11 @@ static bool xt_rateest_tg_checkentry(const struct xt_tgchk_param *par)
 		struct gnet_estimator	est;
 	} cfg;
 
+	if (unlikely(!rnd_inited)) {
+		get_random_bytes(&jhash_rnd, sizeof(jhash_rnd));
+		rnd_inited = true;
+	}
+
 	est = xt_rateest_lookup(info->name);
 	if (est) {
 		/*
@@ -164,7 +170,6 @@ static int __init xt_rateest_tg_init(void)
 	for (i = 0; i < ARRAY_SIZE(rateest_hash); i++)
 		INIT_HLIST_HEAD(&rateest_hash[i]);
 
-	get_random_bytes(&jhash_rnd, sizeof(jhash_rnd));
 	return xt_register_target(&xt_rateest_tg_reg);
 }
 
