From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 09/20] net: Simplify af_key pernet operations.
Date: Sun, 29 Nov 2009 17:46:06 -0800
Message-ID: <1259545577-7466-9-git-send-email-ebiederm@xmission.com>
References: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46436 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753168AbZK3Bq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:46:27 -0500
In-Reply-To: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

Take advantage of the new pernet automatic storage management,
and stop using compatibility network namespace functions.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/key/af_key.c |   25 ++++++-------------------
 1 files changed, 6 insertions(+), 19 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 478c8b3..84209fb 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3765,28 +3765,14 @@ static struct xfrm_mgr pfkeyv2_mgr =
 
 static int __net_init pfkey_net_init(struct net *net)
 {
-	struct netns_pfkey *net_pfkey;
+	struct netns_pfkey *net_pfkey = net_generic(net, pfkey_net_id);
 	int rv;
 
-	net_pfkey = kmalloc(sizeof(struct netns_pfkey), GFP_KERNEL);
-	if (!net_pfkey) {
-		rv = -ENOMEM;
-		goto out_kmalloc;
-	}
 	INIT_HLIST_HEAD(&net_pfkey->table);
 	atomic_set(&net_pfkey->socks_nr, 0);
-	rv = net_assign_generic(net, pfkey_net_id, net_pfkey);
-	if (rv < 0)
-		goto out_assign;
+
 	rv = pfkey_init_proc(net);
-	if (rv < 0)
-		goto out_proc;
-	return 0;
 
-out_proc:
-out_assign:
-	kfree(net_pfkey);
-out_kmalloc:
 	return rv;
 }
 
@@ -3796,17 +3782,18 @@ static void __net_exit pfkey_net_exit(struct net *net)
 
 	pfkey_exit_proc(net);
 	BUG_ON(!hlist_empty(&net_pfkey->table));
-	kfree(net_pfkey);
 }
 
 static struct pernet_operations pfkey_net_ops = {
 	.init = pfkey_net_init,
 	.exit = pfkey_net_exit,
+	.id   = &pfkey_net_id,
+	.size = sizeof(struct netns_pfkey),
 };
 
 static void __exit ipsec_pfkey_exit(void)
 {
-	unregister_pernet_gen_subsys(pfkey_net_id, &pfkey_net_ops);
+	unregister_pernet_subsys(&pfkey_net_ops);
 	xfrm_unregister_km(&pfkeyv2_mgr);
 	sock_unregister(PF_KEY);
 	proto_unregister(&key_proto);
@@ -3825,7 +3812,7 @@ static int __init ipsec_pfkey_init(void)
 	err = xfrm_register_km(&pfkeyv2_mgr);
 	if (err != 0)
 		goto out_sock_unregister;
-	err = register_pernet_gen_subsys(&pfkey_net_id, &pfkey_net_ops);
+	err = register_pernet_subsys(&pfkey_net_ops);
 	if (err != 0)
 		goto out_xfrm_unregister_km;
 out:
-- 
1.6.5.2.143.g8cc62

