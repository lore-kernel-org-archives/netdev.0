From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] vrf: rename the framework to mrf
Date: Sat, 22 Aug 2015 18:10:20 +0200
Message-ID: <1440259820-7875-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	David Ahern <dsa@cumulusnetworks.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:37350 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752596AbbHVQKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Aug 2015 12:10:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch renames the recently added vrf driver. 'VRF' term is very
generic and there is no clear definition of it.
For example, someone may expect more isolation and uses network namespaces
to implement VRF,

MRF was suggested by Cumulus people, so let's use this term.

This patch also enlightens the fact that this driver is not *the* way to
implement VRF in linux, but *a* tool among others.

CC: Shrijeet Mukherjee <shm@cumulusnetworks.com>
CC: David Ahern <dsa@cumulusnetworks.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/Kconfig          |   8 +-
 drivers/net/Makefile         |   2 +-
 drivers/net/mrf.c            | 668 +++++++++++++++++++++++++++++++++++++++++++
 drivers/net/vrf.c            | 668 -------------------------------------------
 include/linux/netdevice.h    |  20 +-
 include/net/flow.h           |   2 +-
 include/net/mrf.h            | 177 ++++++++++++
 include/net/route.h          |   4 +-
 include/net/vrf.h            | 178 ------------
 include/uapi/linux/if_link.h |  10 +-
 net/ipv4/af_inet.c           |   4 +-
 net/ipv4/fib_frontend.c      |  12 +-
 net/ipv4/fib_trie.c          |   2 +-
 net/ipv4/icmp.c              |   7 +-
 net/ipv4/ip_fragment.c       |   6 +-
 net/ipv4/ip_output.c         |   2 +-
 net/ipv4/route.c             |  10 +-
 net/ipv4/udp.c               |   8 +-
 18 files changed, 894 insertions(+), 894 deletions(-)
 create mode 100644 drivers/net/mrf.c
 delete mode 100644 drivers/net/vrf.c
 create mode 100644 include/net/mrf.h
 delete mode 100644 include/net/vrf.h

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f50373645ab4..db4e5f5e8535 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -296,12 +296,12 @@ config NLMON
 	  diagnostics, etc. This is mostly intended for developers or support
 	  to debug netlink issues. If unsure, say N.
 
-config NET_VRF
-	tristate "Virtual Routing and Forwarding (Lite)"
+config NET_MRF
+	tristate "Multiple Routing Framework"
 	depends on IP_MULTIPLE_TABLES && IPV6_MULTIPLE_TABLES
 	---help---
-	  This option enables the support for mapping interfaces into VRF's. The
-	  support enables VRF devices.
+	  This option enables the support for mapping interfaces into MRF's. The
+	  support enables MRF devices.
 
 endif # NET_CORE
 
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index ca16dd689b36..60da845fa976 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -25,7 +25,7 @@ obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_VXLAN) += vxlan.o
 obj-$(CONFIG_GENEVE) += geneve.o
 obj-$(CONFIG_NLMON) += nlmon.o
-obj-$(CONFIG_NET_VRF) += vrf.o
+obj-$(CONFIG_NET_MRF) += mrf.o
 
 #
 # Networking Drivers
