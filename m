From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/62: xt_recent: save 8 bytes per htable
Date: Tue, 16 Feb 2010 15:55:21 +0100 (MET)
Message-ID: <20100216145519.2796.39711.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51943 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755514Ab0BPOzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:55:25 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 89bc7a0f64de7bed2e0bc68a23d75699a610cd37
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Mon Jan 4 16:26:03 2010 +0100

    netfilter: xt_recent: save 8 bytes per htable
    
    Moving rnd_inited into the hole after the uint8 lets go of the uint32
    rnd_inited was using, plus the padding that would follow the int group.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index dd16e40..5bdc1fb 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -81,13 +81,13 @@ struct xt_hashlimit_htable {
 	struct hlist_node node;		/* global list of all htables */
 	atomic_t use;
 	u_int8_t family;
+	bool rnd_initialized;
 
 	struct hashlimit_cfg1 cfg;	/* config */
 
 	/* used internally */
 	spinlock_t lock;		/* lock for list_head */
 	u_int32_t rnd;			/* random seed for hash */
-	int rnd_initialized;
 	unsigned int count;		/* number entries in table */
 	struct timer_list timer;	/* timer for gc */
 
@@ -150,7 +150,7 @@ dsthash_alloc_init(struct xt_hashlimit_htable *ht,
 	 * the first hashtable entry */
 	if (!ht->rnd_initialized) {
 		get_random_bytes(&ht->rnd, sizeof(ht->rnd));
-		ht->rnd_initialized = 1;
+		ht->rnd_initialized = true;
 	}
 
 	if (ht->cfg.max && ht->count >= ht->cfg.max) {
@@ -235,7 +235,7 @@ static int htable_create_v0(struct xt_hashlimit_info *minfo, u_int8_t family)
 	atomic_set(&hinfo->use, 1);
 	hinfo->count = 0;
 	hinfo->family = family;
-	hinfo->rnd_initialized = 0;
+	hinfo->rnd_initialized = false;
 	spin_lock_init(&hinfo->lock);
 	hinfo->pde = proc_create_data(minfo->name, 0,
 		(family == NFPROTO_IPV4) ?
@@ -296,7 +296,7 @@ static int htable_create(struct xt_hashlimit_mtinfo1 *minfo, u_int8_t family)
 	atomic_set(&hinfo->use, 1);
 	hinfo->count = 0;
 	hinfo->family = family;
-	hinfo->rnd_initialized = 0;
+	hinfo->rnd_initialized = false;
 	spin_lock_init(&hinfo->lock);
 
 	hinfo->pde = proc_create_data(minfo->name, 0,
