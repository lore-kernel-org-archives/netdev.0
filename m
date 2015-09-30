From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/17] i40e: use QOS field consistently
Date: Wed, 30 Sep 2015 05:52:32 -0700
Message-ID: <1443617561-40490-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8321 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932352AbbI3Mwp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 08:52:45 -0400
In-Reply-To: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

In i40e_ndo_set_vf_port_vlan, we were using the QOS value
inconsistently, sometimes shifting it, sometimes not. Do the shift-and-
or operation correctly, once, and use the result consistently everywhere
in the function.

Change-ID: I46f062f3edc90a8a017ecec9137f4d1ab0ab9e41
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index eacce93..b148694 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2089,6 +2089,7 @@ error_param:
 int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 			      int vf_id, u16 vlan_id, u8 qos)
 {
+	u16 vlanprio = vlan_id | (qos << I40E_VLAN_PRIORITY_SHIFT);
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_pf *pf = np->vsi->back;
 	struct i40e_vsi *vsi;
@@ -2116,8 +2117,7 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 		goto error_pvid;
 	}
 
-	if (le16_to_cpu(vsi->info.pvid) ==
-	    (vlan_id | (qos << I40E_VLAN_PRIORITY_SHIFT)))
+	if (le16_to_cpu(vsi->info.pvid) == vlanprio)
 		/* duplicate request, so just return success */
 		goto error_pvid;
 
@@ -2141,7 +2141,7 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 	 * MAC addresses deleted.
 	 */
 	if ((!(vlan_id || qos) ||
-	    (vlan_id | qos) != le16_to_cpu(vsi->info.pvid)) &&
+	    vlanprio != le16_to_cpu(vsi->info.pvid)) &&
 	    vsi->info.pvid)
 		ret = i40e_vsi_add_vlan(vsi, I40E_VLAN_ANY);
 
@@ -2156,8 +2156,7 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 		}
 	}
 	if (vlan_id || qos)
-		ret = i40e_vsi_add_pvid(vsi,
-				vlan_id | (qos << I40E_VLAN_PRIORITY_SHIFT));
+		ret = i40e_vsi_add_pvid(vsi, vlanprio);
 	else
 		i40e_vsi_remove_pvid(vsi);
 
-- 
2.4.3
