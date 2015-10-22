From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 15/16] tipc: ensure binding table
	initial distribution is sent via first link
Date: Thu, 22 Oct 2015 08:51:47 -0400
Message-ID: <1445518308-26200-16-git-send-email-jon.maloy@ericsson.com>
References: <1445518308-26200-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1445518308-26200-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Correct synchronization of the broadcast link at first contact between
two nodes is dependent on the assumption that the binding table "bulk"
update passes via the same link as the initial broadcast syncronization
message, i.e., via the first link that is established.

This is not guaranteed in the current implementation. If two link
come up very close to each other in time, the "bulk" may quite well
pass via the second link, and hence void the guarantee of a correct
initial synchronization before the broadcast link is opened.

This commit makes two small changes to strengthen this guarantee.

1) We let the second established link occupy slot 1 of the
   "active_links" array, while the first link will retain slot 0.
   (This is in reality a cosmetic change, we could just as well keep
    the current, opposite order)

2) We let the name distributor always use link selector/slot 0 when
   it sends it binding table updates.

The extra traffic bias on the first link caused by this change should
be negligible, since binding table updates constitutes a very small
fraction of the total traffic.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/name_distr.c | 4 ++--
 net/tipc/node.c       | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index e6018b7..c07612b 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -102,7 +102,7 @@ void named_cluster_distribute(struct net *net, struct sk_buff *skb)
 		if (!oskb)
 			break;
 		msg_set_destnode(buf_msg(oskb), dnode);
-		tipc_node_xmit_skb(net, oskb, dnode, dnode);
+		tipc_node_xmit_skb(net, oskb, dnode, 0);
 	}
 	rcu_read_unlock();
 
@@ -223,7 +223,7 @@ void tipc_named_node_up(struct net *net, u32 dnode)
 			 &tn->nametbl->publ_list[TIPC_ZONE_SCOPE]);
 	rcu_read_unlock();
 
-	tipc_node_xmit(net, &head, dnode, dnode);
+	tipc_node_xmit(net, &head, dnode, 0);
 }
 
 static void tipc_publ_subscribe(struct net *net, struct publication *publ,
diff --git a/net/tipc/node.c b/net/tipc/node.c
index eb739d2..f4772f5 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -370,7 +370,7 @@ static void __tipc_node_link_up(struct tipc_node *n, int bearer_id,
 		tipc_link_set_active(ol, false);
 	} else if (nl->priority == ol->priority) {
 		tipc_link_set_active(nl, true);
-		*slot0 = bearer_id;
+		*slot1 = bearer_id;
 	} else {
 		pr_debug("New link <%s> is standby\n", nl->name);
 	}
-- 
1.9.1


------------------------------------------------------------------------------
