From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH 3/4] firewire: net: replace lists by counters
Date: Sun, 7 Nov 2010 22:40:38 +0100 (CET)
Message-ID: <tkrat.4d02be0f9a3ae740@s5r6.in-berlin.de>
References: <tkrat.036c5d10fb83f85d@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: linux1394-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <tkrat.036c5d10fb83f85d@s5r6.in-berlin.de>
Content-Disposition: INLINE
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current transmit code does not at all make use of
  - fwnet_device.packet_list
and only very limited use of
  - fwnet_device.broadcasted_list,
  - fwnet_device.queued_packets.
Their current function is to track whether the TX soft-IRQ finished
dealing with an skb when the AT-req tasklet takes over, and to discard
pending tx datagrams (if there are any) when the local node is removed.

The latter does actually contain a race condition bug with TX soft-IRQ
and AT-req tasklet.

Instead of these lists and the corresponding link in fwnet_packet_task,
  - a flag in fwnet_packet_task to track whether fwnet_tx is done,
  - a counter of queued datagrams in fwnet_device
do the job as well.

The above mentioned theoretic race condition is resolved by letting
fwnet_remove sleep until all datagrams were flushed.  It may sleep
almost arbitrarily long since fwnet_remove is executed in the context of
a multithreaded (concurrency managed) workqueue.

The type of max_payload is changed to u16 here to avoid waste in struct
fwnet_packet_task.  This value cannot exceed 4096 per IEEE 1394:2008
table 16-18 (or 32678 per specification of packet headers, if there is
ever going to be something else than beta mode).

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
 drivers/firewire/net.c |   73 +++++++++++++++--------------------------
 1 file changed, 26 insertions(+), 47 deletions(-)

Index: b/drivers/firewire/net.c
===================================================================
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -7,6 +7,7 @@
  */
 
 #include <linux/bug.h>
+#include <linux/delay.h>
 #include <linux/device.h>
 #include <linux/ethtool.h>
 #include <linux/firewire.h>
