From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/3] ixgbe: Add hardware specific initialization code
	for 82599 devices
Date: Fri, 27 Feb 2009 17:44:30 -0800
Message-ID: <20090228014430.22664.79867.stgit@lost.foo-projects.org>
References: <20090228013916.22664.54781.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:40213 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760992AbZB1Bot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 20:44:49 -0500
In-Reply-To: <20090228013916.22664.54781.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This patch adds the hardware initialization code specific to 82599.  This
is similar to the 82598 hardware initialization code.  It also includes all
changes to the existing hardware init code to support 82599.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c   |    7 
 drivers/net/ixgbe/ixgbe_82599.c   | 1277 +++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_common.c  |  319 +++++++++
 drivers/net/ixgbe/ixgbe_common.h  |   10 
 drivers/net/ixgbe/ixgbe_ethtool.c |    2 
 drivers/net/ixgbe/ixgbe_phy.c     |  590 +++++++++++++++++
 drivers/net/ixgbe/ixgbe_phy.h     |   16 
 drivers/net/ixgbe/ixgbe_type.h    |  766 +++++++++++++++++++++-
 8 files changed, 2928 insertions(+), 59 deletions(-)
 create mode 100644 drivers/net/ixgbe/ixgbe_82599.c

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 51dba1c..623737f 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -1046,9 +1046,9 @@ out:
  *
  *  Determines physical layer capabilities of the current configuration.
  **/
