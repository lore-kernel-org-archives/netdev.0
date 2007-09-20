From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/6] sky2: reorganize chip revision features
Date: Wed, 19 Sep 2007 22:06:02 -0700
Message-ID: <20070920050700.441110105@linux-foundation.org>
References: <20070920050559.763089637@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzk <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51268 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752151AbXITFH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 01:07:57 -0400
Content-Disposition: inline; filename=sky2-flags.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch should cause no functional changes in driver behaviour.
There are (too) many revisions of the Yukon 2 chip now. Instead of
adding more conditionals based on chip revision; rerganize into a
set of feature flags so adding new versions is less problematic.


Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-09-19 21:57:42.000000000 -0700
+++ b/drivers/net/sky2.c	2007-09-19 21:57:59.000000000 -0700
@@ -222,8 +222,7 @@ static void sky2_power_on(struct sky2_hw
 	else
 		sky2_write8(hw, B2_Y2_CLK_GATE, 0);
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U ||
-	    hw->chip_id == CHIP_ID_YUKON_EX) {
+	if (hw->flags & SKY2_HW_ADV_POWER_CTL) {
 		struct pci_dev *pdev = hw->pdev;
 		u32 reg;
 
@@ -317,10 +316,8 @@ static void sky2_phy_init(struct sky2_hw
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
@@ -353,9 +350,7 @@ static void sky2_phy_init(struct sky2_hw
 
 			/* downshift on PHY 88E1112 and 88E1149 is changed */
 			if (sky2->autoneg == AUTONEG_ENABLE
-			    && (hw->chip_id == CHIP_ID_YUKON_XL
-				|| hw->chip_id == CHIP_ID_YUKON_EC_U
-				|| hw->chip_id == CHIP_ID_YUKON_EX)) {
+			    && (hw->flags & SKY2_HW_NEWER_PHY)) {
 				/* set downshift counter to 3x and enable downshift */
 				ctrl &= ~PHY_M_PC_DSC_MSK;
 				ctrl |= PHY_M_PC_DSC(2) | PHY_M_PC_DOWN_S_ENA;
@@ -371,7 +366,7 @@ static void sky2_phy_init(struct sky2_hw
 	gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
 
 	/* special setup for PHY 88E1112 Fiber */
-	if (hw->chip_id == CHIP_ID_YUKON_XL && !sky2_is_copper(hw)) {
+	if (hw->chip_id == CHIP_ID_YUKON_XL && (hw->flags & SKY2_HW_FIBRE_PHY)) {
 		pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
 
 		/* Fiber: select 1000BASE-X only mode MAC Specific Ctrl Reg. */
@@ -815,7 +810,7 @@ static void sky2_mac_init(struct sky2_hw
 	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_CLR);
 	sky2_write16(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_OPER_ON);
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX) {
+	if (!(hw->flags & SKY2_HW_RAMBUFFER)) {
 		sky2_write8(hw, SK_REG(port, RX_GMF_LP_THR), 768/8);
 		sky2_write8(hw, SK_REG(port, RX_GMF_UP_THR), 1024/8);
 
@@ -994,19 +989,15 @@ static void sky2_rx_unmap_skb(struct pci
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
@@ -1202,7 +1193,8 @@ static int sky2_rx_start(struct sky2_por
 
 	sky2_prefetch_init(hw, rxq, sky2->rx_le_map, RX_LE_SIZE - 1);
 
-	rx_set_checksum(sky2);
+	if (!(hw->flags & SKY2_HW_NEW_LE))
+		rx_set_checksum(sky2);
 
 	/* Space needed for frame data + headers rounded up */
 	size = roundup(sky2->netdev->mtu + ETH_HLEN + VLAN_HLEN, 8);
@@ -1273,7 +1265,7 @@ static int sky2_up(struct net_device *de
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
-	u32 ramsize, imask;
+	u32 imask;
 	int cap, err = -ENOMEM;
 	struct net_device *otherdev = hw->dev[sky2->port^1];
 
@@ -1328,13 +1320,13 @@ static int sky2_up(struct net_device *de
 
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
@@ -1467,13 +1459,15 @@ static int sky2_xmit_frame(struct sk_buf
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
@@ -1499,8 +1493,7 @@ static int sky2_xmit_frame(struct sk_buf
 	/* Handle TCP checksum offload */
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		/* On Yukon EX (some versions) encoding change. */
- 		if (hw->chip_id == CHIP_ID_YUKON_EX
-		    && hw->chip_rev != CHIP_REV_YU_EX_B0)
+ 		if (hw->flags & SKY2_HW_AUTO_TX_SUM)
  			ctrl |= CALSUM;	/* auto checksum */
 		else {
 			const unsigned offset = skb_transport_offset(skb);
@@ -1741,7 +1734,7 @@ static int sky2_down(struct net_device *
 
 static u16 sky2_phy_speed(const struct sky2_hw *hw, u16 aux)
 {
-	if (!sky2_is_copper(hw))
+	if (hw->flags & SKY2_HW_FIBRE_PHY)
 		return SPEED_1000;
 
 	if (!sky2_is_gigabit(hw)) {
@@ -1790,9 +1783,7 @@ static void sky2_link_up(struct sky2_por
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG),
 		    LINKLED_ON | LINKLED_BLINK_OFF | LINKLED_LINKSYNC_OFF);
 
-	if (hw->chip_id == CHIP_ID_YUKON_XL
-	    || hw->chip_id == CHIP_ID_YUKON_EC_U
-	    || hw->chip_id == CHIP_ID_YUKON_EX) {
+	if (hw->flags & SKY2_HW_NEWER_PHY) {
 		u16 pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
 		u16 led = PHY_M_LEDC_LOS_CTRL(1);	/* link active */
 
@@ -1884,7 +1875,7 @@ static int sky2_autoneg_done(struct sky2
 	/* Since the pause result bits seem to in different positions on
 	 * different chips. look at registers.
 	 */
-	if (!sky2_is_copper(hw)) {
+	if (hw->flags & SKY2_HW_FIBRE_PHY) {
 		/* Shift for bits in fiber PHY */
 		advert &= ~(ADVERTISE_PAUSE_CAP|ADVERTISE_PAUSE_ASYM);
 		lpa &= ~(LPA_PAUSE_CAP|LPA_PAUSE_ASYM);
@@ -2627,24 +2618,55 @@ static int __devinit sky2_init(struct sk
 	sky2_write8(hw, B0_CTST, CS_RST_CLR);
 
 	hw->chip_id = sky2_read8(hw, B2_CHIP_ID);
-	if (hw->chip_id < CHIP_ID_YUKON_XL ||
-	    hw->chip_id > CHIP_ID_YUKON_FE_P) {
-		dev_err(&hw->pdev->dev, "unsupported chip type 0x%x\n",
-			hw->chip_id);
-		return -EOPNOTSUPP;
-	}
-
 	hw->chip_rev = (sky2_read8(hw, B2_MAC_CFG) & CFG_CHIP_R_MSK) >> 4;
 
-	/* This rev is really old, and requires untested workarounds */
-	if (hw->chip_id == CHIP_ID_YUKON_EC && hw->chip_rev == CHIP_REV_YU_EC_A1) {
-		dev_err(&hw->pdev->dev, "unsupported revision Yukon-%s (0x%x) rev %d\n",
-			yukon2_name[hw->chip_id - CHIP_ID_YUKON_XL],
-			hw->chip_id, hw->chip_rev);
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
+	default:
+		dev_err(&hw->pdev->dev, "unsupported chip type 0x%x\n",
+			hw->chip_id);
 		return -EOPNOTSUPP;
 	}
 
 	hw->pmd_type = sky2_read8(hw, B2_PMD_TYP);
+	if (hw->pmd_type == 'L' || hw->pmd_type == 'S' || hw->pmd_type == 'P')
+		hw->flags |= SKY2_HW_FIBRE_PHY;
+
 	hw->ports = 1;
 	t8 = sky2_read8(hw, B2_Y2_HW_RES);
 	if ((t8 & CFG_DUAL_MAC_MSK) == CFG_DUAL_MAC_MSK) {
@@ -2860,7 +2882,7 @@ static u32 sky2_supported_modes(const st
 			| SUPPORTED_100baseT_Full
 			| SUPPORTED_Autoneg | SUPPORTED_TP;
 
-		if (hw->chip_id != CHIP_ID_YUKON_FE)
+		if (hw->flags & SKY2_HW_GIGABIT)
 			modes |= SUPPORTED_1000baseT_Half
 				| SUPPORTED_1000baseT_Full;
 		return modes;
@@ -3880,7 +3902,7 @@ static irqreturn_t __devinit sky2_test_i
 		return IRQ_NONE;
 
 	if (status & Y2_IS_IRQ_SW) {
-		hw->msi = 1;
+		hw->flags |= SKY2_HW_USE_MSI;
 		wake_up(&hw->msi_wait);
 		sky2_write8(hw, B0_CTST, CS_CL_SW_IRQ);
 	}
@@ -3908,9 +3930,9 @@ static int __devinit sky2_test_msi(struc
 	sky2_write8(hw, B0_CTST, CS_ST_SW_IRQ);
 	sky2_read8(hw, B0_CTST);
 
-	wait_event_timeout(hw->msi_wait, hw->msi, HZ/10);
+	wait_event_timeout(hw->msi_wait, (hw->flags & SKY2_HW_USE_MSI), HZ/10);
 
-	if (!hw->msi) {
+	if (!(hw->flags & SKY2_HW_USE_MSI)) {
 		/* MSI test failed, go back to INTx mode */
 		dev_info(&pdev->dev, "No interrupt generated using MSI, "
 			 "switching to INTx mode.\n");
@@ -4043,7 +4065,8 @@ static int __devinit sky2_probe(struct p
 		goto err_out_free_netdev;
 	}
 
-	err = request_irq(pdev->irq,  sky2_intr, hw->msi ? 0 : IRQF_SHARED,
+	err = request_irq(pdev->irq, sky2_intr,
+			  (hw->flags & SKY2_HW_USE_MSI) ? 0 : IRQF_SHARED,
 			  dev->name, hw);
 	if (err) {
 		dev_err(&pdev->dev, "cannot assign irq %d\n", pdev->irq);
@@ -4076,7 +4099,7 @@ static int __devinit sky2_probe(struct p
 	return 0;
 
 err_out_unregister:
-	if (hw->msi)
+	if (hw->flags & SKY2_HW_USE_MSI)
 		pci_disable_msi(pdev);
 	unregister_netdev(dev);
 err_out_free_netdev:
@@ -4125,7 +4148,7 @@ static void __devexit sky2_remove(struct
 	sky2_read8(hw, B0_CTST);
 
 	free_irq(pdev->irq, hw);
-	if (hw->msi)
+	if (hw->flags & SKY2_HW_USE_MSI)
 		pci_disable_msi(pdev);
 	pci_free_consistent(pdev, STATUS_LE_BYTES, hw->st_le, hw->st_dma);
 	pci_release_regions(pdev);
--- a/drivers/net/sky2.h	2007-09-19 21:57:42.000000000 -0700
+++ b/drivers/net/sky2.h	2007-09-19 21:57:42.000000000 -0700
@@ -2028,6 +2028,15 @@ struct sky2_hw {
 	struct pci_dev	     *pdev;
 	struct napi_struct   napi;
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
@@ -2041,13 +2050,12 @@ struct sky2_hw {
 
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
 
 static inline int sky2_is_gigabit(const struct sky2_hw *hw)

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

