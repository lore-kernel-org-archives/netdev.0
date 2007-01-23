From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 10/12] forcedeth: tx max work
Date: Tue, 23 Jan 2007 12:00:56 -0500
Message-ID: <45B63F48.10607@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020704010500040500000801"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate02.nvidia.com ([216.228.112.143]:1274 "EHLO
	HQEMGATE02.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933104AbXAWWfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 17:35:15 -0500
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020704010500040500000801
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds a limit to how much tx work can be done in each
iteration of tx processing. If the max limit is reached, remaining tx 
completions will be handled by timer interrupt.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------020704010500040500000801
Content-Type: text/plain;
 name="patch-tx-loop-limit"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-tx-loop-limit"

--- orig/drivers/net/forcedeth.c	2007-01-19 11:13:59.000000000 -0500
+++ new/drivers/net/forcedeth.c	2007-01-21 17:33:02.000000000 -0500
@@ -210,7 +210,7 @@
  * NVREG_POLL_DEFAULT=97 would result in an interval length of 1 ms
  */
 	NvRegPollingInterval = 0x00c,
-#define NVREG_POLL_DEFAULT_THROUGHPUT	970
+#define NVREG_POLL_DEFAULT_THROUGHPUT	970 /* backup tx cleanup if loop max reached */
 #define NVREG_POLL_DEFAULT_CPU	13
 	NvRegMSIMap0 = 0x020,
 	NvRegMSIMap1 = 0x024,
@@ -1859,14 +1859,15 @@
 	}
 }
 
-static void nv_tx_done_optimized(struct net_device *dev)
+static void nv_tx_done_optimized(struct net_device *dev, int limit)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u32 flags;
 	struct ring_desc_ex* orig_get_tx = np->get_tx.ex;
 
 	while ((np->get_tx.ex != np->put_tx.ex) &&
-	       !((flags = le32_to_cpu(np->get_tx.ex->flaglen)) & NV_TX_VALID)) {
+	       !((flags = le32_to_cpu(np->get_tx.ex->flaglen)) & NV_TX_VALID) &&
+	       (limit-- > 0)) {
 
 		dprintk(KERN_DEBUG "%s: nv_tx_done_optimized: flags 0x%x.\n",
 					dev->name, flags);
@@ -1973,7 +1974,7 @@
 	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
 		nv_tx_done(dev);
 	else
-		nv_tx_done_optimized(dev);
+		nv_tx_done_optimized(dev, np->tx_ring_size);
 
 	/* 3) if there are dead entries: clear everything */
 	if (np->get_tx_ctx != np->put_tx_ctx) {
@@ -2899,7 +2900,7 @@
 			break;
 
 		spin_lock(&np->lock);
-		nv_tx_done_optimized(dev);
+		nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
 		spin_unlock(&np->lock);
 
 #ifdef CONFIG_FORCEDETH_NAPI
@@ -3006,7 +3007,7 @@
 			break;
 
 		spin_lock_irqsave(&np->lock, flags);
-		nv_tx_done_optimized(dev);
+		nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
 		spin_unlock_irqrestore(&np->lock, flags);
 
 		if (unlikely(events & (NVREG_IRQ_TX_ERR))) {
@@ -3163,6 +3164,11 @@
 		if (!(events & np->irqmask))
 			break;
 
+		/* check tx in case we reached max loop limit in tx isr */
+		spin_lock_irqsave(&np->lock, flags);
+		nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
+		spin_unlock_irqrestore(&np->lock, flags);
+
 		if (events & NVREG_IRQ_LINK) {
 			spin_lock_irqsave(&np->lock, flags);
 			nv_link_irq(dev);

--------------020704010500040500000801--
