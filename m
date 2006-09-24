From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] skge: fiber support (rebased)
Date: Sat, 23 Sep 2006 21:25:28 -0700
Message-ID: <20060923212528.109a5056@localhost.localdomain>
References: <20060815131852.GP2900@mathom.us>
	<20060921153939.739947ab@dxpl.pdx.osdl.net>
	<45147CED.10801@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Stone <mstone@mathom.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:20710 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1752096AbWIXEZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Sep 2006 00:25:56 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <45147CED.10801@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for older fiber versions of the SysKonnect board. These chipsets
use an internal PHY so they require special handling. The older sk98lin
driver already supported these

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 drivers/net/skge.c |  357 +++++++++++++++++++++++++++++++++++++++-------------
 drivers/net/skge.h |   37 ++++-
 2 files changed, 301 insertions(+), 93 deletions(-)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 4b267b8..1b677ec 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -58,6 +58,7 @@ #define ETH_JUMBO_MTU		9000
 #define TX_WATCHDOG		(5 * HZ)
 #define NAPI_WEIGHT		64
 #define BLINK_MS		250
+#define LINK_HZ			(HZ/2)
 
 MODULE_DESCRIPTION("SysKonnect Gigabit Ethernet driver");
 MODULE_AUTHOR("Stephen Hemminger <shemminger@osdl.org>");
