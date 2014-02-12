From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 09/14] tipc: more cleanup of
	tunnelling reception function
Date: Wed, 12 Feb 2014 13:31:09 -0500
Message-ID: <1392229874-29675-10-git-send-email-jon.maloy@ericsson.com>
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

We simplify and slim down the code in function tipc_tunnel_rcv()
No impact on the users of this function.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c |   21 +++++++--------------
 1 file changed, 7 insertions(+), 14 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 76adca6..00f529e 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2179,9 +2179,10 @@ static int tipc_link_tunnel_rcv(struct tipc_node *n_ptr,
 	struct sk_buff *tunnel_buf = *buf;
 	struct tipc_link *dest_link;
 	struct tipc_msg *tunnel_msg = buf_msg(tunnel_buf);
-	u32 msg_typ = msg_type(tunnel_msg);
 	u32 bearer_id = msg_bearer_id(tunnel_msg);
 
+	*buf = NULL;
+
 	if (bearer_id >= MAX_BEARERS)
 		goto exit;
 
@@ -2189,24 +2190,16 @@ static int tipc_link_tunnel_rcv(struct tipc_node *n_ptr,
 	if (!dest_link)
 		goto exit;
 
-	if (msg_typ == DUPLICATE_MSG) {
+	if (msg_type(tunnel_msg) == DUPLICATE_MSG)
 		tipc_link_dup_rcv(dest_link, tunnel_buf);
-		goto exit;
-	}
-
-	if (msg_type(tunnel_msg) == ORIGINAL_MSG) {
+	else if (msg_type(tunnel_msg) == ORIGINAL_MSG)
 		*buf = tipc_link_failover_rcv(dest_link, tunnel_buf);
+	else
+		pr_warn("%sunknown tunnel pkt received\n", link_co_err);
 
-		/* Do we have a buffer/buffer chain to return? */
-		if (*buf != NULL) {
-			kfree_skb(tunnel_buf);
-			return 1;
-		}
-	}
 exit:
-	*buf = NULL;
 	kfree_skb(tunnel_buf);
-	return 0;
+	return *buf != NULL;
 }
 
 /*
-- 
1.7.9.5


------------------------------------------------------------------------------
Android apps run on BlackBerry 10
Introducing the new BlackBerry 10.2.1 Runtime for Android apps.
Now with support for Jelly Bean, Bluetooth, Mapview and more.
Get your Android app in front of a whole new audience.  Start now.
http://pubads.g.doubleclick.net/gampad/clk?id=124407151&iu=/4140/ostg.clktrk
