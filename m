From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] ixgbe: don't check minimum link when direct assigned to virtual machine
Date: Thu, 24 Jul 2014 06:13:14 -0700
Message-ID: <1406207604-31653-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:36520 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759013AbaGXNOE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 09:14:04 -0400
In-Reply-To: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch prevents the display of the minimum link qualification check
if we might be in a virtual machine. This check is incorrect and
misleading in this case, since we actually don't really know what the
available bandwidth is. To do so, we simply check whether each function
on the bus matches our device id. If it doesn't the most likely scenario
is that we're directly assigned to a virtual machine.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 4268a89..e1f83ee 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7973,7 +7973,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
  **/
 static inline int ixgbe_enumerate_functions(struct ixgbe_adapter *adapter)
 {
-	struct pci_dev *entry;
+	struct pci_dev *entry, *pdev = adapter->pdev;
 	int physfns = 0;
 
 	/* Some cards can not use the generic count PCIe functions method,
@@ -7985,8 +7985,20 @@ static inline int ixgbe_enumerate_functions(struct ixgbe_adapter *adapter)
 
 	list_for_each_entry(entry, &adapter->pdev->bus->devices, bus_list) {
 		/* don't count virtual functions */
-		if (!entry->is_virtfn)
-			physfns++;
+		if (entry->is_virtfn)
+			continue;
+
+		/* When the devices on the bus don't all match our device ID,
+		 * we can't reliably determine the correct number of
+		 * functions. This can occur if a function has been direct
+		 * attached to a virtual machine using VT-d, for example. In
+		 * this case, simply return -1 to indicate this.
+		 */
+		if ((entry->vendor != pdev->vendor) ||
+		    (entry->device != pdev->device))
+			return -1;
+
+		physfns++;
 	}
 
 	return physfns;
@@ -8381,7 +8393,10 @@ skip_sriov:
 		expected_gts = ixgbe_enumerate_functions(adapter) * 10;
 		break;
 	}
-	ixgbe_check_minimum_link(adapter, expected_gts);
+
+	/* don't check link if we failed to enumerate functions */
+	if (expected_gts > 0)
+		ixgbe_check_minimum_link(adapter, expected_gts);
 
 	err = ixgbe_read_pba_string_generic(hw, part_str, sizeof(part_str));
 	if (err)
-- 
1.9.3
