From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH] forcedeth: tx timeout fix
Date: Sat, 25 Apr 2009 15:17:56 -0400
Message-ID: <49F361E4.4050605@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040606060903070102000204"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:4605 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169AbZDZA6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2009 20:58:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040606060903070102000204
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes the tx_timeout() to properly handle the clean up of the 
tx ring. It also sets the tx put pointer back to the correct position to 
be in sync with HW.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>




--------------040606060903070102000204
Content-Type: text/plain;
 name="patch-forcedeth-tx-timeout"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-tx-timeout"

--- old/drivers/net/forcedeth.c	2009-04-25 15:07:31.000000000 -0400
+++ new/drivers/net/forcedeth.c	2009-04-25 15:10:34.000000000 -0400
@@ -1880,6 +1880,7 @@
 	np->tx_pkts_in_progress = 0;
 	np->tx_change_owner = NULL;
 	np->tx_end_flip = NULL;
+	np->tx_stop = 0;
 
 	for (i = 0; i < np->tx_ring_size; i++) {
 		if (!nv_optimized(np)) {
@@ -2530,6 +2531,8 @@
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	u32 status;
+	union ring_type put_tx;
+	int saved_tx_limit;
 
 	if (np->msi_flags & NV_MSI_X_ENABLED)
 		status = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQSTAT_MASK;
@@ -2589,24 +2592,32 @@
 	/* 1) stop tx engine */
 	nv_stop_tx(dev);
 
-	/* 2) check that the packets were not sent already: */
+	/* 2) complete any outstanding tx and do not give HW any limited tx pkts */
+	saved_tx_limit = np->tx_limit;
+	np->tx_limit = 0; /* prevent giving HW any limited pkts */
+	np->tx_stop = 0;  /* prevent waking tx queue */
 	if (!nv_optimized(np))
 		nv_tx_done(dev, np->tx_ring_size);
 	else
 		nv_tx_done_optimized(dev, np->tx_ring_size);
 
-	/* 3) if there are dead entries: clear everything */
-	if (np->get_tx_ctx != np->put_tx_ctx) {
-		printk(KERN_DEBUG "%s: tx_timeout: dead entries!\n", dev->name);
-		nv_drain_tx(dev);
-		nv_init_tx(dev);
-		setup_hw_rings(dev, NV_SETUP_TX_RING);
-	}
+	/* save current HW postion */
+	if (np->tx_change_owner)
+		put_tx.ex = np->tx_change_owner->first_tx_desc;
+	else
+		put_tx = np->put_tx;
 
-	netif_wake_queue(dev);
+	/* 3) clear all tx state */
+	nv_drain_tx(dev);
+	nv_init_tx(dev);
+
+	/* 4) restore state to current HW position */
+	np->get_tx = np->put_tx = put_tx;
+	np->tx_limit = saved_tx_limit;
 
-	/* 4) restart tx engine */
+	/* 5) restart tx engine */
 	nv_start_tx(dev);
+	netif_wake_queue(dev);
 	spin_unlock_irq(&np->lock);
 }
 

--------------040606060903070102000204--
