From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 10/12] forcedeth: tx max work
Date: Tue, 09 Jan 2007 13:30:27 -0500
Message-ID: <45A3DF43.8030301@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090108010106080109080900"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate02.nvidia.com ([216.228.112.143]:1879 "EHLO
	HQEMGATE02.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932400AbXAIVXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 16:23:24 -0500
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090108010106080109080900
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds a limit to how much tx work can be done in each 
iteration of tx processing.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------090108010106080109080900
Content-Type: text/plain;
 name="patch-tx-loop-limit"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-tx-loop-limit"

--- orig/drivers/net/forcedeth.c	2007-01-08 20:34:35.000000000 -0500
+++ new/drivers/net/forcedeth.c	2007-01-08 20:35:22.000000000 -0500
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

--------------090108010106080109080900--