-static s32 ixgbe_get_supported_physical_layer_82598(struct ixgbe_hw *hw)
+static u32 ixgbe_get_supported_physical_layer_82598(struct ixgbe_hw *hw)
 {
-	s32 physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
+	u32 physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
 
 	switch (hw->device_id) {
 	case IXGBE_DEV_ID_82598:
@@ -1111,8 +1111,11 @@ static struct ixgbe_mac_operations mac_ops_82598 = {
 	.clear_hw_cntrs		= &ixgbe_clear_hw_cntrs_generic,
 	.get_media_type		= &ixgbe_get_media_type_82598,
 	.get_supported_physical_layer = &ixgbe_get_supported_physical_layer_82598,
+	.enable_rx_dma          = &ixgbe_enable_rx_dma_generic,
 	.get_mac_addr		= &ixgbe_get_mac_addr_generic,
 	.stop_adapter		= &ixgbe_stop_adapter_generic,
+	.get_bus_info           = &ixgbe_get_bus_info_generic,
+	.set_lan_id             = &ixgbe_set_lan_id_multi_port_pcie,
 	.read_analog_reg8	= &ixgbe_read_analog_reg8_82598,
 	.write_analog_reg8	= &ixgbe_write_analog_reg8_82598,
 	.setup_link		= &ixgbe_setup_mac_link_82598,
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
new file mode 100644
index 0000000..cc3bfa1
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -0,0 +1,1277 @@
+/*******************************************************************************
+
+  Intel 10 Gigabit PCI Express Linux driver
+  Copyright(c) 1999 - 2009 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#include <linux/pci.h>
+#include <linux/delay.h>
+#include <linux/sched.h>
+
+#include "ixgbe.h"
+#include "ixgbe_phy.h"
+
+#define IXGBE_82599_MAX_TX_QUEUES 128
+#define IXGBE_82599_MAX_RX_QUEUES 128
+#define IXGBE_82599_RAR_ENTRIES   128
+#define IXGBE_82599_MC_TBL_SIZE   128
+#define IXGBE_82599_VFT_TBL_SIZE  128
+
+s32 ixgbe_get_link_capabilities_82599(struct ixgbe_hw *hw,
+                                      ixgbe_link_speed *speed,
+                                      bool *autoneg);
+enum ixgbe_media_type ixgbe_get_media_type_82599(struct ixgbe_hw *hw);
+s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw);
+s32 ixgbe_setup_mac_link_speed_multispeed_fiber(struct ixgbe_hw *hw,
+                                     ixgbe_link_speed speed, bool autoneg,
+                                     bool autoneg_wait_to_complete);
+s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw);
+s32 ixgbe_check_mac_link_82599(struct ixgbe_hw *hw,
+                               ixgbe_link_speed *speed,
+                               bool *link_up, bool link_up_wait_to_complete);
+s32 ixgbe_setup_mac_link_speed_82599(struct ixgbe_hw *hw,
+                                     ixgbe_link_speed speed,
+                                     bool autoneg,
+                                     bool autoneg_wait_to_complete);
+static s32 ixgbe_get_copper_link_capabilities_82599(struct ixgbe_hw *hw,
+                                             ixgbe_link_speed *speed,
+                                             bool *autoneg);
+static s32 ixgbe_setup_copper_link_82599(struct ixgbe_hw *hw);
+static s32 ixgbe_setup_copper_link_speed_82599(struct ixgbe_hw *hw,
+                                               ixgbe_link_speed speed,
+                                               bool autoneg,
+                                               bool autoneg_wait_to_complete);
+s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw);
+s32 ixgbe_set_vmdq_82599(struct ixgbe_hw *hw, u32 rar, u32 vmdq);
+s32 ixgbe_clear_vmdq_82599(struct ixgbe_hw *hw, u32 rar, u32 vmdq);
+s32 ixgbe_set_vfta_82599(struct ixgbe_hw *hw, u32 vlan,
+                         u32 vind, bool vlan_on);
+s32 ixgbe_clear_vfta_82599(struct ixgbe_hw *hw);
+s32 ixgbe_blink_led_stop_82599(struct ixgbe_hw *hw, u32 index);
+s32 ixgbe_blink_led_start_82599(struct ixgbe_hw *hw, u32 index);
+s32 ixgbe_init_uta_tables_82599(struct ixgbe_hw *hw);
+s32 ixgbe_read_analog_reg8_82599(struct ixgbe_hw *hw, u32 reg, u8 *val);
+s32 ixgbe_write_analog_reg8_82599(struct ixgbe_hw *hw, u32 reg, u8 val);
+s32 ixgbe_start_hw_rev_0_82599(struct ixgbe_hw *hw);
+s32 ixgbe_identify_phy_82599(struct ixgbe_hw *hw);
+s32 ixgbe_start_hw_82599(struct ixgbe_hw *hw);
+u32 ixgbe_get_supported_physical_layer_82599(struct ixgbe_hw *hw);
+
+void ixgbe_init_mac_link_ops_82599(struct ixgbe_hw *hw)
+{
+	struct ixgbe_mac_info *mac = &hw->mac;
+	if (hw->phy.multispeed_fiber) {
+		/* Set up dual speed SFP+ support */
+		mac->ops.setup_link =
+		          &ixgbe_setup_mac_link_multispeed_fiber;
+		mac->ops.setup_link_speed =
+		          &ixgbe_setup_mac_link_speed_multispeed_fiber;
+	} else {
+		mac->ops.setup_link =
+		          &ixgbe_setup_mac_link_82599;
+		mac->ops.setup_link_speed =
+		          &ixgbe_setup_mac_link_speed_82599;
+	}
+}
+
+s32 ixgbe_setup_sfp_modules_82599(struct ixgbe_hw *hw)
+{
+	s32 ret_val = 0;
+	u16 list_offset, data_offset, data_value;
+
+	if (hw->phy.sfp_type != ixgbe_sfp_type_unknown) {
+		ixgbe_init_mac_link_ops_82599(hw);
+		ret_val = ixgbe_get_sfp_init_sequence_offsets(hw, &list_offset,
+		                                              &data_offset);
+
+		if (ret_val != 0)
+			goto setup_sfp_out;
+
+		hw->eeprom.ops.read(hw, ++data_offset, &data_value);
+		while (data_value != 0xffff) {
+			IXGBE_WRITE_REG(hw, IXGBE_CORECTL, data_value);
+			IXGBE_WRITE_FLUSH(hw);
+			hw->eeprom.ops.read(hw, ++data_offset, &data_value);
+		}
+		/* Now restart DSP */
+		IXGBE_WRITE_REG(hw, IXGBE_CORECTL, 0x00000102);
+		IXGBE_WRITE_REG(hw, IXGBE_CORECTL, 0x00000b1d);
+		IXGBE_WRITE_FLUSH(hw);
+	}
+
+setup_sfp_out:
+	return ret_val;
+}
+
+/**
+ *  ixgbe_get_pcie_msix_count_82599 - Gets MSI-X vector count
+ *  @hw: pointer to hardware structure
+ *
+ *  Read PCIe configuration space, and get the MSI-X vector count from
+ *  the capabilities table.
+ **/
+u32 ixgbe_get_pcie_msix_count_82599(struct ixgbe_hw *hw)
+{
+	struct ixgbe_adapter *adapter = hw->back;
+	u16 msix_count;
+	pci_read_config_word(adapter->pdev, IXGBE_PCIE_MSIX_82599_CAPS,
+	                     &msix_count);
+	msix_count &= IXGBE_PCIE_MSIX_TBL_SZ_MASK;
+
+	/* MSI-X count is zero-based in HW, so increment to give proper value */
+	msix_count++;
+
+	return msix_count;
+}
+
+static s32 ixgbe_get_invariants_82599(struct ixgbe_hw *hw)
+{
+	struct ixgbe_mac_info *mac = &hw->mac;
+	struct ixgbe_phy_info *phy = &hw->phy;
+	s32 ret_val;
+
+	/* Set the bus information prior to PHY identification */
+	mac->ops.get_bus_info(hw);
+
+	/* Call PHY identify routine to get the Cu or SFI phy type */
+	ret_val = phy->ops.identify(hw);
+
+	if (ret_val == IXGBE_ERR_SFP_NOT_SUPPORTED)
+		goto get_invariants_out;
+
+	ixgbe_init_mac_link_ops_82599(hw);
+
+	/* Setup SFP module if there is one present. */
+	ret_val = mac->ops.setup_sfp(hw);
+
+	/* If copper media, overwrite with copper function pointers */
+	if (mac->ops.get_media_type(hw) == ixgbe_media_type_copper) {
+		mac->ops.setup_link = &ixgbe_setup_copper_link_82599;
+		mac->ops.setup_link_speed =
+		                  &ixgbe_setup_copper_link_speed_82599;
+		mac->ops.get_link_capabilities =
+		                  &ixgbe_get_copper_link_capabilities_82599;
+	}
+
+	/* PHY Init */
+	switch (hw->phy.type) {
+	case ixgbe_phy_tn:
+		phy->ops.check_link = &ixgbe_check_phy_link_tnx;
+		phy->ops.get_firmware_version =
+		                  &ixgbe_get_phy_firmware_version_tnx;
+		break;
+	default:
+		break;
+	}
+
+	mac->mcft_size = IXGBE_82599_MC_TBL_SIZE;
+	mac->vft_size = IXGBE_82599_VFT_TBL_SIZE;
+	mac->num_rar_entries = IXGBE_82599_RAR_ENTRIES;
+	mac->max_rx_queues = IXGBE_82599_MAX_RX_QUEUES;
+	mac->max_tx_queues = IXGBE_82599_MAX_TX_QUEUES;
+	mac->max_msix_vectors = ixgbe_get_pcie_msix_count_82599(hw);
+
+get_invariants_out:
+	return ret_val;
+}
+
+/**
+ *  ixgbe_get_link_capabilities_82599 - Determines link capabilities
+ *  @hw: pointer to hardware structure
+ *  @speed: pointer to link speed
+ *  @negotiation: true when autoneg or autotry is enabled
+ *
+ *  Determines the link capabilities by reading the AUTOC register.
+ **/
+s32 ixgbe_get_link_capabilities_82599(struct ixgbe_hw *hw,
+                                      ixgbe_link_speed *speed,
+                                      bool *negotiation)
+{
+	s32 status = 0;
+
+	switch (hw->mac.orig_autoc & IXGBE_AUTOC_LMS_MASK) {
+	case IXGBE_AUTOC_LMS_1G_LINK_NO_AN:
+		*speed = IXGBE_LINK_SPEED_1GB_FULL;
+		*negotiation = false;
+		break;
+
+	case IXGBE_AUTOC_LMS_10G_LINK_NO_AN:
+		*speed = IXGBE_LINK_SPEED_10GB_FULL;
+		*negotiation = false;
+		break;
+
+	case IXGBE_AUTOC_LMS_1G_AN:
+		*speed = IXGBE_LINK_SPEED_1GB_FULL;
+		*negotiation = true;
+		break;
+
+	case IXGBE_AUTOC_LMS_10G_SERIAL:
+		*speed = IXGBE_LINK_SPEED_10GB_FULL;
+		*negotiation = false;
+		break;
+
+	case IXGBE_AUTOC_LMS_KX4_KX_KR:
+	case IXGBE_AUTOC_LMS_KX4_KX_KR_1G_AN:
+		*speed = IXGBE_LINK_SPEED_UNKNOWN;
+		if (hw->mac.orig_autoc & IXGBE_AUTOC_KR_SUPP)
+			*speed |= IXGBE_LINK_SPEED_10GB_FULL;
+		if (hw->mac.orig_autoc & IXGBE_AUTOC_KX4_SUPP)
+			*speed |= IXGBE_LINK_SPEED_10GB_FULL;
+		if (hw->mac.orig_autoc & IXGBE_AUTOC_KX_SUPP)
+			*speed |= IXGBE_LINK_SPEED_1GB_FULL;
+		*negotiation = true;
+		break;
+
+	case IXGBE_AUTOC_LMS_KX4_KX_KR_SGMII:
+		*speed = IXGBE_LINK_SPEED_100_FULL;
+		if (hw->mac.orig_autoc & IXGBE_AUTOC_KR_SUPP)
+			*speed |= IXGBE_LINK_SPEED_10GB_FULL;
+		if (hw->mac.orig_autoc & IXGBE_AUTOC_KX4_SUPP)
+			*speed |= IXGBE_LINK_SPEED_10GB_FULL;
+		if (hw->mac.orig_autoc & IXGBE_AUTOC_KX_SUPP)
+			*speed |= IXGBE_LINK_SPEED_1GB_FULL;
+		*negotiation = true;
+		break;
+
+	case IXGBE_AUTOC_LMS_SGMII_1G_100M:
+		*speed = IXGBE_LINK_SPEED_1GB_FULL | IXGBE_LINK_SPEED_100_FULL;
+		*negotiation = false;
+		break;
+
+	default:
+		status = IXGBE_ERR_LINK_SETUP;
+		goto out;
+		break;
+	}
+
+	if (hw->phy.multispeed_fiber) {
+		*speed |= IXGBE_LINK_SPEED_10GB_FULL |
+		          IXGBE_LINK_SPEED_1GB_FULL;
+		*negotiation = true;
+	}
+
+out:
+	return status;
+}
+
+/**
+ *  ixgbe_get_copper_link_capabilities_82599 - Determines link capabilities
+ *  @hw: pointer to hardware structure
+ *  @speed: pointer to link speed
+ *  @autoneg: boolean auto-negotiation value
+ *
+ *  Determines the link capabilities by reading the AUTOC register.
+ **/
+static s32 ixgbe_get_copper_link_capabilities_82599(struct ixgbe_hw *hw,
+                                                    ixgbe_link_speed *speed,
+                                                    bool *autoneg)
+{
+	s32 status = IXGBE_ERR_LINK_SETUP;
+	u16 speed_ability;
+
+	*speed = 0;
+	*autoneg = true;
+
+	status = hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_SPEED_ABILITY,
+	                              IXGBE_MDIO_PMA_PMD_DEV_TYPE,
+	                              &speed_ability);
+
+	if (status == 0) {
+		if (speed_ability & IXGBE_MDIO_PHY_SPEED_10G)
+		    *speed |= IXGBE_LINK_SPEED_10GB_FULL;
+		if (speed_ability & IXGBE_MDIO_PHY_SPEED_1G)
+		    *speed |= IXGBE_LINK_SPEED_1GB_FULL;
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_get_media_type_82599 - Get media type
+ *  @hw: pointer to hardware structure
+ *
+ *  Returns the media type (fiber, copper, backplane)
+ **/
+enum ixgbe_media_type ixgbe_get_media_type_82599(struct ixgbe_hw *hw)
+{
+	enum ixgbe_media_type media_type;
+
+	/* Detect if there is a copper PHY attached. */
+	if (hw->phy.type == ixgbe_phy_cu_unknown ||
+	    hw->phy.type == ixgbe_phy_tn) {
+		media_type = ixgbe_media_type_copper;
+		goto out;
+	}
+
+	switch (hw->device_id) {
+	case IXGBE_DEV_ID_82599:
+	case IXGBE_DEV_ID_82599_KX4:
+		/* Default device ID is mezzanine card KX/KX4 */
+		media_type = ixgbe_media_type_backplane;
+		break;
+	case IXGBE_DEV_ID_82599_SFP:
+		media_type = ixgbe_media_type_fiber;
+		break;
+	default:
+		media_type = ixgbe_media_type_unknown;
+		break;
+	}
+out:
+	return media_type;
+}
+
+/**
+ *  ixgbe_setup_mac_link_82599 - Setup MAC link settings
+ *  @hw: pointer to hardware structure
+ *
+ *  Configures link settings based on values in the ixgbe_hw struct.
+ *  Restarts the link.  Performs autonegotiation if needed.
+ **/
+s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw)
+{
+	u32 autoc_reg;
+	u32 links_reg;
+	u32 i;
+	s32 status = 0;
+
+	/* Restart link */
+	autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	autoc_reg |= IXGBE_AUTOC_AN_RESTART;
+	IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg);
+
+	/* Only poll for autoneg to complete if specified to do so */
+	if (hw->phy.autoneg_wait_to_complete) {
+		if ((autoc_reg & IXGBE_AUTOC_LMS_MASK) ==
+		     IXGBE_AUTOC_LMS_KX4_KX_KR ||
+		    (autoc_reg & IXGBE_AUTOC_LMS_MASK) ==
+		     IXGBE_AUTOC_LMS_KX4_KX_KR_1G_AN ||
+		    (autoc_reg & IXGBE_AUTOC_LMS_MASK) ==
+		     IXGBE_AUTOC_LMS_KX4_KX_KR_SGMII) {
+			links_reg = 0; /* Just in case Autoneg time = 0 */
+			for (i = 0; i < IXGBE_AUTO_NEG_TIME; i++) {
+				links_reg = IXGBE_READ_REG(hw, IXGBE_LINKS);
+				if (links_reg & IXGBE_LINKS_KX_AN_COMP)
+					break;
+				msleep(100);
+			}
+			if (!(links_reg & IXGBE_LINKS_KX_AN_COMP)) {
+				status = IXGBE_ERR_AUTONEG_NOT_COMPLETE;
+				hw_dbg(hw, "Autoneg did not complete.\n");
+			}
+		}
+	}
+
+	/* Set up flow control */
+	status = ixgbe_setup_fc_generic(hw, 0);
+
+	/* Add delay to filter out noises during initial link setup */
+	msleep(50);
+
+	return status;
+}
+
+/**
+ *  ixgbe_setup_mac_link_multispeed_fiber - Setup MAC link settings
+ *  @hw: pointer to hardware structure
+ *
+ *  Configures link settings based on values in the ixgbe_hw struct.
+ *  Restarts the link for multi-speed fiber at 1G speed, if link
+ *  fails at 10G.
+ *  Performs autonegotiation if needed.
+ **/
+s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw)
+{
+	s32 status = 0;
+	ixgbe_link_speed link_speed = IXGBE_LINK_SPEED_82599_AUTONEG;
+	status = ixgbe_setup_mac_link_speed_multispeed_fiber(hw,
+	                                                     link_speed,
+	                                                     true, true);
+	return status;
+}
+
+/**
+ *  ixgbe_setup_mac_link_speed_multispeed_fiber - Set MAC link speed
+ *  @hw: pointer to hardware structure
+ *  @speed: new link speed
+ *  @autoneg: true if autonegotiation enabled
+ *  @autoneg_wait_to_complete: true when waiting for completion is needed
+ *
+ *  Set the link speed in the AUTOC register and restarts link.
+ **/
+s32 ixgbe_setup_mac_link_speed_multispeed_fiber(struct ixgbe_hw *hw,
+                                                ixgbe_link_speed speed,
+                                                bool autoneg,
+                                                bool autoneg_wait_to_complete)
+{
+	s32 status = 0;
+	ixgbe_link_speed phy_link_speed;
+	ixgbe_link_speed highest_link_speed = IXGBE_LINK_SPEED_UNKNOWN;
+	u32 speedcnt = 0;
+	u32 esdp_reg = IXGBE_READ_REG(hw, IXGBE_ESDP);
+	bool link_up = false;
+	bool negotiation;
+
+	/* Mask off requested but non-supported speeds */
+	hw->mac.ops.get_link_capabilities(hw, &phy_link_speed, &negotiation);
+	speed &= phy_link_speed;
+
+	/*
+	 * Try each speed one by one, highest priority first.  We do this in
+	 * software because 10gb fiber doesn't support speed autonegotiation.
+	 */
+	if (speed & IXGBE_LINK_SPEED_10GB_FULL) {
+		speedcnt++;
+		highest_link_speed = IXGBE_LINK_SPEED_10GB_FULL;
+
+		/* Set hardware SDP's */
+		esdp_reg |= (IXGBE_ESDP_SDP5_DIR | IXGBE_ESDP_SDP5);
+		IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp_reg);
+
+		ixgbe_setup_mac_link_speed_82599(hw,
+		                                 IXGBE_LINK_SPEED_10GB_FULL,
+		                                 autoneg,
+		                                 autoneg_wait_to_complete);
+
+		msleep(50);
+
+		/* If we have link, just jump out */
+		hw->mac.ops.check_link(hw, &phy_link_speed, &link_up, false);
+		if (link_up)
+			goto out;
+	}
+
+	if (speed & IXGBE_LINK_SPEED_1GB_FULL) {
+		speedcnt++;
+		if (highest_link_speed == IXGBE_LINK_SPEED_UNKNOWN)
+			highest_link_speed = IXGBE_LINK_SPEED_1GB_FULL;
+
+		/* Set hardware SDP's */
+		esdp_reg &= ~IXGBE_ESDP_SDP5;
+		esdp_reg |= IXGBE_ESDP_SDP5_DIR;
+		IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp_reg);
+
+		ixgbe_setup_mac_link_speed_82599(
+			hw, IXGBE_LINK_SPEED_1GB_FULL, autoneg,
+			autoneg_wait_to_complete);
+
+		msleep(50);
+
+		/* If we have link, just jump out */
+		hw->mac.ops.check_link(hw, &phy_link_speed, &link_up, false);
+		if (link_up)
+			goto out;
+	}
+
+	/*
+	 * We didn't get link.  Configure back to the highest speed we tried,
+	 * (if there was more than one).  We call ourselves back with just the
+	 * single highest speed that the user requested.
+	 */
+	if (speedcnt > 1)
+		status = ixgbe_setup_mac_link_speed_multispeed_fiber(hw,
+		                                     highest_link_speed,
+		                                     autoneg,
+		                                     autoneg_wait_to_complete);
+
+out:
+	return status;
+}
+
+/**
+ *  ixgbe_check_mac_link_82599 - Determine link and speed status
+ *  @hw: pointer to hardware structure
+ *  @speed: pointer to link speed
+ *  @link_up: true when link is up
+ *  @link_up_wait_to_complete: bool used to wait for link up or not
+ *
+ *  Reads the links register to determine if link is up and the current speed
+ **/
+s32 ixgbe_check_mac_link_82599(struct ixgbe_hw *hw, ixgbe_link_speed *speed,
+                               bool *link_up, bool link_up_wait_to_complete)
+{
+	u32 links_reg;
+	u32 i;
+
+	links_reg = IXGBE_READ_REG(hw, IXGBE_LINKS);
+	if (link_up_wait_to_complete) {
+		for (i = 0; i < IXGBE_LINK_UP_TIME; i++) {
+			if (links_reg & IXGBE_LINKS_UP) {
+				*link_up = true;
+				break;
+			} else {
+				*link_up = false;
+			}
+			msleep(100);
+			links_reg = IXGBE_READ_REG(hw, IXGBE_LINKS);
+		}
+	} else {
+		if (links_reg & IXGBE_LINKS_UP)
+			*link_up = true;
+		else
+			*link_up = false;
+	}
+
+	if ((links_reg & IXGBE_LINKS_SPEED_82599) ==
+	    IXGBE_LINKS_SPEED_10G_82599)
+		*speed = IXGBE_LINK_SPEED_10GB_FULL;
+	else if ((links_reg & IXGBE_LINKS_SPEED_82599) ==
+	         IXGBE_LINKS_SPEED_1G_82599)
+		*speed = IXGBE_LINK_SPEED_1GB_FULL;
+	else
+		*speed = IXGBE_LINK_SPEED_100_FULL;
+
+
+	return 0;
+}
+
+/**
+ *  ixgbe_setup_mac_link_speed_82599 - Set MAC link speed
+ *  @hw: pointer to hardware structure
+ *  @speed: new link speed
+ *  @autoneg: true if autonegotiation enabled
+ *  @autoneg_wait_to_complete: true when waiting for completion is needed
+ *
+ *  Set the link speed in the AUTOC register and restarts link.
+ **/
+s32 ixgbe_setup_mac_link_speed_82599(struct ixgbe_hw *hw,
+                                     ixgbe_link_speed speed, bool autoneg,
+                                     bool autoneg_wait_to_complete)
+{
+	s32 status = 0;
+	u32 autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	u32 autoc2 = IXGBE_READ_REG(hw, IXGBE_AUTOC2);
+	u32 link_mode = autoc & IXGBE_AUTOC_LMS_MASK;
+	u32 pma_pmd_1g = autoc & IXGBE_AUTOC_1G_PMA_PMD_MASK;
+	u32 pma_pmd_10g_serial = autoc2 & IXGBE_AUTOC2_10G_SERIAL_PMA_PMD_MASK;
+	u32 links_reg;
+	u32 i;
+	ixgbe_link_speed link_capabilities = IXGBE_LINK_SPEED_UNKNOWN;
+
+	/* Check to see if speed passed in is supported. */
+	hw->mac.ops.get_link_capabilities(hw, &link_capabilities, &autoneg);
+	speed &= link_capabilities;
+
+	if (speed == IXGBE_LINK_SPEED_UNKNOWN) {
+		status = IXGBE_ERR_LINK_SETUP;
+	} else if (link_mode == IXGBE_AUTOC_LMS_KX4_KX_KR ||
+	           link_mode == IXGBE_AUTOC_LMS_KX4_KX_KR_1G_AN ||
+	           link_mode == IXGBE_AUTOC_LMS_KX4_KX_KR_SGMII) {
+		/* Set KX4/KX/KR support according to speed requested */
+		autoc &= ~(IXGBE_AUTOC_KX4_KX_SUPP_MASK | IXGBE_AUTOC_KR_SUPP);
+		if (speed & IXGBE_LINK_SPEED_10GB_FULL)
+			if (hw->mac.orig_autoc & IXGBE_AUTOC_KX4_SUPP)
+				autoc |= IXGBE_AUTOC_KX4_SUPP;
+			if (hw->mac.orig_autoc & IXGBE_AUTOC_KR_SUPP)
+				autoc |= IXGBE_AUTOC_KR_SUPP;
+		if (speed & IXGBE_LINK_SPEED_1GB_FULL)
+			autoc |= IXGBE_AUTOC_KX_SUPP;
+	} else if ((pma_pmd_1g == IXGBE_AUTOC_1G_SFI) &&
+	           (link_mode == IXGBE_AUTOC_LMS_1G_LINK_NO_AN ||
+	            link_mode == IXGBE_AUTOC_LMS_1G_AN)) {
+		/* Switch from 1G SFI to 10G SFI if requested */
+		if ((speed == IXGBE_LINK_SPEED_10GB_FULL) &&
+		    (pma_pmd_10g_serial == IXGBE_AUTOC2_10G_SFI)) {
+			autoc &= ~IXGBE_AUTOC_LMS_MASK;
+			autoc |= IXGBE_AUTOC_LMS_10G_SERIAL;
+		}
+	} else if ((pma_pmd_10g_serial == IXGBE_AUTOC2_10G_SFI) &&
+	           (link_mode == IXGBE_AUTOC_LMS_10G_SERIAL)) {
+		/* Switch from 10G SFI to 1G SFI if requested */
+		if ((speed == IXGBE_LINK_SPEED_1GB_FULL) &&
+		    (pma_pmd_1g == IXGBE_AUTOC_1G_SFI)) {
+			autoc &= ~IXGBE_AUTOC_LMS_MASK;
+			if (autoneg)
+				autoc |= IXGBE_AUTOC_LMS_1G_AN;
+			else
+				autoc |= IXGBE_AUTOC_LMS_1G_LINK_NO_AN;
+		}
+	}
+
+	if (status == 0) {
+		/* Restart link */
+		autoc |= IXGBE_AUTOC_AN_RESTART;
+		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc);
+
+		/* Only poll for autoneg to complete if specified to do so */
+		if (autoneg_wait_to_complete) {
+			if (link_mode == IXGBE_AUTOC_LMS_KX4_KX_KR ||
+			    link_mode == IXGBE_AUTOC_LMS_KX4_KX_KR_1G_AN ||
+			    link_mode == IXGBE_AUTOC_LMS_KX4_KX_KR_SGMII) {
+				links_reg = 0; /*Just in case Autoneg time=0*/
+				for (i = 0; i < IXGBE_AUTO_NEG_TIME; i++) {
+					links_reg =
+					       IXGBE_READ_REG(hw, IXGBE_LINKS);
+					if (links_reg & IXGBE_LINKS_KX_AN_COMP)
+						break;
+					msleep(100);
+				}
+				if (!(links_reg & IXGBE_LINKS_KX_AN_COMP)) {
+					status =
+					        IXGBE_ERR_AUTONEG_NOT_COMPLETE;
+					hw_dbg(hw, "Autoneg did not "
+					       "complete.\n");
+				}
+			}
+		}
+
+		/* Set up flow control */
+		status = ixgbe_setup_fc_generic(hw, 0);
+
+		/* Add delay to filter out noises during initial link setup */
+		msleep(50);
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_setup_copper_link_82599 - Setup copper link settings
+ *  @hw: pointer to hardware structure
+ *
+ *  Restarts the link on PHY and then MAC. Performs autonegotiation if needed.
+ **/
+static s32 ixgbe_setup_copper_link_82599(struct ixgbe_hw *hw)
+{
+	s32 status;
+
+	/* Restart autonegotiation on PHY */
+	status = hw->phy.ops.setup_link(hw);
+
+	/* Set up MAC */
+	ixgbe_setup_mac_link_82599(hw);
+
+	return status;
+}
+
+/**
+ *  ixgbe_setup_copper_link_speed_82599 - Set the PHY autoneg advertised field
+ *  @hw: pointer to hardware structure
+ *  @speed: new link speed
+ *  @autoneg: true if autonegotiation enabled
+ *  @autoneg_wait_to_complete: true if waiting is needed to complete
+ *
+ *  Restarts link on PHY and MAC based on settings passed in.
+ **/
+static s32 ixgbe_setup_copper_link_speed_82599(struct ixgbe_hw *hw,
+                                               ixgbe_link_speed speed,
+                                               bool autoneg,
+                                               bool autoneg_wait_to_complete)
+{
+	s32 status;
+
+	/* Setup the PHY according to input speed */
+	status = hw->phy.ops.setup_link_speed(hw, speed, autoneg,
+	                                      autoneg_wait_to_complete);
+	/* Set up MAC */
+	ixgbe_setup_mac_link_82599(hw);
+
+	return status;
+}
+
+/**
+ *  ixgbe_reset_hw_82599 - Perform hardware reset
+ *  @hw: pointer to hardware structure
+ *
+ *  Resets the hardware by resetting the transmit and receive units, masks
+ *  and clears all interrupts, perform a PHY reset, and perform a link (MAC)
+ *  reset.
+ **/
+s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
+{
+	s32 status = 0;
+	u32 ctrl, ctrl_ext;
+	u32 i;
+	u32 autoc;
+	u32 autoc2;
+
+	/* Call adapter stop to disable tx/rx and clear interrupts */
+	hw->mac.ops.stop_adapter(hw);
+
+	/* Reset PHY */
+	hw->phy.ops.reset(hw);
+
+	/*
+	 * Prevent the PCI-E bus from from hanging by disabling PCI-E master
+	 * access and verify no pending requests before reset
+	 */
+	if (ixgbe_disable_pcie_master(hw) != 0) {
+		status = IXGBE_ERR_MASTER_REQUESTS_PENDING;
+		hw_dbg(hw, "PCI-E Master disable polling has failed.\n");
+	}
+
+	/*
+	 * Issue global reset to the MAC.  This needs to be a SW reset.
+	 * If link reset is used, it might reset the MAC when mng is using it
+	 */
+	ctrl = IXGBE_READ_REG(hw, IXGBE_CTRL);
+	IXGBE_WRITE_REG(hw, IXGBE_CTRL, (ctrl | IXGBE_CTRL_RST));
+	IXGBE_WRITE_FLUSH(hw);
+
+	/* Poll for reset bit to self-clear indicating reset is complete */
+	for (i = 0; i < 10; i++) {
+		udelay(1);
+		ctrl = IXGBE_READ_REG(hw, IXGBE_CTRL);
+		if (!(ctrl & IXGBE_CTRL_RST))
+			break;
+	}
+	if (ctrl & IXGBE_CTRL_RST) {
+		status = IXGBE_ERR_RESET_FAILED;
+		hw_dbg(hw, "Reset polling failed to complete.\n");
+	}
+	/* Clear PF Reset Done bit so PF/VF Mail Ops can work */
+	ctrl_ext = IXGBE_READ_REG(hw, IXGBE_CTRL_EXT);
+	ctrl_ext |= IXGBE_CTRL_EXT_PFRSTD;
+	IXGBE_WRITE_REG(hw, IXGBE_CTRL_EXT, ctrl_ext);
+
+	msleep(50);
+
+
+
+	/*
+	 * Store the original AUTOC/AUTOC2 values if they have not been
+	 * stored off yet.  Otherwise restore the stored original
+	 * values since the reset operation sets back to defaults.
+	 */
+	autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	autoc2 = IXGBE_READ_REG(hw, IXGBE_AUTOC2);
+	if (hw->mac.orig_link_settings_stored == false) {
+		hw->mac.orig_autoc = autoc;
+		hw->mac.orig_autoc2 = autoc2;
+		hw->mac.orig_link_settings_stored = true;
+	} else  {
+		if (autoc != hw->mac.orig_autoc)
+			IXGBE_WRITE_REG(hw, IXGBE_AUTOC, (hw->mac.orig_autoc |
+			                IXGBE_AUTOC_AN_RESTART));
+
+		if ((autoc2 & IXGBE_AUTOC2_UPPER_MASK) !=
+		    (hw->mac.orig_autoc2 & IXGBE_AUTOC2_UPPER_MASK)) {
+			autoc2 &= ~IXGBE_AUTOC2_UPPER_MASK;
+			autoc2 |= (hw->mac.orig_autoc2 &
+			           IXGBE_AUTOC2_UPPER_MASK);
+			IXGBE_WRITE_REG(hw, IXGBE_AUTOC2, autoc2);
+		}
+	}
+
+	/* Store the permanent mac address */
+	hw->mac.ops.get_mac_addr(hw, hw->mac.perm_addr);
+
+	return status;
+}
+
+/**
+ *  ixgbe_clear_vmdq_82599 - Disassociate a VMDq pool index from a rx address
+ *  @hw: pointer to hardware struct
+ *  @rar: receive address register index to disassociate
+ *  @vmdq: VMDq pool index to remove from the rar
+ **/
+s32 ixgbe_clear_vmdq_82599(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
+{
+	u32 mpsar_lo, mpsar_hi;
+	u32 rar_entries = hw->mac.num_rar_entries;
+
+	if (rar < rar_entries) {
+		mpsar_lo = IXGBE_READ_REG(hw, IXGBE_MPSAR_LO(rar));
+		mpsar_hi = IXGBE_READ_REG(hw, IXGBE_MPSAR_HI(rar));
+
+		if (!mpsar_lo && !mpsar_hi)
+			goto done;
+
+		if (vmdq == IXGBE_CLEAR_VMDQ_ALL) {
+			if (mpsar_lo) {
+				IXGBE_WRITE_REG(hw, IXGBE_MPSAR_LO(rar), 0);
+				mpsar_lo = 0;
+			}
+			if (mpsar_hi) {
+				IXGBE_WRITE_REG(hw, IXGBE_MPSAR_HI(rar), 0);
+				mpsar_hi = 0;
+			}
+		} else if (vmdq < 32) {
+			mpsar_lo &= ~(1 << vmdq);
+			IXGBE_WRITE_REG(hw, IXGBE_MPSAR_LO(rar), mpsar_lo);
+		} else {
+			mpsar_hi &= ~(1 << (vmdq - 32));
+			IXGBE_WRITE_REG(hw, IXGBE_MPSAR_HI(rar), mpsar_hi);
+		}
+
+		/* was that the last pool using this rar? */
+		if (mpsar_lo == 0 && mpsar_hi == 0 && rar != 0)
+			hw->mac.ops.clear_rar(hw, rar);
+	} else {
+		hw_dbg(hw, "RAR index %d is out of range.\n", rar);
+	}
+
+done:
+	return 0;
+}
+
+/**
+ *  ixgbe_set_vmdq_82599 - Associate a VMDq pool index with a rx address
+ *  @hw: pointer to hardware struct
+ *  @rar: receive address register index to associate with a VMDq index
+ *  @vmdq: VMDq pool index
+ **/
+s32 ixgbe_set_vmdq_82599(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
+{
+	u32 mpsar;
+	u32 rar_entries = hw->mac.num_rar_entries;
+
+	if (rar < rar_entries) {
+		if (vmdq < 32) {
+			mpsar = IXGBE_READ_REG(hw, IXGBE_MPSAR_LO(rar));
+			mpsar |= 1 << vmdq;
+			IXGBE_WRITE_REG(hw, IXGBE_MPSAR_LO(rar), mpsar);
+		} else {
+			mpsar = IXGBE_READ_REG(hw, IXGBE_MPSAR_HI(rar));
+			mpsar |= 1 << (vmdq - 32);
+			IXGBE_WRITE_REG(hw, IXGBE_MPSAR_HI(rar), mpsar);
+		}
+	} else {
+		hw_dbg(hw, "RAR index %d is out of range.\n", rar);
+	}
+	return 0;
+}
+
+/**
+ *  ixgbe_set_vfta_82599 - Set VLAN filter table
+ *  @hw: pointer to hardware structure
+ *  @vlan: VLAN id to write to VLAN filter
+ *  @vind: VMDq output index that maps queue to VLAN id in VFVFB
+ *  @vlan_on: boolean flag to turn on/off VLAN in VFVF
+ *
+ *  Turn on/off specified VLAN in the VLAN filter table.
+ **/
+s32 ixgbe_set_vfta_82599(struct ixgbe_hw *hw, u32 vlan, u32 vind,
+                         bool vlan_on)
+{
+	u32 regindex;
+	u32 bitindex;
+	u32 bits;
+	u32 first_empty_slot;
+
+	if (vlan > 4095)
+		return IXGBE_ERR_PARAM;
+
+	/*
+	 * this is a 2 part operation - first the VFTA, then the
+	 * VLVF and VLVFB if vind is set
+	 */
+
+	/* Part 1
+	 * The VFTA is a bitstring made up of 128 32-bit registers
+	 * that enable the particular VLAN id, much like the MTA:
+	 *    bits[11-5]: which register
+	 *    bits[4-0]:  which bit in the register
+	 */
+	regindex = (vlan >> 5) & 0x7F;
+	bitindex = vlan & 0x1F;
+	bits = IXGBE_READ_REG(hw, IXGBE_VFTA(regindex));
+	if (vlan_on)
+		bits |= (1 << bitindex);
+	else
+		bits &= ~(1 << bitindex);
+	IXGBE_WRITE_REG(hw, IXGBE_VFTA(regindex), bits);
+
+
+	/* Part 2
+	 * If the vind is set
+	 *   Either vlan_on
+	 *     make sure the vlan is in VLVF
+	 *     set the vind bit in the matching VLVFB
+	 *   Or !vlan_on
+	 *     clear the pool bit and possibly the vind
+	 */
+	if (vind) {
+		/* find the vlanid or the first empty slot */
+		first_empty_slot = 0;
+
+		for (regindex = 1; regindex < IXGBE_VLVF_ENTRIES; regindex++) {
+			bits = IXGBE_READ_REG(hw, IXGBE_VLVF(regindex));
+			if (!bits && !first_empty_slot)
+				first_empty_slot = regindex;
+			else if ((bits & 0x0FFF) == vlan)
+				break;
+		}
+
+		if (regindex >= IXGBE_VLVF_ENTRIES) {
+			if (first_empty_slot)
+				regindex = first_empty_slot;
+			else {
+				hw_dbg(hw, "No space in VLVF.\n");
+				goto out;
+			}
+		}
+
+		if (vlan_on) {
+			/* set the pool bit */
+			if (vind < 32) {
+				bits = IXGBE_READ_REG(hw,
+				                    IXGBE_VLVFB(regindex * 2));
+				bits |= (1 << vind);
+				IXGBE_WRITE_REG(hw,
+				              IXGBE_VLVFB(regindex * 2), bits);
+			} else {
+				bits = IXGBE_READ_REG(hw,
+				              IXGBE_VLVFB((regindex * 2) + 1));
+				bits |= (1 << vind);
+				IXGBE_WRITE_REG(hw,
+				        IXGBE_VLVFB((regindex * 2) + 1), bits);
+			}
+		} else {
+			/* clear the pool bit */
+			if (vind < 32) {
+				bits = IXGBE_READ_REG(hw,
+				     IXGBE_VLVFB(regindex * 2));
+			bits &= ~(1 << vind);
+				IXGBE_WRITE_REG(hw,
+				              IXGBE_VLVFB(regindex * 2), bits);
+				bits |= IXGBE_READ_REG(hw,
+				              IXGBE_VLVFB((regindex * 2) + 1));
+			} else {
+				bits = IXGBE_READ_REG(hw,
+				              IXGBE_VLVFB((regindex * 2) + 1));
+				bits &= ~(1 << vind);
+				IXGBE_WRITE_REG(hw,
+				        IXGBE_VLVFB((regindex * 2) + 1), bits);
+				bits |= IXGBE_READ_REG(hw,
+				                    IXGBE_VLVFB(regindex * 2));
+			}
+		}
+
+		if (bits)
+			IXGBE_WRITE_REG(hw, IXGBE_VLVF(regindex),
+			                (IXGBE_VLVF_VIEN | vlan));
+		else
+			IXGBE_WRITE_REG(hw, IXGBE_VLVF(regindex), 0);
+	}
+
+out:
+	return 0;
+}
+
+/**
+ *  ixgbe_clear_vfta_82599 - Clear VLAN filter table
+ *  @hw: pointer to hardware structure
+ *
+ *  Clears the VLAN filer table, and the VMDq index associated with the filter
+ **/
+s32 ixgbe_clear_vfta_82599(struct ixgbe_hw *hw)
+{
+	u32 offset;
+
+	for (offset = 0; offset < hw->mac.vft_size; offset++)
+		IXGBE_WRITE_REG(hw, IXGBE_VFTA(offset), 0);
+
+	for (offset = 0; offset < IXGBE_VLVF_ENTRIES; offset++) {
+		IXGBE_WRITE_REG(hw, IXGBE_VLVF(offset), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_VLVFB(offset * 2), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_VLVFB((offset * 2) + 1), 0);
+	}
+
+	return 0;
+}
+
+/**
+ *  ixgbe_blink_led_start_82599 - Blink LED based on index.
+ *  @hw: pointer to hardware structure
+ *  @index: led number to blink
+ **/
+s32 ixgbe_blink_led_start_82599(struct ixgbe_hw *hw, u32 index)
+{
+	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
+
+	led_reg &= ~IXGBE_LED_MODE_MASK(index);
+	led_reg |= IXGBE_LED_BLINK(index);
+	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, led_reg);
+	IXGBE_WRITE_FLUSH(hw);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_blink_led_stop_82599 - Stop blinking LED based on index.
+ *  @hw: pointer to hardware structure
+ *  @index: led number to stop blinking
+ **/
+s32 ixgbe_blink_led_stop_82599(struct ixgbe_hw *hw, u32 index)
+{
+	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
+
+	led_reg &= ~IXGBE_LED_MODE_MASK(index);
+	led_reg &= ~IXGBE_LED_BLINK(index);
+	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, led_reg);
+	IXGBE_WRITE_FLUSH(hw);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_init_uta_tables_82599 - Initialize the Unicast Table Array
+ *  @hw: pointer to hardware structure
+ **/
+s32 ixgbe_init_uta_tables_82599(struct ixgbe_hw *hw)
+{
+	int i;
+	hw_dbg(hw, " Clearing UTA\n");
+
+	for (i = 0; i < 128; i++)
+		IXGBE_WRITE_REG(hw, IXGBE_UTA(i), 0);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_read_analog_reg8_82599 - Reads 8 bit Omer analog register
+ *  @hw: pointer to hardware structure
+ *  @reg: analog register to read
+ *  @val: read value
+ *
+ *  Performs read operation to Omer analog register specified.
+ **/
+s32 ixgbe_read_analog_reg8_82599(struct ixgbe_hw *hw, u32 reg, u8 *val)
+{
+	u32  core_ctl;
+
+	IXGBE_WRITE_REG(hw, IXGBE_CORECTL, IXGBE_CORECTL_WRITE_CMD |
+	                (reg << 8));
+	IXGBE_WRITE_FLUSH(hw);
+	udelay(10);
+	core_ctl = IXGBE_READ_REG(hw, IXGBE_CORECTL);
+	*val = (u8)core_ctl;
+
+	return 0;
+}
+
+/**
+ *  ixgbe_write_analog_reg8_82599 - Writes 8 bit Omer analog register
+ *  @hw: pointer to hardware structure
+ *  @reg: atlas register to write
+ *  @val: value to write
+ *
+ *  Performs write operation to Omer analog register specified.
+ **/
+s32 ixgbe_write_analog_reg8_82599(struct ixgbe_hw *hw, u32 reg, u8 val)
+{
+	u32  core_ctl;
+
+	core_ctl = (reg << 8) | val;
+	IXGBE_WRITE_REG(hw, IXGBE_CORECTL, core_ctl);
+	IXGBE_WRITE_FLUSH(hw);
+	udelay(10);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_start_hw_82599 - Prepare hardware for Tx/Rx
+ *  @hw: pointer to hardware structure
+ *
+ *  Starts the hardware using the generic start_hw function.
+ *  Then performs device-specific:
+ *  Clears the rate limiter registers.
+ **/
+s32 ixgbe_start_hw_82599(struct ixgbe_hw *hw)
+{
+	u32 q_num;
+
+	ixgbe_start_hw_generic(hw);
+
+	/* Clear the rate limiters */
+	for (q_num = 0; q_num < hw->mac.max_tx_queues; q_num++) {
+		IXGBE_WRITE_REG(hw, IXGBE_RTTDQSEL, q_num);
+		IXGBE_WRITE_REG(hw, IXGBE_RTTBCNRC, 0);
+	}
+	IXGBE_WRITE_FLUSH(hw);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_identify_phy_82599 - Get physical layer module
+ *  @hw: pointer to hardware structure
+ *
+ *  Determines the physical layer module found on the current adapter.
+ **/
+s32 ixgbe_identify_phy_82599(struct ixgbe_hw *hw)
+{
+	s32 status = IXGBE_ERR_PHY_ADDR_INVALID;
+	status = ixgbe_identify_phy_generic(hw);
+	if (status != 0)
+		status = ixgbe_identify_sfp_module_generic(hw);
+	return status;
+}
+
+/**
+ *  ixgbe_get_supported_physical_layer_82599 - Returns physical layer type
+ *  @hw: pointer to hardware structure
+ *
+ *  Determines physical layer capabilities of the current configuration.
+ **/
+u32 ixgbe_get_supported_physical_layer_82599(struct ixgbe_hw *hw)
+{
+	u32 physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
+
+	switch (hw->device_id) {
+	case IXGBE_DEV_ID_82599:
+	case IXGBE_DEV_ID_82599_KX4:
+		/* Default device ID is mezzanine card KX/KX4 */
+		physical_layer = (IXGBE_PHYSICAL_LAYER_10GBASE_KX4 |
+		                  IXGBE_PHYSICAL_LAYER_1000BASE_KX);
+		break;
+	case IXGBE_DEV_ID_82599_SFP:
+		hw->phy.ops.identify_sfp(hw);
+
+		switch (hw->phy.sfp_type) {
+		case ixgbe_sfp_type_da_cu:
+			physical_layer = IXGBE_PHYSICAL_LAYER_SFP_PLUS_CU;
+			break;
+		case ixgbe_sfp_type_sr:
+			physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_SR;
+			break;
+		case ixgbe_sfp_type_lr:
+			physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_LR;
+			break;
+		default:
+			physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
+			break;
+		}
+		break;
+	default:
+		physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
+		break;
+	}
+
+	return physical_layer;
+}
+
+/**
+ *  ixgbe_enable_rx_dma_82599 - Enable the Rx DMA unit on 82599
+ *  @hw: pointer to hardware structure
+ *  @regval: register value to write to RXCTRL
+ *
+ *  Enables the Rx DMA unit for 82599
+ **/
+s32 ixgbe_enable_rx_dma_82599(struct ixgbe_hw *hw, u32 regval)
+{
+#define IXGBE_MAX_SECRX_POLL 30
+	int i;
+	int secrxreg;
+
+	/*
+	 * Workaround for 82599 silicon errata when enabling the Rx datapath.
+	 * If traffic is incoming before we enable the Rx unit, it could hang
+	 * the Rx DMA unit.  Therefore, make sure the security engine is
+	 * completely disabled prior to enabling the Rx unit.
+	 */
+	secrxreg = IXGBE_READ_REG(hw, IXGBE_SECRXCTRL);
+	secrxreg |= IXGBE_SECRXCTRL_RX_DIS;
+	IXGBE_WRITE_REG(hw, IXGBE_SECRXCTRL, secrxreg);
+	for (i = 0; i < IXGBE_MAX_SECRX_POLL; i++) {
+		secrxreg = IXGBE_READ_REG(hw, IXGBE_SECRXSTAT);
+		if (secrxreg & IXGBE_SECRXSTAT_SECRX_RDY)
+			break;
+		else
+			udelay(10);
+	}
+
+	/* For informational purposes only */
+	if (i >= IXGBE_MAX_SECRX_POLL)
+		hw_dbg(hw, "Rx unit being enabled before security "
+		       "path fully disabled.  Continuing with init.\n");
+
+	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, regval);
+	secrxreg = IXGBE_READ_REG(hw, IXGBE_SECRXCTRL);
+	secrxreg &= ~IXGBE_SECRXCTRL_RX_DIS;
+	IXGBE_WRITE_REG(hw, IXGBE_SECRXCTRL, secrxreg);
+	IXGBE_WRITE_FLUSH(hw);
+
+	return 0;
+}
+
+static struct ixgbe_mac_operations mac_ops_82599 = {
+	.init_hw                = &ixgbe_init_hw_generic,
+	.reset_hw               = &ixgbe_reset_hw_82599,
+	.start_hw               = &ixgbe_start_hw_82599,
+	.clear_hw_cntrs         = &ixgbe_clear_hw_cntrs_generic,
+	.get_media_type         = &ixgbe_get_media_type_82599,
+	.get_supported_physical_layer = &ixgbe_get_supported_physical_layer_82599,
+	.enable_rx_dma          = &ixgbe_enable_rx_dma_82599,
+	.get_mac_addr           = &ixgbe_get_mac_addr_generic,
+	.stop_adapter           = &ixgbe_stop_adapter_generic,
+	.get_bus_info           = &ixgbe_get_bus_info_generic,
+	.set_lan_id             = &ixgbe_set_lan_id_multi_port_pcie,
+	.read_analog_reg8       = &ixgbe_read_analog_reg8_82599,
+	.write_analog_reg8      = &ixgbe_write_analog_reg8_82599,
+	.setup_link             = &ixgbe_setup_mac_link_82599,
+	.setup_link_speed       = &ixgbe_setup_mac_link_speed_82599,
+	.check_link             = &ixgbe_check_mac_link_82599,
+	.get_link_capabilities  = &ixgbe_get_link_capabilities_82599,
+	.led_on                 = &ixgbe_led_on_generic,
+	.led_off                = &ixgbe_led_off_generic,
+	.blink_led_start        = &ixgbe_blink_led_start_82599,
+	.blink_led_stop         = &ixgbe_blink_led_stop_82599,
+	.set_rar                = &ixgbe_set_rar_generic,
+	.clear_rar              = &ixgbe_clear_rar_generic,
+	.set_vmdq               = &ixgbe_set_vmdq_82599,
+	.clear_vmdq             = &ixgbe_clear_vmdq_82599,
+	.init_rx_addrs          = &ixgbe_init_rx_addrs_generic,
+	.update_uc_addr_list    = &ixgbe_update_uc_addr_list_generic,
+	.update_mc_addr_list    = &ixgbe_update_mc_addr_list_generic,
+	.enable_mc              = &ixgbe_enable_mc_generic,
+	.disable_mc             = &ixgbe_disable_mc_generic,
+	.clear_vfta             = &ixgbe_clear_vfta_82599,
+	.set_vfta               = &ixgbe_set_vfta_82599,
+	.setup_fc               = &ixgbe_setup_fc_generic,
+	.init_uta_tables        = &ixgbe_init_uta_tables_82599,
+	.setup_sfp              = &ixgbe_setup_sfp_modules_82599,
+};
+
+static struct ixgbe_eeprom_operations eeprom_ops_82599 = {
+	.init_params            = &ixgbe_init_eeprom_params_generic,
+	.read                   = &ixgbe_read_eeprom_generic,
+	.write                  = &ixgbe_write_eeprom_generic,
+	.validate_checksum      = &ixgbe_validate_eeprom_checksum_generic,
+	.update_checksum        = &ixgbe_update_eeprom_checksum_generic,
+};
+
+static struct ixgbe_phy_operations phy_ops_82599 = {
+	.identify               = &ixgbe_identify_phy_82599,
+	.identify_sfp           = &ixgbe_identify_sfp_module_generic,
+	.reset                  = &ixgbe_reset_phy_generic,
+	.read_reg               = &ixgbe_read_phy_reg_generic,
+	.write_reg              = &ixgbe_write_phy_reg_generic,
+	.setup_link             = &ixgbe_setup_phy_link_generic,
+	.setup_link_speed       = &ixgbe_setup_phy_link_speed_generic,
+	.read_i2c_byte          = &ixgbe_read_i2c_byte_generic,
+	.write_i2c_byte         = &ixgbe_write_i2c_byte_generic,
+	.read_i2c_eeprom        = &ixgbe_read_i2c_eeprom_generic,
+	.write_i2c_eeprom       = &ixgbe_write_i2c_eeprom_generic,
+};
+
+struct ixgbe_info ixgbe_82599_info = {
+	.mac                    = ixgbe_mac_82599EB,
+	.get_invariants         = &ixgbe_get_invariants_82599,
+	.mac_ops                = &mac_ops_82599,
+	.eeprom_ops             = &eeprom_ops_82599,
+	.phy_ops                = &phy_ops_82599,
+};
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 5ae9398..26ee8a0 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -29,6 +29,7 @@
 #include <linux/delay.h>
 #include <linux/sched.h>
 
+#include "ixgbe.h"
 #include "ixgbe_common.h"
 #include "ixgbe_phy.h"
 
@@ -251,6 +252,81 @@ s32 ixgbe_get_mac_addr_generic(struct ixgbe_hw *hw, u8 *mac_addr)
 }
 
 /**
+ *  ixgbe_get_bus_info_generic - Generic set PCI bus info
+ *  @hw: pointer to hardware structure
+ *
+ *  Sets the PCI bus info (speed, width, type) within the ixgbe_hw structure
+ **/
+s32 ixgbe_get_bus_info_generic(struct ixgbe_hw *hw)
+{
+	struct ixgbe_adapter *adapter = hw->back;
+	struct ixgbe_mac_info *mac = &hw->mac;
+	u16 link_status;
+
+	hw->bus.type = ixgbe_bus_type_pci_express;
+
+	/* Get the negotiated link width and speed from PCI config space */
+	pci_read_config_word(adapter->pdev, IXGBE_PCI_LINK_STATUS,
+	                     &link_status);
+
+	switch (link_status & IXGBE_PCI_LINK_WIDTH) {
+	case IXGBE_PCI_LINK_WIDTH_1:
+		hw->bus.width = ixgbe_bus_width_pcie_x1;
+		break;
+	case IXGBE_PCI_LINK_WIDTH_2:
+		hw->bus.width = ixgbe_bus_width_pcie_x2;
+		break;
+	case IXGBE_PCI_LINK_WIDTH_4:
+		hw->bus.width = ixgbe_bus_width_pcie_x4;
+		break;
+	case IXGBE_PCI_LINK_WIDTH_8:
+		hw->bus.width = ixgbe_bus_width_pcie_x8;
+		break;
+	default:
+		hw->bus.width = ixgbe_bus_width_unknown;
+		break;
+	}
+
+	switch (link_status & IXGBE_PCI_LINK_SPEED) {
+	case IXGBE_PCI_LINK_SPEED_2500:
+		hw->bus.speed = ixgbe_bus_speed_2500;
+		break;
+	case IXGBE_PCI_LINK_SPEED_5000:
+		hw->bus.speed = ixgbe_bus_speed_5000;
+		break;
+	default:
+		hw->bus.speed = ixgbe_bus_speed_unknown;
+		break;
+	}
+
+	mac->ops.set_lan_id(hw);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_set_lan_id_multi_port_pcie - Set LAN id for PCIe multiple port devices
+ *  @hw: pointer to the HW structure
+ *
+ *  Determines the LAN function id by reading memory-mapped registers
+ *  and swaps the port value if requested.
+ **/
+void ixgbe_set_lan_id_multi_port_pcie(struct ixgbe_hw *hw)
+{
+	struct ixgbe_bus_info *bus = &hw->bus;
+	u32 reg;
+
+	reg = IXGBE_READ_REG(hw, IXGBE_STATUS);
+	bus->func = (reg & IXGBE_STATUS_LAN_ID) >> IXGBE_STATUS_LAN_ID_SHIFT;
+	bus->lan_id = bus->func;
+
+	/* check for a port swap */
+	reg = IXGBE_READ_REG(hw, IXGBE_FACTPS);
+	if (reg & IXGBE_FACTPS_LFS)
+		bus->func ^= 0x1;
+}
+
+/**
  *  ixgbe_stop_adapter_generic - Generic stop Tx/Rx units
  *  @hw: pointer to hardware structure
  *
@@ -390,6 +466,73 @@ s32 ixgbe_init_eeprom_params_generic(struct ixgbe_hw *hw)
 }
 
 /**
+ *  ixgbe_write_eeprom_generic - Writes 16 bit value to EEPROM
+ *  @hw: pointer to hardware structure
+ *  @offset: offset within the EEPROM to be written to
+ *  @data: 16 bit word to be written to the EEPROM
+ *
+ *  If ixgbe_eeprom_update_checksum is not called after this function, the
+ *  EEPROM will most likely contain an invalid checksum.
+ **/
+s32 ixgbe_write_eeprom_generic(struct ixgbe_hw *hw, u16 offset, u16 data)
+{
+	s32 status;
+	u8 write_opcode = IXGBE_EEPROM_WRITE_OPCODE_SPI;
+
+	hw->eeprom.ops.init_params(hw);
+
+	if (offset >= hw->eeprom.word_size) {
+		status = IXGBE_ERR_EEPROM;
+		goto out;
+	}
+
+	/* Prepare the EEPROM for writing  */
+	status = ixgbe_acquire_eeprom(hw);
+
+	if (status == 0) {
+		if (ixgbe_ready_eeprom(hw) != 0) {
+			ixgbe_release_eeprom(hw);
+			status = IXGBE_ERR_EEPROM;
+		}
+	}
+
+	if (status == 0) {
+		ixgbe_standby_eeprom(hw);
+
+		/*  Send the WRITE ENABLE command (8 bit opcode )  */
+		ixgbe_shift_out_eeprom_bits(hw, IXGBE_EEPROM_WREN_OPCODE_SPI,
+		                            IXGBE_EEPROM_OPCODE_BITS);
+
+		ixgbe_standby_eeprom(hw);
+
+		/*
+		 * Some SPI eeproms use the 8th address bit embedded in the
+		 * opcode
+		 */
+		if ((hw->eeprom.address_bits == 8) && (offset >= 128))
+			write_opcode |= IXGBE_EEPROM_A8_OPCODE_SPI;
+
+		/* Send the Write command (8-bit opcode + addr) */
+		ixgbe_shift_out_eeprom_bits(hw, write_opcode,
+		                            IXGBE_EEPROM_OPCODE_BITS);
+		ixgbe_shift_out_eeprom_bits(hw, (u16)(offset*2),
+		                            hw->eeprom.address_bits);
+
+		/* Send the data */
+		data = (data >> 8) | (data << 8);
+		ixgbe_shift_out_eeprom_bits(hw, data, 16);
+		ixgbe_standby_eeprom(hw);
+
+		msleep(hw->eeprom.semaphore_delay);
+		/* Done with writing - release the EEPROM */
+		ixgbe_release_eeprom(hw);
+	}
+
+out:
+	return status;
+}
+
+/**
  *  ixgbe_read_eeprom_bit_bang_generic - Read EEPROM word using bit-bang
  *  @hw: pointer to hardware structure
  *  @offset: offset within the EEPROM to be read
@@ -1487,6 +1630,101 @@ s32 ixgbe_disable_mc_generic(struct ixgbe_hw *hw)
 }
 
 /**
+ *  ixgbe_fc_enable - Enable flow control
+ *  @hw: pointer to hardware structure
+ *  @packetbuf_num: packet buffer number (0-7)
+ *
+ *  Enable flow control according to the current settings.
+ **/
+s32 ixgbe_fc_enable(struct ixgbe_hw *hw, s32 packetbuf_num)
+{
+	s32 ret_val = 0;
+	u32 mflcn_reg;
+	u32 fccfg_reg;
+	u32 reg;
+
+	mflcn_reg = IXGBE_READ_REG(hw, IXGBE_MFLCN);
+	mflcn_reg &= ~(IXGBE_MFLCN_RFCE | IXGBE_MFLCN_RPFCE);
+
+	fccfg_reg = IXGBE_READ_REG(hw, IXGBE_FCCFG);
+	fccfg_reg &= ~(IXGBE_FCCFG_TFCE_802_3X | IXGBE_FCCFG_TFCE_PRIORITY);
+
+	/*
+	 * The possible values of fc.current_mode are:
+	 * 0: Flow control is completely disabled
+	 * 1: Rx flow control is enabled (we can receive pause frames,
+	 *    but not send pause frames).
+	 * 2:  Tx flow control is enabled (we can send pause frames but
+	 *     we do not support receiving pause frames).
+	 * 3: Both Rx and Tx flow control (symmetric) are enabled.
+	 * other: Invalid.
+	 */
+	switch (hw->fc.current_mode) {
+	case ixgbe_fc_none:
+		/* Flow control completely disabled by software override. */
+		break;
+	case ixgbe_fc_rx_pause:
+		/*
+		 * Rx Flow control is enabled and Tx Flow control is
+		 * disabled by software override. Since there really
+		 * isn't a way to advertise that we are capable of RX
+		 * Pause ONLY, we will advertise that we support both
+		 * symmetric and asymmetric Rx PAUSE.  Later, we will
+		 * disable the adapter's ability to send PAUSE frames.
+		 */
+		mflcn_reg |= IXGBE_MFLCN_RFCE;
+		break;
+	case ixgbe_fc_tx_pause:
+		/*
+		 * Tx Flow control is enabled, and Rx Flow control is
+		 * disabled by software override.
+		 */
+		fccfg_reg |= IXGBE_FCCFG_TFCE_802_3X;
+		break;
+	case ixgbe_fc_full:
+		/* Flow control (both Rx and Tx) is enabled by SW override. */
+		mflcn_reg |= IXGBE_MFLCN_RFCE;
+		fccfg_reg |= IXGBE_FCCFG_TFCE_802_3X;
+		break;
+	default:
+		hw_dbg(hw, "Flow control param set incorrectly\n");
+		ret_val = -IXGBE_ERR_CONFIG;
+		goto out;
+		break;
+	}
+
+	/* Enable 802.3x based flow control settings. */
+	IXGBE_WRITE_REG(hw, IXGBE_MFLCN, mflcn_reg);
+	IXGBE_WRITE_REG(hw, IXGBE_FCCFG, fccfg_reg);
+
+	/* Set up and enable Rx high/low water mark thresholds, enable XON. */
+	if (hw->fc.current_mode & ixgbe_fc_tx_pause) {
+		if (hw->fc.send_xon)
+			IXGBE_WRITE_REG(hw, IXGBE_FCRTL_82599(packetbuf_num),
+			                (hw->fc.low_water | IXGBE_FCRTL_XONE));
+		else
+			IXGBE_WRITE_REG(hw, IXGBE_FCRTL_82599(packetbuf_num),
+			                hw->fc.low_water);
+
+		IXGBE_WRITE_REG(hw, IXGBE_FCRTH_82599(packetbuf_num),
+		                (hw->fc.high_water | IXGBE_FCRTH_FCEN));
+	}
+
+	/* Configure pause time (2 TCs per register) */
+	reg = IXGBE_READ_REG(hw, IXGBE_FCTTV(packetbuf_num));
+	if ((packetbuf_num & 1) == 0)
+		reg = (reg & 0xFFFF0000) | hw->fc.pause_time;
+	else
+		reg = (reg & 0x0000FFFF) | (hw->fc.pause_time << 16);
+	IXGBE_WRITE_REG(hw, IXGBE_FCTTV(packetbuf_num / 2), reg);
+
+	IXGBE_WRITE_REG(hw, IXGBE_FCRTV, (hw->fc.pause_time >> 1));
+
+out:
+	return ret_val;
+}
+
+/**
  *  ixgbe_fc_autoneg - Configure flow control
  *  @hw: pointer to hardware structure
  *
@@ -1625,6 +1863,74 @@ out:
 }
 
 /**
+ *  ixgbe_setup_fc_generic - Set up flow control
+ *  @hw: pointer to hardware structure
+ *
+ *  Sets up flow control.
+ **/
+s32 ixgbe_setup_fc_generic(struct ixgbe_hw *hw, s32 packetbuf_num)
+{
+	s32 ret_val = 0;
+	ixgbe_link_speed speed;
+	bool link_up;
+
+	/* Validate the packetbuf configuration */
+	if (packetbuf_num < 0 || packetbuf_num > 7) {
+		hw_dbg(hw, "Invalid packet buffer number [%d], expected range "
+		       "is 0-7\n", packetbuf_num);
+		ret_val = IXGBE_ERR_INVALID_LINK_SETTINGS;
+		goto out;
+	}
+
+	/*
+	 * Validate the water mark configuration.  Zero water marks are invalid
+	 * because it causes the controller to just blast out fc packets.
+	 */
+	if (!hw->fc.low_water || !hw->fc.high_water || !hw->fc.pause_time) {
+		hw_dbg(hw, "Invalid water mark configuration\n");
+		ret_val = IXGBE_ERR_INVALID_LINK_SETTINGS;
+		goto out;
+	}
+
+	/*
+	 * Validate the requested mode.  Strict IEEE mode does not allow
+	 * ixgbe_fc_rx_pause because it will cause testing anomalies.
+	 */
+	if (hw->fc.strict_ieee && hw->fc.requested_mode == ixgbe_fc_rx_pause) {
+		hw_dbg(hw, "ixgbe_fc_rx_pause not valid in strict "
+		       "IEEE mode\n");
+		ret_val = IXGBE_ERR_INVALID_LINK_SETTINGS;
+		goto out;
+	}
+
+	/*
+	 * 10gig parts do not have a word in the EEPROM to determine the
+	 * default flow control setting, so we explicitly set it to full.
+	 */
+	if (hw->fc.requested_mode == ixgbe_fc_default)
+		hw->fc.requested_mode = ixgbe_fc_full;
+
+	/*
+	 * Save off the requested flow control mode for use later.  Depending
+	 * on the link partner's capabilities, we may or may not use this mode.
+	 */
+	hw->fc.current_mode = hw->fc.requested_mode;
+
+	/* Decide whether to use autoneg or not. */
+	hw->mac.ops.check_link(hw, &speed, &link_up, false);
+	if (hw->phy.multispeed_fiber && (speed == IXGBE_LINK_SPEED_1GB_FULL))
+		ret_val = ixgbe_fc_autoneg(hw);
+
+	if (ret_val)
+		goto out;
+
+	ret_val = ixgbe_fc_enable(hw, packetbuf_num);
+
+out:
+	return ret_val;
+}
+
+/**
  *  ixgbe_disable_pcie_master - Disable PCI-express master access
  *  @hw: pointer to hardware structure
  *
@@ -1732,3 +2038,16 @@ void ixgbe_release_swfw_sync(struct ixgbe_hw *hw, u16 mask)
 	ixgbe_release_eeprom_semaphore(hw);
 }
 
+/**
+ *  ixgbe_enable_rx_dma_generic - Enable the Rx DMA unit
+ *  @hw: pointer to hardware structure
+ *  @regval: register value to write to RXCTRL
+ *
+ *  Enables the Rx DMA unit
+ **/
+s32 ixgbe_enable_rx_dma_generic(struct ixgbe_hw *hw, u32 regval)
+{
+	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, regval);
+
+	return 0;
+}
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index c630212..7e94d6d 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -37,12 +37,14 @@ s32 ixgbe_clear_hw_cntrs_generic(struct ixgbe_hw *hw);
 s32 ixgbe_read_pba_num_generic(struct ixgbe_hw *hw, u32 *pba_num);
 s32 ixgbe_get_mac_addr_generic(struct ixgbe_hw *hw, u8 *mac_addr);
 s32 ixgbe_get_bus_info_generic(struct ixgbe_hw *hw);
+void ixgbe_set_lan_id_multi_port_pcie(struct ixgbe_hw *hw);
 s32 ixgbe_stop_adapter_generic(struct ixgbe_hw *hw);
 
 s32 ixgbe_led_on_generic(struct ixgbe_hw *hw, u32 index);
 s32 ixgbe_led_off_generic(struct ixgbe_hw *hw, u32 index);
 
 s32 ixgbe_init_eeprom_params_generic(struct ixgbe_hw *hw);
+s32 ixgbe_write_eeprom_generic(struct ixgbe_hw *hw, u16 offset, u16 data);
 s32 ixgbe_read_eeprom_generic(struct ixgbe_hw *hw, u16 offset, u16 *data);
 s32 ixgbe_read_eeprom_bit_bang_generic(struct ixgbe_hw *hw, u16 offset,
                                        u16 *data);
@@ -61,6 +63,7 @@ s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw, u8 *addr_list,
                                       u32 addr_count, ixgbe_mc_addr_itr func);
 s32 ixgbe_enable_mc_generic(struct ixgbe_hw *hw);
 s32 ixgbe_disable_mc_generic(struct ixgbe_hw *hw);
+s32 ixgbe_enable_rx_dma_generic(struct ixgbe_hw *hw, u32 regval);
 s32 ixgbe_setup_fc_generic(struct ixgbe_hw *hw, s32 packetbuf_num);
 s32 ixgbe_fc_enable(struct ixgbe_hw *hw, s32 packtetbuf_num);
 s32 ixgbe_fc_autoneg(struct ixgbe_hw *hw);
@@ -75,6 +78,13 @@ s32 ixgbe_write_analog_reg8_generic(struct ixgbe_hw *hw, u32 reg, u8 val);
 
 #define IXGBE_WRITE_REG(a, reg, value) writel((value), ((a)->hw_addr + (reg)))
 
+#ifndef writeq
+#define writeq(val, addr) writel((u32) (val), addr); \
+    writel((u32) (val >> 32), (addr + 4));
+#endif
+
+#define IXGBE_WRITE_REG64(a, reg, value) writeq((value), ((a)->hw_addr + (reg)))
+
 #define IXGBE_READ_REG(a, reg) readl((a)->hw_addr + (reg))
 
 #define IXGBE_WRITE_REG_ARRAY(a, reg, offset, value) (\
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index cec2f4e..35d820e 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -469,7 +469,7 @@ static void ixgbe_get_regs(struct net_device *netdev,
 	regs_buff[825] = IXGBE_READ_REG(hw, IXGBE_IP6AT);
 	regs_buff[826] = IXGBE_READ_REG(hw, IXGBE_WUPL);
 	regs_buff[827] = IXGBE_READ_REG(hw, IXGBE_WUPM);
-	regs_buff[828] = IXGBE_READ_REG(hw, IXGBE_FHFT);
+	regs_buff[828] = IXGBE_READ_REG(hw, IXGBE_FHFT(0));
 
 	regs_buff[829] = IXGBE_READ_REG(hw, IXGBE_RMCS);
 	regs_buff[830] = IXGBE_READ_REG(hw, IXGBE_DPMCS);
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 77ec26f..14e9606 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -32,6 +32,18 @@
 #include "ixgbe_common.h"
 #include "ixgbe_phy.h"
 
+static void ixgbe_i2c_start(struct ixgbe_hw *hw);
+static void ixgbe_i2c_stop(struct ixgbe_hw *hw);
+static s32 ixgbe_clock_in_i2c_byte(struct ixgbe_hw *hw, u8 *data);
+static s32 ixgbe_clock_out_i2c_byte(struct ixgbe_hw *hw, u8 data);
+static s32 ixgbe_get_i2c_ack(struct ixgbe_hw *hw);
+static s32 ixgbe_clock_in_i2c_bit(struct ixgbe_hw *hw, bool *data);
+static s32 ixgbe_clock_out_i2c_bit(struct ixgbe_hw *hw, bool data);
+static s32 ixgbe_raise_i2c_clk(struct ixgbe_hw *hw, u32 *i2cctl);
+static void ixgbe_lower_i2c_clk(struct ixgbe_hw *hw, u32 *i2cctl);
+static s32 ixgbe_set_i2c_data(struct ixgbe_hw *hw, u32 *i2cctl, bool data);
+static bool ixgbe_get_i2c_data(u32 *i2cctl);
+static void ixgbe_i2c_bus_clear(struct ixgbe_hw *hw);
 static bool ixgbe_validate_phy_addr(struct ixgbe_hw *hw, u32 phy_addr);
 static enum ixgbe_phy_type ixgbe_get_phy_type_from_id(u32 phy_id);
 static s32 ixgbe_get_phy_id(struct ixgbe_hw *hw);
@@ -543,8 +555,9 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 	u8 identifier = 0;
 	u8 comp_codes_1g = 0;
 	u8 comp_codes_10g = 0;
-	u8 oui_bytes[4] = {0, 0, 0, 0};
+	u8 oui_bytes[3] = {0, 0, 0};
 	u8 transmission_media = 0;
+	u16 enforce_sfp = 0;
 
 	status = hw->phy.ops.read_i2c_eeprom(hw, IXGBE_SFF_IDENTIFIER,
 	                                     &identifier);
@@ -564,18 +577,48 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 
 		/* ID Module
 		 * =========
-		 * 0	SFP_DA_CU
-		 * 1	SFP_SR
-		 * 2	SFP_LR
+		 * 0    SFP_DA_CU
+		 * 1    SFP_SR
+		 * 2    SFP_LR
+		 * 3    SFP_DA_CORE0 - 82599-specific
+		 * 4    SFP_DA_CORE1 - 82599-specific
+		 * 5    SFP_SR/LR_CORE0 - 82599-specific
+		 * 6    SFP_SR/LR_CORE1 - 82599-specific
 		 */
-		if (transmission_media & IXGBE_SFF_TWIN_AX_CAPABLE)
-			hw->phy.sfp_type = ixgbe_sfp_type_da_cu;
-		else if (comp_codes_10g & IXGBE_SFF_10GBASESR_CAPABLE)
-			hw->phy.sfp_type = ixgbe_sfp_type_sr;
-		else if (comp_codes_10g & IXGBE_SFF_10GBASELR_CAPABLE)
-			hw->phy.sfp_type = ixgbe_sfp_type_lr;
-		else
-			hw->phy.sfp_type = ixgbe_sfp_type_unknown;
+		if (hw->mac.type == ixgbe_mac_82598EB) {
+			if (transmission_media & IXGBE_SFF_TWIN_AX_CAPABLE)
+				hw->phy.sfp_type = ixgbe_sfp_type_da_cu;
+			else if (comp_codes_10g & IXGBE_SFF_10GBASESR_CAPABLE)
+				hw->phy.sfp_type = ixgbe_sfp_type_sr;
+			else if (comp_codes_10g & IXGBE_SFF_10GBASELR_CAPABLE)
+				hw->phy.sfp_type = ixgbe_sfp_type_lr;
+			else
+				hw->phy.sfp_type = ixgbe_sfp_type_unknown;
+		} else if (hw->mac.type == ixgbe_mac_82599EB) {
+			if (transmission_media & IXGBE_SFF_TWIN_AX_CAPABLE)
+				if (hw->bus.lan_id == 0)
+					hw->phy.sfp_type =
+					             ixgbe_sfp_type_da_cu_core0;
+				else
+					hw->phy.sfp_type =
+					             ixgbe_sfp_type_da_cu_core1;
+			else if (comp_codes_10g & IXGBE_SFF_10GBASESR_CAPABLE)
+				if (hw->bus.lan_id == 0)
+					hw->phy.sfp_type =
+					              ixgbe_sfp_type_srlr_core0;
+				else
+					hw->phy.sfp_type =
+					              ixgbe_sfp_type_srlr_core1;
+			else if (comp_codes_10g & IXGBE_SFF_10GBASELR_CAPABLE)
+				if (hw->bus.lan_id == 0)
+					hw->phy.sfp_type =
+					              ixgbe_sfp_type_srlr_core0;
+				else
+					hw->phy.sfp_type =
+					              ixgbe_sfp_type_srlr_core1;
+			else
+				hw->phy.sfp_type = ixgbe_sfp_type_unknown;
+		}
 
 		/* Determine PHY vendor */
 		if (hw->phy.type == ixgbe_phy_unknown) {
@@ -607,6 +650,9 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 			case IXGBE_SFF_VENDOR_OUI_AVAGO:
 				hw->phy.type = ixgbe_phy_sfp_avago;
 				break;
+			case IXGBE_SFF_VENDOR_OUI_INTEL:
+				hw->phy.type = ixgbe_phy_sfp_intel;
+				break;
 			default:
 				if (transmission_media &
 				    IXGBE_SFF_TWIN_AX_CAPABLE)
@@ -616,7 +662,28 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 				break;
 			}
 		}
-		status = 0;
+		if (hw->mac.type == ixgbe_mac_82598EB ||
+		    (hw->phy.sfp_type != ixgbe_sfp_type_sr &&
+		     hw->phy.sfp_type != ixgbe_sfp_type_lr &&
+		     hw->phy.sfp_type != ixgbe_sfp_type_srlr_core0 &&
+		     hw->phy.sfp_type != ixgbe_sfp_type_srlr_core1)) {
+			status = 0;
+			goto out;
+		}
+
+		hw->eeprom.ops.read(hw, IXGBE_PHY_ENFORCE_INTEL_SFP_OFFSET,
+		                    &enforce_sfp);
+		if (!(enforce_sfp & IXGBE_PHY_ALLOW_ANY_SFP)) {
+			/* Make sure we're a supported PHY type */
+			if (hw->phy.type == ixgbe_phy_sfp_intel) {
+				status = 0;
+			} else {
+				hw_dbg(hw, "SFP+ module not supported\n");
+				status = IXGBE_ERR_SFP_NOT_SUPPORTED;
+			}
+		} else {
+			status = 0;
+		}
 	}
 
 out:
@@ -651,7 +718,7 @@ s32 ixgbe_get_sfp_init_sequence_offsets(struct ixgbe_hw *hw,
 	hw->eeprom.ops.read(hw, IXGBE_PHY_INIT_OFFSET_NL, list_offset);
 
 	if ((!*list_offset) || (*list_offset == 0xFFFF))
-		return IXGBE_ERR_PHY;
+		return IXGBE_ERR_SFP_NO_INIT_SEQ_PRESENT;
 
 	/* Shift offset to first ID word */
 	(*list_offset)++;
@@ -688,6 +755,501 @@ s32 ixgbe_get_sfp_init_sequence_offsets(struct ixgbe_hw *hw,
 }
 
 /**
+ *  ixgbe_read_i2c_eeprom_generic - Reads 8 bit EEPROM word over I2C interface
+ *  @hw: pointer to hardware structure
+ *  @byte_offset: EEPROM byte offset to read
+ *  @eeprom_data: value read
+ *
+ *  Performs byte read operation to SFP module's EEPROM over I2C interface.
+ **/
+s32 ixgbe_read_i2c_eeprom_generic(struct ixgbe_hw *hw, u8 byte_offset,
+                                  u8 *eeprom_data)
+{
+	return hw->phy.ops.read_i2c_byte(hw, byte_offset,
+	                                 IXGBE_I2C_EEPROM_DEV_ADDR,
+	                                 eeprom_data);
+}
+
+/**
+ *  ixgbe_write_i2c_eeprom_generic - Writes 8 bit EEPROM word over I2C interface
+ *  @hw: pointer to hardware structure
+ *  @byte_offset: EEPROM byte offset to write
+ *  @eeprom_data: value to write
+ *
+ *  Performs byte write operation to SFP module's EEPROM over I2C interface.
+ **/
+s32 ixgbe_write_i2c_eeprom_generic(struct ixgbe_hw *hw, u8 byte_offset,
+                                   u8 eeprom_data)
+{
+	return hw->phy.ops.write_i2c_byte(hw, byte_offset,
+	                                  IXGBE_I2C_EEPROM_DEV_ADDR,
+	                                  eeprom_data);
+}
+
+/**
+ *  ixgbe_read_i2c_byte_generic - Reads 8 bit word over I2C
+ *  @hw: pointer to hardware structure
+ *  @byte_offset: byte offset to read
+ *  @data: value read
+ *
+ *  Performs byte read operation to SFP module's EEPROM over I2C interface at
+ *  a specified deivce address.
+ **/
+s32 ixgbe_read_i2c_byte_generic(struct ixgbe_hw *hw, u8 byte_offset,
+                                u8 dev_addr, u8 *data)
+{
+	s32 status = 0;
+	u32 max_retry = 1;
+	u32 retry = 0;
+	bool nack = 1;
+
+	do {
+		ixgbe_i2c_start(hw);
+
+		/* Device Address and write indication */
+		status = ixgbe_clock_out_i2c_byte(hw, dev_addr);
+		if (status != 0)
+			goto fail;
+
+		status = ixgbe_get_i2c_ack(hw);
+		if (status != 0)
+			goto fail;
+
+		status = ixgbe_clock_out_i2c_byte(hw, byte_offset);
+		if (status != 0)
+			goto fail;
+
+		status = ixgbe_get_i2c_ack(hw);
+		if (status != 0)
+			goto fail;
+
+		ixgbe_i2c_start(hw);
+
+		/* Device Address and read indication */
+		status = ixgbe_clock_out_i2c_byte(hw, (dev_addr | 0x1));
+		if (status != 0)
+			goto fail;
+
+		status = ixgbe_get_i2c_ack(hw);
+		if (status != 0)
+			goto fail;
+
+		status = ixgbe_clock_in_i2c_byte(hw, data);
+		if (status != 0)
+			goto fail;
+
+		status = ixgbe_clock_out_i2c_bit(hw, nack);
+		if (status != 0)
+			goto fail;
+
+		ixgbe_i2c_stop(hw);
+		break;
+
+fail:
+		ixgbe_i2c_bus_clear(hw);
+		retry++;
+		if (retry < max_retry)
+			hw_dbg(hw, "I2C byte read error - Retrying.\n");
+		else
+			hw_dbg(hw, "I2C byte read error.\n");
+
+	} while (retry < max_retry);
+
+	return status;
+}
+
+/**
+ *  ixgbe_write_i2c_byte_generic - Writes 8 bit word over I2C
+ *  @hw: pointer to hardware structure
+ *  @byte_offset: byte offset to write
+ *  @data: value to write
+ *
+ *  Performs byte write operation to SFP module's EEPROM over I2C interface at
+ *  a specified device address.
+ **/
+s32 ixgbe_write_i2c_byte_generic(struct ixgbe_hw *hw, u8 byte_offset,
+                                 u8 dev_addr, u8 data)
+{
+	s32 status = 0;
+	u32 max_retry = 1;
+	u32 retry = 0;
+
+	do {
+		ixgbe_i2c_start(hw);
+
+		status = ixgbe_clock_out_i2c_byte(hw, dev_addr);
+		if (status != 0)
+			goto fail;
+
+		status = ixgbe_get_i2c_ack(hw);
+		if (status != 0)
+			goto fail;
+
+		status = ixgbe_clock_out_i2c_byte(hw, byte_offset);
+		if (status != 0)
+			goto fail;
+
+		status = ixgbe_get_i2c_ack(hw);
+		if (status != 0)
+			goto fail;
+
+		status = ixgbe_clock_out_i2c_byte(hw, data);
+		if (status != 0)
+			goto fail;
+
+		status = ixgbe_get_i2c_ack(hw);
+		if (status != 0)
+			goto fail;
+
+		ixgbe_i2c_stop(hw);
+		break;
+
+fail:
+		ixgbe_i2c_bus_clear(hw);
+		retry++;
+		if (retry < max_retry)
+			hw_dbg(hw, "I2C byte write error - Retrying.\n");
+		else
+			hw_dbg(hw, "I2C byte write error.\n");
+	} while (retry < max_retry);
+
+	return status;
+}
+
+/**
+ *  ixgbe_i2c_start - Sets I2C start condition
+ *  @hw: pointer to hardware structure
+ *
+ *  Sets I2C start condition (High -> Low on SDA while SCL is High)
+ **/
+static void ixgbe_i2c_start(struct ixgbe_hw *hw)
+{
+	u32 i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL);
+
+	/* Start condition must begin with data and clock high */
+	ixgbe_set_i2c_data(hw, &i2cctl, 1);
+	ixgbe_raise_i2c_clk(hw, &i2cctl);
+
+	/* Setup time for start condition (4.7us) */
+	udelay(IXGBE_I2C_T_SU_STA);
+
+	ixgbe_set_i2c_data(hw, &i2cctl, 0);
+
+	/* Hold time for start condition (4us) */
+	udelay(IXGBE_I2C_T_HD_STA);
+
+	ixgbe_lower_i2c_clk(hw, &i2cctl);
+
+	/* Minimum low period of clock is 4.7 us */
+	udelay(IXGBE_I2C_T_LOW);
+
+}
+
+/**
+ *  ixgbe_i2c_stop - Sets I2C stop condition
+ *  @hw: pointer to hardware structure
+ *
+ *  Sets I2C stop condition (Low -> High on SDA while SCL is High)
+ **/
+static void ixgbe_i2c_stop(struct ixgbe_hw *hw)
+{
+	u32 i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL);
+
+	/* Stop condition must begin with data low and clock high */
+	ixgbe_set_i2c_data(hw, &i2cctl, 0);
+	ixgbe_raise_i2c_clk(hw, &i2cctl);
+
+	/* Setup time for stop condition (4us) */
+	udelay(IXGBE_I2C_T_SU_STO);
+
+	ixgbe_set_i2c_data(hw, &i2cctl, 1);
+
+	/* bus free time between stop and start (4.7us)*/
+	udelay(IXGBE_I2C_T_BUF);
+}
+
+/**
+ *  ixgbe_clock_in_i2c_byte - Clocks in one byte via I2C
+ *  @hw: pointer to hardware structure
+ *  @data: data byte to clock in
+ *
+ *  Clocks in one byte data via I2C data/clock
+ **/
+static s32 ixgbe_clock_in_i2c_byte(struct ixgbe_hw *hw, u8 *data)
+{
+	s32 status = 0;
+	s32 i;
+	bool bit = 0;
+
+	for (i = 7; i >= 0; i--) {
+		status = ixgbe_clock_in_i2c_bit(hw, &bit);
+		*data |= bit << i;
+
+		if (status != 0)
+			break;
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_clock_out_i2c_byte - Clocks out one byte via I2C
+ *  @hw: pointer to hardware structure
+ *  @data: data byte clocked out
+ *
+ *  Clocks out one byte data via I2C data/clock
+ **/
+static s32 ixgbe_clock_out_i2c_byte(struct ixgbe_hw *hw, u8 data)
+{
+	s32 status = 0;
+	s32 i;
+	u32 i2cctl;
+	bool bit = 0;
+
+	for (i = 7; i >= 0; i--) {
+		bit = (data >> i) & 0x1;
+		status = ixgbe_clock_out_i2c_bit(hw, bit);
+
+		if (status != 0)
+			break;
+	}
+
+	/* Release SDA line (set high) */
+	i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL);
+	i2cctl |= IXGBE_I2C_DATA_OUT;
+	IXGBE_WRITE_REG(hw, IXGBE_I2CCTL, i2cctl);
+
+	return status;
+}
+
+/**
+ *  ixgbe_get_i2c_ack - Polls for I2C ACK
+ *  @hw: pointer to hardware structure
+ *
+ *  Clocks in/out one bit via I2C data/clock
+ **/
+static s32 ixgbe_get_i2c_ack(struct ixgbe_hw *hw)
+{
+	s32 status;
+	u32 i = 0;
+	u32 i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL);
+	u32 timeout = 10;
+	bool ack = 1;
+
+	status = ixgbe_raise_i2c_clk(hw, &i2cctl);
+
+	if (status != 0)
+		goto out;
+
+	/* Minimum high period of clock is 4us */
+	udelay(IXGBE_I2C_T_HIGH);
+
+	/* Poll for ACK.  Note that ACK in I2C spec is
+	 * transition from 1 to 0 */
+	for (i = 0; i < timeout; i++) {
+		i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL);
+		ack = ixgbe_get_i2c_data(&i2cctl);
+
+		udelay(1);
+		if (ack == 0)
+			break;
+	}
+
+	if (ack == 1) {
+		hw_dbg(hw, "I2C ack was not received.\n");
+		status = IXGBE_ERR_I2C;
+	}
+
+	ixgbe_lower_i2c_clk(hw, &i2cctl);
+
+	/* Minimum low period of clock is 4.7 us */
+	udelay(IXGBE_I2C_T_LOW);
+
+out:
+	return status;
+}
+
+/**
+ *  ixgbe_clock_in_i2c_bit - Clocks in one bit via I2C data/clock
+ *  @hw: pointer to hardware structure
+ *  @data: read data value
+ *
+ *  Clocks in one bit via I2C data/clock
+ **/
+static s32 ixgbe_clock_in_i2c_bit(struct ixgbe_hw *hw, bool *data)
+{
+	s32 status;
+	u32 i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL);
+
+	status = ixgbe_raise_i2c_clk(hw, &i2cctl);
+
+	/* Minimum high period of clock is 4us */
+	udelay(IXGBE_I2C_T_HIGH);
+
+	i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL);
+	*data = ixgbe_get_i2c_data(&i2cctl);
+
+	ixgbe_lower_i2c_clk(hw, &i2cctl);
+
+	/* Minimum low period of clock is 4.7 us */
+	udelay(IXGBE_I2C_T_LOW);
+
+	return status;
+}
+
+/**
+ *  ixgbe_clock_out_i2c_bit - Clocks in/out one bit via I2C data/clock
+ *  @hw: pointer to hardware structure
+ *  @data: data value to write
+ *
+ *  Clocks out one bit via I2C data/clock
+ **/
+static s32 ixgbe_clock_out_i2c_bit(struct ixgbe_hw *hw, bool data)
+{
+	s32 status;
+	u32 i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL);
+
+	status = ixgbe_set_i2c_data(hw, &i2cctl, data);
+	if (status == 0) {
+		status = ixgbe_raise_i2c_clk(hw, &i2cctl);
+
+		/* Minimum high period of clock is 4us */
+		udelay(IXGBE_I2C_T_HIGH);
+
+		ixgbe_lower_i2c_clk(hw, &i2cctl);
+
+		/* Minimum low period of clock is 4.7 us.
+		 * This also takes care of the data hold time.
+		 */
+		udelay(IXGBE_I2C_T_LOW);
+	} else {
+		status = IXGBE_ERR_I2C;
+		hw_dbg(hw, "I2C data was not set to %X\n", data);
+	}
+
+	return status;
+}
+/**
+ *  ixgbe_raise_i2c_clk - Raises the I2C SCL clock
+ *  @hw: pointer to hardware structure
+ *  @i2cctl: Current value of I2CCTL register
+ *
+ *  Raises the I2C clock line '0'->'1'
+ **/
+static s32 ixgbe_raise_i2c_clk(struct ixgbe_hw *hw, u32 *i2cctl)
+{
+	s32 status = 0;
+
+	*i2cctl |= IXGBE_I2C_CLK_OUT;
+
+	IXGBE_WRITE_REG(hw, IXGBE_I2CCTL, *i2cctl);
+
+	/* SCL rise time (1000ns) */
+	udelay(IXGBE_I2C_T_RISE);
+
+	return status;
+}
+
+/**
+ *  ixgbe_lower_i2c_clk - Lowers the I2C SCL clock
+ *  @hw: pointer to hardware structure
+ *  @i2cctl: Current value of I2CCTL register
+ *
+ *  Lowers the I2C clock line '1'->'0'
+ **/
+static void ixgbe_lower_i2c_clk(struct ixgbe_hw *hw, u32 *i2cctl)
+{
+
+	*i2cctl &= ~IXGBE_I2C_CLK_OUT;
+
+	IXGBE_WRITE_REG(hw, IXGBE_I2CCTL, *i2cctl);
+
+	/* SCL fall time (300ns) */
+	udelay(IXGBE_I2C_T_FALL);
+}
+
+/**
+ *  ixgbe_set_i2c_data - Sets the I2C data bit
+ *  @hw: pointer to hardware structure
+ *  @i2cctl: Current value of I2CCTL register
+ *  @data: I2C data value (0 or 1) to set
+ *
+ *  Sets the I2C data bit
+ **/
+static s32 ixgbe_set_i2c_data(struct ixgbe_hw *hw, u32 *i2cctl, bool data)
+{
+	s32 status = 0;
+
+	if (data)
+		*i2cctl |= IXGBE_I2C_DATA_OUT;
+	else
+		*i2cctl &= ~IXGBE_I2C_DATA_OUT;
+
+	IXGBE_WRITE_REG(hw, IXGBE_I2CCTL, *i2cctl);
+
+	/* Data rise/fall (1000ns/300ns) and set-up time (250ns) */
+	udelay(IXGBE_I2C_T_RISE + IXGBE_I2C_T_FALL + IXGBE_I2C_T_SU_DATA);
+
+	/* Verify data was set correctly */
+	*i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL);
+	if (data != ixgbe_get_i2c_data(i2cctl)) {
+		status = IXGBE_ERR_I2C;
+		hw_dbg(hw, "Error - I2C data was not set to %X.\n", data);
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_get_i2c_data - Reads the I2C SDA data bit
+ *  @hw: pointer to hardware structure
+ *  @i2cctl: Current value of I2CCTL register
+ *
+ *  Returns the I2C data bit value
+ **/
+static bool ixgbe_get_i2c_data(u32 *i2cctl)
+{
+	bool data;
+
+	if (*i2cctl & IXGBE_I2C_DATA_IN)
+		data = 1;
+	else
+		data = 0;
+
+	return data;
+}
+
+/**
+ *  ixgbe_i2c_bus_clear - Clears the I2C bus
+ *  @hw: pointer to hardware structure
+ *
+ *  Clears the I2C bus by sending nine clock pulses.
+ *  Used when data line is stuck low.
+ **/
+static void ixgbe_i2c_bus_clear(struct ixgbe_hw *hw)
+{
+	u32 i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL);
+	u32 i;
+
+	ixgbe_set_i2c_data(hw, &i2cctl, 1);
+
+	for (i = 0; i < 9; i++) {
+		ixgbe_raise_i2c_clk(hw, &i2cctl);
+
+		/* Min high period of clock is 4us */
+		udelay(IXGBE_I2C_T_HIGH);
+
+		ixgbe_lower_i2c_clk(hw, &i2cctl);
+
+		/* Min low period of clock is 4.7us*/
+		udelay(IXGBE_I2C_T_LOW);
+	}
+
+	/* Put the i2c bus back to default state */
+	ixgbe_i2c_stop(hw);
+}
+
+/**
  *  ixgbe_check_phy_link_tnx - Determine link and speed status
  *  @hw: pointer to hardware structure
  *
diff --git a/drivers/net/ixgbe/ixgbe_phy.h b/drivers/net/ixgbe/ixgbe_phy.h
index 539a306..cc5f1b3 100644
--- a/drivers/net/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ixgbe/ixgbe_phy.h
@@ -54,14 +54,15 @@
 #define IXGBE_I2C_EEPROM_STATUS_IN_PROGRESS  0x3
 
 /* Bit-shift macros */
