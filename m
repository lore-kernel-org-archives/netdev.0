From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] i40e: use the safe hash table iterator when deleting mac filters
Date: Mon,  9 Oct 2017 15:38:29 -0700
Message-ID: <20171009223841.2557-3-jeffrey.t.kirsher@intel.com>
References: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Cc: Lihong Yang <lihong.yang@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:36096 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754302AbdJIWjF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 18:39:05 -0400
In-Reply-To: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lihong Yang <lihong.yang@intel.com>

This patch replaces hash_for_each function with hash_for_each_safe
when calling  __i40e_del_filter. The hash_for_each_safe function is
the right one to use when iterating over a hash table to safely remove
a hash entry. Otherwise, incorrect values may be read from freed memory.

Detected by CoverityScan, CID 1402048 Read from pointer after free

Signed-off-by: Lihong Yang <lihong.yang@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 04568137e029..c062d74d21f3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2883,6 +2883,7 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 	struct i40e_mac_filter *f;
 	struct i40e_vf *vf;
 	int ret = 0;
+	struct hlist_node *h;
 	int bkt;
 
 	/* validate the request */
@@ -2921,7 +2922,7 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 	/* Delete all the filters for this VSI - we're going to kill it
 	 * anyway.
 	 */
-	hash_for_each(vsi->mac_filter_hash, bkt, f, hlist)
+	hash_for_each_safe(vsi->mac_filter_hash, bkt, h, f, hlist)
 		__i40e_del_filter(vsi, f);
 
 	spin_unlock_bh(&vsi->mac_filter_hash_lock);
-- 
2.14.2
