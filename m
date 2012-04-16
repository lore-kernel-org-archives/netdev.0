From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] netns: do not leak net_generic data on failed init
Date: Mon, 16 Apr 2012 17:43:15 +0300
Message-ID: <1334587395-6033-1-git-send-email-ja@ssi.bg>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:46587 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753920Ab2DPOmX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2012 10:42:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	ops_init should free the net_generic data on
init failure and __register_pernet_operations should not
call ops_free when NET_NS is not enabled.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/core/net_namespace.c |   33 ++++++++++++++++++---------------
 1 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 0e950fd..31a5ae5 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -83,21 +83,29 @@ assign:
 
 static int ops_init(const struct pernet_operations *ops, struct net *net)
 {
-	int err;
+	int err = -ENOMEM;
+	void *data = NULL;
+
 	if (ops->id && ops->size) {
-		void *data = kzalloc(ops->size, GFP_KERNEL);
+		data = kzalloc(ops->size, GFP_KERNEL);
 		if (!data)
-			return -ENOMEM;
+			goto out;
 
 		err = net_assign_generic(net, *ops->id, data);
-		if (err) {
-			kfree(data);
-			return err;
-		}
+		if (err)
+			goto cleanup;
 	}
+	err = 0;
 	if (ops->init)
-		return ops->init(net);
-	return 0;
+		err = ops->init(net);
+	if (!err)
+		return 0;
+
+cleanup:
+	kfree(data);
+
+out:
+	return err;
 }
 
 static void ops_free(const struct pernet_operations *ops, struct net *net)
@@ -448,12 +456,7 @@ static void __unregister_pernet_operations(struct pernet_operations *ops)
 static int __register_pernet_operations(struct list_head *list,
 					struct pernet_operations *ops)
 {
-	int err = 0;
-	err = ops_init(ops, &init_net);
-	if (err)
-		ops_free(ops, &init_net);
-	return err;
-	
+	return ops_init(ops, &init_net);
 }
 
 static void __unregister_pernet_operations(struct pernet_operations *ops)
-- 
1.7.3.4
