From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 11/14] tipc: changes to general
	packet reception algorithm
Date: Wed, 12 Feb 2014 13:31:11 -0500
Message-ID: <1392229874-29675-12-git-send-email-jon.maloy@ericsson.com>
References: <1392229874-29675-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1392229874-29675-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

We change the order of checking for destination users when processing
incoming packets. By placing the checks for users that may potentially
replace the processed buffer, i.e., CHANGEOVER_PROTOCOL and
MSG_FRAGMENTER, in a separate step before we check for the true end
users, we get rid of a label and a 'goto', at the same time making the
code more comprehensible and easy to follow.

This commit does not change any functionality, it is just a cosmetic
code reshuffle.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/link.c |   76 +++++++++++++++++++++++++++++--------------------------
 1 file changed, 40 insertions(+), 36 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 758f7cd..1228d6c 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1483,7 +1483,7 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		if ((n_ptr->block_setup & WAIT_PEER_DOWN) &&
 			msg_user(msg) == LINK_PROTOCOL &&
 			(msg_type(msg) == RESET_MSG ||
-					msg_type(msg) == ACTIVATE_MSG) &&
+			 msg_type(msg) == ACTIVATE_MSG) &&
 			!msg_redundant_link(msg))
 			n_ptr->block_setup &= ~WAIT_PEER_DOWN;
 
@@ -1502,7 +1502,6 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		while ((crs != l_ptr->next_out) &&
 		       less_eq(buf_seqno(crs), ackd)) {
 			struct sk_buff *next = crs->next;
-
 			kfree_skb(crs);
 			crs = next;
 			released++;
@@ -1515,14 +1514,17 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		/* Try sending any messages link endpoint has pending */
 		if (unlikely(l_ptr->next_out))
 			tipc_link_push_queue(l_ptr);
+
 		if (unlikely(!list_empty(&l_ptr->waiting_ports)))
 			tipc_link_wakeup_ports(l_ptr, 0);
+
 		if (unlikely(++l_ptr->unacked_window >= TIPC_MIN_LINK_WIN)) {
 			l_ptr->stats.sent_acks++;
-			tipc_link_send_proto_msg(l_ptr, STATE_MSG, 0, 0, 0, 0, 0);
+			tipc_link_send_proto_msg(l_ptr, STATE_MSG,
+						 0, 0, 0, 0, 0);
 		}
 
-		/* Now (finally!) process the incoming message */
+		/* Process the incoming packet */
 		if (unlikely(!link_working_working(l_ptr))) {
 			if (msg_user(msg) == LINK_PROTOCOL) {
 				link_recv_proto_msg(l_ptr, buf);
@@ -1554,14 +1556,40 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		l_ptr->next_in_no++;
 		if (unlikely(l_ptr->oldest_deferred_in))
 			head = link_insert_deferred_queue(l_ptr, head);
-deliver:
-		if (likely(msg_isdata(msg))) {
+
+		/* Deliver packet/message to correct user: */
+		if (unlikely(msg_user(msg) ==  CHANGEOVER_PROTOCOL)) {
+			if (!tipc_link_tunnel_rcv(n_ptr, &buf)) {
+				tipc_node_unlock(n_ptr);
+				continue;
+			}
+			msg = buf_msg(buf);
+		} else if (msg_user(msg) == MSG_FRAGMENTER) {
+			int rc;
+
+			l_ptr->stats.recv_fragments++;
+			rc = tipc_link_frag_rcv(&l_ptr->reasm_head,
+						&l_ptr->reasm_tail,
+						&buf);
+			if (rc == LINK_REASM_COMPLETE) {
+				l_ptr->stats.recv_fragmented++;
+				msg = buf_msg(buf);
+			} else {
+				if (rc == LINK_REASM_ERROR)
+					tipc_link_reset(l_ptr);
+				tipc_node_unlock(n_ptr);
+				continue;
+			}
+		}
+
+		switch (msg_user(msg)) {
+		case TIPC_LOW_IMPORTANCE:
+		case TIPC_MEDIUM_IMPORTANCE:
+		case TIPC_HIGH_IMPORTANCE:
+		case TIPC_CRITICAL_IMPORTANCE:
 			tipc_node_unlock(n_ptr);
 			tipc_port_recv_msg(buf);
 			continue;
-		}
-		switch (msg_user(msg)) {
-			int ret;
 		case MSG_BUNDLER:
 			l_ptr->stats.recv_bundles++;
 			l_ptr->stats.recv_bundled += msg_msgcnt(msg);
@@ -1573,44 +1601,20 @@ deliver:
 			tipc_node_unlock(n_ptr);
 			tipc_named_recv(buf);
 			continue;
-		case BCAST_PROTOCOL:
-			tipc_link_recv_sync(n_ptr, buf);
-			tipc_node_unlock(n_ptr);
-			continue;
 		case CONN_MANAGER:
 			tipc_node_unlock(n_ptr);
 			tipc_port_recv_proto_msg(buf);
 			continue;
-		case MSG_FRAGMENTER:
-			l_ptr->stats.recv_fragments++;
-			ret = tipc_link_frag_rcv(&l_ptr->reasm_head,
-						 &l_ptr->reasm_tail,
-						 &buf);
-			if (ret == LINK_REASM_COMPLETE) {
-				l_ptr->stats.recv_fragmented++;
-				msg = buf_msg(buf);
-				goto deliver;
-			}
-			if (ret == LINK_REASM_ERROR)
-				tipc_link_reset(l_ptr);
-			tipc_node_unlock(n_ptr);
-			continue;
-		case CHANGEOVER_PROTOCOL:
-			if (!tipc_link_tunnel_rcv(n_ptr, &buf))
-				break;
-			msg = buf_msg(buf);
-			seq_no = msg_seqno(msg);
-			goto deliver;
+		case BCAST_PROTOCOL:
+			tipc_link_recv_sync(n_ptr, buf);
+			break;
 		default:
 			kfree_skb(buf);
-			buf = NULL;
 			break;
 		}
 		tipc_node_unlock(n_ptr);
-		tipc_net_route_msg(buf);
 		continue;
 unlock_discard:
-
 		tipc_node_unlock(n_ptr);
 discard:
 		kfree_skb(buf);
-- 
1.7.9.5


------------------------------------------------------------------------------
Android apps run on BlackBerry 10
Introducing the new BlackBerry 10.2.1 Runtime for Android apps.
Now with support for Jelly Bean, Bluetooth, Mapview and more.
Get your Android app in front of a whole new audience.  Start now.
http://pubads.g.doubleclick.net/gampad/clk?id=124407151&iu=/4140/ostg.clktrk
