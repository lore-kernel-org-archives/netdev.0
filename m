From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 6/6] r8169: print errors when dma mapping fail
Date: Fri, 15 Oct 2010 14:15:22 +0200
Message-ID: <1287144922-3297-6-git-send-email-sgruszka@redhat.com>
References: <1287144922-3297-1-git-send-email-sgruszka@redhat.com>
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22972 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754830Ab0JOMNN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 08:13:13 -0400
In-Reply-To: <1287144922-3297-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Print errors because dma mapping failures can cause device to stop
working and will need user intervention to recover.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/r8169.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 0ef49b4..b27b989 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4022,8 +4022,10 @@ static struct sk_buff *rtl8169_alloc_rx_skb(struct rtl8169_private *tp,
 	skb_reserve(skb, align ? ((pad - 1) & (unsigned long)skb->data) : pad);
 
 	mapping = dma_map_single(d, skb->data, rx_buf_sz, DMA_FROM_DEVICE);
-	if (dma_mapping_error(d, mapping))
+	if (dma_mapping_error(d, mapping)) {
+		netif_err(tp, drv, tp->dev, "Failed to map RX DMA!\n");
 		goto err_free_skb_1;
+	}
 
 	rtl8169_map_to_asic(desc, mapping, rx_buf_sz);
 
@@ -4259,8 +4261,11 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 		len = frag->size;
 		addr = ((void *) page_address(frag->page)) + frag->page_offset;
 		mapping = dma_map_single(d, addr, len, DMA_TO_DEVICE);
-		if (unlikely(dma_mapping_error(d, mapping)))
+		if (unlikely(dma_mapping_error(d, mapping))) {
+			netif_err(tp, drv, tp->dev,
+				  "Failed to map TX fragments DMA!\n");
 			goto err_out;
+		}
 
 		/* anti gcc 2.95.3 bugware (sic) */
 		status = opts1 | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
@@ -4326,8 +4331,10 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	len = skb_headlen(skb);
 	mapping = dma_map_single(d, skb->data, len, DMA_TO_DEVICE);
-	if (unlikely(dma_mapping_error(d, mapping)))
+	if (unlikely(dma_mapping_error(d, mapping))) {
+		netif_err(tp, drv, dev, "Failed to map TX DMA!\n");
 		goto err_stop_0;
+	}
 
 	tp->tx_skb[entry].len = len;
 	txd->addr = cpu_to_le64(mapping);
-- 
1.7.1

