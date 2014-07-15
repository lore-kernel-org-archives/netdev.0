From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 2/7] tipc: let internal link
	users call the new link send function
Date: Tue, 15 Jul 2014 10:49:52 -0400
Message-ID: <1405435797-30116-3-git-send-email-jon.maloy@ericsson.com>
References: <1405435797-30116-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1405435797-30116-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

We convert the link internal users (changeover protocol, broadcast
synchronization) to use the new packet send function.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/link.c |   15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 367b0f5..d1255ba 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -999,7 +999,7 @@ int tipc_link_xmit2(struct sk_buff *buf, u32 dnode, u32 selector)
  *
  * Called with node locked
  */
-static void tipc_link_sync_xmit(struct tipc_link *l)
+static void tipc_link_sync_xmit(struct tipc_link *link)
 {
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
@@ -1009,10 +1009,9 @@ static void tipc_link_sync_xmit(struct tipc_link *l)
 		return;
 
 	msg = buf_msg(buf);
-	tipc_msg_init(msg, BCAST_PROTOCOL, STATE_MSG, INT_H_SIZE, l->addr);
-	msg_set_last_bcast(msg, l->owner->bclink.acked);
-	link_add_chain_to_outqueue(l, buf, 0);
-	tipc_link_push_queue(l);
+	tipc_msg_init(msg, BCAST_PROTOCOL, STATE_MSG, INT_H_SIZE, link->addr);
+	msg_set_last_bcast(msg, link->owner->bclink.acked);
+	__tipc_link_xmit2(link, buf);
 }
 
 /*
@@ -1859,7 +1858,7 @@ static void tipc_link_tunnel_xmit(struct tipc_link *l_ptr,
 	}
 	skb_copy_to_linear_data(buf, tunnel_hdr, INT_H_SIZE);
 	skb_copy_to_linear_data_offset(buf, INT_H_SIZE, msg, length);
-	__tipc_link_xmit(tunnel, buf);
+	__tipc_link_xmit2(tunnel, buf);
 }
 
 
@@ -1892,7 +1891,7 @@ void tipc_link_failover_send_queue(struct tipc_link *l_ptr)
 		if (buf) {
 			skb_copy_to_linear_data(buf, &tunnel_hdr, INT_H_SIZE);
 			msg_set_size(&tunnel_hdr, INT_H_SIZE);
-			__tipc_link_xmit(tunnel, buf);
+			__tipc_link_xmit2(tunnel, buf);
 		} else {
 			pr_warn("%sunable to send changeover msg\n",
 				link_co_err);
@@ -1965,7 +1964,7 @@ void tipc_link_dup_queue_xmit(struct tipc_link *l_ptr,
 		skb_copy_to_linear_data(outbuf, &tunnel_hdr, INT_H_SIZE);
 		skb_copy_to_linear_data_offset(outbuf, INT_H_SIZE, iter->data,
 					       length);
-		__tipc_link_xmit(tunnel, outbuf);
+		__tipc_link_xmit2(tunnel, outbuf);
 		if (!tipc_link_is_up(l_ptr))
 			return;
 		iter = iter->next;
-- 
1.7.9.5


------------------------------------------------------------------------------
Want fast and easy access to all the code in your enterprise? Index and
search up to 200,000 lines of code with a free copy of Black Duck
Code Sight - the same software that powers the world's largest code
search on Ohloh, the Black Duck Open Hub! Try it now.
http://p.sf.net/sfu/bds
