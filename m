From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 07/14] tipc: change reception of
	tunnelled failover packets
Date: Wed, 12 Feb 2014 13:31:07 -0500
Message-ID: <1392229874-29675-8-git-send-email-jon.maloy@ericsson.com>
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

When a link is reset, and there is a redundant link available, all
sender sockets will steer their subsequent traffic through the
remaining link. In order to guarantee preserved packet order and
cardinality during the transition, we tunnel the failing link's send
queue through the remaining link before we allow any sockets to use it.

In this commit, we change the algorithm for receiving failover
("ORIGINAL_MSG") packets in tipc_link_tunnel_rcv(), at the same time
delegating it to a new subfuncton, tipc_link_failover_rcv(). Instead
of directly returning an extracted inner packet to the packet reception
loop in tipc_rcv(), we first check if it is a message fragment, in which
case we append it to the reset link's fragment chain. If the fragment
chain is complete, we return the whole chain instead of the individual
buffer, eliminating any need for the tipc_rcv() loop to do reassembly of
tunneled packets.

This change makes it possible to further simplify tipc_link_tunnel_rcv(),
as well as the calling tipc_rcv() loop. We will do that in later
commits. It also makes it possible to identify a single spot in the code
where we can tell that a failover procedure is finished, something that
is useful when we are deleting links after a failover. This will also
be done in a later commit.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/link.c |   75 ++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 47 insertions(+), 28 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 80f9eb2..978fd3a 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2123,6 +2123,50 @@ static void tipc_link_dup_rcv(struct tipc_link *l_ptr,
 	link_handle_out_of_seq_msg(l_ptr, buf);
 }
 
+/*  tipc_link_failover_rcv(): Receive a tunnelled ORIGINAL_MSG packet
+ *  Owner node is locked.
+ */
+static struct sk_buff *tipc_link_failover_rcv(struct tipc_link *l_ptr,
+					      struct sk_buff *t_buf)
+{
+	struct tipc_msg *t_msg = buf_msg(t_buf);
+	struct sk_buff *buf = NULL;
+	struct tipc_msg *msg;
+
+	if (tipc_link_is_up(l_ptr))
+		tipc_link_reset(l_ptr);
+
+	/* First failover packet? */
+	if (l_ptr->exp_msg_count == START_CHANGEOVER)
+		l_ptr->exp_msg_count = msg_msgcnt(t_msg);
+
+	/* Should there be an inner packet? */
+	if (l_ptr->exp_msg_count) {
+		l_ptr->exp_msg_count--;
+		buf = buf_extract(t_buf, INT_H_SIZE);
+		if (buf == NULL) {
+			pr_warn("%sno inner failover pkt\n", link_co_err);
+			goto exit;
+		}
+		msg = buf_msg(buf);
+
+		if (less(msg_seqno(msg), l_ptr->reset_checkpoint)) {
+			kfree_skb(buf);
+			buf = NULL;
+			goto exit;
+		}
+		if (msg_user(msg) == MSG_FRAGMENTER) {
+			l_ptr->stats.recv_fragments++;
+			tipc_link_frag_rcv(&l_ptr->reasm_head,
+					   &l_ptr->reasm_tail,
+					   &buf);
+		}
+	}
+
+exit:
+	return buf;
+}
+
 /*  tipc_link_tunnel_rcv(): Receive a tunnelled packet, sent
  *  via other link as result of a failover (ORIGINAL_MSG) or
  *  a new active link (DUPLICATE_MSG). Failover packets are
@@ -2134,10 +2178,8 @@ static int tipc_link_tunnel_rcv(struct tipc_link **l_ptr,
 {
 	struct sk_buff *tunnel_buf = *buf;
 	struct tipc_link *dest_link;
-	struct tipc_msg *msg;
 	struct tipc_msg *tunnel_msg = buf_msg(tunnel_buf);
 	u32 msg_typ = msg_type(tunnel_msg);
-	u32 msg_count = msg_msgcnt(tunnel_msg);
 	u32 bearer_id = msg_bearer_id(tunnel_msg);
 
 	if (bearer_id >= MAX_BEARERS)
@@ -2152,42 +2194,19 @@ static int tipc_link_tunnel_rcv(struct tipc_link **l_ptr,
 		goto exit;
 	}
 	*l_ptr = dest_link;
-	msg = msg_get_wrapped(tunnel_msg);
 
 	if (msg_typ == DUPLICATE_MSG) {
 		tipc_link_dup_rcv(dest_link, tunnel_buf);
 		goto exit;
 	}
 
-	/* First original message ?: */
-	if (tipc_link_is_up(dest_link)) {
-		pr_info("%s<%s>, changeover initiated by peer\n", link_rst_msg,
-			dest_link->name);
-		tipc_link_reset(dest_link);
-		dest_link->exp_msg_count = msg_count;
-		if (!msg_count)
-			goto exit;
-	} else if (dest_link->exp_msg_count == START_CHANGEOVER) {
-		dest_link->exp_msg_count = msg_count;
-		if (!msg_count)
-			goto exit;
-	}
+	if (msg_type(tunnel_msg) == ORIGINAL_MSG) {
+		*buf = tipc_link_failover_rcv(dest_link, tunnel_buf);
 
-	/* Receive original message */
-	if (dest_link->exp_msg_count == 0) {
-		pr_warn("%sgot too many tunnelled messages\n", link_co_err);
-		goto exit;
-	}
-	dest_link->exp_msg_count--;
-	if (less(msg_seqno(msg), dest_link->reset_checkpoint)) {
-		goto exit;
-	} else {
-		*buf = buf_extract(tunnel_buf, INT_H_SIZE);
+		/* Do we have a buffer/buffer chain to return? */
 		if (*buf != NULL) {
 			kfree_skb(tunnel_buf);
 			return 1;
-		} else {
-			pr_warn("%soriginal msg dropped\n", link_co_err);
 		}
 	}
 exit:
-- 
1.7.9.5


------------------------------------------------------------------------------
Android apps run on BlackBerry 10
Introducing the new BlackBerry 10.2.1 Runtime for Android apps.
Now with support for Jelly Bean, Bluetooth, Mapview and more.
Get your Android app in front of a whole new audience.  Start now.
http://pubads.g.doubleclick.net/gampad/clk?id=124407151&iu=/4140/ostg.clktrk
