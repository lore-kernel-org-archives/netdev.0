From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCHv4 net-next] vxlan: virtual extensible lan
Date: Mon, 24 Sep 2012 14:50:31 -0700
Message-ID: <20120924145031.3b0122e6@nehalam.linuxnetplumber.net>
References: <20120924184304.727711327@vyatta.com>
	<20120924185050.162920909@vyatta.com>
	<20120924205822.GI26494@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Chris Wright <chrisw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41777 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750735Ab2IXVvG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 17:51:06 -0400
In-Reply-To: <20120924205822.GI26494@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an implementation of Virtual eXtensible Local Area Network
as described in draft RFC:
  http://tools.ietf.org/html/draft-mahalingam-dutt-dcops-vxlan-02

The driver integrates a Virtual Tunnel Endpoint (VTEP) functionality
that learns MAC to IP address mapping. 

This implementation has not been tested for Interoperation with
other equipment. Still needs more testing of static entry manipulation.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
v4 - fix ecn and set state of fdb entries
v3 - fix ordering of change versus migration message
v2 - fix use of ip header after pskb_may_pull

 Documentation/networking/vxlan.txt |   36 +
 drivers/net/Kconfig                |   13 
 drivers/net/Makefile               |    1 
 drivers/net/vxlan.c                | 1180 +++++++++++++++++++++++++++++++++++++
 include/linux/if_link.h            |   14 
 5 files changed, 1244 insertions(+)

--- a/drivers/net/Kconfig	2012-09-24 10:56:57.080291529 -0700
+++ b/drivers/net/Kconfig	2012-09-24 12:43:25.298239026 -0700
@@ -149,6 +149,19 @@ config MACVTAP
 	  To compile this driver as a module, choose M here: the module
 	  will be called macvtap.
 
+config VXLAN
+       tristate "Virtual eXtensible Local Area Network (VXLAN)"
+       depends on EXPERIMENTAL
+       ---help---
+	  This allows one to create vxlan virtual interfaces that provide
+	  Layer 2 Networks over Layer 3 Networks. VXLAN is often used
+	  to tunnel virtual network infrastructure in virtualized environments.
+	  For more information see:
+	    http://tools.ietf.org/html/draft-mahalingam-dutt-dcops-vxlan-02
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called vxlan.
+
 config NETCONSOLE
 	tristate "Network console logging support"
 	---help---
--- a/drivers/net/Makefile	2012-09-24 10:56:57.080291529 -0700
+++ b/drivers/net/Makefile	2012-09-24 11:08:02.865416523 -0700
@@ -21,6 +21,7 @@ obj-$(CONFIG_NET_TEAM) += team/
 obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