@@ -170,15 +171,8 @@ struct fwnet_device {
 	struct fw_address_handler handler;
 	u64 local_fifo;
 
-	/* List of packets to be sent */
-	struct list_head packet_list;
-	/*
-	 * List of packets that were broadcasted.  When we get an ISO interrupt
-	 * one of them has been sent
-	 */
-	struct list_head broadcasted_list;
-	/* List of packets that have been sent but not yet acked */
-	struct list_head sent_list;
+	/* Number of tx datagrams that have been queued but not yet acked */
+	int queued_datagrams;
 
 	struct list_head peer_list;
 	struct fw_card *card;
@@ -196,7 +190,7 @@ struct fwnet_peer {
 	unsigned pdg_size;        /* pd_list size */
 
 	u16 datagram_label;       /* outgoing datagram label */
-	unsigned max_payload;     /* includes RFC2374_FRAG_HDR_SIZE overhead */
+	u16 max_payload;          /* includes RFC2374_FRAG_HDR_SIZE overhead */
 	int node_id;
 	int generation;
 	unsigned speed;
@@ -204,22 +198,18 @@ struct fwnet_peer {
 
 /* This is our task struct. It's used for the packet complete callback.  */
 struct fwnet_packet_task {
-	/*
-	 * ptask can actually be on dev->packet_list, dev->broadcasted_list,
-	 * or dev->sent_list depending on its current state.
-	 */
-	struct list_head pt_link;
 	struct fw_transaction transaction;
 	struct rfc2734_header hdr;
 	struct sk_buff *skb;
 	struct fwnet_device *dev;
 
 	int outstanding_pkts;
-	unsigned max_payload;
 	u64 fifo_addr;
 	u16 dest_node;
+	u16 max_payload;
 	u8 generation;
 	u8 speed;
+	u8 enqueued;
 };
 
 /*
@@ -916,9 +906,9 @@ static void fwnet_transmit_packet_done(s
 	ptask->outstanding_pkts--;
 
 	/* Check whether we or the networking TX soft-IRQ is last user. */
-	free = (ptask->outstanding_pkts == 0 && !list_empty(&ptask->pt_link));
+	free = (ptask->outstanding_pkts == 0 && ptask->enqueued);
 	if (free)
-		list_del(&ptask->pt_link);
+		dev->queued_datagrams--;
 
 	if (ptask->outstanding_pkts == 0) {
 		dev->netdev->stats.tx_packets++;
@@ -987,9 +977,9 @@ static void fwnet_transmit_packet_failed
 	ptask->outstanding_pkts = 0;
 
 	/* Check whether we or the networking TX soft-IRQ is last user. */
-	free = !list_empty(&ptask->pt_link);
+	free = ptask->enqueued;
 	if (free)
-		list_del(&ptask->pt_link);
+		dev->queued_datagrams--;
 
 	dev->netdev->stats.tx_dropped++;
 	dev->netdev->stats.tx_errors++;
@@ -1070,9 +1060,11 @@ static int fwnet_send_packet(struct fwne
 		spin_lock_irqsave(&dev->lock, flags);
 
 		/* If the AT tasklet already ran, we may be last user. */
-		free = (ptask->outstanding_pkts == 0 && list_empty(&ptask->pt_link));
+		free = (ptask->outstanding_pkts == 0 && !ptask->enqueued);
 		if (!free)
-			list_add_tail(&ptask->pt_link, &dev->broadcasted_list);
+			ptask->enqueued = true;
+		else
+			dev->queued_datagrams--;
 
 		spin_unlock_irqrestore(&dev->lock, flags);
 
@@ -1087,9 +1079,11 @@ static int fwnet_send_packet(struct fwne
 	spin_lock_irqsave(&dev->lock, flags);
 
 	/* If the AT tasklet already ran, we may be last user. */
-	free = (ptask->outstanding_pkts == 0 && list_empty(&ptask->pt_link));
+	free = (ptask->outstanding_pkts == 0 && !ptask->enqueued);
 	if (!free)
-		list_add_tail(&ptask->pt_link, &dev->sent_list);
+		ptask->enqueued = true;
+	else
+		dev->queued_datagrams--;
 
 	spin_unlock_irqrestore(&dev->lock, flags);
 
@@ -1351,10 +1345,12 @@ static netdev_tx_t fwnet_tx(struct sk_bu
 		max_payload += RFC2374_FRAG_HDR_SIZE;
 	}
 
+	dev->queued_datagrams++;
+
 	spin_unlock_irqrestore(&dev->lock, flags);
 
 	ptask->max_payload = max_payload;
-	INIT_LIST_HEAD(&ptask->pt_link);
+	ptask->enqueued    = 0;
 
 	fwnet_send_packet(ptask);
 
@@ -1500,14 +1496,9 @@ static int fwnet_probe(struct device *_d
 	dev->broadcast_rcv_context = NULL;
 	dev->broadcast_xmt_max_payload = 0;
 	dev->broadcast_xmt_datagramlabel = 0;
-
 	dev->local_fifo = FWNET_NO_FIFO_ADDR;
-
-	INIT_LIST_HEAD(&dev->packet_list);
-	INIT_LIST_HEAD(&dev->broadcasted_list);
-	INIT_LIST_HEAD(&dev->sent_list);
+	dev->queued_datagrams = 0;
 	INIT_LIST_HEAD(&dev->peer_list);
-
 	dev->card = card;
 	dev->netdev = net;
 
@@ -1565,7 +1556,7 @@ static int fwnet_remove(struct device *_
 	struct fwnet_peer *peer = dev_get_drvdata(_dev);
 	struct fwnet_device *dev = peer->dev;
 	struct net_device *net;
-	struct fwnet_packet_task *ptask, *pt_next;
+	int i;
 
 	mutex_lock(&fwnet_device_mutex);
 
@@ -1583,21 +1574,9 @@ static int fwnet_remove(struct device *_
 					      dev->card);
 			fw_iso_context_destroy(dev->broadcast_rcv_context);
 		}
-		list_for_each_entry_safe(ptask, pt_next,
-					 &dev->packet_list, pt_link) {
-			dev_kfree_skb_any(ptask->skb);
-			kmem_cache_free(fwnet_packet_task_cache, ptask);
-		}
-		list_for_each_entry_safe(ptask, pt_next,
-					 &dev->broadcasted_list, pt_link) {
-			dev_kfree_skb_any(ptask->skb);
-			kmem_cache_free(fwnet_packet_task_cache, ptask);
-		}
-		list_for_each_entry_safe(ptask, pt_next,
-					 &dev->sent_list, pt_link) {
-			dev_kfree_skb_any(ptask->skb);
-			kmem_cache_free(fwnet_packet_task_cache, ptask);
-		}
+		for (i = 0; dev->queued_datagrams && i < 5; i++)
+			ssleep(1);
+		WARN_ON(dev->queued_datagrams);
 		list_del(&dev->dev_link);
 
 		free_netdev(net);

-- 
Stefan Richter
-=====-==-=- =-== --===
http://arcgraph.de/sr/
