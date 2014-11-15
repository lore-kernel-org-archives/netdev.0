From: "Martin K. Petersen" <mkp@mkp.net>
Subject: [PATCH v3] ixgbe: Look up MAC address in Open Firmware or IDPROM
Date: Fri, 14 Nov 2014 21:16:25 -0500
Message-ID: <yq17fyxus1y.fsf@sermon.lab.mkp.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux.nics@intel.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mojo.mkp.net ([70.38.64.14]:46219 "EHLO mojo.mkp.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755011AbaKOCpQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2014 21:45:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Attempt to look up the MAC address in Open Firmware on systems that
support it. On SPARC resort to using the IDPROM if no OF address is
found.

Signed-off-by: Martin K. Petersen <martin.petersen@oracle.com>

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d2df4e3d1032..11b6997150d9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -42,6 +42,7 @@
 #include <linux/slab.h>
 #include <net/checksum.h>
 #include <net/ip6_checksum.h>
+#include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/if.h>
 #include <linux/if_vlan.h>
@@ -50,6 +51,15 @@
 #include <linux/prefetch.h>
 #include <scsi/fc/fc_fcoe.h>
 
+#ifdef CONFIG_OF
+#include <linux/of_net.h>
+#endif
+
+#ifdef CONFIG_SPARC
+#include <asm/idprom.h>
+#include <asm/prom.h>
+#endif
+
 #include "ixgbe.h"
 #include "ixgbe_common.h"
 #include "ixgbe_dcb_82599.h"
@@ -7960,6 +7970,29 @@ int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
 }
 
 /**
+ * ixgbe_get_platform_mac_addr - Look up MAC address in Open Firmware / IDPROM
+ * @adapter: Pointer to adapter struct
+ */
+static void ixgbe_get_platform_mac_addr(struct ixgbe_adapter *adapter)
+{
+#ifdef CONFIG_OF
+	struct device_node *dp = pci_device_to_OF_node(adapter->pdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	const unsigned char *addr;
+
+	addr = of_get_mac_address(dp);
+	if (addr) {
+		ether_addr_copy(hw->mac.perm_addr, addr);
+		return;
+	}
+#endif /* CONFIG_OF */
+
+#ifdef CONFIG_SPARC
+	ether_addr_copy(hw->mac.perm_addr, idprom->id_ethaddr);
+#endif /* CONFIG_SPARC */
+}
+
+/**
  * ixgbe_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in ixgbe_pci_tbl
@@ -8223,6 +8256,8 @@ skip_sriov:
 		goto err_sw_init;
 	}
 
+	ixgbe_get_platform_mac_addr(adapter);
+
 	memcpy(netdev->dev_addr, hw->mac.perm_addr, netdev->addr_len);
 
 	if (!is_valid_ether_addr(netdev->dev_addr)) {
