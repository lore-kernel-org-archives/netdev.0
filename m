From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/2 v4] xps: Transmit Packet Steering
Date: Tue, 26 Oct 2010 20:38:21 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1010262033520.2997@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:50942 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151Ab0J0Di0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 23:38:26 -0400
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
use the queue to send packets.  This is configured as a CPU mask on a
per queue basis in:

/sys/class/net/eth<n>/queues/tx-<n>/xps_cpus

The mappings are stored per device in an inverted data structure that
maps CPUs to queues.  In the netdevice structure this is an array of
num_possible_cpu structures where each structure holds and array of
queue_indexes for queues which that CPU can use.

The benefits of XPS are improved locality in the per queue data
structures.  Also, transmit completions are more likely to be done
nearer to the sending thread, so this should promote locality back
to the socket on free (e.g. UDP).  The benefits of XPS are dependent on
cache hierarchy, application load, and other factors.  XPS would
nominally be configured so that a queue would only be shared by CPUs
which are sharing a cache, the degenerative configuration woud be that
each CPU has it's own queue.

Below are some benchmark results which show the potential benfit of
this patch.  The netperf test has 500 instances of netperf TCP_RR test
with 1 byte req. and resp.

bnx2x on 16 core AMD
   XPS (16 queues, 1 TX queue per CPU)  1234K at 100% CPU
   No XPS (16 queues)                   996K at 100% CPU

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |   27 ++++
 net/core/dev.c            |   55 +++++++-
 net/core/net-sysfs.c      |  367 ++++++++++++++++++++++++++++++++++++++++++++-
 net/core/net-sysfs.h      |    3 +
 4 files changed, 446 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index fcd3dda..f19b78b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -503,6 +503,13 @@ struct netdev_queue {
 	struct Qdisc		*qdisc;
 	unsigned long		state;
 	struct Qdisc		*qdisc_sleeping;
+#ifdef CONFIG_RPS
+	struct netdev_queue	*first;
+	atomic_t		count;
+	struct xps_dev_maps	*xps_maps;
+	struct kobject		kobj;
+#endif
+
 /*
  * write mostly part
  */
@@ -530,6 +537,26 @@ struct rps_map {
 #define RPS_MAP_SIZE(_num) (sizeof(struct rps_map) + (_num * sizeof(u16)))
 
 /*
+ * This structure holds an XPS map which can be of variable length.  The
+ * map is an array of queues.
+ */
+struct xps_map {
+	unsigned int len;
+	unsigned int alloc_len;
+	struct rcu_head rcu;
+	u16 queues[0];
+};
+
+/*
+ * This structure holds all XPS maps for device.  Maps are indexed by CPU.
+ */
+struct xps_dev_maps {
+	struct rcu_head rcu;
+	struct xps_map *cpu_map[0];
+};
+#define netdev_get_xps_maps(dev) ((dev)->_tx[0].xps_maps)
+
+/*
  * The rps_dev_flow structure contains the mapping of a flow to a CPU and the
  * tail pointer for that CPU's input queue at the time of last enqueue.
  */
diff --git a/net/core/dev.c b/net/core/dev.c
index 4df783c..12426a6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2119,6 +2119,44 @@ static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_index)
 	return queue_index;
 }
 
+static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
+{
+#ifdef CONFIG_RPS
+	struct xps_dev_maps *dev_maps;
+	struct xps_map *map;
+	int queue_index = -1;
+
+	preempt_disable();
+	rcu_read_lock();
+	dev_maps = rcu_dereference(netdev_get_xps_maps(dev));
+	if (dev_maps) {
+		map = rcu_dereference(dev_maps->cpu_map[smp_processor_id()]);
+		if (map) {
+			if (map->len == 1)
+				queue_index = map->queues[0];
+			else {
+				u32 hash;
+				if (skb->sk && skb->sk->sk_hash)
+					hash = skb->sk->sk_hash;
+				else
+					hash = (__force u16) skb->protocol ^
+					    skb->rxhash;
+				hash = jhash_1word(hash, hashrnd);
+				queue_index = map->queues[
+				    ((u64)hash * map->len) >> 32];
+			}
+			if (unlikely(queue_index >= dev->real_num_tx_queues))
+				queue_index = -1;
+		}
+	}
+	rcu_read_unlock();
+	preempt_enable();
+
+	return queue_index;
+#endif
+	return -1;
+}
+
 static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 					struct sk_buff *skb)
 {
@@ -2138,7 +2176,9 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 		    queue_index >= dev->real_num_tx_queues) {
 			int old_index = queue_index;
 
-			queue_index = skb_tx_hash(dev, skb);
+			queue_index = get_xps_queue(dev, skb);
+			if (queue_index < 0)
+				queue_index = skb_tx_hash(dev, skb);
 
 			if (queue_index != old_index && sk) {
 				struct dst_entry *dst =
@@ -5052,6 +5092,17 @@ static int netif_alloc_netdev_queues(struct net_device *dev)
 		return -ENOMEM;
 	}
 	dev->_tx = tx;
+#ifdef CONFIG_RPS
+	/*
+	 * Set a pointer to first element in the array which holds the
+	 * reference count.
+	 */
+	{
+		int i;
+		for (i = 0; i < count; i++)
+			tx[i].first = tx;
+	}
+#endif
 	return 0;
 }
 
