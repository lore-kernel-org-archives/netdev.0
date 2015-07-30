From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 01/12] tipc: eliminate function
	tipc_link_activate()
Date: Thu, 30 Jul 2015 18:24:15 -0400
Message-ID: <1438295066-29655-2-git-send-email-jon.maloy@ericsson.com>
References: <1438295066-29655-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1438295066-29655-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The function tipc_link_activate() is redundant, since it mostly performs
settings that have already been done in a preceding tipc_link_reset().

There are three exceptions to this:
- The actual state change to TIPC_LINK_WORKING. This should anyway be done
  in the FSM, and not in a separate function.
- Registration of the link with the bearer. This should be done by the
  node, since we don't want the link to have any knowledge about its
  specific bearer.
- Call to tipc_node_link_up() for user access registration. With the new
  role distribution between link aggregation and link level this becomes
  the wrong call order; tipc_node_link_up() should instead be called
  directly as a result of a TIPC_LINK_UP event, hence by the node itself.

This commit implements those changes.

Tested-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 17 ++++-------------
 net/tipc/link.h |  1 -
 net/tipc/node.c |  6 ++++--
 3 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index cc40aa6..05837ba 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -228,6 +228,8 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 	l_ptr->peer_session = WILDCARD_SESSION;
 	l_ptr->bearer_id = b_ptr->identity;
 	l_ptr->tolerance = b_ptr->tolerance;
+	l_ptr->snd_nxt = 1;
+	l_ptr->rcv_nxt = 1;
 	l_ptr->state = TIPC_LINK_RESETTING;
 
 	l_ptr->pmsg = (struct tipc_msg *)&l_ptr->proto_msg;
@@ -376,6 +378,7 @@ static int tipc_link_fsm_evt(struct tipc_link *l, int evt,
 			pl = node_active_link(l->owner, 0);
 			if (pl && link_probing(pl))
 				break;
+			l->state = TIPC_LINK_WORKING;
 			actions |= LINK_ACTIVATE;
 			if (!l->owner->working_links)
 				actions |= SND_BCAST_SYNC;
@@ -398,6 +401,7 @@ static int tipc_link_fsm_evt(struct tipc_link *l, int evt,
 			pl = node_active_link(l->owner, 0);
 			if (pl && link_probing(pl))
 				break;
+			l->state = TIPC_LINK_WORKING;
 			actions |= LINK_ACTIVATE;
 			if (!l->owner->working_links)
 				actions |= SND_BCAST_SYNC;
@@ -639,19 +643,6 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 	link_reset_statistics(l_ptr);
 }
 
-void tipc_link_activate(struct tipc_link *link)
-{
-	struct tipc_node *node = link->owner;
-
-	link->rcv_nxt = 1;
-	link->stats.recv_info = 1;
-	link->silent_intv_cnt = 0;
-	link->state = TIPC_LINK_WORKING;
-	link->exec_mode = TIPC_LINK_OPEN;
-	tipc_node_link_up(node, link->bearer_id);
-	tipc_bearer_add_dest(node->net, link->bearer_id, link->addr);
-}
-
 /**
  * __tipc_link_xmit(): same as tipc_link_xmit, but destlink is known & locked
  * @link: link to use
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 37cfd7d..279196d 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -223,7 +223,6 @@ void tipc_link_purge_queues(struct tipc_link *l_ptr);
 void tipc_link_purge_backlog(struct tipc_link *l);
 void tipc_link_reset_all(struct tipc_node *node);
 void tipc_link_reset(struct tipc_link *l_ptr);
-void tipc_link_activate(struct tipc_link *link);
 int __tipc_link_xmit(struct net *net, struct tipc_link *link,
 		     struct sk_buff_head *list);
 int tipc_link_xmit(struct tipc_link *link,	struct sk_buff_head *list,
diff --git a/net/tipc/node.c b/net/tipc/node.c
index e92f84a..558df25 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -295,11 +295,13 @@ void tipc_node_link_up(struct tipc_node *n, int bearer_id)
 	n->action_flags |= TIPC_NOTIFY_LINK_UP;
 	n->link_id = l->peer_bearer_id << 16 | l->bearer_id;
 
+	tipc_bearer_add_dest(n->net, bearer_id, n->addr);
+
 	pr_debug("Established link <%s> on network plane %c\n",
 		 l->name, l->net_plane);
 
 	/* No active links ? => take both active slots */
-	if (*slot0 < 0) {
+	if (!tipc_node_is_up(n)) {
 		*slot0 = bearer_id;
 		*slot1 = bearer_id;
 		node_established_contact(n);
@@ -896,7 +898,7 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b)
 	rc = tipc_link_rcv(l, skb, &xmitq);
 
 	if (unlikely(rc & TIPC_LINK_UP_EVT))
-		tipc_link_activate(l);
+		tipc_node_link_up(n, bearer_id);
 	if (unlikely(rc & TIPC_LINK_DOWN_EVT))
 		tipc_link_reset(l);
 	skb = NULL;
-- 
1.9.1


------------------------------------------------------------------------------
