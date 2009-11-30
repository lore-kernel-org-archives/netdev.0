From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 15/20] net: Simplify phonet pernet operations.
Date: Sun, 29 Nov 2009 17:46:12 -0800
Message-ID: <1259545577-7466-15-git-send-email-ebiederm@xmission.com>
References: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:42743 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753206AbZK3Bqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:46:31 -0500
In-Reply-To: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

Take advantage of the new pernet automatic storage management,
and stop using compatibility network namespace functions.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/phonet/pn_dev.c |   16 ++++++----------
 1 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index d87388c..bc4a33b 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -313,19 +313,14 @@ static struct notifier_block phonet_device_notifier = {
 /* Per-namespace Phonet devices handling */
 static int phonet_init_net(struct net *net)
 {
-	struct phonet_net *pnn = kzalloc(sizeof(*pnn), GFP_KERNEL);
-	if (!pnn)
-		return -ENOMEM;
+	struct phonet_net *pnn = net_generic(net, phonet_net_id);
 
-	if (!proc_net_fops_create(net, "phonet", 0, &pn_sock_seq_fops)) {
-		kfree(pnn);
+	if (!proc_net_fops_create(net, "phonet", 0, &pn_sock_seq_fops))
 		return -ENOMEM;
-	}
 
 	INIT_LIST_HEAD(&pnn->pndevs.list);
 	mutex_init(&pnn->pndevs.lock);
 	mutex_init(&pnn->routes.lock);
-	net_assign_generic(net, phonet_net_id, pnn);
 	return 0;
 }
 
@@ -349,18 +344,19 @@ static void phonet_exit_net(struct net *net)
 	rtnl_unlock();
 
 	proc_net_remove(net, "phonet");
-	kfree(pnn);
 }
 
 static struct pernet_operations phonet_net_ops = {
 	.init = phonet_init_net,
 	.exit = phonet_exit_net,
+	.id   = &phonet_net_id,
+	.size = sizeof(struct phonet_net),
 };
 
 /* Initialize Phonet devices list */
 int __init phonet_device_init(void)
 {
-	int err = register_pernet_gen_device(&phonet_net_id, &phonet_net_ops);
+	int err = register_pernet_device(&phonet_net_ops);
 	if (err)
 		return err;
 
@@ -375,7 +371,7 @@ void phonet_device_exit(void)
 {
 	rtnl_unregister_all(PF_PHONET);
 	unregister_netdevice_notifier(&phonet_device_notifier);
-	unregister_pernet_gen_device(phonet_net_id, &phonet_net_ops);
+	unregister_pernet_device(&phonet_net_ops);
 }
 
 int phonet_route_add(struct net_device *dev, u8 daddr)
-- 
1.6.5.2.143.g8cc62

