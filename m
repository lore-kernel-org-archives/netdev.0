From: Stephen Hemminger <shemminger@osdl.org>
Subject: [patch 5/6] sky2: add Wake On Lan support
Date: Wed, 20 Dec 2006 13:06:37 -0800
Message-ID: <20061220210923.418676394@osdl.org>
References: <20061220210632.183204605@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:58252 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423154AbWLVAlI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Dec 2006 19:41:08 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-wol2.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds basic magic packet wake on lan support to the sky2 driver.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 drivers/net/sky2.c |  149 ++++++++++++++++++++++++++++++++++++++++++++++++++---
 drivers/net/sky2.h |   28 ++-------
 2 files changed, 150 insertions(+), 27 deletions(-)

--- sky2-2.6.orig/drivers/net/sky2.c	2006-12-20 12:45:40.000000000 -0800
+++ sky2-2.6/drivers/net/sky2.c	2006-12-18 13:31:22.000000000 -0800
@@ -567,6 +567,73 @@
 	spin_unlock_bh(&sky2->phy_lock);
 }
 
+/* Put device in state to listen for Wake On Lan */
+static void sky2_wol_init(struct sky2_port *sky2)
+{
+	struct sky2_hw *hw = sky2->hw;
+	unsigned port = sky2->port;
+	enum flow_control save_mode;
+	u16 ctrl;
+	u32 reg1;
+
+	/* Bring hardware out of reset */
+	sky2_write16(hw, B0_CTST, CS_RST_CLR);
+	sky2_write16(hw, SK_REG(port, GMAC_LINK_CTRL), GMLC_RST_CLR);
+
+	sky2_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_CLR);
+	sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_RST_CLR);
+
+	/* Force to 10/100
+	 * sky2_reset will re-enable on resume
+	 */
+	save_mode = sky2->flow_mode;
+	ctrl = sky2->advertising;
+
+	sky2->advertising &= ~(ADVERTISED_1000baseT_Half|ADVERTISED_1000baseT_Full);
+	sky2->flow_mode = FC_NONE;
+	sky2_phy_power(hw, port, 1);
+	sky2_phy_reinit(sky2);
+
+	sky2->flow_mode = save_mode;
+	sky2->advertising = ctrl;
+
+	/* Set GMAC to no flow control and auto update for speed/duplex */
+	gma_write16(hw, port, GM_GP_CTRL,
+		    GM_GPCR_FC_TX_DIS|GM_GPCR_TX_ENA|GM_GPCR_RX_ENA|
+		    GM_GPCR_DUP_FULL|GM_GPCR_FC_RX_DIS|GM_GPCR_AU_FCT_DIS);
+
+	/* Set WOL address */
+	memcpy_toio(hw->regs + WOL_REGS(port, WOL_MAC_ADDR),
+		    sky2->netdev->dev_addr, ETH_ALEN);
+
+	/* Turn on appropriate WOL control bits */
+	sky2_write16(hw, WOL_REGS(port, WOL_CTRL_STAT), WOL_CTL_CLEAR_RESULT);
+	ctrl = 0;
+	if (sky2->wol & WAKE_PHY)
+		ctrl |= WOL_CTL_ENA_PME_ON_LINK_CHG|WOL_CTL_ENA_LINK_CHG_UNIT;
+	else
+		ctrl |= WOL_CTL_DIS_PME_ON_LINK_CHG|WOL_CTL_DIS_LINK_CHG_UNIT;
+
+	if (sky2->wol & WAKE_MAGIC)
+		ctrl |= WOL_CTL_ENA_PME_ON_MAGIC_PKT|WOL_CTL_ENA_MAGIC_PKT_UNIT;
+	else
+		ctrl |= WOL_CTL_DIS_PME_ON_MAGIC_PKT|WOL_CTL_DIS_MAGIC_PKT_UNIT;;
+
+	ctrl |= WOL_CTL_DIS_PME_ON_PATTERN|WOL_CTL_DIS_PATTERN_UNIT;
+	sky2_write16(hw, WOL_REGS(port, WOL_CTRL_STAT), ctrl);
+
+	/* Turn on legacy PCI-Express PME mode */
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
+	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
+	reg1 |= PCI_Y2_PME_LEGACY;
+	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
+
+	/* block receiver */
+	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
+
+}
+
 static void sky2_mac_init(struct sky2_hw *hw, unsigned port)
 {
 	struct sky2_port *sky2 = netdev_priv(hw->dev[port]);
@@ -2543,6 +2610,38 @@
 	return 0;
 }
 
