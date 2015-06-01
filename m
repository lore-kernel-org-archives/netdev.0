From: Thomas Graf <tgraf@suug.ch>
Subject: [net-next RFC 13/14] openvswitch: Use regular GRE net_device instead of vport
Date: Mon,  1 Jun 2015 16:27:37 +0200
Message-ID: <011371519a93dc4695d9afebfb9141e87221a7f2.1433167296.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Cc: pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, dev@openvswitch.org, tom@herbertland.com,
	edumazet@google.com, jiri@resnulli.us, hannes@stressinduktion.org,
	marcelo.leitner@gmail.com, stephen@networkplumber.org,
	jpettit@nicira.com, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51080 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752790AbbFAO14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 10:27:56 -0400
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>

Removes all of the OVS specific GRE code and makes OVS use a
GRE net_device .

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/core/dev.c                 |   5 +-
 net/ipv4/ip_gre.c              | 161 ++++++++++++++++++++-
 net/openvswitch/Makefile       |   1 -
 net/openvswitch/vport-gre.c    | 313 -----------------------------------------
 net/openvswitch/vport-netdev.c |   7 +-
 5 files changed, 168 insertions(+), 319 deletions(-)
 delete mode 100644 net/openvswitch/vport-gre.c

diff --git a/net/core/dev.c b/net/core/dev.c
index 594163d..656f3b4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6969,6 +6969,9 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	INIT_LIST_HEAD(&dev->ptype_all);
 	INIT_LIST_HEAD(&dev->ptype_specific);
 	dev->priv_flags = IFF_XMIT_DST_RELEASE | IFF_XMIT_DST_RELEASE_PERM;
+
+	strcpy(dev->name, name);
+	dev->name_assign_type = name_assign_type;
 	setup(dev);
 
 	dev->num_tx_queues = txqs;
@@ -6983,8 +6986,6 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 		goto free_all;
 #endif
 
-	strcpy(dev->name, name);
-	dev->name_assign_type = name_assign_type;
 	dev->group = INIT_NETDEV_GROUP;
 	if (!dev->ethtool_ops)
 		dev->ethtool_ops = &default_ethtool_ops;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 5fd7064..b37515e 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -25,6 +25,7 @@
 #include <linux/udp.h>
 #include <linux/if_arp.h>
 #include <linux/mroute.h>
+#include <linux/if_vlan.h>
 #include <linux/init.h>
 #include <linux/in6.h>
 #include <linux/inetdevice.h>
@@ -115,6 +116,8 @@ static bool log_ecn_error = true;
 module_param(log_ecn_error, bool, 0644);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
+#define GRE_TAP_FB_NAME "gretap0"
+
 static struct rtnl_link_ops ipgre_link_ops __read_mostly;
 static int ipgre_tunnel_init(struct net_device *dev);
 
@@ -217,7 +220,17 @@ static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
 				  iph->saddr, iph->daddr, tpi->key);
 
 	if (tunnel) {
+
 		skb_pop_mac_header(skb);
+		if (tunnel->dev == itn->fb_tunnel_dev) {
+			struct ip_tunnel_info *tun_info;
+
+			tun_info = ip_tunnel_info_alloc(0, GFP_ATOMIC);
+
+			/* TODO: setup tun info from tpi */
+			skb_attach_tunnel_info(skb, tun_info);
+		}
+
 		ip_tunnel_rcv(tunnel, skb, tpi, log_ecn_error);
 		return PACKET_RCVD;
 	}
@@ -287,6 +300,135 @@ out:
 	return NETDEV_TX_OK;
 }
 
