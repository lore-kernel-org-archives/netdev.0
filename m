From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/3][BNX2]: Disable parallel detect on an HP blade.
Date: Fri, 22 Feb 2008 11:50:11 -0800
Message-ID: <1203709811.13495.178.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1723 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758435AbYBVTrb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Feb 2008 14:47:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Disable parallel detect on an HP blade.

Because of some board issues, we need to disable parallel detect on
an HP blade.  Without this patch, the link state can become stuck
when it goes into parallel detect mode.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 2fa2580..35356fb 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5362,11 +5362,15 @@ bnx2_test_intr(struct bnx2 *bp)
 	return -ENODEV;
 }
 
+/* Determining link for parallel detection. */
 static int
 bnx2_5706_serdes_has_link(struct bnx2 *bp)
 {
 	u32 mode_ctl, an_dbg, exp;
 
+	if (bp->phy_flags & BNX2_PHY_FLAG_NO_PARALLEL)
+		return 0;
+
 	bnx2_write_phy(bp, MII_BNX2_MISC_SHADOW, MISC_SHDW_MODE_CTL);
 	bnx2_read_phy(bp, MII_BNX2_MISC_SHADOW, &mode_ctl);
 
@@ -7328,7 +7332,15 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 			bp->flags |= BNX2_FLAG_NO_WOL;
 			bp->wol = 0;
 		}
-		if (CHIP_NUM(bp) != CHIP_NUM_5706) {
+		if (CHIP_NUM(bp) == CHIP_NUM_5706) {
+			/* Don't do parallel detect on this board because of
+			 * some board problems.  The link will not go down
+			 * if we do parallel detect.
+			 */
+			if (pdev->subsystem_vendor == PCI_VENDOR_ID_HP &&
+			    pdev->subsystem_device == 0x310c)
+				bp->phy_flags |= BNX2_PHY_FLAG_NO_PARALLEL;
+		} else {
 			bp->phy_addr = 2;
 			if (reg & BNX2_SHARED_HW_CFG_PHY_2_5G)
 				bp->phy_flags |= BNX2_PHY_FLAG_2_5G_CAPABLE;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 3aa0364..1eaf5bb 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6673,6 +6673,7 @@ struct bnx2 {
 #define BNX2_PHY_FLAG_DIS_EARLY_DAC		0x00000400
 #define BNX2_PHY_FLAG_REMOTE_PHY_CAP		0x00000800
 #define BNX2_PHY_FLAG_FORCED_DOWN		0x00001000
+#define BNX2_PHY_FLAG_NO_PARALLEL		0x00002000
 
 	u32			mii_bmcr;
 	u32			mii_bmsr;


