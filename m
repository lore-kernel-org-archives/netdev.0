From: Tom Herbert <therbert@google.com>
Subject: [PATCH v3 07/10] forcedeth: Support for byte queue limits
Date: Tue, 22 Nov 2011 21:53:04 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1111222141340.17052@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f74.google.com ([209.85.161.74]:54794 "EHLO
	mail-fx0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411Ab1KWFxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 00:53:07 -0500
Received: by mail-fx0-f74.google.com with SMTP id s1so38323fab.1
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 21:53:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to forcedeth to use byte queue limits.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index e8a5ae3..98e5464 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -1842,6 +1842,7 @@ static void nv_init_tx(struct net_device *dev)
 		np->last_tx.ex = &np->tx_ring.ex[np->tx_ring_size-1];
 	np->get_tx_ctx = np->put_tx_ctx = np->first_tx_ctx = np->tx_skb;
 	np->last_tx_ctx = &np->tx_skb[np->tx_ring_size-1];
+	netdev_reset_queue(np->dev);
 	np->tx_pkts_in_progress = 0;
 	np->tx_change_owner = NULL;
 	np->tx_end_flip = NULL;
@@ -2187,6 +2188,9 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* set tx flags */
 	start_tx->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
+
+	netdev_sent_queue(np->dev, 1, skb->len);
+
 	np->put_tx.orig = put_tx;
 
 	spin_unlock_irqrestore(&np->lock, flags);
@@ -2331,6 +2335,9 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 
 	/* set tx flags */
 	start_tx->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
+
+	netdev_sent_queue(np->dev, 1, skb->len);
+
 	np->put_tx.ex = put_tx;
 
 	spin_unlock_irqrestore(&np->lock, flags);
@@ -2368,6 +2375,7 @@ static int nv_tx_done(struct net_device *dev, int limit)
 	u32 flags;
 	int tx_work = 0;
 	struct ring_desc *orig_get_tx = np->get_tx.orig;
+	unsigned int bytes_compl = 0;
 
 	while ((np->get_tx.orig != np->put_tx.orig) &&
 	       !((flags = le32_to_cpu(np->get_tx.orig->flaglen)) & NV_TX_VALID) &&
@@ -2381,6 +2389,7 @@ static int nv_tx_done(struct net_device *dev, int limit)
 					if ((flags & NV_TX_RETRYERROR) && !(flags & NV_TX_RETRYCOUNT_MASK))
 						nv_legacybackoff_reseed(dev);
 				}
+				bytes_compl += np->get_tx_ctx->skb->len;
 				dev_kfree_skb_any(np->get_tx_ctx->skb);
 				np->get_tx_ctx->skb = NULL;
 				tx_work++;
@@ -2391,6 +2400,7 @@ static int nv_tx_done(struct net_device *dev, int limit)
 					if ((flags & NV_TX2_RETRYERROR) && !(flags & NV_TX2_RETRYCOUNT_MASK))
 						nv_legacybackoff_reseed(dev);
 				}
+				bytes_compl += np->get_tx_ctx->skb->len;
 				dev_kfree_skb_any(np->get_tx_ctx->skb);
 				np->get_tx_ctx->skb = NULL;
 				tx_work++;
@@ -2401,6 +2411,9 @@ static int nv_tx_done(struct net_device *dev, int limit)
 		if (unlikely(np->get_tx_ctx++ == np->last_tx_ctx))
 			np->get_tx_ctx = np->first_tx_ctx;
 	}
+
+	netdev_completed_queue(np->dev, tx_work, bytes_compl);
+
 	if (unlikely((np->tx_stop == 1) && (np->get_tx.orig != orig_get_tx))) {
 		np->tx_stop = 0;
 		netif_wake_queue(dev);
@@ -2414,6 +2427,7 @@ static int nv_tx_done_optimized(struct net_device *dev, int limit)
 	u32 flags;
 	int tx_work = 0;
 	struct ring_desc_ex *orig_get_tx = np->get_tx.ex;
+	unsigned long bytes_cleaned = 0;
 
 	while ((np->get_tx.ex != np->put_tx.ex) &&
 	       !((flags = le32_to_cpu(np->get_tx.ex->flaglen)) & NV_TX2_VALID) &&
@@ -2431,6 +2445,7 @@ static int nv_tx_done_optimized(struct net_device *dev, int limit)
 				}
 			}
 
+			bytes_cleaned += np->get_tx_ctx->skb->len;
 			dev_kfree_skb_any(np->get_tx_ctx->skb);
 			np->get_tx_ctx->skb = NULL;
 			tx_work++;
@@ -2438,6 +2453,9 @@ static int nv_tx_done_optimized(struct net_device *dev, int limit)
 			if (np->tx_limit)
 				nv_tx_flip_ownership(dev);
 		}
+
+		netdev_completed_queue(np->dev, tx_work, bytes_cleaned);
+
 		if (unlikely(np->get_tx.ex++ == np->last_tx.ex))
 			np->get_tx.ex = np->first_tx.ex;
 		if (unlikely(np->get_tx_ctx++ == np->last_tx_ctx))
-- 
1.7.3.1
