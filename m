From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 07/10] sit: always notify change when params are updated
Date: Wed, 14 Nov 2012 16:14:04 +0100
Message-ID: <1352906047-11604-8-git-send-email-nicolas.dichtel@6wind.com>
References: <1352906047-11604-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34748 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964810Ab2KNPQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 10:16:12 -0500
In-Reply-To: <1352906047-11604-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev_state_change() was called only when end points or link was updated. Now
that all parameters are advertised via netlink, we must advertise any change.

This patch also prepares the support of sit tunnels management via rtnl. The
code which update tunnels will be put in a new function.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/sit.c | 32 +++++++++++++++-----------------
 1 file changed, 15 insertions(+), 17 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index b543c56..b2cfdda 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -997,28 +997,26 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 					break;
 				}
 				t = netdev_priv(dev);
-				ipip6_tunnel_unlink(sitn, t);
-				synchronize_net();
-				t->parms.iph.saddr = p.iph.saddr;
-				t->parms.iph.daddr = p.iph.daddr;
-				memcpy(dev->dev_addr, &p.iph.saddr, 4);
-				memcpy(dev->broadcast, &p.iph.daddr, 4);
-				ipip6_tunnel_link(sitn, t);
-				netdev_state_change(dev);
 			}
+
+			ipip6_tunnel_unlink(sitn, t);
+			synchronize_net();
+			t->parms.iph.saddr = p.iph.saddr;
+			t->parms.iph.daddr = p.iph.daddr;
+			memcpy(dev->dev_addr, &p.iph.saddr, 4);
+			memcpy(dev->broadcast, &p.iph.daddr, 4);
+			ipip6_tunnel_link(sitn, t);
+			t->parms.iph.ttl = p.iph.ttl;
+			t->parms.iph.tos = p.iph.tos;
+			if (t->parms.link != p.link) {
+				t->parms.link = p.link;
+				ipip6_tunnel_bind_dev(dev);
+			}
+			netdev_state_change(dev);
 		}
 
 		if (t) {
 			err = 0;
-			if (cmd == SIOCCHGTUNNEL) {
-				t->parms.iph.ttl = p.iph.ttl;
-				t->parms.iph.tos = p.iph.tos;
-				if (t->parms.link != p.link) {
-					t->parms.link = p.link;
-					ipip6_tunnel_bind_dev(dev);
-					netdev_state_change(dev);
-				}
-			}
 			if (copy_to_user(ifr->ifr_ifru.ifru_data, &t->parms, sizeof(p)))
 				err = -EFAULT;
 		} else
-- 
1.7.12
