From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH v2 11/16][BNX2]: Add support for 5709 Serdes.
Date: Thu, 03 May 2007 00:30:37 -0700
Message-ID: <1178177437.4909.74.camel@dell>
References: <1178068303.4820.35.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2344 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030970AbXECGnd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 02:43:33 -0400
In-Reply-To: <1178068303.4820.35.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Add support for 5709 Serdes.

Add PCI ID and code to support the 5709 Serdes PHY.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 944f547..ab58909 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -84,6 +84,7 @@ typedef enum {
 	BCM5708,
 	BCM5708S,
 	BCM5709,
+	BCM5709S,
 } board_t;
 
 /* indexed by board_t, above */
@@ -98,6 +99,7 @@ static const struct {
 	{ "Broadcom NetXtreme II BCM5708 1000Base-T" },
 	{ "Broadcom NetXtreme II BCM5708 1000Base-SX" },
 	{ "Broadcom NetXtreme II BCM5709 1000Base-T" },
+	{ "Broadcom NetXtreme II BCM5709 1000Base-SX" },
 	};
 
 static struct pci_device_id bnx2_pci_tbl[] = {
@@ -117,6 +119,8 @@ static struct pci_device_id bnx2_pci_tbl[] = {
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5708S },
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5709,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5709 },
+	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5709S,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5709S },
 	{ 0, }
 };
 
@@ -700,6 +704,45 @@ bnx2_resolve_flow_ctrl(struct bnx2 *bp)
 }
 
 static int
+bnx2_5709s_linkup(struct bnx2 *bp)
+{
+	u32 val, speed;
+
+	bp->link_up = 1;
+
+	bnx2_write_phy(bp, MII_BNX2_BLK_ADDR, MII_BNX2_BLK_ADDR_GP_STATUS);
+	bnx2_read_phy(bp, MII_BNX2_GP_TOP_AN_STATUS1, &val);
+	bnx2_write_phy(bp, MII_BNX2_BLK_ADDR, MII_BNX2_BLK_ADDR_COMBO_IEEEB0);
+
+	if ((bp->autoneg & AUTONEG_SPEED) == 0) {
+		bp->line_speed = bp->req_line_speed;
+		bp->duplex = bp->req_duplex;
+		return 0;
+	}
+	speed = val & MII_BNX2_GP_TOP_AN_SPEED_MSK;
+	switch (speed) {
+		case MII_BNX2_GP_TOP_AN_SPEED_10:
+			bp->line_speed = SPEED_10;
+			break;
+		case MII_BNX2_GP_TOP_AN_SPEED_100:
+			bp->line_speed = SPEED_100;
+			break;
+		case MII_BNX2_GP_TOP_AN_SPEED_1G:
+		case MII_BNX2_GP_TOP_AN_SPEED_1GKV:
+			bp->line_speed = SPEED_1000;
+			break;
+		case MII_BNX2_GP_TOP_AN_SPEED_2_5G:
+			bp->line_speed = SPEED_2500;
+			break;
+	}
+	if (val & MII_BNX2_GP_TOP_AN_FD)
+		bp->duplex = DUPLEX_FULL;
+	else
+		bp->duplex = DUPLEX_HALF;
+	return 0;
+}
+
+static int
 bnx2_5708s_linkup(struct bnx2 *bp)
 {
 	u32 val;
@@ -898,6 +941,24 @@ bnx2_set_mac_link(struct bnx2 *bp)
 	return 0;
 }
 
+static void
+bnx2_enable_bmsr1(struct bnx2 *bp)
+{
+	if ((bp->phy_flags & PHY_SERDES_FLAG) &&
+	    (CHIP_NUM(bp) == CHIP_NUM_5709))
+		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR,
+			       MII_BNX2_BLK_ADDR_GP_STATUS);
+}
+
+static void
+bnx2_disable_bmsr1(struct bnx2 *bp)
+{
+	if ((bp->phy_flags & PHY_SERDES_FLAG) &&
+	    (CHIP_NUM(bp) == CHIP_NUM_5709))
+		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR,
+			       MII_BNX2_BLK_ADDR_COMBO_IEEEB0);
+}
+
 static int
 bnx2_test_and_enable_2g5(struct bnx2 *bp)
 {
@@ -910,6 +971,9 @@ bnx2_test_and_enable_2g5(struct bnx2 *bp)
 	if (bp->autoneg & AUTONEG_SPEED)
 		bp->advertising |= ADVERTISED_2500baseX_Full;
 
+	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR, MII_BNX2_BLK_ADDR_OVER1G);
+
 	bnx2_read_phy(bp, bp->mii_up1, &up1);
 	if (!(up1 & BCM5708S_UP1_2G5)) {
 		up1 |= BCM5708S_UP1_2G5;
@@ -917,6 +981,10 @@ bnx2_test_and_enable_2g5(struct bnx2 *bp)
 		ret = 0;
 	}
 
