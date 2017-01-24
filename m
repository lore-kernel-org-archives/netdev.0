From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH v2 08/18] gtp: consolidate pdp context destruction into helper
Date: Tue, 24 Jan 2017 16:28:38 +0100
Message-ID: <20170124152848.6120-9-aschultz@tpip.net>
References: <20170124152848.6120-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:34279 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751135AbdAXP25 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 10:28:57 -0500
In-Reply-To: <20170124152848.6120-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove duplicate code and use a rcu helper to free the
structure to prepare for addition of PDP context members
that need to be handled in the rcu callcack.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 32 +++++++++++++++++++++-----------
 1 file changed, 21 insertions(+), 11 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index f434f84..c117f63 100644
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
@@ -984,6 +983,20 @@ static int ipv4_pdp_add(struct net_device *dev, struct genl_info *info)
 	return 0;
 }
 
+static void pdp_context_free(struct rcu_head *head)
+{
+	struct pdp_ctx *pctx = container_of(head, struct pdp_ctx, rcu_head);
+
+	kfree(pctx);
+}
+
+static void pdp_context_delete(struct pdp_ctx *pctx)
+{
+	hlist_del_rcu(&pctx->hlist_tid);
+	hlist_del_rcu(&pctx->hlist_addr);
+	call_rcu(&pctx->rcu_head, pdp_context_free);
+}
+
 static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net_device *dev;
@@ -1082,10 +1095,7 @@ static int gtp_genl_del_pdp(struct sk_buff *skb, struct genl_info *info)
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
