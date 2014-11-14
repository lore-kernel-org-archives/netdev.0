From: "Martin K. Petersen" <martin.petersen@oracle.com>
Subject: [PATCH] ixgbe: Look up MAC address in Open Firmware
Date: Fri, 14 Nov 2014 14:16:50 -0500
Message-ID: <yq1r3x5vbh9.fsf@sermon.lab.mkp.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux.nics@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31227 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965580AbaKNTQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 14:16:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Attempt to look up the MAC address in Open Firmware on systems that
support it. If the "local-mac-address" property is not valid resort to
using the IDPROM value.

Signed-off-by: Martin K. Petersen <martin.petersen@oracle.com>

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d2df4e3d1032..365924124fab 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -50,6 +50,11 @@
 #include <linux/prefetch.h>
 #include <scsi/fc/fc_fcoe.h>
 
+#ifdef CONFIG_OF
+#include <asm/idprom.h>
+#include <asm/prom.h>
+#endif
+
 #include "ixgbe.h"
 #include "ixgbe_common.h"
 #include "ixgbe_dcb_82599.h"
@@ -7959,6 +7964,31 @@ int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
 	return is_wol_supported;
 }
 
+#ifdef CONFIG_OF
+/**
+ * ixgbe_of_mac_addr - Look up MAC address in Open Firmware
+ * @adapter: Pointer to adapter struct
+ */
+static void ixgbe_of_mac_addr(struct ixgbe_adapter *adapter)
+{
+	struct device_node *dp = pci_device_to_OF_node(adapter->pdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	const unsigned char *addr;
+	int len;
+
+	addr = of_get_property(dp, "local-mac-address", &len);
+	if (addr && len == 6) {
+		e_dev_info("Using OpenPROM MAC address\n");
+		memcpy(hw->mac.perm_addr, addr, 6);
+	}
+
+	if (!is_valid_ether_addr(hw->mac.perm_addr)) {
+		e_dev_info("Using IDPROM MAC address\n");
+		memcpy(hw->mac.perm_addr, idprom->id_ethaddr, 6);
+	}
+}
+#endif
+
 /**
  * ixgbe_probe - Device Initialization Routine
  * @pdev: PCI device information struct
@@ -8223,6 +8253,10 @@ skip_sriov:
 		goto err_sw_init;
 	}
 
+#ifdef CONFIG_OF
+	ixgbe_of_mac_addr(adapter);
+#endif
+
 	memcpy(netdev->dev_addr, hw->mac.perm_addr, netdev->addr_len);
 
 	if (!is_valid_ether_addr(netdev->dev_addr)) {
