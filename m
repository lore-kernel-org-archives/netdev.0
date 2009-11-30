From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 08/20] net: Simplify vlan pernet operations.
Date: Sun, 29 Nov 2009 17:46:05 -0800
Message-ID: <1259545577-7466-8-git-send-email-ebiederm@xmission.com>
References: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:42725 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753066AbZK3Bq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:46:27 -0500
In-Reply-To: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

Take advantage of the new pernet automatic storage management,
and stop using compatibility network namespace functions.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/8021q/vlan.c |   33 +++++++--------------------------
 1 files changed, 7 insertions(+), 26 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 225aa2f..91e9073 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -686,47 +686,28 @@ out:
 
 static int vlan_init_net(struct net *net)
 {
+	struct vlan_net *vn = net_generic(net, vlan_net_id);
 	int err;
-	struct vlan_net *vn;
-
-	err = -ENOMEM;
-	vn = kzalloc(sizeof(struct vlan_net), GFP_KERNEL);
-	if (vn == NULL)
-		goto err_alloc;
-
-	err = net_assign_generic(net, vlan_net_id, vn);
-	if (err < 0)
-		goto err_assign;
 
 	vn->name_type = VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD;
 
 	err = vlan_proc_init(net);
-	if (err < 0)
-		goto err_proc;
 
-	return 0;
-
-err_proc:
-	/* nothing */
-err_assign:
-	kfree(vn);
-err_alloc:
 	return err;
 }
 
 static void vlan_exit_net(struct net *net)
 {
-	struct vlan_net *vn;
-
-	vn = net_generic(net, vlan_net_id);
 	rtnl_kill_links(net, &vlan_link_ops);
+
 	vlan_proc_cleanup(net);
-	kfree(vn);
 }
 
 static struct pernet_operations vlan_net_ops = {
 	.init = vlan_init_net,
 	.exit = vlan_exit_net,
+	.id   = &vlan_net_id,
+	.size = sizeof(struct vlan_net),
 };
 
 static int __init vlan_proto_init(void)
@@ -736,7 +717,7 @@ static int __init vlan_proto_init(void)
 	pr_info("%s v%s %s\n", vlan_fullname, vlan_version, vlan_copyright);
 	pr_info("All bugs added by %s\n", vlan_buggyright);
 
-	err = register_pernet_gen_device(&vlan_net_id, &vlan_net_ops);
+	err = register_pernet_device(&vlan_net_ops);
 	if (err < 0)
 		goto err0;
 
@@ -761,7 +742,7 @@ err4:
 err3:
 	unregister_netdevice_notifier(&vlan_notifier_block);
 err2:
-	unregister_pernet_gen_device(vlan_net_id, &vlan_net_ops);
+	unregister_pernet_device(&vlan_net_ops);
 err0:
 	return err;
 }
@@ -781,7 +762,7 @@ static void __exit vlan_cleanup_module(void)
 	for (i = 0; i < VLAN_GRP_HASH_SIZE; i++)
 		BUG_ON(!hlist_empty(&vlan_group_hash[i]));
 
-	unregister_pernet_gen_device(vlan_net_id, &vlan_net_ops);
+	unregister_pernet_device(&vlan_net_ops);
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 
 	vlan_gvrp_uninit();
-- 
1.6.5.2.143.g8cc62

