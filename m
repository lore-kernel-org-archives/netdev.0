From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH 2/4] firewire: net: fix memory leaks
Date: Sun, 7 Nov 2010 22:40:03 +0100 (CET)
Message-ID: <tkrat.d3b1585b222c0bb6@s5r6.in-berlin.de>
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

a) fwnet_transmit_packet_done used to poison ptask->pt_link by list_del.
If fwnet_send_packet checked later whether it was responsible to clean
up (in the border case that the TX soft IRQ was outpaced by the AT-req
tasklet on another CPU), it missed this because ptask->pt_link was no
longer shown as empty.

b) If fwnet_write_complete got an rcode other than RCODE_COMPLETE, we
missed to free the skb and ptask entirely.

Also, count stats.tx_dropped and stats.tx_errors when rcode != 0.

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
 drivers/firewire/net.c |   35 +++++++++++++++++++++++++++++++----
 1 file changed, 31 insertions(+), 4 deletions(-)

Index: b/drivers/firewire/net.c
===================================================================
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -917,9 +917,10 @@ static void fwnet_transmit_packet_done(s
 
 	/* Check whether we or the networking TX soft-IRQ is last user. */
 	free = (ptask->outstanding_pkts == 0 && !list_empty(&ptask->pt_link));
+	if (free)
+		list_del(&ptask->pt_link);
 
 	if (ptask->outstanding_pkts == 0) {
-		list_del(&ptask->pt_link);
 		dev->netdev->stats.tx_packets++;
 		dev->netdev->stats.tx_bytes += skb->len;
 	}
@@ -974,6 +975,31 @@ static void fwnet_transmit_packet_done(s
 		fwnet_free_ptask(ptask);
 }
 
+static void fwnet_transmit_packet_failed(struct fwnet_packet_task *ptask)
+{
+	struct fwnet_device *dev = ptask->dev;
+	unsigned long flags;
+	bool free;
+
+	spin_lock_irqsave(&dev->lock, flags);
+
+	/* One fragment failed; don't try to send remaining fragments. */
+	ptask->outstanding_pkts = 0;
+
+	/* Check whether we or the networking TX soft-IRQ is last user. */
+	free = !list_empty(&ptask->pt_link);
+	if (free)
+		list_del(&ptask->pt_link);
+
+	dev->netdev->stats.tx_dropped++;
+	dev->netdev->stats.tx_errors++;
+
+	spin_unlock_irqrestore(&dev->lock, flags);
+
+	if (free)
+		fwnet_free_ptask(ptask);
+}
+
 static void fwnet_write_complete(struct fw_card *card, int rcode,
 				 void *payload, size_t length, void *data)
 {
@@ -981,11 +1007,12 @@ static void fwnet_write_complete(struct 
 
 	ptask = data;
 
-	if (rcode == RCODE_COMPLETE)
+	if (rcode == RCODE_COMPLETE) {
 		fwnet_transmit_packet_done(ptask);
-	else
+	} else {
 		fw_error("fwnet_write_complete: failed: %x\n", rcode);
-		/* ??? error recovery */
+		fwnet_transmit_packet_failed(ptask);
+	}
 }
 
 static int fwnet_send_packet(struct fwnet_packet_task *ptask)

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