-#define IXGBE_SFF_VENDOR_OUI_BYTE0_SHIFT    12
-#define IXGBE_SFF_VENDOR_OUI_BYTE1_SHIFT    8
-#define IXGBE_SFF_VENDOR_OUI_BYTE2_SHIFT    4
+#define IXGBE_SFF_VENDOR_OUI_BYTE0_SHIFT    24
+#define IXGBE_SFF_VENDOR_OUI_BYTE1_SHIFT    16
+#define IXGBE_SFF_VENDOR_OUI_BYTE2_SHIFT    8
 
 /* Vendor OUIs: format of OUI is 0x[byte0][byte1][byte2][00] */
 #define IXGBE_SFF_VENDOR_OUI_TYCO     0x00407600
 #define IXGBE_SFF_VENDOR_OUI_FTL      0x00906500
 #define IXGBE_SFF_VENDOR_OUI_AVAGO    0x00176A00
+#define IXGBE_SFF_VENDOR_OUI_INTEL    0x001B2100
 
 /* I2C SDA and SCL timing parameters for standard mode */
 #define IXGBE_I2C_T_HD_STA  4
@@ -101,5 +102,12 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw);
 s32 ixgbe_get_sfp_init_sequence_offsets(struct ixgbe_hw *hw,
                                         u16 *list_offset,
                                         u16 *data_offset);
