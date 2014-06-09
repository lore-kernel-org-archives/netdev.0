From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/13] i40e: keep SR-IOV enabled in the case that RSS, VMDQ, FD_SB and DCB are disabled
Date: Mon,  9 Jun 2014 01:49:13 -0700
Message-ID: <1402303758-1429-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402303758-1429-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Frank Zhang <frank_1.zhang@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27489 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754626AbaFIIt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2014 04:49:27 -0400
In-Reply-To: <1402303758-1429-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Zhang <frank_1.zhang@intel.com>

Modify the logic in i40e_determine_queue_usage() so that
SR-IOV doesn't get turned off unnecessarily.

Change-ID: I86ca304fa9f742a50e9ea831b887f358a6a9d53d
Signed-off-by: Frank Zhang <frank_1.zhang@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index eb32c5c..b5f0dea 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8180,9 +8180,7 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
 	queues_left = pf->hw.func_caps.num_tx_qp;
 
 	if ((queues_left == 1) ||
-	    !(pf->flags & I40E_FLAG_MSIX_ENABLED) ||
-	    !(pf->flags & (I40E_FLAG_RSS_ENABLED | I40E_FLAG_FD_SB_ENABLED |
-			   I40E_FLAG_DCB_ENABLED))) {
+	    !(pf->flags & I40E_FLAG_MSIX_ENABLED)) {
 		/* one qp for PF, no queues for anything else */
 		queues_left = 0;
 		pf->rss_size = pf->num_lan_qps = 1;
@@ -8194,6 +8192,18 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
 			       I40E_FLAG_DCB_ENABLED	|
 			       I40E_FLAG_SRIOV_ENABLED	|
 			       I40E_FLAG_VMDQ_ENABLED);
+	} else if (!(pf->flags & (I40E_FLAG_RSS_ENABLED |
+				  I40E_FLAG_FD_SB_ENABLED |
+				  I40E_FLAG_DCB_ENABLED))) {
+		/* one qp for PF */
+		pf->rss_size = pf->num_lan_qps = 1;
+		queues_left -= pf->num_lan_qps;
+
+		pf->flags &= ~(I40E_FLAG_RSS_ENABLED	|
+			       I40E_FLAG_FD_SB_ENABLED	|
+			       I40E_FLAG_FD_ATR_ENABLED	|
+			       I40E_FLAG_DCB_ENABLED	|
+			       I40E_FLAG_VMDQ_ENABLED);
 	} else {
 		/* Not enough queues for all TCs */
 		if ((pf->flags & I40E_FLAG_DCB_ENABLED) &&
-- 
1.9.3
