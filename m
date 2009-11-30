From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 14/20] net: Simplify pppol2tp pernet operations.
Date: Sun, 29 Nov 2009 17:46:11 -0800
Message-ID: <1259545577-7466-14-git-send-email-ebiederm@xmission.com>
References: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:42737 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753253AbZK3Bqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:46:31 -0500
In-Reply-To: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

Take advantage of the new pernet automatic storage management,
and stop using compatibility network namespace functions.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/net/pppol2tp.c |   36 +++++++-----------------------------
 1 files changed, 7 insertions(+), 29 deletions(-)

diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index c58b50f..9fbb2eb 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -2605,53 +2605,31 @@ static struct pppox_proto pppol2tp_proto = {
 
 static __net_init int pppol2tp_init_net(struct net *net)
 {
-	struct pppol2tp_net *pn;
+	struct pppol2tp_net *pn = pppol2tp_pernet(net);
 	struct proc_dir_entry *pde;
-	int err;
-
-	pn = kzalloc(sizeof(*pn), GFP_KERNEL);
-	if (!pn)
-		return -ENOMEM;
 
 	INIT_LIST_HEAD(&pn->pppol2tp_tunnel_list);
 	rwlock_init(&pn->pppol2tp_tunnel_list_lock);
 
-	err = net_assign_generic(net, pppol2tp_net_id, pn);
-	if (err)
-		goto out;
-
 	pde = proc_net_fops_create(net, "pppol2tp", S_IRUGO, &pppol2tp_proc_fops);
 #ifdef CONFIG_PROC_FS
-	if (!pde) {
-		err = -ENOMEM;
-		goto out;
-	}
+	if (!pde)
+		return -ENOMEM;
 #endif
 
 	return 0;
-
-out:
-	kfree(pn);
-	return err;
 }
 
 static __net_exit void pppol2tp_exit_net(struct net *net)
 {
-	struct pppoe_net *pn;
-
 	proc_net_remove(net, "pppol2tp");
-	pn = net_generic(net, pppol2tp_net_id);
-	/*
-	 * if someone has cached our net then
-	 * further net_generic call will return NULL
-	 */
-	net_assign_generic(net, pppol2tp_net_id, NULL);
-	kfree(pn);
 }
 
 static struct pernet_operations pppol2tp_net_ops = {
 	.init = pppol2tp_init_net,
 	.exit = pppol2tp_exit_net,
+	.id   = &pppol2tp_net_id,
+	.size = sizeof(struct pppol2tp_net),
 };
 
 static int __init pppol2tp_init(void)
@@ -2665,7 +2643,7 @@ static int __init pppol2tp_init(void)
 	if (err)
 		goto out_unregister_pppol2tp_proto;
 
-	err = register_pernet_gen_device(&pppol2tp_net_id, &pppol2tp_net_ops);
+	err = register_pernet_device(&pppol2tp_net_ops);
 	if (err)
 		goto out_unregister_pppox_proto;
 
@@ -2684,7 +2662,7 @@ out_unregister_pppol2tp_proto:
 static void __exit pppol2tp_exit(void)
 {
 	unregister_pppox_proto(PX_PROTO_OL2TP);
-	unregister_pernet_gen_device(pppol2tp_net_id, &pppol2tp_net_ops);
+	unregister_pernet_device(&pppol2tp_net_ops);
 	proto_unregister(&pppol2tp_sk_proto);
 }
 
-- 
1.6.5.2.143.g8cc62

