From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 05/11] tipc: eliminate two pseudo
	message types of BUNDLE_OPEN and BUNDLE_CLOSED
Date: Wed, 26 Nov 2014 11:41:49 +0800
Message-ID: <1416973315-6047-6-git-send-email-ying.xue@windriver.com>
References: <1416973315-6047-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1416973315-6047-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The pseudo message types of BUNDLE_CLOSED as well as BUNDLE_OPEN are
used to flag whether or not more messages can be bundled into a data
packet in the outgoing transmission queue. Obviously, no more messages
can be appended after the packet has been sent and is waiting to be
acknowledged and deleted. These message types do in reality represent
a send-side local implementation flag, and are not defined as part of
the protocol. It is therefore safe to move it to to where it belongs,
that is, the control area (TIPC_SKB_CB) of the buffer.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/core.h |    1 +
 net/tipc/link.c |    2 +-
 net/tipc/msg.c  |    5 +++--
 net/tipc/msg.h  |    5 -----
 4 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index b578b10..8460213 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -192,6 +192,7 @@ struct tipc_skb_cb {
 	struct sk_buff *tail;
 	bool deferred;
 	bool wakeup_pending;
+	bool bundling;
 	u16 chain_sz;
 	u16 chain_imp;
 };
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 470f053..8eb885e 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -875,7 +875,7 @@ void tipc_link_push_packets(struct tipc_link *l_ptr)
 			msg_set_ack(msg, mod(l_ptr->next_in_no - 1));
 			msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in);
 			if (msg_user(msg) == MSG_BUNDLER)
-				msg_set_type(msg, BUNDLE_CLOSED);
+				TIPC_SKB_CB(skb)->bundling = false;
 			tipc_bearer_send(l_ptr->bearer_id, skb,
 					 &l_ptr->media_addr);
 			l_ptr->next_out = skb->next;
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 9155496..94db392 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -289,7 +289,7 @@ bool tipc_msg_bundle(struct sk_buff *bbuf, struct sk_buff *buf, u32 mtu)
 		return false;
 	if (likely(msg_user(bmsg) != MSG_BUNDLER))
 		return false;
-	if (likely(msg_type(bmsg) != BUNDLE_OPEN))
+	if (likely(!TIPC_SKB_CB(bbuf)->bundling))
 		return false;
 	if (unlikely(skb_tailroom(bbuf) < (pad + msz)))
 		return false;
@@ -336,11 +336,12 @@ bool tipc_msg_make_bundle(struct sk_buff **buf, u32 mtu, u32 dnode)
 
 	skb_trim(bbuf, INT_H_SIZE);
 	bmsg = buf_msg(bbuf);
-	tipc_msg_init(bmsg, MSG_BUNDLER, BUNDLE_OPEN, INT_H_SIZE, dnode);
+	tipc_msg_init(bmsg, MSG_BUNDLER, 0, INT_H_SIZE, dnode);
 	msg_set_seqno(bmsg, msg_seqno(msg));
 	msg_set_ack(bmsg, msg_ack(msg));
 	msg_set_bcast_ack(bmsg, msg_bcast_ack(msg));
 	bbuf->next = (*buf)->next;
+	TIPC_SKB_CB(bbuf)->bundling = true;
 	tipc_msg_bundle(bbuf, *buf, mtu);
 	*buf = bbuf;
 	return true;
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index d7d2ba2..8ca874d 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -464,11 +464,6 @@ static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
 #define FRAGMENT		1
 #define LAST_FRAGMENT		2
 
-/* Bundling protocol message types
- */
-#define BUNDLE_OPEN             0
-#define BUNDLE_CLOSED           1
-
 /*
  * Link management protocol message types
  */
-- 
1.7.9.5


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
