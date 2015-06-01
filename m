From: Thomas Graf <tgraf@suug.ch>
Subject: [net-next RFC 11/14] openvswitch: Use regular VXLAN net_device device
Date: Mon,  1 Jun 2015 16:27:35 +0200
Message-ID: <09736f6c310b1ac762c3c36e83737fae18f0441a.1433167296.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Cc: pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, dev@openvswitch.org, tom@herbertland.com,
	edumazet@google.com, jiri@resnulli.us, hannes@stressinduktion.org,
	marcelo.leitner@gmail.com, stephen@networkplumber.org,
	jpettit@nicira.com, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51056 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752660AbbFAO1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 10:27:54 -0400
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This gets rid of all OVS specific VXLAN code in the receive and
transmit path by using a VXLAN net_device to represent the vport.
Only a small shim layer remains which takes care of handling the
VXLAN specific OVS Netlink configuration.

Unexports vxlan_sock_add(), vxlan_sock_release(), vxlan_xmit_skb()
since they are no longer needed.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c            |  23 +--
 include/net/vxlan.h            |  14 +-
 net/openvswitch/Kconfig        |  12 --
 net/openvswitch/Makefile       |   1 -
 net/openvswitch/flow_netlink.c |   5 +-
 net/openvswitch/vport-netdev.c | 176 +++++++++++++++++++++-
 net/openvswitch/vport-vxlan.c  | 322 -----------------------------------------
 7 files changed, 193 insertions(+), 360 deletions(-)
 delete mode 100644 net/openvswitch/vport-vxlan.c

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 3acab95..b696871 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -74,6 +74,10 @@ static struct rtnl_link_ops vxlan_link_ops;
 
 static const u8 all_zeros_mac[ETH_ALEN];
 
+static struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
+					 vxlan_rcv_t *rcv, void *data,
+					 bool no_share, u32 flags);
+
 /* per-network namespace private data for this module */
 struct vxlan_net {
 	struct list_head  vxlan_list;
@@ -1020,7 +1024,7 @@ static bool vxlan_group_used(struct vxlan_net *vn, struct vxlan_dev *dev)
 	return false;
 }
 
-void vxlan_sock_release(struct vxlan_sock *vs)
+static void vxlan_sock_release(struct vxlan_sock *vs)
 {
 	struct sock *sk = vs->sock->sk;
 	struct net *net = sock_net(sk);
@@ -1036,7 +1040,6 @@ void vxlan_sock_release(struct vxlan_sock *vs)
 
 	queue_work(vxlan_wq, &vs->del_work);
 }
-EXPORT_SYMBOL_GPL(vxlan_sock_release);
 
 /* Update multicast group membership when first VNI on
  * multicast address is brought up
@@ -1761,10 +1764,10 @@ err:
 }
 #endif
 
-int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
-		   __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
-		   __be16 src_port, __be16 dst_port,
-		   struct vxlan_metadata *md, bool xnet, u32 vxflags)
+static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
+			  __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
+			  __be16 src_port, __be16 dst_port,
+			  struct vxlan_metadata *md, bool xnet, u32 vxflags)
 {
 	struct vxlanhdr *vxh;
 	int min_headroom;
@@ -1834,7 +1837,6 @@ int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
 				   ttl, df, src_port, dst_port, xnet,
 				   !(vxflags & VXLAN_F_UDP_CSUM));
 }
-EXPORT_SYMBOL_GPL(vxlan_xmit_skb);
 
 /* Bypass encapsulation if the destination is local */
 static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
@@ -2609,9 +2611,9 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 	return vs;
 }
 
-struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
-				  vxlan_rcv_t *rcv, void *data,
-				  bool no_share, u32 flags)
+static struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
+					 vxlan_rcv_t *rcv, void *data,
+					 bool no_share, u32 flags)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
@@ -2632,7 +2634,6 @@ struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 
 	return vxlan_socket_create(net, port, rcv, data, flags);
 }
-EXPORT_SYMBOL_GPL(vxlan_sock_add);
 
 static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 			       struct vxlan_config *conf)
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index c037b27..d3ce81f 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -197,19 +197,13 @@ struct vxlan_dev {
 					 VXLAN_F_REMCSUM_NOPARTIAL |	\
 					 VXLAN_F_FLOW_BASED)
 
-struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
-				  vxlan_rcv_t *rcv, void *data,
-				  bool no_share, u32 flags);
-
 struct net_device *vxlan_dev_create(struct net *net, const char *name,
 				    u8 name_assign_type, struct vxlan_config *conf);
 
-void vxlan_sock_release(struct vxlan_sock *vs);
-
-int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
-		   __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
-		   __be16 src_port, __be16 dst_port, struct vxlan_metadata *md,
-		   bool xnet, u32 vxflags);
+static inline __be16 vxlan_dev_dst_port(struct vxlan_dev *vxlan)
+{
+	return inet_sk(vxlan->vn_sock->sock->sk)->inet_sport;
+}
 
 static inline netdev_features_t vxlan_features_check(struct sk_buff *skb,
 						     netdev_features_t features)
diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index 1584040..1119f46 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -44,18 +44,6 @@ config OPENVSWITCH_GRE
 
 	  If unsure, say Y.
 
-config OPENVSWITCH_VXLAN
-	tristate "Open vSwitch VXLAN tunneling support"
-	depends on OPENVSWITCH
-	depends on VXLAN
-	default OPENVSWITCH
-	---help---
-	  If you say Y here, then the Open vSwitch will be able create vxlan vport.
-
-	  Say N to exclude this support and reduce the binary size.
-
-	  If unsure, say Y.
-
 config OPENVSWITCH_GENEVE
 	tristate "Open vSwitch Geneve tunneling support"
 	depends on OPENVSWITCH
diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
index 91b9478..38e0e14 100644
--- a/net/openvswitch/Makefile
+++ b/net/openvswitch/Makefile
@@ -16,5 +16,4 @@ openvswitch-y := \
 	vport-netdev.o
 
 obj-$(CONFIG_OPENVSWITCH_GENEVE)+= vport-geneve.o
-obj-$(CONFIG_OPENVSWITCH_VXLAN)	+= vport-vxlan.o
 obj-$(CONFIG_OPENVSWITCH_GRE)	+= vport-gre.o
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 35086c6..f43ce04 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -47,6 +47,7 @@
 #include <net/ipv6.h>
 #include <net/ndisc.h>
 #include <net/mpls.h>
+#include <net/vxlan.h>
 
 #include "flow_netlink.h"
 #include "vport-vxlan.h"
