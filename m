From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2] xps-mp: Transmit Packet Steering for multiqueue
Date: Tue, 12 Oct 2010 17:20:57 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1010121705500.15786@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:57060 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363Ab0JMAVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 20:21:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements transmit packet steering (XPS) for multiqueue
devices.  XPS selects a transmit queue during packet transmission based
on configuration.  This is done by mapping the CPU transmitting the
packet to a queue.  This is the transmit side analogue to RPS-- where
RPS is selecting a CPU based on receive queue, XPS selects a queue
based on the CPU (previously there was an XPS patch from Eric
Dumazet, but that might more appropriately be called transmit completion
steering).

Each transmit queue can be associated with a number of CPUs which will
used the queue to send packets.  This is configured as a CPU mask on a
per queue basis in:

/sys/class/net/eth<n>/queues/tx-<n>/xps_cpus

The mappings are stored per device in an inverted data structure that
maps CPUs to queues.  In the netdevice structure this is an array of
num_possible_cpu structures where each array entry contains a bit map
of queues which that CPU can use.

We also allow the mapping of a socket to queue to be modified, for
instance if a thread is scheduled on a different CPU the desired queue
for transmitting packets would likely change.  To maintain in order
packet transmission a flag (ooo_okay) has been added to the sk_buf
structure.  If a transport layer sets this flag on a packet, the
transmit queue can be changed for this socket.  Presumably, the
transport would set this is there was no possbility of creating ooo
packets (for instance there are no packets in flight for the socket).
This patch includes the modification in TCP output for setting this
flag.

The allocation of the netdev_queues was modified to be symmetric
with how the rx queues are allocated, including the ability to
change the number of real queues.

In dev_pick_tx, don't do work in calculating queue index or setting
the index in the sock unless the device has more than one queue.  This
allows the sock to be set only with a queue index of a multi-queue
device which is desirable if device are stacked like in a tunnel.

The benefits of XPS are improved locality in the per queue data
structures.  Also, transmit completions are more likely to be done
nearer to the sending thread so this should promote locality back 
to the socket (e.g. UDP).  The benefits of XPS are dependent on
cache hierarchy, application load, and other factors.  XPS would
nominally be configured so that a queue would only be shared by CPUs
which are sharing a cache, the degenerative configuration woud be that
each CPU has it's own queue.

Below are some benchmark results which show the potential benfit of
this patch.  The netperf test has 500 instances of netperf TCP_RR test
with 1 byte req. and resp.

bnx2x on 16 core AMD
   XPS (16 queues, 1 TX queue per CPU)	1135K at 99% CPU
   No XPS (16 queues)			992K at 100% CPU

Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 14fbb04..4a944a7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -503,6 +503,13 @@ struct netdev_queue {
 	struct Qdisc		*qdisc;
 	unsigned long		state;
 	struct Qdisc		*qdisc_sleeping;
+#ifdef CONFIG_RPS
+	struct kobject		kobj;
+	struct netdev_queue	*first;
+	atomic_t		count;
+	struct xps_map		*xps_maps;
+#endif
+
 /*
  * write mostly part
  */
@@ -530,6 +537,23 @@ struct rps_map {
 #define RPS_MAP_SIZE(_num) (sizeof(struct rps_map) + (_num * sizeof(u16)))
 
 /*
+ * This structure holds an XPS map which can be of variable length.  queues
+ * is an array of num_possible_cpus entries, where each entry is a mask of
+ * queues for that CPU (up to num_tx_queues bits for device).
+ */
+struct xps_map {
+	struct rcu_head rcu;
+	unsigned long queues[0];
+};
+
+#define QUEUE_MASK_SIZE(dev) (BITS_TO_LONGS(dev->num_tx_queues))
+#define XPS_MAP_SIZE(dev) (sizeof(struct xps_map) + (num_possible_cpus() * \
+    QUEUE_MASK_SIZE(dev) * sizeof(unsigned long)))
+#define XPS_ENTRY(map, offset, dev) \
+    (&map->queues[offset * QUEUE_MASK_SIZE(dev)])
+#define netdev_get_xps_maps(dev) ((dev)->_tx[0].xps_maps)
+
+/*
  * The rps_dev_flow structure contains the mapping of a flow to a CPU and the
  * tail pointer for that CPU's input queue at the time of last enqueue.
  */
@@ -1696,8 +1720,8 @@ static inline int netif_is_multiqueue(const struct net_device *dev)
 	return dev->num_tx_queues > 1;
 }
 
