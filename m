From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 01/14] i40e: don't degrade __le16
Date: Wed, 26 Aug 2015 15:49:20 -0700
Message-ID: <1440629373-21287-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1440629373-21287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12760 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752996AbbHZWtg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2015 18:49:36 -0400
In-Reply-To: <1440629373-21287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Sparse cries when we compare an __le16 to a u16, almost like it cares
about architectures other than x86. Weird. Use the le16_to_cpu macro to
make it stop crying.

Change-ID: Id068f4d7868a2d3df234a791a76d15938f37db35
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 2 ++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 5 +++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3bb832a..ded62eb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1255,6 +1255,8 @@ struct i40e_mac_filter *i40e_put_mac_in_vlan(struct i40e_vsi *vsi, u8 *macaddr,
 	struct i40e_mac_filter *f;
 
 	list_for_each_entry(f, &vsi->mac_filter_list, list) {
+		if (vsi->info.pvid)
+			f->vlan = le16_to_cpu(vsi->info.pvid);
 		if (!i40e_find_filter(vsi, macaddr, f->vlan,
 				      is_vf, is_netdev)) {
 			if (!i40e_add_filter(vsi, macaddr, f->vlan,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 8a7607c..70a6fb1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2106,11 +2106,12 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 		goto error_pvid;
 	}
 
-	if (vsi->info.pvid == (vlan_id | (qos << I40E_VLAN_PRIORITY_SHIFT)))
+	if (le16_to_cpu(vsi->info.pvid) ==
+	    (vlan_id | (qos << I40E_VLAN_PRIORITY_SHIFT)))
 		/* duplicate request, so just return success */
 		goto error_pvid;
 
-	if (vsi->info.pvid == 0 && i40e_is_vsi_in_vlan(vsi)) {
+	if (le16_to_cpu(vsi->info.pvid) == 0 && i40e_is_vsi_in_vlan(vsi)) {
 		dev_err(&pf->pdev->dev,
 			"VF %d has already configured VLAN filters and the administrator is requesting a port VLAN override.\nPlease unload and reload the VF driver for this change to take effect.\n",
 			vf_id);
-- 
2.4.3
