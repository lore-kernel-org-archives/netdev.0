From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 11/26] atl1: refactor initialization and startup
Date: Mon, 31 Dec 2007 20:22:38 -0600
Message-ID: <1199154173-4058-12-git-send-email-jacliburn@bellsouth.net>
References: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Cc: Jay Cliburn <jacliburn@bellsouth.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost04.isp.att.net ([207.115.11.54]:49507 "EHLO
	fmailhost04.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753822AbYAACbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 21:31:46 -0500
In-Reply-To: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor atl1 initialization and startup to conform with the current
vendor driver version 1.2.40.2.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl1.c |  507 ++++++++++++++++++++++++-----------------------
 drivers/net/atlx/atl1.h |   10 +-
 drivers/net/atlx/atlx.c |    1 +
 drivers/net/atlx/atlx.h |   21 ++-
 4 files changed, 284 insertions(+), 255 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 31aad9f..e96f706 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -568,39 +568,6 @@ static u32 atl1_check_link(struct atl1_adapter *adapter)
 	return 0;
 }
 
-/*
- * atl1_change_mtu - Change the Maximum Transfer Unit
- * @netdev: network interface device structure
- * @new_mtu: new value for maximum frame size
- *
- * Returns 0 on success, negative on failure
- */
-static int atl1_change_mtu(struct net_device *netdev, int new_mtu)
-{
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-	int old_mtu = netdev->mtu;
-	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
-
-	if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
-	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		dev_warn(&adapter->pdev->dev, "invalid MTU setting\n");
-		return -EINVAL;
-	}
-
-	adapter->hw.max_frame_size = max_frame;
-	adapter->hw.tx_jumbo_task_th = (max_frame + 7) >> 3;
-	adapter->rx_buffer_len = (max_frame + 7) & ~7;
-	adapter->hw.rx_jumbo_th = adapter->rx_buffer_len / 8;
-
-	netdev->mtu = new_mtu;
-	if ((old_mtu != new_mtu) && netif_running(netdev)) {
-		atl1_down(adapter);
-		atl1_up(adapter);
-	}
-
-	return 0;
-}
-
 static void set_flow_ctrl_old(struct atl1_adapter *adapter)
 {
 	u32 hi, lo, value;
@@ -1043,6 +1010,7 @@ static void atl1_rx_checksum(struct atl1_adapter *adapter,
 static u16 atl1_alloc_rx_buffers(struct atl1_adapter *adapter)
 {
 	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
+	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	struct page *page;
 	unsigned long offset;
@@ -1052,7 +1020,7 @@ static u16 atl1_alloc_rx_buffers(struct atl1_adapter *adapter)
 	u16 rfd_next_to_use, next_next;
 	struct rx_free_desc *rfd_desc;
 
-	next_next = rfd_next_to_use = atomic_read(&rfd_ring->next_to_use);
+	next_next = rfd_next_to_use = (u16) atomic_read(&rfd_ring->next_to_use);
 	if (++next_next == rfd_ring->count)
 		next_next = 0;
 	buffer_info = &rfd_ring->buffer_info[rfd_next_to_use];
@@ -1079,7 +1047,7 @@ static u16 atl1_alloc_rx_buffers(struct atl1_adapter *adapter)
 		 * the 14 byte MAC header is removed
 		 */
 		skb_reserve(skb, NET_IP_ALIGN);
-
+		skb->dev = netdev;
 		buffer_info->alloced = 1;
 		buffer_info->skb = skb;
 		buffer_info->length = (u16) adapter->rx_buffer_len;
@@ -1767,28 +1735,6 @@ static void atl1_phy_config(unsigned long data)
 	spin_unlock_irqrestore(&adapter->lock, flags);
 }
 
-/*
- * Orphaned vendor comment left intact here:
- * <vendor comment>
- * If TPD Buffer size equal to 0, PCIE DMAR_TO_INT
- * will assert. We do soft reset <0x1400=1> according
- * with the SPEC. BUT, it seemes that PCIE or DMA
- * state-machine will not be reset. DMAR_TO_INT will
- * assert again and again.
- * </vendor comment>
- */
-static void atl1_tx_timeout_task(struct work_struct *work)
-{
-	struct atl1_adapter *adapter =
-		container_of(work, struct atl1_adapter, tx_timeout_task);
-	struct net_device *netdev = adapter->netdev;
-
-	netif_device_detach(netdev);
-	atl1_down(adapter);
-	atl1_up(adapter);
-	netif_device_attach(netdev);
-}
-
 int atl1_reset(struct atl1_adapter *adapter)
 {
 	int ret;
@@ -1798,48 +1744,40 @@ int atl1_reset(struct atl1_adapter *adapter)
 	return atl1_init_hw(&adapter->hw);
 }
 
-s32 atl1_up(struct atl1_adapter *adapter)
+static s32 atl1_up(struct atl1_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	int err;
-	int irq_flags = IRQF_SAMPLE_RANDOM;
+	u32 retval;
 
 	/* hardware has been reset, we need to reload some things */
+	err = atl1_init_hw(&adapter->hw);
+	if (err) {
+		err = -EIO;
+		return err;
+	}
+
 	atlx_set_multi(netdev);
 	atl1_init_ring_ptrs(adapter);
 	atlx_restore_vlan(adapter);
 	err = atl1_alloc_rx_buffers(adapter);
 	if (unlikely(!err))
-		/* no RX BUFFER allocated */
+		/* no rx buffer allocated */
 		return -ENOMEM;
 
 	if (unlikely(atl1_configure(adapter))) {
 		err = -EIO;
-		goto err_up;
-	}
-
-	err = pci_enable_msi(adapter->pdev);
-	if (err) {
-		dev_info(&adapter->pdev->dev,
-			"Unable to enable MSI: %d\n", err);
-		irq_flags |= IRQF_SHARED;
+		return err;
 	}
 
-	err = request_irq(adapter->pdev->irq, &atl1_intr, irq_flags,
-			netdev->name, netdev);
-	if (unlikely(err))
-		goto err_up;
-
-	mod_timer(&adapter->watchdog_timer, jiffies);
+	clear_bit(__ATL1_DOWN, &adapter->flags);
+	mod_timer(&adapter->watchdog_timer, jiffies + (4 * HZ));
+	retval = ioread32(&adapter->hw + REG_MASTER_CTRL);
+	retval |= MASTER_CTRL_MANUAL_INT;
+	iowrite32(retval, &adapter->hw + REG_MASTER_CTRL);
 	atlx_irq_enable(adapter);
-	atl1_check_link(adapter);
-	return 0;
 
-err_up:
-	pci_disable_msi(adapter->pdev);
-	/* free rx_buffers */
-	atl1_clean_rx_ring(adapter);
-	return err;
+	return 0;
 }
 
 void atl1_down(struct atl1_adapter *adapter)
@@ -1865,36 +1803,134 @@ void atl1_down(struct atl1_adapter *adapter)
 	atl1_clean_rx_ring(adapter);
 }
 
+static void atl1_tx_timeout_task(struct work_struct *work)
+{
+	struct atl1_adapter *adapter =
+		container_of(work, struct atl1_adapter, tx_timeout_task);
+	struct net_device *netdev = adapter->netdev;
+
+	netif_device_detach(netdev);
+	atl1_down(adapter);
+	atl1_up(adapter);
+	netif_device_attach(netdev);
+}
+
 /*
- * atl1_open - Called when a network interface is made active
+ * atl1_change_mtu - Change the Maximum Transfer Unit
  * @netdev: network interface device structure
+ * @new_mtu: new value for maximum frame size
  *
- * Returns 0 on success, negative value on failure
- *
- * The open entry point is called when a network interface is made
- * active by the system (IFF_UP).  At this point all resources needed
- * for transmit and receive operations are allocated, the interrupt
- * handler is registered with the OS, the watchdog timer is started,
- * and the stack is notified that the interface is ready.
+ * Returns 0 on success, negative on failure
+ */
+static int atl1_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	int old_mtu = netdev->mtu;
+	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
+
+	if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
+	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
+		dev_warn(&adapter->pdev->dev, "invalid MTU setting\n");
+		return -EINVAL;
+	}
+
+	adapter->hw.max_frame_size = max_frame;
+	adapter->hw.tx_jumbo_task_th = (max_frame + 7) >> 3;
+	adapter->rx_buffer_len = (max_frame + 7) & ~7;
+	adapter->hw.rx_jumbo_th = adapter->rx_buffer_len / 8;
+
+	netdev->mtu = new_mtu;
+	if ((old_mtu != new_mtu) && netif_running(netdev)) {
+		atl1_down(adapter);
+		atl1_up(adapter);
+	}
+
+	return 0;
+}
+
+static int atl1_request_irq(struct atl1_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	int flags, err;
+
+	flags = IRQF_SHARED;
+#ifdef CONFIG_PCI_MSI
+	adapter->have_msi = true;
+
+	err = pci_enable_msi(adapter->pdev);
+	if (err)
+		adapter->have_msi = false;
+
+	if (adapter->have_msi)
+		flags &= ~IRQF_SHARED;
+#endif
+
+	err = request_irq(adapter->pdev->irq, &atl1_intr, flags, netdev->name,
+		netdev);
+	if (err)
+		dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+			"unable to obtain irq: err = %d\n", err);
+
+	return err;
+}
+
+/*
+ * atl1_open - Called when a network interface is made active
+ * @netdev: network interface device structure
  */
 static int atl1_open(struct net_device *netdev)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
