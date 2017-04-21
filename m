From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/11] ixgbe: Allow setting zero MAC address for VF
Date: Thu, 20 Apr 2017 18:50:25 -0700
Message-ID: <20170421015029.18994-8-jeffrey.t.kirsher@intel.com>
References: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:53037 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034427AbdDUBvA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 21:51:00 -0400
In-Reply-To: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

Currently, there is no logic that allows a VF's MAC address to be removed
from the RAR table.

Allow the user to specify a zero MAC address in order to clear the VF's
MAC address from the RAR table.  This functionality is also utilized by
libvirt when removing VFs.

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 28 +++++++++++++++++---------
 1 file changed, 18 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index c45de53300aa..58897d97412e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -1347,18 +1347,26 @@ void ixgbe_ping_all_vfs(struct ixgbe_adapter *adapter)
 int ixgbe_ndo_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	if (!is_valid_ether_addr(mac) || (vf >= adapter->num_vfs))
+
+	if (vf >= adapter->num_vfs)
+		return -EINVAL;
+
+	if (is_zero_ether_addr(mac)) {
+		adapter->vfinfo[vf].pf_set_mac = false;
+		dev_info(&adapter->pdev->dev, "removing MAC on VF %d\n", vf);
+	} else if (is_valid_ether_addr(mac)) {
+		adapter->vfinfo[vf].pf_set_mac = true;
+		dev_info(&adapter->pdev->dev, "setting MAC %pM on VF %d\n",
+			 mac, vf);
+		dev_info(&adapter->pdev->dev, "Reload the VF driver to make this change effective.");
+		if (test_bit(__IXGBE_DOWN, &adapter->state)) {
+			dev_warn(&adapter->pdev->dev, "The VF MAC address has been set, but the PF device is not up.\n");
+			dev_warn(&adapter->pdev->dev, "Bring the PF device up before attempting to use the VF device.\n");
+		}
+	} else {
 		return -EINVAL;
-	adapter->vfinfo[vf].pf_set_mac = true;
-	dev_info(&adapter->pdev->dev, "setting MAC %pM on VF %d\n", mac, vf);
-	dev_info(&adapter->pdev->dev, "Reload the VF driver to make this"
-				      " change effective.");
-	if (test_bit(__IXGBE_DOWN, &adapter->state)) {
-		dev_warn(&adapter->pdev->dev, "The VF MAC address has been set,"
-			 " but the PF device is not up.\n");
-		dev_warn(&adapter->pdev->dev, "Bring the PF device up before"
-			 " attempting to use the VF device.\n");
 	}
+
 	return ixgbe_set_vf_mac(adapter, vf, mac);
 }
 
-- 
2.12.2
