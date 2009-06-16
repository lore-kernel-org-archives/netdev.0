From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-next-2.6] ixgbe: fix multi-ring polling
Date: Tue, 16 Jun 2009 16:53:38 -0400
Message-ID: <20090616205338.GB8515@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peter.p.waskiewicz.jr@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34831 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753081AbZFPUxh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2009 16:53:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When looking at ixgbe_clean_rxtx_many I noticed two small problems.

 - work_done needs to be cleared before calling ixgbe_clean_rx_irq since
   it will exit without cleaning any buffers when work_done is greater
   than budget (which could happen pretty often after the first ring is
   cleaned).  A total count will ensure we still return the correct
   number of frames processed.
 - napi_complete should only be called if all rings associated with this
   napi instance were cleaned completely.  It seems wise to stay on the
   poll-list if not completely cleaned.

This has been compile tested only.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 ixgbe_main.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a551a96..c009642 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1362,9 +1362,9 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 	                       container_of(napi, struct ixgbe_q_vector, napi);
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	struct ixgbe_ring *ring = NULL;
-	int work_done = 0, i;
+	int work_done = 0, total_work = 0, i;
 	long r_idx;
-	bool tx_clean_complete = true;
+	bool rx_clean_complete = true, tx_clean_complete = true;
 
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
 	for (i = 0; i < q_vector->txr_count; i++) {
@@ -1384,12 +1384,15 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 	budget = max(budget, 1);
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	for (i = 0; i < q_vector->rxr_count; i++) {
+		work_done = 0;
 		ring = &(adapter->rx_ring[r_idx]);
 #ifdef CONFIG_IXGBE_DCA
 		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
 			ixgbe_update_rx_dca(adapter, ring);
 #endif
 		ixgbe_clean_rx_irq(q_vector, ring, &work_done, budget);
+		total_work += work_done;
+		rx_clean_complete &= (work_done < budget);
 		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
 		                      r_idx + 1);
 	}
@@ -1397,7 +1400,7 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	ring = &(adapter->rx_ring[r_idx]);
 	/* If all Rx work done, exit the polling mode */
-	if (work_done < budget) {
+	if (rx_clean_complete && tx_clean_complete) {
 		napi_complete(napi);
 		if (adapter->itr_setting & 1)
 			ixgbe_set_itr_msix(q_vector);
@@ -1407,7 +1410,7 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 		return 0;
 	}
 
-	return work_done;
+	return total_work;
 }
 
 /**
