From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Subject: [PATCH V7 net-next 6/7] xen-netfront: Add support for
	multiple queues
Date: Tue, 29 Apr 2014 14:27:14 +0100
Message-ID: <1398778035-26233-7-git-send-email-andrew.bennieston@citrix.com>
References: <1398778035-26233-1-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, ian.campbell@citrix.com, netdev@vger.kernel.org,
	paul.durrant@citrix.com, david.vrabel@citrix.com, zoltan.kiss@citrix.com,
	"Andrew J. Bennieston" <andrew.bennieston@citrix.com>
To: <xen-devel@lists.xenproject.org>, <davem@davemloft.net>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1398778035-26233-1-git-send-email-andrew.bennieston@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>

Build on the refactoring of the previous patch to implement multiple
queues between xen-netfront and xen-netback.

Check XenStore for multi-queue support, and set up the rings and event
channels accordingly.

Write ring references and event channels to XenStore in a queue
hierarchy if appropriate, or flat when using only one queue.

Update the xennet_select_queue() function to choose the queue on which
to transmit a packet based on the skb hash result.

Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
Reviewed-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netfront.c |  170 ++++++++++++++++++++++++++++++++++----------
 1 file changed, 134 insertions(+), 36 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index f2aa7e8..cb2905e 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -57,6 +57,12 @@
 #include <xen/interface/memory.h>
 #include <xen/interface/grant_table.h>
 
+/* Module parameters */
+static unsigned int xennet_max_queues;
+module_param_named(max_queues, xennet_max_queues, uint, 0644);
+MODULE_PARM_DESC(max_queues,
+		 "Maximum number of queues per virtual interface");
+
 static const struct ethtool_ops xennet_ethtool_ops;
 
 struct netfront_cb {
@@ -565,10 +571,22 @@ static int xennet_count_skb_frag_slots(struct sk_buff *skb)
 	return pages;
 }
 
-static u16 xennet_select_queue(struct net_device *dev, struct sk_buff *skb)
+static u16 xennet_select_queue(struct net_device *dev, struct sk_buff *skb,
+			       void *accel_priv, select_queue_fallback_t fallback)
 {
-	/* Stub for later implementation of queue selection */
-	return 0;
+	unsigned int num_queues = dev->real_num_tx_queues;
+	u32 hash;
+	u16 queue_idx;
+
+	/* First, check if there is only one queue */
+	if (num_queues == 1) {
+		queue_idx = 0;
+	} else {
+		hash = skb_get_hash(skb);
+		queue_idx = hash % num_queues;
+	}
+
+	return queue_idx;
 }
 
 static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -1316,7 +1334,7 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
 	struct net_device *netdev;
 	struct netfront_info *np;
 
-	netdev = alloc_etherdev_mq(sizeof(struct netfront_info), 1);
+	netdev = alloc_etherdev_mq(sizeof(struct netfront_info), xennet_max_queues);
 	if (!netdev)
 		return ERR_PTR(-ENOMEM);
 
@@ -1687,6 +1705,88 @@ static int xennet_init_queue(struct netfront_queue *queue)
 	return err;
 }
 
+static int write_queue_xenstore_keys(struct netfront_queue *queue,
+			   struct xenbus_transaction *xbt, int write_hierarchical)
+{
+	/* Write the queue-specific keys into XenStore in the traditional
+	 * way for a single queue, or in a queue subkeys for multiple
+	 * queues.
+	 */
+	struct xenbus_device *dev = queue->info->xbdev;
+	int err;
+	const char *message;
+	char *path;
+	size_t pathsize;
+
+	/* Choose the correct place to write the keys */
+	if (write_hierarchical) {
+		pathsize = strlen(dev->nodename) + 10;
+		path = kzalloc(pathsize, GFP_KERNEL);
+		if (!path) {
+			err = -ENOMEM;
+			message = "out of memory while writing ring references";
+			goto error;
+		}
+		snprintf(path, pathsize, "%s/queue-%u",
+				dev->nodename, queue->id);
+	} else {
+		path = (char *)dev->nodename;
+	}
+
+	/* Write ring references */
+	err = xenbus_printf(*xbt, path, "tx-ring-ref", "%u",
+			queue->tx_ring_ref);
+	if (err) {
+		message = "writing tx-ring-ref";
+		goto error;
+	}
+
+	err = xenbus_printf(*xbt, path, "rx-ring-ref", "%u",
+			queue->rx_ring_ref);
+	if (err) {
+		message = "writing rx-ring-ref";
+		goto error;
+	}
+
+	/* Write event channels; taking into account both shared
+	 * and split event channel scenarios.
+	 */
+	if (queue->tx_evtchn == queue->rx_evtchn) {
+		/* Shared event channel */
+		err = xenbus_printf(*xbt, path,
+				"event-channel", "%u", queue->tx_evtchn);
+		if (err) {
+			message = "writing event-channel";
+			goto error;
+		}
+	} else {
+		/* Split event channels */
+		err = xenbus_printf(*xbt, path,
+				"event-channel-tx", "%u", queue->tx_evtchn);
+		if (err) {
+			message = "writing event-channel-tx";
+			goto error;
+		}
+
+		err = xenbus_printf(*xbt, path,
+				"event-channel-rx", "%u", queue->rx_evtchn);
+		if (err) {
+			message = "writing event-channel-rx";
+			goto error;
+		}
+	}
+
+	if (write_hierarchical)
+		kfree(path);
+	return 0;
+
+error:
+	if (write_hierarchical)
+		kfree(path);
+	xenbus_dev_fatal(dev, err, "%s", message);
+	return err;
+}
+
 /* Common code used when first setting up, and when resuming. */
 static int talk_to_netback(struct xenbus_device *dev,
 			   struct netfront_info *info)
