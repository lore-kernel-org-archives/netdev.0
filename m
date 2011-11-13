From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC] ndo: ndo_queue_xmit/ndo_flush_xmit (was Re: [RFC] [ver3
	PATCH 0/6] Implement multiqueue virtio-net)
Date: Sun, 13 Nov 2011 19:48:28 +0200
Message-ID: <20111113174827.GA23310@redhat.com>
References: <20111111130223.9878.59517.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20111111130223.9878.59517.sendpatchset@krkumar2.in.ibm.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 11, 2011 at 06:32:23PM +0530, Krishna Kumar wrote:
> This patch series resurrects the earlier multiple TX/RX queues
> functionality for virtio_net, and addresses the issues pointed
> out.

I'm guessing the biggest source of contention for transmit is keeping
the TX hardware lock across VM exit.  I wonder whether, for transmit,
it's not a good idea to pass all traffic through a single queue to
improve batching, and then if necessary multiplex it out on the host.

The following is a stub at supporting this in the guest - it needs to be
split up, and cleaned up, and I'm not sure about the trick
of returning NETDEV_TX_QUEUED, but should give you the idea.

Compile-tested only, sent out for early flames/feedback.

This is on top of Rusty's unlocked kick patches.

---->

- add optional ndo_queue_xmit/ndo_flush_xmit netdev ops
- ndo_queue_xmit can transmit skb and return NETDEV_TX_OK,
  or it can return NETDEV_TX_QUEUED to signal that
  the skb was queued and ndo_flush_xmit needs to be called
  to actually transmit it.

The point is to improve batching by calling ndo_flush_xmit once after
multiple ndo_queue_xmit calls, and reduce lock contention by calling
ndo_flush_xmit outside any locks.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Compile-tested only.

---

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cbeb586..a7df098 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -105,6 +105,7 @@ struct wireless_dev;
 enum netdev_tx {
 	__NETDEV_TX_MIN	 = INT_MIN,	/* make sure enum is signed */
 	NETDEV_TX_OK	 = 0x00,	/* driver took care of packet */
+	NETDEV_TX_QUEUED = 0x04,	/* queued, need to flush */
 	NETDEV_TX_BUSY	 = 0x10,	/* driver tx path was busy*/
 	NETDEV_TX_LOCKED = 0x20,	/* driver tx lock was already taken */
 };
@@ -712,6 +713,14 @@ struct netdev_tc_txq {
  *	Must return NETDEV_TX_OK , NETDEV_TX_BUSY.
  *        (can also return NETDEV_TX_LOCKED iff NETIF_F_LLTX)
  *	Required can not be NULL.
+ * netdev_tx_t (*ndo_queue_xmit)(struct sk_buff *skb,
+ *                               struct net_device *dev);
+ *	Same as ndo_start_xmit but allows batching packet transmission.
+ *	Must return NETDEV_TX_QUEUED , NETDEV_TX_OK , NETDEV_TX_BUSY.
+ *        (can also return NETDEV_TX_LOCKED iff NETIF_F_LLTX)
+ *
+ * void (*ndo_flush_xmit)(struct net_device *dev);
+ *	Called after queueing a batch of packets.
  *
  * u16 (*ndo_select_queue)(struct net_device *dev, struct sk_buff *skb);
  *	Called to decide which queue to when device supports multiple
@@ -863,6 +872,9 @@ struct net_device_ops {
 	int			(*ndo_stop)(struct net_device *dev);
 	netdev_tx_t		(*ndo_start_xmit) (struct sk_buff *skb,
 						   struct net_device *dev);
+	netdev_tx_t		(*ndo_queue_xmit)(struct sk_buff *skb,
+						  struct net_device *dev);
+	void			(*ndo_flush_xmit)(struct net_device *dev);
 	u16			(*ndo_select_queue)(struct net_device *dev,
 						    struct sk_buff *skb);
 	void			(*ndo_change_rx_flags)(struct net_device *dev,
@@ -2099,6 +2111,10 @@ extern int		dev_set_mac_address(struct net_device *,
 extern int		dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev,
 					    struct netdev_queue *txq);
+extern int		dev_queue_start_xmit(struct sk_buff *skb,
+					     struct net_device *dev,
+					     struct netdev_queue *txq);
+extern void		dev_flush_start_xmit(struct net_device *dev);
 extern int		dev_forward_skb(struct net_device *dev,
 					struct sk_buff *skb);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 6ba50a1..608b67c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2167,8 +2167,8 @@ static inline int skb_needs_linearize(struct sk_buff *skb,
 				!(features & NETIF_F_SG)));
 }
 
-int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
-			struct netdev_queue *txq)
+static int __dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
+				 struct netdev_queue *txq, bool queue)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 	int rc = NETDEV_TX_OK;
@@ -2224,9 +2224,12 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		}
 
 		skb_len = skb->len;
