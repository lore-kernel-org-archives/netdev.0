From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 13/16] net: Introduce VRF device driver - v2
Date: Mon, 27 Jul 2015 12:31:06 -0600
Message-ID: <1438021869-49186-14-git-send-email-dsa@cumulusnetworks.com>
References: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net, svaidya@brocade.com,
	mingo@kernel.org, luto@amacapital.net,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:38886 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753628AbbG0SdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 14:33:13 -0400
Received: by iggf3 with SMTP id f3so89055073igg.1
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 11:33:12 -0700 (PDT)
In-Reply-To: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver borrows heavily from IPvlan and teaming drivers.

Routing domains (VRF-lite) are created by instantiating a VRF master
device with an associated table and enslaving all routed interfaces that
participate in the domain. As part of the enslavement, all connected
routes for the enslaved devices are moved to the table associated with
the VRF device. Outgoing sockets must bind to the VRF device to function.

Standard FIB rules bind the VRF device to tables and regular fib rule
processing is followed. Routed traffic through the box, is forwarded by
using the VRF device as the IIF and following the IIF rule to a table
that is mated with the VRF.

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
 drivers/net/vrf.c    | 596 +++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 604 insertions(+)
 create mode 100644 drivers/net/vrf.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index c18f9e62a9fa..e58468b02987 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -297,6 +297,13 @@ config NLMON
 	  diagnostics, etc. This is mostly intended for developers or support
 	  to debug netlink issues. If unsure, say N.
 
