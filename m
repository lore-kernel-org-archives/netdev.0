From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 18/20] net: Simplify ip6_tunnel pernet operations.
Date: Sun, 29 Nov 2009 17:46:15 -0800
Message-ID: <1259545577-7466-18-git-send-email-ebiederm@xmission.com>
References: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46472 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753294AbZK3Bqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:46:33 -0500
In-Reply-To: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

Take advantage of the new pernet automatic storage management,
and stop using compatibility network namespace functions.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/ipv6/ip6_tunnel.c |   25 ++++++-------------------
 1 files changed, 6 insertions(+), 19 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index e5c0f6b..d453d07 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1409,17 +1409,8 @@ static void ip6_tnl_destroy_tunnels(struct ip6_tnl_net *ip6n)
 
 static int ip6_tnl_init_net(struct net *net)
 {
+	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 	int err;
-	struct ip6_tnl_net *ip6n;
-
-	err = -ENOMEM;
-	ip6n = kzalloc(sizeof(struct ip6_tnl_net), GFP_KERNEL);
-	if (ip6n == NULL)
-		goto err_alloc;
-
-	err = net_assign_generic(net, ip6_tnl_net_id, ip6n);
-	if (err < 0)
-		goto err_assign;
 
 	ip6n->tnls[0] = ip6n->tnls_wc;
 	ip6n->tnls[1] = ip6n->tnls_r_l;
@@ -1442,27 +1433,23 @@ static int ip6_tnl_init_net(struct net *net)
 err_register:
 	free_netdev(ip6n->fb_tnl_dev);
 err_alloc_dev:
-	/* nothing */
-err_assign:
-	kfree(ip6n);
-err_alloc:
 	return err;
 }
 
 static void ip6_tnl_exit_net(struct net *net)
 {
-	struct ip6_tnl_net *ip6n;
+	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 
-	ip6n = net_generic(net, ip6_tnl_net_id);
 	rtnl_lock();
 	ip6_tnl_destroy_tunnels(ip6n);
 	rtnl_unlock();
-	kfree(ip6n);
 }
 
 static struct pernet_operations ip6_tnl_net_ops = {
 	.init = ip6_tnl_init_net,
 	.exit = ip6_tnl_exit_net,
+	.id   = &ip6_tnl_net_id,
+	.size = sizeof(struct ip6_tnl_net),
 };
 
 /**
@@ -1487,7 +1474,7 @@ static int __init ip6_tunnel_init(void)
 		goto unreg_ip4ip6;
 	}
 
-	err = register_pernet_gen_device(&ip6_tnl_net_id, &ip6_tnl_net_ops);
+	err = register_pernet_device(&ip6_tnl_net_ops);
 	if (err < 0)
 		goto err_pernet;
 	return 0;
@@ -1511,7 +1498,7 @@ static void __exit ip6_tunnel_cleanup(void)
 	if (xfrm6_tunnel_deregister(&ip6ip6_handler, AF_INET6))
 		printk(KERN_INFO "ip6_tunnel close: can't deregister ip6ip6\n");
 
-	unregister_pernet_gen_device(ip6_tnl_net_id, &ip6_tnl_net_ops);
+	unregister_pernet_device(&ip6_tnl_net_ops);
 }
 
 module_init(ip6_tunnel_init);
-- 
1.6.5.2.143.g8cc62

