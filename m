From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 19/19] e1000: major part of the new API changes
Date: Thu, 29 Mar 2007 09:40:38 -0700
Message-ID: <20070329164038.6595.18817.stgit@localhost.localdomain>
References: <20070329163304.6595.81963.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: auke-jan.h.kok@intel.com, bruce.w.allan@intel.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	cramerj@intel.com, john.ronciak@intel.com,
	arjan.van.de.ven@intel.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:46025 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030417AbXC2QlM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 12:41:12 -0400
In-Reply-To: <20070329163304.6595.81963.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeb Cramer <cramerj@intel.com>

The new hardware initialization code requires us to follow a slightly
different approach to setup the device. First the function pointers
have to be initialized for the proper hardware type, after which the
general initialization calls those in turn to do per-device specific
initialization.

Signed-off-by: Jeb Cramer <cramerj@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |   97 ++++++++++++++++++++++-
 drivers/net/e1000/e1000_main.c    |  155 ++++++++++++++++---------------------
 2 files changed, 160 insertions(+), 92 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 033cdb6..c26fdac 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -29,6 +29,7 @@
 /* ethtool support for e1000 */
 
 #include "e1000.h"
+#include "e1000_82541.h"
 
 #include <asm/uaccess.h>
 
@@ -1334,6 +1335,43 @@ e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 }
 
 static int
+e1000_set_82571_fiber_loopback(struct e1000_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 ctrl = E1000_READ_REG(hw, E1000_CTRL);
+	int link = 0;
+
+	/* special requirements for 82571/82572 fiber adapters */
+
+	/* jump through hoops to make sure link is up because serdes
+	 * link is hardwired up */
+	ctrl |= E1000_CTRL_SLU;
+	E1000_WRITE_REG(hw, E1000_CTRL, ctrl);
+
+	/* disable autoneg */
+	ctrl = E1000_READ_REG(hw, E1000_TXCW);
+	ctrl &= ~(1 << 31);
+	E1000_WRITE_REG(hw, E1000_TXCW, ctrl);
+
+	link = (E1000_READ_REG(hw, E1000_STATUS) & E1000_STATUS_LU);
+
+	if (!link) {
+		/* set invert loss of signal */
+		ctrl = E1000_READ_REG(hw, E1000_CTRL);
+		ctrl |= E1000_CTRL_ILOS;
+		E1000_WRITE_REG(hw, E1000_CTRL, ctrl);
+	}
+
+	/* special write to serdes control register to enable SerDes analog
+	 * loopback */
+#define E1000_SERDES_LB_ON 0x410
+	E1000_WRITE_REG(hw, E1000_SCTL, E1000_SERDES_LB_ON);
+	msleep(10);
+
+	return 0;
+}
+
+static int
 e1000_set_phy_loopback(struct e1000_adapter *adapter)
 {
 	uint16_t phy_reg = 0;
@@ -1385,6 +1423,42 @@ e1000_set_phy_loopback(struct e1000_adapter *adapter)
 	return 8;
 }
 
