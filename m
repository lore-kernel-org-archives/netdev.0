From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 12/23] e1000: Maybe stop TX if not enough free descriptors
Date: Tue, 19 Sep 2006 10:28:59 -0700
Message-ID: <20060919172859.4605.60855.stgit@gitlost.site>
References: <20060919172623.4605.56860.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:21261 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030348AbWISRUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:20:04 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060919172623.4605.56860.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   52 ++++++++++++++++++++++++++++++++--------
 1 files changed, 42 insertions(+), 10 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 2ecec51..af9d360 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2899,6 +2899,35 @@ e1000_transfer_dhcp_info(struct e1000_ad
 	return 0;
 }
 
+static int __e1000_maybe_stop_tx(struct net_device *netdev, int size)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_tx_ring *tx_ring = adapter->tx_ring;
+
+	netif_stop_queue(netdev);
+	/* Herbert's original patch had:
+	 *  smp_mb__after_netif_stop_queue();
+	 * but since that doesn't exist yet, just open code it. */
+	smp_mb();
+
+	/* We need to check again in a case another CPU has just
+	 * made room available. */
+	if (likely(E1000_DESC_UNUSED(tx_ring) < size))
+		return -EBUSY;
+
+	/* A reprieve! */
+	netif_start_queue(netdev);
+	return 0;
+}
+
+static int e1000_maybe_stop_tx(struct net_device *netdev,
+                               struct e1000_tx_ring *tx_ring, int size)
+{
+	if (likely(E1000_DESC_UNUSED(tx_ring) >= size))
+		return 0;
+	return __e1000_maybe_stop_tx(netdev, size);
+}
+
 #define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1 )
 static int
 e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
@@ -2917,6 +2946,10 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	unsigned int f;
 	len -= skb->data_len;
 
+	/* This goes back to the question of how to logically map a tx queue
+	 * to a flow.  Right now, performance is impacted slightly negatively
+	 * if using multiple tx queues.  If the stack breaks away from a
+	 * single qdisc implementation, we can look at this again. */
 	tx_ring = adapter->tx_ring;
 
 	if (unlikely(skb->len <= 0)) {
@@ -3012,8 +3045,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
-	if (unlikely(E1000_DESC_UNUSED(tx_ring) < count + 2)) {
-		netif_stop_queue(netdev);
+	if (unlikely(e1000_maybe_stop_tx(netdev, tx_ring, count + 2))) {
 		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
@@ -3060,8 +3092,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	netdev->trans_start = jiffies;
 
 	/* Make sure there is space in the ring for the next send. */
-	if (unlikely(E1000_DESC_UNUSED(tx_ring) < MAX_SKB_FRAGS + 2))
-		netif_stop_queue(netdev);
+	e1000_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 2);
 
 	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 	return NETDEV_TX_OK;
@@ -3557,13 +3588,14 @@ e1000_clean_tx_irq(struct e1000_adapter 
 	tx_ring->next_to_clean = i;
 
 #define TX_WAKE_THRESHOLD 32
-	if (unlikely(cleaned && netif_queue_stopped(netdev) &&
-	             netif_carrier_ok(netdev))) {
-		spin_lock(&tx_ring->tx_lock);
-		if (netif_queue_stopped(netdev) &&
-		    (E1000_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD))
+	if (unlikely(cleaned && netif_carrier_ok(netdev) &&
+		     E1000_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD)) {
+		/* Make sure that anybody stopping the queue after this
+		 * sees the new next_to_clean.
+		 */
+		smp_mb();
+		if (netif_queue_stopped(netdev))
 			netif_wake_queue(netdev);
-		spin_unlock(&tx_ring->tx_lock);
 	}
 
 	if (adapter->detect_tx_hung) {



---
Auke Kok <auke-jan.h.kok@intel.com>
