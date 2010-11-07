From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH 4/4] firewire: net: throttle TX queue before running out of
	tlabels
Date: Sun, 7 Nov 2010 22:41:21 +0100 (CET)
Message-ID: <tkrat.39c164e4c52e2fc8@s5r6.in-berlin.de>
References: <tkrat.036c5d10fb83f85d@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux1394-devel@lists.sourceforge.net
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <tkrat.036c5d10fb83f85d@s5r6.in-berlin.de>
Content-Disposition: INLINE
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This prevents firewire-net from submitting write requests in fast
succession until failure due to all 64 transaction labels used up for
unfinished split transactions.  The netif_stop/wake_queue API is used
for this purpose.

The high watermark is set to considerably less than 64 (I chose 8) in
order to put less pressure on to responder peers.  Still, responders
which run Linux firewire-net still need to improved to keep up with
even this small amount of outstanding split transactions.  (This is
considering the case of only one responder at a time, or a primary
responder, because this is the most likely case with IP over 1394.)

This is based on the count of unfinished TX datagrams.  Maybe it should
rather be based on the count of unfinished TX fragments?  Many 1394a
CardBus cards accept only 1024k sized packets, i.e. require two fragments
per datagram at the standard MTU of 1500.  However, the chosen watermark
is still well below the maximum number of tlabels.

Without this stop/wake mechanism, datagrams were simply lost whenever
the tlabel pool was exhausted.

I wonder what a good net_device.tx_queue_len value is.  I just set it
to the same value as the chosen watermark for now.  Note that the net
scheduler still lets us exceed the high watermark occasionally.  This
could be prevented by an earlier queued_datagrams check in fwnet_tx with
a NETDEV_TX_BUSY return but such an early check did not actually
improve performance in my testing, i.e. did not reduce busy responder
situations.

Results:
  - I did not see changes to resulting throughput that were discernible
    from the usual measuring noise.
  - With this change, other requesters on the same node now have a
    chance to get spare transaction labels while firewire-net is
    transmitting.

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
 drivers/firewire/net.c |   36 ++++++++++++++++++++++++++++--------
 1 file changed, 28 insertions(+), 8 deletions(-)

Index: b/drivers/firewire/net.c
===================================================================
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -28,8 +28,14 @@
 #include <asm/unaligned.h>
 #include <net/arp.h>
 
-#define FWNET_MAX_FRAGMENTS	25	/* arbitrary limit */
-#define FWNET_ISO_PAGE_COUNT	(PAGE_SIZE < 16 * 1024 ? 4 : 2)
+/* rx limits */
+#define FWNET_MAX_FRAGMENTS		25 /* arbitrary limit */
+#define FWNET_ISO_PAGE_COUNT		(PAGE_SIZE < 16 * 1024 ? 4 : 2)
+
+/* tx limits */
+#define FWNET_TX_QUEUE_LEN		8 /* ? */
+#define FWNET_MAX_QUEUED_DATAGRAMS	8 /* should keep AT DMA busy enough */
+#define FWNET_MIN_QUEUED_DATAGRAMS	2
 
 #define IEEE1394_BROADCAST_CHANNEL	31
 #define IEEE1394_ALL_NODES		(0xffc0 | 0x003f)
@@ -892,6 +898,20 @@ static void fwnet_free_ptask(struct fwne
 	kmem_cache_free(fwnet_packet_task_cache, ptask);
 }
 
+/* caller must hold dev->lock */
+static void inc_queued_datagrams(struct fwnet_device *dev)
+{
+	if (++dev->queued_datagrams >= FWNET_MAX_QUEUED_DATAGRAMS)
+		netif_stop_queue(dev->netdev);
+}
+
+/* caller must hold dev->lock */
+static void dec_queued_datagrams(struct fwnet_device *dev)
+{
+	if (--dev->queued_datagrams == FWNET_MIN_QUEUED_DATAGRAMS)
+		netif_wake_queue(dev->netdev);
+}
+
 static int fwnet_send_packet(struct fwnet_packet_task *ptask);
 
 static void fwnet_transmit_packet_done(struct fwnet_packet_task *ptask)
@@ -908,7 +928,7 @@ static void fwnet_transmit_packet_done(s
 	/* Check whether we or the networking TX soft-IRQ is last user. */
 	free = (ptask->outstanding_pkts == 0 && ptask->enqueued);
 	if (free)
-		dev->queued_datagrams--;
+		dec_queued_datagrams(dev);
 
 	if (ptask->outstanding_pkts == 0) {
 		dev->netdev->stats.tx_packets++;
@@ -979,7 +999,7 @@ static void fwnet_transmit_packet_failed
 	/* Check whether we or the networking TX soft-IRQ is last user. */
 	free = ptask->enqueued;
 	if (free)
-		dev->queued_datagrams--;
+		dec_queued_datagrams(dev);
 
 	dev->netdev->stats.tx_dropped++;
 	dev->netdev->stats.tx_errors++;
@@ -1064,7 +1084,7 @@ static int fwnet_send_packet(struct fwne
 		if (!free)
 			ptask->enqueued = true;
 		else
-			dev->queued_datagrams--;
+			dec_queued_datagrams(dev);
 
 		spin_unlock_irqrestore(&dev->lock, flags);
 
@@ -1083,7 +1103,7 @@ static int fwnet_send_packet(struct fwne
 	if (!free)
 		ptask->enqueued = true;
 	else
-		dev->queued_datagrams--;
+		dec_queued_datagrams(dev);
 
 	spin_unlock_irqrestore(&dev->lock, flags);
 
@@ -1345,7 +1365,7 @@ static netdev_tx_t fwnet_tx(struct sk_bu
 		max_payload += RFC2374_FRAG_HDR_SIZE;
 	}
 
-	dev->queued_datagrams++;
+	inc_queued_datagrams(dev);
 
 	spin_unlock_irqrestore(&dev->lock, flags);
 
@@ -1415,7 +1435,7 @@ static void fwnet_init_dev(struct net_de
 	net->addr_len		= FWNET_ALEN;
 	net->hard_header_len	= FWNET_HLEN;
 	net->type		= ARPHRD_IEEE1394;
-	net->tx_queue_len	= 10;
+	net->tx_queue_len	= FWNET_TX_QUEUE_LEN;
 	SET_ETHTOOL_OPS(net, &fwnet_ethtool_ops);
 }
 

-- 
Stefan Richter
-=====-==-=- =-== --===
http://arcgraph.de/sr/


------------------------------------------------------------------------------
The Next 800 Companies to Lead America's Growth: New Video Whitepaper
David G. Thomson, author of the best-selling book "Blueprint to a 
Billion" shares his insights and actions to help propel your 
business during the next growth cycle. Listen Now!
http://p.sf.net/sfu/SAP-dev2dev
