From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 1/4] bnx2: Advertise nothing when speed is forced
Date: Tue, 31 Dec 2013 23:22:32 -0800
Message-ID: <1388560955-32586-2-git-send-email-mchan@broadcom.com>
References: <1388560955-32586-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:52184 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391AbaAAG6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 01:58:48 -0500
In-Reply-To: <1388560955-32586-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code does not reset the advertisement register when the speed
is forced, leaving the default advertisement value of 10 Mbps.  This does
not work with some link partners when the next patch enables auto-mdix.

Set advertisement register to 0 if the speed is forced.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 0ced358..1ae3348 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -2048,29 +2048,27 @@ bnx2_setup_copper_phy(struct bnx2 *bp)
 __releases(&bp->phy_lock)
 __acquires(&bp->phy_lock)
 {
-	u32 bmcr;
+	u32 bmcr, adv_reg, new_adv = 0;
 	u32 new_bmcr;
 
 	bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 
+	bnx2_read_phy(bp, bp->mii_adv, &adv_reg);
+	adv_reg &= (PHY_ALL_10_100_SPEED | ADVERTISE_PAUSE_CAP |
+		    ADVERTISE_PAUSE_ASYM);
+
+	new_adv = ADVERTISE_CSMA | ethtool_adv_to_mii_adv_t(bp->advertising);
+
 	if (bp->autoneg & AUTONEG_SPEED) {
-		u32 adv_reg, adv1000_reg;
-		u32 new_adv = 0;
+		u32 adv1000_reg;
 		u32 new_adv1000 = 0;
 
-		bnx2_read_phy(bp, bp->mii_adv, &adv_reg);
-		adv_reg &= (PHY_ALL_10_100_SPEED | ADVERTISE_PAUSE_CAP |
-			ADVERTISE_PAUSE_ASYM);
+		new_adv |= bnx2_phy_get_pause_adv(bp);
 
 		bnx2_read_phy(bp, MII_CTRL1000, &adv1000_reg);
 		adv1000_reg &= PHY_ALL_1000_SPEED;
 
-		new_adv = ethtool_adv_to_mii_adv_t(bp->advertising);
-		new_adv |= ADVERTISE_CSMA;
-		new_adv |= bnx2_phy_get_pause_adv(bp);
-
 		new_adv1000 |= ethtool_adv_to_mii_ctrl1000_t(bp->advertising);
-
 		if ((adv1000_reg != new_adv1000) ||
 			(adv_reg != new_adv) ||
 			((bmcr & BMCR_ANENABLE) == 0)) {
@@ -2090,6 +2088,10 @@ __acquires(&bp->phy_lock)
 		return 0;
 	}
 
+	/* advertise nothing when forcing speed */
+	if (adv_reg != new_adv)
+		bnx2_write_phy(bp, bp->mii_adv, new_adv);
+
 	new_bmcr = 0;
 	if (bp->req_line_speed == SPEED_100) {
 		new_bmcr |= BMCR_SPEED100;
-- 
1.7.1
