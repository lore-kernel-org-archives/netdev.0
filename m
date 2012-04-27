From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/6] ixgbe: check for WoL support in single function
Date: Fri, 27 Apr 2012 02:36:53 -0700
Message-ID: <1335519413-1892-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1335519413-1892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58719 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759256Ab2D0Jg6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2012 05:36:58 -0400
In-Reply-To: <1335519413-1892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch consolidates the case logic for checking whether a device supports
WoL into a single place. Previously ethtool and probe used similar logic that
was copied and maintained separately. This patch encapsulates the core logic
into a function so that a user only has to update one place.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   51 +-----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   88 ++++++++++++++--------
 3 files changed, 62 insertions(+), 79 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 74e1921..8e082f2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -600,6 +600,8 @@ extern void ixgbe_disable_rx_queue(struct ixgbe_adapter *adapter,
 				   struct ixgbe_ring *);
 extern void ixgbe_update_stats(struct ixgbe_adapter *adapter);
 extern int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter);
+extern int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
+			       u16 subdevice_id);
 extern void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter);
 extern netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *,
 					 struct ixgbe_adapter *,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 31a2bf7..27225ff 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1969,53 +1969,12 @@ static int ixgbe_wol_exclusion(struct ixgbe_adapter *adapter,
                                struct ethtool_wolinfo *wol)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	int retval = 1;
-	u16 wol_cap = adapter->eeprom_cap & IXGBE_DEVICE_CAPS_WOL_MASK;
-
-	/* WOL not supported except for the following */
-	switch(hw->device_id) {
-	case IXGBE_DEV_ID_82599_SFP:
-		/* Only these subdevices could supports WOL */
-		switch (hw->subsystem_device_id) {
-		case IXGBE_SUBDEV_ID_82599_560FLR:
-			/* only support first port */
-			if (hw->bus.func != 0) {
-				wol->supported = 0;
-				break;
-			}
-		case IXGBE_SUBDEV_ID_82599_SFP:
-			retval = 0;
-			break;
-		default:
-			wol->supported = 0;
-			break;
-		}
-		break;
-	case IXGBE_DEV_ID_82599_COMBO_BACKPLANE:
-		/* All except this subdevice support WOL */
-		if (hw->subsystem_device_id ==
-		    IXGBE_SUBDEV_ID_82599_KX4_KR_MEZZ) {
-			wol->supported = 0;
-			break;
-		}
-		retval = 0;
-		break;
-	case IXGBE_DEV_ID_82599_KX4:
-		retval = 0;
-		break;
-	case IXGBE_DEV_ID_X540T:
-		/* check eeprom to see if enabled wol */
-		if ((wol_cap == IXGBE_DEVICE_CAPS_WOL_PORT0_1) ||
-		    ((wol_cap == IXGBE_DEVICE_CAPS_WOL_PORT0) &&
-		     (hw->bus.func == 0))) {
-			retval = 0;
-			break;
-		}
+	int retval = 0;
 
-		/* All others not supported */
-		wol->supported = 0;
-		break;
-	default:
+	/* WOL not supported for all devices */
+	if (!ixgbe_wol_supported(adapter, hw->device_id,
+				 hw->subsystem_device_id)) {
+		retval = 1;
 		wol->supported = 0;
 	}
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7c4325ec..aa29edb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6598,7 +6598,7 @@ static netdev_features_t ixgbe_fix_features(struct net_device *netdev,
 	/* Turn off LRO if not RSC capable */
 	if (!(adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE))
 		features &= ~NETIF_F_LRO;
-	
+
 
 	return features;
 }
@@ -6786,6 +6786,57 @@ static void __devinit ixgbe_probe_vf(struct ixgbe_adapter *adapter,
 }
 
 /**
+ * ixgbe_wol_supported - Check whether device supports WoL
+ * @hw: hw specific details
+ * @device_id: the device ID
+ * @subdev_id: the subsystem device ID
+ *
+ * This function is used by probe and ethtool to determine
+ * which devices have WoL support
+ *
+ **/
+int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
+			u16 subdevice_id)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u16 wol_cap = adapter->eeprom_cap & IXGBE_DEVICE_CAPS_WOL_MASK;
+	int is_wol_supported = 0;
+
+	switch (device_id) {
+	case IXGBE_DEV_ID_82599_SFP:
+		/* Only these subdevices could supports WOL */
+		switch (subdevice_id) {
+		case IXGBE_SUBDEV_ID_82599_560FLR:
+			/* only support first port */
+			if (hw->bus.func != 0)
+				break;
+		case IXGBE_SUBDEV_ID_82599_SFP:
+			is_wol_supported = 1;
+			break;
+		}
+		break;
+	case IXGBE_DEV_ID_82599_COMBO_BACKPLANE:
+		/* All except this subdevice support WOL */
+		if (subdevice_id != IXGBE_SUBDEV_ID_82599_KX4_KR_MEZZ)
+			is_wol_supported = 1;
+		break;
+	case IXGBE_DEV_ID_82599_KX4:
+		is_wol_supported = 1;
+		break;
+	case IXGBE_DEV_ID_X540T:
+		/* check eeprom to see if enabled wol */
+		if ((wol_cap == IXGBE_DEVICE_CAPS_WOL_PORT0_1) ||
+		    ((wol_cap == IXGBE_DEVICE_CAPS_WOL_PORT0) &&
+		     (hw->bus.func == 0))) {
+			is_wol_supported = 1;
+		}
+		break;
+	}
+
+	return is_wol_supported;
+}
+
+/**
  * ixgbe_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in ixgbe_pci_tbl
@@ -6811,7 +6862,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	u16 device_caps;
 #endif
 	u32 eec;
-	u16 wol_cap;
 
 	/* Catch broken hardware that put the wrong VF device ID in
 	 * the PCIe SR-IOV capability.
@@ -7075,40 +7125,12 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		netdev->features &= ~NETIF_F_RXHASH;
 	}
 
-	/* WOL not supported for all but the following */
+	/* WOL not supported for all devices */
 	adapter->wol = 0;
