From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 19/20] net: Simplify ipip6 aka sit pernet operations.
Date: Sun, 29 Nov 2009 17:46:16 -0800
Message-ID: <1259545577-7466-19-git-send-email-ebiederm@xmission.com>
References: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:42751 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753312AbZK3Bqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:46:34 -0500
In-Reply-To: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

Take advantage of the new pernet automatic storage management,
and stop using compatibility network namespace functions.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/ipv6/sit.c |   25 ++++++-------------------
 1 files changed, 6 insertions(+), 19 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index d9deaa7..976e682 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1164,17 +1164,8 @@ static void sit_destroy_tunnels(struct sit_net *sitn, struct list_head *head)
 
 static int sit_init_net(struct net *net)
 {
+	struct sit_net *sitn = net_generic(net, sit_net_id);
 	int err;
-	struct sit_net *sitn;
-
-	err = -ENOMEM;
-	sitn = kzalloc(sizeof(struct sit_net), GFP_KERNEL);
-	if (sitn == NULL)
-		goto err_alloc;
-
-	err = net_assign_generic(net, sit_net_id, sitn);
-	if (err < 0)
-		goto err_assign;
 
 	sitn->tunnels[0] = sitn->tunnels_wc;
 	sitn->tunnels[1] = sitn->tunnels_l;
@@ -1201,37 +1192,33 @@ err_reg_dev:
 	dev_put(sitn->fb_tunnel_dev);
 	free_netdev(sitn->fb_tunnel_dev);
 err_alloc_dev:
-	/* nothing */
-err_assign:
-	kfree(sitn);
-err_alloc:
 	return err;
 }
 
 static void sit_exit_net(struct net *net)
 {
-	struct sit_net *sitn;
+	struct sit_net *sitn = net_generic(net, sit_net_id);
 	LIST_HEAD(list);
 
-	sitn = net_generic(net, sit_net_id);
 	rtnl_lock();
 	sit_destroy_tunnels(sitn, &list);
 	unregister_netdevice_queue(sitn->fb_tunnel_dev, &list);
 	unregister_netdevice_many(&list);
 	rtnl_unlock();
-	kfree(sitn);
 }
 
 static struct pernet_operations sit_net_ops = {
 	.init = sit_init_net,
 	.exit = sit_exit_net,
+	.id   = &sit_net_id,
+	.size = sizeof(struct sit_net),
 };
 
 static void __exit sit_cleanup(void)
 {
 	xfrm4_tunnel_deregister(&sit_handler, AF_INET6);
 
-	unregister_pernet_gen_device(sit_net_id, &sit_net_ops);
+	unregister_pernet_device(&sit_net_ops);
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 
@@ -1246,7 +1233,7 @@ static int __init sit_init(void)
 		return -EAGAIN;
 	}
 
-	err = register_pernet_gen_device(&sit_net_id, &sit_net_ops);
+	err = register_pernet_device(&sit_net_ops);
 	if (err < 0)
 		xfrm4_tunnel_deregister(&sit_handler, AF_INET6);
 
-- 
1.6.5.2.143.g8cc62

