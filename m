From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 10/33] ip: convert to net_device_ops for ioctl
Date: Mon, 17 Nov 2008 15:42:17 -0800
Message-ID: <20081117234355.629353591@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55060 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752095AbYKRAAG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:06 -0500
Content-Disposition: inline; filename=ip-ioctl.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to net_device_ops function table pointer for ioctl.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/ipmr.c	2008-11-17 12:37:11.000000000 -0800
+++ b/net/ipv4/ipmr.c	2008-11-17 12:38:54.000000000 -0800
@@ -124,8 +124,8 @@ static void ipmr_del_tunnel(struct net_d
 
 	dev = __dev_get_by_name(&init_net, "tunl0");
 	if (dev) {
+		const struct net_device_ops *ops = dev->netdev_ops;
 		struct ifreq ifr;
-		mm_segment_t	oldfs;
 		struct ip_tunnel_parm p;
 
 		memset(&p, 0, sizeof(p));
@@ -137,9 +137,13 @@ static void ipmr_del_tunnel(struct net_d
 		sprintf(p.name, "dvmrp%d", v->vifc_vifi);
 		ifr.ifr_ifru.ifru_data = (__force void __user *)&p;
 
-		oldfs = get_fs(); set_fs(KERNEL_DS);
-		dev->do_ioctl(dev, &ifr, SIOCDELTUNNEL);
-		set_fs(oldfs);
+		if (ops->do_ioctl) {
+			mm_segment_t oldfs = get_fs();
+
+			set_fs(KERNEL_DS);
+			ops->do_ioctl(dev, &ifr, SIOCDELTUNNEL);
+			set_fs(oldfs);
+		}
 	}
 }
 
@@ -151,9 +155,9 @@ struct net_device *ipmr_new_tunnel(struc
 	dev = __dev_get_by_name(&init_net, "tunl0");
 
 	if (dev) {
+		const struct net_device_ops *ops = dev->netdev_ops;
 		int err;
 		struct ifreq ifr;
-		mm_segment_t	oldfs;
 		struct ip_tunnel_parm p;
 		struct in_device  *in_dev;
 
@@ -166,9 +170,14 @@ struct net_device *ipmr_new_tunnel(struc
 		sprintf(p.name, "dvmrp%d", v->vifc_vifi);
 		ifr.ifr_ifru.ifru_data = (__force void __user *)&p;
 
-		oldfs = get_fs(); set_fs(KERNEL_DS);
-		err = dev->do_ioctl(dev, &ifr, SIOCADDTUNNEL);
-		set_fs(oldfs);
+		if (ops->do_ioctl) {
+			mm_segment_t oldfs = get_fs();
+
+			set_fs(KERNEL_DS);
+			err = ops->do_ioctl(dev, &ifr, SIOCADDTUNNEL);
+			set_fs(oldfs);
+		} else
+			err = -EOPNOTSUPP;
 
 		dev = NULL;
 
--- a/net/ipv6/addrconf.c	2008-11-17 12:37:26.000000000 -0800
+++ b/net/ipv6/addrconf.c	2008-11-17 12:38:39.000000000 -0800
@@ -2031,8 +2031,8 @@ int addrconf_set_dstaddr(struct net *net
 
 #if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
 	if (dev->type == ARPHRD_SIT) {
+		const struct net_device_ops *ops = dev->netdev_ops;
 		struct ifreq ifr;
-		mm_segment_t	oldfs;
 		struct ip_tunnel_parm p;
 
 		err = -EADDRNOTAVAIL;
@@ -2048,9 +2048,14 @@ int addrconf_set_dstaddr(struct net *net
 		p.iph.ttl = 64;
 		ifr.ifr_ifru.ifru_data = (__force void __user *)&p;
 
-		oldfs = get_fs(); set_fs(KERNEL_DS);
-		err = dev->do_ioctl(dev, &ifr, SIOCADDTUNNEL);
-		set_fs(oldfs);
+		if (ops->do_ioctl) {
+			mm_segment_t oldfs = get_fs();
+
+			set_fs(KERNEL_DS);
+			err = ops->do_ioctl(dev, &ifr, SIOCADDTUNNEL);
+			set_fs(oldfs);
+		} else
+			err = -EOPNOTSUPP;
 
 		if (err == 0) {
 			err = -ENOBUFS;

-- 

