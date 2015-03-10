From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/1] tipc: ensure that idle links
	are deleted when a bearer is disabled
Date: Tue, 10 Mar 2015 12:23:34 -0400
Message-ID: <1426004614-18168-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

commit afaa3f65f65fda2e7b190aac7e2a75d9a2a77cb6
(tipc: purge links when bearer is disabled) was an attempt to resolve
a problem that turned out to have a more profound reason.

When we disable a bearer, we delete all its pertaining links if
there is no other bearer to perform failover to, or if the module
is shutting down. In case there are dual bearers, we wait with
deleting links until the failover procedure is finished.

However, this misses the case when a link on the removed bearer
was already down, so that there will be no failover procedure to
finish the link delete. This causes confusion if a new bearer is
added to replace the removed one, and also entails a small memory
leak.

This commit takes the current state of the link into account when
deciding when to delete it, and also reverses the above-mentioned
commit.

Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bearer.c | 2 +-
 net/tipc/link.c   | 4 +++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 840db89..3613e72 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -747,7 +747,7 @@ int tipc_nl_bearer_disable(struct sk_buff *skb, struct genl_info *info)
 		return -EINVAL;
 	}
 
-	bearer_disable(net, bearer, true);
+	bearer_disable(net, bearer, false);
 	rtnl_unlock();
 
 	return 0;
diff --git a/net/tipc/link.c b/net/tipc/link.c
index a4cf364..0e31497 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -344,6 +344,7 @@ void tipc_link_delete_list(struct net *net, unsigned int bearer_id,
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_link *link;
 	struct tipc_node *node;
+	bool del_link;
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(node, &tn->node_list, list) {
@@ -353,12 +354,13 @@ void tipc_link_delete_list(struct net *net, unsigned int bearer_id,
 			tipc_node_unlock(node);
 			continue;
 		}
+		del_link = !tipc_link_is_up(link) && !link->exp_msg_count;
 		tipc_link_reset(link);
 		if (del_timer(&link->timer))
 			tipc_link_put(link);
 		link->flags |= LINK_STOPPED;
 		/* Delete link now, or when failover is finished: */
-		if (shutting_down || !tipc_node_is_up(node))
+		if (shutting_down || !tipc_node_is_up(node) || del_link)
 			tipc_link_delete(link);
 		tipc_node_unlock(node);
 	}
-- 
1.9.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