+config NET_VRF
+	tristate "Virtual Routing and Forwarding (Lite)"
+	depends on IP_MULTIPLE_TABLES && IPV6_MULTIPLE_TABLES
+	---help---
+	  This option enables the support for mapping interfaces into VRF's. The
+	  support enables VRF devices.
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
index 000000000000..8669b0f9d749
--- /dev/null
+++ b/drivers/net/vrf.c
@@ -0,0 +1,596 @@
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
+};
+
+struct slave_queue {
+	spinlock_t		lock; /* lock for slave insert/delete */
+	struct list_head	all_slaves;
+	int			num_slaves;
+};
+
+struct net_vrf {
+	struct slave_queue	queue;
+	struct fib_table	*tb;
+	u32			tb_id;
+};
+
+static bool is_ip_rx_frame(struct sk_buff *skb)
+{
+	switch (skb->protocol) {
+	case htons(ETH_P_IP):
+	case htons(ETH_P_IPV6):
+		return true;
+	}
+	return false;
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
+
+		skb->dev = dev;
+
+		return RX_HANDLER_ANOTHER;
+	}
+	return RX_HANDLER_PASS;
+}
+
+static struct rtnl_link_stats64 *vrf_get_stats64(struct net_device *dev,
+						 struct rtnl_link_stats64 *stats)
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
+static int vrf_process_v4_outbound(struct sk_buff *skb)
+{
+	const struct iphdr *iph = ip_hdr(skb);
+	struct net_device *dev = skb->dev;
+	struct net *net = dev_net(dev);
+	int tb_id = vrf_dev_table(dev);
+	int err, ret = NET_XMIT_DROP;
+	struct in_device *in_dev;
+	struct flowi4 fl4 = {
+		.flowi4_tos = RT_TOS(iph->tos),
+		.daddr = iph->daddr,
+		.saddr = iph->saddr,
+	};
+	struct rtable *rth;
+
+	struct fib_result res;
+	struct fib_table *tbl;
+
+	rcu_read_lock();
+	in_dev = __in_dev_get_rcu(dev);
+	if (!in_dev)
+		goto out;
+
+	if (tb_id == 0)
+		goto out;
+
+	tbl = fib_get_table(net, tb_id);
+	if (!tbl)
+		goto out;
+
+	res.tclassid    = 0;
+	res.fi          = NULL;
+	res.table       = NULL;
+	if (fib_table_lookup(tbl, &fl4, &res, 0) != 0)
+		goto out;
+
+	dev = FIB_RES_DEV(res);
+
+	rth = ip_route_new_rtable(dev, RTCF_LOCAL, res.type,
+				  IN_DEV_CONF_GET(in_dev, NOPOLICY),
+				  IN_DEV_CONF_GET(in_dev, NOXFRM),
+				  true);
+	if (!rth)
+		goto out;
+
+	ip_route_set_nexthop(rth, fl4.daddr, &res);
+
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rth->dst);
+	err = ip_local_out(skb);
+	if (!net_xmit_eval(err))
+		ret = NET_XMIT_SUCCESS;
+
+out:
+	rcu_read_unlock();
+
+	if (ret != NET_XMIT_SUCCESS)
+		dev->stats.tx_errors++;
+
+	return ret;
+}
+
+static netdev_tx_t vrf_xmit(struct sk_buff *skb, struct net_device *mdev)
+{
+	struct pcpu_dstats *dstats = this_cpu_ptr(mdev->dstats);
+	unsigned int len = skb->len;
+	int ret = NET_XMIT_DROP;
+
+	if (skb_mac_header_was_set(skb)) {
+		skb_pull(skb, sizeof(struct ethhdr));
+		skb->mac_header = (typeof(skb->mac_header))~0U;
+		skb_reset_network_header(skb);
+	}
+
+	if (skb->protocol == htons(ETH_P_IP))
+		ret = vrf_process_v4_outbound(skb);
+
+	if (ret == NET_XMIT_SUCCESS) {
+		u64_stats_update_begin(&dstats->syncp);
+		dstats->tx_pkts++;
+		dstats->tx_bytes += len;
+		u64_stats_update_end(&dstats->syncp);
+	} else {
+		dstats->tx_drps++;
+		kfree_skb(skb);
+	}
+	return ret;
+}
+
+/**************************** device handling ********************/
+
+/* cycle interface to flush neighbor cache and move routes across tables */
+static void cycle_netdev(struct net_device *dev)
+{
+	unsigned int flags = dev->flags;
+	int ret;
+
+	if (!netif_running(dev))
+		return;
+
+	ret = dev_change_flags(dev, flags & ~IFF_UP);
+	if (ret >= 0)
+		ret = dev_change_flags(dev, flags);
+
+	if (ret < 0) {
+		netdev_err(dev,
+			   "Failed to cycle device %s; route tables might be wrong!\n",
+			   dev->name);
+	}
+}
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
+/* inverse of __vrf_insert_slave; queue->lock must be held */
+static void __vrf_remove_slave(struct slave_queue *queue, struct slave *slave)
+{
+	dev_put(slave->dev);
+	list_del(&slave->list);
+	queue->num_slaves--;
+}
+
+/* queue->lock must be held */
+static void __vrf_insert_slave(struct slave_queue *queue, struct slave *slave)
+{
+	dev_hold(slave->dev);
+	list_add(&slave->list, &queue->all_slaves);
+	queue->num_slaves++;
+}
+
+static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
+{
+	struct net_vrf_dev *vrf_ptr = kmalloc(sizeof(*vrf_ptr), GFP_KERNEL);
+	struct slave *slave = kzalloc(sizeof(*slave), GFP_KERNEL);
+	struct slave *duplicate_slave;
+	struct net_vrf *vrf = netdev_priv(dev);
+	struct slave_queue *queue = &vrf->queue;
+	int ret = -ENOMEM;
+
+	if (!slave || !vrf_ptr)
+		goto out_fail;
+
+	slave->dev = port_dev;
+
+	vrf_ptr->ifindex = dev->ifindex;
+	vrf_ptr->tb_id = vrf->tb_id;
+
+	spin_lock_bh(&queue->lock);
+
+	duplicate_slave = __vrf_find_slave_dev(queue, port_dev);
+	if (duplicate_slave) {
+		spin_unlock_bh(&queue->lock);
+		ret = -EBUSY;
+		goto out_fail;
+	}
+
+	__vrf_insert_slave(queue, slave);
+
+	spin_unlock_bh(&queue->lock);
+
+	/* register the packet handler for slave ports */
+	ret = netdev_rx_handler_register(port_dev, vrf_handle_frame, dev);
+	if (ret) {
+		netdev_err(port_dev,
+			   "Device %s failed to register rx_handler\n",
+			   port_dev->name);
+		goto out_remove;
+	}
+
+	ret = netdev_master_upper_dev_link(port_dev, dev);
+	if (ret < 0)
+		goto out_unregister;
+
+	port_dev->flags |= IFF_SLAVE;
+
+	rcu_assign_pointer(port_dev->vrf_ptr, vrf_ptr);
+	cycle_netdev(port_dev);
+
+	return 0;
+
+out_unregister:
+	netdev_rx_handler_unregister(port_dev);
+out_remove:
+	__vrf_remove_slave(queue, slave);
+out_fail:
+	kfree(vrf_ptr);
+	kfree(slave);
+	return ret;
+}
+
+static int vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
+{
+	ASSERT_RTNL();
+
+	if (!dev || !port_dev || dev_net(dev) != dev_net(port_dev))
+		return -ENODEV;
+
+	if (!vrf_is_master(dev) || vrf_is_master(port_dev) ||
+	    vrf_is_slave(port_dev))
+		return -EINVAL;
+
+	return do_vrf_add_slave(dev, port_dev);
+}
+
+/* inverse of do_vrf_add_slave */
+static int do_vrf_del_slave(struct net_device *dev, struct net_device *port_dev)
+{
+	struct net_vrf *vrf = netdev_priv(dev);
+	struct slave_queue *queue = &vrf->queue;
+	struct net_vrf_dev *vrf_ptr = NULL;
+	struct slave *slave;
+
+	vrf_ptr = rcu_dereference(dev->vrf_ptr);
+	RCU_INIT_POINTER(dev->vrf_ptr, NULL);
+	kfree(vrf_ptr);
+
+	netdev_upper_dev_unlink(port_dev, dev);
+	port_dev->flags &= ~IFF_SLAVE;
+
+	netdev_rx_handler_unregister(dev);
+
+	cycle_netdev(port_dev);
+
+	spin_lock_bh(&queue->lock);
+
+	slave = __vrf_find_slave_dev(queue, port_dev);
+	if (slave)
+		__vrf_remove_slave(queue, slave);
+
+	spin_unlock_bh(&queue->lock);
+
+	kfree(slave);
+
+	return 0;
+}
+
+static int vrf_del_slave(struct net_device *dev, struct net_device *port_dev)
+{
+	ASSERT_RTNL();
+
+	if (!dev || !port_dev)
+		return -ENODEV;
+
+	if (!vrf_is_master(dev))
+		return -EINVAL;
+
+	return do_vrf_del_slave(dev, port_dev);
+}
+
+static int vrf_dev_init(struct net_device *dev)
+{
+	struct net_vrf *vrf = netdev_priv(dev);
+
+	spin_lock_init(&vrf->queue.lock);
+	INIT_LIST_HEAD(&vrf->queue.all_slaves);
+
+	dev->dstats = netdev_alloc_pcpu_stats(struct pcpu_dstats);
+	if (!dev->dstats)
+		return -ENOMEM;
+
+	dev->flags  =  IFF_MASTER | IFF_NOARP;
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
+	.ndo_stop		= vrf_dev_close,
+	.ndo_start_xmit		= vrf_xmit,
+	.ndo_get_stats64	= vrf_get_stats64,
+	.ndo_add_slave		= vrf_add_slave,
+	.ndo_del_slave		= vrf_del_slave,
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
+	.get_drvinfo	= vrf_get_drvinfo,
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
+	.priv_size	= sizeof(struct net_vrf),
+
+	.get_size	= vrf_nl_getsize,
+	.policy		= vrf_nl_policy,
+	.validate	= vrf_validate,
+	.fill_info	= vrf_fillinfo,
+
+	.newlink	= vrf_newlink,
+	.dellink	= vrf_dellink,
+	.setup		= vrf_setup,
+	.maxtype	= IFLA_VRF_MAX,
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
-- 
2.3.2 (Apple Git-55)
