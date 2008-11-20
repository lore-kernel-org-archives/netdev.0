From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 8/9] ipv6: convert tunnels to net_device_ops
Date: Thu, 20 Nov 2008 09:59:21 -0800
Message-ID: <20081120175934.215776511@vyatta.com>
References: <20081120175913.943543638@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:53084 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754642AbYKTSEQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2008 13:04:16 -0500
Content-Disposition: inline; filename=ipip6-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Like IPV4, convert the tunnel virtual devices to use net_device_ops.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/ipv6/ip6_tunnel.c |   29 +++++++++++++++--------------
 net/ipv6/sit.c        |   33 +++++++++++++++++----------------
 2 files changed, 32 insertions(+), 30 deletions(-)

--- a/net/ipv6/sit.c	2008-11-20 09:49:19.000000000 -0800
+++ b/net/ipv6/sit.c	2008-11-20 09:49:46.000000000 -0800
@@ -62,8 +62,8 @@
 #define HASH_SIZE  16
 #define HASH(addr) (((__force u32)addr^((__force u32)addr>>4))&0xF)
 
-static int ipip6_fb_tunnel_init(struct net_device *dev);
-static int ipip6_tunnel_init(struct net_device *dev);
+static void ipip6_fb_tunnel_init(struct net_device *dev);
+static void ipip6_tunnel_init(struct net_device *dev);
 static void ipip6_tunnel_setup(struct net_device *dev);
 
 static int sit_net_id;
@@ -188,7 +188,8 @@ static struct ip_tunnel * ipip6_tunnel_l
 	}
 
 	nt = netdev_priv(dev);
-	dev->init = ipip6_tunnel_init;
+	ipip6_tunnel_init(dev);
+
 	nt->parms = *parms;
 
 	if (parms->i_flags & SIT_ISATAP)
@@ -926,13 +927,17 @@ static int ipip6_tunnel_change_mtu(struc
 	return 0;
 }
 
+static const struct net_device_ops ipip6_netdev_ops = {
+	.ndo_uninit	= ipip6_tunnel_uninit,
+	.ndo_start_xmit	= ipip6_tunnel_xmit,
+	.ndo_do_ioctl	= ipip6_tunnel_ioctl,
+	.ndo_change_mtu	= ipip6_tunnel_change_mtu,
+};
+
 static void ipip6_tunnel_setup(struct net_device *dev)
 {
-	dev->uninit		= ipip6_tunnel_uninit;
+	dev->netdev_ops		= &ipip6_netdev_ops;
 	dev->destructor 	= free_netdev;
-	dev->hard_start_xmit	= ipip6_tunnel_xmit;
-	dev->do_ioctl		= ipip6_tunnel_ioctl;
-	dev->change_mtu		= ipip6_tunnel_change_mtu;
 
 	dev->type		= ARPHRD_SIT;
 	dev->hard_header_len 	= LL_MAX_HEADER + sizeof(struct iphdr);
@@ -943,11 +948,9 @@ static void ipip6_tunnel_setup(struct ne
 	dev->features		|= NETIF_F_NETNS_LOCAL;
 }
 
-static int ipip6_tunnel_init(struct net_device *dev)
+static void ipip6_tunnel_init(struct net_device *dev)
 {
-	struct ip_tunnel *tunnel;
-
-	tunnel = netdev_priv(dev);
+	struct ip_tunnel *tunnel = netdev_priv(dev);
 
 	tunnel->dev = dev;
 	strcpy(tunnel->parms.name, dev->name);
@@ -956,11 +959,9 @@ static int ipip6_tunnel_init(struct net_
 	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
 
 	ipip6_tunnel_bind_dev(dev);
-
-	return 0;
 }
 
-static int ipip6_fb_tunnel_init(struct net_device *dev)
+static void ipip6_fb_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct iphdr *iph = &tunnel->parms.iph;
@@ -977,7 +978,6 @@ static int ipip6_fb_tunnel_init(struct n
 
 	dev_hold(dev);
 	sitn->tunnels_wc[0]	= tunnel;
-	return 0;
 }
 
 static struct xfrm_tunnel sit_handler = {
@@ -1026,7 +1026,7 @@ static int sit_init_net(struct net *net)
 		goto err_alloc_dev;
 	}
 
-	sitn->fb_tunnel_dev->init = ipip6_fb_tunnel_init;
+	ipip6_fb_tunnel_init(sitn->fb_tunnel_dev);
 	dev_net_set(sitn->fb_tunnel_dev, net);
 
 	if ((err = register_netdev(sitn->fb_tunnel_dev)))
@@ -1035,6 +1035,7 @@ static int sit_init_net(struct net *net)
 	return 0;
 
 err_reg_dev:
+	dev_put(sitn->fb_tunnel_dev);
 	free_netdev(sitn->fb_tunnel_dev);
 err_alloc_dev:
 	/* nothing */
--- a/net/ipv6/ip6_tunnel.c	2008-11-20 09:49:19.000000000 -0800
+++ b/net/ipv6/ip6_tunnel.c	2008-11-20 09:49:46.000000000 -0800
@@ -74,8 +74,8 @@ MODULE_LICENSE("GPL");
 		     (addr)->s6_addr32[2] ^ (addr)->s6_addr32[3]) & \
 		    (HASH_SIZE - 1))
 
