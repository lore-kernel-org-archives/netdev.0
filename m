From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 2/3] sit: use the right netns in ioctl handler
Date: Wed, 16 Apr 2014 11:19:33 +0200
Message-ID: <1397639974-22693-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1397639974-22693-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:43398 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754892AbaDPJUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 05:20:03 -0400
In-Reply-To: <1397639974-22693-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because the netdevice may be in another netns than the i/o netns, we should
use the i/o netns instead of dev_net(dev).

Note that netdev_priv(dev) cannot bu NULL, hence we can remove these useless
checks.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/sit.c | 17 ++++-------------
 1 file changed, 4 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 8da8268d65f8..e5a453ca302e 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1127,8 +1127,8 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 	int err = 0;
 	struct ip_tunnel_parm p;
 	struct ip_tunnel_prl prl;
-	struct ip_tunnel *t;
-	struct net *net = dev_net(dev);
+	struct ip_tunnel *t = netdev_priv(dev);
+	struct net *net = t->net;
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 #ifdef CONFIG_IPV6_SIT_6RD
 	struct ip_tunnel_6rd ip6rd;
@@ -1139,16 +1139,15 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 #ifdef CONFIG_IPV6_SIT_6RD
 	case SIOCGET6RD:
 #endif
-		t = NULL;
 		if (dev == sitn->fb_tunnel_dev) {
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p))) {
 				err = -EFAULT;
 				break;
 			}
 			t = ipip6_tunnel_locate(net, &p, 0);
+			if (t == NULL)
+				t = netdev_priv(dev);
 		}
-		if (t == NULL)
-			t = netdev_priv(dev);
 
 		err = -EFAULT;
 		if (cmd == SIOCGETTUNNEL) {
@@ -1244,9 +1243,6 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 		err = -EINVAL;
 		if (dev == sitn->fb_tunnel_dev)
 			goto done;
-		err = -ENOENT;
-		if (!(t = netdev_priv(dev)))
-			goto done;
 		err = ipip6_tunnel_get_prl(t, ifr->ifr_ifru.ifru_data);
 		break;
 
@@ -1262,9 +1258,6 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 		err = -EFAULT;
 		if (copy_from_user(&prl, ifr->ifr_ifru.ifru_data, sizeof(prl)))
 			goto done;
-		err = -ENOENT;
-		if (!(t = netdev_priv(dev)))
-			goto done;
 
 		switch (cmd) {
 		case SIOCDELPRL:
@@ -1292,8 +1285,6 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 				   sizeof(ip6rd)))
 			goto done;
 
-		t = netdev_priv(dev);
-
 		if (cmd != SIOCDEL6RD) {
 			err = ipip6_tunnel_update_6rd(t, &ip6rd);
 			if (err < 0)
-- 
1.9.0
