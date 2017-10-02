From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e: limit lan queue count in large CPU count machine
Date: Mon,  2 Oct 2017 12:48:38 -0700
Message-ID: <20171002194852.71970-2-jeffrey.t.kirsher@intel.com>
References: <20171002194852.71970-1-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@oracle.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:29126 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751062AbdJBTtR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 15:49:17 -0400
In-Reply-To: <20171002194852.71970-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@oracle.com>

When a machine has more CPUs than queue pairs, e.g. 512 cores, the
counting gets a little funky and turns off Flow Director with the
message:
  not enough queues for Flow Director. Flow Director feature is disabled

This patch limits the number of lan queues initially allocated to
be sure we have some left for FD and other features.

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 47f71d7c3ae0..387f0863f794 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -11093,6 +11093,7 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit)
 static void i40e_determine_queue_usage(struct i40e_pf *pf)
 {
 	int queues_left;
+	int q_max;
 
 	pf->num_lan_qps = 0;
 
@@ -11139,10 +11140,12 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
 					I40E_FLAG_DCB_ENABLED);
 			dev_info(&pf->pdev->dev, "not enough queues for DCB. DCB is disabled.\n");
 		}
-		pf->num_lan_qps = max_t(int, pf->rss_size_max,
-					num_online_cpus());
-		pf->num_lan_qps = min_t(int, pf->num_lan_qps,
-					pf->hw.func_caps.num_tx_qp);
+
+		/* limit lan qps to the smaller of qps, cpus or msix */
+		q_max = max_t(int, pf->rss_size_max, num_online_cpus());
+		q_max = min_t(int, q_max, pf->hw.func_caps.num_tx_qp);
+		q_max = min_t(int, q_max, pf->hw.func_caps.num_msix_vectors);
+		pf->num_lan_qps = q_max;
 
 		queues_left -= pf->num_lan_qps;
 	}
-- 
2.14.2
