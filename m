From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6 1/7] be2net: Remove ERR compl workaround for Lancer
Date: Mon, 7 Mar 2011 18:37:58 +0530
Message-ID: <e596584a-be7a-483f-9828-f60eb84f98ef@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subramanian Seetharaman <subbu.seetharaman@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:52331 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751301Ab1CGNIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 08:08:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Workaround added for Lancer in handling RX ERR completion received
when no RX buffers are posted is not needed.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Subramanian Seetharaman <subbu.seetharaman@emulex.com>
---
 drivers/net/benet/be.h      |    4 +---
 drivers/net/benet/be_main.c |   31 ++++++++-----------------------
 2 files changed, 9 insertions(+), 26 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index ed709a5..4ac0d72 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -220,9 +220,7 @@ struct be_rx_obj {
 	struct be_rx_stats stats;
 	u8 rss_id;
 	bool rx_post_starved;	/* Zero rx frags have been posted to BE */
-	u16 last_frag_index;
-	u16 rsvd;
-	u32 cache_line_barrier[15];
+	u32 cache_line_barrier[16];
 };
 
 struct be_drv_stats {
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index ef66dc6..bf34434 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -909,17 +909,11 @@ static void be_rx_compl_discard(struct be_adapter *adapter,
 	rxq_idx = AMAP_GET_BITS(struct amap_eth_rx_compl, fragndx, rxcp);
 	num_rcvd = AMAP_GET_BITS(struct amap_eth_rx_compl, numfrags, rxcp);
 
-	 /* Skip out-of-buffer compl(lancer) or flush compl(BE) */
-	if (likely(rxq_idx != rxo->last_frag_index && num_rcvd != 0)) {
-
-		rxo->last_frag_index = rxq_idx;
-
-		for (i = 0; i < num_rcvd; i++) {
-			page_info = get_rx_page_info(adapter, rxo, rxq_idx);
-			put_page(page_info->page);
-			memset(page_info, 0, sizeof(*page_info));
-			index_inc(&rxq_idx, rxq->len);
-		}
+	for (i = 0; i < num_rcvd; i++) {
+		page_info = get_rx_page_info(adapter, rxo, rxq_idx);
+		put_page(page_info->page);
+		memset(page_info, 0, sizeof(*page_info));
+		index_inc(&rxq_idx, rxq->len);
 	}
 }
 
@@ -1579,9 +1573,6 @@ static int be_rx_queues_create(struct be_adapter *adapter)
 	adapter->big_page_size = (1 << get_order(rx_frag_size)) * PAGE_SIZE;
 	for_all_rx_queues(adapter, rxo, i) {
 		rxo->adapter = adapter;
-		/* Init last_frag_index so that the frag index in the first
-		 * completion will never match */
-		rxo->last_frag_index = 0xffff;
 		rxo->rx_eq.max_eqd = BE_MAX_EQD;
 		rxo->rx_eq.enable_aic = true;
 
@@ -1722,7 +1713,7 @@ static int be_poll_rx(struct napi_struct *napi, int budget)
 	struct be_queue_info *rx_cq = &rxo->cq;
 	struct be_eth_rx_compl *rxcp;
 	u32 work_done;
-	u16 frag_index, num_rcvd;
+	u16 num_rcvd;
 	u8 err;
 
 	rxo->stats.rx_polls++;
@@ -1732,16 +1723,10 @@ static int be_poll_rx(struct napi_struct *napi, int budget)
 			break;
 
 		err = AMAP_GET_BITS(struct amap_eth_rx_compl, err, rxcp);
-		frag_index = AMAP_GET_BITS(struct amap_eth_rx_compl, fragndx,
-								rxcp);
 		num_rcvd = AMAP_GET_BITS(struct amap_eth_rx_compl, numfrags,
 								rxcp);
-
-		/* Skip out-of-buffer compl(lancer) or flush compl(BE) */
-		if (likely(frag_index != rxo->last_frag_index &&
-				num_rcvd != 0)) {
-			rxo->last_frag_index = frag_index;
-
+		/* Ignore flush completions */
+		if (num_rcvd) {
 			if (do_gro(rxo, rxcp, err))
 				be_rx_compl_process_gro(adapter, rxo, rxcp);
 			else
-- 
1.6.0.2

