From: jeffrey.t.kirsher@intel.com
Subject: [net-next 03/12] e1000e: properly bounds-check string functions
Date: Thu,  6 Jan 2011 16:29:50 -0800
Message-ID: <1294360199-9860-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gosp@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:19337 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753345Ab1AGAar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 19:30:47 -0500
To: davem@davemloft.net
In-Reply-To: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Use string functions with bounds checking rather than their non-bounds
checking counterparts, and do not hard code these boundaries.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/ethtool.c |   14 +++++++++-----
 drivers/net/e1000e/netdev.c  |    4 ++--
 2 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index affcacf..c942cca 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -624,20 +624,24 @@ static void e1000_get_drvinfo(struct net_device *netdev,
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	char firmware_version[32];
 
-	strncpy(drvinfo->driver,  e1000e_driver_name, 32);
-	strncpy(drvinfo->version, e1000e_driver_version, 32);
+	strncpy(drvinfo->driver,  e1000e_driver_name,
+		sizeof(drvinfo->driver) - 1);
+	strncpy(drvinfo->version, e1000e_driver_version,
+		sizeof(drvinfo->version) - 1);
 
 	/*
 	 * EEPROM image version # is reported as firmware version # for
 	 * PCI-E controllers
 	 */
-	sprintf(firmware_version, "%d.%d-%d",
+	snprintf(firmware_version, sizeof(firmware_version), "%d.%d-%d",
 		(adapter->eeprom_vers & 0xF000) >> 12,
 		(adapter->eeprom_vers & 0x0FF0) >> 4,
 		(adapter->eeprom_vers & 0x000F));
 
-	strncpy(drvinfo->fw_version, firmware_version, 32);
-	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
+	strncpy(drvinfo->fw_version, firmware_version,
+		sizeof(drvinfo->fw_version) - 1);
+	strncpy(drvinfo->bus_info, pci_name(adapter->pdev),
+		sizeof(drvinfo->bus_info) - 1);
 	drvinfo->regdump_len = e1000_get_regs_len(netdev);
 	drvinfo->eedump_len = e1000_get_eeprom_len(netdev);
 }
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 5498689..98729a6 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5639,7 +5639,7 @@ static void e1000_print_device_info(struct e1000_adapter *adapter)
 	ret_val = e1000_read_pba_string_generic(hw, pba_str,
 						E1000_PBANUM_LENGTH);
 	if (ret_val)
-		strcpy(pba_str, "Unknown");
+		strncpy((char *)pba_str, "Unknown", sizeof(pba_str) - 1);
 	e_info("MAC: %d, PHY: %d, PBA No: %s\n",
 	       hw->mac.type, hw->phy.type, pba_str);
 }
@@ -5968,7 +5968,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (!(adapter->flags & FLAG_HAS_AMT))
 		e1000_get_hw_control(adapter);
 
-	strcpy(netdev->name, "eth%d");
+	strncpy(netdev->name, "eth%d", sizeof(netdev->name) - 1);
 	err = register_netdev(netdev);
 	if (err)
 		goto err_register;
-- 
1.7.3.4

