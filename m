From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 3/8] be2net: fix RX fragment posting for jumbo frames
Date: Fri, 12 Sep 2014 17:39:16 +0530
Message-ID: <1410523761-1744-4-git-send-email-sathya.perla@emulex.com>
References: <1410523761-1744-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:24676 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754525AbaILMGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 08:06:49 -0400
In-Reply-To: <1410523761-1744-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@emulex.com>

In the RX path, the driver currently consumes upto 64 (budget) packets in
one NAPI sweep. When the size of the packet received is larger than a
fragment size (2K), more than one fragment is consumed for each packet.
As the driver currently posts a max of 64 fragments, all the consumed
fragments may not be replenished. This can cause avoidable drops in RX path.
This patch fixes this by posting a max(consumed_frags, 64) frags. This is
done only when there are atleast 64 free slots in the RXQ.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   22 +++++++++++++++-------
 1 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f059b62..a6cf6c7 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1852,7 +1852,7 @@ static inline struct page *be_alloc_pages(u32 size, gfp_t gfp)
  * Allocate a page, split it to fragments of size rx_frag_size and post as
  * receive buffers to BE
  */
-static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp)
+static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp, u32 frags_needed)
 {
 	struct be_adapter *adapter = rxo->adapter;
 	struct be_rx_page_info *page_info = NULL, *prev_page_info = NULL;
@@ -1861,10 +1861,10 @@ static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp)
 	struct device *dev = &adapter->pdev->dev;
 	struct be_eth_rx_d *rxd;
 	u64 page_dmaaddr = 0, frag_dmaaddr;
-	u32 posted, page_offset = 0;
+	u32 posted, page_offset = 0, notify = 0;
 
 	page_info = &rxo->page_info_tbl[rxq->head];
-	for (posted = 0; posted < MAX_RX_POST && !page_info->page; posted++) {
+	for (posted = 0; posted < frags_needed && !page_info->page; posted++) {
 		if (!pagep) {
 			pagep = be_alloc_pages(adapter->big_page_size, gfp);
 			if (unlikely(!pagep)) {
@@ -1920,7 +1920,11 @@ static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp)
 		atomic_add(posted, &rxq->used);
 		if (rxo->rx_post_starved)
 			rxo->rx_post_starved = false;
-		be_rxq_notify(adapter, rxq->id, posted);
+		do {
+			notify = min(256u, posted);
+			be_rxq_notify(adapter, rxq->id, notify);
+			posted -= notify;
+		} while (posted);
 	} else if (atomic_read(&rxq->used) == 0) {
 		/* Let be_worker replenish when memory is available */
 		rxo->rx_post_starved = true;
@@ -2371,6 +2375,7 @@ static int be_process_rx(struct be_rx_obj *rxo, struct napi_struct *napi,
 	struct be_queue_info *rx_cq = &rxo->cq;
 	struct be_rx_compl_info *rxcp;
 	u32 work_done;
+	u32 frags_consumed = 0;
 
 	for (work_done = 0; work_done < budget; work_done++) {
 		rxcp = be_rx_compl_get(rxo);
@@ -2403,6 +2408,7 @@ static int be_process_rx(struct be_rx_obj *rxo, struct napi_struct *napi,
 			be_rx_compl_process(rxo, napi, rxcp);
 
 loop_continue:
+		frags_consumed += rxcp->num_rcvd;
 		be_rx_stats_update(rxo, rxcp);
 	}
 
@@ -2414,7 +2420,9 @@ loop_continue:
 		 */
 		if (atomic_read(&rxo->q.used) < RX_FRAGS_REFILL_WM &&
 		    !rxo->rx_post_starved)
-			be_post_rx_frags(rxo, GFP_ATOMIC);
+			be_post_rx_frags(rxo, GFP_ATOMIC,
+					 max_t(u32, MAX_RX_POST,
+					       frags_consumed));
 	}
 
 	return work_done;
@@ -2896,7 +2904,7 @@ static int be_rx_qs_create(struct be_adapter *adapter)
 
 	/* First time posting */
 	for_all_rx_queues(adapter, rxo, i)
-		be_post_rx_frags(rxo, GFP_KERNEL);
+		be_post_rx_frags(rxo, GFP_KERNEL, MAX_RX_POST);
 	return 0;
 }
 
@@ -4778,7 +4786,7 @@ static void be_worker(struct work_struct *work)
 		 * allocation failures.
 		 */
 		if (rxo->rx_post_starved)
-			be_post_rx_frags(rxo, GFP_KERNEL);
+			be_post_rx_frags(rxo, GFP_KERNEL, MAX_RX_POST);
 	}
 
 	be_eqd_update(adapter);
-- 
1.7.1
