From: "Michael Chan" <mchan@broadcom.com>
Subject: [BNX2 2/4]: Fix 5709 Serdes detection.
Date: Mon, 08 Jan 2007 15:56:31 -0800
Message-ID: <1168300591.4430.8.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2843 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161165AbXAHXJl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jan 2007 18:09:41 -0500
To: davem@davemloft.net, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Fix 5709 Serdes detection.

5709 has a new register to detect copper/fiber PHYs.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 8d682fc..e325f93 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5643,6 +5643,44 @@ poll_bnx2(struct net_device *dev)
 }
 #endif
 
+static void __devinit
+bnx2_get_5709_media(struct bnx2 *bp)
+{
+	u32 val = REG_RD(bp, BNX2_MISC_DUAL_MEDIA_CTRL);
+	u32 bond_id = val & BNX2_MISC_DUAL_MEDIA_CTRL_BOND_ID;
+	u32 strap;
+
+	if (bond_id == BNX2_MISC_DUAL_MEDIA_CTRL_BOND_ID_C)
+		return;
+	else if (bond_id == BNX2_MISC_DUAL_MEDIA_CTRL_BOND_ID_S) {
+		bp->phy_flags |= PHY_SERDES_FLAG;
+		return;
+	}
+
+	if (val & BNX2_MISC_DUAL_MEDIA_CTRL_STRAP_OVERRIDE)
+		strap = (val & BNX2_MISC_DUAL_MEDIA_CTRL_PHY_CTRL) >> 21;
+	else
+		strap = (val & BNX2_MISC_DUAL_MEDIA_CTRL_PHY_CTRL_STRAP) >> 8;
+
+	if (PCI_FUNC(bp->pdev->devfn) == 0) {
+		switch (strap) {
+		case 0x4:
+		case 0x5:
+		case 0x6:
+			bp->phy_flags |= PHY_SERDES_FLAG;
+			return;
+		}
+	} else {
+		switch (strap) {
+		case 0x1:
+		case 0x2:
+		case 0x4:
+			bp->phy_flags |= PHY_SERDES_FLAG;
+			return;
+		}
+	}
+}
+
 static int __devinit
 bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 {
@@ -5863,10 +5901,9 @@ bnx2_init_board(struct pci_dev *pdev, st
 	bp->phy_addr = 1;
 
 	/* Disable WOL support if we are running on a SERDES chip. */
-	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
-		if (CHIP_BOND_ID(bp) != BNX2_MISC_DUAL_MEDIA_CTRL_BOND_ID_C)
-			bp->phy_flags |= PHY_SERDES_FLAG;
-	} else if (CHIP_BOND_ID(bp) & CHIP_BOND_ID_SERDES_BIT)
+	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+		bnx2_get_5709_media(bp);
+	else if (CHIP_BOND_ID(bp) & CHIP_BOND_ID_SERDES_BIT)
 		bp->phy_flags |= PHY_SERDES_FLAG;
 
 	if (bp->phy_flags & PHY_SERDES_FLAG) {


