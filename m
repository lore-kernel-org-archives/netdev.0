From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH update] firewire: net: throttle TX queue before running out of
 tlabels
Date: Sat, 13 Nov 2010 13:16:42 +0100 (CET)
Message-ID: <tkrat.eaac597cf54bb660@s5r6.in-berlin.de>
References: <tkrat.036c5d10fb83f85d@s5r6.in-berlin.de>
 <tkrat.39c164e4c52e2fc8@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:39822 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754499Ab0KMMRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Nov 2010 07:17:04 -0500
In-Reply-To: <tkrat.39c164e4c52e2fc8@s5r6.in-berlin.de>
Content-Disposition: INLINE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This prevents firewire-net from submitting write requests in fast
succession until failure due to all 64 transaction labels used up for
unfinished split transactions.  The netif_stop/wake_queue API is used
for this purpose.

Without this stop/wake mechanism, datagrams were simply lost whenever
the tlabel pool was exhausted.  Plus, tlabel exhaustion by firewire-net
also prevented other unrelated outbound transactions to be initiated.

The high watermark is set to considerably less than 64 (I chose 8)
because peers which run current Linux firewire-ohci are still easily
saturated by this (i.e. some datagrams are dropped with ack-busy-*
events), depending on the hardware at transmitter and receiver side.

I did not see changes to resulting throughput that were discernible from
the usual measuring noise.  To do:  Revisit the choice of queue depth
once firewire-ohci's AR DMA was improved.

I wonder what a good net_device.tx_queue_len value is.  I just set it
to the same value as the chosen watermark for now.

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
Update:  Stricter version with an early NETDEV_TX_BUSY return if the
.ndo_start_xmit method is called while the driver is stopping (or has
stopped) the transmit queue.  Thus there can really be never more than
FWNET_MAX_QUEUED_DATAGRAMS of pending outbound 1394 transactions.

 drivers/firewire/net.c |   53 ++++++++++++++++++++++++++++++-----------
 1 file changed, 39 insertions(+), 14 deletions(-)

Index: b/drivers/firewire/net.c
===================================================================
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -28,8 +28,15 @@
 #include <asm/unaligned.h>
 #include <net/arp.h>
 
-#define FWNET_MAX_FRAGMENTS	25	/* arbitrary limit */
-#define FWNET_ISO_PAGE_COUNT	(PAGE_SIZE < 16 * 1024 ? 4 : 2)
+/* rx limits */
+#define FWNET_MAX_FRAGMENTS		25 /* arbitrary limit */
+#define FWNET_ISO_PAGE_COUNT		(PAGE_SIZE < 16*1024 ? 4 : 2)
+
+/* tx limits */
+#define FWNET_MAX_QUEUED_DATAGRAMS	8 /* should keep AT DMA busy enough */
+#define FWNET_MIN_QUEUED_DATAGRAMS	2
+#define FWNET_TX_QUEUE_STOPPED		FWNET_MAX_QUEUED_DATAGRAMS
+#define FWNET_TX_QUEUE_LEN		FWNET_MAX_QUEUED_DATAGRAMS /* ? */
 
 #define IEEE1394_BROADCAST_CHANNEL	31
 #define IEEE1394_ALL_NODES		(0xffc0 | 0x003f)
@@ -892,6 +899,16 @@ static void fwnet_free_ptask(struct fwne
 	kmem_cache_free(fwnet_packet_task_cache, ptask);
 }
 
+/* Caller must hold dev->lock. */
+static void dec_queued_datagrams(struct fwnet_device *dev)
+{
+	if (--dev->queued_datagrams ==
+			FWNET_MIN_QUEUED_DATAGRAMS + FWNET_TX_QUEUE_STOPPED) {
+		dev->queued_datagrams -= FWNET_TX_QUEUE_STOPPED;
+		netif_wake_queue(dev->netdev);
+	}
+}
+
 static int fwnet_send_packet(struct fwnet_packet_task *ptask);
 
 static void fwnet_transmit_packet_done(struct fwnet_packet_task *ptask)
