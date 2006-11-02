From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH 1/6] IPv6: Fix SIOCCHGTUNNEL bug in IPv6 tunnels
Date: Thu, 02 Nov 2006 13:29:31 +0200
Message-ID: <4549D69B.20903@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070805070405020906090009"
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:44937 "EHLO mail.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1752857AbWKBL3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 06:29:40 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070805070405020906090009
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit


--------------070805070405020906090009
Content-Type: text/plain;
 name="0001-IPv6-Fix-SIOCCHGTUNNEL-bug-in-IPv6-tunnels.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0001-IPv6-Fix-SIOCCHGTUNNEL-bug-in-IPv6-tunnels.txt"

>From f9812eb0349f44f6374910ce38524f0c6f7ce8f4 Mon Sep 17 00:00:00 2001
From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Date: Thu, 2 Nov 2006 12:40:38 +0200
Subject: [PATCH 1/6] IPv6: Fix SIOCCHGTUNNEL bug in IPv6 tunnels

A logic bug in tunnel lookup could result in duplicate tunnels
when changing an existing device.

Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
---
 net/ipv6/ip6_tunnel.c |  111 ++++++++++++++++++++----------------------------
 1 files changed, 46 insertions(+), 65 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 84d7ebd..e61458c 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -215,11 +215,10 @@ ip6ip6_tnl_unlink(struct ip6_tnl *t)
  *   Create tunnel matching given parameters.
  * 
  * Return: 
- *   0 on success
+ *   created tunnel or NULL
  **/
 
-static int
-ip6_tnl_create(struct ip6_tnl_parm *p, struct ip6_tnl **pt)
+static struct ip6_tnl *ip6_tnl_create(struct ip6_tnl_parm *p)
 {
 	struct net_device *dev;
 	struct ip6_tnl *t;
@@ -236,11 +235,11 @@ ip6_tnl_create(struct ip6_tnl_parm *p, s
 				break;
 		}
 		if (i == IP6_TNL_MAX) 
-			return -ENOBUFS;
+			goto failed;
 	}
 	dev = alloc_netdev(sizeof (*t), name, ip6ip6_tnl_dev_setup);
 	if (dev == NULL)
-		return -ENOMEM;
+		goto failed;
 
 	t = netdev_priv(dev);
 	dev->init = ip6ip6_tnl_dev_init;
@@ -248,13 +247,13 @@ ip6_tnl_create(struct ip6_tnl_parm *p, s
 
 	if ((err = register_netdevice(dev)) < 0) {
 		free_netdev(dev);
-		return err;
+		goto failed;
 	}
 	dev_hold(dev);
-
 	ip6ip6_tnl_link(t);
-	*pt = t;
-	return 0;
+	return t;
+failed:
+	return NULL;
 }
 
 /**
@@ -268,32 +267,23 @@ ip6_tnl_create(struct ip6_tnl_parm *p, s
  *   tunnel device is created and registered for use.
  *
  * Return:
- *   0 if tunnel located or created,
- *   -EINVAL if parameters incorrect,
- *   -ENODEV if no matching tunnel available
+ *   matching tunnel or NULL
  **/
 
-static int
-ip6ip6_tnl_locate(struct ip6_tnl_parm *p, struct ip6_tnl **pt, int create)
+static struct ip6_tnl *ip6ip6_tnl_locate(struct ip6_tnl_parm *p, int create)
 {
 	struct in6_addr *remote = &p->raddr;
 	struct in6_addr *local = &p->laddr;
 	struct ip6_tnl *t;
 
-	if (p->proto != IPPROTO_IPV6)
-		return -EINVAL;
-
 	for (t = *ip6ip6_bucket(p); t; t = t->next) {
 		if (ipv6_addr_equal(local, &t->parms.laddr) &&
-		    ipv6_addr_equal(remote, &t->parms.raddr)) {
-			*pt = t;
-			return (create ? -EEXIST : 0);
-		}
+		    ipv6_addr_equal(remote, &t->parms.raddr))
+			return t;
 	}
 	if (!create)
