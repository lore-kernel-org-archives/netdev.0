From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/11] i40e: fix configuration of RSS table with DCB
Date: Sat, 25 Mar 2017 01:12:56 -0700
Message-ID: <20170325081305.31835-3-jeffrey.t.kirsher@intel.com>
References: <20170325081305.31835-1-jeffrey.t.kirsher@intel.com>
Cc: Harshitha Ramamurthy <harshitha.ramamurthy@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:23525 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750908AbdCYINJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 25 Mar 2017 04:13:09 -0400
In-Reply-To: <20170325081305.31835-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harshitha Ramamurthy <harshitha.ramamurthy@intel.com>

There exists a bug in the driver where the calculation of the
RSS size was not taking into account the number of traffic classes
enabled. This patch factors in the traffic classes both in
the initial configuration of the table as well as reconfiguration.

Change-ID: I34dcd345ce52faf1d6b9614bea28d450cfd5f621
Signed-off-by: Harshitha Ramamurthy <harshitha.ramamurthy@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 1d8febd721ac..5da990909a88 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8577,9 +8577,12 @@ static int i40e_pf_config_rss(struct i40e_pf *pf)
 	i40e_write_rx_ctl(hw, I40E_PFQF_CTL_0, reg_val);
 
 	/* Determine the RSS size of the VSI */
-	if (!vsi->rss_size)
-		vsi->rss_size = min_t(int, pf->alloc_rss_size,
-				      vsi->num_queue_pairs);
+	if (!vsi->rss_size) {
+		u16 qcount;
+
+		qcount = vsi->num_queue_pairs / vsi->tc_config.numtc;
+		vsi->rss_size = min_t(int, pf->alloc_rss_size, qcount);
+	}
 	if (!vsi->rss_size)
 		return -EINVAL;
 
@@ -8625,6 +8628,8 @@ int i40e_reconfig_rss_queues(struct i40e_pf *pf, int queue_count)
 	new_rss_size = min_t(int, queue_count, pf->rss_size_max);
 
 	if (queue_count != vsi->num_queue_pairs) {
+		u16 qcount;
+
 		vsi->req_queue_pairs = queue_count;
 		i40e_prep_for_reset(pf);
 
@@ -8642,8 +8647,8 @@ int i40e_reconfig_rss_queues(struct i40e_pf *pf, int queue_count)
 		}
 
 		/* Reset vsi->rss_size, as number of enabled queues changed */
-		vsi->rss_size = min_t(int, pf->alloc_rss_size,
-				      vsi->num_queue_pairs);
+		qcount = vsi->num_queue_pairs / vsi->tc_config.numtc;
+		vsi->rss_size = min_t(int, pf->alloc_rss_size, qcount);
 
 		i40e_pf_config_rss(pf);
 	}
-- 
2.12.0
