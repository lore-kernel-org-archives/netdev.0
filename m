From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 06/10] ixgbe: Move PHY ops initialization to centralize bus
	accesses
Date: Fri, 10 Apr 2009 01:27:57 -0700
Message-ID: <20090410082757.14372.49418.stgit@localhost.localdomain>
References: <20090410082618.14372.86091.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:40053 "EHLO
	QMTA03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S938583AbZDJQ4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2009 12:56:25 -0400
In-Reply-To: <20090410082618.14372.86091.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

When PHY operations are determined, the PHY must be identified.  This
identification causes bus access, and should be contained within its own
routines.  This also helps the 82599 PHY init paths for both SFP+ and
KX/KX4 devices to be easier to maintain.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c |   77 ++++++++++++++++++++++++++-------------
 drivers/net/ixgbe/ixgbe_82599.c |   70 +++++++++++++++++++++++------------
 drivers/net/ixgbe/ixgbe_main.c  |    9 ++++-
 drivers/net/ixgbe/ixgbe_type.h  |    1 +
 4 files changed, 107 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 6e2a837..2400fcf 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -75,18 +75,49 @@ static u16 ixgbe_get_pcie_msix_count_82598(struct ixgbe_hw *hw)
 static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw)
 {
 	struct ixgbe_mac_info *mac = &hw->mac;
+
+	/* Call PHY identify routine to get the phy type */
+	ixgbe_identify_phy_generic(hw);
+
+	mac->mcft_size = IXGBE_82598_MC_TBL_SIZE;
+	mac->vft_size = IXGBE_82598_VFT_TBL_SIZE;
+	mac->num_rar_entries = IXGBE_82598_RAR_ENTRIES;
+	mac->max_rx_queues = IXGBE_82598_MAX_RX_QUEUES;
+	mac->max_tx_queues = IXGBE_82598_MAX_TX_QUEUES;
+	mac->max_msix_vectors = ixgbe_get_pcie_msix_count_82598(hw);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_init_phy_ops_82598 - PHY/SFP specific init
+ *  @hw: pointer to hardware structure
+ *
+ *  Initialize any function pointers that were not able to be
+ *  set during get_invariants because the PHY/SFP type was
+ *  not known.  Perform the SFP init if necessary.
+ *
+ **/
+s32 ixgbe_init_phy_ops_82598(struct ixgbe_hw *hw)
+{
+	struct ixgbe_mac_info *mac = &hw->mac;
 	struct ixgbe_phy_info *phy = &hw->phy;
 	s32 ret_val = 0;
 	u16 list_offset, data_offset;
 
-	/* Set the bus information prior to PHY identification */
-	mac->ops.get_bus_info(hw);
+	/* Identify the PHY */
+	phy->ops.identify(hw);
 
-	/* Call PHY identify routine to get the phy type */
-	ixgbe_identify_phy_generic(hw);
+	/* Overwrite the link function pointers if copper PHY */
+	if (mac->ops.get_media_type(hw) == ixgbe_media_type_copper) {
+		mac->ops.setup_link = &ixgbe_setup_copper_link_82598;
+		mac->ops.setup_link_speed =
+		                     &ixgbe_setup_copper_link_speed_82598;
+		mac->ops.get_link_capabilities =
+		                  &ixgbe_get_copper_link_capabilities_82598;
+	}
 
-	/* PHY Init */
-	switch (phy->type) {
+	switch (hw->phy.type) {
 	case ixgbe_phy_tn:
 		phy->ops.check_link = &ixgbe_check_phy_link_tnx;
 		phy->ops.get_firmware_version =
@@ -106,8 +137,8 @@ static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw)
 
 		/* Check to see if SFP+ module is supported */
 		ret_val = ixgbe_get_sfp_init_sequence_offsets(hw,
-		                                              &list_offset,
-		                                              &data_offset);
+		                                            &list_offset,
+		                                            &data_offset);
 		if (ret_val != 0) {
 			ret_val = IXGBE_ERR_SFP_NOT_SUPPORTED;
 			goto out;
@@ -117,21 +148,6 @@ static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw)
 		break;
 	}
 
-	if (mac->ops.get_media_type(hw) == ixgbe_media_type_copper) {
-		mac->ops.setup_link = &ixgbe_setup_copper_link_82598;
-		mac->ops.setup_link_speed =
-		                     &ixgbe_setup_copper_link_speed_82598;
-		mac->ops.get_link_capabilities =
-		                     &ixgbe_get_copper_link_capabilities_82598;
-	}
-
-	mac->mcft_size = IXGBE_82598_MC_TBL_SIZE;
-	mac->vft_size = IXGBE_82598_VFT_TBL_SIZE;
-	mac->num_rar_entries = IXGBE_82598_RAR_ENTRIES;
-	mac->max_rx_queues = IXGBE_82598_MAX_RX_QUEUES;
-	mac->max_tx_queues = IXGBE_82598_MAX_TX_QUEUES;
-	mac->max_msix_vectors = ixgbe_get_pcie_msix_count_82598(hw);
-
 out:
 	return ret_val;
 }
