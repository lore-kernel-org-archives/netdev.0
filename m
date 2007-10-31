From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 1/5][NETNS] Make the init/exit hooks checks outside the loop
Date: Wed, 31 Oct 2007 22:23:35 +0300
Message-ID: <4728D637.5030106@openvz.org>
References: <4728D54F.2080208@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:44388 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752357AbXJaSVS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 14:21:18 -0400
In-Reply-To: <4728D54F.2080208@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the new pernet something (subsys, device or operations) is
being registered, the init callback is to be called for each
namespace, that currently exitst in the system. During the
unregister, the same is to be done with the exit callback.

However, not every pernet something has both calls, but the
check for the appropriate pointer to be not NULL is performed
inside the for_each_net() loop.

This is (at least) strange, so tune this.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 662e6ea..4e52921 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -187,29 +187,28 @@ static int register_pernet_operations(struct list_head *list,
 	struct net *net, *undo_net;
 	int error;
 
-	error = 0;
 	list_add_tail(&ops->list, list);
-	for_each_net(net) {
-		if (ops->init) {
+	if (ops->init) {
+		for_each_net(net) {
 			error = ops->init(net);
 			if (error)
 				goto out_undo;
 		}
 	}
-out:
-	return error;
+	return 0;
 
 out_undo:
 	/* If I have an error cleanup all namespaces I initialized */
 	list_del(&ops->list);
-	for_each_net(undo_net) {
-		if (undo_net == net)
-			goto undone;
-		if (ops->exit)
+	if (ops->exit) {
+		for_each_net(undo_net) {
+			if (undo_net == net)
+				goto undone;
 			ops->exit(undo_net);
+		}
 	}
 undone:
-	goto out;
+	return error;
 }
 
 static void unregister_pernet_operations(struct pernet_operations *ops)
@@ -217,8 +216,8 @@ static void unregister_pernet_operations(struct pernet_operations *ops)
 	struct net *net;
 
 	list_del(&ops->list);
-	for_each_net(net)
-		if (ops->exit)
+	if (ops->exit)
+		for_each_net(net)
 			ops->exit(net);
 }
 
-- 
1.5.3.4

