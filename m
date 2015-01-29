From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 6/6] net: Add STT device.
Date: Thu, 29 Jan 2015 15:29:49 -0800
Message-ID: <1422574189-2005-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:38362 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752664AbbA2X3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 18:29:52 -0500
Received: by mail-pa0-f50.google.com with SMTP id rd3so44394871pab.9
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 15:29:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch adds STT device driver so that user can create
standalone STT device without Open vSwitch.  I have provided netlink
interface to manage STT device from userspace.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/uapi/linux/if_tunnel.h |  17 ++
 net/ipv4/Kconfig               |   9 +
 net/ipv4/Makefile              |   1 +
 net/ipv4/ip_stt.c              | 410 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 437 insertions(+)
 create mode 100644 net/ipv4/ip_stt.c

diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index bd3cc11..1d4e799 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -131,4 +131,21 @@ enum {
 };
 
 #define IFLA_VTI_MAX	(__IFLA_VTI_MAX - 1)
+
+enum {
+	IFLA_STT_UNSPEC,
+	IFLA_STT_LINK,
+	IFLA_STT_LOCAL,
+	IFLA_STT_REMOTE,
+	IFLA_STT_TTL,
+	IFLA_STT_TOS,
+	IFLA_STT_DF,
+	IFLA_STT_IKEY,
+	IFLA_STT_OKEY,
+	IFLA_STT_DST_PORT,
+	__IFLA_STT_MAX,
+};
+#define IFLA_STT_MAX	(__IFLA_STT_MAX - 1)
+
+
 #endif /* _UAPI_IF_TUNNEL_H_ */
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 3ab00be..f1044fb 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -356,6 +356,15 @@ config STT
 
 	  To compile this driver as a module, choose M here: the module
 
+config IP_STT
+	tristate "STT device"
+	depends on STT
+	---help---
+	This allows one to create STT device that provide Layer 2 Networks
+	over Layer 3 (IPv4) Networks.
+
+	  To compile this driver as a module, choose M here: the module
+
 config INET_AH
 	tristate "IP: AH transformation"
 	select XFRM_ALGO
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index d504fde..313ef86 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -58,6 +58,7 @@ obj-$(CONFIG_MEMCG_KMEM) += tcp_memcontrol.o
 obj-$(CONFIG_NETLABEL) += cipso_ipv4.o
 obj-$(CONFIG_GENEVE) += geneve.o
 obj-$(CONFIG_STT) += stt.o
