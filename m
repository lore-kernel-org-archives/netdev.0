From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] ixgbe: fix use of list_for_each in ixgbe_enumerate_functions
Date: Thu, 24 Jul 2014 06:13:13 -0700
Message-ID: <1406207604-31653-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:36503 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758990AbaGXNOE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 09:14:04 -0400
In-Reply-To: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Fix a bug in the misuse of the list_for_each macro to loop over every
entry in the bus_list. Instead of attempting to loop over the list from
a random entry point, go up to the bus and use the real list_head entry
point. This prevents the possible read or write of unallocated or
incorrectly addressed memory.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 9aa9d0b..4268a89 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7973,23 +7973,20 @@ static const struct net_device_ops ixgbe_netdev_ops = {
  **/
 static inline int ixgbe_enumerate_functions(struct ixgbe_adapter *adapter)
 {
-	struct list_head *entry;
+	struct pci_dev *entry;
 	int physfns = 0;
 
 	/* Some cards can not use the generic count PCIe functions method,
 	 * because they are behind a parent switch, so we hardcode these with
 	 * the correct number of functions.
 	 */
-	if (ixgbe_pcie_from_parent(&adapter->hw)) {
+	if (ixgbe_pcie_from_parent(&adapter->hw))
 		physfns = 4;
-	} else {
-		list_for_each(entry, &adapter->pdev->bus_list) {
-			struct pci_dev *pdev =
-				list_entry(entry, struct pci_dev, bus_list);
-			/* don't count virtual functions */
-			if (!pdev->is_virtfn)
-				physfns++;
-		}
+
+	list_for_each_entry(entry, &adapter->pdev->bus->devices, bus_list) {
+		/* don't count virtual functions */
+		if (!entry->is_virtfn)
+			physfns++;
 	}
 
 	return physfns;
-- 
1.9.3
