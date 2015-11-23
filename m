From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] fm10k: Fix handling of NAPI budget when multiple queues are enabled per vector
Date: Mon, 23 Nov 2015 11:36:07 -0800
Message-ID: <1448307376-20063-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:41412 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752635AbbKWTgV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 14:36:21 -0500
In-Reply-To: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This patch corrects an issue in which the polling routine would increase
the budget for Rx to at least 1 per queue if multiple queues were present.
This would result in Rx packets being processed when the budget was 0 which
is meant to indicate that no Rx can be handled.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index e76a44c..746a198 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1428,6 +1428,10 @@ static int fm10k_poll(struct napi_struct *napi, int budget)
 	fm10k_for_each_ring(ring, q_vector->tx)
 		clean_complete &= fm10k_clean_tx_irq(q_vector, ring);
 
+	/* Handle case where we are called by netpoll with a budget of 0 */
+	if (budget <= 0)
+		return budget;
+
 	/* attempt to distribute budget to each queue fairly, but don't
 	 * allow the budget to go below 1 because we'll exit polling
 	 */
-- 
2.5.0
