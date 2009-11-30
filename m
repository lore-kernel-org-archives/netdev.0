From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 17/20] net: Simplify ipip pernet operations.
Date: Sun, 29 Nov 2009 17:46:14 -0800
Message-ID: <1259545577-7466-17-git-send-email-ebiederm@xmission.com>
References: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46466 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272AbZK3Bqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:46:33 -0500
In-Reply-To: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

Take advantage of the new pernet automatic storage management,
and stop using compatibility network namespace functions.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/ipv4/ipip.c |   24 ++++++------------------
 1 files changed, 6 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 7242ffc..eda04fe 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -775,17 +775,8 @@ static void ipip_destroy_tunnels(struct ipip_net *ipn, struct list_head *head)
 
 static int ipip_init_net(struct net *net)
 {
+	struct ipip_net *ipn = net_generic(net, ipip_net_id);
 	int err;
-	struct ipip_net *ipn;
-
-	err = -ENOMEM;
-	ipn = kzalloc(sizeof(struct ipip_net), GFP_KERNEL);
-	if (ipn == NULL)
-		goto err_alloc;
-
-	err = net_assign_generic(net, ipip_net_id, ipn);
-	if (err < 0)
-		goto err_assign;
 
 	ipn->tunnels[0] = ipn->tunnels_wc;
 	ipn->tunnels[1] = ipn->tunnels_l;
@@ -812,29 +803,26 @@ err_reg_dev:
 	free_netdev(ipn->fb_tunnel_dev);
 err_alloc_dev:
 	/* nothing */
-err_assign:
-	kfree(ipn);
-err_alloc:
 	return err;
 }
 
 static void ipip_exit_net(struct net *net)
 {
-	struct ipip_net *ipn;
+	struct ipip_net *ipn = net_generic(net, ipip_net_id);
 	LIST_HEAD(list);
 
-	ipn = net_generic(net, ipip_net_id);
 	rtnl_lock();
 	ipip_destroy_tunnels(ipn, &list);
 	unregister_netdevice_queue(ipn->fb_tunnel_dev, &list);
 	unregister_netdevice_many(&list);
 	rtnl_unlock();
-	kfree(ipn);
 }
 
 static struct pernet_operations ipip_net_ops = {
 	.init = ipip_init_net,
 	.exit = ipip_exit_net,
+	.id   = &ipip_net_id,
+	.size = sizeof(struct ipip_net),
 };
 
 static int __init ipip_init(void)
@@ -848,7 +836,7 @@ static int __init ipip_init(void)
 		return -EAGAIN;
 	}
 
-	err = register_pernet_gen_device(&ipip_net_id, &ipip_net_ops);
+	err = register_pernet_device(&ipip_net_ops);
 	if (err)
 		xfrm4_tunnel_deregister(&ipip_handler, AF_INET);
 
@@ -860,7 +848,7 @@ static void __exit ipip_fini(void)
 	if (xfrm4_tunnel_deregister(&ipip_handler, AF_INET))
 		printk(KERN_INFO "ipip close: can't deregister tunnel\n");
 
-	unregister_pernet_gen_device(ipip_net_id, &ipip_net_ops);
+	unregister_pernet_device(&ipip_net_ops);
 }
 
 module_init(ipip_init);
-- 
1.6.5.2.143.g8cc62

