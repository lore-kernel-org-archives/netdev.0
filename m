From: Gregory Haskins <ghaskins@novell.com>
Subject: [RFC PATCH v2 09/19] net: Add vbus_enet driver
Date: Thu, 09 Apr 2009 12:31:29 -0400
Message-ID: <20090409163128.32740.46975.stgit@dev.haskins.net>
References: <20090409155200.32740.19358.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org, avi@redhat.com,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: linux-kernel@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090409155200.32740.19358.stgit@dev.haskins.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 drivers/net/Kconfig     |   13 +
 drivers/net/Makefile    |    1 
 drivers/net/vbus-enet.c |  680 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 694 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/vbus-enet.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 62d732a..ac9dabd 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -3099,4 +3099,17 @@ config VIRTIO_NET
 	  This is the virtual network driver for virtio.  It can be used with
           lguest or QEMU based VMMs (like KVM or Xen).  Say Y or M.
 
+config VBUS_ENET
+	tristate "Virtual Ethernet Driver"
+	depends on VBUS_DRIVERS
+	help
+	   A virtualized 802.x network device based on the VBUS interface.
+	   It can be used with any hypervisor/kernel that supports the
+	   vbus protocol.
+
+config VBUS_ENET_DEBUG
+        bool "Enable Debugging"
+	depends on VBUS_ENET
+	default n
+
 endif # NETDEVICES
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 471baaf..61db928 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -264,6 +264,7 @@ obj-$(CONFIG_FS_ENET) += fs_enet/
 obj-$(CONFIG_NETXEN_NIC) += netxen/
 obj-$(CONFIG_NIU) += niu.o
 obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
+obj-$(CONFIG_VBUS_ENET) += vbus-enet.o
 obj-$(CONFIG_SFC) += sfc/
 
 obj-$(CONFIG_WIMAX) += wimax/