+obj-$(CONFIG_IP_STT) += ip_stt.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o xfrm4_protocol.o
diff --git a/net/ipv4/ip_stt.c b/net/ipv4/ip_stt.c
new file mode 100644
index 0000000..882a333
--- /dev/null
+++ b/net/ipv4/ip_stt.c
@@ -0,0 +1,410 @@
+/*
+ * Stateless TCP Tunnel (STT) device.
+ *
+ * Copyright (c) 2015 Nicira, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <asm/unaligned.h>
+
+#include <linux/delay.h>
+#include <linux/flex_array.h>
+#include <linux/if.h>
+#include <linux/if_vlan.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/jhash.h>
+#include <linux/list.h>
+#include <linux/log2.h>
+#include <linux/module.h>
+#include <linux/netfilter.h>
+#include <linux/percpu.h>
+#include <linux/skbuff.h>
+#include <linux/tcp.h>
+#include <linux/workqueue.h>
+
+#include <net/icmp.h>
+#include <net/inet_ecn.h>
+#include <net/ip.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+#include <net/sock.h>
+#include <net/stt.h>
+#include <net/tcp.h>
+#include <net/udp.h>
+
+static bool log_ecn_error = true;
+module_param(log_ecn_error, bool, 0644);
+MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
+
+static int stt_net_id __read_mostly;
+
+static int stt_tunnel_init(struct net_device *dev);
+static struct rtnl_link_ops stt_link_ops __read_mostly;
+
+static void stt_rcv(struct stt_sock *stt_sock, struct sk_buff *skb)
+{
+	struct net *net = dev_net(skb->dev);
+	struct ip_tunnel_net *itn = net_generic(net, stt_net_id);
+	struct ip_tunnel *tunnel;
+	struct tnl_ptk_info tpi;
+	const struct iphdr *iph;
+	struct stthdr *stth;
+	struct sk_buff *next;
+
+	iph = ip_hdr(skb);
+	stth = stt_hdr(skb);
+	tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex, 0,
+				  iph->saddr, iph->daddr, tcp_hdr(skb)->dest,
+				  get_unaligned(&stth->key));
+	if (!tunnel)
+		goto error;
+
+	tpi.proto = htons(ETH_P_TEB);
+	tpi.key = get_unaligned(&stth->key);
+	tpi.flags = TUNNEL_KEY;
+	tpi.seq = 0;
+	do {
+		next = skb->next;
+		skb->next = NULL;
+		ip_tunnel_rcv(tunnel, skb, &tpi, log_ecn_error);
+	} while ((skb = next));
+error:
+	kfree_skb_list(skb);
+}
+
+static netdev_tx_t stt_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct tunnel_info *info = &tunnel->info;
+	struct net *net = dev_net(skb->dev);
+	const struct iphdr *inner_iph;
+	bool connected = true;
+	struct rtable *rt;
+	__u8 ttl, tos;
+	__be32 saddr;
+	__be16 df, sport;
+	int err;
+
+	inner_iph = (const struct iphdr *)skb_network_header(skb);
+	/* Calculate ToS */
+	tos = info->tos;
+	if (tos & 0x1) {
+		tos &= ~0x1;
+		if (skb->protocol == htons(ETH_P_IP)) {
+			tos = inner_iph->tos;
+			connected = false;
+#if IS_ENABLED(CONFIG_IPV6)
+		} else if (skb->protocol == htons(ETH_P_IPV6)) {
+			tos = ipv6_get_dsfield((const struct ipv6hdr *)inner_iph);
+			connected = false;
+		}
+#endif
+	}
+
+	/* Calculate saddr */
+	saddr = info->saddr;
+	rt = connected ? tunnel_rtable_get(tunnel, 0, &saddr) : NULL;
+	if (!rt) {
+		struct flowi4 fl;
+
+		memset(&fl, 0, sizeof(fl));
+		fl.daddr = info->daddr;
+		fl.saddr = info->saddr;
+		fl.flowi4_tos = RT_TOS(tos);
+		fl.flowi4_mark = skb->mark;
+		fl.flowi4_proto = IPPROTO_TCP;
+
+		rt = ip_route_output_key(net, &fl);
+		if (IS_ERR(rt)) {
+			err = PTR_ERR(rt);
+			goto error;
+		}
+		if (connected)
+			tunnel_dst_set(tunnel, &rt->dst, fl.saddr);
+		saddr = fl.saddr;
+	}
+
+	/* Calculate src-port */
+	sport = udp_flow_src_port(net, skb, 1, USHRT_MAX, true);
+	skb->ignore_df = 1;
+
+	/* Calculate ttl */
+	ttl = info->ttl;
+	if (ttl == 0) {
+		if (skb->protocol == htons(ETH_P_IP))
+			ttl = inner_iph->ttl;
+#if IS_ENABLED(CONFIG_IPV6)
+		else if (skb->protocol == htons(ETH_P_IPV6))
+			ttl = ((const struct ipv6hdr *)inner_iph)->hop_limit;
+#endif
+		else
+			ttl = ip4_dst_hoplimit(&rt->dst);
+	}
+
+	/* Calculate df */
+	df = info->df;
+	if (skb->protocol == htons(ETH_P_IP))
+		df |= (inner_iph->frag_off&htons(IP_DF));
+
+	tos = ip_tunnel_ecn_encap(tos, inner_iph, skb);
+	err = stt_xmit_skb(skb, rt, saddr, info->daddr, tos, ttl, df,
+			   sport, info->portno, info->o_key);
+
+	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
+	return NETDEV_TX_OK;
+error:
+	kfree_skb(skb);
+	return NETDEV_TX_OK;
+}
+
+static const struct net_device_ops stt_netdev_ops = {
+	.ndo_init       = stt_tunnel_init,
+	.ndo_uninit     = ip_tunnel_uninit,
+	.ndo_start_xmit	= stt_tunnel_xmit,
+	.ndo_change_mtu = ip_tunnel_change_mtu,
+	.ndo_get_stats64 = ip_tunnel_get_stats64,
+};
+
+#define STT_DST_PORT 7471
+
+static int stt_tunnel_init(struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	int t_hlen;
+
+	tunnel->info.portno = htons(STT_DST_PORT);
+	memcpy(dev->dev_addr, &tunnel->info.saddr, 4);
+	memcpy(dev->broadcast, &tunnel->info.daddr, 4);
+
+	tunnel->tun_hlen = STT_HEADER_LEN;
+	tunnel->hlen = tunnel->tun_hlen;
+	t_hlen = tunnel->hlen + sizeof(struct iphdr);
+
+	dev->needed_headroom	= LL_MAX_HEADER + t_hlen;
+	dev->mtu		= ETH_DATA_LEN - t_hlen;
+
+	return ip_tunnel_init(dev);
+}
+
+#define STT_FEATURES (NETIF_F_SG |		\
+		       NETIF_F_FRAGLIST |	\
+		       NETIF_F_HIGHDMA |	\
+		       NETIF_F_GSO_SOFTWARE |	\
+		       NETIF_F_HW_CSUM)
+
+static void stt_tunnel_setup(struct net_device *dev)
+{
+	ether_setup(dev);
+	dev->netdev_ops		= &stt_netdev_ops;
+	dev->priv_flags		|= IFF_LIVE_ADDR_CHANGE;
+
+	dev->features		|= STT_FEATURES;
+	dev->hw_features	|= STT_FEATURES;
+	ip_tunnel_setup(dev, stt_net_id);
+}
+
+static void stt_netlink_parms(struct nlattr *data[],
+			      struct tunnel_info *info)
+{
+	memset(info, 0, sizeof(*info));
+
+	info->protocol = IPPROTO_TCP;
+
+	if (!data)
+		return;
+
+	if (data[IFLA_STT_LINK])
+		info->link = nla_get_u32(data[IFLA_STT_LINK]);
+
+	if (data[IFLA_STT_LOCAL])
+		info->saddr = nla_get_be32(data[IFLA_STT_LOCAL]);
+
+	if (data[IFLA_STT_REMOTE])
+		info->daddr = nla_get_be32(data[IFLA_STT_REMOTE]);
+
+	if (data[IFLA_STT_TTL]) {
+		info->ttl = nla_get_u8(data[IFLA_STT_TTL]);
+		if (info->ttl)
+			info->df = htons(IP_DF);
+	}
+
+	if (data[IFLA_STT_TOS])
+		info->tos = nla_get_u8(data[IFLA_STT_TOS]);
+
+	if (data[IFLA_STT_DF])
+		info->df = htons(IP_DF);
+
+	if (data[IFLA_STT_IKEY])
+		info->i_key = nla_get_u64(data[IFLA_STT_IKEY]);
+
+	if (data[IFLA_STT_OKEY])
+		info->o_key = nla_get_u64(data[IFLA_STT_OKEY]);
+
+	if (data[IFLA_STT_DST_PORT])
+		info->portno = htons(nla_get_u16(data[IFLA_STT_DST_PORT]));
+}
+
+static int stt_newlink(struct net *src_net, struct net_device *dev,
+		       struct nlattr *tb[], struct nlattr *data[])
+{
+	struct net *net = dev_net(dev);
+	struct tunnel_info info;
+	struct stt_sock *stt_sock;
+
+	stt_netlink_parms(data, &info);
+
+	stt_sock = stt_sock_add(net, info.portno, stt_rcv, NULL);
+	if (IS_ERR(stt_sock))
+		return PTR_ERR(stt_sock);
+
+	return ip_tunnel_newlink(dev, tb, &info);
+}
+
+static int stt_changelink(struct net_device *dev, struct nlattr *tb[],
+			  struct nlattr *data[])
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct tunnel_info info;
+
+	stt_netlink_parms(data, &info);
+
+	if (info.portno != tunnel->info.portno)
+		return -EINVAL;
+
+	return ip_tunnel_changelink(dev, tb, &info);
+}
+
+static size_t stt_get_size(const struct net_device *dev)
+{
+	return
+		/* IFLA_STT_LINK */
+		nla_total_size(4) +
+		/* IFLA_STT_LOCAL */
+		nla_total_size(4) +
+		/* IFLA_STT_REMOTE */
+		nla_total_size(4) +
+		/* IFLA_STT_TTL */
+		nla_total_size(1) +
+		/* IFLA_STT_TOS */
+		nla_total_size(1) +
+		/* IFLA_STT_DF */
+		nla_total_size(1) +
+		/* IFLA_STT_IKEY */
+		nla_total_size(8) +
+		/* IFLA_STT_OKEY */
+		nla_total_size(8);
+}
+
+static int stt_fill_info(struct sk_buff *skb, const struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct tunnel_info *info = &tunnel->info;
+
+	if (nla_put_u32(skb, IFLA_STT_LINK, info->link) ||
+	    nla_put_be32(skb, IFLA_STT_LOCAL, info->saddr) ||
+	    nla_put_be32(skb, IFLA_STT_REMOTE, info->daddr) ||
+	    nla_put_u8(skb, IFLA_STT_TTL, info->ttl) ||
+	    nla_put_u8(skb, IFLA_STT_TOS, info->tos) ||
+	    nla_put_u64(skb, IFLA_STT_DST_PORT, ntohs(info->portno)) ||
+	    nla_put_u64(skb, IFLA_STT_IKEY, info->i_key) ||
+	    nla_put_u64(skb, IFLA_STT_OKEY, info->o_key))
+		goto nla_put_failure;
+
+	if (info->df & htons(IP_DF) &&
+	    nla_put_flag(skb, IFLA_STT_DF))
+		goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static const struct nla_policy stt_policy[IFLA_STT_MAX + 1] = {
+	[IFLA_STT_LINK]		= { .type = NLA_U32 },
+	[IFLA_STT_LOCAL]	= { .type = NLA_U32 },
+	[IFLA_STT_REMOTE]	= { .type = NLA_U32 },
+	[IFLA_STT_TTL]		= { .type = NLA_U8 },
+	[IFLA_STT_TOS]		= { .type = NLA_U8 },
+	[IFLA_STT_DF]		= { .type = NLA_FLAG },
+	[IFLA_STT_IKEY]		= { .type = NLA_U64 },
+	[IFLA_STT_OKEY]		= { .type = NLA_U64 },
+	[IFLA_STT_DST_PORT]	= { .type = NLA_U16 },
+};
+
+void stt_dellink(struct net_device *dev, struct list_head *head)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct tunnel_info *info = &tunnel->info;
+	struct net *net = dev_net(dev);
+
+	stt_sock_release(net, info->portno);
+	ip_tunnel_dellink(dev, head);
+}
+
+static struct rtnl_link_ops stt_link_ops __read_mostly = {
+	.kind		= "stt",
+	.maxtype	= IFLA_STT_MAX,
+	.policy		= stt_policy,
+	.priv_size	= sizeof(struct ip_tunnel),
+	.setup		= stt_tunnel_setup,
+	.newlink	= stt_newlink,
+	.changelink	= stt_changelink,
+	.dellink	= stt_dellink,
+	.get_size	= stt_get_size,
+	.fill_info	= stt_fill_info,
+	.get_link_net	= ip_tunnel_get_link_net,
+};
+
+static int __net_init stt_init_net(struct net *net)
+{
+	return ip_tunnel_init_net(net, stt_net_id, &stt_link_ops, NULL);
+}
+
+static void __net_exit stt_exit_net(struct net *net)
+{
+	struct ip_tunnel_net *itn = net_generic(net, stt_net_id);
+
+	ip_tunnel_delete_net(itn, &stt_link_ops);
+}
+
+static struct pernet_operations stt_net_ops = {
+	.init = stt_init_net,
+	.exit = stt_exit_net,
+	.id   = &stt_net_id,
+	.size = sizeof(struct ip_tunnel_net),
+};
+
+static int __init stt_init(void)
+{
+	int err;
+
+	err = register_pernet_device(&stt_net_ops);
+	if (err < 0)
+		return err;
+	err = rtnl_link_register(&stt_link_ops);
+	if (err < 0)
+		goto error;
+
+	return 0;
+
+error:
+	unregister_pernet_device(&stt_net_ops);
+	return err;
+}
+
+static void __exit stt_fini(void)
+{
+	rtnl_link_unregister(&stt_link_ops);
+	unregister_pernet_device(&stt_net_ops);
+}
+
+module_init(stt_init);
+module_exit(stt_fini);
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_RTNL_LINK("stt");
+MODULE_ALIAS_NETDEV("stt0");
-- 
1.9.1
