From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: simplify octeon_flush_iq()
Date: Fri, 6 Jan 2017 17:16:12 -0800
Message-ID: <20170107011612.GA16333@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <raghu.vatsavayi@cavium.com>,
        <derek.chickles@cavium.com>, <satananda.burla@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0054.outbound.protection.outlook.com ([104.47.40.54]:22848
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933632AbdAGBRN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 20:17:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Derek Chickles <derek.chickles@cavium.com>

Because every call to octeon_flush_iq() has a hardcoded 1 for the
pending_thresh argument, simplify that function by removing that argument.
This avoids one atomic read as well.

Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  2 +-
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c |  2 +-
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   |  2 +-
 .../net/ethernet/cavium/liquidio/request_manager.c | 49 +++++++++++-----------
 4 files changed, 27 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 6443bc1..13f67a3 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2441,7 +2441,7 @@ static int liquidio_napi_poll(struct napi_struct *napi, int budget)
 	iq = oct->instr_queue[iq_no];
 	if (iq) {
 		/* Process iq buffers with in the budget limits */
-		tx_done = octeon_flush_iq(oct, iq, 1, budget);
+		tx_done = octeon_flush_iq(oct, iq, budget);
 		/* Update iq read-index rather than waiting for next interrupt.
 		 * Return back if tx_done is false.
 		 */
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 70d96c1..55846f2 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -1627,7 +1627,7 @@ static int liquidio_napi_poll(struct napi_struct *napi, int budget)
 	iq = oct->instr_queue[iq_no];
 	if (iq) {
 		/* Process iq buffers with in the budget limits */
-		tx_done = octeon_flush_iq(oct, iq, 1, budget);
+		tx_done = octeon_flush_iq(oct, iq, budget);
 		/* Update iq read-index rather than waiting for next interrupt.
 		 * Return back if tx_done is false.
 		 */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
index e04ca8f..4608a5a 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
@@ -369,5 +369,5 @@ int octeon_setup_iq(struct octeon_device *oct, int ifidx,
 		    void *app_ctx);
 int
 octeon_flush_iq(struct octeon_device *oct, struct octeon_instr_queue *iq,
-		u32 pending_thresh, u32 napi_budget);
+		u32 napi_budget);
 #endif				/* __OCTEON_IQ_H__ */
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 3ce6675..707bc15 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -455,7 +455,7 @@ lio_process_iq_request_list(struct octeon_device *oct,
 /* Can only be called from process context */
 int
 octeon_flush_iq(struct octeon_device *oct, struct octeon_instr_queue *iq,
-		u32 pending_thresh, u32 napi_budget)
+		u32 napi_budget)
 {
 	u32 inst_processed = 0;
 	u32 tot_inst_processed = 0;
@@ -468,33 +468,32 @@ octeon_flush_iq(struct octeon_device *oct, struct octeon_instr_queue *iq,
 
 	iq->octeon_read_index = oct->fn_list.update_iq_read_idx(iq);
 
-	if (atomic_read(&iq->instr_pending) >= (s32)pending_thresh) {
-		do {
-			/* Process any outstanding IQ packets. */
-			if (iq->flush_index == iq->octeon_read_index)
-				break;
-
-			if (napi_budget)
-				inst_processed = lio_process_iq_request_list
-					(oct, iq,
-					 napi_budget - tot_inst_processed);
-			else
-				inst_processed =
-					lio_process_iq_request_list(oct, iq, 0);
+	do {
+		/* Process any outstanding IQ packets. */
+		if (iq->flush_index == iq->octeon_read_index)
+			break;
 
-			if (inst_processed) {
-				atomic_sub(inst_processed, &iq->instr_pending);
-				iq->stats.instr_processed += inst_processed;
-			}
+		if (napi_budget)
+			inst_processed =
+				lio_process_iq_request_list(oct, iq,
+							    napi_budget -
+							    tot_inst_processed);
+		else
+			inst_processed =
+				lio_process_iq_request_list(oct, iq, 0);
+
+		if (inst_processed) {
+			atomic_sub(inst_processed, &iq->instr_pending);
+			iq->stats.instr_processed += inst_processed;
+		}
 
-			tot_inst_processed += inst_processed;
-			inst_processed = 0;
+		tot_inst_processed += inst_processed;
+		inst_processed = 0;
 
-		} while (tot_inst_processed < napi_budget);
+	} while (tot_inst_processed < napi_budget);
 
-		if (napi_budget && (tot_inst_processed >= napi_budget))
-			tx_done = 0;
-	}
+	if (napi_budget && (tot_inst_processed >= napi_budget))
+		tx_done = 0;
 
 	iq->last_db_time = jiffies;
 
@@ -530,7 +529,7 @@ static void __check_db_timeout(struct octeon_device *oct, u64 iq_no)
 	iq->last_db_time = jiffies;
 
 	/* Flush the instruction queue */
-	octeon_flush_iq(oct, iq, 1, 0);
+	octeon_flush_iq(oct, iq, 0);
 
 	lio_enable_irq(NULL, iq);
 }
