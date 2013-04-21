From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v5 4/5] vxlan: add ipv6 support
Date: Sun, 21 Apr 2013 22:23:11 +0800
Message-ID: <1366554192-27887-5-git-send-email-amwang@redhat.com>
References: <1366554192-27887-1-git-send-email-amwang@redhat.com>
Cc: David Stevens <dlstevens@us.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25877 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753676Ab3DUOYV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Apr 2013 10:24:21 -0400
In-Reply-To: <1366554192-27887-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

This patch adds IPv6 support to vxlan device, as the new version
RFC already mentions it:

   http://tools.ietf.org/html/draft-mahalingam-dutt-dcops-vxlan-03

Cc: David Stevens <dlstevens@us.ibm.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/vxlan.c          |  623 +++++++++++++++++++++++++++++++++---------
 include/uapi/linux/if_link.h |    2 +
 2 files changed, 489 insertions(+), 136 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index f8ac900..8167973 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -9,7 +9,6 @@
  *
  * TODO
  *  - use IANA UDP port number (when defined)
- *  - IPv6 (not in RFC)
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
@@ -42,6 +41,11 @@
 #include <net/inet_ecn.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#if IS_ENABLED(CONFIG_IPV6)
+#include <net/addrconf.h>
+#include <net/ip6_route.h>
+#include <net/ip6_tunnel.h>
+#endif
 
 #define VXLAN_VERSION	"0.1"
 
@@ -56,6 +60,7 @@
 #define VXLAN_VID_MASK	(VXLAN_N_VID - 1)
 /* IP header + UDP + VXLAN + Ethernet header */
 #define VXLAN_HEADROOM (20 + 8 + 8 + 14)
+#define VXLAN6_HEADROOM (40 + 8 + 8 + 14)
 
 #define VXLAN_FLAGS 0x08000000	/* struct vxlanhdr.vx_flags required value. */
 
@@ -81,9 +86,15 @@ struct vxlan_net {
 	struct hlist_head vni_list[VNI_HASH_SIZE];
 };
 
