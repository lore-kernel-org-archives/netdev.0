From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 1/2] tipc: fix link attribute
	propagation bug
Date: Mon, 1 Feb 2016 08:19:56 +0100
Message-ID: <1454311197-10948-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
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

Changing certain link attributes (link tolerance and link priority)
from the TIPC management tool is supposed to automatically take
effect at both endpoints of the affected link.

Currently the media address is not instantiated for the link and is
used uninstantiated when crafting protocol messages designated for the
peer endpoint. This means that changing a link property currently
results in the property being changed on the local machine but the
protocol message designated for the peer gets lost. Resulting in
property discrepancy between the endpoints.

In this patch we resolve this by using the media address from the
link entry and using the bearer transmit function to send it. Hence,
we can now eliminate the redundant function tipc_link_prot_xmit() and
the redundant field tipc_link::media_addr.

Fixes: 2af5ae372a4b (tipc: clean up unused code and structures)
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Reported-by: Jason Hu <huzhijiang@gmail.com>
Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
---
 net/tipc/link.c | 31 ++++++-------------------------
 net/tipc/link.h |  6 ++++--
 net/tipc/node.c |  9 ++++++---
 3 files changed, 16 insertions(+), 30 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 0c2944f..f156353 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -123,7 +123,6 @@ struct tipc_stats {
 struct tipc_link {
 	u32 addr;
 	char name[TIPC_MAX_LINK_NAME];
-	struct tipc_media_addr *media_addr;
 	struct net *net;
 
 	/* Management and link supervision data */
@@ -1261,26 +1260,6 @@ drop:
 	return rc;
 }
 
-/*
- * Send protocol message to the other endpoint.
- */
-static void tipc_link_proto_xmit(struct tipc_link *l, u32 msg_typ,
-				 int probe_msg, u32 gap, u32 tolerance,
-				 u32 priority)
-{
-	struct sk_buff *skb = NULL;
-	struct sk_buff_head xmitq;
-
-	__skb_queue_head_init(&xmitq);
-	tipc_link_build_proto_msg(l, msg_typ, probe_msg, gap,
-				  tolerance, priority, &xmitq);
-	skb = __skb_dequeue(&xmitq);
-	if (!skb)
-		return;
-	tipc_bearer_xmit_skb(l->net, l->bearer_id, skb, l->media_addr);
-	l->rcv_unacked = 0;
-}
-
 static void tipc_link_build_proto_msg(struct tipc_link *l, int mtyp, bool probe,
 				      u16 rcvgap, int tolerance, int priority,
 				      struct sk_buff_head *xmitq)
@@ -2021,16 +2000,18 @@ msg_full:
 	return -EMSGSIZE;
 }
 
-void tipc_link_set_tolerance(struct tipc_link *l, u32 tol)
+void tipc_link_set_tolerance(struct tipc_link *l, u32 tol,
+			     struct sk_buff_head *xmitq)
 {
 	l->tolerance = tol;
-	tipc_link_proto_xmit(l, STATE_MSG, 0, 0, tol, 0);
+	tipc_link_build_proto_msg(l, STATE_MSG, 0, 0, tol, 0, xmitq);
 }
 
-void tipc_link_set_prio(struct tipc_link *l, u32 prio)
+void tipc_link_set_prio(struct tipc_link *l, u32 prio,
+			struct sk_buff_head *xmitq)
 {
 	l->priority = prio;
-	tipc_link_proto_xmit(l, STATE_MSG, 0, 0, 0, prio);
+	tipc_link_build_proto_msg(l, STATE_MSG, 0, 0, 0, prio, xmitq);
 }
 
 void tipc_link_set_abort_limit(struct tipc_link *l, u32 limit)
diff --git a/net/tipc/link.h b/net/tipc/link.h
index b2ae0f4..b4ee9d6 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -112,8 +112,10 @@ char tipc_link_plane(struct tipc_link *l);
 int tipc_link_prio(struct tipc_link *l);
 int tipc_link_window(struct tipc_link *l);
 unsigned long tipc_link_tolerance(struct tipc_link *l);
-void tipc_link_set_tolerance(struct tipc_link *l, u32 tol);
-void tipc_link_set_prio(struct tipc_link *l, u32 prio);
+void tipc_link_set_tolerance(struct tipc_link *l, u32 tol,
+			     struct sk_buff_head *xmitq);
+void tipc_link_set_prio(struct tipc_link *l, u32 prio,
+			struct sk_buff_head *xmitq);
 void tipc_link_set_abort_limit(struct tipc_link *l, u32 limit);
 void tipc_link_set_queue_limits(struct tipc_link *l, u32 window);
 int __tipc_nl_add_link(struct net *net, struct tipc_nl_msg *msg,
diff --git a/net/tipc/node.c b/net/tipc/node.c
index fa97d96..f8a8255 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1637,9 +1637,12 @@ int tipc_nl_node_set_link(struct sk_buff *skb, struct genl_info *info)
 	char *name;
 	struct tipc_link *link;
 	struct tipc_node *node;
+	struct sk_buff_head xmitq;
 	struct nlattr *attrs[TIPC_NLA_LINK_MAX + 1];
 	struct net *net = sock_net(skb->sk);
 
+	__skb_queue_head_init(&xmitq);
+
 	if (!info->attrs[TIPC_NLA_LINK])
 		return -EINVAL;
 
@@ -1683,13 +1686,13 @@ int tipc_nl_node_set_link(struct sk_buff *skb, struct genl_info *info)
 			u32 tol;
 
 			tol = nla_get_u32(props[TIPC_NLA_PROP_TOL]);
-			tipc_link_set_tolerance(link, tol);
+			tipc_link_set_tolerance(link, tol, &xmitq);
 		}
 		if (props[TIPC_NLA_PROP_PRIO]) {
 			u32 prio;
 
 			prio = nla_get_u32(props[TIPC_NLA_PROP_PRIO]);
-			tipc_link_set_prio(link, prio);
+			tipc_link_set_prio(link, prio, &xmitq);
 		}
 		if (props[TIPC_NLA_PROP_WIN]) {
 			u32 win;
@@ -1701,7 +1704,7 @@ int tipc_nl_node_set_link(struct sk_buff *skb, struct genl_info *info)
 
 out:
 	tipc_node_read_unlock(node);
-
+	tipc_bearer_xmit(net, bearer_id, &xmitq, &node->links[bearer_id].maddr);
 	return res;
 }
 
-- 
2.1.4


------------------------------------------------------------------------------
Site24x7 APM Insight: Get Deep Visibility into Application Performance
APM + Mobile APM + RUM: Monitor 3 App instances at just $35/Month
Monitor end-to-end web transactions and take corrective actions now
Troubleshoot faster and improve end-user experience. Signup Now!
http://pubads.g.doubleclick.net/gampad/clk?id=267308311&iu=/4140
