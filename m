From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v12 06/11] vxlan: add ipv6 support
Date: Sat, 31 Aug 2013 13:44:33 +0800
Message-ID: <1377927878-23975-7-git-send-email-amwang@redhat.com>
References: <1377927878-23975-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9898 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754358Ab3HaFqG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Aug 2013 01:46:06 -0400
In-Reply-To: <1377927878-23975-1-git-send-email-amwang@redhat.com>
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
 drivers/net/vxlan.c           |  764 +++++++++++++++++++++++++++++++++--------
 include/net/vxlan.h           |    2 +-
 include/uapi/linux/if_link.h  |    2 +
 net/openvswitch/vport-vxlan.c |    2 +-
 4 files changed, 622 insertions(+), 148 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 3b21aca..faf131e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -6,9 +6,6 @@
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
- *
- * TODO
- *  - IPv6 (not in RFC)
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
@@ -43,6 +40,11 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/vxlan.h>
+#if IS_ENABLED(CONFIG_IPV6)
+#include <net/ipv6.h>
+#include <net/addrconf.h>
+#include <net/ip6_tunnel.h>
+#endif
 
 #define VXLAN_VERSION	"0.1"
 
@@ -59,6 +61,8 @@
 #define VXLAN_VID_MASK	(VXLAN_N_VID - 1)
 /* IP header + UDP + VXLAN + Ethernet header */
 #define VXLAN_HEADROOM (20 + 8 + 8 + 14)
+/* IPv6 header + UDP + VXLAN + Ethernet header */
+#define VXLAN6_HEADROOM (40 + 8 + 8 + 14)
 #define VXLAN_HLEN (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
 
 #define VXLAN_FLAGS 0x08000000	/* struct vxlanhdr.vx_flags required value. */
@@ -92,8 +96,14 @@ struct vxlan_net {
 	spinlock_t	  sock_lock;
 };
 
