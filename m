From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: [RFC v2: Patch 2/3] net: hand off skb list to other cpu to submit
	to upper layer
Date: Wed, 11 Mar 2009 16:53:50 +0800
Message-ID: <1236761630.2567.443.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, jesse.brandeburg@intel.com,
	shemminger@vyatta.com, David Miller <davem@davemloft.net>
To: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18531 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753520AbZCKIyV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2009 04:54:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: net: hand off skb list to other cpu to submit to upper layer
=46rom: =EF=BB=BFZhang Yanmin <yanmin.zhang@linux.intel.com>=EF=BB=BF

Add new sysfs interface /sys/class/net/ethXXX/rx_queueXXX/processing_cp=
u. Admin
could use it to configure the binding between RX and cpu number. So it'=
s convenient
for driver to use the new capability.

=46unction=EF=BB=BF alloc_netdev_rxtx_mq is called by drivers to initia=
te netdev with RX queue.
=EF=BB=BF
Signed-off-by: =EF=BB=BFZhang Yanmin <yanmin.zhang@linux.intel.com>

---

--- linux-2.6.29-rc7_backlog/include/linux/netdevice.h	2009-03-11 10:17=
:08.000000000 +0800
+++ linux-2.6.29-rc7_rxqueue_sysfs/include/linux/netdevice.h	2009-03-11=
 13:26:23.000000000 +0800
@@ -443,6 +443,10 @@ struct netdev_queue {
 	struct Qdisc		*qdisc_sleeping;
 } ____cacheline_aligned_in_smp;
=20
+struct netdev_queue_attr {
+	struct kobject		kobj;
+	int			processing_cpu;
+};
=20
 /*
  * This structure defines the management hooks for network devices.
@@ -760,6 +764,10 @@ struct net_device
=20
 	struct netdev_queue	rx_queue;
=20
+	/* Export by sysfs */
+	struct netdev_queue_attr *_rx_attr;
+	unsigned int		num_rx_queues;
+
 	struct netdev_queue	*_tx ____cacheline_aligned_in_smp;
=20
 	/* Number of TX queues allocated at alloc_netdev_mq() time  */
@@ -770,6 +778,7 @@ struct net_device
=20
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
 	spinlock_t		tx_global_lock;
+
 /*
  * One part is mostly used on xmit path (device)
  */
