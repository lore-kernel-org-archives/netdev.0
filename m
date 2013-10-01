From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 1/2] sit: allow to use rtnl ops on fb tunnel
Date: Tue,  1 Oct 2013 18:04:59 +0200
Message-ID: <1380643500-5018-1-git-send-email-nicolas.dichtel@6wind.com>
References: <524AB26B.1070700@6wind.com>
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	pshelar@nicira.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:47960 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964Ab3JAQF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 12:05:57 -0400
In-Reply-To: <524AB26B.1070700@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtnl ops where introduced by ba3e3f50a0e5 ("sit: advertise tunnel param via
rtnl"), but I forget to assign rtnl ops to fb tunnels.

Now that it is done, we must remove the explicit call to
unregister_netdevice_queue(), because  the fallback tunnel is added to the queue
in sit_destroy_tunnels() when checking rtnl_link_ops of all netdevices (this
is valid since commit 5e6700b3bf98 ("sit: add support of x-netns")).

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/sit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index afd5605aea7c..19269453a8ea 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1666,6 +1666,7 @@ static int __net_init sit_init_net(struct net *net)
 		goto err_alloc_dev;
 	}
 	dev_net_set(sitn->fb_tunnel_dev, net);
+	sitn->fb_tunnel_dev->rtnl_link_ops = &sit_link_ops;
 	/* FB netdevice is special: we have one, and only one per netns.
 	 * Allowing to move it to another netns is clearly unsafe.
 	 */
@@ -1700,7 +1701,6 @@ static void __net_exit sit_exit_net(struct net *net)
 
 	rtnl_lock();
 	sit_destroy_tunnels(sitn, &list);
-	unregister_netdevice_queue(sitn->fb_tunnel_dev, &list);
 	unregister_netdevice_many(&list);
 	rtnl_unlock();
 }
-- 
1.8.2.1