@@ -605,7 +606,12 @@ static void skge_led(struct skge_port *s
 	if (hw->chip_id == CHIP_ID_GENESIS) {
 		switch (mode) {
 		case LED_MODE_OFF:
-			xm_phy_write(hw, port, PHY_BCOM_P_EXT_CTRL, PHY_B_PEC_LED_OFF);
+			if (hw->phy_type == SK_PHY_BCOM)
+				xm_phy_write(hw, port, PHY_BCOM_P_EXT_CTRL, PHY_B_PEC_LED_OFF);
+			else {
+				skge_write32(hw, SK_REG(port, TX_LED_VAL), 0);
+				skge_write8(hw, SK_REG(port, TX_LED_CTRL), LED_T_OFF);
+			}
 			skge_write8(hw, SK_REG(port, LNK_LED_REG), LINKLED_OFF);
 			skge_write32(hw, SK_REG(port, RX_LED_VAL), 0);
 			skge_write8(hw, SK_REG(port, RX_LED_CTRL), LED_T_OFF);
@@ -625,8 +631,14 @@ static void skge_led(struct skge_port *s
 			skge_write32(hw, SK_REG(port, RX_LED_VAL), 100);
 			skge_write8(hw, SK_REG(port, RX_LED_CTRL), LED_START);
 
-			xm_phy_write(hw, port, PHY_BCOM_P_EXT_CTRL, PHY_B_PEC_LED_ON);
-			break;
+			if (hw->phy_type == SK_PHY_BCOM)
+				xm_phy_write(hw, port, PHY_BCOM_P_EXT_CTRL, PHY_B_PEC_LED_ON);
+			else {
+				skge_write8(hw, SK_REG(port, TX_LED_TST), LED_T_ON);
+				skge_write32(hw, SK_REG(port, TX_LED_VAL), 100);
+				skge_write8(hw, SK_REG(port, TX_LED_CTRL), LED_START);
+			}
+
 		}
 	} else {
 		switch (mode) {
@@ -879,6 +891,9 @@ static int __xm_phy_read(struct skge_hw 
 	xm_write16(hw, port, XM_PHY_ADDR, reg | hw->phy_addr);
 	*val = xm_read16(hw, port, XM_PHY_DATA);
 
+	if (hw->phy_type == SK_PHY_XMAC)
+		goto ready;
+
 	for (i = 0; i < PHY_RETRIES; i++) {
 		if (xm_read16(hw, port, XM_MMU_CMD) & XM_MMU_PHY_RDY)
 			goto ready;
@@ -965,7 +980,8 @@ static void genesis_reset(struct skge_hw
 	xm_write16(hw, port, XM_RX_CMD, 0);	/* reset RX CMD Reg */
 
 	/* disable Broadcom PHY IRQ */
-	xm_write16(hw, port, PHY_BCOM_INT_MASK, 0xffff);
+	if (hw->phy_type == SK_PHY_BCOM)
+		xm_write16(hw, port, PHY_BCOM_INT_MASK, 0xffff);
 
 	xm_outhash(hw, port, XM_HSM, zero);
 }
@@ -1000,60 +1016,64 @@ static void bcom_check_link(struct skge_
 
 		if (netif_carrier_ok(dev))
 			skge_link_down(skge);
-	} else {
-		if (skge->autoneg == AUTONEG_ENABLE &&
-		    (status & PHY_ST_AN_OVER)) {
-			u16 lpa = xm_phy_read(hw, port, PHY_BCOM_AUNE_LP);
-			u16 aux = xm_phy_read(hw, port, PHY_BCOM_AUX_STAT);
-
-			if (lpa & PHY_B_AN_RF) {
-				printk(KERN_NOTICE PFX "%s: remote fault\n",
-				       dev->name);
-				return;
-			}
+		return;
+	}
 
-			/* Check Duplex mismatch */
-			switch (aux & PHY_B_AS_AN_RES_MSK) {
-			case PHY_B_RES_1000FD:
-				skge->duplex = DUPLEX_FULL;
-				break;
-			case PHY_B_RES_1000HD:
-				skge->duplex = DUPLEX_HALF;
-				break;
-			default:
-				printk(KERN_NOTICE PFX "%s: duplex mismatch\n",
-				       dev->name);
-				return;
-			}
+	if (skge->autoneg == AUTONEG_ENABLE) {
+		u16 lpa, aux;
 
+		if (!(status & PHY_ST_AN_OVER))
+			return;
 
-			/* We are using IEEE 802.3z/D5.0 Table 37-4 */
-			switch (aux & PHY_B_AS_PAUSE_MSK) {
-			case PHY_B_AS_PAUSE_MSK:
-				skge->flow_control = FLOW_MODE_SYMMETRIC;
-				break;
-			case PHY_B_AS_PRR:
-				skge->flow_control = FLOW_MODE_REM_SEND;
-				break;
-			case PHY_B_AS_PRT:
-				skge->flow_control = FLOW_MODE_LOC_SEND;
-				break;
-			default:
-				skge->flow_control = FLOW_MODE_NONE;
-			}
+		lpa = xm_phy_read(hw, port, PHY_XMAC_AUNE_LP);
+		if (lpa & PHY_B_AN_RF) {
+			printk(KERN_NOTICE PFX "%s: remote fault\n",
+			       dev->name);
+			return;
+		}
 
-			skge->speed = SPEED_1000;
+		aux = xm_phy_read(hw, port, PHY_BCOM_AUX_STAT);
+
+		/* Check Duplex mismatch */
+		switch (aux & PHY_B_AS_AN_RES_MSK) {
+		case PHY_B_RES_1000FD:
+			skge->duplex = DUPLEX_FULL;
+			break;
+		case PHY_B_RES_1000HD:
+			skge->duplex = DUPLEX_HALF;
+			break;
+		default:
+			printk(KERN_NOTICE PFX "%s: duplex mismatch\n",
+			       dev->name);
+			return;
 		}
 
-		if (!netif_carrier_ok(dev))
-			genesis_link_up(skge);
+
+		/* We are using IEEE 802.3z/D5.0 Table 37-4 */
+		switch (aux & PHY_B_AS_PAUSE_MSK) {
+		case PHY_B_AS_PAUSE_MSK:
+			skge->flow_control = FLOW_MODE_SYMMETRIC;
+			break;
+		case PHY_B_AS_PRR:
+			skge->flow_control = FLOW_MODE_REM_SEND;
+			break;
+		case PHY_B_AS_PRT:
+			skge->flow_control = FLOW_MODE_LOC_SEND;
+			break;
+		default:
+			skge->flow_control = FLOW_MODE_NONE;
+		}
+		skge->speed = SPEED_1000;
 	}
+
+	if (!netif_carrier_ok(dev))
+		genesis_link_up(skge);
 }
 
 /* Broadcom 5400 only supports giagabit! SysKonnect did not put an additional
  * Phy on for 100 or 10Mbit operation
  */
-static void bcom_phy_init(struct skge_port *skge, int jumbo)
+static void bcom_phy_init(struct skge_port *skge)
 {
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
@@ -1144,7 +1164,7 @@ static void bcom_phy_init(struct skge_po
 		     phy_pause_map[skge->flow_control] | PHY_AN_CSMA);
 
 	/* Handle Jumbo frames */
-	if (jumbo) {
+	if (hw->dev[port]->mtu > ETH_DATA_LEN) {
 		xm_phy_write(hw, port, PHY_BCOM_AUX_CTRL,
 			     PHY_B_AC_TX_TST | PHY_B_AC_LONG_PACK);
 
@@ -1157,8 +1177,154 @@ static void bcom_phy_init(struct skge_po
 
 	/* Use link status change interrupt */
 	xm_phy_write(hw, port, PHY_BCOM_INT_MASK, PHY_B_DEF_MSK);
+}
 
-	bcom_check_link(hw, port);
+static void xm_phy_init(struct skge_port *skge)
+{
+	struct skge_hw *hw = skge->hw;
+	int port = skge->port;
+	u16 ctrl = 0;
+
+	if (skge->autoneg == AUTONEG_ENABLE) {
+		if (skge->advertising & ADVERTISED_1000baseT_Half)
+			ctrl |= PHY_X_AN_HD;
+		if (skge->advertising & ADVERTISED_1000baseT_Full)
+			ctrl |= PHY_X_AN_FD;
+
+		switch(skge->flow_control) {
+		case FLOW_MODE_NONE:
+			ctrl |= PHY_X_P_NO_PAUSE;
+			break;
+		case FLOW_MODE_LOC_SEND:
+			ctrl |= PHY_X_P_ASYM_MD;
+			break;
+		case FLOW_MODE_SYMMETRIC:
+			ctrl |= PHY_X_P_BOTH_MD;
+			break;
+		}
+
+		xm_phy_write(hw, port, PHY_XMAC_AUNE_ADV, ctrl);
+
+		/* Restart Auto-negotiation */
+		ctrl = PHY_CT_ANE | PHY_CT_RE_CFG;
+	} else {
+		/* Set DuplexMode in Config register */
+		if (skge->duplex == DUPLEX_FULL)
+			ctrl |= PHY_CT_DUP_MD;
+		/*
+		 * Do NOT enable Auto-negotiation here. This would hold
+		 * the link down because no IDLEs are transmitted
+		 */
+	}
+
+	xm_phy_write(hw, port, PHY_XMAC_CTRL, ctrl);
+
+	/* Poll PHY for status changes */
+	schedule_delayed_work(&skge->link_thread, LINK_HZ);
+}
+
+static void xm_check_link(struct net_device *dev)
+{
+	struct skge_port *skge = netdev_priv(dev);
+	struct skge_hw *hw = skge->hw;
+	int port = skge->port;
+	u16 status;
+
+	/* read twice because of latch */
+	(void) xm_phy_read(hw, port, PHY_XMAC_STAT);
+	status = xm_phy_read(hw, port, PHY_XMAC_STAT);
+
+	if ((status & PHY_ST_LSYNC) == 0) {
+		u16 cmd = xm_read16(hw, port, XM_MMU_CMD);
+		cmd &= ~(XM_MMU_ENA_RX | XM_MMU_ENA_TX);
+		xm_write16(hw, port, XM_MMU_CMD, cmd);
+		/* dummy read to ensure writing */
+		(void) xm_read16(hw, port, XM_MMU_CMD);
+
+		if (netif_carrier_ok(dev))
+			skge_link_down(skge);
+		return;
+	}
+
+	if (skge->autoneg == AUTONEG_ENABLE) {
+		u16 lpa, res;
+
+		if (!(status & PHY_ST_AN_OVER))
+			return;
+
+		lpa = xm_phy_read(hw, port, PHY_XMAC_AUNE_LP);
+		if (lpa & PHY_B_AN_RF) {
+			printk(KERN_NOTICE PFX "%s: remote fault\n",
+			       dev->name);
+			return;
+		}
+
+		res = xm_phy_read(hw, port, PHY_XMAC_RES_ABI);
+
+		/* Check Duplex mismatch */
+		switch (res & (PHY_X_RS_HD | PHY_X_RS_FD)) {
+		case PHY_X_RS_FD:
+			skge->duplex = DUPLEX_FULL;
+			break;
+		case PHY_X_RS_HD:
+			skge->duplex = DUPLEX_HALF;
+			break;
+		default:
+			printk(KERN_NOTICE PFX "%s: duplex mismatch\n",
+			       dev->name);
+			return;
+		}
+
+		/* We are using IEEE 802.3z/D5.0 Table 37-4 */
+		if (lpa & PHY_X_P_SYM_MD)
+			skge->flow_control = FLOW_MODE_SYMMETRIC;
+		else if ((lpa & PHY_X_RS_PAUSE) == PHY_X_P_ASYM_MD)
+			skge->flow_control = FLOW_MODE_REM_SEND;
+		else if ((lpa & PHY_X_RS_PAUSE) == PHY_X_P_BOTH_MD)
+			skge->flow_control = FLOW_MODE_LOC_SEND;
+		else
+			skge->flow_control = FLOW_MODE_NONE;
+
+
+		skge->speed = SPEED_1000;
+	}
+
+	if (!netif_carrier_ok(dev))
+		genesis_link_up(skge);
+}
+
+/* Poll to check for link coming up.
+ * Since internal PHY is wired to a level triggered pin, can't
+ * get an interrupt when carrier is detected.
+ */
+static void xm_link_timer(void *arg)
+{
+	struct net_device *dev = arg;
+	struct skge_port *skge = netdev_priv(arg);
+ 	struct skge_hw *hw = skge->hw;
+	int port = skge->port;
+
+	if (!netif_running(dev))
+		return;
+
+	if (netif_carrier_ok(dev)) {
+		xm_read16(hw, port, XM_ISRC);
+		if (!(xm_read16(hw, port, XM_ISRC) & XM_IS_INP_ASS))
+			goto nochange;
+	} else {
+		if (xm_read32(hw, port, XM_GP_PORT) & XM_GP_INP_ASS)
+			goto nochange;
+		xm_read16(hw, port, XM_ISRC);
+		if (xm_read16(hw, port, XM_ISRC) & XM_IS_INP_ASS)
+			goto nochange;
+	}
+
+	mutex_lock(&hw->phy_mutex);
+	xm_check_link(dev);
+	mutex_unlock(&hw->phy_mutex);
+
+nochange:
+	schedule_delayed_work(&skge->link_thread, LINK_HZ);
 }
 
 static void genesis_mac_init(struct skge_hw *hw, int port)
@@ -1189,20 +1355,29 @@ static void genesis_mac_init(struct skge
 	 * namely for the 1000baseTX cards that use the XMAC's
 	 * GMII mode.
 	 */
-	/* Take external Phy out of reset */
-	r = skge_read32(hw, B2_GP_IO);
-	if (port == 0)
-		r |= GP_DIR_0|GP_IO_0;
-	else
-		r |= GP_DIR_2|GP_IO_2;
+	if (hw->phy_type != SK_PHY_XMAC) {
+		/* Take external Phy out of reset */
+		r = skge_read32(hw, B2_GP_IO);
+		if (port == 0)
+			r |= GP_DIR_0|GP_IO_0;
+		else
+			r |= GP_DIR_2|GP_IO_2;
 
-	skge_write32(hw, B2_GP_IO, r);
+		skge_write32(hw, B2_GP_IO, r);
 
+		/* Enable GMII interface */
+		xm_write16(hw, port, XM_HW_CFG, XM_HW_GMII_MD);
+	}
 
-	/* Enable GMII interface */
-	xm_write16(hw, port, XM_HW_CFG, XM_HW_GMII_MD);
 
-	bcom_phy_init(skge, jumbo);
+	switch(hw->phy_type) {
+	case SK_PHY_XMAC:
+		xm_phy_init(skge);
+		break;
+	case SK_PHY_BCOM:
+		bcom_phy_init(skge);
+		bcom_check_link(hw, port);
+	}
 
 	/* Set Station Address */
 	xm_outaddr(hw, port, XM_SA, dev->dev_addr);
@@ -1335,16 +1510,18 @@ static void genesis_stop(struct skge_por
 	skge_write16(hw, SK_REG(port, TX_MFF_CTRL1), MFF_SET_MAC_RST);
 
 	/* For external PHYs there must be special handling */
-	reg = skge_read32(hw, B2_GP_IO);
-	if (port == 0) {
-		reg |= GP_DIR_0;
-		reg &= ~GP_IO_0;
-	} else {
-		reg |= GP_DIR_2;
-		reg &= ~GP_IO_2;
+	if (hw->phy_type != SK_PHY_XMAC) {
+		reg = skge_read32(hw, B2_GP_IO);
+		if (port == 0) {
+			reg |= GP_DIR_0;
+			reg &= ~GP_IO_0;
+		} else {
+			reg |= GP_DIR_2;
+			reg &= ~GP_IO_2;
+		}
+		skge_write32(hw, B2_GP_IO, reg);
+		skge_read32(hw, B2_GP_IO);
 	}
-	skge_write32(hw, B2_GP_IO, reg);
-	skge_read32(hw, B2_GP_IO);
 
 	xm_write16(hw, port, XM_MMU_CMD,
 			xm_read16(hw, port, XM_MMU_CMD)
@@ -1406,7 +1583,7 @@ static void genesis_link_up(struct skge_
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
 	u16 cmd;
-	u32 mode, msk;
+	u32 mode;
 
 	cmd = xm_read16(hw, port, XM_MMU_CMD);
 
@@ -1454,27 +1631,24 @@ static void genesis_link_up(struct skge_
 	}
 
 	xm_write32(hw, port, XM_MODE, mode);
-
-	msk = XM_DEF_MSK;
-	/* disable GP0 interrupt bit for external Phy */
-	msk |= XM_IS_INP_ASS;
-
-	xm_write16(hw, port, XM_IMSK, msk);
+	xm_write16(hw, port, XM_IMSK, XM_DEF_MSK);
 	xm_read16(hw, port, XM_ISRC);
 
 	/* get MMU Command Reg. */
 	cmd = xm_read16(hw, port, XM_MMU_CMD);
-	if (skge->duplex == DUPLEX_FULL)
+	if (hw->phy_type != SK_PHY_XMAC && skge->duplex == DUPLEX_FULL)
 		cmd |= XM_MMU_GMII_FD;
 
 	/*
 	 * Workaround BCOM Errata (#10523) for all BCom Phys
 	 * Enable Power Management after link up
 	 */
-	xm_phy_write(hw, port, PHY_BCOM_AUX_CTRL,
-		     xm_phy_read(hw, port, PHY_BCOM_AUX_CTRL)
-		     & ~PHY_B_AC_DIS_PM);
-	xm_phy_write(hw, port, PHY_BCOM_INT_MASK, PHY_B_DEF_MSK);
+	if (hw->phy_type == SK_PHY_BCOM) {
+		xm_phy_write(hw, port, PHY_BCOM_AUX_CTRL,
+			     xm_phy_read(hw, port, PHY_BCOM_AUX_CTRL)
+			     & ~PHY_B_AC_DIS_PM);
+		xm_phy_write(hw, port, PHY_BCOM_INT_MASK, PHY_B_DEF_MSK);
+	}
 
 	/* enable Rx/Tx */
 	xm_write16(hw, port, XM_MMU_CMD,
@@ -2240,6 +2414,8 @@ static int skge_down(struct net_device *
 		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
 
 	netif_stop_queue(dev);
+	if (hw->chip_id == CHIP_ID_GENESIS && hw->phy_type == SK_PHY_XMAC)
+		cancel_rearming_delayed_work(&skge->link_thread);
 
 	skge_write8(skge->hw, SK_REG(skge->port, LNK_LED_REG), LED_OFF);
 	if (hw->chip_id == CHIP_ID_GENESIS)
@@ -2862,7 +3038,7 @@ static void skge_extirq(void *arg)
 		if (netif_running(dev)) {
 			if (hw->chip_id != CHIP_ID_GENESIS)
 				yukon_phy_intr(skge);
-			else
+			else if (hw->phy_type == SK_PHY_BCOM)
 				bcom_phy_intr(skge);
 		}
 	}
@@ -3014,7 +3190,7 @@ static int skge_reset(struct skge_hw *hw
 {
 	u32 reg;
 	u16 ctst, pci_status;
-	u8 t8, mac_cfg, pmd_type, phy_type;
+	u8 t8, mac_cfg, pmd_type;
 	int i;
 
 	ctst = skge_read16(hw, B0_CTST);
@@ -3038,19 +3214,22 @@ static int skge_reset(struct skge_hw *hw
 		     ctst & (CS_CLK_RUN_HOT|CS_CLK_RUN_RST|CS_CLK_RUN_ENA));
 
 	hw->chip_id = skge_read8(hw, B2_CHIP_ID);
-	phy_type = skge_read8(hw, B2_E_1) & 0xf;
+	hw->phy_type = skge_read8(hw, B2_E_1) & 0xf;
 	pmd_type = skge_read8(hw, B2_PMD_TYP);
 	hw->copper = (pmd_type == 'T' || pmd_type == '1');
 
 	switch (hw->chip_id) {
 	case CHIP_ID_GENESIS:
-		switch (phy_type) {
+		switch (hw->phy_type) {
+		case SK_PHY_XMAC:
+			hw->phy_addr = PHY_ADDR_XMAC;
+			break;
 		case SK_PHY_BCOM:
 			hw->phy_addr = PHY_ADDR_BCOM;
 			break;
 		default:
 			printk(KERN_ERR PFX "%s: unsupported phy type 0x%x\n",
-			       pci_name(hw->pdev), phy_type);
+			       pci_name(hw->pdev), hw->phy_type);
 			return -EOPNOTSUPP;
 		}
 		break;
@@ -3058,7 +3237,7 @@ static int skge_reset(struct skge_hw *hw
 	case CHIP_ID_YUKON:
 	case CHIP_ID_YUKON_LITE:
 	case CHIP_ID_YUKON_LP:
-		if (phy_type < SK_PHY_MARV_COPPER && pmd_type != 'S')
+		if (hw->phy_type < SK_PHY_MARV_COPPER && pmd_type != 'S')
 			hw->copper = 1;
 
 		hw->phy_addr = PHY_ADDR_MARV;
@@ -3089,10 +3268,13 @@ static int skge_reset(struct skge_hw *hw
 	else
 		hw->ram_size = t8 * 4096;
 
-	hw->intr_mask = IS_HW_ERR | IS_EXT_REG | IS_PORT_1;
+	hw->intr_mask = IS_HW_ERR | IS_PORT_1;
 	if (hw->ports > 1)
 		hw->intr_mask |= IS_PORT_2;
 
+	if (!(hw->chip_id == CHIP_ID_GENESIS && hw->phy_type == SK_PHY_XMAC))
+		hw->intr_mask |= IS_EXT_REG;
+
 	if (hw->chip_id == CHIP_ID_GENESIS)
 		genesis_init(hw);
 	else {
@@ -3226,6 +3408,9 @@ #endif
 
 	skge->port = port;
 
+	/* Only used for Genesis XMAC */
+	INIT_WORK(&skge->link_thread, xm_link_timer, dev);
+
 	if (hw->chip_id != CHIP_ID_GENESIS) {
 		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 		skge->rx_csum = 1;
diff --git a/drivers/net/skge.h b/drivers/net/skge.h
index 79e0927..d0b47d4 100644
--- a/drivers/net/skge.h
+++ b/drivers/net/skge.h
@@ -934,7 +934,7 @@ enum {
 	PHY_XMAC_AUNE_ADV	= 0x04,/* 16 bit r/w	Auto-Neg. Advertisement */
 	PHY_XMAC_AUNE_LP	= 0x05,/* 16 bit r/o	Link Partner Abi Reg */
 	PHY_XMAC_AUNE_EXP	= 0x06,/* 16 bit r/o	Auto-Neg. Expansion Reg */
-	PHY_XMAC_NEPG	= 0x07,/* 16 bit r/w	Next Page Register */
+	PHY_XMAC_NEPG		= 0x07,/* 16 bit r/w	Next Page Register */
 	PHY_XMAC_NEPG_LP	= 0x08,/* 16 bit r/o	Next Page Link Partner */
 
 	PHY_XMAC_EXT_STAT	= 0x0f,/* 16 bit r/o	Ext Status Register */
@@ -1097,13 +1097,36 @@ enum {
 
 /* Pause Bits (PHY_X_AN_PAUSE and PHY_X_RS_PAUSE) encoding */
 enum {
-	PHY_X_P_NO_PAUSE	= 0<<7,/* Bit  8..7:	no Pause Mode */
+	PHY_X_P_NO_PAUSE= 0<<7,/* Bit  8..7:	no Pause Mode */
 	PHY_X_P_SYM_MD	= 1<<7, /* Bit  8..7:	symmetric Pause Mode */
 	PHY_X_P_ASYM_MD	= 2<<7,/* Bit  8..7:	asymmetric Pause Mode */
 	PHY_X_P_BOTH_MD	= 3<<7,/* Bit  8..7:	both Pause Mode */
 };
 
 
+/*****  PHY_XMAC_EXT_STAT	16 bit r/w	Extended Status Register *****/
+enum {
+	PHY_X_EX_FD	= 1<<15, /* Bit 15:	Device Supports Full Duplex */
+	PHY_X_EX_HD	= 1<<14, /* Bit 14:	Device Supports Half Duplex */
+};
+
+/*****  PHY_XMAC_RES_ABI	16 bit r/o	PHY Resolved Ability *****/
+enum {
+	PHY_X_RS_PAUSE	= 3<<7,	/* Bit  8..7:	selected Pause Mode */
+	PHY_X_RS_HD	= 1<<6,	/* Bit  6:	Half Duplex Mode selected */
+	PHY_X_RS_FD	= 1<<5,	/* Bit  5:	Full Duplex Mode selected */
+	PHY_X_RS_ABLMIS = 1<<4,	/* Bit  4:	duplex or pause cap mismatch */
+	PHY_X_RS_PAUMIS = 1<<3,	/* Bit  3:	pause capability mismatch */
+};
+
+/* Remote Fault Bits (PHY_X_AN_RFB) encoding */
+enum {
+	X_RFB_OK	= 0<<12,/* Bit 13..12	No errors, Link OK */
+	X_RFB_LF	= 1<<12,/* Bit 13..12	Link Failure */
+	X_RFB_OFF	= 2<<12,/* Bit 13..12	Offline */
+	X_RFB_AN_ERR	= 3<<12,/* Bit 13..12	Auto-Negotiation Error */
+};
+
 /* Broadcom-Specific */
 /*****  PHY_BCOM_1000T_CTRL	16 bit r/w	1000Base-T Control Reg *****/
 enum {
@@ -2158,8 +2181,8 @@ enum {
 	XM_IS_LNK_AE	= 1<<14, /* Bit 14:	Link Asynchronous Event */
 	XM_IS_TX_ABORT	= 1<<13, /* Bit 13:	Transmit Abort, late Col. etc */
 	XM_IS_FRC_INT	= 1<<12, /* Bit 12:	Force INT bit set in GP */
-	XM_IS_INP_ASS	= 1<<11,	/* Bit 11:	Input Asserted, GP bit 0 set */
-	XM_IS_LIPA_RC	= 1<<10,	/* Bit 10:	Link Partner requests config */
+	XM_IS_INP_ASS	= 1<<11, /* Bit 11:	Input Asserted, GP bit 0 set */
+	XM_IS_LIPA_RC	= 1<<10, /* Bit 10:	Link Partner requests config */
 	XM_IS_RX_PAGE	= 1<<9,	/* Bit  9:	Page Received */
 	XM_IS_TX_PAGE	= 1<<8,	/* Bit  8:	Next Page Loaded for Transmit */
 	XM_IS_AND	= 1<<7,	/* Bit  7:	Auto-Negotiation Done */
@@ -2172,9 +2195,7 @@ enum {
 	XM_IS_RX_COMP	= 1<<0,	/* Bit  0:	Frame Rx Complete */
 };
 
-#define XM_DEF_MSK	(~(XM_IS_INP_ASS | XM_IS_LIPA_RC | XM_IS_RX_PAGE | \
-			   XM_IS_AND | XM_IS_RXC_OV | XM_IS_TXC_OV | \
-			   XM_IS_RXF_OV | XM_IS_TXF_UR))
+#define XM_DEF_MSK	(~(XM_IS_RXC_OV | XM_IS_TXC_OV | XM_IS_RXF_OV | XM_IS_TXF_UR))
 
 
 /*	XM_HW_CFG	16 bit r/w	Hardware Config Register */
@@ -2396,6 +2417,7 @@ struct skge_hw {
 	u8		     chip_rev;
 	u8		     copper;
 	u8		     ports;
+	u8		     phy_type;
 
 	u32	     	     ram_size;
 	u32	     	     ram_offset;
@@ -2422,6 +2444,7 @@ struct skge_port {
 
 	struct net_device_stats net_stats;
 
+	struct work_struct   link_thread;
 	u8		     rx_csum;
 	u8		     blink_on;
 	u8		     flow_control;
-- 
1.4.1

