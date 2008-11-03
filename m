From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 11/15] tg3: 5785 enhancements
Date: Mon, 3 Nov 2008 02:27:04 -0800
Message-ID: <1225751628.6196@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4905 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756731AbYKCWd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 17:33:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch refines support for the 5785 device.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   87 ++++++++++++++++++++++++++++++++++++-----------
 drivers/net/tg3.h |   97 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 163 insertions(+), 21 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 03a930e..c48bb51 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -880,10 +880,45 @@ static int tg3_mdio_reset(struct mii_bus *bp)
 static void tg3_mdio_config_5785(struct tg3 *tp)
 {
 	u32 val;
+	struct phy_device *phydev;
 
-	if (tp->mdio_bus->phy_map[PHY_ADDR]->interface !=
-	    PHY_INTERFACE_MODE_RGMII)
+	phydev = tp->mdio_bus->phy_map[PHY_ADDR];
+	switch (phydev->drv->phy_id & phydev->drv->phy_id_mask) {
+	case TG3_PHY_ID_BCM50610:
+		val = MAC_PHYCFG2_50610_LED_MODES;
+		break;
+	case TG3_PHY_ID_BCMAC131:
+		val = MAC_PHYCFG2_AC131_LED_MODES;
+		break;
+	case TG3_PHY_ID_RTL8211C:
+		val = MAC_PHYCFG2_RTL8211C_LED_MODES;
+		break;
+	case TG3_PHY_ID_RTL8201E:
+		val = MAC_PHYCFG2_RTL8201E_LED_MODES;
+		break;
+	default:
 		return;
+	}
+
+	if (phydev->interface != PHY_INTERFACE_MODE_RGMII) {
+		tw32(MAC_PHYCFG2, val);
+
+		val = tr32(MAC_PHYCFG1);
+		val &= ~MAC_PHYCFG1_RGMII_INT;
+		tw32(MAC_PHYCFG1, val);
+
+		return;
+	}
+
+	if (!(tp->tg3_flags3 & TG3_FLG3_RGMII_STD_IBND_DISABLE))
+		val |= MAC_PHYCFG2_EMODE_MASK_MASK |
+		       MAC_PHYCFG2_FMODE_MASK_MASK |
+		       MAC_PHYCFG2_GMODE_MASK_MASK |
+		       MAC_PHYCFG2_ACT_MASK_MASK   |
+		       MAC_PHYCFG2_QUAL_MASK_MASK |
+		       MAC_PHYCFG2_INBAND_ENABLE;
+
+	tw32(MAC_PHYCFG2, val);
 
 	val = tr32(MAC_PHYCFG1) & ~(MAC_PHYCFG1_RGMII_EXT_RX_DEC |
 				    MAC_PHYCFG1_RGMII_SND_STAT_EN);
@@ -895,11 +930,6 @@ static void tg3_mdio_config_5785(struct tg3 *tp)
 	}
 	tw32(MAC_PHYCFG1, val | MAC_PHYCFG1_RGMII_INT | MAC_PHYCFG1_TXC_DRV);
 
-	val = tr32(MAC_PHYCFG2) & ~(MAC_PHYCFG2_INBAND_ENABLE);
-	if (!(tp->tg3_flags3 & TG3_FLG3_RGMII_STD_IBND_DISABLE))
-		val |= MAC_PHYCFG2_INBAND_ENABLE;
-	tw32(MAC_PHYCFG2, val);
-
 	val = tr32(MAC_EXT_RGMII_MODE);
 	val &= ~(MAC_RGMII_MODE_RX_INT_B |
 		 MAC_RGMII_MODE_RX_QUALITY |
@@ -908,7 +938,7 @@ static void tg3_mdio_config_5785(struct tg3 *tp)
 		 MAC_RGMII_MODE_TX_ENABLE |
 		 MAC_RGMII_MODE_TX_LOWPWR |
 		 MAC_RGMII_MODE_TX_RESET);
-	if (tp->tg3_flags3 & TG3_FLG3_RGMII_STD_IBND_DISABLE) {
+	if (!(tp->tg3_flags3 & TG3_FLG3_RGMII_STD_IBND_DISABLE)) {
 		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_RX_EN)
 			val |= MAC_RGMII_MODE_RX_INT_B |
 			       MAC_RGMII_MODE_RX_QUALITY |
@@ -1005,14 +1035,17 @@ static int tg3_mdio_init(struct tg3 *tp)
 
 	switch (phydev->drv->phy_id & phydev->drv->phy_id_mask) {
 	case TG3_PHY_ID_BCM50610:
-		phydev->interface = PHY_INTERFACE_MODE_RGMII;
 		if (tp->tg3_flags3 & TG3_FLG3_RGMII_STD_IBND_DISABLE)
 			phydev->dev_flags |= PHY_BRCM_STD_IBND_DISABLE;
 		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_RX_EN)
 			phydev->dev_flags |= PHY_BRCM_EXT_IBND_RX_ENABLE;
 		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_TX_EN)
 			phydev->dev_flags |= PHY_BRCM_EXT_IBND_TX_ENABLE;
