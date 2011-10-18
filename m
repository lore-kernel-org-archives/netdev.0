From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/5] ixgbe: change the eeprom version reported by ethtool
Date: Mon, 17 Oct 2011 17:12:47 -0700
Message-ID: <1318896767-5374-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318896767-5374-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45853 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751402Ab1JRAMx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 20:12:53 -0400
In-Reply-To: <1318896767-5374-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Use 32bit value starting at offset 0x2d for displaying the firmware
version in ethtool. This should work for all current ixgbe HW

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    3 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   13 +++++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |    7 ++++---
 3 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 6c4d693..a8368d5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -497,7 +497,8 @@ struct ixgbe_adapter {
 	u64 rsc_total_count;
 	u64 rsc_total_flush;
 	u32 wol;
-	u16 eeprom_version;
+	u16 eeprom_verh;
+	u16 eeprom_verl;
 	u16 eeprom_cap;
 
 	int node;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 7acfce3..70d58c3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -889,21 +889,22 @@ static void ixgbe_get_drvinfo(struct net_device *netdev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	char firmware_version[32];
+	u32 nvm_track_id;
 
 	strncpy(drvinfo->driver, ixgbe_driver_name,
 	        sizeof(drvinfo->driver) - 1);
 	strncpy(drvinfo->version, ixgbe_driver_version,
 	        sizeof(drvinfo->version) - 1);
 
-	snprintf(firmware_version, sizeof(firmware_version), "%d.%d-%d",
-	         (adapter->eeprom_version & 0xF000) >> 12,
-	         (adapter->eeprom_version & 0x0FF0) >> 4,
-	         adapter->eeprom_version & 0x000F);
+	nvm_track_id = (adapter->eeprom_verh << 16) |
+			adapter->eeprom_verl;
+	snprintf(firmware_version, sizeof(firmware_version), "0x%08x",
+		 nvm_track_id);
 
 	strncpy(drvinfo->fw_version, firmware_version,
-	        sizeof(drvinfo->fw_version));
+		sizeof(drvinfo->fw_version) - 1);
 	strncpy(drvinfo->bus_info, pci_name(adapter->pdev),
-	        sizeof(drvinfo->bus_info));
+		sizeof(drvinfo->bus_info) - 1);
 	drvinfo->n_stats = IXGBE_STATS_LEN;
 	drvinfo->testinfo_len = IXGBE_TEST_LEN;
 	drvinfo->regdump_len = ixgbe_get_regs_len(netdev);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index fb7d884..8075d11 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7640,6 +7640,10 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	}
 	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
 
+	/* save off EEPROM version number */
+	hw->eeprom.ops.read(hw, 0x2e, &adapter->eeprom_verh);
+	hw->eeprom.ops.read(hw, 0x2d, &adapter->eeprom_verl);
+
 	/* pick up the PCI bus settings for reporting later */
 	hw->mac.ops.get_bus_info(hw);
 
@@ -7672,9 +7676,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 			   "is required.\n");
 	}
 
-	/* save off EEPROM version number */
-	hw->eeprom.ops.read(hw, 0x29, &adapter->eeprom_version);
-
 	/* reset the hardware with the new settings */
 	err = hw->mac.ops.start_hw(hw);
 
-- 
1.7.6.4