+	struct atl1_hw *hw = &adapter->hw;
 	int err;
+	u32 val;
+
+	if (test_bit(__ATL1_TESTING, &adapter->flags))
+		return -EBUSY;
 
 	/* allocate transmit descriptors */
 	err = atl1_setup_ring_resources(adapter);
 	if (err)
 		return err;
 
-	err = atl1_up(adapter);
+	err = atl1_init_hw(hw);
+	if (err) {
+		err = -EIO;
+		goto err_open;
+	}
+
+	atlx_set_multi(netdev);
+	atl1_init_ring_ptrs(adapter);
+	atlx_restore_vlan(adapter);
+
+	err = atl1_alloc_rx_buffers(adapter);
+	if (!err) {
+		err = -ENOMEM;
+		goto err_open;
+	}
+
+	err = atl1_configure(adapter);
+	if (err) {
+		err = -EIO;
+		goto err_open;
+	}
+
+	err = atl1_request_irq(adapter);
 	if (err)
-		goto err_up;
+		goto err_open;
+
+	clear_bit(__ATL1_DOWN, &adapter->flags);
+	mod_timer(&adapter->watchdog_timer, jiffies + (4 * HZ));
+	val = ioread32(hw->hw_addr + REG_MASTER_CTRL);
+	val |= MASTER_CTRL_MANUAL_INT;
+	iowrite32(val, hw->hw_addr + REG_MASTER_CTRL);
+	atlx_irq_enable(adapter);
 
 	return 0;
 
