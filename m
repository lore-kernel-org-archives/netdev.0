From: Andy Zhou <azhou@nicira.com>
Subject: [net-next 05/10] net: Add Geneve tunneling protocol driver
Date: Tue, 22 Jul 2014 03:19:48 -0700
Message-ID: <1406024393-6778-6-git-send-email-azhou@nicira.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:55691 "HELO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751471AbaGVKbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 06:31:52 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so10900386pde.23
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 03:31:46 -0700 (PDT)
In-Reply-To: <1406024393-6778-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a device level support for Geneve -- Generic Network
Virtualization Encapsulation. The protocol is documented at
http://tools.ietf.org/html/draft-gross-geneve-00

Only protocol layer Geneve support is provided by this driver.
Openvswitch can be used for configuring, set up and tear down
functional Geneve tunnels.

Signed-off-by: Jesse Gross <jesse@nicira.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 include/net/geneve.h     |   85 +++++++++++++++
 include/net/ip_tunnels.h |    2 +
 net/ipv4/Kconfig         |   14 +++
 net/ipv4/Makefile        |    1 +
 net/ipv4/geneve.c        |  273 ++++++++++++++++++++++++++++++++++++++++++++++
 net/openvswitch/Kconfig  |   11 ++
 net/openvswitch/vport.c  |    3 +
 7 files changed, 389 insertions(+)
 create mode 100644 include/net/geneve.h
 create mode 100644 net/ipv4/geneve.c

