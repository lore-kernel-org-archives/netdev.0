From: Cong Wang <amwang@redhat.com>
Subject: [RFC Patch net-next] vxlan: add ipv6 support
Date: Thu, 28 Feb 2013 14:01:26 +0800
Message-ID: <1362031286-23295-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10827 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750723Ab3B1GBm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2013 01:01:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WARNING: This is just an RFC patch, it only compiles!!

This patch adds IPv6 support to vxlan device, as the new version
RFC already mentioned it:

	http://tools.ietf.org/html/draft-mahalingam-dutt-dcops-vxlan-03

I am not sure if the following trick will work:

	+       if (nla_len(nla) == sizeof(__be32)) {
	+               ip->ip4 = nla_get_be32(nla);
	+               ip->proto = htons(ETH_P_IP);
	+       }
	+#if IS_ENABLED(CONFIG_IPV6)
	+       else if (nla_len(nla) == sizeof(struct in6_addr)) {
	+               nla_memcpy(&ip->ip6, nla, sizeof(struct in6_addr));
	+               ip->proto = htons(ETH_P_IPV6);
	+       }
	+#endif

otherwise we have to introduce some new netlink attributes for
IPv6 addresses? Any comments?
 
Cc: David S. Miller <davem@davemloft.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
 drivers/net/vxlan.c |  463 ++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 344 insertions(+), 119 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index f736823..6d6fc68 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -9,7 +9,6 @@
  *
  * TODO
  *  - use IANA UDP port number (when defined)
- *  - IPv6 (not in RFC)
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
@@ -42,6 +41,10 @@
 #include <net/inet_ecn.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#if IS_ENABLED(CONFIG_IPV6)
+#include <net/addrconf.h>
+#include <net/ip6_route.h>
+#endif
 
 #define VXLAN_VERSION	"0.1"
 
@@ -78,16 +81,29 @@ MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 static unsigned int vxlan_net_id;
 struct vxlan_net {
 	struct socket	  *sock;	/* UDP encap socket */
+#if IS_ENABLED(CONFIG_IPV6)
+	struct socket	  *sock6;
+#endif
 	struct hlist_head vni_list[VNI_HASH_SIZE];
 };
 
+struct vxlan_ip {
+	union {
+		__be32  ip4;
+#if IS_ENABLED(CONFIG_IPV6)
+		struct in6_addr ip6;
+#endif
+	};
+	__be16          proto;
+};
+
 /* Forwarding table entry */
 struct vxlan_fdb {
 	struct hlist_node hlist;	/* linked list of entries */
 	struct rcu_head	  rcu;
 	unsigned long	  updated;	/* jiffies */
 	unsigned long	  used;
-	__be32		  remote_ip;
+	struct vxlan_ip	  remote_ip;
 	u16		  state;	/* see ndm_state */
 	u8		  eth_addr[ETH_ALEN];
 };