@@ -719,14 +735,23 @@ static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw)
 	}
 
 	/* Reset PHY */
-	if (hw->phy.reset_disable == false)
+	if (hw->phy.reset_disable == false) {
+		/* PHY ops must be identified and initialized prior to reset */
+
+		/* Init PHY and function pointers, perform SFP setup */
+		status = hw->phy.ops.init(hw);
+		if (status == IXGBE_ERR_SFP_NOT_SUPPORTED)
+			goto reset_hw_out;
+
 		hw->phy.ops.reset(hw);
+	}
 
 	/*
 	 * Prevent the PCI-E bus from from hanging by disabling PCI-E master
 	 * access and verify no pending requests before reset
 	 */
-	if (ixgbe_disable_pcie_master(hw) != 0) {
+	status = ixgbe_disable_pcie_master(hw);
+	if (status != 0) {
 		status = IXGBE_ERR_MASTER_REQUESTS_PENDING;
 		hw_dbg(hw, "PCI-E Master disable polling has failed.\n");
 	}
@@ -773,6 +798,7 @@ static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw)
 	/* Store the permanent mac address */
 	hw->mac.ops.get_mac_addr(hw, hw->mac.perm_addr);
 
+reset_hw_out:
 	return status;
 }
 
@@ -1102,6 +1128,7 @@ static struct ixgbe_eeprom_operations eeprom_ops_82598 = {
 static struct ixgbe_phy_operations phy_ops_82598 = {
 	.identify		= &ixgbe_identify_phy_generic,
 	.identify_sfp		= &ixgbe_identify_sfp_module_generic,
+	.init			= &ixgbe_init_phy_ops_82598,
 	.reset			= &ixgbe_reset_phy_generic,
 	.read_reg		= &ixgbe_read_phy_reg_generic,
 	.write_reg		= &ixgbe_write_phy_reg_generic,
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 29771fb..35689d8 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -146,51 +146,60 @@ u32 ixgbe_get_pcie_msix_count_82599(struct ixgbe_hw *hw)
 static s32 ixgbe_get_invariants_82599(struct ixgbe_hw *hw)
 {
 	struct ixgbe_mac_info *mac = &hw->mac;
-	struct ixgbe_phy_info *phy = &hw->phy;
-	s32 ret_val;
 
-	/* Set the bus information prior to PHY identification */
-	mac->ops.get_bus_info(hw);
+	ixgbe_init_mac_link_ops_82599(hw);
 
-	/* Call PHY identify routine to get the Cu or SFI phy type */
-	ret_val = phy->ops.identify(hw);
+	mac->mcft_size = IXGBE_82599_MC_TBL_SIZE;
+	mac->vft_size = IXGBE_82599_VFT_TBL_SIZE;
+	mac->num_rar_entries = IXGBE_82599_RAR_ENTRIES;
+	mac->max_rx_queues = IXGBE_82599_MAX_RX_QUEUES;
+	mac->max_tx_queues = IXGBE_82599_MAX_TX_QUEUES;
+	mac->max_msix_vectors = ixgbe_get_pcie_msix_count_82599(hw);
 
-	if (ret_val == IXGBE_ERR_SFP_NOT_SUPPORTED)
-		goto get_invariants_out;
+	return 0;
+}
 
-	ixgbe_init_mac_link_ops_82599(hw);
+/**
+ *  ixgbe_init_phy_ops_82599 - PHY/SFP specific init
+ *  @hw: pointer to hardware structure
+ *
+ *  Initialize any function pointers that were not able to be
+ *  set during get_invariants because the PHY/SFP type was
+ *  not known.  Perform the SFP init if necessary.
+ *
+ **/
+s32 ixgbe_init_phy_ops_82599(struct ixgbe_hw *hw)
+{
+	struct ixgbe_mac_info *mac = &hw->mac;
+	struct ixgbe_phy_info *phy = &hw->phy;
+	s32 ret_val = 0;
 
-	/* Setup SFP module if there is one present. */
-	ret_val = mac->ops.setup_sfp(hw);
+	/* Identify the PHY or SFP module */
+	ret_val = phy->ops.identify(hw);
+
+	/* Setup function pointers based on detected SFP module and speeds */
+	ixgbe_init_mac_link_ops_82599(hw);
 
 	/* If copper media, overwrite with copper function pointers */
 	if (mac->ops.get_media_type(hw) == ixgbe_media_type_copper) {
 		mac->ops.setup_link = &ixgbe_setup_copper_link_82599;
 		mac->ops.setup_link_speed =
-		                  &ixgbe_setup_copper_link_speed_82599;
+		                     &ixgbe_setup_copper_link_speed_82599;
 		mac->ops.get_link_capabilities =
 		                  &ixgbe_get_copper_link_capabilities_82599;
 	}
 
-	/* PHY Init */
+	/* Set necessary function pointers based on phy type */
 	switch (hw->phy.type) {
 	case ixgbe_phy_tn:
 		phy->ops.check_link = &ixgbe_check_phy_link_tnx;
 		phy->ops.get_firmware_version =
-		                  &ixgbe_get_phy_firmware_version_tnx;
+		             &ixgbe_get_phy_firmware_version_tnx;
 		break;
 	default:
 		break;
 	}
 
-	mac->mcft_size = IXGBE_82599_MC_TBL_SIZE;
-	mac->vft_size = IXGBE_82599_VFT_TBL_SIZE;
-	mac->num_rar_entries = IXGBE_82599_RAR_ENTRIES;
-	mac->max_rx_queues = IXGBE_82599_MAX_RX_QUEUES;
-	mac->max_tx_queues = IXGBE_82599_MAX_TX_QUEUES;
-	mac->max_msix_vectors = ixgbe_get_pcie_msix_count_82599(hw);
-
-get_invariants_out:
 	return ret_val;
 }
 
@@ -706,13 +715,24 @@ s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 	hw->mac.ops.stop_adapter(hw);
 
 	/* Reset PHY */
-	hw->phy.ops.reset(hw);
+	if (hw->phy.reset_disable == false) {
+		/* PHY ops must be identified and initialized prior to reset */
+
+		/* Init PHY and function pointers, perform SFP setup */
+		status = hw->phy.ops.init(hw);
+
+		if (status == IXGBE_ERR_SFP_NOT_SUPPORTED)
+			goto reset_hw_out;
+
+		hw->phy.ops.reset(hw);
+	}
 
 	/*
 	 * Prevent the PCI-E bus from from hanging by disabling PCI-E master
 	 * access and verify no pending requests before reset
 	 */
-	if (ixgbe_disable_pcie_master(hw) != 0) {
+	status = ixgbe_disable_pcie_master(hw);
+	if (status != 0) {
 		status = IXGBE_ERR_MASTER_REQUESTS_PENDING;
 		hw_dbg(hw, "PCI-E Master disable polling has failed.\n");
 	}
@@ -773,6 +793,7 @@ s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 	/* Store the permanent mac address */
 	hw->mac.ops.get_mac_addr(hw, hw->mac.perm_addr);
 
+reset_hw_out:
 	return status;
 }
 
@@ -1236,6 +1257,7 @@ static struct ixgbe_eeprom_operations eeprom_ops_82599 = {
 static struct ixgbe_phy_operations phy_ops_82599 = {
 	.identify               = &ixgbe_identify_phy_82599,
 	.identify_sfp           = &ixgbe_identify_sfp_module_generic,
+	.init			= &ixgbe_init_phy_ops_82599,
 	.reset                  = &ixgbe_reset_phy_generic,
 	.read_reg               = &ixgbe_read_phy_reg_generic,
 	.write_reg              = &ixgbe_write_phy_reg_generic,
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 9ef128a..936a3ef 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4630,7 +4630,11 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	/* reset_hw fills in the perm_addr as well */
 	err = hw->mac.ops.reset_hw(hw);
-	if (err) {
+	if (err == IXGBE_ERR_SFP_NOT_SUPPORTED) {
+		dev_err(&adapter->pdev->dev, "failed to load because an "
+		        "unsupported SFP+ module type was detected.\n");
+		goto err_sw_init;
+	} else if (err) {
 		dev_err(&adapter->pdev->dev, "HW Init failed: %d\n", err);
 		goto err_sw_init;
 	}
@@ -4703,6 +4707,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	device_init_wakeup(&adapter->pdev->dev, true);
 	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
 
+	/* pick up the PCI bus settings for reporting later */
+	hw->mac.ops.get_bus_info(hw);
+
 	/* print bus type/speed/width info */
 	dev_info(&pdev->dev, "(PCI Express:%s:%s) %pM\n",
 	        ((hw->bus.speed == ixgbe_bus_speed_5000) ? "5.0Gb/s":
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 96e15d0..06d7e8a 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2150,6 +2150,7 @@ struct ixgbe_mac_operations {
 struct ixgbe_phy_operations {
 	s32 (*identify)(struct ixgbe_hw *);
 	s32 (*identify_sfp)(struct ixgbe_hw *);
+	s32 (*init)(struct ixgbe_hw *);
 	s32 (*reset)(struct ixgbe_hw *);
 	s32 (*read_reg)(struct ixgbe_hw *, u32, u32, u16 *);
 	s32 (*write_reg)(struct ixgbe_hw *, u32, u32, u16);

