From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Subject: [PATCH V8 net-next 3/6] xen-netback: Add support for
	multiple queues
Date: Wed, 14 May 2014 14:52:27 +0100
Message-ID: <1400075550-4580-4-git-send-email-andrew.bennieston@citrix.com>
References: <1400075550-4580-1-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, ian.campbell@citrix.com, netdev@vger.kernel.org,
	paul.durrant@citrix.com, david.vrabel@citrix.com, zoltan.kiss@citrix.com,
	"Andrew J. Bennieston" <andrew.bennieston@citrix.com>
To: <xen-devel@lists.xenproject.org>, <davem@davemloft.net>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1400075550-4580-1-git-send-email-andrew.bennieston@citrix.com>
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

Builds on the refactoring of the previous patch to implement multiple
queues between xen-netfront and xen-netback.

Writes the maximum supported number of queues into XenStore, and reads
the values written by the frontend to determine how many queues to use.

Ring references and event channels are read from XenStore on a per-queue
basis and rings are connected accordingly.

Also adds code to handle the cleanup of any already initialised queues
if the initialisation of a subsequent queue fails.

Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
---
 drivers/net/xen-netback/common.h    |    2 +
 drivers/net/xen-netback/interface.c |   23 +++++---
 drivers/net/xen-netback/netback.c   |    8 +++
 drivers/net/xen-netback/xenbus.c    |  102 ++++++++++++++++++++++++++++++-----
 4 files changed, 117 insertions(+), 18 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index bd696f7..16d6a05 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -237,6 +237,7 @@ struct xenvif *xenvif_alloc(struct device *parent,
 			    unsigned int handle);
 
 int xenvif_init_queue(struct xenvif_queue *queue);
