From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 2/2] be2net: fix wrong frag_idx reported by RX CQ
Date: Tue, 18 Dec 2012 11:08:51 +0530
Message-ID: <42b4ddf1-1024-4762-b86c-66c033afc219@CMEXHTCAS2.ad.emulex.com>
References: <1355809131-8924-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:29992 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753741Ab2LRFgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 00:36:20 -0500
In-Reply-To: <1355809131-8924-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RX CQ can report completions with invalid frag_idx when the RXQ that
was *previously* using it, was not cleaned up properly. This hits
a BUG_ON() in be2net.

When completion coalescing is enabled on a CQ, an explicit CQ-notify
(with rearm) is needed for each compl, to flush partially coalesced CQ
entries that are pending DMA.

In be_close(), this fix now notifies CQ for each compl, waits explicitly
for the flush compl to arrive and complains if it doesn't arrive.

Also renaming be_crit_error() to be_hw_error() as it's the more
appropriate name and to convey that we don't wait for the flush compl
only when a HW error has occurred.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c |   38 ++++++++++++++++++++++----
 2 files changed, 33 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index abf26c7..3bc1912 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -616,7 +616,7 @@ static inline bool be_error(struct be_adapter *adapter)
 	return adapter->eeh_error || adapter->hw_error || adapter->fw_timeout;
 }
 
-static inline bool be_crit_error(struct be_adapter *adapter)
+static inline bool be_hw_error(struct be_adapter *adapter)
 {
 	return adapter->eeh_error || adapter->hw_error;
 }
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index bf50e73..9dca22b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1689,15 +1689,41 @@ static void be_rx_cq_clean(struct be_rx_obj *rxo)
 	struct be_queue_info *rxq = &rxo->q;
 	struct be_queue_info *rx_cq = &rxo->cq;
 	struct be_rx_compl_info *rxcp;
+	struct be_adapter *adapter = rxo->adapter;
+	int flush_wait = 0;
 	u16 tail;
 
-	/* First cleanup pending rx completions */
-	while ((rxcp = be_rx_compl_get(rxo)) != NULL) {
-		be_rx_compl_discard(rxo, rxcp);
-		be_cq_notify(rxo->adapter, rx_cq->id, false, 1);
+	/* Consume pending rx completions.
+	 * Wait for the flush completion (identified by zero num_rcvd)
+	 * to arrive. Notify CQ even when there are no more CQ entries
+	 * for HW to flush partially coalesced CQ entries.
+	 * In Lancer, there is no need to wait for flush compl.
+	 */
+	for (;;) {
+		rxcp = be_rx_compl_get(rxo);
+		if (rxcp == NULL) {
+			if (lancer_chip(adapter))
+				break;
+
+			if (flush_wait++ > 10 || be_hw_error(adapter)) {
+				dev_warn(&adapter->pdev->dev,
+					 "did not receive flush compl\n");
+				break;
+			}
+			be_cq_notify(adapter, rx_cq->id, true, 0);
+			mdelay(1);
+		} else {
+			be_rx_compl_discard(rxo, rxcp);
+			be_cq_notify(adapter, rx_cq->id, true, 1);
+			if (rxcp->num_rcvd == 0)
+				break;
+		}
 	}
 
-	/* Then free posted rx buffer that were not used */
+	/* After cleanup, leave the CQ in unarmed state */
+	be_cq_notify(adapter, rx_cq->id, false, 0);
+
+	/* Then free posted rx buffers that were not used */
 	tail = (rxq->head + rxq->len - atomic_read(&rxq->used)) % rxq->len;
 	for (; atomic_read(&rxq->used) > 0; index_inc(&tail, rxq->len)) {
 		page_info = get_rx_page_info(rxo, tail);
@@ -2157,7 +2183,7 @@ void be_detect_error(struct be_adapter *adapter)
 	u32 sliport_status = 0, sliport_err1 = 0, sliport_err2 = 0;
 	u32 i;
 
-	if (be_crit_error(adapter))
+	if (be_hw_error(adapter))
 		return;
 
 	if (lancer_chip(adapter)) {
-- 
1.7.1
