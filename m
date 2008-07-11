From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 4/6] bnx2: Allow flexible VLAN tag settings.
Date: Thu, 10 Jul 2008 18:29:13 -0700
Message-ID: <1215739755-5495-4-git-send-email-mchan@broadcom.com>
References: <1215739755-5495-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1731 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756548AbYGKB03 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 21:26:29 -0400
In-Reply-To: <1215739755-5495-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Negotiate with boot code and ASF firmware to see if it can
support keeping VLAN tags in the RX packets.  If supported
by firmware, the VLAN tag will be kept in the RX packet
unless VLAN acceleration is registered.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   44 +++++++++++++++++++++++++++-----------------
 drivers/net/bnx2.h |    6 ++++++
 2 files changed, 33 insertions(+), 17 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 4dfd439..2d0213e 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4255,35 +4255,43 @@ nvram_write_end:
 }
 
 static void
-bnx2_init_remote_phy(struct bnx2 *bp)
+bnx2_init_fw_cap(struct bnx2 *bp)
 {
-	u32 val;
+	u32 val, sig = 0;
 
 	bp->phy_flags &= ~BNX2_PHY_FLAG_REMOTE_PHY_CAP;
-	if (!(bp->phy_flags & BNX2_PHY_FLAG_SERDES))
-		return;
+	bp->flags &= ~BNX2_FLAG_CAN_KEEP_VLAN;
+
+	if (!(bp->flags & BNX2_FLAG_ASF_ENABLE))
+		bp->flags |= BNX2_FLAG_CAN_KEEP_VLAN;
 
 	val = bnx2_shmem_rd(bp, BNX2_FW_CAP_MB);
 	if ((val & BNX2_FW_CAP_SIGNATURE_MASK) != BNX2_FW_CAP_SIGNATURE)
 		return;
 
-	if (val & BNX2_FW_CAP_REMOTE_PHY_CAPABLE) {
+	if ((val & BNX2_FW_CAP_CAN_KEEP_VLAN) == BNX2_FW_CAP_CAN_KEEP_VLAN) {
+		bp->flags |= BNX2_FLAG_CAN_KEEP_VLAN;
+		sig |= BNX2_DRV_ACK_CAP_SIGNATURE | BNX2_FW_CAP_CAN_KEEP_VLAN;
+	}
+
+	if ((bp->phy_flags & BNX2_PHY_FLAG_SERDES) &&
+	    (val & BNX2_FW_CAP_REMOTE_PHY_CAPABLE)) {
+		u32 link;
+
 		bp->phy_flags |= BNX2_PHY_FLAG_REMOTE_PHY_CAP;
 
-		val = bnx2_shmem_rd(bp, BNX2_LINK_STATUS);
-		if (val & BNX2_LINK_STATUS_SERDES_LINK)
+		link = bnx2_shmem_rd(bp, BNX2_LINK_STATUS);
+		if (link & BNX2_LINK_STATUS_SERDES_LINK)
 			bp->phy_port = PORT_FIBRE;
 		else
 			bp->phy_port = PORT_TP;
 
-		if (netif_running(bp->dev)) {
-			u32 sig;
-
-			sig = BNX2_DRV_ACK_CAP_SIGNATURE |
-			      BNX2_FW_CAP_REMOTE_PHY_CAPABLE;
-			bnx2_shmem_wr(bp, BNX2_DRV_ACK_CAP_MB, sig);
-		}
+		sig |= BNX2_DRV_ACK_CAP_SIGNATURE |
+		       BNX2_FW_CAP_REMOTE_PHY_CAPABLE;
 	}
+
+	if (netif_running(bp->dev) && sig)
+		bnx2_shmem_wr(bp, BNX2_DRV_ACK_CAP_MB, sig);
 }
 
 static void
@@ -4380,7 +4388,7 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 
 	spin_lock_bh(&bp->phy_lock);
 	old_port = bp->phy_port;
-	bnx2_init_remote_phy(bp);
+	bnx2_init_fw_cap(bp);
 	if ((bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP) &&
 	    old_port != bp->phy_port)
 		bnx2_set_default_remote_link(bp);
@@ -5879,6 +5887,8 @@ bnx2_vlan_rx_register(struct net_device *dev, struct vlan_group *vlgrp)
 
 	bp->vlgrp = vlgrp;
 	bnx2_set_rx_mode(dev);
+	if (bp->flags & BNX2_FLAG_CAN_KEEP_VLAN)
+		bnx2_fw_sync(bp, BNX2_DRV_MSG_CODE_KEEP_VLAN_UPDATE, 0, 1);
 
 	bnx2_netif_start(bp);
 }
