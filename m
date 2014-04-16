From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 3/3] ip6_tunnel: use the right netns in ioctl handler
Date: Wed, 16 Apr 2014 11:19:34 +0200
Message-ID: <1397639974-22693-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1397639974-22693-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:43401 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755015AbaDPJUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 05:20:05 -0400
In-Reply-To: <1397639974-22693-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because the netdevice may be in another netns than the i/o netns, we should
use the i/o netns instead of dev_net(dev).

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_tunnel.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index e1df691d78be..b05b609f69d1 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1340,8 +1340,8 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	int err = 0;
 	struct ip6_tnl_parm p;
 	struct __ip6_tnl_parm p1;
-	struct ip6_tnl *t = NULL;
-	struct net *net = dev_net(dev);
+	struct ip6_tnl *t = netdev_priv(dev);
+	struct net *net = t->net;
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 
 	switch (cmd) {
@@ -1353,11 +1353,11 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			}
 			ip6_tnl_parm_from_user(&p1, &p);
 			t = ip6_tnl_locate(net, &p1, 0);
+			if (t == NULL)
+				t = netdev_priv(dev);
 		} else {
 			memset(&p, 0, sizeof(p));
 		}
-		if (t == NULL)
-			t = netdev_priv(dev);
 		ip6_tnl_parm_to_user(&p, &t->parms);
 		if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof (p))) {
 			err = -EFAULT;
-- 
1.9.0