@@ -475,7 +476,7 @@ static int vxlan_tun_opt_from_nlattr(const struct nlattr *a,
 {
 	struct nlattr *tb[OVS_VXLAN_EXT_MAX+1];
 	unsigned long opt_key_offset;
-	struct ovs_vxlan_opts opts;
+	struct vxlan_metadata opts;
 	int err;
 
 	BUILD_BUG_ON(sizeof(opts) > sizeof(match->key->tun_opts));
@@ -626,7 +627,7 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 static int vxlan_opt_to_nlattr(struct sk_buff *skb,
 			       const void *tun_opts, int swkey_tun_opts_len)
 {
-	const struct ovs_vxlan_opts *opts = tun_opts;
+	const struct vxlan_metadata *opts = tun_opts;
 	struct nlattr *nla;
 
 	nla = nla_nest_start(skb, OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS);
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index ef11a41..77703ee 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -27,9 +27,14 @@
 #include <linux/skbuff.h>
 #include <linux/openvswitch.h>
 
-#include <net/llc.h>
+#include <net/udp.h>
+#include <net/ip_tunnels.h>
+#include <net/rtnetlink.h>
+#include <net/vxlan.h>
 
 #include "datapath.h"
+#include "vport.h"
+#include "vport-vxlan.h"
 #include "vport-internal_dev.h"
 #include "vport-netdev.h"
 
@@ -220,12 +225,179 @@ static struct vport_ops ovs_netdev_vport_ops = {
 	.send		= netdev_send,
 };
 
+/* Compat code for old userspace. */
+#if IS_ENABLED(CONFIG_VXLAN)
+static struct vport_ops ovs_vxlan_netdev_vport_ops;
+
+static int vxlan_get_options(const struct vport *vport, struct sk_buff *skb)
+{
+	struct vxlan_dev *vxlan = netdev_priv(vport->dev);
+	__be16 dst_port = vxlan->cfg.dst_port;
+
+	if (nla_put_u16(skb, OVS_TUNNEL_ATTR_DST_PORT, ntohs(dst_port)))
+		return -EMSGSIZE;
+
+	if (vxlan->flags & VXLAN_F_GBP) {
+		struct nlattr *exts;
+
+		exts = nla_nest_start(skb, OVS_TUNNEL_ATTR_EXTENSION);
+		if (!exts)
+			return -EMSGSIZE;
+
+		if (vxlan->flags & VXLAN_F_GBP &&
+		    nla_put_flag(skb, OVS_VXLAN_EXT_GBP))
+			return -EMSGSIZE;
+
+		nla_nest_end(skb, exts);
+	}
+
+	return 0;
+}
+
+static const struct nla_policy exts_policy[OVS_VXLAN_EXT_MAX + 1] = {
+	[OVS_VXLAN_EXT_GBP]	= { .type = NLA_FLAG, },
+};
+
+static int vxlan_configure_exts(struct vport *vport, struct nlattr *attr,
+				struct vxlan_config *conf)
+{
+	struct nlattr *exts[OVS_VXLAN_EXT_MAX + 1];
+	int err;
+
+	if (nla_len(attr) < sizeof(struct nlattr))
+		return -EINVAL;
+
+	err = nla_parse_nested(exts, OVS_VXLAN_EXT_MAX, attr, exts_policy);
+	if (err < 0)
+		return err;
+
+	if (exts[OVS_VXLAN_EXT_GBP])
+		conf->flags |= VXLAN_F_GBP;
+
+	return 0;
+}
+
+static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
+{
+	struct net *net = ovs_dp_get_net(parms->dp);
+	struct nlattr *options = parms->options;
+	struct vport *vport;
+	struct nlattr *a;
+	int err;
+	struct vxlan_config conf = {
+		.no_share = true,
+		.flags = VXLAN_F_FLOW_BASED,
+	};
+
+	if (!options) {
+		err = -EINVAL;
+		goto error;
+	}
+
+	a = nla_find_nested(options, OVS_TUNNEL_ATTR_DST_PORT);
+	if (a && nla_len(a) == sizeof(u16)) {
+		conf.dst_port = htons(nla_get_u16(a));
+	} else {
+		/* Require destination port from userspace. */
+		err = -EINVAL;
+		goto error;
+	}
+
+	vport = ovs_vport_alloc(0, &ovs_vxlan_netdev_vport_ops, parms);
+	if (IS_ERR(vport))
+		return vport;
+
+	a = nla_find_nested(options, OVS_TUNNEL_ATTR_EXTENSION);
+	if (a) {
+		err = vxlan_configure_exts(vport, a, &conf);
+		if (err) {
+			ovs_vport_free(vport);
+			goto error;
+		}
+	}
+
+	rtnl_lock();
+	vxlan_dev_create(net, parms->name, NET_NAME_USER, &conf);
+	rtnl_unlock();
+	return vport;
+error:
+	return ERR_PTR(err);
+}
+
+static struct vport *vxlan_create(const struct vport_parms *parms)
+{
+	struct vport *vport;
+
+	vport = vxlan_tnl_create(parms);
+	if (IS_ERR(vport))
+		return vport;
+
+	return netdev_link(vport, parms->name);
+}
+
+static int vxlan_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
+				     struct ip_tunnel_info *egress_tun_info)
+{
+	struct vxlan_dev *vxlan = netdev_priv(vport->dev);
+	struct net *net = ovs_dp_get_net(vport->dp);
+	__be16 dst_port = vxlan_dev_dst_port(vxlan);
+	__be16 src_port;
+	int port_min;
+	int port_max;
+
+	inet_get_local_port_range(net, &port_min, &port_max);
+	src_port = udp_flow_src_port(net, skb, 0, 0, true);
+
+	return ovs_tunnel_get_egress_info(egress_tun_info, net,
+					  OVS_CB(skb)->egress_tun_info,
+					  IPPROTO_UDP, skb->mark,
+					  src_port, dst_port);
+}
+
+static struct vport_ops ovs_vxlan_netdev_vport_ops = {
+	.type		= OVS_VPORT_TYPE_VXLAN,
+	.create		= vxlan_create,
+	.destroy	= netdev_destroy,
+	.get_options	= vxlan_get_options,
+	.send		= netdev_send,
+	.get_egress_tun_info	= vxlan_get_egress_tun_info,
+};
+
+static int vxlan_campat_init(void)
+{
+	return ovs_vport_ops_register(&ovs_vxlan_netdev_vport_ops);
+}
+
+static void vxlan_campat_exit(void)
+{
+	ovs_vport_ops_unregister(&ovs_vxlan_netdev_vport_ops);
+}
+#else
+static int vxlan_campat_init(void)
+{
+	return 0;
+}
+
+static void vxlan_campat_exit(void)
+{
+}
+#endif
+
 int __init ovs_netdev_init(void)
 {
-	return ovs_vport_ops_register(&ovs_netdev_vport_ops);
+	int err;
+
+	err = ovs_vport_ops_register(&ovs_netdev_vport_ops);
+	if (err)
+		return err;
+	err = vxlan_campat_init();
+	if (err)
+		vxlan_campat_exit();
+	return err;
 }
 
 void ovs_netdev_exit(void)
 {
 	ovs_vport_ops_unregister(&ovs_netdev_vport_ops);
+	vxlan_campat_exit();
 }
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
deleted file mode 100644
index 6f7986f..0000000
--- a/net/openvswitch/vport-vxlan.c
+++ /dev/null
@@ -1,322 +0,0 @@
-/*
- * Copyright (c) 2014 Nicira, Inc.
- * Copyright (c) 2013 Cisco Systems, Inc.
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
-#include <linux/in.h>
-#include <linux/ip.h>
-#include <linux/net.h>
-#include <linux/rculist.h>
-#include <linux/udp.h>
-#include <linux/module.h>
-
-#include <net/icmp.h>
-#include <net/ip.h>
-#include <net/udp.h>
-#include <net/ip_tunnels.h>
-#include <net/rtnetlink.h>
-#include <net/route.h>
-#include <net/dsfield.h>
-#include <net/inet_ecn.h>
-#include <net/net_namespace.h>
-#include <net/netns/generic.h>
-#include <net/vxlan.h>
-
-#include "datapath.h"
-#include "vport.h"
-#include "vport-vxlan.h"
-
-/**
- * struct vxlan_port - Keeps track of open UDP ports
- * @vs: vxlan_sock created for the port.
- * @name: vport name.
- */
-struct vxlan_port {
-	struct vxlan_sock *vs;
-	char name[IFNAMSIZ];
-	u32 exts; /* VXLAN_F_* in <net/vxlan.h> */
-};
-
-static struct vport_ops ovs_vxlan_vport_ops;
-
-static inline struct vxlan_port *vxlan_vport(const struct vport *vport)
-{
-	return vport_priv(vport);
-}
-
-/* Called with rcu_read_lock and BH disabled. */
-static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
-		      struct vxlan_metadata *md)
-{
-	struct ip_tunnel_info tun_info;
-	struct vxlan_port *vxlan_port;
-	struct vport *vport = vs->data;
-	struct iphdr *iph;
-	struct ovs_vxlan_opts opts = {
-		.gbp = md->gbp,
-	};
-	__be64 key;
-	__be16 flags;
-
-	flags = TUNNEL_KEY | (udp_hdr(skb)->check != 0 ? TUNNEL_CSUM : 0);
-	vxlan_port = vxlan_vport(vport);
-	if (vxlan_port->exts & VXLAN_F_GBP && md->gbp)
-		flags |= TUNNEL_VXLAN_OPT;
-
-	/* Save outer tunnel values */
-	iph = ip_hdr(skb);
-	key = cpu_to_be64(ntohl(md->vni) >> 8);
-	ip_tunnel_info_init(&tun_info, iph,
-			    udp_hdr(skb)->source, udp_hdr(skb)->dest,
-			    key, flags, &opts, sizeof(opts));
-
-	ovs_vport_receive(vport, skb, &tun_info);
-}
-
-static int vxlan_get_options(const struct vport *vport, struct sk_buff *skb)
-{
-	struct vxlan_port *vxlan_port = vxlan_vport(vport);
-	__be16 dst_port = inet_sk(vxlan_port->vs->sock->sk)->inet_sport;
-
-	if (nla_put_u16(skb, OVS_TUNNEL_ATTR_DST_PORT, ntohs(dst_port)))
-		return -EMSGSIZE;
-
-	if (vxlan_port->exts) {
-		struct nlattr *exts;
-
-		exts = nla_nest_start(skb, OVS_TUNNEL_ATTR_EXTENSION);
-		if (!exts)
-			return -EMSGSIZE;
-
-		if (vxlan_port->exts & VXLAN_F_GBP &&
-		    nla_put_flag(skb, OVS_VXLAN_EXT_GBP))
-			return -EMSGSIZE;
-
-		nla_nest_end(skb, exts);
-	}
-
-	return 0;
-}
-
-static void vxlan_tnl_destroy(struct vport *vport)
-{
-	struct vxlan_port *vxlan_port = vxlan_vport(vport);
-
-	vxlan_sock_release(vxlan_port->vs);
-
-	ovs_vport_deferred_free(vport);
-}
-
-static const struct nla_policy exts_policy[OVS_VXLAN_EXT_MAX+1] = {
-	[OVS_VXLAN_EXT_GBP]	= { .type = NLA_FLAG, },
-};
-
-static int vxlan_configure_exts(struct vport *vport, struct nlattr *attr)
-{
-	struct nlattr *exts[OVS_VXLAN_EXT_MAX+1];
-	struct vxlan_port *vxlan_port;
-	int err;
-
-	if (nla_len(attr) < sizeof(struct nlattr))
-		return -EINVAL;
-
-	err = nla_parse_nested(exts, OVS_VXLAN_EXT_MAX, attr, exts_policy);
-	if (err < 0)
-		return err;
-
-	vxlan_port = vxlan_vport(vport);
-
-	if (exts[OVS_VXLAN_EXT_GBP])
-		vxlan_port->exts |= VXLAN_F_GBP;
-
-	return 0;
-}
-
-static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
-{
-	struct net *net = ovs_dp_get_net(parms->dp);
-	struct nlattr *options = parms->options;
-	struct vxlan_port *vxlan_port;
-	struct vxlan_sock *vs;
-	struct vport *vport;
-	struct nlattr *a;
-	u16 dst_port;
-	int err;
-
-	if (!options) {
-		err = -EINVAL;
-		goto error;
-	}
-	a = nla_find_nested(options, OVS_TUNNEL_ATTR_DST_PORT);
-	if (a && nla_len(a) == sizeof(u16)) {
-		dst_port = nla_get_u16(a);
-	} else {
-		/* Require destination port from userspace. */
-		err = -EINVAL;
-		goto error;
-	}
-
-	vport = ovs_vport_alloc(sizeof(struct vxlan_port),
-				&ovs_vxlan_vport_ops, parms);
-	if (IS_ERR(vport))
-		return vport;
-
-	vxlan_port = vxlan_vport(vport);
-	strncpy(vxlan_port->name, parms->name, IFNAMSIZ);
-
-	a = nla_find_nested(options, OVS_TUNNEL_ATTR_EXTENSION);
-	if (a) {
-		err = vxlan_configure_exts(vport, a);
-		if (err) {
-			ovs_vport_free(vport);
-			goto error;
-		}
-	}
-
-	vs = vxlan_sock_add(net, htons(dst_port), vxlan_rcv, vport, true,
-			    vxlan_port->exts);
-	if (IS_ERR(vs)) {
-		ovs_vport_free(vport);
-		return (void *)vs;
-	}
-	vxlan_port->vs = vs;
-
-	return vport;
-
-error:
-	return ERR_PTR(err);
-}
-
-static int vxlan_ext_gbp(struct sk_buff *skb)
-{
-	const struct ip_tunnel_info *tun_info;
-	const struct ovs_vxlan_opts *opts;
-
-	tun_info = OVS_CB(skb)->egress_tun_info;
-	opts = tun_info->options;
-
-	if (tun_info->key.tun_flags & TUNNEL_VXLAN_OPT &&
-	    tun_info->options_len >= sizeof(*opts))
-		return opts->gbp;
-	else
-		return 0;
-}
-
-static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
-{
-	struct net *net = ovs_dp_get_net(vport->dp);
-	struct vxlan_port *vxlan_port = vxlan_vport(vport);
-	struct sock *sk = vxlan_port->vs->sock->sk;
-	__be16 dst_port = inet_sk(sk)->inet_sport;
-	const struct ip_tunnel_key *tun_key;
-	struct vxlan_metadata md = {0};
-	struct rtable *rt;
-	struct flowi4 fl;
-	__be16 src_port;
-	__be16 df;
-	int err;
-	u32 vxflags;
-
-	if (unlikely(!OVS_CB(skb)->egress_tun_info)) {
-		err = -EINVAL;
-		goto error;
-	}
-
-	tun_key = &OVS_CB(skb)->egress_tun_info->key;
-	rt = ovs_tunnel_route_lookup(net, tun_key, skb->mark, &fl, IPPROTO_UDP);
-	if (IS_ERR(rt)) {
-		err = PTR_ERR(rt);
-		goto error;
-	}
-
-	df = tun_key->tun_flags & TUNNEL_DONT_FRAGMENT ?
-		htons(IP_DF) : 0;
-
-	skb->ignore_df = 1;
-
-	src_port = udp_flow_src_port(net, skb, 0, 0, true);
-	md.vni = htonl(be64_to_cpu(tun_key->tun_id) << 8);
-	md.gbp = vxlan_ext_gbp(skb);
-	vxflags = vxlan_port->exts |
-		      (tun_key->tun_flags & TUNNEL_CSUM ? VXLAN_F_UDP_CSUM : 0);
-
-	err = vxlan_xmit_skb(rt, sk, skb, fl.saddr, tun_key->ipv4_dst,
-			     tun_key->ipv4_tos, tun_key->ipv4_ttl, df,
-			     src_port, dst_port,
-			     &md, false, vxflags);
-	if (err < 0)
-		ip_rt_put(rt);
-	return err;
-error:
-	kfree_skb(skb);
-	return err;
-}
-
-static int vxlan_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
-				     struct ip_tunnel_info *egress_tun_info)
-{
-	struct net *net = ovs_dp_get_net(vport->dp);
-	struct vxlan_port *vxlan_port = vxlan_vport(vport);
-	__be16 dst_port = inet_sk(vxlan_port->vs->sock->sk)->inet_sport;
-	__be16 src_port;
-	int port_min;
-	int port_max;
-
-	inet_get_local_port_range(net, &port_min, &port_max);
-	src_port = udp_flow_src_port(net, skb, 0, 0, true);
-
-	return ovs_tunnel_get_egress_info(egress_tun_info, net,
-					  OVS_CB(skb)->egress_tun_info,
-					  IPPROTO_UDP, skb->mark,
-					  src_port, dst_port);
-}
-
-static const char *vxlan_get_name(const struct vport *vport)
-{
-	struct vxlan_port *vxlan_port = vxlan_vport(vport);
-	return vxlan_port->name;
-}
-
-static struct vport_ops ovs_vxlan_vport_ops = {
-	.type		= OVS_VPORT_TYPE_VXLAN,
-	.create		= vxlan_tnl_create,
-	.destroy	= vxlan_tnl_destroy,
-	.get_name	= vxlan_get_name,
-	.get_options	= vxlan_get_options,
-	.send		= vxlan_tnl_send,
-	.get_egress_tun_info	= vxlan_get_egress_tun_info,
-	.owner		= THIS_MODULE,
-};
-
-static int __init ovs_vxlan_tnl_init(void)
-{
-	return ovs_vport_ops_register(&ovs_vxlan_vport_ops);
-}
-
-static void __exit ovs_vxlan_tnl_exit(void)
-{
-	ovs_vport_ops_unregister(&ovs_vxlan_vport_ops);
-}
-
-module_init(ovs_vxlan_tnl_init);
-module_exit(ovs_vxlan_tnl_exit);
-
-MODULE_DESCRIPTION("OVS: VXLAN switching port");
-MODULE_LICENSE("GPL");
-MODULE_ALIAS("vport-type-4");
-- 
2.3.5
