From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next V3] ip_tunnel: return more precise errno value when adding tunnel fails
Date: Fri, 14 Feb 2014 13:14:39 +0100
Message-ID: <1392380079-3226-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:47849 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751098AbaBNMTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 07:19:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently this always returns ENOBUFS, because the return value of
__ip_tunnel_create is discarded.

A more common failure is a duplicate name (EEXIST).  Propagate the real
error code so userspace can display a more meaningful error message.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
Changes since v2:
 Fix subject prefix (s/gre/ip_tunnel/)
Changes since v1:
  Use ERR_CAST() (suggested by Ben Hutchings)

 net/ipv4/ip_tunnel.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 50228be..f137c5d 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -443,7 +443,7 @@ static struct ip_tunnel *ip_tunnel_create(struct net *net,
 	fbt = netdev_priv(itn->fb_tunnel_dev);
 	dev = __ip_tunnel_create(net, itn->fb_tunnel_dev->rtnl_link_ops, parms);
 	if (IS_ERR(dev))
-		return NULL;
+		return ERR_CAST(dev);
 
 	dev->mtu = ip_tunnel_bind_dev(dev);
 
@@ -796,9 +796,13 @@ int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
 
 		t = ip_tunnel_find(itn, p, itn->fb_tunnel_dev->type);
 
-		if (!t && (cmd == SIOCADDTUNNEL))
+		if (!t && (cmd == SIOCADDTUNNEL)) {
 			t = ip_tunnel_create(net, itn, p);
-
+			if (IS_ERR(t)) {
+				err = PTR_ERR(t);
+				break;
+			}
+		}
 		if (dev != itn->fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
 			if (t != NULL) {
 				if (t->dev != dev) {
@@ -825,8 +829,9 @@ int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
 		if (t) {
 			err = 0;
 			ip_tunnel_update(itn, t, dev, p, true);
-		} else
-			err = (cmd == SIOCADDTUNNEL ? -ENOBUFS : -ENOENT);
+		} else {
+			err = -ENOENT;
+		}
 		break;
 
 	case SIOCDELTUNNEL:
-- 
1.8.1.5