-
+s32 ixgbe_read_i2c_byte_generic(struct ixgbe_hw *hw, u8 byte_offset,
+                                u8 dev_addr, u8 *data);
+s32 ixgbe_write_i2c_byte_generic(struct ixgbe_hw *hw, u8 byte_offset,
+                                 u8 dev_addr, u8 data);
+s32 ixgbe_read_i2c_eeprom_generic(struct ixgbe_hw *hw, u8 byte_offset,
+                                  u8 *eeprom_data);
+s32 ixgbe_write_i2c_eeprom_generic(struct ixgbe_hw *hw, u8 byte_offset,
+                                   u8 eeprom_data);
 #endif /* _IXGBE_PHY_H_ */
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 237c688..6090593 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -45,6 +45,9 @@
 #define IXGBE_DEV_ID_82598_DA_DUAL_PORT  0x10F1
 #define IXGBE_DEV_ID_82598_SR_DUAL_PORT_EM      0x10E1
 #define IXGBE_DEV_ID_82598EB_XF_LR       0x10F4
+#define IXGBE_DEV_ID_82599               0x10D8
+#define IXGBE_DEV_ID_82599_KX4           0x10F7
+#define IXGBE_DEV_ID_82599_SFP           0x10FB
 
 /* General Registers */
 #define IXGBE_CTRL      0x00000
