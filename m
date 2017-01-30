From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 4/6] gtp: consolidate pdp context destruction into helper
Date: Mon, 30 Jan 2017 17:31:58 +0100
Message-ID: <20170130163200.17070-5-aschultz@tpip.net>
References: <20170130163200.17070-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:46930 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750850AbdA3QmK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Jan 2017 11:42:10 -0500
In-Reply-To: <20170130163200.17070-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consolidate duplicate code into helper.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 6b7a3c2..68c6c9b 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -84,6 +84,8 @@ struct gtp_net {
 
 static u32 gtp_h_initval;
 
+static void pdp_context_delete(struct pdp_ctx *pctx);
+
 static inline u32 gtp0_hashfn(u64 tid)
 {
 	u32 *tid32 = (u32 *) &tid;
@@ -774,13 +776,10 @@ static void gtp_hashtable_free(struct gtp_dev *gtp)
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
@@ -985,6 +984,13 @@ static int ipv4_pdp_add(struct gtp_dev *gtp, struct genl_info *info)
 	return 0;
 }
 
+static void pdp_context_delete(struct pdp_ctx *pctx)
+{
+	hlist_del_rcu(&pctx->hlist_tid);
+	hlist_del_rcu(&pctx->hlist_addr);
+	kfree(pctx);
+}
+
 static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 {
 	struct gtp_dev *gtp;
@@ -1093,9 +1099,7 @@ static int gtp_genl_del_pdp(struct sk_buff *skb, struct genl_info *info)
 		pr_debug("GTPv1-U: deleting tunnel id = %x/%x (pdp %p)\n",
 			 pctx->u.v1.i_tei, pctx->u.v1.o_tei, pctx);
 
-	hlist_del_rcu(&pctx->hlist_tid);
-	hlist_del_rcu(&pctx->hlist_addr);
-	kfree_rcu(pctx, rcu_head);
+	pdp_context_delete(pctx);
 
 out_unlock:
 	rcu_read_unlock();
-- 
2.10.2
