From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 07/20] net: Simplify the bond drivers pernet operations.
Date: Sun, 29 Nov 2009 17:46:04 -0800
Message-ID: <1259545577-7466-7-git-send-email-ebiederm@xmission.com>
References: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:42719 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753087AbZK3Bq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:46:26 -0500
In-Reply-To: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

Take advantage of the new pernet automatic storage management,
and stop using compatibility network namespace functions.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/net/bonding/bond_main.c |   32 +++++++++-----------------------
 1 files changed, 9 insertions(+), 23 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 726bd75..ac3fe20 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -5103,42 +5103,28 @@ out_netdev:
 
 static int bond_net_init(struct net *net)
 {
-	struct bond_net *bn;
-	int err;
-
-	err = -ENOMEM;
-	bn = kzalloc(sizeof(struct bond_net), GFP_KERNEL);
-	if (bn == NULL)
-		goto out;
+	struct bond_net *bn = net_generic(net, bond_net_id);
 
 	bn->net = net;
 	INIT_LIST_HEAD(&bn->dev_list);
 
-	err = net_assign_generic(net, bond_net_id, bn);
-	if (err)
-		goto out_free;
-
 	bond_create_proc_dir(bn);
-out:
-	return err;
-out_free:
-	kfree(bn);
-	goto out;
+	
+	return 0;
 }
 
 static void bond_net_exit(struct net *net)
 {
-	struct bond_net *bn;
-
-	bn = net_generic(net, bond_net_id);
+	struct bond_net *bn = net_generic(net, bond_net_id);
 
 	bond_destroy_proc_dir(bn);
-	kfree(bn);
 }
 
 static struct pernet_operations bond_net_ops = {
 	.init = bond_net_init,
 	.exit = bond_net_exit,
+	.id   = &bond_net_id,
+	.size = sizeof(struct bond_net),
 };
 
 static int __init bonding_init(void)
@@ -5152,7 +5138,7 @@ static int __init bonding_init(void)
 	if (res)
 		goto out;
 
-	res = register_pernet_gen_subsys(&bond_net_id, &bond_net_ops);
+	res = register_pernet_subsys(&bond_net_ops);
 	if (res)
 		goto out;
 
@@ -5178,7 +5164,7 @@ out:
 err:
 	rtnl_link_unregister(&bond_link_ops);
 err_link:
-	unregister_pernet_gen_subsys(bond_net_id, &bond_net_ops);
+	unregister_pernet_subsys(&bond_net_ops);
 	goto out;
 
 }
@@ -5192,7 +5178,7 @@ static void __exit bonding_exit(void)
 	bond_destroy_sysfs();
 
 	rtnl_link_unregister(&bond_link_ops);
-	unregister_pernet_gen_subsys(bond_net_id, &bond_net_ops);
+	unregister_pernet_subsys(&bond_net_ops);
 }
 
 module_init(bonding_init);
-- 
1.6.5.2.143.g8cc62

