From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/12] ixgbe: Add support for tracking the default user priority to SR-IOV
Date: Mon, 22 Oct 2012 21:26:15 -0700
Message-ID: <1350966385-19020-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350966385-19020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:35959 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753031Ab2JWE03 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 00:26:29 -0400
In-Reply-To: <1350966385-19020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

It is necessary to track the default user priority in the PF so that we can
force it upon the VFs.  The motivation behind this is to keep the VFs from
getting access to user priorities meant for things like storage.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 20 ++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 53 ++++++++++++++++----------
 3 files changed, 55 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index ccb8505..101e525 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -601,6 +601,8 @@ struct ixgbe_adapter {
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *ixgbe_dbg_adapter;
 #endif /*CONFIG_DEBUG_FS*/
+
+	u8 default_up;
 };
 
 struct ixgbe_fdir_filter {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3ef74f8..35be7d3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5460,6 +5460,23 @@ static void ixgbe_watchdog_update_link(struct ixgbe_adapter *adapter)
 	adapter->link_speed = link_speed;
 }
 
+static void ixgbe_update_default_up(struct ixgbe_adapter *adapter)
+{
+#ifdef CONFIG_IXGBE_DCB
+	struct net_device *netdev = adapter->netdev;
+	struct dcb_app app = {
+			      .selector = IEEE_8021QAZ_APP_SEL_ETHERTYPE,
+			      .protocol = 0,
+			     };
+	u8 up = 0;
+
+	if (adapter->dcbx_cap & DCB_CAP_DCBX_VER_IEEE)
+		up = dcb_ieee_getapp_mask(netdev, &app);
+
+	adapter->default_up = (up > 1) ? (ffs(up) - 1) : 0;
+#endif
+}
+
 /**
  * ixgbe_watchdog_link_is_up - update netif_carrier status and
  *                             print link up message
@@ -5519,6 +5536,9 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 	netif_carrier_on(netdev);
 	ixgbe_check_vf_rate_limit(adapter);
 
+	/* update the default user priority for VFs */
+	ixgbe_update_default_up(adapter);
+
 	/* ping all the active vfs to let them know link has changed */
 	ixgbe_ping_all_vfs(adapter);
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index f563625..b330a1c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -431,35 +431,47 @@ static void ixgbe_set_vmolr(struct ixgbe_hw *hw, u32 vf, bool aupe)
 	IXGBE_WRITE_REG(hw, IXGBE_VMOLR(vf), vmolr);
 }
 
-static void ixgbe_set_vmvir(struct ixgbe_adapter *adapter, u32 vid, u32 vf)
+static void ixgbe_set_vmvir(struct ixgbe_adapter *adapter,
+			    u16 vid, u16 qos, u32 vf)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
+	u32 vmvir = vid | (qos << VLAN_PRIO_SHIFT) | IXGBE_VMVIR_VLANA_DEFAULT;
 
-	if (vid)
-		IXGBE_WRITE_REG(hw, IXGBE_VMVIR(vf),
-				(vid | IXGBE_VMVIR_VLANA_DEFAULT));
-	else
-		IXGBE_WRITE_REG(hw, IXGBE_VMVIR(vf), 0);
+	IXGBE_WRITE_REG(hw, IXGBE_VMVIR(vf), vmvir);
 }
 
+static void ixgbe_clear_vmvir(struct ixgbe_adapter *adapter, u32 vf)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	IXGBE_WRITE_REG(hw, IXGBE_VMVIR(vf), 0);
+}
 static inline void ixgbe_vf_reset_event(struct ixgbe_adapter *adapter, u32 vf)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
+	struct vf_data_storage *vfinfo = &adapter->vfinfo[vf];
 	int rar_entry = hw->mac.num_rar_entries - (vf + 1);
+	u8 num_tcs = netdev_get_num_tc(adapter->netdev);
+
+	/* add PF assigned VLAN or VLAN 0 */
+	ixgbe_set_vf_vlan(adapter, true, vfinfo->pf_vlan, vf);
 
 	/* reset offloads to defaults */
-	if (adapter->vfinfo[vf].pf_vlan) {
-		ixgbe_set_vf_vlan(adapter, true,
-				  adapter->vfinfo[vf].pf_vlan, vf);
-		ixgbe_set_vmvir(adapter,
-				(adapter->vfinfo[vf].pf_vlan |
-				 (adapter->vfinfo[vf].pf_qos <<
-				  VLAN_PRIO_SHIFT)), vf);
-		ixgbe_set_vmolr(hw, vf, false);
+	ixgbe_set_vmolr(hw, vf, !vfinfo->pf_vlan);
+
+	/* set outgoing tags for VFs */
+	if (!vfinfo->pf_vlan && !vfinfo->pf_qos && !num_tcs) {
+		ixgbe_clear_vmvir(adapter, vf);
 	} else {
-		ixgbe_set_vf_vlan(adapter, true, 0, vf);
-		ixgbe_set_vmvir(adapter, 0, vf);
-		ixgbe_set_vmolr(hw, vf, true);
+		if (vfinfo->pf_qos || !num_tcs)
+			ixgbe_set_vmvir(adapter, vfinfo->pf_vlan,
+					vfinfo->pf_qos, vf);
+		else
+			ixgbe_set_vmvir(adapter, vfinfo->pf_vlan,
+					adapter->default_up, vf);
+
+		if (vfinfo->spoofchk_enabled)
+			hw->mac.ops.set_vlan_anti_spoofing(hw, true, vf);
 	}
 
 	/* reset multicast table array for vf */
@@ -661,8 +673,9 @@ static int ixgbe_set_vf_vlan_msg(struct ixgbe_adapter *adapter,
 	int add = (msgbuf[0] & IXGBE_VT_MSGINFO_MASK) >> IXGBE_VT_MSGINFO_SHIFT;
 	int vid = (msgbuf[1] & IXGBE_VLVF_VLANID_MASK);
 	int err;
+	u8 tcs = netdev_get_num_tc(adapter->netdev);
 
-	if (adapter->vfinfo[vf].pf_vlan) {
+	if (adapter->vfinfo[vf].pf_vlan || tcs) {
 		e_warn(drv,
 		       "VF %d attempted to override administratively set VLAN configuration\n"
 		       "Reload the VF driver to resume operations\n",
@@ -896,7 +909,7 @@ int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos)
 		err = ixgbe_set_vf_vlan(adapter, true, vlan, vf);
 		if (err)
 			goto out;
-		ixgbe_set_vmvir(adapter, vlan | (qos << VLAN_PRIO_SHIFT), vf);
+		ixgbe_set_vmvir(adapter, vlan, qos, vf);
 		ixgbe_set_vmolr(hw, vf, false);
 		if (adapter->vfinfo[vf].spoofchk_enabled)
 			hw->mac.ops.set_vlan_anti_spoofing(hw, true, vf);
@@ -916,7 +929,7 @@ int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos)
 	} else {
 		err = ixgbe_set_vf_vlan(adapter, false,
 					adapter->vfinfo[vf].pf_vlan, vf);
-		ixgbe_set_vmvir(adapter, vlan, vf);
+		ixgbe_clear_vmvir(adapter, vf);
 		ixgbe_set_vmolr(hw, vf, true);
 		hw->mac.ops.set_vlan_anti_spoofing(hw, false, vf);
 		if (adapter->vfinfo[vf].vlan_count)
-- 
1.7.11.7
