From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: [PATCH 2/2] drivers: add vpls support
Date: Thu, 10 Aug 2017 22:28:37 +0200
Message-ID: <1502396917-14848-3-git-send-email-amine.kherbouche@6wind.com>
References: <1502396917-14848-1-git-send-email-amine.kherbouche@6wind.com>
Cc: amine.kherbouche@6wind.com, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:34820 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753183AbdHJU3B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 16:29:01 -0400
Received: by mail-wm0-f50.google.com with SMTP id m85so28246863wma.0
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2017 13:29:01 -0700 (PDT)
In-Reply-To: <1502396917-14848-1-git-send-email-amine.kherbouche@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit introduces the support of VPLS virtual device, that allows
performing  L2VPN multipoint to multipoint communication over MPLS PSN.

VPLS device encap received ethernet frame over mpls packet and send it the
output device, in the other direction, when receiving the right configured
mpls packet, the matched mpls route calls the handler vpls function,
then pulls out the mpls header and send it back the entry point via
netif_rx().

Two functions, mpls_entry_encode() and mpls_output_possible() are
exported from mpls/internal.h to be able to use them inside vpls driver.

Signed-off-by: Amine Kherbouche <amine.kherbouche@6wind.com>
---
 drivers/net/Kconfig          |   8 +
 drivers/net/Makefile         |   1 +
 drivers/net/vpls.c           | 531 +++++++++++++++++++++++++++++++++++++++++++
 include/net/mpls.h           |  15 ++
 include/net/vpls.h           |  21 ++
 include/uapi/linux/if_link.h |  15 ++
 net/mpls/internal.h          |  12 -
 7 files changed, 591 insertions(+), 12 deletions(-)
 create mode 100644 drivers/net/vpls.c
 create mode 100644 include/net/vpls.h

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 83a1616..2ae5a23 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -363,6 +363,14 @@ config VSOCKMON
      mostly intended for developers or support to debug vsock issues. If
      unsure, say N.
 
+config VPLS
+       tristate "Virtual Private LAN Service (VPLS)"
+       depends on MPLS_ROUTING
+       ---help---
+	  This allows one to create VPLS virtual interfaces that provide
+	  Layer 2 Networks multipoint to multipoint communication over MPLS
+	  PSN.
+
 endif # NET_CORE
 
 config SUNGEM_PHY
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index b2f6556..7488975 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -31,6 +31,7 @@ obj-$(CONFIG_GTP) += gtp.o
 obj-$(CONFIG_NLMON) += nlmon.o
 obj-$(CONFIG_NET_VRF) += vrf.o
 obj-$(CONFIG_VSOCKMON) += vsockmon.o
+obj-$(CONFIG_VPLS) += vpls.o
 
 #
 # Networking Drivers
