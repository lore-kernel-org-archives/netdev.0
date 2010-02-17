From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH net-next-2.6 3/4] be2net: fix rx-path to ignore a flush
 completion
Date: Wed, 17 Feb 2010 17:05:26 +0530
Message-ID: <20100217113526.GA20173@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:23323 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755962Ab0BQLfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:35:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The flush compl (compl with numfrags == 0; no data) is rcvd
from hw to indicate completion of RXQ destory operation. Fix
the RX path to not process it as RX data.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |   23 +++++++++++++++++++----
 1 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 43dbe28..0ce2c26 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -680,17 +680,17 @@ static void be_rx_compl_discard(struct be_adapter *adapter,
  * indicated by rxcp.
  */
 static void skb_fill_rx_data(struct be_adapter *adapter,
-			struct sk_buff *skb, struct be_eth_rx_compl *rxcp)
+			struct sk_buff *skb, struct be_eth_rx_compl *rxcp,
+			u16 num_rcvd)
 {
 	struct be_queue_info *rxq = &adapter->rx_obj.q;
 	struct be_rx_page_info *page_info;
-	u16 rxq_idx, i, num_rcvd, j;
+	u16 rxq_idx, i, j;
 	u32 pktsize, hdr_len, curr_frag_len, size;
 	u8 *start;
 
 	rxq_idx = AMAP_GET_BITS(struct amap_eth_rx_compl, fragndx, rxcp);
 	pktsize = AMAP_GET_BITS(struct amap_eth_rx_compl, pktsize, rxcp);
-	num_rcvd = AMAP_GET_BITS(struct amap_eth_rx_compl, numfrags, rxcp);
 
 	page_info = get_rx_page_info(adapter, rxq_idx);
 
@@ -766,8 +766,14 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 {
 	struct sk_buff *skb;
 	u32 vlanf, vid;
+	u16 num_rcvd;
 	u8 vtm;
 
+	num_rcvd = AMAP_GET_BITS(struct amap_eth_rx_compl, numfrags, rxcp);
+	/* Is it a flush compl that has no data */
+	if (unlikely(num_rcvd == 0))
+		return;
+
 	skb = netdev_alloc_skb_ip_align(adapter->netdev, BE_HDR_LEN);
 	if (unlikely(!skb)) {
 		if (net_ratelimit())
@@ -776,7 +782,7 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 		return;
 	}
 
-	skb_fill_rx_data(adapter, skb, rxcp);
+	skb_fill_rx_data(adapter, skb, rxcp, num_rcvd);
 
 	if (do_pkt_csum(rxcp, adapter->rx_csum))
 		skb->ip_summed = CHECKSUM_NONE;
@@ -823,6 +829,10 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 	u8 vtm;
 
 	num_rcvd = AMAP_GET_BITS(struct amap_eth_rx_compl, numfrags, rxcp);
+	/* Is it a flush compl that has no data */
+	if (unlikely(num_rcvd == 0))
+		return;
+
 	pkt_size = AMAP_GET_BITS(struct amap_eth_rx_compl, pktsize, rxcp);
 	vlanf = AMAP_GET_BITS(struct amap_eth_rx_compl, vtp, rxcp);
 	rxq_idx = AMAP_GET_BITS(struct amap_eth_rx_compl, fragndx, rxcp);
@@ -1273,6 +1283,11 @@ static void be_rx_queues_destroy(struct be_adapter *adapter)
 	q = &adapter->rx_obj.q;
 	if (q->created) {
 		be_cmd_q_destroy(adapter, q, QTYPE_RXQ);
+		
+		/* After the rxq is invalidated, wait for a grace time
+		 * of 1ms for all dma to end and the flush compl to arrive
+		 */
+		mdelay(1);
 		be_rx_q_clean(adapter);
 	}
 	be_queue_free(adapter, q);
-- 
1.6.3.3

