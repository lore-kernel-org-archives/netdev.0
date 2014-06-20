From: Christopher White <chris@logicalelegance.com>
Subject: [PATCH V5 net-next] LISP: Locator/Identifier Separation Protocol
Date: Thu, 19 Jun 2014 21:47:46 -0700
Message-ID: <BC8091AB-E852-422D-8759-E0AE1EB4BD46@logicalelegance.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Vina Ermagan (vermagan)" <vermagan@cisco.com>,
	"Lorand Jakab -X (lojakab - M SQUARED CONSULTING INC. at Cisco)"
	<lojakab@cisco.com>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.webfaction.com ([74.55.86.74]:48463 "EHLO
	smtp.webfaction.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932514AbaFTErt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 00:47:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a static tunnel implementation of LISP as described in RFC 6830:
  http://tools.ietf.org/html/rfc6830

This driver provides point-to-point LISP dataplane
encapsulation/decapsulation for statically configured endpoints. It provides
support for IPv4 in IPv4 and IPv6 in IPv4. IPv6 outer headers are not
supported yet. Instance ID is supported on a per device basis.

This implementation has been tested against LISPMob.

Changes from V2: Move some functions to common headers. Remove unecessary skb
ownership change. Minor cleanup.
Changes from V3: Revert some generic function consolidation for later patches.
Changes from V4: Indentation (Note V4 was erroneously marked V3)
Signed-off-by: Chris White <chris@logicalelegance.com>
---
 drivers/net/Kconfig          |   12 +
 drivers/net/Makefile         |    1 +
 drivers/net/lisp.c           |  899 ++++++++++++++++++++++++++++++++++++++++++
 drivers/net/vxlan.c          |   22 +-
 include/net/route.h          |   21 +
 include/net/udp.h            |   21 +
 include/uapi/linux/if_link.h |   17 +
 7 files changed, 973 insertions(+), 20 deletions(-)
 create mode 100644 drivers/net/lisp.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 89402c3..5d49b1e 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -158,6 +158,18 @@ config VXLAN
 	  To compile this driver as a module, choose M here: the module
 	  will be called vxlan.
 
+config LISP
+       tristate "Locator Identifier Separation Protocol (LISP)"
+       depends on INET
+       select NET_IP_TUNNEL
+       ---help---
+       Create a LISP virtual interface that provides static LISP tunnel
+       encapsulation. For more information see:
+         http://tools.ietf.org/html/rfc6830
+
+       To compile this driver as a module, choose M here: the module will be
+       called lisp.
+
 config NETCONSOLE
 	tristate "Network console logging support"
 	---help---
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 3fef8a8..943590d 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -23,6 +23,7 @@ obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_VXLAN) += vxlan.o
 obj-$(CONFIG_NLMON) += nlmon.o
+obj-$(CONFIG_LISP) += lisp.o
 
 #
 # Networking Drivers
