From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] openvswitch: Re-add CONFIG_OPENVSWITCH_VXLAN
Date: Wed, 29 Jul 2015 13:52:06 +0200
Message-ID: <bd6d90197964df7c1b8e52ba5d30e9f703355366.1438169322.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Pravin B Shelar <pshelar@nicira.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49394 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbbG2LwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 07:52:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This readds the config option CONFIG_OPENVSWITCH_VXLAN to avoid a
hard dependency of OVS on VXLAN. It moves the VXLAN config compat
code to vport-vxlan.c and allows compliation as a module.

Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device")
Fixes: 2661371ace96 ("openvswitch: fix compilation when vxlan is a module")
Cc: Pravin B Shelar <pshelar@nicira.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/openvswitch/Kconfig        |  13 ++-
 net/openvswitch/Makefile       |   1 +
 net/openvswitch/vport-netdev.c | 211 +++--------------------------------------
 net/openvswitch/vport-netdev.h |   3 +
 net/openvswitch/vport-vxlan.c  | 207 ++++++++++++++++++++++++++++++++++++++++
 5 files changed, 235 insertions(+), 200 deletions(-)
 create mode 100644 net/openvswitch/vport-vxlan.c

diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index 6ed1d2d..1584040 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -5,7 +5,6 @@
 config OPENVSWITCH
 	tristate "Open vSwitch"
 	depends on INET
-	depends on VXLAN
 	select LIBCRC32C
 	select MPLS
 	select NET_MPLS_GSO
@@ -45,6 +44,18 @@ config OPENVSWITCH_GRE
 
 	  If unsure, say Y.
 
+config OPENVSWITCH_VXLAN
+	tristate "Open vSwitch VXLAN tunneling support"
+	depends on OPENVSWITCH
+	depends on VXLAN
+	default OPENVSWITCH
+	---help---
+	  If you say Y here, then the Open vSwitch will be able create vxlan vport.
+
+	  Say N to exclude this support and reduce the binary size.
+
+	  If unsure, say Y.
+
 config OPENVSWITCH_GENEVE
 	tristate "Open vSwitch Geneve tunneling support"
 	depends on OPENVSWITCH
diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
index 38e0e14..6e1701d 100644
--- a/net/openvswitch/Makefile
+++ b/net/openvswitch/Makefile
@@ -15,5 +15,6 @@ openvswitch-y := \
 	vport-internal_dev.o \
 	vport-netdev.o
 
+obj-$(CONFIG_OPENVSWITCH_VXLAN)+= vport-vxlan.o
 obj-$(CONFIG_OPENVSWITCH_GENEVE)+= vport-geneve.o
 obj-$(CONFIG_OPENVSWITCH_GRE)	+= vport-gre.o
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 2254b74..cddb706 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -26,11 +26,10 @@
 #include <linux/rtnetlink.h>
 #include <linux/skbuff.h>
 #include <linux/openvswitch.h>
+#include <linux/export.h>
 
-#include <net/udp.h>
 #include <net/ip_tunnels.h>
 #include <net/rtnetlink.h>
-#include <net/vxlan.h>
 
 #include "datapath.h"
 #include "vport.h"
@@ -90,7 +89,7 @@ static struct net_device *get_dpdev(const struct datapath *dp)
 	return local->dev;
 }
 
-static struct vport *netdev_link(struct vport *vport, const char *name)
+struct vport *ovs_netdev_link(struct vport *vport, const char *name)
 {
 	int err;
 
@@ -135,6 +134,7 @@ error_free_vport:
 	ovs_vport_free(vport);
 	return ERR_PTR(err);
 }
+EXPORT_SYMBOL_GPL(ovs_netdev_link);
 
 static struct vport *netdev_create(const struct vport_parms *parms)
 {
@@ -144,10 +144,10 @@ static struct vport *netdev_create(const struct vport_parms *parms)
 	if (IS_ERR(vport))
 		return vport;
 
-	return netdev_link(vport, parms->name);
+	return ovs_netdev_link(vport, parms->name);
 }
 