@@ -5616,7 +5667,9 @@ void free_netdev(struct net_device *dev)
 
 	release_net(dev_net(dev));
 
+#ifndef CONFIG_RPS
 	kfree(dev->_tx);
+#endif
 
 	kfree(rcu_dereference_raw(dev->ingress_queue));
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index b143173..e193cf2 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -764,18 +764,375 @@ net_rx_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
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
+static const struct sysfs_ops netdev_queue_sysfs_ops = {
+	.show = netdev_queue_attr_show,
+	.store = netdev_queue_attr_store,
+};
+
+static inline unsigned int get_netdev_queue_index(struct netdev_queue *queue)
+{
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
+
+static ssize_t show_xps_map(struct netdev_queue *queue,
+			    struct netdev_queue_attribute *attribute, char *buf)
+{
+	struct netdev_queue *first = queue->first;
+	struct xps_dev_maps *dev_maps;
+	cpumask_var_t mask;
+	unsigned long index;
+	size_t len = 0;
+	int i;
+
+	if (!zalloc_cpumask_var(&mask, GFP_KERNEL))
+		return -ENOMEM;
+
+	index = get_netdev_queue_index(queue);
+
+	rcu_read_lock();
+	dev_maps = rcu_dereference(first->xps_maps);
+	if (dev_maps) {
+		for (i = 0; i < num_possible_cpus(); i++) {
+			struct xps_map *map =
+			    rcu_dereference(dev_maps->cpu_map[i]);
+			if (map) {
+				int j;
+				for (j = 0; j < map->len; j++) {
+					if (map->queues[j] == index) {
+						cpumask_set_cpu(i, mask);
+						break;
+					}
+				}
+			}
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
+}
+
+static void xps_dev_maps_release(struct rcu_head *rcu)
 {
+	struct xps_dev_maps *dev_maps =
+	    container_of(rcu, struct xps_dev_maps, rcu);
+
+	kfree(dev_maps);
+}
+
+static DEFINE_MUTEX(xps_map_mutex);
+
+static ssize_t store_xps_map(struct netdev_queue *queue,
+		      struct netdev_queue_attribute *attribute,
+		      const char *buf, size_t len)
+{
+	struct netdev_queue *first = queue->first;
+	cpumask_var_t mask;
+	int err, i, cpu, pos, map_len, alloc_len, need_set;
+	unsigned long index;
+	struct xps_map *map, *new_map;
+	struct xps_dev_maps *dev_maps, *new_dev_maps;
+	int nonempty = 0;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
+		return -ENOMEM;
+
+	index = get_netdev_queue_index(queue);
+
+	err = bitmap_parse(buf, len, cpumask_bits(mask), nr_cpumask_bits);
+	if (err) {
+		free_cpumask_var(mask);
+		return err;
+	}
+
+	new_dev_maps = kzalloc(sizeof(struct xps_dev_maps) +
+	    (num_possible_cpus() * sizeof(struct xps_map *)), GFP_KERNEL);
+	if (!new_dev_maps) {
+		free_cpumask_var(mask);
+		return err;
+	}
+
+	mutex_lock(&xps_map_mutex);
+
+	dev_maps = first->xps_maps;
+
+	for (cpu = 0; cpu < num_possible_cpus(); cpu++) {
+		new_map = map = dev_maps ? dev_maps->cpu_map[cpu] : NULL;
+
+		if (map) {
+			for (pos = 0; pos < map->len; pos++)
+				if (map->queues[pos] == index)
+					break;
+			map_len = map->len;
+			alloc_len = map->alloc_len;
+		} else
+			pos = map_len = alloc_len = 0;
+
+		need_set = cpu_isset(cpu, *mask) && cpu_online(cpu);
+
+		if (need_set && pos >= map_len) {
+			/* Need to add queue to this CPU's map */
+			if (map_len >= alloc_len) {
+				alloc_len = alloc_len ?  2 * alloc_len : 1;
+				new_map = kzalloc(sizeof(struct xps_map) +
+				    (alloc_len * sizeof(u16)), GFP_KERNEL);
+				if (!new_map)
+					goto error;
+				new_map->alloc_len = alloc_len;
+				for (i = 0; i < map_len; i++)
+					new_map->queues[i] = map->queues[i];
+				new_map->len = map_len;
+			}
+			new_map->queues[new_map->len++] = index;
+		} else if (!need_set && pos < map_len) {
+			/* Need to remove queue from this CPU's map */
+			if (map_len > 1)
+				new_map->queues[pos] =
+				    new_map->queues[--new_map->len];
+			else
+				new_map = NULL;
+		}
+		new_dev_maps->cpu_map[cpu] = new_map;
+	}
+
+	/* Cleanup old maps */
+	for (cpu = 0; cpu < num_possible_cpus(); cpu++) {
+		map = dev_maps ? dev_maps->cpu_map[cpu] : NULL;
+		if (map && new_dev_maps->cpu_map[cpu] != map)
+			call_rcu(&map->rcu, xps_map_release);
+		if (new_dev_maps->cpu_map[cpu])
+			nonempty = 1;
+	}
+
+	if (nonempty)
+		rcu_assign_pointer(first->xps_maps, new_dev_maps);
+	else {
+		kfree(new_dev_maps);
+		rcu_assign_pointer(first->xps_maps, NULL);
+	}
+
+	if (dev_maps)
+		call_rcu(&dev_maps->rcu, xps_dev_maps_release);
+
+	mutex_unlock(&xps_map_mutex);
+
+	free_cpumask_var(mask);
+	return len;
+
+error:
+	mutex_unlock(&xps_map_mutex);
+
+	if (new_dev_maps)
+		for (i = 0; i < num_possible_cpus(); i++)
+			kfree(new_dev_maps->cpu_map[i]);
+
+	kfree(new_dev_maps);
+	free_cpumask_var(mask);
+	return -ENOMEM;
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
+	struct netdev_queue *first = queue->first;
+	struct xps_dev_maps *dev_maps;
+	struct xps_map *map;
+	unsigned long index;
+	int i, pos, nonempty = 0;
+
+	index = get_netdev_queue_index(queue);
+
+	mutex_lock(&xps_map_mutex);
+	dev_maps = first->xps_maps;
+
+	for (i = 0; i < num_possible_cpus(); i++) {
+		map  = dev_maps ? dev_maps->cpu_map[i] : NULL;
+		if (!map)
+			continue;
+
+		for (pos = 0; pos < map->len; pos++)
+			if (map->queues[pos] == index)
+				break;
+
+		if (pos < map->len) {
+			if (map->len > 1)
+				map->queues[pos] = map->queues[--map->len];
+			else {
+				rcu_assign_pointer(dev_maps->cpu_map[i],
+				    NULL);
+				call_rcu(&map->rcu, xps_map_release);
+				map = NULL;
+			}
+		}
+
+		if (map)
+			nonempty = 1;
+	}
+
+	if (!nonempty) {
+		rcu_assign_pointer(first->xps_maps, NULL);
+		call_rcu(&dev_maps->rcu, xps_dev_maps_release);
+	}
+	mutex_unlock(&xps_map_mutex);
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
+	int error = 0, txq = 0, rxq = 0;
+
 	net->queues_kset = kset_create_and_add("queues",
 	    NULL, &net->dev.kobj);
 	if (!net->queues_kset)
 		return -ENOMEM;
-	return net_rx_queue_update_kobjects(net, 0, net->real_num_rx_queues);
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
 }
 
-static void rx_queue_remove_kobjects(struct net_device *net)
+static void remove_queue_kobjects(struct net_device *net)
 {
 	net_rx_queue_update_kobjects(net, net->real_num_rx_queues, 0);
+	netdev_queue_update_kobjects(net, net->real_num_tx_queues, 0);
 	kset_unregister(net->queues_kset);
 }
 #endif /* CONFIG_RPS */
@@ -878,7 +1235,7 @@ void netdev_unregister_kobject(struct net_device * net)
 	kobject_get(&dev->kobj);
 
 #ifdef CONFIG_RPS
-	rx_queue_remove_kobjects(net);
+	remove_queue_kobjects(net);
 #endif
 
 	device_del(dev);
@@ -919,7 +1276,7 @@ int netdev_register_kobject(struct net_device *net)
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
-- 
1.7.1

