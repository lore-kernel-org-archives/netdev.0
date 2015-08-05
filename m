From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH 2/3] be2net: post buffers before destroying RXQs in Lancer
Date: Wed,  5 Aug 2015 03:27:49 -0400
Message-ID: <1438759670-2134-3-git-send-email-sathya.perla@avagotech.com>
References: <1438759670-2134-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:56694 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751902AbbHEHVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 03:21:33 -0400
In-Reply-To: <1438759670-2134-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@avagotech.com>

An RX stall issue was seen on Lancer adapters, when RXQs are destroyed
while they are in an "out of buffer" state. This patch fixes this issue
by posting 64 buffers to each RXQ before destroying them in the close path.
This is done after ensuring that no more new packets are selected for
transfer to the RXQs by disabling interface filters.

Signed-off-by: Kalesh AP <kalesh.purayil@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 42 ++++++++++++++++++++---------
 1 file changed, 30 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 7730f21..14ae67a 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2451,10 +2451,24 @@ static void be_eq_clean(struct be_eq_obj *eqo)
 	be_eq_notify(eqo->adapter, eqo->q.id, false, true, num, 0);
 }
 
+/* Free posted rx buffers that were not used */
+static void be_rxq_clean(struct be_rx_obj *rxo)
+{
+	struct be_queue_info *rxq = &rxo->q;
+	struct be_rx_page_info *page_info;
+
+	while (atomic_read(&rxq->used) > 0) {
+		page_info = get_rx_page_info(rxo);
+		put_page(page_info->page);
+		memset(page_info, 0, sizeof(*page_info));
+	}
+	BUG_ON(atomic_read(&rxq->used));
+	rxq->tail = 0;
+	rxq->head = 0;
+}
+
 static void be_rx_cq_clean(struct be_rx_obj *rxo)
 {
-	struct be_rx_page_info *page_info;
-	struct be_queue_info *rxq = &rxo->q;
 	struct be_queue_info *rx_cq = &rxo->cq;
 	struct be_rx_compl_info *rxcp;
 	struct be_adapter *adapter = rxo->adapter;
@@ -2491,16 +2505,6 @@ static void be_rx_cq_clean(struct be_rx_obj *rxo)
 
 	/* After cleanup, leave the CQ in unarmed state */
 	be_cq_notify(adapter, rx_cq->id, false, 0);
-
-	/* Then free posted rx buffers that were not used */
-	while (atomic_read(&rxq->used) > 0) {
-		page_info = get_rx_page_info(rxo);
-		put_page(page_info->page);
-		memset(page_info, 0, sizeof(*page_info));
-	}
-	BUG_ON(atomic_read(&rxq->used));
-	rxq->tail = 0;
-	rxq->head = 0;
 }
 
 static void be_tx_compl_clean(struct be_adapter *adapter)
@@ -3358,8 +3362,22 @@ static void be_rx_qs_destroy(struct be_adapter *adapter)
 	for_all_rx_queues(adapter, rxo, i) {
 		q = &rxo->q;
 		if (q->created) {
+			/* If RXQs are destroyed while in an "out of buffer"
+			 * state, there is a possibility of an HW stall on
+			 * Lancer. So, post 64 buffers to each queue to relieve
+			 * the "out of buffer" condition.
+			 * Make sure there's space in the RXQ before posting.
+			 */
+			if (lancer_chip(adapter)) {
+				be_rx_cq_clean(rxo);
+				if (atomic_read(&q->used) == 0)
+					be_post_rx_frags(rxo, GFP_KERNEL,
+							 MAX_RX_POST);
+			}
+
 			be_cmd_rxq_destroy(adapter, q);
 			be_rx_cq_clean(rxo);
+			be_rxq_clean(rxo);
 		}
 		be_queue_free(adapter, q);
 	}
-- 
2.4.1
