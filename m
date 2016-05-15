From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v5 net-next 09/14] ip6_tun: Add infrastructure for doing encapsulation
Date: Sun, 15 May 2016 16:42:30 -0700
Message-ID: <1463355755-3481375-10-git-send-email-tom@herbertland.com>
References: <1463355755-3481375-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:57886 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752764AbcEOXnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 19:43:00 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4FNf1cb023477
	for <netdev@vger.kernel.org>; Sun, 15 May 2016 16:42:57 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22x03xx363-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 15 May 2016 16:42:57 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 bf7f1db41af611e6a12624be0595f910-d34ebc50 for <netdev@vger.kernel.org>;	Sun,
 15 May 2016 16:42:56 -0700
In-Reply-To: <1463355755-3481375-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add encap_hlen and ip_tunnel_encap structure to ip6_tnl. Add functions
for getting encap hlen, setting up encap on a tunnel, performing
encapsulation operation.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/ip6_tunnel.h  | 58 ++++++++++++++++++++++++++++++
 net/ipv4/ip_tunnel_core.c |  5 +++
 net/ipv6/ip6_tunnel.c     | 89 +++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 141 insertions(+), 11 deletions(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index fb9e015..d325c81 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -52,10 +52,68 @@ struct ip6_tnl {
 	__u32 o_seqno;	/* The last output seqno */
 	int hlen;       /* tun_hlen + encap_hlen */
 	int tun_hlen;	/* Precalculated header length */
+	int encap_hlen; /* Encap header length (FOU,GUE) */
+	struct ip_tunnel_encap encap;
 	int mlink;
+};
 
+struct ip6_tnl_encap_ops {
+	size_t (*encap_hlen)(struct ip_tunnel_encap *e);
+	int (*build_header)(struct sk_buff *skb, struct ip_tunnel_encap *e,
+			    u8 *protocol, struct flowi6 *fl6);
 };
 
+extern const struct ip6_tnl_encap_ops __rcu *
+		ip6tun_encaps[MAX_IPTUN_ENCAP_OPS];
+
+int ip6_tnl_encap_add_ops(const struct ip6_tnl_encap_ops *ops,
+			  unsigned int num);
+int ip6_tnl_encap_del_ops(const struct ip6_tnl_encap_ops *ops,
+			  unsigned int num);
+int ip6_tnl_encap_setup(struct ip6_tnl *t,
+			struct ip_tunnel_encap *ipencap);
+
+static inline int ip6_encap_hlen(struct ip_tunnel_encap *e)
+{
+	const struct ip6_tnl_encap_ops *ops;
+	int hlen = -EINVAL;
+
+	if (e->type == TUNNEL_ENCAP_NONE)
+		return 0;
+
+	if (e->type >= MAX_IPTUN_ENCAP_OPS)
+		return -EINVAL;
+
+	rcu_read_lock();
+	ops = rcu_dereference(ip6tun_encaps[e->type]);
+	if (likely(ops && ops->encap_hlen))
+		hlen = ops->encap_hlen(e);
+	rcu_read_unlock();
+
+	return hlen;
+}
+
+static inline int ip6_tnl_encap(struct sk_buff *skb, struct ip6_tnl *t,
+				u8 *protocol, struct flowi6 *fl6)
+{
+	const struct ip6_tnl_encap_ops *ops;
+	int ret = -EINVAL;
+
+	if (t->encap.type == TUNNEL_ENCAP_NONE)
+		return 0;
+
+	if (t->encap.type >= MAX_IPTUN_ENCAP_OPS)
+		return -EINVAL;
+
+	rcu_read_lock();
+	ops = rcu_dereference(ip6tun_encaps[t->encap.type]);
+	if (likely(ops && ops->build_header))
+		ret = ops->build_header(skb, &t->encap, protocol, fl6);
+	rcu_read_unlock();
+
+	return ret;
+}
+
 /* Tunnel encapsulation limit destination sub-option */
 
 struct ipv6_tlv_tnl_enc_lim {
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index cc66a20..afd6b59 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -37,6 +37,7 @@
 #include <net/icmp.h>
 #include <net/protocol.h>
 #include <net/ip_tunnels.h>
+#include <net/ip6_tunnel.h>
 #include <net/arp.h>
 #include <net/checksum.h>
 #include <net/dsfield.h>
@@ -51,6 +52,10 @@ const struct ip_tunnel_encap_ops __rcu *
 		iptun_encaps[MAX_IPTUN_ENCAP_OPS] __read_mostly;
 EXPORT_SYMBOL(iptun_encaps);
 
+const struct ip6_tnl_encap_ops __rcu *
+		ip6tun_encaps[MAX_IPTUN_ENCAP_OPS] __read_mostly;
+EXPORT_SYMBOL(ip6tun_encaps);
+
 void iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 		   __be32 src, __be32 dst, __u8 proto,
 		   __u8 tos, __u8 ttl, __be16 df, bool xnet)
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index e79330f..9f0ea85 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1010,7 +1010,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 	struct dst_entry *dst = NULL, *ndst = NULL;
 	struct net_device *tdev;
 	int mtu;
-	unsigned int max_headroom = sizeof(struct ipv6hdr);
+	unsigned int max_headroom = sizeof(struct ipv6hdr) + t->hlen;
 	int err = -1;
 
 	/* NBMA tunnel */
@@ -1063,7 +1063,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 				     t->parms.name);
 		goto tx_err_dst_release;
 	}