-err_up:
-	atl1_reset(adapter);
+err_open:
+	atl1_free_ring_resources(adapter);
+	atl1_reset_hw(hw);
 	return err;
 }
 
@@ -1937,7 +1973,6 @@ static int atl1_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	/* reduce speed to 10/100M */
 	if (wufc) {
-		atl1_phy_enter_power_saving(hw);
 		/* if resume, let driver to re- setup link */
 		hw->phy_configured = false;
 		atl1_set_mac_addr(hw);
@@ -2830,15 +2865,6 @@ s32 atl1_reset_hw(struct atl1_hw *hw)
 	int i;
 
 	/*
-	 * Clear Interrupt mask to stop board from generating
-	 * interrupts & Clear any pending interrupt events
-	 */
-	/*
-	 * iowrite32(0, hw->hw_addr + REG_IMR);
-	 * iowrite32(0xffffffff, hw->hw_addr + REG_ISR);
-	 */
-
-	/*
 	 * Issue Soft Reset to the MAC.  This will reset the chip's
 	 * transmit, receive, DMA.  It will not effect
 	 * the current PCI configuration.  The global reset bit is self-
@@ -2847,20 +2873,16 @@ s32 atl1_reset_hw(struct atl1_hw *hw)
 	iowrite32(MASTER_CTRL_SOFT_RST, hw->hw_addr + REG_MASTER_CTRL);
 	ioread32(hw->hw_addr + REG_MASTER_CTRL);
 
-	iowrite16(1, hw->hw_addr + REG_PHY_ENABLE);
-	ioread16(hw->hw_addr + REG_PHY_ENABLE);
-
 	/* delay about 1ms */
 	msleep(1);
 
-	/* Wait at least 10ms for All module to be Idle */
+	/* wait at least 10ms for idle */
 	for (i = 0; i < 10; i++) {
 		icr = ioread32(hw->hw_addr + REG_IDLE_STATUS);
 		if (!icr)
 			break;
 		/* delay 1 ms */
 		msleep(1);
-		/* FIXME: still the right way to do this? */
 		cpu_relax();
 	}
 
@@ -2880,6 +2902,7 @@ s32 atl1_reset_hw(struct atl1_hw *hw)
 static int atl1_check_eeprom_exist(struct atl1_hw *hw)
 {
 	u32 value;
+
 	value = ioread32(hw->hw_addr + REG_SPI_FLASH_CTRL);
 	if (value & SPI_FLASH_CTRL_EN_VPD) {
 		value &= ~SPI_FLASH_CTRL_EN_VPD;
@@ -3194,96 +3217,6 @@ s32 atl1_write_phy_reg(struct atl1_hw *hw, u32 reg_addr, u16 phy_data)
 }
 
 /*
- * Make L001's PHY out of Power Saving State (bug)
- * hw - Struct containing variables accessed by shared code
- * when power on, L001's PHY always on Power saving State
- * (Gigabit Link forbidden)
- */
-static s32 atl1_phy_leave_power_saving(struct atl1_hw *hw)
-{
-	s32 ret;
-	ret = atl1_write_phy_reg(hw, 29, 0x0029);
-	if (ret)
-		return ret;
-	return atl1_write_phy_reg(hw, 30, 0);
-}
-
-/*
- *TODO: do something or get rid of this
- */
-s32 atl1_phy_enter_power_saving(struct atl1_hw *hw)
-{
-/*    s32 ret_val;
- *    u16 phy_data;
- */
-
-/*
-    ret_val = atl1_write_phy_reg(hw, ...);
-    ret_val = atl1_write_phy_reg(hw, ...);
-    ....
-*/
-	return 0;
-}
-
-/*
- * Resets the PHY and make all config validate
- * hw - Struct containing variables accessed by shared code
- *
- * Sets bit 15 and 12 of the MII Control regiser (for F001 bug)
- */
-static s32 atl1_phy_reset(struct atl1_hw *hw)
-{
-	struct pci_dev *pdev = hw->back->pdev;
-	s32 ret_val;
-	u16 phy_data;
-
-	if (hw->media_type == MEDIA_TYPE_AUTO_SENSOR ||
-	    hw->media_type == MEDIA_TYPE_1000M_FULL)
-		phy_data = MII_CR_RESET | MII_CR_AUTO_NEG_EN;
-	else {
-		switch (hw->media_type) {
-		case MEDIA_TYPE_100M_FULL:
-			phy_data =
-			    MII_CR_FULL_DUPLEX | MII_CR_SPEED_100 |
-			    MII_CR_RESET;
-			break;
-		case MEDIA_TYPE_100M_HALF:
-			phy_data = MII_CR_SPEED_100 | MII_CR_RESET;
-			break;
-		case MEDIA_TYPE_10M_FULL:
-			phy_data =
-			    MII_CR_FULL_DUPLEX | MII_CR_SPEED_10 | MII_CR_RESET;
-			break;
-		default:
-			/* MEDIA_TYPE_10M_HALF: */
-			phy_data = MII_CR_SPEED_10 | MII_CR_RESET;
-			break;
-		}
-	}
-
-	ret_val = atl1_write_phy_reg(hw, MII_BMCR, phy_data);
-	if (ret_val) {
-		u32 val;
-		int i;
-		/* pcie serdes link may be down! */
-		dev_dbg(&pdev->dev, "pcie phy link down\n");
-
-		for (i = 0; i < 25; i++) {
-			msleep(1);
-			val = ioread32(hw->hw_addr + REG_MDIO_CTRL);
-			if (!(val & (MDIO_START | MDIO_BUSY)))
-				break;
-		}
-
-		if ((val & (MDIO_START | MDIO_BUSY)) != 0) {
-			dev_warn(&pdev->dev, "pcie link down at least 25ms\n");
-			return ret_val;
-		}
-	}
-	return 0;
-}
-
-/*
  * Configures PHY autoneg and flow control advertisement settings
  * hw - Struct containing variables accessed by shared code
  */
@@ -3318,26 +3251,31 @@ s32 atl1_phy_setup_autoneg_adv(struct atl1_hw *hw)
 					MII_AR_100TX_HD_CAPS |
 					MII_AR_100TX_FD_CAPS);
 		mii_1000t_ctrl_reg |= MII_ATLX_CR_1000T_FD_CAPS;
-		break;
-
-	case MEDIA_TYPE_1000M_FULL:
-		mii_1000t_ctrl_reg |= MII_ATLX_CR_1000T_FD_CAPS;
+		hw->autoneg_advertised = ADVERTISE_10_HALF |
+					ADVERTISE_10_FULL  |
+					ADVERTISE_100_HALF |
+					ADVERTISE_100_FULL |
+					ADVERTISE_1000_FULL;
 		break;
 
 	case MEDIA_TYPE_100M_FULL:
-		mii_autoneg_adv_reg |= MII_AR_100TX_FD_CAPS;
+		mii_1000t_ctrl_reg |= MII_AR_100TX_FD_CAPS;
+		hw->autoneg_advertised = ADVERTISE_100_FULL;
 		break;
 
 	case MEDIA_TYPE_100M_HALF:
 		mii_autoneg_adv_reg |= MII_AR_100TX_HD_CAPS;
+		hw->autoneg_advertised = ADVERTISE_100_HALF;
 		break;
 
 	case MEDIA_TYPE_10M_FULL:
 		mii_autoneg_adv_reg |= MII_AR_10T_FD_CAPS;
+		hw->autoneg_advertised = ADVERTISE_10_FULL;
 		break;
 
 	default:
 		mii_autoneg_adv_reg |= MII_AR_10T_HD_CAPS;
+		hw->autoneg_advertised = ADVERTISE_10_HALF;
 		break;
 	}
 