diff --git a/drivers/net/vbus-enet.c b/drivers/net/vbus-enet.c
new file mode 100644
index 0000000..3779f77
--- /dev/null
+++ b/drivers/net/vbus-enet.c
@@ -0,0 +1,680 @@
+/*
+ * vbus_enet - A virtualized 802.x network device based on the VBUS interface
+ *
+ * Copyright (C) 2009 Novell, Gregory Haskins <ghaskins@novell.com>
+ *
+ * Derived from the SNULL example from the book "Linux Device Drivers" by
+ * Alessandro Rubini, Jonathan Corbet, and Greg Kroah-Hartman, published
+ * by O'Reilly & Associates.
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/moduleparam.h>
+
+#include <linux/sched.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/interrupt.h>
+
+#include <linux/in.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/skbuff.h>
+#include <linux/ioq.h>
+#include <linux/vbus_driver.h>
+
+#include <linux/in6.h>
+#include <asm/checksum.h>
+
+#include <linux/venet.h>
+
+MODULE_AUTHOR("Gregory Haskins");
+MODULE_LICENSE("GPL");
+
+static int napi_weight = 128;
+module_param(napi_weight, int, 0444);
+static int rx_ringlen = 256;
+module_param(rx_ringlen, int, 0444);
+static int tx_ringlen = 256;
+module_param(tx_ringlen, int, 0444);
+
+#undef PDEBUG             /* undef it, just in case */
+#ifdef VBUS_ENET_DEBUG
+#  define PDEBUG(fmt, args...) printk(KERN_DEBUG "vbus_enet: " fmt, ## args)
+#else
+#  define PDEBUG(fmt, args...) /* not debugging: nothing */
+#endif
+
+struct vbus_enet_queue {
+	struct ioq              *queue;
+	struct ioq_notifier      notifier;
+};
+
+struct vbus_enet_priv {
+	spinlock_t                 lock;
+	struct net_device         *dev;
+	struct vbus_device_proxy  *vdev;
+	struct napi_struct         napi;
+	struct vbus_enet_queue     rxq;
+	struct vbus_enet_queue     txq;
+	struct tasklet_struct      txtask;
+};
+
+static struct vbus_enet_priv *
+napi_to_priv(struct napi_struct *napi)
+{
+	return container_of(napi, struct vbus_enet_priv, napi);
+}
+
+static int
+queue_init(struct vbus_enet_priv *priv,
+	   struct vbus_enet_queue *q,
+	   int qid,
+	   size_t ringsize,
+	   void (*func)(struct ioq_notifier *))
+{
+	struct vbus_device_proxy *dev = priv->vdev;
+	int ret;
+
+	ret = vbus_driver_ioq_alloc(dev, qid, 0, ringsize, &q->queue);
+	if (ret < 0)
+		panic("ioq_alloc failed: %d\n", ret);
+
+	if (func) {
+		q->notifier.signal = func;
+		q->queue->notifier = &q->notifier;
+	}
+
+	return 0;
+}
+
+static int
+devcall(struct vbus_enet_priv *priv, u32 func, void *data, size_t len)
+{
+	struct vbus_device_proxy *dev = priv->vdev;
+
+	return dev->ops->call(dev, func, data, len, 0);
+}
+
+/*
+ * ---------------
+ * rx descriptors
+ * ---------------
+ */
+
+static void
+rxdesc_alloc(struct ioq_ring_desc *desc, size_t len)
+{
+	struct sk_buff *skb;
+
+	len += ETH_HLEN;
+
+	skb = dev_alloc_skb(len + 2);
+	BUG_ON(!skb);
+
+	skb_reserve(skb, 2); /* align IP on 16B boundary */
+
+	desc->cookie = (u64)skb;
+	desc->ptr    = (u64)__pa(skb->data);
+	desc->len    = len; /* total length  */
+	desc->valid  = 1;
+}
+
+static void
+rx_setup(struct vbus_enet_priv *priv)
+{
+	struct ioq *ioq = priv->rxq.queue;
+	struct ioq_iterator iter;
+	int ret;
+
+	/*
+	 * We want to iterate on the "valid" index.  By default the iterator
+	 * will not "autoupdate" which means it will not hypercall the host
+	 * with our changes.  This is good, because we are really just
+	 * initializing stuff here anyway.  Note that you can always manually
+	 * signal the host with ioq_signal() if the autoupdate feature is not
+	 * used.
+	 */
+	ret = ioq_iter_init(ioq, &iter, ioq_idxtype_valid, 0);
+	BUG_ON(ret < 0);
+
+	/*
+	 * Seek to the tail of the valid index (which should be our first
+	 * item, since the queue is brand-new)
+	 */
+	ret = ioq_iter_seek(&iter, ioq_seek_tail, 0, 0);
+	BUG_ON(ret < 0);
+
+	/*
+	 * Now populate each descriptor with an empty SKB and mark it valid
+	 */
+	while (!iter.desc->valid) {
+		rxdesc_alloc(iter.desc, priv->dev->mtu);
+
+		/*
+		 * This push operation will simultaneously advance the
+		 * valid-head index and increment our position in the queue
+		 * by one.
+		 */
+		ret = ioq_iter_push(&iter, 0);
+		BUG_ON(ret < 0);
+	}
+}
+
+static void
+rx_teardown(struct vbus_enet_priv *priv)
+{
+	struct ioq *ioq = priv->rxq.queue;
+	struct ioq_iterator iter;
+	int ret;
+
+	ret = ioq_iter_init(ioq, &iter, ioq_idxtype_valid, 0);
+	BUG_ON(ret < 0);
+
+	ret = ioq_iter_seek(&iter, ioq_seek_head, 0, 0);
+	BUG_ON(ret < 0);
+
+	/*
+	 * free each valid descriptor
+	 */
+	while (iter.desc->valid) {
+		struct sk_buff *skb = (struct sk_buff *)iter.desc->cookie;
+
+		iter.desc->valid = 0;
+		wmb();
+
+		iter.desc->ptr = 0;
+		iter.desc->cookie = 0;
+
+		ret = ioq_iter_pop(&iter, 0);
+		BUG_ON(ret < 0);
+
+		dev_kfree_skb(skb);
+	}
+}
+
+/*
+ * Open and close
+ */
+
+static int
+vbus_enet_open(struct net_device *dev)
+{
+	struct vbus_enet_priv *priv = netdev_priv(dev);
+	int ret;
+
+	ret = devcall(priv, VENET_FUNC_LINKUP, NULL, 0);
+	BUG_ON(ret < 0);
+
+	napi_enable(&priv->napi);
+
+	return 0;
+}
+
+static int
+vbus_enet_stop(struct net_device *dev)
+{
+	struct vbus_enet_priv *priv = netdev_priv(dev);
+	int ret;
+
+	napi_disable(&priv->napi);
+
+	ret = devcall(priv, VENET_FUNC_LINKDOWN, NULL, 0);
+	BUG_ON(ret < 0);
+
+	return 0;
+}
+
+/*
+ * Configuration changes (passed on by ifconfig)
+ */
+static int
+vbus_enet_config(struct net_device *dev, struct ifmap *map)
+{
+	if (dev->flags & IFF_UP) /* can't act on a running interface */
+		return -EBUSY;
+
+	/* Don't allow changing the I/O address */
+	if (map->base_addr != dev->base_addr) {
+		printk(KERN_WARNING "vbus_enet: Can't change I/O address\n");
+		return -EOPNOTSUPP;
+	}
+
+	/* ignore other fields */
+	return 0;
+}
+
+static void
+vbus_enet_schedule_rx(struct vbus_enet_priv *priv)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->lock, flags);
+
+	if (netif_rx_schedule_prep(&priv->napi)) {
+		/* Disable further interrupts */
+		ioq_notify_disable(priv->rxq.queue, 0);
+		__netif_rx_schedule(&priv->napi);
+	}
+
+	spin_unlock_irqrestore(&priv->lock, flags);
+}
+
+static int
+vbus_enet_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct vbus_enet_priv *priv = netdev_priv(dev);
+	int ret;
+
+	dev->mtu = new_mtu;
+
+	/*
+	 * FLUSHRX will cause the device to flush any outstanding
+	 * RX buffers.  They will appear to come in as 0 length
+	 * packets which we can simply discard and replace with new_mtu
+	 * buffers for the future.
+	 */
+	ret = devcall(priv, VENET_FUNC_FLUSHRX, NULL, 0);
+	BUG_ON(ret < 0);
+
+	vbus_enet_schedule_rx(priv);
+
+	return 0;
+}
+
+/*
+ * The poll implementation.
+ */
+static int
+vbus_enet_poll(struct napi_struct *napi, int budget)
+{
+	struct vbus_enet_priv *priv = napi_to_priv(napi);
+	int npackets = 0;
+	struct ioq_iterator iter;
+	int ret;
+
+	PDEBUG("%lld: polling...\n", priv->vdev->id);
+
+	/* We want to iterate on the head of the in-use index */
+	ret = ioq_iter_init(priv->rxq.queue, &iter, ioq_idxtype_inuse,
+			    IOQ_ITER_AUTOUPDATE);
+	BUG_ON(ret < 0);
+
+	ret = ioq_iter_seek(&iter, ioq_seek_head, 0, 0);
+	BUG_ON(ret < 0);
+
+	/*
+	 * We stop if we have met the quota or there are no more packets.
+	 * The EOM is indicated by finding a packet that is still owned by
+	 * the south side
+	 */
+	while ((npackets < budget) && (!iter.desc->sown)) {
+		struct sk_buff *skb = (struct sk_buff *)iter.desc->cookie;
+
+		if (iter.desc->len) {
+			skb_put(skb, iter.desc->len);
+
+			/* Maintain stats */
+			npackets++;
+			priv->dev->stats.rx_packets++;
+			priv->dev->stats.rx_bytes += iter.desc->len;
+
+			/* Pass the buffer up to the stack */
+			skb->dev      = priv->dev;
+			skb->protocol = eth_type_trans(skb, priv->dev);
+			netif_receive_skb(skb);
+
+			mb();
+		} else
+			/*
+			 * the device may send a zero-length packet when its
+			 * flushing references on the ring.  We can just drop
+			 * these on the floor
+			 */
+			dev_kfree_skb(skb);
+
+		/* Grab a new buffer to put in the ring */
+		rxdesc_alloc(iter.desc, priv->dev->mtu);
+
+		/* Advance the in-use tail */
+		ret = ioq_iter_pop(&iter, 0);
+		BUG_ON(ret < 0);
+	}
+
+	PDEBUG("%lld poll: %d packets received\n", priv->vdev->id, npackets);
+
+	/*
+	 * If we processed all packets, we're done; tell the kernel and
+	 * reenable ints
+	 */
+	if (ioq_empty(priv->rxq.queue, ioq_idxtype_inuse)) {
+		netif_rx_complete(napi);
+		ioq_notify_enable(priv->rxq.queue, 0);
+		ret = 0;
+	} else
+		/* We couldn't process everything. */
+		ret = 1;
+
+	return ret;
+}
+
+/*
+ * Transmit a packet (called by the kernel)
+ */
+static int
+vbus_enet_tx_start(struct sk_buff *skb, struct net_device *dev)
+{
+	struct vbus_enet_priv *priv = netdev_priv(dev);
+	struct ioq_iterator    iter;
+	int ret;
+	unsigned long flags;
+
+	PDEBUG("%lld: sending %d bytes\n", priv->vdev->id, skb->len);
+
+	spin_lock_irqsave(&priv->lock, flags);
+
+	if (ioq_full(priv->txq.queue, ioq_idxtype_valid)) {
+		/*
+		 * We must flow-control the kernel by disabling the
+		 * queue
+		 */
+		spin_unlock_irqrestore(&priv->lock, flags);
+		netif_stop_queue(dev);
+		printk(KERN_ERR "VBUS_ENET: tx on full queue bug "	\
+		       "on device %lld\n", priv->vdev->id);
+		return 1;
+	}
+
+	/*
+	 * We want to iterate on the tail of both the "inuse" and "valid" index
+	 * so we specify the "both" index
+	 */
+	ret = ioq_iter_init(priv->txq.queue, &iter, ioq_idxtype_both,
+			    IOQ_ITER_AUTOUPDATE);
+	BUG_ON(ret < 0);
+
+	ret = ioq_iter_seek(&iter, ioq_seek_tail, 0, 0);
+	BUG_ON(ret < 0);
+	BUG_ON(iter.desc->sown);
+
+	/*
+	 * We simply put the skb right onto the ring.  We will get an interrupt
+	 * later when the data has been consumed and we can reap the pointers
+	 * at that time
+	 */
+	iter.desc->cookie = (u64)skb;
+	iter.desc->len = (u64)skb->len;
+	iter.desc->ptr = (u64)__pa(skb->data);
+	iter.desc->valid  = 1;
+
+	priv->dev->stats.tx_packets++;
+	priv->dev->stats.tx_bytes += skb->len;
+
+	/*
+	 * This advances both indexes together implicitly, and then
+	 * signals the south side to consume the packet
+	 */
+	ret = ioq_iter_push(&iter, 0);
+	BUG_ON(ret < 0);
+
+	dev->trans_start = jiffies; /* save the timestamp */
+
+	if (ioq_full(priv->txq.queue, ioq_idxtype_valid)) {
+		/*
+		 * If the queue is congested, we must flow-control the kernel
+		 */
+		PDEBUG("%lld: backpressure tx queue\n", priv->vdev->id);
+		netif_stop_queue(dev);
+	}
+
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	return 0;
+}
+
+/*
+ * reclaim any outstanding completed tx packets
+ *
+ * assumes priv->lock held
+ */
+static void
+vbus_enet_tx_reap(struct vbus_enet_priv *priv, int force)
+{
+	struct ioq_iterator iter;
+	int ret;
+
+	/*
+	 * We want to iterate on the head of the valid index, but we
+	 * do not want the iter_pop (below) to flip the ownership, so
+	 * we set the NOFLIPOWNER option
+	 */
+	ret = ioq_iter_init(priv->txq.queue, &iter, ioq_idxtype_valid,
+			    IOQ_ITER_NOFLIPOWNER);
+	BUG_ON(ret < 0);
+
+	ret = ioq_iter_seek(&iter, ioq_seek_head, 0, 0);
+	BUG_ON(ret < 0);
+
+	/*
+	 * We are done once we find the first packet either invalid or still
+	 * owned by the south-side
+	 */
+	while (iter.desc->valid && (!iter.desc->sown || force)) {
+		struct sk_buff *skb = (struct sk_buff *)iter.desc->cookie;
+
+		PDEBUG("%lld: completed sending %d bytes\n",
+		       priv->vdev->id, skb->len);
+
+		/* Reset the descriptor */
+		iter.desc->valid  = 0;
+
+		dev_kfree_skb(skb);
+
+		/* Advance the valid-index head */
+		ret = ioq_iter_pop(&iter, 0);
+		BUG_ON(ret < 0);
+	}
+
+	/*
+	 * If we were previously stopped due to flow control, restart the
+	 * processing
+	 */
+	if (netif_queue_stopped(priv->dev)
+	    && !ioq_full(priv->txq.queue, ioq_idxtype_valid)) {
+		PDEBUG("%lld: re-enabling tx queue\n", priv->vdev->id);
+		netif_wake_queue(priv->dev);
+	}
+}
+
+static void
+vbus_enet_timeout(struct net_device *dev)
+{
+	struct vbus_enet_priv *priv = netdev_priv(dev);
+	unsigned long flags;
+
+	printk(KERN_DEBUG "VBUS_ENET %lld: Transmit timeout\n", priv->vdev->id);
+
+	spin_lock_irqsave(&priv->lock, flags);
+	vbus_enet_tx_reap(priv, 0);
+	spin_unlock_irqrestore(&priv->lock, flags);
+}
+
+static void
+rx_isr(struct ioq_notifier *notifier)
+{
+	struct vbus_enet_priv *priv;
+	struct net_device  *dev;
+
+	priv = container_of(notifier, struct vbus_enet_priv, rxq.notifier);
+	dev = priv->dev;
+
+	if (!ioq_empty(priv->rxq.queue, ioq_idxtype_inuse))
+		vbus_enet_schedule_rx(priv);
+}
+
+static void
+deferred_tx_isr(unsigned long data)
+{
+	struct vbus_enet_priv *priv = (struct vbus_enet_priv *)data;
+	unsigned long flags;
+
+	PDEBUG("deferred_tx_isr for %lld\n", priv->vdev->id);
+
+	spin_lock_irqsave(&priv->lock, flags);
+	vbus_enet_tx_reap(priv, 0);
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	ioq_notify_enable(priv->txq.queue, 0);
+}
+
+static void
+tx_isr(struct ioq_notifier *notifier)
+{
+       struct vbus_enet_priv *priv;
+       unsigned long flags;
+
+       priv = container_of(notifier, struct vbus_enet_priv, txq.notifier);
+
+       PDEBUG("tx_isr for %lld\n", priv->vdev->id);
+
+       ioq_notify_disable(priv->txq.queue, 0);
+       tasklet_schedule(&priv->txtask);
+}
+
+static const struct net_device_ops vbus_enet_netdev_ops = {
+	.ndo_open          = vbus_enet_open,
+	.ndo_stop          = vbus_enet_stop,
+	.ndo_set_config    = vbus_enet_config,
+	.ndo_start_xmit    = vbus_enet_tx_start,
+	.ndo_change_mtu	   = vbus_enet_change_mtu,
+	.ndo_tx_timeout    = vbus_enet_timeout,
+};
+
+/*
+ * This is called whenever a new vbus_device_proxy is added to the vbus
+ * with the matching VENET_ID
+ */
+static int
+vbus_enet_probe(struct vbus_device_proxy *vdev)
+{
+	struct net_device  *dev;
+	struct vbus_enet_priv *priv;
+	int ret;
+
+	printk(KERN_INFO "VBUS_ENET: Found new device at %lld\n", vdev->id);
+
+	ret = vdev->ops->open(vdev, VENET_VERSION, 0);
+	if (ret < 0)
+		return ret;
+
+	dev = alloc_etherdev(sizeof(struct vbus_enet_priv));
+	if (!dev)
+		return -ENOMEM;
+
+	priv = netdev_priv(dev);
+
+	spin_lock_init(&priv->lock);
+	priv->dev  = dev;
+	priv->vdev = vdev;
+
+	tasklet_init(&priv->txtask, deferred_tx_isr, (unsigned long)priv);
+
+	queue_init(priv, &priv->rxq, VENET_QUEUE_RX, rx_ringlen, rx_isr);
+	queue_init(priv, &priv->txq, VENET_QUEUE_TX, tx_ringlen, tx_isr);
+
+	rx_setup(priv);
+
+	ioq_notify_enable(priv->rxq.queue, 0);  /* enable interrupts */
+	ioq_notify_enable(priv->txq.queue, 0);
+
+	dev->netdev_ops     = &vbus_enet_netdev_ops;
+	dev->watchdog_timeo = 5 * HZ;
+
+	netif_napi_add(dev, &priv->napi, vbus_enet_poll, napi_weight);
+
+	ret = devcall(priv, VENET_FUNC_MACQUERY, priv->dev->dev_addr, ETH_ALEN);
+	if (ret < 0) {
+		printk(KERN_INFO "VENET: Error obtaining MAC address for " \
+		       "%lld\n",
+		       priv->vdev->id);
+		goto out_free;
+	}
+
+	dev->features |= NETIF_F_HIGHDMA;
+
+	ret = register_netdev(dev);
+	if (ret < 0) {
+		printk(KERN_INFO "VENET: error %i registering device \"%s\"\n",
+		       ret, dev->name);
+		goto out_free;
+	}
+
+	vdev->priv = priv;
+
+	return 0;
+
+ out_free:
+	free_netdev(dev);
+
+	return ret;
+}
+
+static int
+vbus_enet_remove(struct vbus_device_proxy *vdev)
+{
+	struct vbus_enet_priv *priv = (struct vbus_enet_priv *)vdev->priv;
+	struct vbus_device_proxy *dev = priv->vdev;
+
+	unregister_netdev(priv->dev);
+	napi_disable(&priv->napi);
+
+	rx_teardown(priv);
+	vbus_enet_tx_reap(priv, 1);
+
+	ioq_put(priv->rxq.queue);
+	ioq_put(priv->txq.queue);
+
+	dev->ops->close(dev, 0);
+
+	free_netdev(priv->dev);
+
+	return 0;
+}
+
+/*
+ * Finally, the module stuff
+ */
+
+static struct vbus_driver_ops vbus_enet_driver_ops = {
+	.probe  = vbus_enet_probe,
+	.remove = vbus_enet_remove,
+};
+
+static struct vbus_driver vbus_enet_driver = {
+	.type   = VENET_TYPE,
+	.owner  = THIS_MODULE,
+	.ops    = &vbus_enet_driver_ops,
+};
+
+static __init int
+vbus_enet_init_module(void)
+{
+	printk(KERN_INFO "Virtual Ethernet: Copyright (C) 2009 Novell, Gregory Haskins\n");
+	printk(KERN_DEBUG "VBUSENET: Using %d/%d queue depth\n",
+	       rx_ringlen, tx_ringlen);
+	return vbus_driver_register(&vbus_enet_driver);
+}
+
+static __exit void
+vbus_enet_cleanup(void)
+{
+	vbus_driver_unregister(&vbus_enet_driver);
+}
+
+module_init(vbus_enet_init_module);
+module_exit(vbus_enet_cleanup);

