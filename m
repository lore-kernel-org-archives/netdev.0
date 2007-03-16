From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 5/7] skge: transmit locking improvements
Date: Fri, 16 Mar 2007 14:01:30 -0700
Message-ID: <20070316210156.110890451@linux-foundation.org>
References: <20070316210125.324052637@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36172 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965936AbXCPVGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 17:06:41 -0400
Content-Disposition: inline; filename=skge-prefetch.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't need to lock when processing transmit complete unless queue fills.
Modeled after tg3.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/skge.c |   28 ++++++++++++++++++----------
 1 file changed, 18 insertions(+), 10 deletions(-)

--- skge-dev.orig/drivers/net/skge.c
+++ skge-dev/drivers/net/skge.c
@@ -2602,6 +2602,7 @@ static int skge_down(struct net_device *
 
 static inline int skge_avail(const struct skge_ring *ring)
 {
+	smp_mb();
 	return ((ring->to_clean > ring->to_use) ? 0 : ring->count)
 		+ (ring->to_clean - ring->to_use) - 1;
 }
@@ -2690,6 +2691,8 @@ static int skge_xmit_frame(struct sk_buf
 		       dev->name, e - skge->tx_ring.start, skb->len);
 
 	skge->tx_ring.to_use = e->next;
+	smp_wmb();
+
 	if (skge_avail(&skge->tx_ring) <= TX_LOW_WATER) {
 		pr_debug("%s: transmit queue full\n", dev->name);
 		netif_stop_queue(dev);
@@ -2707,8 +2710,6 @@ static void skge_tx_free(struct skge_por
 {
 	struct pci_dev *pdev = skge->hw->pdev;
 
-	BUG_ON(!e->skb);
-
 	/* skb header vs. fragment */
 	if (control & BMU_STF)
 		pci_unmap_single(pdev, pci_unmap_addr(e, mapaddr),
@@ -2726,7 +2727,6 @@ static void skge_tx_free(struct skge_por
 
 		dev_kfree_skb(e->skb);
 	}
-	e->skb = NULL;
 }
 
 /* Free all buffers in transmit ring */
@@ -2998,21 +2998,29 @@ static void skge_tx_done(struct net_devi
 
 	skge_write8(skge->hw, Q_ADDR(txqaddr[skge->port], Q_CSR), CSR_IRQ_CL_F);
 
-	netif_tx_lock(dev);
 	for (e = ring->to_clean; e != ring->to_use; e = e->next) {
-		struct skge_tx_desc *td = e->desc;
+		u32 control = ((const struct skge_tx_desc *) e->desc)->control;
 
-		if (td->control & BMU_OWN)
+		if (control & BMU_OWN)
 			break;
 
-		skge_tx_free(skge, e, td->control);
+		skge_tx_free(skge, e, control);
 	}
 	skge->tx_ring.to_clean = e;
 
-	if (skge_avail(&skge->tx_ring) > TX_LOW_WATER)
-		netif_wake_queue(dev);
+	/* Can run lockless until we need to synchronize to restart queue. */
+	smp_mb();
+
+	if (unlikely(netif_queue_stopped(dev) &&
+		     skge_avail(&skge->tx_ring) > TX_LOW_WATER)) {
+		netif_tx_lock(dev);
+		if (unlikely(netif_queue_stopped(dev) &&
+			     skge_avail(&skge->tx_ring) > TX_LOW_WATER)) {
+			netif_wake_queue(dev);
 
-	netif_tx_unlock(dev);
+		}
+		netif_tx_unlock(dev);
+	}
 }
 
 static int skge_poll(struct net_device *dev, int *budget)

-- 