-		rc = ops->ndo_start_xmit(skb, dev);
+		if (queue && ops->ndo_queue_xmit)
+			rc = ops->ndo_queue_xmit(skb, dev);
+		else
+			rc = ops->ndo_start_xmit(skb, dev);
 		trace_net_dev_xmit(skb, rc, dev, skb_len);
-		if (rc == NETDEV_TX_OK)
+		if (rc == NETDEV_TX_OK || rc == NETDEV_TX_QUEUED)
 			txq_trans_update(txq);
 		return rc;
 	}
@@ -2246,9 +2249,12 @@ gso:
 			skb_dst_drop(nskb);
 
 		skb_len = nskb->len;
-		rc = ops->ndo_start_xmit(nskb, dev);
+		if (queue && ops->ndo_queue_xmit)
+			rc = ops->ndo_queue_xmit(nskb, dev);
+		else
+			rc = ops->ndo_start_xmit(nskb, dev);
 		trace_net_dev_xmit(nskb, rc, dev, skb_len);
-		if (unlikely(rc != NETDEV_TX_OK)) {
+		if (unlikely(rc != NETDEV_TX_OK && rc != NETDEV_TX_QUEUED)) {
 			if (rc & ~NETDEV_TX_MASK)
 				goto out_kfree_gso_skb;
 			nskb->next = skb->next;
@@ -2269,6 +2275,25 @@ out:
 	return rc;
 }
 
+int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
+			  struct netdev_queue *txq)
+{
+	return __dev_hard_start_xmit(skb, dev, txq, false);
+}
+
+int dev_queue_start_xmit(struct sk_buff *skb, struct net_device *dev,
+			 struct netdev_queue *txq)
+{
+	return __dev_hard_start_xmit(skb, dev, txq, true);
+}
+
+void dev_flush_start_xmit(struct net_device *dev)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	if (ops->ndo_flush_xmit)
+		ops->ndo_flush_xmit(dev);
+}
+
 static u32 hashrnd __read_mostly;
 
 /*
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 69fca27..83b3758 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -102,18 +102,9 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 	return ret;
 }
 
-/*
- * Transmit one skb, and handle the return status as required. Holding the
- * __QDISC_STATE_RUNNING bit guarantees that only one CPU can execute this
- * function.
- *
- * Returns to the caller:
- *				0  - queue is empty or throttled.
- *				>0 - queue is not empty.
- */
-int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
+static int __sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 		    struct net_device *dev, struct netdev_queue *txq,
-		    spinlock_t *root_lock)
+		    spinlock_t *root_lock, bool *queued)
 {
 	int ret = NETDEV_TX_BUSY;
 
@@ -122,10 +113,13 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
 	if (!netif_tx_queue_frozen_or_stopped(txq))
-		ret = dev_hard_start_xmit(skb, dev, txq);
+		ret = dev_queue_start_xmit(skb, dev, txq);
 
 	HARD_TX_UNLOCK(dev, txq);
 
+	if (ret == NETDEV_TX_QUEUED)
+		*queued = true;
+
 	spin_lock(root_lock);
 
 	if (dev_xmit_complete(ret)) {
@@ -150,6 +144,30 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 }
 
 /*
+ * Transmit one skb, and handle the return status as required. Holding the
+ * __QDISC_STATE_RUNNING bit guarantees that only one CPU can execute this
+ * function.
+ *
+ * Returns to the caller:
+ *				0  - queue is empty or throttled.
+ *				>0 - queue is not empty.
+ */
+int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
+		    struct net_device *dev, struct netdev_queue *txq,
+		    spinlock_t *root_lock)
+{
+	bool queued = false;
+	int ret;
+	ret = __sch_direct_xmit(skb, q, dev, txq, root_lock, &queued);
+	if (queued) {
+		spin_unlock(root_lock);
+		dev_flush_start_xmit(dev);
+		spin_lock(root_lock);
+	}
+	return ret;
+}
+
+/*
  * NOTE: Called under qdisc_lock(q) with locally disabled BH.
  *
  * __QDISC_STATE_RUNNING guarantees only one CPU can process
@@ -168,7 +186,7 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
  *				>0 - queue is not empty.
  *
  */
