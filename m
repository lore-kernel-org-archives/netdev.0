From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/4] i40e: enable VSI broadcast promiscuous mode instead of adding broadcast filter
Date: Fri, 15 Jul 2016 00:02:02 -0700
Message-ID: <1468566124-63101-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1468566124-63101-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kiran Patil <kiran.patil@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com, stable@kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:56902 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752622AbcGOHCs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2016 03:02:48 -0400
In-Reply-To: <1468566124-63101-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kiran Patil <kiran.patil@intel.com>

This patch sets VSI broadcast promiscuous mode during VSI add sequence
and prevents adding MAC filter if specified MAC address is broadcast.

Change-ID: Ia62251fca095bc449d0497fc44bec3a5a0136773
CC: stable@kernel.org
Signed-off-by: Kiran Patil <kiran.patil@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 32 ++++++++++++++++++-----------
 1 file changed, 20 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 5ea2200..1592dcb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1344,6 +1344,13 @@ struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
 	if (!vsi || !macaddr)
 		return NULL;
 
+	/* Do not allow broadcast filter to be added since broadcast filter
+	 * is added as part of add VSI for any newly created VSI except
+	 * FDIR VSI
+	 */
+	if (is_broadcast_ether_addr(macaddr))
+		return NULL;
+
 	f = i40e_find_filter(vsi, macaddr, vlan, is_vf, is_netdev);
 	if (!f) {
 		f = kzalloc(sizeof(*f), GFP_ATOMIC);
@@ -2151,18 +2158,6 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 					 aq_ret, pf->hw.aq.asq_last_status);
 			}
 		}
-		aq_ret = i40e_aq_set_vsi_broadcast(&vsi->back->hw,
-						   vsi->seid,
-						   cur_promisc, NULL);
-		if (aq_ret) {
-			retval = i40e_aq_rc_to_posix(aq_ret,
-						     pf->hw.aq.asq_last_status);
-			dev_info(&pf->pdev->dev,
-				 "set brdcast promisc failed, err %s, aq_err %s\n",
-				 i40e_stat_str(&pf->hw, aq_ret),
-				 i40e_aq_str(&pf->hw,
-					     pf->hw.aq.asq_last_status));
-		}
 	}
 out:
 	/* if something went wrong then set the changed flag so we try again */
@@ -9224,6 +9219,7 @@ int i40e_is_vsi_uplink_mode_veb(struct i40e_vsi *vsi)
 static int i40e_add_vsi(struct i40e_vsi *vsi)
 {
 	int ret = -ENODEV;
+	i40e_status aq_ret = 0;
 	u8 laa_macaddr[ETH_ALEN];
 	bool found_laa_mac_filter = false;
 	struct i40e_pf *pf = vsi->back;
@@ -9413,6 +9409,18 @@ static int i40e_add_vsi(struct i40e_vsi *vsi)
 		vsi->seid = ctxt.seid;
 		vsi->id = ctxt.vsi_number;
 	}
+	/* Except FDIR VSI, for all othet VSI set the broadcast filter */
+	if (vsi->type != I40E_VSI_FDIR) {
+		aq_ret = i40e_aq_set_vsi_broadcast(hw, vsi->seid, true, NULL);
+		if (aq_ret) {
+			ret = i40e_aq_rc_to_posix(aq_ret,
+						  hw->aq.asq_last_status);
+			dev_info(&pf->pdev->dev,
+				 "set brdcast promisc failed, err %s, aq_err %s\n",
+				 i40e_stat_str(hw, aq_ret),
+				 i40e_aq_str(hw, hw->aq.asq_last_status));
+		}
+	}
 
 	spin_lock_bh(&vsi->mac_filter_list_lock);
 	/* If macvlan filters already exist, force them to get loaded */
-- 
2.5.5
