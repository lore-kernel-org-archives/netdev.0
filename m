From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/4] skge: make support for old Genesis chips optional
Date: Wed, 06 Jul 2011 22:00:07 -0700
Message-ID: <20110707050049.088695957@vyatta.com>
References: <20110707050003.998140428@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42589 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751332Ab1GGFBP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2011 01:01:15 -0400
Content-Disposition: inline; filename=skge-genesis-optional.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The GENESIS boards are really old PCI-X boards that are rare.
Marvell has dropped support for this hardware and there is no reason
for most users to have to have this code.

Rather than riddling code with ifdef's make one macro and let
the compiler do the dead code elimination.  This saves about 15%
of the text size.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/Kconfig	2011-07-06 19:26:47.503999151 -0700
+++ b/drivers/net/Kconfig	2011-07-06 19:29:14.639999138 -0700
@@ -2303,6 +2303,15 @@ config SKGE_DEBUG
 
 	  If unsure, say N.
 
+config SKGE_GENESIS
+       bool "Support for older SysKonnect Genesis boards"
+       depends on SKGE
+       help
+         This enables support for the older and uncommon SysKonnect Genesis
+	 chips, which support MII via an external transceiver, instead of
+	 an internal one. Disabling this option will save some memory
+	 by making code smaller. If unsure say Y.
+
 config SKY2
 	tristate "SysKonnect Yukon2 support"
 	depends on PCI
--- a/drivers/net/skge.c	2011-07-06 19:28:58.836000719 -0700
+++ b/drivers/net/skge.c	2011-07-06 19:29:14.639999138 -0700
@@ -85,6 +85,9 @@ MODULE_PARM_DESC(debug, "Debug level (0=
 static DEFINE_PCI_DEVICE_TABLE(skge_id_table) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_3COM, 0x1700) },	  /* 3Com 3C940 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_3COM, 0x80EB) },	  /* 3Com 3C940B */
