From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 12/20] net: Simplify ppp_generic pernet operations.
Date: Sun, 29 Nov 2009 17:46:09 -0800
Message-ID: <1259545577-7466-12-git-send-email-ebiederm@xmission.com>
References: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:42731 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753168AbZK3Bqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:46:30 -0500
In-Reply-To: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

Take advantage of the new pernet automatic storage management,
and stop using compatibility network namespace functions.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/net/ppp_generic.c |   30 +++++++-----------------------
 1 files changed, 7 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 0a56a77..f671bb8 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -864,12 +864,7 @@ static const struct file_operations ppp_device_fops = {
 
 static __net_init int ppp_init_net(struct net *net)
 {
-	struct ppp_net *pn;
-	int err;
-
-	pn = kzalloc(sizeof(*pn), GFP_KERNEL);
-	if (!pn)
-		return -ENOMEM;
+	struct ppp_net *pn = net_generic(net, ppp_net_id);
 
 	idr_init(&pn->units_idr);
 	mutex_init(&pn->all_ppp_mutex);
@@ -879,32 +874,21 @@ static __net_init int ppp_init_net(struct net *net)
 
 	spin_lock_init(&pn->all_channels_lock);
 
-	err = net_assign_generic(net, ppp_net_id, pn);
-	if (err) {
-		kfree(pn);
-		return err;
-	}
-
 	return 0;
 }
 
 static __net_exit void ppp_exit_net(struct net *net)
 {
-	struct ppp_net *pn;
+	struct ppp_net *pn = net_generic(net, ppp_net_id);
 
-	pn = net_generic(net, ppp_net_id);
 	idr_destroy(&pn->units_idr);
-	/*
-	 * if someone has cached our net then
-	 * further net_generic call will return NULL
-	 */
-	net_assign_generic(net, ppp_net_id, NULL);
-	kfree(pn);
 }
 
 static struct pernet_operations ppp_net_ops = {
 	.init = ppp_init_net,
 	.exit = ppp_exit_net,
+	.id   = &ppp_net_id,
+	.size = sizeof(struct ppp_net),
 };
 
 #define PPP_MAJOR	108
@@ -917,7 +901,7 @@ static int __init ppp_init(void)
 
 	printk(KERN_INFO "PPP generic driver version " PPP_VERSION "\n");
 
-	err = register_pernet_gen_device(&ppp_net_id, &ppp_net_ops);
+	err = register_pernet_device(&ppp_net_ops);
 	if (err) {
 		printk(KERN_ERR "failed to register PPP pernet device (%d)\n", err);
 		goto out;
@@ -943,7 +927,7 @@ static int __init ppp_init(void)
 out_chrdev:
 	unregister_chrdev(PPP_MAJOR, "ppp");
 out_net:
-	unregister_pernet_gen_device(ppp_net_id, &ppp_net_ops);
+	unregister_pernet_device(&ppp_net_ops);
 out:
 	return err;
 }
@@ -2835,7 +2819,7 @@ static void __exit ppp_cleanup(void)
 	unregister_chrdev(PPP_MAJOR, "ppp");
 	device_destroy(ppp_class, MKDEV(PPP_MAJOR, 0));
 	class_destroy(ppp_class);
-	unregister_pernet_gen_device(ppp_net_id, &ppp_net_ops);
+	unregister_pernet_device(&ppp_net_ops);
 }
 
 /*
-- 
1.6.5.2.143.g8cc62