@@ -107,8 +123,8 @@ struct vxlan_dev {
 	struct net_device *dev;
 	struct vxlan_stats __percpu *stats;
 	__u32		  vni;		/* virtual network id */
-	__be32	          gaddr;	/* multicast group */
-	__be32		  saddr;	/* source address */
+	struct vxlan_ip	  gaddr;	/* multicast group */
+	struct vxlan_ip	  saddr;	/* source address */
 	unsigned int      link;		/* link to multicast over */
 	__u16		  port_min;	/* source port range */
 	__u16		  port_max;
@@ -131,6 +147,62 @@ struct vxlan_dev {
 #define VXLAN_F_L2MISS	0x08
 #define VXLAN_F_L3MISS	0x10
 
+static inline int vxlan_ip_equal(const struct vxlan_ip *a, const struct vxlan_ip *b)
+{
+	if (a->proto != b->proto)
+		return 0;
+	switch (a->proto) {
+	case htons(ETH_P_IP):
+		return a->ip4 == b->ip4;
+#if IS_ENABLED(CONFIG_IPV6)
+	case htons(ETH_P_IPV6):
+		return ipv6_addr_equal(&a->ip6, &b->ip6);
+#endif
+	}
+	return 0;
+}
+
+static inline bool vxlan_ip_any(const struct vxlan_ip *ipa)
+{
+#if IS_ENABLED(CONFIG_IPV6)
+	if (ipa->proto == htons(ETH_P_IP))
+		return ipa->ip4 == htonl(INADDR_ANY);
+	else
+		return ipv6_addr_any(&ipa->ip6);
+#else
+	return ipa->ip4 == htonl(INADDR_ANY);
+#endif
+}
+
+static int vxlan_nla_get_addr(struct vxlan_ip *ip, struct nlattr *nla)
+{
+	if (nla_len(nla) == sizeof(__be32)) {
+		ip->ip4 = nla_get_be32(nla);
+		ip->proto = htons(ETH_P_IP);
+	}
+#if IS_ENABLED(CONFIG_IPV6)
+	else if (nla_len(nla) == sizeof(struct in6_addr)) {
+		nla_memcpy(&ip->ip6, nla, sizeof(struct in6_addr));
+		ip->proto = htons(ETH_P_IPV6);
+	}
+#endif
+	else
+		return -EAFNOSUPPORT;
+	return 0;
+}
+
+static int vxlan_nla_put_addr(struct sk_buff *skb, int attr, const struct vxlan_ip *ip)
+{
+	if (ip->proto == htons(ETH_P_IP))
+		return nla_put_be32(skb, attr, ip->ip4);
+#if IS_ENABLED(CONFIG_IPV6)
+	else if (ip->proto == htons(ETH_P_IPV6))
+		return nla_put(skb, attr, sizeof(struct in6_addr), &ip->ip6);
+#endif
+	else
+		return -EAFNOSUPPORT;
+}
+
 /* salt for hash table */
 static u32 vxlan_salt __read_mostly;
 
@@ -177,7 +249,7 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 
 	if (type == RTM_GETNEIGH) {
 		ndm->ndm_family	= AF_INET;
-		send_ip = fdb->remote_ip != 0;
+		send_ip = fdb->remote_ip.proto != 0;
 		send_eth = !is_zero_ether_addr(fdb->eth_addr);
 	} else
 		ndm->ndm_family	= AF_BRIDGE;
@@ -189,7 +261,7 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 	if (send_eth && nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->eth_addr))
 		goto nla_put_failure;
 
-	if (send_ip && nla_put_be32(skb, NDA_DST, fdb->remote_ip))
+	if (send_ip && vxlan_nla_put_addr(skb, NDA_DST, &fdb->remote_ip))
 		goto nla_put_failure;
 
 	ci.ndm_used	 = jiffies_to_clock_t(now - fdb->used);
@@ -211,7 +283,7 @@ static inline size_t vxlan_nlmsg_size(void)
 {
 	return NLMSG_ALIGN(sizeof(struct ndmsg))
 		+ nla_total_size(ETH_ALEN) /* NDA_LLADDR */
-		+ nla_total_size(sizeof(__be32)) /* NDA_DST */
+		+ nla_total_size(sizeof(struct in6_addr)) /* NDA_DST */
 		+ nla_total_size(sizeof(struct nda_cacheinfo));
 }
 
@@ -241,14 +313,14 @@ errout:
 		rtnl_set_sk_err(net, RTNLGRP_NEIGH, err);
 }
 
-static void vxlan_ip_miss(struct net_device *dev, __be32 ipa)
+static void vxlan_ip_miss(struct net_device *dev, struct vxlan_ip *ipa)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_fdb f;
 
 	memset(&f, 0, sizeof f);
 	f.state = NUD_STALE;
-	f.remote_ip = ipa; /* goes to NDA_DST */
+	f.remote_ip = *ipa; /* goes to NDA_DST */
 
 	vxlan_fdb_notify(vxlan, &f, RTM_GETNEIGH);
 }
