From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 09/16] i40e: correctly program filters for VFs
Date: Tue, 14 Jul 2015 18:30:33 -0700
Message-ID: <1436923840-24455-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1436923840-24455-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22319 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752603AbbGOBar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2015 21:30:47 -0400
In-Reply-To: <1436923840-24455-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

MAC filters for VFs were being programmed with 0 for the VLAN value when
there was no VLAN assigned. This is incorrect and actually assigns the
VF to VLAN 0. Instead, we must use -1 to indicate that no VLAN is in
use. This change programs the filters correctly and gets rid of a bogus
error message when setting a port VLAN on an active VF.

Change-ID: Ica9a9906d768405377ff3308e27f7d0b5b2ea96e
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 433e803..4070a22 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -542,11 +542,13 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 		if (vf->port_vlan_id)
 			i40e_vsi_add_pvid(vsi, vf->port_vlan_id);
 		f = i40e_add_filter(vsi, vf->default_lan_addr.addr,
-				    vf->port_vlan_id, true, false);
+				    vf->port_vlan_id ? vf->port_vlan_id : -1,
+				    true, false);
 		if (!f)
 			dev_info(&pf->pdev->dev,
 				 "Could not allocate VF MAC addr\n");
-		f = i40e_add_filter(vsi, brdcast, vf->port_vlan_id,
+		f = i40e_add_filter(vsi, brdcast,
+				    vf->port_vlan_id ? vf->port_vlan_id : -1,
 				    true, false);
 		if (!f)
 			dev_info(&pf->pdev->dev,
@@ -2023,7 +2025,8 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 	}
 
 	/* delete the temporary mac address */
-	i40e_del_filter(vsi, vf->default_lan_addr.addr, vf->port_vlan_id,
+	i40e_del_filter(vsi, vf->default_lan_addr.addr,
+			vf->port_vlan_id ? vf->port_vlan_id : -1,
 			true, false);
 
 	/* Delete all the filters for this VSI - we're going to kill it
-- 
2.4.3
