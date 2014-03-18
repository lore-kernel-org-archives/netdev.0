From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: [PATCH] net : Remove unnecessary assignments
Date: Tue, 18 Mar 2014 21:40:56 +0530
Message-ID: <53287010.8000703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	kumaran.4353@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:59295 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753791AbaCRQMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 12:12:08 -0400
Received: by mail-pa0-f52.google.com with SMTP id rd3so7549281pab.39
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 09:12:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unnecessary assignments

Signed-off-by: Balakumaran Kannan <kumaran.4353@gmail.com>
---
Some unnecessary assignments has been removed from devinet_ioctl function.
The 'ret' variable is set in multiple places, but used only based on if
conditions. So keeping the assignment inside if will be a better.

Patch is prepared for Linux-3.14-rc7 kernel.
---
--- net/ipv4/devinet.c.orig	2014-03-19 02:15:33.000000000 +0530
+++ net/ipv4/devinet.c	2014-03-19 03:02:16.000000000 +0530
@@ -886,15 +886,17 @@ int devinet_ioctl(struct net *net, unsig
 	struct in_ifaddr *ifa = NULL;
 	struct net_device *dev;
 	char *colon;
-	int ret = -EFAULT;
+	int ret;
 	int tryaddrmatch = 0;
 
 	/*
 	 *	Fetch the caller's info block into kernel space
 	 */
 
-	if (copy_from_user(&ifr, arg, sizeof(struct ifreq)))
+	if (copy_from_user(&ifr, arg, sizeof(struct ifreq))) {
+		ret = -EFAULT;
 		goto out;
+	}
 	ifr.ifr_name[IFNAMSIZ - 1] = 0;
 
 	/* save original address for comparison */
@@ -921,20 +923,23 @@ int devinet_ioctl(struct net *net, unsig
 		break;
 
 	case SIOCSIFFLAGS:
-		ret = -EPERM;
-		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN)) {
+			ret = -EPERM;
 			goto out;
+		}
 		break;
 	case SIOCSIFADDR:	/* Set interface address (and family) */
 	case SIOCSIFBRDADDR:	/* Set the broadcast address */
 	case SIOCSIFDSTADDR:	/* Set the destination address */
 	case SIOCSIFNETMASK: 	/* Set the netmask for the interface */
-		ret = -EPERM;
-		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN)) {
+			ret = -EPERM;
 			goto out;
-		ret = -EINVAL;
-		if (sin->sin_family != AF_INET)
+		}
+		if (sin->sin_family != AF_INET) {
+			ret = -EINVAL;
 			goto out;
+		}
 		break;
 	default:
 		ret = -EINVAL;
@@ -943,10 +948,11 @@ int devinet_ioctl(struct net *net, unsig
 
 	rtnl_lock();
 
-	ret = -ENODEV;
 	dev = __dev_get_by_name(net, ifr.ifr_name);
-	if (!dev)
+	if (!dev) {
+		ret = -ENODEV;
 		goto done;
+	}
 
 	if (colon)
 		*colon = ':';
@@ -979,9 +985,10 @@ int devinet_ioctl(struct net *net, unsig
 		}
 	}
 
-	ret = -EADDRNOTAVAIL;
-	if (!ifa && cmd != SIOCSIFADDR && cmd != SIOCSIFFLAGS)
+	if (!ifa && cmd != SIOCSIFADDR && cmd != SIOCSIFFLAGS) {
+		ret = -EADDRNOTAVAIL;
 		goto done;
+	}
 
 	switch (cmd) {
 	case SIOCGIFADDR:	/* Get interface address */
@@ -1002,9 +1009,10 @@ int devinet_ioctl(struct net *net, unsig
 
 	case SIOCSIFFLAGS:
 		if (colon) {
-			ret = -EADDRNOTAVAIL;
-			if (!ifa)
+			if (!ifa) {
+				ret = -EADDRNOTAVAIL;
 				break;
+			}
 			ret = 0;
 			if (!(ifr.ifr_flags & IFF_UP))
 				inet_del_ifa(in_dev, ifap, 1);
@@ -1014,24 +1022,27 @@ int devinet_ioctl(struct net *net, unsig
 		break;
 
 	case SIOCSIFADDR:	/* Set interface address (and family) */
-		ret = -EINVAL;
-		if (inet_abc_len(sin->sin_addr.s_addr) < 0)
+		if (inet_abc_len(sin->sin_addr.s_addr) < 0) {
+			ret = -EINVAL;
 			break;
+		}
 
 		if (!ifa) {
-			ret = -ENOBUFS;
 			ifa = inet_alloc_ifa();
-			if (!ifa)
+			if (!ifa) {
+				ret = -ENOBUFS;
 				break;
+			}
 			INIT_HLIST_NODE(&ifa->hash);
 			if (colon)
 				memcpy(ifa->ifa_label, ifr.ifr_name, IFNAMSIZ);
 			else
 				memcpy(ifa->ifa_label, dev->name, IFNAMSIZ);
 		} else {
-			ret = 0;
-			if (ifa->ifa_local == sin->sin_addr.s_addr)
+			if (ifa->ifa_local == sin->sin_addr.s_addr) {
+				ret = 0;
 				break;
+			}
 			inet_del_ifa(in_dev, ifap, 0);
 			ifa->ifa_broadcast = 0;
 			ifa->ifa_scope = 0;
@@ -1064,12 +1075,14 @@ int devinet_ioctl(struct net *net, unsig
 		break;
 
 	case SIOCSIFDSTADDR:	/* Set the destination address */
-		ret = 0;
-		if (ifa->ifa_address == sin->sin_addr.s_addr)
+		if (ifa->ifa_address == sin->sin_addr.s_addr) {
+			ret = 0;
 			break;
-		ret = -EINVAL;
-		if (inet_abc_len(sin->sin_addr.s_addr) < 0)
+		}
+		if (inet_abc_len(sin->sin_addr.s_addr) < 0) {
+			ret = -EINVAL;
 			break;
+		}
 		ret = 0;
 		inet_del_ifa(in_dev, ifap, 0);
 		ifa->ifa_address = sin->sin_addr.s_addr;
@@ -1081,9 +1094,10 @@ int devinet_ioctl(struct net *net, unsig
 		/*
 		 *	The mask we set must be legal.
 		 */
-		ret = -EINVAL;
-		if (bad_mask(sin->sin_addr.s_addr, 0))
+		if (bad_mask(sin->sin_addr.s_addr, 0)) {
+			ret = -EINVAL;
 			break;
+		}
 		ret = 0;
 		if (ifa->ifa_mask != sin->sin_addr.s_addr) {
 			__be32 old_mask = ifa->ifa_mask;
@@ -1107,6 +1121,8 @@ int devinet_ioctl(struct net *net, unsig
 			inet_insert_ifa(ifa);
 		}
 		break;
+	default:
+		ret = -EADDRNOTAVAIL;
 	}
 done:
 	rtnl_unlock();