+	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR,
+			       MII_BNX2_BLK_ADDR_COMBO_IEEEB0);
+
 	return ret;
 }
 
@@ -929,6 +997,9 @@ bnx2_test_and_disable_2g5(struct bnx2 *bp)
 	if (!(bp->phy_flags & PHY_2_5G_CAPABLE_FLAG))
 		return 0;
 
+	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR, MII_BNX2_BLK_ADDR_OVER1G);
+
 	bnx2_read_phy(bp, bp->mii_up1, &up1);
 	if (up1 & BCM5708S_UP1_2G5) {
 		up1 &= ~BCM5708S_UP1_2G5;
@@ -936,6 +1007,10 @@ bnx2_test_and_disable_2g5(struct bnx2 *bp)
 		ret = 1;
 	}
 
+	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR,
+			       MII_BNX2_BLK_ADDR_COMBO_IEEEB0);
+
 	return ret;
 }
 
@@ -947,7 +1022,21 @@ bnx2_enable_forced_2g5(struct bnx2 *bp)
 	if (!(bp->phy_flags & PHY_2_5G_CAPABLE_FLAG))
 		return;
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5708) {
+	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+		u32 val;
+
+		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR,
+			       MII_BNX2_BLK_ADDR_SERDES_DIG);
+		bnx2_read_phy(bp, MII_BNX2_SERDES_DIG_MISC1, &val);
+		val &= ~MII_BNX2_SD_MISC1_FORCE_MSK;
+		val |= MII_BNX2_SD_MISC1_FORCE | MII_BNX2_SD_MISC1_FORCE_2_5G;
+		bnx2_write_phy(bp, MII_BNX2_SERDES_DIG_MISC1, val);
+
+		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR,
+			       MII_BNX2_BLK_ADDR_COMBO_IEEEB0);
+		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
+
+	} else if (CHIP_NUM(bp) == CHIP_NUM_5708) {
 		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 		bmcr |= BCM5708S_BMCR_FORCE_2500;
 	}
@@ -968,7 +1057,20 @@ bnx2_disable_forced_2g5(struct bnx2 *bp)
 	if (!(bp->phy_flags & PHY_2_5G_CAPABLE_FLAG))
 		return;
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5708) {
+	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+		u32 val;
+
+		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR,
+			       MII_BNX2_BLK_ADDR_SERDES_DIG);
+		bnx2_read_phy(bp, MII_BNX2_SERDES_DIG_MISC1, &val);
+		val &= ~MII_BNX2_SD_MISC1_FORCE;
+		bnx2_write_phy(bp, MII_BNX2_SERDES_DIG_MISC1, val);
+
+		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR,
+			       MII_BNX2_BLK_ADDR_COMBO_IEEEB0);
+		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
+
+	} else if (CHIP_NUM(bp) == CHIP_NUM_5708) {
 		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 		bmcr &= ~BCM5708S_BMCR_FORCE_2500;
 	}
@@ -991,8 +1093,10 @@ bnx2_set_link(struct bnx2 *bp)
 
 	link_up = bp->link_up;
 