@@ -1696,11 +1796,19 @@ static int talk_to_netback(struct xenbus_device *dev,
 	int err;
 	unsigned int feature_split_evtchn;
 	unsigned int i = 0;
+	unsigned int max_queues = 0;
 	struct netfront_queue *queue = NULL;
 	unsigned int num_queues = 1;
 
 	info->netdev->irq = 0;
 
+	/* Check if backend supports multiple queues */
+	err = xenbus_scanf(XBT_NIL, info->xbdev->otherend,
+			   "multi-queue-max-queues", "%u", &max_queues);
+	if (err < 0)
+		max_queues = 1;
+	num_queues = min(max_queues, xennet_max_queues);
+
 	/* Check feature-split-event-channels */
 	err = xenbus_scanf(XBT_NIL, info->xbdev->otherend,
 			   "feature-split-event-channels", "%u",
@@ -1765,49 +1873,35 @@ static int talk_to_netback(struct xenbus_device *dev,
 	}
 
 again:
-	queue = &info->queues[0]; /* Use first queue only */
-
 	err = xenbus_transaction_start(&xbt);
 	if (err) {
 		xenbus_dev_fatal(dev, err, "starting transaction");
 		goto destroy_ring;
 	}
 
-	err = xenbus_printf(xbt, dev->nodename, "tx-ring-ref", "%u",
-			    queue->tx_ring_ref);
-	if (err) {
-		message = "writing tx ring-ref";
-		goto abort_transaction;
-	}
-	err = xenbus_printf(xbt, dev->nodename, "rx-ring-ref", "%u",
-			    queue->rx_ring_ref);
-	if (err) {
-		message = "writing rx ring-ref";
-		goto abort_transaction;
-	}
-
-	if (queue->tx_evtchn == queue->rx_evtchn) {
-		err = xenbus_printf(xbt, dev->nodename,
-				    "event-channel", "%u", queue->tx_evtchn);
-		if (err) {
-			message = "writing event-channel";
-			goto abort_transaction;
-		}
+	if (num_queues == 1) {
+		err = write_queue_xenstore_keys(&info->queues[0], &xbt, 0); /* flat */
+		if (err)
+			goto abort_transaction_no_dev_fatal;
 	} else {
-		err = xenbus_printf(xbt, dev->nodename,
-				    "event-channel-tx", "%u", queue->tx_evtchn);
+		/* Write the number of queues */
+		err = xenbus_printf(xbt, dev->nodename, "multi-queue-num-queues",
+				    "%u", num_queues);
 		if (err) {
-			message = "writing event-channel-tx";
-			goto abort_transaction;
+			message = "writing multi-queue-num-queues";
+			goto abort_transaction_no_dev_fatal;
 		}
-		err = xenbus_printf(xbt, dev->nodename,
-				    "event-channel-rx", "%u", queue->rx_evtchn);
-		if (err) {
-			message = "writing event-channel-rx";
-			goto abort_transaction;
+
+		/* Write the keys for each queue */
+		for (i = 0; i < num_queues; ++i) {
+			queue = &info->queues[i];
+			err = write_queue_xenstore_keys(queue, &xbt, 1); /* hierarchical */
+			if (err)
+				goto abort_transaction_no_dev_fatal;
 		}
 	}
 
+	/* The remaining keys are not queue-specific */
 	err = xenbus_printf(xbt, dev->nodename, "request-rx-copy", "%u",
 			    1);
 	if (err) {
@@ -1857,8 +1951,9 @@ again:
 	return 0;
 
  abort_transaction:
-	xenbus_transaction_end(xbt, 1);
 	xenbus_dev_fatal(dev, err, "%s", message);
+abort_transaction_no_dev_fatal:
+	xenbus_transaction_end(xbt, 1);
  destroy_ring:
 	xennet_disconnect_backend(info);
 	kfree(info->queues);
@@ -2264,6 +2359,9 @@ static int __init netif_init(void)
 
 	pr_info("Initialising Xen virtual ethernet driver\n");
 
+	/* Allow as many queues as there are CPUs, by default */
+	xennet_max_queues = num_online_cpus();
+
 	return xenbus_register_frontend(&netfront_driver);
 }
 module_init(netif_init);
-- 
1.7.10.4
