From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] ixgbe: Look up MAC address in Open Firmware or IDPROM
Date: Fri,  5 Dec 2014 09:52:42 -0800
Message-ID: <1417801973-28793-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1417801973-28793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Martin K Petersen <mkp@mkp.net>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Martin K Petersen <martin.petersen@oracle.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:7163 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751848AbaLERxw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2014 12:53:52 -0500
In-Reply-To: <1417801973-28793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin K Petersen <mkp@mkp.net>

Attempt to look up the MAC address in Open Firmware on systems that
support it. On SPARC resort to using the IDPROM if no OF address is
found.

Signed-off-by: Martin K Petersen <martin.petersen@oracle.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 35 +++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 73cd0fe..18ddffb 100644
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
@@ -8021,6 +8031,29 @@ int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
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
@@ -8289,6 +8322,8 @@ skip_sriov:
 		goto err_sw_init;
 	}
 
+	ixgbe_get_platform_mac_addr(adapter);
+
 	memcpy(netdev->dev_addr, hw->mac.perm_addr, netdev->addr_len);
 
 	if (!is_valid_ether_addr(netdev->dev_addr)) {
-- 
1.9.3