diff --git a/drivers/net/lisp.c b/drivers/net/lisp.c
new file mode 100644
index 0000000..c50bc93
--- /dev/null
+++ b/drivers/net/lisp.c
@@ -0,0 +1,899 @@
+/*
+ * lisp.c
+ * This file is part of LISP Implementation.
+ * It provides a netdevice for static tunneling between LISP
+ * devices. IPv4 encapsulation is currently supported.
+ *
+ * Copyright (C) 2014 Cisco Systems, Inc, 2014. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * Written or modified by:
+ * Chris White <chris@logicalelegance.com>
+ *
+ */
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
+#if IS_ENABLED(CONFIG_IPV6)
+#include <net/ipv6.h>
+#include <net/addrconf.h>
+#include <net/ip6_tunnel.h>
+#include <net/ip6_checksum.h>
+#endif
+#include <net/route.h>
+#include <net/xfrm.h>
+#include <linux/in_route.h>
+#include <linux/version.h>
+
+#define LISP_VERSION "0.1"
+
+static inline void vlan_set_tci(struct sk_buff *skb, u16 vlan_tci)
+{
+	skb->vlan_tci = vlan_tci;
+}
+
+#define PORT_HASH_BITS  8
+#define PORT_HASH_SIZE  (1 << PORT_HASH_BITS)
+
+/**
+ * struct lisphdr - LISP header
+ * @nonce_present: Flag indicating the presence of a 24 bit nonce value.
+ * @locator_status_bits_present: Flag indicating the presence of Locator Status
+ *                               Bits (LSB).
+ * @solicit_echo_nonce: Flag indicating the use of the echo noncing mechanism.
+ * @map_version_present: Flag indicating the use of mapping versioning.
+ * @instance_id_present: Flag indicating the presence of a 24 bit Instance ID.
+ * @reserved_flags: 3 bits reserved for future flags.
+ * @nonce: 24 bit nonce value.
+ * @map_version: 24 bit mapping version.
+ * @locator_status_bits: Locator Status Bits: 32 bits when instance_id_present
+ *                       is not set, 8 bits when it is.
+ * @instance_id: 24 bit Instance ID
+ */
+struct lisphdr {
+#ifdef __LITTLE_ENDIAN_BITFIELD
+	__u8	reserved_flags : 3;
+	__u8	instance_id_present : 1;
+	__u8	map_version_present : 1;
+	__u8	solicit_echo_nonce : 1;
+	__u8	locator_status_bits_present : 1;
+	__u8	nonce_present : 1;
+#else
+	__u8	nonce_present : 1;
+	__u8	locator_status_bits_present : 1;
+	__u8	solicit_echo_nonce : 1;
+	__u8	map_version_present : 1;
+	__u8	instance_id_present : 1;
+	__u8	reserved_flags : 3;
+#endif
+	union {
+		__u8	nonce[3];
+		__u8	map_version[3];
+	} u1;
+	union {
+		__be32 locator_status_bits;
+		struct {
+			__u8	instance_id[3];
+			__u8	locator_status_bits;
+		} word2;
+	} u2;
+};
+
+#define LISP_HLEN (sizeof(struct udphdr) + sizeof(struct lisphdr))
+
+/* UDP port for LISP traffic.
+ * The IANA assigned port is 4341.
+ */
+static unsigned short lisp_port __read_mostly = 4341;
+module_param_named(udp_port, lisp_port, ushort, 0444);
+MODULE_PARM_DESC(udp_port, "Destination UDP port");
+static int lisp_net_id;
+
+/* per-network namespace private data for this module */
+struct lisp_net {
+	struct list_head	lisp_list;
+	struct hlist_head	sock_list[PORT_HASH_SIZE];
+	spinlock_t		sock_lock;
+};
+
+union lisp_addr {
+struct sockaddr_in	sin;
+	struct sockaddr_in6	sin6;
+	struct sockaddr		sa;
+};
+
+#define IID_HASH_BITS   10
+#define IID_HASH_SIZE   (1 << IID_HASH_BITS)
+
+struct lisp_sock;
+typedef void (lisp_rcv_t)(struct lisp_sock *ls, struct sk_buff *skb);
+
+/* per UDP socket information */
+struct lisp_sock {
+	struct hlist_node	hlist;
+	lisp_rcv_t         *rcv;
+	void               *data;
+	struct      work_struct del_work;
+	struct      socket *sock;
+	struct rcu_head		rcu;
+	struct hlist_head	iid_list[IID_HASH_SIZE];
+	atomic_t		refcnt;
+};
+
+/* LISP psuedo network device */
+struct lisp_dev {
+	struct hlist_node	hlist;
+	struct list_head	next;
+	struct net_device	*dev;
+	u32			iid;            /* Instance ID */
+	struct lisp_sock	*ls_socket; /* Input socket */
+	__be16			rcv_port;   /* Listen port to receive packets */
+	__be16			encap_port; /* Dest port for encaped packets */
+	__u8			tos;
+	__u8			ttl;
+	u32			flags;
+	union lisp_addr		remote; /* Tunnel dst (RLOC) */
+	union lisp_addr		local;  /* Tunnel src (our RLOC) */
+	struct work_struct	sock_work;
+};
+
+#define LISP_F_UDP_CSUM 0x1
+
+static struct workqueue_struct *lisp_wq;
+
+/* Instance ID hash table head */
+static inline struct hlist_head *iid_head(struct lisp_sock *s, u32 iid)
+{
+	return &s->iid_list[hash_32(iid, IID_HASH_BITS)];
+}
+
+/* Socket hash table head */
+static inline struct hlist_head *s_head(struct net *net, __be16 port)
+{
+	struct lisp_net *ln = net_generic(net, lisp_net_id);
+
+	return &ln->sock_list[hash_32(ntohs(port), PORT_HASH_BITS)];
+}
+
+/* Find LISP socket based on network namespace and UDP port */
+static struct lisp_sock *lisp_find_sock(struct net *net, __be16 port)
+{
+	struct lisp_sock *s;
+
+	hlist_for_each_entry_rcu(s, s_head(net, port), hlist) {
+		if (inet_sk(s->sock->sk)->inet_sport == port)
+			return s;
+	}
+	return NULL;
+}
+
+/* Find device based on IID */
+static struct lisp_dev *lisp_find_iid(struct lisp_sock *s, u32 iid)
+{
+	struct lisp_dev *lispdev;
+
+	hlist_for_each_entry_rcu(lispdev, iid_head(s, iid), hlist) {
+		if (lispdev->iid == iid)
+			return lispdev;
+	}
+	return NULL;
+}
+
+static void lisp_sock_add_dev(struct lisp_sock *s, struct lisp_dev *dev)
+{
+	__u32 iid = dev->iid;
+
+	dev->ls_socket = s;
+	hlist_add_head_rcu(&dev->hlist, iid_head(s, iid));
+}
+
+static int lisp_init(struct net_device *dev)
+{
+	struct lisp_dev *lispdev = netdev_priv(dev);
+	struct lisp_net *ln = net_generic(dev_net(dev), lisp_net_id);
+	struct lisp_sock *s;
+	int i;
+
+	/* Allocate stats space */
+	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
+	if (!dev->tstats)
+		return -ENOMEM;
+
+	for_each_possible_cpu(i) {
+		struct pcpu_sw_netstats *lisp_stats;
+
+		lisp_stats = per_cpu_ptr(dev->tstats, i);
+		u64_stats_init(&lisp_stats->syncp);
+	}
+
+	/* Create port, if necessary */
+	spin_lock(&ln->sock_lock);
+	s = lisp_find_sock(dev_net(dev), lispdev->rcv_port);
+	if (s) {
+		/* Reuse the socket if it's the same port */
+		atomic_inc(&s->refcnt);
+		lisp_sock_add_dev(s, lispdev);
+	} else {
+		/* Make a new socket */
+		dev_hold(dev);
+		queue_work(lisp_wq, &lispdev->sock_work);
+	}
+	spin_unlock(&ln->sock_lock);
+	return 0;
+}
+
+void lisp_sock_release(struct lisp_sock *s)
+{
+	struct sock *sk = s->sock->sk;
+	struct net *net = sock_net(sk);
+	struct lisp_net *ln = net_generic(net, lisp_net_id);
+
+	if (!atomic_dec_and_test(&s->refcnt))
+		return;
+	spin_lock(&ln->sock_lock);
+	hlist_del_rcu(&s->hlist);
+	rcu_assign_sk_user_data(s->sock->sk, NULL);
+	spin_unlock(&ln->sock_lock);
+	queue_work(lisp_wq, &s->del_work);
+}
+EXPORT_SYMBOL_GPL(lisp_sock_release);
+
+static void lisp_uninit(struct net_device *dev)
+{
+	struct lisp_dev *lispdev = netdev_priv(dev);
+	struct lisp_sock *s = lispdev->ls_socket;
+
+	if (s)
+		lisp_sock_release(s);
+	free_percpu(dev->tstats);
+}
+
+static int lisp_change_mtu(struct net_device *dev, int new_mtu)
+{
+	return eth_change_mtu(dev, new_mtu);
+}
+
+static inline struct sk_buff *lisp_handle_offloads(struct sk_buff *skb,
+						   bool udp_csum)
+{
+	int type = udp_csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
+
+	return iptunnel_handle_offloads(skb, udp_csum, type);
+}
+
+static void lisp_build_header(const struct lisp_dev *dev,
+			      struct sk_buff *skb, u32 saddr, u32 daddr)
+{
+	struct udphdr *udph = udp_hdr(skb);
+	struct lisphdr *lisph = (struct lisphdr *)(udph + 1);
+	struct net *net = dev_net(dev->dev);
+	__u32 iid;
+	int high, low;
+
+	udph->dest = dev->encap_port;
+
+	inet_get_local_port_range(net, &low, &high);
+	udph->source = udp_tunnel_get_src_port(low, high, skb);
+	udph->len = htons(skb->len - skb_transport_offset(skb));
+
+	/* We don't support echo nonce algorithm */
+	lisph->nonce_present = 0;
+	lisph->locator_status_bits_present = 1; /* Set LSB */
+	lisph->solicit_echo_nonce = 0;          /* No echo noncing */
+
+	/* No mapping versioning, nonce instead */
+	lisph->map_version_present = 0;
+
+	/* Store the tun_id as Instance ID  */
+	lisph->instance_id_present = 1;
+
+	/* Reserved flags, set to 0  */
+	lisph->reserved_flags = 0;
+	lisph->u1.nonce[0] = 0;
+	lisph->u1.nonce[1] = 0;
+	lisph->u1.nonce[2] = 0;
+
+	/* Include the instance ID for this device */
+	iid = htonl(dev->iid << 8);
+	memcpy(&lisph->u2.word2.instance_id, &iid, 3);
+	lisph->u2.word2.locator_status_bits = 1;
+
+	udp_set_csum(dev->ls_socket->sock->sk, skb, saddr, daddr,
+		     skb->len);
+}
+
+/* Transmit local sourced packets with LISP encapsulation
+ */
+static netdev_tx_t lisp_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct lisp_dev *lispdev = netdev_priv(dev);
+	struct net *net = dev_net(lispdev->dev);
+	struct lisp_sock *s = lispdev->ls_socket;
+	struct rtable *rt;
+	int min_headroom;
+	__be32 saddr;
+	__be32 daddr;
+	__be16 df;
+	int sent_len;
+	int err;
+
+	if (skb->protocol != htons(ETH_P_IP) &&
+	    skb->protocol != htons(ETH_P_IPV6)) {
+		kfree_skb(skb);
+		return 0;
+	}
+
+	/* Route lookup */
+	saddr = lispdev->local.sin.sin_addr.s_addr;
+	daddr = lispdev->remote.sin.sin_addr.s_addr;
+	rt = ip_route_output_mark(net,
+				  &saddr,
+				  daddr,
+				  IPPROTO_UDP,
+				  lispdev->tos,
+				  skb->mark);
+	if (IS_ERR(rt)) {
+		err = PTR_ERR(rt);
+		goto error;
+	}
+	skb = lisp_handle_offloads(skb,
+				   s->sock->sk->sk_no_check_tx);
+
+	if (IS_ERR(skb))
+		goto rx_tx_err;
+
+	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
+		+ sizeof(struct iphdr) + LISP_HLEN;
+
+	if (skb_headroom(skb) < min_headroom || skb_header_cloned(skb)) {
+		int head_delta = SKB_DATA_ALIGN(min_headroom -
+						skb_headroom(skb) +
+						16);
+
+		err = pskb_expand_head(skb, max_t(int, head_delta, 0),
+				       0, GFP_ATOMIC);
+		if (unlikely(err))
+			goto err_free_rt;
+	}
+
+	skb_reset_inner_headers(skb);
+
+	__skb_push(skb, LISP_HLEN);
+	skb_reset_transport_header(skb);
+
+	lisp_build_header(lispdev, skb, saddr, daddr);
+
+	/* Offloading */
+	skb->ignore_df = 1;
+
+	df = 0;
+	sent_len = iptunnel_xmit(lispdev->ls_socket->sock->sk, rt, skb,
+				 saddr, daddr,
+				 IPPROTO_UDP, lispdev->tos,
+				 lispdev->ttl, df, false);
+
+	iptunnel_xmit_stats(sent_len, &dev->stats, dev->tstats);
+	return NETDEV_TX_OK;
+
+rx_tx_err:
+	dev->stats.tx_errors++;
+err_free_rt:
+	ip_rt_put(rt);
+error:
+	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
+	return NETDEV_TX_OK;
+}
+
+static void lisp_rcv(struct lisp_sock *s,
+		     struct sk_buff *skb)
+{
+	struct lisp_dev *lispdev;
+	struct iphdr *iph, *inner_iph;
+	struct lisphdr *lisph;
+	struct pcpu_sw_netstats *stats;
+	__be16 protocol;
+	__u32 iid = 0;
+
+	iph = ip_hdr(skb);
+	lisph = (struct lisphdr *)(udp_hdr(skb) + 1);
+	inner_iph = (struct iphdr *)(lisph + 1);
+	switch (inner_iph->version) {
+	case 4:
+		protocol = htons(ETH_P_IP);
+		break;
+	case 6:
+		protocol = htons(ETH_P_IPV6);
+		break;
+	default:
+		kfree_skb(skb);
+		return;
+	}
+
+	if (lisph->instance_id_present)
+		iid = ntohl(*((__be32 *)(&lisph->u2.word2.instance_id))) >> 8;
+
+	/* Find the IID in our configuration */
+	lispdev = lisp_find_iid(s, iid);
+	if (!lispdev) {
+		netdev_info(lispdev->dev, "Instance ID 0x%x not found\n", iid);
+		goto drop;
+	}
+
+	skb->protocol = protocol;
+	skb->dev = lispdev->dev;
+	skb_reset_network_header(skb);
+
+	stats = this_cpu_ptr(lispdev->dev->tstats);
+	u64_stats_update_begin(&stats->syncp);
+	stats->rx_packets++;
+	stats->rx_bytes += skb->len;
+	u64_stats_update_end(&stats->syncp);
+
+	netif_rx(skb);
+	return;
+drop:
+	kfree_skb(skb);
+}
+
+
+/* Callback from net/ipv4/udp.c to receive packets */
+static int lisp_udp_encap_rcv(struct sock *sk, struct sk_buff *skb)
+{
+	struct lisp_sock *s;
+	__be16 port;
+
+	if (!pskb_may_pull(skb, LISP_HLEN))
+		goto error;
+
+	if (iptunnel_pull_header(skb, LISP_HLEN, 0))
+		goto drop;
+
+	port = inet_sk(sk)->inet_sport;
+	s = rcu_dereference_sk_user_data(sk);
+	if (!s)
+		goto drop;
+
+	/* If the NIC driver gave us an encapsulated packet
+	 * with the encapsulation mark, the device checksummed it
+	 * for us. Otherwise force the upper layers to verify it.
+	 */
+	if ((skb->ip_summed != CHECKSUM_UNNECESSARY &&
+	     skb->ip_summed != CHECKSUM_PARTIAL) ||
+	    !skb->encapsulation)
+		skb->ip_summed = CHECKSUM_NONE;
+
+	skb->encapsulation = 0;
+	lisp_rcv(s, skb);
+	return 0;
+drop:
+	kfree_skb(skb);
+	return 0;
+error:
+	return 1;
+}
+
+static const struct net_device_ops lisp_netdev_ops = {
+	.ndo_init		= lisp_init,
+	.ndo_uninit		= lisp_uninit,
+	.ndo_start_xmit		= lisp_xmit,
+	.ndo_get_stats64	= ip_tunnel_get_stats64,
+	.ndo_change_mtu		= lisp_change_mtu
+};
+
+/* Info for udev */
+static struct device_type lisp_type = {
+	.name	= "lisp",
+};
+
+static void lisp_del_work(struct work_struct *work)
+{
+	struct lisp_sock *ls = container_of(work, struct lisp_sock, del_work);
+
+	sk_release_kernel(ls->sock->sk);
+	kfree_rcu(ls, rcu);
+}
+
+static int create_v4_encap_sock(struct net *net, __be16 port,
+				struct socket **psock,
+				bool csum)
+{
+	struct sock *sk;
+	struct socket *sock;
+	struct sockaddr_in lisp_addr = {
+		.sin_family		= AF_INET,
+		.sin_addr.s_addr	= htonl(INADDR_ANY),
+		.sin_port		= port,
+	};
+	int rc;
+
+	/* Create UDP socket for encapsulation receive. */
+	rc = sock_create_kern(AF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	if (rc < 0) {
+		pr_debug("UDP socket create failed\n");
+		return rc;
+	}
+
+	/* Put in proper namespace */
+	sk = sock->sk;
+	sk_change_net(sk, net);
+
+	rc = kernel_bind(sock, (struct sockaddr *)&lisp_addr,
+			 sizeof(lisp_addr));
+	if (rc < 0) {
+		pr_debug("bind for UDP socket %pI4:%u (%d)\n",
+			 &lisp_addr.sin_addr, ntohs(lisp_addr.sin_port), rc);
+		sk_release_kernel(sk);
+		return rc;
+	}
+
+	*psock = sock;
+	/* Disable multicast loopback */
+	inet_sk(sk)->mc_loop = 0;
+
+	if (!csum)
+		sock->sk->sk_no_check_tx = 1;
+	return 0;
+}
+
+/* Create new listen socket */
+static struct lisp_sock *lisp_socket_create(struct net *net, __be16 port,
+					    lisp_rcv_t *rcv, void *data,
+					    u32 flags)
+{
+	struct lisp_net *ln = net_generic(net, lisp_net_id);
+	struct lisp_sock *s;
+	struct socket *sock;
+	struct sock *sk;
+	int rc = 0;
+	unsigned int h;
+
+	s = kmalloc(sizeof(*s), GFP_KERNEL);
+	if (!s)
+		return ERR_PTR(-ENOMEM);
+
+	for (h = 0; h < IID_HASH_SIZE; ++h)
+		INIT_HLIST_HEAD(&s->iid_list[h]);
+
+	INIT_WORK(&s->del_work, lisp_del_work);
+
+	rc = create_v4_encap_sock(net, port, &sock,
+				  (flags & LISP_F_UDP_CSUM));
+	if (rc < 0) {
+		kfree(s);
+		return ERR_PTR(rc);
+	}
+
+	s->sock = sock;
+	atomic_set(&s->refcnt, 1);
+	sk = sock->sk;
+	s->rcv = rcv;
+	s->data = data;
+	rcu_assign_sk_user_data(s->sock->sk, s);
+
+	spin_lock(&ln->sock_lock);
+	hlist_add_head_rcu(&s->hlist, s_head(net, port));
+	spin_unlock(&ln->sock_lock);
+	udp_sk(sk)->encap_type = 1;
+	udp_sk(sk)->encap_rcv = lisp_udp_encap_rcv;
+	udp_encap_enable();
+
+	return s;
+}
+
+struct lisp_sock *lisp_sock_add(struct net *net, __be16 port, lisp_rcv_t *rcv,
+				void *data, u32 flags)
+{
+	struct lisp_net *ln = net_generic(net, lisp_net_id);
+	struct lisp_sock *s;
+
+	s = lisp_socket_create(net, port, rcv, data, flags);
+	if (!IS_ERR(s))
+		return s;
+
+	spin_lock(&ln->sock_lock);
+	s = lisp_find_sock(net, port);
+	if (s) {
+		if (s->rcv == rcv)
+			atomic_inc(&s->refcnt);
+		else
+			s = ERR_PTR(-EBUSY);
+	}
+	spin_unlock(&ln->sock_lock);
+
+	if (!s)
+		s = ERR_PTR(-EINVAL);
+	return s;
+}
+
+/* Scheduled at device creation to bind to a socket */
+static void lisp_sock_work(struct work_struct *work)
+{
+	struct lisp_dev *lispdev = container_of(work, struct lisp_dev,
+						sock_work);
+	struct net *net = dev_net(lispdev->dev);
+	struct lisp_net *ln = net_generic(net, lisp_net_id);
+	__be16 port = lispdev->rcv_port;
+	struct lisp_sock *s;
+
+	s = lisp_sock_add(net, port, lisp_rcv, NULL, lispdev->flags);
+	spin_lock(&ln->sock_lock);
+	if (!IS_ERR(s))
+		lisp_sock_add_dev(s, lispdev);
+	spin_unlock(&ln->sock_lock);
+
+	dev_put(lispdev->dev);
+}
+
+/* Init the device structure. */
+static void lisp_setup(struct net_device *dev)
+{
+	struct lisp_dev *lispdev = netdev_priv(dev);
+
+	dev->type = ARPHRD_NONE;
+	dev->flags = IFF_NOARP;
+	dev->addr_len = 4;
+	dev->needed_headroom = LL_MAX_HEADER + sizeof(struct lisphdr) + 4;
+	dev->mtu = ETH_DATA_LEN - sizeof(struct lisphdr) - 4;
+
+	dev->netdev_ops = &lisp_netdev_ops;
+	dev->destructor = free_netdev;
+	SET_NETDEV_DEVTYPE(dev, &lisp_type);
+
+	dev->tx_queue_len = 0;
+	dev->features |= (NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_NETNS_LOCAL |
+			  NETIF_F_RXCSUM | NETIF_F_GSO_SOFTWARE);
+	dev->hw_features |= (NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_RXCSUM |
+			     NETIF_F_GSO_SOFTWARE);
+	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
+
+	INIT_LIST_HEAD(&lispdev->next);
+	INIT_WORK(&lispdev->sock_work, lisp_sock_work);
+
+	lispdev->rcv_port = htons(lisp_port);
+	lispdev->dev = dev;
+}
+
+static const struct nla_policy lisp_policy[IFLA_LISP_MAX + 1] = {
+	[IFLA_LISP_IID] =	  { .type = NLA_U32		    },
+	[IFLA_LISP_LOCAL] =	  { .len  = FIELD_SIZEOF(struct iphdr, daddr)},
+	[IFLA_LISP_LOCAL6] =	  { .len  = sizeof(struct in6_addr) },
+	[IFLA_LISP_REMOTE] =	  { .len  = FIELD_SIZEOF(struct iphdr, daddr)},
+	[IFLA_LISP_REMOTE6] =	  { .len  = sizeof(struct in6_addr) },
+	[IFLA_LISP_ENCAP_PORT] =  { .type = NLA_U16		    },
+	[IFLA_LISP_LISTEN_PORT] = { .type = NLA_U16		    },
+	[IFLA_LISP_TOS] =	  { .type = NLA_U8		    },
+	[IFLA_LISP_TTL] =	  { .type = NLA_U8		    }
+};
+
+static int lisp_newlink(struct net *net, struct net_device *dev,
+			struct nlattr *tb[], struct nlattr *data[])
+{
+	struct lisp_net *ln = net_generic(net, lisp_net_id);
+	struct lisp_dev *lispdev = netdev_priv(dev);
+	int err = 0;
+
+	if (data[IFLA_LISP_IID])
+		lispdev->iid = nla_get_be32(data[IFLA_LISP_IID]);
+
+	if (data[IFLA_LISP_LOCAL]) {
+		lispdev->local.sin.sin_addr.s_addr =
+			nla_get_be32(data[IFLA_LISP_LOCAL]);
+		lispdev->local.sa.sa_family = AF_INET;
+	}
+
+	if (data[IFLA_LISP_ENCAP_PORT])
+		lispdev->encap_port =
+			ntohs(nla_get_be16(data[IFLA_LISP_ENCAP_PORT]));
+
+	if (data[IFLA_LISP_LISTEN_PORT])
+		lispdev->rcv_port =
+			ntohs(nla_get_be16(data[IFLA_LISP_LISTEN_PORT]));
+
+	if (data[IFLA_LISP_REMOTE]) {
+		lispdev->remote.sin.sin_addr.s_addr =
+			nla_get_be32(data[IFLA_LISP_REMOTE]);
+		lispdev->remote.sa.sa_family = AF_INET;
+	}
+
+	if (data[IFLA_LISP_TOS])
+		lispdev->tos = nla_get_u8(data[IFLA_LISP_TOS]);
+
+	if (data[IFLA_LISP_TTL])
+		lispdev->ttl = nla_get_u8(data[IFLA_LISP_TTL]);
+
+	if (data[IFLA_LISP_UDP_CSUM] && nla_get_u8(data[IFLA_LISP_UDP_CSUM]))
+		lispdev->flags |= LISP_F_UDP_CSUM;
+	err = register_netdevice(dev);
+	if (err)
+		return err;
+
+	list_add(&lispdev->next, &ln->lisp_list);
+	return 0;
+}
+
+static void lisp_dellink(struct net_device *dev, struct list_head *head)
+{
+	struct lisp_net *ln = net_generic(dev_net(dev), lisp_net_id);
+	struct lisp_dev *lispdev = netdev_priv(dev);
+
+	spin_lock(&ln->sock_lock);
+	if (!hlist_unhashed(&lispdev->hlist))
+		hlist_del_rcu(&lispdev->hlist);
+	spin_unlock(&ln->sock_lock);
+
+	list_del(&lispdev->next);
+	unregister_netdevice_queue(dev, head);
+}
+
+static size_t lisp_get_size(const struct net_device *dev)
+{
+	return
+		/* IFLA_LISP_IID */
+		nla_total_size(4) +
+		/* IFLA_LISP_LOCAL */
+		nla_total_size(4) +
+		/* IFLA_LISP_LOCAL6 */
+		nla_total_size(sizeof(struct in6_addr)) +
+		/* IFLA_LISP_REMOTE */
+		nla_total_size(4) +
+		/* IFLA_LISP_REMOTE6 */
+		nla_total_size(sizeof(struct in6_addr)) +
+		/* IFLA_LISP_ENCAP_PORT */
+		nla_total_size(2) +
+		/* IFLA_LISP_LISTEN_PORT */
+		nla_total_size(2) +
+		/* IFLA_LISP_TOS */
+		nla_total_size(1) +
+		/* IFLA_LISP_TTL */
+		nla_total_size(1) +
+		/* IFLA_LISP_UDP_CSUM */
+		nla_total_size(1) +
+		0;
+}
+
+/* Fill attributes into skb
+ */
+static int lisp_fill_info(struct sk_buff *skb, const struct net_device *dev)
+{
+	const struct lisp_dev *lispdev = netdev_priv(dev);
+
+	/* V6 options needed for future
+	 */
+	if (nla_put_u32(skb, IFLA_LISP_IID, lispdev->iid) ||
+	    nla_put_u32(skb, IFLA_LISP_LOCAL,
+			lispdev->local.sin.sin_addr.s_addr) ||
+	    nla_put_u32(skb, IFLA_LISP_REMOTE,
+			lispdev->remote.sin.sin_addr.s_addr) ||
+	    nla_put_be16(skb, IFLA_LISP_ENCAP_PORT, lispdev->encap_port) ||
+	    nla_put_be16(skb, IFLA_LISP_LISTEN_PORT, lispdev->rcv_port) ||
+	    nla_put_u8(skb, IFLA_LISP_TOS, lispdev->tos) ||
+	    nla_put_u8(skb, IFLA_LISP_TTL, lispdev->ttl) ||
+	    nla_put_u8(skb, IFLA_LISP_UDP_CSUM,
+		       !!(lispdev->flags & LISP_F_UDP_CSUM)))
+		return -EMSGSIZE;
+	return 0;
+}
+
+static int lisp_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	return 0;
+}
+
+static struct rtnl_link_ops lisp_link_ops __read_mostly = {
+	.kind		= "lisp",
+	.maxtype	= IFLA_LISP_MAX,
+	.policy		= lisp_policy,
+	.priv_size	= sizeof(struct lisp_dev),
+	.setup		= lisp_setup,
+	.validate	= lisp_validate,
+	.newlink	= lisp_newlink,
+	.dellink	= lisp_dellink,
+	.get_size	= lisp_get_size,
+	.fill_info	= lisp_fill_info,
+};
+
+static __net_exit void lisp_exit_net(struct net *net)
+{
+	struct lisp_net *ln = net_generic(net, lisp_net_id);
+	struct lisp_dev *lispdev;
+
+	LIST_HEAD(list);
+
+	rtnl_lock();
+	list_for_each_entry(lispdev, &ln->lisp_list, next)
+		unregister_netdevice_queue(lispdev->dev, &list);
+	unregister_netdevice_many(&list);
+	rtnl_unlock();
+}
+
+static __net_init int lisp_init_net(struct net *net)
+{
+	struct lisp_net *ln = net_generic(net, lisp_net_id);
+	unsigned int h;
+
+	INIT_LIST_HEAD(&ln->lisp_list);
+	spin_lock_init(&ln->sock_lock);
+
+	for (h = 0; h < PORT_HASH_SIZE; ++h)
+		INIT_HLIST_HEAD(&ln->sock_list[h]);
+
+	return 0;
+}
+
+static struct pernet_operations lisp_net_ops = {
+	.init	= lisp_init_net,
+	.exit	= lisp_exit_net,
+	.id	= &lisp_net_id,
+	.size	= sizeof(struct lisp_net),
+};
+
+static int __init lisp_netdev_init(void)
+{
+	int rc;
+
+	lisp_wq = alloc_workqueue("lisp", 0, 0);
+	if (!lisp_wq)
+		return -ENOMEM;
+
+	rc = register_pernet_device(&lisp_net_ops);
+	if (rc)
+		goto out1;
+
+	rc = rtnl_link_register(&lisp_link_ops);
+	if (rc)
+		goto out2;
+
+	return 0;
+
+out2:
+	unregister_pernet_device(&lisp_net_ops);
+out1:
+	destroy_workqueue(lisp_wq);
+	return rc;
+}
+
+static void __exit lisp_netdev_cleanup(void)
+{
+	rtnl_link_unregister(&lisp_link_ops);
+	destroy_workqueue(lisp_wq);
+	unregister_pernet_device(&lisp_net_ops);
+	rcu_barrier();
+}
+
+late_initcall(lisp_netdev_init);
+module_exit(lisp_netdev_cleanup);
+
+MODULE_LICENSE("GPL");
+MODULE_VERSION(LISP_VERSION);
+MODULE_AUTHOR("Chris White <chris@logicalelegance.com>");
+MODULE_ALIAS_RTNL_LINK("lisp");
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ade33ef..c04cce8 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1570,25 +1570,6 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 	return false;
 }
 