+obj-$(CONFIG_VXLAN) += vxlan.o
 
 #
 # Networking Drivers
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ b/drivers/net/vxlan.c	2012-09-24 14:33:00.687939813 -0700
@@ -0,0 +1,1182 @@
+/*
+ * VXLAN: Virtual eXtensiable Local Area Network
+ *
+ * Copyright (c) 2012 Vyatta Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * TODO
+ *  - use IANA UDP port number (when defined)
+ *  - IPv6 (not in RFC)
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
+#include <linux/version.h>
+#include <linux/hash.h>
+#include <net/ip.h>
+#include <net/icmp.h>
+#include <net/udp.h>
+#include <net/rtnetlink.h>
+#include <net/route.h>
+#include <net/dsfield.h>
+#include <net/inet_ecn.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+
+#define VXLAN_VERSION	"0.0"
+
+#define VNI_HASH_BITS	10
+#define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
+#define FDB_HASH_BITS	8
+#define FDB_HASH_SIZE	(1<<FDB_HASH_BITS)
+
+#define VXLAN_N_VID	(1u << 24)
+#define VXLAN_VID_MASK	(VXLAN_N_VID - 1)
+
+#define FDB_AGE_INTERVAL (10 * HZ)	/* rescan interval */
+#define FDB_AGE_TIME	 (300 * HZ)	/* drop if not used in 5 min */
+
+#define VXLAN_FLAGS 0x08000000	/* struct vxlanhdr.vx_flags required value. */
+
+/* VXLAN protocol header */
+struct vxlanhdr {
+	__be32 vx_flags;
+	__be32 vx_vni;
+};
+
+#define VXLAN_HEADROOM (sizeof(struct iphdr)		\
+			+ sizeof(struct udphdr)		\
+			+ sizeof(struct vxlanhdr))
+
+/* UDP port for VXLAN traffic. */
+static unsigned int vxlan_port __read_mostly = 8472;
+module_param_named(port, vxlan_port, uint, 0);
+MODULE_PARM_DESC(vxlan_port, "Destination UDP port");
+
+/* per-net private data for this module */
+static unsigned int vxlan_net_id;
+struct vxlan_net {
+	struct socket	  *sock;	/* UDP encap socket */
+	struct hlist_head vni_list[VNI_HASH_SIZE];
+};
+
+/* Forwarding table entry */
+struct vxlan_fdb {
+	struct hlist_node hlist;	/* linked list of entries */
+	struct rcu_head	  rcu;
+	unsigned long	  updated;	/* jiffies */
+	unsigned long	  used;
+	__be32		  remote_ip;
+	u16		  state;	/* see ndm_state */
+	u8		  eth_addr[ETH_ALEN];
+};
+
+/* Per-cpu network traffic stats */
+struct vxlan_stats {
+	u64			rx_packets;
+	u64			rx_bytes;
+	u64			tx_packets;
+	u64			tx_bytes;
+	struct u64_stats_sync	syncp;
+};
+
+/* Pseudo network device */
+struct vxlan_dev {
+	struct hlist_node hlist;
+	struct net_device *dev;
+	struct vxlan_stats __percpu *stats;
+	__u32		  vni;		/* virtual network id */
+	__be32	          gaddr;	/* multicast group */
+	__be32		  saddr;	/* source address */
+	unsigned int      link;		/* link to multicast over */
+	__u8		  tos;		/* TOS override */
+	__u8		  ttl;
+	bool		  learn;
+
+	struct timer_list age_timer;
+	spinlock_t	  hash_lock;
+	struct hlist_head fdb_head[FDB_HASH_SIZE];
+};
+
+/* salt for hash table */
+static u32 vxlan_salt __read_mostly;
+
+static inline struct hlist_head *vni_head(struct net *net, u32 id)
+{
+	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
+
+	return &vn->vni_list[hash_32(id, VNI_HASH_BITS)];
+}
+
+/* Look up VNI in a per net namespace table */
+static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id)
+{
+	struct vxlan_dev *vxlan;
+	struct hlist_node *node;
+
+	hlist_for_each_entry_rcu(vxlan, node, vni_head(net, id), hlist) {
+		if (vxlan->vni == id)
+			return vxlan;
+	}
+
+	return NULL;
+}
+
+/* Fill in neighbour message in skbuff. */
+static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
+			   const struct vxlan_fdb *fdb,
+			   u32 portid, u32 seq, int type, unsigned int flags)
+{
+	unsigned long now = jiffies;
+	struct nda_cacheinfo ci;
+	struct nlmsghdr *nlh;
+	struct ndmsg *ndm;
+
+	nlh = nlmsg_put(skb, portid, seq, type, sizeof(*ndm), flags);
+	if (nlh == NULL)
+		return -EMSGSIZE;
+
+	ndm = nlmsg_data(nlh);
+	memset(ndm, 0, sizeof(*ndm));
+	ndm->ndm_family	= AF_BRIDGE;
+	ndm->ndm_state = fdb->state;
+
+	if (nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->eth_addr))
+		goto nla_put_failure;
+
+	if (nla_put_be32(skb, NDA_DST, fdb->remote_ip))
+		goto nla_put_failure;
+
+	ci.ndm_used	 = jiffies_to_clock_t(now - fdb->used);
+	ci.ndm_confirmed = 0;
+	ci.ndm_updated	 = jiffies_to_clock_t(now - fdb->updated);
+	ci.ndm_refcnt	 = 0;
+
+	if (nla_put(skb, NDA_CACHEINFO, sizeof(ci), &ci))
+		goto nla_put_failure;
+
+	return nlmsg_end(skb, nlh);
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
+static inline size_t vxlan_nlmsg_size(void)
+{
+	return NLMSG_ALIGN(sizeof(struct ndmsg))
+		+ nla_total_size(ETH_ALEN) /* NDA_LLADDR */
+		+ nla_total_size(sizeof(__be32)) /* NDA_DST */
+		+ nla_total_size(sizeof(struct nda_cacheinfo));
+}
+
+static void vxlan_fdb_notify(struct vxlan_dev *vxlan,
+			     const struct vxlan_fdb *fdb, int type)
+{
+	struct net *net = dev_net(vxlan->dev);
+	struct sk_buff *skb;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(vxlan_nlmsg_size(), GFP_ATOMIC);
+	if (skb == NULL)
+		goto errout;
+
+	err = vxlan_fdb_info(skb, vxlan, fdb, 0, 0, type, 0);
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in vxlan_nlmsg_size() */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
+
+	rtnl_notify(skb, net, 0, RTNLGRP_NEIGH, NULL, GFP_ATOMIC);
+	return;
+errout:
+	if (err < 0)
+		rtnl_set_sk_err(net, RTNLGRP_NEIGH, err);
+}
+
+/* Hash Ethernet address */
+static u32 eth_hash(const unsigned char *addr)
+{
+	/* could be optimized for unaligned access */
+	u32 a = addr[5] << 8 | addr[4];
+	u32 b = addr[3] << 24 | addr[2] << 16 | addr[1] << 8 | addr[0];
+
+	return jhash_2words(a, b, vxlan_salt);
+}
+
+/* Hash chain to use given mac address */
+static inline struct hlist_head *vxlan_fdb_head(struct vxlan_dev *vxlan,
+						const u8 *mac)
+{
+	return &vxlan->fdb_head[hash_32(eth_hash(mac), FDB_HASH_BITS)];
+}
+
+/* Look up Ethernet address in forwarding table */
+static struct vxlan_fdb *vxlan_find_mac(struct vxlan_dev *vxlan,
+					const u8 *mac)
+
+{
+	struct hlist_head *head = vxlan_fdb_head(vxlan, mac);
+	struct vxlan_fdb *f;
+	struct hlist_node *node;
+
+	hlist_for_each_entry_rcu(f, node, head, hlist) {
+		if (compare_ether_addr(mac, f->eth_addr) == 0)
+			return f;
+	}
+
+	return NULL;
+}
+
+/* Add new entry to forwarding table -- assumes lock held */
+static int vxlan_fdb_create(struct vxlan_dev *vxlan,
+			    const u8 *mac, __be32 ip,
+			    __u16 state, __u16 flags)
+{
+	struct vxlan_fdb *f;
+
+	f = vxlan_find_mac(vxlan, mac);
+	if (f) {
+		if (flags & NLM_F_EXCL) {
+			netdev_dbg(vxlan->dev,
+				   "lost race to create %pM\n", mac);
+			return -EEXIST;
+		}
+	} else {
+		if (!(flags & NLM_F_CREATE))
+			return -ENOENT;
+
+		netdev_dbg(vxlan->dev, "add %pM -> %pI4\n", mac, &ip);
+		f = kmalloc(sizeof(*f), GFP_ATOMIC);
+		if (!f)
+			return -ENOMEM;
+
+		f->remote_ip = ip;
+		memcpy(f->eth_addr, mac, ETH_ALEN);
+		hlist_add_head_rcu(&f->hlist,
+				   vxlan_fdb_head(vxlan, mac));
+		f->state = 0;
+	}
+
+	if (f->state != state) {
+		f->state = state;
+		f->updated = f->used = jiffies;
+		vxlan_fdb_notify(vxlan, f, RTM_NEWNEIGH);
+	}
+
+	return 0;
+}
+
+static void vxlan_fdb_destroy(struct vxlan_dev *vxlan, struct vxlan_fdb *f)
+{
+	netdev_dbg(vxlan->dev,
+		    "delete %pM\n", f->eth_addr);
+
+	vxlan_fdb_notify(vxlan, f, RTM_DELNEIGH);
+
+	hlist_del_rcu(&f->hlist);
+	kfree_rcu(f, rcu);
+}
+
+/* Add static entry (via netlink) */
+static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
+			 struct net_device *dev,
+			 const unsigned char *addr, u16 flags)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	__be32 ip;
+	int err;
+
+	if (!(ndm->ndm_state & (NUD_PERMANENT|NUD_REACHABLE))) {
+		pr_info("RTM_NEWNEIGH with invalid state %#x\n", ndm->ndm_state);
+		return -EINVAL;
+	}
+
+	if (tb[NDA_DST] == NULL)
+		return -EINVAL;
+
+	if (nla_len(tb[NDA_DST]) != sizeof(__be32))
+		return -EAFNOSUPPORT;
+
+	ip = nla_get_be32(tb[NDA_DST]);
+
+	spin_lock_bh(&vxlan->hash_lock);
+	err = vxlan_fdb_create(vxlan, addr, ip, ndm->ndm_state, flags);
+	spin_unlock_bh(&vxlan->hash_lock);
+
+	return err;
+}
+
+/* Delete entry (via netlink) */
+static int vxlan_fdb_delete(struct ndmsg *ndm, struct net_device *dev,
+			    const unsigned char *addr)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_fdb *f;
+	int err = -ENOENT;
+
+	spin_lock_bh(&vxlan->hash_lock);
+	f = vxlan_find_mac(vxlan, addr);
+	if (f) {
+		vxlan_fdb_destroy(vxlan, f);
+		err = 0;
+	}
+	spin_unlock_bh(&vxlan->hash_lock);
+
+	return err;
+}
+
+/* Dump forwarding table */
+static int vxlan_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
+			  struct net_device *dev, int idx)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	unsigned int h;
+
+	for (h = 0; h < FDB_HASH_SIZE; ++h) {
+		struct vxlan_fdb *f;
+		struct hlist_node *n;
+
+		hlist_for_each_entry_rcu(f, n, &vxlan->fdb_head[h], hlist) {
+			if (idx < cb->args[0])
+				goto skip;
+
+			if (vxlan_fdb_info(skb, vxlan, f,
+					    NETLINK_CB(cb->skb).portid,
+					    cb->nlh->nlmsg_seq,
+					    RTM_NEWNEIGH,
+					    NLM_F_MULTI) < 0)
+				break;
+skip:
+			++idx;
+		}
+	}
+
+	return idx;
+}
+
+/* Watch incoming packets to learn mapping between Ethernet address
+ * and Tunnel endpoint.
+ */
+static void vxlan_snoop(struct net_device *dev,
+			__be32 src_ip, const u8 *src_mac)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_fdb *f;
+	int err;
+
+	f = vxlan_find_mac(vxlan, src_mac);
+	if (likely(f)) {
+		f->used = jiffies;
+		if (likely(f->remote_ip == src_ip))
+			return;
+
+		if (net_ratelimit())
+			netdev_info(dev,
+				    "%pM migrated from %pI4 to %pI4\n",
+				    src_mac, &f->remote_ip, &src_ip);
+
+		f->remote_ip = src_ip;
+		f->updated = jiffies;
+	} else {
+		/* learned new entry */
+		spin_lock(&vxlan->hash_lock);
+		err = vxlan_fdb_create(vxlan, src_mac, src_ip,
+				       NUD_REACHABLE,
+				       NLM_F_EXCL|NLM_F_CREATE);
+		spin_unlock(&vxlan->hash_lock);
+	}
+}
+
+
+/* See if multicast group is already in use by other ID */
+static bool vxlan_group_used(struct vxlan_net *vn,
+			     const struct vxlan_dev *this)
+{
+	const struct vxlan_dev *vxlan;
+	struct hlist_node *node;
+	unsigned h;
+
+	for (h = 0; h < VNI_HASH_SIZE; ++h)
+		hlist_for_each_entry(vxlan, node, &vn->vni_list[h], hlist) {
+			if (vxlan == this)
+				continue;
+
+			if (!netif_running(vxlan->dev))
+				continue;
+
+			if (vxlan->gaddr == this->gaddr)
+				return true;
+		}
+
+	return false;
+}
+
+/* kernel equivalent to IP_ADD_MEMBERSHIP */
+static int vxlan_join_group(struct net_device *dev)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
+	struct sock *sk = vn->sock->sk;
+	struct ip_mreqn mreq = {
+		.imr_multiaddr.s_addr = vxlan->gaddr,
+	};
+	int err;
+
+	if (vxlan_group_used(vn, vxlan))
+		return 0;
+
+	/* Need to drop RTNL to call multicast join */
+	rtnl_unlock();
+	lock_sock(sk);
+	err = ip_mc_join_group(sk, &mreq);
+	release_sock(sk);
+	rtnl_lock();
+
+	return err;
+}
+
+
+/* kernel equivalent to IP_DROP_MEMBERSHIP */
+static int vxlan_leave_group(struct net_device *dev)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
+	int err = 0;
+	struct sock *sk = vn->sock->sk;
+	struct ip_mreqn mreq = {
+		.imr_multiaddr.s_addr = vxlan->gaddr,
+	};
+
+	if (vxlan_group_used(vn, vxlan))
+		return 0;
+
+	/* Need to drop RTNL to call multicast leave */
+	rtnl_unlock();
+	lock_sock(sk);
+	err = ip_mc_leave_group(sk, &mreq);
+	release_sock(sk);
+	rtnl_lock();
+
+	return err;
+}
+
+/* Propogate ECN from outer IP header to tunneled packet */
+static inline int vxlan_ecn_decap(const struct iphdr *iph, struct sk_buff *skb)
+{
+	if (unlikely(INET_ECN_is_ce(iph->tos))) {
+		if (skb->protocol == htons(ETH_P_IP))
+			return IP_ECN_set_ce(ip_hdr(skb));
+		else if (skb->protocol == htons(ETH_P_IPV6))
+			return IP6_ECN_set_ce(ipv6_hdr(skb));
+	}
+	return 1;
+}
+
+/* Callback from net/ipv4/udp.c to receive packets */
+static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
+{
+	struct iphdr *oip;
+	struct vxlanhdr *vxh;
+	struct vxlan_dev *vxlan;
+	struct vxlan_stats *stats;
+	__u32 vni;
+
+	/* pop off outer UDP header */
+	__skb_pull(skb, sizeof(struct udphdr));
+
+	/* Need Vxlan and inner Ethernet header to be present */
+	if (!pskb_may_pull(skb,
+			   sizeof(struct vxlanhdr) + sizeof(struct ethhdr)))
+		goto error;
+
+	oip = ip_hdr(skb);
+
+	/* Drop packets with reserved bits set */
+	vxh = (struct vxlanhdr *) skb->data;
+	if (vxh->vx_flags != htonl(VXLAN_FLAGS) ||
+	    (vxh->vx_vni & htonl(0xff)))
+		goto error;
+
+	__skb_pull(skb, sizeof(struct vxlanhdr));
+
+	/* Is this VNI defined? */
+	vni = ntohl(vxh->vx_vni) >> 8;
+	vxlan = vxlan_find_vni(sock_net(sk), vni);
+	if (!vxlan)
+		goto drop;
+
+	/* Ignore packets if device is not up */
+	if (!netif_running(vxlan->dev))
+		goto drop;
+
+	/* Re-examine inner Ethernet packet */
+	skb->protocol = eth_type_trans(skb, vxlan->dev);
+	skb->ip_summed = CHECKSUM_NONE;
+
+	/* Ignore packet loops (and multicast echo) */
+	if (compare_ether_addr(eth_hdr(skb)->h_source,
+			       vxlan->dev->dev_addr) == 0)
+		goto drop;
+
+	/* Check for multicast group configuration errors */
+	if (IN_MULTICAST(ntohl(oip->daddr)) &&
+	    oip->daddr != vxlan->gaddr) {
+		if (net_ratelimit())
+			netdev_notice(vxlan->dev,
+				      "group address %pI4 does not match\n",
+				      &oip->daddr);
+		goto drop;
+	}
+
+	if (vxlan->learn)
+		vxlan_snoop(skb->dev, oip->saddr, eth_hdr(skb)->h_source);
+
+	__skb_tunnel_rx(skb, vxlan->dev);
+	skb_reset_network_header(skb);
+	if (!vxlan_ecn_decap(oip, skb))
+		goto drop;
+
+	stats = this_cpu_ptr(vxlan->stats);
+	u64_stats_update_begin(&stats->syncp);
+	stats->rx_packets++;
+	stats->rx_bytes += skb->len;
+	u64_stats_update_end(&stats->syncp);
+
+	netif_rx(skb);
+
+	return 0;
+error:
+	/* Put UDP header back */
+	__skb_push(skb, sizeof(struct udphdr));
+
+	return 1;
+drop:
+	/* Consume bad packet */
+	kfree_skb(skb);
+	return 0;
+}
+
+/* Extract dsfield from inner protocol */
+static inline u8 vxlan_get_dsfield(const struct iphdr *iph,
+				   const struct sk_buff *skb)
+{
+	if (skb->protocol == htons(ETH_P_IP))
+		return iph->tos;
+	else if (skb->protocol == htons(ETH_P_IPV6))
+		return ipv6_get_dsfield((const struct ipv6hdr *)iph);
+	else
+		return 0;
+}
+
+/* Propogate ECN bits out */
+static inline u8 vxlan_ecn_encap(u8 tos,
+				 const struct iphdr *iph,
+				 const struct sk_buff *skb)
+{
+	u8 inner = vxlan_get_dsfield(iph, skb);
+
+	return INET_ECN_encapsulate(tos, inner);
+}
+
+/* Transmit local packets over Vxlan
+ *
+ * Outer IP header inherits ECN and DF from inner header.
+ * Outer UDP destination is the VXLAN assigned port.
+ *           source port is based on hash of flow if available
+ *                       otherwise use a random value
+ */
+static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct rtable *rt;
+	const struct ethhdr *eth;
+	const struct iphdr *old_iph;
+	struct iphdr *iph;
+	struct vxlanhdr *vxh;
+	struct udphdr *uh;
+	struct flowi4 fl4;
+	struct vxlan_fdb *f;
+	unsigned int pkt_len = skb->len;
+	unsigned int mtu;
+	u32 hash;
+	__be32 dst;
+	__be16 df = 0;
+	__u8 tos, ttl;
+	int err;
+
+	/* Need space for new headers (invalidates iph ptr) */
+	if (skb_cow_head(skb, VXLAN_HEADROOM))
+		goto drop;
+
+	eth = (void *)skb->data;
+	old_iph = ip_hdr(skb);
+
+	if (!is_multicast_ether_addr(eth->h_dest) &&
+	    (f = vxlan_find_mac(vxlan, eth->h_dest)))
+		dst = f->remote_ip;
+	else if (vxlan->gaddr) {
+		dst = vxlan->gaddr;
+	} else
+		goto drop;
+
+	ttl = vxlan->ttl;
+	if (!ttl && IN_MULTICAST(ntohl(dst)))
+		ttl = 1;
+
+	tos = vxlan->tos;
+	if (tos == 1)
+		tos = vxlan_get_dsfield(old_iph, skb);
+
+	hash = skb_get_rxhash(skb);
+
+	rt = ip_route_output_gre(dev_net(dev), &fl4, dst,
+				 vxlan->saddr, vxlan->vni,
+				 RT_TOS(tos), vxlan->link);
+	if (IS_ERR(rt)) {
+		netdev_dbg(dev, "no route to %pI4\n", &dst);
+		dev->stats.tx_carrier_errors++;
+		goto tx_error;
+	}
+
+	if (rt->dst.dev == dev) {
+		netdev_dbg(dev, "circular route to %pI4\n", &dst);
+		ip_rt_put(rt);
+		dev->stats.collisions++;
+		goto tx_error;
+	}
+
+	mtu = dst_mtu(&rt->dst) - VXLAN_HEADROOM;
+	/* Do PMTU */
+	if (skb->protocol == htons(ETH_P_IP)) {
+		df |= old_iph->frag_off & htons(IP_DF);
+		if (df && mtu < pkt_len) {
+			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
+				  htonl(mtu));
+			ip_rt_put(rt);
+			goto tx_error;
+		}
+	}
+#if IS_ENABLED(CONFIG_IPV6)
+	else if (skb->protocol == htons(ETH_P_IPV6)) {
+		if (mtu >= IPV6_MIN_MTU && mtu < pkt_len) {
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+			ip_rt_put(rt);
+			goto tx_error;
+		}
+	}
+#endif
+
+	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
+	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
+			      IPSKB_REROUTED);
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->dst);
+
+	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
+	vxh->vx_flags = htonl(VXLAN_FLAGS);
+	vxh->vx_vni = htonl(vxlan->vni << 8);
+
+	__skb_push(skb, sizeof(*uh));
+	skb_reset_transport_header(skb);
+	uh = udp_hdr(skb);
+
+	uh->dest = htons(vxlan_port);
+	uh->source = hash ? :random32();
+
+	uh->len = htons(skb->len);
+	uh->check = 0;
+
+	__skb_push(skb, sizeof(*iph));
+	skb_reset_network_header(skb);
+	iph		= ip_hdr(skb);
+	iph->version	= 4;
+	iph->ihl	= sizeof(struct iphdr) >> 2;
+	iph->frag_off	= df;
+	iph->protocol	= IPPROTO_UDP;
+	iph->tos	= vxlan_ecn_encap(tos, old_iph, skb);
+	iph->daddr	= fl4.daddr;
+	iph->saddr	= fl4.saddr;
+	iph->ttl	= ttl ? : ip4_dst_hoplimit(&rt->dst);
+
+	/* See __IPTUNNEL_XMIT */
+	skb->ip_summed = CHECKSUM_NONE;
+	ip_select_ident(iph, &rt->dst, NULL);
+
+	err = ip_local_out(skb);
+	if (likely(net_xmit_eval(err) == 0)) {
+		struct vxlan_stats *stats = this_cpu_ptr(vxlan->stats);
+
+		u64_stats_update_begin(&stats->syncp);
+		stats->tx_packets++;
+		stats->tx_bytes += pkt_len;
+		u64_stats_update_end(&stats->syncp);
+	} else {
+		dev->stats.tx_errors++;
+		dev->stats.tx_aborted_errors++;
+	}
+	return NETDEV_TX_OK;
+
+drop:
+	dev->stats.tx_dropped++;
+	goto tx_free;
+
+tx_error:
+	dev->stats.tx_errors++;
+tx_free:
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
+}
+
+/* Walk the forwarding table and purge stale entries */
+static void vxlan_cleanup(unsigned long arg)
+{
+	struct vxlan_dev *vxlan = (struct vxlan_dev *) arg;
+	unsigned long next_timer = jiffies + FDB_AGE_INTERVAL;
+	unsigned int h;
+
+	if (!netif_running(vxlan->dev))
+		return;
+
+	spin_lock_bh(&vxlan->hash_lock);
+	for (h = 0; h < FDB_HASH_SIZE; ++h) {
+		struct hlist_node *p, *n;
+		hlist_for_each_safe(p, n, &vxlan->fdb_head[h]) {
+			struct vxlan_fdb *f
+				= container_of(p, struct vxlan_fdb, hlist);
+			unsigned long timeout = f->used + FDB_AGE_TIME;
+
+			if (f->state == NUD_PERMANENT)
+				continue;
+
+			if (time_before_eq(timeout, jiffies)) {
+				netdev_dbg(vxlan->dev,
+					   "garbage collect %pM\n",
+					   f->eth_addr);
+				f->state = NUD_STALE;
+				vxlan_fdb_destroy(vxlan, f);
+			} else if (time_before(timeout, next_timer))
+				next_timer = timeout;
+		}
+	}
+	spin_unlock_bh(&vxlan->hash_lock);
+
+	mod_timer(&vxlan->age_timer, next_timer);
+}
+
+/* Setup stats when device is created */
+static int vxlan_init(struct net_device *dev)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+
+	vxlan->stats = alloc_percpu(struct vxlan_stats);
+	if (!vxlan->stats)
+		return -ENOMEM;
+
+	return 0;
+}
+
+/* Start ageing timer and join group when device is brought up */
+static int vxlan_open(struct net_device *dev)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	int err;
+
+	if (vxlan->gaddr) {
+		err = vxlan_join_group(dev);
+		if (err)
+			return err;
+	}
+
+	mod_timer(&vxlan->age_timer, jiffies + FDB_AGE_INTERVAL);
+	return 0;
+}
+
+/* Purge the forwarding table */
+static void vxlan_flush(struct vxlan_dev *vxlan)
+{
+	unsigned h;
+
+	spin_lock_bh(&vxlan->hash_lock);
+	for (h = 0; h < FDB_HASH_SIZE; ++h) {
+		struct hlist_node *p, *n;
+		hlist_for_each_safe(p, n, &vxlan->fdb_head[h]) {
+			struct vxlan_fdb *f
+				= container_of(p, struct vxlan_fdb, hlist);
+			vxlan_fdb_destroy(vxlan, f);
+		}
+	}
+	spin_unlock_bh(&vxlan->hash_lock);
+}
+
+/* Cleanup timer and forwarding table on shutdown */
+static int vxlan_stop(struct net_device *dev)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+
+	if (vxlan->gaddr)
+		vxlan_leave_group(dev);
+
+	del_timer_sync(&vxlan->age_timer);
+
+	vxlan_flush(vxlan);
+
+	return 0;
+}
+
+/* Merge per-cpu statistics */
+static struct rtnl_link_stats64 *vxlan_stats64(struct net_device *dev,
+					       struct rtnl_link_stats64 *stats)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_stats tmp, sum = { 0 };
+	unsigned int cpu;
+
+	for_each_possible_cpu(cpu) {
+		unsigned int start;
+		const struct vxlan_stats *stats
+			= per_cpu_ptr(vxlan->stats, cpu);
+
+		do {
+			start = u64_stats_fetch_begin_bh(&stats->syncp);
+			memcpy(&tmp, stats, sizeof(tmp));
+		} while (u64_stats_fetch_retry_bh(&stats->syncp, start));
+
+		sum.tx_bytes   += tmp.tx_bytes;
+		sum.tx_packets += tmp.tx_packets;
+		sum.rx_bytes   += tmp.rx_bytes;
+		sum.rx_packets += tmp.rx_packets;
+	}
+
+	stats->tx_bytes   = sum.tx_bytes;
+	stats->tx_packets = sum.tx_packets;
+	stats->rx_bytes   = sum.rx_bytes;
+	stats->rx_packets = sum.rx_packets;
+
+	stats->tx_dropped = dev->stats.tx_dropped;
+	stats->tx_errors  = dev->stats.tx_errors;
+	stats->tx_carrier_errors  = dev->stats.tx_carrier_errors;
+	stats->collisions  = dev->stats.collisions;
+
+	return stats;
+}
+
+/* Stub, nothing needs to be done. */
+static void vxlan_set_multicast_list(struct net_device *dev)
+{
+}
+
+static const struct net_device_ops vxlan_netdev_ops = {
+	.ndo_init		= vxlan_init,
+	.ndo_open		= vxlan_open,
+	.ndo_stop		= vxlan_stop,
+	.ndo_start_xmit		= vxlan_xmit,
+	.ndo_get_stats64	= vxlan_stats64,
+	.ndo_set_rx_mode	= vxlan_set_multicast_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_fdb_add		= vxlan_fdb_add,
+	.ndo_fdb_del		= vxlan_fdb_delete,
+	.ndo_fdb_dump		= vxlan_fdb_dump,
+};
+
+/* Info for udev, that this is a virtual tunnel endpoint */
+static struct device_type vxlan_type = {
+	.name = "vxlan",
+};
+
+static void vxlan_free(struct net_device *dev)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+
+	free_percpu(vxlan->stats);
+	free_netdev(dev);
+}
+
+/* Initialize the device structure. */
+static void vxlan_setup(struct net_device *dev)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	unsigned h;
+
+	eth_hw_addr_random(dev);
+	ether_setup(dev);
+
+	dev->netdev_ops = &vxlan_netdev_ops;
+	dev->destructor = vxlan_free;
+	SET_NETDEV_DEVTYPE(dev, &vxlan_type);
+
+	dev->tx_queue_len = 0;
+	dev->features	|= NETIF_F_LLTX;
+	dev->features	|= NETIF_F_NETNS_LOCAL;
+	dev->priv_flags	&= ~IFF_XMIT_DST_RELEASE;
+
+	spin_lock_init(&vxlan->hash_lock);
+
+	init_timer_deferrable(&vxlan->age_timer);
+	vxlan->age_timer.function = vxlan_cleanup;
+	vxlan->age_timer.data = (unsigned long) vxlan;
+
+	vxlan->dev = dev;
+
+	for (h = 0; h < FDB_HASH_SIZE; ++h)
+		INIT_HLIST_HEAD(&vxlan->fdb_head[h]);
+}
+
+static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
+	[IFLA_VXLAN_ID]		= { .type = NLA_U32 },
+	[IFLA_VXLAN_GROUP]	= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
+	[IFLA_VXLAN_LINK]	= { .type = NLA_U32 },
+	[IFLA_VXLAN_LOCAL]	= { .len = FIELD_SIZEOF(struct iphdr, saddr) },
+	[IFLA_VXLAN_TOS]	= { .type = NLA_U8 },
+	[IFLA_VXLAN_LEARNING]	= { .type = NLA_U8 },
+};
+
+static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	if (tb[IFLA_ADDRESS]) {
+		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN) {
+			pr_debug("invalid link address (not ethernet)\n");
+			return -EINVAL;
+		}
+
+		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS]))) {
+			pr_debug("invalid all zero ethernet address\n");
+			return -EADDRNOTAVAIL;
+		}
+	}
+
+	if (!data)
+		return -EINVAL;
+
+	if (data[IFLA_VXLAN_ID]) {
+		__u32 id = nla_get_u32(data[IFLA_VXLAN_ID]);
+		if (id >= VXLAN_VID_MASK)
+			return -ERANGE;
+	}
+
+	if (data[IFLA_VXLAN_GROUP]) {
+		__be32 gaddr = nla_get_be32(data[IFLA_VXLAN_GROUP]);
+		if (!IN_MULTICAST(ntohl(gaddr))) {
+			pr_debug("group address is not IPv4 multicast\n");
+			return -EADDRNOTAVAIL;
+		}
+	}
+
+	return 0;
+}
+
+static int vxlan_newlink(struct net *net, struct net_device *dev,
+			 struct nlattr *tb[], struct nlattr *data[])
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	__u32 vni;
+	int err;
+
+	if (!data[IFLA_VXLAN_ID])
+		return -EINVAL;
+
+	vni = nla_get_u32(data[IFLA_VXLAN_ID]);
+	if (vxlan_find_vni(net, vni)) {
+		pr_info("duplicate VNI %u\n", vni);
+		return -EEXIST;
+	}
+	vxlan->vni = vni;
+
+	if (data[IFLA_VXLAN_GROUP])
+		vxlan->gaddr = nla_get_be32(data[IFLA_VXLAN_GROUP]);
+
+	if (data[IFLA_VXLAN_LOCAL])
+		vxlan->saddr = nla_get_be32(data[IFLA_VXLAN_LOCAL]);
+
+	if (data[IFLA_VXLAN_LINK])
+		vxlan->link = nla_get_u32(data[IFLA_VXLAN_LINK]);
+
+	if (data[IFLA_VXLAN_TOS])
+		vxlan->tos  = nla_get_u8(data[IFLA_VXLAN_TOS]);
+
+	if (!data[IFLA_VXLAN_LEARNING] || nla_get_u8(data[IFLA_VXLAN_LEARNING]))
+		vxlan->learn = true;
+
+	err = register_netdevice(dev);
+	if (!err)
+		hlist_add_head_rcu(&vxlan->hlist, vni_head(net, vxlan->vni));
+
+	return err;
+}
+
+static void vxlan_dellink(struct net_device *dev, struct list_head *head)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+
+	hlist_del_rcu(&vxlan->hlist);
+
+	unregister_netdevice_queue(dev, head);
+}
+
+static size_t vxlan_get_size(const struct net_device *dev)
+{
+
+	return nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_ID */
+		nla_total_size(sizeof(__be32)) +/* IFLA_VXLAN_GROUP */
+		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_LINK */
+		nla_total_size(sizeof(__be32))+	/* IFLA_VXLAN_LOCAL */
+		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_TTL */
+		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_TOS */
+		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_LEARNING */
+		0;
+}
+
+static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
+{
+	const struct vxlan_dev *vxlan = netdev_priv(dev);
+
+	if (nla_put_u32(skb, IFLA_VXLAN_ID, vxlan->vni))
+		goto nla_put_failure;
+
+	if (vxlan->gaddr && nla_put_u32(skb, IFLA_VXLAN_GROUP, vxlan->gaddr))
+		goto nla_put_failure;
+
+	if (vxlan->link && nla_put_u32(skb, IFLA_VXLAN_LINK, vxlan->link))
+		goto nla_put_failure;
+
+	if (vxlan->saddr && nla_put_u32(skb, IFLA_VXLAN_LOCAL, vxlan->saddr))
+		goto nla_put_failure;
+
+	if (nla_put_u8(skb, IFLA_VXLAN_TTL, vxlan->ttl) ||
+	    nla_put_u8(skb, IFLA_VXLAN_TOS, vxlan->tos) ||
+	    nla_put_u8(skb, IFLA_VXLAN_LEARNING, vxlan->learn))
+		goto nla_put_failure;
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static struct rtnl_link_ops vxlan_link_ops __read_mostly = {
+	.kind		= "vxlan",
+	.maxtype	= IFLA_VXLAN_MAX,
+	.policy		= vxlan_policy,
+	.priv_size	= sizeof(struct vxlan_dev),
+	.setup		= vxlan_setup,
+	.validate	= vxlan_validate,
+	.newlink	= vxlan_newlink,
+	.dellink	= vxlan_dellink,
+	.get_size	= vxlan_get_size,
+	.fill_info	= vxlan_fill_info,
+};
+
+static __net_init int vxlan_init_net(struct net *net)
+{
+	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
+	struct sock *sk;
+	struct sockaddr_in addr;
+	int rc;
+	unsigned h;
+
+	/* Create UDP socket for encapsulation receive. */
+	rc = sock_create_kern(AF_INET, SOCK_DGRAM, IPPROTO_UDP, &vn->sock);
+	if (rc < 0) {
+		pr_debug("UDP socket create failed\n");
+		return rc;
+	}
+
+	addr.sin_family = AF_INET;
+	addr.sin_addr.s_addr = INADDR_ANY;
+	addr.sin_port = htons(vxlan_port);
+
+	rc = kernel_bind(vn->sock, (struct sockaddr *) &addr, sizeof(addr));
+	if (rc < 0) {
+		pr_debug("bind for port %u failed %d\n", vxlan_port, rc);
+		sock_release(vn->sock);
+		vn->sock = NULL;
+		return rc;
+	}
+
+	/* Disable multicast loopback */
+	sk = vn->sock->sk;
+	inet_sk(sk)->mc_loop = 0;
+
+	/* Mark socket as an encapsulation socket. */
+	udp_sk(sk)->encap_type = 1;
+	udp_sk(sk)->encap_rcv = vxlan_udp_encap_recv;
+	udp_encap_enable();
+
+	for (h = 0; h < VNI_HASH_SIZE; ++h)
+		INIT_HLIST_HEAD(&vn->vni_list[h]);
+
+	return 0;
+}
+
+static __net_exit void vxlan_exit_net(struct net *net)
+{
+	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
+
+	if (vn->sock) {
+		sock_release(vn->sock);
+		vn->sock = NULL;
+	}
+}
+
+static struct pernet_operations vxlan_net_ops = {
+	.init = vxlan_init_net,
+	.exit = vxlan_exit_net,
+	.id   = &vxlan_net_id,
+	.size = sizeof(struct vxlan_net),
+};
+
+static int __init vxlan_init_module(void)
+{
+	int rc;
+
+	get_random_bytes(&vxlan_salt, sizeof(vxlan_salt));
+
+	rc = register_pernet_device(&vxlan_net_ops);
+	if (rc)
+		goto out1;
+
+	rc = rtnl_link_register(&vxlan_link_ops);
+	if (rc)
+		goto out2;
+
+	return 0;
+
+out2:
+	unregister_pernet_device(&vxlan_net_ops);
+out1:
+	return rc;
+}
+module_init(vxlan_init_module);
+
+static void __exit vxlan_cleanup_module(void)
+{
+	rtnl_link_unregister(&vxlan_link_ops);
+	unregister_pernet_device(&vxlan_net_ops);
+}
+module_exit(vxlan_cleanup_module);
+
+MODULE_LICENSE("GPL");
+MODULE_VERSION(VXLAN_VERSION);
+MODULE_AUTHOR("Stephen Hemminger <shemminger@vyatta.com>");
+MODULE_ALIAS_RTNL_LINK("vxlan");
--- a/include/linux/if_link.h	2012-09-24 10:56:57.080291529 -0700
+++ b/include/linux/if_link.h	2012-09-24 11:08:02.869416484 -0700
@@ -272,6 +272,20 @@ enum macvlan_mode {
 
 #define MACVLAN_FLAG_NOPROMISC	1
 
+/* VXLAN section */
+enum {
+	IFLA_VXLAN_UNSPEC,
+	IFLA_VXLAN_ID,
+	IFLA_VXLAN_GROUP,
+	IFLA_VXLAN_LINK,
+	IFLA_VXLAN_LOCAL,
+	IFLA_VXLAN_TTL,
+	IFLA_VXLAN_TOS,
+	IFLA_VXLAN_LEARNING,
+	__IFLA_VXLAN_MAX
+};
+#define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
+
 /* SR-IOV virtual function management section */
 
 enum {
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ b/Documentation/networking/vxlan.txt	2012-09-24 11:08:02.869416484 -0700
@@ -0,0 +1,36 @@
+Virtual eXtensible Local Area Networking documentation
+======================================================
+
+The VXLAN protocol is a tunnelling protocol that is designed to
+solve the problem of limited number of available VLAN's (4096).
+With VXLAN identifier is expanded to 24 bits.
+
+It is a draft RFC standard, that is implemented by Cisco Nexus,
+Vmware and Brocade. The protocol runs over UDP using a single
+destination port (still not standardized by IANA).
+This document describes the Linux kernel tunnel device,
+there is also an implantation of VXLAN for Openvswitch.
+
+Unlike most tunnels, a VXLAN is a 1 to N network, not just point
+to point. A VXLAN device can either dynamically learn the IP address
+of the other end, in a manner similar to a learning bridge, or the
+forwarding entries can be configured statically.
+
+The management of vxlan is done in a similar fashion to it's
+too closest neighbors GRE and VLAN. Configuring VXLAN requires
+the version of iproute2 that matches the kernel release
+where VXLAN was first merged upstream.
+
+1. Create vxlan device
+  # ip li add vxlan0 type vxlan id 42 group 239.1.1.1 dev eth1
+
+This creates a new device (vxlan0). The device uses the
+the multicast group 239.1.1.1 over eth1 to handle packets where
+no entry is in the forwarding table.
+
+2. Delete vxlan device
+  # ip link delete vxlan0
+
+3. Show vxlan info
+  # ip -d show vxlan0
+