-extern void netif_set_real_num_tx_queues(struct net_device *dev,
-					 unsigned int txq);
+extern int netif_set_real_num_tx_queues(struct net_device *dev,
+					unsigned int txq);
 
 #ifdef CONFIG_RPS
 extern int netif_set_real_num_rx_queues(struct net_device *dev,
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0b53c43..2f28b1f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -386,6 +386,7 @@ struct sk_buff {
 #else
 	__u8			deliver_no_wcard:1;
 #endif
+	 __u8			ooo_okay:1;
 	kmemcheck_bitfield_end(flags2);
 
 	/* 0/14 bit hole */
diff --git a/net/core/dev.c b/net/core/dev.c
index 04972a4..9f19545 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1553,18 +1553,31 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
  * Routine to help set real_num_tx_queues. To avoid skbs mapped to queues
  * greater then real_num_tx_queues stale skbs on the qdisc must be flushed.
  */
-void netif_set_real_num_tx_queues(struct net_device *dev, unsigned int txq)
+int netif_set_real_num_tx_queues(struct net_device *dev, unsigned int txq)
 {
 	unsigned int real_num = dev->real_num_tx_queues;
 
-	if (unlikely(txq > dev->num_tx_queues))
-		;
-	else if (txq > real_num)
-		dev->real_num_tx_queues = txq;
-	else if (txq < real_num) {
-		dev->real_num_tx_queues = txq;
-		qdisc_reset_all_tx_gt(dev, txq);
-	}
+	if (dev->reg_state == NETREG_REGISTERED) {
+		ASSERT_RTNL();
+		if (unlikely(txq > dev->num_tx_queues))
+			return -EINVAL;
+#ifdef CONFIG_RPS
+		{
+			int rc;
+			rc = netdev_queue_update_kobjects(dev,
+			    dev->real_num_tx_queues, txq);
+
+			if (rc)
+				return rc;
+		}
+#endif
+		if (txq < real_num)
+			qdisc_reset_all_tx_gt(dev, txq);
+	} else
+		dev->num_tx_queues = txq;
+
+	dev->real_num_tx_queues = txq;
+	return 0;
 }
 EXPORT_SYMBOL(netif_set_real_num_tx_queues);
 
@@ -2087,32 +2100,93 @@ static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_index)
 	return queue_index;
 }
 
