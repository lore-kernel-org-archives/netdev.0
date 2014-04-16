From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 1/3] ip_tunnel: use the right netns in ioctl handler
Date: Wed, 16 Apr 2014 11:19:32 +0200
Message-ID: <1397639974-22693-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:43395 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752315AbaDPJUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 05:20:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because the netdevice may be in another netns than the i/o netns, we should
use the i/o netns instead of dev_net(dev).

The variable 'tunnel' was used only to get 'itn', hence to simplify code I
remove it and use 't' instead.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/ip_tunnel.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 484d0ce27ef7..fa5b7519765f 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -722,19 +722,18 @@ static void ip_tunnel_update(struct ip_tunnel_net *itn,
 int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
 {
 	int err = 0;
-	struct ip_tunnel *t;
-	struct net *net = dev_net(dev);
-	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct ip_tunnel_net *itn = net_generic(net, tunnel->ip_tnl_net_id);
+	struct ip_tunnel *t = netdev_priv(dev);
+	struct net *net = t->net;
+	struct ip_tunnel_net *itn = net_generic(net, t->ip_tnl_net_id);
 
 	BUG_ON(!itn->fb_tunnel_dev);
 	switch (cmd) {
 	case SIOCGETTUNNEL:
-		t = NULL;
-		if (dev == itn->fb_tunnel_dev)
+		if (dev == itn->fb_tunnel_dev) {
 			t = ip_tunnel_find(itn, p, itn->fb_tunnel_dev->type);
-		if (t == NULL)
-			t = netdev_priv(dev);
+			if (t == NULL)
+				t = netdev_priv(dev);
+		}
 		memcpy(p, &t->parms, sizeof(*p));
 		break;
 
-- 
1.9.0
