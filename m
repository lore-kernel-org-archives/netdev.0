From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 3/3] be2net: Handle out of buffer completions
 for lancer
Date: Wed, 1 Dec 2010 16:34:17 +0530
Message-ID: <20101201110417.GA1653@emulex.com>
Reply-To: Sathya Perla <sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:37753 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751520Ab0LALEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 06:04:41 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If Lancer chip does not have posted RX buffers, it posts an RX completion entry
with the same frag_index as the last valid completion. The Error bit is also
set. In BE, a flush completion is indicated with a zero value for num_rcvd in
the completion.
Such completions don't carry any data and are not processed.
This patch refactors code to handle both cases with the same code.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be.h      |    4 ++-
 drivers/net/benet/be_main.c |   55 +++++++++++++++++++++++++++---------------
 2 files changed, 38 insertions(+), 21 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index b61a1df..9cab323 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -220,7 +220,9 @@ struct be_rx_obj {
 	struct be_rx_stats stats;
 	u8 rss_id;
 	bool rx_post_starved;	/* Zero rx frags have been posted to BE */
-	u32 cache_line_barrier[16];
+	u16 last_frag_index;
+	u16 rsvd;
+	u32 cache_line_barrier[15];
 };
 
 struct be_vf_cfg {
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index ca4bf9b..114a2d4 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -911,11 +911,17 @@ static void be_rx_compl_discard(struct be_adapter *adapter,
 	rxq_idx = AMAP_GET_BITS(struct amap_eth_rx_compl, fragndx, rxcp);
 	num_rcvd = AMAP_GET_BITS(struct amap_eth_rx_compl, numfrags, rxcp);
 
-	for (i = 0; i < num_rcvd; i++) {
-		page_info = get_rx_page_info(adapter, rxo, rxq_idx);
-		put_page(page_info->page);
-		memset(page_info, 0, sizeof(*page_info));
-		index_inc(&rxq_idx, rxq->len);
+	 /* Skip out-of-buffer compl(lancer) or flush compl(BE) */
+	if (likely(rxq_idx != rxo->last_frag_index && num_rcvd != 0)) {
+
+		rxo->last_frag_index = rxq_idx;
+
+		for (i = 0; i < num_rcvd; i++) {
+			page_info = get_rx_page_info(adapter, rxo, rxq_idx);
+			put_page(page_info->page);
+			memset(page_info, 0, sizeof(*page_info));
+			index_inc(&rxq_idx, rxq->len);
+		}
 	}
 }
 
@@ -1016,9 +1022,6 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 	u8 vtm;
 
 	num_rcvd = AMAP_GET_BITS(struct amap_eth_rx_compl, numfrags, rxcp);
-	/* Is it a flush compl that has no data */
-	if (unlikely(num_rcvd == 0))
-		return;
 
 	skb = netdev_alloc_skb_ip_align(adapter->netdev, BE_HDR_LEN);
 	if (unlikely(!skb)) {
@@ -1075,10 +1078,6 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 	u8 pkt_type;
 
 	num_rcvd = AMAP_GET_BITS(struct amap_eth_rx_compl, numfrags, rxcp);
-	/* Is it a flush compl that has no data */
-	if (unlikely(num_rcvd == 0))
-		return;
-
 	pkt_size = AMAP_GET_BITS(struct amap_eth_rx_compl, pktsize, rxcp);
 	vlanf = AMAP_GET_BITS(struct amap_eth_rx_compl, vtp, rxcp);
 	rxq_idx = AMAP_GET_BITS(struct amap_eth_rx_compl, fragndx, rxcp);
@@ -1349,7 +1348,7 @@ static void be_rx_q_clean(struct be_adapter *adapter, struct be_rx_obj *rxo)
 	while ((rxcp = be_rx_compl_get(rxo)) != NULL) {
 		be_rx_compl_discard(adapter, rxo, rxcp);
 		be_rx_compl_reset(rxcp);
-		be_cq_notify(adapter, rx_cq->id, true, 1);
+		be_cq_notify(adapter, rx_cq->id, false, 1);
 	}
 
 	/* Then free posted rx buffer that were not used */
@@ -1576,6 +1575,9 @@ static int be_rx_queues_create(struct be_adapter *adapter)
 	adapter->big_page_size = (1 << get_order(rx_frag_size)) * PAGE_SIZE;
 	for_all_rx_queues(adapter, rxo, i) {
 		rxo->adapter = adapter;
+		/* Init last_frag_index so that the frag index in the first
+		 * completion will never match */
+		rxo->last_frag_index = 0xffff;
 		rxo->rx_eq.max_eqd = BE_MAX_EQD;
 		rxo->rx_eq.enable_aic = true;
 
@@ -1697,10 +1699,9 @@ static irqreturn_t be_msix_tx_mcc(int irq, void *dev)
 	return IRQ_HANDLED;
 }
 
-static inline bool do_gro(struct be_adapter *adapter, struct be_rx_obj *rxo,
-			struct be_eth_rx_compl *rxcp)
+static inline bool do_gro(struct be_rx_obj *rxo,
+			struct be_eth_rx_compl *rxcp, u8 err)
 {
-	int err = AMAP_GET_BITS(struct amap_eth_rx_compl, err, rxcp);
 	int tcp_frame = AMAP_GET_BITS(struct amap_eth_rx_compl, tcpf, rxcp);
 
 	if (err)
@@ -1717,6 +1718,8 @@ static int be_poll_rx(struct napi_struct *napi, int budget)
 	struct be_queue_info *rx_cq = &rxo->cq;
 	struct be_eth_rx_compl *rxcp;
 	u32 work_done;
+	u16 frag_index, num_rcvd;
+	u8 err;
 
 	rxo->stats.rx_polls++;
 	for (work_done = 0; work_done < budget; work_done++) {
@@ -1724,10 +1727,22 @@ static int be_poll_rx(struct napi_struct *napi, int budget)
 		if (!rxcp)
 			break;
 
-		if (do_gro(adapter, rxo, rxcp))
-			be_rx_compl_process_gro(adapter, rxo, rxcp);
-		else
-			be_rx_compl_process(adapter, rxo, rxcp);
+		err = AMAP_GET_BITS(struct amap_eth_rx_compl, err, rxcp);
+		frag_index = AMAP_GET_BITS(struct amap_eth_rx_compl, fragndx,
+								rxcp);
+		num_rcvd = AMAP_GET_BITS(struct amap_eth_rx_compl, numfrags,
+								rxcp);
+
+		/* Skip out-of-buffer compl(lancer) or flush compl(BE) */
+		if (likely(frag_index != rxo->last_frag_index &&
+				num_rcvd != 0)) {
+			rxo->last_frag_index = frag_index;
+
+			if (do_gro(rxo, rxcp, err))
+				be_rx_compl_process_gro(adapter, rxo, rxcp);
+			else
+				be_rx_compl_process(adapter, rxo, rxcp);
+		}
 
 		be_rx_compl_reset(rxcp);
 	}
-- 
1.6.5.2