@@ -3358,38 +3296,6 @@ s32 atl1_phy_setup_autoneg_adv(struct atl1_hw *hw)
 	return 0;
 }
 
-/*
- * Configures link settings.
- * hw - Struct containing variables accessed by shared code
- * Assumes the hardware has previously been reset and the
- * transmitter and receiver are not enabled.
- */
-static s32 atl1_setup_link(struct atl1_hw *hw)
-{
-	struct pci_dev *pdev = hw->back->pdev;
-	s32 ret_val;
-
-	/*
-	 * Options:
-	 *  PHY will advertise value(s) parsed from
-	 *  autoneg_advertised and fc
-	 *  no matter what autoneg is , We will not wait link result.
-	 */
-	ret_val = atl1_phy_setup_autoneg_adv(hw);
-	if (ret_val) {
-		dev_dbg(&pdev->dev, "error setting up autonegotiation\n");
-		return ret_val;
-	}
-	/* SW.Reset , En-Auto-Neg if needed */
-	ret_val = atl1_phy_reset(hw);
-	if (ret_val) {
-		dev_dbg(&pdev->dev, "error resetting phy\n");
-		return ret_val;
-	}
-	hw->phy_configured = true;
-	return ret_val;
-}
-
 static void atl1_init_flash_opcode(struct atl1_hw *hw)
 {
 	if (hw->flash_vendor >= ARRAY_SIZE(flash_table))
@@ -3415,6 +3321,116 @@ static void atl1_init_flash_opcode(struct atl1_hw *hw)
 		hw->hw_addr + REG_SPI_FLASH_OP_READ);
 }
 