-static inline int qdisc_restart(struct Qdisc *q)
+static inline int qdisc_restart(struct Qdisc *q, bool *queued)
 {
 	struct netdev_queue *txq;
 	struct net_device *dev;
@@ -184,14 +202,22 @@ static inline int qdisc_restart(struct Qdisc *q)
 	dev = qdisc_dev(q);
 	txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
 
-	return sch_direct_xmit(skb, q, dev, txq, root_lock);
+	return __sch_direct_xmit(skb, q, dev, txq, root_lock, queued);
+}
+
+static inline void qdisc_flush_start(struct Qdisc *q)
+{
+	spin_unlock(qdisc_lock(q));
+	dev_flush_start_xmit(qdisc_dev(q));
+	spin_lock(qdisc_lock(q));
 }
 
 void __qdisc_run(struct Qdisc *q)
 {
 	int quota = weight_p;
+	bool queued = false;
 
-	while (qdisc_restart(q)) {
+	while (qdisc_restart(q, &queued)) {
 		/*
 		 * Ordered by possible occurrence: Postpone processing if
 		 * 1. we've exceeded packet quota
@@ -203,6 +229,9 @@ void __qdisc_run(struct Qdisc *q)
 		}
 	}
 
+	if (queued)
+		qdisc_flush_start(q);
+
 	qdisc_run_end(q);
 }
 
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index d6f6f40..6d28c26 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -604,9 +604,11 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 				 0, skb, GFP_ATOMIC);
 }
 
-static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t __start_xmit(struct sk_buff *skb, struct net_device *dev,
+				bool queue)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
+	bool notify;
 	int capacity;
 
 	/* Free up any pending old buffers before queueing new ones. */
@@ -632,7 +634,12 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
-	virtqueue_kick(vi->svq);
+
+	notify = virtqueue_kick_prepare(vi->svq);
+	if (!queue && notify) {
+		virtqueue_notify(vi->svq);
+		notify = false;
+	}
 
 	/* Don't wait up for transmitted skbs to be freed. */
 	skb_orphan(skb);
@@ -652,7 +659,23 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
-	return NETDEV_TX_OK;
+	return notify ? NETDEV_TX_QUEUED : NETDEV_TX_OK;
+}
+
+static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	return __start_xmit(skb, dev, false);
+}
+
+static netdev_tx_t queue_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	return __start_xmit(skb, dev, true);
+}
+
+static void flush_xmit(struct net_device *dev)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	virtqueue_notify(vi->svq);
 }
 
 static int virtnet_set_mac_address(struct net_device *dev, void *p)
@@ -909,6 +932,8 @@ static const struct net_device_ops virtnet_netdev = {
 	.ndo_open            = virtnet_open,
 	.ndo_stop   	     = virtnet_close,
 	.ndo_start_xmit      = start_xmit,
+	.ndo_queue_xmit      = queue_xmit,
+	.ndo_flush_xmit      = flush_xmit,
 	.ndo_validate_addr   = eth_validate_addr,
 	.ndo_set_mac_address = virtnet_set_mac_address,
 	.ndo_set_rx_mode     = virtnet_set_rx_mode,
