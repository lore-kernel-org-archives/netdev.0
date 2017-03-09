From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net-next v5 6/7] gtp: consolidate pdp context destruction into helper
Date: Thu,  9 Mar 2017 17:43:01 +0100
Message-ID: <20170309164302.13550-7-aschultz@tpip.net>
References: <20170309164302.13550-1-aschultz@tpip.net>
Cc: osmocom-net-gprs@lists.osmocom.org, netdev <netdev@vger.kernel.org>
To: Harald Welte <laforge@gnumonks.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:60143 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932722AbdCIQnr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 11:43:47 -0500
In-Reply-To: <20170309164302.13550-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consolidate duplicate code into helper.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index bf4b352..d58f46f 100644
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
