From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next v2 9/9] ipv4/6: use core net MTU range checking
Date: Thu, 20 Oct 2016 13:55:24 -0400
Message-ID: <20161020175524.6184-10-jarod@redhat.com>
References: <20161019023333.15760-1-jarod@redhat.com>
 <20161020175524.6184-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161020175524.6184-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ipv4/ip_tunnel:
- min_mtu = 68, max_mtu = 0xFFF8 - dev->hard_header_len - t_hlen
- preserve all ndo_change_mtu checks for now to prevent regressions

ipv6/ip6_tunnel:
- min_mtu = 68, max_mtu = 0xFFF8 - dev->hard_header_len
- preserve all ndo_change_mtu checks for now to prevent regressions

ipv6/ip6_vti:
- min_mtu = 1280, max_mtu = 65535
- remove redundant vti6_change_mtu

ipv6/sit:
- min_mtu = 1280, max_mtu = 0xFFF8 - t_hlen
- remove redundant ipip6_tunnel_change_mtu

CC: netdev@vger.kernel.org
CC: "David S. Miller" <davem@davemloft.net>
CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
CC: James Morris <jmorris@namei.org>
CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
CC: Patrick McHardy <kaber@trash.net>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 net/ipv4/ip_tunnel.c  |  6 +++++-
 net/ipv6/ip6_tunnel.c |  4 +++-
 net/ipv6/ip6_vti.c    | 21 ++-------------------
 net/ipv6/sit.c        | 14 ++------------
 4 files changed, 12 insertions(+), 33 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 5719d6b..12a92e3 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -358,6 +358,7 @@ static struct ip_tunnel *ip_tunnel_create(struct net *net,
 {
 	struct ip_tunnel *nt;
 	struct net_device *dev;
+	int t_hlen;
 
 	BUG_ON(!itn->fb_tunnel_dev);
 	dev = __ip_tunnel_create(net, itn->fb_tunnel_dev->rtnl_link_ops, parms);
@@ -367,6 +368,9 @@ static struct ip_tunnel *ip_tunnel_create(struct net *net,
 	dev->mtu = ip_tunnel_bind_dev(dev);
 
 	nt = netdev_priv(dev);
+	t_hlen = nt->hlen + sizeof(struct iphdr);
+	dev->min_mtu = ETH_MIN_MTU;
+	dev->max_mtu = 0xFFF8 - dev->hard_header_len - t_hlen;
 	ip_tunnel_add(itn, nt);
 	return nt;
 }
@@ -929,7 +933,7 @@ int __ip_tunnel_change_mtu(struct net_device *dev, int new_mtu, bool strict)
 	int t_hlen = tunnel->hlen + sizeof(struct iphdr);
 	int max_mtu = 0xFFF8 - dev->hard_header_len - t_hlen;
 
-	if (new_mtu < 68)
+	if (new_mtu < ETH_MIN_MTU)
 		return -EINVAL;
 
 	if (new_mtu > max_mtu) {
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 6a66adb..3a70567 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1634,7 +1634,7 @@ int ip6_tnl_change_mtu(struct net_device *dev, int new_mtu)
 	struct ip6_tnl *tnl = netdev_priv(dev);
 
 	if (tnl->parms.proto == IPPROTO_IPIP) {
-		if (new_mtu < 68)
+		if (new_mtu < ETH_MIN_MTU)
 			return -EINVAL;
 	} else {
 		if (new_mtu < IPV6_MIN_MTU)
@@ -1787,6 +1787,8 @@ ip6_tnl_dev_init_gen(struct net_device *dev)
 	dev->mtu = ETH_DATA_LEN - t_hlen;
 	if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
 		dev->mtu -= 8;
+	dev->min_mtu = ETH_MIN_MTU;
+	dev->max_mtu = 0xFFF8 - dev->hard_header_len;
 
 	return 0;
 
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 8a02ca8..35c5b2d 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -812,30 +812,11 @@ vti6_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return err;
 }
 
-/**
- * vti6_tnl_change_mtu - change mtu manually for tunnel device
- *   @dev: virtual device associated with tunnel
- *   @new_mtu: the new mtu
- *
- * Return:
- *   0 on success,
- *   %-EINVAL if mtu too small
- **/
-static int vti6_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if (new_mtu < IPV6_MIN_MTU)
-		return -EINVAL;
-
-	dev->mtu = new_mtu;
-	return 0;
-}
-
 static const struct net_device_ops vti6_netdev_ops = {
 	.ndo_init	= vti6_dev_init,
 	.ndo_uninit	= vti6_dev_uninit,
 	.ndo_start_xmit = vti6_tnl_xmit,
 	.ndo_do_ioctl	= vti6_ioctl,
-	.ndo_change_mtu = vti6_change_mtu,
 	.ndo_get_stats64 = ip_tunnel_get_stats64,
 	.ndo_get_iflink = ip6_tnl_get_iflink,
 };
@@ -855,6 +836,8 @@ static void vti6_dev_setup(struct net_device *dev)
 	dev->type = ARPHRD_TUNNEL6;
 	dev->hard_header_len = LL_MAX_HEADER + sizeof(struct ipv6hdr);
 	dev->mtu = ETH_DATA_LEN;
+	dev->min_mtu = IPV6_MIN_MTU;
+	dev->max_mtu = IP_MAX_MTU;
 	dev->flags |= IFF_NOARP;
 	dev->addr_len = sizeof(struct in6_addr);
 	netif_keep_dst(dev);
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index b1cdf80..dc7a344 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1318,23 +1318,11 @@ ipip6_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return err;
 }
 
-static int ipip6_tunnel_change_mtu(struct net_device *dev, int new_mtu)
-{
-	struct ip_tunnel *tunnel = netdev_priv(dev);
-	int t_hlen = tunnel->hlen + sizeof(struct iphdr);
-
-	if (new_mtu < IPV6_MIN_MTU || new_mtu > 0xFFF8 - t_hlen)
-		return -EINVAL;
-	dev->mtu = new_mtu;
-	return 0;
-}
-
 static const struct net_device_ops ipip6_netdev_ops = {
 	.ndo_init	= ipip6_tunnel_init,
 	.ndo_uninit	= ipip6_tunnel_uninit,
 	.ndo_start_xmit	= sit_tunnel_xmit,
 	.ndo_do_ioctl	= ipip6_tunnel_ioctl,
-	.ndo_change_mtu	= ipip6_tunnel_change_mtu,
 	.ndo_get_stats64 = ip_tunnel_get_stats64,
 	.ndo_get_iflink = ip_tunnel_get_iflink,
 };
@@ -1365,6 +1353,8 @@ static void ipip6_tunnel_setup(struct net_device *dev)
 	dev->type		= ARPHRD_SIT;
 	dev->hard_header_len	= LL_MAX_HEADER + t_hlen;
 	dev->mtu		= ETH_DATA_LEN - t_hlen;
+	dev->min_mtu		= IPV6_MIN_MTU;
+	dev->max_mtu		= 0xFFF8 - t_hlen;
 	dev->flags		= IFF_NOARP;
 	netif_keep_dst(dev);
 	dev->addr_len		= 4;
-- 
2.10.0
