From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: fix tx completions in napi poll
Date: Wed, 22 Mar 2017 11:54:50 -0700
Message-ID: <20170322185449.GA1072@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0088.outbound.protection.outlook.com ([104.47.34.88]:55347
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751109AbdCVSy4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 22 Mar 2017 14:54:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: VSR Burru <veerasenareddy.burru@cavium.com>

If there are no egress packets pending, then don't look for tx completions
in napi poll.  Also, fix broken tx queue wakeup logic.

Signed-off-by: VSR Burru <veerasenareddy.burru@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 20 +++++++++++---------
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 19 +++++++++++--------
 2 files changed, 22 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index be9c0e3..9124e63 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -959,14 +959,13 @@ static void update_txq_status(struct octeon_device *oct, int iq_num)
 			INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, iq_num,
 						  tx_restart, 1);
 			netif_wake_subqueue(netdev, iq->q_index);
-		} else {
-			if (!octnet_iq_is_full(oct, lio->txq)) {
-				INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev,
-							  lio->txq,
-							  tx_restart, 1);
-				wake_q(netdev, lio->txq);
-			}
 		}
+	} else if (netif_queue_stopped(netdev) &&
+		   lio->linfo.link.s.link_up &&
+		   (!octnet_iq_is_full(oct, lio->txq))) {
+		INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev,
+					  lio->txq, tx_restart, 1);
+		netif_wake_queue(netdev);
 	}
 }
 
@@ -2435,8 +2434,11 @@ static int liquidio_napi_poll(struct napi_struct *napi, int budget)
 	/* Flush the instruction queue */
 	iq = oct->instr_queue[iq_no];
 	if (iq) {
-		/* Process iq buffers with in the budget limits */
-		tx_done = octeon_flush_iq(oct, iq, budget);
+		if (atomic_read(&iq->instr_pending))
+			/* Process iq buffers with in the budget limits */
+			tx_done = octeon_flush_iq(oct, iq, budget);
+		else
+			tx_done = 1;
 		/* Update iq read-index rather than waiting for next interrupt.
 		 * Return back if tx_done is false.
 		 */
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 9d5e035..585ea70 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -692,13 +692,12 @@ static void update_txq_status(struct octeon_device *oct, int iq_num)
 			netif_wake_subqueue(netdev, iq->q_index);
 			INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, iq_num,
 						  tx_restart, 1);
-		} else {
-			if (!octnet_iq_is_full(oct, lio->txq)) {
-				INCR_INSTRQUEUE_PKT_COUNT(
-				    lio->oct_dev, lio->txq, tx_restart, 1);
-				wake_q(netdev, lio->txq);
-			}
 		}
+	} else if (netif_queue_stopped(netdev) && lio->linfo.link.s.link_up &&
+		   (!octnet_iq_is_full(oct, lio->txq))) {
+		INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev,
+					  lio->txq, tx_restart, 1);
+		netif_wake_queue(netdev);
 	}
 }
 
@@ -1620,8 +1619,12 @@ static int liquidio_napi_poll(struct napi_struct *napi, int budget)
 	/* Flush the instruction queue */
 	iq = oct->instr_queue[iq_no];
 	if (iq) {
-		/* Process iq buffers with in the budget limits */
-		tx_done = octeon_flush_iq(oct, iq, budget);
+		if (atomic_read(&iq->instr_pending))
+			/* Process iq buffers with in the budget limits */
+			tx_done = octeon_flush_iq(oct, iq, budget);
+		else
+			tx_done = 1;
+
 		/* Update iq read-index rather than waiting for next interrupt.
 		 * Return back if tx_done is false.
 		 */