@@ -52,9 +55,12 @@
 #define IXGBE_CTRL_EXT  0x00018
 #define IXGBE_ESDP      0x00020
 #define IXGBE_EODSDP    0x00028
+#define IXGBE_I2CCTL    0x00028
 #define IXGBE_LEDCTL    0x00200
 #define IXGBE_FRTIMER   0x00048
 #define IXGBE_TCPTIMER  0x0004C
+#define IXGBE_CORESPARE 0x00600
+#define IXGBE_EXVET     0x05078
 
 /* NVM Registers */
 #define IXGBE_EEC       0x10010
@@ -68,6 +74,19 @@
 #define IXGBE_FLOP      0x1013C
 #define IXGBE_GRC       0x10200
 
+/* General Receive Control */
+#define IXGBE_GRC_MNG  0x00000001 /* Manageability Enable */
+#define IXGBE_GRC_APME 0x00000002 /* Advanced Power Management Enable */
+
+#define IXGBE_VPDDIAG0  0x10204
+#define IXGBE_VPDDIAG1  0x10208
+
+/* I2CCTL Bit Masks */
+#define IXGBE_I2C_CLK_IN    0x00000001
+#define IXGBE_I2C_CLK_OUT   0x00000002
+#define IXGBE_I2C_DATA_IN   0x00000004
+#define IXGBE_I2C_DATA_OUT  0x00000008
+
 /* Interrupt Registers */
 #define IXGBE_EICR      0x00800
 #define IXGBE_EICS      0x00808
@@ -75,28 +94,54 @@
 #define IXGBE_EIMC      0x00888
 #define IXGBE_EIAC      0x00810
 #define IXGBE_EIAM      0x00890
-#define IXGBE_EITR(_i)  (((_i) <= 23) ? (0x00820 + ((_i) * 4)) : (0x012300 + ((_i) * 4)))
+#define IXGBE_EICS_EX(_i)   (0x00A90 + (_i) * 4)
+#define IXGBE_EIMS_EX(_i)   (0x00AA0 + (_i) * 4)
+#define IXGBE_EIMC_EX(_i)   (0x00AB0 + (_i) * 4)
+#define IXGBE_EIAM_EX(_i)   (0x00AD0 + (_i) * 4)
+#define IXGBE_EITR(_i)  (((_i) <= 23) ? (0x00820 + ((_i) * 4)) : \
+                         (0x012300 + (((_i) - 24) * 4)))
+#define IXGBE_EITR_ITR_INT_MASK 0x00000FFF
+#define IXGBE_EITR_LLI_MOD      0x00008000
+#define IXGBE_EITR_CNT_WDIS     0x80000000
 #define IXGBE_IVAR(_i)  (0x00900 + ((_i) * 4)) /* 24 at 0x900-0x960 */
+#define IXGBE_IVAR_MISC 0x00A00 /* misc MSI-X interrupt causes */
+#define IXGBE_EITRSEL   0x00894
 #define IXGBE_MSIXT     0x00000 /* MSI-X Table. 0x0000 - 0x01C */
 #define IXGBE_MSIXPBA   0x02000 /* MSI-X Pending bit array */
 #define IXGBE_PBACL(_i) (((_i) == 0) ? (0x11068) : (0x110C0 + ((_i) * 4)))
 #define IXGBE_GPIE      0x00898
 
 /* Flow Control Registers */
+#define IXGBE_FCADBUL   0x03210
+#define IXGBE_FCADBUH   0x03214
+#define IXGBE_FCAMACL   0x04328
+#define IXGBE_FCAMACH   0x0432C
+#define IXGBE_FCRTH_82599(_i) (0x03260 + ((_i) * 4)) /* 8 of these (0-7) */
+#define IXGBE_FCRTL_82599(_i) (0x03220 + ((_i) * 4)) /* 8 of these (0-7) */
 #define IXGBE_PFCTOP    0x03008
 #define IXGBE_FCTTV(_i) (0x03200 + ((_i) * 4)) /* 4 of these (0-3) */
 #define IXGBE_FCRTL(_i) (0x03220 + ((_i) * 8)) /* 8 of these (0-7) */
 #define IXGBE_FCRTH(_i) (0x03260 + ((_i) * 8)) /* 8 of these (0-7) */
 #define IXGBE_FCRTV     0x032A0
+#define IXGBE_FCCFG     0x03D00
 #define IXGBE_TFCS      0x0CE00
 
 /* Receive DMA Registers */
-#define IXGBE_RDBAL(_i) (((_i) < 64) ? (0x01000 + ((_i) * 0x40)) : (0x0D000 + ((_i - 64) * 0x40)))
-#define IXGBE_RDBAH(_i) (((_i) < 64) ? (0x01004 + ((_i) * 0x40)) : (0x0D004 + ((_i - 64) * 0x40)))
-#define IXGBE_RDLEN(_i) (((_i) < 64) ? (0x01008 + ((_i) * 0x40)) : (0x0D008 + ((_i - 64) * 0x40)))
-#define IXGBE_RDH(_i)   (((_i) < 64) ? (0x01010 + ((_i) * 0x40)) : (0x0D010 + ((_i - 64) * 0x40)))
-#define IXGBE_RDT(_i)   (((_i) < 64) ? (0x01018 + ((_i) * 0x40)) : (0x0D018 + ((_i - 64) * 0x40)))
-#define IXGBE_RXDCTL(_i) (((_i) < 64) ? (0x01028 + ((_i) * 0x40)) : (0x0D028 + ((_i - 64) * 0x40)))
+#define IXGBE_RDBAL(_i) (((_i) < 64) ? (0x01000 + ((_i) * 0x40)) : \
+                         (0x0D000 + ((_i - 64) * 0x40)))
+#define IXGBE_RDBAH(_i) (((_i) < 64) ? (0x01004 + ((_i) * 0x40)) : \
+                         (0x0D004 + ((_i - 64) * 0x40)))
+#define IXGBE_RDLEN(_i) (((_i) < 64) ? (0x01008 + ((_i) * 0x40)) : \
+                         (0x0D008 + ((_i - 64) * 0x40)))
+#define IXGBE_RDH(_i)   (((_i) < 64) ? (0x01010 + ((_i) * 0x40)) : \
+                         (0x0D010 + ((_i - 64) * 0x40)))
+#define IXGBE_RDT(_i)   (((_i) < 64) ? (0x01018 + ((_i) * 0x40)) : \
+                         (0x0D018 + ((_i - 64) * 0x40)))
+#define IXGBE_RXDCTL(_i) (((_i) < 64) ? (0x01028 + ((_i) * 0x40)) : \
+                          (0x0D028 + ((_i - 64) * 0x40)))
+#define IXGBE_RDDCC      0x02F20
+#define IXGBE_RXMEMWRAP  0x03190
+#define IXGBE_STARCTRL   0x03024
 /*
  * Split and Replication Receive Control Registers
  * 00-15 : 0x02100 + n*4
@@ -129,10 +174,15 @@
 #define IXGBE_DRECCCTL_DISABLE 0
 /* Multicast Table Array - 128 entries */
 #define IXGBE_MTA(_i)   (0x05200 + ((_i) * 4))
-#define IXGBE_RAL(_i)   (((_i) <= 15) ? (0x05400 + ((_i) * 8)) : (0x0A200 + ((_i) * 8)))
-#define IXGBE_RAH(_i)   (((_i) <= 15) ? (0x05404 + ((_i) * 8)) : (0x0A204 + ((_i) * 8)))
+#define IXGBE_RAL(_i)   (((_i) <= 15) ? (0x05400 + ((_i) * 8)) : \
+                         (0x0A200 + ((_i) * 8)))
+#define IXGBE_RAH(_i)   (((_i) <= 15) ? (0x05404 + ((_i) * 8)) : \
+                         (0x0A204 + ((_i) * 8)))
+#define IXGBE_MPSAR_LO(_i) (0x0A600 + ((_i) * 8))
+#define IXGBE_MPSAR_HI(_i) (0x0A604 + ((_i) * 8))
 /* Packet split receive type */
-#define IXGBE_PSRTYPE(_i)    (((_i) <= 15) ? (0x05480 + ((_i) * 4)) : (0x0EA00 + ((_i) * 4)))
+#define IXGBE_PSRTYPE(_i)    (((_i) <= 15) ? (0x05480 + ((_i) * 4)) : \
+                              (0x0EA00 + ((_i) * 4)))
 /* array of 4096 1-bit vlan filters */
 #define IXGBE_VFTA(_i)  (0x0A000 + ((_i) * 4))
 /*array of 4096 4-bit vlan vmdq indices */
@@ -141,6 +191,28 @@
 #define IXGBE_VLNCTRL   0x05088
 #define IXGBE_MCSTCTRL  0x05090
 #define IXGBE_MRQC      0x05818
+#define IXGBE_SAQF(_i)  (0x0E000 + ((_i) * 4)) /* Source Address Queue Filter */
+#define IXGBE_DAQF(_i)  (0x0E200 + ((_i) * 4)) /* Dest. Address Queue Filter */
+#define IXGBE_SDPQF(_i) (0x0E400 + ((_i) * 4)) /* Src Dest. Addr Queue Filter */
+#define IXGBE_FTQF(_i)  (0x0E600 + ((_i) * 4)) /* Five Tuple Queue Filter */
+#define IXGBE_ETQF(_i)  (0x05128 + ((_i) * 4)) /* EType Queue Filter */
+#define IXGBE_ETQS(_i)  (0x0EC00 + ((_i) * 4)) /* EType Queue Select */
+#define IXGBE_SYNQF     0x0EC30 /* SYN Packet Queue Filter */
+#define IXGBE_RQTC      0x0EC70
+#define IXGBE_MTQC      0x08120
+#define IXGBE_VLVF(_i)  (0x0F100 + ((_i) * 4))  /* 64 of these (0-63) */
+#define IXGBE_VLVFB(_i) (0x0F200 + ((_i) * 4))  /* 128 of these (0-127) */
+#define IXGBE_VT_CTL    0x051B0
+#define IXGBE_VFRE(_i)  (0x051E0 + ((_i) * 4))
+#define IXGBE_VFTE(_i)  (0x08110 + ((_i) * 4))
+#define IXGBE_QDE       0x2F04
+#define IXGBE_VMOLR(_i) (0x0F000 + ((_i) * 4)) /* 64 total */
+#define IXGBE_UTA(_i)   (0x0F400 + ((_i) * 4))
+#define IXGBE_VMRCTL(_i)        (0x0F600 + ((_i) * 4))
+#define IXGBE_VMRVLAN(_i)       (0x0F610 + ((_i) * 4))
+#define IXGBE_VMRVM(_i)         (0x0F630 + ((_i) * 4))
+#define IXGBE_L34T_IMIR(_i)      (0x0E800 + ((_i) * 4)) /*128 of these (0-127)*/
+#define IXGBE_LLITHRESH 0x0EC90
 #define IXGBE_IMIR(_i)  (0x05A80 + ((_i) * 4))  /* 8 of these (0-7) */
 #define IXGBE_IMIREXT(_i)       (0x05AA0 + ((_i) * 4))  /* 8 of these (0-7) */
 #define IXGBE_IMIRVP    0x05AC0
@@ -148,7 +220,6 @@
 #define IXGBE_RETA(_i)  (0x05C00 + ((_i) * 4))  /* 32 of these (0-31) */
 #define IXGBE_RSSRK(_i) (0x05C80 + ((_i) * 4))  /* 10 of these (0-9) */
 
-
 /* Transmit DMA registers */
 #define IXGBE_TDBAL(_i) (0x06000 + ((_i) * 0x40)) /* 32 of these (0-31)*/
 #define IXGBE_TDBAH(_i) (0x06004 + ((_i) * 0x40))
@@ -160,7 +231,20 @@
 #define IXGBE_TDWBAH(_i) (0x0603C + ((_i) * 0x40))
 #define IXGBE_DTXCTL    0x07E00
 
+#define IXGBE_DMATXCTL  0x04A80
+#define IXGBE_DTXMXSZRQ     0x08100
+#define IXGBE_DTXTCPFLGL    0x04A88
+#define IXGBE_DTXTCPFLGH    0x04A8C
+#define IXGBE_LBDRPEN       0x0CA00
+#define IXGBE_TXPBTHRESH(_i) (0x04950 + ((_i) * 4)) /* 8 of these 0 - 7 */
+
+#define IXGBE_DMATXCTL_TE       0x1 /* Transmit Enable */
+#define IXGBE_DMATXCTL_NS       0x2 /* No Snoop LSO hdr buffer */
+#define IXGBE_DMATXCTL_GDV      0x8 /* Global Double VLAN */
+#define IXGBE_DMATXCTL_VT_SHIFT 16  /* VLAN EtherType */
 #define IXGBE_DCA_TXCTRL(_i)    (0x07200 + ((_i) * 4)) /* 16 of these (0-15) */
+/* Tx DCA Control register : 128 of these (0-127) */
+#define IXGBE_DCA_TXCTRL_82599(_i)  (0x0600C + ((_i) * 0x40))
 #define IXGBE_TIPG      0x0CB00
 #define IXGBE_TXPBSIZE(_i)      (0x0CC00 + ((_i) * 4)) /* 8 of these */
 #define IXGBE_MNGTXMAP  0x0CD10
@@ -177,9 +261,69 @@
 
 #define IXGBE_WUPL      0x05900
 #define IXGBE_WUPM      0x05A00 /* wake up pkt memory 0x5A00-0x5A7C */
-#define IXGBE_FHFT      0x09000 /* Flex host filter table 9000-93FC */
-
-/* Music registers */
+#define IXGBE_FHFT(_n)     (0x09000 + (_n * 0x100)) /* Flex host filter table */
+#define IXGBE_FHFT_EXT(_n) (0x09800 + (_n * 0x100)) /* Ext Flexible Host
+                                                     * Filter Table */
+
+#define IXGBE_FLEXIBLE_FILTER_COUNT_MAX         4
+#define IXGBE_EXT_FLEXIBLE_FILTER_COUNT_MAX     2
+
+/* Each Flexible Filter is at most 128 (0x80) bytes in length */
+#define IXGBE_FLEXIBLE_FILTER_SIZE_MAX  128
+#define IXGBE_FHFT_LENGTH_OFFSET        0xFC  /* Length byte in FHFT */
+#define IXGBE_FHFT_LENGTH_MASK          0x0FF /* Length in lower byte */
+
+/* Definitions for power management and wakeup registers */
+/* Wake Up Control */
+#define IXGBE_WUC_PME_EN     0x00000002 /* PME Enable */
+#define IXGBE_WUC_PME_STATUS 0x00000004 /* PME Status */
+#define IXGBE_WUC_ADVD3WUC   0x00000010 /* D3Cold wake up cap. enable*/
+
+/* Wake Up Filter Control */
+#define IXGBE_WUFC_LNKC 0x00000001 /* Link Status Change Wakeup Enable */
+#define IXGBE_WUFC_MAG  0x00000002 /* Magic Packet Wakeup Enable */
+#define IXGBE_WUFC_EX   0x00000004 /* Directed Exact Wakeup Enable */
+#define IXGBE_WUFC_MC   0x00000008 /* Directed Multicast Wakeup Enable */
+#define IXGBE_WUFC_BC   0x00000010 /* Broadcast Wakeup Enable */
+#define IXGBE_WUFC_ARP  0x00000020 /* ARP Request Packet Wakeup Enable */
+#define IXGBE_WUFC_IPV4 0x00000040 /* Directed IPv4 Packet Wakeup Enable */
+#define IXGBE_WUFC_IPV6 0x00000080 /* Directed IPv6 Packet Wakeup Enable */
+#define IXGBE_WUFC_MNG  0x00000100 /* Directed Mgmt Packet Wakeup Enable */
+
+#define IXGBE_WUFC_IGNORE_TCO   0x00008000 /* Ignore WakeOn TCO packets */
+#define IXGBE_WUFC_FLX0 0x00010000 /* Flexible Filter 0 Enable */
+#define IXGBE_WUFC_FLX1 0x00020000 /* Flexible Filter 1 Enable */
+#define IXGBE_WUFC_FLX2 0x00040000 /* Flexible Filter 2 Enable */
+#define IXGBE_WUFC_FLX3 0x00080000 /* Flexible Filter 3 Enable */
+#define IXGBE_WUFC_FLX4 0x00100000 /* Flexible Filter 4 Enable */
+#define IXGBE_WUFC_FLX5 0x00200000 /* Flexible Filter 5 Enable */
+#define IXGBE_WUFC_FLX_FILTERS     0x000F0000 /* Mask for 4 flex filters */
+#define IXGBE_WUFC_EXT_FLX_FILTERS 0x00300000 /* Mask for Ext. flex filters */
+#define IXGBE_WUFC_ALL_FILTERS     0x003F00FF /* Mask for all 6 wakeup filters*/
+#define IXGBE_WUFC_FLX_OFFSET      16 /* Offset to the Flexible Filters bits */
+
+/* Wake Up Status */
+#define IXGBE_WUS_LNKC  IXGBE_WUFC_LNKC
+#define IXGBE_WUS_MAG   IXGBE_WUFC_MAG
+#define IXGBE_WUS_EX    IXGBE_WUFC_EX
+#define IXGBE_WUS_MC    IXGBE_WUFC_MC
+#define IXGBE_WUS_BC    IXGBE_WUFC_BC
+#define IXGBE_WUS_ARP   IXGBE_WUFC_ARP
+#define IXGBE_WUS_IPV4  IXGBE_WUFC_IPV4
+#define IXGBE_WUS_IPV6  IXGBE_WUFC_IPV6
+#define IXGBE_WUS_MNG   IXGBE_WUFC_MNG
+#define IXGBE_WUS_FLX0  IXGBE_WUFC_FLX0
+#define IXGBE_WUS_FLX1  IXGBE_WUFC_FLX1
+#define IXGBE_WUS_FLX2  IXGBE_WUFC_FLX2
+#define IXGBE_WUS_FLX3  IXGBE_WUFC_FLX3
+#define IXGBE_WUS_FLX4  IXGBE_WUFC_FLX4
+#define IXGBE_WUS_FLX5  IXGBE_WUFC_FLX5
+#define IXGBE_WUS_FLX_FILTERS  IXGBE_WUFC_FLX_FILTERS
+
+/* Wake Up Packet Length */
+#define IXGBE_WUPL_LENGTH_MASK 0xFFFF
+
+/* DCB registers */
 #define IXGBE_RMCS      0x03D00
 #define IXGBE_DPMCS     0x07F40
 #define IXGBE_PDPMCS    0x0CD00
@@ -192,6 +336,122 @@
 #define IXGBE_TDPT2TCSR(_i)     (0x0CD40 + ((_i) * 4)) /* 8 of these (0-7) */
 
 
