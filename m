From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/7] sky2: add Wake On Lan support
Date: Tue, 06 Feb 2007 10:45:39 -0800
Message-ID: <20070206184854.882274000@linux-foundation.org>
References: <20070206184538.675048000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:45616 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965239AbXBFSx0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 13:53:26 -0500
Content-Disposition: inline; filename=sky2-wol2.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds basic magic packet wake on lan support to the sky2 driver.
Note: initial WOL value is based on BIOS settings.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 drivers/net/sky2.c |  208 ++++++++++++++++++++++++++++++++++++++++++++++-------
 drivers/net/sky2.h |   28 ++-----
 2 files changed, 189 insertions(+), 47 deletions(-)

--- sky2-dev.orig/drivers/net/sky2.c	2007-02-06 10:44:10.000000000 -0800
+++ sky2-dev/drivers/net/sky2.c	2007-02-06 10:44:15.000000000 -0800
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
@@ -2404,11 +2471,9 @@
 }
 
 
-static int sky2_reset(struct sky2_hw *hw)
+static int __devinit sky2_init(struct sky2_hw *hw)
 {
-	u16 status;
 	u8 t8;
-	int i;
 
 	sky2_write8(hw, B0_CTST, CS_RST_CLR);
 
@@ -2429,6 +2494,22 @@
 		return -EOPNOTSUPP;
 	}
 
+	hw->pmd_type = sky2_read8(hw, B2_PMD_TYP);
+	hw->ports = 1;
+	t8 = sky2_read8(hw, B2_Y2_HW_RES);
+	if ((t8 & CFG_DUAL_MAC_MSK) == CFG_DUAL_MAC_MSK) {
+		if (!(sky2_read8(hw, B2_Y2_CLK_GATE) & Y2_STATUS_LNK2_INAC))
+			++hw->ports;
+	}
+
+	return 0;
+}
+
+static void sky2_reset(struct sky2_hw *hw)
+{
+	u16 status;
+	int i;
+
 	/* disable ASF */
 	if (hw->chip_id <= CHIP_ID_YUKON_EC) {
 		sky2_write8(hw, B28_Y2_ASF_STAT_CMD, Y2_ASF_RESET);
@@ -2453,14 +2534,6 @@
 		sky2_pci_write32(hw, PEX_UNC_ERR_STAT, 0xffffffffUL);
 
 
-	hw->pmd_type = sky2_read8(hw, B2_PMD_TYP);
-	hw->ports = 1;
-	t8 = sky2_read8(hw, B2_Y2_HW_RES);
-	if ((t8 & CFG_DUAL_MAC_MSK) == CFG_DUAL_MAC_MSK) {
-		if (!(sky2_read8(hw, B2_Y2_CLK_GATE) & Y2_STATUS_LNK2_INAC))
-			++hw->ports;
-	}
-
 	sky2_power_on(hw);
 
 	for (i = 0; i < hw->ports; i++) {
@@ -2544,7 +2617,37 @@
 	sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
 	sky2_write8(hw, STAT_LEV_TIMER_CTRL, TIM_START);
 	sky2_write8(hw, STAT_ISR_TIMER_CTRL, TIM_START);
+}
 
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
 	return 0;
 }
 
@@ -3156,7 +3259,9 @@
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
@@ -3186,7 +3291,8 @@
 
 /* Initialize network device */
 static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
-						     unsigned port, int highmem)
+						     unsigned port,
+						     int highmem, int wol)
 {
 	struct sky2_port *sky2;
 	struct net_device *dev = alloc_etherdev(sizeof(*sky2));
@@ -3234,6 +3340,7 @@
 	sky2->speed = -1;
 	sky2->advertising = sky2_supported_modes(hw);
 	sky2->rx_csum = 1;
+	sky2->wol = wol;
 
 	spin_lock_init(&sky2->phy_lock);
 	sky2->tx_pending = TX_DEF_PENDING;
@@ -3336,12 +3443,24 @@
 	return err;
 }
 
+static int __devinit pci_wake_enabled(struct pci_dev *dev)
+{
+	int pm  = pci_find_capability(dev, PCI_CAP_ID_PM);
+	u16 value;
+
+	if (!pm)
+		return 0;
+	if (pci_read_config_word(dev, pm + PCI_PM_CTRL, &value))
+		return 0;
+	return value & PCI_PM_CTRL_PME_ENABLE;
+}
+
 static int __devinit sky2_probe(struct pci_dev *pdev,
 				const struct pci_device_id *ent)
 {
 	struct net_device *dev;
 	struct sky2_hw *hw;
-	int err, using_dac = 0;
+	int err, using_dac = 0, wol_default;
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -3378,6 +3497,8 @@
 		}
 	}
 
+	wol_default = pci_wake_enabled(pdev) ? WAKE_MAGIC : 0;
+
 	err = -ENOMEM;
 	hw = kzalloc(sizeof(*hw), GFP_KERNEL);
 	if (!hw) {
@@ -3413,7 +3534,7 @@
 	if (!hw->st_le)
 		goto err_out_iounmap;
 
-	err = sky2_reset(hw);
+	err = sky2_init(hw);
 	if (err)
 		goto err_out_iounmap;
 
@@ -3422,7 +3543,9 @@
 	       pdev->irq, yukon2_name[hw->chip_id - CHIP_ID_YUKON_XL],
 	       hw->chip_id, hw->chip_rev);
 
-	dev = sky2_init_netdev(hw, 0, using_dac);
+	sky2_reset(hw);
+
+	dev = sky2_init_netdev(hw, 0, using_dac, wol_default);
 	if (!dev) {
 		err = -ENOMEM;
 		goto err_out_free_pci;
@@ -3457,7 +3580,7 @@
 	if (hw->ports > 1) {
 		struct net_device *dev1;
 
-		dev1 = sky2_init_netdev(hw, 1, using_dac);
+		dev1 = sky2_init_netdev(hw, 1, using_dac, wol_default);
 		if (!dev1) {
 			printk(KERN_WARNING PFX
 			       "allocation of second port failed\n");
@@ -3544,23 +3667,29 @@
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
@@ -3580,18 +3709,13 @@
 		goto out;
 
 	pci_enable_wake(pdev, PCI_D0, 0);
-
-	err = sky2_reset(hw);
-	if (err)
-		goto out;
+	sky2_reset(hw);
 
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
 
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
 		if (netif_running(dev)) {
-			netif_device_attach(dev);
-
 			err = sky2_up(dev);
 			if (err) {
 				printk(KERN_ERR PFX "%s: could not up: %d\n",
@@ -3612,6 +3736,35 @@
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
@@ -3621,6 +3774,7 @@
 	.suspend = sky2_suspend,
 	.resume = sky2_resume,
 #endif
+	.shutdown = sky2_shutdown,
 };
 
 static int __init sky2_init_module(void)
--- sky2-dev.orig/drivers/net/sky2.h	2007-02-06 10:44:10.000000000 -0800
+++ sky2-dev/drivers/net/sky2.h	2007-02-06 10:44:15.000000000 -0800
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
Stephen Hemminger <shemminger@linux-foundation.org>