diff --git a/drivers/net/vpls.c b/drivers/net/vpls.c
new file mode 100644
index 0000000..b51e31a
--- /dev/null
+++ b/drivers/net/vpls.c
@@ -0,0 +1,531 @@
+/*
+ * Copyright (c) 2017 6WIND S.A.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ */
+
+#include <linux/netdevice.h>
+#include <linux/slab.h>
+#include <linux/etherdevice.h>
+#include <linux/u64_stats_sync.h>
+#include <linux/module.h>
+#include <linux/mpls.h>
+
+#include <net/rtnetlink.h>
+#include <net/dst.h>
+#include <net/mpls.h>
+#include <net/vpls.h>
+
+#define DRV_NAME		"vpls"
+#define DRV_VERSION		"0.1"
+#define VPLS_MAX_ID		256	/* Max VPLS WireID (arbitrary) */
+#define VPLS_DEFAULT_TTL	255	/* Max TTL */
+
+static struct rtnl_link_ops vpls_link_ops;
+
+union vpls_nh {
+	struct in6_addr		addr6;
+	struct in_addr		addr;
+};
+
+struct vpls_dst {
+	struct net_device	*dev;
+	union vpls_nh		addr;
+	u32			label_in, label_out;
+	u32			id;
+	u16			vlan_id;
+	u8			via_table;
+	u8			flags;
+	u8			ttl;
+};
+
+struct vpls_priv {
+	struct net		*encap_net;
+	struct vpls_dst		dst;
+};
+
+static struct nla_policy vpls_policy[IFLA_VPLS_MAX + 1] = {
+	[IFLA_VPLS_ID]		= { .type = NLA_U32 },
+	[IFLA_VPLS_IN_LABEL]	= { .type = NLA_U32 },
+	[IFLA_VPLS_OUT_LABEL]	= { .type = NLA_U32 },
+	[IFLA_VPLS_OIF]		= { .type = NLA_U32 },
+	[IFLA_VPLS_TTL]		= { .type = NLA_U8  },
+	[IFLA_VPLS_VLANID]	= { .type = NLA_U8 },
+	[IFLA_VPLS_NH]		= { .type = NLA_U32 },
+	[IFLA_VPLS_NH6]		= { .len = sizeof(struct in6_addr) },
+};
+
+static netdev_tx_t vpls_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct vpls_priv *priv = netdev_priv(dev);
+	struct vpls_dst *dst = &priv->dst;
+	struct pcpu_sw_netstats *stats;
+	unsigned int new_header_size;
+	struct net_device *out_dev;
+	struct mpls_shim_hdr *hdr;
+	int ret = NET_RX_DROP;
+	unsigned int hh_len;
+
+	out_dev = dst->dev;
+	skb_orphan(skb);
+	skb_forward_csum(skb);
+	stats = this_cpu_ptr(dev->tstats);
+
+	if (!mpls_output_possible(dst->dev) || skb_warn_if_lro(skb)) {
+		dev->stats.tx_errors++;
+		goto end;
+	}
+
+	new_header_size = 1 * sizeof(struct mpls_shim_hdr);
+
+	hh_len = LL_RESERVED_SPACE(out_dev);
+	if (!out_dev->header_ops)
+		hh_len = 0;
+
+	ret = skb_cow(skb, hh_len + new_header_size);
+	if (ret) {
+		dev->stats.tx_errors++;
+		goto end;
+	}
+
+	skb_push(skb, new_header_size);
+	skb_reset_network_header(skb);
+
+	skb->dev = out_dev;
+	skb->protocol = htons(ETH_P_MPLS_UC);
+
+	hdr = mpls_hdr(skb);
+	hdr[0] = mpls_entry_encode(dst->label_out, dst->ttl, 0, true);
+
+	if (dst->flags & VPLS_F_VLAN)
+		skb_vlan_push(skb, htons(ETH_P_8021Q), dst->vlan_id);
+
+	ret = neigh_xmit(dst->via_table, out_dev, &dst->addr, skb);
+	if (ret) {
+		net_dbg_ratelimited("%s: packet transmission failed: %d\n",
+				    __func__, ret);
+		dev->stats.tx_errors++;
+		goto end;
+	}
+
+	u64_stats_update_begin(&stats->syncp);
+	stats->tx_packets++;
+	stats->tx_bytes += skb->len;
+	u64_stats_update_end(&stats->syncp);
+end:
+	return ret;
+}
+
+static int vpls_rcv(void *arg, struct sk_buff *skb, struct net_device *in_dev,
+		    u32 label, u8 bos)
+{
+	struct pcpu_sw_netstats *stats;
+	struct net_device *dev;
+	struct vpls_priv *priv;
+	struct vpls_dst *dst;
+
+	dev = arg;
+	priv = netdev_priv(dev);
+	dst = &priv->dst;
+	stats = this_cpu_ptr(dev->tstats);
+
+	if (!bos) {
+		pr_info("%s: incoming BoS mismatch\n", dev->name);
+		goto drop;
+	}
+
+	if (!dst->dev && label != dst->label_in) {
+		pr_info("%s: incoming label %u mismatch\n", dev->name,
+			label);
+		goto drop;
+	}
+
+	if (unlikely(!pskb_may_pull(skb,
+				    ETH_HLEN + sizeof(struct mpls_shim_hdr))))
+		goto drop;
+
+	skb->dev = dev;
+	skb_reset_mac_header(skb);
+	skb_pull(skb, sizeof(struct mpls_shim_hdr));
+	skb->protocol = eth_type_trans(skb, dev);
+	skb->ip_summed = CHECKSUM_NONE;
+	skb->pkt_type = PACKET_HOST;
+	skb_clear_hash(skb);
+	skb->vlan_tci = 0;
+	skb_set_queue_mapping(skb, 0);
+	skb_scrub_packet(skb, !net_eq(dev_net(in_dev), dev_net(dev)));
+	skb_reset_network_header(skb);
+	skb_probe_transport_header(skb, 0);
+
+	if (netif_rx(skb) == NET_RX_SUCCESS) {
+		u64_stats_update_begin(&stats->syncp);
+		stats->rx_packets++;
+		stats->rx_bytes += skb->len;
+		u64_stats_update_end(&stats->syncp);
+
+		return NET_RX_SUCCESS;
+	}
+drop:
+	dev->stats.rx_errors++;
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+/* Stub, nothing needs to be done. */
+static void vpls_set_multicast_list(struct net_device *dev)
+{
+}
+
+static int vpls_open(struct net_device *dev)
+{
+	struct vpls_priv *priv = netdev_priv(dev);
+	struct vpls_dst *dst = &priv->dst;
+	int ret;
+
+	ret = mpls_handler_add(priv->encap_net, dst->label_in,
+			       dst->via_table, (u8 *)&dst->addr,
+			       vpls_rcv, dev, NULL);
+	/* A mpls route is added when creating the interface, so -EEXIST
+	 * is just a confirmation, don't return an error.
+	 */
+	if (ret == -EEXIST)
+		ret = 0;
+
+	netif_carrier_on(dev);
+
+	return ret;
+}
+
+static int vpls_close(struct net_device *dev)
+{
+	struct vpls_priv *priv = netdev_priv(dev);
+	struct vpls_dst *dst;
+	int ret;
+
+	dst = &priv->dst;
+	netif_carrier_off(dev);
+	ret = mpls_handler_del(priv->encap_net, dst->label_in, NULL);
+
+	return ret;
+}
+
+static void vpls_dev_get_stats64(struct net_device *dev,
+				 struct rtnl_link_stats64 *stats)
+{
+	u64 rx_packets, rx_bytes, tx_packets, tx_bytes;
+	const struct pcpu_sw_netstats *tstats;
+	u64 rx_errors = 0, tx_errors = 0;
+	unsigned int start;
+	int i;
+
+	if (!dev->tstats)
+		return;
+
+	for_each_possible_cpu(i) {
+		tstats = per_cpu_ptr(dev->tstats, i);
+		do {
+			start = u64_stats_fetch_begin_irq(&tstats->syncp);
+			rx_packets = tstats->rx_packets;
+			tx_packets = tstats->tx_packets;
+			rx_bytes = tstats->rx_bytes;
+			tx_bytes = tstats->tx_bytes;
+		} while (u64_stats_fetch_retry_irq(&tstats->syncp, start));
+
+		stats->rx_packets += rx_packets;
+		stats->tx_packets += tx_packets;
+		stats->rx_bytes += rx_bytes;
+		stats->tx_bytes	+= tx_bytes;
+
+		rx_errors += dev->stats.rx_errors;
+		tx_errors += dev->stats.tx_errors;
+	}
+
+	stats->rx_dropped = rx_errors;
+	stats->tx_dropped = tx_errors;
+	stats->rx_errors = rx_errors;
+	stats->tx_errors = tx_errors;
+}
+
+static int is_valid_vpls_mtu(int new_mtu)
+{
+	return new_mtu >= ETH_MIN_MTU && new_mtu <= ETH_MAX_MTU;
+}
+
+static int vpls_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if (!is_valid_vpls_mtu(new_mtu))
+		return -EINVAL;
+	dev->mtu = new_mtu;
+	return 0;
+}
+
+static int vpls_dev_init(struct net_device *dev)
+{
+	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
+	if (!dev->tstats)
+		return -ENOMEM;
+	return 0;
+}
+
+static const struct net_device_ops vpls_netdev_ops = {
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_features_check	= passthru_features_check,
+	.ndo_set_rx_mode	= vpls_set_multicast_list,
+	.ndo_get_stats64	= vpls_dev_get_stats64,
+	.ndo_start_xmit		= vpls_xmit,
+	.ndo_change_mtu		= vpls_change_mtu,
+	.ndo_init		= vpls_dev_init,
+	.ndo_open		= vpls_open,
+	.ndo_stop		= vpls_close,
+};
+
+#define VPLS_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | \
+		       NETIF_F_HW_CSUM | NETIF_F_RXCSUM | NETIF_F_HIGHDMA)
+
+static void vpls_setup(struct net_device *dev)
+{
+	ether_setup(dev);
+
+	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
+	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+	dev->priv_flags |= IFF_NO_QUEUE;
+
+	dev->netdev_ops = &vpls_netdev_ops;
+	dev->features |= NETIF_F_LLTX;
+	dev->features |= VPLS_FEATURES;
+	dev->vlan_features = dev->features;
+	dev->hw_features = VPLS_FEATURES;
+	dev->hw_enc_features = VPLS_FEATURES;
+
+	dev->needs_free_netdev = true;
+}
+
+static int vpls_validate(struct nlattr *tb[], struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
+{
+	if (tb[IFLA_ADDRESS]) {
+		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN) {
+			NL_SET_ERR_MSG(extack, "Invalid mac address length");
+			return -EINVAL;
+		}
+		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS]))) {
+			NL_SET_ERR_MSG(extack, "Invalid mac address");
+			return -EADDRNOTAVAIL;
+		}
+	}
+
+	if (tb[IFLA_MTU])
+		if (!is_valid_vpls_mtu(nla_get_u32(tb[IFLA_MTU]))) {
+			NL_SET_ERR_MSG(extack, "Invalid MTU");
+			return -EINVAL;
+		}
+
+	if (!data) {
+		NL_SET_ERR_MSG(extack, "No vpls data available");
+		return -EINVAL;
+	}
+
+	if (data[IFLA_VPLS_ID]) {
+		__u32 id = nla_get_u32(data[IFLA_VPLS_ID]);
+		if (id >= VPLS_MAX_ID) {
+			NL_SET_ERR_MSG(extack, "vpls id out of range");
+			return -ERANGE;
+		}
+	}
+
+	return 0;
+}
+
+static int vpls_dev_configure(struct net *net, struct net_device *dev,
+			      struct nlattr *tb[], struct nlattr *data[],
+			      bool changelink, struct netlink_ext_ack *extack)
+{
+	struct vpls_priv *priv = netdev_priv(dev);
+	struct vpls_dst *dst = &priv->dst;
+	struct net_device *outdev;
+	int ret;
+
+	if (!data[IFLA_VPLS_ID] || !data[IFLA_VPLS_OIF] ||
+	    !data[IFLA_VPLS_IN_LABEL] || !data[IFLA_VPLS_OUT_LABEL]) {
+		NL_SET_ERR_MSG(extack, "Missing essential arguments");
+		return -EINVAL;
+	}
+
+	if (!tb[IFLA_ADDRESS])
+		eth_hw_addr_random(dev);
+
+	if (tb[IFLA_IFNAME])
+		nla_strlcpy(dev->name, tb[IFLA_IFNAME], IFNAMSIZ);
+	else
+		snprintf(dev->name, IFNAMSIZ, DRV_NAME "%%d");
+
+	outdev = dev_get_by_index(net, nla_get_u32(data[IFLA_VPLS_OIF]));
+	if (!outdev) {
+		NL_SET_ERR_MSG(extack, "Invalid output device");
+		return -EINVAL;
+	}
+
+	priv->encap_net = get_net(net);
+	dst->id = nla_get_u32(data[IFLA_VPLS_ID]);
+	dst->label_in = nla_get_u32(data[IFLA_VPLS_IN_LABEL]);
+	dst->label_out = nla_get_u32(data[IFLA_VPLS_OUT_LABEL]);
+	dst->dev = outdev;
+
+	if (data[IFLA_VPLS_NH]) {
+		dst->addr.addr.s_addr = nla_get_in_addr(data[IFLA_VPLS_NH]);
+		dst->flags |= VPLS_F_INET;
+		dst->via_table = NEIGH_ARP_TABLE;
+	} else if (data[IFLA_VPLS_NH6]) {
+		if (!IS_ENABLED(CONFIG_IPV6)) {
+			NL_SET_ERR_MSG(extack, "IPv6 not enabled");
+			return -EPFNOSUPPORT;
+		}
+		dst->addr.addr6 = nla_get_in6_addr(data[IFLA_VPLS_NH6]);
+		dst->flags |= VPLS_F_INET6;
+		dst->via_table = NEIGH_ND_TABLE;
+	}
+
+	if (data[IFLA_VPLS_VLANID]) {
+		dst->vlan_id = nla_get_u16(data[IFLA_VPLS_VLANID]);
+		dst->flags |= VPLS_F_VLAN;
+	}
+
+	if (data[IFLA_VPLS_TTL])
+		dst->ttl = nla_get_u8(data[IFLA_VPLS_TTL]);
+	else
+		dst->ttl = VPLS_DEFAULT_TTL;
+
+	if (changelink) {
+		ret = mpls_handler_del(priv->encap_net, dst->label_in, extack);
+		if (ret)
+			return ret;
+	}
+
+	ret = mpls_handler_add(priv->encap_net, dst->label_in, dst->via_table,
+			       (u8 *)&dst->addr, vpls_rcv, dev, extack);
+	synchronize_rcu();
+
+	return ret;
+}
+
+static int vpls_newlink(struct net *src_net, struct net_device *dev,
+			struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
+{
+	int err;
+
+	err = vpls_dev_configure(src_net, dev, tb, data, 0, extack);
+	if (err < 0) {
+		NL_SET_ERR_MSG(extack, "Error while configuring VPLS device");
+		goto err;
+	}
+
+	err = register_netdevice(dev);
+	if (err < 0)
+		goto err;
+
+	netif_carrier_off(dev);
+	return 0;
+
+err:
+	return err;
+}
+
+static void vpls_dellink(struct net_device *dev, struct list_head *head)
+{
+	struct vpls_priv *priv = netdev_priv(dev);
+
+	mpls_handler_del(priv->encap_net, priv->dst.label_in, NULL);
+	unregister_netdevice_queue(dev, head);
+}
+
+static int vpls_changelink(struct net_device *dev, struct nlattr *tb[],
+			   struct nlattr *data[],
+			   struct netlink_ext_ack *extack)
+{
+	struct vpls_priv *priv = netdev_priv(dev);
+	struct net *net;
+	int err;
+
+	net = priv->encap_net;
+	err = vpls_dev_configure(net, dev, tb, data, 1, extack);
+	if (err)
+		NL_SET_ERR_MSG(extack, "Error while configuring VPLS device");
+
+	return err;
+}
+
+static int vpls_fill_info(struct sk_buff *skb, const struct net_device *dev)
+{
+	const struct vpls_priv *priv = netdev_priv(dev);
+	const struct vpls_dst *dst = &priv->dst;
+	struct net_device *out_dev = dst->dev;
+
+	if (nla_put_u32(skb, IFLA_VPLS_ID, dst->id) ||
+	    nla_put_u32(skb, IFLA_VPLS_IN_LABEL, dst->label_in) ||
+	    nla_put_u32(skb, IFLA_VPLS_OUT_LABEL, dst->label_out) ||
+	    nla_put_u32(skb, IFLA_VPLS_OIF, out_dev->ifindex))
+		goto nla_put_failure;
+
+	if (nla_put_u8(skb, IFLA_VPLS_TTL, dst->ttl))
+		goto nla_put_failure;
+
+	if (dst->flags & VPLS_F_VLAN)
+		if (nla_put_u16(skb, IFLA_VPLS_VLANID, dst->vlan_id))
+			goto nla_put_failure;
+
+	if (dst->flags & VPLS_F_INET) {
+		if (nla_put_in_addr(skb, IFLA_VPLS_NH,
+				    dst->addr.addr.s_addr))
+			goto nla_put_failure;
+#if IS_ENABLED(CONFIG_IPV6)
+	} else if (dst->flags & VPLS_F_INET6) {
+		if (nla_put_in6_addr(skb, IFLA_VPLS_NH6,
+				     &dst->addr.addr6))
+			goto nla_put_failure;
+#endif
+	}
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static struct rtnl_link_ops vpls_link_ops = {
+	.changelink	= vpls_changelink,
+	.priv_size	= sizeof(struct vpls_priv),
+	.fill_info	= vpls_fill_info,
+	.validate	= vpls_validate,
+	.dellink	= vpls_dellink,
+	.newlink	= vpls_newlink,
+	.maxtype	= IFLA_VPLS_MAX,
+	.policy		= vpls_policy,
+	.setup		= vpls_setup,
+	.kind		= DRV_NAME,
+};
+
+static __init int vpls_init(void)
+{
+	return rtnl_link_register(&vpls_link_ops);
+}
+
+static __exit void vpls_exit(void)
+{
+	rtnl_link_unregister(&vpls_link_ops);
+}
+
+module_init(vpls_init);
+module_exit(vpls_exit);
+
+MODULE_AUTHOR("Amine Kherbouche <amine.kherbouche@6wind.com>");
+MODULE_DESCRIPTION("Virtual Private LAN Service");
+MODULE_ALIAS_RTNL_LINK(DRV_NAME);
+MODULE_VERSION(DRV_VERSION);
+MODULE_LICENSE("GPL v2");
diff --git a/include/net/mpls.h b/include/net/mpls.h
index 0ff51b6..deb2be3 100644
--- a/include/net/mpls.h
+++ b/include/net/mpls.h
@@ -16,6 +16,8 @@
 
 #include <linux/if_ether.h>
 #include <linux/netdevice.h>
+#include <linux/kernel.h>
+#include <linux/mpls.h>
 
 #define MPLS_HLEN 4
 
@@ -34,6 +36,19 @@ static inline struct mpls_shim_hdr *mpls_hdr(const struct sk_buff *skb)
 	return (struct mpls_shim_hdr *)skb_network_header(skb);
 }
 
+static inline struct mpls_shim_hdr mpls_entry_encode(u32 label, u32 ttl,
+						     u32 tc, bool bos)
+{
+	struct mpls_shim_hdr result;
+	result.label_stack_entry =
+		cpu_to_be32((label << MPLS_LS_LABEL_SHIFT) |
+			    (tc << MPLS_LS_TC_SHIFT) |
+			    (bos ? (1 << MPLS_LS_S_SHIFT) : 0) |
+			    (ttl << MPLS_LS_TTL_SHIFT));
+	return result;
+}
+
+bool mpls_output_possible(const struct net_device *dev);
 typedef int (*mpls_handler)(void *arg, struct sk_buff *skb,
 			    struct net_device *dev, u32 index, u8 bos);
 
diff --git a/include/net/vpls.h b/include/net/vpls.h
new file mode 100644
index 0000000..f1111bc
--- /dev/null
+++ b/include/net/vpls.h
@@ -0,0 +1,21 @@
+/*
+ * Copyright (c) 2017 6WIND S.A.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ */
+
+#ifndef _VPLS_H
+#define _VPLS_H
+
+#define	VPLS_F_INET	0x01
+#define	VPLS_F_INET6	0x02
+#define	VPLS_F_VLAN	0x04
+
+#endif /* _VPLS_H */
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 8d062c5..3952c54 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -458,6 +458,21 @@ enum macsec_validation_type {
 	MACSEC_VALIDATE_MAX = __MACSEC_VALIDATE_END - 1,
 };
 
+/* VPLS section */
+enum {
+	IFLA_VPLS_UNSPEC,
+	IFLA_VPLS_ID,
+	IFLA_VPLS_IN_LABEL,
+	IFLA_VPLS_OUT_LABEL,
+	IFLA_VPLS_OIF,
+	IFLA_VPLS_TTL,
+	IFLA_VPLS_VLANID,
+	IFLA_VPLS_NH,
+	IFLA_VPLS_NH6,
+	__IFLA_VPLS_MAX
+};
+#define IFLA_VPLS_MAX	(__IFLA_VPLS_MAX - 1)
+
 /* IPVLAN section */
 enum {
 	IFLA_IPVLAN_UNSPEC,
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index 2cd73eb..64a48a5 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -174,17 +174,6 @@ struct mpls_route { /* next hop label forwarding entry */
 
 #define endfor_nexthops(rt) }
 
-static inline struct mpls_shim_hdr mpls_entry_encode(u32 label, unsigned ttl, unsigned tc, bool bos)
-{
-	struct mpls_shim_hdr result;
-	result.label_stack_entry =
-		cpu_to_be32((label << MPLS_LS_LABEL_SHIFT) |
-			    (tc << MPLS_LS_TC_SHIFT) |
-			    (bos ? (1 << MPLS_LS_S_SHIFT) : 0) |
-			    (ttl << MPLS_LS_TTL_SHIFT));
-	return result;
-}
-
 static inline struct mpls_entry_decoded mpls_entry_decode(struct mpls_shim_hdr *hdr)
 {
 	struct mpls_entry_decoded result;
@@ -207,7 +196,6 @@ int nla_put_labels(struct sk_buff *skb, int attrtype,  u8 labels,
 		   const u32 label[]);
 int nla_get_labels(const struct nlattr *nla, u8 max_labels, u8 *labels,
 		   u32 label[], struct netlink_ext_ack *extack);
-bool mpls_output_possible(const struct net_device *dev);
 unsigned int mpls_dev_mtu(const struct net_device *dev);
 bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu);
 void mpls_stats_inc_outucastpkts(struct net_device *dev,
-- 
2.1.4
