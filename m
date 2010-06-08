From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH] bnx2: Fix compiler warning in
 bnx2_disable_forced_2g5().
Date: Tue, 8 Jun 2010 10:21:30 -0700
Message-ID: <1276017690-5442-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: prarit@redhat.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2140 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752971Ab0FHRTd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jun 2010 13:19:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/bnx2.c: In function 'bnx2_disable_forced_2g5':
drivers/net/bnx2.c:1489: warning: 'bmcr' may be used uninitialized in this function

We fix it by checking return values from all bnx2_read_phy() and proceeding
to do read-modify-write only if the read operation is successful.

The related bnx2_enable_forced_2g5() is also fixed the same way.

Reported-by: Prarit Bhargava <prarit@redhat.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   43 ++++++++++++++++++++++++++++---------------
 1 files changed, 28 insertions(+), 15 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 949d7a9..522de9f 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1446,7 +1446,8 @@ bnx2_test_and_disable_2g5(struct bnx2 *bp)
 static void
 bnx2_enable_forced_2g5(struct bnx2 *bp)
 {
-	u32 bmcr;
+	u32 uninitialized_var(bmcr);
+	int err;
 
 	if (!(bp->phy_flags & BNX2_PHY_FLAG_2_5G_CAPABLE))
 		return;
@@ -1456,22 +1457,28 @@ bnx2_enable_forced_2g5(struct bnx2 *bp)
 
 		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR,
 			       MII_BNX2_BLK_ADDR_SERDES_DIG);
-		bnx2_read_phy(bp, MII_BNX2_SERDES_DIG_MISC1, &val);
-		val &= ~MII_BNX2_SD_MISC1_FORCE_MSK;
-		val |= MII_BNX2_SD_MISC1_FORCE | MII_BNX2_SD_MISC1_FORCE_2_5G;
-		bnx2_write_phy(bp, MII_BNX2_SERDES_DIG_MISC1, val);
+		if (!bnx2_read_phy(bp, MII_BNX2_SERDES_DIG_MISC1, &val)) {
+			val &= ~MII_BNX2_SD_MISC1_FORCE_MSK;
+			val |= MII_BNX2_SD_MISC1_FORCE |
+				MII_BNX2_SD_MISC1_FORCE_2_5G;
+			bnx2_write_phy(bp, MII_BNX2_SERDES_DIG_MISC1, val);
+		}
 
 		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR,
 			       MII_BNX2_BLK_ADDR_COMBO_IEEEB0);
-		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
+		err = bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 
 	} else if (CHIP_NUM(bp) == CHIP_NUM_5708) {
-		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
-		bmcr |= BCM5708S_BMCR_FORCE_2500;
+		err = bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
+		if (!err)
+			bmcr |= BCM5708S_BMCR_FORCE_2500;
 	} else {
 		return;
 	}
 
+	if (err)
+		return;
+
 	if (bp->autoneg & AUTONEG_SPEED) {
 		bmcr &= ~BMCR_ANENABLE;
 		if (bp->req_duplex == DUPLEX_FULL)
@@ -1483,7 +1490,8 @@ bnx2_enable_forced_2g5(struct bnx2 *bp)
 static void
 bnx2_disable_forced_2g5(struct bnx2 *bp)
 {
-	u32 bmcr;
+	u32 uninitialized_var(bmcr);
+	int err;
 
 	if (!(bp->phy_flags & BNX2_PHY_FLAG_2_5G_CAPABLE))
 		return;
@@ -1493,21 +1501,26 @@ bnx2_disable_forced_2g5(struct bnx2 *bp)
 
 		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR,
 			       MII_BNX2_BLK_ADDR_SERDES_DIG);
-		bnx2_read_phy(bp, MII_BNX2_SERDES_DIG_MISC1, &val);
-		val &= ~MII_BNX2_SD_MISC1_FORCE;
-		bnx2_write_phy(bp, MII_BNX2_SERDES_DIG_MISC1, val);
+		if (!bnx2_read_phy(bp, MII_BNX2_SERDES_DIG_MISC1, &val)) {
+			val &= ~MII_BNX2_SD_MISC1_FORCE;
+			bnx2_write_phy(bp, MII_BNX2_SERDES_DIG_MISC1, val);
+		}
 
 		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR,
 			       MII_BNX2_BLK_ADDR_COMBO_IEEEB0);
-		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
+		err = bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 
 	} else if (CHIP_NUM(bp) == CHIP_NUM_5708) {
-		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
-		bmcr &= ~BCM5708S_BMCR_FORCE_2500;
+		err = bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
+		if (!err)
+			bmcr &= ~BCM5708S_BMCR_FORCE_2500;
 	} else {
 		return;
 	}
 
+	if (err)
+		return;
+
 	if (bp->autoneg & AUTONEG_SPEED)
 		bmcr |= BMCR_SPEED1000 | BMCR_ANENABLE | BMCR_ANRESTART;
 	bnx2_write_phy(bp, bp->mii_bmcr, bmcr);
-- 
1.6.4.GIT


