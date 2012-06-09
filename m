From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/9] igb: Update firmware info output
Date: Sat,  9 Jun 2012 01:20:57 -0700
Message-ID: <1339230063-12545-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1339230063-12545-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8495 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751985Ab2FIIVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2012 04:21:09 -0400
In-Reply-To: <1339230063-12545-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

Our NVM image creation tools have evolved over the years and there are
multiple versions contained in them, depending on the tool used to create
them.  This patch outputs the NVM versions available in ethtool -i output.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h         |   15 ++++++
 drivers/net/ethernet/intel/igb/igb_ethtool.c |   16 +++----
 drivers/net/ethernet/intel/igb/igb_main.c    |   66 ++++++++++++++++++++++++++
 3 files changed, 87 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 4bf856f..989f266 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -78,6 +78,20 @@ struct igb_adapter;
 #define IGB_82576_VF_DEV_ID                0x10CA
 #define IGB_I350_VF_DEV_ID                 0x1520
 
+/* NVM version defines */
+#define IGB_MAJOR_MASK			0xF000
+#define IGB_MINOR_MASK			0x0FF0
+#define IGB_BUILD_MASK			0x000F
+#define IGB_COMB_VER_MASK		0x00FF
+#define IGB_MAJOR_SHIFT			12
+#define IGB_MINOR_SHIFT			4
+#define IGB_COMB_VER_SHFT		8
+#define IGB_NVM_VER_INVALID		0xFFFF
+#define IGB_ETRACK_SHIFT		16
+#define NVM_ETRACK_WORD			0x0042
+#define NVM_COMB_VER_OFF		0x0083
+#define NVM_COMB_VER_PTR		0x003d
+
 struct vf_data_storage {
 	unsigned char vf_mac_addresses[ETH_ALEN];
 	u16 vf_mc_hashes[IGB_MAX_VF_MC_ENTRIES];
@@ -396,6 +410,7 @@ struct igb_adapter {
 	struct hwmon_buff igb_hwmon_buff;
 	bool ets;
 #endif /* CONFIG_IGB_HWMON */
+	char fw_version[32];
 };
 
 #define IGB_FLAG_HAS_MSI           (1 << 0)
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 812d4f9..7b6387c 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -718,20 +718,16 @@ static void igb_get_drvinfo(struct net_device *netdev,
 			    struct ethtool_drvinfo *drvinfo)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
-	u16 eeprom_data;
 
 	strlcpy(drvinfo->driver,  igb_driver_name, sizeof(drvinfo->driver));
 	strlcpy(drvinfo->version, igb_driver_version, sizeof(drvinfo->version));
 
-	/* EEPROM image version # is reported as firmware version # for
-	 * 82575 controllers */
-	adapter->hw.nvm.ops.read(&adapter->hw, 5, 1, &eeprom_data);
-	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
-		"%d.%d-%d",
-		(eeprom_data & 0xF000) >> 12,
-		(eeprom_data & 0x0FF0) >> 4,
-		eeprom_data & 0x000F);
-
+	/*
+	 * EEPROM image version # is reported as firmware version # for
+	 * 82575 controllers
+	 */
+	strlcpy(drvinfo->fw_version, adapter->fw_version,
+		sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
 	drvinfo->n_stats = IGB_STATS_LEN;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index e94a99b..c19dd55 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1821,6 +1821,69 @@ static const struct net_device_ops igb_netdev_ops = {
 };
 
 /**
+ * igb_set_fw_version - Configure version string for ethtool
+ * @adapter: adapter struct
+ *
+ **/
+static void igb_set_fw_version(struct igb_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u16 eeprom_verh, eeprom_verl, comb_verh, comb_verl, comb_offset;
+	u16 major, build, patch, fw_version;
+	u32 etrack_id;
+
+	hw->nvm.ops.read(hw, 5, 1, &fw_version);
+	if (adapter->hw.mac.type != e1000_i211) {
+		hw->nvm.ops.read(hw, NVM_ETRACK_WORD, 1, &eeprom_verh);
+		hw->nvm.ops.read(hw, (NVM_ETRACK_WORD + 1), 1, &eeprom_verl);
+		etrack_id = (eeprom_verh << IGB_ETRACK_SHIFT) | eeprom_verl;
+
+		/* combo image version needs to be found */
+		hw->nvm.ops.read(hw, NVM_COMB_VER_PTR, 1, &comb_offset);
+		if ((comb_offset != 0x0) &&
+		    (comb_offset != IGB_NVM_VER_INVALID)) {
+			hw->nvm.ops.read(hw, (NVM_COMB_VER_OFF + comb_offset
+					 + 1), 1, &comb_verh);
+			hw->nvm.ops.read(hw, (NVM_COMB_VER_OFF + comb_offset),
+					 1, &comb_verl);
+
+			/* Only display Option Rom if it exists and is valid */
+			if ((comb_verh && comb_verl) &&
+			    ((comb_verh != IGB_NVM_VER_INVALID) &&
+			     (comb_verl != IGB_NVM_VER_INVALID))) {
+				major = comb_verl >> IGB_COMB_VER_SHFT;
+				build = (comb_verl << IGB_COMB_VER_SHFT) |
+					(comb_verh >> IGB_COMB_VER_SHFT);
+				patch = comb_verh & IGB_COMB_VER_MASK;
+				snprintf(adapter->fw_version,
+					 sizeof(adapter->fw_version),
+					 "%d.%d%d, 0x%08x, %d.%d.%d",
+					 (fw_version & IGB_MAJOR_MASK) >>
+					 IGB_MAJOR_SHIFT,
+					 (fw_version & IGB_MINOR_MASK) >>
+					 IGB_MINOR_SHIFT,
+					 (fw_version & IGB_BUILD_MASK),
+					 etrack_id, major, build, patch);
+				goto out;
+			}
+		}
+		snprintf(adapter->fw_version, sizeof(adapter->fw_version),
+			 "%d.%d%d, 0x%08x",
+			 (fw_version & IGB_MAJOR_MASK) >> IGB_MAJOR_SHIFT,
+			 (fw_version & IGB_MINOR_MASK) >> IGB_MINOR_SHIFT,
+			 (fw_version & IGB_BUILD_MASK), etrack_id);
+	} else {
+		snprintf(adapter->fw_version, sizeof(adapter->fw_version),
+			 "%d.%d%d",
+			 (fw_version & IGB_MAJOR_MASK) >> IGB_MAJOR_SHIFT,
+			 (fw_version & IGB_MINOR_MASK) >> IGB_MINOR_SHIFT,
+			 (fw_version & IGB_BUILD_MASK));
+	}
+out:
+	return;
+}
+
+/**
  * igb_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in igb_pci_tbl
@@ -2030,6 +2093,9 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		goto err_eeprom;
 	}
 
+	/* get firmware version for ethtool -i */
+	igb_set_fw_version(adapter);
+
 	setup_timer(&adapter->watchdog_timer, igb_watchdog,
 	            (unsigned long) adapter);
 	setup_timer(&adapter->phy_info_timer, igb_update_phy_info,
-- 
1.7.10.2