@@ -1773,10 +1782,28 @@ static inline void netif_addr_unlock_bh(
=20
 extern void		ether_setup(struct net_device *dev);
=20
+static inline int netif_rx_processing_cpu(struct net_device *dev, int =
rx_num)
+{
+	int cpu =3D -1;
+
+	if (rx_num >=3D 0 && rx_num < dev->num_rx_queues)
+		cpu =3D dev->_rx_attr[rx_num].processing_cpu;
+
+	if (cpu =3D=3D -1)
+		cpu =3D smp_processor_id();
+
+	return cpu;
+}
+
 /* Support for loadable net-drivers */
 extern struct net_device *alloc_netdev_mq(int sizeof_priv, const char =
*name,
 				       void (*setup)(struct net_device *),
 				       unsigned int queue_count);
+extern struct net_device *alloc_netdev_rxtx_mq(int sizeof_priv,
+				const char *name,
+				void (*setup)(struct net_device *),
+				unsigned int rx_queue_count,
+				unsigned int tx_queue_count);
 #define alloc_netdev(sizeof_priv, name, setup) \
 	alloc_netdev_mq(sizeof_priv, name, setup, 1)
 extern int		register_netdev(struct net_device *dev);
--- linux-2.6.29-rc7_backlog/include/linux/etherdevice.h	2009-03-11 10:=
16:16.000000000 +0800
+++ linux-2.6.29-rc7_rxqueue_sysfs/include/linux/etherdevice.h	2009-03-=
10 12:53:59.000000000 +0800
@@ -51,6 +51,9 @@ extern int eth_validate_addr(struct net_
 extern struct net_device *alloc_etherdev_mq(int sizeof_priv, unsigned =
int queue_count);
 #define alloc_etherdev(sizeof_priv) alloc_etherdev_mq(sizeof_priv, 1)
=20
+extern struct net_device *alloc_etherdev_rxtx_mq(int sizeof_priv,
+		unsigned int rx_queue_count, unsigned int tx_queue_count);
+
 /**
  * is_zero_ether_addr - Determine if give Ethernet address is all zero=
s.
  * @addr: Pointer to a six-byte array containing the Ethernet address
--- linux-2.6.29-rc7_backlog/net/core/dev.c	2009-03-11 10:27:57.0000000=
00 +0800
+++ linux-2.6.29-rc7_rxqueue_sysfs/net/core/dev.c	2009-03-11 13:26:23.0=
00000000 +0800
@@ -4862,6 +4862,39 @@ struct net_device *alloc_netdev_mq(int s
 }
 EXPORT_SYMBOL(alloc_netdev_mq);
=20
+struct net_device *alloc_netdev_rxtx_mq(int sizeof_priv,
+		const char *name,
+		void (*setup)(struct net_device *),
+		unsigned int rx_queue_count,
+		unsigned int tx_queue_count)
+{
+	struct netdev_queue_attr *rx;
+	struct net_device *dev;
+	int i;
+
+	dev =3D alloc_netdev_mq(sizeof_priv, name, setup, tx_queue_count);
+	if (dev && rx_queue_count) {
+		rx =3D kcalloc(rx_queue_count,
+			sizeof(struct netdev_queue_attr),
+			GFP_KERNEL);
+		if (!rx) {
+			printk(KERN_ERR "alloc_netdev: Unable to allocate "
+					"rx attributes.\n");
+			free_netdev(dev);
+			return NULL;
+		}
+
+		for (i =3D 0; i < rx_queue_count; i ++)
+			rx[i].processing_cpu =3D -1;
+
+		dev->_rx_attr =3D rx;
+		dev->num_rx_queues =3D rx_queue_count;
+	}
+
+	return dev;
+}
+EXPORT_SYMBOL(alloc_netdev_rxtx_mq);
+
 /**
  *	free_netdev - free network device
  *	@dev: device
@@ -4877,6 +4910,7 @@ void free_netdev(struct net_device *dev)
 	release_net(dev_net(dev));
=20
 	kfree(dev->_tx);
+	kfree(dev->_rx_attr);
=20
 	list_for_each_entry_safe(p, n, &dev->napi_list, dev_list)
 		netif_napi_del(p);
--- linux-2.6.29-rc7_backlog/net/core/net-sysfs.c	2009-03-11 10:15:23.0=
00000000 +0800
+++ linux-2.6.29-rc7_rxqueue_sysfs/net/core/net-sysfs.c	2009-03-11 13:1=
8:45.000000000 +0800
@@ -419,6 +419,83 @@ static struct attribute_group wireless_g
 };
 #endif
=20
+#define to_rx_queue_attr(k)	container_of(k, struct netdev_queue_attr, =
kobj)
+#define RX_QUEUE_ATTR(name)				\
+static struct kobj_attribute name##_attr =3D		\
+	__ATTR(name, 0644, show_##name, store_##name);
+
+static ssize_t show_processing_cpu(struct kobject *kobj,
+			struct kobj_attribute *attr,
+			char *buf)
+{
+	return sprintf(buf, "%d", to_rx_queue_attr(kobj)->processing_cpu);
+}
+
+static ssize_t store_processing_cpu(struct kobject *kobj,
+		struct kobj_attribute *attr,
+		const char *buf,
+		size_t count)
+{
+	int var;
+	sscanf(buf, "%d", &var);
+	if ((var >=3D 0 && var < nr_cpu_ids) || var =3D=3D -1) {
+		to_rx_queue_attr(kobj)->processing_cpu =3D var;
+		return count;
+	} else
+		return -EINVAL;
+}
+
+RX_QUEUE_ATTR(processing_cpu);
+
+static struct attribute *rx_queue_attrs[] =3D {
+	&processing_cpu_attr.attr,
+	NULL
+};
+
+static struct kobj_type ktype_rx_queue =3D {
+	.sysfs_ops      =3D &kobj_sysfs_ops,
+	.default_attrs  =3D rx_queue_attrs
+};
+
+static int sysfs_net_remove_rx_queue(struct net_device *net,
+		int rx_queue_count)
+{
+	int i;
+
+	for (i =3D 0; i < rx_queue_count; i ++)
+		kobject_put(&net->_rx_attr[i].kobj);
+
+	return 0;
+}
+
+int sysfs_net_add_rx_queue(struct net_device *net)
+{
+	char *queue_name;
+	int retval =3D 0;
+	int i;
+
+	if (!net->num_rx_queues)
+		return 0;
+
+	queue_name =3D kmalloc(4096, GFP_KERNEL);
+	if (!queue_name)
+		return -ENOMEM;
+
+	for (i =3D 0; i < net->num_rx_queues; i ++) {
+		sprintf(queue_name, "rx_queue%d", i);
+		retval =3D kobject_init_and_add(&net->_rx_attr[i].kobj,
+				&ktype_rx_queue,
+				&net->dev.kobj, "%s", queue_name);
+		if (retval < 0) {
+			sysfs_net_remove_rx_queue(net, i);
+			break;
+		}
+	}
+
+	kfree(queue_name);
+	return retval;
+}
+
 #endif /* CONFIG_SYSFS */
=20
 #ifdef CONFIG_HOTPLUG
@@ -482,6 +559,10 @@ void netdev_unregister_kobject(struct ne
 	if (dev_net(net) !=3D &init_net)
 		return;
=20
+#ifdef CONFIG_SYSFS
+	sysfs_net_remove_rx_queue(net, net->num_rx_queues);
+#endif
+
 	device_del(dev);
 }
=20
@@ -490,6 +571,7 @@ int netdev_register_kobject(struct net_d
 {
 	struct device *dev =3D &(net->dev);
 	struct attribute_group **groups =3D net->sysfs_groups;
+	int retval;
=20
 	dev->class =3D &net_class;
 	dev->platform_data =3D net;
@@ -510,7 +592,17 @@ int netdev_register_kobject(struct net_d
 	if (dev_net(net) !=3D &init_net)
 		return 0;
=20
-	return device_add(dev);
+	retval =3D  device_add(dev);
+
+#ifdef CONFIG_SYSFS
+	if (!retval) {
+		retval =3D sysfs_net_add_rx_queue(net);
+		if (retval)
+			device_del(dev);
+	}
+#endif
+
+	return retval;
 }
=20
 int netdev_class_create_file(struct class_attribute *class_attr)
--- linux-2.6.29-rc7_backlog/net/ethernet/eth.c	2009-03-11 10:15:22.000=
000000 +0800
+++ linux-2.6.29-rc7_rxqueue_sysfs/net/ethernet/eth.c	2009-03-10 12:55:=
26.000000000 +0800
@@ -374,6 +374,14 @@ struct net_device *alloc_etherdev_mq(int
 }
 EXPORT_SYMBOL(alloc_etherdev_mq);
=20
+struct net_device *alloc_etherdev_rxtx_mq(int sizeof_priv,
+		unsigned int rx_queue_count, unsigned int tx_queue_count)
+{
+	return alloc_netdev_rxtx_mq(sizeof_priv, "eth%d", ether_setup,
+			rx_queue_count, tx_queue_count);
+}
+EXPORT_SYMBOL(alloc_etherdev_rxtx_mq);
+
 static size_t _format_mac_addr(char *buf, int buflen,
 				const unsigned char *addr, int len)
 {


