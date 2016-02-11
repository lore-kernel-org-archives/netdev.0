From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1] tipc: refactor node xmit and
	fix memory leaks
Date: Thu, 11 Feb 2016 10:43:15 +0100
Message-ID: <1455183795-15303-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net, Richard
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

Refactor tipc_node_xmit() to fail fast and fail early. Fix several
potential memory leaks in unexpected error paths.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
---
 net/tipc/link.c |  8 ++++++--
 net/tipc/node.c | 54 ++++++++++++++++++++++++++++++++----------------------
 2 files changed, 38 insertions(+), 24 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 6f4a6d9..3e513da 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -903,8 +903,10 @@ int tipc_link_xmit(struct tipc_link *l, struct sk_buff_head *list,
 		if (unlikely(l->backlog[i].len >= l->backlog[i].limit))
 			return link_schedule_user(l, list);
 	}
-	if (unlikely(msg_size(hdr) > mtu))
+	if (unlikely(msg_size(hdr) > mtu)) {
+		skb_queue_purge(list);
 		return -EMSGSIZE;
+	}
 
 	/* Prepare each packet for sending, and add to relevant queue: */
 	while (skb_queue_len(list)) {
@@ -916,8 +918,10 @@ int tipc_link_xmit(struct tipc_link *l, struct sk_buff_head *list,
 
 		if (likely(skb_queue_len(transmq) < maxwin)) {
 			_skb = skb_clone(skb, GFP_ATOMIC);
-			if (!_skb)
+			if (!_skb) {
+				skb_queue_purge(list);
 				return -ENOBUFS;
+			}
 			__skb_dequeue(list);
 			__skb_queue_tail(transmq, skb);
 			__skb_queue_tail(xmitq, _skb);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index f8a8255..10a1e87 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1166,7 +1166,7 @@ msg_full:
  * @dnode: address of destination node
  * @selector: a number used for deterministic link selection
  * Consumes the buffer chain, except when returning -ELINKCONG
- * Returns 0 if success, otherwise errno: -ELINKCONG,-EHOSTUNREACH,-EMSGSIZE
+ * Returns 0 if success, otherwise: -ELINKCONG,-EHOSTUNREACH,-EMSGSIZE,-ENOBUF
  */
 int tipc_node_xmit(struct net *net, struct sk_buff_head *list,
 		   u32 dnode, int selector)
@@ -1174,33 +1174,43 @@ int tipc_node_xmit(struct net *net, struct sk_buff_head *list,
 	struct tipc_link_entry *le = NULL;
 	struct tipc_node *n;
 	struct sk_buff_head xmitq;
-	int bearer_id = -1;
-	int rc = -EHOSTUNREACH;
+	int bearer_id;
+	int rc;
+
+	if (in_own_node(net, dnode)) {
+		tipc_sk_rcv(net, list);
+		return 0;
+	}
 
-	__skb_queue_head_init(&xmitq);
 	n = tipc_node_find(net, dnode);
-	if (likely(n)) {
-		tipc_node_read_lock(n);
-		bearer_id = n->active_links[selector & 1];
-		if (bearer_id >= 0) {
-			le = &n->links[bearer_id];
-			spin_lock_bh(&le->lock);
-			rc = tipc_link_xmit(le->link, list, &xmitq);
-			spin_unlock_bh(&le->lock);
-		}
+	if (unlikely(!n)) {
+		skb_queue_purge(list);
+		return -EHOSTUNREACH;
+	}
+
+	tipc_node_read_lock(n);
+	bearer_id = n->active_links[selector & 1];
+	if (unlikely(bearer_id == INVALID_BEARER_ID)) {
 		tipc_node_read_unlock(n);
-		if (likely(!rc))
-			tipc_bearer_xmit(net, bearer_id, &xmitq, &le->maddr);
-		else if (rc == -ENOBUFS)
-			tipc_node_link_down(n, bearer_id, false);
 		tipc_node_put(n);
-		return rc;
+		skb_queue_purge(list);
+		return -EHOSTUNREACH;
 	}
 
-	if (likely(in_own_node(net, dnode))) {
-		tipc_sk_rcv(net, list);
-		return 0;
-	}
+	__skb_queue_head_init(&xmitq);
+	le = &n->links[bearer_id];
+	spin_lock_bh(&le->lock);
+	rc = tipc_link_xmit(le->link, list, &xmitq);
+	spin_unlock_bh(&le->lock);
+	tipc_node_read_unlock(n);
+
+	if (likely(rc == 0))
+		tipc_bearer_xmit(net, bearer_id, &xmitq, &le->maddr);
+	else if (rc == -ENOBUFS)
+		tipc_node_link_down(n, bearer_id, false);
+
+	tipc_node_put(n);
+
 	return rc;
 }
 
-- 
2.1.4


------------------------------------------------------------------------------
Site24x7 APM Insight: Get Deep Visibility into Application Performance
APM + Mobile APM + RUM: Monitor 3 App instances at just $35/Month
Monitor end-to-end web transactions and take corrective actions now
Troubleshoot faster and improve end-user experience. Signup Now!
http://pubads.g.doubleclick.net/gampad/clk?id=272487151&iu=/4140
