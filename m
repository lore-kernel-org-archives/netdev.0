From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 8/8] r8169: print errors when dma mapping fail
Date: Thu, 21 Oct 2010 10:25:43 +0200
Message-ID: <1287649543-6569-9-git-send-email-sgruszka@redhat.com>
References: <1287649543-6569-1-git-send-email-sgruszka@redhat.com>
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45602 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753565Ab0JUIXg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 04:23:36 -0400
In-Reply-To: <1287649543-6569-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If dma mapping fail we are dropping packages or fail to open device.
But exact reason of drop/fail stays unknow for a user, so print errors.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/r8169.c |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 1165e7d..cd16077 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3974,8 +3974,11 @@ static struct sk_buff *rtl8169_alloc_rx_data(struct rtl8169_private *tp,
 
 	mapping = dma_map_single(d, rtl8169_align(data), rx_buf_sz,
 				 DMA_FROM_DEVICE);
-	if (unlikely(dma_mapping_error(d, mapping)))
+	if (unlikely(dma_mapping_error(d, mapping))) {
+		if (net_ratelimit())
+			netif_err(tp, drv, tp->dev, "Failed to map RX DMA!\n");
 		goto err_out;
+	}
 
 	rtl8169_map_to_asic(desc, mapping, rx_buf_sz);
 	return data;
@@ -4203,8 +4206,12 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 		len = frag->size;
 		addr = ((void *) page_address(frag->page)) + frag->page_offset;
 		mapping = dma_map_single(d, addr, len, DMA_TO_DEVICE);
-		if (unlikely(dma_mapping_error(d, mapping)))
+		if (unlikely(dma_mapping_error(d, mapping))) {
+			if (net_ratelimit())
+				netif_err(tp, drv, tp->dev,
+					  "Failed to map TX fragments DMA!\n");
 			goto err_out;
+		}
 
 		/* anti gcc 2.95.3 bugware (sic) */
 		status = opts1 | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
@@ -4270,8 +4277,11 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	len = skb_headlen(skb);
 	mapping = dma_map_single(d, skb->data, len, DMA_TO_DEVICE);
-	if (unlikely(dma_mapping_error(d, mapping)))
+	if (unlikely(dma_mapping_error(d, mapping))) {
+		if (net_ratelimit())
+			netif_err(tp, drv, dev, "Failed to map TX DMA!\n");
 		goto err_dma_0;
+	}
 
 	tp->tx_skb[entry].len = len;
 	txd->addr = cpu_to_le64(mapping);
-- 
1.6.5.2