+void xenvif_deinit_queue(struct xenvif_queue *queue);
 
 int xenvif_connect(struct xenvif_queue *queue, unsigned long tx_ring_ref,
 		   unsigned long rx_ring_ref, unsigned int tx_evtchn,
@@ -299,5 +300,6 @@ extern bool separate_tx_rx_irq;
 
 extern unsigned int rx_drain_timeout_msecs;
 extern unsigned int rx_drain_timeout_jiffies;
+extern unsigned int xenvif_max_queues;
 
 #endif /* __XEN_NETBACK__COMMON_H__ */
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 5122c8f..bbb2f56 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -162,7 +162,6 @@ static void xenvif_wake_queue_callback(unsigned long data)
 static u16 xenvif_select_queue(struct net_device *dev, struct sk_buff *skb,
 			       void *accel_priv, select_queue_fallback_t fallback)
 {
-	struct xenvif *vif = netdev_priv(dev);
 	unsigned int num_queues = dev->real_num_tx_queues;
 	u32 hash;
 	u16 queue_index;
@@ -459,7 +458,12 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	char name[IFNAMSIZ] = {};
 
 	snprintf(name, IFNAMSIZ - 1, "vif%u.%u", domid, handle);
-	dev = alloc_netdev_mq(sizeof(struct xenvif), name, ether_setup, 1);
+	/* Allocate a netdev with the max. supported number of queues.
+	 * When the guest selects the desired number, it will be updated
+	 * via netif_set_real_num_tx_queues().
+	 */
+	dev = alloc_netdev_mq(sizeof(struct xenvif), name, ether_setup,
+			      xenvif_max_queues);
 	if (dev == NULL) {
 		pr_warn("Could not allocate netdev for %s\n", name);
 		return ERR_PTR(-ENOMEM);
@@ -729,6 +733,16 @@ void xenvif_disconnect(struct xenvif *vif)
 	}
 }
 
+/* Reverse the relevant parts of xenvif_init_queue().
+ * Used for queue teardown from xenvif_free(), and on the
+ * error handling paths in xenbus.c:connect().
+ */
+void xenvif_deinit_queue(struct xenvif_queue *queue)
+{
+	free_xenballooned_pages(MAX_PENDING_REQS, queue->mmap_pages);
+	netif_napi_del(&queue->napi);
+}
+
 void xenvif_free(struct xenvif *vif)
 {
 	struct xenvif_queue *queue = NULL;
@@ -752,11 +766,8 @@ void xenvif_free(struct xenvif *vif)
 
 	for (queue_index = 0; queue_index < num_queues; ++queue_index) {
 		queue = &vif->queues[queue_index];
-
 		xenvif_wait_unmap_timeout(queue, worst_case_skb_lifetime);
-		free_xenballooned_pages(MAX_PENDING_REQS, queue->mmap_pages);
-
-		netif_napi_del(&queue->napi);
+		xenvif_deinit_queue(queue);
 	}
 
 	/* Free the array of queues. The call below does not require
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 16935ac..208e39e 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -62,6 +62,11 @@ unsigned int rx_drain_timeout_msecs = 10000;
 module_param(rx_drain_timeout_msecs, uint, 0444);
 unsigned int rx_drain_timeout_jiffies;
 
+unsigned int xenvif_max_queues;
+module_param_named(max_queues, xenvif_max_queues, uint, 0644);
+MODULE_PARM_DESC(max_queues,
+		 "Maximum number of queues per virtual interface");
+
 /*
  * This is the maximum slots a skb can have. If a guest sends a skb
  * which exceeds this limit it is considered malicious.
@@ -1890,6 +1895,9 @@ static int __init netback_init(void)
 	if (!xen_domain())
 		return -ENODEV;
 
+	/* Allow as many queues as there are CPUs, by default */
+	xenvif_max_queues = num_online_cpus();
+
 	if (fatal_skb_slots < XEN_NETBK_LEGACY_SLOTS_MAX) {
 		pr_info("fatal_skb_slots too small (%d), bump it to XEN_NETBK_LEGACY_SLOTS_MAX (%d)\n",
 			fatal_skb_slots, XEN_NETBK_LEGACY_SLOTS_MAX);
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index b42ff27..96c63dc2 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -20,6 +20,7 @@
 
 #include "common.h"
 #include <linux/vmalloc.h>
+#include <linux/rtnetlink.h>
 
 struct backend_info {
 	struct xenbus_device *dev;
@@ -159,6 +160,12 @@ static int netback_probe(struct xenbus_device *dev,
 	if (err)
 		pr_debug("Error writing feature-split-event-channels\n");
 
+	/* Multi-queue support: This is an optional feature. */
+	err = xenbus_printf(XBT_NIL, dev->nodename,
+			    "multi-queue-max-queues", "%u", xenvif_max_queues);
+	if (err)
+		pr_debug("Error writing multi-queue-max-queues\n");
+
 	err = xenbus_switch_state(dev, XenbusStateInitWait);
 	if (err)
 		goto fail;
@@ -489,9 +496,25 @@ static void connect(struct backend_info *be)
 	struct xenbus_device *dev = be->dev;
 	unsigned long credit_bytes, credit_usec;
 	unsigned int queue_index;
-	unsigned int requested_num_queues = 1;
+	unsigned int requested_num_queues;
 	struct xenvif_queue *queue;
 
+	/* Check whether the frontend requested multiple queues
+	 * and read the number requested.
+	 */
+	err = xenbus_scanf(XBT_NIL, dev->otherend,
+			   "multi-queue-num-queues",
+			   "%u", &requested_num_queues);
+	if (err < 0) {
+		requested_num_queues = 1; /* Fall back to single queue */
+	} else if (requested_num_queues > xenvif_max_queues) {
+		/* buggy or malicious guest */
+		xenbus_dev_fatal(dev, err,
+				 "guest requested %u queues, exceeding the maximum of %u.",
+				 requested_num_queues, xenvif_max_queues);
+		return;
+	}
+
 	err = xen_net_read_mac(dev, be->vif->fe_dev_addr);
 	if (err) {
 		xenbus_dev_fatal(dev, err, "parsing %s/mac", dev->nodename);
@@ -501,6 +524,7 @@ static void connect(struct backend_info *be)
 	xen_net_read_rate(dev, &credit_bytes, &credit_usec);
 	read_xenbus_vif_flags(be);
 
+	/* Use the number of queues requested by the frontend */
 	be->vif->queues = vzalloc(requested_num_queues *
 				  sizeof(struct xenvif_queue));
 	rtnl_lock();
@@ -515,14 +539,33 @@ static void connect(struct backend_info *be)
 				be->vif->dev->name, queue->id);
 
 		err = xenvif_init_queue(queue);
-		if (err)
+		if (err) {
+			/* xenvif_init_queue() cleans up after itself on
+			 * failure, but we need to clean up any previously
+			 * initialised queues. Set num_queues to i so that
+			 * earlier queues can be destroyed using the regular
+			 * disconnect logic.
+			 */
+			rtnl_lock();
+			netif_set_real_num_tx_queues(be->vif->dev, queue_index);
+			rtnl_unlock();
 			goto err;
+		}
 
 		queue->remaining_credit = credit_bytes;
 
 		err = connect_rings(be, queue);
-		if (err)
+		if (err) {
+			/* connect_rings() cleans up after itself on failure,
+			 * but we need to clean up after xenvif_init_queue() here,
+			 * and also clean up any previously initialised queues.
+			 */
+			xenvif_deinit_queue(queue);
+			rtnl_lock();
+			netif_set_real_num_tx_queues(be->vif->dev, queue_index);
+			rtnl_unlock();
 			goto err;
+		}
 	}
 
 	xenvif_carrier_on(be->vif);
@@ -539,6 +582,8 @@ static void connect(struct backend_info *be)
 	return;
 
 err:
+	if (be->vif->dev->real_num_tx_queues > 0)
+		xenvif_disconnect(be->vif); /* Clean up existing queues */
 	vfree(be->vif->queues);
 	be->vif->queues = NULL;
 	rtnl_lock();
@@ -551,32 +596,62 @@ err:
 static int connect_rings(struct backend_info *be, struct xenvif_queue *queue)
 {
 	struct xenbus_device *dev = be->dev;
+	unsigned int num_queues = queue->vif->dev->real_num_tx_queues;
 	unsigned long tx_ring_ref, rx_ring_ref;
 	unsigned int tx_evtchn, rx_evtchn;
 	int err;
+	char *xspath;
+	size_t xspathsize;
+	const size_t xenstore_path_ext_size = 11; /* sufficient for "/queue-NNN" */
+
+	/* If the frontend requested 1 queue, or we have fallen back
+	 * to single queue due to lack of frontend support for multi-
+	 * queue, expect the remaining XenStore keys in the toplevel
+	 * directory. Otherwise, expect them in a subdirectory called
+	 * queue-N.
+	 */
+	if (num_queues == 1) {
+		xspath = kzalloc(strlen(dev->otherend) + 1, GFP_KERNEL);
+		if (!xspath) {
+			xenbus_dev_fatal(dev, -ENOMEM,
+					 "reading ring references");
+			return -ENOMEM;
+		}
+		strcpy(xspath, dev->otherend);
+	} else {
+		xspathsize = strlen(dev->otherend) + xenstore_path_ext_size;
+		xspath = kzalloc(xspathsize, GFP_KERNEL);
+		if (!xspath) {
+			xenbus_dev_fatal(dev, -ENOMEM,
+					 "reading ring references");
+			return -ENOMEM;
+		}
+		snprintf(xspath, xspathsize, "%s/queue-%u", dev->otherend,
+			 queue->id);
+	}
 
-	err = xenbus_gather(XBT_NIL, dev->otherend,
+	err = xenbus_gather(XBT_NIL, xspath,
 			    "tx-ring-ref", "%lu", &tx_ring_ref,
 			    "rx-ring-ref", "%lu", &rx_ring_ref, NULL);
 	if (err) {
 		xenbus_dev_fatal(dev, err,
 				 "reading %s/ring-ref",
-				 dev->otherend);
-		return err;
+				 xspath);
+		goto err;
 	}
 
 	/* Try split event channels first, then single event channel. */
-	err = xenbus_gather(XBT_NIL, dev->otherend,
+	err = xenbus_gather(XBT_NIL, xspath,
 			    "event-channel-tx", "%u", &tx_evtchn,
 			    "event-channel-rx", "%u", &rx_evtchn, NULL);
 	if (err < 0) {
-		err = xenbus_scanf(XBT_NIL, dev->otherend,
+		err = xenbus_scanf(XBT_NIL, xspath,
 				   "event-channel", "%u", &tx_evtchn);
 		if (err < 0) {
 			xenbus_dev_fatal(dev, err,
 					 "reading %s/event-channel(-tx/rx)",
-					 dev->otherend);
-			return err;
+					 xspath);
+			goto err;
 		}
 		rx_evtchn = tx_evtchn;
 	}
@@ -589,10 +664,13 @@ static int connect_rings(struct backend_info *be, struct xenvif_queue *queue)
 				 "mapping shared-frames %lu/%lu port tx %u rx %u",
 				 tx_ring_ref, rx_ring_ref,
 				 tx_evtchn, rx_evtchn);
-		return err;
+		goto err;
 	}
 
-	return 0;
+	err = 0;
+err: /* Regular return falls through with err == 0 */
+	kfree(xspath);
+	return err;
 }
 
 static int read_xenbus_vif_flags(struct backend_info *be)
-- 
1.7.10.4
