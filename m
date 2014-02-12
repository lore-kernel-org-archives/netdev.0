From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 01/14] tipc: stricter behavior of
	message reassembly function
Date: Wed, 12 Feb 2014 13:31:01 -0500
Message-ID: <1392229874-29675-2-git-send-email-jon.maloy@ericsson.com>
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

The function tipc_link_recv_fragment(struct sk_buff **buf) currently
leaves the value of the input buffer pointer undefined when it returns,
except when the return code indicates that the reassembly is complete.
This despite the fact that it always consumes the input buffer.

Here, we enforce a stricter behavior by this function, ensuring that
the returned buffer pointer is non-NULL if and only if the reassembly
is complete. This makes it possible to test for the buffer pointer as
criteria for successful reassembly.

We also rename the function to tipc_link_frag_rcv(), which is both
shorter and more in line with common naming practice in the network
subsystem.

Apart from the new name, these changes have no impact on current
users of the function, but makes it more practical for use in some
planned future commits.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/bcast.c |    6 +++---
 net/tipc/link.c  |   16 +++++++++-------
 net/tipc/link.h  |    6 +++---
 3 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index bf860d9..af35f76 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -481,9 +481,9 @@ receive:
 			tipc_link_recv_bundle(buf);
 		} else if (msg_user(msg) == MSG_FRAGMENTER) {
 			int ret;
-			ret = tipc_link_recv_fragment(&node->bclink.reasm_head,
-						      &node->bclink.reasm_tail,
-						      &buf);
+			ret = tipc_link_frag_rcv(&node->bclink.reasm_head,
+						 &node->bclink.reasm_tail,
+						 &buf);
 			if (ret == LINK_REASM_ERROR)
 				goto unlock;
 			spin_lock_bh(&bc_lock);
diff --git a/net/tipc/link.c b/net/tipc/link.c
index d4b5de4..17fbd15 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1584,9 +1584,9 @@ deliver:
 			continue;
 		case MSG_FRAGMENTER:
 			l_ptr->stats.recv_fragments++;
-			ret = tipc_link_recv_fragment(&l_ptr->reasm_head,
-						      &l_ptr->reasm_tail,
-						      &buf);
+			ret = tipc_link_frag_rcv(&l_ptr->reasm_head,
+						 &l_ptr->reasm_tail,
+						 &buf);
 			if (ret == LINK_REASM_COMPLETE) {
 				l_ptr->stats.recv_fragmented++;
 				msg = buf_msg(buf);
@@ -2277,12 +2277,11 @@ static int link_send_long_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
 	return dsz;
 }
 
-/*
- * tipc_link_recv_fragment(): Called with node lock on. Returns
+/* tipc_link_frag_rcv(): Called with node lock on. Returns
  * the reassembled buffer if message is complete.
  */
-int tipc_link_recv_fragment(struct sk_buff **head, struct sk_buff **tail,
-			    struct sk_buff **fbuf)
+int tipc_link_frag_rcv(struct sk_buff **head, struct sk_buff **tail,
+		       struct sk_buff **fbuf)
 {
 	struct sk_buff *frag = *fbuf;
 	struct tipc_msg *msg = buf_msg(frag);
@@ -2296,6 +2295,7 @@ int tipc_link_recv_fragment(struct sk_buff **head, struct sk_buff **tail,
 			goto out_free;
 		*head = frag;
 		skb_frag_list_init(*head);
+		*fbuf = NULL;
 		return 0;
 	} else if (*head &&
 		   skb_try_coalesce(*head, frag, &headstolen, &delta)) {
@@ -2315,10 +2315,12 @@ int tipc_link_recv_fragment(struct sk_buff **head, struct sk_buff **tail,
 		*tail = *head = NULL;
 		return LINK_REASM_COMPLETE;
 	}
+	*fbuf = NULL;
 	return 0;
 out_free:
 	pr_warn_ratelimited("Link unable to reassemble fragmented message\n");
 	kfree_skb(*fbuf);
+	*fbuf = NULL;
 	return LINK_REASM_ERROR;
 }
 
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 3b6aa65..8addc5e 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -239,9 +239,9 @@ int tipc_link_send_sections_fast(struct tipc_port *sender,
 				 struct iovec const *msg_sect,
 				 unsigned int len, u32 destnode);
 void tipc_link_recv_bundle(struct sk_buff *buf);
-int  tipc_link_recv_fragment(struct sk_buff **reasm_head,
-			     struct sk_buff **reasm_tail,
-			     struct sk_buff **fbuf);
+int  tipc_link_frag_rcv(struct sk_buff **reasm_head,
+			struct sk_buff **reasm_tail,
+			struct sk_buff **fbuf);
 void tipc_link_send_proto_msg(struct tipc_link *l_ptr, u32 msg_typ, int prob,
 			      u32 gap, u32 tolerance, u32 priority,
 			      u32 acked_mtu);
-- 
1.7.9.5


------------------------------------------------------------------------------
Android apps run on BlackBerry 10
Introducing the new BlackBerry 10.2.1 Runtime for Android apps.
Now with support for Jelly Bean, Bluetooth, Mapview and more.
Get your Android app in front of a whole new audience.  Start now.
http://pubads.g.doubleclick.net/gampad/clk?id=124407151&iu=/4140/ostg.clktrk