+		/* fallthru */
+	case TG3_PHY_ID_RTL8211C:
+		phydev->interface = PHY_INTERFACE_MODE_RGMII;
 		break;
+	case TG3_PHY_ID_RTL8201E:
 	case TG3_PHY_ID_BCMAC131:
 		phydev->interface = PHY_INTERFACE_MODE_MII;
 		break;
@@ -1314,6 +1347,15 @@ static void tg3_adjust_link(struct net_device *dev)
 		udelay(40);
 	}
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785) {
+		if (phydev->speed == SPEED_10)
+			tw32(MAC_MI_STAT,
+			     MAC_MI_STAT_10MBPS_MODE |
+			     MAC_MI_STAT_LNKSTAT_ATTN_ENAB);
+		else
+			tw32(MAC_MI_STAT, MAC_MI_STAT_LNKSTAT_ATTN_ENAB);
+	}
+
 	if (phydev->speed == SPEED_1000 && phydev->duplex == DUPLEX_HALF)
 		tw32(MAC_TX_LENGTHS,
 		     ((2 << TX_LENGTHS_IPG_CRS_SHIFT) |
@@ -5817,13 +5859,15 @@ static void tg3_restore_pci_state(struct tg3 *tp)
 
 	pci_write_config_word(tp->pdev, PCI_COMMAND, tp->pci_cmd);
 
-	if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS)
-		pcie_set_readrq(tp->pdev, 4096);
-	else {
-		pci_write_config_byte(tp->pdev, PCI_CACHE_LINE_SIZE,
-				      tp->pci_cacheline_sz);
-		pci_write_config_byte(tp->pdev, PCI_LATENCY_TIMER,
-				      tp->pci_lat_timer);
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785) {
+		if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS)
+			pcie_set_readrq(tp->pdev, 4096);
+		else {
+			pci_write_config_byte(tp->pdev, PCI_CACHE_LINE_SIZE,
+					      tp->pci_cacheline_sz);
+			pci_write_config_byte(tp->pdev, PCI_LATENCY_TIMER,
+					      tp->pci_lat_timer);
+		}
 	}
 
 	/* Make sure PCI-X relaxed ordering bit is clear. */
@@ -5980,8 +6024,9 @@ static int tg3_chip_reset(struct tg3 *tp)
 			pci_write_config_dword(tp->pdev, 0xc4,
 					       cfg_val | (1 << 15));
 		}
-		/* Set PCIE max payload size and clear error status.  */
-		pci_write_config_dword(tp->pdev, 0xd8, 0xf5000);
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785)
+			/* Set PCIE max payload size and clear error status.  */
+			pci_write_config_dword(tp->pdev, 0xd8, 0xf5000);
 	}
 
 	tg3_restore_pci_state(tp);
@@ -7149,8 +7194,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		return err;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5784 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5761 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785) {
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5761) {
 		/* This value is determined during the probe time DMA
 		 * engine test, tg3_test_dma.
 		 */
@@ -12156,7 +12200,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 			if (lnkctl & PCI_EXP_LNKCTL_CLKREQ_EN)
 				tp->tg3_flags2 &= ~TG3_FLG2_HW_TSO_2;
 		}