+/* Security Control Registers */
+#define IXGBE_SECTXCTRL         0x08800
+#define IXGBE_SECTXSTAT         0x08804
+#define IXGBE_SECTXBUFFAF       0x08808
+#define IXGBE_SECTXMINIFG       0x08810
+#define IXGBE_SECTXSTAT         0x08804
+#define IXGBE_SECRXCTRL         0x08D00
+#define IXGBE_SECRXSTAT         0x08D04
+
+/* Security Bit Fields and Masks */
+#define IXGBE_SECTXCTRL_SECTX_DIS       0x00000001
+#define IXGBE_SECTXCTRL_TX_DIS          0x00000002
+#define IXGBE_SECTXCTRL_STORE_FORWARD   0x00000004
+
+#define IXGBE_SECTXSTAT_SECTX_RDY       0x00000001
+#define IXGBE_SECTXSTAT_ECC_TXERR       0x00000002
+
+#define IXGBE_SECRXCTRL_SECRX_DIS       0x00000001
+#define IXGBE_SECRXCTRL_RX_DIS          0x00000002
+
+#define IXGBE_SECRXSTAT_SECRX_RDY       0x00000001
+#define IXGBE_SECRXSTAT_ECC_RXERR       0x00000002
+
+/* LinkSec (MacSec) Registers */
+#define IXGBE_LSECTXCAP         0x08A00
+#define IXGBE_LSECRXCAP         0x08F00
+#define IXGBE_LSECTXCTRL        0x08A04
+#define IXGBE_LSECTXSCL         0x08A08 /* SCI Low */
+#define IXGBE_LSECTXSCH         0x08A0C /* SCI High */
+#define IXGBE_LSECTXSA          0x08A10
+#define IXGBE_LSECTXPN0         0x08A14
+#define IXGBE_LSECTXPN1         0x08A18
+#define IXGBE_LSECTXKEY0(_n)    (0x08A1C + (4 * (_n))) /* 4 of these (0-3) */
+#define IXGBE_LSECTXKEY1(_n)    (0x08A2C + (4 * (_n))) /* 4 of these (0-3) */
+#define IXGBE_LSECRXCTRL        0x08F04
+#define IXGBE_LSECRXSCL         0x08F08
+#define IXGBE_LSECRXSCH         0x08F0C
+#define IXGBE_LSECRXSA(_i)      (0x08F10 + (4 * (_i))) /* 2 of these (0-1) */
+#define IXGBE_LSECRXPN(_i)      (0x08F18 + (4 * (_i))) /* 2 of these (0-1) */
+#define IXGBE_LSECRXKEY(_n, _m) (0x08F20 + ((0x10 * (_n)) + (4 * (_m))))
+#define IXGBE_LSECTXUT          0x08A3C /* OutPktsUntagged */
+#define IXGBE_LSECTXPKTE        0x08A40 /* OutPktsEncrypted */
+#define IXGBE_LSECTXPKTP        0x08A44 /* OutPktsProtected */
+#define IXGBE_LSECTXOCTE        0x08A48 /* OutOctetsEncrypted */
+#define IXGBE_LSECTXOCTP        0x08A4C /* OutOctetsProtected */
+#define IXGBE_LSECRXUT          0x08F40 /* InPktsUntagged/InPktsNoTag */
+#define IXGBE_LSECRXOCTD        0x08F44 /* InOctetsDecrypted */
+#define IXGBE_LSECRXOCTV        0x08F48 /* InOctetsValidated */
+#define IXGBE_LSECRXBAD         0x08F4C /* InPktsBadTag */
+#define IXGBE_LSECRXNOSCI       0x08F50 /* InPktsNoSci */
+#define IXGBE_LSECRXUNSCI       0x08F54 /* InPktsUnknownSci */
+#define IXGBE_LSECRXUNCH        0x08F58 /* InPktsUnchecked */
+#define IXGBE_LSECRXDELAY       0x08F5C /* InPktsDelayed */
+#define IXGBE_LSECRXLATE        0x08F60 /* InPktsLate */
+#define IXGBE_LSECRXOK(_n)      (0x08F64 + (0x04 * (_n))) /* InPktsOk */
+#define IXGBE_LSECRXINV(_n)     (0x08F6C + (0x04 * (_n))) /* InPktsInvalid */
+#define IXGBE_LSECRXNV(_n)      (0x08F74 + (0x04 * (_n))) /* InPktsNotValid */
+#define IXGBE_LSECRXUNSA        0x08F7C /* InPktsUnusedSa */
+#define IXGBE_LSECRXNUSA        0x08F80 /* InPktsNotUsingSa */
+
+/* LinkSec (MacSec) Bit Fields and Masks */
+#define IXGBE_LSECTXCAP_SUM_MASK        0x00FF0000
+#define IXGBE_LSECTXCAP_SUM_SHIFT       16
+#define IXGBE_LSECRXCAP_SUM_MASK        0x00FF0000
+#define IXGBE_LSECRXCAP_SUM_SHIFT       16
+
+#define IXGBE_LSECTXCTRL_EN_MASK        0x00000003
+#define IXGBE_LSECTXCTRL_DISABLE        0x0
+#define IXGBE_LSECTXCTRL_AUTH           0x1
+#define IXGBE_LSECTXCTRL_AUTH_ENCRYPT   0x2
+#define IXGBE_LSECTXCTRL_AISCI          0x00000020
+#define IXGBE_LSECTXCTRL_PNTHRSH_MASK   0xFFFFFF00
+#define IXGBE_LSECTXCTRL_RSV_MASK       0x000000D8
+
+#define IXGBE_LSECRXCTRL_EN_MASK        0x0000000C
+#define IXGBE_LSECRXCTRL_EN_SHIFT       2
+#define IXGBE_LSECRXCTRL_DISABLE        0x0
+#define IXGBE_LSECRXCTRL_CHECK          0x1
+#define IXGBE_LSECRXCTRL_STRICT         0x2
+#define IXGBE_LSECRXCTRL_DROP           0x3
+#define IXGBE_LSECRXCTRL_PLSH           0x00000040
+#define IXGBE_LSECRXCTRL_RP             0x00000080
+#define IXGBE_LSECRXCTRL_RSV_MASK       0xFFFFFF33
+
+/* IpSec Registers */
+#define IXGBE_IPSTXIDX          0x08900
+#define IXGBE_IPSTXSALT         0x08904
+#define IXGBE_IPSTXKEY(_i)      (0x08908 + (4 * (_i))) /* 4 of these (0-3) */
+#define IXGBE_IPSRXIDX          0x08E00
+#define IXGBE_IPSRXIPADDR(_i)   (0x08E04 + (4 * (_i))) /* 4 of these (0-3) */
+#define IXGBE_IPSRXSPI          0x08E14
+#define IXGBE_IPSRXIPIDX        0x08E18
+#define IXGBE_IPSRXKEY(_i)      (0x08E1C + (4 * (_i))) /* 4 of these (0-3) */
+#define IXGBE_IPSRXSALT         0x08E2C
+#define IXGBE_IPSRXMOD          0x08E30
+
+#define IXGBE_SECTXCTRL_STORE_FORWARD_ENABLE    0x4
+
+/* DCB registers */
+#define IXGBE_RTRPCS      0x02430
+#define IXGBE_RTTDCS      0x04900
+#define IXGBE_RTTPCS      0x0CD00
+#define IXGBE_RTRUP2TC    0x03020
+#define IXGBE_RTTUP2TC    0x0C800
+#define IXGBE_RTRPT4C(_i) (0x02140 + ((_i) * 4)) /* 8 of these (0-7) */
+#define IXGBE_RTRPT4S(_i) (0x02160 + ((_i) * 4)) /* 8 of these (0-7) */
+#define IXGBE_RTTDT2C(_i) (0x04910 + ((_i) * 4)) /* 8 of these (0-7) */
+#define IXGBE_RTTDT2S(_i) (0x04930 + ((_i) * 4)) /* 8 of these (0-7) */
+#define IXGBE_RTTPT2C(_i) (0x0CD20 + ((_i) * 4)) /* 8 of these (0-7) */
+#define IXGBE_RTTPT2S(_i) (0x0CD40 + ((_i) * 4)) /* 8 of these (0-7) */
+#define IXGBE_RTTDQSEL    0x04904
+#define IXGBE_RTTDT1C     0x04908
+#define IXGBE_RTTDT1S     0x0490C
+#define IXGBE_RTTDTECC    0x04990
+#define IXGBE_RTTDTECC_NO_BCN   0x00000100
+#define IXGBE_RTTBCNRC    0x04984
 
 /* Stats registers */
 #define IXGBE_CRCERRS   0x04000
@@ -206,6 +466,11 @@
 #define IXGBE_LXONRXC   0x0CF60
 #define IXGBE_LXOFFTXC  0x03F68
 #define IXGBE_LXOFFRXC  0x0CF68
+#define IXGBE_LXONRXCNT 0x041A4
+#define IXGBE_LXOFFRXCNT 0x041A8
+#define IXGBE_PXONRXCNT(_i)     (0x04140 + ((_i) * 4)) /* 8 of these */
+#define IXGBE_PXOFFRXCNT(_i)    (0x04160 + ((_i) * 4)) /* 8 of these */
+#define IXGBE_PXON2OFFCNT(_i)   (0x03240 + ((_i) * 4)) /* 8 of these */
 #define IXGBE_PXONTXC(_i)       (0x03F00 + ((_i) * 4)) /* 8 of these 3F00-3F1C*/
 #define IXGBE_PXONRXC(_i)       (0x0CF00 + ((_i) * 4)) /* 8 of these CF00-CF1C*/
 #define IXGBE_PXOFFTXC(_i)      (0x03F20 + ((_i) * 4)) /* 8 of these 3F20-3F3C*/
@@ -245,14 +510,20 @@
 #define IXGBE_MPTC      0x040F0
 #define IXGBE_BPTC      0x040F4
 #define IXGBE_XEC       0x04120
+#define IXGBE_SSVPC     0x08780
 
-#define IXGBE_RQSMR(_i) (0x02300 + ((_i) * 4)) /* 16 of these */
-#define IXGBE_TQSMR(_i) (((_i) <= 7) ? (0x07300 + ((_i) * 4)) : (0x08600 + ((_i) * 4)))
+#define IXGBE_RQSMR(_i) (0x02300 + ((_i) * 4))
+#define IXGBE_TQSMR(_i) (((_i) <= 7) ? (0x07300 + ((_i) * 4)) : \
+                         (0x08600 + ((_i) * 4)))
+#define IXGBE_TQSM(_i)  (0x08600 + ((_i) * 4))
 
 #define IXGBE_QPRC(_i) (0x01030 + ((_i) * 0x40)) /* 16 of these */
 #define IXGBE_QPTC(_i) (0x06030 + ((_i) * 0x40)) /* 16 of these */
 #define IXGBE_QBRC(_i) (0x01034 + ((_i) * 0x40)) /* 16 of these */
 #define IXGBE_QBTC(_i) (0x06034 + ((_i) * 0x40)) /* 16 of these */
+#define IXGBE_QPRDC(_i) (0x01430 + ((_i) * 0x40)) /* 16 of these */
+#define IXGBE_QBTC_L(_i) (0x08700 + ((_i) * 0x8)) /* 16 of these */
+#define IXGBE_QBTC_H(_i) (0x08704 + ((_i) * 0x8)) /* 16 of these */
 
 /* Management */
 #define IXGBE_MAVTV(_i) (0x05010 + ((_i) * 4)) /* 8 of these (0-7) */
@@ -265,6 +536,9 @@
 #define IXGBE_MMAL(_i)  (0x05910 + ((_i) * 8)) /* 4 of these (0-3) */
 #define IXGBE_MMAH(_i)  (0x05914 + ((_i) * 8)) /* 4 of these (0-3) */
 #define IXGBE_FTFT      0x09400 /* 0x9400-0x97FC */
+#define IXGBE_METF(_i)  (0x05190 + ((_i) * 4)) /* 4 of these (0-3) */
+#define IXGBE_MDEF_EXT(_i) (0x05160 + ((_i) * 4)) /* 8 of these (0-7) */
+#define IXGBE_LSWFW     0x15014
 
 /* ARC Subsystem registers */
 #define IXGBE_HICR      0x15F00
@@ -297,16 +571,65 @@
 #define IXGBE_DCA_ID    0x11070
 #define IXGBE_DCA_CTRL  0x11074
 
+/* PCIe registers 82599-specific */
+#define IXGBE_GCR_EXT           0x11050
+#define IXGBE_GSCL_5_82599      0x11030
+#define IXGBE_GSCL_6_82599      0x11034
+#define IXGBE_GSCL_7_82599      0x11038
+#define IXGBE_GSCL_8_82599      0x1103C
+#define IXGBE_PHYADR_82599      0x11040
+#define IXGBE_PHYDAT_82599      0x11044
+#define IXGBE_PHYCTL_82599      0x11048
+#define IXGBE_PBACLR_82599      0x11068
+#define IXGBE_CIAA_82599        0x11088
+#define IXGBE_CIAD_82599        0x1108C
+#define IXGBE_PCIE_DIAG_0_82599 0x11090
+#define IXGBE_PCIE_DIAG_1_82599 0x11094
+#define IXGBE_PCIE_DIAG_2_82599 0x11098
+#define IXGBE_PCIE_DIAG_3_82599 0x1109C
+#define IXGBE_PCIE_DIAG_4_82599 0x110A0
+#define IXGBE_PCIE_DIAG_5_82599 0x110A4
+#define IXGBE_PCIE_DIAG_6_82599 0x110A8
+#define IXGBE_PCIE_DIAG_7_82599 0x110C0
+#define IXGBE_INTRPT_CSR_82599  0x110B0
+#define IXGBE_INTRPT_MASK_82599 0x110B8
+#define IXGBE_CDQ_MBR_82599     0x110B4
+#define IXGBE_MISC_REG_82599    0x110F0
+#define IXGBE_ECC_CTRL_0_82599  0x11100
+#define IXGBE_ECC_CTRL_1_82599  0x11104
+#define IXGBE_ECC_STATUS_82599  0x110E0
+#define IXGBE_BAR_CTRL_82599    0x110F4
+
+/* Time Sync Registers */
+#define IXGBE_TSYNCRXCTL 0x05188 /* Rx Time Sync Control register - RW */
+#define IXGBE_TSYNCTXCTL 0x08C00 /* Tx Time Sync Control register - RW */
+#define IXGBE_RXSTMPL    0x051E8 /* Rx timestamp Low - RO */
+#define IXGBE_RXSTMPH    0x051A4 /* Rx timestamp High - RO */
+#define IXGBE_RXSATRL    0x051A0 /* Rx timestamp attribute low - RO */
+#define IXGBE_RXSATRH    0x051A8 /* Rx timestamp attribute high - RO */
+#define IXGBE_RXMTRL     0x05120 /* RX message type register low - RW */
+#define IXGBE_TXSTMPL    0x08C04 /* Tx timestamp value Low - RO */
+#define IXGBE_TXSTMPH    0x08C08 /* Tx timestamp value High - RO */
+#define IXGBE_SYSTIML    0x08C0C /* System time register Low - RO */
+#define IXGBE_SYSTIMH    0x08C10 /* System time register High - RO */
+#define IXGBE_TIMINCA    0x08C14 /* Increment attributes register - RW */
+#define IXGBE_RXUDP      0x08C1C /* Time Sync Rx UDP Port - RW */
+
 /* Diagnostic Registers */
 #define IXGBE_RDSTATCTL   0x02C20
 #define IXGBE_RDSTAT(_i)  (0x02C00 + ((_i) * 4)) /* 0x02C00-0x02C1C */
 #define IXGBE_RDHMPN      0x02F08
 #define IXGBE_RIC_DW(_i)  (0x02F10 + ((_i) * 4))
 #define IXGBE_RDPROBE     0x02F20
+#define IXGBE_RDMAM       0x02F30
+#define IXGBE_RDMAD       0x02F34
 #define IXGBE_TDSTATCTL   0x07C20
 #define IXGBE_TDSTAT(_i)  (0x07C00 + ((_i) * 4)) /* 0x07C00 - 0x07C1C */
 #define IXGBE_TDHMPN      0x07F08
+#define IXGBE_TDHMPN2     0x082FC
+#define IXGBE_TXDESCIC    0x082CC
 #define IXGBE_TIC_DW(_i)  (0x07F10 + ((_i) * 4))
+#define IXGBE_TIC_DW2(_i) (0x082B0 + ((_i) * 4))
 #define IXGBE_TDPROBE     0x07F20
 #define IXGBE_TXBUFCTRL   0x0C600
 #define IXGBE_TXBUFDATA0  0x0C610
@@ -334,6 +657,8 @@
 #define IXGBE_TXDATARDPTR(_i)   (0x0C720 + ((_i) * 4)) /* 8 of these C720-C72C*/
 #define IXGBE_TXDESCRDPTR(_i)   (0x0C730 + ((_i) * 4)) /* 8 of these C730-C73C*/
 #define IXGBE_PCIEECCCTL 0x1106C
+#define IXGBE_PCIEECCCTL0 0x11100
+#define IXGBE_PCIEECCCTL1 0x11104
 #define IXGBE_PBTXECC   0x0C300
 #define IXGBE_PBRXECC   0x03300
 #define IXGBE_GHECCR    0x110B0
@@ -359,24 +684,61 @@
 #define IXGBE_MSRWD     0x04260
 #define IXGBE_MLADD     0x04264
 #define IXGBE_MHADD     0x04268
+#define IXGBE_MAXFRS    0x04268
 #define IXGBE_TREG      0x0426C
 #define IXGBE_PCSS1     0x04288
 #define IXGBE_PCSS2     0x0428C
 #define IXGBE_XPCSS     0x04290
+#define IXGBE_MFLCN     0x04294
 #define IXGBE_SERDESC   0x04298
 #define IXGBE_MACS      0x0429C
 #define IXGBE_AUTOC     0x042A0
 #define IXGBE_LINKS     0x042A4
+#define IXGBE_LINKS2    0x04324
 #define IXGBE_AUTOC2    0x042A8
 #define IXGBE_AUTOC3    0x042AC
 #define IXGBE_ANLP1     0x042B0
 #define IXGBE_ANLP2     0x042B4
 #define IXGBE_ATLASCTL  0x04800
+#define IXGBE_MMNGC     0x042D0
+#define IXGBE_ANLPNP1   0x042D4
+#define IXGBE_ANLPNP2   0x042D8
+#define IXGBE_KRPCSFC   0x042E0
+#define IXGBE_KRPCSS    0x042E4
+#define IXGBE_FECS1     0x042E8
+#define IXGBE_FECS2     0x042EC
+#define IXGBE_SMADARCTL 0x14F10
+#define IXGBE_MPVC      0x04318
+#define IXGBE_SGMIIC    0x04314
+
+/* Omer CORECTL */
+#define IXGBE_CORECTL           0x014F00
+/* BARCTRL */
+#define IXGBE_BARCTRL           0x110F4
+#define IXGBE_BARCTRL_FLSIZE    0x0700
+#define IXGBE_BARCTRL_CSRSIZE   0x2000
 
 /* RDRXCTL Bit Masks */
 #define IXGBE_RDRXCTL_RDMTS_1_2     0x00000000 /* Rx Desc Min Threshold Size */
+#define IXGBE_RDRXCTL_CRCSTRIP      0x00000002 /* CRC Strip */
 #define IXGBE_RDRXCTL_MVMEN         0x00000020
 #define IXGBE_RDRXCTL_DMAIDONE      0x00000008 /* DMA init cycle done */
+#define IXGBE_RDRXCTL_AGGDIS        0x00010000 /* Aggregation disable */
+
+/* RQTC Bit Masks and Shifts */
+#define IXGBE_RQTC_SHIFT_TC(_i)     ((_i) * 4)
+#define IXGBE_RQTC_TC0_MASK         (0x7 << 0)
+#define IXGBE_RQTC_TC1_MASK         (0x7 << 4)
+#define IXGBE_RQTC_TC2_MASK         (0x7 << 8)
+#define IXGBE_RQTC_TC3_MASK         (0x7 << 12)
+#define IXGBE_RQTC_TC4_MASK         (0x7 << 16)
+#define IXGBE_RQTC_TC5_MASK         (0x7 << 20)
+#define IXGBE_RQTC_TC6_MASK         (0x7 << 24)
+#define IXGBE_RQTC_TC7_MASK         (0x7 << 28)
+
+/* PSRTYPE.RQPL Bit masks and shift */
+#define IXGBE_PSRTYPE_RQPL_MASK     0x7
+#define IXGBE_PSRTYPE_RQPL_SHIFT    29
 
 /* CTRL Bit Masks */
 #define IXGBE_CTRL_GIO_DIS      0x00000004 /* Global IO Master Disable bit */
@@ -391,6 +753,7 @@
 #define IXGBE_MHADD_MFS_SHIFT   16
 
 /* Extended Device Control */
+#define IXGBE_CTRL_EXT_PFRSTD   0x00004000 /* Physical Function Reset Done */
 #define IXGBE_CTRL_EXT_NS_DIS   0x00010000 /* No Snoop disable */
 #define IXGBE_CTRL_EXT_RO_DIS   0x00020000 /* Relaxed Ordering disable */
 #define IXGBE_CTRL_EXT_DRV_LOAD 0x10000000 /* Driver loaded bit for FW */
@@ -403,6 +766,8 @@
 #define IXGBE_DCA_CTRL_DCA_MODE_CB2 0x02 /* DCA Mode CB2 */
 
 #define IXGBE_DCA_RXCTRL_CPUID_MASK 0x0000001F /* Rx CPUID Mask */
+#define IXGBE_DCA_RXCTRL_CPUID_MASK_82599  0xFF000000 /* Rx CPUID Mask */
+#define IXGBE_DCA_RXCTRL_CPUID_SHIFT_82599 24 /* Rx CPUID Shift */
 #define IXGBE_DCA_RXCTRL_DESC_DCA_EN (1 << 5) /* DCA Rx Desc enable */
 #define IXGBE_DCA_RXCTRL_HEAD_DCA_EN (1 << 6) /* DCA Rx Desc header enable */
 #define IXGBE_DCA_RXCTRL_DATA_DCA_EN (1 << 7) /* DCA Rx Desc payload enable */
@@ -411,6 +776,8 @@
 #define IXGBE_DCA_RXCTRL_DESC_HSRO_EN (1 << 15) /* DCA Rx Split Header RO */
 
 #define IXGBE_DCA_TXCTRL_CPUID_MASK 0x0000001F /* Tx CPUID Mask */
+#define IXGBE_DCA_TXCTRL_CPUID_MASK_82599  0xFF000000 /* Tx CPUID Mask */
+#define IXGBE_DCA_TXCTRL_CPUID_SHIFT_82599 24 /* Tx CPUID Shift */
 #define IXGBE_DCA_TXCTRL_DESC_DCA_EN (1 << 5) /* DCA Tx Desc enable */
 #define IXGBE_DCA_TXCTRL_TX_WB_RO_EN (1 << 11) /* Tx Desc writeback RO bit */
 #define IXGBE_DCA_MAX_QUEUES_82598   16 /* DCA regs only on 16 queues */
@@ -454,6 +821,8 @@
 #define IXGBE_ATLAS_PDN_TX_1G_QL_ALL    0xF0
 #define IXGBE_ATLAS_PDN_TX_AN_QL_ALL    0xF0
 
+/* Omer bit masks */
+#define IXGBE_CORECTL_WRITE_CMD         0x00010000
 
 /* Device Type definitions for new protocol MDIO commands */
 #define IXGBE_MDIO_PMA_PMD_DEV_TYPE               0x1
@@ -481,8 +850,11 @@
 #define IXGBE_MDIO_PHY_SPEED_ABILITY   0x4 /* Speed Ability Reg */
 #define IXGBE_MDIO_PHY_SPEED_10G       0x0001 /* 10G capable */
 #define IXGBE_MDIO_PHY_SPEED_1G        0x0010 /* 1G capable */
+#define IXGBE_MDIO_PHY_EXT_ABILITY        0xB /* Ext Ability Reg */
+#define IXGBE_MDIO_PHY_10GBASET_ABILITY   0x0004 /* 10GBaseT capable */
+#define IXGBE_MDIO_PHY_1000BASET_ABILITY  0x0020 /* 1000BaseT capable */
 
-#define IXGBE_MDIO_PMA_PMD_SDA_SCL_ADDR     0xC30A /* PHY_XS SDA/SCL Address Reg */
+#define IXGBE_MDIO_PMA_PMD_SDA_SCL_ADDR     0xC30A /* PHY_XS SDA/SCL Addr Reg */
 #define IXGBE_MDIO_PMA_PMD_SDA_SCL_DATA     0xC30B /* PHY_XS SDA/SCL Data Reg */
 #define IXGBE_MDIO_PMA_PMD_SDA_SCL_STAT     0xC30C /* PHY_XS SDA/SCL Status Reg */
 
@@ -497,7 +869,7 @@
 #define IXGBE_PHY_REVISION_MASK        0xFFFFFFF0
 #define IXGBE_MAX_PHY_ADDR             32
 
-/* PHY IDs */
+/* PHY IDs*/
 #define TN1010_PHY_ID    0x00A19410
 #define TNX_FW_REV       0xB
 #define QT2022_PHY_ID    0x0043A400
@@ -517,15 +889,22 @@
 #define IXGBE_CONTROL_NL         0x000F
 #define IXGBE_CONTROL_EOL_NL     0x0FFF
 #define IXGBE_CONTROL_SOL_NL     0x0000
+#define IXGBE_PHY_ENFORCE_INTEL_SFP_OFFSET 0x002C
+#define IXGBE_PHY_ALLOW_ANY_SFP            0x1
 
 /* General purpose Interrupt Enable */
 #define IXGBE_SDP0_GPIEN         0x00000001 /* SDP0 */
 #define IXGBE_SDP1_GPIEN         0x00000002 /* SDP1 */
+#define IXGBE_SDP2_GPIEN         0x00000004 /* SDP2 */
 #define IXGBE_GPIE_MSIX_MODE     0x00000010 /* MSI-X mode */
 #define IXGBE_GPIE_OCD           0x00000020 /* Other Clear Disable */
 #define IXGBE_GPIE_EIMEN         0x00000040 /* Immediate Interrupt Enable */
 #define IXGBE_GPIE_EIAME         0x40000000
 #define IXGBE_GPIE_PBA_SUPPORT   0x80000000
+#define IXGBE_GPIE_VTMODE_MASK   0x0000C000 /* VT Mode Mask */
+#define IXGBE_GPIE_VTMODE_16     0x00004000 /* 16 VFs 8 queues per VF */
+#define IXGBE_GPIE_VTMODE_32     0x00008000 /* 32 VFs 4 queues per VF */
+#define IXGBE_GPIE_VTMODE_64     0x0000C000 /* 64 VFs 2 queues per VF */
 
 /* Transmit Flow Control status */
 #define IXGBE_TFCS_TXOFF         0x00000001