+union vxlan_addr {
+	struct sockaddr_in sin;
+	struct sockaddr_in6 sin6;
+	struct sockaddr sa;
+};
+
 struct vxlan_rdst {
-	__be32			 remote_ip;
+	union vxlan_addr	 remote_ip;
 	__be16			 remote_port;
 	u32			 remote_vni;
 	u32			 remote_ifindex;
@@ -120,7 +130,7 @@ struct vxlan_dev {
 	struct vxlan_sock *vn_sock;	/* listening socket */
 	struct net_device *dev;
 	struct vxlan_rdst default_dst;	/* default destination */
-	__be32		  saddr;	/* source address */
+	union vxlan_addr  saddr;	/* source address */
 	__be16		  dst_port;
 	__u16		  port_min;	/* source port range */
 	__u16		  port_max;
@@ -146,6 +156,7 @@ struct vxlan_dev {
 #define VXLAN_F_RSC	0x04
 #define VXLAN_F_L2MISS	0x08
 #define VXLAN_F_L3MISS	0x10
+#define VXLAN_F_IPV6	0x20 /* internal flag */
 
 /* salt for hash table */
 static u32 vxlan_salt __read_mostly;
@@ -153,6 +164,96 @@ static struct workqueue_struct *vxlan_wq;
 
 static void vxlan_sock_work(struct work_struct *work);
 
+#if IS_ENABLED(CONFIG_IPV6)
+static inline
+bool vxlan_addr_equal(const union vxlan_addr *a, const union vxlan_addr *b)
+{
+       if (a->sa.sa_family != b->sa.sa_family)
+               return false;
+       if (a->sa.sa_family == AF_INET6)
+               return ipv6_addr_equal(&a->sin6.sin6_addr, &b->sin6.sin6_addr);
+       else
+               return a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr;
+}
+
+static inline bool vxlan_addr_any(const union vxlan_addr *ipa)
+{
+       if (ipa->sa.sa_family == AF_INET6)
+               return ipv6_addr_any(&ipa->sin6.sin6_addr);
+       else
+               return ipa->sin.sin_addr.s_addr == htonl(INADDR_ANY);
+}
+
+static inline bool vxlan_addr_multicast(const union vxlan_addr *ipa)
+{
+       if (ipa->sa.sa_family == AF_INET6)
+               return ipv6_addr_is_multicast(&ipa->sin6.sin6_addr);
+       else
+               return IN_MULTICAST(ntohl(ipa->sin.sin_addr.s_addr));
+}
+
+static int vxlan_nla_get_addr(union vxlan_addr *ip, struct nlattr *nla)
+{
+       if (nla_len(nla) >= sizeof(struct in6_addr)) {
+               nla_memcpy(&ip->sin6.sin6_addr, nla, sizeof(struct in6_addr));
+               ip->sa.sa_family = AF_INET6;
+               return 0;
+       } else if (nla_len(nla) >= sizeof(__be32)) {
+               ip->sin.sin_addr.s_addr = nla_get_be32(nla);
+               ip->sa.sa_family = AF_INET;
+               return 0;
+       } else {
+               return -EAFNOSUPPORT;
+       }
+}
+
+static int vxlan_nla_put_addr(struct sk_buff *skb, int attr,
+                             const union vxlan_addr *ip)
+{
+       if (ip->sa.sa_family == AF_INET6)
+               return nla_put(skb, attr, sizeof(struct in6_addr), &ip->sin6.sin6_addr);
+       else
+               return nla_put_be32(skb, attr, ip->sin.sin_addr.s_addr);
+}
+
+#else /* !CONFIG_IPV6 */
+
+static inline
+bool vxlan_addr_equal(const union vxlan_addr *a, const union vxlan_addr *b)
+{
+       return a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr;
+}
+
+static inline bool vxlan_addr_any(const union vxlan_addr *ipa)
+{
+       return ipa->sin.sin_addr.s_addr == htonl(INADDR_ANY);
+}
+
+static inline bool vxlan_addr_multicast(const union vxlan_addr *ipa)
+{
+       return IN_MULTICAST(ntohl(ipa->sin.sin_addr.s_addr));
+}
+
+static int vxlan_nla_get_addr(union vxlan_addr *ip, struct nlattr *nla)
+{
+       if (nla_len(nla) >= sizeof(struct in6_addr)) {
+               return -EAFNOSUPPORT;
+       } else if (nla_len(nla) >= sizeof(__be32)) {
+               ip->sin.sin_addr.s_addr = nla_get_be32(nla);
+               ip->sa.sa_family = AF_INET;
+               return 0;
+       } else {
+               return -EAFNOSUPPORT;
+       }
+}
+
+static int vxlan_nla_put_addr(struct sk_buff *skb, int attr,
+                             const union vxlan_addr *ip)
+{
+       return nla_put_be32(skb, attr, ip->sin.sin_addr.s_addr);
+}
+#endif
+
 /* Virtual Network hash table head */
 static inline struct hlist_head *vni_head(struct vxlan_sock *vs, u32 id)
 {
@@ -239,7 +340,7 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 
 	if (type == RTM_GETNEIGH) {
 		ndm->ndm_family	= AF_INET;
-		send_ip = rdst->remote_ip != htonl(INADDR_ANY);
+		send_ip = !vxlan_addr_any(&rdst->remote_ip);
 		send_eth = !is_zero_ether_addr(fdb->eth_addr);
 	} else
 		ndm->ndm_family	= AF_BRIDGE;
@@ -251,7 +352,7 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 	if (send_eth && nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->eth_addr))
 		goto nla_put_failure;
 
-	if (send_ip && nla_put_be32(skb, NDA_DST, rdst->remote_ip))
+	if (send_ip && vxlan_nla_put_addr(skb, NDA_DST, &rdst->remote_ip))
 		goto nla_put_failure;
 
 	if (rdst->remote_port && rdst->remote_port != vxlan->dst_port &&
@@ -283,7 +384,7 @@ static inline size_t vxlan_nlmsg_size(void)
 {
 	return NLMSG_ALIGN(sizeof(struct ndmsg))
 		+ nla_total_size(ETH_ALEN) /* NDA_LLADDR */
-		+ nla_total_size(sizeof(__be32)) /* NDA_DST */
+		+ nla_total_size(sizeof(struct in6_addr)) /* NDA_DST */
 		+ nla_total_size(sizeof(__be16)) /* NDA_PORT */
 		+ nla_total_size(sizeof(__be32)) /* NDA_VNI */
 		+ nla_total_size(sizeof(__u32)) /* NDA_IFINDEX */
@@ -317,14 +418,14 @@ errout:
 		rtnl_set_sk_err(net, RTNLGRP_NEIGH, err);
 }
 
-static void vxlan_ip_miss(struct net_device *dev, __be32 ipa)
+static void vxlan_ip_miss(struct net_device *dev, union vxlan_addr *ipa)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_fdb f = {
 		.state = NUD_STALE,
 	};
 	struct vxlan_rdst remote = {
-		.remote_ip = ipa, /* goes to NDA_DST */
+		.remote_ip = *ipa, /* goes to NDA_DST */
 		.remote_vni = VXLAN_N_VID,
 	};
 
@@ -397,13 +498,13 @@ static struct vxlan_fdb *vxlan_find_mac(struct vxlan_dev *vxlan,
 
 /* caller should hold vxlan->hash_lock */
 static struct vxlan_rdst *vxlan_fdb_find_rdst(struct vxlan_fdb *f,
-					      __be32 ip, __be16 port,
+					      union vxlan_addr *ip, __be16 port,
 					      __u32 vni, __u32 ifindex)
 {
 	struct vxlan_rdst *rd;
 
 	list_for_each_entry(rd, &f->remotes, list) {
-		if (rd->remote_ip == ip &&
+		if (vxlan_addr_equal(&rd->remote_ip, ip) &&
 		    rd->remote_port == port &&
 		    rd->remote_vni == vni &&
 		    rd->remote_ifindex == ifindex)
@@ -415,7 +516,7 @@ static struct vxlan_rdst *vxlan_fdb_find_rdst(struct vxlan_fdb *f,
 
 /* Replace destination of unicast mac */
 static int vxlan_fdb_replace(struct vxlan_fdb *f,
-			    __be32 ip, __be16 port, __u32 vni, __u32 ifindex)
+			     union vxlan_addr *ip, __be16 port, __u32 vni, __u32 ifindex)
 {
 	struct vxlan_rdst *rd;
 
@@ -426,7 +527,7 @@ static int vxlan_fdb_replace(struct vxlan_fdb *f,
 	rd = list_first_entry_or_null(&f->remotes, struct vxlan_rdst, list);
 	if (!rd)
 		return 0;
-	rd->remote_ip = ip;
+	rd->remote_ip = *ip;
 	rd->remote_port = port;
 	rd->remote_vni = vni;
 	rd->remote_ifindex = ifindex;
@@ -435,7 +536,7 @@ static int vxlan_fdb_replace(struct vxlan_fdb *f,
 
 /* Add/update destinations for multicast */
 static int vxlan_fdb_append(struct vxlan_fdb *f,
-			    __be32 ip, __be16 port, __u32 vni, __u32 ifindex)
+			    union vxlan_addr *ip, __be16 port, __u32 vni, __u32 ifindex)
 {
 	struct vxlan_rdst *rd;
 
@@ -446,7 +547,7 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
 	rd = kmalloc(sizeof(*rd), GFP_ATOMIC);
 	if (rd == NULL)
 		return -ENOBUFS;
-	rd->remote_ip = ip;
+	rd->remote_ip = *ip;
 	rd->remote_port = port;
 	rd->remote_vni = vni;
 	rd->remote_ifindex = ifindex;
@@ -458,7 +559,7 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
 
 /* Add new entry to forwarding table -- assumes lock held */
 static int vxlan_fdb_create(struct vxlan_dev *vxlan,
-			    const u8 *mac, __be32 ip,
+			    const u8 *mac, union vxlan_addr *ip,
 			    __u16 state, __u16 flags,
 			    __be16 port, __u32 vni, __u32 ifindex,
 			    __u8 ndm_flags)
@@ -517,7 +618,7 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 		    (is_multicast_ether_addr(mac) || is_zero_ether_addr(mac)))
 			return -EOPNOTSUPP;
 
-		netdev_dbg(vxlan->dev, "add %pM -> %pI4\n", mac, &ip);
+		netdev_dbg(vxlan->dev, "add %pM -> %pIS\n", mac, ip);
 		f = kmalloc(sizeof(*f), GFP_ATOMIC);
 		if (!f)
 			return -ENOMEM;
@@ -565,17 +666,26 @@ static void vxlan_fdb_destroy(struct vxlan_dev *vxlan, struct vxlan_fdb *f)
 }
 
 static int vxlan_fdb_parse(struct nlattr *tb[], struct vxlan_dev *vxlan,
-			   __be32 *ip, __be16 *port, u32 *vni, u32 *ifindex)
+			   union vxlan_addr *ip, __be16 *port, u32 *vni, u32 *ifindex)
 {
 	struct net *net = dev_net(vxlan->dev);
+	int err;
 
 	if (tb[NDA_DST]) {
-		if (nla_len(tb[NDA_DST]) != sizeof(__be32))
-			return -EAFNOSUPPORT;
-
-		*ip = nla_get_be32(tb[NDA_DST]);
+		err = vxlan_nla_get_addr(ip, tb[NDA_DST]);
+		if (err)
+			return err;
 	} else {
-		*ip = htonl(INADDR_ANY);
+		union vxlan_addr *remote = &vxlan->default_dst.remote_ip;
+		if (remote->sa.sa_family == AF_INET) {
+			ip->sin.sin_addr.s_addr = htonl(INADDR_ANY);
+			ip->sa.sa_family = AF_INET;
+#if IS_ENABLED(CONFIG_IPV6)
+		} else {
+			ip->sin6.sin6_addr = in6addr_any;
+			ip->sa.sa_family = AF_INET6;
+#endif
+		}
 	}
 
 	if (tb[NDA_PORT]) {
@@ -618,7 +728,7 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	/* struct net *net = dev_net(vxlan->dev); */
-	__be32 ip;
+	union vxlan_addr ip;
 	__be16 port;
 	u32 vni, ifindex;
 	int err;
@@ -637,7 +747,7 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		return err;
 
 	spin_lock_bh(&vxlan->hash_lock);
-	err = vxlan_fdb_create(vxlan, addr, ip, ndm->ndm_state, flags,
+	err = vxlan_fdb_create(vxlan, addr, &ip, ndm->ndm_state, flags,
 			       port, vni, ifindex, ndm->ndm_flags);
 	spin_unlock_bh(&vxlan->hash_lock);
 
@@ -652,7 +762,7 @@ static int vxlan_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_fdb *f;
 	struct vxlan_rdst *rd = NULL;
-	__be32 ip;
+	union vxlan_addr ip;
 	__be16 port;
 	u32 vni, ifindex;
 	int err;
@@ -668,8 +778,8 @@ static int vxlan_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 	if (!f)
 		goto out;
 
-	if (ip != htonl(INADDR_ANY)) {
-		rd = vxlan_fdb_find_rdst(f, ip, port, vni, ifindex);
+	if (!vxlan_addr_any(&ip)) {
+		rd = vxlan_fdb_find_rdst(f, &ip, port, vni, ifindex);
 		if (!rd)
 			goto out;
 	}
@@ -732,7 +842,7 @@ out:
  * Return true if packet is bogus and should be droppped.
  */
 static bool vxlan_snoop(struct net_device *dev,
-			__be32 src_ip, const u8 *src_mac)
+			union vxlan_addr *src_ip, const u8 *src_mac)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_fdb *f;
@@ -741,7 +851,7 @@ static bool vxlan_snoop(struct net_device *dev,
 	if (likely(f)) {
 		struct vxlan_rdst *rdst = first_remote_rcu(f);
 
-		if (likely(rdst->remote_ip == src_ip))
+		if (likely(vxlan_addr_equal(&rdst->remote_ip, src_ip)))
 			return false;
 
 		/* Don't migrate static entries, drop packets */
@@ -750,10 +860,10 @@ static bool vxlan_snoop(struct net_device *dev,
 
 		if (net_ratelimit())
 			netdev_info(dev,
-				    "%pM migrated from %pI4 to %pI4\n",
+				    "%pM migrated from %pIS to %pIS\n",
 				    src_mac, &rdst->remote_ip, &src_ip);
 
-		rdst->remote_ip = src_ip;
+		rdst->remote_ip = *src_ip;
 		f->updated = jiffies;
 		vxlan_fdb_notify(vxlan, f, RTM_NEWNEIGH);
 	} else {
@@ -775,7 +885,7 @@ static bool vxlan_snoop(struct net_device *dev,
 }
 
 /* See if multicast group is already in use by other ID */
-static bool vxlan_group_used(struct vxlan_net *vn, __be32 remote_ip)
+static bool vxlan_group_used(struct vxlan_net *vn, union vxlan_addr *remote_ip)
 {
 	struct vxlan_dev *vxlan;
 
@@ -783,7 +893,8 @@ static bool vxlan_group_used(struct vxlan_net *vn, __be32 remote_ip)
 		if (!netif_running(vxlan->dev))
 			continue;
 
-		if (vxlan->default_dst.remote_ip == remote_ip)
+		if (vxlan_addr_equal(&vxlan->default_dst.remote_ip,
+				     remote_ip))
 			return true;
 	}
 
@@ -819,13 +930,23 @@ static void vxlan_igmp_join(struct work_struct *work)
 	struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, igmp_join);
 	struct vxlan_sock *vs = vxlan->vn_sock;
 	struct sock *sk = vs->sock->sk;
-	struct ip_mreqn mreq = {
-		.imr_multiaddr.s_addr	= vxlan->default_dst.remote_ip,
-		.imr_ifindex		= vxlan->default_dst.remote_ifindex,
-	};
+	union vxlan_addr *ip = &vxlan->default_dst.remote_ip;
+	int ifindex = vxlan->default_dst.remote_ifindex;
 
 	lock_sock(sk);
-	ip_mc_join_group(sk, &mreq);
+	if (ip->sa.sa_family == AF_INET) {
+		struct ip_mreqn mreq = {
+			.imr_multiaddr.s_addr	= ip->sin.sin_addr.s_addr,
+			.imr_ifindex		= ifindex,
+		};
+
+		ip_mc_join_group(sk, &mreq);
+#if IS_ENABLED(CONFIG_IPV6)
+	} else {
+		ipv6_stub->ipv6_sock_mc_join(sk, ifindex,
+					     &ip->sin6.sin6_addr);
+#endif
+	}
 	release_sock(sk);
 
 	vxlan_sock_release(vs);
@@ -838,13 +959,24 @@ static void vxlan_igmp_leave(struct work_struct *work)
 	struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, igmp_leave);
 	struct vxlan_sock *vs = vxlan->vn_sock;
 	struct sock *sk = vs->sock->sk;
-	struct ip_mreqn mreq = {
-		.imr_multiaddr.s_addr	= vxlan->default_dst.remote_ip,
-		.imr_ifindex		= vxlan->default_dst.remote_ifindex,
-	};
+	union vxlan_addr *ip = &vxlan->default_dst.remote_ip;
+	int ifindex = vxlan->default_dst.remote_ifindex;
 
 	lock_sock(sk);
-	ip_mc_leave_group(sk, &mreq);
+	if (ip->sa.sa_family == AF_INET) {
+		struct ip_mreqn mreq = {
+			.imr_multiaddr.s_addr	= ip->sin.sin_addr.s_addr,
+			.imr_ifindex		= ifindex,
+		};
+
+		ip_mc_leave_group(sk, &mreq);
+#if IS_ENABLED(CONFIG_IPV6)
+	} else {
+		ipv6_stub->ipv6_sock_mc_drop(sk, ifindex,
+					     &ip->sin6.sin6_addr);
+#endif
+	}
+
 	release_sock(sk);
 
 	vxlan_sock_release(vs);
@@ -896,11 +1028,14 @@ error:
 static void vxlan_rcv(struct vxlan_sock *vs,
 		      struct sk_buff *skb, __be32 vx_vni)
 {
-	struct iphdr *oip;
+	struct iphdr *oip = NULL;
+	struct ipv6hdr *oip6 = NULL;
 	struct vxlan_dev *vxlan;
 	struct pcpu_tstats *stats;
+	union vxlan_addr saddr;
 	__u32 vni;
-	int err;
+	int err = 0;
+	union vxlan_addr *remote_ip;
 
 	vni = ntohl(vx_vni) >> 8;
 	/* Is this VNI defined? */
@@ -908,6 +1043,7 @@ static void vxlan_rcv(struct vxlan_sock *vs,
 	if (!vxlan)
 		goto drop;
 
+	remote_ip = &vxlan->default_dst.remote_ip;
 	skb_reset_mac_header(skb);
 	skb->protocol = eth_type_trans(skb, vxlan->dev);
 
@@ -917,9 +1053,20 @@ static void vxlan_rcv(struct vxlan_sock *vs,
 		goto drop;
 
 	/* Re-examine inner Ethernet packet */
-	oip = ip_hdr(skb);
+	if (remote_ip->sa.sa_family == AF_INET) {
+		oip = ip_hdr(skb);
+		saddr.sin.sin_addr.s_addr = oip->saddr;
+		saddr.sa.sa_family = AF_INET;
+#if IS_ENABLED(CONFIG_IPV6)
+	} else {
+		oip6 = ipv6_hdr(skb);
+		saddr.sin6.sin6_addr = oip6->saddr;
+		saddr.sa.sa_family = AF_INET6;
+#endif
+	}
+
 	if ((vxlan->flags & VXLAN_F_LEARN) &&
-	    vxlan_snoop(skb->dev, oip->saddr, eth_hdr(skb)->h_source))
+	    vxlan_snoop(skb->dev, &saddr, eth_hdr(skb)->h_source))
 		goto drop;
 
 	skb_reset_network_header(skb);
@@ -935,11 +1082,20 @@ static void vxlan_rcv(struct vxlan_sock *vs,
 
 	skb->encapsulation = 0;
 
-	err = IP_ECN_decapsulate(oip, skb);
+	if (oip6)
+		err = IP6_ECN_decapsulate(oip6, skb);
+	if (oip)
+		err = IP_ECN_decapsulate(oip, skb);
+
 	if (unlikely(err)) {
-		if (log_ecn_error)
-			net_info_ratelimited("non-ECT from %pI4 with TOS=%#x\n",
-					     &oip->saddr, oip->tos);
+		if (log_ecn_error) {
+			if (oip6)
+				net_info_ratelimited("non-ECT from %pI6\n",
+						     &oip6->saddr);
+			if (oip)
+				net_info_ratelimited("non-ECT from %pI4 with TOS=%#x\n",
+						     &oip->saddr, oip->tos);
+		}
 		if (err > 1) {
 			++vxlan->dev->stats.rx_frame_errors;
 			++vxlan->dev->stats.rx_errors;
@@ -1009,7 +1165,7 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
 		}
 
 		f = vxlan_find_mac(vxlan, n->ha);
-		if (f && first_remote_rcu(f)->remote_ip == htonl(INADDR_ANY)) {
+		if (f && vxlan_addr_any(&(first_remote_rcu(f)->remote_ip))) {
 			/* bridge-local neighbor */
 			neigh_release(n);
 			goto out;
@@ -1027,8 +1183,14 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
 
 		if (netif_rx_ni(reply) == NET_RX_DROP)
 			dev->stats.rx_dropped++;
-	} else if (vxlan->flags & VXLAN_F_L3MISS)
-		vxlan_ip_miss(dev, tip);
+	} else if (vxlan->flags & VXLAN_F_L3MISS) {
+		union vxlan_addr ipa = {
+			.sin.sin_addr.s_addr = tip,
+			.sa.sa_family = AF_INET,
+		};
+
+		vxlan_ip_miss(dev, &ipa);
+	}
 out:
 	consume_skb(skb);
 	return NETDEV_TX_OK;
@@ -1050,6 +1212,16 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 			return false;
 		pip = ip_hdr(skb);
 		n = neigh_lookup(&arp_tbl, &pip->daddr, dev);
+		if (!n && (vxlan->flags & VXLAN_F_L3MISS)) {
+			union vxlan_addr ipa = {
+				.sin.sin_addr.s_addr = pip->daddr,
+				.sa.sa_family = AF_INET,
+			};
+
+			vxlan_ip_miss(dev, &ipa);
+			return false;
+		}
+
 		break;
 	default:
 		return false;
@@ -1066,8 +1238,8 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 		}
 		neigh_release(n);
 		return diff;
-	} else if (vxlan->flags & VXLAN_F_L3MISS)
-		vxlan_ip_miss(dev, pip->daddr);
+	}
+
 	return false;
 }
 
@@ -1118,6 +1290,102 @@ static int handle_offloads(struct sk_buff *skb)
 	return 0;
 }
 
+#if IS_ENABLED(CONFIG_IPV6)
+static int vxlan6_xmit_skb(struct net *net, struct vxlan_sock *vs,
+			   struct dst_entry *dst, struct sk_buff *skb,
+			   struct net_device *dev, struct in6_addr *saddr,
+			   struct in6_addr *daddr, __u8 prio, __u8 ttl,
+			   __be16 src_port, __be16 dst_port, __be32 vni)
+{
+	struct ipv6hdr *ip6h;
+	struct vxlanhdr *vxh;
+	struct udphdr *uh;
+	int min_headroom;
+	int err;
+
+	if (!skb->encapsulation) {
+		skb_reset_inner_headers(skb);
+		skb->encapsulation = 1;
+	}
+
+	min_headroom = LL_RESERVED_SPACE(dst->dev) + dst->header_len
+			+ VXLAN_HLEN + sizeof(struct ipv6hdr)
+			+ (vlan_tx_tag_present(skb) ? VLAN_HLEN : 0);
+
+	/* Need space for new headers (invalidates iph ptr) */
+	err = skb_cow_head(skb, min_headroom);
+	if (unlikely(err))
+		return err;
+
+	if (vlan_tx_tag_present(skb)) {
+		if (WARN_ON(!__vlan_put_tag(skb,
+					    skb->vlan_proto,
+					    vlan_tx_tag_get(skb))))
+			return -ENOMEM;
+
+		skb->vlan_tci = 0;
+	}
+
+	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
+	vxh->vx_flags = htonl(VXLAN_FLAGS);
+	vxh->vx_vni = vni;
+
+	__skb_push(skb, sizeof(*uh));
+	skb_reset_transport_header(skb);
+	uh = udp_hdr(skb);
+
+	uh->dest = dst_port;
+	uh->source = src_port;
+
+	uh->len = htons(skb->len);
+	uh->check = 0;
+
+	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
+	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
+			      IPSKB_REROUTED);
+	skb_dst_drop(skb);
+	skb_dst_set(skb, dst);
+
+	if (!skb_is_gso(skb) && !(dst->dev->features & NETIF_F_IPV6_CSUM)) {
+		__wsum csum = skb_checksum(skb, 0, skb->len, 0);
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		uh->check = csum_ipv6_magic(saddr, daddr, skb->len,
+					    IPPROTO_UDP, csum);
+		if (uh->check == 0)
+			uh->check = CSUM_MANGLED_0;
+	} else {
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		skb->csum_start = skb_transport_header(skb) - skb->head;
+		skb->csum_offset = offsetof(struct udphdr, check);
+		uh->check = ~csum_ipv6_magic(saddr, daddr,
+					     skb->len, IPPROTO_UDP, 0);
+	}
+
+	__skb_push(skb, sizeof(*ip6h));
+	skb_reset_network_header(skb);
+	ip6h		  = ipv6_hdr(skb);
+	ip6h->version	  = 6;
+	ip6h->priority	  = prio;
+	ip6h->flow_lbl[0] = 0;
+	ip6h->flow_lbl[1] = 0;
+	ip6h->flow_lbl[2] = 0;
+	ip6h->payload_len = htons(skb->len);
+	ip6h->nexthdr     = IPPROTO_UDP;
+	ip6h->hop_limit   = ttl;
+	ip6h->daddr	  = *daddr;
+	ip6h->saddr	  = *saddr;
+
+	vxlan_set_owner(vs->sock->sk, skb);
+
+	err = handle_offloads(skb);
+	if (err)
+		return err;
+
+	ip6tunnel_xmit(skb, dev);
+	return 0;
+}
+#endif
+
 int vxlan_xmit_skb(struct net *net, struct vxlan_sock *vs,
 		   struct rtable *rt, struct sk_buff *skb,
 		   __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
@@ -1182,15 +1450,26 @@ static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
 {
 	struct pcpu_tstats *tx_stats = this_cpu_ptr(src_vxlan->dev->tstats);
 	struct pcpu_tstats *rx_stats = this_cpu_ptr(dst_vxlan->dev->tstats);
+	union vxlan_addr loopback;
+	union vxlan_addr *remote_ip = &dst_vxlan->default_dst.remote_ip;
 
 	skb->pkt_type = PACKET_HOST;
 	skb->encapsulation = 0;
 	skb->dev = dst_vxlan->dev;
 	__skb_pull(skb, skb_network_offset(skb));
 
+	if (remote_ip->sa.sa_family == AF_INET) {
+		loopback.sin.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+		loopback.sa.sa_family =  AF_INET;
+#if IS_ENABLED(CONFIG_IPV6)
+	} else {
+		loopback.sin6.sin6_addr = in6addr_loopback;
+		loopback.sa.sa_family =  AF_INET6;
+#endif
+	}
+
 	if (dst_vxlan->flags & VXLAN_F_LEARN)
-		vxlan_snoop(skb->dev, htonl(INADDR_LOOPBACK),
-			    eth_hdr(skb)->h_source);
+		vxlan_snoop(skb->dev, &loopback, eth_hdr(skb)->h_source);
 
 	u64_stats_update_begin(&tx_stats->syncp);
 	tx_stats->tx_packets++;
@@ -1211,11 +1490,11 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			   struct vxlan_rdst *rdst, bool did_rsc)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct rtable *rt;
+	struct rtable *rt = NULL;
 	const struct iphdr *old_iph;
 	struct flowi4 fl4;
-	__be32 dst;
-	__be16 src_port, dst_port;
+	union vxlan_addr *dst;
+	__be16 src_port = 0, dst_port;
 	u32 vni;
 	__be16 df = 0;
 	__u8 tos, ttl;
@@ -1223,9 +1502,9 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 	dst_port = rdst->remote_port ? rdst->remote_port : vxlan->dst_port;
 	vni = rdst->remote_vni;
-	dst = rdst->remote_ip;
+	dst = &rdst->remote_ip;
 
-	if (!dst) {
+	if (vxlan_addr_any(dst)) {
 		if (did_rsc) {
 			/* short-circuited back to local bridge */
 			vxlan_encap_bypass(skb, vxlan, vxlan);
@@ -1237,7 +1516,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	old_iph = ip_hdr(skb);
 
 	ttl = vxlan->ttl;
-	if (!ttl && IN_MULTICAST(ntohl(dst)))
+	if (!ttl && vxlan_addr_multicast(dst))
 		ttl = 1;
 
 	tos = vxlan->tos;
@@ -1246,48 +1525,101 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 	src_port = vxlan_src_port(vxlan->port_min, vxlan->port_max, skb);
 
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
+	if (dst->sa.sa_family == AF_INET) {
+		memset(&fl4, 0, sizeof(fl4));
+		fl4.flowi4_oif = rdst->remote_ifindex;
+		fl4.flowi4_tos = RT_TOS(tos);
+		fl4.daddr = dst->sin.sin_addr.s_addr;
+		fl4.saddr = vxlan->saddr.sin.sin_addr.s_addr;
+
+		rt = ip_route_output_key(dev_net(dev), &fl4);
+		if (IS_ERR(rt)) {
+			netdev_dbg(dev, "no route to %pI4\n",
+				   &dst->sin.sin_addr.s_addr);
+			dev->stats.tx_carrier_errors++;
+			goto tx_error;
+		}
 
-	if (rt->dst.dev == dev) {
-		netdev_dbg(dev, "circular route to %pI4\n", &dst);
-		dev->stats.collisions++;
-		goto rt_tx_error;
-	}
+		if (rt->dst.dev == dev) {
+			netdev_dbg(dev, "circular route to %pI4\n",
+				   &dst->sin.sin_addr.s_addr);
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
+			dst_vxlan = vxlan_find_vni(dev_net(dev), vni, dst_port);
+			if (!dst_vxlan)
+				goto tx_error;
+			vxlan_encap_bypass(skb, vxlan, dst_vxlan);
+			return;
+		}
 
-	/* Bypass encapsulation if the destination is local */
-	if (rt->rt_flags & RTCF_LOCAL &&
-	    !(rt->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))) {
-		struct vxlan_dev *dst_vxlan;
+		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
+		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
 
-		ip_rt_put(rt);
-		dst_vxlan = vxlan_find_vni(dev_net(dev), vni, dst_port);
-		if (!dst_vxlan)
+		err = vxlan_xmit_skb(dev_net(dev), vxlan->vn_sock, rt, skb,
+				     fl4.saddr, dst->sin.sin_addr.s_addr,
+				     tos, ttl, df, src_port, dst_port,
+				     htonl(vni << 8));
+
+		if (err < 0)
+			goto rt_tx_error;
+		iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
+#if IS_ENABLED(CONFIG_IPV6)
+	} else {
+		struct sock *sk = vxlan->vn_sock->sock->sk;
+		struct dst_entry *ndst;
+		struct flowi6 fl6;
+		u32 flags;
+
+		memset(&fl6, 0, sizeof(fl6));
+		fl6.flowi6_oif = rdst->remote_ifindex;
+		fl6.daddr = dst->sin6.sin6_addr;
+		fl6.saddr = vxlan->saddr.sin6.sin6_addr;
+		fl6.flowi6_proto = skb->protocol;
+
+		if (ipv6_stub->ipv6_dst_lookup(sk, &ndst, &fl6)) {
+			netdev_dbg(dev, "no route to %pI6\n",
+				   &dst->sin6.sin6_addr);
+			dev->stats.tx_carrier_errors++;
 			goto tx_error;
-		vxlan_encap_bypass(skb, vxlan, dst_vxlan);
-		return;
-	}
+		}
 
-	tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
-	ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
+		if (ndst->dev == dev) {
+			netdev_dbg(dev, "circular route to %pI6\n",
+				   &dst->sin6.sin6_addr);
+			dst_release(ndst);
+			dev->stats.collisions++;
+			goto tx_error;
+		}
 
-	err = vxlan_xmit_skb(dev_net(dev), vxlan->vn_sock, rt, skb,
-			     fl4.saddr, dst, tos, ttl, df,
-			     src_port, dst_port, htonl(vni << 8));
+		/* Bypass encapsulation if the destination is local */
+		flags = ((struct rt6_info *)ndst)->rt6i_flags;
+		if (flags & RTF_LOCAL &&
+		    !(flags & (RTCF_BROADCAST | RTCF_MULTICAST))) {
+			struct vxlan_dev *dst_vxlan;
+
+			dst_release(ndst);
+			dst_vxlan = vxlan_find_vni(dev_net(dev), vni, dst_port);
+			if (!dst_vxlan)
+				goto tx_error;
+			vxlan_encap_bypass(skb, vxlan, dst_vxlan);
+			return;
+		}
 
-	if (err < 0)
-		goto rt_tx_error;
-	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
+		ttl = ttl ? : ip6_dst_hoplimit(ndst);
+
+		err = vxlan6_xmit_skb(dev_net(dev), vxlan->vn_sock, ndst, skb,
+				      dev, &fl6.saddr, &fl6.daddr, 0, ttl,
+				      src_port, dst_port, htonl(vni << 8));
+#endif
+	}
 
 	return;
 
@@ -1464,8 +1796,8 @@ static int vxlan_open(struct net_device *dev)
 	if (!vs)
 		return -ENOTCONN;
 
-	if (IN_MULTICAST(ntohl(vxlan->default_dst.remote_ip)) &&
-	    vxlan_group_used(vn, vxlan->default_dst.remote_ip)) {
+	if (vxlan_addr_multicast(&vxlan->default_dst.remote_ip) &&
+	    vxlan_group_used(vn, &vxlan->default_dst.remote_ip)) {
 		vxlan_sock_hold(vs);
 		dev_hold(dev);
 		queue_work(vxlan_wq, &vxlan->igmp_join);
@@ -1503,8 +1835,8 @@ static int vxlan_stop(struct net_device *dev)
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_sock *vs = vxlan->vn_sock;
 
-	if (vs && IN_MULTICAST(ntohl(vxlan->default_dst.remote_ip)) &&
-	    ! vxlan_group_used(vn, vxlan->default_dst.remote_ip)) {
+	if (vs && vxlan_addr_multicast(&vxlan->default_dst.remote_ip) &&
+	    ! vxlan_group_used(vn, &vxlan->default_dst.remote_ip)) {
 		vxlan_sock_hold(vs);
 		dev_hold(dev);
 		queue_work(vxlan_wq, &vxlan->igmp_leave);
@@ -1552,7 +1884,10 @@ static void vxlan_setup(struct net_device *dev)
 
 	eth_hw_addr_random(dev);
 	ether_setup(dev);
-	dev->hard_header_len = ETH_HLEN + VXLAN_HEADROOM;
+	if (vxlan->default_dst.remote_ip.sa.sa_family == AF_INET6)
+		dev->hard_header_len = ETH_HLEN + VXLAN6_HEADROOM;
+	else
+		dev->hard_header_len = ETH_HLEN + VXLAN_HEADROOM;
 
 	dev->netdev_ops = &vxlan_netdev_ops;
 	dev->destructor = free_netdev;
@@ -1597,8 +1932,10 @@ static void vxlan_setup(struct net_device *dev)
 static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_ID]		= { .type = NLA_U32 },
 	[IFLA_VXLAN_GROUP]	= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
+	[IFLA_VXLAN_GROUP6]	= { .len = sizeof(struct in6_addr) },
 	[IFLA_VXLAN_LINK]	= { .type = NLA_U32 },
 	[IFLA_VXLAN_LOCAL]	= { .len = FIELD_SIZEOF(struct iphdr, saddr) },
+	[IFLA_VXLAN_LOCAL6]	= { .len = sizeof(struct in6_addr) },
 	[IFLA_VXLAN_TOS]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_TTL]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_LEARNING]	= { .type = NLA_U8 },
@@ -1669,58 +2006,132 @@ static void vxlan_del_work(struct work_struct *work)
 	kfree_rcu(vs, rcu);
 }
 
-static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
-					      vxlan_rcv_t *rcv, void *data)
+#if IS_ENABLED(CONFIG_IPV6)
+/* Create UDP socket for encapsulation receive. AF_INET6 socket
+ * could be used for both IPv4 and IPv6 communications, but
+ * users may set bindv6only=1.
+ */
+static int create_v6_sock(struct net *net, __be16 port, struct socket **psock)
+{
+	struct sock *sk;
+	struct socket *sock;
+	struct sockaddr_in6 vxlan_addr = {
+		.sin6_family = AF_INET6,
+		.sin6_port = port,
+	};
+	int rc, val = 1;
+
+	rc = sock_create_kern(AF_INET6, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	if (rc < 0) {
+		pr_debug("UDPv6 socket create failed\n");
+		return rc;
+	}
+
+	/* Put in proper namespace */
+	sk = sock->sk;
+	sk_change_net(sk, net);
+
+	kernel_setsockopt(sock, SOL_IPV6, IPV6_V6ONLY,
+			  (char *)&val, sizeof(val));
+	rc = kernel_bind(sock, (struct sockaddr *)&vxlan_addr,
+			 sizeof(struct sockaddr_in6));
+	if (rc < 0) {
+		pr_debug("bind for UDPv6 socket %pI6:%u (%d)\n",
+			 &vxlan_addr.sin6_addr, ntohs(vxlan_addr.sin6_port), rc);
+		sk_release_kernel(sk);
+		return rc;
+	}
+	/* At this point, IPv6 module should have been loaded in
+	 * sock_create_kern().
+	 */
+	BUG_ON(!ipv6_stub);
+
+	*psock = sock;
+	/* Disable multicast loopback */
+	inet_sk(sk)->mc_loop = 0;
+	return 0;
+}
+
+#else
+
+static int create_v6_sock(struct net *net, __be16 port, struct socket **psock)
+{
+		return -EPFNOSUPPORT;
+}
+#endif
+
+static int create_v4_sock(struct net *net, __be16 port, struct socket **psock)
 {
-	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-	struct vxlan_sock *vs;
 	struct sock *sk;
+	struct socket *sock;
 	struct sockaddr_in vxlan_addr = {
 		.sin_family = AF_INET,
 		.sin_addr.s_addr = htonl(INADDR_ANY),
 		.sin_port = port,
 	};
 	int rc;
-	unsigned int h;
-
-	vs = kmalloc(sizeof(*vs), GFP_KERNEL);
-	if (!vs) {
-		pr_debug("memory alocation failure\n");
-		return ERR_PTR(-ENOMEM);
-	}
-
-	for (h = 0; h < VNI_HASH_SIZE; ++h)
-		INIT_HLIST_HEAD(&vs->vni_list[h]);
-
-	INIT_WORK(&vs->del_work, vxlan_del_work);
 
 	/* Create UDP socket for encapsulation receive. */
-	rc = sock_create_kern(AF_INET, SOCK_DGRAM, IPPROTO_UDP, &vs->sock);
+	rc = sock_create_kern(AF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
 	if (rc < 0) {
 		pr_debug("UDP socket create failed\n");
-		kfree(vs);
-		return ERR_PTR(rc);
+		return rc;
 	}
 
 	/* Put in proper namespace */
-	sk = vs->sock->sk;
+	sk = sock->sk;
 	sk_change_net(sk, net);
 
-	rc = kernel_bind(vs->sock, (struct sockaddr *) &vxlan_addr,
+	rc = kernel_bind(sock, (struct sockaddr *) &vxlan_addr,
 			 sizeof(vxlan_addr));
 	if (rc < 0) {
 		pr_debug("bind for UDP socket %pI4:%u (%d)\n",
 			 &vxlan_addr.sin_addr, ntohs(vxlan_addr.sin_port), rc);
 		sk_release_kernel(sk);
+		return rc;
+	}
+
+	*psock = sock;
+	/* Disable multicast loopback */
+	inet_sk(sk)->mc_loop = 0;
+	return 0;
+}
+
+/* Create new listen socket if needed */
+static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
+					      vxlan_rcv_t *rcv, void *data, bool ipv6)
+{
+	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
+	struct vxlan_sock *vs;
+	struct socket *sock;
+	struct sock *sk;
+	int rc = 0;
+	unsigned int h;
+
+	vs = kmalloc(sizeof(*vs), GFP_KERNEL);
+	if (!vs)
+		return ERR_PTR(-ENOMEM);
+
+	for (h = 0; h < VNI_HASH_SIZE; ++h)
+		INIT_HLIST_HEAD(&vs->vni_list[h]);
+
+	INIT_WORK(&vs->del_work, vxlan_del_work);
+
+	if (ipv6)
+		rc = create_v6_sock(net, port, &sock);
+	else
+		rc = create_v4_sock(net, port, &sock);
+	if (rc < 0) {
 		kfree(vs);
 		return ERR_PTR(rc);
 	}
+
+	vs->sock = sock;
+	sk = sock->sk;
 	atomic_set(&vs->refcnt, 1);
 	vs->rcv = rcv;
 	vs->data = data;
 
-	/* Disable multicast loopback */
-	inet_sk(sk)->mc_loop = 0;
 	spin_lock(&vn->sock_lock);
 	hlist_add_head_rcu(&vs->hlist, vs_head(net, port));
 	spin_unlock(&vn->sock_lock);
@@ -1728,18 +2139,24 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 	/* Mark socket as an encapsulation socket. */
 	udp_sk(sk)->encap_type = 1;
 	udp_sk(sk)->encap_rcv = vxlan_udp_encap_recv;
-	udp_encap_enable();
+#if IS_ENABLED(CONFIG_IPV6)
+	if (ipv6)
+		ipv6_stub->udpv6_encap_enable();
+	else
+#endif
+		udp_encap_enable();
+
 	return vs;
 }
 
 struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 				  vxlan_rcv_t *rcv, void *data,
-				  bool no_share)
+				  bool no_share, bool ipv6)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
 
-	vs = vxlan_socket_create(net, port, rcv, data);
+	vs = vxlan_socket_create(net, port, rcv, data, ipv6);
 	if (!IS_ERR(vs))
 		return vs;
 
@@ -1772,7 +2189,7 @@ static void vxlan_sock_work(struct work_struct *work)
 	__be16 port = vxlan->dst_port;
 	struct vxlan_sock *nvs;
 
-	nvs = vxlan_sock_add(net, port, vxlan_rcv, NULL, false);
+	nvs = vxlan_sock_add(net, port, vxlan_rcv, NULL, false, vxlan->flags & VXLAN_F_IPV6);
 	spin_lock(&vn->sock_lock);
 	if (!IS_ERR(nvs))
 		vxlan_vs_add_dev(nvs, vxlan);
@@ -1789,6 +2206,7 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 	struct vxlan_rdst *dst = &vxlan->default_dst;
 	__u32 vni;
 	int err;
+	bool use_ipv6 = false;
 
 	if (!data[IFLA_VXLAN_ID])
 		return -EINVAL;
@@ -1796,11 +2214,32 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 	vni = nla_get_u32(data[IFLA_VXLAN_ID]);
 	dst->remote_vni = vni;
 
-	if (data[IFLA_VXLAN_GROUP])
-		dst->remote_ip = nla_get_be32(data[IFLA_VXLAN_GROUP]);
+	if (data[IFLA_VXLAN_GROUP]) {
+		dst->remote_ip.sin.sin_addr.s_addr = nla_get_be32(data[IFLA_VXLAN_GROUP]);
+		dst->remote_ip.sa.sa_family = AF_INET;
+	} else if (data[IFLA_VXLAN_GROUP6]) {
+		if (!IS_ENABLED(CONFIG_IPV6))
+			return -EPFNOSUPPORT;
+
+		nla_memcpy(&dst->remote_ip.sin6.sin6_addr, data[IFLA_VXLAN_GROUP6],
+			   sizeof(struct in6_addr));
+		dst->remote_ip.sa.sa_family = AF_INET6;
+		use_ipv6 = true;
+	}
 
-	if (data[IFLA_VXLAN_LOCAL])
-		vxlan->saddr = nla_get_be32(data[IFLA_VXLAN_LOCAL]);
+	if (data[IFLA_VXLAN_LOCAL]) {
+		vxlan->saddr.sin.sin_addr.s_addr = nla_get_be32(data[IFLA_VXLAN_LOCAL]);
+		vxlan->saddr.sa.sa_family = AF_INET;
+	} else if (data[IFLA_VXLAN_LOCAL6]) {
+		if (!IS_ENABLED(CONFIG_IPV6))
+			return -EPFNOSUPPORT;
+
+		/* TODO: respect scope id */
+		nla_memcpy(&vxlan->saddr.sin6.sin6_addr, data[IFLA_VXLAN_LOCAL6],
+			   sizeof(struct in6_addr));
+		vxlan->saddr.sa.sa_family = AF_INET6;
+		use_ipv6 = true;
+	}
 
 	if (data[IFLA_VXLAN_LINK] &&
 	    (dst->remote_ifindex = nla_get_u32(data[IFLA_VXLAN_LINK]))) {
@@ -1812,12 +2251,23 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 			return -ENODEV;
 		}
 
+#if IS_ENABLED(CONFIG_IPV6)
+		if (use_ipv6) {
+			struct inet6_dev *idev = __in6_dev_get(lowerdev);
+			if (idev && idev->cnf.disable_ipv6) {
+				pr_info("IPv6 is disabled via sysctl\n");
+				return -EPERM;
+			}
+			vxlan->flags |= VXLAN_F_IPV6;
+		}
+#endif
+
 		if (!tb[IFLA_MTU])
-			dev->mtu = lowerdev->mtu - VXLAN_HEADROOM;
+			dev->mtu = lowerdev->mtu - (use_ipv6 ? VXLAN6_HEADROOM : VXLAN_HEADROOM);
 
 		/* update header length based on lower device */
 		dev->hard_header_len = lowerdev->hard_header_len +
-				       VXLAN_HEADROOM;
+				       (use_ipv6 ? VXLAN6_HEADROOM : VXLAN_HEADROOM);
 	}
 
 	if (data[IFLA_VXLAN_TOS])
@@ -1868,7 +2318,7 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 
 	/* create an fdb entry for default destination */
 	err = vxlan_fdb_create(vxlan, all_zeros_mac,
-			       vxlan->default_dst.remote_ip,
+			       &vxlan->default_dst.remote_ip,
 			       NUD_REACHABLE|NUD_PERMANENT,
 			       NLM_F_EXCL|NLM_F_CREATE,
 			       vxlan->dst_port, vxlan->default_dst.remote_vni,
@@ -1905,9 +2355,9 @@ static size_t vxlan_get_size(const struct net_device *dev)
 {
 
 	return nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_ID */
-		nla_total_size(sizeof(__be32)) +/* IFLA_VXLAN_GROUP */
+		nla_total_size(sizeof(struct in6_addr)) + /* IFLA_VXLAN_GROUP{6} */
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_LINK */
-		nla_total_size(sizeof(__be32))+	/* IFLA_VXLAN_LOCAL */
+		nla_total_size(sizeof(struct in6_addr)) + /* IFLA_VXLAN_LOCAL{6} */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_TTL */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_TOS */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_LEARNING */
@@ -1934,14 +2384,36 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	if (nla_put_u32(skb, IFLA_VXLAN_ID, dst->remote_vni))
 		goto nla_put_failure;
 
-	if (dst->remote_ip && nla_put_be32(skb, IFLA_VXLAN_GROUP, dst->remote_ip))
-		goto nla_put_failure;
+	if (!vxlan_addr_any(&dst->remote_ip)) {
+		if (dst->remote_ip.sa.sa_family == AF_INET) {
+			if (nla_put_be32(skb, IFLA_VXLAN_GROUP,
+					 dst->remote_ip.sin.sin_addr.s_addr))
+				goto nla_put_failure;
+#if IS_ENABLED(CONFIG_IPV6)
+		} else {
+			if (nla_put(skb, IFLA_VXLAN_GROUP6, sizeof(struct in6_addr),
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
+			if (nla_put_be32(skb, IFLA_VXLAN_LOCAL,
+					 vxlan->saddr.sin.sin_addr.s_addr))
+				goto nla_put_failure;
+#if IS_ENABLED(CONFIG_IPV6)
+		} else {
+			if (nla_put(skb, IFLA_VXLAN_LOCAL6, sizeof(struct in6_addr),
+				    &vxlan->saddr.sin6.sin6_addr))
+				goto nla_put_failure;
+#endif
+		}
+	}
 
 	if (nla_put_u8(skb, IFLA_VXLAN_TTL, vxlan->ttl) ||
 	    nla_put_u8(skb, IFLA_VXLAN_TOS, vxlan->tos) ||
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index ad342e3..d2b88ca 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -25,7 +25,7 @@ struct vxlan_sock {
 
 struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 				  vxlan_rcv_t *rcv, void *data,
-				  bool no_share);
+				  bool no_share, bool ipv6);
 
 void vxlan_sock_release(struct vxlan_sock *vs);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 04c0e7a..80394e8 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -314,6 +314,8 @@ enum {
 	IFLA_VXLAN_L2MISS,
 	IFLA_VXLAN_L3MISS,
 	IFLA_VXLAN_PORT,	/* destination port */
+	IFLA_VXLAN_GROUP6,
+	IFLA_VXLAN_LOCAL6,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 36848bd..a006024 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -123,7 +123,7 @@ static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
 	vxlan_port = vxlan_vport(vport);
 	strncpy(vxlan_port->name, parms->name, IFNAMSIZ);
 
-	vs = vxlan_sock_add(net, htons(dst_port), vxlan_rcv, vport, true);
+	vs = vxlan_sock_add(net, htons(dst_port), vxlan_rcv, vport, true, false);
 	if (IS_ERR(vs)) {
 		ovs_vport_free(vport);
 		return (void *)vs;
-- 
1.7.7.6