-		return -ENODEV;
-	
-	return ip6_tnl_create(p, pt);
+		return NULL;
+	return ip6_tnl_create(p);
 }
 
 /**
@@ -919,26 +909,20 @@ static int
 ip6ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	int err = 0;
-	int create;
 	struct ip6_tnl_parm p;
 	struct ip6_tnl *t = NULL;
 
 	switch (cmd) {
 	case SIOCGETTUNNEL:
 		if (dev == ip6ip6_fb_tnl_dev) {
-			if (copy_from_user(&p,
-					   ifr->ifr_ifru.ifru_data,
-					   sizeof (p))) {
+			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof (p))) {
 				err = -EFAULT;
 				break;
 			}
-			if ((err = ip6ip6_tnl_locate(&p, &t, 0)) == -ENODEV)
-				t = netdev_priv(dev);
-			else if (err)
-				break;
-		} else
+			t = ip6ip6_tnl_locate(&p, 0);
+		}
+		if (t == NULL)
 			t = netdev_priv(dev);
-
 		memcpy(&p, &t->parms, sizeof (p));
 		if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof (p))) {
 			err = -EFAULT;
@@ -947,35 +931,36 @@ ip6ip6_tnl_ioctl(struct net_device *dev,
 	case SIOCADDTUNNEL:
 	case SIOCCHGTUNNEL:
 		err = -EPERM;
-		create = (cmd == SIOCADDTUNNEL);
 		if (!capable(CAP_NET_ADMIN))
 			break;
-		if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof (p))) {
-			err = -EFAULT;
+		err = -EFAULT;
+		if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof (p)))
 			break;
-		}
-		if (!create && dev != ip6ip6_fb_tnl_dev) {
-			t = netdev_priv(dev);
-		}
-		if (!t && (err = ip6ip6_tnl_locate(&p, &t, create))) {
+		err = -EINVAL;
+		if (p.proto != IPPROTO_IPV6)
 			break;
-		}
-		if (cmd == SIOCCHGTUNNEL) {
-			if (t->dev != dev) {
-				err = -EEXIST;
-				break;
-			}
+		t = ip6ip6_tnl_locate(&p, cmd == SIOCADDTUNNEL);
+		if (dev != ip6ip6_fb_tnl_dev && cmd == SIOCCHGTUNNEL) {
+			if (t != NULL) {
+				if (t->dev != dev) {
+					err = -EEXIST;
+					break;
+				}
+			} else
+				t = netdev_priv(dev);
+
 			ip6ip6_tnl_unlink(t);
 			err = ip6ip6_tnl_change(t, &p);
 			ip6ip6_tnl_link(t);
 			netdev_state_change(dev);
 		}
-		if (copy_to_user(ifr->ifr_ifru.ifru_data,
-				 &t->parms, sizeof (p))) {
-			err = -EFAULT;
-		} else {
+		if (t) {
 			err = 0;
-		}
+			if (copy_to_user(ifr->ifr_ifru.ifru_data, &t->parms, sizeof (p)))
+				err = -EFAULT;
+			
+		} else
+			err = (cmd == SIOCADDTUNNEL ? -ENOBUFS : -ENOENT);
 		break;
 	case SIOCDELTUNNEL:
 		err = -EPERM;
@@ -983,22 +968,18 @@ ip6ip6_tnl_ioctl(struct net_device *dev,
 			break;
 
 		if (dev == ip6ip6_fb_tnl_dev) {
-			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data,
-					   sizeof (p))) {
-				err = -EFAULT;
+			err = -EFAULT;
+			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof (p)))
 				break;
-			}
-			err = ip6ip6_tnl_locate(&p, &t, 0);
-			if (err)
+			err = -ENOENT;
+			if ((t = ip6ip6_tnl_locate(&p, 0)) == NULL)
 				break;
-			if (t == netdev_priv(ip6ip6_fb_tnl_dev)) {
-				err = -EPERM;
+			err = -EPERM;
+			if (t->dev == ip6ip6_fb_tnl_dev)
 				break;
-			}
-		} else {
-			t = netdev_priv(dev);
+			dev = t->dev;
 		}
-		err = unregister_netdevice(t->dev);
+		err = unregister_netdevice(dev);
 		break;
 	default:
 		err = -EINVAL;
-- 
1.4.3.2


--------------070805070405020906090009--
