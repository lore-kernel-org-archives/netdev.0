From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: wake on LAN with sky2
Date: Wed, 13 Dec 2006 14:58:18 -0800
Message-ID: <20061213145818.6223ffbb@dxpl.pdx.osdl.net>
References: <20061212202720.GA12047@thinkpad.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:53974 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751683AbWLMW6X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 17:58:23 -0500
To: Tino Keitel <tino.keitel@tikei.de>
In-Reply-To: <20061212202720.GA12047@thinkpad.home.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 12 Dec 2006 21:27:20 +0100
Tino Keitel <tino.keitel@tikei.de> wrote:

> Hi folks,
> 
> I just tried the sk98lin driver version 8.41.2.3 and was happy that it
> seems to support wake on LAN with the Marvell 88E8053 PCIe chip.
> However, after resume from suspend to RAM, the machine hangs. As it
> doesn't hang with sky2, it looks like this particular driver breaks
> suspend to RAM. ($%&?#!!!)



> A quick look into sk98lin_suspend() shows that there is not much stuff
> in there. Am I right that I just have to port that stuff to sky2? The
> affected file skge.c is licenced under the GPL v2 or later.
> 
> Regards,
> Tino
> -


I was working on Wol for sky2, and got part way, but discovered that on my
test machine there were worse problems. The current code in the power management
resume runs the ACPI finish routine after the device resume. The ACPI finish
routine calls the BIOS, the BIOS then breaks MSI support.

The fix for that will be to reorder the PM resume code, but doing it right
means making the process thaw code SMP safe....  There are some patches
slowly working through the PM tree to fix this..

Anyway, this is as far as I got.

---
 drivers/net/sky2.c |   92 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/sky2.h |   19 ++++------
 2 files changed, 96 insertions(+), 15 deletions(-)

--- sky2.orig/drivers/net/sky2.c	2006-11-09 14:47:59.000000000 -0800
+++ sky2/drivers/net/sky2.c	2006-11-09 14:51:21.000000000 -0800
@@ -539,16 +539,21 @@
 
 static void sky2_phy_power(struct sky2_hw *hw, unsigned port, int onoff)
 {
+	struct sky2_port *sky2 = netdev_priv(hw->dev[port]);
 	u32 reg1;
 	static const u32 phy_power[]
 		= { PCI_Y2_PHY1_POWD, PCI_Y2_PHY2_POWD };
 
+	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
+	if (sky2->wol)
+		reg1 |= PCI_Y2_PIG_ENA;
+	else
+		reg1 &= ~PCI_Y2_PIG_ENA;
+
 	/* looks like this XL is back asswards .. */
 	if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
 		onoff = !onoff;
 
-	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
-
 	if (onoff)
 		/* Turn off phy power saving */
 		reg1 &= ~phy_power[port];
@@ -568,6 +573,50 @@
 	spin_unlock_bh(&sky2->phy_lock);
 }
 
+/* Put device in state to listen for Wake On Lan */
+static void sky2_wol_init(struct sky2_port *sky2)
+{
+	struct sky2_hw *hw = sky2->hw;
+	unsigned port = sky2->port;
+	enum flow_control save_mode;
+	u16 ctrl;
+
+	sky2_phy_power(hw, port, 1);
+
+	sky2_write16(hw, B0_CTST, CS_RST_CLR);
+	sky2_write16(hw, SK_REG(port, GMAC_LINK_CTRL), GMLC_RST_CLR);
+	sky2_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_CLR);
+	sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_RST_CLR);
+
+	/* Force no F/C when for WOL, re-enable when link comes up */
+	save_mode = sky2->flow_mode;
+	sky2->flow_mode = FC_NONE;
+	sky2_phy_reinit(sky2);
+	sky2->flow_mode = save_mode;
+
+	gma_write16(hw, port, GM_GP_CTRL,
+		    GM_GPCR_FC_TX_DIS|GM_GPCR_TX_ENA|
+		    GM_GPCR_RX_ENA|GM_GPCR_FC_RX_DIS|
+		    GM_GPCR_DUP_FULL|GM_GPCR_AU_FCT_DIS);
+
+	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_CLR);
+
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
+}
+
 static void sky2_mac_init(struct sky2_hw *hw, unsigned port)
 {
 	struct sky2_port *sky2 = netdev_priv(hw->dev[port]);
@@ -1551,6 +1600,8 @@
 	sky2->rx_ring = NULL;
 	sky2->tx_ring = NULL;
 
+	if (sky2->wol)
+		sky2_wol_init(sky2);
 	return 0;
 }
 
@@ -2525,6 +2576,35 @@
 	return 0;
 }
 
+static const u8 wol_supported = WAKE_PHY | WAKE_MAGIC;
+
+static void sky2_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	const struct sky2_port *sky2 = netdev_priv(dev);
+
+	wol->supported = wol_supported;
+	wol->wolopts = sky2->wol;
+}
+
+static int sky2_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+	struct sky2_hw *hw = sky2->hw;
+
+	if (wol->wolopts & ~wol_supported)
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
@@ -2809,6 +2889,8 @@
 		    dev->dev_addr, ETH_ALEN);
 	memcpy_toio(hw->regs + B2_MAC_2 + port * 8,
 		    dev->dev_addr, ETH_ALEN);
+	memcpy_toio(hw->regs + WOL_REGS(port, WOL_MAC_ADDR),
+		    dev->dev_addr, ETH_ALEN);
 
 	/* virtual address for data */
 	gma_set_addr(hw, port, GM_SRC_ADDR_2L, dev->dev_addr);
@@ -3162,7 +3244,9 @@
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
@@ -3264,6 +3348,8 @@
 	/* read the mac address */
 	memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8, ETH_ALEN);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
+	memcpy_toio(hw->regs + WOL_REGS(port, WOL_MAC_ADDR),
+		    dev->dev_addr, ETH_ALEN);
 
 	/* device is off until link detection */
 	netif_carrier_off(dev);
--- sky2.orig/drivers/net/sky2.h	2006-11-09 14:46:08.000000000 -0800
+++ sky2/drivers/net/sky2.h	2006-11-09 14:51:21.000000000 -0800
@@ -831,9 +831,6 @@
 	GMAC_LINK_CTRL	= 0x0f10,/* 16 bit	Link Control Reg */
 
 /* Wake-up Frame Pattern Match Control Registers (YUKON only) */
-
-	WOL_REG_OFFS	= 0x20,/* HW-Bug: Address is + 0x20 against spec. */
-
 	WOL_CTRL_STAT	= 0x0f20,/* 16 bit	WOL Control/Status Reg */
 	WOL_MATCH_CTL	= 0x0f22,/*  8 bit	WOL Match Control Reg */
 	WOL_MATCH_RES	= 0x0f23,/*  8 bit	WOL Match Result Reg */
@@ -853,11 +850,13 @@
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
@@ -1712,14 +1711,17 @@
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
@@ -1738,14 +1740,6 @@
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
 /*	WOL_MATCH_CTL	 8 bit	WOL Match Control Reg */
 #define WOL_CTL_PATT_ENA(x)	(1 << (x))
 
@@ -1872,6 +1866,7 @@
 	u8		     autoneg;	/* AUTONEG_ENABLE, AUTONEG_DISABLE */
 	u8		     duplex;	/* DUPLEX_HALF, DUPLEX_FULL */
 	u8		     rx_csum;
+	u8		     wol;
  	enum flow_control    flow_mode;
  	enum flow_control    flow_status;
 

