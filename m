From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 6/13] forcedeth: add/modify tx done with limit
Date: Thu, 05 Mar 2009 13:02:10 -0500
Message-ID: <49B013A2.8030806@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030602030902030603040704"
To: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:8366 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753210AbZCEVBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 16:01:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030602030902030603040704
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

There are two tx_done routines to handle tx completion processing. Both 
these functions now take in a limit value and return the amount of tx 
completions. This will be used by a future patch to determine the total 
amount of work done.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------030602030902030603040704
Content-Type: text/plain;
 name="patch-forcedeth-tx-done-limit"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-tx-done-limit"

--- old/drivers/net/forcedeth.c	2009-03-05 10:41:12.000000000 -0800
+++ new/drivers/net/forcedeth.c	2009-03-05 10:41:29.000000000 -0800
@@ -2397,14 +2397,16 @@
  *
  * Caller must own np->lock.
  */
-static void nv_tx_done(struct net_device *dev)
+static int nv_tx_done(struct net_device *dev, int limit)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u32 flags;
+	int tx_work = 0;
 	struct ring_desc* orig_get_tx = np->get_tx.orig;
 
 	while ((np->get_tx.orig != np->put_tx.orig) &&
-	       !((flags = le32_to_cpu(np->get_tx.orig->flaglen)) & NV_TX_VALID)) {
+	       !((flags = le32_to_cpu(np->get_tx.orig->flaglen)) & NV_TX_VALID) &&
+	       (tx_work < limit)) {
 
 		dprintk(KERN_DEBUG "%s: nv_tx_done: flags 0x%x.\n",
 					dev->name, flags);
@@ -2430,6 +2432,7 @@
 				}
 				dev_kfree_skb_any(np->get_tx_ctx->skb);
 				np->get_tx_ctx->skb = NULL;
+				tx_work++;
 			}
 		} else {
 			if (flags & NV_TX2_LASTPACKET) {
@@ -2447,6 +2450,7 @@
 				}
 				dev_kfree_skb_any(np->get_tx_ctx->skb);
 				np->get_tx_ctx->skb = NULL;
+				tx_work++;
 			}
 		}
 		if (unlikely(np->get_tx.orig++ == np->last_tx.orig))
@@ -2458,17 +2462,19 @@
 		np->tx_stop = 0;
 		netif_wake_queue(dev);
 	}
+	return tx_work;
 }
 
-static void nv_tx_done_optimized(struct net_device *dev, int limit)
+static int nv_tx_done_optimized(struct net_device *dev, int limit)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u32 flags;
+	int tx_work = 0;
 	struct ring_desc_ex* orig_get_tx = np->get_tx.ex;
 
 	while ((np->get_tx.ex != np->put_tx.ex) &&
 	       !((flags = le32_to_cpu(np->get_tx.ex->flaglen)) & NV_TX_VALID) &&
-	       (limit-- > 0)) {
+	       (tx_work < limit)) {
 
 		dprintk(KERN_DEBUG "%s: nv_tx_done_optimized: flags 0x%x.\n",
 					dev->name, flags);
@@ -2492,6 +2498,7 @@
 
 			dev_kfree_skb_any(np->get_tx_ctx->skb);
 			np->get_tx_ctx->skb = NULL;
+			tx_work++;
 
 			if (np->tx_limit) {
 				nv_tx_flip_ownership(dev);
@@ -2506,6 +2513,7 @@
 		np->tx_stop = 0;
 		netif_wake_queue(dev);
 	}
+	return tx_work;
 }
 
 /*
@@ -2578,7 +2586,7 @@
 
 	/* 2) check that the packets were not sent already: */
 	if (!nv_optimized(np))
-		nv_tx_done(dev);
+		nv_tx_done(dev, np->tx_ring_size);
 	else
 		nv_tx_done_optimized(dev, np->tx_ring_size);
 
@@ -3433,7 +3441,7 @@
 		nv_msi_workaround(np);
 
 		spin_lock(&np->lock);
-		nv_tx_done(dev);
+		nv_tx_done(dev, np->tx_ring_size);
 		spin_unlock(&np->lock);
 
 #ifdef CONFIG_FORCEDETH_NAPI

--------------030602030902030603040704--
