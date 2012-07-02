From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: dont use __netdev_alloc_skb for bounce buffer
Date: Mon, 02 Jul 2012 20:36:12 +0200
Message-ID: <1341254172.22621.456.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stefan Bader <stefan.bader@canonical.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:44530 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755752Ab2GBSgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 14:36:16 -0400
Received: by eaak11 with SMTP id k11so2214056eaa.19
        for <netdev@vger.kernel.org>; Mon, 02 Jul 2012 11:36:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit a1c7fff7e1 (net: netdev_alloc_skb() use build_skb()) broke b44 on
some 64bit machines.

It appears b44 and b43 use __netdev_alloc_skb() instead of alloc_skb()
for their bounce buffers.

There is no need to add an extra NET_SKB_PAD reservation for bounce
buffers :

- In TX path, NET_SKB_PAD is useless

- In RX path in b44, we force a copy of incoming frames if
  GFP_DMA allocations were needed.

Reported-and-bisected-by: Stefan Bader <stefan.bader@canonical.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/broadcom/b44.c  |    4 ++--
 drivers/net/wireless/b43legacy/dma.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 46b8b7d..d09c6b5 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -656,7 +656,7 @@ static int b44_alloc_rx_skb(struct b44 *bp, int src_idx, u32 dest_idx_unmasked)
 			dma_unmap_single(bp->sdev->dma_dev, mapping,
 					     RX_PKT_BUF_SZ, DMA_FROM_DEVICE);
 		dev_kfree_skb_any(skb);
-		skb = __netdev_alloc_skb(bp->dev, RX_PKT_BUF_SZ, GFP_ATOMIC|GFP_DMA);
+		skb = alloc_skb(RX_PKT_BUF_SZ, GFP_ATOMIC | GFP_DMA);
 		if (skb == NULL)
 			return -ENOMEM;
 		mapping = dma_map_single(bp->sdev->dma_dev, skb->data,
@@ -967,7 +967,7 @@ static netdev_tx_t b44_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			dma_unmap_single(bp->sdev->dma_dev, mapping, len,
 					     DMA_TO_DEVICE);
 
-		bounce_skb = __netdev_alloc_skb(dev, len, GFP_ATOMIC | GFP_DMA);
+		bounce_skb = alloc_skb(len, GFP_ATOMIC | GFP_DMA);
 		if (!bounce_skb)
 			goto err_out;
 
diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
index f1f8bd0..c8baf02 100644
--- a/drivers/net/wireless/b43legacy/dma.c
+++ b/drivers/net/wireless/b43legacy/dma.c
@@ -1072,7 +1072,7 @@ static int dma_tx_fragment(struct b43legacy_dmaring *ring,
 	meta->dmaaddr = map_descbuffer(ring, skb->data, skb->len, 1);
 	/* create a bounce buffer in zone_dma on mapping failure. */
 	if (b43legacy_dma_mapping_error(ring, meta->dmaaddr, skb->len, 1)) {
-		bounce_skb = __dev_alloc_skb(skb->len, GFP_ATOMIC | GFP_DMA);
+		bounce_skb = alloc_skb(skb->len, GFP_ATOMIC | GFP_DMA);
 		if (!bounce_skb) {
 			ring->current_slot = old_top_slot;
 			ring->used_slots = old_used_slots;
