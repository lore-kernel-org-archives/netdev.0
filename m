From: "John W. Linville" <linville@tuxdriver.com>
Subject: [RFC PATCH 5/5] geneve: add initial netdev driver for GENEVE tunnels
Date: Thu,  2 Apr 2015 15:17:06 -0400
Message-ID: <1428002227-11636-6-git-send-email-linville@tuxdriver.com>
References: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49872 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752295AbbDBTTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 15:19:13 -0400
In-Reply-To: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an initial implementation of a netdev driver for GENEVE
tunnels.  This implementation uses a fixed UDP port, and only supports
a single tunnel (and therefore only a single VNI) per net namespace.
Only IPv4 links are supported at this time.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 drivers/net/Kconfig          |  14 ++
 drivers/net/Makefile         |   1 +
 drivers/net/geneve.c         | 451 +++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/if_link.h |   9 +
 4 files changed, 475 insertions(+)
 create mode 100644 drivers/net/geneve.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index df51d6025a90..c2519a4e0845 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -179,6 +179,20 @@ config VXLAN
 	  To compile this driver as a module, choose M here: the module
 	  will be called vxlan.
 
+config GENEVE
+       tristate "Generic Network Virtualization Encapsulation netdev"
+       depends on INET && LIBGENEVE
+       select NET_IP_TUNNEL
+       ---help---
+	  This allows one to create geneve virtual interfaces that provide
+	  Layer 2 Networks over Layer 3 Networks. GENEVE is often used
+	  to tunnel virtual network infrastructure in virtualized environments.
+	  For more information see:
+	    http://tools.ietf.org/html/draft-gross-geneve-02
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called geneve.
+
 config NETCONSOLE
 	tristate "Network console logging support"
 	---help---
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index e25fdd7d905e..c12cb22478a7 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -23,6 +23,7 @@ obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_VXLAN) += vxlan.o
+obj-$(CONFIG_GENEVE) += geneve.o
 obj-$(CONFIG_NLMON) += nlmon.o
 
 #
diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
new file mode 100644
index 000000000000..fe8895487fc2
--- /dev/null
+++ b/drivers/net/geneve.c
@@ -0,0 +1,451 @@
+/*
+ * GENEVE: Generic Network Virtualization Encapsulation
+ *
+ * Copyright (c) 2015 Red Hat, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <net/rtnetlink.h>
+#include <net/geneve.h>
+
+#define GENEVE_NETDEV_VER	"0.1"
+
+#define GENEVE_UDP_PORT		6081
+
+#define GENEVE_N_VID	(1u << 24)
+#define GENEVE_VID_MASK	(GENEVE_N_VID - 1)
+
+/* per-network namespace private data for this module */
+struct geneve_net {
+	struct list_head  geneve_list;
+};
+
+/* Pseudo network device */
+struct geneve_dev {
+	struct net	   *net;	/* netns for packet i/o */
+	struct net_device  *dev;	/* netdev for geneve tunnel */
+	struct geneve_sock *sock;	/* socket used for geneve tunnel */
+	u8 vni[3];			/* virtual network ID for tunnel */
+	struct sockaddr_in remote;	/* IPv4 address for link partner */
+	struct work_struct sock_work;	/* work item for binding socket */
+	struct list_head   next;	/* geneve's per namespace list */
+};
+
+static void geneve_sock_work(struct work_struct *work);
+
+static struct workqueue_struct *geneve_wq;
+
+static int geneve_net_id;
+
+/* geneve receive/decap routine */
+static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
+{
+	struct genevehdr *gnvh = geneve_hdr(skb);
+	struct geneve_dev *geneve;
+	struct pcpu_sw_netstats *stats;
+
+	geneve = gs->rcv_data;
+
+	/* Does the VNI match the device? */
+	if (memcmp(gnvh->vni, geneve->vni, sizeof(geneve->vni)))
+		goto drop;
+
+	skb_reset_mac_header(skb);
+	skb_scrub_packet(skb, !net_eq(geneve->net, dev_net(geneve->dev)));
+	skb->protocol = eth_type_trans(skb, geneve->dev);
+
+	/* force IP checksum recalculation */
+	skb->ip_summed = CHECKSUM_NONE;
+
+	/* Ignore packet loops (and multicast echo) */
+	if (ether_addr_equal(eth_hdr(skb)->h_source, geneve->dev->dev_addr))
+		goto drop;
+
+	skb_reset_network_header(skb);
+
+	stats = this_cpu_ptr(geneve->dev->tstats);
+	u64_stats_update_begin(&stats->syncp);
+	stats->rx_packets++;
+	stats->rx_bytes += skb->len;
+	u64_stats_update_end(&stats->syncp);
+
+	netif_rx(skb);
+
+	return;
+drop:
+	/* Consume bad packet */
+	kfree_skb(skb);
+}
+
+/* Scheduled at device creation to bind to a socket */
+static void geneve_sock_work(struct work_struct *work)
+{
+	struct geneve_dev *geneve = container_of(work, struct geneve_dev, sock_work);
+	struct net *net = geneve->net;
+	struct geneve_sock *gs;
+
+	gs = geneve_sock_add(net, htons(GENEVE_UDP_PORT), geneve_rx, geneve,
+	                     true, false);
+	if (!IS_ERR(gs))
+		geneve->sock = gs;
+
+	dev_put(geneve->dev);
+}
+
+/* Setup stats when device is created */
+static int geneve_init(struct net_device *dev)
+{
+	struct geneve_dev *geneve = netdev_priv(dev);
+
+	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
+	if (!dev->tstats)
+		return -ENOMEM;
+
+	/* make new socket outside of RTNL */
+	dev_hold(dev);
+	queue_work(geneve_wq, &geneve->sock_work);
+
+	return 0;
+}
+
+static void geneve_uninit(struct net_device *dev)
+{
+	struct geneve_dev *geneve = netdev_priv(dev);
+	struct geneve_sock *gs = geneve->sock;
+
+	if (gs)
+		geneve_sock_release(gs);
+	free_percpu(dev->tstats);
+}
+
+static int geneve_open(struct net_device *dev)
+{
+	struct geneve_dev *geneve = netdev_priv(dev);
+	struct geneve_sock *gs = geneve->sock;
+
+	/* socket hasn't been created */
+	if (!gs)
+		return -ENOTCONN;
+
+	return 0;
+}
+
+static int geneve_stop(struct net_device *dev)
+{
+	return 0;
+}
+
+static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct geneve_dev *geneve = netdev_priv(dev);
+	struct geneve_sock *gs = geneve->sock;
+	struct rtable *rt = NULL;
+	const struct iphdr *iip; /* interior IP header */
+	struct flowi4 fl4;
+	int err;
+	__be16 sport;
+	__u8 tos, ttl = 0;
+
+	iip = ip_hdr(skb);
+
+	skb_reset_mac_header(skb);
+
+	/* TODO: port min/max limits should be configurable */
+	sport = udp_flow_src_port(dev_net(dev), skb, 0, 0, true);
+
+	memset(&fl4, 0, sizeof(fl4));
+	fl4.daddr = geneve->remote.sin_addr.s_addr;
+	rt = ip_route_output_key(geneve->net, &fl4);
+	if (IS_ERR(rt)) {
+		netdev_dbg(dev, "no route to %pI4\n", &fl4.daddr);
+		dev->stats.tx_carrier_errors++;
+		goto tx_error;
+	}
+	if (rt->dst.dev == dev) { /* is this necessary? */
+		netdev_dbg(dev, "circular route to %pI4\n", &fl4.daddr);
+		dev->stats.collisions++;
+		goto rt_tx_error;
+	}
+
+	/* TODO: tos and ttl should be configurable */
+
+	tos = ip_tunnel_ecn_encap(0, iip, skb);
+
+	if (IN_MULTICAST(ntohl(fl4.daddr)))
+		ttl = 1;
+
+	ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
+
+	/* no need to handle local destination and encap bypass...yet... */
+
+	err = geneve_xmit_skb(gs, rt, skb, fl4.saddr, fl4.daddr,
+	                      tos, ttl, 0, sport, htons(GENEVE_UDP_PORT), 0,
+	                      geneve->vni, 0, NULL, false,
+	                      !net_eq(geneve->net, dev_net(geneve->dev)));
+	if (err < 0)
+		ip_rt_put(rt);
+
+	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
+
+	return NETDEV_TX_OK;
+
+rt_tx_error:
+	ip_rt_put(rt);
+tx_error:
+	dev->stats.tx_errors++;
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
+}
+
+static const struct net_device_ops geneve_netdev_ops = {
+	.ndo_init		= geneve_init,
+	.ndo_uninit		= geneve_uninit,
+	.ndo_open		= geneve_open,
+	.ndo_stop		= geneve_stop,
+	.ndo_start_xmit		= geneve_xmit,
+	.ndo_get_stats64	= ip_tunnel_get_stats64,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
+/* Info for udev, that this is a virtual tunnel endpoint */
+static struct device_type geneve_type = {
+	.name = "geneve",
+};
+
+/* Initialize the device structure. */
+static void geneve_setup(struct net_device *dev)
+{
+	struct geneve_dev *geneve = netdev_priv(dev);
+
+	ether_setup(dev);
+
+	dev->netdev_ops = &geneve_netdev_ops;
+	dev->destructor = free_netdev;
+	SET_NETDEV_DEVTYPE(dev, &geneve_type);
+
+	INIT_WORK(&geneve->sock_work, geneve_sock_work);
+
+	dev->tx_queue_len = 0;
+	dev->features = 0;
+
+	dev->vlan_features = dev->features;
+	dev->hw_features = 0;
+
+	geneve->dev = dev;
+}
+
+static const struct nla_policy geneve_policy[IFLA_GENEVE_MAX + 1] = {
+	[IFLA_GENEVE_ID]		= { .type = NLA_U32 },
+	[IFLA_GENEVE_REMOTE]		= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
+};
+
+static int geneve_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	if (tb[IFLA_ADDRESS]) {
+		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
+			return -EINVAL;
+
+		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+			return -EADDRNOTAVAIL;
+	}
+
+	if (!data)
+		return -EINVAL;
+
+	if (data[IFLA_GENEVE_ID]) {
+		__u32 vni =  nla_get_u32(data[IFLA_GENEVE_ID]);
+		if (vni >= GENEVE_VID_MASK)
+			return -ERANGE;
+	}
+
+	return 0;
+}
+
+static void geneve_get_drvinfo(struct net_device *dev,
+			       struct ethtool_drvinfo *drvinfo)
+{
+	strlcpy(drvinfo->version, GENEVE_NETDEV_VER, sizeof(drvinfo->version));
+	strlcpy(drvinfo->driver, "geneve", sizeof(drvinfo->driver));
+}
+
+static const struct ethtool_ops geneve_ethtool_ops = {
+	.get_drvinfo	= geneve_get_drvinfo,
+	.get_link	= ethtool_op_get_link,
+};
+
+static int geneve_newlink(struct net *net, struct net_device *dev,
+			 struct nlattr *tb[], struct nlattr *data[])
+{
+	struct geneve_net *gn = net_generic(net, geneve_net_id);
+	struct geneve_dev *geneve = netdev_priv(dev);
+	__u32 vni;
+	int err;
+
+	/* TODO: need to support multiple tunnels in a namespace */
+	if (!list_empty(&gn->geneve_list))
+		return -EBUSY;
+
+	if (!data[IFLA_GENEVE_ID])
+		return -EINVAL;
+
+	geneve->net = net;
+
+	vni = nla_get_u32(data[IFLA_GENEVE_ID]);
+	geneve->vni[0] = (vni & 0x00ff0000) >> 16;
+	geneve->vni[1] = (vni & 0x0000ff00) >> 8;
+	geneve->vni[2] =  vni & 0x000000ff;
+
+	if (data[IFLA_GENEVE_REMOTE])
+		geneve->remote.sin_addr.s_addr =
+			nla_get_be32(data[IFLA_GENEVE_REMOTE]);
+
+	dev->ethtool_ops = &geneve_ethtool_ops;
+
+	if (tb[IFLA_ADDRESS] == NULL)
+		eth_hw_addr_random(dev);
+
+	err = register_netdevice(dev);
+	if (err)
+		return err;
+
+	list_add(&geneve->next, &gn->geneve_list);
+
+	return 0;
+}
+
+static void geneve_dellink(struct net_device *dev, struct list_head *head)
+{
+	struct geneve_dev *geneve = netdev_priv(dev);
+
+	list_del(&geneve->next);
+	unregister_netdevice_queue(dev, head);
+}
+
+static size_t geneve_get_size(const struct net_device *dev)
+{
+	return nla_total_size(sizeof(__u32)) +	/* IFLA_GENEVE_ID */
+		nla_total_size(sizeof(struct in_addr)) + /* IFLA_GENEVE_REMOTE */
+		0;
+}
+
+static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
+{
+	struct geneve_dev *geneve = netdev_priv(dev);
+	__u32 vni;
+
+	vni = (geneve->vni[0] << 16) | (geneve->vni[1] << 8) | geneve->vni[2];
+	if (nla_put_u32(skb, IFLA_GENEVE_ID, vni))
+		goto nla_put_failure;
+
+	if (nla_put_be32(skb, IFLA_GENEVE_REMOTE,
+			 geneve->remote.sin_addr.s_addr))
+		goto nla_put_failure;
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static struct rtnl_link_ops geneve_link_ops __read_mostly = {
+	.kind		= "geneve",
+	.maxtype	= IFLA_GENEVE_MAX,
+	.policy		= geneve_policy,
+	.priv_size	= sizeof(struct geneve_dev),
+	.setup		= geneve_setup,
+	.validate	= geneve_validate,
+	.newlink	= geneve_newlink,
+	.dellink	= geneve_dellink,
+	.get_size	= geneve_get_size,
+	.fill_info	= geneve_fill_info,
+};
+
+static __net_init int geneve_init_net(struct net *net)
+{
+	struct geneve_net *gn = net_generic(net, geneve_net_id);
+
+	INIT_LIST_HEAD(&gn->geneve_list);
+
+	return 0;
+}
+
+static void __net_exit geneve_exit_net(struct net *net)
+{
+	struct geneve_net *gn = net_generic(net, geneve_net_id);
+	struct geneve_dev *geneve, *next;
+	struct net_device *dev, *aux;
+	LIST_HEAD(list);
+
+	rtnl_lock();
+	for_each_netdev_safe(net, dev, aux)
+		if (dev->rtnl_link_ops == &geneve_link_ops)
+			unregister_netdevice_queue(dev, &list);
+
+	list_for_each_entry_safe(geneve, next, &gn->geneve_list, next) {
+		/* If geneve->dev is in the same netns, it was already added
+		 * to the list by the previous loop.
+		 */
+		if (!net_eq(dev_net(geneve->dev), net))
+			unregister_netdevice_queue(dev, &list);
+	}
+
+	unregister_netdevice_many(&list);
+	rtnl_unlock();
+}
+
+static struct pernet_operations geneve_net_ops = {
+	.init = geneve_init_net,
+	.exit = geneve_exit_net,
+	.id   = &geneve_net_id,
+	.size = sizeof(struct geneve_net),
+};
+
+static int __init geneve_init_module(void)
+{
+	int rc;
+
+	geneve_wq = alloc_workqueue("geneve", 0, 0);
+	if (!geneve_wq)
+		return -ENOMEM;
+
+	rc = register_pernet_subsys(&geneve_net_ops);
+	if (rc)
+		goto out1;
+
+	rc = rtnl_link_register(&geneve_link_ops);
+	if (rc)
+		goto out2;
+
+	return 0;
+out2:
+	unregister_pernet_subsys(&geneve_net_ops);
+out1:
+	destroy_workqueue(geneve_wq);
+	return rc;
+}
+late_initcall(geneve_init_module);
+
+static void __exit geneve_cleanup_module(void)
+{
+	rtnl_link_unregister(&geneve_link_ops);
+	destroy_workqueue(geneve_wq);
+	unregister_pernet_subsys(&geneve_net_ops);
+}
+module_exit(geneve_cleanup_module);
+
+MODULE_LICENSE("GPL");
+MODULE_VERSION(GENEVE_NETDEV_VER);
+MODULE_AUTHOR("John W. Linville <linville@tuxdriver.com>");
+MODULE_DESCRIPTION("Interface driver for GENEVE encapsulated traffic");
+MODULE_ALIAS_RTNL_LINK("geneve");
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 7ffb18df01ca..b0c93c361844 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -390,6 +390,15 @@ struct ifla_vxlan_port_range {
 	__be16	high;
 };
 
+/* GENEVE section */
+enum {
+	IFLA_GENEVE_UNSPEC,
+	IFLA_GENEVE_ID,
+	IFLA_GENEVE_REMOTE,
+	__IFLA_GENEVE_MAX
+};
+#define IFLA_GENEVE_MAX	(__IFLA_GENEVE_MAX - 1)
+
 /* Bonding section */
 
 enum {
-- 
2.1.0