+static void atl1_init_pcie(struct atl1_hw *hw)
+{
+	u32 val;
+
+	val = LTSSM_TEST_MODE_DEF;
+	iowrite32(val, hw->hw_addr + REG_LTSSM_TEST_MODE);
+	val = ioread32(hw->hw_addr + REG_PCIE_PHY_MISC3);
+	val |= PCIE_PHY_MISC3_DS_PWR_DOWN;
+	iowrite32(val, hw->hw_addr + REG_PCIE_PHY_MISC3);
+}
+
+static bool atl1_check_cable(struct atl1_hw *hw)
+{
+	u16 pair_num;
+	u16 i;
+	u16 phy_val;
+
+	phy_val = 0x8000;
+	atl1_write_phy_reg(hw, MII_BMCR, phy_val);
+
+	for (pair_num = 0; pair_num < 4; pair_num++) {
+		phy_val = (u16) (pair_num << CDTC_PAIR_OFFSET);
+		phy_val |= CDTC_EN;
+		atl1_write_phy_reg(hw, MII_CDTC, phy_val);
+		for (i = 0; i < 200; i++) {
+			msleep(1);
+			atl1_read_phy_reg(hw, MII_CDTC, &phy_val);
+			if (!(phy_val & CDTC_EN))
+				break;
+		}
+		msleep(1);
+		atl1_read_phy_reg(hw, MII_CDTS, &phy_val);
+		if (((phy_val >> CDTS_STATUS_OFFSET) & 3) != CDTS_OPEN)
+			return true;
+	}
+	return false;
+}
+static s32 atl1_phy_commit(struct atl1_hw *hw)
+{
+	s32 retval;
+	u16 phy_data;
+	u32 val;
+	int i;
+
+	phy_data = MII_CR_RESET | MII_CR_AUTO_NEG_EN | MII_CR_RESTART_AUTO_NEG;
+	retval = atl1_write_phy_reg(hw, MII_BMCR, phy_data);
+	if (retval) {
+		for (i = 0; i < 25; i++) {
+			msleep(1);
+			val = ioread32(hw->hw_addr + REG_MDIO_CTRL);
+			if (!(val & (MDIO_START | MDIO_BUSY)))
+				break;
+		}
+		if (val & (MDIO_START | MDIO_BUSY))
+			return retval;
+	}
+	return 0;
+}
+
+static s32 atl1_phy_init(struct atl1_hw *hw)
+{
+	u16 phy_data;
+	u16 i;
+	s32 retval;
+
+	if (hw->phy_configured)
+		return 0;
+
+	iowrite16(0, hw->hw_addr + REG_PHY_ENABLE);
+	msleep(2);
+	iowrite16(PHY_RESET, hw->hw_addr + REG_PHY_ENABLE);
+	msleep(2);
+
+	/* check for cable */
+	if (!atl1_check_cable(hw))
+		set_bit(0, &hw->force_ps);
+	else
+		clear_bit(0, &hw->force_ps);
+
+	/* enable PHY link change interrupt */
+	retval = atl1_write_phy_reg(hw, 18, 0xC00);
+	if (retval)
+		return retval;
+
+	/* setup autonegotiation parameters */
+	retval = atl1_phy_setup_autoneg_adv(hw);
+	if (retval)
+		return retval;
+
+	retval = atl1_phy_commit(hw);
+	if (retval)
+		return retval;
+
+	if (test_bit(0, &hw->force_ps)) {
+		atl1_write_phy_reg(hw, MII_DBG_ADDR, 0);
+		atl1_write_phy_reg(hw, MII_DBG_DATA, 0x124E);
+		atl1_write_phy_reg(hw, MII_DBG_ADDR, 1);
+		atl1_read_phy_reg(hw, MII_DBG_DATA, &phy_data);
+		phy_data |= 0x3;
+		atl1_write_phy_reg(hw, MII_DBG_DATA, phy_data);
+
+		for (i = 0; i < 15; i++)
+			msleep(100);
+		atl1_write_phy_reg(hw, MII_DBG_ADDR, 0);
+		atl1_write_phy_reg(hw, MII_DBG_DATA, 0x024E);
+	}
+	hw->phy_configured = true;
+	return retval;
+}
+
 /*
  * Performs basic configuration of the adapter.
  * hw - Struct containing variables accessed by shared code
@@ -3425,28 +3441,15 @@ static void atl1_init_flash_opcode(struct atl1_hw *hw)
  */
 s32 atl1_init_hw(struct atl1_hw *hw)
 {
-	u32 ret_val = 0;
+	u32 retval = 0;
 
-	/* Zero out the Multicast HASH table */
+	atl1_init_pcie(hw);
 	iowrite32(0, hw->hw_addr + REG_RX_HASH_TABLE);
-	/* clear the old settings from the multicast hash table */
 	iowrite32(0, (hw->hw_addr + REG_RX_HASH_TABLE) + (1 << 2));
-
 	atl1_init_flash_opcode(hw);
+	retval = atl1_phy_init(hw);
 
-	if (!hw->phy_configured) {
-		/* enable GPHY LinkChange Interrrupt */
-		ret_val = atl1_write_phy_reg(hw, 18, 0xC00);
-		if (ret_val)
-			return ret_val;
-		/* make PHY out of power-saving state */
-		ret_val = atl1_phy_leave_power_saving(hw);
-		if (ret_val)
-			return ret_val;
-		/* Call a subroutine to configure the link */
-		ret_val = atl1_setup_link(hw);
-	}
-	return ret_val;
+	return retval;
 }
 
 /*
diff --git a/drivers/net/atlx/atl1.h b/drivers/net/atlx/atl1.h
index f50441b..c1b99f2 100644
--- a/drivers/net/atlx/atl1.h
+++ b/drivers/net/atlx/atl1.h
@@ -73,7 +73,6 @@ void atl1_check_options(struct atl1_adapter *adapter);
 static int atl1_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 	int cmd);
 static u32 atl1_check_link(struct atl1_adapter *adapter);
-s32 atl1_up(struct atl1_adapter *adapter);
 void atl1_down(struct atl1_adapter *adapter);
 int atl1_reset(struct atl1_adapter *adapter);
 
@@ -762,6 +761,7 @@ struct atl1_hw {
 	u8 perm_mac_addr[ETH_ALEN];
 
 	bool phy_configured;
+	unsigned long force_ps;
 };
 
 struct atl1_adapter {
@@ -801,9 +801,17 @@ struct atl1_adapter {
 
 	u32 bd_number;		/* board number */
 	bool pci_using_64;
