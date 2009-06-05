From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 09/10] ixgbe: Add FW detection and warning for 82599
	SFP+ adapters
Date: Thu, 04 Jun 2009 19:02:24 -0700
Message-ID: <20090605020223.8468.19005.stgit@localhost.localdomain>
References: <20090605015948.8468.25862.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:39453 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752795AbZFECCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 22:02:42 -0400
In-Reply-To: <20090605015948.8468.25862.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

82599 has a FW running that helps manage the internal SFI PHY.  There are
also a number of pre-production samples of these SFI-based devices in the
field.  This patch adds a check to look for the firmware running on all
SFP+ based adapters, and displays a warning to the system log if a
pre-production adapter is identified.  The driver will continue loading
though, with no functional degradation.

Also remove an old function prototype from ixgbe_82599.c that isn't being
used.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c  |   58 ++++++++++++++++++++++++++++++++++++--
 drivers/net/ixgbe/ixgbe_common.c |   12 +++++---
 drivers/net/ixgbe/ixgbe_main.c   |   20 ++++++++++++-
 drivers/net/ixgbe/ixgbe_type.h   |    3 ++
 4 files changed, 85 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 5c2627b..1984cab 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -71,10 +71,10 @@ s32 ixgbe_clear_vfta_82599(struct ixgbe_hw *hw);
 s32 ixgbe_init_uta_tables_82599(struct ixgbe_hw *hw);
 s32 ixgbe_read_analog_reg8_82599(struct ixgbe_hw *hw, u32 reg, u8 *val);
 s32 ixgbe_write_analog_reg8_82599(struct ixgbe_hw *hw, u32 reg, u8 val);
-s32 ixgbe_start_hw_rev_0_82599(struct ixgbe_hw *hw);
 s32 ixgbe_identify_phy_82599(struct ixgbe_hw *hw);
 s32 ixgbe_start_hw_82599(struct ixgbe_hw *hw);
 u32 ixgbe_get_supported_physical_layer_82599(struct ixgbe_hw *hw);
