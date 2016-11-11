From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 1/2] bnxt_en: Fix ring arithmetic in bnxt_setup_tc().
Date: Fri, 11 Nov 2016 00:11:42 -0500
Message-ID: <1478841103-22413-2-git-send-email-michael.chan@broadcom.com>
References: <1478841103-22413-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34751 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755811AbcKKFLy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 00:11:54 -0500
Received: by mail-pf0-f171.google.com with SMTP id n85so5371846pfi.1
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 21:11:53 -0800 (PST)
In-Reply-To: <1478841103-22413-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The logic is missing the check on whether the tx and rx rings are sharing
completion rings or not.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index a9f9f37..c690966 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -6309,6 +6309,7 @@ static int bnxt_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 			 struct tc_to_netdev *ntc)
 {
 	struct bnxt *bp = netdev_priv(dev);
+	bool sh = false;
 	u8 tc;
 
 	if (ntc->type != TC_SETUP_MQPRIO)
@@ -6325,12 +6326,11 @@ static int bnxt_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 	if (netdev_get_num_tc(dev) == tc)
 		return 0;
 
+	if (bp->flags & BNXT_FLAG_SHARED_RINGS)
+		sh = true;
+
 	if (tc) {
 		int max_rx_rings, max_tx_rings, rc;
-		bool sh = false;
-
-		if (bp->flags & BNXT_FLAG_SHARED_RINGS)
-			sh = true;
 
 		rc = bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, sh);
 		if (rc || bp->tx_nr_rings_per_tc * tc > max_tx_rings)
@@ -6348,7 +6348,8 @@ static int bnxt_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 		bp->tx_nr_rings = bp->tx_nr_rings_per_tc;
 		netdev_reset_tc(dev);
 	}
-	bp->cp_nr_rings = max_t(int, bp->tx_nr_rings, bp->rx_nr_rings);
+	bp->cp_nr_rings = sh ? max_t(int, bp->tx_nr_rings, bp->rx_nr_rings) :
+			       bp->tx_nr_rings + bp->rx_nr_rings;
 	bp->num_stat_ctxs = bp->cp_nr_rings;
 
 	if (netif_running(bp->dev))
-- 
1.8.3.1
