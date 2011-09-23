From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/8] ixgbe: add WOL support for X540
Date: Fri, 23 Sep 2011 09:12:46 -0700
Message-ID: <1316794367-23265-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316794367-23265-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:35014 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752118Ab1IWQTC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Sep 2011 12:19:02 -0400
In-Reply-To: <1316794367-23265-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Add support for WOL as determined by the EEPROM.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   13 +++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   14 ++++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |    4 ++++
 4 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index b43b2cd..1f4a4ca 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -491,6 +491,7 @@ struct ixgbe_adapter {
 	u64 rsc_total_flush;
 	u32 wol;
 	u16 eeprom_version;
+	u16 eeprom_cap;
 
 	int node;
 	u32 led_reg;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 63cd2a1..debcf5f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1888,6 +1888,7 @@ static int ixgbe_wol_exclusion(struct ixgbe_adapter *adapter,
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	int retval = 1;
+	u16 wol_cap = adapter->eeprom_cap & IXGBE_DEVICE_CAPS_WOL_MASK;
 
 	/* WOL not supported except for the following */
 	switch(hw->device_id) {
@@ -1911,6 +1912,18 @@ static int ixgbe_wol_exclusion(struct ixgbe_adapter *adapter,
 	case IXGBE_DEV_ID_82599_KX4:
 		retval = 0;
 		break;
+	case IXGBE_DEV_ID_X540T:
+		/* check eeprom to see if enabled wol */
+		if ((wol_cap == IXGBE_DEVICE_CAPS_WOL_PORT0_1) ||
+		    ((wol_cap == IXGBE_DEVICE_CAPS_WOL_PORT0) &&
+		     (hw->bus.func == 0))) {
+			retval = 0;
+			break;
+		}
+
+		/* All others not supported */
+		wol->supported = 0;
+		break;
 	default:
 		wol->supported = 0;
 	}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index fae2f44..5f50f1b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7074,6 +7074,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	u16 device_caps;
 #endif
 	u32 eec;
+	u16 wol_cap;
 
 	/* Catch broken hardware that put the wrong VF device ID in
 	 * the PCIe SR-IOV capability.
@@ -7338,6 +7339,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		netdev->features &= ~NETIF_F_RXHASH;
 	}
 
+	/* WOL not supported for all but the following */
+	adapter->wol = 0;
 	switch (pdev->device) {
 	case IXGBE_DEV_ID_82599_SFP:
 		/* Only this subdevice supports WOL */
@@ -7352,8 +7355,15 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	case IXGBE_DEV_ID_82599_KX4:
 		adapter->wol = IXGBE_WUFC_MAG;
 		break;
-	default:
-		adapter->wol = 0;
+	case IXGBE_DEV_ID_X540T:
+		/* Check eeprom to see if it is enabled */
+		hw->eeprom.ops.read(hw, 0x2c, &adapter->eeprom_cap);
+		wol_cap = adapter->eeprom_cap & IXGBE_DEVICE_CAPS_WOL_MASK;
+
+		if ((wol_cap == IXGBE_DEVICE_CAPS_WOL_PORT0_1) ||
+		    ((wol_cap == IXGBE_DEVICE_CAPS_WOL_PORT0) &&
+		     (hw->bus.func == 0)))
+			adapter->wol = IXGBE_WUFC_MAG;
 		break;
 	}
 	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index b119cd6..9a03341 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1754,6 +1754,10 @@ enum {
 #define IXGBE_ALT_SAN_MAC_ADDR_CAPS_SANMAC  0x0 /* Alt. SAN MAC exists */
 #define IXGBE_ALT_SAN_MAC_ADDR_CAPS_ALTWWN  0x1 /* Alt. WWN base exists */
 
+#define IXGBE_DEVICE_CAPS_WOL_PORT0_1  0x4 /* WoL supported on ports 0 & 1 */
+#define IXGBE_DEVICE_CAPS_WOL_PORT0    0x8 /* WoL supported on port 0 */
+#define IXGBE_DEVICE_CAPS_WOL_MASK     0xC /* Mask for WoL capabilities */
+
 /* PCI Bus Info */
 #define IXGBE_PCI_DEVICE_STATUS   0xAA
 #define IXGBE_PCI_DEVICE_STATUS_TRANSACTION_PENDING   0x0020
-- 
1.7.6.2
