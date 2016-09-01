From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v1] tipc: fix random link resets while
	adding a second bearer
Date: Thu, 1 Sep 2016 16:22:16 +0200
Message-ID: <1472739736-29391-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
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

In a dual bearer configuration, if the second tipc link becomes
active while the first link still has pending nametable "bulk"
updates, it randomly leads to reset of the second link.

When a link is established, the function named_distribute(),
fills the skb based on node mtu (allows room for TUNNEL_PROTOCOL)
with NAME_DISTRIBUTOR message for each PUBLICATION.
However, the function named_distribute() allocates the buffer by
increasing the node mtu by INT_H_SIZE (to insert NAME_DISTRIBUTOR).
This consumes the space allocated for TUNNEL_PROTOCOL.

When establishing the second link, the link shall tunnel all the
messages in the first link queue including the "bulk" update.
As size of the NAME_DISTRIBUTOR messages while tunnelling, exceeds
the link mtu the transmission fails (-EMSGSIZE).

Thus, the synch point based on the message count of the tunnel
packets is never reached leading to link timeout.

In this commit, we adjust the size of name distributor message so that
they can be tunnelled.

Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/name_distr.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 6b626a64b517..a04fe9be1c60 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -62,6 +62,8 @@ static void publ_to_item(struct distr_item *i, struct publication *p)
 
 /**
  * named_prepare_buf - allocate & initialize a publication message
+ *
+ * The buffer returned is of size INT_H_SIZE + payload size
  */
 static struct sk_buff *named_prepare_buf(struct net *net, u32 type, u32 size,
 					 u32 dest)
@@ -141,9 +143,9 @@ static void named_distribute(struct net *net, struct sk_buff_head *list,
 	struct publication *publ;
 	struct sk_buff *skb = NULL;
 	struct distr_item *item = NULL;
-	uint msg_dsz = (tipc_node_get_mtu(net, dnode, 0) / ITEM_SIZE) *
-			ITEM_SIZE;
-	uint msg_rem = msg_dsz;
+	u32 msg_dsz = ((tipc_node_get_mtu(net, dnode, 0) - INT_H_SIZE) /
+			ITEM_SIZE) * ITEM_SIZE;
+	u32 msg_rem = msg_dsz;
 
 	list_for_each_entry(publ, pls, local_list) {
 		/* Prepare next buffer: */
-- 
2.1.4


------------------------------------------------------------------------------
