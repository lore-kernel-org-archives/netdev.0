From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 12/12] openvswitch: Add gre tunnel support.
Date: Mon, 17 Jun 2013 17:50:33 -0700
Message-ID: <1371516633-18090-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:41790 "HELO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753294Ab3FRAuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 20:50:37 -0400
Received: by mail-pd0-f179.google.com with SMTP id q10so3298704pdj.24
        for <netdev@vger.kernel.org>; Mon, 17 Jun 2013 17:50:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add gre vport implementation.  Most of gre protocol processing
is pushed to gre module. It make use of gre demultiplexer
therefore it can co-exist with linux device based gre tunnels.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
v2:
- filter ip-tunnel flags.
- Add CONFIG_NET_IPGRE_DEMUX guard for ovs-gre.
---
 include/uapi/linux/openvswitch.h |    1 +
 net/openvswitch/Kconfig          |    2 +
 net/openvswitch/Makefile         |    3 +-
 net/openvswitch/datapath.h       |    1 +
 net/openvswitch/flow.h           |   18 +++-
 net/openvswitch/vport-gre.c      |  274 ++++++++++++++++++++++++++++++++++++++
 net/openvswitch/vport.c          |   19 +++
 net/openvswitch/vport.h          |    7 +
 8 files changed, 323 insertions(+), 2 deletions(-)
 create mode 100644 net/openvswitch/vport-gre.c

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index b15a445..c55efaa 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -164,6 +164,7 @@ enum ovs_vport_type {
 	OVS_VPORT_TYPE_UNSPEC,
 	OVS_VPORT_TYPE_NETDEV,   /* network device */
 	OVS_VPORT_TYPE_INTERNAL, /* network device implemented by datapath */
+	OVS_VPORT_TYPE_GRE,      /* GRE tunnel. */
 	__OVS_VPORT_TYPE_MAX
 };
 
diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index d9ea33c..9fbc04a 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -19,6 +19,8 @@ config OPENVSWITCH
 	  which is able to accept configuration from a variety of sources and
 	  translate it into packet processing rules.
 
+	  Open vSwitch GRE support depends on CONFIG_NET_IPGRE_DEMUX.
+
 	  See http://openvswitch.org for more information and userspace
 	  utilities.
 
diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
index 15e7384..01bddb2 100644
--- a/net/openvswitch/Makefile
+++ b/net/openvswitch/Makefile
@@ -10,5 +10,6 @@ openvswitch-y := \
 	dp_notify.o \
 	flow.o \
 	vport.o \
+	vport-gre.o \
 	vport-internal_dev.o \