+/* only call this for fiber/serdes connections to es2lan */
+static int
+e1000_set_es2lan_mac_loopback(struct e1000_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 ctrlext = E1000_READ_REG(hw, E1000_CTRL_EXT);
+	u32 ctrl = E1000_READ_REG(hw, E1000_CTRL);
+
+	/* save CTRL_EXT to restore later, reuse an empty variable (unused
+	   on mac_type 80003es2lan) */
+	adapter->tx_fifo_head = ctrlext;
+
+	/* clear the serdes mode bits, putting the device into mac loopback */
+	ctrlext &= ~E1000_CTRL_EXT_LINK_MODE_PCIE_SERDES;
+	E1000_WRITE_REG(hw, E1000_CTRL_EXT, ctrlext);
+
+	/* force speed to 1000/FD, link up */
+	ctrl &= ~(E1000_CTRL_SPD_1000 | E1000_CTRL_SPD_100);
+	ctrl |= (E1000_CTRL_SLU | E1000_CTRL_FRCSPD | E1000_CTRL_FRCDPX |
+	         E1000_CTRL_SPD_1000 | E1000_CTRL_FD);
+	E1000_WRITE_REG(hw, E1000_CTRL, ctrl);
+
+	/* set mac loopback */
+	ctrl = E1000_READ_REG(hw, E1000_RCTL);
+	ctrl |= E1000_RCTL_LBM_MAC;
+	E1000_WRITE_REG(hw, E1000_RCTL, ctrl);
+
+	/* set testing mode parameters (no need to reset later) */
+#define KMRNCTRLSTA_OPMODE (0x1F << 16)
+#define KMRNCTRLSTA_OPMODE_1GB_FD_GMII 0x0582
+	E1000_WRITE_REG(hw, E1000_KMRNCTRLSTA,
+		(KMRNCTRLSTA_OPMODE | KMRNCTRLSTA_OPMODE_1GB_FD_GMII));
+
+	return 0;
+}
+
 static int
 e1000_setup_loopback_test(struct e1000_adapter *adapter)
 {
@@ -1394,6 +1468,9 @@ e1000_setup_loopback_test(struct e1000_adapter *adapter)
 	if (hw->media_type == e1000_media_type_fiber ||
 	    hw->media_type == e1000_media_type_internal_serdes) {
 		switch (hw->mac.type) {
+		case e1000_80003es2lan:
+			return e1000_set_es2lan_mac_loopback(adapter);
+			break;
 		case e1000_82545:
 		case e1000_82546:
 		case e1000_82545_rev_3:
@@ -1402,11 +1479,7 @@ e1000_setup_loopback_test(struct e1000_adapter *adapter)
 			break;
 		case e1000_82571:
 		case e1000_82572:
-#define E1000_SERDES_LB_ON 0x410
-			e1000_set_phy_loopback(adapter);
-			E1000_WRITE_REG(hw, E1000_SCTL, E1000_SERDES_LB_ON);
-			msleep(10);
-			return 0;
+			return e1000_set_82571_fiber_loopback(adapter);
 			break;
 		default:
 			rctl = E1000_READ_REG(hw, E1000_RCTL);
@@ -1432,6 +1505,14 @@ e1000_loopback_cleanup(struct e1000_adapter *adapter)
 	E1000_WRITE_REG(hw, E1000_RCTL, rctl);
 
 	switch (hw->mac.type) {
+	case e1000_80003es2lan:
+		if (hw->media_type == e1000_media_type_fiber ||
+		    hw->media_type == e1000_media_type_internal_serdes) {
+			/* restore CTRL_EXT, stealing space from tx_fifo_head */
+			E1000_WRITE_REG(hw, E1000_CTRL_EXT, adapter->tx_fifo_head);
+			adapter->tx_fifo_head = 0;
+		}
+		/* fall through */
 	case e1000_82571:
 	case e1000_82572:
 		if (hw->media_type == e1000_media_type_fiber ||
@@ -1595,7 +1676,7 @@ e1000_link_test(struct e1000_adapter *adapter, uint64_t *data)
 		*data = 1;
 	} else {
 		e1000_check_for_link(&adapter->hw);
-		if (adapter->hw.mac.autoneg)  /* if auto_neg is set wait for it */
+		if (adapter->hw.mac.autoneg)
 			msleep(4000);
 
 		if (!(E1000_READ_REG(&adapter->hw, E1000_STATUS) & E1000_STATUS_LU)) {
@@ -1666,7 +1747,11 @@ e1000_diag_test(struct net_device *netdev,
 		adapter->hw.mac.forced_speed_duplex = forced_speed_duplex;
 		adapter->hw.mac.autoneg = autoneg;
 
+		/* force this routine to wait until autoneg complete/timeout */
+		adapter->hw.phy.wait_for_link = TRUE;
 		e1000_reset(adapter);
+		adapter->hw.phy.wait_for_link = FALSE;
+
 		clear_bit(__E1000_TESTING, &adapter->flags);
 		if (if_running)
 			dev_open(netdev);
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index ecc41b7..13292a0 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -974,6 +974,31 @@ e1000_probe(struct pci_dev *pdev,
 			goto err_flashmap;
 	}
 
+	if ((err = e1000_init_mac_params(&adapter->hw)))
+		goto err_hw_init;
+
+	if ((err = e1000_init_nvm_params(&adapter->hw)))
+		goto err_hw_init;
+
+	if ((err = e1000_init_phy_params(&adapter->hw)))
+		goto err_hw_init;
+
+	e1000_get_bus_info(&adapter->hw);
+
+	e1000_init_script_state_82541(&adapter->hw, TRUE);
+	e1000_set_tbi_compatibility_82543(&adapter->hw, TRUE);
+
+	adapter->hw.phy.wait_for_link = FALSE;
+	adapter->hw.mac.adaptive_ifs = TRUE;
+
+	/* Copper options */
+
+	if (adapter->hw.media_type == e1000_media_type_copper) {
+		adapter->hw.phy.mdix = AUTO_ALL_MODES;
+		adapter->hw.phy.disable_polarity_correction = FALSE;
+		adapter->hw.phy.ms_type = e1000_ms_hw_default;
+	}
+
 	if (e1000_check_reset_block(&adapter->hw))
 		DPRINTK(PROBE, INFO, "PHY reset is blocked due to SOL/IDER session.\n");
 
@@ -1018,13 +1043,6 @@ e1000_probe(struct pci_dev *pdev,
 
 	adapter->en_mng_pt = e1000_enable_mng_pass_thru(&adapter->hw);
 
-	/* initialize eeprom parameters */
-
-	if (e1000_init_eeprom_params(&adapter->hw)) {
-		E1000_ERR("EEPROM initialization failed\n");
-		goto err_eeprom;
-	}
-
 	/* before reading the NVM, reset the controller to
 	 * put the device in a known good starting state */
 
@@ -1051,8 +1069,6 @@ e1000_probe(struct pci_dev *pdev,
 		goto err_eeprom;
 	}
 
-	e1000_get_bus_info(&adapter->hw);
-
 	init_timer(&adapter->tx_fifo_stall_timer);
 	adapter->tx_fifo_stall_timer.function = &e1000_82547_tx_fifo_stall;
 	adapter->tx_fifo_stall_timer.data = (unsigned long) adapter;
@@ -1183,6 +1199,7 @@ e1000_probe(struct pci_dev *pdev,
 	return 0;
 
 err_register:
+err_hw_init:
 	e1000_release_hw_control(adapter);
 err_eeprom:
 	if (!e1000_check_reset_block(&adapter->hw))
@@ -1190,6 +1207,8 @@ err_eeprom:
 
 	if (adapter->hw.flash_address)
 		iounmap(adapter->hw.flash_address);
+
+	e1000_remove_device(&adapter->hw);
 err_flashmap:
 #ifdef CONFIG_E1000_NAPI
 	for (i = 0; i < adapter->num_rx_queues; i++)
@@ -1300,38 +1319,12 @@ e1000_sw_init(struct e1000_adapter *adapter)
 	hw->mac.max_frame_size = netdev->mtu + ETH_HLEN + ETHERNET_FCS_SIZE;
 	hw->mac.min_frame_size = ETH_ZLEN + ETHERNET_FCS_SIZE;
 
-	/* identify the MAC */
-
-	if (e1000_set_mac_type(hw)) {
-		DPRINTK(PROBE, ERR, "Unknown MAC Type\n");
+	/* Initialize the hardware-specific values */
+	if (e1000_setup_init_funcs(hw, FALSE)) {
+		DPRINTK(PROBE, ERR, "Hardware Initialization Failure\n");
 		return -EIO;
 	}
 
-	switch (hw->mac_type) {
-	default:
-		break;
-	case e1000_82541:
-	case e1000_82547:
-	case e1000_82541_rev_2:
-	case e1000_82547_rev_2:
-		hw->phy_init_script = 1;
-		break;
-	}
-
-	e1000_set_media_type(hw);
-
-	hw->wait_autoneg_complete = FALSE;
-	hw->tbi_compatibility_en = TRUE;
-	hw->adaptive_ifs = TRUE;
-
-	/* Copper options */
-
-	if (hw->media_type == e1000_media_type_copper) {
-		hw->mdix = AUTO_ALL_MODES;
-		hw->disable_polarity_correction = FALSE;
-		hw->master_slave = E1000_MASTER_SLAVE;
-	}
-
 	adapter->num_tx_queues = 1;
 	adapter->num_rx_queues = 1;
 
@@ -1355,7 +1348,6 @@ e1000_sw_init(struct e1000_adapter *adapter)
 	spin_lock_init(&adapter->stats_lock);
 
 	set_bit(__E1000_DOWN, &adapter->flags);
-
 	return 0;
 }
 
@@ -1918,7 +1910,7 @@ e1000_setup_rctl(struct e1000_adapter *adapter)
 		E1000_RCTL_LBM_NO | E1000_RCTL_RDMTS_HALF |
 		(adapter->hw.mac.mc_filter_type << E1000_RCTL_MO_SHIFT);
 
-	if (adapter->hw.tbi_compatibility_on == 1)
+	if (e1000_tbi_sbp_enabled_82543(&adapter->hw))
 		rctl |= E1000_RCTL_SBP;
 	else
 		rctl &= ~E1000_RCTL_SBP;
@@ -2458,19 +2450,9 @@ e1000_set_multi(struct net_device *netdev)
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_mac_info *mac = &hw->mac;
 	struct dev_mc_list *mc_ptr;
+	uint8_t *mta_list;
 	uint32_t rctl;
-	uint32_t hash_value;
-	int i, rar_entries = E1000_RAR_ENTRIES;
-	int mta_reg_count = (hw->mac_type == e1000_ich8lan) ?
-				E1000_NUM_MTA_REGISTERS_ICH8LAN :
-				E1000_NUM_MTA_REGISTERS;
-
-	if (adapter->hw.mac.type == e1000_ich8lan)
-		rar_entries = E1000_RAR_ENTRIES_ICH8LAN;
-
-	/* reserve RAR[14] for LAA over-write work-around */
-	if (adapter->hw.mac.type == e1000_82571)
-		rar_entries--;
+	int i;
 
 	/* Check for Promiscuous and All Multicast modes */
 
@@ -2492,40 +2474,25 @@ e1000_set_multi(struct net_device *netdev)
 	if (hw->mac.type == e1000_82542)
 		e1000_enter_82542_rst(adapter);
 
-	/* load the first 14 multicast address into the exact filters 1-14
-	 * RAR 0 is used for the station MAC adddress
-	 * if there are not 14 addresses, go ahead and clear the filters
-	 * -- with 82571 controllers only 0-13 entries are filled here
-	 */
-	mc_ptr = netdev->mc_list;
-
-	for (i = 1; i < rar_entries; i++) {
-		if (mc_ptr) {
-			e1000_rar_set(hw, mc_ptr->dmi_addr, i);
-			mc_ptr = mc_ptr->next;
-		} else {
-			E1000_WRITE_REG_ARRAY(hw, E1000_RA, i << 1, 0);
-			E1000_WRITE_FLUSH(hw);
-			E1000_WRITE_REG_ARRAY(hw, E1000_RA, (i << 1) + 1, 0);
-			E1000_WRITE_FLUSH(hw);
-		}
-	}
+	mta_list = kmalloc(netdev->mc_count * 6, GFP_ATOMIC);
+	if (!mta_list)
+		return;
 
-	/* clear the old settings from the multicast hash table */
+	/* The shared function expects a packed array of only addresses. */
+	mc_ptr = netdev->mc_list;
 
-	for (i = 0; i < mta_reg_count; i++) {
-		E1000_WRITE_REG_ARRAY(hw, E1000_MTA, i, 0);
-		E1000_WRITE_FLUSH(hw);
+	for (i = 0; i < netdev->mc_count; i++) {
+		if (!mc_ptr)
+			break;
+		memcpy(mta_list + (i*ETH_ALEN), mc_ptr->dmi_addr, ETH_ALEN);
+		mc_ptr = mc_ptr->next;
 	}
 
-	/* load any remaining addresses into the hash table */
+	e1000_mc_addr_list_update(hw, mta_list, i, 1, mac->rar_entry_count);
 
-	for (; mc_ptr; mc_ptr = mc_ptr->next) {
-		hash_value = e1000_hash_mc_addr(hw, mc_ptr->dmi_addr);
-		e1000_mta_set(hw, hash_value);
-	}
+	kfree(mta_list);
 
-	if (hw->mac_type == e1000_82542)
+	if (hw->mac.type == e1000_82542)
 		e1000_leave_82542_rst(adapter);
 }
 
@@ -4960,12 +4927,6 @@ struct e1000_adapter *adapter = hw->back;
     return E1000_SUCCESS;
 }
 
-void
-e1000_io_write(struct e1000_hw *hw, unsigned long port, uint32_t value)
-{
-	outl(value, port);
-}
-
 static void
 e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 {
@@ -5360,4 +5321,26 @@ static void e1000_io_resume(struct pci_dev *pdev)
 
 }
 
+s32
+e1000_alloc_zeroed_dev_spec_struct(struct e1000_hw *hw, u32 size)
+{
+	hw->dev_spec = kmalloc(size, GFP_KERNEL);
+
+	if (!hw->dev_spec)
+		return -ENOMEM;
+
+	memset(hw->dev_spec, 0, size);
+
+	return E1000_SUCCESS;
+}
+
+void
+e1000_free_dev_spec_struct(struct e1000_hw *hw)
+{
+	if (!hw->dev_spec)
+		return;
+
+	kfree(hw->dev_spec);
+}
+
 /* e1000_main.c */
