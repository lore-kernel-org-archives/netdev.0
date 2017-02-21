From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net-next v4 6/7] gtp: consolidate pdp context destruction into helper
Date: Tue, 21 Feb 2017 11:18:54 +0100
Message-ID: <20170221101855.23940-7-aschultz@tpip.net>
References: <20170221101855.23940-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        osmocom-net-gprs@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:34533 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751761AbdBUKTD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Feb 2017 05:19:03 -0500
In-Reply-To: <20170221101855.23940-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consolidate duplicate code into helper.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index f529d1e..b6aae68 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -86,6 +86,8 @@ struct gtp_net {
 
 static u32 gtp_h_initval;
 
+static void pdp_context_delete(struct pdp_ctx *pctx);
+
 static inline u32 gtp0_hashfn(u64 tid)
 {
 	u32 *tid32 = (u32 *) &tid;
@@ -780,13 +782,10 @@ static void gtp_hashtable_free(struct gtp_dev *gtp)
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
@@ -995,6 +994,13 @@ static int ipv4_pdp_add(struct gtp_dev *gtp, struct genl_info *info)
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
 	struct gtp_dev *gtp;
@@ -1100,9 +1106,7 @@ static int gtp_genl_del_pdp(struct sk_buff *skb, struct genl_info *info)
 		netdev_dbg(pctx->dev, "GTPv1-U: deleting tunnel id = %x/%x (pdp %p)\n",
 			   pctx->u.v1.i_tei, pctx->u.v1.o_tei, pctx);
 
-	hlist_del_rcu(&pctx->hlist_tid);
-	hlist_del_rcu(&pctx->hlist_addr);
-	kfree_rcu(pctx, rcu_head);
+	pdp_context_delete(pctx);
 
 out_unlock:
 	rcu_read_unlock();
-- 
2.10.2
