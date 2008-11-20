From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 7/9] ipip: convert to net_device_ops
Date: Thu, 20 Nov 2008 09:59:20 -0800
Message-ID: <20081120175934.092348986@vyatta.com>
References: <20081120175913.943543638@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:53081 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754262AbYKTSEP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2008 13:04:15 -0500
Content-Disposition: inline; filename=ipip-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to network device ops. Needed to change to directly call
the init routine since two sides share same ops.  In the process
found by inspection a device ref count leak if register_netdevice failed.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/ipip.c	2008-11-20 09:41:54.000000000 -0800
+++ b/net/ipv4/ipip.c	2008-11-20 09:47:10.000000000 -0800
@@ -130,8 +130,8 @@ struct ipip_net {
 	struct net_device *fb_tunnel_dev;
 };
 
-static int ipip_fb_tunnel_init(struct net_device *dev);
-static int ipip_tunnel_init(struct net_device *dev);
+static void ipip_fb_tunnel_init(struct net_device *dev);
+static void ipip_tunnel_init(struct net_device *dev);
 static void ipip_tunnel_setup(struct net_device *dev);
 
 static DEFINE_RWLOCK(ipip_lock);
@@ -245,9 +245,10 @@ static struct ip_tunnel * ipip_tunnel_lo
 	}
 
 	nt = netdev_priv(dev);
-	dev->init = ipip_tunnel_init;
 	nt->parms = *parms;
 
+	ipip_tunnel_init(dev);
+
 	if (register_netdevice(dev) < 0)
 		goto failed_free;
 
@@ -691,12 +692,17 @@ static int ipip_tunnel_change_mtu(struct
 	return 0;
 }
 
+static const struct net_device_ops ipip_netdev_ops = {
+	.ndo_uninit	= ipip_tunnel_uninit,
+	.ndo_start_xmit	= ipip_tunnel_xmit,
+	.ndo_do_ioctl	= ipip_tunnel_ioctl,
+	.ndo_change_mtu	= ipip_tunnel_change_mtu,
+
+};
+
 static void ipip_tunnel_setup(struct net_device *dev)
 {
-	dev->uninit		= ipip_tunnel_uninit;
-	dev->hard_start_xmit	= ipip_tunnel_xmit;
-	dev->do_ioctl		= ipip_tunnel_ioctl;
-	dev->change_mtu		= ipip_tunnel_change_mtu;
+	dev->netdev_ops		= &ipip_netdev_ops;
 	dev->destructor		= free_netdev;
 
 	dev->type		= ARPHRD_TUNNEL;
@@ -708,11 +714,9 @@ static void ipip_tunnel_setup(struct net
 	dev->features		|= NETIF_F_NETNS_LOCAL;
 }
 
-static int ipip_tunnel_init(struct net_device *dev)
+static void ipip_tunnel_init(struct net_device *dev)
 {
-	struct ip_tunnel *tunnel;
-
-	tunnel = netdev_priv(dev);
+	struct ip_tunnel *tunnel = netdev_priv(dev);
 
 	tunnel->dev = dev;
 	strcpy(tunnel->parms.name, dev->name);
@@ -721,11 +725,9 @@ static int ipip_tunnel_init(struct net_d
 	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
 
 	ipip_tunnel_bind_dev(dev);
-
-	return 0;
 }
 
-static int ipip_fb_tunnel_init(struct net_device *dev)
+static void ipip_fb_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct iphdr *iph = &tunnel->parms.iph;
@@ -740,7 +742,6 @@ static int ipip_fb_tunnel_init(struct ne
 
 	dev_hold(dev);
 	ipn->tunnels_wc[0]	= tunnel;
-	return 0;
 }
 
 static struct xfrm_tunnel ipip_handler = {
@@ -793,7 +794,7 @@ static int ipip_init_net(struct net *net
 		goto err_alloc_dev;
 	}
 
-	ipn->fb_tunnel_dev->init = ipip_fb_tunnel_init;
+	ipip_fb_tunnel_init(ipn->fb_tunnel_dev);
 	dev_net_set(ipn->fb_tunnel_dev, net);
 
 	if ((err = register_netdev(ipn->fb_tunnel_dev)))

-- 

