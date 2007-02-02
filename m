From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/4] skge: WOL support
Date: Fri, 02 Feb 2007 08:22:53 -0800
Message-ID: <20070202162419.257951000@linux-foundation.org>
References: <20070202162250.980620000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:56761 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945974AbXBBQZr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 11:25:47 -0500
Content-Disposition: inline; filename=skge-wol.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add WOL support for Yukon chipsets in skge device.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/skge.c |  158 +++++++++++++++++++++++++++++++++++++++++------------
 drivers/net/skge.h |    2 
 2 files changed, 125 insertions(+), 35 deletions(-)

--- skge.orig/drivers/net/skge.c
+++ skge/drivers/net/skge.c
@@ -132,18 +132,93 @@ static void skge_get_regs(struct net_dev
 }
 
 /* Wake on Lan only supported on Yukon chips with rev 1 or above */
-static int wol_supported(const struct skge_hw *hw)
+static u32 wol_supported(const struct skge_hw *hw)
 {
-	return !((hw->chip_id == CHIP_ID_GENESIS ||
-		  (hw->chip_id == CHIP_ID_YUKON && hw->chip_rev == 0)));
+	if (hw->chip_id == CHIP_ID_YUKON && hw->chip_rev != 0)
+		return WAKE_MAGIC | WAKE_PHY;
+	else
+		return 0;
+}
+
+static u32 pci_wake_enabled(struct pci_dev *dev)
+{
+	int pm = pci_find_capability(dev, PCI_CAP_ID_PM);
+	u16 value;
+
+	/* If device doesn't support PM Capabilities, but request is to disable
+	 * wake events, it's a nop; otherwise fail */
+	if (!pm)
+		return 0;
+
+	pci_read_config_word(dev, pm + PCI_PM_PMC, &value);
+
+	value &= PCI_PM_CAP_PME_MASK;
+	value >>= ffs(PCI_PM_CAP_PME_MASK) - 1;   /* First bit of mask */
+
+	return value != 0;
+}
+
+static void skge_wol_init(struct skge_port *skge)
+{
+	struct skge_hw *hw = skge->hw;
+	int port = skge->port;
+	enum pause_control save_mode;
+	u32 ctrl;
+
+	/* Bring hardware out of reset */
+	skge_write16(hw, B0_CTST, CS_RST_CLR);
+	skge_write16(hw, SK_REG(port, GMAC_LINK_CTRL), GMLC_RST_CLR);
+
+	skge_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_CLR);
+	skge_write8(hw, SK_REG(port, GMAC_CTRL), GMC_RST_CLR);
+
+	/* Force to 10/100 skge_reset will re-enable on resume	 */
+	save_mode = skge->flow_control;
+	skge->flow_control = FLOW_MODE_SYMMETRIC;
+
+	ctrl = skge->advertising;
+	skge->advertising &= ~(ADVERTISED_1000baseT_Half|ADVERTISED_1000baseT_Full);
+
+	skge_phy_reset(skge);
+
+	skge->flow_control = save_mode;
+	skge->advertising = ctrl;
+
+	/* Set GMAC to no flow control and auto update for speed/duplex */
+	gma_write16(hw, port, GM_GP_CTRL,
+		    GM_GPCR_FC_TX_DIS|GM_GPCR_TX_ENA|GM_GPCR_RX_ENA|
+		    GM_GPCR_DUP_FULL|GM_GPCR_FC_RX_DIS|GM_GPCR_AU_FCT_DIS);
+
+	/* Set WOL address */
+	memcpy_toio(hw->regs + WOL_REGS(port, WOL_MAC_ADDR),
+		    skge->netdev->dev_addr, ETH_ALEN);
+
+	/* Turn on appropriate WOL control bits */
+	skge_write16(hw, WOL_REGS(port, WOL_CTRL_STAT), WOL_CTL_CLEAR_RESULT);
+	ctrl = 0;
+	if (skge->wol & WAKE_PHY)
+		ctrl |= WOL_CTL_ENA_PME_ON_LINK_CHG|WOL_CTL_ENA_LINK_CHG_UNIT;
+	else
+		ctrl |= WOL_CTL_DIS_PME_ON_LINK_CHG|WOL_CTL_DIS_LINK_CHG_UNIT;
+
+	if (skge->wol & WAKE_MAGIC)
+		ctrl |= WOL_CTL_ENA_PME_ON_MAGIC_PKT|WOL_CTL_ENA_MAGIC_PKT_UNIT;
+	else
+		ctrl |= WOL_CTL_DIS_PME_ON_MAGIC_PKT|WOL_CTL_DIS_MAGIC_PKT_UNIT;;
+
+	ctrl |= WOL_CTL_DIS_PME_ON_PATTERN|WOL_CTL_DIS_PATTERN_UNIT;
+	skge_write16(hw, WOL_REGS(port, WOL_CTRL_STAT), ctrl);
+
+	/* block receiver */
+	skge_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
 }
 
 static void skge_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct skge_port *skge = netdev_priv(dev);
 
