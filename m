From: Tom Herbert <therbert@google.com>
Subject: [RFC PATCH v2 6/9] forcedeth: Support for byte queue limits
Date: Sun, 7 Aug 2011 21:51:27 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1108072148310.13386@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:22505 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947Ab1HHEva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 00:51:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to forcedeth to use byte queue limits.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/forcedeth.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index e55df30..fcd664a 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1924,6 +1924,7 @@ static void nv_drain_tx(struct net_device *dev)
 		np->tx_skb[i].first_tx_desc = NULL;
 		np->tx_skb[i].next_tx_ctx = NULL;
 	}
+	netdev_reset_queue(np->dev);
 	np->tx_pkts_in_progress = 0;
 	np->tx_change_owner = NULL;
 	np->tx_end_flip = NULL;
@@ -2178,6 +2179,9 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* set tx flags */
 	start_tx->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
+
+	netdev_sent_queue(np->dev, 1, skb->len);
+
 	np->put_tx.orig = put_tx;
 
 	spin_unlock_irqrestore(&np->lock, flags);
@@ -2317,6 +2321,9 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 
 	/* set tx flags */
 	start_tx->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
+
+	netdev_sent_queue(np->dev, 1, skb->len);
+
 	np->put_tx.ex = put_tx;
 
 	spin_unlock_irqrestore(&np->lock, flags);
@@ -2354,6 +2361,7 @@ static int nv_tx_done(struct net_device *dev, int limit)
 	u32 flags;
 	int tx_work = 0;
 	struct ring_desc *orig_get_tx = np->get_tx.orig;
+	unsigned int bytes_compl = 0;
 
 	while ((np->get_tx.orig != np->put_tx.orig) &&
 	       !((flags = le32_to_cpu(np->get_tx.orig->flaglen)) & NV_TX_VALID) &&
@@ -2375,6 +2383,7 @@ static int nv_tx_done(struct net_device *dev, int limit)
 					dev->stats.tx_packets++;
 					dev->stats.tx_bytes += np->get_tx_ctx->skb->len;
 				}
+				bytes_compl += np->get_tx_ctx->skb->len;
 				dev_kfree_skb_any(np->get_tx_ctx->skb);
 				np->get_tx_ctx->skb = NULL;
 				tx_work++;
@@ -2393,6 +2402,7 @@ static int nv_tx_done(struct net_device *dev, int limit)
 					dev->stats.tx_packets++;
 					dev->stats.tx_bytes += np->get_tx_ctx->skb->len;
 				}
+				bytes_compl += np->get_tx_ctx->skb->len;
 				dev_kfree_skb_any(np->get_tx_ctx->skb);
 				np->get_tx_ctx->skb = NULL;
 				tx_work++;
@@ -2403,6 +2413,9 @@ static int nv_tx_done(struct net_device *dev, int limit)
 		if (unlikely(np->get_tx_ctx++ == np->last_tx_ctx))
 			np->get_tx_ctx = np->first_tx_ctx;
 	}
+
+	netdev_completed_queue(np->dev, tx_work, bytes_compl);
+
 	if (unlikely((np->tx_stop == 1) && (np->get_tx.orig != orig_get_tx))) {
 		np->tx_stop = 0;
 		netif_wake_queue(dev);
@@ -2416,6 +2429,7 @@ static int nv_tx_done_optimized(struct net_device *dev, int limit)
 	u32 flags;
 	int tx_work = 0;
 	struct ring_desc_ex *orig_get_tx = np->get_tx.ex;
+	unsigned long bytes_cleaned = 0;
 
 	while ((np->get_tx.ex != np->put_tx.ex) &&
 	       !((flags = le32_to_cpu(np->get_tx.ex->flaglen)) & NV_TX2_VALID) &&
@@ -2435,6 +2449,7 @@ static int nv_tx_done_optimized(struct net_device *dev, int limit)
 				}
 			}
 
+			bytes_cleaned += np->get_tx_ctx->skb->len;
 			dev_kfree_skb_any(np->get_tx_ctx->skb);
 			np->get_tx_ctx->skb = NULL;
 			tx_work++;
@@ -2447,6 +2462,9 @@ static int nv_tx_done_optimized(struct net_device *dev, int limit)
 		if (unlikely(np->get_tx_ctx++ == np->last_tx_ctx))
 			np->get_tx_ctx = np->first_tx_ctx;
 	}
+
+	netdev_completed_queue(np->dev, tx_work, bytes_cleaned);
+
 	if (unlikely((np->tx_stop == 1) && (np->get_tx.ex != orig_get_tx))) {
 		np->tx_stop = 0;
 		netif_wake_queue(dev);
-- 
1.7.3.1