diff --git a/drivers/net/mrf.c b/drivers/net/mrf.c
new file mode 100644
index 000000000000..c959703a5a9c
--- /dev/null
+++ b/drivers/net/mrf.c
@@ -0,0 +1,668 @@
+/*
+ * mrf.c: device driver to encapsulate a MRF space
+ *
+ * Copyright (c) 2015 Cumulus Networks. All rights reserved.
+ * Copyright (c) 2015 Shrijeet Mukherjee <shm@cumulusnetworks.com>
+ * Copyright (c) 2015 David Ahern <dsa@cumulusnetworks.com>
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
+#include <linux/netfilter.h>
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
+#include <net/mrf.h>
+
+#define DRV_NAME	"mrf"
+#define DRV_VERSION	"1.0"
+
+#define mrf_is_slave(dev)   ((dev)->flags & IFF_SLAVE)
+
+#define mrf_master_get_rcu(dev) \
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
+static struct dst_entry *mrf_ip_check(struct dst_entry *dst, u32 cookie)
+{
+	return dst;
+}
+
+static int mrf_ip_local_out(struct sk_buff *skb)
+{
+	return ip_local_out(skb);
+}
+
+static unsigned int mrf_v4_mtu(const struct dst_entry *dst)
+{
+	/* TO-DO: return max ethernet size? */
+	return dst->dev->mtu;
+}
+
+static void mrf_dst_destroy(struct dst_entry *dst)
+{
+	/* our dst lives forever - or until the device is closed */
+}
+
+static unsigned int mrf_default_advmss(const struct dst_entry *dst)
+{
+	return 65535 - 40;
+}
+
+static struct dst_ops mrf_dst_ops = {
+	.family		= AF_INET,
+	.local_out	= mrf_ip_local_out,
+	.check		= mrf_ip_check,
+	.mtu		= mrf_v4_mtu,
+	.destroy	= mrf_dst_destroy,
+	.default_advmss	= mrf_default_advmss,
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
+static void mrf_tx_error(struct net_device *mrf_dev, struct sk_buff *skb)
+{
+	mrf_dev->stats.tx_errors++;
+	kfree_skb(skb);
+}
+
+/* note: already called with rcu_read_lock */
+static rx_handler_result_t mrf_handle_frame(struct sk_buff **pskb)
+{
+	struct sk_buff *skb = *pskb;
+
+	if (is_ip_rx_frame(skb)) {
+		struct net_device *dev = mrf_master_get_rcu(skb->dev);
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
+static struct rtnl_link_stats64 *mrf_get_stats64(struct net_device *dev,
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
+static netdev_tx_t mrf_process_v6_outbound(struct sk_buff *skb,
+					   struct net_device *dev)
+{
+	mrf_tx_error(dev, skb);
+	return NET_XMIT_DROP;
+}
+
+static int mrf_send_v4_prep(struct sk_buff *skb, struct flowi4 *fl4,
+			    struct net_device *mrf_dev)
+{
+	struct rtable *rt;
+	int err = 1;
+
+	rt = ip_route_output_flow(dev_net(mrf_dev), fl4, NULL);
+	if (IS_ERR(rt))
+		goto out;
+
+	/* TO-DO: what about broadcast ? */
+	if (rt->rt_type != RTN_UNICAST && rt->rt_type != RTN_LOCAL) {
+		ip_rt_put(rt);
+		goto out;
+	}
+
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->dst);
+	err = 0;
+out:
+	return err;
+}
+
+static netdev_tx_t mrf_process_v4_outbound(struct sk_buff *skb,
+					   struct net_device *mrf_dev)
+{
+	struct iphdr *ip4h = ip_hdr(skb);
+	int ret = NET_XMIT_DROP;
+	struct flowi4 fl4 = {
+		/* needed to match OIF rule */
+		.flowi4_oif = mrf_dev->ifindex,
+		.flowi4_iif = LOOPBACK_IFINDEX,
+		.flowi4_tos = RT_TOS(ip4h->tos),
+		.flowi4_flags = FLOWI_FLAG_ANYSRC | FLOWI_FLAG_MRFSRC,
+		.daddr = ip4h->daddr,
+	};
+
+	if (mrf_send_v4_prep(skb, &fl4, mrf_dev))
+		goto err;
+
+	if (!ip4h->saddr) {
+		ip4h->saddr = inet_select_addr(skb_dst(skb)->dev, 0,
+					       RT_SCOPE_LINK);
+	}
+
+	ret = ip_local_out(skb);
+	if (unlikely(net_xmit_eval(ret)))
+		mrf_dev->stats.tx_errors++;
+	else
+		ret = NET_XMIT_SUCCESS;
+
+out:
+	return ret;
+err:
+	mrf_tx_error(mrf_dev, skb);
+	goto out;
+}
+
+static netdev_tx_t is_ip_tx_frame(struct sk_buff *skb, struct net_device *dev)
+{
+	switch (skb->protocol) {
+	case htons(ETH_P_IP):
+		return mrf_process_v4_outbound(skb, dev);
+	case htons(ETH_P_IPV6):
+		return mrf_process_v6_outbound(skb, dev);
+	default:
+		mrf_tx_error(dev, skb);
+		return NET_XMIT_DROP;
+	}
+}
+
+static netdev_tx_t mrf_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	netdev_tx_t ret = is_ip_tx_frame(skb, dev);
+
+	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
+		struct pcpu_dstats *dstats = this_cpu_ptr(dev->dstats);
+
+		u64_stats_update_begin(&dstats->syncp);
+		dstats->tx_pkts++;
+		dstats->tx_bytes += skb->len;
+		u64_stats_update_end(&dstats->syncp);
+	} else {
+		this_cpu_inc(dev->dstats->tx_drps);
+	}
+
+	return ret;
+}
+
+static netdev_tx_t mrf_finish(struct sock *sk, struct sk_buff *skb)
+{
+	return dev_queue_xmit(skb);
+}
+
+static int mrf_output(struct sock *sk, struct sk_buff *skb)
+{
+	struct net_device *dev = skb_dst(skb)->dev;
+
+	IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUT, skb->len);
+
+	skb->dev = dev;
+	skb->protocol = htons(ETH_P_IP);
+
+	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, sk, skb,
+			    NULL, dev,
+			    mrf_finish,
+			    !(IPCB(skb)->flags & IPSKB_REROUTED));
+}
+
+static void mrf_rtable_destroy(struct net_mrf *mrf)
+{
+	struct dst_entry *dst = (struct dst_entry *)mrf->rth;
+
+	dst_destroy(dst);
+	mrf->rth = NULL;
+}
+
+static struct rtable *mrf_rtable_create(struct net_device *dev)
+{
+	struct rtable *rth;
+
+	rth = dst_alloc(&mrf_dst_ops, dev, 2,
+			DST_OBSOLETE_NONE,
+			(DST_HOST | DST_NOPOLICY | DST_NOXFRM));
+	if (rth) {
+		rth->dst.output	= mrf_output;
+		rth->rt_genid	= rt_genid_ipv4(dev_net(dev));
+		rth->rt_flags	= 0;
+		rth->rt_type	= RTN_UNICAST;
+		rth->rt_is_input = 0;
+		rth->rt_iif	= 0;
+		rth->rt_pmtu	= 0;
+		rth->rt_gateway	= 0;
+		rth->rt_uses_gateway = 0;
+		INIT_LIST_HEAD(&rth->rt_uncached);
+		rth->rt_uncached_list = NULL;
+	}
+
+	return rth;
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
+static struct slave *__mrf_find_slave_dev(struct slave_queue *queue,
+					  struct net_device *dev)
+{
+	struct list_head *head = &queue->all_slaves;
+	struct slave *slave;
+
+	list_for_each_entry(slave, head, list) {
+		if (slave->dev == dev)
+			return slave;
+	}
+
+	return NULL;
+}
+
+/* inverse of __mrf_insert_slave */
+static void __mrf_remove_slave(struct slave_queue *queue, struct slave *slave)
+{
+	list_del(&slave->list);
+}
+
+static void __mrf_insert_slave(struct slave_queue *queue, struct slave *slave)
+{
+	list_add(&slave->list, &queue->all_slaves);
+}
+
+static int do_mrf_add_slave(struct net_device *dev, struct net_device *port_dev)
+{
+	struct net_mrf_dev *mrf_ptr = kmalloc(sizeof(*mrf_ptr), GFP_KERNEL);
+	struct slave *slave = kzalloc(sizeof(*slave), GFP_KERNEL);
+	struct net_mrf *mrf = netdev_priv(dev);
+	struct slave_queue *queue = &mrf->queue;
+	int ret = -ENOMEM;
+
+	if (!slave || !mrf_ptr)
+		goto out_fail;
+
+	slave->dev = port_dev;
+	mrf_ptr->ifindex = dev->ifindex;
+	mrf_ptr->tb_id = mrf->tb_id;
+
+	/* register the packet handler for slave ports */
+	ret = netdev_rx_handler_register(port_dev, mrf_handle_frame, dev);
+	if (ret) {
+		netdev_err(port_dev,
+			   "Device %s failed to register rx_handler\n",
+			   port_dev->name);
+		goto out_fail;
+	}
+
+	ret = netdev_master_upper_dev_link(port_dev, dev);
+	if (ret < 0)
+		goto out_unregister;
+
+	port_dev->flags |= IFF_SLAVE;
+	__mrf_insert_slave(queue, slave);
+	rcu_assign_pointer(port_dev->mrf_ptr, mrf_ptr);
+	cycle_netdev(port_dev);
+
+	return 0;
+
+out_unregister:
+	netdev_rx_handler_unregister(port_dev);
+out_fail:
+	kfree(mrf_ptr);
+	kfree(slave);
+	return ret;
+}
+
+static int mrf_add_slave(struct net_device *dev, struct net_device *port_dev)
+{
+	if (netif_is_mrf(port_dev) || mrf_is_slave(port_dev))
+		return -EINVAL;
+
+	return do_mrf_add_slave(dev, port_dev);
+}
+
+/* inverse of do_mrf_add_slave */
+static int do_mrf_del_slave(struct net_device *dev, struct net_device *port_dev)
+{
+	struct net_mrf_dev *mrf_ptr = rtnl_dereference(port_dev->mrf_ptr);
+	struct net_mrf *mrf = netdev_priv(dev);
+	struct slave_queue *queue = &mrf->queue;
+	struct slave *slave;
+
+	RCU_INIT_POINTER(port_dev->mrf_ptr, NULL);
+
+	netdev_upper_dev_unlink(port_dev, dev);
+	port_dev->flags &= ~IFF_SLAVE;
+
+	netdev_rx_handler_unregister(port_dev);
+
+	/* after netdev_rx_handler_unregister for synchronize_rcu */
+	kfree(mrf_ptr);
+
+	cycle_netdev(port_dev);
+
+	slave = __mrf_find_slave_dev(queue, port_dev);
+	if (slave)
+		__mrf_remove_slave(queue, slave);
+
+	kfree(slave);
+
+	return 0;
+}
+
+static int mrf_del_slave(struct net_device *dev, struct net_device *port_dev)
+{
+	return do_mrf_del_slave(dev, port_dev);
+}
+
+static void mrf_dev_uninit(struct net_device *dev)
+{
+	struct net_mrf *mrf = netdev_priv(dev);
+	struct slave_queue *queue = &mrf->queue;
+	struct list_head *head = &queue->all_slaves;
+	struct slave *slave, *next;
+
+	mrf_rtable_destroy(mrf);
+
+	list_for_each_entry_safe(slave, next, head, list)
+		mrf_del_slave(dev, slave->dev);
+
+	free_percpu(dev->dstats);
+	dev->dstats = NULL;
+}
+
+static int mrf_dev_init(struct net_device *dev)
+{
+	struct net_mrf *mrf = netdev_priv(dev);
+
+	INIT_LIST_HEAD(&mrf->queue.all_slaves);
+
+	dev->dstats = netdev_alloc_pcpu_stats(struct pcpu_dstats);
+	if (!dev->dstats)
+		goto out_nomem;
+
+	/* create the default dst which points back to us */
+	mrf->rth = mrf_rtable_create(dev);
+	if (!mrf->rth)
+		goto out_stats;
+
+	dev->flags = IFF_MASTER | IFF_NOARP;
+
+	return 0;
+
+out_stats:
+	free_percpu(dev->dstats);
+	dev->dstats = NULL;
+out_nomem:
+	return -ENOMEM;
+}
+
+static const struct net_device_ops mrf_netdev_ops = {
+	.ndo_init		= mrf_dev_init,
+	.ndo_uninit		= mrf_dev_uninit,
+	.ndo_start_xmit		= mrf_xmit,
+	.ndo_get_stats64	= mrf_get_stats64,
+	.ndo_add_slave		= mrf_add_slave,
+	.ndo_del_slave		= mrf_del_slave,
+};
+
+static void mrf_get_drvinfo(struct net_device *dev,
+			    struct ethtool_drvinfo *info)
+{
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+}
+
+static const struct ethtool_ops mrf_ethtool_ops = {
+	.get_drvinfo	= mrf_get_drvinfo,
+};
+
+static void mrf_setup(struct net_device *dev)
+{
+	ether_setup(dev);
+
+	/* Initialize the device structure. */
+	dev->netdev_ops = &mrf_netdev_ops;
+	dev->ethtool_ops = &mrf_ethtool_ops;
+	dev->destructor = free_netdev;
+
+	/* Fill in device structure with ethernet-generic values. */
+	eth_hw_addr_random(dev);
+
+	/* don't acquire mrf device's netif_tx_lock when transmitting */
+	dev->features |= NETIF_F_LLTX;
+
+	/* don't allow mrf devices to change network namespaces. */
+	dev->features |= NETIF_F_NETNS_LOCAL;
+}
+
+static int mrf_validate(struct nlattr *tb[], struct nlattr *data[])
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
+static void mrf_dellink(struct net_device *dev, struct list_head *head)
+{
+	struct net_mrf_dev *mrf_ptr = rtnl_dereference(dev->mrf_ptr);
+
+	RCU_INIT_POINTER(dev->mrf_ptr, NULL);
+	kfree_rcu(mrf_ptr, rcu);
+	unregister_netdevice_queue(dev, head);
+}
+
+static int mrf_newlink(struct net *src_net, struct net_device *dev,
+		       struct nlattr *tb[], struct nlattr *data[])
+{
+	struct net_mrf *mrf = netdev_priv(dev);
+	struct net_mrf_dev *mrf_ptr;
+	int err;
+
+	if (!data || !data[IFLA_MRF_TABLE])
+		return -EINVAL;
+
+	mrf->tb_id = nla_get_u32(data[IFLA_MRF_TABLE]);
+
+	dev->priv_flags |= IFF_MRF_MASTER;
+
+	err = -ENOMEM;
+	mrf_ptr = kmalloc(sizeof(*dev->mrf_ptr), GFP_KERNEL);
+	if (!mrf_ptr)
+		goto out_fail;
+
+	mrf_ptr->ifindex = dev->ifindex;
+	mrf_ptr->tb_id = mrf->tb_id;
+
+	err = register_netdevice(dev);
+	if (err < 0)
+		goto out_fail;
+
+	rcu_assign_pointer(dev->mrf_ptr, mrf_ptr);
+
+	return 0;
+
+out_fail:
+	kfree(mrf_ptr);
+	free_netdev(dev);
+	return err;
+}
+
+static size_t mrf_nl_getsize(const struct net_device *dev)
+{
+	return nla_total_size(sizeof(u32));  /* IFLA_MRF_TABLE */
+}
+
+static int mrf_fillinfo(struct sk_buff *skb,
+			const struct net_device *dev)
+{
+	struct net_mrf *mrf = netdev_priv(dev);
+
+	return nla_put_u32(skb, IFLA_MRF_TABLE, mrf->tb_id);
+}
+
+static const struct nla_policy mrf_nl_policy[IFLA_MRF_MAX + 1] = {
+	[IFLA_MRF_TABLE] = { .type = NLA_U32 },
+};
+
+static struct rtnl_link_ops mrf_link_ops __read_mostly = {
+	.kind		= DRV_NAME,
+	.priv_size	= sizeof(struct net_mrf),
+
+	.get_size	= mrf_nl_getsize,
+	.policy		= mrf_nl_policy,
+	.validate	= mrf_validate,
+	.fill_info	= mrf_fillinfo,
+
+	.newlink	= mrf_newlink,
+	.dellink	= mrf_dellink,
+	.setup		= mrf_setup,
+	.maxtype	= IFLA_MRF_MAX,
+};
+
+static int mrf_device_event(struct notifier_block *unused,
+			    unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+
+	/* only care about unregister events to drop slave references */
+	if (event == NETDEV_UNREGISTER) {
+		struct net_mrf_dev *mrf_ptr = rtnl_dereference(dev->mrf_ptr);
+		struct net_device *mrf_dev;
+
+		if (!mrf_ptr || netif_is_mrf(dev))
+			goto out;
+
+		mrf_dev = netdev_master_upper_dev_get(dev);
+		mrf_del_slave(mrf_dev, dev);
+	}
+out:
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block mrf_notifier_block __read_mostly = {
+	.notifier_call = mrf_device_event,
+};
+
+static int __init mrf_init_module(void)
+{
+	int rc;
+
+	mrf_dst_ops.kmem_cachep =
+		kmem_cache_create("mrf_ip_dst_cache",
+				  sizeof(struct rtable), 0,
+				  SLAB_HWCACHE_ALIGN,
+				  NULL);
+
+	if (!mrf_dst_ops.kmem_cachep)
+		return -ENOMEM;
+
+	register_netdevice_notifier(&mrf_notifier_block);
+
+	rc = rtnl_link_register(&mrf_link_ops);
+	if (rc < 0)
+		goto error;
+
+	return 0;
+
+error:
+	unregister_netdevice_notifier(&mrf_notifier_block);
+	kmem_cache_destroy(mrf_dst_ops.kmem_cachep);
+	return rc;
+}
+
+static void __exit mrf_cleanup_module(void)
+{
+	rtnl_link_unregister(&mrf_link_ops);
+	unregister_netdevice_notifier(&mrf_notifier_block);
+	kmem_cache_destroy(mrf_dst_ops.kmem_cachep);
+}
+
+module_init(mrf_init_module);
+module_exit(mrf_cleanup_module);
+MODULE_AUTHOR("Shrijeet Mukherjee, David Ahern");
+MODULE_DESCRIPTION("Device driver to instantiate MRF domains");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_RTNL_LINK(DRV_NAME);
+MODULE_VERSION(DRV_VERSION);
diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
deleted file mode 100644
index b3d9c5546c79..000000000000
--- a/drivers/net/vrf.c
+++ /dev/null
@@ -1,668 +0,0 @@
-/*
- * vrf.c: device driver to encapsulate a VRF space
- *
- * Copyright (c) 2015 Cumulus Networks. All rights reserved.
- * Copyright (c) 2015 Shrijeet Mukherjee <shm@cumulusnetworks.com>
- * Copyright (c) 2015 David Ahern <dsa@cumulusnetworks.com>
- *
- * Based on dummy, team and ipvlan drivers
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- */
-
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/ip.h>
-#include <linux/init.h>
-#include <linux/moduleparam.h>
-#include <linux/netfilter.h>
-#include <linux/rtnetlink.h>
-#include <net/rtnetlink.h>
-#include <linux/u64_stats_sync.h>
-#include <linux/hashtable.h>
-
-#include <linux/inetdevice.h>
-#include <net/ip.h>
-#include <net/ip_fib.h>
-#include <net/ip6_route.h>
-#include <net/rtnetlink.h>
-#include <net/route.h>
-#include <net/addrconf.h>
-#include <net/vrf.h>
-
-#define DRV_NAME	"vrf"
-#define DRV_VERSION	"1.0"
-
-#define vrf_is_slave(dev)   ((dev)->flags & IFF_SLAVE)
-
-#define vrf_master_get_rcu(dev) \
-	((struct net_device *)rcu_dereference(dev->rx_handler_data))
-
-struct pcpu_dstats {
-	u64			tx_pkts;
-	u64			tx_bytes;
-	u64			tx_drps;
-	u64			rx_pkts;
-	u64			rx_bytes;
-	struct u64_stats_sync	syncp;
-};
-
-static struct dst_entry *vrf_ip_check(struct dst_entry *dst, u32 cookie)
-{
-	return dst;
-}
-
-static int vrf_ip_local_out(struct sk_buff *skb)
-{
-	return ip_local_out(skb);
-}
-
-static unsigned int vrf_v4_mtu(const struct dst_entry *dst)
-{
-	/* TO-DO: return max ethernet size? */
-	return dst->dev->mtu;
-}
-
-static void vrf_dst_destroy(struct dst_entry *dst)
-{
-	/* our dst lives forever - or until the device is closed */
-}
-
-static unsigned int vrf_default_advmss(const struct dst_entry *dst)
-{
-	return 65535 - 40;
-}
-
-static struct dst_ops vrf_dst_ops = {
-	.family		= AF_INET,
-	.local_out	= vrf_ip_local_out,
-	.check		= vrf_ip_check,
-	.mtu		= vrf_v4_mtu,
-	.destroy	= vrf_dst_destroy,
-	.default_advmss	= vrf_default_advmss,
-};
-
-static bool is_ip_rx_frame(struct sk_buff *skb)
-{
-	switch (skb->protocol) {
-	case htons(ETH_P_IP):
-	case htons(ETH_P_IPV6):
-		return true;
-	}
-	return false;
-}
-
-static void vrf_tx_error(struct net_device *vrf_dev, struct sk_buff *skb)
-{
-	vrf_dev->stats.tx_errors++;
-	kfree_skb(skb);
-}
-
-/* note: already called with rcu_read_lock */
-static rx_handler_result_t vrf_handle_frame(struct sk_buff **pskb)
-{
-	struct sk_buff *skb = *pskb;
-
-	if (is_ip_rx_frame(skb)) {
-		struct net_device *dev = vrf_master_get_rcu(skb->dev);
-		struct pcpu_dstats *dstats = this_cpu_ptr(dev->dstats);
-
-		u64_stats_update_begin(&dstats->syncp);
-		dstats->rx_pkts++;
-		dstats->rx_bytes += skb->len;
-		u64_stats_update_end(&dstats->syncp);
-
-		skb->dev = dev;
-
-		return RX_HANDLER_ANOTHER;
-	}
-	return RX_HANDLER_PASS;
-}
-
-static struct rtnl_link_stats64 *vrf_get_stats64(struct net_device *dev,
-						 struct rtnl_link_stats64 *stats)
-{
-	int i;
-
-	for_each_possible_cpu(i) {
-		const struct pcpu_dstats *dstats;
-		u64 tbytes, tpkts, tdrops, rbytes, rpkts;
-		unsigned int start;
-
-		dstats = per_cpu_ptr(dev->dstats, i);
-		do {
-			start = u64_stats_fetch_begin_irq(&dstats->syncp);
-			tbytes = dstats->tx_bytes;
-			tpkts = dstats->tx_pkts;
-			tdrops = dstats->tx_drps;
-			rbytes = dstats->rx_bytes;
-			rpkts = dstats->rx_pkts;
-		} while (u64_stats_fetch_retry_irq(&dstats->syncp, start));
-		stats->tx_bytes += tbytes;
-		stats->tx_packets += tpkts;
-		stats->tx_dropped += tdrops;
-		stats->rx_bytes += rbytes;
-		stats->rx_packets += rpkts;
-	}
-	return stats;
-}
-
-static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
-					   struct net_device *dev)
-{
-	vrf_tx_error(dev, skb);
-	return NET_XMIT_DROP;
-}
-
-static int vrf_send_v4_prep(struct sk_buff *skb, struct flowi4 *fl4,
-			    struct net_device *vrf_dev)
-{
-	struct rtable *rt;
-	int err = 1;
-
-	rt = ip_route_output_flow(dev_net(vrf_dev), fl4, NULL);
-	if (IS_ERR(rt))
-		goto out;
-
-	/* TO-DO: what about broadcast ? */
-	if (rt->rt_type != RTN_UNICAST && rt->rt_type != RTN_LOCAL) {
-		ip_rt_put(rt);
-		goto out;
-	}
-
-	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
-	err = 0;
-out:
-	return err;
-}
-
-static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
-					   struct net_device *vrf_dev)
-{
-	struct iphdr *ip4h = ip_hdr(skb);
-	int ret = NET_XMIT_DROP;
-	struct flowi4 fl4 = {
-		/* needed to match OIF rule */
-		.flowi4_oif = vrf_dev->ifindex,
-		.flowi4_iif = LOOPBACK_IFINDEX,
-		.flowi4_tos = RT_TOS(ip4h->tos),
-		.flowi4_flags = FLOWI_FLAG_ANYSRC | FLOWI_FLAG_VRFSRC,
-		.daddr = ip4h->daddr,
-	};
-
-	if (vrf_send_v4_prep(skb, &fl4, vrf_dev))
-		goto err;
-
-	if (!ip4h->saddr) {
-		ip4h->saddr = inet_select_addr(skb_dst(skb)->dev, 0,
-					       RT_SCOPE_LINK);
-	}
-
-	ret = ip_local_out(skb);
-	if (unlikely(net_xmit_eval(ret)))
-		vrf_dev->stats.tx_errors++;
-	else
-		ret = NET_XMIT_SUCCESS;
-
-out:
-	return ret;
-err:
-	vrf_tx_error(vrf_dev, skb);
-	goto out;
-}
-
-static netdev_tx_t is_ip_tx_frame(struct sk_buff *skb, struct net_device *dev)
-{
-	switch (skb->protocol) {
-	case htons(ETH_P_IP):
-		return vrf_process_v4_outbound(skb, dev);
-	case htons(ETH_P_IPV6):
-		return vrf_process_v6_outbound(skb, dev);
-	default:
-		vrf_tx_error(dev, skb);
-		return NET_XMIT_DROP;
-	}
-}
-
-static netdev_tx_t vrf_xmit(struct sk_buff *skb, struct net_device *dev)
-{
-	netdev_tx_t ret = is_ip_tx_frame(skb, dev);
-
-	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
-		struct pcpu_dstats *dstats = this_cpu_ptr(dev->dstats);
-
-		u64_stats_update_begin(&dstats->syncp);
-		dstats->tx_pkts++;
-		dstats->tx_bytes += skb->len;
-		u64_stats_update_end(&dstats->syncp);
-	} else {
-		this_cpu_inc(dev->dstats->tx_drps);
-	}
-
-	return ret;
-}
-
-static netdev_tx_t vrf_finish(struct sock *sk, struct sk_buff *skb)
-{
-	return dev_queue_xmit(skb);
-}
-
-static int vrf_output(struct sock *sk, struct sk_buff *skb)
-{
-	struct net_device *dev = skb_dst(skb)->dev;
-
-	IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUT, skb->len);
-
-	skb->dev = dev;
-	skb->protocol = htons(ETH_P_IP);
-
-	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, sk, skb,
-			    NULL, dev,
-			    vrf_finish,
-			    !(IPCB(skb)->flags & IPSKB_REROUTED));
-}
-
-static void vrf_rtable_destroy(struct net_vrf *vrf)
-{
-	struct dst_entry *dst = (struct dst_entry *)vrf->rth;
-
-	dst_destroy(dst);
-	vrf->rth = NULL;
-}
-
-static struct rtable *vrf_rtable_create(struct net_device *dev)
-{
-	struct rtable *rth;
-
-	rth = dst_alloc(&vrf_dst_ops, dev, 2,
-			DST_OBSOLETE_NONE,
-			(DST_HOST | DST_NOPOLICY | DST_NOXFRM));
-	if (rth) {
-		rth->dst.output	= vrf_output;
-		rth->rt_genid	= rt_genid_ipv4(dev_net(dev));
-		rth->rt_flags	= 0;
-		rth->rt_type	= RTN_UNICAST;
-		rth->rt_is_input = 0;
-		rth->rt_iif	= 0;
-		rth->rt_pmtu	= 0;
-		rth->rt_gateway	= 0;
-		rth->rt_uses_gateway = 0;
-		INIT_LIST_HEAD(&rth->rt_uncached);
-		rth->rt_uncached_list = NULL;
-	}
-
-	return rth;
-}
-
-/**************************** device handling ********************/
-
-/* cycle interface to flush neighbor cache and move routes across tables */
-static void cycle_netdev(struct net_device *dev)
-{
-	unsigned int flags = dev->flags;
-	int ret;
-
-	if (!netif_running(dev))
-		return;
-
-	ret = dev_change_flags(dev, flags & ~IFF_UP);
-	if (ret >= 0)
-		ret = dev_change_flags(dev, flags);
-
-	if (ret < 0) {
-		netdev_err(dev,
-			   "Failed to cycle device %s; route tables might be wrong!\n",
-			   dev->name);
-	}
-}
-
-static struct slave *__vrf_find_slave_dev(struct slave_queue *queue,
-					  struct net_device *dev)
-{
-	struct list_head *head = &queue->all_slaves;
-	struct slave *slave;
-
-	list_for_each_entry(slave, head, list) {
-		if (slave->dev == dev)
-			return slave;
-	}
-
-	return NULL;
-}
-
-/* inverse of __vrf_insert_slave */
-static void __vrf_remove_slave(struct slave_queue *queue, struct slave *slave)
-{
-	list_del(&slave->list);
-}
-
-static void __vrf_insert_slave(struct slave_queue *queue, struct slave *slave)
-{
-	list_add(&slave->list, &queue->all_slaves);
-}
-
-static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
-{
-	struct net_vrf_dev *vrf_ptr = kmalloc(sizeof(*vrf_ptr), GFP_KERNEL);
-	struct slave *slave = kzalloc(sizeof(*slave), GFP_KERNEL);
-	struct net_vrf *vrf = netdev_priv(dev);
-	struct slave_queue *queue = &vrf->queue;
-	int ret = -ENOMEM;
-
-	if (!slave || !vrf_ptr)
-		goto out_fail;
-
-	slave->dev = port_dev;
-	vrf_ptr->ifindex = dev->ifindex;
-	vrf_ptr->tb_id = vrf->tb_id;
-
-	/* register the packet handler for slave ports */
-	ret = netdev_rx_handler_register(port_dev, vrf_handle_frame, dev);
-	if (ret) {
-		netdev_err(port_dev,
-			   "Device %s failed to register rx_handler\n",
-			   port_dev->name);
-		goto out_fail;
-	}
-
-	ret = netdev_master_upper_dev_link(port_dev, dev);
-	if (ret < 0)
-		goto out_unregister;
-
-	port_dev->flags |= IFF_SLAVE;
-	__vrf_insert_slave(queue, slave);
-	rcu_assign_pointer(port_dev->vrf_ptr, vrf_ptr);
-	cycle_netdev(port_dev);
-
-	return 0;
-
-out_unregister:
-	netdev_rx_handler_unregister(port_dev);
-out_fail:
-	kfree(vrf_ptr);
-	kfree(slave);
-	return ret;
-}
-
-static int vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
-{
-	if (netif_is_vrf(port_dev) || vrf_is_slave(port_dev))
-		return -EINVAL;
-
-	return do_vrf_add_slave(dev, port_dev);
-}
-
-/* inverse of do_vrf_add_slave */
-static int do_vrf_del_slave(struct net_device *dev, struct net_device *port_dev)
-{
-	struct net_vrf_dev *vrf_ptr = rtnl_dereference(port_dev->vrf_ptr);
-	struct net_vrf *vrf = netdev_priv(dev);
-	struct slave_queue *queue = &vrf->queue;
-	struct slave *slave;
-
-	RCU_INIT_POINTER(port_dev->vrf_ptr, NULL);
-
-	netdev_upper_dev_unlink(port_dev, dev);
-	port_dev->flags &= ~IFF_SLAVE;
-
-	netdev_rx_handler_unregister(port_dev);
-
-	/* after netdev_rx_handler_unregister for synchronize_rcu */
-	kfree(vrf_ptr);
-
-	cycle_netdev(port_dev);
-
-	slave = __vrf_find_slave_dev(queue, port_dev);
-	if (slave)
-		__vrf_remove_slave(queue, slave);
-
-	kfree(slave);
-
-	return 0;
-}
-
-static int vrf_del_slave(struct net_device *dev, struct net_device *port_dev)
-{
-	return do_vrf_del_slave(dev, port_dev);
-}
-
-static void vrf_dev_uninit(struct net_device *dev)
-{
-	struct net_vrf *vrf = netdev_priv(dev);
-	struct slave_queue *queue = &vrf->queue;
-	struct list_head *head = &queue->all_slaves;
-	struct slave *slave, *next;
-
-	vrf_rtable_destroy(vrf);
-
-	list_for_each_entry_safe(slave, next, head, list)
-		vrf_del_slave(dev, slave->dev);
-
-	free_percpu(dev->dstats);
-	dev->dstats = NULL;
-}
-
-static int vrf_dev_init(struct net_device *dev)
-{
-	struct net_vrf *vrf = netdev_priv(dev);
-
-	INIT_LIST_HEAD(&vrf->queue.all_slaves);
-
-	dev->dstats = netdev_alloc_pcpu_stats(struct pcpu_dstats);
-	if (!dev->dstats)
-		goto out_nomem;
-
-	/* create the default dst which points back to us */
-	vrf->rth = vrf_rtable_create(dev);
-	if (!vrf->rth)
-		goto out_stats;
-
-	dev->flags = IFF_MASTER | IFF_NOARP;
-
-	return 0;
-
-out_stats:
-	free_percpu(dev->dstats);
-	dev->dstats = NULL;
-out_nomem:
-	return -ENOMEM;
-}
-
-static const struct net_device_ops vrf_netdev_ops = {
-	.ndo_init		= vrf_dev_init,
-	.ndo_uninit		= vrf_dev_uninit,
-	.ndo_start_xmit		= vrf_xmit,
-	.ndo_get_stats64	= vrf_get_stats64,
-	.ndo_add_slave		= vrf_add_slave,
-	.ndo_del_slave		= vrf_del_slave,
-};
-
-static void vrf_get_drvinfo(struct net_device *dev,
-			    struct ethtool_drvinfo *info)
-{
-	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
-	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
-}
-
-static const struct ethtool_ops vrf_ethtool_ops = {
-	.get_drvinfo	= vrf_get_drvinfo,
-};
-
-static void vrf_setup(struct net_device *dev)
-{
-	ether_setup(dev);
-
-	/* Initialize the device structure. */
-	dev->netdev_ops = &vrf_netdev_ops;
-	dev->ethtool_ops = &vrf_ethtool_ops;
-	dev->destructor = free_netdev;
-
-	/* Fill in device structure with ethernet-generic values. */
-	eth_hw_addr_random(dev);
-
-	/* don't acquire vrf device's netif_tx_lock when transmitting */
-	dev->features |= NETIF_F_LLTX;
-
-	/* don't allow vrf devices to change network namespaces. */
-	dev->features |= NETIF_F_NETNS_LOCAL;
-}
-
-static int vrf_validate(struct nlattr *tb[], struct nlattr *data[])
-{
-	if (tb[IFLA_ADDRESS]) {
-		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
-			return -EINVAL;
-		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
-			return -EADDRNOTAVAIL;
-	}
-	return 0;
-}
-
-static void vrf_dellink(struct net_device *dev, struct list_head *head)
-{
-	struct net_vrf_dev *vrf_ptr = rtnl_dereference(dev->vrf_ptr);
-
-	RCU_INIT_POINTER(dev->vrf_ptr, NULL);
-	kfree_rcu(vrf_ptr, rcu);
-	unregister_netdevice_queue(dev, head);
-}
-
-static int vrf_newlink(struct net *src_net, struct net_device *dev,
-		       struct nlattr *tb[], struct nlattr *data[])
-{
-	struct net_vrf *vrf = netdev_priv(dev);
-	struct net_vrf_dev *vrf_ptr;
-	int err;
-
-	if (!data || !data[IFLA_VRF_TABLE])
-		return -EINVAL;
-
-	vrf->tb_id = nla_get_u32(data[IFLA_VRF_TABLE]);
-
-	dev->priv_flags |= IFF_VRF_MASTER;
-
-	err = -ENOMEM;
-	vrf_ptr = kmalloc(sizeof(*dev->vrf_ptr), GFP_KERNEL);
-	if (!vrf_ptr)
-		goto out_fail;
-
-	vrf_ptr->ifindex = dev->ifindex;
-	vrf_ptr->tb_id = vrf->tb_id;
-
-	err = register_netdevice(dev);
-	if (err < 0)
-		goto out_fail;
-
-	rcu_assign_pointer(dev->vrf_ptr, vrf_ptr);
-
-	return 0;
-
-out_fail:
-	kfree(vrf_ptr);
-	free_netdev(dev);
-	return err;
-}
-
-static size_t vrf_nl_getsize(const struct net_device *dev)
-{
-	return nla_total_size(sizeof(u32));  /* IFLA_VRF_TABLE */
-}
-
-static int vrf_fillinfo(struct sk_buff *skb,
-			const struct net_device *dev)
-{
-	struct net_vrf *vrf = netdev_priv(dev);
-
-	return nla_put_u32(skb, IFLA_VRF_TABLE, vrf->tb_id);
-}
-
-static const struct nla_policy vrf_nl_policy[IFLA_VRF_MAX + 1] = {
-	[IFLA_VRF_TABLE] = { .type = NLA_U32 },
-};
-
-static struct rtnl_link_ops vrf_link_ops __read_mostly = {
-	.kind		= DRV_NAME,
-	.priv_size	= sizeof(struct net_vrf),
-
-	.get_size	= vrf_nl_getsize,
-	.policy		= vrf_nl_policy,
-	.validate	= vrf_validate,
-	.fill_info	= vrf_fillinfo,
-
-	.newlink	= vrf_newlink,
-	.dellink	= vrf_dellink,
-	.setup		= vrf_setup,
-	.maxtype	= IFLA_VRF_MAX,
-};
-
-static int vrf_device_event(struct notifier_block *unused,
-			    unsigned long event, void *ptr)
-{
-	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
-
-	/* only care about unregister events to drop slave references */
-	if (event == NETDEV_UNREGISTER) {
-		struct net_vrf_dev *vrf_ptr = rtnl_dereference(dev->vrf_ptr);
-		struct net_device *vrf_dev;
-
-		if (!vrf_ptr || netif_is_vrf(dev))
-			goto out;
-
-		vrf_dev = netdev_master_upper_dev_get(dev);
-		vrf_del_slave(vrf_dev, dev);
-	}
-out:
-	return NOTIFY_DONE;
-}
-
-static struct notifier_block vrf_notifier_block __read_mostly = {
-	.notifier_call = vrf_device_event,
-};
-
-static int __init vrf_init_module(void)
-{
-	int rc;
-
-	vrf_dst_ops.kmem_cachep =
-		kmem_cache_create("vrf_ip_dst_cache",
-				  sizeof(struct rtable), 0,
-				  SLAB_HWCACHE_ALIGN,
-				  NULL);
-
-	if (!vrf_dst_ops.kmem_cachep)
-		return -ENOMEM;
-
-	register_netdevice_notifier(&vrf_notifier_block);
-
-	rc = rtnl_link_register(&vrf_link_ops);
-	if (rc < 0)
-		goto error;
-
-	return 0;
-
-error:
-	unregister_netdevice_notifier(&vrf_notifier_block);
-	kmem_cache_destroy(vrf_dst_ops.kmem_cachep);
-	return rc;
-}
-
-static void __exit vrf_cleanup_module(void)
-{
-	rtnl_link_unregister(&vrf_link_ops);
-	unregister_netdevice_notifier(&vrf_notifier_block);
-	kmem_cache_destroy(vrf_dst_ops.kmem_cachep);
-}
-
-module_init(vrf_init_module);
-module_exit(vrf_cleanup_module);
-MODULE_AUTHOR("Shrijeet Mukherjee, David Ahern");
-MODULE_DESCRIPTION("Device driver to instantiate VRF domains");
-MODULE_LICENSE("GPL");
-MODULE_ALIAS_RTNL_LINK(DRV_NAME);
-MODULE_VERSION(DRV_VERSION);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4bd177faa90c..cf393cd39ecf 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1262,7 +1262,7 @@ struct net_device_ops {
  * @IFF_LIVE_ADDR_CHANGE: device supports hardware address
  *	change when it's running
  * @IFF_MACVLAN: Macvlan device
- * @IFF_VRF_MASTER: device is a VRF master
+ * @IFF_MRF_MASTER: device is a MRF master
  * @IFF_NO_QUEUE: device can run without qdisc attached
  */
 enum netdev_priv_flags {
@@ -1291,7 +1291,7 @@ enum netdev_priv_flags {
 	IFF_XMIT_DST_RELEASE_PERM	= 1<<22,
 	IFF_IPVLAN_MASTER		= 1<<23,
 	IFF_IPVLAN_SLAVE		= 1<<24,
-	IFF_VRF_MASTER			= 1<<25,
+	IFF_MRF_MASTER			= 1<<25,
 	IFF_NO_QUEUE			= 1<<26,
 };
 
@@ -1320,7 +1320,7 @@ enum netdev_priv_flags {
 #define IFF_XMIT_DST_RELEASE_PERM	IFF_XMIT_DST_RELEASE_PERM
 #define IFF_IPVLAN_MASTER		IFF_IPVLAN_MASTER
 #define IFF_IPVLAN_SLAVE		IFF_IPVLAN_SLAVE
-#define IFF_VRF_MASTER			IFF_VRF_MASTER
+#define IFF_MRF_MASTER			IFF_MRF_MASTER
 #define IFF_NO_QUEUE			IFF_NO_QUEUE
 
 /**
@@ -1438,7 +1438,7 @@ enum netdev_priv_flags {
  *	@dn_ptr:	DECnet specific data
  *	@ip6_ptr:	IPv6 specific data
  *	@ax25_ptr:	AX.25 specific data
- *	@vrf_ptr:	VRF specific data
+ *	@mrf_ptr:	MRF specific data
  *	@ieee80211_ptr:	IEEE 802.11 specific data, assign before registering
  *
  *	@last_rx:	Time of last Rx
@@ -1657,7 +1657,7 @@ struct net_device {
 	struct dn_dev __rcu     *dn_ptr;
 	struct inet6_dev __rcu	*ip6_ptr;
 	void			*ax25_ptr;
-	struct net_vrf_dev __rcu *vrf_ptr;
+	struct net_mrf_dev __rcu *mrf_ptr;
 	struct wireless_dev	*ieee80211_ptr;
 	struct wpan_dev		*ieee802154_ptr;
 #if IS_ENABLED(CONFIG_MPLS_ROUTING)
@@ -3816,16 +3816,16 @@ static inline bool netif_supports_nofcs(struct net_device *dev)
 	return dev->priv_flags & IFF_SUPP_NOFCS;
 }
 
-static inline bool netif_is_vrf(const struct net_device *dev)
+static inline bool netif_is_mrf(const struct net_device *dev)
 {
-	return dev->priv_flags & IFF_VRF_MASTER;
+	return dev->priv_flags & IFF_MRF_MASTER;
 }
 
-static inline bool netif_index_is_vrf(struct net *net, int ifindex)
+static inline bool netif_index_is_mrf(struct net *net, int ifindex)
 {
 	bool rc = false;
 
-#if IS_ENABLED(CONFIG_NET_VRF)
+#if IS_ENABLED(CONFIG_NET_MRF)
 	struct net_device *dev;
 
 	if (ifindex == 0)
@@ -3835,7 +3835,7 @@ static inline bool netif_index_is_vrf(struct net *net, int ifindex)
 
 	dev = dev_get_by_index_rcu(net, ifindex);
 	if (dev)
-		rc = netif_is_vrf(dev);
+		rc = netif_is_mrf(dev);
 
 	rcu_read_unlock();
 #endif
diff --git a/include/net/flow.h b/include/net/flow.h
index 9e0297c4c11d..f16b2f9007e6 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -33,7 +33,7 @@ struct flowi_common {
 	__u8	flowic_flags;
 #define FLOWI_FLAG_ANYSRC		0x01
 #define FLOWI_FLAG_KNOWN_NH		0x02
-#define FLOWI_FLAG_VRFSRC		0x04
+#define FLOWI_FLAG_MRFSRC		0x04
 	__u32	flowic_secid;
 	struct flowi_tunnel flowic_tun_key;
 };
diff --git a/include/net/mrf.h b/include/net/mrf.h
new file mode 100644
index 000000000000..28aefa2661b0
--- /dev/null
+++ b/include/net/mrf.h
@@ -0,0 +1,177 @@
+/*
+ * include/net/mrf.h - adds mrf dev structure definitions
+ * Copyright (c) 2015 Cumulus Networks
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef __LINUX_NET_MRF_H
+#define __LINUX_NET_MRF_H
+
+struct net_mrf_dev {
+	struct rcu_head		rcu;
+	int                     ifindex; /* ifindex of master dev */
+	u32                     tb_id;   /* table id for MRF */
+};
+
+struct slave {
+	struct list_head	list;
+	struct net_device	*dev;
+};
+
+struct slave_queue {
+	struct list_head	all_slaves;
+};
+
+struct net_mrf {
+	struct slave_queue	queue;
+	struct rtable           *rth;
+	u32			tb_id;
+};
+
+#if IS_ENABLED(CONFIG_NET_MRF)
+/* called with rcu_read_lock() */
+static inline int mrf_master_ifindex_rcu(const struct net_device *dev)
+{
+	struct net_mrf_dev *mrf_ptr;
+	int ifindex = 0;
+
+	if (!dev)
+		return 0;
+
+	if (netif_is_mrf(dev)) {
+		ifindex = dev->ifindex;
+	} else {
+		mrf_ptr = rcu_dereference(dev->mrf_ptr);
+		if (mrf_ptr)
+			ifindex = mrf_ptr->ifindex;
+	}
+
+	return ifindex;
+}
+
+static inline int mrf_master_ifindex(const struct net_device *dev)
+{
+	int ifindex;
+
+	rcu_read_lock();
+	ifindex = mrf_master_ifindex_rcu(dev);
+	rcu_read_unlock();
+
+	return ifindex;
+}
+
+/* called with rcu_read_lock */
+static inline int mrf_dev_table_rcu(const struct net_device *dev)
+{
+	int tb_id = 0;
+
+	if (dev) {
+		struct net_mrf_dev *mrf_ptr;
+
+		mrf_ptr = rcu_dereference(dev->mrf_ptr);
+		if (mrf_ptr)
+			tb_id = mrf_ptr->tb_id;
+	}
+	return tb_id;
+}
+
+static inline int mrf_dev_table(const struct net_device *dev)
+{
+	int tb_id;
+
+	rcu_read_lock();
+	tb_id = mrf_dev_table_rcu(dev);
+	rcu_read_unlock();
+
+	return tb_id;
+}
+
+static inline int mrf_dev_table_ifindex(struct net *net, int ifindex)
+{
+	struct net_device *dev;
+	int tb_id = 0;
+
+	if (!ifindex)
+		return 0;
+
+	rcu_read_lock();
+
+	dev = dev_get_by_index_rcu(net, ifindex);
+	if (dev)
+		tb_id = mrf_dev_table_rcu(dev);
+
+	rcu_read_unlock();
+
+	return tb_id;
+}
+
+/* called with rtnl */
+static inline int mrf_dev_table_rtnl(const struct net_device *dev)
+{
+	int tb_id = 0;
+
+	if (dev) {
+		struct net_mrf_dev *mrf_ptr;
+
+		mrf_ptr = rtnl_dereference(dev->mrf_ptr);
+		if (mrf_ptr)
+			tb_id = mrf_ptr->tb_id;
+	}
+	return tb_id;
+}
+
+/* caller has already checked netif_is_mrf(dev) */
+static inline struct rtable *mrf_dev_get_rth(const struct net_device *dev)
+{
+	struct rtable *rth = ERR_PTR(-ENETUNREACH);
+	struct net_mrf *mrf = netdev_priv(dev);
+
+	if (mrf) {
+		rth = mrf->rth;
+		atomic_inc(&rth->dst.__refcnt);
+	}
+	return rth;
+}
+
+#else
+static inline int mrf_master_ifindex_rcu(const struct net_device *dev)
+{
+	return 0;
+}
+
+static inline int mrf_master_ifindex(const struct net_device *dev)
+{
+	return 0;
+}
+
+static inline int mrf_dev_table_rcu(const struct net_device *dev)
+{
+	return 0;
+}
+
+static inline int mrf_dev_table(const struct net_device *dev)
+{
+	return 0;
+}
+
+static inline int mrf_dev_table_ifindex(struct net *net, int ifindex)
+{
+	return 0;
+}
+
+static inline int mrf_dev_table_rtnl(const struct net_device *dev)
+{
+	return 0;
+}
+
+static inline struct rtable *mrf_dev_get_rth(const struct net_device *dev)
+{
+	return ERR_PTR(-ENETUNREACH);
+}
+#endif
+
+#endif /* __LINUX_NET_MRF_H */
diff --git a/include/net/route.h b/include/net/route.h
index 395d79bb556c..563689584be1 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -254,8 +254,8 @@ static inline void ip_route_connect_init(struct flowi4 *fl4, __be32 dst, __be32
 	if (inet_sk(sk)->transparent)
 		flow_flags |= FLOWI_FLAG_ANYSRC;
 
-	if (netif_index_is_vrf(sock_net(sk), oif))
-		flow_flags |= FLOWI_FLAG_VRFSRC;
+	if (netif_index_is_mrf(sock_net(sk), oif))
+		flow_flags |= FLOWI_FLAG_MRFSRC;
 
 	flowi4_init_output(fl4, oif, sk->sk_mark, tos, RT_SCOPE_UNIVERSE,
 			   protocol, flow_flags, dst, src, dport, sport);
diff --git a/include/net/vrf.h b/include/net/vrf.h
deleted file mode 100644
index 5bfb16237fd7..000000000000
--- a/include/net/vrf.h
+++ /dev/null
@@ -1,178 +0,0 @@
-/*
- * include/net/net_vrf.h - adds vrf dev structure definitions
- * Copyright (c) 2015 Cumulus Networks
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- */
-
-#ifndef __LINUX_NET_VRF_H
-#define __LINUX_NET_VRF_H
-
-struct net_vrf_dev {
-	struct rcu_head		rcu;
-	int                     ifindex; /* ifindex of master dev */
-	u32                     tb_id;   /* table id for VRF */
-};
-
-struct slave {
-	struct list_head	list;
-	struct net_device	*dev;
-};
-
-struct slave_queue {
-	struct list_head	all_slaves;
-};
-
-struct net_vrf {
-	struct slave_queue	queue;
-	struct rtable           *rth;
-	u32			tb_id;
-};
-
-
-#if IS_ENABLED(CONFIG_NET_VRF)
-/* called with rcu_read_lock() */
-static inline int vrf_master_ifindex_rcu(const struct net_device *dev)
-{
-	struct net_vrf_dev *vrf_ptr;
-	int ifindex = 0;
-
-	if (!dev)
-		return 0;
-
-	if (netif_is_vrf(dev)) {
-		ifindex = dev->ifindex;
-	} else {
-		vrf_ptr = rcu_dereference(dev->vrf_ptr);
-		if (vrf_ptr)
-			ifindex = vrf_ptr->ifindex;
-	}
-
-	return ifindex;
-}
-
-static inline int vrf_master_ifindex(const struct net_device *dev)
-{
-	int ifindex;
-
-	rcu_read_lock();
-	ifindex = vrf_master_ifindex_rcu(dev);
-	rcu_read_unlock();
-
-	return ifindex;
-}
-
-/* called with rcu_read_lock */
-static inline int vrf_dev_table_rcu(const struct net_device *dev)
-{
-	int tb_id = 0;
-
-	if (dev) {
-		struct net_vrf_dev *vrf_ptr;
-
-		vrf_ptr = rcu_dereference(dev->vrf_ptr);
-		if (vrf_ptr)
-			tb_id = vrf_ptr->tb_id;
-	}
-	return tb_id;
-}
-
-static inline int vrf_dev_table(const struct net_device *dev)
-{
-	int tb_id;
-
-	rcu_read_lock();
-	tb_id = vrf_dev_table_rcu(dev);
-	rcu_read_unlock();
-
-	return tb_id;
-}
-
-static inline int vrf_dev_table_ifindex(struct net *net, int ifindex)
-{
-	struct net_device *dev;
-	int tb_id = 0;
-
-	if (!ifindex)
-		return 0;
-
-	rcu_read_lock();
-
-	dev = dev_get_by_index_rcu(net, ifindex);
-	if (dev)
-		tb_id = vrf_dev_table_rcu(dev);
-
-	rcu_read_unlock();
-
-	return tb_id;
-}
-
-/* called with rtnl */
-static inline int vrf_dev_table_rtnl(const struct net_device *dev)
-{
-	int tb_id = 0;
-
-	if (dev) {
-		struct net_vrf_dev *vrf_ptr;
-
-		vrf_ptr = rtnl_dereference(dev->vrf_ptr);
-		if (vrf_ptr)
-			tb_id = vrf_ptr->tb_id;
-	}
-	return tb_id;
-}
-
-/* caller has already checked netif_is_vrf(dev) */
-static inline struct rtable *vrf_dev_get_rth(const struct net_device *dev)
-{
-	struct rtable *rth = ERR_PTR(-ENETUNREACH);
-	struct net_vrf *vrf = netdev_priv(dev);
-
-	if (vrf) {
-		rth = vrf->rth;
-		atomic_inc(&rth->dst.__refcnt);
-	}
-	return rth;
-}
-
-#else
-static inline int vrf_master_ifindex_rcu(const struct net_device *dev)
-{
-	return 0;
-}
-
-static inline int vrf_master_ifindex(const struct net_device *dev)
-{
-	return 0;
-}
-
-static inline int vrf_dev_table_rcu(const struct net_device *dev)
-{
-	return 0;
-}
-
-static inline int vrf_dev_table(const struct net_device *dev)
-{
-	return 0;
-}
-
-static inline int vrf_dev_table_ifindex(struct net *net, int ifindex)
-{
-	return 0;
-}
-
-static inline int vrf_dev_table_rtnl(const struct net_device *dev)
-{
-	return 0;
-}
-
-static inline struct rtable *vrf_dev_get_rth(const struct net_device *dev)
-{
-	return ERR_PTR(-ENETUNREACH);
-}
-#endif
-
-#endif /* __LINUX_NET_VRF_H */
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 313c305fd1ad..09848e0a7e12 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -341,14 +341,14 @@ enum macvlan_macaddr_mode {
 
 #define MACVLAN_FLAG_NOPROMISC	1
 
-/* VRF section */
+/* MRF section */
 enum {
-	IFLA_VRF_UNSPEC,
-	IFLA_VRF_TABLE,
-	__IFLA_VRF_MAX
+	IFLA_MRF_UNSPEC,
+	IFLA_MRF_TABLE,
+	__IFLA_MRF_MAX
 };
 
-#define IFLA_VRF_MAX (__IFLA_VRF_MAX - 1)
+#define IFLA_MRF_MAX (__IFLA_MRF_MAX - 1)
 
 /* IPVLAN section */
 enum {
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 675e88cac2b4..10a6f7b85c1b 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -119,7 +119,7 @@
 #ifdef CONFIG_IP_MROUTE
 #include <linux/mroute.h>
 #endif
-#include <net/vrf.h>
+#include <net/mrf.h>
 
 
 /* The inetsw table contains everything that inet_create needs to
@@ -450,7 +450,7 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			goto out;
 	}
 
-	tb_id = vrf_dev_table_ifindex(net, sk->sk_bound_dev_if) ? : tb_id;
+	tb_id = mrf_dev_table_ifindex(net, sk->sk_bound_dev_if) ? : tb_id;
 	chk_addr_ret = inet_addr_type_table(net, addr->sin_addr.s_addr, tb_id);
 
 	/* Not specified by any standard per-se, however it breaks too
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 7fa277176c33..69a0e0563ab6 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -45,7 +45,7 @@
 #include <net/ip_fib.h>
 #include <net/rtnetlink.h>
 #include <net/xfrm.h>
-#include <net/vrf.h>
+#include <net/mrf.h>
 
 #ifndef CONFIG_IP_MULTIPLE_TABLES
 
@@ -254,7 +254,7 @@ EXPORT_SYMBOL(inet_addr_type);
 unsigned int inet_dev_addr_type(struct net *net, const struct net_device *dev,
 				__be32 addr)
 {
-	int rt_table = vrf_dev_table(dev) ? : RT_TABLE_LOCAL;
+	int rt_table = mrf_dev_table(dev) ? : RT_TABLE_LOCAL;
 
 	return __inet_dev_addr_type(net, dev, addr, rt_table);
 }
@@ -267,7 +267,7 @@ unsigned int inet_addr_type_dev_table(struct net *net,
 				      const struct net_device *dev,
 				      __be32 addr)
 {
-	int rt_table = vrf_dev_table(dev) ? : RT_TABLE_LOCAL;
+	int rt_table = mrf_dev_table(dev) ? : RT_TABLE_LOCAL;
 
 	return __inet_dev_addr_type(net, NULL, addr, rt_table);
 }
@@ -331,7 +331,7 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	bool dev_match;
 
 	fl4.flowi4_oif = 0;
-	fl4.flowi4_iif = vrf_master_ifindex_rcu(dev);
+	fl4.flowi4_iif = mrf_master_ifindex_rcu(dev);
 	if (!fl4.flowi4_iif)
 		fl4.flowi4_iif = oif ? : LOOPBACK_IFINDEX;
 	fl4.daddr = src;
@@ -363,7 +363,7 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 		if (nh->nh_dev == dev) {
 			dev_match = true;
 			break;
-		} else if (vrf_master_ifindex_rcu(nh->nh_dev) == dev->ifindex) {
+		} else if (mrf_master_ifindex_rcu(nh->nh_dev) == dev->ifindex) {
 			dev_match = true;
 			break;
 		}
@@ -800,7 +800,7 @@ out:
 static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifaddr *ifa)
 {
 	struct net *net = dev_net(ifa->ifa_dev->dev);
-	int tb_id = vrf_dev_table_rtnl(ifa->ifa_dev->dev);
+	int tb_id = mrf_dev_table_rtnl(ifa->ifa_dev->dev);
 	struct fib_table *tb;
 	struct fib_config cfg = {
 		.fc_protocol = RTPROT_KERNEL,
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 5154f81c5326..990637261312 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1423,7 +1423,7 @@ found:
 			    nh->nh_flags & RTNH_F_LINKDOWN &&
 			    !(fib_flags & FIB_LOOKUP_IGNORE_LINKSTATE))
 				continue;
-			if (!(flp->flowi4_flags & FLOWI_FLAG_VRFSRC)) {
+			if (!(flp->flowi4_flags & FLOWI_FLAG_MRFSRC)) {
 				if (flp->flowi4_oif &&
 				    flp->flowi4_oif != nh->nh_oif)
 					continue;
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index f16488efa1c8..3ad1f3749494 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -96,7 +96,7 @@
 #include <net/xfrm.h>
 #include <net/inet_common.h>
 #include <net/ip_fib.h>
-#include <net/vrf.h>
+#include <net/mrf.h>
 
 /*
  *	Build xmit assembly blocks
@@ -426,7 +426,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	fl4.flowi4_mark = mark;
 	fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
 	fl4.flowi4_proto = IPPROTO_ICMP;
-	fl4.flowi4_oif = vrf_master_ifindex(skb->dev) ? : skb->dev->ifindex;
+	fl4.flowi4_oif = mrf_master_ifindex(skb->dev) ? : skb->dev->ifindex;
 	security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_key(net, &fl4);
 	if (IS_ERR(rt))
@@ -460,7 +460,8 @@ static struct rtable *icmp_route_lookup(struct net *net,
 	fl4->flowi4_proto = IPPROTO_ICMP;
 	fl4->fl4_icmp_type = type;
 	fl4->fl4_icmp_code = code;
-	fl4->flowi4_oif = vrf_master_ifindex(skb_in->dev) ? : skb_in->dev->ifindex;
+	fl4->flowi4_oif = mrf_master_ifindex(skb_in->dev) ? :
+			  skb_in->dev->ifindex;
 
 	security_skb_classify_flow(skb_in, flowi4_to_flowi(fl4));
 	rt = __ip_route_output_key(net, fl4);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 15762e758861..aa2edb33a1fb 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -48,7 +48,7 @@
 #include <linux/inet.h>
 #include <linux/netfilter_ipv4.h>
 #include <net/inet_ecn.h>
-#include <net/vrf.h>
+#include <net/mrf.h>
 
 /* NOTE. Logic of IP defragmentation is parallel to corresponding IPv6
  * code now. If you change something here, _PLEASE_ update ipv6/reassembly.c
@@ -78,7 +78,7 @@ struct ipq {
 	u8		ecn; /* RFC3168 support */
 	u16		max_df_size; /* largest frag with DF set seen */
 	int             iif;
-	int             vif;   /* VRF device index */
+	int             vif;   /* MRF device index */
 	unsigned int    rid;
 	struct inet_peer *peer;
 };
@@ -656,7 +656,7 @@ out_fail:
 int ip_defrag(struct sk_buff *skb, u32 user)
 {
 	struct net_device *dev = skb->dev ? : skb_dst(skb)->dev;
-	int vif = vrf_master_ifindex_rcu(dev);
+	int vif = mrf_master_ifindex_rcu(dev);
 	struct net *net = dev_net(dev);
 	struct ipq *qp;
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 0138fada0951..ab0ca85ff35f 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1561,7 +1561,7 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb,
 	}
 
 	oif = arg->bound_dev_if;
-	if (!oif && netif_index_is_vrf(net, skb->skb_iif))
+	if (!oif && netif_index_is_mrf(net, skb->skb_iif))
 		oif = skb->skb_iif;
 
 	flowi4_init_output(&fl4, oif,
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f3087aaa6dd8..a804ec1a672d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -112,7 +112,7 @@
 #endif
 #include <net/secure_seq.h>
 #include <net/ip_tunnels.h>
-#include <net/vrf.h>
+#include <net/mrf.h>
 
 #define RT_FL_TOS(oldflp4) \
 	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
@@ -1730,7 +1730,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	 *	Now we are ready to route packet.
 	 */
 	fl4.flowi4_oif = 0;
-	fl4.flowi4_iif = vrf_master_ifindex_rcu(dev) ? : dev->ifindex;
+	fl4.flowi4_iif = mrf_master_ifindex_rcu(dev) ? : dev->ifindex;
 	fl4.flowi4_mark = skb->mark;
 	fl4.flowi4_tos = tos;
 	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
@@ -2132,9 +2132,9 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 				fl4->saddr = inet_select_addr(dev_out, 0,
 							      RT_SCOPE_HOST);
 		}
-		if (netif_is_vrf(dev_out) &&
-		    !(fl4->flowi4_flags & FLOWI_FLAG_VRFSRC)) {
-			rth = vrf_dev_get_rth(dev_out);
+		if (netif_is_mrf(dev_out) &&
+		    !(fl4->flowi4_flags & FLOWI_FLAG_MRFSRC)) {
+			rth = mrf_dev_get_rth(dev_out);
 			goto out;
 		}
 	}
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index c0a15e7f359f..5898254b0c01 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1017,14 +1017,14 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 
 		fl4 = &fl4_stack;
 
-		/* unconnected socket. If output device is enslaved to a VRF
-		 * device lookup source address from VRF table. This mimics
+		/* unconnected socket. If output device is enslaved to a MRF
+		 * device lookup source address from MRF table. This mimics
 		 * behavior of ip_route_connect{_init}.
 		 */
-		if (netif_index_is_vrf(net, ipc.oif)) {
+		if (netif_index_is_mrf(net, ipc.oif)) {
 			flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
 					   RT_SCOPE_UNIVERSE, sk->sk_protocol,
-					   (flow_flags | FLOWI_FLAG_VRFSRC),
+					   (flow_flags | FLOWI_FLAG_MRFSRC),
 					   faddr, saddr, dport,
 					   inet->inet_sport);
 
-- 
2.4.2