@@ -304,7 +376,7 @@ static struct vxlan_fdb *vxlan_find_mac(struct vxlan_dev *vxlan,
 
 /* Add new entry to forwarding table -- assumes lock held */
 static int vxlan_fdb_create(struct vxlan_dev *vxlan,
-			    const u8 *mac, __be32 ip,
+			    const u8 *mac, struct vxlan_ip *ip,
 			    __u16 state, __u16 flags)
 {
 	struct vxlan_fdb *f;
@@ -335,7 +407,7 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 			return -ENOMEM;
 
 		notify = 1;
-		f->remote_ip = ip;
+		f->remote_ip = *ip;
 		f->state = state;
 		f->updated = f->used = jiffies;
 		memcpy(f->eth_addr, mac, ETH_ALEN);
@@ -369,7 +441,7 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 			 const unsigned char *addr, u16 flags)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	__be32 ip;
+	struct vxlan_ip ip;
 	int err;
 
 	if (!(ndm->ndm_state & (NUD_PERMANENT|NUD_REACHABLE))) {
@@ -381,13 +453,12 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	if (tb[NDA_DST] == NULL)
 		return -EINVAL;
 
-	if (nla_len(tb[NDA_DST]) != sizeof(__be32))
-		return -EAFNOSUPPORT;
-
-	ip = nla_get_be32(tb[NDA_DST]);
+	err = vxlan_nla_get_addr(&ip, tb[NDA_DST]);
+	if (err)
+		return err;
 
 	spin_lock_bh(&vxlan->hash_lock);
-	err = vxlan_fdb_create(vxlan, addr, ip, ndm->ndm_state, flags);
+	err = vxlan_fdb_create(vxlan, addr, &ip, ndm->ndm_state, flags);
 	spin_unlock_bh(&vxlan->hash_lock);
 
 	return err;
@@ -448,7 +519,7 @@ skip:
  * and Tunnel endpoint.
  */
 static void vxlan_snoop(struct net_device *dev,
-			__be32 src_ip, const u8 *src_mac)
+			struct vxlan_ip *src_ip, const u8 *src_mac)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_fdb *f;
@@ -457,7 +528,7 @@ static void vxlan_snoop(struct net_device *dev,
 	f = vxlan_find_mac(vxlan, src_mac);
 	if (likely(f)) {
 		f->used = jiffies;
-		if (likely(f->remote_ip == src_ip))
+		if (likely(vxlan_ip_equal(&f->remote_ip, src_ip)))
 			return;
 
 		if (net_ratelimit())
@@ -465,7 +536,7 @@ static void vxlan_snoop(struct net_device *dev,
 				    "%pM migrated from %pI4 to %pI4\n",
 				    src_mac, &f->remote_ip, &src_ip);
 
-		f->remote_ip = src_ip;
+		f->remote_ip = *src_ip;
 		f->updated = jiffies;
 	} else {
 		/* learned new entry */
@@ -494,7 +565,7 @@ static bool vxlan_group_used(struct vxlan_net *vn,
 			if (!netif_running(vxlan->dev))
 				continue;
 
-			if (vxlan->gaddr == this->gaddr)
+			if (vxlan_ip_equal(&vxlan->gaddr, &this->gaddr))
 				return true;
 		}
 
@@ -506,9 +577,9 @@ static int vxlan_join_group(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
-	struct sock *sk = vn->sock->sk;
+	struct sock *sk;
 	struct ip_mreqn mreq = {
-		.imr_multiaddr.s_addr	= vxlan->gaddr,
+		.imr_multiaddr.s_addr	= vxlan->gaddr.ip4,
 		.imr_ifindex		= vxlan->link,
 	};
 	int err;
@@ -519,8 +590,17 @@ static int vxlan_join_group(struct net_device *dev)
 
 	/* Need to drop RTNL to call multicast join */
 	rtnl_unlock();
-	lock_sock(sk);
-	err = ip_mc_join_group(sk, &mreq);
+	if (vxlan->gaddr.proto == htons(ETH_P_IP)) {
+		sk = vn->sock->sk;
+		lock_sock(sk);
+		err = ip_mc_join_group(sk, &mreq);
+	} else {
+#if IS_ENABLED(CONFIG_IPV6)
+		sk = vn->sock6->sk;
+		lock_sock(sk);
+		err = ipv6_sock_mc_join(sk, vxlan->link, &vxlan->gaddr.ip6);
+#endif
+	}
 	release_sock(sk);
 	rtnl_lock();
 
@@ -534,9 +614,9 @@ static int vxlan_leave_group(struct net_device *dev)
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 	int err = 0;
-	struct sock *sk = vn->sock->sk;
+	struct sock *sk;
 	struct ip_mreqn mreq = {
-		.imr_multiaddr.s_addr	= vxlan->gaddr,
+		.imr_multiaddr.s_addr	= vxlan->gaddr.ip4,
 		.imr_ifindex		= vxlan->link,
 	};
 
@@ -546,8 +626,17 @@ static int vxlan_leave_group(struct net_device *dev)
 
 	/* Need to drop RTNL to call multicast leave */
 	rtnl_unlock();
-	lock_sock(sk);
-	err = ip_mc_leave_group(sk, &mreq);
+	if (vxlan->gaddr.proto == htons(ETH_P_IP)) {
+		sk = vn->sock->sk;
+		lock_sock(sk);
+		err = ip_mc_leave_group(sk, &mreq);
+	} else {
+#if IS_ENABLED(CONFIG_IPV6)
+		sk = vn->sock6->sk;
+		lock_sock(sk);
+		err = ipv6_sock_mc_drop(sk, vxlan->link, &vxlan->gaddr.ip6);
+#endif
+	}
 	release_sock(sk);
 	rtnl_lock();
 
@@ -557,10 +646,12 @@ static int vxlan_leave_group(struct net_device *dev)
 /* Callback from net/ipv4/udp.c to receive packets */
 static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
-	struct iphdr *oip;
+	struct iphdr *oip = NULL;
+	struct ipv6hdr *oip6 = NULL;
 	struct vxlanhdr *vxh;
 	struct vxlan_dev *vxlan;
 	struct vxlan_stats *stats;
+	struct vxlan_ip src_ip;
 	__u32 vni;
 	int err;
 
@@ -599,7 +690,13 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	skb_reset_mac_header(skb);
 
 	/* Re-examine inner Ethernet packet */
-	oip = ip_hdr(skb);
+	if (skb->protocol == htons(ETH_P_IP))
+		oip = ip_hdr(skb);
+#if IS_ENABLED(CONFIG_IPV6)
+	else
+		oip6 = ipv6_hdr(skb);
+#endif
+
 	skb->protocol = eth_type_trans(skb, vxlan->dev);
 
 	/* Ignore packet loops (and multicast echo) */
@@ -607,8 +704,19 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 			       vxlan->dev->dev_addr) == 0)
 		goto drop;
 
-	if (vxlan->flags & VXLAN_F_LEARN)
-		vxlan_snoop(skb->dev, oip->saddr, eth_hdr(skb)->h_source);
+	if (vxlan->flags & VXLAN_F_LEARN) {
+		if (oip) {
+			src_ip.ip4 = oip->saddr;
+			src_ip.proto = htons(ETH_P_IP);
+		}
+#if IS_ENABLED(CONFIG_IPV6)
+		if (oip6) {
+			src_ip.ip6 = oip6->saddr;
+			src_ip.proto = ETH_P_IPV6;
+		}
+#endif
+		vxlan_snoop(skb->dev, &src_ip, eth_hdr(skb)->h_source);
+	}
 
 	__skb_tunnel_rx(skb, vxlan->dev);
 	skb_reset_network_header(skb);
@@ -663,6 +771,7 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
 	u8 *arpptr, *sha;
 	__be32 sip, tip;
 	struct neighbour *n;
+	struct vxlan_ip ipa;
 
 	if (dev->flags & IFF_NOARP)
 		goto out;
@@ -705,7 +814,7 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
 		}
 
 		f = vxlan_find_mac(vxlan, n->ha);
-		if (f && f->remote_ip == 0) {
+		if (f && f->remote_ip.proto == 0) {
 			/* bridge-local neighbor */
 			neigh_release(n);
 			goto out;
@@ -723,8 +832,11 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
 
 		if (netif_rx_ni(reply) == NET_RX_DROP)
 			dev->stats.rx_dropped++;
-	} else if (vxlan->flags & VXLAN_F_L3MISS)
-		vxlan_ip_miss(dev, tip);
+	} else if (vxlan->flags & VXLAN_F_L3MISS) {
+		ipa.ip4 = tip;
+		ipa.proto = htons(ETH_P_IP);
+		vxlan_ip_miss(dev, &ipa);
+	}
 out:
 	consume_skb(skb);
 	return NETDEV_TX_OK;
@@ -746,6 +858,14 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 			return false;
 		pip = ip_hdr(skb);
 		n = neigh_lookup(&arp_tbl, &pip->daddr, dev);
+		if (!n && vxlan->flags & VXLAN_F_L3MISS) {
+			struct vxlan_ip ipa;
+			ipa.ip4 = pip->daddr;
+			ipa.proto = htons(ETH_P_IP);
+			vxlan_ip_miss(dev, &ipa);
+			return false;
+		}
+
 		break;
 	default:
 		return false;
@@ -762,17 +882,17 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 		}
 		neigh_release(n);
 		return diff;