-	vport-netdev.o \
+	vport-netdev.o
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index e88ebc2..a914864 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -122,6 +122,7 @@ struct dp_upcall_info {
 struct ovs_net {
 	struct list_head dps;
 	struct work_struct dp_notify_work;
+	struct vport_net vport_net;
 };
 
 extern int ovs_net_id;
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 999842f..66ef722 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -49,11 +49,27 @@ struct ovs_key_ipv4_tunnel {
 	__be64 tun_id;
 	__be32 ipv4_src;
 	__be32 ipv4_dst;
-	u16  tun_flags;
+	__be16 tun_flags;
 	u8   ipv4_tos;
 	u8   ipv4_ttl;
 };
 
+static inline void ovs_flow_tun_key_init(struct ovs_key_ipv4_tunnel *tun_key,
+					 const struct iphdr *iph, __be64 tun_id,
+					 __be16 tun_flags)
+{
+	tun_key->tun_id = tun_id;
+	tun_key->ipv4_src = iph->saddr;
+	tun_key->ipv4_dst = iph->daddr;
+	tun_key->ipv4_tos = iph->tos;
+	tun_key->ipv4_ttl = iph->ttl;
+	tun_key->tun_flags = tun_flags;
+
+	/* clear struct padding. */
+	memset((unsigned char *) tun_key + OVS_TUNNEL_KEY_SIZE, 0,
+	       sizeof(*tun_key) - OVS_TUNNEL_KEY_SIZE);
+}
+
 struct sw_flow_key {
 	struct ovs_key_ipv4_tunnel tun_key;  /* Encapsulating tunnel key. */
 	struct {
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
new file mode 100644
index 0000000..3a8d190
--- /dev/null
+++ b/net/openvswitch/vport-gre.c
@@ -0,0 +1,274 @@
+/*
+ * Copyright (c) 2007-2013 Nicira, Inc.
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
+#ifdef CONFIG_NET_IPGRE_DEMUX
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/if.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <linux/if_tunnel.h>
+#include <linux/if_vlan.h>
+#include <linux/in.h>
+#include <linux/if_vlan.h>
+#include <linux/in.h>
+#include <linux/in_route.h>
+#include <linux/inetdevice.h>
+#include <linux/jhash.h>
+#include <linux/list.h>
+#include <linux/kernel.h>
+#include <linux/workqueue.h>
+#include <linux/rculist.h>
+#include <net/route.h>
+#include <net/xfrm.h>
+
+#include <net/icmp.h>
+#include <net/ip.h>
+#include <net/ip_tunnels.h>
+#include <net/gre.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+#include <net/protocol.h>
+
+#include "datapath.h"
+#include "vport.h"
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
+static struct sk_buff *__build_header(struct sk_buff *skb,
+				      int tunnel_hlen)
+{
+	const struct ovs_key_ipv4_tunnel *tun_key = OVS_CB(skb)->tun_key;
+	struct tnl_ptk_info tpi;
+
+	skb = gre_handle_offloads(skb, !!(tun_key->tun_flags & TUNNEL_CSUM));
+	if (IS_ERR(skb))
+		return NULL;
+
+	tpi.flags = filter_tnl_flags(tun_key->tun_flags);
+	tpi.proto = htons(ETH_P_TEB);
+	tpi.key = be64_get_low32(tun_key->tun_id);
+	tpi.seq = 0;
+	gre_build_header(skb, &tpi, tunnel_hlen);
+
+	return skb;
+}
+
+static __be64 key_to_tunnel_id(__be32 key, __be32 seq)
+{
+#ifdef __BIG_ENDIAN
+	return (__force __be64)((__force u64)seq << 32 | (__force u32)key);
+#else
+	return (__force __be64)((__force u64)key << 32 | (__force u32)seq);
+#endif
+}
+
+/* Called with rcu_read_lock and BH disabled. */
+static int gre_rcv(struct sk_buff *skb,
+		   const struct tnl_ptk_info *tpi)
+{
+	struct ovs_key_ipv4_tunnel tun_key;
+	struct ovs_net *ovs_net;
+	struct vport *vport;
+	__be64 key;
+
+	ovs_net = net_generic(dev_net(skb->dev), ovs_net_id);
+	vport = rcu_dereference(ovs_net->vport_net.gre_vport);
+	if (unlikely(!vport))
+		return PACKET_REJECT;
+
+	key = key_to_tunnel_id(tpi->key, tpi->seq);
+	ovs_flow_tun_key_init(&tun_key, ip_hdr(skb), key,
+			      filter_tnl_flags(tpi->flags));
+
+	ovs_vport_receive(vport, skb, &tun_key);
+	return PACKET_RCVD;
+}
+
+static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
+{
+	struct net *net = ovs_dp_get_net(vport->dp);
+	struct flowi4 fl;
+	struct rtable *rt;
+	int min_headroom;
+	int tunnel_hlen;
+	__be16 df;
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
+	if (IS_ERR(rt))
+		return PTR_ERR(rt);
+
+	tunnel_hlen = ip_gre_calc_hlen(OVS_CB(skb)->tun_key->tun_flags);
+
+	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
+			+ tunnel_hlen + sizeof(struct iphdr)
+			+ (vlan_tx_tag_present(skb) ? VLAN_HLEN : 0);
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
+	if (vlan_tx_tag_present(skb)) {
+		if (unlikely(!__vlan_put_tag(skb,
+					     skb->vlan_proto,
+					     vlan_tx_tag_get(skb)))) {
+			err = -ENOMEM;
+			goto err_free_rt;
+		}
+		skb->vlan_tci = 0;
+	}
+
+	/* Push Tunnel header. */
+	skb = __build_header(skb, tunnel_hlen);
+	if (unlikely(!skb)) {
+		err = 0;
+		goto err_free_rt;
+	}
+
+	df = OVS_CB(skb)->tun_key->tun_flags & TUNNEL_DONT_FRAGMENT ?
+		htons(IP_DF) : 0;
+
+	skb->local_df = 1;
+
+	return iptunnel_xmit(net, rt, skb, fl.saddr,
+			     OVS_CB(skb)->tun_key->ipv4_dst, IPPROTO_GRE,
+			     OVS_CB(skb)->tun_key->ipv4_tos,
+			     OVS_CB(skb)->tun_key->ipv4_ttl, df);
+err_free_rt:
+	ip_rt_put(rt);
+error:
+	return err;
+}
+
+static struct gre_cisco_protocol gre_protocol = {
+	.handler        = gre_rcv,
+	.priority       = 1,
+};
+
+static int gre_ports;
+static int gre_init(void)
+{
+	int err;
+
+	gre_ports++;
+	if (gre_ports > 1)
+		return 0;
+
+	err = gre_cisco_register(&gre_protocol);
+	if (err)
+		pr_warn("cannot register gre protocol handler\n");
+
+	return err;
+}
+
+static void gre_exit(void)
+{
+	gre_ports--;
+	if (gre_ports > 0)
+		return;
+
+	gre_cisco_unregister(&gre_protocol);
+}
+
+static const char *gre_get_name(const struct vport *vport)
+{
+	return vport_priv(vport);
+}
+
+static struct vport *gre_create(const struct vport_parms *parms)
+{
+	struct net *net = ovs_dp_get_net(parms->dp);
+	struct ovs_net *ovs_net;
+	struct vport *vport;
+	int err;
+
+	err = gre_init();
+	if (err)
+		return ERR_PTR(err);
+
+	ovs_net = net_generic(net, ovs_net_id);
+	if (ovsl_dereference(ovs_net->vport_net.gre_vport)) {
+		vport = ERR_PTR(-EEXIST);
+		goto error;
+	}
+
+	vport = ovs_vport_alloc(IFNAMSIZ, &ovs_gre_vport_ops, parms);
+	if (IS_ERR(vport))
+		goto error;
+
+	strncpy(vport_priv(vport), parms->name, IFNAMSIZ);
+	rcu_assign_pointer(ovs_net->vport_net.gre_vport, vport);
+	return vport;
+
+error:
+	gre_exit();
+	return vport;
+}
+
+static void gre_tnl_destroy(struct vport *vport)
+{
+	struct net *net = ovs_dp_get_net(vport->dp);
+	struct ovs_net *ovs_net;
+
+	ovs_net = net_generic(net, ovs_net_id);
+
+	rcu_assign_pointer(ovs_net->vport_net.gre_vport, NULL);
+	ovs_vport_deferred_free(vport);
+	gre_exit();
+}
+
+const struct vport_ops ovs_gre_vport_ops = {
+	.type		= OVS_VPORT_TYPE_GRE,
+	.create		= gre_create,
+	.destroy	= gre_tnl_destroy,
+	.get_name	= gre_get_name,
+	.send		= gre_tnl_send,
+};
+#endif
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 413287a..f52dfb9 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -38,6 +38,10 @@
 static const struct vport_ops *vport_ops_list[] = {
 	&ovs_netdev_vport_ops,
 	&ovs_internal_vport_ops,
+
+#ifdef CONFIG_NET_IPGRE_DEMUX
+	&ovs_gre_vport_ops,
+#endif
 };
 
 /* Protected by RCU read lock for reading, ovs_mutex for writing. */
@@ -404,3 +408,18 @@ void ovs_vport_record_error(struct vport *vport, enum vport_err_type err_type)
 
 	spin_unlock(&vport->stats_lock);
 }
+
+static void free_vport_rcu(struct rcu_head *rcu)
+{
+	struct vport *vport = container_of(rcu, struct vport, rcu);
+
+	ovs_vport_free(vport);
+}
+
+void ovs_vport_deferred_free(struct vport *vport)
+{
+	if (!vport)
+		return;
+
+	call_rcu(&vport->rcu, free_vport_rcu);
+}
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 2d961ae..376045c 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -34,6 +34,11 @@ struct vport_parms;
 
 /* The following definitions are for users of the vport subsytem: */
 
+/* The following definitions are for users of the vport subsytem: */
+struct vport_net {
+	struct vport __rcu *gre_vport;
+};
+
 int ovs_vport_init(void);
 void ovs_vport_exit(void);
 
@@ -152,6 +157,7 @@ enum vport_err_type {
 struct vport *ovs_vport_alloc(int priv_size, const struct vport_ops *,
 			      const struct vport_parms *);
 void ovs_vport_free(struct vport *);
+void ovs_vport_deferred_free(struct vport *vport);
 
 #define VPORT_ALIGN 8
 
@@ -192,6 +198,7 @@ void ovs_vport_record_error(struct vport *, enum vport_err_type err_type);
  * add yours to the list at the top of vport.c. */
 extern const struct vport_ops ovs_netdev_vport_ops;
 extern const struct vport_ops ovs_internal_vport_ops;
+extern const struct vport_ops ovs_gre_vport_ops;
 
 static inline void ovs_skb_postpush_rcsum(struct sk_buff *skb,
 				      const void *start, unsigned int len)
-- 
1.7.1
