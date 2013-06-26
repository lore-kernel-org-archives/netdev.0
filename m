From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH vxlan v2 8/8] openvswitch: Add vxlan tunneling support.
Date: Wed, 26 Jun 2013 13:14:08 -0700
Message-ID: <1372277648-17740-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog123.obsmtp.com ([74.125.149.149]:44401 "HELO
	na3sys009aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752740Ab3FZUOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 16:14:12 -0400
Received: by mail-pd0-f172.google.com with SMTP id z10so1653589pdj.17
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 13:14:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch adds vxlan vport type for openvswitch using
vxlan api.
This patch adds vxlan dependency for openvswitch.

CC: Jesse Gross <jesse@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
v1-v2:
 - removed NULL check in vxlan-rcv.
 - change vxlan-port create to look good.
 - Added Cisco copyright.
---
 include/uapi/linux/openvswitch.h |   11 ++
 net/openvswitch/Kconfig          |    1 +
 net/openvswitch/Makefile         |    3 +-
 net/openvswitch/vport-vxlan.c    |  214 ++++++++++++++++++++++++++++++++++++++
 net/openvswitch/vport.c          |    3 +
 net/openvswitch/vport.h          |    1 +
 6 files changed, 232 insertions(+), 1 deletions(-)
 create mode 100644 net/openvswitch/vport-vxlan.c

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index c55efaa..52490b0 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -165,6 +165,7 @@ enum ovs_vport_type {
 	OVS_VPORT_TYPE_NETDEV,   /* network device */
 	OVS_VPORT_TYPE_INTERNAL, /* network device implemented by datapath */
 	OVS_VPORT_TYPE_GRE,      /* GRE tunnel. */
+	OVS_VPORT_TYPE_VXLAN,	 /* VXLAN tunnel. */
 	__OVS_VPORT_TYPE_MAX
 };
 
@@ -211,6 +212,16 @@ enum ovs_vport_attr {
 
 #define OVS_VPORT_ATTR_MAX (__OVS_VPORT_ATTR_MAX - 1)
 
+/* OVS_VPORT_ATTR_OPTIONS attributes for tunnels.
+ */
+enum {
+	OVS_TUNNEL_ATTR_UNSPEC,
+	OVS_TUNNEL_ATTR_DST_PORT, /* 16-bit UDP port, used by L4 tunnels. */
+	__OVS_TUNNEL_ATTR_MAX
+};
+
+#define OVS_TUNNEL_ATTR_MAX (__OVS_TUNNEL_ATTR_MAX - 1)
+
 /* Flows. */
 
 #define OVS_FLOW_FAMILY  "ovs_flow"
diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index 9fbc04a..201b40c 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -20,6 +20,7 @@ config OPENVSWITCH
 	  translate it into packet processing rules.
 
 	  Open vSwitch GRE support depends on CONFIG_NET_IPGRE_DEMUX.
+	  Open vSwitch VXLAN support depends on CONFIG_VXLAN.
 
 	  See http://openvswitch.org for more information and userspace
 	  utilities.
diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
index 01bddb2..33952c9 100644
--- a/net/openvswitch/Makefile
+++ b/net/openvswitch/Makefile
@@ -12,4 +12,5 @@ openvswitch-y := \
 	vport.o \
 	vport-gre.o \
 	vport-internal_dev.o \
-	vport-netdev.o
+	vport-netdev.o \
+	vport-vxlan.o
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
new file mode 100644
index 0000000..4022876
--- /dev/null
+++ b/net/openvswitch/vport-vxlan.c
@@ -0,0 +1,214 @@
+/*
+ * Copyright (c) 2013 Nicira, Inc.
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
+#if IS_ENABLED(CONFIG_VXLAN)
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/net.h>
+#include <linux/rculist.h>
+#include <linux/udp.h>
+
+#include <net/icmp.h>
+#include <net/ip.h>
+#include <net/udp.h>
+#include <net/ip_tunnels.h>
+#include <net/udp.h>
+#include <net/rtnetlink.h>
+#include <net/route.h>
+#include <net/dsfield.h>
+#include <net/inet_ecn.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+#include <net/vxlan.h>
+
+#include "datapath.h"
+#include "vport.h"
+
+#define OVS_VXLAN_RCV_PRIORITY		8
+
+/**
+ * struct vxlan_port - Keeps track of open UDP ports
+ * @vh: vxlan_handler created for the port.
+ * @dst_port: vxlan UDP port no.
+ * @name: vport name.
+ */
+struct vxlan_port {
+	struct vxlan_handler *vh;
+	__be16 dst_port;
+	char name[IFNAMSIZ];
+};
+
+static inline struct vxlan_port *vxlan_vport(const struct vport *vport)
+{
+	return vport_priv(vport);
+}
+
+/* Called with rcu_read_lock and BH disabled. */
+static int vxlan_rcv(struct vxlan_handler *vh, struct sk_buff *skb, __be32 vx_vni)
+{
+	struct vport *vport = vh->data;
+	struct iphdr *iph;
+	struct ovs_key_ipv4_tunnel tun_key;
+	__be64 key;
+
+	/* Save outer tunnel values */
+	iph = ip_hdr(skb);
+	key = cpu_to_be64(ntohl(vx_vni) >> 8);
+	ovs_flow_tun_key_init(&tun_key, iph, key, TUNNEL_KEY);
+
+	ovs_vport_receive(vport, skb, &tun_key);
+	return PACKET_RCVD;
+}
+
+static int vxlan_get_options(const struct vport *vport, struct sk_buff *skb)
+{
+	struct vxlan_port *vxlan_port = vxlan_vport(vport);
+
+	if (nla_put_u16(skb, OVS_TUNNEL_ATTR_DST_PORT, ntohs(vxlan_port->dst_port)))
+		return -EMSGSIZE;
+	return 0;
+}
+
+static void vxlan_tnl_destroy(struct vport *vport)
+{
+	struct vxlan_port *vxlan_port = vxlan_vport(vport);
+
+	vxlan_handler_put(vxlan_port->vh);
+
+	ovs_vport_deferred_free(vport);
+}
+
+static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
+{
+	struct net *net = ovs_dp_get_net(parms->dp);
+	struct nlattr *options = parms->options;
+	struct vxlan_port *vxlan_port;
+	struct vxlan_handler *vh;
+	struct vport *vport;
+	struct nlattr *a;
+	int err;
+	u16 dst_port;
+
+	if (!options) {
+		err = -EINVAL;
+		goto error;
+	}
+	a = nla_find_nested(options, OVS_TUNNEL_ATTR_DST_PORT);
+	if (a && nla_len(a) == sizeof(u16)) {
+		dst_port = nla_get_u16(a);
+	} else {
+		/* Require destination port from userspace. */
+		err = -EINVAL;
+		goto error;
+	}
+
+	vport = ovs_vport_alloc(sizeof(struct vxlan_port),
+				&ovs_vxlan_vport_ops, parms);
+	if (IS_ERR(vport))
+		return vport;
+
+	vxlan_port = vxlan_vport(vport);
+	strncpy(vxlan_port->name, parms->name, IFNAMSIZ);
+	vxlan_port->dst_port = htons(dst_port);
+
+	vh = vxlan_handler_add(net, htons(dst_port), vxlan_rcv,
+			       vport, OVS_VXLAN_RCV_PRIORITY);
+	if (IS_ERR(vh)) {
+		ovs_vport_free(vport);
+		return (void *)vh;
+	}
+	vxlan_port->vh = vh;
+
+	return vport;
+
+error:
+	return ERR_PTR(err);
+}
+
+static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
+{
+	struct net *net = ovs_dp_get_net(vport->dp);
+	struct vxlan_port *vxlan_port = vxlan_vport(vport);
+	__be16 dst_port = vxlan_port->dst_port;
+	struct flowi4 fl;
+	struct rtable *rt;
+	__be16 df;
+	int port_min;
+	int port_max;
+	__be16 src_port;
+	int err;
+
+	if (unlikely(!OVS_CB(skb)->tun_key)) {
+		err = -EINVAL;
+		goto error;
+	}
+
+	/* Route lookup */
+	memset(&fl, 0, sizeof(fl));
+	fl.daddr = OVS_CB(skb)->tun_key->ipv4_dst;
+	fl.saddr = OVS_CB(skb)->tun_key->ipv4_src;
+	fl.flowi4_tos = RT_TOS(OVS_CB(skb)->tun_key->ipv4_tos);
+	fl.flowi4_mark = skb->mark;
+	fl.flowi4_proto = IPPROTO_GRE;
+
+	rt = ip_route_output_key(net, &fl);
+	if (IS_ERR(rt)) {
+		err = PTR_ERR(rt);
+		goto error;
+	}
+
+	df = OVS_CB(skb)->tun_key->tun_flags & TUNNEL_DONT_FRAGMENT ?
+		htons(IP_DF) : 0;
+
+	skb->local_df = 1;
+
+	inet_get_local_port_range(&port_min, &port_max);
+	src_port = vxlan_src_port(port_min, port_max, skb);
+
+	err = vxlan_xmit_skb(net, vxlan_port->vh, rt, skb,
+			     fl.saddr, OVS_CB(skb)->tun_key->ipv4_dst,
+			     OVS_CB(skb)->tun_key->ipv4_tos,
+			     OVS_CB(skb)->tun_key->ipv4_ttl, df,
+			     src_port, dst_port,
+			     htonl(be64_to_cpu(OVS_CB(skb)->tun_key->tun_id) << 8));
+	if (err < 0)
+		ip_rt_put(rt);
+error:
+	return err;
+
+}
+
+static const char *vxlan_get_name(const struct vport *vport)
+{
+	struct vxlan_port *vxlan_port = vxlan_vport(vport);
+	return vxlan_port->name;
+}
+
+const struct vport_ops ovs_vxlan_vport_ops = {
+	.type		= OVS_VPORT_TYPE_VXLAN,
+	.create		= vxlan_tnl_create,
+	.destroy	= vxlan_tnl_destroy,
+	.get_name	= vxlan_get_name,
+	.get_options	= vxlan_get_options,
+	.send		= vxlan_tnl_send,
+};
+#endif
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index ba81294..f795862 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -42,6 +42,9 @@ static const struct vport_ops *vport_ops_list[] = {
 #if IS_ENABLED(CONFIG_NET_IPGRE_DEMUX)
 	&ovs_gre_vport_ops,
 #endif
+#if IS_ENABLED(CONFIG_VXLAN)
+	&ovs_vxlan_vport_ops,
+#endif
 };
 
 /* Protected by RCU read lock for reading, ovs_mutex for writing. */
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 376045c..1a9fbce 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -199,6 +199,7 @@ void ovs_vport_record_error(struct vport *, enum vport_err_type err_type);
 extern const struct vport_ops ovs_netdev_vport_ops;
 extern const struct vport_ops ovs_internal_vport_ops;
 extern const struct vport_ops ovs_gre_vport_ops;
+extern const struct vport_ops ovs_vxlan_vport_ops;
 
 static inline void ovs_skb_postpush_rcsum(struct sk_buff *skb,
 				      const void *start, unsigned int len)
-- 
1.7.1
