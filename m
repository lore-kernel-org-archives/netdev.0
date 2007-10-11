From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/3][BNX2]: Fix default WoL setting.
Date: Wed, 10 Oct 2007 17:01:59 -0700
Message-ID: <1192060919.6534.5.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mann@vmware.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4233 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756702AbXJJXC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 19:02:26 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Fix default WoL setting.

Change the default WoL setting to match the NVRAM's setting.  It
always defaulted to WoL disabled before and caused a lot of confusion
for users.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 21493e0..574d043 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6569,8 +6569,11 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		if (i != 2)
 			bp->fw_version[j++] = '.';
 	}
-	if (REG_RD_IND(bp, bp->shmem_base + BNX2_PORT_FEATURE) &
-	    BNX2_PORT_FEATURE_ASF_ENABLED) {
+	reg = REG_RD_IND(bp, bp->shmem_base + BNX2_PORT_FEATURE);
+	if (reg & BNX2_PORT_FEATURE_WOL_ENABLED)
+		bp->wol = 1;
+
+	if (reg & BNX2_PORT_FEATURE_ASF_ENABLED) {
 		bp->flags |= ASF_ENABLE_FLAG;
 
 		for (i = 0; i < 30; i++) {
@@ -6640,11 +6643,14 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bp->phy_port = PORT_TP;
 	if (bp->phy_flags & PHY_SERDES_FLAG) {
 		bp->phy_port = PORT_FIBRE;
-		bp->flags |= NO_WOL_FLAG;
+		reg = REG_RD_IND(bp, bp->shmem_base +
+				     BNX2_SHARED_HW_CFG_CONFIG);
+		if (!(reg & BNX2_SHARED_HW_CFG_GIG_LINK_ON_VAUX)) {
+			bp->flags |= NO_WOL_FLAG;
+			bp->wol = 0;
+		}
 		if (CHIP_NUM(bp) != CHIP_NUM_5706) {
 			bp->phy_addr = 2;
-			reg = REG_RD_IND(bp, bp->shmem_base +
-					 BNX2_SHARED_HW_CFG_CONFIG);
 			if (reg & BNX2_SHARED_HW_CFG_PHY_2_5G)
 				bp->phy_flags |= PHY_2_5G_CAPABLE_FLAG;
 		}
@@ -6659,8 +6665,10 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 
 	if ((CHIP_ID(bp) == CHIP_ID_5708_A0) ||
 	    (CHIP_ID(bp) == CHIP_ID_5708_B0) ||
-	    (CHIP_ID(bp) == CHIP_ID_5708_B1))
+	    (CHIP_ID(bp) == CHIP_ID_5708_B1)) {
 		bp->flags |= NO_WOL_FLAG;
+		bp->wol = 0;
+	}
 
 	if (CHIP_ID(bp) == CHIP_ID_5706_A0) {
 		bp->tx_quick_cons_trip_int =
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 56c190f..1dce0d1 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6908,6 +6908,7 @@ struct fw_info {
 #define BNX2_SHARED_HW_CFG_LED_MODE_MAC		 0
 #define BNX2_SHARED_HW_CFG_LED_MODE_GPHY1	 0x100
 #define BNX2_SHARED_HW_CFG_LED_MODE_GPHY2	 0x200
+#define BNX2_SHARED_HW_CFG_GIG_LINK_ON_VAUX	 0x8000
 
 #define BNX2_SHARED_HW_CFG_CONFIG2		0x00000040
 #define BNX2_SHARED_HW_CFG2_NVM_SIZE_MASK	 0x00fff000


