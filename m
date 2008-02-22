From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/3][BNX2]: More 5706S link down workaround.
Date: Fri, 22 Feb 2008 11:49:38 -0800
Message-ID: <1203709778.13495.177.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4307 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764721AbYBVTrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Feb 2008 14:47:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: More 5706S link down workaround.

The previous patches to workaround the 5706S on an HP blade were not
sufficient.  The link state still does not change properly in some
cases.  This patch adds polling to make it completely reliable.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 471c7f3..2fa2580 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1273,14 +1273,20 @@ bnx2_set_link(struct bnx2 *bp)
 
 	if ((bp->phy_flags & BNX2_PHY_FLAG_SERDES) &&
 	    (CHIP_NUM(bp) == CHIP_NUM_5706)) {
-		u32 val;
+		u32 val, an_dbg;
 
 		if (bp->phy_flags & BNX2_PHY_FLAG_FORCED_DOWN) {
 			bnx2_5706s_force_link_dn(bp, 0);
 			bp->phy_flags &= ~BNX2_PHY_FLAG_FORCED_DOWN;
 		}
 		val = REG_RD(bp, BNX2_EMAC_STATUS);
-		if (val & BNX2_EMAC_STATUS_LINK)
+
+		bnx2_write_phy(bp, MII_BNX2_MISC_SHADOW, MISC_SHDW_AN_DBG);
+		bnx2_read_phy(bp, MII_BNX2_MISC_SHADOW, &an_dbg);
+		bnx2_read_phy(bp, MII_BNX2_MISC_SHADOW, &an_dbg);
+
+		if ((val & BNX2_EMAC_STATUS_LINK) &&
+		    !(an_dbg & MISC_SHDW_AN_DBG_NOSYNC))
 			bmsr |= BMSR_LSTATUS;
 		else
 			bmsr &= ~BMSR_LSTATUS;
@@ -5390,13 +5396,6 @@ bnx2_5706_serdes_timer(struct bnx2 *bp)
 	int check_link = 1;
 
 	spin_lock(&bp->phy_lock);
-	if (bp->phy_flags & BNX2_PHY_FLAG_FORCED_DOWN) {
-		bnx2_5706s_force_link_dn(bp, 0);
-		bp->phy_flags &= ~BNX2_PHY_FLAG_FORCED_DOWN;
-		spin_unlock(&bp->phy_lock);
-		return;
-	}
-
 	if (bp->serdes_an_pending) {
 		bp->serdes_an_pending--;
 		check_link = 0;
@@ -5420,7 +5419,6 @@ bnx2_5706_serdes_timer(struct bnx2 *bp)
 		 (bp->phy_flags & BNX2_PHY_FLAG_PARALLEL_DETECT)) {
 		u32 phy2;
 
-		check_link = 0;
 		bnx2_write_phy(bp, 0x17, 0x0f01);
 		bnx2_read_phy(bp, 0x15, &phy2);
 		if (phy2 & 0x20) {
@@ -5435,17 +5433,21 @@ bnx2_5706_serdes_timer(struct bnx2 *bp)
 	} else
 		bp->current_interval = bp->timer_interval;
 
-	if (bp->link_up && (bp->autoneg & AUTONEG_SPEED) && check_link) {
+	if (check_link) {
 		u32 val;
 
 		bnx2_write_phy(bp, MII_BNX2_MISC_SHADOW, MISC_SHDW_AN_DBG);
 		bnx2_read_phy(bp, MII_BNX2_MISC_SHADOW, &val);
 		bnx2_read_phy(bp, MII_BNX2_MISC_SHADOW, &val);
 
-		if (val & MISC_SHDW_AN_DBG_NOSYNC) {
-			bnx2_5706s_force_link_dn(bp, 1);
-			bp->phy_flags |= BNX2_PHY_FLAG_FORCED_DOWN;
-		}
+		if (bp->link_up && (val & MISC_SHDW_AN_DBG_NOSYNC)) {
+			if (!(bp->phy_flags & BNX2_PHY_FLAG_FORCED_DOWN)) {
+				bnx2_5706s_force_link_dn(bp, 1);
+				bp->phy_flags |= BNX2_PHY_FLAG_FORCED_DOWN;
+			} else
+				bnx2_set_link(bp);
+		} else if (!bp->link_up && !(val & MISC_SHDW_AN_DBG_NOSYNC))
+			bnx2_set_link(bp);
 	}
 	spin_unlock(&bp->phy_lock);
 }


