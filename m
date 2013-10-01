From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 2/2] ip6tnl: allow to use rtnl ops on fb tunnel
Date: Tue,  1 Oct 2013 18:05:00 +0200
Message-ID: <1380643500-5018-2-git-send-email-nicolas.dichtel@6wind.com>
References: <524AB26B.1070700@6wind.com>
 <1380643500-5018-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	pshelar@nicira.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:47961 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082Ab3JAQF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 12:05:57 -0400
In-Reply-To: <1380643500-5018-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtnl ops where introduced by c075b13098b3 ("ip6tnl: advertise tunnel param via
rtnl"), but I forget to assign rtnl ops to fb tunnels.

Now that it is done, we must remove the explicit call to
unregister_netdevice_queue(), because  the fallback tunnel is added to the queue
in ip6_tnl_destroy_tunnels() when checking rtnl_link_ops of all netdevices (this
is valid since commit 0bd8762824e7 ("ip6tnl: add x-netns support")).

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_tunnel.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 2d8f4829575b..a791552e0422 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1731,8 +1731,6 @@ static void __net_exit ip6_tnl_destroy_tunnels(struct ip6_tnl_net *ip6n)
 		}
 	}
 
-	t = rtnl_dereference(ip6n->tnls_wc[0]);
-	unregister_netdevice_queue(t->dev, &list);
 	unregister_netdevice_many(&list);
 }
 
@@ -1752,6 +1750,7 @@ static int __net_init ip6_tnl_init_net(struct net *net)
 	if (!ip6n->fb_tnl_dev)
 		goto err_alloc_dev;
 	dev_net_set(ip6n->fb_tnl_dev, net);
+	ip6n->fb_tnl_dev->rtnl_link_ops = &ip6_link_ops;
 	/* FB netdevice is special: we have one, and only one per netns.
 	 * Allowing to move it to another netns is clearly unsafe.
 	 */
-- 
1.8.2.1
