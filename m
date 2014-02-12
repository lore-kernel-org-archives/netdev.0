From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 08/14] tipc: change signature of
	tunnelling reception function
Date: Wed, 12 Feb 2014 13:31:08 -0500
Message-ID: <1392229874-29675-9-git-send-email-jon.maloy@ericsson.com>
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

After the earlier commits in this series related to the function
tipc_link_tunnel_rcv(), we can now go further and simplify its
signature.

The function now consumes all DUPLICATE packets, and only returns such
ORIGINAL packets that are ready for immediate delivery, i.e., no
more link level protocol processing needs to be done by the caller.
As a consequence, the the caller, tipc_rcv(), does not access the link
pointer after call return, and it becomes unnecessary to pass a link
pointer reference in the call. Instead, we now only pass it the tunnel
link's owner node, which is sufficient to find the destination link for
the tunnelled packet.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/link.c |   14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 978fd3a..76adca6 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -78,7 +78,7 @@ static const char *link_unk_evt = "Unknown link event ";
 static void link_handle_out_of_seq_msg(struct tipc_link *l_ptr,
 				       struct sk_buff *buf);
 static void link_recv_proto_msg(struct tipc_link *l_ptr, struct sk_buff *buf);
-static int  tipc_link_tunnel_rcv(struct tipc_link **l_ptr,
+static int  tipc_link_tunnel_rcv(struct tipc_node *n_ptr,
 				 struct sk_buff **buf);
 static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tolerance);
 static int  link_send_sections_long(struct tipc_port *sender,
@@ -1596,7 +1596,7 @@ deliver:
 			tipc_node_unlock(n_ptr);
 			continue;
 		case CHANGEOVER_PROTOCOL:
-			if (!tipc_link_tunnel_rcv(&l_ptr, &buf))
+			if (!tipc_link_tunnel_rcv(n_ptr, &buf))
 				break;
 			msg = buf_msg(buf);
 			seq_no = msg_seqno(msg);
@@ -2173,7 +2173,7 @@ exit:
  *  returned to the active link for delivery upwards.
  *  Owner node is locked.
  */
-static int tipc_link_tunnel_rcv(struct tipc_link **l_ptr,
+static int tipc_link_tunnel_rcv(struct tipc_node *n_ptr,
 				struct sk_buff **buf)
 {
 	struct sk_buff *tunnel_buf = *buf;
@@ -2185,15 +2185,9 @@ static int tipc_link_tunnel_rcv(struct tipc_link **l_ptr,
 	if (bearer_id >= MAX_BEARERS)
 		goto exit;
 
-	dest_link = (*l_ptr)->owner->links[bearer_id];
+	dest_link = n_ptr->links[bearer_id];
 	if (!dest_link)
 		goto exit;
-	if (dest_link == *l_ptr) {
-		pr_err("Unexpected changeover message on link <%s>\n",
-		       (*l_ptr)->name);
-		goto exit;
-	}
-	*l_ptr = dest_link;
 
 	if (msg_typ == DUPLICATE_MSG) {
 		tipc_link_dup_rcv(dest_link, tunnel_buf);
-- 
1.7.9.5


------------------------------------------------------------------------------
Android apps run on BlackBerry 10
Introducing the new BlackBerry 10.2.1 Runtime for Android apps.
Now with support for Jelly Bean, Bluetooth, Mapview and more.
Get your Android app in front of a whole new audience.  Start now.
http://pubads.g.doubleclick.net/gampad/clk?id=124407151&iu=/4140/ostg.clktrk
