From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40e: Report cmd->data in ETHTOOL_GRXCLSRLCNT instead of ETHTOOL_GRXCLSRULE
Date: Thu, 29 May 2014 08:10:08 -0700
Message-ID: <1401376216-12531-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42446 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932848AbaE2PKh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 11:10:37 -0400
In-Reply-To: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Based on review feedback from upstream cmd->data is not
defined in ETHTOOL_GRXCLSRULE but needs to be reported in
ETHTOOL_GRXCLSRLCNT. Also use a helper function to calculate the total
filter count.

Change-ID: Iaacbf729527b73290c4fdad837b379b44fd7dd20
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         | 9 +++++++++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 9 +++------
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index ef5bb11..581898f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -534,6 +534,15 @@ static inline bool i40e_rx_is_programming_status(u64 qw)
 		(qw >> I40E_RX_PROG_STATUS_DESC_LENGTH_SHIFT);
 }
 
+/**
+ * i40e_get_fd_cnt_all - get the total FD filter space available
+ * @pf: pointer to the pf struct
+ **/
+static inline int i40e_get_fd_cnt_all(struct i40e_pf *pf)
+{
+	return pf->hw.fdir_shared_filter_count + pf->fdir_pf_filter_count;
+}
+
 /* needed by i40e_ethtool.c */
 int i40e_up(struct i40e_vsi *vsi);
 void i40e_down(struct i40e_vsi *vsi);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 8a6fef2..354181d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1131,8 +1131,7 @@ static int i40e_get_ethtool_fdir_all(struct i40e_pf *pf,
 	int cnt = 0;
 
 	/* report total rule count */
-	cmd->data = pf->hw.fdir_shared_filter_count +
-		    pf->fdir_pf_filter_count;
+	cmd->data = i40e_get_fd_cnt_all(pf);
 
 	hlist_for_each_entry_safe(rule, node2,
 				  &pf->fdir_filter_list, fdir_node) {
@@ -1166,10 +1165,6 @@ static int i40e_get_ethtool_fdir_entry(struct i40e_pf *pf,
 	struct i40e_fdir_filter *rule = NULL;
 	struct hlist_node *node2;
 
-	/* report total rule count */
-	cmd->data = pf->hw.fdir_shared_filter_count +
-		    pf->fdir_pf_filter_count;
-
 	hlist_for_each_entry_safe(rule, node2,
 				  &pf->fdir_filter_list, fdir_node) {
 		if (fsp->location <= rule->fd_id)
@@ -1220,6 +1215,8 @@ static int i40e_get_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *cmd,
 		break;
 	case ETHTOOL_GRXCLSRLCNT:
 		cmd->rule_cnt = pf->fdir_pf_active_filters;
+		/* report total rule count */
+		cmd->data = i40e_get_fd_cnt_all(pf);
 		ret = 0;
 		break;
 	case ETHTOOL_GRXCLSRULE:
-- 
1.9.3
