From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 3/3] openvswitch: Add support for STT tunneling.
Date: Tue, 20 Jan 2015 12:25:54 -0800
Message-ID: <1421785554-19883-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:55964 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752985AbbATVJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 16:09:08 -0500
Received: by mail-pa0-f43.google.com with SMTP id eu11so10798612pac.2
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 13:09:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use STT driver to create STT tunnel port.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 include/uapi/linux/openvswitch.h |   1 +
 net/openvswitch/Kconfig          |  10 ++
 net/openvswitch/Makefile         |   1 +
 net/openvswitch/vport-stt.c      | 214 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 226 insertions(+)
 create mode 100644 net/openvswitch/vport-stt.c

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index cd8d933..a7396a7 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -204,6 +204,7 @@ enum ovs_vport_type {
 	OVS_VPORT_TYPE_GRE,      /* GRE tunnel. */
 	OVS_VPORT_TYPE_VXLAN,	 /* VXLAN tunnel. */
 	OVS_VPORT_TYPE_GENEVE,	 /* Geneve tunnel. */
+	OVS_VPORT_TYPE_STT,	 /* STT tunnel. */
 	__OVS_VPORT_TYPE_MAX
 };
 
diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index b7d818c..65b5fb7 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -64,3 +64,13 @@ config OPENVSWITCH_GENEVE
 	  If you say Y here, then the Open vSwitch will be able create geneve vport.
 
 	  Say N to exclude this support and reduce the binary size.
+
+config OPENVSWITCH_STT
+	tristate "Open vSwitch STT tunneling support"
+	depends on OPENVSWITCH
+	depends on STT
+	default OPENVSWITCH
+	---help---
+	  If you say Y here, then the Open vSwitch will be able create stt vport.
+
+	  Say N to exclude this support and reduce the binary size.
diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
index 91b9478..352bd05 100644
--- a/net/openvswitch/Makefile
+++ b/net/openvswitch/Makefile
@@ -18,3 +18,4 @@ openvswitch-y := \
 obj-$(CONFIG_OPENVSWITCH_GENEVE)+= vport-geneve.o
 obj-$(CONFIG_OPENVSWITCH_VXLAN)	+= vport-vxlan.o
 obj-$(CONFIG_OPENVSWITCH_GRE)	+= vport-gre.o
