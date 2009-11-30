From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 13/20] net: Simplify pppoe pernet operations.
Date: Sun, 29 Nov 2009 17:46:10 -0800
Message-ID: <1259545577-7466-13-git-send-email-ebiederm@xmission.com>
References: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46454 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753226AbZK3Bqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:46:30 -0500
In-Reply-To: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

Take advantage of the new pernet automatic storage management,
and stop using compatibility network namespace functions.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/net/pppoe.c |   38 ++++++++------------------------------
 1 files changed, 8 insertions(+), 30 deletions(-)

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index a1dcba2..a4ed776 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -1139,59 +1139,37 @@ static struct pppox_proto pppoe_proto = {
 
 static __net_init int pppoe_init_net(struct net *net)
 {
-	struct pppoe_net *pn;
+	struct pppoe_net *pn = pppoe_pernet(net);
 	struct proc_dir_entry *pde;
-	int err;
-
-	pn = kzalloc(sizeof(*pn), GFP_KERNEL);
-	if (!pn)
-		return -ENOMEM;
 
 	rwlock_init(&pn->hash_lock);
 
-	err = net_assign_generic(net, pppoe_net_id, pn);
-	if (err)
-		goto out;
-
 	pde = proc_net_fops_create(net, "pppoe", S_IRUGO, &pppoe_seq_fops);
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
 
 static __net_exit void pppoe_exit_net(struct net *net)
 {
-	struct pppoe_net *pn;
-
 	proc_net_remove(net, "pppoe");
-	pn = net_generic(net, pppoe_net_id);
-	/*
-	 * if someone has cached our net then
-	 * further net_generic call will return NULL
-	 */
-	net_assign_generic(net, pppoe_net_id, NULL);
-	kfree(pn);
 }
 
 static struct pernet_operations pppoe_net_ops = {
 	.init = pppoe_init_net,
 	.exit = pppoe_exit_net,
+	.id   = &pppoe_net_id,
+	.size = sizeof(struct pppoe_net),
 };
 
 static int __init pppoe_init(void)
 {
 	int err;
 
-	err = register_pernet_gen_device(&pppoe_net_id, &pppoe_net_ops);
+	err = register_pernet_device(&pppoe_net_ops);
 	if (err)
 		goto out;
 
@@ -1212,7 +1190,7 @@ static int __init pppoe_init(void)
 out_unregister_pppoe_proto:
 	proto_unregister(&pppoe_sk_proto);
 out_unregister_net_ops:
-	unregister_pernet_gen_device(pppoe_net_id, &pppoe_net_ops);
+	unregister_pernet_device(&pppoe_net_ops);
 out:
 	return err;
 }
@@ -1224,7 +1202,7 @@ static void __exit pppoe_exit(void)
 	dev_remove_pack(&pppoes_ptype);
 	unregister_pppox_proto(PX_PROTO_OE);
 	proto_unregister(&pppoe_sk_proto);
-	unregister_pernet_gen_device(pppoe_net_id, &pppoe_net_ops);
+	unregister_pernet_device(&pppoe_net_ops);
 }
 
 module_init(pppoe_init);
-- 
1.6.5.2.143.g8cc62