-	}
+	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
+		tp->tg3_flags2 |= TG3_FLG2_PCI_EXPRESS;
 
 	/* If we have an AMD 762 or VIA K8T800 chipset, write
 	 * reordering to the mailbox registers done by the host
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index d7ce3a0..599e490 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -417,6 +417,7 @@
 #define  MI_COM_DATA_MASK		 0x0000ffff
 #define MAC_MI_STAT			0x00000450
 #define  MAC_MI_STAT_LNKSTAT_ATTN_ENAB	 0x00000001
+#define  MAC_MI_STAT_10MBPS_MODE	 0x00000002
 #define MAC_MI_MODE			0x00000454
 #define  MAC_MI_MODE_CLK_10MHZ		 0x00000001
 #define  MAC_MI_MODE_SHORT_PREAMBLE	 0x00000002
@@ -542,6 +543,100 @@
 #define  MAC_PHYCFG1_TXC_DRV		 0x20000000
 #define MAC_PHYCFG2			0x000005a4
 #define  MAC_PHYCFG2_INBAND_ENABLE	 0x00000001
+#define  MAC_PHYCFG2_EMODE_MASK_MASK	 0x000001c0
+#define  MAC_PHYCFG2_EMODE_MASK_AC131	 0x000000c0
+#define  MAC_PHYCFG2_EMODE_MASK_50610	 0x00000100
+#define  MAC_PHYCFG2_EMODE_MASK_RT8211	 0x00000000
+#define  MAC_PHYCFG2_EMODE_MASK_RT8201	 0x000001c0
+#define  MAC_PHYCFG2_EMODE_COMP_MASK	 0x00000e00
+#define  MAC_PHYCFG2_EMODE_COMP_AC131	 0x00000600
+#define  MAC_PHYCFG2_EMODE_COMP_50610	 0x00000400
+#define  MAC_PHYCFG2_EMODE_COMP_RT8211	 0x00000800
+#define  MAC_PHYCFG2_EMODE_COMP_RT8201	 0x00000000
+#define  MAC_PHYCFG2_FMODE_MASK_MASK	 0x00007000
+#define  MAC_PHYCFG2_FMODE_MASK_AC131	 0x00006000
+#define  MAC_PHYCFG2_FMODE_MASK_50610	 0x00004000
+#define  MAC_PHYCFG2_FMODE_MASK_RT8211	 0x00000000
+#define  MAC_PHYCFG2_FMODE_MASK_RT8201	 0x00007000
+#define  MAC_PHYCFG2_FMODE_COMP_MASK	 0x00038000
+#define  MAC_PHYCFG2_FMODE_COMP_AC131	 0x00030000
+#define  MAC_PHYCFG2_FMODE_COMP_50610	 0x00008000
+#define  MAC_PHYCFG2_FMODE_COMP_RT8211	 0x00038000
+#define  MAC_PHYCFG2_FMODE_COMP_RT8201	 0x00000000
+#define  MAC_PHYCFG2_GMODE_MASK_MASK	 0x001c0000
+#define  MAC_PHYCFG2_GMODE_MASK_AC131	 0x001c0000
+#define  MAC_PHYCFG2_GMODE_MASK_50610	 0x00100000
+#define  MAC_PHYCFG2_GMODE_MASK_RT8211	 0x00000000
+#define  MAC_PHYCFG2_GMODE_MASK_RT8201	 0x001c0000
+#define  MAC_PHYCFG2_GMODE_COMP_MASK	 0x00e00000
+#define  MAC_PHYCFG2_GMODE_COMP_AC131	 0x00e00000
+#define  MAC_PHYCFG2_GMODE_COMP_50610	 0x00000000
+#define  MAC_PHYCFG2_GMODE_COMP_RT8211	 0x00200000
+#define  MAC_PHYCFG2_GMODE_COMP_RT8201	 0x00000000
+#define  MAC_PHYCFG2_ACT_MASK_MASK	 0x03000000
+#define  MAC_PHYCFG2_ACT_MASK_AC131	 0x03000000
+#define  MAC_PHYCFG2_ACT_MASK_50610	 0x01000000
+#define  MAC_PHYCFG2_ACT_MASK_RT8211	 0x03000000
+#define  MAC_PHYCFG2_ACT_MASK_RT8201	 0x01000000
+#define  MAC_PHYCFG2_ACT_COMP_MASK	 0x0c000000
+#define  MAC_PHYCFG2_ACT_COMP_AC131	 0x00000000
+#define  MAC_PHYCFG2_ACT_COMP_50610	 0x00000000
+#define  MAC_PHYCFG2_ACT_COMP_RT8211	 0x00000000
+#define  MAC_PHYCFG2_ACT_COMP_RT8201	 0x08000000
+#define  MAC_PHYCFG2_QUAL_MASK_MASK	 0x30000000
+#define  MAC_PHYCFG2_QUAL_MASK_AC131	 0x30000000
+#define  MAC_PHYCFG2_QUAL_MASK_50610	 0x30000000
+#define  MAC_PHYCFG2_QUAL_MASK_RT8211	 0x30000000
+#define  MAC_PHYCFG2_QUAL_MASK_RT8201	 0x30000000
+#define  MAC_PHYCFG2_QUAL_COMP_MASK	 0xc0000000
+#define  MAC_PHYCFG2_QUAL_COMP_AC131	 0x00000000
+#define  MAC_PHYCFG2_QUAL_COMP_50610	 0x00000000
+#define  MAC_PHYCFG2_QUAL_COMP_RT8211	 0x00000000
+#define  MAC_PHYCFG2_QUAL_COMP_RT8201	 0x00000000
+#define MAC_PHYCFG2_50610_LED_MODES \
+	(MAC_PHYCFG2_EMODE_MASK_50610 | \
+	 MAC_PHYCFG2_EMODE_COMP_50610 | \
+	 MAC_PHYCFG2_FMODE_MASK_50610 | \
+	 MAC_PHYCFG2_FMODE_COMP_50610 | \
+	 MAC_PHYCFG2_GMODE_MASK_50610 | \
+	 MAC_PHYCFG2_GMODE_COMP_50610 | \
+	 MAC_PHYCFG2_ACT_MASK_50610 | \
+	 MAC_PHYCFG2_ACT_COMP_50610 | \
+	 MAC_PHYCFG2_QUAL_MASK_50610 | \
+	 MAC_PHYCFG2_QUAL_COMP_50610)
+#define MAC_PHYCFG2_AC131_LED_MODES \
+	(MAC_PHYCFG2_EMODE_MASK_AC131 | \
+	 MAC_PHYCFG2_EMODE_COMP_AC131 | \
+	 MAC_PHYCFG2_FMODE_MASK_AC131 | \
+	 MAC_PHYCFG2_FMODE_COMP_AC131 | \
+	 MAC_PHYCFG2_GMODE_MASK_AC131 | \
+	 MAC_PHYCFG2_GMODE_COMP_AC131 | \
+	 MAC_PHYCFG2_ACT_MASK_AC131 | \
+	 MAC_PHYCFG2_ACT_COMP_AC131 | \
+	 MAC_PHYCFG2_QUAL_MASK_AC131 | \
+	 MAC_PHYCFG2_QUAL_COMP_AC131)
+#define MAC_PHYCFG2_RTL8211C_LED_MODES \
+	(MAC_PHYCFG2_EMODE_MASK_RT8211 | \
+	 MAC_PHYCFG2_EMODE_COMP_RT8211 | \
+	 MAC_PHYCFG2_FMODE_MASK_RT8211 | \
+	 MAC_PHYCFG2_FMODE_COMP_RT8211 | \
+	 MAC_PHYCFG2_GMODE_MASK_RT8211 | \
+	 MAC_PHYCFG2_GMODE_COMP_RT8211 | \
+	 MAC_PHYCFG2_ACT_MASK_RT8211 | \
+	 MAC_PHYCFG2_ACT_COMP_RT8211 | \
+	 MAC_PHYCFG2_QUAL_MASK_RT8211 | \
+	 MAC_PHYCFG2_QUAL_COMP_RT8211)
+#define MAC_PHYCFG2_RTL8201E_LED_MODES \
+	(MAC_PHYCFG2_EMODE_MASK_RT8201 | \
+	 MAC_PHYCFG2_EMODE_COMP_RT8201 | \
+	 MAC_PHYCFG2_FMODE_MASK_RT8201 | \
+	 MAC_PHYCFG2_FMODE_COMP_RT8201 | \
+	 MAC_PHYCFG2_GMODE_MASK_RT8201 | \
+	 MAC_PHYCFG2_GMODE_COMP_RT8201 | \
+	 MAC_PHYCFG2_ACT_MASK_RT8201 | \
+	 MAC_PHYCFG2_ACT_COMP_RT8201 | \
+	 MAC_PHYCFG2_QUAL_MASK_RT8201 | \
+	 MAC_PHYCFG2_QUAL_COMP_RT8201)
 #define MAC_EXT_RGMII_MODE		0x000005a8
 #define  MAC_RGMII_MODE_TX_ENABLE	 0x00000001
 #define  MAC_RGMII_MODE_TX_LOWPWR	 0x00000002
@@ -2595,6 +2690,8 @@ struct tg3 {
 #define PHY_REV_BCM5411_X0		0x1 /* Found on Netgear GA302T */
 #define TG3_PHY_ID_BCM50610		0x143bd60
 #define TG3_PHY_ID_BCMAC131		0x143bc70
+#define TG3_PHY_ID_RTL8211C		0x001cc910
+#define TG3_PHY_ID_RTL8201E		0x00008200
 #define TG3_PHY_OUI_MASK		0xfffffc00
 #define TG3_PHY_OUI_1			0x00206000
 #define TG3_PHY_OUI_2			0x0143bc00
-- 
1.5.6.4



