From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 6/6] geneve: Remove duplicate dev list
Date: Tue, 11 Aug 2015 22:17:58 -0700
Message-ID: <1439356678-21874-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34246 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933534AbbHLFTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 01:19:04 -0400
Received: by pawu10 with SMTP id u10so6502716paw.1
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 22:19:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Geneve driver maintains list and hash table of Geneve devices.
Following patch removes the duplicate Geneve list and iterate
hash table when it is needed.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/geneve.c | 28 ++++++++++++++++------------
 1 file changed, 16 insertions(+), 12 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index af50061..ad1cb45 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -39,7 +39,6 @@ MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
 /* per-network namespace private data for this module */
 struct geneve_net {
-	struct list_head  geneve_list;
 	struct hlist_head vni_list[VNI_HASH_SIZE];
 	struct list_head	sock_list;
 };
@@ -56,7 +55,6 @@ struct geneve_dev {
 	u8                 ttl;		/* TTL override */
 	u8                 tos;		/* TOS override */
 	struct sockaddr_in remote;	/* IPv4 address for link partner */
-	struct list_head   next;	/* geneve's per namespace list */
 	__be16		   dst_port;
 	bool		   collect_md;
 };
@@ -818,7 +816,6 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 	if (err)
 		return err;
 
-	list_add(&geneve->next, &gn->geneve_list);
 	hlist_add_head_rcu(&geneve->hlist, &gn->vni_list[hash]);
 	return 0;
 }
@@ -864,7 +861,6 @@ static void geneve_dellink(struct net_device *dev, struct list_head *head)
 	if (!hlist_unhashed(&geneve->hlist))
 		hlist_del_rcu(&geneve->hlist);
 
-	list_del(&geneve->next);
 	unregister_netdevice_queue(dev, head);
 }
 
@@ -952,7 +948,6 @@ static __net_init int geneve_init_net(struct net *net)
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	unsigned int h;
 
-	INIT_LIST_HEAD(&gn->geneve_list);
 	INIT_LIST_HEAD(&gn->sock_list);
 
 	for (h = 0; h < VNI_HASH_SIZE; ++h)
@@ -964,8 +959,11 @@ static __net_init int geneve_init_net(struct net *net)
 static void __net_exit geneve_exit_net(struct net *net)
 {
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
-	struct geneve_dev *geneve, *next;
+	struct hlist_head *vni_list_head;
+	struct hlist_node *next;
 	struct net_device *dev, *aux;
+	struct geneve_dev *geneve;
+	unsigned int h;
 	LIST_HEAD(list);
 
 	rtnl_lock();
@@ -975,13 +973,19 @@ static void __net_exit geneve_exit_net(struct net *net)
 		if (dev->rtnl_link_ops == &geneve_link_ops)
 			unregister_netdevice_queue(dev, &list);
 
-	/* now gather any other geneve devices that were created in this ns */
-	list_for_each_entry_safe(geneve, next, &gn->geneve_list, next) {
-		/* If geneve->dev is in the same netns, it was already added
-		 * to the list by the previous loop.
+	for (h = 0; h < VNI_HASH_SIZE; ++h) {
+		vni_list_head = &gn->vni_list[h];
+
+		/* now gather any other geneve devices that were created
+		 * in this ns
 		 */
-		if (!net_eq(dev_net(geneve->dev), net))
-			unregister_netdevice_queue(geneve->dev, &list);
+		hlist_for_each_entry_safe(geneve, next, vni_list_head, hlist) {
+			/* If geneve->dev is in the same netns, it was
+			 * already added to the list by the previous loop.
+			 */
+			if (!net_eq(dev_net(geneve->dev), net))
+				unregister_netdevice_queue(geneve->dev, &list);
+		}
 	}
 
 	/* unregister the devices gathered above */
-- 
1.8.3.1
