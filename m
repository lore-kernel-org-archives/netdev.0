From: Andy Zhou <azhou@nicira.com>
Subject: [net-next v2 1/6] net: Add Geneve tunneling protocol driver
Date: Fri,  3 Oct 2014 15:35:28 -0700
Message-ID: <1412375733-30981-2-git-send-email-azhou@nicira.com>
References: <1412375733-30981-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:32903 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758699AbaJCWlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:41:49 -0400
Received: by mail-pa0-f41.google.com with SMTP id eu11so2230262pac.0
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 15:41:48 -0700 (PDT)
In-Reply-To: <1412375733-30981-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a device level support for Geneve -- Generic Network
Virtualization Encapsulation. The protocol is documented at
http://tools.ietf.org/html/draft-gross-geneve-01

Only protocol layer Geneve support is provided by this driver.
Openvswitch can be used for configuring, set up and tear down
functional Geneve tunnels.

Signed-off-by: Jesse Gross <jesse@nicira.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 include/net/geneve.h     |   91 +++++++++++
 include/net/ip_tunnels.h |    2 +
 net/ipv4/Kconfig         |   14 ++
 net/ipv4/Makefile        |    1 +
 net/ipv4/geneve.c        |  373 ++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 481 insertions(+)
 create mode 100644 include/net/geneve.h
 create mode 100644 net/ipv4/geneve.c