+static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb,
+				int queue_index)
+{
+	struct xps_map *maps;
+	int cpu = smp_processor_id();
+	u32 hash;
+	unsigned long *queues;
+	int weight, select;
+
+	rcu_read_lock();
+	maps = rcu_dereference(netdev_get_xps_maps(dev));
+
+	if (!maps) {
+		rcu_read_unlock();
+		return queue_index;
+	}
+
+	queues = XPS_ENTRY(maps, cpu, dev);
+
+	if (queue_index >= 0) {
+		if (test_bit(queue_index, queues)) {
+			rcu_read_unlock();
+			return queue_index;
+		}
+	}
+
+	weight = bitmap_weight(queues, dev->real_num_tx_queues);
+	switch (weight) {
+	case 0:
+		break;
+	case 1:
+		queue_index =
+		    find_first_bit(queues, dev->real_num_tx_queues);
+		break;
+	default:
+		if (skb->sk && skb->sk->sk_hash)
+			hash = skb->sk->sk_hash;
+		else
+			hash = (__force u16) skb->protocol ^ skb->rxhash;
+		hash = jhash_1word(hash, hashrnd);
+
+		select = ((u64) hash * weight) >> 32;
+		queue_index =
+		    find_first_bit(queues, dev->real_num_tx_queues);
+		while (select--)
+			queue_index = find_next_bit(queues,
+			    dev->real_num_tx_queues, queue_index + 1);
+		break;
+	}
+
+	rcu_read_unlock();
+	return queue_index;
+}
+
 static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 					struct sk_buff *skb)
 {
 	int queue_index;
-	const struct net_device_ops *ops = dev->netdev_ops;
 
-	if (ops->ndo_select_queue) {
-		queue_index = ops->ndo_select_queue(dev, skb);
-		queue_index = dev_cap_txqueue(dev, queue_index);
-	} else {
+	if (dev->real_num_tx_queues > 1) {
 		struct sock *sk = skb->sk;
+		
 		queue_index = sk_tx_queue_get(sk);
-		if (queue_index < 0) {
+		if (queue_index < 0 || skb->ooo_okay) {
+			const struct net_device_ops *ops = dev->netdev_ops;
+			int old_index = queue_index;
 
-			queue_index = 0;
-			if (dev->real_num_tx_queues > 1)
-				queue_index = skb_tx_hash(dev, skb);
+			if (ops->ndo_select_queue) {
+				queue_index = ops->ndo_select_queue(dev, skb);
+				queue_index = dev_cap_txqueue(dev, queue_index);
+			} else {
+				queue_index = get_xps_queue(dev,
+				    skb, queue_index);
+				if (queue_index < 0)
+					queue_index = skb_tx_hash(dev, skb);
+			}
 
-			if (sk) {
-				struct dst_entry *dst = rcu_dereference_check(sk->sk_dst_cache, 1);
+			if ((queue_index != old_index) && sk) {
+				struct dst_entry *dst =
+				    rcu_dereference_check(sk->sk_dst_cache, 1);
 
 				if (dst && skb_dst(skb) == dst)
 					sk_tx_queue_set(sk, queue_index);
 			}
 		}
-	}
+	} else
+		queue_index = 0;
 
 	skb_set_queue_mapping(skb, queue_index);
 	return netdev_get_tx_queue(dev, queue_index);
@@ -5036,6 +5110,42 @@ static int netif_alloc_rx_queues(struct net_device *dev)
 	return 0;
 }
 
+static int netif_alloc_netdev_queues(struct net_device *dev)
+{
+	unsigned int i, count = dev->num_tx_queues;
+	struct netdev_queue *tx;
+
+	tx = kcalloc(count, sizeof(struct netdev_queue), GFP_KERNEL);
+	if (!tx) {
+		pr_err("netdev: Unable to allocate %u tx queues.\n",
+		       count);
+			return -ENOMEM;
+	}
+	dev->_tx = tx;
+#ifdef CONFIG_RPS
+	/*
+	 * Set a pointer to first element in the array which holds the
+	 * reference count.
+	 */
+	for (i = 0; i < count; i++)
+		tx[i].first = tx;
+#endif
+	return 0;
+}
+
+static void netdev_init_one_queue(struct net_device *dev,
+				  struct netdev_queue *queue,
+				  void *_unused)
+{
+	queue->dev = dev;
+}
+
+static void netdev_init_queues(struct net_device *dev)
+{
+	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
+	spin_lock_init(&dev->tx_global_lock);
+}
+
 /**
  *	register_netdevice	- register a network device
  *	@dev: device to register
@@ -5069,7 +5179,6 @@ int register_netdevice(struct net_device *dev)
 
 	spin_lock_init(&dev->addr_list_lock);
 	netdev_set_addr_lockdep_class(dev);
-	netdev_init_queue_locks(dev);
 
 	dev->iflink = -1;
 
@@ -5077,6 +5186,13 @@ int register_netdevice(struct net_device *dev)
 	if (ret)
 		goto out;
 
+	ret = netif_alloc_netdev_queues(dev);
+	if (ret)
+		goto out;
+
+	netdev_init_queues(dev);
+	netdev_init_queue_locks(dev);
+
 	/* Init, if this function is available */
 	if (dev->netdev_ops->ndo_init) {
 		ret = dev->netdev_ops->ndo_init(dev);
@@ -5458,19 +5574,6 @@ struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
 }
 EXPORT_SYMBOL(dev_get_stats);
 
-static void netdev_init_one_queue(struct net_device *dev,
-				  struct netdev_queue *queue,
-				  void *_unused)
-{
-	queue->dev = dev;
-}
-
-static void netdev_init_queues(struct net_device *dev)
-{
-	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
-	spin_lock_init(&dev->tx_global_lock);
-}
-
 struct netdev_queue *dev_ingress_queue_create(struct net_device *dev)
 {
 	struct netdev_queue *queue = dev_ingress_queue(dev);
@@ -5504,7 +5607,6 @@ struct netdev_queue *dev_ingress_queue_create(struct net_device *dev)
 struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 		void (*setup)(struct net_device *), unsigned int queue_count)
 {
-	struct netdev_queue *tx;
 	struct net_device *dev;
 	size_t alloc_size;
 	struct net_device *p;
@@ -5526,20 +5628,12 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 		return NULL;
 	}
 
-	tx = kcalloc(queue_count, sizeof(struct netdev_queue), GFP_KERNEL);
-	if (!tx) {
-		printk(KERN_ERR "alloc_netdev: Unable to allocate "
-		       "tx qdiscs.\n");
-		goto free_p;
-	}
-
-
 	dev = PTR_ALIGN(p, NETDEV_ALIGN);
 	dev->padded = (char *)dev - (char *)p;
 
 	dev->pcpu_refcnt = alloc_percpu(int);
 	if (!dev->pcpu_refcnt)
-		goto free_tx;
+		goto free_p;
 
 	if (dev_addr_init(dev))
 		goto free_pcpu;
@@ -5549,7 +5643,6 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	dev_net_set(dev, &init_net);
 
-	dev->_tx = tx;
 	dev->num_tx_queues = queue_count;
 	dev->real_num_tx_queues = queue_count;
 
@@ -5560,8 +5653,6 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	dev->gso_max_size = GSO_MAX_SIZE;
 
-	netdev_init_queues(dev);
-
 	INIT_LIST_HEAD(&dev->ethtool_ntuple_list.list);
 	dev->ethtool_ntuple_list.count = 0;
 	INIT_LIST_HEAD(&dev->napi_list);
@@ -5572,8 +5663,6 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	strcpy(dev->name, name);
 	return dev;
 
-free_tx:
-	kfree(tx);
 free_pcpu:
 	free_percpu(dev->pcpu_refcnt);
 free_p:
@@ -5596,7 +5685,9 @@ void free_netdev(struct net_device *dev)
 
 	release_net(dev_net(dev));
 
+#ifndef CONFIG_RPS
 	kfree(dev->_tx);
+#endif
 
 	kfree(rcu_dereference_raw(dev->ingress_queue));
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index b143173..2f1f09a 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -764,18 +764,307 @@ net_rx_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
 	return error;
 }
 
-static int rx_queue_register_kobjects(struct net_device *net)
+/*
+ * netdev_queue sysfs structures and functions.
+ */
+struct netdev_queue_attribute {
+	struct attribute attr;
+	ssize_t (*show)(struct netdev_queue *queue,
+	    struct netdev_queue_attribute *attr, char *buf);
+	ssize_t (*store)(struct netdev_queue *queue,
+	    struct netdev_queue_attribute *attr, const char *buf, size_t len);
+};
+#define to_netdev_queue_attr(_attr) container_of(_attr,		\
+    struct netdev_queue_attribute, attr)
+
+#define to_netdev_queue(obj) container_of(obj, struct netdev_queue, kobj)
+
+static ssize_t netdev_queue_attr_show(struct kobject *kobj,
+				      struct attribute *attr, char *buf)
+{
+	struct netdev_queue_attribute *attribute = to_netdev_queue_attr(attr);
+	struct netdev_queue *queue = to_netdev_queue(kobj);
+
+	if (!attribute->show)
+		return -EIO;
+
+	return attribute->show(queue, attribute, buf);
+}
+
+static ssize_t netdev_queue_attr_store(struct kobject *kobj,
+				       struct attribute *attr,
+				       const char *buf, size_t count)
+{
+	struct netdev_queue_attribute *attribute = to_netdev_queue_attr(attr);
+	struct netdev_queue *queue = to_netdev_queue(kobj);
+
+	if (!attribute->store)
+		return -EIO;
+
+	return attribute->store(queue, attribute, buf, count);
+}
+
+static struct sysfs_ops netdev_queue_sysfs_ops = {
+	.show = netdev_queue_attr_show,
+	.store = netdev_queue_attr_store,
+};
+
+static inline unsigned int get_netdev_queue_index(struct netdev_queue *queue)
 {
-	net->queues_kset = kset_create_and_add("queues",
-	    NULL, &net->dev.kobj);
-	if (!net->queues_kset)
+	struct net_device *dev = queue->dev;
+	int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++)
+		if (queue == &dev->_tx[i])
+			break;
+
+	BUG_ON(i >= dev->num_tx_queues);
+
+	return i;
+}
+
+static ssize_t show_xps_map(struct netdev_queue *queue,
+			    struct netdev_queue_attribute *attribute, char *buf)
+{
+	struct net_device *dev = queue->dev;
+	struct netdev_queue *first = queue->first;
+	struct xps_map *maps;
+	cpumask_var_t mask;
+	unsigned long *qmask, index;
+	size_t len = 0;
+ 	int i;
+	unsigned int qmask_size = QUEUE_MASK_SIZE(dev);
+
+	if (!zalloc_cpumask_var(&mask, GFP_KERNEL))
 		return -ENOMEM;
-	return net_rx_queue_update_kobjects(net, 0, net->real_num_rx_queues);
+
+	index = get_netdev_queue_index(queue);
+
+	rcu_read_lock();
+	maps = rcu_dereference(first->xps_maps);
+	if (maps) {
+		qmask = maps->queues;
+		for (i = 0; i < num_possible_cpus(); i++) {
+			if (test_bit(index, qmask))
+				cpumask_set_cpu(i, mask);
+			qmask += qmask_size;
+		}
+	}
+	len += cpumask_scnprintf(buf + len, PAGE_SIZE, mask);
+	if (PAGE_SIZE - len < 3) {
+		rcu_read_unlock();
+		free_cpumask_var(mask);
+		return -EINVAL;
+	}
+	rcu_read_unlock();
+
+	free_cpumask_var(mask);
+	len += sprintf(buf + len, "\n");
+	return len;
+}
+
+static void xps_map_release(struct rcu_head *rcu)
+{
+	struct xps_map *map = container_of(rcu, struct xps_map, rcu);
+
+	kfree(map);
 }
 
