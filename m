From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 1/2] Revert "netns: don't clear nsid too early on removal"
Date: Fri,  3 Apr 2015 12:02:36 +0200
Message-ID: <1428055357-15289-1-git-send-email-nicolas.dichtel@6wind.com>
References: <551E63B9.9050208@6wind.com>
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:57419 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005AbbDCKC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 06:02:58 -0400
In-Reply-To: <551E63B9.9050208@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts
commit 4217291e592d ("netns: don't clear nsid too early on removal").

This is not the right fix, it introduces races.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/net_namespace.c | 24 +++++++++---------------
 1 file changed, 9 insertions(+), 15 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 5221f975a4cc..cb5290b8c428 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -349,7 +349,7 @@ static LIST_HEAD(cleanup_list);  /* Must hold cleanup_list_lock to touch */
 static void cleanup_net(struct work_struct *work)
 {
 	const struct pernet_operations *ops;
-	struct net *net, *tmp, *peer;
+	struct net *net, *tmp;
 	struct list_head net_kill_list;
 	LIST_HEAD(net_exit_list);
 
@@ -365,6 +365,14 @@ static void cleanup_net(struct work_struct *work)
 	list_for_each_entry(net, &net_kill_list, cleanup_list) {
 		list_del_rcu(&net->list);
 		list_add_tail(&net->exit_list, &net_exit_list);
+		for_each_net(tmp) {
+			int id = __peernet2id(tmp, net, false);
+
+			if (id >= 0)
+				idr_remove(&tmp->netns_ids, id);
+		}
+		idr_destroy(&net->netns_ids);
+
 	}
 	rtnl_unlock();
 
@@ -390,26 +398,12 @@ static void cleanup_net(struct work_struct *work)
 	 */
 	rcu_barrier();
 
-	rtnl_lock();
 	/* Finally it is safe to free my network namespace structure */
 	list_for_each_entry_safe(net, tmp, &net_exit_list, exit_list) {
-		/* Unreference net from all peers (no need to loop over
-		 * net_exit_list because idr_destroy() will be called for each
-		 * element of this list.
-		 */
-		for_each_net(peer) {
-			int id = __peernet2id(peer, net, false);
-
-			if (id >= 0)
-				idr_remove(&peer->netns_ids, id);
-		}
-		idr_destroy(&net->netns_ids);
-
 		list_del_init(&net->exit_list);
 		put_user_ns(net->user_ns);
 		net_drop_ns(net);
 	}
-	rtnl_unlock();
 }
 static DECLARE_WORK(net_cleanup_work, cleanup_net);
 
-- 
2.2.2
