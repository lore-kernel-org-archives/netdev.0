From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 08/17] gtp: consolidate pdp context destruction into helper
Date: Mon, 23 Jan 2017 12:56:57 +0100
Message-ID: <20170123115706.4354-9-aschultz@tpip.net>
References: <20170123115706.4354-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:41459 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750908AbdAWMGy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 07:06:54 -0500
In-Reply-To: <20170123115706.4354-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index f434f84..5b35ebb 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -84,6 +84,8 @@ struct gtp_net {
 
 static u32 gtp_h_initval;
 
+static void pdp_context_delete(struct pdp_ctx *pctx);
+
 static inline u32 gtp0_hashfn(u64 tid)
 {
 	u32 *tid32 = (u32 *) &tid;
@@ -775,13 +777,10 @@ static void gtp_hashtable_free(struct gtp_dev *gtp)
 	struct pdp_ctx *pctx;
 	int i;
 
-	for (i = 0; i < gtp->hash_size; i++) {
-		hlist_for_each_entry_rcu(pctx, &gtp->tid_hash[i], hlist_tid) {
-			hlist_del_rcu(&pctx->hlist_tid);
-			hlist_del_rcu(&pctx->hlist_addr);
-			kfree_rcu(pctx, rcu_head);
-		}
-	}
+	for (i = 0; i < gtp->hash_size; i++)
+		hlist_for_each_entry_rcu(pctx, &gtp->tid_hash[i], hlist_tid)
+			pdp_context_delete(pctx);
+
 	synchronize_rcu();
 	kfree(gtp->addr_hash);
 	kfree(gtp->tid_hash);
@@ -984,6 +983,13 @@ static int ipv4_pdp_add(struct net_device *dev, struct genl_info *info)
 	return 0;
 }
 
+static void pdp_context_delete(struct pdp_ctx *pctx)
+{
+	hlist_del_rcu(&pctx->hlist_tid);
+	hlist_del_rcu(&pctx->hlist_addr);
+	kfree_rcu(pctx, rcu_head);
+}
+
 static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net_device *dev;
@@ -1082,10 +1088,7 @@ static int gtp_genl_del_pdp(struct sk_buff *skb, struct genl_info *info)
 		pr_debug("GTPv1-U: deleting tunnel id = %x/%x (pdp %p)\n",
 			 pctx->u.v1.i_tei, pctx->u.v1.o_tei, pctx);
 
-	hlist_del_rcu(&pctx->hlist_tid);
-	hlist_del_rcu(&pctx->hlist_addr);
-	kfree_rcu(pctx, rcu_head);
-
+	pdp_context_delete(pctx);
 	return 0;
 }
 
-- 
2.10.2
