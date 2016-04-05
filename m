From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 07/14] ixgbe: use eth_platform_get_mac_address()
Date: Mon,  4 Apr 2016 17:58:58 -0700
Message-ID: <1459817945-144915-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459817945-144915-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:38979 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756655AbcDEA7K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2016 20:59:10 -0400
In-Reply-To: <1459817945-144915-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>

This commit converts commit c762dff24c06 ("ixgbe: Look up MAC address in
Open Firmware or IDPROM") to use eth_platform_get_mac_address()
added by commit c7f5d105495a ("net: Add eth_platform_get_mac_address()
helper.")

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 35 ++-------------------------
 1 file changed, 2 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 5f4ecf5..bce5737 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -54,15 +54,6 @@
 #include <net/pkt_cls.h>
 #include <net/tc_act/tc_gact.h>
 
-#ifdef CONFIG_OF
-#include <linux/of_net.h>
-#endif
-
-#ifdef CONFIG_SPARC
-#include <asm/idprom.h>
-#include <asm/prom.h>
-#endif
-
 #include "ixgbe.h"
 #include "ixgbe_common.h"
 #include "ixgbe_dcb_82599.h"
@@ -9011,29 +9002,6 @@ int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
 }
 
 /**
- * ixgbe_get_platform_mac_addr - Look up MAC address in Open Firmware / IDPROM
- * @adapter: Pointer to adapter struct
- */
-static void ixgbe_get_platform_mac_addr(struct ixgbe_adapter *adapter)
-{
-#ifdef CONFIG_OF
-	struct device_node *dp = pci_device_to_OF_node(adapter->pdev);
-	struct ixgbe_hw *hw = &adapter->hw;
-	const unsigned char *addr;
-
-	addr = of_get_mac_address(dp);
-	if (addr) {
-		ether_addr_copy(hw->mac.perm_addr, addr);
-		return;
-	}
-#endif /* CONFIG_OF */
-
-#ifdef CONFIG_SPARC
-	ether_addr_copy(hw->mac.perm_addr, idprom->id_ethaddr);
-#endif /* CONFIG_SPARC */
-}
-
-/**
  * ixgbe_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in ixgbe_pci_tbl
@@ -9304,7 +9272,8 @@ skip_sriov:
 		goto err_sw_init;
 	}
 
-	ixgbe_get_platform_mac_addr(adapter);
+	eth_platform_get_mac_address(&adapter->pdev->dev,
+				     adapter->hw.mac.perm_addr);
 
 	memcpy(netdev->dev_addr, hw->mac.perm_addr, netdev->addr_len);
 
-- 
2.5.5
