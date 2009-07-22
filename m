From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH] be2net: Bug fix in the non-lro path. Size of received
	packet was not updated in statistics properly.
Date: Wed, 22 Jul 2009 16:49:44 +0530
Message-ID: <20090722111933.GA22465@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:4005 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752521AbZGVLTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 07:19:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug in the non-lro path. 
Wrong size of received packet was being passed for updating receive statistics.
This patch is against the net-2.6 git.

Thanks
-Ajit

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index c43f6a1..dea3155 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -667,7 +667,7 @@ static void skb_fill_rx_data(struct be_adapter *adapter,
 	struct be_queue_info *rxq = &adapter->rx_obj.q;
 	struct be_rx_page_info *page_info;
 	u16 rxq_idx, i, num_rcvd, j;
-	u32 pktsize, hdr_len, curr_frag_len;
+	u32 pktsize, hdr_len, curr_frag_len, size;
 	u8 *start;
 
 	rxq_idx = AMAP_GET_BITS(struct amap_eth_rx_compl, fragndx, rxcp);
@@ -708,12 +708,13 @@ static void skb_fill_rx_data(struct be_adapter *adapter,
 	}
 
 	/* More frags present for this completion */
-	pktsize -= curr_frag_len; /* account for above copied frag */
+	size = pktsize;
 	for (i = 1, j = 0; i < num_rcvd; i++) {
+		size -= curr_frag_len;
 		index_inc(&rxq_idx, rxq->len);
 		page_info = get_rx_page_info(adapter, rxq_idx);
 
-		curr_frag_len = min(pktsize, rx_frag_size);
+		curr_frag_len = min(size, rx_frag_size);
 
 		/* Coalesce all frags from the same physical page in one slot */
 		if (page_info->page_offset == 0) {
@@ -731,7 +732,6 @@ static void skb_fill_rx_data(struct be_adapter *adapter,
 		skb_shinfo(skb)->frags[j].size += curr_frag_len;
 		skb->len += curr_frag_len;
 		skb->data_len += curr_frag_len;
-		pktsize -= curr_frag_len;
 
 		memset(page_info, 0, sizeof(*page_info));
 	}
-- 
1.6.0.4