+union vxlan_addr {
+	struct sockaddr_in	sin;
+	struct sockaddr_in6	sin6;
+	struct sockaddr		sa;
+};
+
 struct vxlan_rdst {
 	struct rcu_head		 rcu;
-	__be32			 remote_ip;
+	union vxlan_addr	 remote_ip;
 	__be16			 remote_port;
 	u32			 remote_vni;
 	u32			 remote_ifindex;
@@ -106,7 +117,7 @@ struct vxlan_dev {
 	struct hlist_node hlist;
 	struct net_device *dev;
 	struct vxlan_rdst default_dst;	/* default destination */
-	__be32		  saddr;	/* source address */
+	union vxlan_addr saddr;	/* source address */
 	__u16		  port_min;	/* source port range */
 	__u16		  port_max;
 	__u8		  tos;		/* TOS override */
@@ -128,6 +139,69 @@ struct vxlan_dev {
 #define VXLAN_F_L2MISS	0x08
 #define VXLAN_F_L3MISS	0x10
 
+static inline
+bool vxlan_addr_equal(const union vxlan_addr *a, const union vxlan_addr *b)
+{
+#if IS_ENABLED(CONFIG_IPV6)
+	if (a->sa.sa_family != b->sa.sa_family)
+		return false;
+	if (a->sa.sa_family == AF_INET6)
+		return ipv6_addr_equal(&a->sin6.sin6_addr, &b->sin6.sin6_addr);
+	else
+#endif
+		return a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr;
+}
+
+static inline bool vxlan_addr_any(const union vxlan_addr *ipa)
+{
+#if IS_ENABLED(CONFIG_IPV6)
+	if (ipa->sa.sa_family == AF_INET6)
+		return ipv6_addr_any(&ipa->sin6.sin6_addr);
+	else
+#endif
+		return ipa->sin.sin_addr.s_addr == htonl(INADDR_ANY);
+}
+
+static inline bool vxlan_addr_multicast(const union vxlan_addr *ipa)
+{
+#if IS_ENABLED(CONFIG_IPV6)
+	if (ipa->sa.sa_family == AF_INET6)
+		return ipv6_addr_is_multicast(&ipa->sin6.sin6_addr);
+	else
+#endif
+		return IN_MULTICAST(ntohl(ipa->sin.sin_addr.s_addr));
+}
+
+static int vxlan_nla_get_addr(union vxlan_addr *ip, struct nlattr *nla)
+{
+	if (nla_len(nla) >= sizeof(struct in6_addr)) {
+#if IS_ENABLED(CONFIG_IPV6)
+		nla_memcpy(&ip->sin6.sin6_addr, nla, sizeof(struct in6_addr));
+		ip->sa.sa_family = AF_INET6;
+		return 0;
+#else
+		return -EAFNOSUPPORT;
+#endif
+	} else if (nla_len(nla) >= sizeof(__be32)) {
+		ip->sin.sin_addr.s_addr = nla_get_be32(nla);
+		ip->sa.sa_family = AF_INET;
+		return 0;
+	} else {
+		return -EAFNOSUPPORT;
+	}
+}
+
+static int vxlan_nla_put_addr(struct sk_buff *skb, int attr,
+			      const union vxlan_addr *ip)
+{
+#if IS_ENABLED(CONFIG_IPV6)
+	if (ip->sa.sa_family == AF_INET6)
+		return nla_put(skb, attr, sizeof(struct in6_addr), &ip->sin6.sin6_addr);
+	else
+#endif
+		return nla_put_be32(skb, attr, ip->sin.sin_addr.s_addr);
+}
+
 /* salt for hash table */
 static u32 vxlan_salt __read_mostly;
 
@@ -174,7 +248,7 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 
 	if (type == RTM_GETNEIGH) {
 		ndm->ndm_family	= AF_INET;
-		send_ip = rdst->remote_ip != htonl(INADDR_ANY);
+		send_ip = !vxlan_addr_any(&rdst->remote_ip);
 		send_eth = !is_zero_ether_addr(fdb->eth_addr);
 	} else
 		ndm->ndm_family	= AF_BRIDGE;
@@ -186,7 +260,7 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 	if (send_eth && nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->eth_addr))
 		goto nla_put_failure;
 
-	if (send_ip && nla_put_be32(skb, NDA_DST, rdst->remote_ip))
+	if (send_ip && vxlan_nla_put_addr(skb, NDA_DST, &rdst->remote_ip))
 		goto nla_put_failure;
 
 	if (rdst->remote_port && rdst->remote_port != vxlan_port &&
@@ -218,7 +292,7 @@ static inline size_t vxlan_nlmsg_size(void)
 {
 	return NLMSG_ALIGN(sizeof(struct ndmsg))
 		+ nla_total_size(ETH_ALEN) /* NDA_LLADDR */
-		+ nla_total_size(sizeof(__be32)) /* NDA_DST */
+		+ nla_total_size(sizeof(struct in6_addr)) /* NDA_DST */
 		+ nla_total_size(sizeof(__be32)) /* NDA_PORT */
 		+ nla_total_size(sizeof(__be32)) /* NDA_VNI */
 		+ nla_total_size(sizeof(__u32)) /* NDA_IFINDEX */
@@ -251,14 +325,14 @@ errout:
 		rtnl_set_sk_err(net, RTNLGRP_NEIGH, err);
 }
 
-static void vxlan_ip_miss(struct net_device *dev, __be32 ipa)
+static void vxlan_ip_miss(struct net_device *dev, union vxlan_addr *ipa)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_fdb f;
 
 	memset(&f, 0, sizeof f);
 	f.state = NUD_STALE;
-	f.remote.remote_ip = ipa; /* goes to NDA_DST */
+	f.remote.remote_ip = *ipa; /* goes to NDA_DST */
 	f.remote.remote_vni = VXLAN_N_VID;
 
 	vxlan_fdb_notify(vxlan, &f, RTM_GETNEIGH);
@@ -313,14 +387,14 @@ static struct vxlan_fdb *vxlan_find_mac(struct vxlan_dev *vxlan,
 }
 
 /* Add/update destinations for multicast */
-static int vxlan_fdb_append(struct vxlan_fdb *f,
-			    __be32 ip, __u32 port, __u32 vni, __u32 ifindex)
+static int vxlan_fdb_append(struct vxlan_fdb *f, union vxlan_addr *ip,
+			    __u32 port, __u32 vni, __u32 ifindex)
 {
 	struct vxlan_rdst *rd_prev, *rd;
 
 	rd_prev = NULL;
 	for (rd = &f->remote; rd; rd = rd->remote_next) {
-		if (rd->remote_ip == ip &&
+		if (vxlan_addr_equal(&rd->remote_ip, ip) &&
 		    rd->remote_port == port &&
 		    rd->remote_vni == vni &&
 		    rd->remote_ifindex == ifindex)
@@ -330,7 +404,7 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
 	rd = kmalloc(sizeof(*rd), GFP_ATOMIC);
 	if (rd == NULL)
 		return -ENOBUFS;
-	rd->remote_ip = ip;
+	rd->remote_ip = *ip;
 	rd->remote_port = port;
 	rd->remote_vni = vni;
 	rd->remote_ifindex = ifindex;
@@ -341,7 +415,7 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
 
 /* Add new entry to forwarding table -- assumes lock held */
 static int vxlan_fdb_create(struct vxlan_dev *vxlan,
-			    const u8 *mac, __be32 ip,
+			    const u8 *mac, union vxlan_addr *ip,
 			    __u16 state, __u16 flags,
 			    __u32 port, __u32 vni, __u32 ifindex)
 {
@@ -375,13 +449,18 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 		if (vxlan->addrmax && vxlan->addrcnt >= vxlan->addrmax)
 			return -ENOSPC;
 
-		netdev_dbg(vxlan->dev, "add %pM -> %pI4\n", mac, &ip);
+#if IS_ENABLED(CONFIG_IPV6)
+		if (ip->sa.sa_family == AF_INET6)
+			netdev_dbg(vxlan->dev, "add %pM -> %pI6\n", mac, &ip->sin6.sin6_addr);
+		else
+#endif
+			netdev_dbg(vxlan->dev, "add %pM -> %pI4\n", mac, &ip->sin.sin_addr.s_addr);
 		f = kmalloc(sizeof(*f), GFP_ATOMIC);
 		if (!f)
 			return -ENOMEM;
 
 		notify = 1;
-		f->remote.remote_ip = ip;
+		f->remote.remote_ip = *ip;
 		f->remote.remote_port = port;
 		f->remote.remote_vni = vni;
 		f->remote.remote_ifindex = ifindex;
@@ -433,7 +512,7 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct net *net = dev_net(vxlan->dev);
-	__be32 ip;
+	union vxlan_addr ip;
 	u32 port, vni, ifindex;
 	int err;
 
@@ -446,10 +525,9 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	if (tb[NDA_DST] == NULL)
 		return -EINVAL;
 
-	if (nla_len(tb[NDA_DST]) != sizeof(__be32))
-		return -EAFNOSUPPORT;
-
-	ip = nla_get_be32(tb[NDA_DST]);
+	err = vxlan_nla_get_addr(&ip, tb[NDA_DST]);
+	if (err)
+		return err;
 
 	if (tb[NDA_PORT]) {
 		if (nla_len(tb[NDA_PORT]) != sizeof(u32))
@@ -479,7 +557,7 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		ifindex = 0;
 
 	spin_lock_bh(&vxlan->hash_lock);
-	err = vxlan_fdb_create(vxlan, addr, ip, ndm->ndm_state, flags, port,
+	err = vxlan_fdb_create(vxlan, addr, &ip, ndm->ndm_state, flags, port,
 		vni, ifindex);
 	spin_unlock_bh(&vxlan->hash_lock);
 
@@ -543,7 +621,7 @@ skip:
  * and Tunnel endpoint.
  */
 static void vxlan_snoop(struct net_device *dev,
-			__be32 src_ip, const u8 *src_mac)
+			union vxlan_addr *src_ip, const u8 *src_mac)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_fdb *f;
@@ -552,15 +630,25 @@ static void vxlan_snoop(struct net_device *dev,
 	f = vxlan_find_mac(vxlan, src_mac);
 	if (likely(f)) {
 		f->used = jiffies;
-		if (likely(f->remote.remote_ip == src_ip))
+		if (likely(vxlan_addr_equal(&f->remote.remote_ip, src_ip)))
 			return;
 
-		if (net_ratelimit())
-			netdev_info(dev,
-				    "%pM migrated from %pI4 to %pI4\n",
-				    src_mac, &f->remote.remote_ip, &src_ip);
+		if (net_ratelimit()) {
+#if IS_ENABLED(CONFIG_IPV6)
+			if (src_ip->sa.sa_family == AF_INET6)
+				netdev_info(dev,
+					    "%pM migrated from %pI6 to %pI6\n",
+					    src_mac, &f->remote.remote_ip.sin6.sin6_addr,
+					    &src_ip->sin6.sin6_addr);
+			else
+#endif
+				netdev_info(dev,
+					    "%pM migrated from %pI4 to %pI4\n",
+					    src_mac, &f->remote.remote_ip.sin.sin_addr.s_addr,
+					    &src_ip->sin.sin_addr.s_addr);
+		}
 
-		f->remote.remote_ip = src_ip;
+		f->remote.remote_ip = *src_ip;
 		f->updated = jiffies;
 	} else {
 		/* learned new entry */
@@ -589,7 +677,8 @@ static bool vxlan_group_used(struct vxlan_net *vn,
 			if (!netif_running(vxlan->dev))
 				continue;
 
-			if (vxlan->default_dst.remote_ip == this->default_dst.remote_ip)
+			if (vxlan_addr_equal(&vxlan->default_dst.remote_ip,
+					     &this->default_dst.remote_ip))
 				return true;
 		}
 
@@ -603,7 +692,7 @@ static int vxlan_join_group(struct net_device *dev)
 	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 	struct sock *sk = vn->sock->sk;
 	struct ip_mreqn mreq = {
-		.imr_multiaddr.s_addr	= vxlan->default_dst.remote_ip,
+		.imr_multiaddr.s_addr	= vxlan->default_dst.remote_ip.sin.sin_addr.s_addr,
 		.imr_ifindex		= vxlan->default_dst.remote_ifindex,
 	};
 	int err;
@@ -615,7 +704,13 @@ static int vxlan_join_group(struct net_device *dev)
 	/* Need to drop RTNL to call multicast join */
 	rtnl_unlock();
 	lock_sock(sk);
-	err = ip_mc_join_group(sk, &mreq);
+#if IS_ENABLED(CONFIG_IPV6)
+	if (vxlan->default_dst.remote_ip.sa.sa_family == AF_INET6)
+		err = ipv6_sock_mc_join(sk, vxlan->default_dst.remote_ifindex,
+					&vxlan->default_dst.remote_ip.sin6.sin6_addr);
+	else
+#endif
+		err = ip_mc_join_group(sk, &mreq);
 	release_sock(sk);
 	rtnl_lock();
 
@@ -631,7 +726,7 @@ static int vxlan_leave_group(struct net_device *dev)
 	int err = 0;
 	struct sock *sk = vn->sock->sk;
 	struct ip_mreqn mreq = {
-		.imr_multiaddr.s_addr	= vxlan->default_dst.remote_ip,
+		.imr_multiaddr.s_addr	= vxlan->default_dst.remote_ip.sin.sin_addr.s_addr,
 		.imr_ifindex		= vxlan->default_dst.remote_ifindex,
 	};
 
@@ -642,7 +737,13 @@ static int vxlan_leave_group(struct net_device *dev)
 	/* Need to drop RTNL to call multicast leave */
 	rtnl_unlock();
 	lock_sock(sk);
-	err = ip_mc_leave_group(sk, &mreq);
+#if IS_ENABLED(CONFIG_IPV6)
+	if (vxlan->default_dst.remote_ip.sa.sa_family == AF_INET6)
+		err = ipv6_sock_mc_drop(sk, vxlan->default_dst.remote_ifindex,
+					&vxlan->default_dst.remote_ip.sin6.sin6_addr);
+	else
+#endif
+		err = ip_mc_leave_group(sk, &mreq);
 	release_sock(sk);
 	rtnl_lock();
 
@@ -652,12 +753,16 @@ static int vxlan_leave_group(struct net_device *dev)
 /* Callback from net/ipv4/udp.c to receive packets */
 static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
-	struct iphdr *oip;
+	struct iphdr *oip = NULL;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct ipv6hdr *oip6 = NULL;
+#endif
 	struct vxlanhdr *vxh;
 	struct vxlan_dev *vxlan;
 	struct pcpu_tstats *stats;
+	union vxlan_addr src_ip;
 	__u32 vni;
-	int err;
+	int err = 0;
 
 	/* pop off outer UDP header */
 	__skb_pull(skb, sizeof(struct udphdr));
@@ -694,7 +799,13 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	skb_reset_mac_header(skb);
 
 	/* Re-examine inner Ethernet packet */
-	oip = ip_hdr(skb);
+	if (skb->protocol == htons(ETH_P_IP))
+		oip = ip_hdr(skb);
+#if IS_ENABLED(CONFIG_IPV6)
+	if (skb->protocol == htons(ETH_P_IPV6))
+		oip6 = ipv6_hdr(skb);
+#endif
+
 	skb->protocol = eth_type_trans(skb, vxlan->dev);
 
 	/* Ignore packet loops (and multicast echo) */
@@ -702,8 +813,19 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 			       vxlan->dev->dev_addr) == 0)
 		goto drop;
 
-	if (vxlan->flags & VXLAN_F_LEARN)
-		vxlan_snoop(skb->dev, oip->saddr, eth_hdr(skb)->h_source);
+	if (vxlan->flags & VXLAN_F_LEARN) {
+		if (oip) {
+			src_ip.sin.sin_addr.s_addr = oip->saddr;
+			src_ip.sa.sa_family = AF_INET;
+		}
+#if IS_ENABLED(CONFIG_IPV6)
+		if (oip6) {
+			src_ip.sin6.sin6_addr = oip6->saddr;
+			src_ip.sa.sa_family = AF_INET6;
+		}
+#endif
+		vxlan_snoop(skb->dev, &src_ip, eth_hdr(skb)->h_source);
+	}
 
 	__skb_tunnel_rx(skb, vxlan->dev);
 	skb_reset_network_header(skb);
@@ -719,11 +841,24 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	skb->encapsulation = 0;
 
-	err = IP_ECN_decapsulate(oip, skb);
+#if IS_ENABLED(CONFIG_IPV6)
+	if (oip6)
+		err = IP6_ECN_decapsulate(oip6, skb);
+#endif
+	if (oip)
+		err = IP_ECN_decapsulate(oip, skb);
+
 	if (unlikely(err)) {
-		if (log_ecn_error)
-			net_info_ratelimited("non-ECT from %pI4 with TOS=%#x\n",
-					     &oip->saddr, oip->tos);
+		if (log_ecn_error) {
+#if IS_ENABLED(CONFIG_IPV6)
+			if (oip6)
+				net_info_ratelimited("non-ECT from %pI6\n",
+						     &oip6->saddr);
+#endif
+			if (oip)
+				net_info_ratelimited("non-ECT from %pI4 with TOS=%#x\n",
+						     &oip->saddr, oip->tos);
+		}
 		if (err > 1) {
 			++vxlan->dev->stats.rx_frame_errors;
 			++vxlan->dev->stats.rx_errors;
@@ -758,6 +893,7 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
 	u8 *arpptr, *sha;
 	__be32 sip, tip;
 	struct neighbour *n;
+	union vxlan_addr ipa;
 
 	if (dev->flags & IFF_NOARP)
 		goto out;
@@ -799,7 +935,7 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
 		}
 
 		f = vxlan_find_mac(vxlan, n->ha);
-		if (f && f->remote.remote_ip == htonl(INADDR_ANY)) {
+		if (f && vxlan_addr_any(&f->remote.remote_ip)) {
 			/* bridge-local neighbor */
 			neigh_release(n);
 			goto out;
@@ -817,8 +953,11 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
 
 		if (netif_rx_ni(reply) == NET_RX_DROP)
 			dev->stats.rx_dropped++;
-	} else if (vxlan->flags & VXLAN_F_L3MISS)
-		vxlan_ip_miss(dev, tip);
+	} else if (vxlan->flags & VXLAN_F_L3MISS) {
+		ipa.sin.sin_addr.s_addr = tip;
+		ipa.sa.sa_family = AF_INET;
+		vxlan_ip_miss(dev, &ipa);
+	}
 out:
 	consume_skb(skb);
 	return NETDEV_TX_OK;
@@ -840,6 +979,14 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 			return false;
 		pip = ip_hdr(skb);
 		n = neigh_lookup(&arp_tbl, &pip->daddr, dev);
+		if (!n && vxlan->flags & VXLAN_F_L3MISS) {
+			union vxlan_addr ipa;
+			ipa.sin.sin_addr.s_addr = pip->daddr;
+			ipa.sa.sa_family = AF_INET;
+			vxlan_ip_miss(dev, &ipa);
+			return false;
+		}
+
 		break;
 	default:
 		return false;
@@ -856,8 +1003,8 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 		}
 		neigh_release(n);
 		return diff;
-	} else if (vxlan->flags & VXLAN_F_L3MISS)
-		vxlan_ip_miss(dev, pip->daddr);
+	}
+
 	return false;
 }
 
@@ -867,7 +1014,8 @@ static void vxlan_sock_free(struct sk_buff *skb)
 }
 
 /* On transmit, associate with the tunnel socket */
-static void vxlan_set_owner(struct net_device *dev, struct sk_buff *skb)
+static inline void vxlan_set_owner(struct net_device *dev,
+				   struct sk_buff *skb)
 {
 	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 	struct sock *sk = vn->sock->sk;
@@ -916,15 +1064,26 @@ static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
 {
 	struct pcpu_tstats *tx_stats = this_cpu_ptr(src_vxlan->dev->tstats);
 	struct pcpu_tstats *rx_stats = this_cpu_ptr(dst_vxlan->dev->tstats);
+	union vxlan_addr loopback;
 
 	skb->pkt_type = PACKET_HOST;
 	skb->encapsulation = 0;
 	skb->dev = dst_vxlan->dev;
 	__skb_pull(skb, skb_network_offset(skb));
 
+	if (dst_vxlan->default_dst.remote_ip.sa.sa_family == AF_INET) {
+		loopback.sin.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+		loopback.sa.sa_family =  AF_INET;
+	}
+#if IS_ENABLED(CONFIG_IPV6)
+	else {
+		loopback.sin6.sin6_addr = in6addr_loopback;
+		loopback.sa.sa_family =  AF_INET6;
+	}
+#endif
+
 	if (dst_vxlan->flags & VXLAN_F_LEARN)
-		vxlan_snoop(skb->dev, htonl(INADDR_LOOPBACK),
-			    eth_hdr(skb)->h_source);
+		vxlan_snoop(skb->dev, &loopback, eth_hdr(skb)->h_source);
 
 	u64_stats_update_begin(&tx_stats->syncp);
 	tx_stats->tx_packets++;
@@ -946,22 +1105,29 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct rtable *rt;
-	const struct iphdr *old_iph;
+	const struct iphdr *old_iph = NULL;
 	struct iphdr *iph;
 	struct vxlanhdr *vxh;
 	struct udphdr *uh;
 	struct flowi4 fl4;
-	__be32 dst;
-	__u16 src_port, dst_port;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct flowi6 fl6;
+	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
+	struct sock *sk = vn->sock->sk;
+	struct ipv6hdr *ip6h;
+#endif
+	const union vxlan_addr *dst;
+	struct dst_entry *ndst = NULL;
+	__u16 src_port = 0, dst_port;
         u32 vni;
 	__be16 df = 0;
 	__u8 tos, ttl;
 
 	dst_port = rdst->remote_port ? rdst->remote_port : vxlan_port;
 	vni = rdst->remote_vni;
-	dst = rdst->remote_ip;
+	dst = &rdst->remote_ip;
 
-	if (!dst) {
+	if (vxlan_addr_any(dst)) {
 		if (did_rsc) {
 			/* short-circuited back to local bridge */
 			vxlan_encap_bypass(skb, vxlan, vxlan);
@@ -975,60 +1141,115 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		skb->encapsulation = 1;
 	}
 
-	/* Need space for new headers (invalidates iph ptr) */
-	if (skb_cow_head(skb, VXLAN_HEADROOM))
-		goto drop;
+	ttl = vxlan->ttl;
+	tos = vxlan->tos;
+	if (dst->sa.sa_family == AF_INET) {
+		/* Need space for new headers (invalidates iph ptr) */
+		if (skb_cow_head(skb, VXLAN_HEADROOM))
+			goto drop;
 
-	old_iph = ip_hdr(skb);
+		old_iph = ip_hdr(skb);
+		if (!ttl && IN_MULTICAST(ntohl(dst->sin.sin_addr.s_addr)))
+			ttl = 1;
 
-	ttl = vxlan->ttl;
-	if (!ttl && IN_MULTICAST(ntohl(dst)))
-		ttl = 1;
+		if (tos == 1)
+			tos = ip_tunnel_get_dsfield(old_iph, skb);
 
-	tos = vxlan->tos;
-	if (tos == 1)
-		tos = ip_tunnel_get_dsfield(old_iph, skb);
-
-	src_port = vxlan_src_port(vxlan, skb);
-
-	memset(&fl4, 0, sizeof(fl4));
-	fl4.flowi4_oif = rdst->remote_ifindex;
-	fl4.flowi4_tos = RT_TOS(tos);
-	fl4.daddr = dst;
-	fl4.saddr = vxlan->saddr;
-
-	rt = ip_route_output_key(dev_net(dev), &fl4);
-	if (IS_ERR(rt)) {
-		netdev_dbg(dev, "no route to %pI4\n", &dst);
-		dev->stats.tx_carrier_errors++;
-		goto tx_error;
-	}
+		src_port = vxlan_src_port(vxlan, skb);
 
-	if (rt->dst.dev == dev) {
-		netdev_dbg(dev, "circular route to %pI4\n", &dst);
-		ip_rt_put(rt);
-		dev->stats.collisions++;
-		goto tx_error;
-	}
+		memset(&fl4, 0, sizeof(fl4));
+		fl4.flowi4_oif = rdst->remote_ifindex;
+		fl4.flowi4_tos = RT_TOS(tos);
+		fl4.daddr = dst->sin.sin_addr.s_addr;
+		fl4.saddr = vxlan->saddr.sin.sin_addr.s_addr;
+
+		rt = ip_route_output_key(dev_net(dev), &fl4);
+		if (IS_ERR(rt)) {
+			netdev_dbg(dev, "no route to %pI4\n", &dst->sin.sin_addr.s_addr);
+			dev->stats.tx_carrier_errors++;
+			goto tx_error;
+		}
 
-	/* Bypass encapsulation if the destination is local */
-	if (rt->rt_flags & RTCF_LOCAL &&
-	    !(rt->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))) {
-		struct vxlan_dev *dst_vxlan;
+		if (rt->dst.dev == dev) {
+			netdev_dbg(dev, "circular route to %pI4\n", &dst->sin.sin_addr.s_addr);
+			ip_rt_put(rt);
+			dev->stats.collisions++;
+			goto tx_error;
+		}
+
+		/* Bypass encapsulation if the destination is local */
+		if (rt->rt_flags & RTCF_LOCAL &&
+		    !(rt->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))) {
+			struct vxlan_dev *dst_vxlan;
+
+			ip_rt_put(rt);
+			dst_vxlan = vxlan_find_vni(dev_net(dev), vni);
+			if (!dst_vxlan)
+				goto tx_error;
+			vxlan_encap_bypass(skb, vxlan, dst_vxlan);
+			return NETDEV_TX_OK;
+		}
+
+		ndst = &rt->dst;
+	} else {
+#if IS_ENABLED(CONFIG_IPV6)
+		const struct ipv6hdr *old_iph6;
+		u32 flags;
+
+		/* Need space for new headers (invalidates iph ptr) */
+		if (skb_cow_head(skb, VXLAN6_HEADROOM))
+			goto drop;
+
+		old_iph6 = ipv6_hdr(skb);
+		if (!ttl && ipv6_addr_is_multicast(&dst->sin6.sin6_addr))
+			ttl = 1;
 
-		ip_rt_put(rt);
-		dst_vxlan = vxlan_find_vni(dev_net(dev), vni);
-		if (!dst_vxlan)
+		if (tos == 1)
+			tos = ipv6_get_dsfield(old_iph6);
+
+		src_port = vxlan_src_port(vxlan, skb);
+
+		memset(&fl6, 0, sizeof(fl6));
+		fl6.flowi6_oif = rdst->remote_ifindex;
+		fl6.flowi6_tos = RT_TOS(tos);
+		fl6.daddr = dst->sin6.sin6_addr;
+		fl6.saddr = vxlan->saddr.sin6.sin6_addr;
+		fl6.flowi6_proto = skb->protocol;
+
+		if (ip6_dst_lookup(sk, &ndst, &fl6)) {
+			netdev_dbg(dev, "no route to %pI6\n", &dst->sin6.sin6_addr);
+			dev->stats.tx_carrier_errors++;
+			goto tx_error;
+		}
+
+		if (ndst->dev == dev) {
+			netdev_dbg(dev, "circular route to %pI6\n", &dst->sin6.sin6_addr);
+			dst_release(ndst);
+			dev->stats.collisions++;
 			goto tx_error;
-		vxlan_encap_bypass(skb, vxlan, dst_vxlan);
-		return NETDEV_TX_OK;
+		}
+
+		/* Bypass encapsulation if the destination is local */
+		flags = ((struct rt6_info *)ndst)->rt6i_flags;
+		if (flags & RTF_LOCAL &&
+		    !(flags & (RTCF_BROADCAST | RTCF_MULTICAST))) {
+			struct vxlan_dev *dst_vxlan;
+
+			dst_release(ndst);
+			dst_vxlan = vxlan_find_vni(dev_net(dev), vni);
+			if (!dst_vxlan)
+				goto tx_error;
+			vxlan_encap_bypass(skb, vxlan, dst_vxlan);
+			return NETDEV_TX_OK;
+		}
+#endif
 	}
 
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
 			      IPSKB_REROUTED);
 	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
+	skb_dst_set(skb, ndst);
 
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
 	vxh->vx_flags = htonl(VXLAN_FLAGS);
@@ -1044,27 +1265,63 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	uh->len = htons(skb->len);
 	uh->check = 0;
 
-	__skb_push(skb, sizeof(*iph));
-	skb_reset_network_header(skb);
-	iph		= ip_hdr(skb);
-	iph->version	= 4;
-	iph->ihl	= sizeof(struct iphdr) >> 2;
-	iph->frag_off	= df;
-	iph->protocol	= IPPROTO_UDP;
-	iph->tos	= ip_tunnel_ecn_encap(tos, old_iph, skb);
-	iph->daddr	= dst;
-	iph->saddr	= fl4.saddr;
-	iph->ttl	= ttl ? : ip4_dst_hoplimit(&rt->dst);
-	tunnel_ip_select_ident(skb, old_iph, &rt->dst);
-
-	nf_reset(skb);
+	if (dst->sa.sa_family == AF_INET) {
+		__skb_push(skb, sizeof(*iph));
+		skb_reset_network_header(skb);
+		iph		= ip_hdr(skb);
+		iph->version	= 4;
+		iph->ihl	= sizeof(struct iphdr) >> 2;
+		iph->frag_off	= df;
+		iph->protocol	= IPPROTO_UDP;
+		iph->tos	= ip_tunnel_ecn_encap(tos, old_iph, skb);
+		iph->daddr	= dst->sin.sin_addr.s_addr;
+		iph->saddr	= fl4.saddr;
+		iph->ttl	= ttl ? : ip4_dst_hoplimit(ndst);
+		tunnel_ip_select_ident(skb, old_iph, ndst);
+	} else {
+#if IS_ENABLED(CONFIG_IPV6)
+		if (!skb_is_gso(skb) && !(ndst->dev->features & NETIF_F_IPV6_CSUM)) {
+			__wsum csum = skb_checksum(skb, 0, skb->len, 0);
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+			uh->check = csum_ipv6_magic(&fl6.saddr, &fl6.daddr, skb->len,
+						    IPPROTO_UDP, csum);
+			if (uh->check == 0)
+				uh->check = CSUM_MANGLED_0;
+		} else {
+			skb->ip_summed = CHECKSUM_PARTIAL;
+			skb->csum_start = skb_transport_header(skb) - skb->head;
+			skb->csum_offset = offsetof(struct udphdr, check);
+			uh->check = ~csum_ipv6_magic(&fl6.saddr, &fl6.daddr,
+						     skb->len, IPPROTO_UDP, 0);
+		}
+
+		__skb_push(skb, sizeof(*ip6h));
+		skb_reset_network_header(skb);
+		ip6h		  = ipv6_hdr(skb);
+		ip6h->version	  = 6;
+		ip6h->priority	  = 0;
+		ip6h->flow_lbl[0] = 0;
+		ip6h->flow_lbl[1] = 0;
+		ip6h->flow_lbl[2] = 0;
+		ip6h->payload_len = htons(skb->len);
+		ip6h->nexthdr     = IPPROTO_UDP;
+		ip6h->hop_limit   = ttl ? : ip6_dst_hoplimit(ndst);
+		ip6h->daddr	  = fl6.daddr;
+		ip6h->saddr	  = fl6.saddr;
+#endif
+	}
 
 	vxlan_set_owner(dev, skb);
 
 	if (handle_offloads(skb))
 		goto drop;
 
-	iptunnel_xmit(skb, dev);
+#if IS_ENABLED(CONFIG_IPV6)
+	if (dst->sa.sa_family == AF_INET6)
+		ip6tunnel_xmit(skb, dev);
+	else
+#endif
+		iptunnel_xmit(skb, dev);
 	return NETDEV_TX_OK;
 
 drop:
@@ -1106,7 +1363,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 		did_rsc = false;
 		rdst0 = &vxlan->default_dst;
 
-		if (rdst0->remote_ip == htonl(INADDR_ANY) &&
+		if (vxlan_addr_any(&rdst0->remote_ip) &&
 		    (vxlan->flags & VXLAN_F_L2MISS) &&
 		    !is_multicast_ether_addr(eth->h_dest))
 			vxlan_fdb_miss(vxlan, eth->h_dest);
@@ -1184,7 +1441,7 @@ static int vxlan_open(struct net_device *dev)
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	int err;
 
-	if (IN_MULTICAST(ntohl(vxlan->default_dst.remote_ip))) {
+	if (vxlan_addr_multicast(&vxlan->default_dst.remote_ip)) {
 		err = vxlan_join_group(dev);
 		if (err)
 			return err;
@@ -1218,7 +1475,7 @@ static int vxlan_stop(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 
-	if (IN_MULTICAST(ntohl(vxlan->default_dst.remote_ip)))
+	if (vxlan_addr_multicast(&vxlan->default_dst.remote_ip))
 		vxlan_leave_group(dev);
 
 	del_timer_sync(&vxlan->age_timer);
@@ -1268,7 +1525,12 @@ static void vxlan_setup(struct net_device *dev)
 
 	eth_hw_addr_random(dev);
 	ether_setup(dev);
-	dev->hard_header_len = ETH_HLEN + VXLAN_HEADROOM;
+#if IS_ENABLED(CONFIG_IPV6)
+	if (vxlan->default_dst.remote_ip.sa.sa_family == AF_INET6)
+		dev->hard_header_len = ETH_HLEN + VXLAN6_HEADROOM;
+	else
+#endif
+		dev->hard_header_len = ETH_HLEN + VXLAN_HEADROOM;
 
 	dev->netdev_ops = &vxlan_netdev_ops;
 	dev->destructor = vxlan_free;
@@ -1305,8 +1567,10 @@ static void vxlan_setup(struct net_device *dev)
 static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_ID]		= { .type = NLA_U32 },
 	[IFLA_VXLAN_REMOTE]	= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
+	[IFLA_VXLAN_REMOTE6]	= { .len = sizeof(struct in6_addr) },
 	[IFLA_VXLAN_LINK]	= { .type = NLA_U32 },
 	[IFLA_VXLAN_LOCAL]	= { .len = FIELD_SIZEOF(struct iphdr, saddr) },
+	[IFLA_VXLAN_LOCAL6]	= { .len = sizeof(struct in6_addr) },
 	[IFLA_VXLAN_TOS]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_TTL]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_LEARNING]	= { .type = NLA_U8 },
@@ -1386,11 +1650,31 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 	}
 	dst->remote_vni = vni;
 
-	if (data[IFLA_VXLAN_REMOTE])
-		dst->remote_ip = nla_get_be32(data[IFLA_VXLAN_REMOTE]);
+	if (data[IFLA_VXLAN_REMOTE]) {
+		dst->remote_ip.sin.sin_addr.s_addr = nla_get_be32(data[IFLA_VXLAN_REMOTE]);
+		dst->remote_ip.sa.sa_family = AF_INET;
+	} else if (data[IFLA_VXLAN_REMOTE6]) {
+#if IS_ENABLED(CONFIG_IPV6)
+		nla_memcpy(&dst->remote_ip.sin6.sin6_addr, data[IFLA_VXLAN_REMOTE6],
+			   sizeof(struct in6_addr));
+		dst->remote_ip.sa.sa_family = AF_INET6;
+#else
+		return -EPFNOSUPPORT;
+#endif
+	}
 
-	if (data[IFLA_VXLAN_LOCAL])
-		vxlan->saddr = nla_get_be32(data[IFLA_VXLAN_LOCAL]);
+	if (data[IFLA_VXLAN_LOCAL]) {
+		vxlan->saddr.sin.sin_addr.s_addr = nla_get_be32(data[IFLA_VXLAN_LOCAL]);
+		vxlan->saddr.sa.sa_family = AF_INET;
+	} else if (data[IFLA_VXLAN_LOCAL6]) {
+#if IS_ENABLED(CONFIG_IPV6)
+		nla_memcpy(&vxlan->saddr.sin6.sin6_addr, data[IFLA_VXLAN_LOCAL6],
+			   sizeof(struct in6_addr));
+		vxlan->saddr.sa.sa_family = AF_INET6;
+#else
+		return -EPFNOSUPPORT;
+#endif
+	}
 
 	if (data[IFLA_VXLAN_LINK] &&
 	    (dst->remote_ifindex = nla_get_u32(data[IFLA_VXLAN_LINK]))) {
@@ -1468,9 +1752,9 @@ static size_t vxlan_get_size(const struct net_device *dev)
 {
 
 	return nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_ID */
-		nla_total_size(sizeof(__be32)) +/* IFLA_VXLAN_REMOTE */
+		nla_total_size(sizeof(struct in6_addr)) + /* IFLA_VXLAN_REMOTE{6} */
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_LINK */
-		nla_total_size(sizeof(__be32))+	/* IFLA_VXLAN_LOCAL */
+		nla_total_size(sizeof(struct in6_addr)) + /* IFLA_VXLAN_LOCAL{6} */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_TTL */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_TOS */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_LEARNING */
@@ -1496,14 +1780,34 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	if (nla_put_u32(skb, IFLA_VXLAN_ID, dst->remote_vni))
 		goto nla_put_failure;
 
-	if (dst->remote_ip && nla_put_be32(skb, IFLA_VXLAN_REMOTE, dst->remote_ip))
-		goto nla_put_failure;
+	if (!vxlan_addr_any(&dst->remote_ip)) {
+		if (dst->remote_ip.sa.sa_family == AF_INET) {
+			if (nla_put_be32(skb, IFLA_VXLAN_REMOTE, dst->remote_ip.sin.sin_addr.s_addr))
+				goto nla_put_failure;
+		} else {
+#if IS_ENABLED(CONFIG_IPV6)
+			if (nla_put(skb, IFLA_VXLAN_REMOTE6, sizeof(struct in6_addr),
+				    &dst->remote_ip.sin6.sin6_addr))
+				goto nla_put_failure;
+#endif
+		}
+	}
 
 	if (dst->remote_ifindex && nla_put_u32(skb, IFLA_VXLAN_LINK, dst->remote_ifindex))
 		goto nla_put_failure;
 
-	if (vxlan->saddr && nla_put_be32(skb, IFLA_VXLAN_LOCAL, vxlan->saddr))
-		goto nla_put_failure;
+	if (!vxlan_addr_any(&vxlan->saddr)) {
+		if (vxlan->saddr.sa.sa_family == AF_INET) {
+			if (nla_put_be32(skb, IFLA_VXLAN_LOCAL, vxlan->saddr.sin.sin_addr.s_addr))
+				goto nla_put_failure;
+		} else {
+#if IS_ENABLED(CONFIG_IPV6)
+			if (nla_put(skb, IFLA_VXLAN_LOCAL6, sizeof(struct in6_addr),
+				    &vxlan->saddr.sin6.sin6_addr))
+				goto nla_put_failure;
+#endif
+		}
+	}
 
 	if (nla_put_u8(skb, IFLA_VXLAN_TTL, vxlan->ttl) ||
 	    nla_put_u8(skb, IFLA_VXLAN_TOS, vxlan->tos) ||
@@ -1542,38 +1846,82 @@ static struct rtnl_link_ops vxlan_link_ops __read_mostly = {
 	.fill_info	= vxlan_fill_info,
 };
 
-static __net_init int vxlan_init_net(struct net *net)
+/* Create UDP socket for encapsulation receive. AF_INET6 socket
+ * could be used for both IPv4 and IPv6 communications.
+ */
+#if IS_ENABLED(CONFIG_IPV6)
+static __net_init int create_sock(struct net *net, struct sock **sk)
+{
+	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
+	struct sockaddr_in6 vxlan_addr = {
+		.sin6_family = AF_INET6,
+		.sin6_port = htons(vxlan_port),
+	};
+	int rc;
+
+	rc = sock_create_kern(AF_INET6, SOCK_DGRAM, IPPROTO_UDP, &vn->sock);
+	if (rc < 0) {
+		pr_debug("UDP socket create failed\n");
+		return rc;
+	}
+	/* Put in proper namespace */
+	*sk = vn->sock->sk;
+	sk_change_net(*sk, net);
+
+	rc = kernel_bind(vn->sock, (struct sockaddr *)&vxlan_addr,
+			 sizeof(struct sockaddr_in6));
+	if (rc < 0) {
+		pr_debug("bind for UDP socket %pI6:%u (%d)\n",
+			 &vxlan_addr.sin6_addr, ntohs(vxlan_addr.sin6_port), rc);
+		sk_release_kernel(*sk);
+		vn->sock = NULL;
+		return rc;
+	}
+	return 0;
+}
+#else
+static __net_init int create_sock(struct net *net, struct sock **sk)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-	struct sock *sk;
 	struct sockaddr_in vxlan_addr = {
 		.sin_family = AF_INET,
+		.sin_port = htons(vxlan_port),
 		.sin_addr.s_addr = htonl(INADDR_ANY),
 	};
 	int rc;
-	unsigned h;
 
-	/* Create UDP socket for encapsulation receive. */
 	rc = sock_create_kern(AF_INET, SOCK_DGRAM, IPPROTO_UDP, &vn->sock);
 	if (rc < 0) {
 		pr_debug("UDP socket create failed\n");
 		return rc;
 	}
 	/* Put in proper namespace */
-	sk = vn->sock->sk;
-	sk_change_net(sk, net);
-
-	vxlan_addr.sin_port = htons(vxlan_port);
+	*sk = vn->sock->sk;
+	sk_change_net(*sk, net);
 
-	rc = kernel_bind(vn->sock, (struct sockaddr *) &vxlan_addr,
-			 sizeof(vxlan_addr));
+	rc = kernel_bind(vn->sock, (struct sockaddr *)&vxlan_addr,
+			 sizeof(struct sockaddr_in));
 	if (rc < 0) {
 		pr_debug("bind for UDP socket %pI4:%u (%d)\n",
 			 &vxlan_addr.sin_addr, ntohs(vxlan_addr.sin_port), rc);
-		sk_release_kernel(sk);
+		sk_release_kernel(*sk);
 		vn->sock = NULL;
 		return rc;
 	}
+	return 0;
+}
+#endif
+
+static __net_init int vxlan_init_net(struct net *net)
+{
+	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
+	struct sock *sk;
+	int rc;
+	unsigned h;
+
+	rc = create_sock(net, &sk);
+	if (rc < 0)
+		return rc;
 
 	/* Disable multicast loopback */
 	inet_sk(sk)->mc_loop = 0;
@@ -1582,6 +1930,9 @@ static __net_init int vxlan_init_net(struct net *net)
 	udp_sk(sk)->encap_type = 1;
 	udp_sk(sk)->encap_rcv = vxlan_udp_encap_recv;
 	udp_encap_enable();
+#if IS_ENABLED(CONFIG_IPV6)
+	udpv6_encap_enable();
+#endif
 
 	for (h = 0; h < VNI_HASH_SIZE; ++h)
 		INIT_HLIST_HEAD(&vn->vni_list[h]);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index e316354..92ae9bd 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -310,6 +310,8 @@ enum {
 	IFLA_VXLAN_RSC,
 	IFLA_VXLAN_L2MISS,
 	IFLA_VXLAN_L3MISS,
+	IFLA_VXLAN_REMOTE6,
+	IFLA_VXLAN_LOCAL6,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
-- 
1.7.7.6
