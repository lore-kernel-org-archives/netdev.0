From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/5] skge: TX low water mark definition
Date: Tue, 06 Jun 2006 10:11:12 -0700
Message-ID: <20060606171341.726839000@zqx3.pdx.osdl.net>
References: <20060606171110.592587000@zqx3.pdx.osdl.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:59090 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750909AbWFFRPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2006 13:15:04 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=skge-lowater.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Consolidate all usage of ring low water mark to one value.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- skge-2.6.orig/drivers/net/skge.c
+++ skge-2.6/drivers/net/skge.c
@@ -50,6 +50,7 @@
 #define DEFAULT_TX_RING_SIZE	128
 #define DEFAULT_RX_RING_SIZE	512
 #define MAX_TX_RING_SIZE	1024
+#define TX_LOW_WATER		(MAX_SKB_FRAGS + 1)
 #define MAX_RX_RING_SIZE	4096
 #define RX_COPY_THRESHOLD	128
 #define RX_BUF_SIZE		1536
@@ -401,7 +402,7 @@ static int skge_set_ring_param(struct ne
 	int err;
 
 	if (p->rx_pending == 0 || p->rx_pending > MAX_RX_RING_SIZE ||
-	    p->tx_pending < MAX_SKB_FRAGS+1 || p->tx_pending > MAX_TX_RING_SIZE)
+	    p->tx_pending < TX_LOW_WATER || p->tx_pending > MAX_TX_RING_SIZE)
 		return -EINVAL;
 
 	skge->rx_ring.count = p->rx_pending;
@@ -2394,7 +2395,7 @@ static int skge_xmit_frame(struct sk_buf
 		       dev->name, e - ring->start, skb->len);
 
 	ring->to_use = e->next;
-	if (skge_avail(&skge->tx_ring) <= MAX_SKB_FRAGS + 1) {
+	if (skge_avail(&skge->tx_ring) <= TX_LOW_WATER) {
 		pr_debug("%s: transmit queue full\n", dev->name);
 		netif_stop_queue(dev);
 	}
@@ -2689,7 +2690,7 @@ static void skge_tx_done(struct skge_por
 
 	skge_write8(skge->hw, Q_ADDR(txqaddr[skge->port], Q_CSR), CSR_IRQ_CL_F);
 
-	if (skge_avail(&skge->tx_ring) > MAX_SKB_FRAGS + 1)
+	if (skge_avail(&skge->tx_ring) > TX_LOW_WATER)
 		netif_wake_queue(skge->netdev);
 
 	spin_unlock(&skge->tx_lock);

--

