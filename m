From: Tom Herbert <therbert@google.com>
Subject: [PATCH 3/3] forcedeth: Support for byte queue limits
Date: Mon, 25 Apr 2011 21:38:13 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1104252131300.5997@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:9285 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503Ab1DZEiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 00:38:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to forcedeth to use byte queue limits.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/forcedeth.c |   38 ++++++++++++++++++++++++++++++++++----
 1 files changed, 34 insertions(+), 4 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 0e1c76a..00f9f99 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1827,6 +1827,11 @@ static void nv_init_rx(struct net_device *dev)
 	}
 }
 
+static struct netdev_queue *nv_netdev_queue(struct fe_priv *np)
+{
+	return netdev_get_tx_queue(np->dev, 0);
+}
+
 static void nv_init_tx(struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
@@ -1843,6 +1848,7 @@ static void nv_init_tx(struct net_device *dev)
 	np->tx_pkts_in_progress = 0;
 	np->tx_change_owner = NULL;
 	np->tx_end_flip = NULL;
+	netdev_queue_bql_reset(nv_netdev_queue(np));
 	np->tx_stop = 0;
 
 	for (i = 0; i < np->tx_ring_size; i++) {
@@ -2107,7 +2113,8 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_lock_irqsave(&np->lock, flags);
 	empty_slots = nv_get_empty_tx_slots(np);
-	if (unlikely(empty_slots <= entries)) {
+	if (unlikely(empty_slots <= entries ||
+	    !netdev_queue_bytes_avail(nv_netdev_queue(np)))) {
 		netif_stop_queue(dev);
 		np->tx_stop = 1;
 		spin_unlock_irqrestore(&np->lock, flags);
@@ -2180,6 +2187,9 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* set tx flags */
 	start_tx->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
+
+	netdev_queue_bytes_sent(nv_netdev_queue(np), skb->len);
+
 	np->put_tx.orig = put_tx;
 
 	spin_unlock_irqrestore(&np->lock, flags);
@@ -2216,7 +2226,8 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 
 	spin_lock_irqsave(&np->lock, flags);
 	empty_slots = nv_get_empty_tx_slots(np);
-	if (unlikely(empty_slots <= entries)) {
+	if (unlikely(empty_slots <= entries ||
+	    !netdev_queue_bytes_avail(nv_netdev_queue(np)))) {
 		netif_stop_queue(dev);
 		np->tx_stop = 1;
 		spin_unlock_irqrestore(&np->lock, flags);
@@ -2319,6 +2330,9 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 
 	/* set tx flags */
 	start_tx->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
+
+	netdev_queue_bytes_sent(nv_netdev_queue(np), skb->len);
+
 	np->put_tx.ex = put_tx;
 
 	spin_unlock_irqrestore(&np->lock, flags);
@@ -2356,6 +2370,7 @@ static int nv_tx_done(struct net_device *dev, int limit)
 	u32 flags;
 	int tx_work = 0;
 	struct ring_desc *orig_get_tx = np->get_tx.orig;
+	unsigned long bytes_cleaned = 0;
 
 	while ((np->get_tx.orig != np->put_tx.orig) &&
 	       !((flags = le32_to_cpu(np->get_tx.orig->flaglen)) & NV_TX_VALID) &&
@@ -2395,6 +2410,7 @@ static int nv_tx_done(struct net_device *dev, int limit)
 					dev->stats.tx_packets++;
 					dev->stats.tx_bytes += np->get_tx_ctx->skb->len;
 				}
+				bytes_cleaned += np->get_tx_ctx->skb->len;
 				dev_kfree_skb_any(np->get_tx_ctx->skb);
 				np->get_tx_ctx->skb = NULL;
 				tx_work++;
@@ -2405,7 +2421,12 @@ static int nv_tx_done(struct net_device *dev, int limit)
 		if (unlikely(np->get_tx_ctx++ == np->last_tx_ctx))
 			np->get_tx_ctx = np->first_tx_ctx;
 	}
-	if (unlikely((np->tx_stop == 1) && (np->get_tx.orig != orig_get_tx))) {
+
+	if (bytes_cleaned)
+		netdev_queue_bytes_completed(nv_netdev_queue(np),
+		    bytes_cleaned);
+	if (unlikely((np->tx_stop == 1) && (np->get_tx.orig != orig_get_tx) &&
+	    netdev_queue_bytes_avail(nv_netdev_queue(np)))) {
 		np->tx_stop = 0;
 		netif_wake_queue(dev);
 	}
@@ -2418,6 +2439,7 @@ static int nv_tx_done_optimized(struct net_device *dev, int limit)
 	u32 flags;
 	int tx_work = 0;
 	struct ring_desc_ex *orig_get_tx = np->get_tx.ex;
+	unsigned long bytes_cleaned = 0;
 
 	while ((np->get_tx.ex != np->put_tx.ex) &&
 	       !((flags = le32_to_cpu(np->get_tx.ex->flaglen)) & NV_TX2_VALID) &&
@@ -2437,6 +2459,7 @@ static int nv_tx_done_optimized(struct net_device *dev, int limit)
 				}
 			}
 
+			bytes_cleaned += np->get_tx_ctx->skb->len;
 			dev_kfree_skb_any(np->get_tx_ctx->skb);
 			np->get_tx_ctx->skb = NULL;
 			tx_work++;
@@ -2449,7 +2472,12 @@ static int nv_tx_done_optimized(struct net_device *dev, int limit)
 		if (unlikely(np->get_tx_ctx++ == np->last_tx_ctx))
 			np->get_tx_ctx = np->first_tx_ctx;
 	}
-	if (unlikely((np->tx_stop == 1) && (np->get_tx.ex != orig_get_tx))) {
+
+	if (bytes_cleaned)
+		netdev_queue_bytes_completed(nv_netdev_queue(np),
+		    bytes_cleaned);
+	if (unlikely((np->tx_stop == 1) && (np->get_tx.ex != orig_get_tx) &&
+	    netdev_queue_bytes_avail(nv_netdev_queue(np)))) {
 		np->tx_stop = 0;
 		netif_wake_queue(dev);
 	}
@@ -5263,6 +5291,8 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	np->stats_poll.data = (unsigned long) dev;
 	np->stats_poll.function = nv_do_stats_poll;	/* timer handler */
 
+	netdev_queue_bql_init(nv_netdev_queue(np));
+
 	err = pci_enable_device(pci_dev);
 	if (err)
 		goto out_free;
-- 
1.7.3.1