@@ -566,6 +945,21 @@
 #define IXGBE_VMD_CTL_VMDQ_EN     0x00000001
 #define IXGBE_VMD_CTL_VMDQ_FILTER 0x00000002
 
+/* VT_CTL bitmasks */
+#define IXGBE_VT_CTL_DIS_DEFPL  0x20000000 /* disable default pool */
+#define IXGBE_VT_CTL_REPLEN     0x40000000 /* replication enabled */
+#define IXGBE_VT_CTL_VT_ENABLE  0x00000001  /* Enable VT Mode */
+
+/* VMOLR bitmasks */
+#define IXGBE_VMOLR_AUPE        0x01000000 /* accept untagged packets */
+#define IXGBE_VMOLR_ROMPE       0x02000000 /* accept packets in MTA tbl */
+#define IXGBE_VMOLR_ROPE        0x04000000 /* accept packets in UC tbl */
+#define IXGBE_VMOLR_BAM         0x08000000 /* accept broadcast packets */
+#define IXGBE_VMOLR_MPE         0x10000000 /* multicast promiscuous */
+
+/* VFRE bitmask */
+#define IXGBE_VFRE_ENABLE_ALL   0xFFFFFFFF
+
 /* RDHMPN and TDHMPN bitmasks */
 #define IXGBE_RDHMPN_RDICADDR       0x007FF800
 #define IXGBE_RDHMPN_RDICRDREQ      0x00800000
@@ -574,13 +968,39 @@
 #define IXGBE_TDHMPN_TDICRDREQ      0x00800000
 #define IXGBE_TDHMPN_TDICADDR_SHIFT 11
 
+#define IXGBE_RDMAM_MEM_SEL_SHIFT   13
+#define IXGBE_RDMAM_DWORD_SHIFT     9
+#define IXGBE_RDMAM_DESC_COMP_FIFO  1
+#define IXGBE_RDMAM_DFC_CMD_FIFO    2
+#define IXGBE_RDMAM_TCN_STATUS_RAM  4
+#define IXGBE_RDMAM_WB_COLL_FIFO    5
+#define IXGBE_RDMAM_QSC_CNT_RAM     6
+#define IXGBE_RDMAM_QSC_QUEUE_CNT   8
+#define IXGBE_RDMAM_QSC_QUEUE_RAM   0xA
+#define IXGBE_RDMAM_DESC_COM_FIFO_RANGE     135
+#define IXGBE_RDMAM_DESC_COM_FIFO_COUNT     4
+#define IXGBE_RDMAM_DFC_CMD_FIFO_RANGE      48
+#define IXGBE_RDMAM_DFC_CMD_FIFO_COUNT      7
+#define IXGBE_RDMAM_TCN_STATUS_RAM_RANGE    256
+#define IXGBE_RDMAM_TCN_STATUS_RAM_COUNT    9
+#define IXGBE_RDMAM_WB_COLL_FIFO_RANGE      8
+#define IXGBE_RDMAM_WB_COLL_FIFO_COUNT      4
+#define IXGBE_RDMAM_QSC_CNT_RAM_RANGE       64
+#define IXGBE_RDMAM_QSC_CNT_RAM_COUNT       4
+#define IXGBE_RDMAM_QSC_QUEUE_CNT_RANGE     32
+#define IXGBE_RDMAM_QSC_QUEUE_CNT_COUNT     4
+#define IXGBE_RDMAM_QSC_QUEUE_RAM_RANGE     128
+#define IXGBE_RDMAM_QSC_QUEUE_RAM_COUNT     8
+
+#define IXGBE_TXDESCIC_READY        0x80000000
+
 /* Receive Checksum Control */
 #define IXGBE_RXCSUM_IPPCSE     0x00001000   /* IP payload checksum enable */
 #define IXGBE_RXCSUM_PCSD       0x00002000   /* packet checksum disabled */
 
 /* FCRTL Bit Masks */
-#define IXGBE_FCRTL_XONE        0x80000000  /* bit 31, XON enable */
-#define IXGBE_FCRTH_FCEN        0x80000000  /* Rx Flow control enable */
+#define IXGBE_FCRTL_XONE        0x80000000  /* XON enable */
+#define IXGBE_FCRTH_FCEN        0x80000000  /* Packet buffer fc enable */
 
 /* PAP bit masks*/
 #define IXGBE_PAP_TXPAUSECNT_MASK   0x0000FFFF /* Pause counter mask */
@@ -590,19 +1010,29 @@
 /* Receive Arbitration Control: 0 Round Robin, 1 DFP */
 #define IXGBE_RMCS_RAC          0x00000004
 #define IXGBE_RMCS_DFP          IXGBE_RMCS_RAC /* Deficit Fixed Priority ena */
-#define IXGBE_RMCS_TFCE_802_3X  0x00000008 /* Tx Priority flow control ena */
-#define IXGBE_RMCS_TFCE_PRIORITY 0x00000010 /* Tx Priority flow control ena */
+#define IXGBE_RMCS_TFCE_802_3X         0x00000008 /* Tx Priority FC ena */
+#define IXGBE_RMCS_TFCE_PRIORITY       0x00000010 /* Tx Priority FC ena */
 #define IXGBE_RMCS_ARBDIS       0x00000040 /* Arbitration disable bit */
 
+/* FCCFG Bit Masks */
+#define IXGBE_FCCFG_TFCE_802_3X         0x00000008 /* Tx link FC enable */
+#define IXGBE_FCCFG_TFCE_PRIORITY       0x00000010 /* Tx priority FC enable */
 
 /* Interrupt register bitmasks */
 
 /* Extended Interrupt Cause Read */
 #define IXGBE_EICR_RTX_QUEUE    0x0000FFFF /* RTx Queue Interrupt */
+#define IXGBE_EICR_FLOW_DIR     0x00010000 /* FDir Exception */
+#define IXGBE_EICR_RX_MISS      0x00020000 /* Packet Buffer Overrun */
+#define IXGBE_EICR_PCI          0x00040000 /* PCI Exception */
+#define IXGBE_EICR_MAILBOX      0x00080000 /* VF to PF Mailbox Interrupt */
 #define IXGBE_EICR_LSC          0x00100000 /* Link Status Change */
+#define IXGBE_EICR_LINKSEC      0x00200000 /* PN Threshold */
 #define IXGBE_EICR_MNG          0x00400000 /* Manageability Event Interrupt */
 #define IXGBE_EICR_GPI_SDP0     0x01000000 /* Gen Purpose Interrupt on SDP0 */
 #define IXGBE_EICR_GPI_SDP1     0x02000000 /* Gen Purpose Interrupt on SDP1 */
+#define IXGBE_EICR_GPI_SDP2     0x04000000 /* Gen Purpose Interrupt on SDP2 */
+#define IXGBE_EICR_ECC          0x10000000 /* ECC Error */
 #define IXGBE_EICR_PBUR         0x10000000 /* Packet Buffer Handler Error */
 #define IXGBE_EICR_DHER         0x20000000 /* Descriptor Handler Error */
 #define IXGBE_EICR_TCP_TIMER    0x40000000 /* TCP Timer */
@@ -610,10 +1040,16 @@
 
 /* Extended Interrupt Cause Set */
 #define IXGBE_EICS_RTX_QUEUE    IXGBE_EICR_RTX_QUEUE /* RTx Queue Interrupt */
+#define IXGBE_EICS_FLOW_DIR     IXGBE_EICR_FLOW_DIR  /* FDir Exception */
+#define IXGBE_EICS_RX_MISS      IXGBE_EICR_RX_MISS   /* Pkt Buffer Overrun */
+#define IXGBE_EICS_PCI          IXGBE_EICR_PCI       /* PCI Exception */
+#define IXGBE_EICS_MAILBOX      IXGBE_EICR_MAILBOX   /* VF to PF Mailbox Int */
 #define IXGBE_EICS_LSC          IXGBE_EICR_LSC       /* Link Status Change */
 #define IXGBE_EICS_MNG          IXGBE_EICR_MNG       /* MNG Event Interrupt */
 #define IXGBE_EICS_GPI_SDP0     IXGBE_EICR_GPI_SDP0  /* SDP0 Gen Purpose Int */
 #define IXGBE_EICS_GPI_SDP1     IXGBE_EICR_GPI_SDP1  /* SDP1 Gen Purpose Int */
+#define IXGBE_EICS_GPI_SDP2     IXGBE_EICR_GPI_SDP2  /* SDP2 Gen Purpose Int */
+#define IXGBE_EICS_ECC          IXGBE_EICR_ECC       /* ECC Error */
 #define IXGBE_EICS_PBUR         IXGBE_EICR_PBUR      /* Pkt Buf Handler Err */
 #define IXGBE_EICS_DHER         IXGBE_EICR_DHER      /* Desc Handler Error */
 #define IXGBE_EICS_TCP_TIMER    IXGBE_EICR_TCP_TIMER /* TCP Timer */
@@ -621,10 +1057,16 @@
 
 /* Extended Interrupt Mask Set */
 #define IXGBE_EIMS_RTX_QUEUE    IXGBE_EICR_RTX_QUEUE /* RTx Queue Interrupt */
+#define IXGBE_EIMS_FLOW_DIR     IXGBE_EICR_FLOW_DIR  /* FDir Exception */
+#define IXGBE_EIMS_RX_MISS      IXGBE_EICR_RX_MISS   /* Packet Buffer Overrun */
+#define IXGBE_EIMS_PCI          IXGBE_EICR_PCI       /* PCI Exception */
+#define IXGBE_EIMS_MAILBOX      IXGBE_EICR_MAILBOX   /* VF to PF Mailbox Int */
 #define IXGBE_EIMS_LSC          IXGBE_EICR_LSC       /* Link Status Change */
 #define IXGBE_EIMS_MNG          IXGBE_EICR_MNG       /* MNG Event Interrupt */
 #define IXGBE_EIMS_GPI_SDP0     IXGBE_EICR_GPI_SDP0  /* SDP0 Gen Purpose Int */
 #define IXGBE_EIMS_GPI_SDP1     IXGBE_EICR_GPI_SDP1  /* SDP1 Gen Purpose Int */
+#define IXGBE_EIMS_GPI_SDP2     IXGBE_EICR_GPI_SDP2  /* SDP2 Gen Purpose Int */
+#define IXGBE_EIMS_ECC          IXGBE_EICR_ECC       /* ECC Error */
 #define IXGBE_EIMS_PBUR         IXGBE_EICR_PBUR      /* Pkt Buf Handler Err */
 #define IXGBE_EIMS_DHER         IXGBE_EICR_DHER      /* Descr Handler Error */
 #define IXGBE_EIMS_TCP_TIMER    IXGBE_EICR_TCP_TIMER /* TCP Timer */
@@ -632,10 +1074,16 @@
 
 /* Extended Interrupt Mask Clear */
 #define IXGBE_EIMC_RTX_QUEUE    IXGBE_EICR_RTX_QUEUE /* RTx Queue Interrupt */
+#define IXGBE_EIMC_FLOW_DIR     IXGBE_EICR_FLOW_DIR  /* FDir Exception */
+#define IXGBE_EIMC_RX_MISS      IXGBE_EICR_RX_MISS   /* Packet Buffer Overrun */
+#define IXGBE_EIMC_PCI          IXGBE_EICR_PCI       /* PCI Exception */
+#define IXGBE_EIMC_MAILBOX      IXGBE_EICR_MAILBOX   /* VF to PF Mailbox Int */
 #define IXGBE_EIMC_LSC          IXGBE_EICR_LSC       /* Link Status Change */
 #define IXGBE_EIMC_MNG          IXGBE_EICR_MNG       /* MNG Event Interrupt */
 #define IXGBE_EIMC_GPI_SDP0     IXGBE_EICR_GPI_SDP0  /* SDP0 Gen Purpose Int */
 #define IXGBE_EIMC_GPI_SDP1     IXGBE_EICR_GPI_SDP1  /* SDP1 Gen Purpose Int */
+#define IXGBE_EIMC_GPI_SDP2     IXGBE_EICR_GPI_SDP2  /* SDP2 Gen Purpose Int */
+#define IXGBE_EIMC_ECC          IXGBE_EICR_ECC       /* ECC Error */
 #define IXGBE_EIMC_PBUR         IXGBE_EICR_PBUR      /* Pkt Buf Handler Err */
 #define IXGBE_EIMC_DHER         IXGBE_EICR_DHER      /* Desc Handler Err */
 #define IXGBE_EIMC_TCP_TIMER    IXGBE_EICR_TCP_TIMER /* TCP Timer */
@@ -658,6 +1106,33 @@
 #define IXGBE_IMIREXT_CTRL_SYN    0x00020000  /* Check SYN bit in header */
 #define IXGBE_IMIREXT_CTRL_FIN    0x00040000  /* Check FIN bit in header */
 #define IXGBE_IMIREXT_CTRL_BP     0x00080000  /* Bypass check of control bits */
+#define IXGBE_IMIR_SIZE_BP_82599  0x00001000 /* Packet size bypass */
+#define IXGBE_IMIR_CTRL_URG_82599 0x00002000 /* Check URG bit in header */
+#define IXGBE_IMIR_CTRL_ACK_82599 0x00004000 /* Check ACK bit in header */
+#define IXGBE_IMIR_CTRL_PSH_82599 0x00008000 /* Check PSH bit in header */
+#define IXGBE_IMIR_CTRL_RST_82599 0x00010000 /* Check RST bit in header */
+#define IXGBE_IMIR_CTRL_SYN_82599 0x00020000 /* Check SYN bit in header */
+#define IXGBE_IMIR_CTRL_FIN_82599 0x00040000 /* Check FIN bit in header */
+#define IXGBE_IMIR_CTRL_BP_82599  0x00080000 /* Bypass check of control bits */
+#define IXGBE_IMIR_LLI_EN_82599   0x00100000 /* Enables low latency Int */
+#define IXGBE_IMIR_RX_QUEUE_MASK_82599  0x0000007F /* Rx Queue Mask */
+#define IXGBE_IMIR_RX_QUEUE_SHIFT_82599 21 /* Rx Queue Shift */
+#define IXGBE_IMIRVP_PRIORITY_MASK      0x00000007 /* VLAN priority mask */
+#define IXGBE_IMIRVP_PRIORITY_EN        0x00000008 /* VLAN priority enable */
+
+#define IXGBE_MAX_FTQF_FILTERS          128
+#define IXGBE_FTQF_PROTOCOL_MASK        0x00000003
+#define IXGBE_FTQF_PROTOCOL_TCP         0x00000000
+#define IXGBE_FTQF_PROTOCOL_UDP         0x00000001
+#define IXGBE_FTQF_PROTOCOL_SCTP        2
+#define IXGBE_FTQF_PRIORITY_MASK        0x00000007
+#define IXGBE_FTQF_PRIORITY_SHIFT       2
+#define IXGBE_FTQF_POOL_MASK            0x0000003F
+#define IXGBE_FTQF_POOL_SHIFT           8
+#define IXGBE_FTQF_5TUPLE_MASK_MASK     0x0000001F
+#define IXGBE_FTQF_5TUPLE_MASK_SHIFT    25
+#define IXGBE_FTQF_POOL_MASK_EN         0x40000000
+#define IXGBE_FTQF_QUEUE_ENABLE         0x80000000
 
 /* Interrupt clear mask */
 #define IXGBE_IRQ_CLEAR_MASK    0xFFFFFFFF
@@ -677,6 +1152,31 @@
 
 #define IXGBE_IVAR_ALLOC_VAL    0x80 /* Interrupt Allocation valid */
 
+/* ETYPE Queue Filter/Select Bit Masks */
+#define IXGBE_MAX_ETQF_FILTERS  8
+#define IXGBE_ETQF_BCN          0x10000000 /* bit 28 */
+#define IXGBE_ETQF_1588         0x40000000 /* bit 30 */
+#define IXGBE_ETQF_FILTER_EN    0x80000000 /* bit 31 */
+#define IXGBE_ETQF_POOL_ENABLE   (1 << 26) /* bit 26 */
+
+#define IXGBE_ETQS_RX_QUEUE     0x007F0000 /* bits 22:16 */
+#define IXGBE_ETQS_RX_QUEUE_SHIFT       16
+#define IXGBE_ETQS_LLI          0x20000000 /* bit 29 */
+#define IXGBE_ETQS_QUEUE_EN     0x80000000 /* bit 31 */
+
+/*
+ * ETQF filter list: one static filter per filter consumer. This is
+ *                   to avoid filter collisions later. Add new filters
+ *                   here!!
+ *
+ * Current filters:
+ *    EAPOL 802.1x (0x888e): Filter 0
+ *    BCN (0x8904):          Filter 1
+ *    1588 (0x88f7):         Filter 3
+ */
+#define IXGBE_ETQF_FILTER_EAPOL          0
+#define IXGBE_ETQF_FILTER_BCN            1
+#define IXGBE_ETQF_FILTER_1588           3
 /* VLAN Control Bit Masks */
 #define IXGBE_VLNCTRL_VET       0x0000FFFF  /* bits 0-15 */
 #define IXGBE_VLNCTRL_CFI       0x10000000  /* bit 28 */
@@ -684,21 +1184,28 @@
 #define IXGBE_VLNCTRL_VFE       0x40000000  /* bit 30 */
 #define IXGBE_VLNCTRL_VME       0x80000000  /* bit 31 */
 
+/* VLAN pool filtering masks */
+#define IXGBE_VLVF_VIEN         0x80000000  /* filter is valid */
+#define IXGBE_VLVF_ENTRIES      64
 
 #define IXGBE_ETHERNET_IEEE_VLAN_TYPE 0x8100  /* 802.1q protocol */
 
 /* STATUS Bit Masks */
-#define IXGBE_STATUS_LAN_ID     0x0000000C /* LAN ID */
-#define IXGBE_STATUS_GIO        0x00080000 /* GIO Master Enable Status */
+#define IXGBE_STATUS_LAN_ID         0x0000000C /* LAN ID */
+#define IXGBE_STATUS_LAN_ID_SHIFT   2          /* LAN ID Shift*/
+#define IXGBE_STATUS_GIO            0x00080000 /* GIO Master Enable Status */
 
 #define IXGBE_STATUS_LAN_ID_0   0x00000000 /* LAN ID 0 */
 #define IXGBE_STATUS_LAN_ID_1   0x00000004 /* LAN ID 1 */
 
 /* ESDP Bit Masks */
-#define IXGBE_ESDP_SDP4 0x00000001 /* SDP4 Data Value */
-#define IXGBE_ESDP_SDP5 0x00000002 /* SDP5 Data Value */
+#define IXGBE_ESDP_SDP0 0x00000001
+#define IXGBE_ESDP_SDP1 0x00000002
+#define IXGBE_ESDP_SDP4 0x00000010 /* SDP4 Data Value */
+#define IXGBE_ESDP_SDP5 0x00000020 /* SDP5 Data Value */
+#define IXGBE_ESDP_SDP6 0x00000040 /* SDP6 Data Value */
 #define IXGBE_ESDP_SDP4_DIR     0x00000004 /* SDP4 IO direction */
-#define IXGBE_ESDP_SDP5_DIR     0x00000008 /* SDP5 IO direction */
+#define IXGBE_ESDP_SDP5_DIR     0x00002000 /* SDP5 IO direction */
 
 /* LEDCTL Bit Masks */
 #define IXGBE_LED_IVRT_BASE      0x00000040
@@ -730,9 +1237,17 @@
 #define IXGBE_AUTOC_AN_RX_LOOSE 0x01000000
 #define IXGBE_AUTOC_AN_RX_DRIFT 0x00800000
 #define IXGBE_AUTOC_AN_RX_ALIGN 0x007C0000
+#define IXGBE_AUTOC_FECA        0x00040000
+#define IXGBE_AUTOC_FECR        0x00020000
+#define IXGBE_AUTOC_KR_SUPP     0x00010000
 #define IXGBE_AUTOC_AN_RESTART  0x00001000
 #define IXGBE_AUTOC_FLU         0x00000001
 #define IXGBE_AUTOC_LMS_SHIFT   13
+#define IXGBE_AUTOC_LMS_10G_SERIAL      (0x3 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_KX4_KX_KR       (0x4 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_SGMII_1G_100M   (0x5 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_KX4_KX_KR_1G_AN (0x6 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_KX4_KX_KR_SGMII (0x7 << IXGBE_AUTOC_LMS_SHIFT)
 #define IXGBE_AUTOC_LMS_MASK            (0x7 << IXGBE_AUTOC_LMS_SHIFT)
 #define IXGBE_AUTOC_LMS_1G_LINK_NO_AN   (0x0 << IXGBE_AUTOC_LMS_SHIFT)
 #define IXGBE_AUTOC_LMS_10G_LINK_NO_AN  (0x1 << IXGBE_AUTOC_LMS_SHIFT)
@@ -741,15 +1256,24 @@
 #define IXGBE_AUTOC_LMS_KX4_AN_1G_AN    (0x6 << IXGBE_AUTOC_LMS_SHIFT)
 #define IXGBE_AUTOC_LMS_ATTACH_TYPE     (0x7 << IXGBE_AUTOC_10G_PMA_PMD_SHIFT)
 
-#define IXGBE_AUTOC_1G_PMA_PMD         0x00000200
-#define IXGBE_AUTOC_10G_PMA_PMD        0x00000180
-#define IXGBE_AUTOC_10G_PMA_PMD_SHIFT 7
-#define IXGBE_AUTOC_1G_PMA_PMD_SHIFT 9
+#define IXGBE_AUTOC_1G_PMA_PMD_MASK    0x00000200
+#define IXGBE_AUTOC_1G_PMA_PMD_SHIFT   9
+#define IXGBE_AUTOC_10G_PMA_PMD_MASK   0x00000180
+#define IXGBE_AUTOC_10G_PMA_PMD_SHIFT  7
 #define IXGBE_AUTOC_10G_XAUI   (0x0 << IXGBE_AUTOC_10G_PMA_PMD_SHIFT)
 #define IXGBE_AUTOC_10G_KX4    (0x1 << IXGBE_AUTOC_10G_PMA_PMD_SHIFT)
 #define IXGBE_AUTOC_10G_CX4    (0x2 << IXGBE_AUTOC_10G_PMA_PMD_SHIFT)
 #define IXGBE_AUTOC_1G_BX      (0x0 << IXGBE_AUTOC_1G_PMA_PMD_SHIFT)
 #define IXGBE_AUTOC_1G_KX      (0x1 << IXGBE_AUTOC_1G_PMA_PMD_SHIFT)
+#define IXGBE_AUTOC_1G_SFI     (0x0 << IXGBE_AUTOC_1G_PMA_PMD_SHIFT)
+#define IXGBE_AUTOC_1G_KX_BX   (0x1 << IXGBE_AUTOC_1G_PMA_PMD_SHIFT)
+
+#define IXGBE_AUTOC2_UPPER_MASK  0xFFFF0000
+#define IXGBE_AUTOC2_10G_SERIAL_PMA_PMD_MASK  0x00030000
+#define IXGBE_AUTOC2_10G_SERIAL_PMA_PMD_SHIFT 16
+#define IXGBE_AUTOC2_10G_KR  (0x0 << IXGBE_AUTOC2_10G_SERIAL_PMA_PMD_SHIFT)
+#define IXGBE_AUTOC2_10G_XFI (0x1 << IXGBE_AUTOC2_10G_SERIAL_PMA_PMD_SHIFT)
+#define IXGBE_AUTOC2_10G_SFI (0x2 << IXGBE_AUTOC2_10G_SERIAL_PMA_PMD_SHIFT)
 
 /* LINKS Bit Masks */
 #define IXGBE_LINKS_KX_AN_COMP  0x80000000
@@ -759,6 +1283,7 @@
 #define IXGBE_LINKS_RX_MODE     0x06000000
 #define IXGBE_LINKS_TX_MODE     0x01800000
 #define IXGBE_LINKS_XGXS_EN     0x00400000
+#define IXGBE_LINKS_SGMII_EN    0x02000000
 #define IXGBE_LINKS_PCS_1G_EN   0x00200000
 #define IXGBE_LINKS_1G_AN_EN    0x00100000
 #define IXGBE_LINKS_KX_AN_IDLE  0x00080000