-/* Compute source port for outgoing packet
- *   first choice to use L4 flow hash since it will spread
- *     better and maybe available from hardware
- *   secondary choice is to use jhash on the Ethernet header
- */
-__be16 vxlan_src_port(__u16 port_min, __u16 port_max, struct sk_buff *skb)
-{
-	unsigned int range = (port_max - port_min) + 1;
-	u32 hash;
-
-	hash = skb_get_hash(skb);
-	if (!hash)
-		hash = jhash(skb->data, 2 * ETH_ALEN,
-			     (__force u32) skb->protocol);
-
-	return htons((((u64) hash * range) >> 32) + port_min);
-}
-EXPORT_SYMBOL_GPL(vxlan_src_port);
-
 static inline struct sk_buff *vxlan_handle_offloads(struct sk_buff *skb,
 						    bool udp_csum)
 {
@@ -1807,7 +1788,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	if (tos == 1)
 		tos = ip_tunnel_get_dsfield(old_iph, skb);
 
-	src_port = vxlan_src_port(vxlan->port_min, vxlan->port_max, skb);
+	src_port = udp_tunnel_get_src_port(vxlan->port_min, vxlan->port_max,
+					   skb);
 
 	if (dst->sa.sa_family == AF_INET) {
 		memset(&fl4, 0, sizeof(fl4));
diff --git a/include/net/route.h b/include/net/route.h
index b17cf28..35e6c4e 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -131,6 +131,27 @@ static inline struct rtable *ip_route_output(struct net *net, __be32 daddr,
 	return ip_route_output_key(net, &fl4);
 }
 
+static inline struct rtable *ip_route_output_mark(struct net *net,
+						  __be32 *saddr, __be32 daddr,
+						  u8 ipproto, u8 tos,
+						  u32 skb_mark)
+{
+	struct rtable *rt;
+
+	/* Tunnel configuration keeps DSCP part of TOS bits, But Linux
+	 * router expect RT_TOS bits only.
+	 */
+	struct flowi4 fl = { .daddr		= daddr,
+			     .saddr		= *saddr,
+			     .flowi4_tos	= RT_TOS(tos),
+			     .flowi4_mark	= skb_mark,
+			     .flowi4_proto	= ipproto };
+
+	rt = ip_route_output_key(net, &fl);
+	*saddr = fl.saddr;
+	return rt;
+}
+
 static inline struct rtable *ip_route_output_ports(struct net *net, struct flowi4 *fl4,
 						   struct sock *sk,
 						   __be32 daddr, __be32 saddr,
diff --git a/include/net/udp.h b/include/net/udp.h
index 68a1fef..99861bd 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -167,6 +167,27 @@ static inline void udp_lib_hash(struct sock *sk)
 void udp_lib_unhash(struct sock *sk);
 void udp_lib_rehash(struct sock *sk, u16 new_hash);
 
+/* Compute source port for outgoing packet
+ *   first choice to use L4 flow hash since it will spread
+ *     better and maybe available from hardware
+ *   secondary choice is to use jhash on the Ethernet header
+ */
+static inline  __be16 udp_tunnel_get_src_port(__u16 port_min, __u16 port_max,
+					      struct sk_buff *skb)
+{
+	unsigned int range = (port_max - port_min) + 1;
+	u32 hash;
+
+	hash = skb_get_hash(skb);
+	if (!hash)
+		hash = jhash(skb->data, 2 * ETH_ALEN,
+			     (__force u32) skb->protocol);
+
+	return htons((((u64) hash * range) >> 32) + port_min);
+}
+
+/* Compute source UDP port for outgoing packets on UDP tunnels
+ */
 static inline void udp_lib_close(struct sock *sk, long timeout)
 {
 	sk_common_release(sk);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index b385348..0077832 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -331,6 +331,23 @@ struct ifla_vxlan_port_range {
 	__be16	high;
 };
 
+/* LISP section */
+enum {
+	IFLA_LISP_UNSPEC,
+	IFLA_LISP_IID,
+	IFLA_LISP_LOCAL,
+	IFLA_LISP_REMOTE,
+	IFLA_LISP_LOCAL6,
+	IFLA_LISP_REMOTE6,
+	IFLA_LISP_ENCAP_PORT,
+	IFLA_LISP_LISTEN_PORT,
+	IFLA_LISP_TOS,
+	IFLA_LISP_TTL,
+	IFLA_LISP_UDP_CSUM,
+	__IFLA_LISP_MAX
+};
+#define IFLA_LISP_MAX (__IFLA_LISP_MAX - 1)
+
 /* Bonding section */
 
 enum {
-- 
1.7.10.4