+	bool have_msi;
 	struct atl1_hw hw;
 	struct atl1_smb smb;
 	struct atl1_cmb cmb;
+	unsigned long flags;
+};
+
+enum atl1_state {
+	__ATL1_TESTING,
+	__ATL1_RESETTING,
+	__ATL1_DOWN
 };
 
 #endif /* ATL1_H */
diff --git a/drivers/net/atlx/atlx.c b/drivers/net/atlx/atlx.c
index 4186326..354050f 100644
--- a/drivers/net/atlx/atlx.c
+++ b/drivers/net/atlx/atlx.c
@@ -157,6 +157,7 @@ static void atlx_set_multi(struct net_device *netdev)
  */
 static void atlx_irq_enable(struct atlx_adapter *adapter)
 {
+	iowrite32(0, adapter->hw.hw_addr + REG_IMR);
 	iowrite32(IMR_NORMAL_MASK, adapter->hw.hw_addr + REG_IMR);
 	ioread32(adapter->hw.hw_addr + REG_IMR);
 }
diff --git a/drivers/net/atlx/atlx.h b/drivers/net/atlx/atlx.h
index 43b8531..352432e 100644
--- a/drivers/net/atlx/atlx.h
+++ b/drivers/net/atlx/atlx.h
@@ -142,8 +142,11 @@ MODULE_VERSION(ATLX_DRIVER_VERSION);
 #define PCIE_DEV_MISC_CTRL_SERDES_ENDIAN	0x8
 #define PCIE_DEV_MISC_CTRL_SERDES_SEL_DIN	0x10
 