+static inline u8 sky2_wol_supported(const struct sky2_hw *hw)
+{
+	return sky2_is_copper(hw) ? (WAKE_PHY | WAKE_MAGIC) : 0;
+}
+
+static void sky2_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	const struct sky2_port *sky2 = netdev_priv(dev);
+
+	wol->supported = sky2_wol_supported(sky2->hw);
+	wol->wolopts = sky2->wol;
+}
+
+static int sky2_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+	struct sky2_hw *hw = sky2->hw;
+
+	if (wol->wolopts & ~sky2_wol_supported(sky2->hw))
+		return -EOPNOTSUPP;
+
+	sky2->wol = wol->wolopts;
+
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U)
+		sky2_write32(hw, B0_CTST, sky2->wol
+			     ? Y2_HW_WOL_ON : Y2_HW_WOL_OFF);
+
+	if (!netif_running(dev))
+		sky2_wol_init(sky2);
+	return 0;
+}
+
 static u32 sky2_supported_modes(const struct sky2_hw *hw)
 {
 	if (sky2_is_copper(hw)) {
@@ -3167,7 +3266,9 @@
 static const struct ethtool_ops sky2_ethtool_ops = {
 	.get_settings = sky2_get_settings,
 	.set_settings = sky2_set_settings,
-	.get_drvinfo = sky2_get_drvinfo,
+	.get_drvinfo  = sky2_get_drvinfo,
+	.get_wol      = sky2_get_wol,
+	.set_wol      = sky2_set_wol,
 	.get_msglevel = sky2_get_msglevel,
 	.set_msglevel = sky2_set_msglevel,
 	.nway_reset   = sky2_nway_reset,
@@ -3547,23 +3648,29 @@
 static int sky2_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
-	int i;
+	int i, wol = 0;
 
 	del_timer_sync(&hw->idle_timer);
 	netif_poll_disable(hw->dev[0]);
 
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
+		struct sky2_port *sky2 = netdev_priv(dev);
 
-		if (netif_running(dev)) {
+		if (netif_running(dev))
 			sky2_down(dev);
-			netif_device_detach(dev);
-		}
+
+		if (sky2->wol)
+			sky2_wol_init(sky2);
+
+		wol |= sky2->wol;
 	}
 
 	sky2_write32(hw, B0_IMSK, 0);
 	sky2_power_aux(hw);
+
 	pci_save_state(pdev);
+	pci_enable_wake(pdev, pci_choose_state(pdev, state), wol);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
 
 	return 0;
@@ -3593,8 +3700,6 @@
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
 		if (netif_running(dev)) {
-			netif_device_attach(dev);
-
 			err = sky2_up(dev);
 			if (err) {
 				printk(KERN_ERR PFX "%s: could not up: %d\n",
@@ -3638,6 +3743,35 @@
 }
 #endif
 
+static void sky2_shutdown(struct pci_dev *pdev)
+{
+	struct sky2_hw *hw = pci_get_drvdata(pdev);
+	int i, wol = 0;
+
+	del_timer_sync(&hw->idle_timer);
+	netif_poll_disable(hw->dev[0]);
+
+	for (i = 0; i < hw->ports; i++) {
+		struct net_device *dev = hw->dev[i];
+		struct sky2_port *sky2 = netdev_priv(dev);
+
+		if (sky2->wol) {
+			wol = 1;
+			sky2_wol_init(sky2);
+		}
+	}
+
+	if (wol)
+		sky2_power_aux(hw);
+
+	pci_enable_wake(pdev, PCI_D3hot, wol);
+	pci_enable_wake(pdev, PCI_D3cold, wol);
+
+	pci_disable_device(pdev);
+	pci_set_power_state(pdev, PCI_D3hot);
+
+}
+
 static struct pci_driver sky2_driver = {
 	.name = DRV_NAME,
 	.id_table = sky2_id_table,
@@ -3649,6 +3783,7 @@
 	.suspend_late = sky2_suspend_late,
 	.resume_early = sky2_resume_early,
 #endif
+	.shutdown = sky2_shutdown,
 };
 
 static int __init sky2_init_module(void)
--- sky2-2.6.orig/drivers/net/sky2.h	2006-12-20 12:45:40.000000000 -0800
+++ sky2-2.6/drivers/net/sky2.h	2006-12-19 13:57:45.000000000 -0800
@@ -32,6 +32,7 @@
 	PCI_Y2_PHY1_COMA = 1<<28, /* Set PHY 1 to Coma Mode (YUKON-2) */
 	PCI_Y2_PHY2_POWD = 1<<27, /* Set PHY 2 to Power Down (YUKON-2) */
 	PCI_Y2_PHY1_POWD = 1<<26, /* Set PHY 1 to Power Down (YUKON-2) */
+	PCI_Y2_PME_LEGACY= 1<<15, /* PCI Express legacy power management mode */
 };
 
 enum pci_dev_reg_2 {
@@ -837,33 +838,27 @@
 	GMAC_LINK_CTRL	= 0x0f10,/* 16 bit	Link Control Reg */
 
 /* Wake-up Frame Pattern Match Control Registers (YUKON only) */
-
-	WOL_REG_OFFS	= 0x20,/* HW-Bug: Address is + 0x20 against spec. */
-
 	WOL_CTRL_STAT	= 0x0f20,/* 16 bit	WOL Control/Status Reg */
 	WOL_MATCH_CTL	= 0x0f22,/*  8 bit	WOL Match Control Reg */
 	WOL_MATCH_RES	= 0x0f23,/*  8 bit	WOL Match Result Reg */
 	WOL_MAC_ADDR	= 0x0f24,/* 32 bit	WOL MAC Address */
-	WOL_PATT_PME	= 0x0f2a,/*  8 bit	WOL PME Match Enable (Yukon-2) */
-	WOL_PATT_ASFM	= 0x0f2b,/*  8 bit	WOL ASF Match Enable (Yukon-2) */
 	WOL_PATT_RPTR	= 0x0f2c,/*  8 bit	WOL Pattern Read Pointer */
 
 /* WOL Pattern Length Registers (YUKON only) */
-
 	WOL_PATT_LEN_LO	= 0x0f30,/* 32 bit	WOL Pattern Length 3..0 */
 	WOL_PATT_LEN_HI	= 0x0f34,/* 24 bit	WOL Pattern Length 6..4 */
 
 /* WOL Pattern Counter Registers (YUKON only) */
-
-
 	WOL_PATT_CNT_0	= 0x0f38,/* 32 bit	WOL Pattern Counter 3..0 */
 	WOL_PATT_CNT_4	= 0x0f3c,/* 24 bit	WOL Pattern Counter 6..4 */
 };
+#define WOL_REGS(port, x)	(x + (port)*0x80)
 
 enum {
 	WOL_PATT_RAM_1	= 0x1000,/*  WOL Pattern RAM Link 1 */
 	WOL_PATT_RAM_2	= 0x1400,/*  WOL Pattern RAM Link 2 */
 };
+#define WOL_PATT_RAM_BASE(port)	(WOL_PATT_RAM_1 + (port)*0x400)
 
 enum {
 	BASE_GMAC_1	= 0x2800,/* GMAC 1 registers */
@@ -1715,14 +1710,17 @@
 	GM_IS_RX_COMPL	= 1<<0,	/* Frame Reception Complete */
 
 #define GMAC_DEF_MSK     GM_IS_TX_FF_UR
+};
 
 /*	GMAC_LINK_CTRL	16 bit	GMAC Link Control Reg (YUKON only) */
-						/* Bits 15.. 2:	reserved */
+enum {						/* Bits 15.. 2:	reserved */
 	GMLC_RST_CLR	= 1<<1,	/* Clear GMAC Link Reset */
 	GMLC_RST_SET	= 1<<0,	/* Set   GMAC Link Reset */
+};
 
 
 /*	WOL_CTRL_STAT	16 bit	WOL Control/Status Reg */
+enum {
 	WOL_CTL_LINK_CHG_OCC		= 1<<15,
 	WOL_CTL_MAGIC_PKT_OCC		= 1<<14,
 	WOL_CTL_PATTERN_OCC		= 1<<13,
@@ -1741,17 +1739,6 @@
 	WOL_CTL_DIS_PATTERN_UNIT	= 1<<0,
 };
 
-#define WOL_CTL_DEFAULT				\
-	(WOL_CTL_DIS_PME_ON_LINK_CHG |	\
-	WOL_CTL_DIS_PME_ON_PATTERN |	\
-	WOL_CTL_DIS_PME_ON_MAGIC_PKT |	\
-	WOL_CTL_DIS_LINK_CHG_UNIT |		\
-	WOL_CTL_DIS_PATTERN_UNIT |		\
-	WOL_CTL_DIS_MAGIC_PKT_UNIT)
-
-/*	WOL_MATCH_CTL	 8 bit	WOL Match Control Reg */
-#define WOL_CTL_PATT_ENA(x)	(1 << (x))
-
 
 /* Control flags */
 enum {
@@ -1875,6 +1862,7 @@
 	u8		     autoneg;	/* AUTONEG_ENABLE, AUTONEG_DISABLE */
 	u8		     duplex;	/* DUPLEX_HALF, DUPLEX_FULL */
 	u8		     rx_csum;
+	u8		     wol;
  	enum flow_control    flow_mode;
  	enum flow_control    flow_status;
 

--
Stephen Hemminger <shemminger@osdl.org>

