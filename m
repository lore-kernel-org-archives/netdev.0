From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 2/2] i40e: Retain MAC filters on port VLAN deletion
Date: Mon, 13 Jan 2014 16:13:04 -0800
Message-ID: <1389658384-15825-3-git-send-email-aaron.f.brown@intel.com>
References: <1389658384-15825-1-git-send-email-aaron.f.brown@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26269 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751289AbaANANP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jan 2014 19:13:15 -0500
In-Reply-To: <1389658384-15825-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

On port VLAN deletion the list of MAC filters for the virtual function (VF) 
VSI were all deleted.  Let's keep them around, they come in handy for keeping 
the VF functional.

Change-Id: I335e760392f274dc8b8b40efcb708f65b49d7973
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  3 +++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 13 +++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ad04da2..e210f8f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1845,7 +1845,10 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 				return -ENOMEM;
 			}
 		}
+	}
 
+	/* Do not assume that I40E_VLAN_ANY should be reset to VLAN 0 */
+	if (vid > 0 && !vsi->info.pvid) {
 		list_for_each_entry(f, &vsi->mac_filter_list, list) {
 			if (i40e_find_filter(vsi, f->macaddr, I40E_VLAN_ANY,
 					     is_vf, is_netdev)) {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index ecb873c..437f9e9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2081,6 +2081,15 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 			"VF %d has already configured VLAN filters and the administrator is requesting a port VLAN override.\nPlease unload and reload the VF driver for this change to take effect.\n",
 			vf_id);
 
+	/* Check for condition where there was already a port VLAN ID
+	 * filter set and now it is being deleted by setting it to zero.
+	 * Before deleting all the old VLAN filters we must add new ones
+	 * with -1 (I40E_VLAN_ANY) or otherwise we're left with all our
+	 * MAC addresses deleted.
+	 */
+	if (!(vlan_id || qos) && vsi->info.pvid)
+		ret = i40e_vsi_add_vlan(vsi, I40E_VLAN_ANY);
+
 	if (vsi->info.pvid) {
 		/* kill old VLAN */
 		ret = i40e_vsi_kill_vlan(vsi, (le16_to_cpu(vsi->info.pvid) &
@@ -2109,6 +2118,10 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 				 vsi->back->hw.aq.asq_last_status);
 			goto error_pvid;
 		}
+		/* Kill non-vlan MAC filters - ignore error return since
+		 * there might not be any non-vlan MAC filters.
+		 */
+		i40e_vsi_kill_vlan(vsi, I40E_VLAN_ANY);
 	}
 
 	if (ret) {
-- 
1.8.5.GIT