-#define REG_PCIE_PHYMISC		0x1000
-#define PCIE_PHYMISC_FORCE_RCV_DET	0x4
+#define REG_PCIE_PHY_MISC1		0x1000
+#define PCIE_PHY_MISC1_FORCE_RCV_DET	0x4
+
+#define REG_PCIE_PHY_MISC3		0x1008
+#define PCIE_PHY_MISC3_DS_PWR_DOWN	0x8000
 
 #define REG_PCIE_DLL_TX_CTRL1		0x1104
 #define PCIE_DLL_TX_CTRL1_SEL_NOR_CLK	0x400
@@ -170,6 +173,7 @@ MODULE_VERSION(ATLX_DRIVER_VERSION);
 #define REG_IRQ_MODU_TIMER_INIT		0x1408
 
 #define REG_PHY_ENABLE			0x140C
+#define PHY_RESET			0x1
 
 /* IRQ Anti-Lost Timer Initial Value Register */
 #define REG_CMBDISDMA_TIMER		0x140E
@@ -319,6 +323,10 @@ MODULE_VERSION(ATLX_DRIVER_VERSION);
 #define MII_ATLX_ESR			0x0F
 #define MII_ATLX_PSCR			0x10
 #define MII_ATLX_PSSR			0x11
+#define MII_DBG_ADDR			0x1D
+#define MII_DBG_DATA			0x1E
+#define MII_CDTC			0x16
+#define MII_CDTS			0x1C
 
 /* PHY Control Register */
 #define MII_CR_SPEED_SELECT_MSB		0x0040	/* bits 6,13: 10=1000, 01=100,
@@ -466,6 +474,15 @@ MODULE_VERSION(ATLX_DRIVER_VERSION);
 #define MII_ATLX_PSSR_100MBS		0x4000	/* 01=100Mbs */
 #define MII_ATLX_PSSR_1000MBS		0x8000	/* 10=1000Mbs */
 
+#define CDTC_EN				1
+#define CDTS_NORMAL			0
+#define CDTS_SHORT			1
+#define CDTS_OPEN			2
+#define CDTS_INVALID			3
+#define CDTC_PAIR_OFFSET		8
+#define CDTS_STATUS_OFFSET		8
+#define CDTS_RESULT_OFFSET		0
+
 /* PCI Command Register Bit Definitions */
 #define PCI_REG_COMMAND			0x04	/* PCI Command Register */
 #define CMD_IO_SPACE			0x0001
-- 
1.5.3.3

