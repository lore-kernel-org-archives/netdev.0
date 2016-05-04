From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] ixgbe: check EEPROM for WOL support for X540 and above
Date: Wed,  4 May 2016 09:26:41 -0700
Message-ID: <1462379208-3997-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462379208-3997-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:11585 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754522AbcEDQ0z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 12:26:55 -0400
In-Reply-To: <1462379208-3997-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This change aims to simplify the logic we use to determine WOL
support by reading the EEPROM bits for MACs X540 and newer.

Also some cleanups in ixgbe_wol_supported() - changed return type to
bool and removed redundant return variable by simply using return after
the checks.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  4 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 49 +++++++++++++--------------
 2 files changed, 25 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 515c3dc..e216a3d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -895,8 +895,8 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *, struct ixgbe_ring *);
 void ixgbe_disable_rx_queue(struct ixgbe_adapter *adapter, struct ixgbe_ring *);
 void ixgbe_update_stats(struct ixgbe_adapter *adapter);
 int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter);
-int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
-			       u16 subdevice_id);
+bool ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
+			 u16 subdevice_id);
 #ifdef CONFIG_PCI_IOV
 void ixgbe_full_sync_mac_table(struct ixgbe_adapter *adapter);
 #endif
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 77c798f..403b3cc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9185,7 +9185,7 @@ static inline int ixgbe_enumerate_functions(struct ixgbe_adapter *adapter)
 
 /**
  * ixgbe_wol_supported - Check whether device supports WoL
- * @hw: hw specific details
+ * @adapter: the adapter private structure
  * @device_id: the device ID
  * @subdev_id: the subsystem device ID
  *
@@ -9193,13 +9193,25 @@ static inline int ixgbe_enumerate_functions(struct ixgbe_adapter *adapter)
  * which devices have WoL support
  *
  **/
-int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
-			u16 subdevice_id)
+bool ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
+			 u16 subdevice_id)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	u16 wol_cap = adapter->eeprom_cap & IXGBE_DEVICE_CAPS_WOL_MASK;
-	int is_wol_supported = 0;
 
+	/* WOL not supported on 82598 */
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		return false;
+
+	/* check eeprom to see if WOL is enabled for X540 and newer */
+	if (hw->mac.type >= ixgbe_mac_X540) {
+		if ((wol_cap == IXGBE_DEVICE_CAPS_WOL_PORT0_1) ||
+		    ((wol_cap == IXGBE_DEVICE_CAPS_WOL_PORT0) &&
+		     (hw->bus.func == 0)))
+			return true;
+	}
+
+	/* WOL is determined based on device IDs for 82599 MACs */
 	switch (device_id) {
 	case IXGBE_DEV_ID_82599_SFP:
 		/* Only these subdevices could supports WOL */
@@ -9218,43 +9230,28 @@ int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
 		case IXGBE_SUBDEV_ID_82599_SFP_1OCP:
 		case IXGBE_SUBDEV_ID_82599_SFP_LOM_OEM1:
 		case IXGBE_SUBDEV_ID_82599_SFP_LOM_OEM2:
-			is_wol_supported = 1;
-			break;
+			return true;
 		}
 		break;
 	case IXGBE_DEV_ID_82599EN_SFP:
-		/* Only this subdevice supports WOL */
+		/* Only these subdevices support WOL */
 		switch (subdevice_id) {
 		case IXGBE_SUBDEV_ID_82599EN_SFP_OCP1:
-			is_wol_supported = 1;
-			break;
+			return true;
 		}
 		break;
 	case IXGBE_DEV_ID_82599_COMBO_BACKPLANE:
 		/* All except this subdevice support WOL */
 		if (subdevice_id != IXGBE_SUBDEV_ID_82599_KX4_KR_MEZZ)
-			is_wol_supported = 1;
+			return true;
 		break;
 	case IXGBE_DEV_ID_82599_KX4:
-		is_wol_supported = 1;
-		break;
-	case IXGBE_DEV_ID_X540T:
-	case IXGBE_DEV_ID_X540T1:
-	case IXGBE_DEV_ID_X550T:
-	case IXGBE_DEV_ID_X550T1:
-	case IXGBE_DEV_ID_X550EM_X_KX4:
-	case IXGBE_DEV_ID_X550EM_X_KR:
-	case IXGBE_DEV_ID_X550EM_X_10G_T:
-		/* check eeprom to see if enabled wol */
-		if ((wol_cap == IXGBE_DEVICE_CAPS_WOL_PORT0_1) ||
-		    ((wol_cap == IXGBE_DEVICE_CAPS_WOL_PORT0) &&
-		     (hw->bus.func == 0))) {
-			is_wol_supported = 1;
-		}
+		return  true;
+	default:
 		break;
 	}
 
-	return is_wol_supported;
+	return false;
 }
 
 /**
-- 
2.5.5