-	mtu = dst_mtu(dst) - sizeof(*ipv6h);
+	mtu = dst_mtu(dst) - sizeof(*ipv6h) - t->hlen;
 	if (encap_limit >= 0) {
 		max_headroom += 8;
 		mtu -= 8;
@@ -1125,10 +1125,14 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 	}
 
 	max_headroom = LL_RESERVED_SPACE(dst->dev) + sizeof(struct ipv6hdr)
-			+ dst->header_len;
+			+ dst->header_len + t->hlen;
 	if (max_headroom > dev->needed_headroom)
 		dev->needed_headroom = max_headroom;
 
+	err = ip6_tnl_encap(skb, t, &proto, fl6);
+	if (err)
+		return err;
+
 	skb_push(skb, sizeof(struct ipv6hdr));
 	skb_reset_network_header(skb);
 	ipv6h = ipv6_hdr(skb);
@@ -1280,6 +1284,7 @@ static void ip6_tnl_link_config(struct ip6_tnl *t)
 	struct net_device *dev = t->dev;
 	struct __ip6_tnl_parm *p = &t->parms;
 	struct flowi6 *fl6 = &t->fl.u.ip6;
+	int t_hlen;
 
 	memcpy(dev->dev_addr, &p->laddr, sizeof(struct in6_addr));
 	memcpy(dev->broadcast, &p->raddr, sizeof(struct in6_addr));
@@ -1303,6 +1308,10 @@ static void ip6_tnl_link_config(struct ip6_tnl *t)
 	else
 		dev->flags &= ~IFF_POINTOPOINT;
 
