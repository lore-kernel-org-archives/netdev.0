From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH] netxen: remove old flash check.
Date: Fri,  6 Mar 2009 16:52:12 -0800
Message-ID: <1236387132-31254-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:35406 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756397AbZCGAwT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2009 19:52:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove flash size check which made sense only for ancient
boards with 1MB flash. The check is based on values read
from specific locations and fails with firmware size changes.

This prevents driver from getting right mac addresses.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    1 -
 drivers/net/netxen/netxen_nic_hw.c   |   22 ----------------------
 drivers/net/netxen/netxen_nic_main.c |    3 ---
 3 files changed, 0 insertions(+), 26 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index f4dd9ac..1ff066b 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1595,7 +1595,6 @@ dma_watchdog_wakeup(struct netxen_adapter *adapter)
 }
 
 
-int netxen_is_flash_supported(struct netxen_adapter *adapter);
 int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, __le64 *mac);
 int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, __le64 *mac);
 extern void netxen_change_ringparam(struct netxen_adapter *adapter);
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 821cff6..7fea770 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -706,28 +706,6 @@ int netxen_nic_change_mtu(struct net_device *netdev, int mtu)
 	return rc;
 }
 
-int netxen_is_flash_supported(struct netxen_adapter *adapter)
-{
-	const int locs[] = { 0, 0x4, 0x100, 0x4000, 0x4128 };
-	int addr, val01, val02, i, j;
-
-	/* if the flash size less than 4Mb, make huge war cry and die */
-	for (j = 1; j < 4; j++) {
-		addr = j * NETXEN_NIC_WINDOW_MARGIN;
-		for (i = 0; i < ARRAY_SIZE(locs); i++) {
-			if (netxen_rom_fast_read(adapter, locs[i], &val01) == 0
-			    && netxen_rom_fast_read(adapter, (addr + locs[i]),
-						    &val02) == 0) {
-				if (val01 == val02)
-					return -1;
-			} else
-				return -1;
-		}
-	}
-
-	return 0;
-}
-
 static int netxen_get_flash_block(struct netxen_adapter *adapter, int base,
 				  int size, __le32 * buf)
 {
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 1308778..c172b6e 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -405,9 +405,6 @@ netxen_read_mac_addr(struct netxen_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 
-	if (netxen_is_flash_supported(adapter) != 0)
-		return -EIO;
-
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
 		if (netxen_p3_get_mac_addr(adapter, &mac_addr) != 0)
 			return -EIO;
-- 
1.6.0.2

