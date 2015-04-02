From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 03/12] ipip,gre,vti,sit: implement ndo_get_iflink
Date: Thu,  2 Apr 2015 17:07:02 +0200
Message-ID: <1427987231-3669-4-git-send-email-nicolas.dichtel@6wind.com>
References: <1422979929.907.19.camel@edumazet-glaptop2.roam.corp.google.com>
 <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56597 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753128AbbDBPHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 11:07:24 -0400
In-Reply-To: <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't use dev->iflink anymore.

CC: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/ip_tunnels.h | 1 +
 net/ipv4/ip_gre.c        | 2 ++
 net/ipv4/ip_tunnel.c     | 9 ++++++++-
 net/ipv4/ip_vti.c        | 2 +-
 net/ipv4/ipip.c          | 2 +-
 net/ipv6/sit.c           | 3 +--
 6 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 2c47061a6954..d8214cb88bbc 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -142,6 +142,7 @@ int ip_tunnel_init(struct net_device *dev);
 void ip_tunnel_uninit(struct net_device *dev);
 void  ip_tunnel_dellink(struct net_device *dev, struct list_head *head);
 struct net *ip_tunnel_get_link_net(const struct net_device *dev);
+int ip_tunnel_get_iflink(const struct net_device *dev);
 int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 		       struct rtnl_link_ops *ops, char *devname);
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 0eb2a040a830..1060ca0bc23a 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -456,6 +456,7 @@ static const struct net_device_ops ipgre_netdev_ops = {
 	.ndo_do_ioctl		= ipgre_tunnel_ioctl,
 	.ndo_change_mtu		= ip_tunnel_change_mtu,
 	.ndo_get_stats64	= ip_tunnel_get_stats64,
+	.ndo_get_iflink		= ip_tunnel_get_iflink,
 };
 
 #define GRE_FEATURES (NETIF_F_SG |		\
@@ -686,6 +687,7 @@ static const struct net_device_ops gre_tap_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= ip_tunnel_change_mtu,
 	.ndo_get_stats64	= ip_tunnel_get_stats64,
+	.ndo_get_iflink		= ip_tunnel_get_iflink,
 };
 
 static void ipgre_tap_setup(struct net_device *dev)
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 2cd08280c77b..4bb7252110a6 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -389,7 +389,6 @@ static int ip_tunnel_bind_dev(struct net_device *dev)
 		hlen = tdev->hard_header_len + tdev->needed_headroom;
 		mtu = tdev->mtu;
 	}
-	dev->iflink = tunnel->parms.link;
 
 	dev->needed_headroom = t_hlen + hlen;
 	mtu -= (dev->hard_header_len + t_hlen);
@@ -980,6 +979,14 @@ struct net *ip_tunnel_get_link_net(const struct net_device *dev)
 }
 EXPORT_SYMBOL(ip_tunnel_get_link_net);
 
+int ip_tunnel_get_iflink(const struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+
+	return tunnel->parms.link;
+}
+EXPORT_SYMBOL(ip_tunnel_get_iflink);
+
 int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 				  struct rtnl_link_ops *ops, char *devname)
 {
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 5a6e27054f0a..c4f93c0d1104 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -341,6 +341,7 @@ static const struct net_device_ops vti_netdev_ops = {
 	.ndo_do_ioctl	= vti_tunnel_ioctl,
 	.ndo_change_mtu	= ip_tunnel_change_mtu,
 	.ndo_get_stats64 = ip_tunnel_get_stats64,
+	.ndo_get_iflink = ip_tunnel_get_iflink,
 };
 
 static void vti_tunnel_setup(struct net_device *dev)
@@ -361,7 +362,6 @@ static int vti_tunnel_init(struct net_device *dev)
 	dev->hard_header_len	= LL_MAX_HEADER + sizeof(struct iphdr);
 	dev->mtu		= ETH_DATA_LEN;
 	dev->flags		= IFF_NOARP;
-	dev->iflink		= 0;
 	dev->addr_len		= 4;
 	dev->features		|= NETIF_F_LLTX;
 	netif_keep_dst(dev);
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index bfbcc85c02ee..5c81f6e40842 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -272,6 +272,7 @@ static const struct net_device_ops ipip_netdev_ops = {
 	.ndo_do_ioctl	= ipip_tunnel_ioctl,
 	.ndo_change_mtu = ip_tunnel_change_mtu,
 	.ndo_get_stats64 = ip_tunnel_get_stats64,
+	.ndo_get_iflink = ip_tunnel_get_iflink,
 };
 
 #define IPIP_FEATURES (NETIF_F_SG |		\
@@ -286,7 +287,6 @@ static void ipip_tunnel_setup(struct net_device *dev)
 
 	dev->type		= ARPHRD_TUNNEL;
 	dev->flags		= IFF_NOARP;
-	dev->iflink		= 0;
 	dev->addr_len		= 4;
 	dev->features		|= NETIF_F_LLTX;
 	netif_keep_dst(dev);
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index e6b9f51b15e8..6cf2026a9cea 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1076,7 +1076,6 @@ static void ipip6_tunnel_bind_dev(struct net_device *dev)
 		if (dev->mtu < IPV6_MIN_MTU)
 			dev->mtu = IPV6_MIN_MTU;
 	}
-	dev->iflink = tunnel->parms.link;
 }
 
 static void ipip6_tunnel_update(struct ip_tunnel *t, struct ip_tunnel_parm *p)
@@ -1336,6 +1335,7 @@ static const struct net_device_ops ipip6_netdev_ops = {
 	.ndo_do_ioctl	= ipip6_tunnel_ioctl,
 	.ndo_change_mtu	= ipip6_tunnel_change_mtu,
 	.ndo_get_stats64 = ip_tunnel_get_stats64,
+	.ndo_get_iflink = ip_tunnel_get_iflink,
 };
 
 static void ipip6_dev_free(struct net_device *dev)
@@ -1366,7 +1366,6 @@ static void ipip6_tunnel_setup(struct net_device *dev)
 	dev->mtu		= ETH_DATA_LEN - t_hlen;
 	dev->flags		= IFF_NOARP;
 	netif_keep_dst(dev);
-	dev->iflink		= 0;
 	dev->addr_len		= 4;
 	dev->features		|= NETIF_F_LLTX;
 	dev->features		|= SIT_FEATURES;
-- 
2.2.2