diff --git a/include/net/geneve.h b/include/net/geneve.h
new file mode 100644
index 0000000..4e3a301
--- /dev/null
+++ b/include/net/geneve.h
@@ -0,0 +1,85 @@
+#ifndef __NET_GENEVE_H
+#define __NET_GENEVE_H  1
+
+#include <net/udp_tunnel.h>
+
+struct geneve_sock {
+	struct udp_tunnel_sock  uts;
+	atomic_t		refcnt;
+	struct udp_offload	udp_offloads;
+};
+
+typedef void (geneve_rcv_t)(struct geneve_sock *gs, struct sk_buff *skb);
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
+#define GENEVE_CRIT_OPT_TYPE (1 << 7)
+
+struct geneve_sock *geneve_sock_add(struct net *net, __be16 port,
+				    geneve_rcv_t *rcv, void *data,
+				    bool no_share, bool ipv6);
+
+void geneve_sock_release(struct geneve_sock *vs);
+
+int geneve_xmit_skb(struct geneve_sock *gs,
+		   struct rtable *rt, struct sk_buff *skb,
+		   __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
+		   __be16 src_port, __be16 dst_port, __be16 tun_flags,
+		   u8 vni[3], u8 opt_len, u8 *opt, bool xnet);
+
+#endif
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index a4daf9e..2e221cd 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -81,6 +81,8 @@ struct ip_tunnel {
 #define TUNNEL_VERSION	__cpu_to_be16(0x40)
 #define TUNNEL_NO_KEY	__cpu_to_be16(0x80)
 #define TUNNEL_DONT_FRAGMENT    __cpu_to_be16(0x0100)
+#define TUNNEL_OAM	__cpu_to_be16(0x0200)
+#define TUNNEL_CRIT_OPT	__cpu_to_be16(0x0400)
 
 struct tnl_ptk_info {
 	__be16 flags;
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index dbc10d8..69cb508 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -595,6 +595,20 @@ endchoice
 
 endif
 
+config GENEVE
+       tristate "Generic Network Virtualization Encapsulation (Geneve)"
+       depends on INET
+       select NET_IP_TUNNEL
+       select NET_UDP_TUNNEL
+       ---help---
+	  This allows one to create Geneve virtual interfaces that provide
+	  Layer 2 Networks over Layer 3 Networks. Geneve is often used
+	  to tunnel virtual network infrastructure in virtualized environments.
+	  For more information see:
+	    http://tools.ietf.org/html/draft-gross-geneve-00
+
+	  To compile this driver as a module, choose M here: the module
+
 config TCP_CONG_CUBIC
 	tristate
 	depends on !TCP_CONG_ADVANCED
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 8ee1cd4..cae2403 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -54,6 +54,7 @@ obj-$(CONFIG_TCP_CONG_YEAH) += tcp_yeah.o
 obj-$(CONFIG_TCP_CONG_ILLINOIS) += tcp_illinois.o
 obj-$(CONFIG_MEMCG_KMEM) += tcp_memcontrol.o
 obj-$(CONFIG_NETLABEL) += cipso_ipv4.o
+obj-$(CONFIG_GENEVE) += geneve.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o xfrm4_protocol.o
diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
new file mode 100644
index 0000000..2fda60e
--- /dev/null
+++ b/net/ipv4/geneve.c
@@ -0,0 +1,273 @@
+/* Copyright (c) 2014 Nicira, Inc.  */
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
+static inline struct genevehdr *geneve_hdr(const struct sk_buff *skb)
+{
+	return (struct genevehdr *)(udp_hdr(skb) + 1);
+}
+
+/* Find geneve socket based on network namespace and UDP port */
+static struct geneve_sock *geneve_find_sock(struct net *net, __be16 port)
+{
+	return (struct geneve_sock *)udp_tunnel_find_sock(net, port);
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
+int geneve_xmit_skb(struct geneve_sock *gs,
+		    struct rtable *rt, struct sk_buff *skb,
+		    __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
+		    __be16 src_port, __be16 dst_port,
+		    __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
+		    bool xnet)
+{
+	struct genevehdr *gnvh;
+	int min_headroom;
+	int err;
+
+	skb = udp_tunnel_handle_offloads(skb, !udp_get_no_check6_tx(gs->uts.sock->sk));
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
+	gnvh = (struct genevehdr *)__skb_push(skb, sizeof(*gnvh));
+	geneve_build_header(gnvh, tun_flags, vni, opt_len, opt);
+
+	return udp_tunnel_xmit_skb(gs->uts.sock, rt, skb, src, dst,
+				   tos, ttl, df, src_port, dst_port, xnet);
+}
+EXPORT_SYMBOL_GPL(geneve_xmit_skb);
+
+static void geneve_notify_add_rx_port(struct geneve_sock *gs)
+{
+	struct net_device *dev;
+	struct sock *sk = gs->uts.sock->sk;
+	struct net *net = sock_net(sk);
+	sa_family_t sa_family = sk->sk_family;
+	__be16 port = inet_sk(sk)->inet_sport;
+	int err;
+
+	if (sa_family == AF_INET) {
+		err = udp_add_offload(&gs->udp_offloads);
+		if (err)
+			pr_warn("geneve: udp_add_offload failed with status %d\n", err);
+	}
+
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev) {
+		if (!dev->netdev_ops->ndo_add_udp_tunnel_port)
+			continue;
+
+		dev->netdev_ops->ndo_add_udp_tunnel_port(dev, sa_family, port,
+						       UDP_TUNNEL_TYPE_GENEVE);
+	}
+	rcu_read_unlock();
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
+	opts_len = geneveh->opt_len * 4;
+	if (iptunnel_pull_header(skb, GENEVE_BASE_HLEN + opts_len,
+				 htons(ETH_P_TEB)))
+		goto drop;
+
+	gs = rcu_dereference_sk_user_data(sk);
+	if (!gs)
+		goto drop;
+
+	skb_pop_rcv_encapsulation(skb);
+
+	gs->uts.rcv(&gs->uts, skb);
+	return 0;
+
+drop:
+	/* Consume bad packet */
+	kfree_skb(skb);
+	return 0;
+
+error:
+	kfree_skb(skb);
+	return 1;
+}
+
+/* Create new listen socket if needed */
+static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
+						geneve_rcv_t *rcv, void *data,
+						bool ipv6)
+{
+	struct geneve_sock *gs;
+	struct udp_tunnel_socket_cfg geneve_ts_cfg;
+
+	memset(&geneve_ts_cfg, 0, sizeof(struct udp_tunnel_socket_cfg));
+
+	if (ipv6) {
+		geneve_ts_cfg.port.family = AF_INET6;
+	} else {
+		geneve_ts_cfg.port.family = AF_INET;
+		geneve_ts_cfg.port.local_ip.s_addr = INADDR_ANY;
+	}
+
+	geneve_ts_cfg.tunnel_type = UDP_TUNNEL_TYPE_GENEVE;
+	geneve_ts_cfg.port.local_udp_port = port;
+	geneve_ts_cfg.rcv = (udp_tunnel_rcv_t *)rcv;
+	geneve_ts_cfg.encap_rcv = geneve_udp_encap_recv;
+	geneve_ts_cfg.data = data;
+
+	gs = (struct geneve_sock *)create_udp_tunnel_socket(net, sizeof(*gs),
+							    &geneve_ts_cfg);
+	if (!gs)
+		return ERR_PTR(-ENOMEM);
+
+	atomic_set(&gs->refcnt, 1);
+
+	/* Initialize the geneve udp offloads structure */
+	gs->udp_offloads.port = port;
+	gs->udp_offloads.callbacks.gro_receive = NULL;
+	gs->udp_offloads.callbacks.gro_complete = NULL;
+
+	geneve_notify_add_rx_port(gs);
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
+		if (gs->uts.rcv == (udp_tunnel_rcv_t *)rcv)
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
+	udp_tunnel_sock_release(&gs->uts);
+}
+EXPORT_SYMBOL_GPL(geneve_sock_release);
+
+static int __init geneve_init_module(void)
+{
+	pr_info("Geneve driver\n");
+
+	return 0;
+}
+late_initcall(geneve_init_module);
+
+static void __exit geneve_cleanup_module(void)
+{
+}
+module_exit(geneve_cleanup_module);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Jesse Gross <jesse@nicira.com>");
+MODULE_DESCRIPTION("Driver for GENEVE encapsulated traffic");
+MODULE_ALIAS_RTNL_LINK("geneve");
diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index 6ecf491..ba3bb82 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -54,3 +54,14 @@ config OPENVSWITCH_VXLAN
 	  Say N to exclude this support and reduce the binary size.
 
 	  If unsure, say Y.
+
+config OPENVSWITCH_GENEVE
+	bool "Open vSwitch Geneve tunneling support"
+	depends on INET
+	depends on OPENVSWITCH
+	depends on GENEVE && !(OPENVSWITCH=y && GENEVE=m)
+	default y
+	---help---
+	  If you say Y here, then the Open vSwitch will be able create geneve vport.
+
+	  Say N to exclude this support and reduce the binary size.
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 42c0f4a..5b4cb82 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -48,6 +48,9 @@ static const struct vport_ops *vport_ops_list[] = {
 #ifdef CONFIG_OPENVSWITCH_VXLAN
 	&ovs_vxlan_vport_ops,
 #endif
+#ifdef CONFIG_OPENVSWITCH_GENEVE
+	&ovs_geneve_vport_ops,
+#endif
 };
 
 /* Protected by RCU read lock for reading, ovs_mutex for writing. */
-- 
1.7.9.5
