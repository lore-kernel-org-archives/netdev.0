From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Subject: [PATCH V5 net-next 1/5] xen-netback: Factor
	queue-specific data into queue struct.
Date: Mon, 24 Feb 2014 14:33:03 +0000
Message-ID: <1393252387-17496-2-git-send-email-andrew.bennieston@citrix.com>
References: <1393252387-17496-1-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>,
	netdev@vger.kernel.org, paul.durrant@citrix.com,
	wei.liu2@citrix.com, ian.campbell@citrix.com
To: <xen-devel@lists.xenproject.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1393252387-17496-1-git-send-email-andrew.bennieston@citrix.com>
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

In preparation for multi-queue support in xen-netback, move the
queue-specific data from struct xenvif into struct xenvif_queue, and
update the rest of the code to use this.

Also adds loops over queues where appropriate, even though only one is
configured at this point, and uses alloc_netdev_mq() and the
corresponding multi-queue netif wake/start/stop functions in preparation
for multiple active queues.

Finally, implements a trivial queue selection function suitable for
ndo_select_queue, which simply returns 0 for a single queue and uses
skb_get_hash() to compute the queue index otherwise.

Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
---
 drivers/net/xen-netback/common.h    |   85 ++++--
 drivers/net/xen-netback/interface.c |  329 ++++++++++++++--------
 drivers/net/xen-netback/netback.c   |  530 ++++++++++++++++++-----------------
 drivers/net/xen-netback/xenbus.c    |   87 ++++--
 4 files changed, 608 insertions(+), 423 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index ae413a2..4176539 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -108,17 +108,39 @@ struct xenvif_rx_meta {
  */
 #define MAX_GRANT_COPY_OPS (MAX_SKB_FRAGS * XEN_NETIF_RX_RING_SIZE)
 
-struct xenvif {
-	/* Unique identifier for this interface. */
-	domid_t          domid;
-	unsigned int     handle;
+/* Queue name is interface name with "-qNNN" appended */
+#define QUEUE_NAME_SIZE (IFNAMSIZ + 6)
+
+/* IRQ name is queue name with "-tx" or "-rx" appended */
+#define IRQ_NAME_SIZE (QUEUE_NAME_SIZE + 3)
+
+struct xenvif;
+
+struct xenvif_stats {
+	/* Stats fields to be updated per-queue.
+	 * A subset of struct net_device_stats that contains only the
+	 * fields that are updated in netback.c for each queue.
+	 */
+	unsigned int rx_bytes;
+	unsigned int rx_packets;
+	unsigned int tx_bytes;
+	unsigned int tx_packets;
+
+	/* Additional stats used by xenvif */
+	unsigned long rx_gso_checksum_fixup;
+};
+
+struct xenvif_queue { /* Per-queue data for xenvif */
+	unsigned int id; /* Queue ID, 0-based */
+	char name[QUEUE_NAME_SIZE]; /* DEVNAME-qN */
+	struct xenvif *vif; /* Parent VIF */
 
 	/* Use NAPI for guest TX */
 	struct napi_struct napi;
 	/* When feature-split-event-channels = 0, tx_irq = rx_irq. */
 	unsigned int tx_irq;
 	/* Only used when feature-split-event-channels = 1 */
-	char tx_irq_name[IFNAMSIZ+4]; /* DEVNAME-tx */
+	char tx_irq_name[IRQ_NAME_SIZE]; /* DEVNAME-qN-tx */
 	struct xen_netif_tx_back_ring tx;
 	struct sk_buff_head tx_queue;
 	struct page *mmap_pages[MAX_PENDING_REQS];
@@ -140,19 +162,34 @@ struct xenvif {
 	/* When feature-split-event-channels = 0, tx_irq = rx_irq. */
 	unsigned int rx_irq;
 	/* Only used when feature-split-event-channels = 1 */
-	char rx_irq_name[IFNAMSIZ+4]; /* DEVNAME-rx */
+	char rx_irq_name[IRQ_NAME_SIZE]; /* DEVNAME-qN-rx */
 	struct xen_netif_rx_back_ring rx;
 	struct sk_buff_head rx_queue;
 	RING_IDX rx_last_skb_slots;
 
-	/* This array is allocated seperately as it is large */
-	struct gnttab_copy *grant_copy_op;
+	struct gnttab_copy grant_copy_op[MAX_GRANT_COPY_OPS];
 
 	/* We create one meta structure per ring request we consume, so
 	 * the maximum number is the same as the ring size.
 	 */
 	struct xenvif_rx_meta meta[XEN_NETIF_RX_RING_SIZE];
 
+	/* Transmit shaping: allow 'credit_bytes' every 'credit_usec'. */
+	unsigned long   credit_bytes;
+	unsigned long   credit_usec;
+	unsigned long   remaining_credit;
+	struct timer_list credit_timeout;
+	u64 credit_window_start;
+
+	/* Statistics */
+	struct xenvif_stats stats;
+};
+
+struct xenvif {
+	/* Unique identifier for this interface. */
+	domid_t          domid;
+	unsigned int     handle;
+
 	u8               fe_dev_addr[6];
 
 	/* Frontend feature information. */
@@ -166,15 +203,9 @@ struct xenvif {
 	/* Internal feature information. */
 	u8 can_queue:1;	    /* can queue packets for receiver? */
 
-	/* Transmit shaping: allow 'credit_bytes' every 'credit_usec'. */
-	unsigned long   credit_bytes;
-	unsigned long   credit_usec;
-	unsigned long   remaining_credit;
-	struct timer_list credit_timeout;
-	u64 credit_window_start;
-
-	/* Statistics */
-	unsigned long rx_gso_checksum_fixup;
+	/* Queues */
+	unsigned int num_queues;
+	struct xenvif_queue *queues;
 
 	/* Miscellaneous private stuff. */
 	struct net_device *dev;
@@ -189,7 +220,9 @@ struct xenvif *xenvif_alloc(struct device *parent,
 			    domid_t domid,
 			    unsigned int handle);
 
-int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
+void xenvif_init_queue(struct xenvif_queue *queue);
+
+int xenvif_connect(struct xenvif_queue *queue, unsigned long tx_ring_ref,
 		   unsigned long rx_ring_ref, unsigned int tx_evtchn,
 		   unsigned int rx_evtchn);
 void xenvif_disconnect(struct xenvif *vif);
@@ -200,31 +233,31 @@ void xenvif_xenbus_fini(void);
 
 int xenvif_schedulable(struct xenvif *vif);
 
-int xenvif_must_stop_queue(struct xenvif *vif);
+int xenvif_must_stop_queue(struct xenvif_queue *queue);
 
 /* (Un)Map communication rings. */
-void xenvif_unmap_frontend_rings(struct xenvif *vif);
-int xenvif_map_frontend_rings(struct xenvif *vif,
+void xenvif_unmap_frontend_rings(struct xenvif_queue *queue);
+int xenvif_map_frontend_rings(struct xenvif_queue *queue,
 			      grant_ref_t tx_ring_ref,
 			      grant_ref_t rx_ring_ref);
 
 /* Check for SKBs from frontend and schedule backend processing */
-void xenvif_check_rx_xenvif(struct xenvif *vif);
+void xenvif_check_rx_xenvif(struct xenvif_queue *queue);
 
 /* Prevent the device from generating any further traffic. */
 void xenvif_carrier_off(struct xenvif *vif);
 
-int xenvif_tx_action(struct xenvif *vif, int budget);
+int xenvif_tx_action(struct xenvif_queue *queue, int budget);
 
 int xenvif_kthread(void *data);
-void xenvif_kick_thread(struct xenvif *vif);
+void xenvif_kick_thread(struct xenvif_queue *queue);
 
 /* Determine whether the needed number of slots (req) are available,
  * and set req_event if not.
  */
-bool xenvif_rx_ring_slots_available(struct xenvif *vif, int needed);
+bool xenvif_rx_ring_slots_available(struct xenvif_queue *queue, int needed);
 
-void xenvif_stop_queue(struct xenvif *vif);
+void xenvif_carrier_on(struct xenvif *vif);
 
 extern bool separate_tx_rx_irq;
 
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 7669d49..0297980 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -34,7 +34,6 @@
 #include <linux/ethtool.h>
 #include <linux/rtnetlink.h>
 #include <linux/if_vlan.h>
-#include <linux/vmalloc.h>
 
 #include <xen/events.h>
 #include <asm/xen/hypercall.h>
@@ -42,6 +41,16 @@
 #define XENVIF_QUEUE_LENGTH 32
 #define XENVIF_NAPI_WEIGHT  64
 
+static inline void xenvif_stop_queue(struct xenvif_queue *queue)
+{
+	struct net_device *dev = queue->vif->dev;
+
+	if (!queue->vif->can_queue)
+		return;
+
+	netif_tx_stop_queue(netdev_get_tx_queue(dev, queue->id));
+}
+
 int xenvif_schedulable(struct xenvif *vif)
 {
 	return netif_running(vif->dev) && netif_carrier_ok(vif->dev);
@@ -49,20 +58,20 @@ int xenvif_schedulable(struct xenvif *vif)
 
 static irqreturn_t xenvif_tx_interrupt(int irq, void *dev_id)
 {
-	struct xenvif *vif = dev_id;
+	struct xenvif_queue *queue = dev_id;
 
-	if (RING_HAS_UNCONSUMED_REQUESTS(&vif->tx))
-		napi_schedule(&vif->napi);
+	if (RING_HAS_UNCONSUMED_REQUESTS(&queue->tx))
+		napi_schedule(&queue->napi);
 
 	return IRQ_HANDLED;
 }
 
-static int xenvif_poll(struct napi_struct *napi, int budget)
+int xenvif_poll(struct napi_struct *napi, int budget)
 {
-	struct xenvif *vif = container_of(napi, struct xenvif, napi);
+	struct xenvif_queue *queue = container_of(napi, struct xenvif_queue, napi);
 	int work_done;
 
-	work_done = xenvif_tx_action(vif, budget);
+	work_done = xenvif_tx_action(queue, budget);
 
 	if (work_done < budget) {
 		int more_to_do = 0;
@@ -86,7 +95,7 @@ static int xenvif_poll(struct napi_struct *napi, int budget)
 
 		local_irq_save(flags);
 
-		RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, more_to_do);
+		RING_FINAL_CHECK_FOR_REQUESTS(&queue->tx, more_to_do);
 		if (!more_to_do)
 			__napi_complete(napi);
 
@@ -98,9 +107,9 @@ static int xenvif_poll(struct napi_struct *napi, int budget)
 
 static irqreturn_t xenvif_rx_interrupt(int irq, void *dev_id)
 {
-	struct xenvif *vif = dev_id;
+	struct xenvif_queue *queue = dev_id;
 
-	xenvif_kick_thread(vif);
+	xenvif_kick_thread(queue);
 
 	return IRQ_HANDLED;
 }
@@ -113,15 +122,48 @@ static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+static u16 xenvif_select_queue(struct net_device *dev, struct sk_buff *skb,
+			       void *accel_priv, select_queue_fallback_t fallback)
+{
+	struct xenvif *vif = netdev_priv(dev);
+	u32 hash;
+	u16 queue_index;
+
+	/* First, check if there is only one queue to optimise the
+	 * single-queue or old frontend scenario.
+	 */
+	if (vif->num_queues == 1) {
+		queue_index = 0;
+	} else {
+		/* Use skb_get_hash to obtain an L4 hash if available */
+		hash = skb_get_hash(skb);
+		queue_index = (u16) (((u64)hash * vif->num_queues) >> 32);
+	}
+
+	return queue_index;
+}
+
 static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct xenvif *vif = netdev_priv(dev);
+	struct xenvif_queue *queue = NULL;
+	u16 index;
 	int min_slots_needed;
 
 	BUG_ON(skb->dev != dev);
 
+	/* Drop the packet if queues are not set up */
+	if (vif->num_queues < 1)
+		goto drop;
+
+	/* Obtain the queue to be used to transmit this packet */
+	index = skb_get_queue_mapping(skb);
+	if (index >= vif->num_queues)
+		index = 0; /* Fall back to queue 0 if out of range */
+	queue = &vif->queues[index];
+
 	/* Drop the packet if vif is not ready */
-	if (vif->task == NULL || !xenvif_schedulable(vif))
+	if (queue->task == NULL || !xenvif_schedulable(vif))
 		goto drop;
 
 	/* At best we'll need one slot for the header and one for each
@@ -140,11 +182,11 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * then turn off the queue to give the ring a chance to
 	 * drain.
 	 */
-	if (!xenvif_rx_ring_slots_available(vif, min_slots_needed))
-		xenvif_stop_queue(vif);
+	if (!xenvif_rx_ring_slots_available(queue, min_slots_needed))
+		xenvif_stop_queue(queue);
 
-	skb_queue_tail(&vif->rx_queue, skb);
-	xenvif_kick_thread(vif);
+	skb_queue_tail(&queue->rx_queue, skb);
+	xenvif_kick_thread(queue);
 
 	return NETDEV_TX_OK;
 
@@ -157,25 +199,58 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 static struct net_device_stats *xenvif_get_stats(struct net_device *dev)
 {
 	struct xenvif *vif = netdev_priv(dev);
+	struct xenvif_queue *queue = NULL;
+	unsigned long rx_bytes = 0;
+	unsigned long rx_packets = 0;
+	unsigned long tx_bytes = 0;
+	unsigned long tx_packets = 0;
+	unsigned int index;
+
+	/* Aggregate tx and rx stats from each queue */
+	for (index = 0; index < vif->num_queues; ++index) {
+		queue = &vif->queues[index];
+		rx_bytes += queue->stats.rx_bytes;
+		rx_packets += queue->stats.rx_packets;
+		tx_bytes += queue->stats.tx_bytes;
+		tx_packets += queue->stats.tx_packets;
+	}
+
+	vif->dev->stats.rx_bytes = rx_bytes;
+	vif->dev->stats.rx_packets = rx_packets;
+	vif->dev->stats.tx_bytes = tx_bytes;
+	vif->dev->stats.tx_packets = tx_packets;
+
 	return &vif->dev->stats;
 }
 
 static void xenvif_up(struct xenvif *vif)
 {
-	napi_enable(&vif->napi);
-	enable_irq(vif->tx_irq);
-	if (vif->tx_irq != vif->rx_irq)
-		enable_irq(vif->rx_irq);
-	xenvif_check_rx_xenvif(vif);
+	struct xenvif_queue *queue = NULL;
+	unsigned int queue_index;
+
+	for (queue_index = 0; queue_index < vif->num_queues; ++queue_index) {
+		queue = &vif->queues[queue_index];
+		napi_enable(&queue->napi);
+		enable_irq(queue->tx_irq);
+		if (queue->tx_irq != queue->rx_irq)
+			enable_irq(queue->rx_irq);
+		xenvif_check_rx_xenvif(queue);
+	}
 }
 
 static void xenvif_down(struct xenvif *vif)
 {
-	napi_disable(&vif->napi);
-	disable_irq(vif->tx_irq);
-	if (vif->tx_irq != vif->rx_irq)
-		disable_irq(vif->rx_irq);
-	del_timer_sync(&vif->credit_timeout);
+	struct xenvif_queue *queue = NULL;
+	unsigned int queue_index;
+
+	for (queue_index = 0; queue_index < vif->num_queues; ++queue_index) {
+		queue = &vif->queues[queue_index];
+		napi_disable(&queue->napi);
+		disable_irq(queue->tx_irq);
+		if (queue->tx_irq != queue->rx_irq)
+			disable_irq(queue->rx_irq);
+		del_timer_sync(&queue->credit_timeout);
+	}
 }
 
 static int xenvif_open(struct net_device *dev)
@@ -183,7 +258,7 @@ static int xenvif_open(struct net_device *dev)
 	struct xenvif *vif = netdev_priv(dev);
 	if (netif_carrier_ok(dev))
 		xenvif_up(vif);
-	netif_start_queue(dev);
+	netif_tx_start_all_queues(dev);
 	return 0;
 }
 
@@ -192,7 +267,7 @@ static int xenvif_close(struct net_device *dev)
 	struct xenvif *vif = netdev_priv(dev);
 	if (netif_carrier_ok(dev))
 		xenvif_down(vif);
-	netif_stop_queue(dev);
+	netif_tx_stop_all_queues(dev);
 	return 0;
 }
 
@@ -232,7 +307,7 @@ static const struct xenvif_stat {
 } xenvif_stats[] = {
 	{
 		"rx_gso_checksum_fixup",
-		offsetof(struct xenvif, rx_gso_checksum_fixup)
+		offsetof(struct xenvif_stats, rx_gso_checksum_fixup)
 	},
 };
 
@@ -249,11 +324,19 @@ static int xenvif_get_sset_count(struct net_device *dev, int string_set)
 static void xenvif_get_ethtool_stats(struct net_device *dev,
 				     struct ethtool_stats *stats, u64 * data)
 {
-	void *vif = netdev_priv(dev);
+	struct xenvif *vif = netdev_priv(dev);
 	int i;
-
-	for (i = 0; i < ARRAY_SIZE(xenvif_stats); i++)
-		data[i] = *(unsigned long *)(vif + xenvif_stats[i].offset);
+	unsigned int queue_index;
+	struct xenvif_stats *vif_stats;
+
+	for (i = 0; i < ARRAY_SIZE(xenvif_stats); i++) {
+		unsigned long accum = 0;
+		for (queue_index = 0; queue_index < vif->num_queues; ++queue_index) {
+			vif_stats = &vif->queues[queue_index].stats;
+			accum += *(unsigned long *)(vif_stats + xenvif_stats[i].offset);
+		}
+		data[i] = accum;
+	}
 }
 
 static void xenvif_get_strings(struct net_device *dev, u32 stringset, u8 * data)
@@ -286,6 +369,7 @@ static const struct net_device_ops xenvif_netdev_ops = {
 	.ndo_fix_features = xenvif_fix_features,
 	.ndo_set_mac_address = eth_mac_addr,
 	.ndo_validate_addr   = eth_validate_addr,
+	.ndo_select_queue = xenvif_select_queue,
 };
 
 struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
@@ -295,10 +379,9 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	struct net_device *dev;
 	struct xenvif *vif;
 	char name[IFNAMSIZ] = {};
-	int i;
 
 	snprintf(name, IFNAMSIZ - 1, "vif%u.%u", domid, handle);
-	dev = alloc_netdev(sizeof(struct xenvif), name, ether_setup);
+	dev = alloc_netdev_mq(sizeof(struct xenvif), name, ether_setup, 1);
 	if (dev == NULL) {
 		pr_warn("Could not allocate netdev for %s\n", name);
 		return ERR_PTR(-ENOMEM);
@@ -308,24 +391,15 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 
 	vif = netdev_priv(dev);
 
-	vif->grant_copy_op = vmalloc(sizeof(struct gnttab_copy) *
-				     MAX_GRANT_COPY_OPS);
-	if (vif->grant_copy_op == NULL) {
-		pr_warn("Could not allocate grant copy space for %s\n", name);
-		free_netdev(dev);
-		return ERR_PTR(-ENOMEM);
-	}
-
 	vif->domid  = domid;
 	vif->handle = handle;
 	vif->can_sg = 1;
 	vif->ip_csum = 1;
 	vif->dev = dev;
 
-	vif->credit_bytes = vif->remaining_credit = ~0UL;
-	vif->credit_usec  = 0UL;
-	init_timer(&vif->credit_timeout);
-	vif->credit_window_start = get_jiffies_64();
+	/* Start out with no queues */
+	vif->num_queues = 0;
+	vif->queues = NULL;
 
 	dev->netdev_ops	= &xenvif_netdev_ops;
 	dev->hw_features = NETIF_F_SG |
@@ -336,16 +410,6 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 
 	dev->tx_queue_len = XENVIF_QUEUE_LENGTH;
 
-	skb_queue_head_init(&vif->rx_queue);
-	skb_queue_head_init(&vif->tx_queue);
-
-	vif->pending_cons = 0;
-	vif->pending_prod = MAX_PENDING_REQS;
-	for (i = 0; i < MAX_PENDING_REQS; i++)
-		vif->pending_ring[i] = i;
-	for (i = 0; i < MAX_PENDING_REQS; i++)
-		vif->mmap_pages[i] = NULL;
-
 	/*
 	 * Initialise a dummy MAC address. We choose the numerically
 	 * largest non-broadcast address to prevent the address getting
@@ -355,8 +419,6 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	memset(dev->dev_addr, 0xFF, ETH_ALEN);
 	dev->dev_addr[0] &= ~0x01;
 
-	netif_napi_add(dev, &vif->napi, xenvif_poll, XENVIF_NAPI_WEIGHT);
-
 	netif_carrier_off(dev);
 
 	err = register_netdev(dev);
@@ -373,85 +435,111 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	return vif;
 }
 
-int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
+void xenvif_init_queue(struct xenvif_queue *queue)
+{
+	int i;
+
+	queue->credit_bytes = queue->remaining_credit = ~0UL;
+	queue->credit_usec  = 0UL;
+	init_timer(&queue->credit_timeout);
+	queue->credit_window_start = get_jiffies_64();
+
+	skb_queue_head_init(&queue->rx_queue);
+	skb_queue_head_init(&queue->tx_queue);
+
+	queue->pending_cons = 0;
+	queue->pending_prod = MAX_PENDING_REQS;
+	for (i = 0; i < MAX_PENDING_REQS; ++i) {
+		queue->pending_ring[i] = i;
+		queue->mmap_pages[i] = NULL;
+	}
+
+	netif_napi_add(queue->vif->dev, &queue->napi, xenvif_poll,
+			XENVIF_NAPI_WEIGHT);
+}
+
+void xenvif_carrier_on(struct xenvif *vif)
+{
+	rtnl_lock();
+	if (!vif->can_sg && vif->dev->mtu > ETH_DATA_LEN)
+		dev_set_mtu(vif->dev, ETH_DATA_LEN);
+	netdev_update_features(vif->dev);
+	netif_carrier_on(vif->dev);
+	if (netif_running(vif->dev))
+		xenvif_up(vif);
+	rtnl_unlock();
+}
+
+int xenvif_connect(struct xenvif_queue *queue, unsigned long tx_ring_ref,
 		   unsigned long rx_ring_ref, unsigned int tx_evtchn,
 		   unsigned int rx_evtchn)
 {
 	struct task_struct *task;
 	int err = -ENOMEM;
 
-	BUG_ON(vif->tx_irq);
-	BUG_ON(vif->task);
+	BUG_ON(queue->tx_irq);
+	BUG_ON(queue->task);
 
-	err = xenvif_map_frontend_rings(vif, tx_ring_ref, rx_ring_ref);
+	err = xenvif_map_frontend_rings(queue, tx_ring_ref, rx_ring_ref);
 	if (err < 0)
 		goto err;
 
-	init_waitqueue_head(&vif->wq);
+	init_waitqueue_head(&queue->wq);
 
 	if (tx_evtchn == rx_evtchn) {
 		/* feature-split-event-channels == 0 */
 		err = bind_interdomain_evtchn_to_irqhandler(
-			vif->domid, tx_evtchn, xenvif_interrupt, 0,
-			vif->dev->name, vif);
+			queue->vif->domid, tx_evtchn, xenvif_interrupt, 0,
+			queue->name, queue);
 		if (err < 0)
 			goto err_unmap;
-		vif->tx_irq = vif->rx_irq = err;
-		disable_irq(vif->tx_irq);
+		queue->tx_irq = queue->rx_irq = err;
+		disable_irq(queue->tx_irq);
 	} else {
 		/* feature-split-event-channels == 1 */
-		snprintf(vif->tx_irq_name, sizeof(vif->tx_irq_name),
-			 "%s-tx", vif->dev->name);
+		snprintf(queue->tx_irq_name, sizeof(queue->tx_irq_name),
+			 "%s-tx", queue->name);
 		err = bind_interdomain_evtchn_to_irqhandler(
-			vif->domid, tx_evtchn, xenvif_tx_interrupt, 0,
-			vif->tx_irq_name, vif);
+			queue->vif->domid, tx_evtchn, xenvif_tx_interrupt, 0,
+			queue->tx_irq_name, queue);
 		if (err < 0)
 			goto err_unmap;
-		vif->tx_irq = err;
-		disable_irq(vif->tx_irq);
+		queue->tx_irq = err;
+		disable_irq(queue->tx_irq);
 
-		snprintf(vif->rx_irq_name, sizeof(vif->rx_irq_name),
-			 "%s-rx", vif->dev->name);
+		snprintf(queue->rx_irq_name, sizeof(queue->rx_irq_name),
+			 "%s-rx", queue->name);
 		err = bind_interdomain_evtchn_to_irqhandler(
-			vif->domid, rx_evtchn, xenvif_rx_interrupt, 0,
-			vif->rx_irq_name, vif);
+			queue->vif->domid, rx_evtchn, xenvif_rx_interrupt, 0,
+			queue->rx_irq_name, queue);
 		if (err < 0)
 			goto err_tx_unbind;
-		vif->rx_irq = err;
-		disable_irq(vif->rx_irq);
+		queue->rx_irq = err;
+		disable_irq(queue->rx_irq);
 	}
 
 	task = kthread_create(xenvif_kthread,
-			      (void *)vif, "%s", vif->dev->name);
+			      (void *)queue, "%s", queue->name);
 	if (IS_ERR(task)) {
-		pr_warn("Could not allocate kthread for %s\n", vif->dev->name);
+		pr_warn("Could not allocate kthread for %s\n", queue->name);
 		err = PTR_ERR(task);
 		goto err_rx_unbind;
 	}
 
-	vif->task = task;
+	queue->task = task;
 
-	rtnl_lock();
-	if (!vif->can_sg && vif->dev->mtu > ETH_DATA_LEN)
-		dev_set_mtu(vif->dev, ETH_DATA_LEN);
-	netdev_update_features(vif->dev);
-	netif_carrier_on(vif->dev);
-	if (netif_running(vif->dev))
-		xenvif_up(vif);
-	rtnl_unlock();
-
-	wake_up_process(vif->task);
+	wake_up_process(queue->task);
 
 	return 0;
 
 err_rx_unbind:
-	unbind_from_irqhandler(vif->rx_irq, vif);
-	vif->rx_irq = 0;
+	unbind_from_irqhandler(queue->rx_irq, queue);
+	queue->rx_irq = 0;
 err_tx_unbind:
-	unbind_from_irqhandler(vif->tx_irq, vif);
-	vif->tx_irq = 0;
+	unbind_from_irqhandler(queue->tx_irq, queue);
+	queue->tx_irq = 0;
 err_unmap:
-	xenvif_unmap_frontend_rings(vif);
+	xenvif_unmap_frontend_rings(queue);
 err:
 	module_put(THIS_MODULE);
 	return err;
@@ -470,34 +558,53 @@ void xenvif_carrier_off(struct xenvif *vif)
 
 void xenvif_disconnect(struct xenvif *vif)
 {
+	struct xenvif_queue *queue = NULL;
+	unsigned int queue_index;
+
 	if (netif_carrier_ok(vif->dev))
 		xenvif_carrier_off(vif);
 
-	if (vif->task) {
-		kthread_stop(vif->task);
-		vif->task = NULL;
-	}
+	for (queue_index = 0; queue_index < vif->num_queues; ++queue_index) {
+		queue = &vif->queues[queue_index];
 
-	if (vif->tx_irq) {
-		if (vif->tx_irq == vif->rx_irq)
-			unbind_from_irqhandler(vif->tx_irq, vif);
-		else {
-			unbind_from_irqhandler(vif->tx_irq, vif);
-			unbind_from_irqhandler(vif->rx_irq, vif);
+		if (queue->task) {
+			kthread_stop(queue->task);
+			queue->task = NULL;
 		}
-		vif->tx_irq = 0;
+
+		if (queue->tx_irq) {
+			if (queue->tx_irq == queue->rx_irq)
+				unbind_from_irqhandler(queue->tx_irq, queue);
+			else {
+				unbind_from_irqhandler(queue->tx_irq, queue);
+				unbind_from_irqhandler(queue->rx_irq, queue);
+			}
+			queue->tx_irq = 0;
+		}
+
+		xenvif_unmap_frontend_rings(queue);
 	}
 
-	xenvif_unmap_frontend_rings(vif);
+
 }
 
 void xenvif_free(struct xenvif *vif)
 {
-	netif_napi_del(&vif->napi);
+	struct xenvif_queue *queue = NULL;
+	unsigned int queue_index;
 
 	unregister_netdev(vif->dev);
 
-	vfree(vif->grant_copy_op);
+	for (queue_index = 0; queue_index < vif->num_queues; ++queue_index) {
+		queue = &vif->queues[queue_index];
+		netif_napi_del(&queue->napi);
+	}
+
+	/* Free the array of queues */
+	vif->num_queues = 0;
+	vfree(vif->queues);
+	vif->queues = NULL;
+
 	free_netdev(vif->dev);
 
 	module_put(THIS_MODULE);
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index e5284bc..a32abd6 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -75,38 +75,38 @@ module_param(fatal_skb_slots, uint, 0444);
  * one or more merged tx requests, otherwise it is the continuation of
  * previous tx request.
  */
-static inline int pending_tx_is_head(struct xenvif *vif, RING_IDX idx)
+static inline int pending_tx_is_head(struct xenvif_queue *queue, RING_IDX idx)
 {
-	return vif->pending_tx_info[idx].head != INVALID_PENDING_RING_IDX;
+	return queue->pending_tx_info[idx].head != INVALID_PENDING_RING_IDX;
 }
 
-static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx,
+static void xenvif_idx_release(struct xenvif_queue *queue, u16 pending_idx,
 			       u8 status);
 
-static void make_tx_response(struct xenvif *vif,
+static void make_tx_response(struct xenvif_queue *queue,
 			     struct xen_netif_tx_request *txp,
 			     s8       st);
 
-static inline int tx_work_todo(struct xenvif *vif);
-static inline int rx_work_todo(struct xenvif *vif);
+static inline int tx_work_todo(struct xenvif_queue *queue);
+static inline int rx_work_todo(struct xenvif_queue *queue);
 
-static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
+static struct xen_netif_rx_response *make_rx_response(struct xenvif_queue *queue,
 					     u16      id,
 					     s8       st,
 					     u16      offset,
 					     u16      size,
 					     u16      flags);
 
-static inline unsigned long idx_to_pfn(struct xenvif *vif,
+static inline unsigned long idx_to_pfn(struct xenvif_queue *queue,
 				       u16 idx)
 {
-	return page_to_pfn(vif->mmap_pages[idx]);
+	return page_to_pfn(queue->mmap_pages[idx]);
 }
 
-static inline unsigned long idx_to_kaddr(struct xenvif *vif,
+static inline unsigned long idx_to_kaddr(struct xenvif_queue *queue,
 					 u16 idx)
 {
-	return (unsigned long)pfn_to_kaddr(idx_to_pfn(vif, idx));
+	return (unsigned long)pfn_to_kaddr(idx_to_pfn(queue, idx));
 }
 
 /* This is a miniumum size for the linear area to avoid lots of
@@ -131,30 +131,30 @@ static inline pending_ring_idx_t pending_index(unsigned i)
 	return i & (MAX_PENDING_REQS-1);
 }
 
-static inline pending_ring_idx_t nr_pending_reqs(struct xenvif *vif)
+static inline pending_ring_idx_t nr_pending_reqs(struct xenvif_queue *queue)
 {
 	return MAX_PENDING_REQS -
-		vif->pending_prod + vif->pending_cons;
+		queue->pending_prod + queue->pending_cons;
 }
 
-bool xenvif_rx_ring_slots_available(struct xenvif *vif, int needed)
+bool xenvif_rx_ring_slots_available(struct xenvif_queue *queue, int needed)
 {
 	RING_IDX prod, cons;
 
 	do {
-		prod = vif->rx.sring->req_prod;
-		cons = vif->rx.req_cons;
+		prod = queue->rx.sring->req_prod;
+		cons = queue->rx.req_cons;
 
 		if (prod - cons >= needed)
 			return true;
 
-		vif->rx.sring->req_event = prod + 1;
+		queue->rx.sring->req_event = prod + 1;
 
 		/* Make sure event is visible before we check prod
 		 * again.
 		 */
 		mb();
-	} while (vif->rx.sring->req_prod != prod);
+	} while (queue->rx.sring->req_prod != prod);
 
 	return false;
 }
@@ -208,13 +208,13 @@ struct netrx_pending_operations {
 	grant_ref_t copy_gref;
 };
 
-static struct xenvif_rx_meta *get_next_rx_buffer(struct xenvif *vif,
+static struct xenvif_rx_meta *get_next_rx_buffer(struct xenvif_queue *queue,
 						 struct netrx_pending_operations *npo)
 {
 	struct xenvif_rx_meta *meta;
 	struct xen_netif_rx_request *req;
 
-	req = RING_GET_REQUEST(&vif->rx, vif->rx.req_cons++);
+	req = RING_GET_REQUEST(&queue->rx, queue->rx.req_cons++);
 
 	meta = npo->meta + npo->meta_prod++;
 	meta->gso_type = XEN_NETIF_GSO_TYPE_NONE;
@@ -232,7 +232,7 @@ static struct xenvif_rx_meta *get_next_rx_buffer(struct xenvif *vif,
  * Set up the grant operations for this fragment. If it's a flipping
  * interface, we also set up the unmap request from here.
  */
-static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
+static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb,
 				 struct netrx_pending_operations *npo,
 				 struct page *page, unsigned long size,
 				 unsigned long offset, int *head)
@@ -267,7 +267,7 @@ static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 			 */
 			BUG_ON(*head);
 
-			meta = get_next_rx_buffer(vif, npo);
+			meta = get_next_rx_buffer(queue, npo);
 		}
 
 		if (npo->copy_off + bytes > MAX_BUFFER_OFFSET)
@@ -281,7 +281,7 @@ static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 		copy_gop->source.u.gmfn = virt_to_mfn(page_address(page));
 		copy_gop->source.offset = offset;
 
-		copy_gop->dest.domid = vif->domid;
+		copy_gop->dest.domid = queue->vif->domid;
 		copy_gop->dest.offset = npo->copy_off;
 		copy_gop->dest.u.ref = npo->copy_gref;
 
@@ -306,8 +306,8 @@ static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 		else
 			gso_type = XEN_NETIF_GSO_TYPE_NONE;
 
-		if (*head && ((1 << gso_type) & vif->gso_mask))
-			vif->rx.req_cons++;
+		if (*head && ((1 << gso_type) & queue->vif->gso_mask))
+			queue->rx.req_cons++;
 
 		*head = 0; /* There must be something in this buffer now. */
 
@@ -327,7 +327,8 @@ static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
  * frontend-side LRO).
  */
 static int xenvif_gop_skb(struct sk_buff *skb,
-			  struct netrx_pending_operations *npo)
+			  struct netrx_pending_operations *npo,
+			  struct xenvif_queue *queue)
 {
 	struct xenvif *vif = netdev_priv(skb->dev);
 	int nr_frags = skb_shinfo(skb)->nr_frags;
@@ -355,7 +356,7 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 
 	/* Set up a GSO prefix descriptor, if necessary */
 	if ((1 << gso_type) & vif->gso_prefix_mask) {
-		req = RING_GET_REQUEST(&vif->rx, vif->rx.req_cons++);
+		req = RING_GET_REQUEST(&queue->rx, queue->rx.req_cons++);
 		meta = npo->meta + npo->meta_prod++;
 		meta->gso_type = gso_type;
 		meta->gso_size = gso_size;
@@ -363,7 +364,7 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 		meta->id = req->id;
 	}
 
-	req = RING_GET_REQUEST(&vif->rx, vif->rx.req_cons++);
+	req = RING_GET_REQUEST(&queue->rx, queue->rx.req_cons++);
 	meta = npo->meta + npo->meta_prod++;
 
 	if ((1 << gso_type) & vif->gso_mask) {
@@ -387,13 +388,13 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 		if (data + len > skb_tail_pointer(skb))
 			len = skb_tail_pointer(skb) - data;
 
-		xenvif_gop_frag_copy(vif, skb, npo,
+		xenvif_gop_frag_copy(queue, skb, npo,
 				     virt_to_page(data), len, offset, &head);
 		data += len;
 	}
 
 	for (i = 0; i < nr_frags; i++) {
-		xenvif_gop_frag_copy(vif, skb, npo,
+		xenvif_gop_frag_copy(queue, skb, npo,
 				     skb_frag_page(&skb_shinfo(skb)->frags[i]),
 				     skb_frag_size(&skb_shinfo(skb)->frags[i]),
 				     skb_shinfo(skb)->frags[i].page_offset,
@@ -429,7 +430,7 @@ static int xenvif_check_gop(struct xenvif *vif, int nr_meta_slots,
 	return status;
 }
 
-static void xenvif_add_frag_responses(struct xenvif *vif, int status,
+static void xenvif_add_frag_responses(struct xenvif_queue *queue, int status,
 				      struct xenvif_rx_meta *meta,
 				      int nr_meta_slots)
 {
@@ -450,7 +451,7 @@ static void xenvif_add_frag_responses(struct xenvif *vif, int status,
 			flags = XEN_NETRXF_more_data;
 
 		offset = 0;
-		make_rx_response(vif, meta[i].id, status, offset,
+		make_rx_response(queue, meta[i].id, status, offset,
 				 meta[i].size, flags);
 	}
 }
@@ -459,12 +460,12 @@ struct skb_cb_overlay {
 	int meta_slots_used;
 };
 
-void xenvif_kick_thread(struct xenvif *vif)
+void xenvif_kick_thread(struct xenvif_queue *queue)
 {
-	wake_up(&vif->wq);
+	wake_up(&queue->wq);
 }
 
-static void xenvif_rx_action(struct xenvif *vif)
+static void xenvif_rx_action(struct xenvif_queue *queue)
 {
 	s8 status;
 	u16 flags;
@@ -478,13 +479,13 @@ static void xenvif_rx_action(struct xenvif *vif)
 	bool need_to_notify = false;
 
 	struct netrx_pending_operations npo = {
-		.copy  = vif->grant_copy_op,
-		.meta  = vif->meta,
+		.copy  = queue->grant_copy_op,
+		.meta  = queue->meta,
 	};
 
 	skb_queue_head_init(&rxq);
 
-	while ((skb = skb_dequeue(&vif->rx_queue)) != NULL) {
+	while ((skb = skb_dequeue(&queue->rx_queue)) != NULL) {
 		RING_IDX max_slots_needed;
 		int i;
 
@@ -505,41 +506,41 @@ static void xenvif_rx_action(struct xenvif *vif)
 			max_slots_needed++;
 
 		/* If the skb may not fit then bail out now */
-		if (!xenvif_rx_ring_slots_available(vif, max_slots_needed)) {
-			skb_queue_head(&vif->rx_queue, skb);
+		if (!xenvif_rx_ring_slots_available(queue, max_slots_needed)) {
+			skb_queue_head(&queue->rx_queue, skb);
 			need_to_notify = true;
-			vif->rx_last_skb_slots = max_slots_needed;
+			queue->rx_last_skb_slots = max_slots_needed;
 			break;
 		} else
-			vif->rx_last_skb_slots = 0;
+			queue->rx_last_skb_slots = 0;
 
 		sco = (struct skb_cb_overlay *)skb->cb;
-		sco->meta_slots_used = xenvif_gop_skb(skb, &npo);
+		sco->meta_slots_used = xenvif_gop_skb(skb, &npo, queue);
 		BUG_ON(sco->meta_slots_used > max_slots_needed);
 
 		__skb_queue_tail(&rxq, skb);
 	}
 
-	BUG_ON(npo.meta_prod > ARRAY_SIZE(vif->meta));
+	BUG_ON(npo.meta_prod > ARRAY_SIZE(queue->meta));
 
 	if (!npo.copy_prod)
 		goto done;
 
 	BUG_ON(npo.copy_prod > MAX_GRANT_COPY_OPS);
-	gnttab_batch_copy(vif->grant_copy_op, npo.copy_prod);
+	gnttab_batch_copy(queue->grant_copy_op, npo.copy_prod);
 
 	while ((skb = __skb_dequeue(&rxq)) != NULL) {
 		sco = (struct skb_cb_overlay *)skb->cb;
 
-		if ((1 << vif->meta[npo.meta_cons].gso_type) &
-		    vif->gso_prefix_mask) {
-			resp = RING_GET_RESPONSE(&vif->rx,
-						 vif->rx.rsp_prod_pvt++);
+		if ((1 << queue->meta[npo.meta_cons].gso_type) &
+		    queue->vif->gso_prefix_mask) {
+			resp = RING_GET_RESPONSE(&queue->rx,
+						 queue->rx.rsp_prod_pvt++);
 
 			resp->flags = XEN_NETRXF_gso_prefix | XEN_NETRXF_more_data;
 
-			resp->offset = vif->meta[npo.meta_cons].gso_size;
-			resp->id = vif->meta[npo.meta_cons].id;
+			resp->offset = queue->meta[npo.meta_cons].gso_size;
+			resp->id = queue->meta[npo.meta_cons].id;
 			resp->status = sco->meta_slots_used;
 
 			npo.meta_cons++;
@@ -547,10 +548,10 @@ static void xenvif_rx_action(struct xenvif *vif)
 		}
 
 
-		vif->dev->stats.tx_bytes += skb->len;
-		vif->dev->stats.tx_packets++;
+		queue->stats.tx_bytes += skb->len;
+		queue->stats.tx_packets++;
 
-		status = xenvif_check_gop(vif, sco->meta_slots_used, &npo);
+		status = xenvif_check_gop(queue->vif, sco->meta_slots_used, &npo);
 
 		if (sco->meta_slots_used == 1)
 			flags = 0;
@@ -564,22 +565,22 @@ static void xenvif_rx_action(struct xenvif *vif)
 			flags |= XEN_NETRXF_data_validated;
 
 		offset = 0;
-		resp = make_rx_response(vif, vif->meta[npo.meta_cons].id,
+		resp = make_rx_response(queue, queue->meta[npo.meta_cons].id,
 					status, offset,
-					vif->meta[npo.meta_cons].size,
+					queue->meta[npo.meta_cons].size,
 					flags);
 
-		if ((1 << vif->meta[npo.meta_cons].gso_type) &
-		    vif->gso_mask) {
+		if ((1 << queue->meta[npo.meta_cons].gso_type) &
+		    queue->vif->gso_mask) {
 			struct xen_netif_extra_info *gso =
 				(struct xen_netif_extra_info *)
-				RING_GET_RESPONSE(&vif->rx,
-						  vif->rx.rsp_prod_pvt++);
+				RING_GET_RESPONSE(&queue->rx,
+						  queue->rx.rsp_prod_pvt++);
 
 			resp->flags |= XEN_NETRXF_extra_info;
 
-			gso->u.gso.type = vif->meta[npo.meta_cons].gso_type;
-			gso->u.gso.size = vif->meta[npo.meta_cons].gso_size;
+			gso->u.gso.type = queue->meta[npo.meta_cons].gso_type;
+			gso->u.gso.size = queue->meta[npo.meta_cons].gso_size;
 			gso->u.gso.pad = 0;
 			gso->u.gso.features = 0;
 
@@ -587,11 +588,11 @@ static void xenvif_rx_action(struct xenvif *vif)
 			gso->flags = 0;
 		}
 
-		xenvif_add_frag_responses(vif, status,
-					  vif->meta + npo.meta_cons + 1,
+		xenvif_add_frag_responses(queue, status,
+					  queue->meta + npo.meta_cons + 1,
 					  sco->meta_slots_used);
 
-		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->rx, ret);
+		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&queue->rx, ret);
 
 		need_to_notify |= !!ret;
 
@@ -601,20 +602,20 @@ static void xenvif_rx_action(struct xenvif *vif)
 
 done:
 	if (need_to_notify)
-		notify_remote_via_irq(vif->rx_irq);
+		notify_remote_via_irq(queue->rx_irq);
 }
 
-void xenvif_check_rx_xenvif(struct xenvif *vif)
+void xenvif_check_rx_xenvif(struct xenvif_queue *queue)
 {
 	int more_to_do;
 
-	RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, more_to_do);
+	RING_FINAL_CHECK_FOR_REQUESTS(&queue->tx, more_to_do);
 
 	if (more_to_do)
-		napi_schedule(&vif->napi);
+		napi_schedule(&queue->napi);
 }
 
-static void tx_add_credit(struct xenvif *vif)
+static void tx_add_credit(struct xenvif_queue *queue)
 {
 	unsigned long max_burst, max_credit;
 
@@ -622,37 +623,37 @@ static void tx_add_credit(struct xenvif *vif)
 	 * Allow a burst big enough to transmit a jumbo packet of up to 128kB.
 	 * Otherwise the interface can seize up due to insufficient credit.
 	 */
-	max_burst = RING_GET_REQUEST(&vif->tx, vif->tx.req_cons)->size;
+	max_burst = RING_GET_REQUEST(&queue->tx, queue->tx.req_cons)->size;
 	max_burst = min(max_burst, 131072UL);
-	max_burst = max(max_burst, vif->credit_bytes);
+	max_burst = max(max_burst, queue->credit_bytes);
 
 	/* Take care that adding a new chunk of credit doesn't wrap to zero. */
-	max_credit = vif->remaining_credit + vif->credit_bytes;
-	if (max_credit < vif->remaining_credit)
+	max_credit = queue->remaining_credit + queue->credit_bytes;
+	if (max_credit < queue->remaining_credit)
 		max_credit = ULONG_MAX; /* wrapped: clamp to ULONG_MAX */
 
-	vif->remaining_credit = min(max_credit, max_burst);
+	queue->remaining_credit = min(max_credit, max_burst);
 }
 
 static void tx_credit_callback(unsigned long data)
 {
-	struct xenvif *vif = (struct xenvif *)data;
-	tx_add_credit(vif);
-	xenvif_check_rx_xenvif(vif);
+	struct xenvif_queue *queue = (struct xenvif_queue *)data;
+	tx_add_credit(queue);
+	xenvif_check_rx_xenvif(queue);
 }
 
-static void xenvif_tx_err(struct xenvif *vif,
+static void xenvif_tx_err(struct xenvif_queue *queue,
 			  struct xen_netif_tx_request *txp, RING_IDX end)
 {
-	RING_IDX cons = vif->tx.req_cons;
+	RING_IDX cons = queue->tx.req_cons;
 
 	do {
-		make_tx_response(vif, txp, XEN_NETIF_RSP_ERROR);
+		make_tx_response(queue, txp, XEN_NETIF_RSP_ERROR);
 		if (cons == end)
 			break;
-		txp = RING_GET_REQUEST(&vif->tx, cons++);
+		txp = RING_GET_REQUEST(&queue->tx, cons++);
 	} while (1);
-	vif->tx.req_cons = cons;
+	queue->tx.req_cons = cons;
 }
 
 static void xenvif_fatal_tx_err(struct xenvif *vif)
@@ -661,12 +662,12 @@ static void xenvif_fatal_tx_err(struct xenvif *vif)
 	xenvif_carrier_off(vif);
 }
 
-static int xenvif_count_requests(struct xenvif *vif,
+static int xenvif_count_requests(struct xenvif_queue *queue,
 				 struct xen_netif_tx_request *first,
 				 struct xen_netif_tx_request *txp,
 				 int work_to_do)
 {
-	RING_IDX cons = vif->tx.req_cons;
+	RING_IDX cons = queue->tx.req_cons;
 	int slots = 0;
 	int drop_err = 0;
 	int more_data;
@@ -678,10 +679,10 @@ static int xenvif_count_requests(struct xenvif *vif,
 		struct xen_netif_tx_request dropped_tx = { 0 };
 
 		if (slots >= work_to_do) {
-			netdev_err(vif->dev,
+			netdev_err(queue->vif->dev,
 				   "Asked for %d slots but exceeds this limit\n",
 				   work_to_do);
-			xenvif_fatal_tx_err(vif);
+			xenvif_fatal_tx_err(queue->vif);
 			return -ENODATA;
 		}
 
@@ -689,10 +690,10 @@ static int xenvif_count_requests(struct xenvif *vif,
 		 * considered malicious.
 		 */
 		if (unlikely(slots >= fatal_skb_slots)) {
-			netdev_err(vif->dev,
+			netdev_err(queue->vif->dev,
 				   "Malicious frontend using %d slots, threshold %u\n",
 				   slots, fatal_skb_slots);
-			xenvif_fatal_tx_err(vif);
+			xenvif_fatal_tx_err(queue->vif);
 			return -E2BIG;
 		}
 
@@ -705,7 +706,7 @@ static int xenvif_count_requests(struct xenvif *vif,
 		 */
 		if (!drop_err && slots >= XEN_NETBK_LEGACY_SLOTS_MAX) {
 			if (net_ratelimit())
-				netdev_dbg(vif->dev,
+				netdev_dbg(queue->vif->dev,
 					   "Too many slots (%d) exceeding limit (%d), dropping packet\n",
 					   slots, XEN_NETBK_LEGACY_SLOTS_MAX);
 			drop_err = -E2BIG;
@@ -714,7 +715,7 @@ static int xenvif_count_requests(struct xenvif *vif,
 		if (drop_err)
 			txp = &dropped_tx;
 
-		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + slots),
+		memcpy(txp, RING_GET_REQUEST(&queue->tx, cons + slots),
 		       sizeof(*txp));
 
 		/* If the guest submitted a frame >= 64 KiB then
@@ -728,7 +729,7 @@ static int xenvif_count_requests(struct xenvif *vif,
 		 */
 		if (!drop_err && txp->size > first->size) {
 			if (net_ratelimit())
-				netdev_dbg(vif->dev,
+				netdev_dbg(queue->vif->dev,
 					   "Invalid tx request, slot size %u > remaining size %u\n",
 					   txp->size, first->size);
 			drop_err = -EIO;
@@ -738,9 +739,9 @@ static int xenvif_count_requests(struct xenvif *vif,
 		slots++;
 
 		if (unlikely((txp->offset + txp->size) > PAGE_SIZE)) {
-			netdev_err(vif->dev, "Cross page boundary, txp->offset: %x, size: %u\n",
+			netdev_err(queue->vif->dev, "Cross page boundary, txp->offset: %x, size: %u\n",
 				 txp->offset, txp->size);
-			xenvif_fatal_tx_err(vif);
+			xenvif_fatal_tx_err(queue->vif);
 			return -EINVAL;
 		}
 
@@ -752,14 +753,14 @@ static int xenvif_count_requests(struct xenvif *vif,
 	} while (more_data);
 
 	if (drop_err) {
-		xenvif_tx_err(vif, first, cons + slots);
+		xenvif_tx_err(queue, first, cons + slots);
 		return drop_err;
 	}
 
 	return slots;
 }
 
-static struct page *xenvif_alloc_page(struct xenvif *vif,
+static struct page *xenvif_alloc_page(struct xenvif_queue *queue,
 				      u16 pending_idx)
 {
 	struct page *page;
@@ -767,12 +768,12 @@ static struct page *xenvif_alloc_page(struct xenvif *vif,
 	page = alloc_page(GFP_ATOMIC|__GFP_COLD);
 	if (!page)
 		return NULL;
-	vif->mmap_pages[pending_idx] = page;
+	queue->mmap_pages[pending_idx] = page;
 
 	return page;
 }
 
-static struct gnttab_copy *xenvif_get_requests(struct xenvif *vif,
+static struct gnttab_copy *xenvif_get_requests(struct xenvif_queue *queue,
 					       struct sk_buff *skb,
 					       struct xen_netif_tx_request *txp,
 					       struct gnttab_copy *gop)
@@ -803,7 +804,7 @@ static struct gnttab_copy *xenvif_get_requests(struct xenvif *vif,
 	for (shinfo->nr_frags = slot = start; slot < nr_slots;
 	     shinfo->nr_frags++) {
 		struct pending_tx_info *pending_tx_info =
-			vif->pending_tx_info;
+			queue->pending_tx_info;
 
 		page = alloc_page(GFP_ATOMIC|__GFP_COLD);
 		if (!page)
@@ -815,7 +816,7 @@ static struct gnttab_copy *xenvif_get_requests(struct xenvif *vif,
 			gop->flags = GNTCOPY_source_gref;
 
 			gop->source.u.ref = txp->gref;
-			gop->source.domid = vif->domid;
+			gop->source.domid = queue->vif->domid;
 			gop->source.offset = txp->offset;
 
 			gop->dest.domid = DOMID_SELF;
@@ -840,9 +841,9 @@ static struct gnttab_copy *xenvif_get_requests(struct xenvif *vif,
 				gop->len = txp->size;
 				dst_offset += gop->len;
 
-				index = pending_index(vif->pending_cons++);
+				index = pending_index(queue->pending_cons++);
 
-				pending_idx = vif->pending_ring[index];
+				pending_idx = queue->pending_ring[index];
 
 				memcpy(&pending_tx_info[pending_idx].req, txp,
 				       sizeof(*txp));
@@ -851,7 +852,7 @@ static struct gnttab_copy *xenvif_get_requests(struct xenvif *vif,
 				 * fields for head tx req will be set
 				 * to correct values after the loop.
 				 */
-				vif->mmap_pages[pending_idx] = (void *)(~0UL);
+				queue->mmap_pages[pending_idx] = (void *)(~0UL);
 				pending_tx_info[pending_idx].head =
 					INVALID_PENDING_RING_IDX;
 
@@ -871,7 +872,7 @@ static struct gnttab_copy *xenvif_get_requests(struct xenvif *vif,
 		first->req.offset = 0;
 		first->req.size = dst_offset;
 		first->head = start_idx;
-		vif->mmap_pages[head_idx] = page;
+		queue->mmap_pages[head_idx] = page;
 		frag_set_pending_idx(&frags[shinfo->nr_frags], head_idx);
 	}
 
@@ -881,18 +882,18 @@ static struct gnttab_copy *xenvif_get_requests(struct xenvif *vif,
 err:
 	/* Unwind, freeing all pages and sending error responses. */
 	while (shinfo->nr_frags-- > start) {
-		xenvif_idx_release(vif,
+		xenvif_idx_release(queue,
 				frag_get_pending_idx(&frags[shinfo->nr_frags]),
 				XEN_NETIF_RSP_ERROR);
 	}
 	/* The head too, if necessary. */
 	if (start)
-		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_ERROR);
+		xenvif_idx_release(queue, pending_idx, XEN_NETIF_RSP_ERROR);
 
 	return NULL;
 }
 
-static int xenvif_tx_check_gop(struct xenvif *vif,
+static int xenvif_tx_check_gop(struct xenvif_queue *queue,
 			       struct sk_buff *skb,
 			       struct gnttab_copy **gopp)
 {
@@ -907,7 +908,7 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 	/* Check status of header. */
 	err = gop->status;
 	if (unlikely(err))
-		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_ERROR);
+		xenvif_idx_release(queue, pending_idx, XEN_NETIF_RSP_ERROR);
 
 	/* Skip first skb fragment if it is on same page as header fragment. */
 	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
@@ -917,7 +918,7 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 		pending_ring_idx_t head;
 
 		pending_idx = frag_get_pending_idx(&shinfo->frags[i]);
-		tx_info = &vif->pending_tx_info[pending_idx];
+		tx_info = &queue->pending_tx_info[pending_idx];
 		head = tx_info->head;
 
 		/* Check error status: if okay then remember grant handle. */
@@ -925,19 +926,19 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 			newerr = (++gop)->status;
 			if (newerr)
 				break;
-			peek = vif->pending_ring[pending_index(++head)];
-		} while (!pending_tx_is_head(vif, peek));
+			peek = queue->pending_ring[pending_index(++head)];
+		} while (!pending_tx_is_head(queue, peek));
 
 		if (likely(!newerr)) {
 			/* Had a previous error? Invalidate this fragment. */
 			if (unlikely(err))
-				xenvif_idx_release(vif, pending_idx,
+				xenvif_idx_release(queue, pending_idx,
 						   XEN_NETIF_RSP_OKAY);
 			continue;
 		}
 
 		/* Error on this fragment: respond to client with an error. */
-		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_ERROR);
+		xenvif_idx_release(queue, pending_idx, XEN_NETIF_RSP_ERROR);
 
 		/* Not the first error? Preceding frags already invalidated. */
 		if (err)
@@ -945,10 +946,10 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 
 		/* First error: invalidate header and preceding fragments. */
 		pending_idx = *((u16 *)skb->data);
-		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_OKAY);
+		xenvif_idx_release(queue, pending_idx, XEN_NETIF_RSP_OKAY);
 		for (j = start; j < i; j++) {
 			pending_idx = frag_get_pending_idx(&shinfo->frags[j]);
-			xenvif_idx_release(vif, pending_idx,
+			xenvif_idx_release(queue, pending_idx,
 					   XEN_NETIF_RSP_OKAY);
 		}
 
@@ -960,7 +961,7 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 	return err;
 }
 
-static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
+static void xenvif_fill_frags(struct xenvif_queue *queue, struct sk_buff *skb)
 {
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	int nr_frags = shinfo->nr_frags;
@@ -974,46 +975,46 @@ static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
 
 		pending_idx = frag_get_pending_idx(frag);
 
-		txp = &vif->pending_tx_info[pending_idx].req;
-		page = virt_to_page(idx_to_kaddr(vif, pending_idx));
+		txp = &queue->pending_tx_info[pending_idx].req;
+		page = virt_to_page(idx_to_kaddr(queue, pending_idx));
 		__skb_fill_page_desc(skb, i, page, txp->offset, txp->size);
 		skb->len += txp->size;
 		skb->data_len += txp->size;
 		skb->truesize += txp->size;
 
 		/* Take an extra reference to offset xenvif_idx_release */
-		get_page(vif->mmap_pages[pending_idx]);
-		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_OKAY);
+		get_page(queue->mmap_pages[pending_idx]);
+		xenvif_idx_release(queue, pending_idx, XEN_NETIF_RSP_OKAY);
 	}
 }
 
-static int xenvif_get_extras(struct xenvif *vif,
+static int xenvif_get_extras(struct xenvif_queue *queue,
 				struct xen_netif_extra_info *extras,
 				int work_to_do)
 {
 	struct xen_netif_extra_info extra;
-	RING_IDX cons = vif->tx.req_cons;
+	RING_IDX cons = queue->tx.req_cons;
 
 	do {
 		if (unlikely(work_to_do-- <= 0)) {
-			netdev_err(vif->dev, "Missing extra info\n");
-			xenvif_fatal_tx_err(vif);
+			netdev_err(queue->vif->dev, "Missing extra info\n");
+			xenvif_fatal_tx_err(queue->vif);
 			return -EBADR;
 		}
 
-		memcpy(&extra, RING_GET_REQUEST(&vif->tx, cons),
+		memcpy(&extra, RING_GET_REQUEST(&queue->tx, cons),
 		       sizeof(extra));
 		if (unlikely(!extra.type ||
 			     extra.type >= XEN_NETIF_EXTRA_TYPE_MAX)) {
-			vif->tx.req_cons = ++cons;
-			netdev_err(vif->dev,
+			queue->tx.req_cons = ++cons;
+			netdev_err(queue->vif->dev,
 				   "Invalid extra type: %d\n", extra.type);
-			xenvif_fatal_tx_err(vif);
+			xenvif_fatal_tx_err(queue->vif);
 			return -EINVAL;
 		}
 
 		memcpy(&extras[extra.type - 1], &extra, sizeof(extra));
-		vif->tx.req_cons = ++cons;
+		queue->tx.req_cons = ++cons;
 	} while (extra.flags & XEN_NETIF_EXTRA_FLAG_MORE);
 
 	return work_to_do;
@@ -1048,7 +1049,7 @@ static int xenvif_set_skb_gso(struct xenvif *vif,
 	return 0;
 }
 
-static int checksum_setup(struct xenvif *vif, struct sk_buff *skb)
+static int checksum_setup(struct xenvif_queue *queue, struct sk_buff *skb)
 {
 	bool recalculate_partial_csum = false;
 
@@ -1058,7 +1059,7 @@ static int checksum_setup(struct xenvif *vif, struct sk_buff *skb)
 	 * recalculate the partial checksum.
 	 */
 	if (skb->ip_summed != CHECKSUM_PARTIAL && skb_is_gso(skb)) {
-		vif->rx_gso_checksum_fixup++;
+		queue->stats.rx_gso_checksum_fixup++;
 		skb->ip_summed = CHECKSUM_PARTIAL;
 		recalculate_partial_csum = true;
 	}
@@ -1070,31 +1071,31 @@ static int checksum_setup(struct xenvif *vif, struct sk_buff *skb)
 	return skb_checksum_setup(skb, recalculate_partial_csum);
 }
 
-static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
+static bool tx_credit_exceeded(struct xenvif_queue *queue, unsigned size)
 {
 	u64 now = get_jiffies_64();
-	u64 next_credit = vif->credit_window_start +
-		msecs_to_jiffies(vif->credit_usec / 1000);
+	u64 next_credit = queue->credit_window_start +
+		msecs_to_jiffies(queue->credit_usec / 1000);
 
 	/* Timer could already be pending in rare cases. */
-	if (timer_pending(&vif->credit_timeout))
+	if (timer_pending(&queue->credit_timeout))
 		return true;
 
 	/* Passed the point where we can replenish credit? */
 	if (time_after_eq64(now, next_credit)) {
-		vif->credit_window_start = now;
-		tx_add_credit(vif);
+		queue->credit_window_start = now;
+		tx_add_credit(queue);
 	}
 
 	/* Still too big to send right now? Set a callback. */
-	if (size > vif->remaining_credit) {
-		vif->credit_timeout.data     =
-			(unsigned long)vif;
-		vif->credit_timeout.function =
+	if (size > queue->remaining_credit) {
+		queue->credit_timeout.data     =
+			(unsigned long)queue;
+		queue->credit_timeout.function =
 			tx_credit_callback;
-		mod_timer(&vif->credit_timeout,
+		mod_timer(&queue->credit_timeout,
 			  next_credit);
-		vif->credit_window_start = next_credit;
+		queue->credit_window_start = next_credit;
 
 		return true;
 	}
@@ -1102,15 +1103,15 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
 	return false;
 }
 
-static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
+static unsigned xenvif_tx_build_gops(struct xenvif_queue *queue, int budget)
 {
-	struct gnttab_copy *gop = vif->tx_copy_ops, *request_gop;
+	struct gnttab_copy *gop = queue->tx_copy_ops, *request_gop;
 	struct sk_buff *skb;
 	int ret;
 
-	while ((nr_pending_reqs(vif) + XEN_NETBK_LEGACY_SLOTS_MAX
+	while ((nr_pending_reqs(queue) + XEN_NETBK_LEGACY_SLOTS_MAX
 		< MAX_PENDING_REQS) &&
-	       (skb_queue_len(&vif->tx_queue) < budget)) {
+	       (skb_queue_len(&queue->tx_queue) < budget)) {
 		struct xen_netif_tx_request txreq;
 		struct xen_netif_tx_request txfrags[XEN_NETBK_LEGACY_SLOTS_MAX];
 		struct page *page;
@@ -1121,69 +1122,69 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
 		unsigned int data_len;
 		pending_ring_idx_t index;
 
-		if (vif->tx.sring->req_prod - vif->tx.req_cons >
+		if (queue->tx.sring->req_prod - queue->tx.req_cons >
 		    XEN_NETIF_TX_RING_SIZE) {
-			netdev_err(vif->dev,
+			netdev_err(queue->vif->dev,
 				   "Impossible number of requests. "
 				   "req_prod %d, req_cons %d, size %ld\n",
-				   vif->tx.sring->req_prod, vif->tx.req_cons,
+				   queue->tx.sring->req_prod, queue->tx.req_cons,
 				   XEN_NETIF_TX_RING_SIZE);
-			xenvif_fatal_tx_err(vif);
+			xenvif_fatal_tx_err(queue->vif);
 			continue;
 		}
 
-		work_to_do = RING_HAS_UNCONSUMED_REQUESTS(&vif->tx);
+		work_to_do = RING_HAS_UNCONSUMED_REQUESTS(&queue->tx);
 		if (!work_to_do)
 			break;
 
-		idx = vif->tx.req_cons;
+		idx = queue->tx.req_cons;
 		rmb(); /* Ensure that we see the request before we copy it. */
-		memcpy(&txreq, RING_GET_REQUEST(&vif->tx, idx), sizeof(txreq));
+		memcpy(&txreq, RING_GET_REQUEST(&queue->tx, idx), sizeof(txreq));
 
 		/* Credit-based scheduling. */
-		if (txreq.size > vif->remaining_credit &&
-		    tx_credit_exceeded(vif, txreq.size))
+		if (txreq.size > queue->remaining_credit &&
+		    tx_credit_exceeded(queue, txreq.size))
 			break;
 
-		vif->remaining_credit -= txreq.size;
+		queue->remaining_credit -= txreq.size;
 
 		work_to_do--;
-		vif->tx.req_cons = ++idx;
+		queue->tx.req_cons = ++idx;
 
 		memset(extras, 0, sizeof(extras));
 		if (txreq.flags & XEN_NETTXF_extra_info) {
-			work_to_do = xenvif_get_extras(vif, extras,
+			work_to_do = xenvif_get_extras(queue, extras,
 						       work_to_do);
-			idx = vif->tx.req_cons;
+			idx = queue->tx.req_cons;
 			if (unlikely(work_to_do < 0))
 				break;
 		}
 
-		ret = xenvif_count_requests(vif, &txreq, txfrags, work_to_do);
+		ret = xenvif_count_requests(queue, &txreq, txfrags, work_to_do);
 		if (unlikely(ret < 0))
 			break;
 
 		idx += ret;
 
 		if (unlikely(txreq.size < ETH_HLEN)) {
-			netdev_dbg(vif->dev,
+			netdev_dbg(queue->vif->dev,
 				   "Bad packet size: %d\n", txreq.size);
-			xenvif_tx_err(vif, &txreq, idx);
+			xenvif_tx_err(queue, &txreq, idx);
 			break;
 		}
 
 		/* No crossing a page as the payload mustn't fragment. */
 		if (unlikely((txreq.offset + txreq.size) > PAGE_SIZE)) {
-			netdev_err(vif->dev,
+			netdev_err(queue->vif->dev,
 				   "txreq.offset: %x, size: %u, end: %lu\n",
 				   txreq.offset, txreq.size,
 				   (txreq.offset&~PAGE_MASK) + txreq.size);
-			xenvif_fatal_tx_err(vif);
+			xenvif_fatal_tx_err(queue->vif);
 			break;
 		}
 
-		index = pending_index(vif->pending_cons);
-		pending_idx = vif->pending_ring[index];
+		index = pending_index(queue->pending_cons);
+		pending_idx = queue->pending_ring[index];
 
 		data_len = (txreq.size > PKT_PROT_LEN &&
 			    ret < XEN_NETBK_LEGACY_SLOTS_MAX) ?
@@ -1192,9 +1193,9 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
 		skb = alloc_skb(data_len + NET_SKB_PAD + NET_IP_ALIGN,
 				GFP_ATOMIC | __GFP_NOWARN);
 		if (unlikely(skb == NULL)) {
-			netdev_dbg(vif->dev,
+			netdev_dbg(queue->vif->dev,
 				   "Can't allocate a skb in start_xmit.\n");
-			xenvif_tx_err(vif, &txreq, idx);
+			xenvif_tx_err(queue, &txreq, idx);
 			break;
 		}
 
@@ -1205,7 +1206,7 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
 			struct xen_netif_extra_info *gso;
 			gso = &extras[XEN_NETIF_EXTRA_TYPE_GSO - 1];
 
-			if (xenvif_set_skb_gso(vif, skb, gso)) {
+			if (xenvif_set_skb_gso(queue->vif, skb, gso)) {
 				/* Failure in xenvif_set_skb_gso is fatal. */
 				kfree_skb(skb);
 				break;
@@ -1213,15 +1214,15 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
 		}
 
 		/* XXX could copy straight to head */
-		page = xenvif_alloc_page(vif, pending_idx);
+		page = xenvif_alloc_page(queue, pending_idx);
 		if (!page) {
 			kfree_skb(skb);
-			xenvif_tx_err(vif, &txreq, idx);
+			xenvif_tx_err(queue, &txreq, idx);
 			break;
 		}
 
 		gop->source.u.ref = txreq.gref;
-		gop->source.domid = vif->domid;
+		gop->source.domid = queue->vif->domid;
 		gop->source.offset = txreq.offset;
 
 		gop->dest.u.gmfn = virt_to_mfn(page_address(page));
@@ -1233,9 +1234,9 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
 
 		gop++;
 
-		memcpy(&vif->pending_tx_info[pending_idx].req,
+		memcpy(&queue->pending_tx_info[pending_idx].req,
 		       &txreq, sizeof(txreq));
-		vif->pending_tx_info[pending_idx].head = index;
+		queue->pending_tx_info[pending_idx].head = index;
 		*((u16 *)skb->data) = pending_idx;
 
 		__skb_put(skb, data_len);
@@ -1250,45 +1251,45 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
 					     INVALID_PENDING_IDX);
 		}
 
-		vif->pending_cons++;
+		queue->pending_cons++;
 
-		request_gop = xenvif_get_requests(vif, skb, txfrags, gop);
+		request_gop = xenvif_get_requests(queue, skb, txfrags, gop);
 		if (request_gop == NULL) {
 			kfree_skb(skb);
-			xenvif_tx_err(vif, &txreq, idx);
+			xenvif_tx_err(queue, &txreq, idx);
 			break;
 		}
 		gop = request_gop;
 
-		__skb_queue_tail(&vif->tx_queue, skb);
+		__skb_queue_tail(&queue->tx_queue, skb);
 
-		vif->tx.req_cons = idx;
+		queue->tx.req_cons = idx;
 
-		if ((gop-vif->tx_copy_ops) >= ARRAY_SIZE(vif->tx_copy_ops))
+		if ((gop - queue->tx_copy_ops) >= ARRAY_SIZE(queue->tx_copy_ops))
 			break;
 	}
 
-	return gop - vif->tx_copy_ops;
+	return gop - queue->tx_copy_ops;
 }
 
 
-static int xenvif_tx_submit(struct xenvif *vif)
+static int xenvif_tx_submit(struct xenvif_queue *queue)
 {
-	struct gnttab_copy *gop = vif->tx_copy_ops;
+	struct gnttab_copy *gop = queue->tx_copy_ops;
 	struct sk_buff *skb;
 	int work_done = 0;
 
-	while ((skb = __skb_dequeue(&vif->tx_queue)) != NULL) {
+	while ((skb = __skb_dequeue(&queue->tx_queue)) != NULL) {
 		struct xen_netif_tx_request *txp;
 		u16 pending_idx;
 		unsigned data_len;
 
 		pending_idx = *((u16 *)skb->data);
-		txp = &vif->pending_tx_info[pending_idx].req;
+		txp = &queue->pending_tx_info[pending_idx].req;
 
 		/* Check the remap error code. */
-		if (unlikely(xenvif_tx_check_gop(vif, skb, &gop))) {
-			netdev_dbg(vif->dev, "netback grant failed.\n");
+		if (unlikely(xenvif_tx_check_gop(queue, skb, &gop))) {
+			netdev_dbg(queue->vif->dev, "netback grant failed.\n");
 			skb_shinfo(skb)->nr_frags = 0;
 			kfree_skb(skb);
 			continue;
@@ -1296,7 +1297,7 @@ static int xenvif_tx_submit(struct xenvif *vif)
 
 		data_len = skb->len;
 		memcpy(skb->data,
-		       (void *)(idx_to_kaddr(vif, pending_idx)|txp->offset),
+		       (void *)(idx_to_kaddr(queue, pending_idx)|txp->offset),
 		       data_len);
 		if (data_len < txp->size) {
 			/* Append the packet payload as a fragment. */
@@ -1304,7 +1305,7 @@ static int xenvif_tx_submit(struct xenvif *vif)
 			txp->size -= data_len;
 		} else {
 			/* Schedule a response immediately. */
-			xenvif_idx_release(vif, pending_idx,
+			xenvif_idx_release(queue, pending_idx,
 					   XEN_NETIF_RSP_OKAY);
 		}
 
@@ -1313,19 +1314,19 @@ static int xenvif_tx_submit(struct xenvif *vif)
 		else if (txp->flags & XEN_NETTXF_data_validated)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-		xenvif_fill_frags(vif, skb);
+		xenvif_fill_frags(queue, skb);
 
 		if (skb_is_nonlinear(skb) && skb_headlen(skb) < PKT_PROT_LEN) {
 			int target = min_t(int, skb->len, PKT_PROT_LEN);
 			__pskb_pull_tail(skb, target - skb_headlen(skb));
 		}
 
-		skb->dev      = vif->dev;
+		skb->dev      = queue->vif->dev;
 		skb->protocol = eth_type_trans(skb, skb->dev);
 		skb_reset_network_header(skb);
 
-		if (checksum_setup(vif, skb)) {
-			netdev_dbg(vif->dev,
+		if (checksum_setup(queue, skb)) {
+			netdev_dbg(queue->vif->dev,
 				   "Can't setup checksum in net_tx_action\n");
 			kfree_skb(skb);
 			continue;
@@ -1347,8 +1348,8 @@ static int xenvif_tx_submit(struct xenvif *vif)
 				DIV_ROUND_UP(skb->len - hdrlen, mss);
 		}
 
-		vif->dev->stats.rx_bytes += skb->len;
-		vif->dev->stats.rx_packets++;
+		queue->stats.rx_bytes += skb->len;
+		queue->stats.rx_packets++;
 
 		work_done++;
 
@@ -1359,53 +1360,53 @@ static int xenvif_tx_submit(struct xenvif *vif)
 }
 
 /* Called after netfront has transmitted */
-int xenvif_tx_action(struct xenvif *vif, int budget)
+int xenvif_tx_action(struct xenvif_queue *queue, int budget)
 {
 	unsigned nr_gops;
 	int work_done;
 
-	if (unlikely(!tx_work_todo(vif)))
+	if (unlikely(!tx_work_todo(queue)))
 		return 0;
 
-	nr_gops = xenvif_tx_build_gops(vif, budget);
+	nr_gops = xenvif_tx_build_gops(queue, budget);
 
 	if (nr_gops == 0)
 		return 0;
 
-	gnttab_batch_copy(vif->tx_copy_ops, nr_gops);
+	gnttab_batch_copy(queue->tx_copy_ops, nr_gops);
 
-	work_done = xenvif_tx_submit(vif);
+	work_done = xenvif_tx_submit(queue);
 
 	return work_done;
 }
 
-static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx,
+static void xenvif_idx_release(struct xenvif_queue *queue, u16 pending_idx,
 			       u8 status)
 {
 	struct pending_tx_info *pending_tx_info;
 	pending_ring_idx_t head;
 	u16 peek; /* peek into next tx request */
 
-	BUG_ON(vif->mmap_pages[pending_idx] == (void *)(~0UL));
+	BUG_ON(queue->mmap_pages[pending_idx] == (void *)(~0UL));
 
 	/* Already complete? */
-	if (vif->mmap_pages[pending_idx] == NULL)
+	if (queue->mmap_pages[pending_idx] == NULL)
 		return;
 
-	pending_tx_info = &vif->pending_tx_info[pending_idx];
+	pending_tx_info = &queue->pending_tx_info[pending_idx];
 
 	head = pending_tx_info->head;
 
-	BUG_ON(!pending_tx_is_head(vif, head));
-	BUG_ON(vif->pending_ring[pending_index(head)] != pending_idx);
+	BUG_ON(!pending_tx_is_head(queue, head));
+	BUG_ON(queue->pending_ring[pending_index(head)] != pending_idx);
 
 	do {
 		pending_ring_idx_t index;
 		pending_ring_idx_t idx = pending_index(head);
-		u16 info_idx = vif->pending_ring[idx];
+		u16 info_idx = queue->pending_ring[idx];
 
-		pending_tx_info = &vif->pending_tx_info[info_idx];
-		make_tx_response(vif, &pending_tx_info->req, status);
+		pending_tx_info = &queue->pending_tx_info[info_idx];
+		make_tx_response(queue, &pending_tx_info->req, status);
 
 		/* Setting any number other than
 		 * INVALID_PENDING_RING_IDX indicates this slot is
@@ -1413,50 +1414,50 @@ static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx,
 		 */
 		pending_tx_info->head = 0;
 
-		index = pending_index(vif->pending_prod++);
-		vif->pending_ring[index] = vif->pending_ring[info_idx];
+		index = pending_index(queue->pending_prod++);
+		queue->pending_ring[index] = queue->pending_ring[info_idx];
 
-		peek = vif->pending_ring[pending_index(++head)];
+		peek = queue->pending_ring[pending_index(++head)];
 
-	} while (!pending_tx_is_head(vif, peek));
+	} while (!pending_tx_is_head(queue, peek));
 
-	put_page(vif->mmap_pages[pending_idx]);
-	vif->mmap_pages[pending_idx] = NULL;
+	put_page(queue->mmap_pages[pending_idx]);
+	queue->mmap_pages[pending_idx] = NULL;
 }
 
 
-static void make_tx_response(struct xenvif *vif,
+static void make_tx_response(struct xenvif_queue *queue,
 			     struct xen_netif_tx_request *txp,
 			     s8       st)
 {
-	RING_IDX i = vif->tx.rsp_prod_pvt;
+	RING_IDX i = queue->tx.rsp_prod_pvt;
 	struct xen_netif_tx_response *resp;
 	int notify;
 
-	resp = RING_GET_RESPONSE(&vif->tx, i);
+	resp = RING_GET_RESPONSE(&queue->tx, i);
 	resp->id     = txp->id;
 	resp->status = st;
 
 	if (txp->flags & XEN_NETTXF_extra_info)
-		RING_GET_RESPONSE(&vif->tx, ++i)->status = XEN_NETIF_RSP_NULL;
+		RING_GET_RESPONSE(&queue->tx, ++i)->status = XEN_NETIF_RSP_NULL;
 
-	vif->tx.rsp_prod_pvt = ++i;
-	RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->tx, notify);
+	queue->tx.rsp_prod_pvt = ++i;
+	RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&queue->tx, notify);
 	if (notify)
-		notify_remote_via_irq(vif->tx_irq);
+		notify_remote_via_irq(queue->tx_irq);
 }
 
-static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
+static struct xen_netif_rx_response *make_rx_response(struct xenvif_queue *queue,
 					     u16      id,
 					     s8       st,
 					     u16      offset,
 					     u16      size,
 					     u16      flags)
 {
-	RING_IDX i = vif->rx.rsp_prod_pvt;
+	RING_IDX i = queue->rx.rsp_prod_pvt;
 	struct xen_netif_rx_response *resp;
 
-	resp = RING_GET_RESPONSE(&vif->rx, i);
+	resp = RING_GET_RESPONSE(&queue->rx, i);
 	resp->offset     = offset;
 	resp->flags      = flags;
 	resp->id         = id;
@@ -1464,39 +1465,39 @@ static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
 	if (st < 0)
 		resp->status = (s16)st;
 
-	vif->rx.rsp_prod_pvt = ++i;
+	queue->rx.rsp_prod_pvt = ++i;
 
 	return resp;
 }
 
-static inline int rx_work_todo(struct xenvif *vif)
+static inline int rx_work_todo(struct xenvif_queue *queue)
 {
-	return !skb_queue_empty(&vif->rx_queue) &&
-	       xenvif_rx_ring_slots_available(vif, vif->rx_last_skb_slots);
+	return !skb_queue_empty(&queue->rx_queue) &&
+	       xenvif_rx_ring_slots_available(queue, queue->rx_last_skb_slots);
 }
 
-static inline int tx_work_todo(struct xenvif *vif)
+static inline int tx_work_todo(struct xenvif_queue *queue)
 {
 
-	if (likely(RING_HAS_UNCONSUMED_REQUESTS(&vif->tx)) &&
-	    (nr_pending_reqs(vif) + XEN_NETBK_LEGACY_SLOTS_MAX
+	if (likely(RING_HAS_UNCONSUMED_REQUESTS(&queue->tx)) &&
+	    (nr_pending_reqs(queue) + XEN_NETBK_LEGACY_SLOTS_MAX
 	     < MAX_PENDING_REQS))
 		return 1;
 
 	return 0;
 }
 
-void xenvif_unmap_frontend_rings(struct xenvif *vif)
+void xenvif_unmap_frontend_rings(struct xenvif_queue *queue)
 {
-	if (vif->tx.sring)
-		xenbus_unmap_ring_vfree(xenvif_to_xenbus_device(vif),
-					vif->tx.sring);
-	if (vif->rx.sring)
-		xenbus_unmap_ring_vfree(xenvif_to_xenbus_device(vif),
-					vif->rx.sring);
+	if (queue->tx.sring)
+		xenbus_unmap_ring_vfree(xenvif_to_xenbus_device(queue->vif),
+					queue->tx.sring);
+	if (queue->rx.sring)
+		xenbus_unmap_ring_vfree(xenvif_to_xenbus_device(queue->vif),
+					queue->rx.sring);
 }
 
-int xenvif_map_frontend_rings(struct xenvif *vif,
+int xenvif_map_frontend_rings(struct xenvif_queue *queue,
 			      grant_ref_t tx_ring_ref,
 			      grant_ref_t rx_ring_ref)
 {
@@ -1506,67 +1507,72 @@ int xenvif_map_frontend_rings(struct xenvif *vif,
 
 	int err = -ENOMEM;
 
-	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif),
+	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(queue->vif),
 				     tx_ring_ref, &addr);
 	if (err)
 		goto err;
 
 	txs = (struct xen_netif_tx_sring *)addr;
-	BACK_RING_INIT(&vif->tx, txs, PAGE_SIZE);
+	BACK_RING_INIT(&queue->tx, txs, PAGE_SIZE);
 
-	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif),
+	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(queue->vif),
 				     rx_ring_ref, &addr);
 	if (err)
 		goto err;
 
 	rxs = (struct xen_netif_rx_sring *)addr;
-	BACK_RING_INIT(&vif->rx, rxs, PAGE_SIZE);
+	BACK_RING_INIT(&queue->rx, rxs, PAGE_SIZE);
 
 	return 0;
 
 err:
-	xenvif_unmap_frontend_rings(vif);
+	xenvif_unmap_frontend_rings(queue);
 	return err;
 }
 
-void xenvif_stop_queue(struct xenvif *vif)
+static inline void xenvif_wake_queue(struct xenvif_queue *queue)
 {
-	if (!vif->can_queue)
-		return;
+	struct net_device *dev = queue->vif->dev;
+	netif_tx_wake_queue(netdev_get_tx_queue(dev, queue->id));
+}
 
-	netif_stop_queue(vif->dev);
+static void xenvif_start_queue(struct xenvif_queue *queue)
+{
+	if (xenvif_schedulable(queue->vif))
+		xenvif_wake_queue(queue);
 }
 
-static void xenvif_start_queue(struct xenvif *vif)
+static int xenvif_queue_stopped(struct xenvif_queue *queue)
 {
-	if (xenvif_schedulable(vif))
-		netif_wake_queue(vif->dev);
+	struct net_device *dev = queue->vif->dev;
+	unsigned int id = queue->id;
+	return netif_tx_queue_stopped(netdev_get_tx_queue(dev, id));
 }
 
 int xenvif_kthread(void *data)
 {
-	struct xenvif *vif = data;
+	struct xenvif_queue *queue = data;
 	struct sk_buff *skb;
 
 	while (!kthread_should_stop()) {
-		wait_event_interruptible(vif->wq,
-					 rx_work_todo(vif) ||
+		wait_event_interruptible(queue->wq,
+					 rx_work_todo(queue) ||
 					 kthread_should_stop());
 		if (kthread_should_stop())
 			break;
 
-		if (!skb_queue_empty(&vif->rx_queue))
-			xenvif_rx_action(vif);
+		if (!skb_queue_empty(&queue->rx_queue))
+			xenvif_rx_action(queue);
 
-		if (skb_queue_empty(&vif->rx_queue) &&
-		    netif_queue_stopped(vif->dev))
-			xenvif_start_queue(vif);
+		if (skb_queue_empty(&queue->rx_queue) &&
+		    xenvif_queue_stopped(queue))
+			xenvif_start_queue(queue);
 
 		cond_resched();
 	}
 
 	/* Bin any remaining skbs */
-	while ((skb = skb_dequeue(&vif->rx_queue)) != NULL)
+	while ((skb = skb_dequeue(&queue->rx_queue)) != NULL)
 		dev_kfree_skb(skb);
 
 	return 0;
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 7a206cf..f23ea0a 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -19,6 +19,7 @@
 */
 
 #include "common.h"
+#include <linux/vmalloc.h>
 
 struct backend_info {
 	struct xenbus_device *dev;
@@ -34,8 +35,9 @@ struct backend_info {
 	u8 have_hotplug_status_watch:1;
 };
 
-static int connect_rings(struct backend_info *);
-static void connect(struct backend_info *);
+static int connect_rings(struct backend_info *be, struct xenvif_queue *queue);
+static void connect(struct backend_info *be);
+static int read_xenbus_vif_flags(struct backend_info *be);
 static void backend_create_xenvif(struct backend_info *be);
 static void unregister_hotplug_status_watch(struct backend_info *be);
 static void set_backend_state(struct backend_info *be,
@@ -485,10 +487,9 @@ static void connect(struct backend_info *be)
 {
 	int err;
 	struct xenbus_device *dev = be->dev;
-
-	err = connect_rings(be);
-	if (err)
-		return;
+	unsigned long credit_bytes, credit_usec;
+	unsigned int queue_index;
+	struct xenvif_queue *queue;
 
 	err = xen_net_read_mac(dev, be->vif->fe_dev_addr);
 	if (err) {
@@ -496,9 +497,30 @@ static void connect(struct backend_info *be)
 		return;
 	}
 
-	xen_net_read_rate(dev, &be->vif->credit_bytes,
-			  &be->vif->credit_usec);
-	be->vif->remaining_credit = be->vif->credit_bytes;
+	xen_net_read_rate(dev, &credit_bytes, &credit_usec);
+	read_xenbus_vif_flags(be);
+
+	be->vif->num_queues = 1;
+	be->vif->queues = vzalloc(be->vif->num_queues *
+			sizeof(struct xenvif_queue));
+
+	for (queue_index = 0; queue_index < be->vif->num_queues; ++queue_index) {
+		queue = &be->vif->queues[queue_index];
+		queue->vif = be->vif;
+		queue->id = queue_index;
+		snprintf(queue->name, sizeof(queue->name), "%s-q%u",
+				be->vif->dev->name, queue->id);
+
+		xenvif_init_queue(queue);
+
+		queue->remaining_credit = credit_bytes;
+
+		err = connect_rings(be, queue);
+		if (err)
+			goto err;
+	}
+
+	xenvif_carrier_on(be->vif);
 
 	unregister_hotplug_status_watch(be);
 	err = xenbus_watch_pathfmt(dev, &be->hotplug_status_watch,
@@ -507,18 +529,24 @@ static void connect(struct backend_info *be)
 	if (!err)
 		be->have_hotplug_status_watch = 1;
 
-	netif_wake_queue(be->vif->dev);
+	netif_tx_wake_all_queues(be->vif->dev);
+
+	return;
+
+err:
+	vfree(be->vif->queues);
+	be->vif->queues = NULL;
+	be->vif->num_queues = 0;
+	return;
 }
 
 
-static int connect_rings(struct backend_info *be)
+static int connect_rings(struct backend_info *be, struct xenvif_queue *queue)
 {
-	struct xenvif *vif = be->vif;
 	struct xenbus_device *dev = be->dev;
 	unsigned long tx_ring_ref, rx_ring_ref;
-	unsigned int tx_evtchn, rx_evtchn, rx_copy;
+	unsigned int tx_evtchn, rx_evtchn;
 	int err;
-	int val;
 
 	err = xenbus_gather(XBT_NIL, dev->otherend,
 			    "tx-ring-ref", "%lu", &tx_ring_ref,
@@ -546,6 +574,27 @@ static int connect_rings(struct backend_info *be)
 		rx_evtchn = tx_evtchn;
 	}
 
+	/* Map the shared frame, irq etc. */
+	err = xenvif_connect(queue, tx_ring_ref, rx_ring_ref,
+			     tx_evtchn, rx_evtchn);
+	if (err) {
+		xenbus_dev_fatal(dev, err,
+				 "mapping shared-frames %lu/%lu port tx %u rx %u",
+				 tx_ring_ref, rx_ring_ref,
+				 tx_evtchn, rx_evtchn);
+		return err;
+	}
+
+	return 0;
+}
+
+static int read_xenbus_vif_flags(struct backend_info *be)
+{
+	struct xenvif *vif = be->vif;
+	struct xenbus_device *dev = be->dev;
+	unsigned int rx_copy;
+	int err, val;
+
 	err = xenbus_scanf(XBT_NIL, dev->otherend, "request-rx-copy", "%u",
 			   &rx_copy);
 	if (err == -ENOENT) {
@@ -621,16 +670,6 @@ static int connect_rings(struct backend_info *be)
 		val = 0;
 	vif->ipv6_csum = !!val;
 
-	/* Map the shared frame, irq etc. */
-	err = xenvif_connect(vif, tx_ring_ref, rx_ring_ref,
-			     tx_evtchn, rx_evtchn);
-	if (err) {
-		xenbus_dev_fatal(dev, err,
-				 "mapping shared-frames %lu/%lu port tx %u rx %u",
-				 tx_ring_ref, rx_ring_ref,
-				 tx_evtchn, rx_evtchn);
-		return err;
-	}
 	return 0;
 }
 
-- 
1.7.10.4