diff --git a/include/net/geneve.h b/include/net/geneve.h
new file mode 100644
index 0000000..ce98865
--- /dev/null
+++ b/include/net/geneve.h
@@ -0,0 +1,91 @@
+#ifndef __NET_GENEVE_H
+#define __NET_GENEVE_H  1
+
+#include <net/udp_tunnel.h>
+
+struct geneve_sock;
+
+typedef void (geneve_rcv_t)(struct geneve_sock *gs, struct sk_buff *skb);
+
+struct geneve_sock {
+	struct hlist_node	hlist;
+	geneve_rcv_t		*rcv;
+	void			*rcv_data;
+	struct work_struct	del_work;
+	struct socket		*sock;
+	struct rcu_head		rcu;
+	atomic_t		refcnt;
+	struct udp_offload	udp_offloads;
+};
+
+/* Geneve Header:
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |Ver|  Opt Len  |O|C|    Rsvd.  |          Protocol Type        |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |        Virtual Network Identifier (VNI)       |    Reserved   |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |                    Variable Length Options                    |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * Option Header:
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |          Option Class         |      Type     |R|R|R| Length  |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |                      Variable Option Data                     |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ */
+
+struct geneve_opt {
+	__be16	opt_class;
+	u8	type;
+#ifdef __LITTLE_ENDIAN_BITFIELD
+	u8	length:5;
+	u8	r3:1;
+	u8	r2:1;
+	u8	r1:1;
+#else
+	u8	r1:1;
+	u8	r2:1;
+	u8	r3:1;
+	u8	length:5;
+#endif
+	u8	opt_data[];
+};
+
+#define GENEVE_CRIT_OPT_TYPE (1 << 7)
+
+struct genevehdr {
+#ifdef __LITTLE_ENDIAN_BITFIELD
+	u8 opt_len:6;
+	u8 ver:2;
+	u8 rsvd1:6;
+	u8 critical:1;
+	u8 oam:1;
+#else
+	u8 ver:2;
+	u8 opt_len:6;
+	u8 oam:1;
+	u8 critical:1;
+	u8 rsvd1:6;
+#endif
+	__be16 proto_type;
+	u8 vni[3];
+	u8 rsvd2;
+	struct geneve_opt options[];
+};
+
+#define GENEVE_VER 0
+#define GENEVE_BASE_HLEN (sizeof(struct udphdr) + sizeof(struct genevehdr))
+
+struct geneve_sock *geneve_sock_add(struct net *net, __be16 port,
+				    geneve_rcv_t *rcv, void *data,
+				    bool no_share, bool ipv6);
+
+void geneve_sock_release(struct geneve_sock *vs);
+
+int geneve_xmit_skb(struct geneve_sock *gs, struct rtable *rt,
+		    struct sk_buff *skb, __be32 src, __be32 dst, __u8 tos,
+		    __u8 ttl, __be16 df, __be16 src_port, __be16 dst_port,
+		    __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
+		    bool xnet);
+#endif
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 7f538ba..a9ce155 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -95,6 +95,8 @@ struct ip_tunnel {
 #define TUNNEL_VERSION	__cpu_to_be16(0x40)
 #define TUNNEL_NO_KEY	__cpu_to_be16(0x80)
 #define TUNNEL_DONT_FRAGMENT    __cpu_to_be16(0x0100)
+#define TUNNEL_OAM	__cpu_to_be16(0x0200)
+#define TUNNEL_CRIT_OPT	__cpu_to_be16(0x0400)
 
 struct tnl_ptk_info {
 	__be16 flags;
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 69fb378..c203544 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -453,6 +453,20 @@ config TCP_CONG_BIC
 	increase provides TCP friendliness.
 	See http://www.csc.ncsu.edu/faculty/rhee/export/bitcp/
 
+config GENEVE
+	tristate "Generic Network Virtualization Encapsulation (Geneve)"
+	depends on INET
+	select NET_IP_TUNNEL
+	select NET_UDP_TUNNEL
+	---help---
+	This allows one to create Geneve virtual interfaces that provide
+	Layer 2 Networks over Layer 3 Networks. Geneve is often used
+	to tunnel virtual network infrastructure in virtualized environments.
+	For more information see:
+	  http://tools.ietf.org/html/draft-gross-geneve-01
+
+	  To compile this driver as a module, choose M here: the module
+
 config TCP_CONG_CUBIC
 	tristate "CUBIC TCP"
 	default y
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index d810578..518c04e 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -56,6 +56,7 @@ obj-$(CONFIG_TCP_CONG_YEAH) += tcp_yeah.o
 obj-$(CONFIG_TCP_CONG_ILLINOIS) += tcp_illinois.o
 obj-$(CONFIG_MEMCG_KMEM) += tcp_memcontrol.o
 obj-$(CONFIG_NETLABEL) += cipso_ipv4.o
+obj-$(CONFIG_GENEVE) += geneve.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o xfrm4_protocol.o
diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
new file mode 100644
index 0000000..f008c55
--- /dev/null
+++ b/net/ipv4/geneve.c
@@ -0,0 +1,373 @@
+/*
+ * Geneve: Generic Network Virtualization Encapsulation
+ *
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
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/module.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/skbuff.h>
+#include <linux/rculist.h>
+#include <linux/netdevice.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/udp.h>
+#include <linux/igmp.h>
+#include <linux/etherdevice.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <linux/hash.h>
+#include <linux/ethtool.h>
+#include <net/arp.h>
+#include <net/ndisc.h>
+#include <net/ip.h>
+#include <net/ip_tunnels.h>
+#include <net/icmp.h>
+#include <net/udp.h>
+#include <net/rtnetlink.h>
+#include <net/route.h>
+#include <net/dsfield.h>
+#include <net/inet_ecn.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+#include <net/geneve.h>
+#include <net/protocol.h>
+#include <net/udp_tunnel.h>
+#if IS_ENABLED(CONFIG_IPV6)
+#include <net/ipv6.h>
+#include <net/addrconf.h>
+#include <net/ip6_tunnel.h>
+#include <net/ip6_checksum.h>
+#endif
+
+#define PORT_HASH_BITS 8
+#define PORT_HASH_SIZE (1<<PORT_HASH_BITS)
+
+/* per-network namespace private data for this module */
+struct geneve_net {
+	struct hlist_head	sock_list[PORT_HASH_SIZE];
+	spinlock_t		sock_lock;   /* Protects sock_list */
+};
+
+static int geneve_net_id;
+
+static struct workqueue_struct *geneve_wq;
+
+static inline struct genevehdr *geneve_hdr(const struct sk_buff *skb)
+{
+	return (struct genevehdr *)(udp_hdr(skb) + 1);
+}
+
+static struct hlist_head *gs_head(struct net *net, __be16 port)
+{
+	struct geneve_net *gn = net_generic(net, geneve_net_id);
+
+	return &gn->sock_list[hash_32(ntohs(port), PORT_HASH_BITS)];
+}
+
+/* Find geneve socket based on network namespace and UDP port */
+static struct geneve_sock *geneve_find_sock(struct net *net, __be16 port)
+{
+	struct geneve_sock *gs;
+
+	hlist_for_each_entry_rcu(gs, gs_head(net, port), hlist) {
+		if (inet_sk(gs->sock->sk)->inet_sport == port)
+			return gs;
+	}
+
+	return NULL;
+}
+
+static void geneve_build_header(struct genevehdr *geneveh,
+				__be16 tun_flags, u8 vni[3],
+				u8 options_len, u8 *options)
+{
+	geneveh->ver = GENEVE_VER;
+	geneveh->opt_len = options_len / 4;
+	geneveh->oam = !!(tun_flags & TUNNEL_OAM);
+	geneveh->critical = !!(tun_flags & TUNNEL_CRIT_OPT);
+	geneveh->rsvd1 = 0;
+	memcpy(geneveh->vni, vni, 3);
+	geneveh->proto_type = htons(ETH_P_TEB);
+	geneveh->rsvd2 = 0;
+
+	memcpy(geneveh->options, options, options_len);
+}
+
+/* Transmit a fully formated Geneve frame.
+ *
+ * When calling this function. The skb->data should point
+ * to the geneve header which is fully formed.
+ *
+ * This function will add other UDP tunnel headers.
+ */
+int geneve_xmit_skb(struct geneve_sock *gs, struct rtable *rt,
+		    struct sk_buff *skb, __be32 src, __be32 dst, __u8 tos,
+		    __u8 ttl, __be16 df, __be16 src_port, __be16 dst_port,
+		    __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
+		    bool xnet)
+{
+	struct genevehdr *gnvh;
+	int min_headroom;
+	int err;
+
+	skb = udp_tunnel_handle_offloads(skb, !gs->sock->sk->sk_no_check_tx);
+
+	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
+			+ GENEVE_BASE_HLEN + opt_len + sizeof(struct iphdr)
+			+ (vlan_tx_tag_present(skb) ? VLAN_HLEN : 0);
+
+	err = skb_cow_head(skb, min_headroom);
+	if (unlikely(err))
+		return err;
+
+	if (vlan_tx_tag_present(skb)) {
+		if (unlikely(!__vlan_put_tag(skb,
+					     skb->vlan_proto,
+					     vlan_tx_tag_get(skb)))) {
+			err = -ENOMEM;
+			return err;
+		}
+		skb->vlan_tci = 0;
+	}
+
+	gnvh = (struct genevehdr *)__skb_push(skb, sizeof(*gnvh) + opt_len);
+	geneve_build_header(gnvh, tun_flags, vni, opt_len, opt);
+
+	return udp_tunnel_xmit_skb(gs->sock, rt, skb, src, dst,
+				   tos, ttl, df, src_port, dst_port, xnet);
+}
+EXPORT_SYMBOL_GPL(geneve_xmit_skb);
+
+static void geneve_notify_add_rx_port(struct geneve_sock *gs)
+{
+	struct sock *sk = gs->sock->sk;
+	sa_family_t sa_family = sk->sk_family;
+	int err;
+
+	if (sa_family == AF_INET) {
+		err = udp_add_offload(&gs->udp_offloads);
+		if (err)
+			pr_warn("geneve: udp_add_offload failed with status %d\n",
+				err);
+	}
+}
+
+/* Callback from net/ipv4/udp.c to receive packets */
+static int geneve_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
+{
+	struct genevehdr *geneveh;
+	struct geneve_sock *gs;
+	int opts_len;
+
+	/* Need Geneve and inner Ethernet header to be present */
+	if (unlikely(!pskb_may_pull(skb, GENEVE_BASE_HLEN)))
+		goto error;
+
+	/* Return packets with reserved bits set */
+	geneveh = geneve_hdr(skb);
+
+	if (unlikely(geneveh->ver != GENEVE_VER))
+		goto error;
+
+	if (unlikely(geneveh->proto_type != htons(ETH_P_TEB)))
+		goto error;
+
+	opts_len = geneveh->opt_len * 4;
+	if (iptunnel_pull_header(skb, GENEVE_BASE_HLEN + opts_len,
+				 htons(ETH_P_TEB)))
+		goto drop;
+
+	gs = rcu_dereference_sk_user_data(sk);
+	if (!gs)
+		goto drop;
+
+	gs->rcv(gs, skb);
+	return 0;
+
+drop:
+	/* Consume bad packet */
+	kfree_skb(skb);
+	return 0;
+
+error:
+	/* Let the UDP layer deal with the skb */
+	return 1;
+}
+
+static void geneve_del_work(struct work_struct *work)
+{
+	struct geneve_sock *gs = container_of(work, struct geneve_sock,
+					      del_work);
+
+	udp_tunnel_sock_release(gs->sock);
+	kfree_rcu(gs, rcu);
+}
+
+static struct socket *geneve_create_sock(struct net *net, bool ipv6,
+					 __be16 port)
+{
+	struct socket *sock;
+	struct udp_port_cfg udp_conf;
+	int err;
+
+	memset(&udp_conf, 0, sizeof(udp_conf));
+
+	if (ipv6) {
+		udp_conf.family = AF_INET6;
+	} else {
+		udp_conf.family = AF_INET;
+		udp_conf.local_ip.s_addr = INADDR_ANY;
+	}
+
+	udp_conf.local_udp_port = port;
+
+	/* Open UDP socket */
+	err = udp_sock_create(net, &udp_conf, &sock);
+	if (err < 0)
+		return ERR_PTR(err);
+
+	return sock;
+}
+
+/* Create new listen socket if needed */
+static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
+						geneve_rcv_t *rcv, void *data,
+						bool ipv6)
+{
+	struct geneve_net *gn = net_generic(net, geneve_net_id);
+	struct geneve_sock *gs;
+	struct socket *sock;
+	struct udp_tunnel_sock_cfg tunnel_cfg;
+
+	gs = kzalloc(sizeof(*gs), GFP_KERNEL);
+	if (!gs)
+		return ERR_PTR(-ENOMEM);
+
+	INIT_WORK(&gs->del_work, geneve_del_work);
+
+	sock = geneve_create_sock(net, ipv6, port);
+	if (IS_ERR(sock)) {
+		kfree(gs);
+		return ERR_CAST(sock);
+	}
+
+	gs->sock = sock;
+	atomic_set(&gs->refcnt, 1);
+	gs->rcv = rcv;
+	gs->rcv_data = data;
+
+	/* Initialize the geneve udp offloads structure */
+	gs->udp_offloads.port = port;
+	gs->udp_offloads.callbacks.gro_receive = NULL;
+	gs->udp_offloads.callbacks.gro_complete = NULL;
+
+	spin_lock(&gn->sock_lock);
+	hlist_add_head_rcu(&gs->hlist, gs_head(net, port));
+	geneve_notify_add_rx_port(gs);
+	spin_unlock(&gn->sock_lock);
+
+	/* Mark socket as an encapsulation socket */
+	tunnel_cfg.sk_user_data = gs;
+	tunnel_cfg.encap_type = 1;
+	tunnel_cfg.encap_rcv = geneve_udp_encap_recv;
+	tunnel_cfg.encap_destroy = NULL;
+	setup_udp_tunnel_sock(net, sock, &tunnel_cfg);
+
+	return gs;
+}
+
+struct geneve_sock *geneve_sock_add(struct net *net, __be16 port,
+				    geneve_rcv_t *rcv, void *data,
+				    bool no_share, bool ipv6)
+{
+	struct geneve_sock *gs;
+
+	gs = geneve_socket_create(net, port, rcv, data, ipv6);
+	if (!IS_ERR(gs))
+		return gs;
+
+	if (no_share)	/* Return error if sharing is not allowed. */
+		return ERR_PTR(-EINVAL);
+
+	gs = geneve_find_sock(net, port);
+	if (gs) {
+		if (gs->rcv == rcv)
+			atomic_inc(&gs->refcnt);
+		else
+			gs = ERR_PTR(-EBUSY);
+	} else {
+		gs = ERR_PTR(-EINVAL);
+	}
+
+	return gs;
+}
+EXPORT_SYMBOL_GPL(geneve_sock_add);
+
+void geneve_sock_release(struct geneve_sock *gs)
+{
+	if (!atomic_dec_and_test(&gs->refcnt))
+		return;
+
+	queue_work(geneve_wq, &gs->del_work);
+}
+EXPORT_SYMBOL_GPL(geneve_sock_release);
+
+static __net_init int geneve_init_net(struct net *net)
+{
+	struct geneve_net *gn = net_generic(net, geneve_net_id);
+	unsigned int h;
+
+	spin_lock_init(&gn->sock_lock);
+
+	for (h = 0; h < PORT_HASH_SIZE; ++h)
+		INIT_HLIST_HEAD(&gn->sock_list[h]);
+
+	return 0;
+}
+
+static struct pernet_operations geneve_net_ops = {
+	.init = geneve_init_net,
+	.exit = NULL,
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
+		return rc;
+
+	pr_info("Geneve driver\n");
+
+	return 0;
+}
+late_initcall(geneve_init_module);
+
+static void __exit geneve_cleanup_module(void)
+{
+	destroy_workqueue(geneve_wq);
+}
+module_exit(geneve_cleanup_module);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Jesse Gross <jesse@nicira.com>");
+MODULE_DESCRIPTION("Driver for GENEVE encapsulated traffic");
+MODULE_ALIAS_RTNL_LINK("geneve");
-- 
1.7.9.5
