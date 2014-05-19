From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 8/9] net: mv643xx_eth: Use dma_map_single() to map the skb fragments
Date: Mon, 19 May 2014 13:59:59 -0300
Message-ID: <1400518800-6111-9-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1400518800-6111-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:53627 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S964813AbaESRBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 13:01:21 -0400
In-Reply-To: <1400518800-6111-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using dma_map_single() instead of skb_frag_dma_map() allows to unmap
all the descriptors using dma_unmap_single(). This change allows
to introduce software TSO in a less intrusive way.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 01fde2c..8854751 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -732,8 +732,10 @@ static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
 		skb_frag_t *this_frag;
 		int tx_index;
 		struct tx_desc *desc;
+		void *addr;
 
 		this_frag = &skb_shinfo(skb)->frags[frag];
+		addr = page_address(this_frag->page.p) + this_frag->page_offset;
 		tx_index = txq->tx_curr_desc++;
 		if (txq->tx_curr_desc == txq->tx_ring_size)
 			txq->tx_curr_desc = 0;
@@ -753,10 +755,8 @@ static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
 
 		desc->l4i_chk = 0;
 		desc->byte_cnt = skb_frag_size(this_frag);
-		desc->buf_ptr = skb_frag_dma_map(mp->dev->dev.parent,
-						 this_frag, 0,
-						 skb_frag_size(this_frag),
-						 DMA_TO_DEVICE);
+		desc->buf_ptr = dma_map_single(mp->dev->dev.parent, addr,
+					       desc->byte_cnt, DMA_TO_DEVICE);
 	}
 }
 
@@ -927,14 +927,8 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 			mp->dev->stats.tx_errors++;
 		}
 
-		if (cmd_sts & TX_FIRST_DESC) {
-			dma_unmap_single(mp->dev->dev.parent, desc->buf_ptr,
-					 desc->byte_cnt, DMA_TO_DEVICE);
-		} else {
-			dma_unmap_page(mp->dev->dev.parent, desc->buf_ptr,
-				       desc->byte_cnt, DMA_TO_DEVICE);
-		}
-
+		dma_unmap_single(mp->dev->dev.parent, desc->buf_ptr,
+				 desc->byte_cnt, DMA_TO_DEVICE);
 		dev_kfree_skb(skb);
 	}
 
-- 
1.9.1
