From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Thu, 20 Sep 2007 15:33:30 -0400
Message-ID: <20070920193330.GA9505@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:41641 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753146AbXITTdb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 15:33:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This includes the sky2 update that you and sch discussed.

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/myri10ge/myri10ge.c |    3 +
 drivers/net/phy/phy.c           |    1 +
 drivers/net/sky2.c              |  368 +++++++++++++++++++++++++++------------
 drivers/net/sky2.h              |   41 ++++-
 4 files changed, 292 insertions(+), 121 deletions(-)

Brice Goglin (1):
      myri10ge: Add support for PCI device id 9

Domen Puncer (1):
      phy: export phy_mii_ioctl

Stephen Hemminger (6):
      sky2: fix VLAN receive processing (resend)
      sky2: ethtool speed report bug
      sky2: reorganize chip revision features
      sky2: fe+ chip support
      sky2: receive FIFO checking
      sky2: version 1.18

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 1c42266..556962f 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -3094,9 +3094,12 @@ static void myri10ge_remove(struct pci_dev *pdev)
 }
 
 #define PCI_DEVICE_ID_MYRICOM_MYRI10GE_Z8E 	0x0008
+#define PCI_DEVICE_ID_MYRICOM_MYRI10GE_Z8E_9	0x0009
 
 static struct pci_device_id myri10ge_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_MYRICOM, PCI_DEVICE_ID_MYRICOM_MYRI10GE_Z8E)},
+	{PCI_DEVICE
+	 (PCI_VENDOR_ID_MYRICOM, PCI_DEVICE_ID_MYRICOM_MYRI10GE_Z8E_9)},
 	{0},
 };
 
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 0cc4369..cb230f4 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -409,6 +409,7 @@ int phy_mii_ioctl(struct phy_device *phydev,
 
 	return 0;
 }
+EXPORT_SYMBOL(phy_mii_ioctl);
 
 /**
  * phy_start_aneg - start auto-negotiation for this PHY device
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 5d812de..eaffe55 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -51,7 +51,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.17"
+#define DRV_VERSION		"1.18"
 #define PFX			DRV_NAME " "
 
 /*
@@ -118,12 +118,15 @@ static const struct pci_device_id sky2_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4351) }, /* 88E8036 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4352) }, /* 88E8038 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4353) }, /* 88E8039 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4354) }, /* 88E8040 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4356) }, /* 88EC033 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x435A) }, /* 88E8048 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4360) }, /* 88E8052 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4361) }, /* 88E8050 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4362) }, /* 88E8053 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4363) }, /* 88E8055 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4364) }, /* 88E8056 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4365) }, /* 88E8070 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4366) }, /* 88EC036 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4367) }, /* 88EC032 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4368) }, /* 88EC034 */
@@ -147,6 +150,7 @@ static const char *yukon2_name[] = {
 	"Extreme",	/* 0xb5 */
 	"EC",		/* 0xb6 */
 	"FE",		/* 0xb7 */
+	"FE+",		/* 0xb8 */
 };
 
 static void sky2_set_multicast(struct net_device *dev);
