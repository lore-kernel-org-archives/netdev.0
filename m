From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/14] i40e: Fix a bug in the update logic for FDIR SB filter.
Date: Fri, 14 Mar 2014 16:34:24 -0700
Message-ID: <1394840075-6851-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394840075-6851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:35472 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754791AbaCNXfH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 19:35:07 -0400
In-Reply-To: <1394840075-6851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

The update filter logic was causing a kernel panic in the original code.
We need to compare the input set to decide whether or not to delete a
filter since we do not have a hash stored. This new design helps fix the issue.

Change-ID: I2462b108e58ca4833312804cda730b4660cc18c9
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 27 +++++++++++++++++++++-----
 1 file changed, 22 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index d34ff31..718a3e0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1357,6 +1357,24 @@ static int i40e_set_rss_hash_opt(struct i40e_pf *pf, struct ethtool_rxnfc *nfc)
 }
 
 /**
+ * i40e_match_fdir_input_set - Match a new filter against an existing one
+ * @rule: The filter already added
+ * @input: The new filter to comapre against
+ *
+ * Returns true if the two input set match
+ **/
+static bool i40e_match_fdir_input_set(struct i40e_fdir_filter *rule,
+				      struct i40e_fdir_filter *input)
+{
+	if ((rule->dst_ip[0] != input->dst_ip[0]) ||
+	    (rule->src_ip[0] != input->src_ip[0]) ||
+	    (rule->dst_port != input->dst_port) ||
+	    (rule->src_port != input->src_port))
+		return false;
+	return true;
+}
+
+/**
  * i40e_update_ethtool_fdir_entry - Updates the fdir filter entry
  * @vsi: Pointer to the targeted VSI
  * @input: The filter to update or NULL to indicate deletion
@@ -1391,11 +1409,10 @@ static int i40e_update_ethtool_fdir_entry(struct i40e_vsi *vsi,
 
 	/* if there is an old rule occupying our place remove it */
 	if (rule && (rule->fd_id == sw_idx)) {
-		if (!input || (rule->fd_id != input->fd_id)) {
-			cmd->fs.flow_type = rule->flow_type;
-			err = i40e_add_del_fdir_ethtool(vsi, cmd, false);
-		}
-
+		if (input && !i40e_match_fdir_input_set(rule, input))
+			err = i40e_add_del_fdir(vsi, rule, false);
+		else if (!input)
+			err = i40e_add_del_fdir(vsi, rule, false);
 		hlist_del(&rule->fdir_node);
 		kfree(rule);
 		pf->fdir_pf_active_filters--;
-- 
1.8.3.1