@@ -7483,8 +7493,6 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 			if (reg & BNX2_SHARED_HW_CFG_PHY_2_5G)
 				bp->phy_flags |= BNX2_PHY_FLAG_2_5G_CAPABLE;
 		}
-		bnx2_init_remote_phy(bp);
-
 	} else if (CHIP_NUM(bp) == CHIP_NUM_5706 ||
 		   CHIP_NUM(bp) == CHIP_NUM_5708)
 		bp->phy_flags |= BNX2_PHY_FLAG_CRC_FIX;
@@ -7493,6 +7501,8 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		  CHIP_REV(bp) == CHIP_REV_Bx))
 		bp->phy_flags |= BNX2_PHY_FLAG_DIS_EARLY_DAC;
 
+	bnx2_init_fw_cap(bp);
+
 	if ((CHIP_ID(bp) == CHIP_ID_5708_A0) ||
 	    (CHIP_ID(bp) == CHIP_ID_5708_B0) ||
 	    (CHIP_ID(bp) == CHIP_ID_5708_B1)) {
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index efa0ca9..7b882fd 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6670,6 +6670,7 @@ struct bnx2 {
 #define BNX2_FLAG_USING_MSI_OR_MSIX	(BNX2_FLAG_USING_MSI | \
 					 BNX2_FLAG_USING_MSIX)
 #define BNX2_FLAG_JUMBO_BROKEN		0x00000800
+#define BNX2_FLAG_CAN_KEEP_VLAN		0x00001000
 
 	struct bnx2_napi	bnx2_napi[BNX2_MAX_MSIX_VEC];
 
@@ -6951,6 +6952,7 @@ struct fw_info {
 #define BNX2_DRV_MSG_CODE_DIAG			 0x07000000
 #define BNX2_DRV_MSG_CODE_SUSPEND_NO_WOL	 0x09000000
 #define BNX2_DRV_MSG_CODE_UNLOAD_LNK_DN		 0x0b000000
+#define BNX2_DRV_MSG_CODE_KEEP_VLAN_UPDATE	 0x0d000000
 #define BNX2_DRV_MSG_CODE_CMD_SET_LINK		 0x10000000
 
 #define BNX2_DRV_MSG_DATA			 0x00ff0000
@@ -7279,6 +7281,10 @@ struct fw_info {
 #define BNX2_FW_CAP_SIGNATURE_MASK		 0xffff0000
 #define BNX2_FW_CAP_REMOTE_PHY_CAPABLE		 0x00000001
 #define BNX2_FW_CAP_REMOTE_PHY_PRESENT		 0x00000002
+#define BNX2_FW_CAP_MFW_CAN_KEEP_VLAN		 0x00000008
+#define BNX2_FW_CAP_BC_CAN_KEEP_VLAN		 0x00000010
+#define BNX2_FW_CAP_CAN_KEEP_VLAN	(BNX2_FW_CAP_BC_CAN_KEEP_VLAN | \
+					 BNX2_FW_CAP_MFW_CAN_KEEP_VLAN)
 
 #define BNX2_RPHY_SIGNATURE			0x36c
 #define BNX2_RPHY_LOAD_SIGNATURE		 0x5a5a5a5a
-- 
1.5.5.GIT