-	} else if (vxlan->flags & VXLAN_F_L3MISS)
-		vxlan_ip_miss(dev, pip->daddr);
+	}
+
 	return false;
 }
 
 /* Extract dsfield from inner protocol */
-static inline u8 vxlan_get_dsfield(const struct iphdr *iph,
+static inline u8 vxlan_get_dsfield(const void *iph,
 				   const struct sk_buff *skb)
 {
 	if (skb->protocol == htons(ETH_P_IP))
-		return iph->tos;
+		return ((struct iphdr *)iph)->tos;
 	else if (skb->protocol == htons(ETH_P_IPV6))
 		return ipv6_get_dsfield((const struct ipv6hdr *)iph);
 	else
@@ -795,10 +915,11 @@ static void vxlan_sock_free(struct sk_buff *skb)
 }
 
 /* On transmit, associate with the tunnel socket */
-static void vxlan_set_owner(struct net_device *dev, struct sk_buff *skb)
+static inline void vxlan_set_owner(struct net_device *dev,
+				   struct sk_buff *skb, bool ipv6)
 {
 	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
-	struct sock *sk = vn->sock->sk;
+	struct sock *sk = ipv6 ? vn->sock6->sk : vn->sock->sk;
 
 	skb_orphan(skb);
 	sock_hold(sk);
@@ -833,15 +954,16 @@ static u16 vxlan_src_port(const struct vxlan_dev *vxlan, struct sk_buff *skb)
 static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct rtable *rt;
-	const struct iphdr *old_iph;
+	const struct iphdr *old_iph = NULL;
+	const struct ipv6hdr *old_iph6 = NULL;
 	struct ethhdr *eth;
 	struct iphdr *iph;
+	struct ipv6hdr *ip6h;
 	struct vxlanhdr *vxh;
 	struct udphdr *uh;
-	struct flowi4 fl4;
 	unsigned int pkt_len = skb->len;
-	__be32 dst;
+	const struct vxlan_ip *dst;
+	struct dst_entry *ndst;
 	__u16 src_port;
 	__be16 df = 0;
 	__u8 tos, ttl;
@@ -860,14 +982,14 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	f = vxlan_find_mac(vxlan, eth->h_dest);
 	if (f == NULL) {
 		did_rsc = false;
-		dst = vxlan->gaddr;
-		if (!dst && (vxlan->flags & VXLAN_F_L2MISS) &&
+		dst = &vxlan->gaddr;
+		if (vxlan_ip_any(dst) && (vxlan->flags & VXLAN_F_L2MISS) &&
 		    !is_multicast_ether_addr(eth->h_dest))
 			vxlan_fdb_miss(vxlan, eth->h_dest);
 	} else
-		dst = f->remote_ip;
+		dst = &f->remote_ip;
 
-	if (!dst) {
+	if (vxlan_ip_any(dst)) {
 		if (did_rsc) {
 			__skb_pull(skb, skb_network_offset(skb));
 			skb->ip_summed = CHECKSUM_NONE;
@@ -900,43 +1022,83 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (skb_cow_head(skb, VXLAN_HEADROOM))
 		goto drop;
 
-	old_iph = ip_hdr(skb);
+	if (dst->proto == htons(ETH_P_IP)) {
+		struct flowi4 fl4;
+		struct rtable *rt;
 
-	ttl = vxlan->ttl;
-	if (!ttl && IN_MULTICAST(ntohl(dst)))
-		ttl = 1;
+		old_iph = ip_hdr(skb);
+		ttl = vxlan->ttl;
+		if (!ttl && IN_MULTICAST(ntohl(dst->ip4)))
+			ttl = 1;
 
-	tos = vxlan->tos;
-	if (tos == 1)
-		tos = vxlan_get_dsfield(old_iph, skb);
+		tos = vxlan->tos;
+		if (tos == 1)
+			tos = vxlan_get_dsfield(old_iph, skb);
 
-	src_port = vxlan_src_port(vxlan, skb);
+		src_port = vxlan_src_port(vxlan, skb);
 
-	memset(&fl4, 0, sizeof(fl4));
-	fl4.flowi4_oif = vxlan->link;
-	fl4.flowi4_tos = RT_TOS(tos);
-	fl4.daddr = dst;
-	fl4.saddr = vxlan->saddr;
+		memset(&fl4, 0, sizeof(fl4));
+		fl4.flowi4_oif = vxlan->link;
+		fl4.flowi4_tos = RT_TOS(tos);
+		fl4.daddr = dst->ip4;
+		fl4.saddr = vxlan->saddr.ip4;
 
-	rt = ip_route_output_key(dev_net(dev), &fl4);
-	if (IS_ERR(rt)) {
-		netdev_dbg(dev, "no route to %pI4\n", &dst);
-		dev->stats.tx_carrier_errors++;
-		goto tx_error;
-	}
+		rt = ip_route_output_key(dev_net(dev), &fl4);
+		if (IS_ERR(rt)) {
+			netdev_dbg(dev, "no route to %pI4\n", &dst->ip4);
+			dev->stats.tx_carrier_errors++;
+			goto tx_error;
+		}
+
+		if (rt->dst.dev == dev) {
+			netdev_dbg(dev, "circular route to %pI4\n", &dst->ip4);
+			ip_rt_put(rt);
+			dev->stats.collisions++;
+			goto tx_error;
+		}
+		ndst = &rt->dst;
+		memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
+	} else {
+#if IS_ENABLED(CONFIG_IPV6)
+		struct flowi6 fl6;
+
+		old_iph6 = ipv6_hdr(skb);
+		ttl = vxlan->ttl;
+		if (!ttl && ipv6_addr_is_multicast(&dst->ip6))
+			ttl = 1;
+
+		tos = vxlan->tos;
+		if (tos == 1)
+			tos = vxlan_get_dsfield(old_iph6, skb);
+
+		src_port = vxlan_src_port(vxlan, skb);
+
+		memset(&fl6, 0, sizeof(fl6));
+		fl6.flowi6_oif = vxlan->link;
+		fl6.flowi6_tos = RT_TOS(tos);
+		fl6.daddr = dst->ip6;
+		fl6.saddr = vxlan->saddr.ip6;
+
+		ndst = ip6_route_output(dev_net(dev), NULL, &fl6);
+		if (ndst->error) {
+			netdev_dbg(dev, "no route to %pI6\n", &dst->ip6);
+			dev->stats.tx_carrier_errors++;
+			goto tx_error;
+		}
 
-	if (rt->dst.dev == dev) {
-		netdev_dbg(dev, "circular route to %pI4\n", &dst);
-		ip_rt_put(rt);
-		dev->stats.collisions++;
-		goto tx_error;
+		if (ndst->dev == dev) {
+			netdev_dbg(dev, "circular route to %pI6\n", &dst->ip6);
+			dst_release(ndst);
+			dev->stats.collisions++;
+			goto tx_error;
+		}
+#endif
 	}
 
-	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
 			      IPSKB_REROUTED);
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
+	skb_dst_set(skb, ndst);
 
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
 	vxh->vx_flags = htonl(VXLAN_FLAGS);
@@ -952,20 +1114,36 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	uh->len = htons(skb->len);
 	uh->check = 0;
 
-	__skb_push(skb, sizeof(*iph));
-	skb_reset_network_header(skb);
-	iph		= ip_hdr(skb);
-	iph->version	= 4;
-	iph->ihl	= sizeof(struct iphdr) >> 2;
-	iph->frag_off	= df;
-	iph->protocol	= IPPROTO_UDP;
-	iph->tos	= vxlan_ecn_encap(tos, old_iph, skb);
-	iph->daddr	= dst;
-	iph->saddr	= fl4.saddr;
-	iph->ttl	= ttl ? : ip4_dst_hoplimit(&rt->dst);
-	tunnel_ip_select_ident(skb, old_iph, &rt->dst);
-
-	vxlan_set_owner(dev, skb);
+	if (dst->proto == htons(ETH_P_IP)) {
+		__skb_push(skb, sizeof(*iph));
+		skb_reset_network_header(skb);
+		iph		= ip_hdr(skb);
+		iph->version	= 4;
+		iph->ihl	= sizeof(struct iphdr) >> 2;
+		iph->frag_off	= df;
+		iph->protocol	= IPPROTO_UDP;
+		iph->tos	= vxlan_ecn_encap(tos, old_iph, skb);
+		iph->daddr	= dst->ip4;
+		iph->saddr	= vxlan->saddr.ip4;
+		iph->ttl	= ttl ? : ip4_dst_hoplimit(ndst);
+		tunnel_ip_select_ident(skb, old_iph, ndst);
+
+		vxlan_set_owner(dev, skb, false);
+	} else {
+#if IS_ENABLED(CONFIG_IPV6)
+		__skb_push(skb, sizeof(*ip6h));
+		skb_reset_network_header(skb);
+		ip6h		  = ipv6_hdr(skb);
+		ip6h->version	  = 6;
+		ip6h->payload_len = htons(skb->len - sizeof(*ip6h));
+		ip6h->nexthdr     = IPPROTO_UDP;
+		ip6h->hop_limit   = ttl ? : ip6_dst_hoplimit(ndst);
+		ip6h->daddr	  = dst->ip6;
+		ip6h->saddr	  = vxlan->saddr.ip6;
+
+		vxlan_set_owner(dev, skb, true);
+#endif
+	}
 
 	/* See iptunnel_xmit() */
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
@@ -1051,7 +1229,7 @@ static int vxlan_open(struct net_device *dev)
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	int err;
 
-	if (vxlan->gaddr) {
+	if (!vxlan_ip_any(&vxlan->gaddr)) {
 		err = vxlan_join_group(dev);
 		if (err)
 			return err;
@@ -1085,7 +1263,7 @@ static int vxlan_stop(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 
-	if (vxlan->gaddr)
+	if (!vxlan_ip_any(&vxlan->gaddr))
 		vxlan_leave_group(dev);
 
 	del_timer_sync(&vxlan->age_timer);
@@ -1253,10 +1431,19 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
 	}
 
 	if (data[IFLA_VXLAN_GROUP]) {
-		__be32 gaddr = nla_get_be32(data[IFLA_VXLAN_GROUP]);
-		if (!IN_MULTICAST(ntohl(gaddr))) {
-			pr_debug("group address is not IPv4 multicast\n");
-			return -EADDRNOTAVAIL;
+		if (nla_len(data[IFLA_VXLAN_GROUP]) == sizeof(__be32)) {
+			__be32 gaddr = nla_get_be32(data[IFLA_VXLAN_GROUP]);
+			if (!IN_MULTICAST(ntohl(gaddr))) {
+				pr_debug("group address is not IPv4 multicast\n");
+				return -EADDRNOTAVAIL;
+			}
+		} else if (nla_len(data[IFLA_VXLAN_GROUP]) == sizeof(struct in6_addr)) {
+			struct in6_addr gaddr;
+			nla_memcpy(&gaddr, data[IFLA_VXLAN_GROUP], sizeof(struct in6_addr));
+			if (!ipv6_addr_is_multicast(&gaddr)) {
+				pr_debug("group address is not IPv6 multicast\n");
+				return -EADDRNOTAVAIL;
+			}
 		}
 	}
 
@@ -1304,10 +1491,10 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 	vxlan->vni = vni;
 
 	if (data[IFLA_VXLAN_GROUP])
-		vxlan->gaddr = nla_get_be32(data[IFLA_VXLAN_GROUP]);
+		vxlan_nla_get_addr(&vxlan->gaddr, data[IFLA_VXLAN_GROUP]);
 
 	if (data[IFLA_VXLAN_LOCAL])
-		vxlan->saddr = nla_get_be32(data[IFLA_VXLAN_LOCAL]);
+		vxlan_nla_get_addr(&vxlan->saddr, data[IFLA_VXLAN_LOCAL]);
 
 	if (data[IFLA_VXLAN_LINK] &&
 	    (vxlan->link = nla_get_u32(data[IFLA_VXLAN_LINK]))) {
@@ -1385,9 +1572,9 @@ static size_t vxlan_get_size(const struct net_device *dev)
 {
 
 	return nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_ID */
-		nla_total_size(sizeof(__be32)) +/* IFLA_VXLAN_GROUP */
+		nla_total_size(sizeof(struct in6_addr)) + /* IFLA_VXLAN_GROUP */
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_LINK */
-		nla_total_size(sizeof(__be32))+	/* IFLA_VXLAN_LOCAL */
+		nla_total_size(sizeof(struct in6_addr)) + /* IFLA_VXLAN_LOCAL */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_TTL */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_TOS */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_LEARNING */
@@ -1412,13 +1599,13 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	if (nla_put_u32(skb, IFLA_VXLAN_ID, vxlan->vni))
 		goto nla_put_failure;
 
-	if (vxlan->gaddr && nla_put_be32(skb, IFLA_VXLAN_GROUP, vxlan->gaddr))
+	if (!vxlan_ip_any(&vxlan->gaddr) && vxlan_nla_put_addr(skb, IFLA_VXLAN_GROUP, &vxlan->gaddr))
 		goto nla_put_failure;
 
 	if (vxlan->link && nla_put_u32(skb, IFLA_VXLAN_LINK, vxlan->link))
 		goto nla_put_failure;
 
-	if (vxlan->saddr && nla_put_be32(skb, IFLA_VXLAN_LOCAL, vxlan->saddr))
+	if (!vxlan_ip_any(&vxlan->saddr) && vxlan_nla_put_addr(skb, IFLA_VXLAN_LOCAL, &vxlan->saddr))
 		goto nla_put_failure;
 
 	if (nla_put_u8(skb, IFLA_VXLAN_TTL, vxlan->ttl) ||
@@ -1458,39 +1645,35 @@ static struct rtnl_link_ops vxlan_link_ops __read_mostly = {
 	.fill_info	= vxlan_fill_info,
 };
 
-static __net_init int vxlan_init_net(struct net *net)
+static __net_init int vxlan_init_sock(struct net *net, struct socket **sock,
+				      struct sockaddr *addr)
 {
-	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct sock *sk;
-	struct sockaddr_in vxlan_addr = {
-		.sin_family = AF_INET,
-		.sin_addr.s_addr = htonl(INADDR_ANY),
-	};
-	int rc;
-	unsigned h;
+	int val = 1, rc;
 
 	/* Create UDP socket for encapsulation receive. */
-	rc = sock_create_kern(AF_INET, SOCK_DGRAM, IPPROTO_UDP, &vn->sock);
+	rc = sock_create_kern(addr->sa_family, SOCK_DGRAM, IPPROTO_UDP, sock);
 	if (rc < 0) {
 		pr_debug("UDP socket create failed\n");
 		return rc;
 	}
 	/* Put in proper namespace */
-	sk = vn->sock->sk;
+	sk = (*sock)->sk;
 	sk_change_net(sk, net);
 
-	vxlan_addr.sin_port = htons(vxlan_port);
-
-	rc = kernel_bind(vn->sock, (struct sockaddr *) &vxlan_addr,
-			 sizeof(vxlan_addr));
+	rc = kernel_bind(*sock, addr, addr->sa_family == AF_INET ?
+			 sizeof(struct sockaddr_in) : sizeof(struct sockaddr_in6));
 	if (rc < 0) {
-		pr_debug("bind for UDP socket %pI4:%u (%d)\n",
-			 &vxlan_addr.sin_addr, ntohs(vxlan_addr.sin_port), rc);
 		sk_release_kernel(sk);
-		vn->sock = NULL;
+		*sock = NULL;
 		return rc;
 	}
 
+#if IS_ENABLED(CONFIG_IPV6)
+	if (addr->sa_family == AF_INET6)
+		kernel_setsockopt(*sock, SOL_IPV6, IPV6_V6ONLY,
+				  (char *)&val, sizeof(val));
+#endif
 	/* Disable multicast loopback */
 	inet_sk(sk)->mc_loop = 0;
 
@@ -1498,6 +1681,42 @@ static __net_init int vxlan_init_net(struct net *net)
 	udp_sk(sk)->encap_type = 1;
 	udp_sk(sk)->encap_rcv = vxlan_udp_encap_recv;
 	udp_encap_enable();
+	return 0;
+}
+
+static __net_init int vxlan_init_net(struct net *net)
+{
+	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
+	int rc;
+	unsigned h;
+	struct sockaddr_in vxlan_addr = {
+		.sin_family = AF_INET,
+		.sin_addr.s_addr = htonl(INADDR_ANY),
+		.sin_port = htons(vxlan_port),
+	};
+#if IS_ENABLED(CONFIG_IPV6)
+	struct sockaddr_in6 vxlan_addr6 = {
+		.sin6_family = AF_INET6,
+		.sin6_port = htons(vxlan_port),
+	};
+#endif
+
+	rc = vxlan_init_sock(net, &vn->sock, (struct sockaddr *)&vxlan_addr);
+	if (rc < 0) {
+		pr_debug("bind for UDP socket %pI4:%u (%d)\n",
+			 &vxlan_addr.sin_addr, ntohs(vxlan_addr.sin_port), rc);
+		return rc;
+	}
+#if IS_ENABLED(CONFIG_IPV6)
+	rc = vxlan_init_sock(net, &vn->sock6, (struct sockaddr *)&vxlan_addr6);
+	if (rc < 0) {
+		sk_release_kernel(vn->sock->sk);
+		vn->sock = NULL;
+		pr_debug("bind for UDP socket %pI6:%u (%d)\n",
+			 &vxlan_addr6.sin6_addr, ntohs(vxlan_addr6.sin6_port), rc);
+		return rc;
+	}
+#endif
 
 	for (h = 0; h < VNI_HASH_SIZE; ++h)
 		INIT_HLIST_HEAD(&vn->vni_list[h]);
@@ -1513,6 +1732,12 @@ static __net_exit void vxlan_exit_net(struct net *net)
 		sk_release_kernel(vn->sock->sk);
 		vn->sock = NULL;
 	}
+#if IS_ENABLED(CONFIG_IPV6)
+	if (vn->sock6) {
+		sk_release_kernel(vn->sock6->sk);
+		vn->sock6 = NULL;
+	}
+#endif
 }
 
 static struct pernet_operations vxlan_net_ops = {