+static s32 ixgbe_verify_fw_version_82599(struct ixgbe_hw *hw);
 
 void ixgbe_init_mac_link_ops_82599(struct ixgbe_hw *hw)
 {
@@ -2142,8 +2142,9 @@ s32 ixgbe_write_analog_reg8_82599(struct ixgbe_hw *hw, u32 reg, u8 val)
 s32 ixgbe_start_hw_82599(struct ixgbe_hw *hw)
 {
 	u32 q_num;
+	s32 ret_val;
 
-	ixgbe_start_hw_generic(hw);
+	ret_val = ixgbe_start_hw_generic(hw);
 
 	/* Clear the rate limiters */
 	for (q_num = 0; q_num < hw->mac.max_tx_queues; q_num++) {
@@ -2155,7 +2156,10 @@ s32 ixgbe_start_hw_82599(struct ixgbe_hw *hw)
 	/* We need to run link autotry after the driver loads */
 	hw->mac.autotry_restart = true;
 
-	return 0;
+	if (ret_val == 0)
+		ret_val = ixgbe_verify_fw_version_82599(hw);
+
+	return ret_val;
 }
 
 /**
@@ -2407,6 +2411,54 @@ san_mac_addr_out:
 	return 0;
 }
 
+/**
+ *  ixgbe_verify_fw_version_82599 - verify fw version for 82599
+ *  @hw: pointer to hardware structure
+ *
+ *  Verifies that installed the firmware version is 0.6 or higher
+ *  for SFI devices. All 82599 SFI devices should have version 0.6 or higher.
+ *
+ *  Returns IXGBE_ERR_EEPROM_VERSION if the FW is not present or
+ *  if the FW version is not supported.
+ **/
+static s32 ixgbe_verify_fw_version_82599(struct ixgbe_hw *hw)
+{
+	s32 status = IXGBE_ERR_EEPROM_VERSION;
+	u16 fw_offset, fw_ptp_cfg_offset;
+	u16 fw_version = 0;
+
+	/* firmware check is only necessary for SFI devices */
+	if (hw->phy.media_type != ixgbe_media_type_fiber) {
+		status = 0;
+		goto fw_version_out;
+	}
+
+	/* get the offset to the Firmware Module block */
+	hw->eeprom.ops.read(hw, IXGBE_FW_PTR, &fw_offset);
+
+	if ((fw_offset == 0) || (fw_offset == 0xFFFF))
+		goto fw_version_out;
+
+	/* get the offset to the Pass Through Patch Configuration block */
+	hw->eeprom.ops.read(hw, (fw_offset +
+	                         IXGBE_FW_PASSTHROUGH_PATCH_CONFIG_PTR),
+	                         &fw_ptp_cfg_offset);
+
+	if ((fw_ptp_cfg_offset == 0) || (fw_ptp_cfg_offset == 0xFFFF))
+		goto fw_version_out;
+
+	/* get the firmware version */
+	hw->eeprom.ops.read(hw, (fw_ptp_cfg_offset +
+	                         IXGBE_FW_PATCH_VERSION_4),
+	                         &fw_version);
+
+	if (fw_version > 0x5)
+		status = 0;
+
+fw_version_out:
+	return status;
+}
+
 static struct ixgbe_mac_operations mac_ops_82599 = {
 	.init_hw                = &ixgbe_init_hw_generic,
 	.reset_hw               = &ixgbe_reset_hw_82599,
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index db339d6..96a1859 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -106,13 +106,17 @@ s32 ixgbe_start_hw_generic(struct ixgbe_hw *hw)
  **/
 s32 ixgbe_init_hw_generic(struct ixgbe_hw *hw)
 {
+	s32 status;
+
 	/* Reset the hardware */
-	hw->mac.ops.reset_hw(hw);
+	status = hw->mac.ops.reset_hw(hw);
 
-	/* Start the HW */
-	hw->mac.ops.start_hw(hw);
+	if (status == 0) {
+		/* Start the HW */
+		status = hw->mac.ops.start_hw(hw);
+	}
 
-	return 0;
+	return status;
 }
 
 /**
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index ca7c5d5..543a606 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2728,6 +2728,15 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
 	case IXGBE_ERR_MASTER_REQUESTS_PENDING:
 		dev_err(&adapter->pdev->dev, "master disable timed out\n");
 		break;
+	case IXGBE_ERR_EEPROM_VERSION:
+		/* We are running on a pre-production device, log a warning */
+		dev_warn(&adapter->pdev->dev, "This device is a pre-production "
+		         "adapter/LOM.  Please be aware there may be issues "
+		         "associated with your hardware.  If you are "
+		         "experiencing problems please contact your Intel or "
+		         "hardware representative who provided you with this "
+		         "hardware.\n");
+		break;
 	default:
 		dev_err(&adapter->pdev->dev, "Hardware Error: %d\n", err);
 	}
@@ -5608,8 +5617,17 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	hw->eeprom.ops.read(hw, 0x29, &adapter->eeprom_version);
 
 	/* reset the hardware with the new settings */
-	hw->mac.ops.start_hw(hw);
+	err = hw->mac.ops.start_hw(hw);
 
+	if (err == IXGBE_ERR_EEPROM_VERSION) {
+		/* We are running on a pre-production device, log a warning */
+		dev_warn(&pdev->dev, "This device is a pre-production "
+		         "adapter/LOM.  Please be aware there may be issues "
+		         "associated with your hardware.  If you are "
+		         "experiencing problems please contact your Intel or "
+		         "hardware representative who provided you with this "
+		         "hardware.\n");
+	}
 	strcpy(netdev->name, "eth%d");
 	err = register_netdev(netdev);
 	if (err)
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 68cac36..fa87309 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1516,6 +1516,8 @@
 #define IXGBE_SAN_MAC_ADDR_PORT1_OFFSET  0x3
 #define IXGBE_DEVICE_CAPS_ALLOW_ANY_SFP  0x1
 #define IXGBE_DEVICE_CAPS_FCOE_OFFLOADS  0x2
+#define IXGBE_FW_PASSTHROUGH_PATCH_CONFIG_PTR   0x4
+#define IXGBE_FW_PATCH_VERSION_4   0x7
 
 /* PCI Bus Info */
 #define IXGBE_PCI_LINK_STATUS     0xB2
@@ -2495,6 +2497,7 @@ struct ixgbe_info {
 #define IXGBE_ERR_SFP_NOT_PRESENT               -20
 #define IXGBE_ERR_SFP_NO_INIT_SEQ_PRESENT       -21
 #define IXGBE_ERR_FDIR_REINIT_FAILED            -23
+#define IXGBE_ERR_EEPROM_VERSION                -24
 #define IXGBE_NOT_IMPLEMENTED                   0x7FFFFFFF
 
 #endif /* _IXGBE_TYPE_H_ */

