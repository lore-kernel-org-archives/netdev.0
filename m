From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/1] tipc: move premature
	initilalization of stack variables
Date: Thu, 23 Feb 2017 11:10:31 -0500
Message-ID: <1487866231-23666-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
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

In the function tipc_rcv() we initialize a couple of stack variables
from the message header before that same header has been validated.
In rare cases when the arriving header is non-linar, the validation
function itself may linearize the buffer by calling skb_may_pull(),
while the wrongly initialized stack fields are not updated accordingly.

We fix this in this commit.

Reported-by: Matthew Wong <mwong@sonusnet.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index e9295fa..4512e83 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1505,19 +1505,21 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b)
 {
 	struct sk_buff_head xmitq;
 	struct tipc_node *n;
-	struct tipc_msg *hdr = buf_msg(skb);
-	int usr = msg_user(hdr);
+	struct tipc_msg *hdr;
 	int bearer_id = b->identity;
 	struct tipc_link_entry *le;
-	u16 bc_ack = msg_bcast_ack(hdr);
 	u32 self = tipc_own_addr(net);
-	int rc = 0;
+	int usr, rc = 0;
+	u16 bc_ack;
 
 	__skb_queue_head_init(&xmitq);
 
-	/* Ensure message is well-formed */
+	/* Ensure message is well-formed before touching the header */
 	if (unlikely(!tipc_msg_validate(skb)))
 		goto discard;
+	hdr = buf_msg(skb);
+	usr = msg_user(hdr);
+	bc_ack = msg_bcast_ack(hdr);
 
 	/* Handle arrival of discovery or broadcast packet */
 	if (unlikely(msg_non_seq(hdr))) {
-- 
2.7.4


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, SlashDot.org! http://sdm.link/slashdot