-	bnx2_read_phy(bp, bp->mii_bmsr, &bmsr);
-	bnx2_read_phy(bp, bp->mii_bmsr, &bmsr);
+	bnx2_enable_bmsr1(bp);
+	bnx2_read_phy(bp, bp->mii_bmsr1, &bmsr);
+	bnx2_read_phy(bp, bp->mii_bmsr1, &bmsr);
+	bnx2_disable_bmsr1(bp);
 
 	if ((bp->phy_flags & PHY_SERDES_FLAG) &&
 	    (CHIP_NUM(bp) == CHIP_NUM_5706)) {
@@ -1013,6 +1117,8 @@ bnx2_set_link(struct bnx2 *bp)
 				bnx2_5706s_linkup(bp);
 			else if (CHIP_NUM(bp) == CHIP_NUM_5708)
 				bnx2_5708s_linkup(bp);
+			else if (CHIP_NUM(bp) == CHIP_NUM_5709)
+				bnx2_5709s_linkup(bp);
 		}
 		else {
 			bnx2_copper_linkup(bp);
@@ -1119,7 +1225,15 @@ bnx2_setup_serdes_phy(struct bnx2 *bp)
 		new_bmcr = bmcr & ~BMCR_ANENABLE;
 		new_bmcr |= BMCR_SPEED1000;
 
-		if (CHIP_NUM(bp) == CHIP_NUM_5708) {
+		if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+			if (bp->req_line_speed == SPEED_2500)
+				bnx2_enable_forced_2g5(bp);
+			else if (bp->req_line_speed == SPEED_1000) {
+				bnx2_disable_forced_2g5(bp);
+				new_bmcr &= ~0x2000;
+			}
+
+		} else if (CHIP_NUM(bp) == CHIP_NUM_5708) {
 			if (bp->req_line_speed == SPEED_2500)
 				new_bmcr |= BCM5708S_BMCR_FORCE_2500;
 			else
@@ -1302,6 +1416,9 @@ bnx2_setup_copper_phy(struct bnx2 *bp)
 			bnx2_resolve_flow_ctrl(bp);
 			bnx2_set_mac_link(bp);
 		}
+	} else {
+		bnx2_resolve_flow_ctrl(bp);
+		bnx2_set_mac_link(bp);
 	}
 	return 0;
 }
@@ -1321,10 +1438,63 @@ bnx2_setup_phy(struct bnx2 *bp)
 }
 
 static int
