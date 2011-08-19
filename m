From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 16/75] benet: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:26:48 +0100
Message-ID: <1313760467-8598-16-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Sathya Perla <sathya.perla@emulex.com>
Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/benet/be_main.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index c411bb1..6464b25 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -720,8 +720,8 @@ static int make_tx_wrbs(struct be_adapter *adapter, struct be_queue_info *txq,
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		struct skb_frag_struct *frag =
 			&skb_shinfo(skb)->frags[i];
-		busaddr = dma_map_page(dev, frag->page, frag->page_offset,
-				       frag->size, DMA_TO_DEVICE);
+		busaddr = skb_frag_dma_map(dev, frag, 0,
+					   frag->size, DMA_TO_DEVICE);
 		if (dma_mapping_error(dev, busaddr))
 			goto dma_err;
 		wrb = queue_head_node(txq);
@@ -1119,7 +1119,7 @@ static void skb_fill_rx_data(struct be_adapter *adapter, struct be_rx_obj *rxo,
 		skb->tail += curr_frag_len;
 	} else {
 		skb_shinfo(skb)->nr_frags = 1;
-		skb_shinfo(skb)->frags[0].page = page_info->page;
+		skb_frag_set_page(skb, 0, page_info->page);
 		skb_shinfo(skb)->frags[0].page_offset =
 					page_info->page_offset + hdr_len;
 		skb_shinfo(skb)->frags[0].size = curr_frag_len - hdr_len;
@@ -1144,7 +1144,7 @@ static void skb_fill_rx_data(struct be_adapter *adapter, struct be_rx_obj *rxo,
 		if (page_info->page_offset == 0) {
 			/* Fresh page */
 			j++;
-			skb_shinfo(skb)->frags[j].page = page_info->page;
+			skb_frag_set_page(skb, j, page_info->page);
 			skb_shinfo(skb)->frags[j].page_offset =
 							page_info->page_offset;
 			skb_shinfo(skb)->frags[j].size = 0;
@@ -1226,7 +1226,7 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 		if (i == 0 || page_info->page_offset == 0) {
 			/* First frag or Fresh page */
 			j++;
-			skb_shinfo(skb)->frags[j].page = page_info->page;
+			skb_frag_set_page(skb, j, page_info->page);
 			skb_shinfo(skb)->frags[j].page_offset =
 							page_info->page_offset;
 			skb_shinfo(skb)->frags[j].size = 0;
-- 
1.7.2.5
