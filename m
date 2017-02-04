From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 05/14] i40e: avoid O(n^2) loop when deleting all filters
Date: Fri,  3 Feb 2017 18:56:36 -0800
Message-ID: <20170204025645.174793-6-jeffrey.t.kirsher@intel.com>
References: <20170204025645.174793-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24543 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753332AbdBDC4t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 21:56:49 -0500
In-Reply-To: <20170204025645.174793-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Use __i40e_del_filter instead of using i40e_del_filter() which will
avoid doing an additional search to delete a filter we already have the
pointer for.

Change-ID: Iea5a7e3cafbf8c682ed9d3b6c69cf5ff53f44daf
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             | 1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 4a64884..8bb0f4b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -762,6 +762,7 @@ bool i40e_set_ntuple(struct i40e_pf *pf, netdev_features_t features);
 void i40e_set_ethtool_ops(struct net_device *netdev);
 struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
 					const u8 *macaddr, s16 vlan);
+void __i40e_del_filter(struct i40e_vsi *vsi, struct i40e_mac_filter *f);
 void i40e_del_filter(struct i40e_vsi *vsi, const u8 *macaddr, s16 vlan);
 int i40e_sync_vsi_filters(struct i40e_vsi *vsi);
 struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index da9f8d3..cabd728 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1434,7 +1434,7 @@ struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
  * the "safe" variants of any list iterators, e.g. list_for_each_entry_safe()
  * instead of list_for_each_entry().
  **/
-static void __i40e_del_filter(struct i40e_vsi *vsi, struct i40e_mac_filter *f)
+void __i40e_del_filter(struct i40e_vsi *vsi, struct i40e_mac_filter *f)
 {
 	if (!f)
 		return;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 1859911..49941dd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2725,7 +2725,7 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 	 * anyway.
 	 */
 	hash_for_each(vsi->mac_filter_hash, bkt, f, hlist)
-		i40e_del_filter(vsi, f->macaddr, f->vlan);
+		__i40e_del_filter(vsi, f);
 
 	spin_unlock_bh(&vsi->mac_filter_hash_lock);
 
-- 
2.10.2