+bnx2_init_5709s_phy(struct bnx2 *bp)
+{
+	u32 val;
+
+	bp->mii_bmcr = MII_BMCR + 0x10;
+	bp->mii_bmsr = MII_BMSR + 0x10;
+	bp->mii_bmsr1 = MII_BNX2_GP_TOP_AN_STATUS1;
+	bp->mii_adv = MII_ADVERTISE + 0x10;
+	bp->mii_lpa = MII_LPA + 0x10;
+	bp->mii_up1 = MII_BNX2_OVER1G_UP1;
+
+	bnx2_write_phy(bp, MII_BNX2_BLK_ADDR, MII_BNX2_BLK_ADDR_AER);
+	bnx2_write_phy(bp, MII_BNX2_AER_AER, MII_BNX2_AER_AER_AN_MMD);
+
+	bnx2_write_phy(bp, MII_BNX2_BLK_ADDR, MII_BNX2_BLK_ADDR_COMBO_IEEEB0);
+	bnx2_reset_phy(bp);
+
+	bnx2_write_phy(bp, MII_BNX2_BLK_ADDR, MII_BNX2_BLK_ADDR_SERDES_DIG);
+
+	bnx2_read_phy(bp, MII_BNX2_SERDES_DIG_1000XCTL1, &val);
+	val &= ~MII_BNX2_SD_1000XCTL1_AUTODET;
+	val |= MII_BNX2_SD_1000XCTL1_FIBER;
+	bnx2_write_phy(bp, MII_BNX2_SERDES_DIG_1000XCTL1, val);
+
+	bnx2_write_phy(bp, MII_BNX2_BLK_ADDR, MII_BNX2_BLK_ADDR_OVER1G);
+	bnx2_read_phy(bp, MII_BNX2_OVER1G_UP1, &val);
+	if (bp->phy_flags & PHY_2_5G_CAPABLE_FLAG)
+		val |= BCM5708S_UP1_2G5;
+	else
+		val &= ~BCM5708S_UP1_2G5;
+	bnx2_write_phy(bp, MII_BNX2_OVER1G_UP1, val);
+
+	bnx2_write_phy(bp, MII_BNX2_BLK_ADDR, MII_BNX2_BLK_ADDR_BAM_NXTPG);
+	bnx2_read_phy(bp, MII_BNX2_BAM_NXTPG_CTL, &val);
+	val |= MII_BNX2_NXTPG_CTL_T2 | MII_BNX2_NXTPG_CTL_BAM;
+	bnx2_write_phy(bp, MII_BNX2_BAM_NXTPG_CTL, val);
+
+	bnx2_write_phy(bp, MII_BNX2_BLK_ADDR, MII_BNX2_BLK_ADDR_CL73_USERB0);
+
+	val = MII_BNX2_CL73_BAM_EN | MII_BNX2_CL73_BAM_STA_MGR_EN |
+	      MII_BNX2_CL73_BAM_NP_AFT_BP_EN;
+	bnx2_write_phy(bp, MII_BNX2_CL73_BAM_CTL1, val);
+
+	bnx2_write_phy(bp, MII_BNX2_BLK_ADDR, MII_BNX2_BLK_ADDR_COMBO_IEEEB0);
+
+	return 0;
+}
+
+static int
 bnx2_init_5708s_phy(struct bnx2 *bp)
 {
 	u32 val;
 
+	bnx2_reset_phy(bp);
+
+	bp->mii_up1 = BCM5708S_UP1;
+
 	bnx2_write_phy(bp, BCM5708S_BLK_ADDR, BCM5708S_BLK_ADDR_DIG3);
 	bnx2_write_phy(bp, BCM5708S_DIG_3_0, BCM5708S_DIG_3_0_USE_IEEE);
 	bnx2_write_phy(bp, BCM5708S_BLK_ADDR, BCM5708S_BLK_ADDR_DIG);
@@ -1377,6 +1547,8 @@ bnx2_init_5708s_phy(struct bnx2 *bp)
 static int
 bnx2_init_5706s_phy(struct bnx2 *bp)
 {
+	bnx2_reset_phy(bp);
+
 	bp->phy_flags &= ~PHY_PARALLEL_DETECT_FLAG;
 
 	if (CHIP_NUM(bp) == CHIP_NUM_5706)
@@ -1414,6 +1586,8 @@ bnx2_init_copper_phy(struct bnx2 *bp)
 {
 	u32 val;
 
+	bnx2_reset_phy(bp);
+
 	if (bp->phy_flags & PHY_CRC_FIX_FLAG) {
 		bnx2_write_phy(bp, 0x18, 0x0c00);
 		bnx2_write_phy(bp, 0x17, 0x000a);
@@ -1470,13 +1644,12 @@ bnx2_init_phy(struct bnx2 *bp)
 
 	bp->mii_bmcr = MII_BMCR;
 	bp->mii_bmsr = MII_BMSR;
+	bp->mii_bmsr1 = MII_BMSR;
 	bp->mii_adv = MII_ADVERTISE;
 	bp->mii_lpa = MII_LPA;
 
         REG_WR(bp, BNX2_EMAC_ATTENTION_ENA, BNX2_EMAC_ATTENTION_ENA_LINK);
 
-	bnx2_reset_phy(bp);
-
 	bnx2_read_phy(bp, MII_PHYSID1, &val);
 	bp->phy_id = val << 16;
 	bnx2_read_phy(bp, MII_PHYSID2, &val);
@@ -1487,6 +1660,8 @@ bnx2_init_phy(struct bnx2 *bp)
 			rc = bnx2_init_5706s_phy(bp);
 		else if (CHIP_NUM(bp) == CHIP_NUM_5708)
 			rc = bnx2_init_5708s_phy(bp);
+		else if (CHIP_NUM(bp) == CHIP_NUM_5709)
+			rc = bnx2_init_5709s_phy(bp);
 	}
 	else {
 		rc = bnx2_init_copper_phy(bp);
@@ -4262,8 +4437,10 @@ bnx2_test_link(struct bnx2 *bp)
 	u32 bmsr;
 
 	spin_lock_bh(&bp->phy_lock);
-	bnx2_read_phy(bp, bp->mii_bmsr, &bmsr);
-	bnx2_read_phy(bp, bp->mii_bmsr, &bmsr);
+	bnx2_enable_bmsr1(bp);
+	bnx2_read_phy(bp, bp->mii_bmsr1, &bmsr);
+	bnx2_read_phy(bp, bp->mii_bmsr1, &bmsr);
+	bnx2_disable_bmsr1(bp);
 	spin_unlock_bh(&bp->phy_lock);
 
 	if (bmsr & BMSR_LSTATUS) {
@@ -4407,7 +4584,7 @@ bnx2_timer(unsigned long data)
 	if (bp->phy_flags & PHY_SERDES_FLAG) {
 		if (CHIP_NUM(bp) == CHIP_NUM_5706)
 			bnx2_5706_serdes_timer(bp);
-		else if (CHIP_NUM(bp) == CHIP_NUM_5708)
+		else
 			bnx2_5708_serdes_timer(bp);
 	}
 
@@ -4910,8 +5087,10 @@ bnx2_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 			advertising = cmd->advertising;
 
-		}
-		else if (cmd->advertising == ADVERTISED_1000baseT_Full) {
+		} else if (cmd->advertising == ADVERTISED_2500baseX_Full) {
+			if (!(bp->phy_flags & PHY_2_5G_CAPABLE_FLAG))
+				return -EINVAL;
+		} else if (cmd->advertising == ADVERTISED_1000baseT_Full) {
 			advertising = cmd->advertising;
 		}
 		else if (cmd->advertising == ADVERTISED_1000baseT_Half) {
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index d4a85d7..124bd03 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6296,6 +6296,41 @@ struct l2_fhdr {
 #define MII_BNX2_DSP_ADDRESS			0x17
 #define MII_BNX2_DSP_EXPAND_REG			 0x0f00
 
+#define MII_BNX2_BLK_ADDR			0x1f
+#define MII_BNX2_BLK_ADDR_IEEE0			 0x0000
+#define MII_BNX2_BLK_ADDR_GP_STATUS		 0x8120
+#define MII_BNX2_GP_TOP_AN_STATUS1		  0x1b
+#define MII_BNX2_GP_TOP_AN_SPEED_MSK		   0x3f00
+#define MII_BNX2_GP_TOP_AN_SPEED_10		   0x0000
+#define MII_BNX2_GP_TOP_AN_SPEED_100		   0x0100
+#define MII_BNX2_GP_TOP_AN_SPEED_1G		   0x0200
+#define MII_BNX2_GP_TOP_AN_SPEED_2_5G		   0x0300
+#define MII_BNX2_GP_TOP_AN_SPEED_1GKV		   0x0d00
+#define MII_BNX2_GP_TOP_AN_FD			   0x8
+#define MII_BNX2_BLK_ADDR_SERDES_DIG		 0x8300
+#define MII_BNX2_SERDES_DIG_1000XCTL1		  0x10
+#define MII_BNX2_SD_1000XCTL1_FIBER		   0x01
+#define MII_BNX2_SD_1000XCTL1_AUTODET		   0x10
+#define MII_BNX2_SERDES_DIG_MISC1		  0x18
+#define MII_BNX2_SD_MISC1_FORCE_MSK		   0xf
+#define MII_BNX2_SD_MISC1_FORCE_2_5G		   0x0
+#define MII_BNX2_SD_MISC1_FORCE			   0x10
+#define MII_BNX2_BLK_ADDR_OVER1G		 0x8320
+#define MII_BNX2_OVER1G_UP1			  0x19
+#define MII_BNX2_BLK_ADDR_BAM_NXTPG		 0x8350
+#define MII_BNX2_BAM_NXTPG_CTL			  0x10
+#define MII_BNX2_NXTPG_CTL_BAM			   0x1
+#define MII_BNX2_NXTPG_CTL_T2			   0x2
+#define MII_BNX2_BLK_ADDR_CL73_USERB0		 0x8370
+#define MII_BNX2_CL73_BAM_CTL1			  0x12
+#define MII_BNX2_CL73_BAM_EN			   0x8000
+#define MII_BNX2_CL73_BAM_STA_MGR_EN		   0x4000
+#define MII_BNX2_CL73_BAM_NP_AFT_BP_EN		   0x2000
+#define MII_BNX2_BLK_ADDR_AER			 0xffd0
+#define MII_BNX2_AER_AER			  0x1e
+#define MII_BNX2_AER_AER_AN_MMD			   0x3800
+#define MII_BNX2_BLK_ADDR_COMBO_IEEEB0		 0xffe0
+
 #define MIN_ETHERNET_PACKET_SIZE	60
 #define MAX_ETHERNET_PACKET_SIZE	1514
 #define MAX_ETHERNET_JUMBO_PACKET_SIZE	9014
@@ -6500,6 +6535,7 @@ struct bnx2 {
 
 	u32			mii_bmcr;
 	u32			mii_bmsr;
+	u32			mii_bmsr1;
 	u32			mii_adv;
 	u32			mii_lpa;
 	u32			mii_up1;
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 600308f..1a7e9bd 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1923,6 +1923,7 @@
 #define PCI_DEVICE_ID_TIGON3_5752	0x1600
 #define PCI_DEVICE_ID_TIGON3_5752M	0x1601
 #define PCI_DEVICE_ID_NX2_5709		0x1639
+#define PCI_DEVICE_ID_NX2_5709S		0x163a
 #define PCI_DEVICE_ID_TIGON3_5700	0x1644
 #define PCI_DEVICE_ID_TIGON3_5701	0x1645
 #define PCI_DEVICE_ID_TIGON3_5702	0x1646


