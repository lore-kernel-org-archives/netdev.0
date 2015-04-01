From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 1/4] netns: don't clear nsid too early on removal
Date: Wed,  1 Apr 2015 14:49:46 +0200
Message-ID: <1427892589-4266-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1427892589-4266-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:55535 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436AbbDAMuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 08:50:08 -0400
In-Reply-To: <1427892589-4266-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the current code, ids are removed too early.
Suppose you have an ipip interface that stands in the netns foo and its link
part in the netns bar (so the netns bar has an nsid into the netns foo).
Now, you remove the netns bar:
 - the bar nsid into the netns foo is removed
 - the netns exit method of ipip is called, thus our ipip iface is removed:
   => a netlink message is sent in the netns foo to advertise this deletion
   => this netlink message requests an nsid for bar, thus a new nsid is
      allocated for bar and never removed.

We must remove nsids when we are sure that nobody will refer to netns currently
cleaned.

Fixes: 0c7aecd4bde4 ("netns: add rtnl cmd to add and get peer netns ids")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
(cherry picked from commit 4217291e592da0e4258b652e82e5428639d29acc)
---

This patch comes from the net tree.

 net/core/net_namespace.c | 24 +++++++++++++++---------
 1 file changed, 15 insertions(+), 9 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index e5e96b0f6717..ce6396a75b8b 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -338,7 +338,7 @@ static LIST_HEAD(cleanup_list);  /* Must hold cleanup_list_lock to touch */
 static void cleanup_net(struct work_struct *work)
 {
 	const struct pernet_operations *ops;
-	struct net *net, *tmp;
+	struct net *net, *tmp, *peer;
 	struct list_head net_kill_list;
 	LIST_HEAD(net_exit_list);
 
@@ -354,14 +354,6 @@ static void cleanup_net(struct work_struct *work)
 	list_for_each_entry(net, &net_kill_list, cleanup_list) {
 		list_del_rcu(&net->list);
 		list_add_tail(&net->exit_list, &net_exit_list);
-		for_each_net(tmp) {
-			int id = __peernet2id(tmp, net, false);
-
-			if (id >= 0)
-				idr_remove(&tmp->netns_ids, id);
-		}
-		idr_destroy(&net->netns_ids);
-
 	}
 	rtnl_unlock();
 
@@ -387,12 +379,26 @@ static void cleanup_net(struct work_struct *work)
 	 */
 	rcu_barrier();
 
+	rtnl_lock();
 	/* Finally it is safe to free my network namespace structure */
 	list_for_each_entry_safe(net, tmp, &net_exit_list, exit_list) {
+		/* Unreference net from all peers (no need to loop over
+		 * net_exit_list because idr_destroy() will be called for each
+		 * element of this list.
+		 */
+		for_each_net(peer) {
+			int id = __peernet2id(peer, net, false);
+
+			if (id >= 0)
+				idr_remove(&peer->netns_ids, id);
+		}
+		idr_destroy(&net->netns_ids);
+
 		list_del_init(&net->exit_list);
 		put_user_ns(net->user_ns);
 		net_drop_ns(net);
 	}
+	rtnl_unlock();
 }
 static DECLARE_WORK(net_cleanup_work, cleanup_net);
 
-- 
2.2.2
