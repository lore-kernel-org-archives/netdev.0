From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 05/19] i40e: remove code to handle dev_addr specially
Date: Wed,  7 Dec 2016 14:19:04 -0800
Message-ID: <20161207221918.57932-6-jeffrey.t.kirsher@intel.com>
References: <20161207221918.57932-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:28873 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933402AbcLGWUN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 17:20:13 -0500
In-Reply-To: <20161207221918.57932-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The netdev->dev_addr MAC filter already exists in the
MAC/VLAN hash table, as it is added when we configure
the netdev in i40e_configure_netdev. Because we already
know that this address will be updated in the
hash_for_each loops, we do not need to handle it
specially. This removes duplicate code and simplifies
the i40e_vsi_add_vlan and i40e_vsi_kill_vlan functions.
Because we know these filters must be part of the
MAC/VLAN hash table, this should not have any functional
impact on what filters are included and is merely a code
simplification.

Change-ID: I5e648302dbdd7cc29efc6d203b7019c11f0b5705
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 43 +++++------------------------
 1 file changed, 7 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c467cc4..ae4a2b2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2515,17 +2515,6 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 	/* Locked once because all functions invoked below iterates list*/
 	spin_lock_bh(&vsi->mac_filter_hash_lock);
 
-	if (vsi->netdev) {
-		add_f = i40e_add_filter(vsi, vsi->netdev->dev_addr, vid);
-		if (!add_f) {
-			dev_info(&vsi->back->pdev->dev,
-				 "Could not add vlan filter %d for %pM\n",
-				 vid, vsi->netdev->dev_addr);
-			spin_unlock_bh(&vsi->mac_filter_hash_lock);
-			return -ENOMEM;
-		}
-	}
-
 	hash_for_each_safe(vsi->mac_filter_hash, bkt, h, f, hlist) {
 		if (f->state == I40E_FILTER_REMOVE)
 			continue;
@@ -2539,28 +2528,14 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 		}
 	}
 
-	/* Now if we add a vlan tag, make sure to check if it is the first
-	 * tag (i.e. a "tag" -1 does exist) and if so replace the -1 "tag"
-	 * with 0, so we now accept untagged and specified tagged traffic
-	 * (and not all tags along with untagged)
+	/* When we add a new VLAN filter, we need to make sure that all existing
+	 * filters which are marked as vid=-1 (I40E_VLAN_ANY) are converted to
+	 * vid=0. The simplest way is just search for all filters marked as
+	 * vid=-1 and replace them with vid=0. This converts all filters that
+	 * were marked to receive all traffic (tagged or untagged) into
+	 * filters to receive only untagged traffic, so that we don't receive
+	 * tagged traffic for VLANs which we have not configured.
 	 */
-	if (vid > 0 && vsi->netdev) {
-		del_f = i40e_find_filter(vsi, vsi->netdev->dev_addr,
-					 I40E_VLAN_ANY);
-		if (del_f) {
-			__i40e_del_filter(vsi, del_f);
-			add_f = i40e_add_filter(vsi, vsi->netdev->dev_addr, 0);
-			if (!add_f) {
-				dev_info(&vsi->back->pdev->dev,
-					 "Could not add filter 0 for %pM\n",
-					 vsi->netdev->dev_addr);
-				spin_unlock_bh(&vsi->mac_filter_hash_lock);
-				return -ENOMEM;
-			}
-		}
-	}
-
-	/* Do not assume that I40E_VLAN_ANY should be reset to VLAN 0 */
 	if (vid > 0 && !vsi->info.pvid) {
 		hash_for_each_safe(vsi->mac_filter_hash, bkt, h, f, hlist) {
 			if (f->state == I40E_FILTER_REMOVE)
@@ -2597,7 +2572,6 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
  **/
 void i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 {
-	struct net_device *netdev = vsi->netdev;
 	struct i40e_mac_filter *f;
 	struct hlist_node *h;
 	int bkt;
@@ -2605,9 +2579,6 @@ void i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 	/* Locked once because all functions invoked below iterates list */
 	spin_lock_bh(&vsi->mac_filter_hash_lock);
 
-	if (vsi->netdev)
-		i40e_del_filter(vsi, netdev->dev_addr, vid);
-
 	hash_for_each_safe(vsi->mac_filter_hash, bkt, h, f, hlist) {
 		if (f->vlan == vid)
 			__i40e_del_filter(vsi, f);
-- 
2.9.3
