From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] ixgbe: Add error checking to setting VF MAC
Date: Wed, 31 May 2017 14:19:27 -0700
Message-ID: <20170531211936.63417-7-jeffrey.t.kirsher@intel.com>
References: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:38747 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750977AbdEaVTu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 17:19:50 -0400
In-Reply-To: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

Currently, when setting a VF MAC address there are no error checks to
ensure that the MAC filter was successfully added.  This patch adds
additional error checks, reporting, and propagation of errors.  It also
will not set the MAC address unless adding the MAC filter was successful.

With these changes, setting the mac address to zeros can no longer call
ixgbe_set_vf_mac() as adding a zero MAC address filter is not valid.
Instead directly delete the filter and, if successful, clear the MAC
address.

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 54 +++++++++++++++++++-------
 1 file changed, 41 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 8baf298a8516..13c96a13841e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -778,11 +778,17 @@ static inline void ixgbe_vf_reset_event(struct ixgbe_adapter *adapter, u32 vf)
 static int ixgbe_set_vf_mac(struct ixgbe_adapter *adapter,
 			    int vf, unsigned char *mac_addr)
 {
+	s32 retval;
+
 	ixgbe_del_mac_filter(adapter, adapter->vfinfo[vf].vf_mac_addresses, vf);
-	memcpy(adapter->vfinfo[vf].vf_mac_addresses, mac_addr, ETH_ALEN);
-	ixgbe_add_mac_filter(adapter, adapter->vfinfo[vf].vf_mac_addresses, vf);
+	retval = ixgbe_add_mac_filter(adapter, mac_addr, vf);
+	if (retval >= 0)
+		memcpy(adapter->vfinfo[vf].vf_mac_addresses, mac_addr,
+		       ETH_ALEN);
+	else
+		memset(adapter->vfinfo[vf].vf_mac_addresses, 0, ETH_ALEN);
 
-	return 0;
+	return retval;
 }
 
 int ixgbe_vf_configuration(struct pci_dev *pdev, unsigned int event_mask)
@@ -1347,27 +1353,49 @@ void ixgbe_ping_all_vfs(struct ixgbe_adapter *adapter)
 int ixgbe_ndo_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	s32 retval;
 
 	if (vf >= adapter->num_vfs)
 		return -EINVAL;
 
-	if (is_zero_ether_addr(mac)) {
-		adapter->vfinfo[vf].pf_set_mac = false;
-		dev_info(&adapter->pdev->dev, "removing MAC on VF %d\n", vf);
-	} else if (is_valid_ether_addr(mac)) {
-		adapter->vfinfo[vf].pf_set_mac = true;
+	if (is_valid_ether_addr(mac)) {
 		dev_info(&adapter->pdev->dev, "setting MAC %pM on VF %d\n",
 			 mac, vf);
 		dev_info(&adapter->pdev->dev, "Reload the VF driver to make this change effective.");
-		if (test_bit(__IXGBE_DOWN, &adapter->state)) {
-			dev_warn(&adapter->pdev->dev, "The VF MAC address has been set, but the PF device is not up.\n");
-			dev_warn(&adapter->pdev->dev, "Bring the PF device up before attempting to use the VF device.\n");
+
+		retval = ixgbe_set_vf_mac(adapter, vf, mac);
+		if (retval >= 0) {
+			adapter->vfinfo[vf].pf_set_mac = true;
+
+			if (test_bit(__IXGBE_DOWN, &adapter->state)) {
+				dev_warn(&adapter->pdev->dev, "The VF MAC address has been set, but the PF device is not up.\n");
+				dev_warn(&adapter->pdev->dev, "Bring the PF device up before attempting to use the VF device.\n");
+			}
+		} else {
+			dev_warn(&adapter->pdev->dev, "The VF MAC address was NOT set due to invalid or duplicate MAC address.\n");
+		}
+	} else if (is_zero_ether_addr(mac)) {
+		unsigned char *vf_mac_addr =
+					   adapter->vfinfo[vf].vf_mac_addresses;
+
+		/* nothing to do */
+		if (is_zero_ether_addr(vf_mac_addr))
+			return 0;
+
+		dev_info(&adapter->pdev->dev, "removing MAC on VF %d\n", vf);
+
+		retval = ixgbe_del_mac_filter(adapter, vf_mac_addr, vf);
+		if (retval >= 0) {
+			adapter->vfinfo[vf].pf_set_mac = false;
+			memcpy(vf_mac_addr, mac, ETH_ALEN);
+		} else {
+			dev_warn(&adapter->pdev->dev, "Could NOT remove the VF MAC address.\n");
 		}
 	} else {
-		return -EINVAL;
+		retval = -EINVAL;
 	}
 
-	return ixgbe_set_vf_mac(adapter, vf, mac);
+	return retval;
 }
 
 static int ixgbe_enable_port_vlan(struct ixgbe_adapter *adapter, int vf,
-- 
2.12.2