@@ -908,7 +925,7 @@ static void fwnet_transmit_packet_done(s
 	/* Check whether we or the networking TX soft-IRQ is last user. */
 	free = (ptask->outstanding_pkts == 0 && ptask->enqueued);
 	if (free)
-		dev->queued_datagrams--;
+		dec_queued_datagrams(dev);
 
 	if (ptask->outstanding_pkts == 0) {
 		dev->netdev->stats.tx_packets++;
@@ -979,7 +996,7 @@ static void fwnet_transmit_packet_failed
 	/* Check whether we or the networking TX soft-IRQ is last user. */
 	free = ptask->enqueued;
 	if (free)
-		dev->queued_datagrams--;
+		dec_queued_datagrams(dev);
 
 	dev->netdev->stats.tx_dropped++;
 	dev->netdev->stats.tx_errors++;
@@ -1064,7 +1081,7 @@ static int fwnet_send_packet(struct fwne
 		if (!free)
 			ptask->enqueued = true;
 		else
-			dev->queued_datagrams--;
+			dec_queued_datagrams(dev);
 
 		spin_unlock_irqrestore(&dev->lock, flags);
 
@@ -1083,7 +1100,7 @@ static int fwnet_send_packet(struct fwne
 	if (!free)
 		ptask->enqueued = true;
 	else
-		dev->queued_datagrams--;
+		dec_queued_datagrams(dev);
 
 	spin_unlock_irqrestore(&dev->lock, flags);
 
@@ -1249,6 +1266,14 @@ static netdev_tx_t fwnet_tx(struct sk_bu
 	struct fwnet_peer *peer;
 	unsigned long flags;
 
+	spin_lock_irqsave(&dev->lock, flags);
+
+	if (dev->queued_datagrams > FWNET_MAX_QUEUED_DATAGRAMS) {
+		spin_unlock_irqrestore(&dev->lock, flags);
+
+		return NETDEV_TX_BUSY;
+	}
+
 	ptask = kmem_cache_alloc(fwnet_packet_task_cache, GFP_ATOMIC);
 	if (ptask == NULL)
 		goto fail;
@@ -1267,9 +1292,6 @@ static netdev_tx_t fwnet_tx(struct sk_bu
 	proto = hdr_buf.h_proto;
 	dg_size = skb->len;
 
-	/* serialize access to peer, including peer->datagram_label */
-	spin_lock_irqsave(&dev->lock, flags);
-
 	/*
 	 * Set the transmission type for the packet.  ARP packets and IP
 	 * broadcast packets are sent via GASP.
@@ -1291,7 +1313,7 @@ static netdev_tx_t fwnet_tx(struct sk_bu
 
 		peer = fwnet_peer_find_by_guid(dev, be64_to_cpu(guid));
 		if (!peer || peer->fifo == FWNET_NO_FIFO_ADDR)
-			goto fail_unlock;
+			goto fail;
 
 		generation         = peer->generation;
 		dest_node          = peer->node_id;
@@ -1345,7 +1367,10 @@ static netdev_tx_t fwnet_tx(struct sk_bu
 		max_payload += RFC2374_FRAG_HDR_SIZE;
 	}
 
-	dev->queued_datagrams++;
+	if (++dev->queued_datagrams == FWNET_MAX_QUEUED_DATAGRAMS) {
+		dev->queued_datagrams += FWNET_TX_QUEUE_STOPPED;
+		netif_stop_queue(dev->netdev);
+	}
 
 	spin_unlock_irqrestore(&dev->lock, flags);
 
@@ -1356,9 +1381,9 @@ static netdev_tx_t fwnet_tx(struct sk_bu
 
 	return NETDEV_TX_OK;
 
- fail_unlock:
-	spin_unlock_irqrestore(&dev->lock, flags);
  fail:
+	spin_unlock_irqrestore(&dev->lock, flags);
+
 	if (ptask)
 		kmem_cache_free(fwnet_packet_task_cache, ptask);
 
@@ -1415,7 +1440,7 @@ static void fwnet_init_dev(struct net_de
 	net->addr_len		= FWNET_ALEN;
 	net->hard_header_len	= FWNET_HLEN;
 	net->type		= ARPHRD_IEEE1394;
-	net->tx_queue_len	= 10;
+	net->tx_queue_len	= FWNET_TX_QUEUE_LEN;
 	SET_ETHTOOL_OPS(net, &fwnet_ethtool_ops);
 }
 

-- 
Stefan Richter
-=====-==-=- =-== -==-=
http://arcgraph.de/sr/

