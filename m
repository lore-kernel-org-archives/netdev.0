From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] tipc: remove two indentation
	levels in tipc_recv_msg routine
Date: Tue, 29 Oct 2013 19:01:11 +0800
Message-ID: <1383044471-12982-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>, <maloy@donjonn.com>
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

The message dispatching part of tipc_recv_msg() is wrapped layers of
while/if/if/switch, causing out-of-control indentation and does not
look very good. We reduce two indentation levels by separating the
message dispatching from the blocks that checks link state and
sequence numbers, allowing longer function and arg names to be
consistently indented without wrapping. This is a cosmetic change
that does not alter the operation of TIPC in any way.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/link.c |  147 +++++++++++++++++++++++++++----------------------------
 1 file changed, 72 insertions(+), 75 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index e8153f6..1bfee8c 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1593,97 +1593,94 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *b_ptr)
 
 		/* Now (finally!) process the incoming message */
 protocol_check:
-		if (likely(link_working_working(l_ptr))) {
-			if (likely(seq_no == mod(l_ptr->next_in_no))) {
-				l_ptr->next_in_no++;
-				if (unlikely(l_ptr->oldest_deferred_in))
-					head = link_insert_deferred_queue(l_ptr,
-									  head);
-deliver:
-				if (likely(msg_isdata(msg))) {
-					tipc_node_unlock(n_ptr);
-					tipc_port_recv_msg(buf);
-					continue;
-				}
-				switch (msg_user(msg)) {
-					int ret;
-				case MSG_BUNDLER:
-					l_ptr->stats.recv_bundles++;
-					l_ptr->stats.recv_bundled +=
-						msg_msgcnt(msg);
-					tipc_node_unlock(n_ptr);
-					tipc_link_recv_bundle(buf);
-					continue;
-				case NAME_DISTRIBUTOR:
-					n_ptr->bclink.recv_permitted = true;
-					tipc_node_unlock(n_ptr);
-					tipc_named_recv(buf);
-					continue;
-				case BCAST_PROTOCOL:
-					tipc_link_recv_sync(n_ptr, buf);
-					tipc_node_unlock(n_ptr);
-					continue;
-				case CONN_MANAGER:
-					tipc_node_unlock(n_ptr);
-					tipc_port_recv_proto_msg(buf);
-					continue;
-				case MSG_FRAGMENTER:
-					l_ptr->stats.recv_fragments++;
-					ret = tipc_link_recv_fragment(
-						&l_ptr->defragm_buf,
-						&buf, &msg);
-					if (ret == 1) {
-						l_ptr->stats.recv_fragmented++;
-						goto deliver;
-					}
-					if (ret == -1)
-						l_ptr->next_in_no--;
-					break;
-				case CHANGEOVER_PROTOCOL:
-					type = msg_type(msg);
-					if (link_recv_changeover_msg(&l_ptr,
-								     &buf)) {
-						msg = buf_msg(buf);
-						seq_no = msg_seqno(msg);
-						if (type == ORIGINAL_MSG)
-							goto deliver;
-						goto protocol_check;
-					}
-					break;
-				default:
-					kfree_skb(buf);
-					buf = NULL;
-					break;
-				}
+		if (unlikely(!link_working_working(l_ptr))) {
+			if (msg_user(msg) == LINK_PROTOCOL) {
+				link_recv_proto_msg(l_ptr, buf);
+				head = link_insert_deferred_queue(l_ptr, head);
+				tipc_node_unlock(n_ptr);
+				continue;
+			}
+
+			/* Traffic message. Conditionally activate link */
+			link_state_event(l_ptr, TRAFFIC_MSG_EVT);
+
+			if (link_working_working(l_ptr)) {
+				/* Re-insert buffer in front of queue */
+				buf->next = head;
+				head = buf;
 				tipc_node_unlock(n_ptr);
-				tipc_net_route_msg(buf);
 				continue;
 			}
+			tipc_node_unlock(n_ptr);
+			goto cont;
+		}
+
+		/* Link is now in state WORKING_WORKING */
+		if (unlikely(seq_no != mod(l_ptr->next_in_no))) {
 			link_handle_out_of_seq_msg(l_ptr, buf);
 			head = link_insert_deferred_queue(l_ptr, head);
 			tipc_node_unlock(n_ptr);
 			continue;
 		}
-
-		/* Link is not in state WORKING_WORKING */
-		if (msg_user(msg) == LINK_PROTOCOL) {
-			link_recv_proto_msg(l_ptr, buf);
+		l_ptr->next_in_no++;
+		if (unlikely(l_ptr->oldest_deferred_in))
 			head = link_insert_deferred_queue(l_ptr, head);
+deliver:
+		if (likely(msg_isdata(msg))) {
 			tipc_node_unlock(n_ptr);
+			tipc_port_recv_msg(buf);
 			continue;
 		}
-
-		/* Traffic message. Conditionally activate link */
-		link_state_event(l_ptr, TRAFFIC_MSG_EVT);
-
-		if (link_working_working(l_ptr)) {
-			/* Re-insert buffer in front of queue */
-			buf->next = head;
-			head = buf;
+		switch (msg_user(msg)) {
+			int ret;
+		case MSG_BUNDLER:
+			l_ptr->stats.recv_bundles++;
+			l_ptr->stats.recv_bundled += msg_msgcnt(msg);
+			tipc_node_unlock(n_ptr);
+			tipc_link_recv_bundle(buf);
+			continue;
+		case NAME_DISTRIBUTOR:
+			n_ptr->bclink.recv_permitted = true;
+			tipc_node_unlock(n_ptr);
+			tipc_named_recv(buf);
+			continue;
+		case BCAST_PROTOCOL:
+			tipc_link_recv_sync(n_ptr, buf);
+			tipc_node_unlock(n_ptr);
+			continue;
+		case CONN_MANAGER:
 			tipc_node_unlock(n_ptr);
+			tipc_port_recv_proto_msg(buf);
 			continue;
+		case MSG_FRAGMENTER:
+			l_ptr->stats.recv_fragments++;
+			ret = tipc_link_recv_fragment(&l_ptr->defragm_buf,
+						      &buf, &msg);
+			if (ret == 1) {
+				l_ptr->stats.recv_fragmented++;
+				goto deliver;
+			}
+			if (ret == -1)
+				l_ptr->next_in_no--;
+			break;
+		case CHANGEOVER_PROTOCOL:
+			type = msg_type(msg);
+			if (link_recv_changeover_msg(&l_ptr, &buf)) {
+				msg = buf_msg(buf);
+				seq_no = msg_seqno(msg);
+				if (type == ORIGINAL_MSG)
+					goto deliver;
+				goto protocol_check;
+			}
+			break;
+		default:
+			kfree_skb(buf);
+			buf = NULL;
+			break;
 		}
 		tipc_node_unlock(n_ptr);
+		tipc_net_route_msg(buf);
+		continue;
 cont:
 		kfree_skb(buf);
 	}
-- 
1.7.9.5


------------------------------------------------------------------------------
Android is increasing in popularity, but the open development platform that
developers love is also attractive to malware creators. Download this white
paper to learn more about secure code signing practices that can help keep
Android apps secure.
http://pubads.g.doubleclick.net/gampad/clk?id=65839951&iu=/4140/ostg.clktrk
