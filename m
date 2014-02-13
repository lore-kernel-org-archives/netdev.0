From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v2 06/14] tipc: change reception
	of tunnelled duplicate packets
Date: Thu, 13 Feb 2014 17:29:10 -0500
Message-ID: <1392330558-19048-7-git-send-email-jon.maloy@ericsson.com>
References: <1392330558-19048-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1392330558-19048-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

When a second link to a destination comes up, some sender sockets will
steer their subsequent traffic through the new link. In order to
guarantee preserved packet order and cardinality for those sockets, we
tunnel a duplicate of the old link's send queue through the new link
before we open it for regular traffic. The last arriving packet copy,
on whichever link, will be dropped at the receiving end based on the
original sequence number, to ensure that only one copy is delivered to
the end receiver.

In this commit, we change the algorithm for receiving DUPLICATE_MSG
packets, at the same time delegating it to a new subfunction,
tipc_link_dup_rcv(). Instead of returning an extracted inner packet to
the packet reception loop in tipc_rcv(), we just add it to the receiving
(new) link's deferred packet queue. The packet will then be processed by
that link when it receives its first non-tunneled packet, i.e., at
latest when the changeover procedure is finished.

Because tipc_link_tunnel_rcv()/tipc_link_dup_rcv() now is consuming all
packets of type DUPLICATE_MSG, the calling tipc_rcv() function can omit
testing for this. This in turn means that the current conditional jump
to the label 'protocol_check' becomes redundant, and we can remove that
label.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/link.c |   53 ++++++++++++++++++++++++++++++++---------------------
 1 file changed, 32 insertions(+), 21 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index e7e44ab..f227a38 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1437,7 +1437,6 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		u32 seq_no;
 		u32 ackd;
 		u32 released = 0;
-		int type;
 
 		head = head->next;
 		buf->next = NULL;
@@ -1525,7 +1524,6 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		}
 
 		/* Now (finally!) process the incoming message */
-protocol_check:
 		if (unlikely(!link_working_working(l_ptr))) {
 			if (msg_user(msg) == LINK_PROTOCOL) {
 				link_recv_proto_msg(l_ptr, buf);
@@ -1599,15 +1597,11 @@ deliver:
 			tipc_node_unlock(n_ptr);
 			continue;
 		case CHANGEOVER_PROTOCOL:
-			type = msg_type(msg);
-			if (tipc_link_tunnel_rcv(&l_ptr, &buf)) {
-				msg = buf_msg(buf);
-				seq_no = msg_seqno(msg);
-				if (type == ORIGINAL_MSG)
-					goto deliver;
-				goto protocol_check;
-			}
-			break;
+			if (!tipc_link_tunnel_rcv(&l_ptr, &buf))
+				break;
+			msg = buf_msg(buf);
+			seq_no = msg_seqno(msg);
+			goto deliver;
 		default:
 			kfree_skb(buf);
 			buf = NULL;
@@ -2107,7 +2101,30 @@ static struct sk_buff *buf_extract(struct sk_buff *skb, u32 from_pos)
 	return eb;
 }
 
-/*  tipc_link_tunnel_rcv(): Receive a tunneled packet, sent
+
+
+/* tipc_link_dup_rcv(): Receive a tunnelled DUPLICATE_MSG packet.
+ * Owner node is locked.
+ */
+static void tipc_link_dup_rcv(struct tipc_link *l_ptr,
+			      struct sk_buff *t_buf)
+{
+	struct sk_buff *buf;
+
+	if (!tipc_link_is_up(l_ptr))
+		return;
+
+	buf = buf_extract(t_buf, INT_H_SIZE);
+	if (buf == NULL) {
+		pr_warn("%sfailed to extract inner dup pkt\n", link_co_err);
+		return;
+	}
+
+	/* Add buffer to deferred queue, if applicable: */
+	link_handle_out_of_seq_msg(l_ptr, buf);
+}
+
+/*  tipc_link_tunnel_rcv(): Receive a tunnelled packet, sent
  *  via other link as result of a failover (ORIGINAL_MSG) or
  *  a new active link (DUPLICATE_MSG). Failover packets are
  *  returned to the active link for delivery upwards.
@@ -2126,6 +2143,7 @@ static int tipc_link_tunnel_rcv(struct tipc_link **l_ptr,
 
 	if (bearer_id >= MAX_BEARERS)
 		goto exit;
+
 	dest_link = (*l_ptr)->owner->links[bearer_id];
 	if (!dest_link)
 		goto exit;
@@ -2138,15 +2156,8 @@ static int tipc_link_tunnel_rcv(struct tipc_link **l_ptr,
 	msg = msg_get_wrapped(tunnel_msg);
 
 	if (msg_typ == DUPLICATE_MSG) {
-		if (less(msg_seqno(msg), mod(dest_link->next_in_no)))
-			goto exit;
-		*buf = buf_extract(tunnel_buf, INT_H_SIZE);
-		if (*buf == NULL) {
-			pr_warn("%sduplicate msg dropped\n", link_co_err);
-			goto exit;
-		}
-		kfree_skb(tunnel_buf);
-		return 1;
+		tipc_link_dup_rcv(dest_link, tunnel_buf);
+		goto exit;
 	}
 
 	/* First original message ?: */
-- 
1.7.9.5


------------------------------------------------------------------------------
Android apps run on BlackBerry 10
Introducing the new BlackBerry 10.2.1 Runtime for Android apps.
Now with support for Jelly Bean, Bluetooth, Mapview and more.
Get your Android app in front of a whole new audience.  Start now.
http://pubads.g.doubleclick.net/gampad/clk?id=124407151&iu=/4140/ostg.clktrk
