From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/8] ixgbe: FCoE: Add support for ndo_get_fcoe_hbainfo() call
Date: Wed,  4 Jan 2012 22:23:40 -0800
Message-ID: <1325744620-5067-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1325744620-5067-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <Neerav.Parikh@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28297 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751731Ab2AEGXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jan 2012 01:23:50 -0500
In-Reply-To: <1325744620-5067-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <Neerav.Parikh@intel.com>

This patch implements support for ndo_get_fcoe_hbainfo()
call in the ixgbe driver.

This function will be called by the FCoE protocol stack to
obtain device specific information from the underlying
device configured to do FCoE.

Signed-off-by: Neerav Parikh <Neerav.Parikh@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    3 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c |   83 +++++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    5 +-
 3 files changed, 90 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index a8368d5..258164d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -560,6 +560,7 @@ extern int ixgbe_copy_dcb_cfg(struct ixgbe_dcb_config *src_dcb_cfg,
 
 extern char ixgbe_driver_name[];
 extern const char ixgbe_driver_version[];
+extern char ixgbe_default_device_descr[];
 
 extern void ixgbe_up(struct ixgbe_adapter *adapter);
 extern void ixgbe_down(struct ixgbe_adapter *adapter);
@@ -627,6 +628,8 @@ extern u8 ixgbe_fcoe_getapp(struct ixgbe_adapter *adapter);
 extern u8 ixgbe_fcoe_setapp(struct ixgbe_adapter *adapter, u8 up);
 #endif /* CONFIG_IXGBE_DCB */
 extern int ixgbe_fcoe_get_wwn(struct net_device *netdev, u64 *wwn, int type);
+extern int ixgbe_fcoe_get_hbainfo(struct net_device *netdev,
+				  struct netdev_fcoe_hbainfo *info);
 #endif /* IXGBE_FCOE */
 
 #endif /* _IXGBE_H_ */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index df3b1be..d18d615 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -855,3 +855,86 @@ int ixgbe_fcoe_get_wwn(struct net_device *netdev, u64 *wwn, int type)
 	}
 	return rc;
 }
+
+/**
+ * ixgbe_fcoe_get_hbainfo - get FCoE HBA information
+ * @netdev : ixgbe adapter
+ * @info : HBA information
+ *
+ * Returns ixgbe HBA information
+ *
+ * Returns : 0 on success
+ */
+int ixgbe_fcoe_get_hbainfo(struct net_device *netdev,
+			   struct netdev_fcoe_hbainfo *info)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	int i, pos;
+	u8 buf[8];
+
+	if (!info)
+		return -EINVAL;
+
+	/* Don't return information on unsupported devices */
+	if (hw->mac.type != ixgbe_mac_82599EB &&
+	    hw->mac.type != ixgbe_mac_X540)
+		return -EINVAL;
+
+	/* Manufacturer */
+	snprintf(info->manufacturer, sizeof(info->manufacturer),
+		 "Intel Corporation");
+
+	/* Serial Number */
+
+	/* Get the PCI-e Device Serial Number Capability */
+	pos = pci_find_ext_capability(adapter->pdev, PCI_EXT_CAP_ID_DSN);
+	if (pos) {
+		pos += 4;
+		for (i = 0; i < 8; i++)
+			pci_read_config_byte(adapter->pdev, pos + i, &buf[i]);
+
+		snprintf(info->serial_number, sizeof(info->serial_number),
+			 "%02X%02X%02X%02X%02X%02X%02X%02X",
+			 buf[7], buf[6], buf[5], buf[4],
+			 buf[3], buf[2], buf[1], buf[0]);
+	} else
+		snprintf(info->serial_number, sizeof(info->serial_number),
+			 "Unknown");
+
+	/* Hardware Version */
+	snprintf(info->hardware_version,
+		 sizeof(info->hardware_version),
+		 "Rev %d", hw->revision_id);
+	/* Driver Name/Version */
+	snprintf(info->driver_version,
+		 sizeof(info->driver_version),
+		 "%s v%s",
+		 ixgbe_driver_name,
+		 ixgbe_driver_version);
+	/* Firmware Version */
+	snprintf(info->firmware_version,
+		 sizeof(info->firmware_version),
+		 "0x%08x",
+		 (adapter->eeprom_verh << 16) |
+		  adapter->eeprom_verl);
+
+	/* Model */
+	if (hw->mac.type == ixgbe_mac_82599EB) {
+		snprintf(info->model,
+			 sizeof(info->model),
+			 "Intel 82599");
+	} else {
+		snprintf(info->model,
+			 sizeof(info->model),
+			 "Intel X540");
+	}
+
+	/* Model Description */
+	snprintf(info->model_description,
+		 sizeof(info->model_description),
+		 "%s",
+		 ixgbe_default_device_descr);
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 74669a8..1ee5d0f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -55,6 +55,8 @@
 char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
 			      "Intel(R) 10 Gigabit PCI Express Network Driver";
+char ixgbe_default_device_descr[] =
+			      "Intel(R) 10 Gigabit Network Connection";
 #define MAJ 3
 #define MIN 6
 #define BUILD 7
@@ -7293,6 +7295,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_fcoe_enable = ixgbe_fcoe_enable,
 	.ndo_fcoe_disable = ixgbe_fcoe_disable,
 	.ndo_fcoe_get_wwn = ixgbe_fcoe_get_wwn,
+	.ndo_fcoe_get_hbainfo = ixgbe_fcoe_get_hbainfo,
 #endif /* IXGBE_FCOE */
 	.ndo_set_features = ixgbe_set_features,
 	.ndo_fix_features = ixgbe_fix_features,
@@ -7722,7 +7725,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	/* add san mac addr to netdev */
 	ixgbe_add_sanmac_netdev(netdev);
 
-	e_dev_info("Intel(R) 10 Gigabit Network Connection\n");
+	e_dev_info("%s\n", ixgbe_default_device_descr);
 	cards_found++;
 	return 0;
 
-- 
1.7.7.5
