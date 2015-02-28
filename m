From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/18] i40e: Enable more than 64 qps for the Main VSI
Date: Sat, 28 Feb 2015 03:29:39 -0800
Message-ID: <1425122989-354-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Shannon Nelson <shannon.nelson@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50492 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751340AbbB1L36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Feb 2015 06:29:58 -0500
In-Reply-To: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

When running in a single TC mode the HW can be configured to enable more
than max RSS qps for the Main VSI. This  patch makes it possible to
enable as many as num_online_cpus().

ethtool -L can still be used to reconfigure number of qps
to a smaller value.

Change-ID: I3e2df085276982603d86dfd79477c0ada8d30b8f
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  1 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |  4 ----
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 25 ++++++++++++++++++++-----
 3 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 5fa4eab..e4e963a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -488,6 +488,7 @@ struct i40e_vsi {
 
 	u16 base_queue;      /* vsi's first queue in hw array */
 	u16 alloc_queue_pairs; /* Allocated Tx/Rx queues */
+	u16 req_queue_pairs; /* User requested queue pairs */
 	u16 num_queue_pairs; /* Used tx and rx pairs */
 	u16 num_desc;
 	enum i40e_vsi_type type;  /* VSI type, e.g., LAN, FCoE, etc */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 8a9d6a2..7413b0e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2348,10 +2348,6 @@ static int i40e_set_channels(struct net_device *dev,
 	/* update feature limits from largest to smallest supported values */
 	/* TODO: Flow director limit, DCB etc */
 
-	/* cap RSS limit */
-	if (count > pf->rss_size_max)
-		count = pf->rss_size_max;
-
 	/* use rss_reconfig to rebuild with new queue count and update traffic
 	 * class queue mapping
 	 */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2757926..849fec7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1566,6 +1566,12 @@ static void i40e_vsi_setup_queue_map(struct i40e_vsi *vsi,
 
 	/* Set actual Tx/Rx queue pairs */
 	vsi->num_queue_pairs = offset;
+	if ((vsi->type == I40E_VSI_MAIN) && (numtc == 1)) {
+		if (vsi->req_queue_pairs > 0)
+			vsi->num_queue_pairs = vsi->req_queue_pairs;
+		else
+			vsi->num_queue_pairs = pf->num_lan_msix;
+	}
 
 	/* Scheduler section valid can only be set for ADD VSI */
 	if (is_add) {
@@ -6921,7 +6927,8 @@ static int i40e_init_msix(struct i40e_pf *pf)
 	 * If we can't get what we want, we'll simplify to nearly nothing
 	 * and try again.  If that still fails, we punt.
 	 */
-	pf->num_lan_msix = pf->num_lan_qps - (pf->rss_size_max - pf->rss_size);
+	pf->num_lan_msix = min_t(int, num_online_cpus(),
+				 hw->func_caps.num_msix_vectors);
 	pf->num_vmdq_msix = pf->num_vmdq_qps;
 	other_vecs = 1;
 	other_vecs += (pf->num_vmdq_vsis * pf->num_vmdq_msix);
@@ -7251,15 +7258,19 @@ static int i40e_config_rss(struct i40e_pf *pf)
  **/
 int i40e_reconfig_rss_queues(struct i40e_pf *pf, int queue_count)
 {
+	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
+	int new_rss_size;
+
 	if (!(pf->flags & I40E_FLAG_RSS_ENABLED))
 		return 0;
 
-	queue_count = min_t(int, queue_count, pf->rss_size_max);
+	new_rss_size = min_t(int, queue_count, pf->rss_size_max);
 
-	if (queue_count != pf->rss_size) {
+	if (queue_count != vsi->num_queue_pairs) {
+		vsi->req_queue_pairs = queue_count;
 		i40e_prep_for_reset(pf);
 
-		pf->rss_size = queue_count;
+		pf->rss_size = new_rss_size;
 
 		i40e_reset_and_rebuild(pf, true);
 		i40e_config_rss(pf);
@@ -9258,7 +9269,11 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
 			pf->flags &= ~I40E_FLAG_DCB_CAPABLE;
 			dev_info(&pf->pdev->dev, "not enough queues for DCB. DCB is disabled.\n");
 		}
-		pf->num_lan_qps = pf->rss_size_max;
+		pf->num_lan_qps = max_t(int, pf->rss_size_max,
+					num_online_cpus());
+		pf->num_lan_qps = min_t(int, pf->num_lan_qps,
+					pf->hw.func_caps.num_tx_qp);
+
 		queues_left -= pf->num_lan_qps;
 	}
 
-- 
1.9.3
