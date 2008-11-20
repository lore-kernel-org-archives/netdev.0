From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 9/9] ipgre: convert to netdevice_ops
Date: Thu, 20 Nov 2008 09:59:22 -0800
Message-ID: <20081120175934.301212308@vyatta.com>
References: <20081120175913.943543638@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:53086 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754722AbYKTSER (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2008 13:04:17 -0500
Content-Disposition: inline; filename=ipgre-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert ipgre tunnel to netdevice ops.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/ip_gre.c	2008-11-20 09:49:13.000000000 -0800
+++ b/net/ipv4/ip_gre.c	2008-11-20 09:56:39.000000000 -0800
@@ -126,8 +126,6 @@ static int ipgre_tunnel_bind_dev(struct 
 
 /* Fallback tunnel: no source, no destination, no key, no options */
 
-static int ipgre_fb_tunnel_init(struct net_device *dev);
-
 #define HASH_SIZE  16
 
 static int ipgre_net_id;
@@ -1142,6 +1140,7 @@ static int ipgre_open(struct net_device 
 static int ipgre_close(struct net_device *dev)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
+
 	if (ipv4_is_multicast(t->parms.iph.daddr) && t->mlink) {
 		struct in_device *in_dev;
 		in_dev = inetdev_by_index(dev_net(dev), t->mlink);
@@ -1155,14 +1154,22 @@ static int ipgre_close(struct net_device
 
 #endif
 
+static const struct net_device_ops ipgre_netdev_ops = {
+	.ndo_init		= ipgre_tunnel_init,
+	.ndo_uninit		= ipgre_tunnel_uninit,
+#ifdef CONFIG_NET_IPGRE_BROADCAST
+	.ndo_open		= ipgre_open,
+	.ndo_stop		= ipgre_close,
+#endif
+	.ndo_start_xmit		= ipgre_tunnel_xmit,
+	.ndo_do_ioctl		= ipgre_tunnel_ioctl,
+	.ndo_change_mtu		= ipgre_tunnel_change_mtu,
+};
+
 static void ipgre_tunnel_setup(struct net_device *dev)
 {
-	dev->init		= ipgre_tunnel_init;
-	dev->uninit		= ipgre_tunnel_uninit;
+	dev->netdev_ops		= &ipgre_netdev_ops;
 	dev->destructor 	= free_netdev;
-	dev->hard_start_xmit	= ipgre_tunnel_xmit;
-	dev->do_ioctl		= ipgre_tunnel_ioctl;
-	dev->change_mtu		= ipgre_tunnel_change_mtu;
 
 	dev->type		= ARPHRD_IPGRE;
 	dev->needed_headroom 	= LL_MAX_HEADER + sizeof(struct iphdr) + 4;
@@ -1194,8 +1201,6 @@ static int ipgre_tunnel_init(struct net_
 				return -EINVAL;
 			dev->flags = IFF_BROADCAST;
 			dev->header_ops = &ipgre_header_ops;
-			dev->open = ipgre_open;
-			dev->stop = ipgre_close;
 		}
 #endif
 	} else
@@ -1204,7 +1209,7 @@ static int ipgre_tunnel_init(struct net_
 	return 0;
 }
 
-static int ipgre_fb_tunnel_init(struct net_device *dev)
+static void ipgre_fb_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct iphdr *iph = &tunnel->parms.iph;
@@ -1220,7 +1225,6 @@ static int ipgre_fb_tunnel_init(struct n
 
 	dev_hold(dev);
 	ign->tunnels_wc[0]	= tunnel;
-	return 0;
 }
 
 
@@ -1265,7 +1269,7 @@ static int ipgre_init_net(struct net *ne
 		goto err_alloc_dev;
 	}
 
-	ign->fb_tunnel_dev->init = ipgre_fb_tunnel_init;
+	ipgre_fb_tunnel_init(ign->fb_tunnel_dev);
 	dev_net_set(ign->fb_tunnel_dev, net);
 	ign->fb_tunnel_dev->rtnl_link_ops = &ipgre_link_ops;
 
@@ -1397,16 +1401,22 @@ static int ipgre_tap_init(struct net_dev
 	return 0;
 }
 
+static const struct net_device_ops ipgre_tap_netdev_ops = {
+	.ndo_init		= ipgre_tap_init,
+	.ndo_uninit		= ipgre_tunnel_uninit,
+	.ndo_start_xmit		= ipgre_tunnel_xmit,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= ipgre_tunnel_change_mtu,
+};
+
 static void ipgre_tap_setup(struct net_device *dev)
 {
 
 	ether_setup(dev);
 
-	dev->init		= ipgre_tap_init;
-	dev->uninit		= ipgre_tunnel_uninit;
+	dev->netdev_ops		= &ipgre_netdev_ops;
 	dev->destructor 	= free_netdev;
-	dev->hard_start_xmit	= ipgre_tunnel_xmit;
-	dev->change_mtu		= ipgre_tunnel_change_mtu;
 
 	dev->iflink		= 0;
 	dev->features		|= NETIF_F_NETNS_LOCAL;

-- 

