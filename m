From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/13] i40e: always remove old filter when adding new FDir filter
Date: Mon, 20 Mar 2017 16:47:12 -0700
Message-ID: <20170320234712.84157-14-jeffrey.t.kirsher@intel.com>
References: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:33079 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932166AbdCTXrX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 19:47:23 -0400
In-Reply-To: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The previous code relied on i40e_match_fdir_input_set to determine when
determining whether to free the old filter. Change this code so that we
simply unconditionally delete the old filter, even if it's identical to
the new filter. This ensures that we don't leak any memory, and that we
always update the filters as expected.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 32 ++++++--------------------
 1 file changed, 7 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 905d66e87247..1c3805b4fcf3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2621,24 +2621,6 @@ static int i40e_set_rss_hash_opt(struct i40e_pf *pf, struct ethtool_rxnfc *nfc)
 }
 
 /**
- * i40e_match_fdir_input_set - Match a new filter against an existing one
- * @rule: The filter already added
- * @input: The new filter to comapre against
- *
- * Returns true if the two input set match
- **/
-static bool i40e_match_fdir_input_set(struct i40e_fdir_filter *rule,
-				      struct i40e_fdir_filter *input)
-{
-	if ((rule->dst_ip != input->dst_ip) ||
-	    (rule->src_ip != input->src_ip) ||
-	    (rule->dst_port != input->dst_port) ||
-	    (rule->src_port != input->src_port))
-		return false;
-	return true;
-}
-
-/**
  * i40e_update_ethtool_fdir_entry - Updates the fdir filter entry
  * @vsi: Pointer to the targeted VSI
  * @input: The filter to update or NULL to indicate deletion
@@ -2673,22 +2655,22 @@ static int i40e_update_ethtool_fdir_entry(struct i40e_vsi *vsi,
 
 	/* if there is an old rule occupying our place remove it */
 	if (rule && (rule->fd_id == sw_idx)) {
-		if (input && !i40e_match_fdir_input_set(rule, input))
-			err = i40e_add_del_fdir(vsi, rule, false);
-		else if (!input)
-			err = i40e_add_del_fdir(vsi, rule, false);
+		/* Remove this rule, since we're either deleting it, or
+		 * replacing it.
+		 */
+		err = i40e_add_del_fdir(vsi, rule, false);
 		hlist_del(&rule->fdir_node);
 		kfree(rule);
 		pf->fdir_pf_active_filters--;
 	}
 
-	/* If no input this was a delete, err should be 0 if a rule was
-	 * successfully found and removed from the list else -EINVAL
+	/* If we weren't given an input, this is a delete, so just return the
+	 * error code indicating if there was an entry at the requested slot
 	 */
 	if (!input)
 		return err;
 
-	/* initialize node and set software index */
+	/* Otherwise, install the new rule as requested */
 	INIT_HLIST_NODE(&input->fdir_node);
 
 	/* add filter to the list */
-- 
2.12.0