+/* TODO: share xmit code */
+static inline struct rtable *tunnel_route_lookup(struct net *net,
+						     const struct ip_tunnel_key *key,
+						     u32 mark,
+						     struct flowi4 *fl,
+						     u8 protocol)
+{
+	struct rtable *rt;
+
+	memset(fl, 0, sizeof(*fl));
+	fl->daddr = key->ipv4_dst;
+	fl->saddr = key->ipv4_src;
+	fl->flowi4_tos = RT_TOS(key->ipv4_tos);
+	fl->flowi4_mark = mark;
+	fl->flowi4_proto = protocol;
+
+	rt = ip_route_output_key(net, fl);
+	return rt;
+}
+
+
+/* Returns the least-significant 32 bits of a __be64. */
+static __be32 be64_get_low32(__be64 x)
+{
+#ifdef __BIG_ENDIAN
+	return (__force __be32)x;
+#else
+	return (__force __be32)((__force u64)x >> 32);
+#endif
+}
+
+static __be16 filter_tnl_flags(__be16 flags)
+{
+	return flags & (TUNNEL_CSUM | TUNNEL_KEY);
+}
+
+
+static struct sk_buff *__build_header(struct sk_buff *skb,
+				      const struct ip_tunnel_info *tun_info,
+				      int tunnel_hlen)
+{
+	struct tnl_ptk_info tpi;
+
+	skb = gre_handle_offloads(skb, !!(tun_info->key.tun_flags & TUNNEL_CSUM));
+	if (IS_ERR(skb))
+		return skb;
+
+	tpi.flags = filter_tnl_flags(tun_info->key.tun_flags);
+	tpi.proto = htons(ETH_P_TEB);
+	tpi.key = be64_get_low32(tun_info->key.tun_id);
+	tpi.seq = 0;
+	gre_build_header(skb, &tpi, tunnel_hlen);
+
+	return skb;
+}
+
+static netdev_tx_t gre_fb_xmit(struct sk_buff *skb,
+				struct net_device *dev)
+{
+	struct net *net = dev_net(dev);
+	struct ip_tunnel_info *tun_info;
+	const struct ip_tunnel_key *key;
+	struct flowi4 fl;
+	struct rtable *rt;
+	int min_headroom;
+	int tunnel_hlen;
+	__be16 df;
+	int err;
+
+	tun_info = skb_shinfo(skb)->tun_info;
+	if (unlikely(!tun_info)) {
+		err = -EINVAL;
+		goto err_free_skb;
+	}
+
+	key = &tun_info->key;
+
+	rt = tunnel_route_lookup(net, key, skb->mark, &fl, IPPROTO_GRE);
+	if (IS_ERR(rt)) {
+		err = PTR_ERR(rt);
+		goto err_free_skb;
+	}
+
+	tunnel_hlen = ip_gre_calc_hlen(key->tun_flags);
+
+	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
+			+ tunnel_hlen + sizeof(struct iphdr)
+			+ (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
+	if (skb_headroom(skb) < min_headroom || skb_header_cloned(skb)) {
+		int head_delta = SKB_DATA_ALIGN(min_headroom -
+						skb_headroom(skb) +
+						16);
+		err = pskb_expand_head(skb, max_t(int, head_delta, 0),
+					0, GFP_ATOMIC);
+		if (unlikely(err))
+			goto err_free_rt;
+	}
+
+	skb = vlan_hwaccel_push_inside(skb);
+	if (unlikely(!skb)) {
+		err = -ENOMEM;
+		goto err_free_rt;
+	}
+
+	/* Push Tunnel header. */
+	skb = __build_header(skb, tun_info, tunnel_hlen);
+	if (IS_ERR(skb)) {
+		err = PTR_ERR(skb);
+		skb = NULL;
+		goto err_free_rt;
+	}
+
+	df = key->tun_flags & TUNNEL_DONT_FRAGMENT ?  htons(IP_DF) : 0;
+
+	skb->ignore_df = 1;
+
+	err = iptunnel_xmit(skb->sk, rt, skb, fl.saddr,
+			     key->ipv4_dst, IPPROTO_GRE,
+			     key->ipv4_tos, key->ipv4_ttl, df, false);
+	skb_release_tunnel_info(skb);
+	return err;
+
+err_free_rt:
+	ip_rt_put(rt);
+err_free_skb:
+	kfree_skb(skb);
+	return err;
+}
+
 static netdev_tx_t gre_tap_xmit(struct sk_buff *skb,
 				struct net_device *dev)
 {
@@ -690,12 +832,27 @@ static const struct net_device_ops gre_tap_netdev_ops = {
 	.ndo_get_iflink		= ip_tunnel_get_iflink,
 };
 
+static const struct net_device_ops gre_fb_netdev_ops = {
+	.ndo_init		= gre_tap_init,
+	.ndo_uninit		= ip_tunnel_uninit,
+	.ndo_start_xmit		= gre_fb_xmit,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= ip_tunnel_change_mtu,
+	.ndo_get_stats64	= ip_tunnel_get_stats64,
+	.ndo_get_iflink		= ip_tunnel_get_iflink,
+};
+
 static void ipgre_tap_setup(struct net_device *dev)
 {
 	ether_setup(dev);
-	dev->netdev_ops		= &gre_tap_netdev_ops;
 	dev->priv_flags 	|= IFF_LIVE_ADDR_CHANGE;
 	ip_tunnel_setup(dev, gre_tap_net_id);
+
+	if (!strcmp(dev->name, GRE_TAP_FB_NAME))
+		dev->netdev_ops		= &gre_fb_netdev_ops;
+	else
+		dev->netdev_ops		= &gre_tap_netdev_ops;
 }
 
 static int ipgre_newlink(struct net *src_net, struct net_device *dev,
@@ -851,7 +1008,7 @@ static struct rtnl_link_ops ipgre_tap_ops __read_mostly = {
 
 static int __net_init ipgre_tap_init_net(struct net *net)
 {
-	return ip_tunnel_init_net(net, gre_tap_net_id, &ipgre_tap_ops, NULL);
+	return ip_tunnel_init_net(net, gre_tap_net_id, &ipgre_tap_ops, GRE_TAP_FB_NAME);
 }
 
 static void __net_exit ipgre_tap_exit_net(struct net *net)
diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
index 38e0e14..7153c6e 100644
--- a/net/openvswitch/Makefile
+++ b/net/openvswitch/Makefile
@@ -16,4 +16,3 @@ openvswitch-y := \
 	vport-netdev.o
 
 obj-$(CONFIG_OPENVSWITCH_GENEVE)+= vport-geneve.o
-obj-$(CONFIG_OPENVSWITCH_GRE)	+= vport-gre.o
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
deleted file mode 100644
index b87656c..0000000
--- a/net/openvswitch/vport-gre.c
+++ /dev/null
@@ -1,313 +0,0 @@
-/*
- * Copyright (c) 2007-2014 Nicira, Inc.
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of version 2 of the GNU General Public
- * License as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
- * General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
- */
-
-#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
-
-#include <linux/if.h>
-#include <linux/skbuff.h>
-#include <linux/ip.h>
-#include <linux/if_tunnel.h>
-#include <linux/if_vlan.h>
-#include <linux/in.h>
-#include <linux/in_route.h>
-#include <linux/inetdevice.h>
-#include <linux/jhash.h>
-#include <linux/list.h>
-#include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/workqueue.h>
-#include <linux/rculist.h>
-#include <net/route.h>
-#include <net/xfrm.h>
-
-#include <net/icmp.h>
-#include <net/ip.h>
-#include <net/ip_tunnels.h>
-#include <net/gre.h>
-#include <net/net_namespace.h>
-#include <net/netns/generic.h>
-#include <net/protocol.h>
-
-#include "datapath.h"
-#include "vport.h"
-
-static struct vport_ops ovs_gre_vport_ops;
-
-/* Returns the least-significant 32 bits of a __be64. */
-static __be32 be64_get_low32(__be64 x)
-{
-#ifdef __BIG_ENDIAN
-	return (__force __be32)x;
-#else
-	return (__force __be32)((__force u64)x >> 32);
-#endif
-}
-
-static __be16 filter_tnl_flags(__be16 flags)
-{
-	return flags & (TUNNEL_CSUM | TUNNEL_KEY);
-}
-
-static struct sk_buff *__build_header(struct sk_buff *skb,
-				      int tunnel_hlen)
-{
-	struct tnl_ptk_info tpi;
-	const struct ip_tunnel_key *tun_key;
-
-	tun_key = &OVS_CB(skb)->egress_tun_info->key;
-
-	skb = gre_handle_offloads(skb, !!(tun_key->tun_flags & TUNNEL_CSUM));
-	if (IS_ERR(skb))
-		return skb;
-
-	tpi.flags = filter_tnl_flags(tun_key->tun_flags);
-	tpi.proto = htons(ETH_P_TEB);
-	tpi.key = be64_get_low32(tun_key->tun_id);
-	tpi.seq = 0;
-	gre_build_header(skb, &tpi, tunnel_hlen);
-
-	return skb;
-}
-
-static __be64 key_to_tunnel_id(__be32 key, __be32 seq)
-{
-#ifdef __BIG_ENDIAN
-	return (__force __be64)((__force u64)seq << 32 | (__force u32)key);
-#else
-	return (__force __be64)((__force u64)key << 32 | (__force u32)seq);
-#endif
-}
-
-/* Called with rcu_read_lock and BH disabled. */
-static int gre_rcv(struct sk_buff *skb,
-		   const struct tnl_ptk_info *tpi)
-{
-	struct ip_tunnel_info tun_info;
-	struct ovs_net *ovs_net;
-	struct vport *vport;
-	__be64 key;
-
-	ovs_net = net_generic(dev_net(skb->dev), ovs_net_id);
-	vport = rcu_dereference(ovs_net->vport_net.gre_vport);
-	if (unlikely(!vport))
-		return PACKET_REJECT;
-
-	key = key_to_tunnel_id(tpi->key, tpi->seq);
-	ip_tunnel_info_init(&tun_info, ip_hdr(skb), 0, 0, key,
-			    filter_tnl_flags(tpi->flags), NULL, 0);
-
-	ovs_vport_receive(vport, skb, &tun_info);
-	return PACKET_RCVD;
-}
-
-/* Called with rcu_read_lock and BH disabled. */
-static int gre_err(struct sk_buff *skb, u32 info,
-		   const struct tnl_ptk_info *tpi)
-{
-	struct ovs_net *ovs_net;
-	struct vport *vport;
-
-	ovs_net = net_generic(dev_net(skb->dev), ovs_net_id);
-	vport = rcu_dereference(ovs_net->vport_net.gre_vport);
-
-	if (unlikely(!vport))
-		return PACKET_REJECT;
-	else
-		return PACKET_RCVD;
-}
-
-static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
-{
-	struct net *net = ovs_dp_get_net(vport->dp);
-	const struct ip_tunnel_key *tun_key;
-	struct flowi4 fl;
-	struct rtable *rt;
-	int min_headroom;
-	int tunnel_hlen;
-	__be16 df;
-	int err;
-
-	if (unlikely(!OVS_CB(skb)->egress_tun_info)) {
-		err = -EINVAL;
-		goto err_free_skb;
-	}
-
-	tun_key = &OVS_CB(skb)->egress_tun_info->key;
-	rt = ovs_tunnel_route_lookup(net, tun_key, skb->mark, &fl, IPPROTO_GRE);
-	if (IS_ERR(rt)) {
-		err = PTR_ERR(rt);
-		goto err_free_skb;
-	}
-
-	tunnel_hlen = ip_gre_calc_hlen(tun_key->tun_flags);
-
-	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
-			+ tunnel_hlen + sizeof(struct iphdr)
-			+ (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
-	if (skb_headroom(skb) < min_headroom || skb_header_cloned(skb)) {
-		int head_delta = SKB_DATA_ALIGN(min_headroom -
-						skb_headroom(skb) +
-						16);
-		err = pskb_expand_head(skb, max_t(int, head_delta, 0),
-					0, GFP_ATOMIC);
-		if (unlikely(err))
-			goto err_free_rt;
-	}
-
-	skb = vlan_hwaccel_push_inside(skb);
-	if (unlikely(!skb)) {
-		err = -ENOMEM;
-		goto err_free_rt;
-	}
-
-	/* Push Tunnel header. */
-	skb = __build_header(skb, tunnel_hlen);
-	if (IS_ERR(skb)) {
-		err = PTR_ERR(skb);
-		skb = NULL;
-		goto err_free_rt;
-	}
-
-	df = tun_key->tun_flags & TUNNEL_DONT_FRAGMENT ?
-		htons(IP_DF) : 0;
-
-	skb->ignore_df = 1;
-
-	return iptunnel_xmit(skb->sk, rt, skb, fl.saddr,
-			     tun_key->ipv4_dst, IPPROTO_GRE,
-			     tun_key->ipv4_tos, tun_key->ipv4_ttl, df, false);
-err_free_rt:
-	ip_rt_put(rt);
-err_free_skb:
-	kfree_skb(skb);
-	return err;
-}
-
-static struct gre_cisco_protocol gre_protocol = {
-	.handler        = gre_rcv,
-	.err_handler    = gre_err,
-	.priority       = 1,
-};
-
-static int gre_ports;
-static int gre_init(void)
-{
-	int err;
-
-	gre_ports++;
-	if (gre_ports > 1)
-		return 0;
-
-	err = gre_cisco_register(&gre_protocol);
-	if (err)
-		pr_warn("cannot register gre protocol handler\n");
-
-	return err;
-}
-
-static void gre_exit(void)
-{
-	gre_ports--;
-	if (gre_ports > 0)
-		return;
-
-	gre_cisco_unregister(&gre_protocol);
-}
-
-static const char *gre_get_name(const struct vport *vport)
-{
-	return vport_priv(vport);
-}
-
-static struct vport *gre_create(const struct vport_parms *parms)
-{
-	struct net *net = ovs_dp_get_net(parms->dp);
-	struct ovs_net *ovs_net;
-	struct vport *vport;
-	int err;
-
-	err = gre_init();
-	if (err)
-		return ERR_PTR(err);
-
-	ovs_net = net_generic(net, ovs_net_id);
-	if (ovsl_dereference(ovs_net->vport_net.gre_vport)) {
-		vport = ERR_PTR(-EEXIST);
-		goto error;
-	}
-
-	vport = ovs_vport_alloc(IFNAMSIZ, &ovs_gre_vport_ops, parms);
-	if (IS_ERR(vport))
-		goto error;
-
-	strncpy(vport_priv(vport), parms->name, IFNAMSIZ);
-	rcu_assign_pointer(ovs_net->vport_net.gre_vport, vport);
-	return vport;
-
-error:
-	gre_exit();
-	return vport;
-}
-
-static void gre_tnl_destroy(struct vport *vport)
-{
-	struct net *net = ovs_dp_get_net(vport->dp);
-	struct ovs_net *ovs_net;
-
-	ovs_net = net_generic(net, ovs_net_id);
-
-	RCU_INIT_POINTER(ovs_net->vport_net.gre_vport, NULL);
-	ovs_vport_deferred_free(vport);
-	gre_exit();
-}
-
-static int gre_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
-				   struct ip_tunnel_info *egress_tun_info)
-{
-	return ovs_tunnel_get_egress_info(egress_tun_info,
-					  ovs_dp_get_net(vport->dp),
-					  OVS_CB(skb)->egress_tun_info,
-					  IPPROTO_GRE, skb->mark, 0, 0);
-}
-
-static struct vport_ops ovs_gre_vport_ops = {
-	.type		= OVS_VPORT_TYPE_GRE,
-	.create		= gre_create,
-	.destroy	= gre_tnl_destroy,
-	.get_name	= gre_get_name,
-	.send		= gre_tnl_send,
-	.get_egress_tun_info	= gre_get_egress_tun_info,
-	.owner		= THIS_MODULE,
-};
-
-static int __init ovs_gre_tnl_init(void)
-{
-	return ovs_vport_ops_register(&ovs_gre_vport_ops);
-}
-
-static void __exit ovs_gre_tnl_exit(void)
-{
-	ovs_vport_ops_unregister(&ovs_gre_vport_ops);
-}
-
-module_init(ovs_gre_tnl_init);
-module_exit(ovs_gre_tnl_exit);
-
-MODULE_DESCRIPTION("OVS: GRE switching port");
-MODULE_LICENSE("GPL");
-MODULE_ALIAS("vport-type-3");
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 77703ee..a8b4360 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -43,6 +43,8 @@ static struct vport_ops ovs_netdev_vport_ops;
 /* Must be called with rcu_read_lock. */
 static void netdev_port_receive(struct vport *vport, struct sk_buff *skb)
 {
+	struct ip_tunnel_info *tun_info;
+
 	if (unlikely(!vport))
 		goto error;
 
@@ -59,7 +61,10 @@ static void netdev_port_receive(struct vport *vport, struct sk_buff *skb)
 	skb_push(skb, ETH_HLEN);
 	ovs_skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
 
-	ovs_vport_receive(vport, skb, NULL);
+	tun_info = skb_shinfo(skb)->tun_info;
+	skb_shinfo(skb)->tun_info = NULL;
+	ovs_vport_receive(vport, skb, tun_info);
+	ip_tunnel_info_put(tun_info);
 	return;
 
 error:
-- 
2.3.5
