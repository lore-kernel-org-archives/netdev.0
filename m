From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] ip6_tunnel: fix error code when tunnel exists
Date: Fri, 13 Mar 2015 13:58:57 +0100
Message-ID: <1426251537-31870-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, me@pierre-cheynier.net,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:58175 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752827AbbCMM73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 08:59:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 2b0bb01b6edb, the kernel returns -ENOBUFS when user tries to add
an existing tunnel with ioctl API:
$ ip -6 tunnel add ip6tnl1 mode ip6ip6 dev eth1
add tunnel "ip6tnl0" failed: No buffer space available

It's confusing, the right error is EEXIST.

Fixes: 2b0bb01b6edb ("ip6_tunnel: Return an error when adding an existing tunnel.")
CC: Steffen Klassert <steffen.klassert@secunet.com>
Reported-by: Pierre Cheynier <me@pierre-cheynier.net>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_tunnel.c | 22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 266a264ec212..7ba5608d64c5 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -380,7 +380,7 @@ static struct ip6_tnl *ip6_tnl_locate(struct net *net,
 		if (ipv6_addr_equal(local, &t->parms.laddr) &&
 		    ipv6_addr_equal(remote, &t->parms.raddr)) {
 			if (create)
-				return NULL;
+				return ERR_PTR(-EEXIST);
 
 			return t;
 		}
@@ -1420,7 +1420,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			}
 			ip6_tnl_parm_from_user(&p1, &p);
 			t = ip6_tnl_locate(net, &p1, 0);
-			if (t == NULL)
+			if (IS_ERR_OR_NULL(t))
 				t = netdev_priv(dev);
 		} else {
 			memset(&p, 0, sizeof(p));
@@ -1445,7 +1445,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		ip6_tnl_parm_from_user(&p1, &p);
 		t = ip6_tnl_locate(net, &p1, cmd == SIOCADDTUNNEL);
 		if (cmd == SIOCCHGTUNNEL) {
-			if (t != NULL) {
+			if (!IS_ERR_OR_NULL(t)) {
 				if (t->dev != dev) {
 					err = -EEXIST;
 					break;
@@ -1457,14 +1457,17 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			else
 				err = ip6_tnl_update(t, &p1);
 		}
-		if (t) {
+		if (!IS_ERR_OR_NULL(t)) {
 			err = 0;
 			ip6_tnl_parm_to_user(&p, &t->parms);
 			if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p)))
 				err = -EFAULT;
 
-		} else
+		} else if (IS_ERR(t)) {
+			err = PTR_ERR(t);
+		} else {
 			err = (cmd == SIOCADDTUNNEL ? -ENOBUFS : -ENOENT);
+		}
 		break;
 	case SIOCDELTUNNEL:
 		err = -EPERM;
@@ -1478,7 +1481,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			err = -ENOENT;
 			ip6_tnl_parm_from_user(&p1, &p);
 			t = ip6_tnl_locate(net, &p1, 0);
-			if (t == NULL)
+			if (IS_ERR_OR_NULL(t))
 				break;
 			err = -EPERM;
 			if (t->dev == ip6n->fb_tnl_dev)
@@ -1672,12 +1675,13 @@ static int ip6_tnl_newlink(struct net *src_net, struct net_device *dev,
 			   struct nlattr *tb[], struct nlattr *data[])
 {
 	struct net *net = dev_net(dev);
-	struct ip6_tnl *nt;
+	struct ip6_tnl *nt, *t;
 
 	nt = netdev_priv(dev);
 	ip6_tnl_netlink_parms(data, &nt->parms);
 
-	if (ip6_tnl_locate(net, &nt->parms, 0))
+	t = ip6_tnl_locate(net, &nt->parms, 0);
+	if (!IS_ERR_OR_NULL(t))
 		return -EEXIST;
 
 	return ip6_tnl_create2(dev);
@@ -1698,7 +1702,7 @@ static int ip6_tnl_changelink(struct net_device *dev, struct nlattr *tb[],
 
 	t = ip6_tnl_locate(net, &p, 0);
 
-	if (t) {
+	if (!IS_ERR_OR_NULL(t)) {
 		if (t->dev != dev)
 			return -EEXIST;
 	} else
-- 
2.2.2