-	wol->supported = wol_supported(skge->hw) ? WAKE_MAGIC : 0;
-	wol->wolopts = skge->wol ? WAKE_MAGIC : 0;
+	wol->supported = wol_supported(skge->hw);
+	wol->wolopts = skge->wol;
 }
 
 static int skge_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
@@ -151,23 +226,12 @@ static int skge_set_wol(struct net_devic
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_hw *hw = skge->hw;
 
-	if (wol->wolopts != WAKE_MAGIC && wol->wolopts != 0)
-		return -EOPNOTSUPP;
-
-	if (wol->wolopts == WAKE_MAGIC && !wol_supported(hw))
+	if (wol->wolopts & wol_supported(hw))
 		return -EOPNOTSUPP;
 
-	skge->wol = wol->wolopts == WAKE_MAGIC;
-
-	if (skge->wol) {
-		memcpy_toio(hw->regs + WOL_MAC_ADDR, dev->dev_addr, ETH_ALEN);
-
-		skge_write16(hw, WOL_CTRL_STAT,
-			     WOL_CTL_ENA_PME_ON_MAGIC_PKT |
-			     WOL_CTL_ENA_MAGIC_PKT_UNIT);
-	} else
-		skge_write16(hw, WOL_CTRL_STAT, WOL_CTL_DEFAULT);
-
+	skge->wol = wol->wolopts;
+	if (!netif_running(dev))
+		skge_wol_init(skge);
 	return 0;
 }
 
@@ -3456,6 +3520,7 @@ static struct net_device *skge_devinit(s
 	skge->duplex = -1;
 	skge->speed = -1;
 	skge->advertising = skge_supported_modes(hw);
+	skge->wol = pci_wake_enabled(hw->pdev) ? wol_supported(hw) : 0;
 
 	hw->dev[port] = dev;
 
@@ -3654,28 +3719,46 @@ static void __devexit skge_remove(struct
 }
 
 #ifdef CONFIG_PM
+static int vaux_avail(struct pci_dev *pdev)
+{
+	int pm_cap;
+
+	pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
+	if (pm_cap) {
+		u16 ctl;
+		pci_read_config_word(pdev, pm_cap + PCI_PM_PMC, &ctl);
+		if (ctl & PCI_PM_CAP_AUX_POWER)
+			return 1;
+	}
+	return 0;
+}
+
+
 static int skge_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct skge_hw *hw  = pci_get_drvdata(pdev);
-	int i, wol = 0;
+	int i, err, wol = 0;
+
+	err = pci_save_state(pdev);
+	if (err)
+		return err;
 
-	pci_save_state(pdev);
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
+		struct skge_port *skge = netdev_priv(dev);
 
-		if (netif_running(dev)) {
-			struct skge_port *skge = netdev_priv(dev);
+		if (netif_running(dev))
+			skge_down(dev);
+		if (skge->wol)
+			skge_wol_init(skge);
 
-			netif_carrier_off(dev);
-			if (skge->wol)
-				netif_stop_queue(dev);
-			else
-				skge_down(dev);
-			wol |= skge->wol;
-		}
-		netif_device_detach(dev);
+		wol |= skge->wol;
 	}
 
+	if (wol && vaux_avail(pdev))
+		skge_write8(hw, B0_POWER_CTRL,
+			    PC_VAUX_ENA | PC_VCC_ENA | PC_VAUX_ON | PC_VCC_OFF);
+
 	skge_write32(hw, B0_IMSK, 0);
 	pci_enable_wake(pdev, pci_choose_state(pdev, state), wol);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
@@ -3688,8 +3771,14 @@ static int skge_resume(struct pci_dev *p
 	struct skge_hw *hw  = pci_get_drvdata(pdev);
 	int i, err;
 
-	pci_set_power_state(pdev, PCI_D0);
-	pci_restore_state(pdev);
+	err = pci_set_power_state(pdev, PCI_D0);
+	if (err)
+		goto out;
+
+	err = pci_restore_state(pdev);
+	if (err)
+		goto out;
+
 	pci_enable_wake(pdev, PCI_D0, 0);
 
 	err = skge_reset(hw);
@@ -3699,7 +3788,6 @@ static int skge_resume(struct pci_dev *p
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
 
-		netif_device_attach(dev);
 		if (netif_running(dev)) {
 			err = skge_up(dev);
 
--- skge.orig/drivers/net/skge.h
+++ skge/drivers/net/skge.h
@@ -876,11 +876,13 @@ enum {
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
 	BASE_XMAC_1	= 0x2000,/* XMAC 1 registers */

-- 

