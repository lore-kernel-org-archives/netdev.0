From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 02/12] ip6tnl,gre6,vti6: implement ndo_get_iflink
Date: Thu,  2 Apr 2015 17:07:01 +0200
Message-ID: <1427987231-3669-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1422979929.907.19.camel@edumazet-glaptop2.roam.corp.google.com>
 <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56594 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752967AbbDBPHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 11:07:23 -0400
In-Reply-To: <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't use dev->iflink anymore.

CC: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/ip6_tunnel.h |  1 +
 net/ipv6/ip6_gre.c       |  8 ++------
 net/ipv6/ip6_tunnel.c    | 10 ++++++++--
 net/ipv6/ip6_vti.c       |  3 +--
 4 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 76c091b53dae..1668be5937e6 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -71,6 +71,7 @@ __u16 ip6_tnl_parse_tlv_enc_lim(struct sk_buff *skb, __u8 *raw);
 __u32 ip6_tnl_get_cap(struct ip6_tnl *t, const struct in6_addr *laddr,
 			     const struct in6_addr *raddr);
 struct net *ip6_tnl_get_link_net(const struct net_device *dev);
+int ip6_tnl_get_iflink(const struct net_device *dev);
 
 static inline void ip6tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 0f4e73da14e4..f724329d7436 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1216,6 +1216,7 @@ static const struct net_device_ops ip6gre_netdev_ops = {
 	.ndo_do_ioctl		= ip6gre_tunnel_ioctl,
 	.ndo_change_mtu		= ip6gre_tunnel_change_mtu,
 	.ndo_get_stats64	= ip_tunnel_get_stats64,
+	.ndo_get_iflink		= ip6_tnl_get_iflink,
 };
 
 static void ip6gre_dev_free(struct net_device *dev)
@@ -1238,7 +1239,6 @@ static void ip6gre_tunnel_setup(struct net_device *dev)
 	if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
 		dev->mtu -= 8;
 	dev->flags |= IFF_NOARP;
-	dev->iflink = 0;
 	dev->addr_len = sizeof(struct in6_addr);
 	netif_keep_dst(dev);
 }
@@ -1270,8 +1270,6 @@ static int ip6gre_tunnel_init(struct net_device *dev)
 		u64_stats_init(&ip6gre_tunnel_stats->syncp);
 	}
 
-	dev->iflink = tunnel->parms.link;
-
 	return 0;
 }
 
@@ -1480,8 +1478,6 @@ static int ip6gre_tap_init(struct net_device *dev)
 	if (!dev->tstats)
 		return -ENOMEM;
 
-	dev->iflink = tunnel->parms.link;
-
 	return 0;
 }
 
@@ -1493,6 +1489,7 @@ static const struct net_device_ops ip6gre_tap_netdev_ops = {
 	.ndo_validate_addr = eth_validate_addr,
 	.ndo_change_mtu = ip6gre_tunnel_change_mtu,
 	.ndo_get_stats64 = ip_tunnel_get_stats64,
+	.ndo_get_iflink = ip6_tnl_get_iflink,
 };
 
 static void ip6gre_tap_setup(struct net_device *dev)
@@ -1503,7 +1500,6 @@ static void ip6gre_tap_setup(struct net_device *dev)
 	dev->netdev_ops = &ip6gre_tap_netdev_ops;
 	dev->destructor = ip6gre_dev_free;
 
-	dev->iflink = 0;
 	dev->features |= NETIF_F_NETNS_LOCAL;
 }
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 9bd85f0dff69..b6a211a150b2 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1264,8 +1264,6 @@ static void ip6_tnl_link_config(struct ip6_tnl *t)
 	else
 		dev->flags &= ~IFF_POINTOPOINT;
 
-	dev->iflink = p->link;
-
 	if (p->flags & IP6_TNL_F_CAP_XMIT) {
 		int strict = (ipv6_addr_type(&p->raddr) &
 			      (IPV6_ADDR_MULTICAST|IPV6_ADDR_LINKLOCAL));
@@ -1517,6 +1515,13 @@ ip6_tnl_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+int ip6_tnl_get_iflink(const struct net_device *dev)
+{
+	struct ip6_tnl *t = netdev_priv(dev);
+
+	return t->parms.link;
+}
+EXPORT_SYMBOL(ip6_tnl_get_iflink);
 
 static const struct net_device_ops ip6_tnl_netdev_ops = {
 	.ndo_init	= ip6_tnl_dev_init,
@@ -1525,6 +1530,7 @@ static const struct net_device_ops ip6_tnl_netdev_ops = {
 	.ndo_do_ioctl	= ip6_tnl_ioctl,
 	.ndo_change_mtu = ip6_tnl_change_mtu,
 	.ndo_get_stats	= ip6_get_stats,
+	.ndo_get_iflink = ip6_tnl_get_iflink,
 };
 
 
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 53d90ed68905..b53148444e15 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -601,8 +601,6 @@ static void vti6_link_config(struct ip6_tnl *t)
 		dev->flags |= IFF_POINTOPOINT;
 	else
 		dev->flags &= ~IFF_POINTOPOINT;
-
-	dev->iflink = p->link;
 }
 
 /**
@@ -808,6 +806,7 @@ static const struct net_device_ops vti6_netdev_ops = {
 	.ndo_do_ioctl	= vti6_ioctl,
 	.ndo_change_mtu = vti6_change_mtu,
 	.ndo_get_stats64 = ip_tunnel_get_stats64,
+	.ndo_get_iflink = ip6_tnl_get_iflink,
 };
 
 /**
-- 
2.2.2
