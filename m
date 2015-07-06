From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC net-next 3/6] net: Introduce VRF device driver - v2
Date: Mon,  6 Jul 2015 09:03:17 -0600
Message-ID: <1436195001-4818-4-git-send-email-dsa@cumulusnetworks.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:34813 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753049AbbGFPDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 11:03:34 -0400
Received: by igcsj18 with SMTP id sj18so236490724igc.1
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 08:03:34 -0700 (PDT)
In-Reply-To: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver borrows heavily from IPvlan and teaming drivers.

Routing domains (VRF-lite) are created by instantiating a device
and enslaving all routed interfaces that participate in the domain.
As part of the enslavement, all local routes pointing to enslaved
devices are re-pointed to the vrf device, thus forcing outgoing
sockets to bind to the vrf to function.

Standard FIB rules can then bind the VRF device to tables and regular
fib rule processing is followed.

Routed traffic through the box, is fwded by using the VRF device as
the IIF and following the IIF rule to a table which is mated with
the VRF.

Locally originated traffic is directed at the VRF device using
SO_BINDTODEVICE or cmsg headers. This in turn drops the packet into
the xmit function of the vrf driver, which then completes the ip lookup
and output.

This solution is completely orthogonal to namespaces and allow the L3
equivalent of vlans to exist allowing the routing space to be
partitioned.

Example:

   Create vrf 1:
     ip link add vrf1 type vrf table 5
     ip rule add iif vrf1 table 5
     ip rule add oif vrf1 table 5
     ip route add table 5 prohibit default
     ip link set vrf1 up

   Add interface to vrf 1:
     ip link set eth1 master vrf1

Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

v2:
- addressed comments from first RFC
- significant changes to improve simplicity of implementation
---
 drivers/net/Kconfig  |   7 +
 drivers/net/Makefile |   1 +
 drivers/net/vrf.c    | 486 +++++++++++++++++++++++++++++++++++++++++++++++++++
 include/net/vrf.h    |  71 ++++++++
 4 files changed, 565 insertions(+)
 create mode 100644 drivers/net/vrf.c
 create mode 100644 include/net/vrf.h

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 019fceffc9e5..b040aa233408 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -283,6 +283,13 @@ config NLMON
 	  diagnostics, etc. This is mostly intended for developers or support
 	  to debug netlink issues. If unsure, say N.
 
+config NET_VRF
+	tristate "Virtual Routing and Forwarding (Lite)"
+	depends on IP_MULTIPLE_TABLES && IPV6_MULTIPLE_TABLES
+	---help---
+          This option enables the support for mapping interfaces into VRF's. The
+          support enables VRF devices
+
 endif # NET_CORE
 
 config SUNGEM_PHY
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index c12cb22478a7..ca16dd689b36 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -25,6 +25,7 @@ obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_VXLAN) += vxlan.o
 obj-$(CONFIG_GENEVE) += geneve.o
 obj-$(CONFIG_NLMON) += nlmon.o
+obj-$(CONFIG_NET_VRF) += vrf.o
 
 #
 # Networking Drivers
diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
new file mode 100644
index 000000000000..b9f9ae68388d
--- /dev/null
+++ b/drivers/net/vrf.c
@@ -0,0 +1,487 @@
+/*
+ * vrf.c: device driver to encapsulate a VRF space
+ *
+ * Copyright (c) 2015 Cumulus Networks
+ *
+ * Based on dummy, team and ipvlan drivers
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ip.h>
+#include <linux/init.h>
+#include <linux/moduleparam.h>
+#include <linux/rtnetlink.h>
+#include <net/rtnetlink.h>
+#include <net/arp.h>
+#include <linux/u64_stats_sync.h>
+#include <linux/hashtable.h>
+
+#include <linux/inetdevice.h>
+#include <net/ip.h>
+#include <net/ip_fib.h>
+#include <net/ip6_route.h>
+#include <net/rtnetlink.h>
+#include <net/route.h>
+#include <net/addrconf.h>
+#include <net/vrf.h>
+
+#define DRV_NAME	"vrf"
+#define DRV_VERSION	"1.0"
+
+#define vrf_is_slave(dev)   ((dev)->flags & IFF_SLAVE)
+#define vrf_is_master(dev)  ((dev)->flags & IFF_MASTER)
+
+#define vrf_master_get_rcu(dev) \
+	((struct net_device *)rcu_dereference(dev->rx_handler_data))
+
+struct pcpu_dstats {
+	u64			tx_pkts;
+	u64			tx_bytes;
+	u64			tx_drps;
+	u64			rx_pkts;
+	u64			rx_bytes;
+	struct u64_stats_sync	syncp;
+};
+
+struct slave {
+	struct list_head	list;
+	struct net_device	*dev;
+	long			priority;
+};
+
+struct slave_queue {
+	spinlock_t		lock; /* lock for slave insert/delete */
+	struct list_head	all_slaves;
+	int			num_slaves;
+	struct net_device	*master_dev;
+};
+
+struct net_vrf {
+	struct slave_queue	queue;
+	struct fib_table        *tb;
+	u32                     tb_id;
+};
+
+static int is_ip_rx_frame(struct sk_buff *skb)
+{
+	switch (skb->protocol) {
+	case htons(ETH_P_IP):
+	case htons(ETH_P_IPV6):
+		return 1;
+	}
+	return 0;
+}
+
+/* note: already called with rcu_read_lock */
+static rx_handler_result_t vrf_handle_frame(struct sk_buff **pskb)
+{
+	struct sk_buff *skb = *pskb;
+
+	if (is_ip_rx_frame(skb)) {
+		struct net_device *dev = vrf_master_get_rcu(skb->dev);
+		struct pcpu_dstats *dstats = this_cpu_ptr(dev->dstats);
+
+		u64_stats_update_begin(&dstats->syncp);
+		dstats->rx_pkts++;
+		dstats->rx_bytes += skb->len;
+		u64_stats_update_end(&dstats->syncp);
+	}
+	return RX_HANDLER_PASS;
+}
+
+static struct rtnl_link_stats64 *vrf_get_stats64(
+	struct net_device *dev, struct rtnl_link_stats64 *stats)
+{
+	int i;
+
+	for_each_possible_cpu(i) {
+		const struct pcpu_dstats *dstats;
+		u64 tbytes, tpkts, tdrops, rbytes, rpkts;
+		unsigned int start;
+
+		dstats = per_cpu_ptr(dev->dstats, i);
+		do {
+			start = u64_stats_fetch_begin_irq(&dstats->syncp);
+			tbytes = dstats->tx_bytes;
+			tpkts = dstats->tx_pkts;
+			tdrops = dstats->tx_drps;
+			rbytes = dstats->rx_bytes;
+			rpkts = dstats->rx_pkts;
+		} while (u64_stats_fetch_retry_irq(&dstats->syncp, start));
+		stats->tx_bytes += tbytes;
+		stats->tx_packets += tpkts;
+		stats->tx_dropped += tdrops;
+		stats->rx_bytes += rbytes;
+		stats->rx_packets += rpkts;
+	}
+	return stats;
+}
+
+static netdev_tx_t vrf_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	return NET_XMIT_DROP;
+}
+
+/**************************** device handling ********************/
+
+/* queue->lock must be held */
+static struct slave *__vrf_find_slave_dev(struct slave_queue *queue,
+					  struct net_device *dev)
+{
+	struct list_head *this, *head;
+
+	head = &queue->all_slaves;
+	list_for_each(this, head) {
+		struct slave *slave = list_entry(this, struct slave, list);
+
+		if (slave->dev == dev)
+			return slave;
+	}
+
+	return NULL;
+}
+
+static void __vrf_kill_slave(struct slave_queue *queue, struct slave *slave)
+{
+	list_del(&slave->list);
+	queue->num_slaves--;
+	slave->dev->flags &= ~IFF_SLAVE;
+	netdev_rx_handler_unregister(slave->dev);
+	kfree(slave->dev->vrf_ptr);
+	slave->dev->vrf_ptr = NULL;
+	dev_put(slave->dev);
+	kfree(slave);
+}
+
+/* queue->lock must be held */
+static void __vrf_insert_slave(struct slave_queue *queue, struct slave *slave,
+			       struct net_device *master)
+{
+	struct slave *duplicate_slave = NULL;
+
+	duplicate_slave = __vrf_find_slave_dev(queue, slave->dev);
+	if (duplicate_slave)
+		__vrf_kill_slave(queue, duplicate_slave);
+
+	dev_hold(slave->dev);
+	list_add(&slave->list, &queue->all_slaves);
+	queue->num_slaves++;
+}
+
+/* netlink lock is assumed here */
+static int vrf_add_slave(struct net_device *dev,
+			 struct net_device *port_dev)
+{
+	if (!dev || !port_dev || dev_net(dev) != dev_net(port_dev))
+		return -ENODEV;
+
+	if (!vrf_is_master(port_dev) && !vrf_is_slave(port_dev)) {
+		struct slave *s = kzalloc(sizeof(*s), GFP_KERNEL);
+		struct net_vrf *vrf = netdev_priv(dev);
+		struct slave_queue *queue = &vrf->queue;
+		bool is_running = netif_running(port_dev);
+		unsigned int flags = port_dev->flags;
+		int ret;
+
+		if (!s)
+			return -ENOMEM;
+
+		s->dev = port_dev;
+
+		spin_lock_bh(&queue->lock);
+		__vrf_insert_slave(queue, s, dev);
+		spin_unlock_bh(&queue->lock);
+
+		port_dev->vrf_ptr = kmalloc(sizeof(*port_dev->vrf_ptr),
+					    GFP_KERNEL);
+		if (!port_dev->vrf_ptr)
+			return -ENOMEM;
+
+		port_dev->vrf_ptr->ifindex = dev->ifindex;
+		port_dev->vrf_ptr->tb_id = vrf->tb_id;
+
+		/* register the packet handler for slave ports */
+		ret = netdev_rx_handler_register(port_dev, vrf_handle_frame,
+						 (void *)dev);
+		if (ret) {
+			netdev_err(port_dev,
+				   "Device %s failed to register rx_handler\n",
+				   port_dev->name);
+			kfree(port_dev->vrf_ptr);
+			kfree(s);
+			return ret;
+		}
+
+		if (is_running) {
+			ret = dev_change_flags(port_dev, flags & ~IFF_UP);
+			if (ret < 0)
+				goto out_fail;
+		}
+
+		ret = netdev_master_upper_dev_link(port_dev, dev);
+		if (ret < 0)
+			goto out_fail;
+
+		if (is_running) {
+			ret = dev_change_flags(port_dev, flags);
+			if (ret < 0)
+				goto out_fail;
+		}
+
+		port_dev->flags |= IFF_SLAVE;
+
+		return 0;
+
+out_fail:
+		spin_lock_bh(&queue->lock);
+		__vrf_kill_slave(queue, s);
+		spin_unlock_bh(&queue->lock);
+
+		return ret;
+	}
+
+	return -EINVAL;
+}
+
+static int vrf_del_slave(struct net_device *dev,
+			 struct net_device *port_dev)
+{
+	struct net_vrf *vrf = netdev_priv(dev);
+	struct slave_queue *queue = &vrf->queue;
+	struct slave *slave = __vrf_find_slave_dev(queue, port_dev);
+	bool is_running = netif_running(port_dev);
+	unsigned int flags = port_dev->flags;
+	int ret = 0;
+
+	if (!slave)
+		return -EINVAL;
+
+	if (is_running)
+		ret = dev_change_flags(port_dev, flags & ~IFF_UP);
+
+	spin_lock_bh(&queue->lock);
+	__vrf_kill_slave(queue, slave);
+	spin_unlock_bh(&queue->lock);
+
+	netdev_upper_dev_unlink(port_dev, dev);
+
+	if (is_running)
+		ret = dev_change_flags(port_dev, flags);
+
+	return 0;
+}
+
+static int vrf_dev_init(struct net_device *dev)
+{
+	struct net_vrf *vrf = netdev_priv(dev);
+
+	spin_lock_init(&vrf->queue.lock);
+	INIT_LIST_HEAD(&vrf->queue.all_slaves);
+	vrf->queue.master_dev = dev;
+
+	dev->dstats = netdev_alloc_pcpu_stats(struct pcpu_dstats);
+	dev->flags  =  IFF_MASTER | IFF_NOARP;
+	if (!dev->dstats)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void vrf_dev_uninit(struct net_device *dev)
+{
+	free_percpu(dev->dstats);
+}
+
+static int vrf_dev_close(struct net_device *dev)
+{
+	struct net_vrf *vrf = netdev_priv(dev);
+	struct slave_queue *queue = &vrf->queue;
+	struct list_head *this, *head;
+
+	head = &queue->all_slaves;
+	list_for_each(this, head) {
+		struct slave *slave = list_entry(this, struct slave, list);
+
+		slave->dev->vrf_ptr->ifindex = 0;
+		slave->dev->vrf_ptr->tb_id = 0;
+	}
+
+	if (dev->flags & IFF_MASTER)
+		dev->flags &= ~IFF_UP;
+
+	return 0;
+}
+
+static int vrf_dev_open(struct net_device *dev)
+{
+	struct net_vrf *vrf = netdev_priv(dev);
+	struct slave_queue *queue = &vrf->queue;
+	struct list_head *this, *head;
+
+	head = &queue->all_slaves;
+	list_for_each(this, head) {
+		struct slave *slave = list_entry(this, struct slave, list);
+
+		slave->dev->vrf_ptr->ifindex = dev->ifindex;
+		slave->dev->vrf_ptr->tb_id = vrf->tb_id;
+	}
+
+	if (dev->flags & IFF_MASTER)
+		dev->flags |= IFF_UP;
+
+	if (!vrf->tb)
+		return -EINVAL;
+
+	return 0;
+}
+
+static const struct net_device_ops vrf_netdev_ops = {
+	.ndo_init		= vrf_dev_init,
+	.ndo_uninit		= vrf_dev_uninit,
+	.ndo_open		= vrf_dev_open,
+	.ndo_stop               = vrf_dev_close,
+	.ndo_start_xmit		= vrf_xmit,
+	.ndo_get_stats64	= vrf_get_stats64,
+	.ndo_add_slave          = vrf_add_slave,
+	.ndo_del_slave          = vrf_del_slave,
+};
+
+static void vrf_get_drvinfo(struct net_device *dev,
+			    struct ethtool_drvinfo *info)
+{
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+}
+
+static const struct ethtool_ops vrf_ethtool_ops = {
+	.get_drvinfo            = vrf_get_drvinfo,
+};
+
+static void vrf_setup(struct net_device *dev)
+{
+	ether_setup(dev);
+
+	/* Initialize the device structure. */
+	dev->netdev_ops = &vrf_netdev_ops;
+	dev->ethtool_ops = &vrf_ethtool_ops;
+	dev->destructor = free_netdev;
+
+	/* Fill in device structure with ethernet-generic values. */
+	dev->tx_queue_len = 0;
+	eth_hw_addr_random(dev);
+}
+
+static int vrf_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	if (tb[IFLA_ADDRESS]) {
+		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
+			return -EINVAL;
+		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+			return -EADDRNOTAVAIL;
+	}
+	return 0;
+}
+
+static int vrf_newlink(struct net *src_net, struct net_device *dev,
+		       struct nlattr *tb[], struct nlattr *data[])
+{
+	struct net_vrf *vrf = netdev_priv(dev);
+	int err;
+
+	if (!data || !data[IFLA_VRF_TABLE])
+		return -EINVAL;
+
+	vrf->tb_id = nla_get_u32(data[IFLA_VRF_TABLE]);
+
+	/* reserve a table for this VRF device */
+	err = -ERANGE;
+	vrf->tb = fib_new_table(dev_net(dev), vrf->tb_id);
+	if (!vrf->tb)
+		goto out_fail;
+
+	dev->priv_flags |= IFF_VRF_MASTER;
+
+	err = -ENOMEM;
+	dev->vrf_ptr = kmalloc(sizeof(*dev->vrf_ptr), GFP_KERNEL);
+	if (!dev->vrf_ptr)
+		goto out_fail;
+
+	dev->vrf_ptr->ifindex = dev->ifindex;
+	dev->vrf_ptr->tb_id = vrf->tb_id;
+
+	err = register_netdevice(dev);
+	if (err < 0)
+		goto out_fail;
+
+	return 0;
+
+out_fail:
+	kfree(dev->vrf_ptr);
+	free_netdev(dev);
+	return err;
+}
+
+static void vrf_dellink(struct net_device *dev, struct list_head *head)
+{
+	struct net_vrf *vrf = netdev_priv(dev);
+
+	kfree(dev->vrf_ptr);
+	fib_free_table(vrf->tb);
+}
+
+static size_t vrf_nl_getsize(const struct net_device *dev)
+{
+	return nla_total_size(sizeof(u32));  /* IFLA_VRF_TABLE */
+}
+
+static int vrf_fillinfo(struct sk_buff *skb,
+			const struct net_device *dev)
+{
+	struct net_vrf *vrf = netdev_priv(dev);
+
+	return nla_put_u32(skb, IFLA_VRF_TABLE, vrf->tb_id);
+}
+
+static const struct nla_policy vrf_nl_policy[IFLA_VRF_MAX + 1] = {
+	[IFLA_VRF_TABLE] = { .type = NLA_U32 },
+};
+
+static struct rtnl_link_ops vrf_link_ops __read_mostly = {
+	.kind		= DRV_NAME,
+	.priv_size      = sizeof(struct net_vrf),
+
+	.get_size       = vrf_nl_getsize,
+	.policy         = vrf_nl_policy,
+	.validate	= vrf_validate,
+	.fill_info      = vrf_fillinfo,
+
+	.newlink        = vrf_newlink,
+	.dellink        = vrf_dellink,
+	.setup		= vrf_setup,
+	.maxtype        = IFLA_VRF_MAX,
+};
+
+static int __init vrf_init_module(void)
+{
+	return rtnl_link_register(&vrf_link_ops);
+}
+
+static void __exit vrf_cleanup_module(void)
+{
+	rtnl_link_unregister(&vrf_link_ops);
+}
+
+module_init(vrf_init_module);
+module_exit(vrf_cleanup_module);
+MODULE_AUTHOR("Shrijeet Mukherjee, David Ahern");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_RTNL_LINK(DRV_NAME);
+MODULE_VERSION(DRV_VERSION);
diff --git a/include/net/vrf.h b/include/net/vrf.h
new file mode 100644
index 000000000000..3ab1e332c781
--- /dev/null
+++ b/include/net/vrf.h
@@ -0,0 +1,71 @@
+/*
+ * include/net/net_vrf.h - adds vrf dev structure definitions
+ * Copyright (c) 2015 Cumulus Networks
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef __LINUX_NET_VRF_H
+#define __LINUX_NET_VRF_H
+
+struct net_vrf_dev {
+	int                     ifindex; /* ifindex of master dev */
+	u32                     tb_id;   /* table id for VRF */
+};
+
+#if IS_ENABLED(CONFIG_NET_VRF)
+static inline int vrf_master_dev_idx(const struct net_device *dev)
+{
+	int idx = 0;
+
+	if (dev && dev->vrf_ptr)
+		idx = dev->vrf_ptr->ifindex;
+
+	return idx;
+}
+
+static inline int vrf_get_master_dev_idx(struct net *net, int idx)
+{
+	int rc = 0;
+
+	if (idx) {
+		struct net_device *dev = dev_get_by_index(net, idx);
+
+		if (dev) {
+			rc = vrf_master_dev_idx(dev);
+			dev_put(dev);
+		}
+	}
+	return rc;
+}
+
+static inline int vrf_dev_table(const struct net_device *dev)
+{
+	int tb_id = 0;
+
+	if (dev && dev->vrf_ptr)
+		tb_id = dev->vrf_ptr->tb_id;
+
+	return tb_id;
+}
+#else
+static inline int vrf_master_dev_idx(const struct net_device *dev)
+{
+	return 0;
+}
+
+static inline int vrf_get_master_dev_idx(struct net *net, int idx)
+{
+	return 0;
+}
+
+static inline int vrf_dev_table(const struct net_device *dev)
+{
+	return 0;
+}
+#endif
+
+#endif /* __LINUX_NET_VRF_H */
-- 
2.3.2 (Apple Git-55)
