From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH net-next] i40e: limit lan queue count in large cpu count machine
Date: Mon, 24 Jul 2017 18:17:42 -0700
Message-ID: <1500945462-33176-1-git-send-email-shannon.nelson@oracle.com>
Cc: intel-wired-lan@lists.osuosl.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:51706 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756883AbdGYBPL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 21:15:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a machine has more cpus than queuepairs, e.g. 512 cores, the
counting gets a little funky and turns off Flow Director with the
message:
  not enough queues for Flow Director. Flow Director feature is disabled

This patch limits the number of lan queues initially allocated to
be sure we have some left for FD and other features.

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2db93d3..a694e99 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -11059,6 +11059,7 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit)
 static void i40e_determine_queue_usage(struct i40e_pf *pf)
 {
 	int queues_left;
+	int q_max;
 
 	pf->num_lan_qps = 0;
 
@@ -11105,10 +11106,12 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
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
1.7.1