-static void rx_queue_remove_kobjects(struct net_device *net)
+static DEFINE_MUTEX(xps_map_lock);
+
+static ssize_t store_xps_map(struct netdev_queue *queue,
+		      struct netdev_queue_attribute *attribute,
+		      const char *buf, size_t len)
+{
+	struct net_device *dev = queue->dev;
+	struct netdev_queue *first = queue->first;
+	struct xps_map *maps;
+	cpumask_var_t mask;
+	int err, i, nonempty = 0;
+	unsigned long *qmask, index;
+	unsigned int qmask_size = QUEUE_MASK_SIZE(dev);
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
+		return -ENOMEM;
+
+	err = bitmap_parse(buf, len, cpumask_bits(mask), nr_cpumask_bits);
+	if (err) {
+		free_cpumask_var(mask);
+		return err;
+	}
+
+	mutex_lock(&xps_map_lock);
+
+	maps = first->xps_maps;
+	if (!maps) {
+		if (!cpumask_weight(mask)) {
+			mutex_unlock(&xps_map_lock);
+			free_cpumask_var(mask);
+			return 0;
+		}
+		maps = kzalloc(XPS_MAP_SIZE(dev), GFP_KERNEL);
+		if (!maps) {
+			mutex_unlock(&xps_map_lock);
+			free_cpumask_var(mask);
+			return -ENOMEM;
+		}
+		rcu_assign_pointer(first->xps_maps, maps);
+	}
+
+	index = get_netdev_queue_index(queue);
+
+	qmask = maps->queues;
+	for (i = 0; i < num_possible_cpus(); i++) {
+		if (cpu_isset(i, *mask) && cpu_online(i)) {
+			set_bit(index, qmask);
+			nonempty = 1;
+		} else
+			clear_bit(index, qmask);
+		if (!nonempty &&
+		    bitmap_weight(qmask, dev->real_num_tx_queues))
+			nonempty = 1;
+		qmask += qmask_size;
+	}
+
+	if (!nonempty) {
+		rcu_assign_pointer(first->xps_maps, NULL);
+		call_rcu(&maps->rcu, xps_map_release);
+	}
+
+	mutex_unlock(&xps_map_lock);
+
+	free_cpumask_var(mask);
+	return len;
+}
+
+static struct netdev_queue_attribute xps_cpus_attribute =
+    __ATTR(xps_cpus, S_IRUGO | S_IWUSR, show_xps_map, store_xps_map);
+
+static struct attribute *netdev_queue_default_attrs[] = {
+	&xps_cpus_attribute.attr,
+	NULL
+};
+
+static void netdev_queue_release(struct kobject *kobj)
+{
+	struct netdev_queue *queue = to_netdev_queue(kobj);
+	struct net_device *dev = queue->dev;
+	struct netdev_queue *first = queue->first;
+	struct xps_map *maps;
+	unsigned long *qmask, index;
+	int i, nonempty = 0;
+	unsigned int qmask_size = QUEUE_MASK_SIZE(dev);
+
+	index = get_netdev_queue_index(queue);
+
+	mutex_lock(&xps_map_lock);
+
+	maps = first->xps_maps;
+
+	if (maps) {
+		qmask = maps->queues;
+		for (i = 0; i < num_possible_cpus(); i++) {
+			clear_bit(index, qmask);
+			if (!nonempty &&
+			    bitmap_weight(qmask, dev->real_num_tx_queues))
+				nonempty = 1;
+			qmask += qmask_size;
+		}
+
+		if (!nonempty) {
+			rcu_assign_pointer(first->xps_maps, NULL);
+			call_rcu(&maps->rcu, xps_map_release);
+		}
+	}
+	mutex_unlock(&xps_map_lock);
+
+	if (atomic_dec_and_test(&first->count))
+		kfree(first);
+}
+
+static struct kobj_type netdev_queue_ktype = {
+	.sysfs_ops = &netdev_queue_sysfs_ops,
+	.release = netdev_queue_release,
+	.default_attrs = netdev_queue_default_attrs,
+};
+
+static int netdev_queue_add_kobject(struct net_device *net, int index)
+{
+	struct netdev_queue *queue = net->_tx + index;
+	struct netdev_queue *first = queue->first;
+	struct kobject *kobj = &queue->kobj;
+	int error = 0;
+
+	kobj->kset = net->queues_kset;
+	error = kobject_init_and_add(kobj, &netdev_queue_ktype, NULL,
+	    "tx-%u", index);
+	if (error) {
+		kobject_put(kobj);
+		return error;
+	}
+
+	kobject_uevent(kobj, KOBJ_ADD);
+	atomic_inc(&first->count);
+
+	return error;
+}
+
+int
+netdev_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
+{
+	int i;
+	int error = 0;
+
+	for (i = old_num; i < new_num; i++) {
+		error = netdev_queue_add_kobject(net, i);
+		if (error) {
+			new_num = old_num;
+			break;
+		}
+	}
+
+	while (--i >= new_num)
+		kobject_put(&net->_rx[i].kobj);
+
+	return error;
+}
+
+static int register_queue_kobjects(struct net_device *net)
+{
+ 	int error = 0, txq = 0, rxq = 0;
+ 
+ 	net->queues_kset = kset_create_and_add("queues",
+ 	    NULL, &net->dev.kobj);
+ 	if (!net->queues_kset)
+ 		return -ENOMEM;
+
+	error = net_rx_queue_update_kobjects(net, 0, net->real_num_rx_queues);
+	if (error)
+		goto error;
+	rxq = net->real_num_rx_queues;
+
+	error = netdev_queue_update_kobjects(net, 0,
+					     net->real_num_tx_queues);
+	if (error)
+		goto error;
+	txq = net->real_num_tx_queues;
+
+	return 0;
+
+error:
+	netdev_queue_update_kobjects(net, txq, 0);
+	net_rx_queue_update_kobjects(net, rxq, 0);
+	return error;
+
+ }
+
+static void remove_queue_kobjects(struct net_device *net)
 {
 	net_rx_queue_update_kobjects(net, net->real_num_rx_queues, 0);
+	netdev_queue_update_kobjects(net, net->real_num_tx_queues, 0);
 	kset_unregister(net->queues_kset);
 }
 #endif /* CONFIG_RPS */
