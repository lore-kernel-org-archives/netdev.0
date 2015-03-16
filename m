From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net v2] ip6_tunnel: fix error code when tunnel exists
Date: Mon, 16 Mar 2015 15:56:05 +0100
Message-ID: <1426517765-4649-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20150313.123231.1641333637059823788.davem@davemloft.net>
Cc: netdev@vger.kernel.org, me@pierre-cheynier.net,
	eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:33168 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933906AbbCPO4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 10:56:10 -0400
In-Reply-To: <20150313.123231.1641333637059823788.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 2b0bb01b6edb, the kernel returns -ENOBUFS when user tries to add
an existing tunnel with ioctl API:
$ ip -6 tunnel add ip6tnl1 mode ip6ip6 dev eth1
add tunnel "ip6tnl0" failed: No buffer space available

It's confusing, the right error is EEXIST.

This patch also change a bit the code returned:
 - ENOBUFS -> ENOMEM
 - ENOENT -> ENODEV

Fixes: 2b0bb01b6edb ("ip6_tunnel: Return an error when adding an existing tunnel.")
CC: Steffen Klassert <steffen.klassert@secunet.com>
Reported-by: Pierre Cheynier <me@pierre-cheynier.net>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_tunnel.c | 33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 266a264ec212..ddd94eca19b3 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -314,7 +314,7 @@ out:
  *   Create tunnel matching given parameters.
  *
  * Return:
- *   created tunnel or NULL
+ *   created tunnel or error pointer
  **/
 
 static struct ip6_tnl *ip6_tnl_create(struct net *net, struct __ip6_tnl_parm *p)
@@ -322,7 +322,7 @@ static struct ip6_tnl *ip6_tnl_create(struct net *net, struct __ip6_tnl_parm *p)
 	struct net_device *dev;
 	struct ip6_tnl *t;
 	char name[IFNAMSIZ];
-	int err;
+	int err = -ENOMEM;
 
 	if (p->name[0])
 		strlcpy(name, p->name, IFNAMSIZ);
@@ -348,7 +348,7 @@ static struct ip6_tnl *ip6_tnl_create(struct net *net, struct __ip6_tnl_parm *p)
 failed_free:
 	ip6_dev_free(dev);
 failed:
-	return NULL;
+	return ERR_PTR(err);
 }
 
 /**
@@ -362,7 +362,7 @@ failed:
  *   tunnel device is created and registered for use.
  *
  * Return:
- *   matching tunnel or NULL
+ *   matching tunnel or error pointer
  **/
 
 static struct ip6_tnl *ip6_tnl_locate(struct net *net,
@@ -380,13 +380,13 @@ static struct ip6_tnl *ip6_tnl_locate(struct net *net,
 		if (ipv6_addr_equal(local, &t->parms.laddr) &&
 		    ipv6_addr_equal(remote, &t->parms.raddr)) {
 			if (create)
-				return NULL;
+				return ERR_PTR(-EEXIST);
 
 			return t;
 		}
 	}
 	if (!create)
-		return NULL;
+		return ERR_PTR(-ENODEV);
 	return ip6_tnl_create(net, p);
 }
 
@@ -1420,7 +1420,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			}
 			ip6_tnl_parm_from_user(&p1, &p);
 			t = ip6_tnl_locate(net, &p1, 0);
-			if (t == NULL)
+			if (IS_ERR(t))
 				t = netdev_priv(dev);
 		} else {
 			memset(&p, 0, sizeof(p));
@@ -1445,7 +1445,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		ip6_tnl_parm_from_user(&p1, &p);
 		t = ip6_tnl_locate(net, &p1, cmd == SIOCADDTUNNEL);
 		if (cmd == SIOCCHGTUNNEL) {
-			if (t != NULL) {
+			if (!IS_ERR(t)) {
 				if (t->dev != dev) {
 					err = -EEXIST;
 					break;
@@ -1457,14 +1457,15 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			else
 				err = ip6_tnl_update(t, &p1);
 		}
-		if (t) {
+		if (!IS_ERR(t)) {
 			err = 0;
 			ip6_tnl_parm_to_user(&p, &t->parms);
 			if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p)))
 				err = -EFAULT;
 
-		} else
-			err = (cmd == SIOCADDTUNNEL ? -ENOBUFS : -ENOENT);
+		} else {
+			err = PTR_ERR(t);
+		}
 		break;
 	case SIOCDELTUNNEL:
 		err = -EPERM;
@@ -1478,7 +1479,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			err = -ENOENT;
 			ip6_tnl_parm_from_user(&p1, &p);
 			t = ip6_tnl_locate(net, &p1, 0);
-			if (t == NULL)
+			if (IS_ERR(t))
 				break;
 			err = -EPERM;
 			if (t->dev == ip6n->fb_tnl_dev)
@@ -1672,12 +1673,13 @@ static int ip6_tnl_newlink(struct net *src_net, struct net_device *dev,
 			   struct nlattr *tb[], struct nlattr *data[])
 {
 	struct net *net = dev_net(dev);
-	struct ip6_tnl *nt;
+	struct ip6_tnl *nt, *t;
 
 	nt = netdev_priv(dev);
 	ip6_tnl_netlink_parms(data, &nt->parms);
 
-	if (ip6_tnl_locate(net, &nt->parms, 0))
+	t = ip6_tnl_locate(net, &nt->parms, 0);
+	if (!IS_ERR(t))
 		return -EEXIST;
 
 	return ip6_tnl_create2(dev);
@@ -1697,8 +1699,7 @@ static int ip6_tnl_changelink(struct net_device *dev, struct nlattr *tb[],
 	ip6_tnl_netlink_parms(data, &p);
 
 	t = ip6_tnl_locate(net, &p, 0);
-
-	if (t) {
+	if (!IS_ERR(t)) {
 		if (t->dev != dev)
 			return -EEXIST;
 	} else
-- 
2.2.2