+obj-$(CONFIG_OPENVSWITCH_STT)	+= vport-stt.o
diff --git a/net/openvswitch/vport-stt.c b/net/openvswitch/vport-stt.c
new file mode 100644
index 0000000..f614b3d
--- /dev/null
+++ b/net/openvswitch/vport-stt.c
@@ -0,0 +1,214 @@
+/*
+ * Copyright (c) 2014 Nicira, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/if_vlan.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/rculist.h>
+#include <linux/udp.h>
+
+#include <net/icmp.h>
+#include <net/ip.h>
+#include <net/route.h>
+#include <net/stt.h>
+#include <net/udp.h>
+
+#include "datapath.h"
+#include "vport.h"
+
+static struct vport_ops ovs_stt_vport_ops;
+
+/**
+ * struct stt_port - Keeps track of open UDP ports
+ * @stt_sock: The socket created for this port number.
+ * @name: vport name.
+ */
+struct stt_port {
+	struct stt_sock *stt_sock;
+	char name[IFNAMSIZ];
+};
+
+static inline struct stt_port *stt_vport(const struct vport *vport)
+{
+	return vport_priv(vport);
+}
+
+static void stt_rcv(struct stt_sock *stt_sock, struct sk_buff *skb)
+{
+	struct vport *vport = stt_sock->rcv_data;
+	struct stthdr *stth = stt_hdr(skb);
+	struct ovs_tunnel_info tun_info;
+	struct sk_buff *next;
+
+	ovs_flow_tun_info_init(&tun_info, ip_hdr(skb),
+			       tcp_hdr(skb)->source, tcp_hdr(skb)->dest,
+			       get_unaligned(&stth->key),
+			       TUNNEL_KEY | TUNNEL_CSUM,
+			       NULL, 0);
+	do {
+		next = skb->next;
+		skb->next = NULL;
+		ovs_vport_receive(vport, skb, &tun_info);
+	} while ((skb = next));
+}
+
+static int stt_tnl_get_options(const struct vport *vport,
+			       struct sk_buff *skb)
+{
+	struct stt_port *stt_port = stt_vport(vport);
+	struct inet_sock *sk = inet_sk(stt_port->stt_sock->sock->sk);
+
+	if (nla_put_u16(skb, OVS_TUNNEL_ATTR_DST_PORT, ntohs(sk->inet_sport)))
+		return -EMSGSIZE;
+	return 0;
+}
+
+static void stt_tnl_destroy(struct vport *vport)
+{
+	struct stt_port *stt_port = stt_vport(vport);
+
+	stt_sock_release(stt_port->stt_sock);
+	ovs_vport_deferred_free(vport);
+}
+
+static struct vport *stt_tnl_create(const struct vport_parms *parms)
+{
+	struct net *net = ovs_dp_get_net(parms->dp);
+	struct nlattr *options = parms->options;
+	struct stt_port *stt_port;
+	struct stt_sock *stt_sock;
+	struct vport *vport;
+	struct nlattr *a;
+	int err;
+	u16 dst_port;
+
+	if (!options) {
+		err = -EINVAL;
+		goto error;
+	}
+
+	a = nla_find_nested(options, OVS_TUNNEL_ATTR_DST_PORT);
+	if (a && nla_len(a) == sizeof(u16)) {
+		dst_port = nla_get_u16(a);
+	} else {
+		/* Require destination port from userspace. */
+		err = -EINVAL;
+		goto error;
+	}
+
+	vport = ovs_vport_alloc(sizeof(struct stt_port),
+				&ovs_stt_vport_ops, parms);
+	if (IS_ERR(vport))
+		return vport;
+
+	stt_port = stt_vport(vport);
+	strncpy(stt_port->name, parms->name, IFNAMSIZ);
+
+	stt_sock = stt_sock_add(net, htons(dst_port), stt_rcv, vport);
+	if (IS_ERR(stt_sock)) {
+		ovs_vport_free(vport);
+		return (void *)stt_sock;
+	}
+	stt_port->stt_sock = stt_sock;
+
+	return vport;
+error:
+	return ERR_PTR(err);
+}
+
+static int stt_tnl_send(struct vport *vport, struct sk_buff *skb)
+{
+	struct net *net = ovs_dp_get_net(vport->dp);
+	struct stt_port *stt_port = stt_vport(vport);
+	__be16 dport = inet_sk(stt_port->stt_sock->sock->sk)->inet_sport;
+	const struct ovs_key_ipv4_tunnel *tun_key;
+	const struct ovs_tunnel_info *tun_info;
+	struct rtable *rt;
+	struct flowi4 fl;
+	__be16 sport;
+	__be16 df;
+	int err;
+
+	tun_info = OVS_CB(skb)->egress_tun_info;
+	if (unlikely(!tun_info)) {
+		err = -EINVAL;
+		goto error;
+	}
+
+	tun_key = &tun_info->tunnel;
+	rt = ovs_tunnel_route_lookup(net, tun_key, skb->mark, &fl, IPPROTO_TCP);
+	if (IS_ERR(rt)) {
+		err = PTR_ERR(rt);
+		goto error;
+	}
+
+	df = tun_key->tun_flags & TUNNEL_DONT_FRAGMENT ? htons(IP_DF) : 0;
+	sport = udp_flow_src_port(net, skb, 1, USHRT_MAX, true);
+	skb->ignore_df = 1;
+
+	return stt_xmit_skb(skb, rt, fl.saddr, tun_key->ipv4_dst,
+			   tun_key->ipv4_tos, tun_key->ipv4_ttl,
+			   df, sport, dport, tun_key->tun_id);
+error:
+	kfree_skb(skb);
+	return err;
+}
+
+static const char *stt_tnl_get_name(const struct vport *vport)
+{
+	return stt_vport(vport)->name;
+}
+
+static int stt_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
+				   struct ovs_tunnel_info *egress_tun_info)
+{
+	struct stt_port *stt_port = stt_vport(vport);
+	struct net *net = ovs_dp_get_net(vport->dp);
+	__be16 dport = inet_sk(stt_port->stt_sock->sock->sk)->inet_sport;
+	__be16 sport = udp_flow_src_port(net, skb, 1, USHRT_MAX, true);
+
+	/* Get tp_src and tp_dst, refert to stt_build_header().
+	 */
+	return ovs_tunnel_get_egress_info(egress_tun_info,
+					  ovs_dp_get_net(vport->dp),
+					  OVS_CB(skb)->egress_tun_info,
+					  IPPROTO_UDP, skb->mark, sport, dport);
+}
+
+static struct vport_ops ovs_stt_vport_ops = {
+	.type		= OVS_VPORT_TYPE_STT,
+	.create		= stt_tnl_create,
+	.destroy	= stt_tnl_destroy,
+	.get_name	= stt_tnl_get_name,
+	.get_options	= stt_tnl_get_options,
+	.send		= stt_tnl_send,
+	.owner          = THIS_MODULE,
+	.get_egress_tun_info	= stt_get_egress_tun_info,
+};
+
+static int __init ovs_stt_tnl_init(void)
+{
+	return ovs_vport_ops_register(&ovs_stt_vport_ops);
+}
+
+static void __exit ovs_stt_tnl_exit(void)
+{
+	ovs_vport_ops_unregister(&ovs_stt_vport_ops);
+}
+
+module_init(ovs_stt_tnl_init);
+module_exit(ovs_stt_tnl_exit);
+
+MODULE_DESCRIPTION("OVS: STT swiching port");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("vport-type-6");
-- 
1.9.1