@@ -878,7 +1167,7 @@ void netdev_unregister_kobject(struct net_device * net)
 	kobject_get(&dev->kobj);
 
 #ifdef CONFIG_RPS
-	rx_queue_remove_kobjects(net);
+	remove_queue_kobjects(net);
 #endif
 
 	device_del(dev);
@@ -919,7 +1208,7 @@ int netdev_register_kobject(struct net_device *net)
 		return error;
 
 #ifdef CONFIG_RPS
-	error = rx_queue_register_kobjects(net);
+	error = register_queue_kobjects(net);
 	if (error) {
 		device_del(dev);
 		return error;
diff --git a/net/core/net-sysfs.h b/net/core/net-sysfs.h
index 778e157..25ec2ee 100644
--- a/net/core/net-sysfs.h
+++ b/net/core/net-sysfs.h
@@ -6,6 +6,9 @@ int netdev_register_kobject(struct net_device *);
 void netdev_unregister_kobject(struct net_device *);
 #ifdef CONFIG_RPS
 int net_rx_queue_update_kobjects(struct net_device *, int old_num, int new_num);
+int netdev_queue_update_kobjects(struct net_device *net,
+				 int old_num, int new_num);
+
 #endif
 
 #endif
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 05b1ecf..67b9c9e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -822,8 +822,10 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 							   &md5);
 	tcp_header_size = tcp_options_size + sizeof(struct tcphdr);
 
-	if (tcp_packets_in_flight(tp) == 0)
+	if (tcp_packets_in_flight(tp) == 0) {
 		tcp_ca_event(sk, CA_EVENT_TX_START);
+		skb->ooo_okay = 1;
+	}
 
 	skb_push(skb, tcp_header_size);
 	skb_reset_transport_header(skb);