-static void free_port_rcu(struct rcu_head *rcu)
+void ovs_vport_free_rcu(struct rcu_head *rcu)
 {
 	struct vport *vport = container_of(rcu, struct vport, rcu);
 
@@ -155,6 +155,7 @@ static void free_port_rcu(struct rcu_head *rcu)
 		dev_put(vport->dev);
 	ovs_vport_free(vport);
 }
+EXPORT_SYMBOL_GPL(ovs_vport_free_rcu);
 
 void ovs_netdev_detach_dev(struct vport *vport)
 {
@@ -165,6 +166,7 @@ void ovs_netdev_detach_dev(struct vport *vport)
 				netdev_master_upper_dev_get(vport->dev));
 	dev_set_promiscuity(vport->dev, -1);
 }
+EXPORT_SYMBOL_GPL(ovs_netdev_detach_dev);
 
 static void netdev_destroy(struct vport *vport)
 {
@@ -173,7 +175,7 @@ static void netdev_destroy(struct vport *vport)
 		ovs_netdev_detach_dev(vport);
 	rtnl_unlock();
 
-	call_rcu(&vport->rcu, free_port_rcu);
+	call_rcu(&vport->rcu, ovs_vport_free_rcu);
 }
 
 static unsigned int packet_length(const struct sk_buff *skb)
@@ -186,7 +188,7 @@ static unsigned int packet_length(const struct sk_buff *skb)
 	return length;
 }
 
