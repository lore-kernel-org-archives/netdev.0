From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-2.6] be2net: Fix to avoid a crash seen on PPC with LRO
	and Jumbo frames.
Date: Fri, 26 Jun 2009 18:21:07 +0530
Message-ID: <20090626125054.GA25517@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:5268 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756758AbZFZMvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 08:51:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While testing the driver on PPC, we ran into a crash with LRO, Jumbo frames.
With CONFIG_PPC_64K_PAGES configured (a default in PPC), MAX_SKB_FRAGS drops to 3 and we were crossing the array limits on skb_shinfo(skb)->frags[]. 
Now we coalesce the frags from the same physical page into one slot in 
skb_shinfo(skb)->frags[] and go to the next index when the frag is from 
different physical page.

This patch is against the net-2.6 tree.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h         |    2 +-
 drivers/net/benet/be_ethtool.c |    4 +-
 drivers/net/benet/be_main.c    |   45 ++++++++++++++++++++++++++++-----------
 3 files changed, 35 insertions(+), 16 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index f703758..5b4bf3d 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -73,7 +73,7 @@ static inline char *nic_name(struct pci_dev *pdev)
 #define RX_FRAGS_REFILL_WM	(RX_Q_LEN - MAX_RX_POST)
 
 #define BE_MAX_LRO_DESCRIPTORS  16
-#define BE_MAX_FRAGS_PER_FRAME  16
+#define BE_MAX_FRAGS_PER_FRAME  (min((u32) 16, (u32) MAX_SKB_FRAGS))
 
 struct be_dma_mem {
 	void *va;
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 9592f22..cccc541 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -162,8 +162,8 @@ be_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
 		return -EINVAL;
 
 	adapter->max_rx_coal = coalesce->rx_max_coalesced_frames;
-	if (adapter->max_rx_coal > MAX_SKB_FRAGS)
-		adapter->max_rx_coal = MAX_SKB_FRAGS - 1;
+	if (adapter->max_rx_coal > BE_MAX_FRAGS_PER_FRAME)
+		adapter->max_rx_coal = BE_MAX_FRAGS_PER_FRAME;
 
 	/* if AIC is being turned on now, start with an EQD of 0 */
 	if (rx_eq->enable_aic == 0 &&
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 66c10c8..308eb09 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -666,7 +666,7 @@ static void skb_fill_rx_data(struct be_adapter *adapter,
 {
 	struct be_queue_info *rxq = &adapter->rx_obj.q;
 	struct be_rx_page_info *page_info;
-	u16 rxq_idx, i, num_rcvd;
+	u16 rxq_idx, i, num_rcvd, j;
 	u32 pktsize, hdr_len, curr_frag_len;
 	u8 *start;
 
@@ -709,22 +709,33 @@ static void skb_fill_rx_data(struct be_adapter *adapter,
 
 	/* More frags present for this completion */
 	pktsize -= curr_frag_len; /* account for above copied frag */
-	for (i = 1; i < num_rcvd; i++) {
+	for (i = 1, j = 0; i < num_rcvd; i++) {
 		index_inc(&rxq_idx, rxq->len);
 		page_info = get_rx_page_info(adapter, rxq_idx);
 
 		curr_frag_len = min(pktsize, rx_frag_size);
 
-		skb_shinfo(skb)->frags[i].page = page_info->page;
-		skb_shinfo(skb)->frags[i].page_offset = page_info->page_offset;
-		skb_shinfo(skb)->frags[i].size = curr_frag_len;
+		/* Coalesce all frags from the same physical page in one slot */
+		if (page_info->page_offset == 0) {
+			/* Fresh page */
+			j++;
+			skb_shinfo(skb)->frags[j].page = page_info->page;
+			skb_shinfo(skb)->frags[j].page_offset =
+							page_info->page_offset;
+			skb_shinfo(skb)->frags[j].size = 0;
+			skb_shinfo(skb)->nr_frags++;
+		} else {
+			put_page(page_info->page);
+		}
+
+		skb_shinfo(skb)->frags[j].size += curr_frag_len;
 		skb->len += curr_frag_len;
 		skb->data_len += curr_frag_len;
-		skb_shinfo(skb)->nr_frags++;
 		pktsize -= curr_frag_len;
 
 		memset(page_info, 0, sizeof(*page_info));
 	}
+	BUG_ON(j > MAX_SKB_FRAGS);
 
 done:
 	be_rx_stats_update(adapter, pktsize, num_rcvd);
@@ -786,7 +797,7 @@ static void be_rx_compl_process_lro(struct be_adapter *adapter,
 	struct skb_frag_struct rx_frags[BE_MAX_FRAGS_PER_FRAME];
 	struct be_queue_info *rxq = &adapter->rx_obj.q;
 	u32 num_rcvd, pkt_size, remaining, vlanf, curr_frag_len;
-	u16 i, rxq_idx = 0, vid;
+	u16 i, rxq_idx = 0, vid, j;
 
 	num_rcvd = AMAP_GET_BITS(struct amap_eth_rx_compl, numfrags, rxcp);
 	pkt_size = AMAP_GET_BITS(struct amap_eth_rx_compl, pktsize, rxcp);
@@ -794,20 +805,28 @@ static void be_rx_compl_process_lro(struct be_adapter *adapter,
 	rxq_idx = AMAP_GET_BITS(struct amap_eth_rx_compl, fragndx, rxcp);
 
 	remaining = pkt_size;
-	for (i = 0; i < num_rcvd; i++) {
+	for (i = 0, j = -1; i < num_rcvd; i++) {
 		page_info = get_rx_page_info(adapter, rxq_idx);
 
 		curr_frag_len = min(remaining, rx_frag_size);
 
-		rx_frags[i].page = page_info->page;
-		rx_frags[i].page_offset = page_info->page_offset;
-		rx_frags[i].size = curr_frag_len;
-		remaining -= curr_frag_len;
+		/* Coalesce all frags from the same physical page in one slot */
+		if (i == 0 || page_info->page_offset == 0) {
+			/* First frag or Fresh page */
+			j++;
+			rx_frags[j].page = page_info->page;
+			rx_frags[j].page_offset = page_info->page_offset;
+			rx_frags[j].size = 0;
+		} else {
+			put_page(page_info->page);
+		}
+		rx_frags[j].size += curr_frag_len;
 
+		remaining -= curr_frag_len;
 		index_inc(&rxq_idx, rxq->len);
-
 		memset(page_info, 0, sizeof(*page_info));
 	}
+	BUG_ON(j > MAX_SKB_FRAGS);
 
 	if (likely(!vlanf)) {
 		lro_receive_frags(&adapter->rx_obj.lro_mgr, rx_frags, pkt_size,
-- 
1.6.0.4

