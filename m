From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 1/3] ethoc: Write bus addresses to registers
Date: Tue, 18 May 2010 07:39:24 +0200
Message-ID: <1274161166-18521-2-git-send-email-jonas@southpole.se>
References: <1274161166-18521-1-git-send-email-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:35396 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756633Ab0ERF6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 01:58:32 -0400
In-Reply-To: <1274161166-18521-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethoc driver should be writing bus addresses to the ethoc registers, not
virtual addresses.

Also, use bus_to_virt instead of phys_to_virt to make this explicit.
---
 drivers/net/ethoc.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index a8d9250..41bded6 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -283,7 +283,7 @@ static inline void ethoc_disable_rx_and_tx(struct ethoc *dev)
 	ethoc_write(dev, MODER, mode);
 }
 
-static int ethoc_init_ring(struct ethoc *dev)
+static int ethoc_init_ring(struct ethoc *dev, void* mem_start)
 {
 	struct ethoc_bd bd;
 	int i;
@@ -293,7 +293,7 @@ static int ethoc_init_ring(struct ethoc *dev)
 	dev->cur_rx = 0;
 
 	/* setup transmission buffers */
-	bd.addr = virt_to_phys(dev->membase);
+	bd.addr = mem_start;
 	bd.stat = TX_BD_IRQ | TX_BD_CRC;
 
 	for (i = 0; i < dev->num_tx; i++) {
@@ -413,7 +413,7 @@ static int ethoc_rx(struct net_device *dev, int limit)
 			skb = netdev_alloc_skb_ip_align(dev, size);
 
 			if (likely(skb)) {
-				void *src = phys_to_virt(bd.addr);
+				void *src = bus_to_virt(bd.addr);
 				memcpy_fromio(skb_put(skb, size), src, size);
 				skb->protocol = eth_type_trans(skb, dev);
 				priv->stats.rx_packets++;
@@ -672,7 +672,7 @@ static int ethoc_open(struct net_device *dev)
 	priv->num_rx = num_bd - priv->num_tx;
 	ethoc_write(priv, TX_BD_NUM, priv->num_tx);
 
-	ethoc_init_ring(priv);
+	ethoc_init_ring(priv, dev->mem_start);
 	ethoc_reset(priv);
 
 	if (netif_queue_stopped(dev)) {
@@ -836,7 +836,7 @@ static netdev_tx_t ethoc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	else
 		bd.stat &= ~TX_BD_PAD;
 
-	dest = phys_to_virt(bd.addr);
+	dest = bus_to_virt(bd.addr);
 	memcpy_toio(dest, skb->data, skb->len);
 
 	bd.stat &= ~(TX_BD_STATS | TX_BD_LEN_MASK);
-- 
1.7.0.4

