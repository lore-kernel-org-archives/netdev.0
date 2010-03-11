From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] rps: Receive Packet Steering
Date: Thu, 11 Mar 2010 15:45:38 +0100
Message-ID: <1268318738.2986.518.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1003102249380.21248@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	bhutchings@solarflare.com, shemminger@vyatta.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:62876 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757886Ab0CKOpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 09:45:45 -0500
Received: by bwz1 with SMTP id 1so94401bwz.21
        for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 06:45:43 -0800 (PST)
In-Reply-To: <alpine.DEB.1.00.1003102249380.21248@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 10 mars 2010 =C3=A0 23:00 -0800, Tom Herbert a =C3=A9crit :
> Added explicit entries entries in sysfs to set RPS cpus for each devi=
ce queue.  This includes:
>=20
> - Create RX queue instances which are attached to each netdevice (net=
dev_rx_queue).  These are analogous to the netdev_queue structures whic=
h are used for transmit.  RX queue instances hold an rps_map.
> - RX queues are allocated in alloc_netdev_mq for the given queue_coun=
t (basically we're assuming #RX queues =3D=3D #TX queues).  If a driver=
 does not call alloc_netdev_mq, a single instance is created in registe=
r_netdevice.
> - Added subdrectories in sysfs for per-queue RPS settings.  These are=
 in /sys/class/net/eth<n>/queues/rx-<n>.  The "queues" directory is not=
 necessary, but keeps the eth<n> directory clean (I don't have a stong =
opinion on this).  Presumably, if TX queues needed entries that could g=
o under tx-<n>
>=20
> Also addessed some previous issues raised:
> - Copy rxhash in skb_clone
> - Took __netif_receive_skb out of kernel-doc
> - Removed VLA containing VLA ugliness (rx queues above fixed that)
> - Copy and clear rps_mask before calling net_rps_action
>=20

Pretty much exciting day began, thanks Tom !

I reviewed/tested your V6 patch, and have few comments :

- When a netdevice is freed, I believe you leak rps_maps if they were
previously allocated. I found following patch necessary to fix it.

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index a07d6ec..ef82b9d 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -596,7 +596,10 @@ static struct attribute *rx_queue_default_attrs[] =
=3D
{
 static void rx_queue_release(struct kobject *kobj)
 {
        struct netdev_rx_queue *queue =3D to_rx_queue(kobj);
+       struct rps_map *map =3D queue->rps_map;
=20
+       if (map)
+               call_rcu(&map->rcu, rps_map_release);
        kfree(queue);
 }
=20
- memory leak in alloc_netdev_mq() if dev_addr_init() fails
	-> must use goto free_rx;


- Maybe use max(RPM_MAP_SIZE(x), L1_CACHE_BYTES) for allocations to
avoid false sharing for small maps. (Or else, other part of cache line
might be given to a user that might dirty it at high rate)

- "struct netdev_rx_queue" being only read in fast path, I am not sure
an alignement is necessary, apart the false sharing that can be
separately addressed.


- A double indirection to get a struct netdev_rx_queue pointer is
expensive, not for heavy load benchmarks, but for latencies in seldom
used devices. I understand you added this for kobject deferred release
and kfreeing, but this seems a high price to pay in our fast path. I
used another solution.


- WARN(1, "Recieved packet on %s for queue %u, "
   -> Received

- Use of cpumask_t for variable on stack is discouraged, we shall use
cpumask_var_t if possible. Easy for show/store commands. (see my patch)

Yet, adding a memory allocation in net_rx_action() seems overkill, so w=
e
might use two static masks per cpu, and perform a flip ? This would hel=
p
machines with 4096 cpus : To Be Done ?


- RTNL to guard rps map exchange ???
This sounds like BKL (Big Kernel Lock) syndrom to me :
Trying to avoid it if possible is better, because it wont exist anymore
in ten years with 0.99 probability.


=46or ease of discussion, I cooked following patch on top of yours :

Thanks !

 include/linux/netdevice.h |    8 ++-
 net/core/dev.c            |   64 ++++++++++-------------------
 net/core/net-sysfs.c      |   78 ++++++++++++++++++++++--------------
 3 files changed, 77 insertions(+), 73 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 468da0a..3f4a986 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -544,9 +544,11 @@ struct rps_map {
=20
 /* This structure contains an instance of an RX queue. */
 struct netdev_rx_queue {
-	struct kobject kobj;
 	struct rps_map *rps_map;
-} ____cacheline_aligned_in_smp;
+	struct kobject kobj;
+	struct netdev_rx_queue *first;
+	atomic_t count;
+};
=20
 /*
  * This structure defines the management hooks for network devices.
@@ -897,7 +899,7 @@ struct net_device {
=20
 	struct kset		*queues_kset;
=20
-	struct netdev_rx_queue	**_rx;
+	struct netdev_rx_queue	*_rx;
=20
 	/* Number of RX queues allocated at alloc_netdev_mq() time  */
 	unsigned int		num_rx_queues;
diff --git a/net/core/dev.c b/net/core/dev.c
index 939b1a2..402f23a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2195,15 +2195,15 @@ static int get_rps_cpu(struct net_device *dev, =
struct sk_buff *skb)
 		u16 index =3D skb_get_rx_queue(skb);
 		if (unlikely(index >=3D dev->num_rx_queues)) {
 			if (net_ratelimit()) {
-				WARN(1, "Recieved packet on %s for queue %u, "
+				WARN(1, "Received packet on %s for queue %u, "
 				    "but number of RX queues is %u\n",
 				     dev->name, index, dev->num_rx_queues);
 			}
 			goto done;
 		}
-		rxqueue =3D dev->_rx[index];
+		rxqueue =3D dev->_rx + index;
 	} else
-		rxqueue =3D dev->_rx[0];
+		rxqueue =3D dev->_rx;
=20
 	if (!rxqueue->rps_map)
 		goto done;
@@ -5236,20 +5236,17 @@ int register_netdevice(struct net_device *dev)
 		 * alloc_netdev_mq
 		 */
=20
-		dev->_rx =3D kzalloc(sizeof(struct netdev_rx_queue *),
-		    GFP_KERNEL);
+		dev->_rx =3D kzalloc(max_t(unsigned,
+					 sizeof(struct netdev_rx_queue),
+					 L1_CACHE_BYTES),
+				   GFP_KERNEL);
 		if (!dev->_rx) {
 			ret =3D -ENOMEM;
 			goto out;
 		}
=20
-		dev->_rx[0] =3D kzalloc(sizeof(struct netdev_rx_queue),
-		    GFP_KERNEL);
-		if (!dev->_rx[0]) {
-			kfree(dev->_rx);
-			ret =3D -ENOMEM;
-			goto out;
-		}
+		dev->_rx[0].first =3D dev->_rx;
+		atomic_set(&dev->_rx[0].count, 1);
 		dev->num_rx_queues =3D 1;
 	}
=20
@@ -5610,7 +5607,7 @@ struct net_device *alloc_netdev_mq(int sizeof_pri=
v, const char *name,
 		void (*setup)(struct net_device *), unsigned int queue_count)
 {
 	struct netdev_queue *tx;
-	struct netdev_rx_queue **rx;
+	struct netdev_rx_queue *rx;
 	struct net_device *dev;
 	size_t alloc_size;
 	struct net_device *p;
@@ -5635,37 +5632,30 @@ struct net_device *alloc_netdev_mq(int sizeof_p=
riv, const char *name,
=20
 	tx =3D kcalloc(queue_count, sizeof(struct netdev_queue), GFP_KERNEL);
 	if (!tx) {
-		printk(KERN_ERR "alloc_netdev: Unable to allocate "
-		       "tx qdiscs.\n");
+		pr_err("alloc_netdev: Unable to allocate tx qdiscs.\n");
 		goto free_p;
 	}
=20
-	/*
-	 * Allocate RX queue structures, this includes an array of pointers
-	 * and netdev_queue_rx stuctures (individually allocated since
-	 * each has a kobject).
-	 */
-	rx =3D kzalloc(queue_count *
-	    sizeof(struct netdev_rx_queue *), GFP_KERNEL);
+	rx =3D kzalloc(max_t(unsigned,
+			   queue_count * sizeof(struct netdev_rx_queue),
+			   L1_CACHE_BYTES),
+		     GFP_KERNEL);
 	if (!rx) {
-		printk(KERN_ERR "alloc_netdev: Unable to allocate "
-		       "rx queues array.\n");
+		pr_err("alloc_netdev: Unable to allocate rx queues.\n");
 		goto free_tx;
 	}
-	for (i =3D 0; i < queue_count; i++) {
-		rx[i] =3D kzalloc(sizeof(struct netdev_rx_queue), GFP_KERNEL);
-		if (!rx[i]) {
-			printk(KERN_ERR "alloc_netdev: Unable to allocate "
-			    "rx queues.\n");
-			goto free_rx;
-		}
-	}
+	atomic_set(&rx->count, queue_count);
+	/*
+	 * Use counter is located in first element of this array
+	 */
+	for (i =3D 0; i < queue_count; i++)
+		rx[i].first =3D rx;
=20
 	dev =3D PTR_ALIGN(p, NETDEV_ALIGN);
 	dev->padded =3D (char *)dev - (char *)p;
=20
 	if (dev_addr_init(dev))
-		goto free_tx;
+		goto free_rx;
=20
 	dev_unicast_init(dev);
=20
@@ -5693,8 +5683,6 @@ struct net_device *alloc_netdev_mq(int sizeof_pri=
v, const char *name,
 	return dev;
=20
 free_rx:
-	for (i =3D 0; i < queue_count; i++)
-		kfree(rx[i]);
 	kfree(rx);
 free_tx:
 	kfree(tx);
@@ -5720,12 +5708,6 @@ void free_netdev(struct net_device *dev)
=20
 	kfree(dev->_tx);
=20
-	/*
-	 * Free RX queue pointer array.  Actual netdev_rx_queue objects are
-	 * freed by kobject release.
-	 */
-	kfree(dev->_rx);
-
 	/* Flush device addresses */
 	dev_addr_flush(dev);
=20
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index a07d6ec..de75258 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -516,24 +516,26 @@ static ssize_t show_rps_map(struct netdev_rx_queu=
e *queue,
 	size_t len =3D 0;
 	struct rps_map *map;
 	int i;
-	cpumask_t mask;
+	cpumask_var_t mask;
=20
-	cpus_clear(mask);
+	if (!zalloc_cpumask_var(&mask, GFP_KERNEL))
+		return -ENOMEM;
=20
 	rcu_read_lock();
 	map =3D rcu_dereference(queue->rps_map);
 	if (map) {
 		for (i =3D 0; i < map->len; i++)
-			cpu_set(map->cpus[i], mask);
+			cpumask_set_cpu(map->cpus[i], mask);
=20
-		len +=3D cpumask_scnprintf(buf + len, PAGE_SIZE, &mask);
+		len +=3D cpumask_scnprintf(buf + len, PAGE_SIZE, mask);
 		if (PAGE_SIZE - len < 3) {
 			rcu_read_unlock();
+			free_cpumask_var(mask);
 			return -EINVAL;
 		}
 	}
 	rcu_read_unlock();
-
+	free_cpumask_var(mask);
 	len +=3D sprintf(buf + len, "\n");
 	return len;
 }
@@ -550,38 +552,48 @@ ssize_t store_rps_map(struct netdev_rx_queue *que=
ue,
 		      const char *buf, size_t len)
 {
 	struct rps_map *old_map, *map;
-	cpumask_t mask;
-	int err, cpu, i, weight;
+	cpumask_var_t mask;
+	int err, cpu, i;
+	static DEFINE_SPINLOCK(rps_map_lock);
=20
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
=20
-	err =3D bitmap_parse(buf, len, cpumask_bits(&mask), nr_cpumask_bits);
-	if (err)
+	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
+		return -ENOMEM;
+
+	err =3D bitmap_parse(buf, len, cpumask_bits(mask), nr_cpumask_bits);
+	if (err) {
+		free_cpumask_var(mask);
 		return err;
+	}
+	map =3D kzalloc(max_t(unsigned,
+			    RPS_MAP_SIZE(cpumask_weight(mask)),
+			    L1_CACHE_BYTES),
+		      GFP_KERNEL);
+	if (!map) {
+		free_cpumask_var(mask);
+		return -ENOMEM;
+	}
+	i =3D 0;
+	for_each_cpu_and(cpu, mask, cpu_online_mask)
+		map->cpus[i++] =3D cpu;
+	if (i)
+ 		map->len =3D i;
+	else {
+		kfree(map);
+ 		map =3D NULL;
+	}
=20
-	weight =3D cpumask_weight(&mask);
-	if (weight) {
-		map =3D kzalloc(RPS_MAP_SIZE(weight), GFP_KERNEL);
-		if (!map)
-			return -ENOMEM;
-
-		cpus_and(mask, mask, cpu_online_map);
-		i =3D 0;
-		for_each_cpu_mask(cpu, mask)
-			map->cpus[i++] =3D cpu;
-		map->len =3D i;
-	} else
-		map =3D NULL;
-
-	rtnl_lock();
+	spin_lock(&rps_map_lock);
 	old_map =3D queue->rps_map;
 	rcu_assign_pointer(queue->rps_map, map);
-	rtnl_unlock();
+	spin_unlock(&rps_map_lock);
=20
 	if (old_map)
 		call_rcu(&old_map->rcu, rps_map_release);
=20
+	free_cpumask_var(mask);
 	return len;
 }
=20
@@ -596,8 +608,16 @@ static struct attribute *rx_queue_default_attrs[] =
=3D {
 static void rx_queue_release(struct kobject *kobj)
 {
 	struct netdev_rx_queue *queue =3D to_rx_queue(kobj);
+	struct rps_map *map =3D queue->rps_map;
+	struct netdev_rx_queue *first =3D queue->first;
=20
-	kfree(queue);
+	if (map)
+		call_rcu(&map->rcu, rps_map_release);
+	/*
+	 * Free the array containing us only if all elems were released
+	 */
+	if (atomic_dec_and_test(&first->count))
+		kfree(first);
 }
=20
 static struct kobj_type rx_queue_ktype =3D {
@@ -609,7 +629,7 @@ static struct kobj_type rx_queue_ktype =3D {
 static int rx_queue_add_kobject(struct net_device *net, int index)
 {
 	int error =3D 0;
-	struct netdev_rx_queue *queue =3D net->_rx[index];
+	struct netdev_rx_queue *queue =3D net->_rx + index;
 	struct kobject *kobj =3D &queue->kobj;
=20
 	kobj->kset =3D net->queues_kset;
@@ -642,7 +662,7 @@ static int rx_queue_register_kobjects(struct net_de=
vice *net)
=20
 	if (error)
 		while (--i >=3D 0)
-			kobject_put(&net->_rx[i]->kobj);
+			kobject_put(&net->_rx[i].kobj);
=20
 	return error;
 }
@@ -652,7 +672,7 @@ static void rx_queue_remove_kobjects(struct net_dev=
ice *net)
 	int i;
=20
 	for (i =3D 0; i < net->num_rx_queues; i++)
-		kobject_put(&net->_rx[i]->kobj);
+		kobject_put(&net->_rx[i].kobj);
 	kset_unregister(net->queues_kset);
 }
=20


