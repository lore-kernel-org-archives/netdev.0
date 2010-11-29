From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] sched: use xps information for qdisc NUMA
 affinity
Date: Mon, 29 Nov 2010 19:14:37 +0100
Message-ID: <1291054477.3435.1302.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1011211501430.14906@pokey.mtv.corp.google.com>
	 <1290705163.4274.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64119 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049Ab0K2SOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 13:14:43 -0500
Received: by wyb28 with SMTP id 28so4702559wyb.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 10:14:41 -0800 (PST)
In-Reply-To: <1290705163.4274.12.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was thinking of using XPS tx_queue->cpu mapping to eventually allocate
memory with correct NUMA affinities, for qdisc/class stuff for example.

Here is a first patch to allocate qdisc with proper NUMA affinities.

Tested on my 16-cpus machine

echo 0001 >/sys/class/net/eth1/queues/tx-0/xps_cpus
echo 0002 >/sys/class/net/eth1/queues/tx-1/xps_cpus
echo 0004 >/sys/class/net/eth1/queues/tx-2/xps_cpus
echo 0008 >/sys/class/net/eth1/queues/tx-3/xps_cpus
echo 0010 >/sys/class/net/eth1/queues/tx-4/xps_cpus
echo 0020 >/sys/class/net/eth1/queues/tx-5/xps_cpus
echo 0040 >/sys/class/net/eth1/queues/tx-6/xps_cpus
echo 0080 >/sys/class/net/eth1/queues/tx-7/xps_cpus
echo 0100 >/sys/class/net/eth1/queues/tx-8/xps_cpus
echo 0200 >/sys/class/net/eth1/queues/tx-9/xps_cpus
echo 0400 >/sys/class/net/eth1/queues/tx-10/xps_cpus
echo 0800 >/sys/class/net/eth1/queues/tx-11/xps_cpus
echo 1000 >/sys/class/net/eth1/queues/tx-12/xps_cpus
echo 2000 >/sys/class/net/eth1/queues/tx-13/xps_cpus
echo 4000 >/sys/class/net/eth1/queues/tx-14/xps_cpus
echo 8000 >/sys/class/net/eth1/queues/tx-15/xps_cpus

tc qdisc del dev eth1 root
tc qdisc add dev eth1 root mq

Thanks

[PATCH net-next-2.6] sched: use xps information for qdisc NUMA affinity

Allocate qdisc memory according to NUMA properties of cpus included in
xps map.

To be effective, qdisc should be (re)setup after changes
of /sys/class/net/eth<n>/queues/tx-<n>/xps_cpus

I added a numa_node field in struct netdev_queue, containing NUMA node
if all cpus included in xps_cpus share same node, else -1.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |   20 +++++++++++++++++++-
 net/core/dev.c            |    5 +++--
 net/core/net-sysfs.c      |   12 +++++++++++-
 net/sched/sch_generic.c   |    4 +++-
 4 files changed, 36 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9ae4544..f912de7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -508,7 +508,9 @@ struct netdev_queue {
 #ifdef CONFIG_RPS
 	struct kobject		kobj;
 #endif
-
+#if defined(CONFIG_XPS) && defined(CONFIG_NUMA)
+	int			numa_node;
+#endif
 /*
  * write mostly part
  */
@@ -523,6 +525,22 @@ struct netdev_queue {
 	u64			tx_dropped;
 } ____cacheline_aligned_in_smp;
 
+static inline int netdev_queue_numa_node_read(const struct netdev_queue *q)
+{
+#if defined(CONFIG_XPS) && defined(CONFIG_NUMA)
+	return q->numa_node;
+#else
+	return -1;
+#endif
+}
+
+static inline void netdev_queue_numa_node_write(struct netdev_queue *q, int node)
+{
+#if defined(CONFIG_XPS) && defined(CONFIG_NUMA)
+	q->numa_node = node;
+#endif
+}
+
 #ifdef CONFIG_RPS
 /*
  * This structure holds an RPS map which can be of variable length.  The
diff --git a/net/core/dev.c b/net/core/dev.c
index 3259d2c..cd24374 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5125,9 +5125,10 @@ static int netif_alloc_netdev_queues(struct net_device *dev)
 	}
 	dev->_tx = tx;
 
-	for (i = 0; i < count; i++)
+	for (i = 0; i < count; i++) {
+		netdev_queue_numa_node_write(&tx[i], -1);
 		tx[i].dev = dev;
-
+	}
 	return 0;
 }
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 99c1129..149dde0 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -911,6 +911,7 @@ static ssize_t store_xps_map(struct netdev_queue *queue,
 	struct xps_map *map, *new_map;
 	struct xps_dev_maps *dev_maps, *new_dev_maps;
 	int nonempty = 0;
+	int numa_node = -2;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -950,7 +951,14 @@ static ssize_t store_xps_map(struct netdev_queue *queue,
 			pos = map_len = alloc_len = 0;
 
 		need_set = cpu_isset(cpu, *mask) && cpu_online(cpu);
-
+#ifdef CONFIG_NUMA
+		if (need_set) {
+			if (numa_node == -2)
+				numa_node = cpu_to_node(cpu);
+			else if (numa_node != cpu_to_node(cpu))
+				numa_node = -1;
+		}
+#endif
 		if (need_set && pos >= map_len) {
 			/* Need to add queue to this CPU's map */
 			if (map_len >= alloc_len) {
@@ -996,6 +1004,8 @@ static ssize_t store_xps_map(struct netdev_queue *queue,
 	if (dev_maps)
 		call_rcu(&dev_maps->rcu, xps_dev_maps_release);
 
+	netdev_queue_numa_node_write(queue, (numa_node >= 0) ? numa_node : -1);
+
 	mutex_unlock(&xps_map_mutex);
 
 	free_cpumask_var(mask);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 7f0bd89..0918834 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -553,7 +553,9 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 	size = QDISC_ALIGN(sizeof(*sch));
 	size += ops->priv_size + (QDISC_ALIGNTO - 1);
 
-	p = kzalloc(size, GFP_KERNEL);
+	p = kzalloc_node(size, GFP_KERNEL,
+			 netdev_queue_numa_node_read(dev_queue));
+
 	if (!p)
 		goto errout;
 	sch = (struct Qdisc *) QDISC_ALIGN((unsigned long) p);


