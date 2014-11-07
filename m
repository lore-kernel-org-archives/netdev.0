From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/9] ixgbe: cleanup ixgbe_ndo_set_vf_vlan
Date: Fri,  7 Nov 2014 00:57:48 -0800
Message-ID: <1415350670-15333-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1415350670-15333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41288 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751229AbaKGI57 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2014 03:57:59 -0500
In-Reply-To: <1415350670-15333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Clean up functionality in ixgbe_ndo_set_vf_vlan that will simplify later
patches.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 94 +++++++++++++++++---------
 1 file changed, 61 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 97c85b8..843e10d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -1079,52 +1079,80 @@ int ixgbe_ndo_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 	return ixgbe_set_vf_mac(adapter, vf, mac);
 }
 
+static int ixgbe_enable_port_vlan(struct ixgbe_adapter *adapter, int vf,
+				  u16 vlan, u8 qos)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	int err;
+
+	if (adapter->vfinfo[vf].pf_vlan)
+		err = ixgbe_set_vf_vlan(adapter, false,
+					adapter->vfinfo[vf].pf_vlan,
+					vf);
+	if (err)
+		goto out;
+	ixgbe_set_vmvir(adapter, vlan, qos, vf);
+	ixgbe_set_vmolr(hw, vf, false);
+	if (adapter->vfinfo[vf].spoofchk_enabled)
+		hw->mac.ops.set_vlan_anti_spoofing(hw, true, vf);
+	adapter->vfinfo[vf].vlan_count++;
+	adapter->vfinfo[vf].pf_vlan = vlan;
+	adapter->vfinfo[vf].pf_qos = qos;
+	dev_info(&adapter->pdev->dev,
+		 "Setting VLAN %d, QOS 0x%x on VF %d\n", vlan, qos, vf);
+	if (test_bit(__IXGBE_DOWN, &adapter->state)) {
+		dev_warn(&adapter->pdev->dev,
+			 "The VF VLAN has been set, but the PF device is not up.\n");
+		dev_warn(&adapter->pdev->dev,
+			 "Bring the PF device up before attempting to use the VF device.\n");
+	}
+
+out:
+	return err;
+}
+
+static int ixgbe_disable_port_vlan(struct ixgbe_adapter *adapter, int vf)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	int err;
+
+	err = ixgbe_set_vf_vlan(adapter, false,
+				adapter->vfinfo[vf].pf_vlan, vf);
+	ixgbe_clear_vmvir(adapter, vf);
+	ixgbe_set_vmolr(hw, vf, true);
+	hw->mac.ops.set_vlan_anti_spoofing(hw, false, vf);
+	if (adapter->vfinfo[vf].vlan_count)
+		adapter->vfinfo[vf].vlan_count--;
+	adapter->vfinfo[vf].pf_vlan = 0;
+	adapter->vfinfo[vf].pf_qos = 0;
+
+	return err;
+}
+
 int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos)
 {
 	int err = 0;
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	struct ixgbe_hw *hw = &adapter->hw;
 
 	if ((vf >= adapter->num_vfs) || (vlan > 4095) || (qos > 7))
 		return -EINVAL;
 	if (vlan || qos) {
+		/* Check if there is already a port VLAN set, if so
+		 * we have to delete the old one first before we
+		 * can set the new one.  The usage model had
+		 * previously assumed the user would delete the
+		 * old port VLAN before setting a new one but this
+		 * is not necessarily the case.
+		 */
 		if (adapter->vfinfo[vf].pf_vlan)
-			err = ixgbe_set_vf_vlan(adapter, false,
-						adapter->vfinfo[vf].pf_vlan,
-						vf);
-		if (err)
-			goto out;
-		err = ixgbe_set_vf_vlan(adapter, true, vlan, vf);
+			err = ixgbe_disable_port_vlan(adapter, vf);
 		if (err)
 			goto out;
-		ixgbe_set_vmvir(adapter, vlan, qos, vf);
-		ixgbe_set_vmolr(hw, vf, false);
-		if (adapter->vfinfo[vf].spoofchk_enabled)
-			hw->mac.ops.set_vlan_anti_spoofing(hw, true, vf);
-		adapter->vfinfo[vf].vlan_count++;
-		adapter->vfinfo[vf].pf_vlan = vlan;
-		adapter->vfinfo[vf].pf_qos = qos;
-		dev_info(&adapter->pdev->dev,
-			 "Setting VLAN %d, QOS 0x%x on VF %d\n", vlan, qos, vf);
-		if (test_bit(__IXGBE_DOWN, &adapter->state)) {
-			dev_warn(&adapter->pdev->dev,
-				 "The VF VLAN has been set,"
-				 " but the PF device is not up.\n");
-			dev_warn(&adapter->pdev->dev,
-				 "Bring the PF device up before"
-				 " attempting to use the VF device.\n");
-		}
+		err = ixgbe_enable_port_vlan(adapter, vf, vlan, qos);
 	} else {
-		err = ixgbe_set_vf_vlan(adapter, false,
-					adapter->vfinfo[vf].pf_vlan, vf);
-		ixgbe_clear_vmvir(adapter, vf);
-		ixgbe_set_vmolr(hw, vf, true);
-		hw->mac.ops.set_vlan_anti_spoofing(hw, false, vf);
-		if (adapter->vfinfo[vf].vlan_count)
-			adapter->vfinfo[vf].vlan_count--;
-		adapter->vfinfo[vf].pf_vlan = 0;
-		adapter->vfinfo[vf].pf_qos = 0;
+		err = ixgbe_disable_port_vlan(adapter, vf);
 	}
+
 out:
 	return err;
 }
-- 
1.9.3