-static int netdev_send(struct vport *vport, struct sk_buff *skb)
+int ovs_netdev_send(struct vport *vport, struct sk_buff *skb)
 {
 	int mtu = vport->dev->mtu;
 	int len;
@@ -208,6 +210,7 @@ drop:
 	kfree_skb(skb);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(ovs_netdev_send);
 
 /* Returns null if this device is not attached to a datapath. */
 struct vport *ovs_netdev_get_vport(struct net_device *dev)
@@ -223,205 +226,15 @@ static struct vport_ops ovs_netdev_vport_ops = {
 	.type		= OVS_VPORT_TYPE_NETDEV,
 	.create		= netdev_create,
 	.destroy	= netdev_destroy,
-	.send		= netdev_send,
+	.send		= ovs_netdev_send,
 };
 
-/* Compat code for old userspace. */
-#if IS_ENABLED(CONFIG_VXLAN)
-static struct vport_ops ovs_vxlan_netdev_vport_ops;
-
-static int vxlan_get_options(const struct vport *vport, struct sk_buff *skb)
-{
-	struct vxlan_dev *vxlan = netdev_priv(vport->dev);
-	__be16 dst_port = vxlan->cfg.dst_port;
-
-	if (nla_put_u16(skb, OVS_TUNNEL_ATTR_DST_PORT, ntohs(dst_port)))
-		return -EMSGSIZE;
-
-	if (vxlan->flags & VXLAN_F_GBP) {
-		struct nlattr *exts;
-
-		exts = nla_nest_start(skb, OVS_TUNNEL_ATTR_EXTENSION);
-		if (!exts)
-			return -EMSGSIZE;
-
-		if (vxlan->flags & VXLAN_F_GBP &&
-		    nla_put_flag(skb, OVS_VXLAN_EXT_GBP))
-			return -EMSGSIZE;
-
-		nla_nest_end(skb, exts);
-	}
-
-	return 0;
-}
-
-static const struct nla_policy exts_policy[OVS_VXLAN_EXT_MAX + 1] = {
-	[OVS_VXLAN_EXT_GBP]	= { .type = NLA_FLAG, },
-};
-
-static int vxlan_configure_exts(struct vport *vport, struct nlattr *attr,
-				struct vxlan_config *conf)
-{
-	struct nlattr *exts[OVS_VXLAN_EXT_MAX + 1];
-	int err;
-
-	if (nla_len(attr) < sizeof(struct nlattr))
-		return -EINVAL;
-
-	err = nla_parse_nested(exts, OVS_VXLAN_EXT_MAX, attr, exts_policy);
-	if (err < 0)
-		return err;
-
-	if (exts[OVS_VXLAN_EXT_GBP])
-		conf->flags |= VXLAN_F_GBP;
-
-	return 0;
-}
-
-static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
-{
-	struct net *net = ovs_dp_get_net(parms->dp);
-	struct nlattr *options = parms->options;
-	struct net_device *dev;
-	struct vport *vport;
-	struct nlattr *a;
-	int err;
-	struct vxlan_config conf = {
-		.no_share = true,
-		.flags = VXLAN_F_FLOW_BASED | VXLAN_F_COLLECT_METADATA,
-	};
-
-	if (!options) {
-		err = -EINVAL;
-		goto error;
-	}
-
-	a = nla_find_nested(options, OVS_TUNNEL_ATTR_DST_PORT);
-	if (a && nla_len(a) == sizeof(u16)) {
-		conf.dst_port = htons(nla_get_u16(a));
-	} else {
-		/* Require destination port from userspace. */
-		err = -EINVAL;
-		goto error;
-	}
-
-	vport = ovs_vport_alloc(0, &ovs_vxlan_netdev_vport_ops, parms);
-	if (IS_ERR(vport))
-		return vport;
-
-	a = nla_find_nested(options, OVS_TUNNEL_ATTR_EXTENSION);
-	if (a) {
-		err = vxlan_configure_exts(vport, a, &conf);
-		if (err) {
-			ovs_vport_free(vport);
-			goto error;
-		}
-	}
-
-	rtnl_lock();
-	dev = vxlan_dev_create(net, parms->name, NET_NAME_USER, &conf);
-	if (IS_ERR(dev)) {
-		rtnl_unlock();
-		ovs_vport_free(vport);
-		return ERR_CAST(dev);
-	}
-
-	dev_change_flags(dev, dev->flags | IFF_UP);
-	rtnl_unlock();
-	return vport;
-error:
-	return ERR_PTR(err);
-}
-
-static struct vport *vxlan_create(const struct vport_parms *parms)
-{
-	struct vport *vport;
-
-	vport = vxlan_tnl_create(parms);
-	if (IS_ERR(vport))
-		return vport;
-
-	return netdev_link(vport, parms->name);
-}
-
-static void vxlan_destroy(struct vport *vport)
-{
-	rtnl_lock();
-	if (vport->dev->priv_flags & IFF_OVS_DATAPATH)
-		ovs_netdev_detach_dev(vport);
-
-	/* Early release so we can unregister the device */
-	dev_put(vport->dev);
-	rtnl_delete_link(vport->dev);
-	vport->dev = NULL;
-	rtnl_unlock();
-
-	call_rcu(&vport->rcu, free_port_rcu);
-}
-
-static int vxlan_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
-				     struct ip_tunnel_info *egress_tun_info)
-{
-	struct vxlan_dev *vxlan = netdev_priv(vport->dev);
-	struct net *net = ovs_dp_get_net(vport->dp);
-	__be16 dst_port = vxlan_dev_dst_port(vxlan);
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
-static struct vport_ops ovs_vxlan_netdev_vport_ops = {
-	.type		= OVS_VPORT_TYPE_VXLAN,
-	.create		= vxlan_create,
-	.destroy	= vxlan_destroy,
-	.get_options	= vxlan_get_options,
-	.send		= netdev_send,
-	.get_egress_tun_info	= vxlan_get_egress_tun_info,
-};
-
-static int vxlan_compat_init(void)
-{
-	return ovs_vport_ops_register(&ovs_vxlan_netdev_vport_ops);
-}
-
-static void vxlan_compat_exit(void)
-{
-	ovs_vport_ops_unregister(&ovs_vxlan_netdev_vport_ops);
-}
-#else
-static int vxlan_compat_init(void)
-{
-	return 0;
-}
-
-static void vxlan_compat_exit(void)
-{
-}
-#endif
-
 int __init ovs_netdev_init(void)
 {
-	int err;
-
-	err = ovs_vport_ops_register(&ovs_netdev_vport_ops);
-	if (err)
-		return err;
-	err = vxlan_compat_init();
-	if (err)
-		vxlan_compat_exit();
-	return err;
+	return ovs_vport_ops_register(&ovs_netdev_vport_ops);
 }
 
 void ovs_netdev_exit(void)
 {
 	ovs_vport_ops_unregister(&ovs_netdev_vport_ops);
-	vxlan_compat_exit();
 }
diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
index 684fb88..8044126 100644
--- a/net/openvswitch/vport-netdev.h
+++ b/net/openvswitch/vport-netdev.h
@@ -26,7 +26,10 @@
 
 struct vport *ovs_netdev_get_vport(struct net_device *dev);
 
+struct vport *ovs_netdev_link(struct vport *vport, const char *name);
+int ovs_netdev_send(struct vport *vport, struct sk_buff *skb);
 void ovs_netdev_detach_dev(struct vport *);
+void ovs_vport_free_rcu(struct rcu_head *);
 
 int __init ovs_netdev_init(void);
 void ovs_netdev_exit(void);
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
new file mode 100644
index 0000000..5471733
--- /dev/null
+++ b/net/openvswitch/vport-vxlan.c
@@ -0,0 +1,207 @@
+/*
+ * Copyright (c) 2014 Nicira, Inc.
+ * Copyright (c) 2013 Cisco Systems, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#include <linux/kernel.h>
+#include <linux/skbuff.h>
+#include <linux/openvswitch.h>
+#include <linux/module.h>
+#include <net/udp.h>
+#include <net/ip_tunnels.h>
+#include <net/rtnetlink.h>
+#include <net/vxlan.h>
+
+#include "datapath.h"
+#include "vport.h"
+#include "vport-netdev.h"
+
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
+	struct net_device *dev;
+	struct vport *vport;
+	struct nlattr *a;
+	int err;
+	struct vxlan_config conf = {
+		.no_share = true,
+		.flags = VXLAN_F_FLOW_BASED | VXLAN_F_COLLECT_METADATA,
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
+	dev = vxlan_dev_create(net, parms->name, NET_NAME_USER, &conf);
+	if (IS_ERR(dev)) {
+		rtnl_unlock();
+		ovs_vport_free(vport);
+		return ERR_CAST(dev);
+	}
+
+	dev_change_flags(dev, dev->flags | IFF_UP);
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
+	return ovs_netdev_link(vport, parms->name);
+}
+
+static void vxlan_destroy(struct vport *vport)
+{
+	rtnl_lock();
+	if (vport->dev->priv_flags & IFF_OVS_DATAPATH)
+		ovs_netdev_detach_dev(vport);
+
+	/* Early release so we can unregister the device */
+	dev_put(vport->dev);
+	rtnl_delete_link(vport->dev);
+	vport->dev = NULL;
+	rtnl_unlock();
+
+	call_rcu(&vport->rcu, ovs_vport_free_rcu);
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
+	.type			= OVS_VPORT_TYPE_VXLAN,
+	.create			= vxlan_create,
+	.destroy		= vxlan_destroy,
+	.get_options		= vxlan_get_options,
+	.send			= ovs_netdev_send,
+	.get_egress_tun_info	= vxlan_get_egress_tun_info,
+};
+
+static int __init ovs_vxlan_tnl_init(void)
+{
+	return ovs_vport_ops_register(&ovs_vxlan_netdev_vport_ops);
+}
+
+static void __exit ovs_vxlan_tnl_exit(void)
+{
+	ovs_vport_ops_unregister(&ovs_vxlan_netdev_vport_ops);
+}
+
+module_init(ovs_vxlan_tnl_init);
+module_exit(ovs_vxlan_tnl_exit);
+
+MODULE_DESCRIPTION("OVS: VXLAN switching port");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("vport-type-4");
-- 
2.4.3