-	switch (pdev->device) {
-	case IXGBE_DEV_ID_82599_SFP:
-		/* Only these subdevice supports WOL */
-		switch (pdev->subsystem_device) {
-		case IXGBE_SUBDEV_ID_82599_560FLR:
-			/* only support first port */
-			if (hw->bus.func != 0)
-				break;
-		case IXGBE_SUBDEV_ID_82599_SFP:
-			adapter->wol = IXGBE_WUFC_MAG;
-			break;
-		}
-		break;
-	case IXGBE_DEV_ID_82599_COMBO_BACKPLANE:
-		/* All except this subdevice support WOL */
-		if (pdev->subsystem_device != IXGBE_SUBDEV_ID_82599_KX4_KR_MEZZ)
-			adapter->wol = IXGBE_WUFC_MAG;
-		break;
-	case IXGBE_DEV_ID_82599_KX4:
+	hw->eeprom.ops.read(hw, 0x2c, &adapter->eeprom_cap);
+	if (ixgbe_wol_supported(adapter, pdev->device, pdev->subsystem_device))
 		adapter->wol = IXGBE_WUFC_MAG;
-		break;
-	case IXGBE_DEV_ID_X540T:
-		/* Check eeprom to see if it is enabled */
-		hw->eeprom.ops.read(hw, 0x2c, &adapter->eeprom_cap);
-		wol_cap = adapter->eeprom_cap & IXGBE_DEVICE_CAPS_WOL_MASK;
 
-		if ((wol_cap == IXGBE_DEVICE_CAPS_WOL_PORT0_1) ||
-		    ((wol_cap == IXGBE_DEVICE_CAPS_WOL_PORT0) &&
-		     (hw->bus.func == 0)))
-			adapter->wol = IXGBE_WUFC_MAG;
-		break;
-	}
 	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
 
 	/* save off EEPROM version number */
-- 
1.7.7.6