+	t->tun_hlen = 0;
+	t->hlen = t->encap_hlen + t->tun_hlen;
+	t_hlen = t->hlen + sizeof(struct ipv6hdr);
+
 	if (p->flags & IP6_TNL_F_CAP_XMIT) {
 		int strict = (ipv6_addr_type(&p->raddr) &
 			      (IPV6_ADDR_MULTICAST|IPV6_ADDR_LINKLOCAL));
@@ -1316,9 +1325,9 @@ static void ip6_tnl_link_config(struct ip6_tnl *t)
 
 		if (rt->dst.dev) {
 			dev->hard_header_len = rt->dst.dev->hard_header_len +
-				sizeof(struct ipv6hdr);
+				sizeof(struct ipv6hdr) + t->encap_hlen;
 
-			dev->mtu = rt->dst.dev->mtu - sizeof(struct ipv6hdr);
+			dev->mtu = rt->dst.dev->mtu - t_hlen;
 			if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
 				dev->mtu -= 8;
 
@@ -1564,6 +1573,59 @@ int ip6_tnl_get_iflink(const struct net_device *dev)
 }
 EXPORT_SYMBOL(ip6_tnl_get_iflink);
 
+int ip6_tnl_encap_add_ops(const struct ip6_tnl_encap_ops *ops,
+			  unsigned int num)
+{
+	if (num >= MAX_IPTUN_ENCAP_OPS)
+		return -ERANGE;
+
+	return !cmpxchg((const struct ip6_tnl_encap_ops **)
+			&ip6tun_encaps[num],
+			NULL, ops) ? 0 : -1;
+}
+EXPORT_SYMBOL(ip6_tnl_encap_add_ops);
+
+int ip6_tnl_encap_del_ops(const struct ip6_tnl_encap_ops *ops,
+			  unsigned int num)
+{
+	int ret;
+
+	if (num >= MAX_IPTUN_ENCAP_OPS)
+		return -ERANGE;
+
+	ret = (cmpxchg((const struct ip6_tnl_encap_ops **)
+		       &ip6tun_encaps[num],
+		       ops, NULL) == ops) ? 0 : -1;
+
+	synchronize_net();
+
+	return ret;
+}
+EXPORT_SYMBOL(ip6_tnl_encap_del_ops);
+
+int ip6_tnl_encap_setup(struct ip6_tnl *t,
+			struct ip_tunnel_encap *ipencap)
+{
+	int hlen;
+
+	memset(&t->encap, 0, sizeof(t->encap));
+
+	hlen = ip6_encap_hlen(ipencap);
+	if (hlen < 0)
+		return hlen;
+
+	t->encap.type = ipencap->type;
+	t->encap.sport = ipencap->sport;
+	t->encap.dport = ipencap->dport;
+	t->encap.flags = ipencap->flags;
+
+	t->encap_hlen = hlen;
+	t->hlen = t->encap_hlen + t->tun_hlen;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ip6_tnl_encap_setup);
+
 static const struct net_device_ops ip6_tnl_netdev_ops = {
 	.ndo_init	= ip6_tnl_dev_init,
 	.ndo_uninit	= ip6_tnl_dev_uninit,
@@ -1590,14 +1652,11 @@ static void ip6_tnl_dev_setup(struct net_device *dev)
 	dev->netdev_ops = &ip6_tnl_netdev_ops;
 	dev->destructor = ip6_dev_free;
 
-	dev->type = ARPHRD_TUNNEL6;
-	dev->hard_header_len = LL_MAX_HEADER + sizeof(struct ipv6hdr);
-	dev->mtu = ETH_DATA_LEN - sizeof(struct ipv6hdr);
 	t = netdev_priv(dev);
-	if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
-		dev->mtu -= 8;
+	dev->type = ARPHRD_TUNNEL6;
 	dev->flags |= IFF_NOARP;
 	dev->addr_len = sizeof(struct in6_addr);
+	dev->features |= NETIF_F_LLTX;
 	netif_keep_dst(dev);
 	/* This perm addr will be used as interface identifier by IPv6 */
 	dev->addr_assign_type = NET_ADDR_RANDOM;
@@ -1615,6 +1674,7 @@ ip6_tnl_dev_init_gen(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 	int ret;
+	int t_hlen;
 
 	t->dev = dev;
 	t->net = dev_net(dev);
@@ -1630,8 +1690,15 @@ ip6_tnl_dev_init_gen(struct net_device *dev)
 	if (ret)
 		goto destroy_dst;
 
-	t->hlen = 0;
 	t->tun_hlen = 0;
+	t->hlen = t->encap_hlen + t->tun_hlen;
+	t_hlen = t->hlen + sizeof(struct ipv6hdr);
+
+	dev->type = ARPHRD_TUNNEL6;
+	dev->hard_header_len = LL_MAX_HEADER + t_hlen;
+	dev->mtu = ETH_DATA_LEN - t_hlen;
+	if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
+		dev->mtu -= 8;
 
 	return 0;
 
-- 
2.8.0.rc2