+#ifdef CONFIG_SKGE_GENESIS
+	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x4300) }, /* SK-9xx */
+#endif
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x4320) }, /* SK-98xx V2.0 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b01) },	  /* D-Link DGE-530T (rev.B) */
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4c00) },	  /* D-Link DGE-530T */
@@ -119,6 +122,15 @@ static const u32 txirqmask[] = { IS_XA1_
 static const u32 napimask[] = { IS_R1_F|IS_XA1_F, IS_R2_F|IS_XA2_F };
 static const u32 portmask[] = { IS_PORT_1, IS_PORT_2 };
 
+static inline bool is_genesis(const struct skge_hw *hw)
+{
+#ifdef CONFIG_SKGE_GENESIS
+ 	return hw->chip_id == CHIP_ID_GENESIS;
+#else
+	return false;
+#endif
+}
+
 static int skge_get_regs_len(struct net_device *dev)
 {
 	return 0x4000;
@@ -146,7 +158,7 @@ static void skge_get_regs(struct net_dev
 /* Wake on Lan only supported on Yukon chips with rev 1 or above */
 static u32 wol_supported(const struct skge_hw *hw)
 {
-	if (hw->chip_id == CHIP_ID_GENESIS)
+	if (is_genesis(hw))
 		return 0;
 
 	if (hw->chip_id == CHIP_ID_YUKON && hw->chip_rev == 0)
@@ -270,7 +282,7 @@ static u32 skge_supported_modes(const st
 			     SUPPORTED_Autoneg |
 			     SUPPORTED_TP);
 
-		if (hw->chip_id == CHIP_ID_GENESIS)
+		if (is_genesis(hw))
 			supported &= ~(SUPPORTED_10baseT_Half |
 				       SUPPORTED_10baseT_Full |
 				       SUPPORTED_100baseT_Half |
@@ -433,7 +445,7 @@ static void skge_get_ethtool_stats(struc
 {
 	struct skge_port *skge = netdev_priv(dev);
 
-	if (skge->hw->chip_id == CHIP_ID_GENESIS)
+	if (is_genesis(skge->hw))
 		genesis_get_stats(skge, data);
 	else
 		yukon_get_stats(skge, data);
@@ -448,7 +460,7 @@ static struct net_device_stats *skge_get
 	struct skge_port *skge = netdev_priv(dev);
 	u64 data[ARRAY_SIZE(skge_stats)];
 
-	if (skge->hw->chip_id == CHIP_ID_GENESIS)
+	if (is_genesis(skge->hw))
 		genesis_get_stats(skge, data);
 	else
 		yukon_get_stats(skge, data);
@@ -589,7 +601,7 @@ static int skge_set_pauseparam(struct ne
 /* Chip internal frequency for clock calculations */
 static inline u32 hwkhz(const struct skge_hw *hw)
 {
-	return (hw->chip_id == CHIP_ID_GENESIS) ? 53125 : 78125;
+	return is_genesis(hw) ? 53125 : 78125;
 }
 
 /* Chip HZ to microseconds */
@@ -674,7 +686,7 @@ static void skge_led(struct skge_port *s
 	int port = skge->port;
 
 	spin_lock_bh(&hw->phy_lock);
-	if (hw->chip_id == CHIP_ID_GENESIS) {
+	if (is_genesis(hw)) {
 		switch (mode) {
 		case LED_MODE_OFF:
 			if (hw->phy_type == SK_PHY_BCOM)
@@ -1053,7 +1065,6 @@ static void skge_link_down(struct skge_p
 	netif_info(skge, link, skge->netdev, "Link is down\n");
 }
 
-
 static void xm_link_down(struct skge_hw *hw, int port)
 {
 	struct net_device *dev = hw->dev[port];
@@ -1172,7 +1183,6 @@ static void genesis_reset(struct skge_hw
 	xm_write32(hw, port, XM_MODE, reg | XM_MD_FRF);
 }
 
-
 /* Convert mode to MII values  */
 static const u16 phy_pause_map[] = {
 	[FLOW_MODE_NONE] =	0,
@@ -2405,7 +2415,7 @@ static void skge_phy_reset(struct skge_p
 	netif_carrier_off(skge->netdev);
 
 	spin_lock_bh(&hw->phy_lock);
-	if (hw->chip_id == CHIP_ID_GENESIS) {
+	if (is_genesis(hw)) {
 		genesis_reset(hw, port);
 		genesis_mac_init(hw, port);
 	} else {
@@ -2436,7 +2446,8 @@ static int skge_ioctl(struct net_device
 	case SIOCGMIIREG: {
 		u16 val = 0;
 		spin_lock_bh(&hw->phy_lock);
-		if (hw->chip_id == CHIP_ID_GENESIS)
+
+		if (is_genesis(hw))
 			err = __xm_phy_read(hw, skge->port, data->reg_num & 0x1f, &val);
 		else
 			err = __gm_phy_read(hw, skge->port, data->reg_num & 0x1f, &val);
@@ -2447,7 +2458,7 @@ static int skge_ioctl(struct net_device
 
 	case SIOCSMIIREG:
 		spin_lock_bh(&hw->phy_lock);
-		if (hw->chip_id == CHIP_ID_GENESIS)
+		if (is_genesis(hw))
 			err = xm_phy_write(hw, skge->port, data->reg_num & 0x1f,
 				   data->val_in);
 		else
@@ -2559,7 +2570,7 @@ static int skge_up(struct net_device *de
 
 	/* Initialize MAC */
 	spin_lock_bh(&hw->phy_lock);
-	if (hw->chip_id == CHIP_ID_GENESIS)
+	if (is_genesis(hw))
 		genesis_mac_init(hw, port);
 	else
 		yukon_mac_init(hw, port);
@@ -2621,7 +2632,7 @@ static int skge_down(struct net_device *
 
 	netif_tx_disable(dev);
 
-	if (hw->chip_id == CHIP_ID_GENESIS && hw->phy_type == SK_PHY_XMAC)
+	if (is_genesis(hw) && hw->phy_type == SK_PHY_XMAC)
 		del_timer_sync(&skge->link_timer);
 
 	napi_disable(&skge->napi);
@@ -2633,7 +2644,7 @@ static int skge_down(struct net_device *
 	spin_unlock_irq(&hw->hw_lock);
 
 	skge_write8(skge->hw, SK_REG(skge->port, LNK_LED_REG), LED_OFF);
-	if (hw->chip_id == CHIP_ID_GENESIS)
+	if (is_genesis(hw))
 		genesis_stop(skge);
 	else
 		yukon_stop(skge);
@@ -2661,7 +2672,7 @@ static int skge_down(struct net_device *
 
 	skge_rx_stop(hw, port);
 
-	if (hw->chip_id == CHIP_ID_GENESIS) {
+	if (is_genesis(hw)) {
 		skge_write8(hw, SK_REG(port, TX_MFF_CTRL2), MFF_RST_SET);
 		skge_write8(hw, SK_REG(port, RX_MFF_CTRL2), MFF_RST_SET);
 	} else {
@@ -2957,7 +2968,7 @@ static void yukon_set_multicast(struct n
 
 static inline u16 phy_length(const struct skge_hw *hw, u32 status)
 {
-	if (hw->chip_id == CHIP_ID_GENESIS)
+	if (is_genesis(hw))
 		return status >> XMR_FS_LEN_SHIFT;
 	else
 		return status >> GMR_FS_LEN_SHIFT;
@@ -2965,7 +2976,7 @@ static inline u16 phy_length(const struc
 
 static inline int bad_phy_status(const struct skge_hw *hw, u32 status)
 {
-	if (hw->chip_id == CHIP_ID_GENESIS)
+	if (is_genesis(hw))
 		return (status & (XMR_FS_ERR | XMR_FS_2L_VLAN)) != 0;
 	else
 		return (status & GMR_FS_ANY_ERR) ||
@@ -2975,9 +2986,8 @@ static inline int bad_phy_status(const s
 static void skge_set_multicast(struct net_device *dev)
 {
 	struct skge_port *skge = netdev_priv(dev);
-	struct skge_hw *hw = skge->hw;
 
-	if (hw->chip_id == CHIP_ID_GENESIS)
+	if (is_genesis(skge->hw))
 		genesis_set_multicast(dev);
 	else
 		yukon_set_multicast(dev);
@@ -3057,7 +3067,7 @@ error:
 		     "rx err, slot %td control 0x%x status 0x%x\n",
 		     e - skge->rx_ring.start, control, status);
 
-	if (skge->hw->chip_id == CHIP_ID_GENESIS) {
+	if (is_genesis(skge->hw)) {
 		if (status & (XMR_FS_RUNT|XMR_FS_LNG_ERR))
 			dev->stats.rx_length_errors++;
 		if (status & XMR_FS_FRA_ERR)
@@ -3171,7 +3181,7 @@ static void skge_mac_parity(struct skge_
 
 	++dev->stats.tx_heartbeat_errors;
 
-	if (hw->chip_id == CHIP_ID_GENESIS)
+	if (is_genesis(hw))
 		skge_write16(hw, SK_REG(port, TX_MFF_CTRL1),
 			     MFF_CLR_PERR);
 	else
@@ -3183,7 +3193,7 @@ static void skge_mac_parity(struct skge_
 
 static void skge_mac_intr(struct skge_hw *hw, int port)
 {
-	if (hw->chip_id == CHIP_ID_GENESIS)
+	if (is_genesis(hw))
 		genesis_mac_intr(hw, port);
 	else
 		yukon_mac_intr(hw, port);
@@ -3195,7 +3205,7 @@ static void skge_error_irq(struct skge_h
 	struct pci_dev *pdev = hw->pdev;
 	u32 hwstatus = skge_read32(hw, B0_HWE_ISRC);
 
-	if (hw->chip_id == CHIP_ID_GENESIS) {
+	if (is_genesis(hw)) {
 		/* clear xmac errors */
 		if (hwstatus & (IS_NO_STAT_M1|IS_NO_TIST_M1))
 			skge_write16(hw, RX_MFF_CTRL1, MFF_CLR_INSTAT);
@@ -3278,7 +3288,7 @@ static void skge_extirq(unsigned long ar
 			struct skge_port *skge = netdev_priv(dev);
 
 			spin_lock(&hw->phy_lock);
-			if (hw->chip_id != CHIP_ID_GENESIS)
+			if (!is_genesis(hw))
 				yukon_phy_intr(skge);
 			else if (hw->phy_type == SK_PHY_BCOM)
 				bcom_phy_intr(skge);
@@ -3397,7 +3407,7 @@ static int skge_set_mac_address(struct n
 		memcpy_toio(hw->regs + B2_MAC_1 + port*8, dev->dev_addr, ETH_ALEN);
 		memcpy_toio(hw->regs + B2_MAC_2 + port*8, dev->dev_addr, ETH_ALEN);
 
-		if (hw->chip_id == CHIP_ID_GENESIS)
+		if (is_genesis(hw))
 			xm_outaddr(hw, port, XM_SA, dev->dev_addr);
 		else {
 			gma_set_addr(hw, port, GM_SRC_ADDR_1L, dev->dev_addr);
@@ -3473,6 +3483,7 @@ static int skge_reset(struct skge_hw *hw
 
 	switch (hw->chip_id) {
 	case CHIP_ID_GENESIS:
+#ifdef CONFIG_SKGE_GENESIS
 		switch (hw->phy_type) {
 		case SK_PHY_XMAC:
 			hw->phy_addr = PHY_ADDR_XMAC;
@@ -3486,6 +3497,10 @@ static int skge_reset(struct skge_hw *hw
 			return -EOPNOTSUPP;
 		}
 		break;
+#else
+		dev_err(&hw->pdev->dev, "Genesis chip detected but not configured\n");
+		return -EOPNOTSUPP;
+#endif
 
 	case CHIP_ID_YUKON:
 	case CHIP_ID_YUKON_LITE:
@@ -3508,7 +3523,7 @@ static int skge_reset(struct skge_hw *hw
 
 	/* read the adapters RAM size */
 	t8 = skge_read8(hw, B2_E_0);
-	if (hw->chip_id == CHIP_ID_GENESIS) {
+	if (is_genesis(hw)) {
 		if (t8 == 3) {
 			/* special case: 4 x 64k x 36, offset = 0x80000 */
 			hw->ram_size = 0x100000;
@@ -3523,10 +3538,10 @@ static int skge_reset(struct skge_hw *hw
 	hw->intr_mask = IS_HW_ERR;
 
 	/* Use PHY IRQ for all but fiber based Genesis board */
-	if (!(hw->chip_id == CHIP_ID_GENESIS && hw->phy_type == SK_PHY_XMAC))
+	if (!(is_genesis(hw) && hw->phy_type == SK_PHY_XMAC))
 		hw->intr_mask |= IS_EXT_REG;
 
-	if (hw->chip_id == CHIP_ID_GENESIS)
+	if (is_genesis(hw))
 		genesis_init(hw);
 	else {
 		/* switch power to VCC (WA for VAUX problem) */
@@ -3591,7 +3606,7 @@ static int skge_reset(struct skge_hw *hw
 	skge_write32(hw, B0_IMSK, hw->intr_mask);
 
 	for (i = 0; i < hw->ports; i++) {
-		if (hw->chip_id == CHIP_ID_GENESIS)
+		if (is_genesis(hw))
 			genesis_reset(hw, i);
 		else
 			yukon_reset(hw, i);
@@ -3802,9 +3817,9 @@ static struct net_device *skge_devinit(s
 	skge->port = port;
 
 	/* Only used for Genesis XMAC */
-	setup_timer(&skge->link_timer, xm_link_timer, (unsigned long) skge);
-
-	if (hw->chip_id != CHIP_ID_GENESIS) {
+	if (is_genesis(hw))
+	    setup_timer(&skge->link_timer, xm_link_timer, (unsigned long) skge);
+	else {
 		dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG |
 		                   NETIF_F_RXCSUM;
 		dev->features |= dev->hw_features;


