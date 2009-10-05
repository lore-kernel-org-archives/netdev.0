From: Thomas Chou <thomas@wytron.com.tw>
Subject: [PATCH 2/4] ethoc: fix buffer address mapping
Date: Mon,  5 Oct 2009 17:33:18 +0800
Message-ID: <1254735200-2718-2-git-send-email-thomas@wytron.com.tw>
References: <1254735200-2718-1-git-send-email-thomas@wytron.com.tw>
Cc: netdev@vger.kernel.org, Thomas Chou <thomas@wytron.com.tw>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr33.hinet.net ([168.95.4.133]:57909 "EHLO msr33.hinet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932458AbZJEKCg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2009 06:02:36 -0400
In-Reply-To: <1254735200-2718-1-git-send-email-thomas@wytron.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pointer address in buffer descriptors is physical address. The
pointer that processor used to access packet is virtual address.

Though the higher bits of pointer address used by the MAC may be
truncated to zero in special case, it is not always true in larger
designs.

Signed-off-by: Thomas Chou <thomas@wytron.com.tw>
---
 drivers/net/ethoc.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 7475620..f92747f 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -284,7 +284,7 @@ static int ethoc_init_ring(struct ethoc *dev)
 	dev->cur_rx = 0;
 
 	/* setup transmission buffers */
-	bd.addr = 0;
+	bd.addr = virt_to_phys(dev->membase);
 	bd.stat = TX_BD_IRQ | TX_BD_CRC;
 
 	for (i = 0; i < dev->num_tx; i++) {
@@ -295,7 +295,6 @@ static int ethoc_init_ring(struct ethoc *dev)
 		bd.addr += ETHOC_BUFSIZ;
 	}
 
-	bd.addr = dev->num_tx * ETHOC_BUFSIZ;
 	bd.stat = RX_BD_EMPTY | RX_BD_IRQ;
 
 	for (i = 0; i < dev->num_rx; i++) {
@@ -401,7 +400,7 @@ static int ethoc_rx(struct net_device *dev, int limit)
 			int size = bd.stat >> 16;
 			struct sk_buff *skb = netdev_alloc_skb(dev, size);
 			if (likely(skb)) {
-				void *src = priv->membase + bd.addr;
+				void *src = phys_to_virt(bd.addr);
 				memcpy_fromio(skb_put(skb, size), src, size);
 				skb->protocol = eth_type_trans(skb, dev);
 				priv->stats.rx_packets++;
@@ -823,7 +822,7 @@ static netdev_tx_t ethoc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	else
 		bd.stat &= ~TX_BD_PAD;
 
-	dest = priv->membase + bd.addr;
+	dest = phys_to_virt(bd.addr);
 	memcpy_toio(dest, skb->data, skb->len);
 
 	bd.stat &= ~(TX_BD_STATS | TX_BD_LEN_MASK);
-- 
1.6.2.5