@@ -217,8 +221,7 @@ static void sky2_power_on(struct sky2_hw *hw)
 	else
 		sky2_write8(hw, B2_Y2_CLK_GATE, 0);
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U ||
-	    hw->chip_id == CHIP_ID_YUKON_EX) {
+	if (hw->flags & SKY2_HW_ADV_POWER_CTL) {
 		u32 reg;
 
 		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
@@ -311,10 +314,8 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 	struct sky2_port *sky2 = netdev_priv(hw->dev[port]);
 	u16 ctrl, ct1000, adv, pg, ledctrl, ledover, reg;
 
-	if (sky2->autoneg == AUTONEG_ENABLE
-	    && !(hw->chip_id == CHIP_ID_YUKON_XL
-		 || hw->chip_id == CHIP_ID_YUKON_EC_U
-		 || hw->chip_id == CHIP_ID_YUKON_EX)) {
+	if (sky2->autoneg == AUTONEG_ENABLE &&
+	    !(hw->flags & SKY2_HW_NEWER_PHY)) {
 		u16 ectrl = gm_phy_read(hw, port, PHY_MARV_EXT_CTRL);
 
 		ectrl &= ~(PHY_M_EC_M_DSC_MSK | PHY_M_EC_S_DSC_MSK |
@@ -334,7 +335,7 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 
 	ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
 	if (sky2_is_copper(hw)) {
-		if (hw->chip_id == CHIP_ID_YUKON_FE) {
+		if (!(hw->flags & SKY2_HW_GIGABIT)) {
 			/* enable automatic crossover */
 			ctrl |= PHY_M_PC_MDI_XMODE(PHY_M_PC_ENA_AUTO) >> 1;
 		} else {
@@ -346,9 +347,7 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 
 			/* downshift on PHY 88E1112 and 88E1149 is changed */
 			if (sky2->autoneg == AUTONEG_ENABLE
-			    && (hw->chip_id == CHIP_ID_YUKON_XL
-				|| hw->chip_id == CHIP_ID_YUKON_EC_U
-				|| hw->chip_id == CHIP_ID_YUKON_EX)) {
+			    && (hw->flags & SKY2_HW_NEWER_PHY)) {
 				/* set downshift counter to 3x and enable downshift */
 				ctrl &= ~PHY_M_PC_DSC_MSK;
 				ctrl |= PHY_M_PC_DSC(2) | PHY_M_PC_DOWN_S_ENA;
@@ -364,7 +363,7 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 	gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
 
 	/* special setup for PHY 88E1112 Fiber */
-	if (hw->chip_id == CHIP_ID_YUKON_XL && !sky2_is_copper(hw)) {
+	if (hw->chip_id == CHIP_ID_YUKON_XL && (hw->flags & SKY2_HW_FIBRE_PHY)) {
 		pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
 
 		/* Fiber: select 1000BASE-X only mode MAC Specific Ctrl Reg. */
@@ -455,7 +454,7 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 
 	gma_write16(hw, port, GM_GP_CTRL, reg);
 
-	if (hw->chip_id != CHIP_ID_YUKON_FE)
+	if (hw->flags & SKY2_HW_GIGABIT)
 		gm_phy_write(hw, port, PHY_MARV_1000T_CTRL, ct1000);
 
 	gm_phy_write(hw, port, PHY_MARV_AUNE_ADV, adv);
@@ -479,6 +478,23 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 		gm_phy_write(hw, port, PHY_MARV_FE_LED_PAR, ctrl);
 		break;
 
+	case CHIP_ID_YUKON_FE_P:
+		/* Enable Link Partner Next Page */
+		ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
+		ctrl |= PHY_M_PC_ENA_LIP_NP;
+
+		/* disable Energy Detect and enable scrambler */
+		ctrl &= ~(PHY_M_PC_ENA_ENE_DT | PHY_M_PC_DIS_SCRAMB);
+		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
+
+		/* set LED2 -> ACT, LED1 -> LINK, LED0 -> SPEED */
+		ctrl = PHY_M_FELP_LED2_CTRL(LED_PAR_CTRL_ACT_BL) |
+			PHY_M_FELP_LED1_CTRL(LED_PAR_CTRL_LINK) |
+			PHY_M_FELP_LED0_CTRL(LED_PAR_CTRL_SPEED);
+
+		gm_phy_write(hw, port, PHY_MARV_FE_LED_PAR, ctrl);
+		break;
+
 	case CHIP_ID_YUKON_XL:
 		pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
 
@@ -548,7 +564,13 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 
 		/* set page register to 0 */
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0);
+	} else if (hw->chip_id == CHIP_ID_YUKON_FE_P &&
+		   hw->chip_rev == CHIP_REV_YU_FE2_A0) {
+		/* apply workaround for integrated resistors calibration */
+		gm_phy_write(hw, port, PHY_MARV_PAGE_ADDR, 17);
+		gm_phy_write(hw, port, PHY_MARV_PAGE_DATA, 0x3f60);
 	} else if (hw->chip_id != CHIP_ID_YUKON_EX) {
+		/* no effect on Yukon-XL */
 		gm_phy_write(hw, port, PHY_MARV_LED_CTRL, ledctrl);
 
 		if (sky2->autoneg == AUTONEG_DISABLE || sky2->speed == SPEED_100) {
@@ -669,25 +691,25 @@ static void sky2_wol_init(struct sky2_port *sky2)
 
 static void sky2_set_tx_stfwd(struct sky2_hw *hw, unsigned port)
 {
-	if (hw->chip_id == CHIP_ID_YUKON_EX && hw->chip_rev != CHIP_REV_YU_EX_A0) {
+	struct net_device *dev = hw->dev[port];
+
+	if (dev->mtu <= ETH_DATA_LEN)
 		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
-			     TX_STFW_ENA |
-			     (hw->dev[port]->mtu > ETH_DATA_LEN) ? TX_JUMBO_ENA : TX_JUMBO_DIS);
-	} else {
-		if (hw->dev[port]->mtu > ETH_DATA_LEN) {
-			/* set Tx GMAC FIFO Almost Empty Threshold */
-			sky2_write32(hw, SK_REG(port, TX_GMF_AE_THR),
-				     (ECU_JUMBO_WM << 16) | ECU_AE_THR);
+			     TX_JUMBO_DIS | TX_STFW_ENA);
 
-			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
-				     TX_JUMBO_ENA | TX_STFW_DIS);
+	else if (hw->chip_id != CHIP_ID_YUKON_EC_U)
+		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+			     TX_STFW_ENA | TX_JUMBO_ENA);
+	else {
+		/* set Tx GMAC FIFO Almost Empty Threshold */
+		sky2_write32(hw, SK_REG(port, TX_GMF_AE_THR),
+			     (ECU_JUMBO_WM << 16) | ECU_AE_THR);
 
-			/* Can't do offload because of lack of store/forward */
-			hw->dev[port]->features &= ~(NETIF_F_TSO | NETIF_F_SG
-						     | NETIF_F_ALL_CSUM);
-		} else
-			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
-				     TX_JUMBO_DIS | TX_STFW_ENA);
+		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+			     TX_JUMBO_ENA | TX_STFW_DIS);
+
+		/* Can't do offload because of lack of store/forward */
+		dev->features &= ~(NETIF_F_TSO | NETIF_F_SG | NETIF_F_ALL_CSUM);
 	}
 }
 
@@ -773,7 +795,8 @@ static void sky2_mac_init(struct sky2_hw *hw, unsigned port)
 	/* Configure Rx MAC FIFO */
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_CLR);
 	rx_reg = GMF_OPER_ON | GMF_RX_F_FL_ON;
-	if (hw->chip_id == CHIP_ID_YUKON_EX)
+	if (hw->chip_id == CHIP_ID_YUKON_EX ||
+	    hw->chip_id == CHIP_ID_YUKON_FE_P)
 		rx_reg |= GMF_RX_OVER_ON;
 
 	sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T), rx_reg);
@@ -782,13 +805,18 @@ static void sky2_mac_init(struct sky2_hw *hw, unsigned port)
 	sky2_write16(hw, SK_REG(port, RX_GMF_FL_MSK), GMR_FS_ANY_ERR);
 
 	/* Set threshold to 0xa (64 bytes) + 1 to workaround pause bug  */
-	sky2_write16(hw, SK_REG(port, RX_GMF_FL_THR), RX_GMF_FL_THR_DEF+1);
+	reg = RX_GMF_FL_THR_DEF + 1;
+	/* Another magic mystery workaround from sk98lin */
+	if (hw->chip_id == CHIP_ID_YUKON_FE_P &&
+	    hw->chip_rev == CHIP_REV_YU_FE2_A0)
+		reg = 0x178;
+	sky2_write16(hw, SK_REG(port, RX_GMF_FL_THR), reg);
 
 	/* Configure Tx MAC FIFO */
 	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_CLR);
 	sky2_write16(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_OPER_ON);
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX) {
+	if (!(hw->flags & SKY2_HW_RAMBUFFER)) {
 		sky2_write8(hw, SK_REG(port, RX_GMF_LP_THR), 768/8);
 		sky2_write8(hw, SK_REG(port, RX_GMF_UP_THR), 1024/8);
 
@@ -967,19 +995,15 @@ static void sky2_rx_unmap_skb(struct pci_dev *pdev, struct rx_ring_info *re)
  */
 static void rx_set_checksum(struct sky2_port *sky2)
 {
-	struct sky2_rx_le *le;
+	struct sky2_rx_le *le = sky2_next_rx(sky2);
 
-	if (sky2->hw->chip_id != CHIP_ID_YUKON_EX) {
-		le = sky2_next_rx(sky2);
-		le->addr = cpu_to_le32((ETH_HLEN << 16) | ETH_HLEN);
-		le->ctrl = 0;
-		le->opcode = OP_TCPSTART | HW_OWNER;
-
-		sky2_write32(sky2->hw,
-			     Q_ADDR(rxqaddr[sky2->port], Q_CSR),
-			     sky2->rx_csum ? BMU_ENA_RX_CHKSUM : BMU_DIS_RX_CHKSUM);
-	}
+	le->addr = cpu_to_le32((ETH_HLEN << 16) | ETH_HLEN);
+	le->ctrl = 0;
+	le->opcode = OP_TCPSTART | HW_OWNER;
 
+	sky2_write32(sky2->hw,
+		     Q_ADDR(rxqaddr[sky2->port], Q_CSR),
+		     sky2->rx_csum ? BMU_ENA_RX_CHKSUM : BMU_DIS_RX_CHKSUM);
 }
 
 /*
@@ -1175,7 +1199,8 @@ static int sky2_rx_start(struct sky2_port *sky2)
 
 	sky2_prefetch_init(hw, rxq, sky2->rx_le_map, RX_LE_SIZE - 1);
 
-	rx_set_checksum(sky2);
+	if (!(hw->flags & SKY2_HW_NEW_LE))
+		rx_set_checksum(sky2);
 
 	/* Space needed for frame data + headers rounded up */
 	size = roundup(sky2->netdev->mtu + ETH_HLEN + VLAN_HLEN, 8);
@@ -1246,7 +1271,7 @@ static int sky2_up(struct net_device *dev)
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
-	u32 ramsize, imask;
+	u32 imask;
 	int cap, err = -ENOMEM;
 	struct net_device *otherdev = hw->dev[sky2->port^1];
 
@@ -1301,13 +1326,13 @@ static int sky2_up(struct net_device *dev)
 
 	sky2_mac_init(hw, port);
 
-	/* Register is number of 4K blocks on internal RAM buffer. */
-	ramsize = sky2_read8(hw, B2_E_0) * 4;
-	printk(KERN_INFO PFX "%s: ram buffer %dK\n", dev->name, ramsize);
-
-	if (ramsize > 0) {
+	if (hw->flags & SKY2_HW_RAMBUFFER) {
+		/* Register is number of 4K blocks on internal RAM buffer. */
+		u32 ramsize = sky2_read8(hw, B2_E_0) * 4;
 		u32 rxspace;
 
+		printk(KERN_DEBUG PFX "%s: ram buffer %dK\n", dev->name, ramsize);
+
 		if (ramsize < 16)
 			rxspace = ramsize / 2;
 		else
@@ -1436,13 +1461,15 @@ static int sky2_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 	/* Check for TCP Segmentation Offload */
 	mss = skb_shinfo(skb)->gso_size;
 	if (mss != 0) {
-		if (hw->chip_id != CHIP_ID_YUKON_EX)
+
+		if (!(hw->flags & SKY2_HW_NEW_LE))
 			mss += ETH_HLEN + ip_hdrlen(skb) + tcp_hdrlen(skb);
 
   		if (mss != sky2->tx_last_mss) {
   			le = get_tx_le(sky2);
   			le->addr = cpu_to_le32(mss);
- 			if (hw->chip_id == CHIP_ID_YUKON_EX)
+
+			if (hw->flags & SKY2_HW_NEW_LE)
 				le->opcode = OP_MSS | HW_OWNER;
 			else
 				le->opcode = OP_LRGLEN | HW_OWNER;
@@ -1468,8 +1495,7 @@ static int sky2_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 	/* Handle TCP checksum offload */
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		/* On Yukon EX (some versions) encoding change. */
- 		if (hw->chip_id == CHIP_ID_YUKON_EX
-		    && hw->chip_rev != CHIP_REV_YU_EX_B0)
+ 		if (hw->flags & SKY2_HW_AUTO_TX_SUM)
  			ctrl |= CALSUM;	/* auto checksum */
 		else {
 			const unsigned offset = skb_transport_offset(skb);
@@ -1622,9 +1648,6 @@ static int sky2_down(struct net_device *dev)
 	if (netif_msg_ifdown(sky2))
 		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
 
-	if (netif_carrier_ok(dev) && --hw->active == 0)
-		del_timer(&hw->watchdog_timer);
-
 	/* Stop more packets from being queued */
 	netif_stop_queue(dev);
 
@@ -1708,11 +1731,15 @@ static int sky2_down(struct net_device *dev)
 
 static u16 sky2_phy_speed(const struct sky2_hw *hw, u16 aux)
 {
-	if (!sky2_is_copper(hw))
+	if (hw->flags & SKY2_HW_FIBRE_PHY)
 		return SPEED_1000;
 
-	if (hw->chip_id == CHIP_ID_YUKON_FE)
-		return (aux & PHY_M_PS_SPEED_100) ? SPEED_100 : SPEED_10;
+	if (!(hw->flags & SKY2_HW_GIGABIT)) {
+		if (aux & PHY_M_PS_SPEED_100)
+			return SPEED_100;
+		else
+			return SPEED_10;
+	}
 
 	switch (aux & PHY_M_PS_SPEED_MSK) {
 	case PHY_M_PS_SPEED_1000:
@@ -1745,17 +1772,13 @@ static void sky2_link_up(struct sky2_port *sky2)
 
 	netif_carrier_on(sky2->netdev);
 
-	if (hw->active++ == 0)
-		mod_timer(&hw->watchdog_timer, jiffies + 1);
-
+	mod_timer(&hw->watchdog_timer, jiffies + 1);
 
 	/* Turn on link LED */
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG),
 		    LINKLED_ON | LINKLED_BLINK_OFF | LINKLED_LINKSYNC_OFF);
 
-	if (hw->chip_id == CHIP_ID_YUKON_XL
-	    || hw->chip_id == CHIP_ID_YUKON_EC_U
-	    || hw->chip_id == CHIP_ID_YUKON_EX) {
+	if (hw->flags & SKY2_HW_NEWER_PHY) {
 		u16 pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
 		u16 led = PHY_M_LEDC_LOS_CTRL(1);	/* link active */
 
@@ -1800,11 +1823,6 @@ static void sky2_link_down(struct sky2_port *sky2)
 
 	netif_carrier_off(sky2->netdev);
 
-	/* Stop watchdog if both ports are not active */
-	if (--hw->active == 0)
-		del_timer(&hw->watchdog_timer);
-
-
 	/* Turn on link LED */
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG), LINKLED_OFF);
 
@@ -1847,7 +1865,7 @@ static int sky2_autoneg_done(struct sky2_port *sky2, u16 aux)
 	/* Since the pause result bits seem to in different positions on
 	 * different chips. look at registers.
 	 */
-	if (!sky2_is_copper(hw)) {
+	if (hw->flags & SKY2_HW_FIBRE_PHY) {
 		/* Shift for bits in fiber PHY */
 		advert &= ~(ADVERTISE_PAUSE_CAP|ADVERTISE_PAUSE_ASYM);
 		lpa &= ~(LPA_PAUSE_CAP|LPA_PAUSE_ASYM);
@@ -1958,7 +1976,9 @@ static int sky2_change_mtu(struct net_device *dev, int new_mtu)
 	if (new_mtu < ETH_ZLEN || new_mtu > ETH_JUMBO_MTU)
 		return -EINVAL;
 
-	if (new_mtu > ETH_DATA_LEN && hw->chip_id == CHIP_ID_YUKON_FE)
+	if (new_mtu > ETH_DATA_LEN &&
+	    (hw->chip_id == CHIP_ID_YUKON_FE ||
+	     hw->chip_id == CHIP_ID_YUKON_FE_P))
 		return -EINVAL;
 
 	if (!netif_running(dev)) {
@@ -1975,7 +1995,7 @@ static int sky2_change_mtu(struct net_device *dev, int new_mtu)
 
 	synchronize_irq(hw->pdev->irq);
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX)
+	if (!(hw->flags & SKY2_HW_RAMBUFFER))
 		sky2_set_tx_stfwd(hw, port);
 
 	ctl = gma_read16(hw, port, GM_GP_CTRL);
@@ -2103,6 +2123,13 @@ static struct sk_buff *sky2_receive(struct net_device *dev,
  	struct sky2_port *sky2 = netdev_priv(dev);
 	struct rx_ring_info *re = sky2->rx_ring + sky2->rx_next;
 	struct sk_buff *skb = NULL;
+	u16 count = (status & GMR_FS_LEN) >> 16;
+
+#ifdef SKY2_VLAN_TAG_USED
+	/* Account for vlan tag */
+	if (sky2->vlgrp && (status & GMR_FS_VLAN))
+		count -= VLAN_HLEN;
+#endif
 
 	if (unlikely(netif_msg_rx_status(sky2)))
 		printk(KERN_DEBUG PFX "%s: rx slot %u status 0x%x len %d\n",
@@ -2117,7 +2144,8 @@ static struct sk_buff *sky2_receive(struct net_device *dev,
 	if (!(status & GMR_FS_RX_OK))
 		goto resubmit;
 
-	if (status >> 16 != length)
+	/* if length reported by DMA does not match PHY, packet was truncated */
+	if (length != count)
 		goto len_mismatch;
 
 	if (length < copybreak)
@@ -2133,6 +2161,10 @@ len_mismatch:
 	/* Truncation of overlength packets
 	   causes PHY length to not match MAC length */
 	++sky2->net_stats.rx_length_errors;
+	if (netif_msg_rx_err(sky2) && net_ratelimit())
+		pr_info(PFX "%s: rx length mismatch: length %d status %#x\n",
+			dev->name, length, status);
+	goto resubmit;
 
 error:
 	++sky2->net_stats.rx_errors;
@@ -2202,7 +2234,7 @@ static int sky2_status_intr(struct sky2_hw *hw, int to_do)
 			}
 
 			/* This chip reports checksum status differently */
-			if (hw->chip_id == CHIP_ID_YUKON_EX) {
+			if (hw->flags & SKY2_HW_NEW_LE) {
 				if (sky2->rx_csum &&
 				    (le->css & (CSS_ISIPV4 | CSS_ISIPV6)) &&
 				    (le->css & CSS_TCPUDPCSOK))
@@ -2243,8 +2275,14 @@ static int sky2_status_intr(struct sky2_hw *hw, int to_do)
 			if (!sky2->rx_csum)
 				break;
 
-			if (hw->chip_id == CHIP_ID_YUKON_EX)
+			/* If this happens then driver assuming wrong format */
+			if (unlikely(hw->flags & SKY2_HW_NEW_LE)) {
+				if (net_ratelimit())
+					printk(KERN_NOTICE "%s: unexpected"
+					       " checksum status\n",
+					       dev->name);
 				break;
+			}
 
 			/* Both checksum counters are programmed to start at
 			 * the same offset, so unless there is a problem they
@@ -2436,20 +2474,72 @@ static void sky2_le_error(struct sky2_hw *hw, unsigned port,
 	sky2_write32(hw, Q_ADDR(q, Q_CSR), BMU_CLR_IRQ_CHK);
 }
 
-/* Check for lost IRQ once a second */
+static int sky2_rx_hung(struct net_device *dev)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+	struct sky2_hw *hw = sky2->hw;
+	unsigned port = sky2->port;
+	unsigned rxq = rxqaddr[port];
+	u32 mac_rp = sky2_read32(hw, SK_REG(port, RX_GMF_RP));
+	u8 mac_lev = sky2_read8(hw, SK_REG(port, RX_GMF_RLEV));
+	u8 fifo_rp = sky2_read8(hw, Q_ADDR(rxq, Q_RP));
+	u8 fifo_lev = sky2_read8(hw, Q_ADDR(rxq, Q_RL));
+
+	/* If idle and MAC or PCI is stuck */
+	if (sky2->check.last == dev->last_rx &&
+	    ((mac_rp == sky2->check.mac_rp &&
+	      mac_lev != 0 && mac_lev >= sky2->check.mac_lev) ||
+	     /* Check if the PCI RX hang */
+	     (fifo_rp == sky2->check.fifo_rp &&
+	      fifo_lev != 0 && fifo_lev >= sky2->check.fifo_lev))) {
+		printk(KERN_DEBUG PFX "%s: hung mac %d:%d fifo %d (%d:%d)\n",
+		       dev->name, mac_lev, mac_rp, fifo_lev, fifo_rp,
+		       sky2_read8(hw, Q_ADDR(rxq, Q_WP)));
+		return 1;
+	} else {
+		sky2->check.last = dev->last_rx;
+		sky2->check.mac_rp = mac_rp;
+		sky2->check.mac_lev = mac_lev;
+		sky2->check.fifo_rp = fifo_rp;
+		sky2->check.fifo_lev = fifo_lev;
+		return 0;
+	}
+}
+
 static void sky2_watchdog(unsigned long arg)
 {
 	struct sky2_hw *hw = (struct sky2_hw *) arg;
+	struct net_device *dev;
 
+	/* Check for lost IRQ once a second */
 	if (sky2_read32(hw, B0_ISRC)) {
-		struct net_device *dev = hw->dev[0];
-
+		dev = hw->dev[0];
 		if (__netif_rx_schedule_prep(dev))
 			__netif_rx_schedule(dev);
+	} else {
+		int i, active = 0;
+
+		for (i = 0; i < hw->ports; i++) {
+			dev = hw->dev[i];
+			if (!netif_running(dev))
+				continue;
+			++active;
+
+			/* For chips with Rx FIFO, check if stuck */
+			if ((hw->flags & SKY2_HW_RAMBUFFER) &&
+			     sky2_rx_hung(dev)) {
+				pr_info(PFX "%s: receiver hang detected\n",
+					dev->name);
+				schedule_work(&hw->restart_work);
+				return;
+			}
+		}
+
+		if (active == 0)
+			return;
 	}
 
-	if (hw->active > 0)
-		mod_timer(&hw->watchdog_timer, round_jiffies(jiffies + HZ));
+	mod_timer(&hw->watchdog_timer, round_jiffies(jiffies + HZ));
 }
 
 /* Hardware/software error handling */
@@ -2546,17 +2636,25 @@ static void sky2_netpoll(struct net_device *dev)
 #endif
 
 /* Chip internal frequency for clock calculations */
-static inline u32 sky2_mhz(const struct sky2_hw *hw)
+static u32 sky2_mhz(const struct sky2_hw *hw)
 {
 	switch (hw->chip_id) {
 	case CHIP_ID_YUKON_EC:
 	case CHIP_ID_YUKON_EC_U:
 	case CHIP_ID_YUKON_EX:
-		return 125;	/* 125 Mhz */
+		return 125;
+
 	case CHIP_ID_YUKON_FE:
-		return 100;	/* 100 Mhz */
-	default:		/* YUKON_XL */
-		return 156;	/* 156 Mhz */
+		return 100;
+
+	case CHIP_ID_YUKON_FE_P:
+		return 50;
+
+	case CHIP_ID_YUKON_XL:
+		return 156;
+
+	default:
+		BUG();
 	}
 }
 
@@ -2581,23 +2679,62 @@ static int __devinit sky2_init(struct sky2_hw *hw)
 	sky2_write8(hw, B0_CTST, CS_RST_CLR);
 
 	hw->chip_id = sky2_read8(hw, B2_CHIP_ID);
-	if (hw->chip_id < CHIP_ID_YUKON_XL || hw->chip_id > CHIP_ID_YUKON_FE) {
+	hw->chip_rev = (sky2_read8(hw, B2_MAC_CFG) & CFG_CHIP_R_MSK) >> 4;
+
+	switch(hw->chip_id) {
+	case CHIP_ID_YUKON_XL:
+		hw->flags = SKY2_HW_GIGABIT
+			| SKY2_HW_NEWER_PHY
+			| SKY2_HW_RAMBUFFER;
+		break;
+
+	case CHIP_ID_YUKON_EC_U:
+		hw->flags = SKY2_HW_GIGABIT
+			| SKY2_HW_NEWER_PHY
+			| SKY2_HW_ADV_POWER_CTL;
+		break;
+
+	case CHIP_ID_YUKON_EX:
+		hw->flags = SKY2_HW_GIGABIT
+			| SKY2_HW_NEWER_PHY
+			| SKY2_HW_NEW_LE
+			| SKY2_HW_ADV_POWER_CTL;
+
+		/* New transmit checksum */
+		if (hw->chip_rev != CHIP_REV_YU_EX_B0)
+			hw->flags |= SKY2_HW_AUTO_TX_SUM;
+		break;
+
+	case CHIP_ID_YUKON_EC:
+		/* This rev is really old, and requires untested workarounds */
+		if (hw->chip_rev == CHIP_REV_YU_EC_A1) {
+			dev_err(&hw->pdev->dev, "unsupported revision Yukon-EC rev A1\n");
+			return -EOPNOTSUPP;
+		}
+		hw->flags = SKY2_HW_GIGABIT | SKY2_HW_RAMBUFFER;
+		break;
+
+	case CHIP_ID_YUKON_FE:
+		hw->flags = SKY2_HW_RAMBUFFER;
+		break;
+
+	case CHIP_ID_YUKON_FE_P:
+		hw->flags = SKY2_HW_NEWER_PHY
+			| SKY2_HW_NEW_LE
+			| SKY2_HW_AUTO_TX_SUM
+			| SKY2_HW_ADV_POWER_CTL;
+		break;
+	default:
 		dev_err(&hw->pdev->dev, "unsupported chip type 0x%x\n",
 			hw->chip_id);
 		return -EOPNOTSUPP;
 	}
 
-	hw->chip_rev = (sky2_read8(hw, B2_MAC_CFG) & CFG_CHIP_R_MSK) >> 4;
+	hw->pmd_type = sky2_read8(hw, B2_PMD_TYP);
+	if (hw->pmd_type == 'L' || hw->pmd_type == 'S' || hw->pmd_type == 'P')
+		hw->flags |= SKY2_HW_FIBRE_PHY;
 
-	/* This rev is really old, and requires untested workarounds */
-	if (hw->chip_id == CHIP_ID_YUKON_EC && hw->chip_rev == CHIP_REV_YU_EC_A1) {
-		dev_err(&hw->pdev->dev, "unsupported revision Yukon-%s (0x%x) rev %d\n",
-			yukon2_name[hw->chip_id - CHIP_ID_YUKON_XL],
-			hw->chip_id, hw->chip_rev);
-		return -EOPNOTSUPP;
-	}
 
-	hw->pmd_type = sky2_read8(hw, B2_PMD_TYP);
 	hw->ports = 1;
 	t8 = sky2_read8(hw, B2_Y2_HW_RES);
 	if ((t8 & CFG_DUAL_MAC_MSK) == CFG_DUAL_MAC_MSK) {
@@ -2791,7 +2928,9 @@ static int sky2_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 
 	sky2->wol = wol->wolopts;
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX)
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U ||
+	    hw->chip_id == CHIP_ID_YUKON_EX ||
+	    hw->chip_id == CHIP_ID_YUKON_FE_P)
 		sky2_write32(hw, B0_CTST, sky2->wol
 			     ? Y2_HW_WOL_ON : Y2_HW_WOL_OFF);
 
@@ -2809,7 +2948,7 @@ static u32 sky2_supported_modes(const struct sky2_hw *hw)
 			| SUPPORTED_100baseT_Full
 			| SUPPORTED_Autoneg | SUPPORTED_TP;
 
-		if (hw->chip_id != CHIP_ID_YUKON_FE)
+		if (hw->flags & SKY2_HW_GIGABIT)
 			modes |= SUPPORTED_1000baseT_Half
 				| SUPPORTED_1000baseT_Full;
 		return modes;
@@ -2829,13 +2968,6 @@ static int sky2_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	ecmd->supported = sky2_supported_modes(hw);
 	ecmd->phy_address = PHY_ADDR_MARV;
 	if (sky2_is_copper(hw)) {
-		ecmd->supported = SUPPORTED_10baseT_Half
-		    | SUPPORTED_10baseT_Full
-		    | SUPPORTED_100baseT_Half
-		    | SUPPORTED_100baseT_Full
-		    | SUPPORTED_1000baseT_Half
-		    | SUPPORTED_1000baseT_Full
-		    | SUPPORTED_Autoneg | SUPPORTED_TP;
 		ecmd->port = PORT_TP;
 		ecmd->speed = sky2->speed;
 	} else {
@@ -3791,6 +3923,13 @@ static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 	sky2->hw = hw;
 	sky2->msg_enable = netif_msg_init(debug, default_msg);
 
+	/* This chip has hardware problems that generates
+	 * bogus PHY receive status so by default shut up the message.
+	 */
+	if (hw->chip_id == CHIP_ID_YUKON_FE_P &&
+	    hw->chip_rev == CHIP_REV_YU_FE2_A0)
+		sky2->msg_enable &= ~NETIF_MSG_RX_ERR;
+
 	/* Auto speed and flow control */
 	sky2->autoneg = AUTONEG_ENABLE;
 	sky2->flow_mode = FC_BOTH;
@@ -3846,7 +3985,7 @@ static irqreturn_t __devinit sky2_test_intr(int irq, void *dev_id)
 		return IRQ_NONE;
 
 	if (status & Y2_IS_IRQ_SW) {
-		hw->msi = 1;
+		hw->flags |= SKY2_HW_USE_MSI;
 		wake_up(&hw->msi_wait);
 		sky2_write8(hw, B0_CTST, CS_CL_SW_IRQ);
 	}
@@ -3874,9 +4013,9 @@ static int __devinit sky2_test_msi(struct sky2_hw *hw)
 	sky2_write8(hw, B0_CTST, CS_ST_SW_IRQ);
 	sky2_read8(hw, B0_CTST);
 
-	wait_event_timeout(hw->msi_wait, hw->msi, HZ/10);
+	wait_event_timeout(hw->msi_wait, (hw->flags & SKY2_HW_USE_MSI), HZ/10);
 
-	if (!hw->msi) {
+	if (!(hw->flags & SKY2_HW_USE_MSI)) {
 		/* MSI test failed, go back to INTx mode */
 		dev_info(&pdev->dev, "No interrupt generated using MSI, "
 			 "switching to INTx mode.\n");
@@ -4009,7 +4148,8 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 		goto err_out_free_netdev;
 	}
 
-	err = request_irq(pdev->irq,  sky2_intr, hw->msi ? 0 : IRQF_SHARED,
+	err = request_irq(pdev->irq, sky2_intr,
+			  (hw->flags & SKY2_HW_USE_MSI) ? 0 : IRQF_SHARED,
 			  dev->name, hw);
 	if (err) {
 		dev_err(&pdev->dev, "cannot assign irq %d\n", pdev->irq);
@@ -4042,7 +4182,7 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 	return 0;
 
 err_out_unregister:
-	if (hw->msi)
+	if (hw->flags & SKY2_HW_USE_MSI)
 		pci_disable_msi(pdev);
 	unregister_netdev(dev);
 err_out_free_netdev:
@@ -4091,7 +4231,7 @@ static void __devexit sky2_remove(struct pci_dev *pdev)
 	sky2_read8(hw, B0_CTST);
 
 	free_irq(pdev->irq, hw);
-	if (hw->msi)
+	if (hw->flags & SKY2_HW_USE_MSI)
 		pci_disable_msi(pdev);
 	pci_free_consistent(pdev, STATUS_LE_BYTES, hw->st_le, hw->st_dma);
 	pci_release_regions(pdev);
@@ -4159,7 +4299,9 @@ static int sky2_resume(struct pci_dev *pdev)
 	pci_enable_wake(pdev, PCI_D0, 0);
 
 	/* Re-enable all clocks */
-	if (hw->chip_id == CHIP_ID_YUKON_EX || hw->chip_id == CHIP_ID_YUKON_EC_U)
+	if (hw->chip_id == CHIP_ID_YUKON_EX ||
+	    hw->chip_id == CHIP_ID_YUKON_EC_U ||
+	    hw->chip_id == CHIP_ID_YUKON_FE_P)
 		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
 
 	sky2_reset(hw);
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 72e12b7..69cd984 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -470,18 +470,24 @@ enum {
 	CHIP_ID_YUKON_EX   = 0xb5, /* Chip ID for YUKON-2 Extreme */
 	CHIP_ID_YUKON_EC   = 0xb6, /* Chip ID for YUKON-2 EC */
  	CHIP_ID_YUKON_FE   = 0xb7, /* Chip ID for YUKON-2 FE */
-
+ 	CHIP_ID_YUKON_FE_P = 0xb8, /* Chip ID for YUKON-2 FE+ */
+};
+enum yukon_ec_rev {
 	CHIP_REV_YU_EC_A1    = 0,  /* Chip Rev. for Yukon-EC A1/A0 */
 	CHIP_REV_YU_EC_A2    = 1,  /* Chip Rev. for Yukon-EC A2 */
 	CHIP_REV_YU_EC_A3    = 2,  /* Chip Rev. for Yukon-EC A3 */
-
+};
+enum yukon_ec_u_rev {
 	CHIP_REV_YU_EC_U_A0  = 1,
 	CHIP_REV_YU_EC_U_A1  = 2,
 	CHIP_REV_YU_EC_U_B0  = 3,
-
+};
+enum yukon_fe_rev {
 	CHIP_REV_YU_FE_A1    = 1,
 	CHIP_REV_YU_FE_A2    = 2,
-
+};
+enum yukon_fe_p_rev {
+	CHIP_REV_YU_FE2_A0   = 0,
 };
 enum yukon_ex_rev {
 	CHIP_REV_YU_EX_A0    = 1,
@@ -1668,7 +1674,7 @@ enum {
 
 /* Receive Frame Status Encoding */
 enum {
-	GMR_FS_LEN	= 0xffff<<16, /* Bit 31..16:	Rx Frame Length */
+	GMR_FS_LEN	= 0x7fff<<16, /* Bit 30..16:	Rx Frame Length */
 	GMR_FS_VLAN	= 1<<13, /* VLAN Packet */
 	GMR_FS_JABBER	= 1<<12, /* Jabber Packet */
 	GMR_FS_UN_SIZE	= 1<<11, /* Undersize Packet */
@@ -1729,6 +1735,10 @@ enum {
 	GMF_RX_CTRL_DEF	= GMF_OPER_ON | GMF_RX_F_FL_ON,
 };
 
+/*	TX_GMF_EA		32 bit	Tx GMAC FIFO End Address */
+enum {
+	TX_DYN_WM_ENA	= 3,	/* Yukon-FE+ specific */
+};
 
 /*	TX_GMF_CTRL_T	32 bit	Tx GMAC FIFO Control/Test */
 enum {
@@ -2017,6 +2027,14 @@ struct sky2_port {
 	u16		     rx_tag;
 	struct vlan_group    *vlgrp;
 #endif
+	struct {
+		unsigned long last;
+		u32	mac_rp;
+		u8	mac_lev;
+		u8	fifo_rp;
+		u8	fifo_lev;
+	} check;
+
 
 	dma_addr_t	     rx_le_map;
 	dma_addr_t	     tx_le_map;
@@ -2040,12 +2058,20 @@ struct sky2_hw {
 	void __iomem  	     *regs;
 	struct pci_dev	     *pdev;
 	struct net_device    *dev[2];
+	unsigned long	     flags;
+#define SKY2_HW_USE_MSI		0x00000001
+#define SKY2_HW_FIBRE_PHY	0x00000002
+#define SKY2_HW_GIGABIT		0x00000004
+#define SKY2_HW_NEWER_PHY	0x00000008
+#define SKY2_HW_RAMBUFFER	0x00000010	/* chip has RAM FIFO */
+#define SKY2_HW_NEW_LE		0x00000020	/* new LSOv2 format */
+#define SKY2_HW_AUTO_TX_SUM	0x00000040	/* new IP decode for Tx */
+#define SKY2_HW_ADV_POWER_CTL	0x00000080	/* additional PHY power regs */
 
 	u8	     	     chip_id;
 	u8		     chip_rev;
 	u8		     pmd_type;
 	u8		     ports;
-	u8		     active;
 
 	struct sky2_status_le *st_le;
 	u32		     st_idx;
@@ -2053,13 +2079,12 @@ struct sky2_hw {
 
 	struct timer_list    watchdog_timer;
 	struct work_struct   restart_work;
-	int		     msi;
 	wait_queue_head_t    msi_wait;
 };
 
 static inline int sky2_is_copper(const struct sky2_hw *hw)
 {
-	return !(hw->pmd_type == 'L' || hw->pmd_type == 'S' || hw->pmd_type == 'P');
+	return !(hw->flags & SKY2_HW_FIBRE_PHY);
 }
 
 /* Register accessor for memory mapped device */