-static int ip6_fb_tnl_dev_init(struct net_device *dev);
-static int ip6_tnl_dev_init(struct net_device *dev);
+static void ip6_fb_tnl_dev_init(struct net_device *dev);
+static void ip6_tnl_dev_init(struct net_device *dev);
 static void ip6_tnl_dev_setup(struct net_device *dev);
 
 static int ip6_tnl_net_id;
@@ -249,7 +249,7 @@ static struct ip6_tnl *ip6_tnl_create(st
 	}
 
 	t = netdev_priv(dev);
-	dev->init = ip6_tnl_dev_init;
+	ip6_tnl_dev_init(dev);
 	t->parms = *p;
 
 	if ((err = register_netdevice(dev)) < 0)
@@ -1306,6 +1306,14 @@ ip6_tnl_change_mtu(struct net_device *de
 	return 0;
 }
 
+
+static const struct net_device_ops ip6_tnl_netdev_ops = {
+	.ndo_uninit = ip6_tnl_dev_uninit,
+	.ndo_start_xmit = ip6_tnl_xmit,
+	.ndo_do_ioctl = ip6_tnl_ioctl,
+	.ndo_change_mtu = ip6_tnl_change_mtu,
+};
+
 /**
  * ip6_tnl_dev_setup - setup virtual tunnel device
  *   @dev: virtual device associated with tunnel
@@ -1316,11 +1324,8 @@ ip6_tnl_change_mtu(struct net_device *de
 
 static void ip6_tnl_dev_setup(struct net_device *dev)
 {
-	dev->uninit = ip6_tnl_dev_uninit;
+	dev->netdev_ops = &ip6_tnl_netdev_ops;
 	dev->destructor = free_netdev;
-	dev->hard_start_xmit = ip6_tnl_xmit;
-	dev->do_ioctl = ip6_tnl_ioctl;
-	dev->change_mtu = ip6_tnl_change_mtu;
 
 	dev->type = ARPHRD_TUNNEL6;
 	dev->hard_header_len = LL_MAX_HEADER + sizeof (struct ipv6hdr);
@@ -1349,13 +1354,11 @@ ip6_tnl_dev_init_gen(struct net_device *
  *   @dev: virtual device associated with tunnel
  **/
 
-static int
-ip6_tnl_dev_init(struct net_device *dev)
+static void ip6_tnl_dev_init(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 	ip6_tnl_dev_init_gen(dev);
 	ip6_tnl_link_config(t);
-	return 0;
 }
 
 /**
@@ -1365,8 +1368,7 @@ ip6_tnl_dev_init(struct net_device *dev)
  * Return: 0
  **/
 
-static int
-ip6_fb_tnl_dev_init(struct net_device *dev)
+static void ip6_fb_tnl_dev_init(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 	struct net *net = dev_net(dev);
@@ -1376,7 +1378,6 @@ ip6_fb_tnl_dev_init(struct net_device *d
 	t->parms.proto = IPPROTO_IPV6;
 	dev_hold(dev);
 	ip6n->tnls_wc[0] = t;
-	return 0;
 }
 
 static struct xfrm6_tunnel ip4ip6_handler = {
@@ -1429,7 +1430,7 @@ static int ip6_tnl_init_net(struct net *
 	if (!ip6n->fb_tnl_dev)
 		goto err_alloc_dev;
 
-	ip6n->fb_tnl_dev->init = ip6_fb_tnl_dev_init;
+	ip6_fb_tnl_dev_init(ip6n->fb_tnl_dev);
 	dev_net_set(ip6n->fb_tnl_dev, net);
 
 	err = register_netdev(ip6n->fb_tnl_dev);

-- 