@@ -768,6 +1293,10 @@
 #define IXGBE_LINKS_TL_FAULT    0x00001000
 #define IXGBE_LINKS_SIGNAL      0x00000F00
 
+#define IXGBE_LINKS_SPEED_82599     0x30000000
+#define IXGBE_LINKS_SPEED_10G_82599 0x30000000
+#define IXGBE_LINKS_SPEED_1G_82599  0x20000000
+#define IXGBE_LINKS_SPEED_100_82599 0x10000000
 #define IXGBE_LINK_UP_TIME      90 /* 9.0 Seconds */
 #define IXGBE_AUTO_NEG_TIME     45 /* 4.5 Seconds */
 
@@ -844,6 +1373,7 @@
 #define IXGBE_FW_PTR            0x0F
 #define IXGBE_PBANUM0_PTR       0x15
 #define IXGBE_PBANUM1_PTR       0x16
+#define IXGBE_PCIE_MSIX_82599_CAPS  0x72
 #define IXGBE_PCIE_MSIX_82598_CAPS  0x62
 
 /* MSI-X capability fields masks */
@@ -896,6 +1426,8 @@
 #define IXGBE_PCI_LINK_SPEED      0xF
 #define IXGBE_PCI_LINK_SPEED_2500 0x1
 #define IXGBE_PCI_LINK_SPEED_5000 0x2
+#define IXGBE_PCI_HEADER_TYPE_REGISTER  0x0E
+#define IXGBE_PCI_HEADER_TYPE_MULTIFUNC 0x80
 
 /* Number of 100 microseconds we wait for PCI Express master disable */
 #define IXGBE_PCI_MASTER_DISABLE_TIMEOUT 800
@@ -948,6 +1480,7 @@
 #define IXGBE_RXCTRL_RXEN       0x00000001  /* Enable Receiver */
 #define IXGBE_RXCTRL_DMBYPS     0x00000002  /* Descriptor Monitor Bypass */
 #define IXGBE_RXDCTL_ENABLE     0x02000000  /* Enable specific Rx Queue */
+#define IXGBE_RXDCTL_VME        0x40000000  /* VLAN mode enable */
 
 #define IXGBE_FCTRL_SBP 0x00000002 /* Store Bad Packet */
 #define IXGBE_FCTRL_MPE 0x00000100 /* Multicast Promiscuous Ena*/
@@ -958,9 +1491,23 @@
 /* Receive Priority Flow Control Enable */
 #define IXGBE_FCTRL_RPFCE 0x00004000
 #define IXGBE_FCTRL_RFCE 0x00008000 /* Receive Flow Control Ena */
+#define IXGBE_MFLCN_PMCF        0x00000001 /* Pass MAC Control Frames */
+#define IXGBE_MFLCN_DPF         0x00000002 /* Discard Pause Frame */
+#define IXGBE_MFLCN_RPFCE       0x00000004 /* Receive Priority FC Enable */
+#define IXGBE_MFLCN_RFCE        0x00000008 /* Receive FC Enable */
 
 /* Multiple Receive Queue Control */
 #define IXGBE_MRQC_RSSEN                 0x00000001  /* RSS Enable */
+#define IXGBE_MRQC_MRQE_MASK                    0xF /* Bits 3:0 */
+#define IXGBE_MRQC_RT8TCEN               0x00000002 /* 8 TC no RSS */
+#define IXGBE_MRQC_RT4TCEN               0x00000003 /* 4 TC no RSS */
+#define IXGBE_MRQC_RTRSS8TCEN            0x00000004 /* 8 TC w/ RSS */
+#define IXGBE_MRQC_RTRSS4TCEN            0x00000005 /* 4 TC w/ RSS */
+#define IXGBE_MRQC_VMDQEN                0x00000008 /* VMDq2 64 pools no RSS */
+#define IXGBE_MRQC_VMDQRSS32EN           0x0000000A /* VMDq2 32 pools w/ RSS */
+#define IXGBE_MRQC_VMDQRSS64EN           0x0000000B /* VMDq2 64 pools w/ RSS */
+#define IXGBE_MRQC_VMDQRT8TCEN           0x0000000C /* VMDq2/RT 16 pool 8 TC */
+#define IXGBE_MRQC_VMDQRT4TCEN           0x0000000D /* VMDq2/RT 32 pool 4 TC */
 #define IXGBE_MRQC_RSS_FIELD_MASK        0xFFFF0000
 #define IXGBE_MRQC_RSS_FIELD_IPV4_TCP    0x00010000
 #define IXGBE_MRQC_RSS_FIELD_IPV4        0x00020000
@@ -971,6 +1518,12 @@
 #define IXGBE_MRQC_RSS_FIELD_IPV4_UDP    0x00400000
 #define IXGBE_MRQC_RSS_FIELD_IPV6_UDP    0x00800000
 #define IXGBE_MRQC_RSS_FIELD_IPV6_EX_UDP 0x01000000
+#define IXGBE_MRQC_L3L4TXSWEN            0x00008000
+
+/* Queue Drop Enable */
+#define IXGBE_QDE_ENABLE     0x00000001
+#define IXGBE_QDE_IDX_MASK   0x00007F00
+#define IXGBE_QDE_IDX_SHIFT           8
 
 #define IXGBE_TXD_POPTS_IXSM 0x01       /* Insert IP checksum */
 #define IXGBE_TXD_POPTS_TXSM 0x02       /* Insert TCP/UDP checksum */
@@ -982,10 +1535,25 @@
 #define IXGBE_TXD_CMD_VLE    0x40000000 /* Add VLAN tag */
 #define IXGBE_TXD_STAT_DD    0x00000001 /* Descriptor Done */
 
+#define IXGBE_RXDADV_IPSEC_STATUS_SECP                  0x00020000
+#define IXGBE_RXDADV_IPSEC_ERROR_INVALID_PROTOCOL       0x08000000
+#define IXGBE_RXDADV_IPSEC_ERROR_INVALID_LENGTH         0x10000000
+#define IXGBE_RXDADV_IPSEC_ERROR_AUTH_FAILED            0x18000000
+#define IXGBE_RXDADV_IPSEC_ERROR_BIT_MASK               0x18000000
+/* Multiple Transmit Queue Command Register */
+#define IXGBE_MTQC_RT_ENA       0x1 /* DCB Enable */
+#define IXGBE_MTQC_VT_ENA       0x2 /* VMDQ2 Enable */
+#define IXGBE_MTQC_64Q_1PB      0x0 /* 64 queues 1 pack buffer */
+#define IXGBE_MTQC_64VF         0x8 /* 2 TX Queues per pool w/64VF's */
+#define IXGBE_MTQC_8TC_8TQ      0xC /* 8 TC if RT_ENA or 8 TQ if VT_ENA */
+
 /* Receive Descriptor bit definitions */
 #define IXGBE_RXD_STAT_DD       0x01    /* Descriptor Done */
 #define IXGBE_RXD_STAT_EOP      0x02    /* End of Packet */
+#define IXGBE_RXD_STAT_FLM      0x04    /* FDir Match */
 #define IXGBE_RXD_STAT_VP       0x08    /* IEEE VLAN Packet */
+#define IXGBE_RXDADV_NEXTP_MASK   0x000FFFF0 /* Next Descriptor Index */
+#define IXGBE_RXDADV_NEXTP_SHIFT  0x00000004
 #define IXGBE_RXD_STAT_UDPCS    0x10    /* UDP xsum calculated */
 #define IXGBE_RXD_STAT_L4CS     0x20    /* L4 xsum calculated */
 #define IXGBE_RXD_STAT_IPCS     0x40    /* IP xsum calculated */
@@ -994,6 +1562,10 @@
 #define IXGBE_RXD_STAT_VEXT     0x200   /* 1st VLAN found */
 #define IXGBE_RXD_STAT_UDPV     0x400   /* Valid UDP checksum */
 #define IXGBE_RXD_STAT_DYNINT   0x800   /* Pkt caused INT via DYNINT */
+#define IXGBE_RXD_STAT_LLINT    0x800   /* Pkt caused Low Latency Interrupt */
+#define IXGBE_RXD_STAT_TS       0x10000 /* Time Stamp */
+#define IXGBE_RXD_STAT_SECP     0x20000 /* Security Processing */
+#define IXGBE_RXD_STAT_LB       0x40000 /* Loopback Status */
 #define IXGBE_RXD_STAT_ACK      0x8000  /* ACK Packet indication */
 #define IXGBE_RXD_ERR_CE        0x01    /* CRC Error */
 #define IXGBE_RXD_ERR_LE        0x02    /* Length Error */
@@ -1002,6 +1574,8 @@
 #define IXGBE_RXD_ERR_USE       0x20    /* Undersize Error */
 #define IXGBE_RXD_ERR_TCPE      0x40    /* TCP/UDP Checksum Error */
 #define IXGBE_RXD_ERR_IPE       0x80    /* IP Checksum Error */
+#define IXGBE_RXDADV_ERR_MASK           0xfff00000 /* RDESC.ERRORS mask */
+#define IXGBE_RXDADV_ERR_SHIFT          20         /* RDESC.ERRORS shift */
 #define IXGBE_RXDADV_ERR_HBO    0x00800000 /*Header Buffer Overflow */
 #define IXGBE_RXDADV_ERR_CE     0x01000000 /* CRC Error */
 #define IXGBE_RXDADV_ERR_LE     0x02000000 /* Length Error */
@@ -1016,9 +1590,23 @@
 #define IXGBE_RXD_CFI_MASK      0x1000  /* CFI is bit 12 */
 #define IXGBE_RXD_CFI_SHIFT     12
 
+#define IXGBE_RXDADV_STAT_DD            IXGBE_RXD_STAT_DD  /* Done */
+#define IXGBE_RXDADV_STAT_EOP           IXGBE_RXD_STAT_EOP /* End of Packet */
+#define IXGBE_RXDADV_STAT_FLM           IXGBE_RXD_STAT_FLM /* FDir Match */
+#define IXGBE_RXDADV_STAT_VP            IXGBE_RXD_STAT_VP  /* IEEE VLAN Pkt */
+#define IXGBE_RXDADV_STAT_MASK          0x000fffff /* Stat/NEXTP: bit 0-19 */
+
+/* PSRTYPE bit definitions */
+#define IXGBE_PSRTYPE_TCPHDR    0x00000010
+#define IXGBE_PSRTYPE_UDPHDR    0x00000020
+#define IXGBE_PSRTYPE_IPV4HDR   0x00000100
+#define IXGBE_PSRTYPE_IPV6HDR   0x00000200
 
 /* SRRCTL bit definitions */
 #define IXGBE_SRRCTL_BSIZEPKT_SHIFT     10     /* so many KBs */
+#define IXGBE_SRRCTL_RDMTS_SHIFT        22
+#define IXGBE_SRRCTL_RDMTS_MASK         0x01C00000
+#define IXGBE_SRRCTL_DROP_EN            0x10000000
 #define IXGBE_SRRCTL_BSIZEPKT_MASK      0x0000007F
 #define IXGBE_SRRCTL_BSIZEHDR_MASK      0x00003F00
 #define IXGBE_SRRCTL_DESCTYPE_LEGACY    0x00000000
@@ -1033,6 +1621,7 @@
 
 #define IXGBE_RXDADV_RSSTYPE_MASK       0x0000000F
 #define IXGBE_RXDADV_PKTTYPE_MASK       0x0000FFF0
+#define IXGBE_RXDADV_PKTTYPE_MASK_EX    0x0001FFF0
 #define IXGBE_RXDADV_HDRBUFLEN_MASK     0x00007FE0
 #define IXGBE_RXDADV_HDRBUFLEN_SHIFT    5
 #define IXGBE_RXDADV_SPLITHEADER_EN     0x00001000
@@ -1060,6 +1649,20 @@
 #define IXGBE_RXDADV_PKTTYPE_UDP        0x00000200 /* UDP hdr present */
 #define IXGBE_RXDADV_PKTTYPE_SCTP       0x00000400 /* SCTP hdr present */
 #define IXGBE_RXDADV_PKTTYPE_NFS        0x00000800 /* NFS hdr present */
+#define IXGBE_RXDADV_PKTTYPE_IPSEC_ESP  0x00001000 /* IPSec ESP */
+#define IXGBE_RXDADV_PKTTYPE_IPSEC_AH   0x00002000 /* IPSec AH */
+#define IXGBE_RXDADV_PKTTYPE_LINKSEC    0x00004000 /* LinkSec Encap */
+#define IXGBE_RXDADV_PKTTYPE_ETQF       0x00008000 /* PKTTYPE is ETQF index */
+#define IXGBE_RXDADV_PKTTYPE_ETQF_MASK  0x00000070 /* ETQF has 8 indices */
+#define IXGBE_RXDADV_PKTTYPE_ETQF_SHIFT 4          /* Right-shift 4 bits */
+
+/* Security Processing bit Indication */
+#define IXGBE_RXDADV_LNKSEC_STATUS_SECP         0x00020000
+#define IXGBE_RXDADV_LNKSEC_ERROR_NO_SA_MATCH   0x08000000
+#define IXGBE_RXDADV_LNKSEC_ERROR_REPLAY_ERROR  0x10000000
+#define IXGBE_RXDADV_LNKSEC_ERROR_BIT_MASK      0x18000000
+#define IXGBE_RXDADV_LNKSEC_ERROR_BAD_SIG       0x18000000
+
 /* Masks to determine if packets should be dropped due to frame errors */
 #define IXGBE_RXD_ERR_FRAME_ERR_MASK ( \
                                       IXGBE_RXD_ERR_CE | \
@@ -1089,6 +1692,14 @@
 #define IXGBE_RX_DESC_SPECIAL_PRI_SHIFT  0x000D /* Priority in upper 3 of 16 */
 #define IXGBE_TX_DESC_SPECIAL_PRI_SHIFT  IXGBE_RX_DESC_SPECIAL_PRI_SHIFT
 
+/* Little Endian defines */
+#ifndef __le32
+#define __le32  u32
+#endif
+#ifndef __le64
+#define __le64  u64
+
+#endif
 
 /* Transmit Descriptor - Legacy */
 struct ixgbe_legacy_tx_desc {
@@ -1176,6 +1787,9 @@ struct ixgbe_adv_tx_context_desc {
 
 /* Adv Transmit Descriptor Config Masks */
 #define IXGBE_ADVTXD_DTALEN_MASK      0x0000FFFF /* Data buf length(bytes) */
+#define IXGBE_ADVTXD_MAC_LINKSEC      0x00040000 /* Insert LinkSec */
+#define IXGBE_ADVTXD_IPSEC_SA_INDEX_MASK   0x000003FF /* IPSec SA index */
+#define IXGBE_ADVTXD_IPSEC_ESP_LEN_MASK    0x000001FF /* IPSec ESP length */
 #define IXGBE_ADVTXD_DTYP_MASK  0x00F00000 /* DTYP mask */
 #define IXGBE_ADVTXD_DTYP_CTXT  0x00200000 /* Advanced Context Desc */
 #define IXGBE_ADVTXD_DTYP_DATA  0x00300000 /* Advanced Data Descriptor */
@@ -1210,6 +1824,9 @@ struct ixgbe_adv_tx_context_desc {
 #define IXGBE_ADVTXD_TUCMD_L4T_TCP   0x00000800  /* L4 Packet TYPE of TCP */
 #define IXGBE_ADVTXD_TUCMD_L4T_SCTP  0x00001000  /* L4 Packet TYPE of SCTP */
 #define IXGBE_ADVTXD_TUCMD_MKRREQ    0x00002000 /*Req requires Markers and CRC*/
+#define IXGBE_ADVTXD_POPTS_IPSEC      0x00000400 /* IPSec offload request */
+#define IXGBE_ADVTXD_TUCMD_IPSEC_TYPE_ESP 0x00002000 /* IPSec Type ESP */
+#define IXGBE_ADVTXD_TUCMD_IPSEC_ENCRYPT_EN 0x00004000/* ESP Encrypt Enable */
 #define IXGBE_ADVTXD_L4LEN_SHIFT     8  /* Adv ctxt L4LEN shift */
 #define IXGBE_ADVTXD_MSS_SHIFT       16  /* Adv ctxt MSS shift */
 
@@ -1223,6 +1840,12 @@ typedef u32 ixgbe_link_speed;
 #define IXGBE_LINK_SPEED_10GB_FULL 0x0080
 #define IXGBE_LINK_SPEED_82598_AUTONEG (IXGBE_LINK_SPEED_1GB_FULL | \
                                         IXGBE_LINK_SPEED_10GB_FULL)
+#define IXGBE_LINK_SPEED_82599_AUTONEG (IXGBE_LINK_SPEED_100_FULL | \
+                                        IXGBE_LINK_SPEED_1GB_FULL | \
+                                        IXGBE_LINK_SPEED_10GB_FULL)
+
+#define IXGBE_PCIE_DEV_CTRL_2 0xC8
+#define PCIE_COMPL_TO_VALUE 0x05
 
 /* Physical layer type */
 typedef u32 ixgbe_physical_layer;
@@ -1239,7 +1862,6 @@ typedef u32 ixgbe_physical_layer;
 #define IXGBE_PHYSICAL_LAYER_1000BASE_KX  0x0200
 #define IXGBE_PHYSICAL_LAYER_1000BASE_BX  0x0400
 
-
 enum ixgbe_eeprom_type {
 	ixgbe_eeprom_uninitialized = 0,
 	ixgbe_eeprom_spi,
@@ -1249,12 +1871,14 @@ enum ixgbe_eeprom_type {
 enum ixgbe_mac_type {
 	ixgbe_mac_unknown = 0,
 	ixgbe_mac_82598EB,
+	ixgbe_mac_82599EB,
 	ixgbe_num_macs
 };
 
 enum ixgbe_phy_type {
 	ixgbe_phy_unknown = 0,
 	ixgbe_phy_tn,
+	ixgbe_phy_cu_unknown,
 	ixgbe_phy_qt,
 	ixgbe_phy_xaui,
 	ixgbe_phy_nl,
@@ -1263,22 +1887,31 @@ enum ixgbe_phy_type {
 	ixgbe_phy_sfp_avago,
 	ixgbe_phy_sfp_ftl,
 	ixgbe_phy_sfp_unknown,
+	ixgbe_phy_sfp_intel,
 	ixgbe_phy_generic
 };
 
 /*
  * SFP+ module type IDs:
  *
- * ID	Module Type
+ * ID   Module Type
  * =============
- * 0	SFP_DA_CU
- * 1	SFP_SR
- * 2	SFP_LR
+ * 0    SFP_DA_CU
+ * 1    SFP_SR
+ * 2    SFP_LR
+ * 3    SFP_DA_CU_CORE0 - 82599-specific
+ * 4    SFP_DA_CU_CORE1 - 82599-specific
+ * 5    SFP_SR/LR_CORE0 - 82599-specific
+ * 6    SFP_SR/LR_CORE1 - 82599-specific
  */
 enum ixgbe_sfp_type {
 	ixgbe_sfp_type_da_cu = 0,
 	ixgbe_sfp_type_sr = 1,
 	ixgbe_sfp_type_lr = 2,
+	ixgbe_sfp_type_da_cu_core0 = 3,
+	ixgbe_sfp_type_da_cu_core1 = 4,
+	ixgbe_sfp_type_srlr_core0 = 5,
+	ixgbe_sfp_type_srlr_core1 = 6,
 	ixgbe_sfp_type_not_present = 0xFFFE,
 	ixgbe_sfp_type_unknown = 0xFFFF
 };
@@ -1300,6 +1933,40 @@ enum ixgbe_fc_mode {
 	ixgbe_fc_default
 };
 
+/* PCI bus types */
+enum ixgbe_bus_type {
+	ixgbe_bus_type_unknown = 0,
+	ixgbe_bus_type_pci,
+	ixgbe_bus_type_pcix,
+	ixgbe_bus_type_pci_express,
+	ixgbe_bus_type_reserved
+};
+
+/* PCI bus speeds */
+enum ixgbe_bus_speed {
+	ixgbe_bus_speed_unknown = 0,
+	ixgbe_bus_speed_33,
+	ixgbe_bus_speed_66,
+	ixgbe_bus_speed_100,
+	ixgbe_bus_speed_120,
+	ixgbe_bus_speed_133,
+	ixgbe_bus_speed_2500,
+	ixgbe_bus_speed_5000,
+	ixgbe_bus_speed_reserved
+};
+
+/* PCI bus widths */
+enum ixgbe_bus_width {
+	ixgbe_bus_width_unknown = 0,
+	ixgbe_bus_width_pcie_x1,
+	ixgbe_bus_width_pcie_x2,
+	ixgbe_bus_width_pcie_x4 = 4,
+	ixgbe_bus_width_pcie_x8 = 8,
+	ixgbe_bus_width_32,
+	ixgbe_bus_width_64,
+	ixgbe_bus_width_reserved
+};
+
 struct ixgbe_addr_filter_info {
 	u32 num_mc_addrs;
 	u32 rar_used_count;
@@ -1309,6 +1976,16 @@ struct ixgbe_addr_filter_info {
 	bool user_set_promisc;
 };
 
+/* Bus parameters */
+struct ixgbe_bus_info {
+	enum ixgbe_bus_speed speed;
+	enum ixgbe_bus_width width;
+	enum ixgbe_bus_type type;
+
+	u16 func;
+	u16 lan_id;
+};
+
 /* Flow control parameters */
 struct ixgbe_fc_info {
 	u32 high_water; /* Flow Control High-water */
@@ -1377,6 +2054,14 @@ struct ixgbe_hw_stats {
 	u64 qptc[16];
 	u64 qbrc[16];
 	u64 qbtc[16];
+	u64 qprdc[16];
+	u64 pxon2offc[8];
+	u64 fdirustat_add;
+	u64 fdirustat_remove;
+	u64 fdirfstat_fadd;
+	u64 fdirfstat_fremove;
+	u64 fdirmatch;
+	u64 fdirmiss;
 };
 
 /* forward declaration */
@@ -1401,12 +2086,15 @@ struct ixgbe_mac_operations {
 	s32 (*start_hw)(struct ixgbe_hw *);
 	s32 (*clear_hw_cntrs)(struct ixgbe_hw *);
 	enum ixgbe_media_type (*get_media_type)(struct ixgbe_hw *);
-	s32 (*get_supported_physical_layer)(struct ixgbe_hw *);
+	u32 (*get_supported_physical_layer)(struct ixgbe_hw *);
 	s32 (*get_mac_addr)(struct ixgbe_hw *, u8 *);
 	s32 (*stop_adapter)(struct ixgbe_hw *);
 	s32 (*get_bus_info)(struct ixgbe_hw *);
+	void (*set_lan_id)(struct ixgbe_hw *);
 	s32 (*read_analog_reg8)(struct ixgbe_hw*, u32, u8*);
 	s32 (*write_analog_reg8)(struct ixgbe_hw*, u32, u8);
+	s32 (*setup_sfp)(struct ixgbe_hw *);
+	s32 (*enable_rx_dma)(struct ixgbe_hw *, u32);
 
 	/* Link */
 	s32 (*setup_link)(struct ixgbe_hw *);
@@ -1462,7 +2150,7 @@ struct ixgbe_phy_operations {
 struct ixgbe_eeprom_info {
 	struct ixgbe_eeprom_operations  ops;
 	enum ixgbe_eeprom_type          type;
-	u32				semaphore_delay;
+	u32                             semaphore_delay;
 	u16                             word_size;
 	u16                             address_bits;
 };
@@ -1508,6 +2196,7 @@ struct ixgbe_hw {
 	struct ixgbe_fc_info		fc;
 	struct ixgbe_phy_info		phy;
 	struct ixgbe_eeprom_info	eeprom;
+	struct ixgbe_bus_info		bus;
 	u16				device_id;
 	u16				vendor_id;
 	u16				subsystem_device_id;
@@ -1546,6 +2235,7 @@ struct ixgbe_info {
 #define IXGBE_ERR_I2C                           -18
 #define IXGBE_ERR_SFP_NOT_SUPPORTED             -19
 #define IXGBE_ERR_SFP_NOT_PRESENT               -20
+#define IXGBE_ERR_SFP_NO_INIT_SEQ_PRESENT       -21
 #define IXGBE_NOT_IMPLEMENTED                   0x7FFFFFFF
 
 #endif /* _IXGBE_TYPE_H_ */

