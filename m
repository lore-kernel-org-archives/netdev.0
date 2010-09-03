From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 3/4] tipc: Optimize handling excess content on incoming messages
Date: Fri,  3 Sep 2010 14:33:41 -0400
Message-ID: <1283538822-25718-3-git-send-email-paul.gortmaker@windriver.com>
References: <1283538822-25718-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54535 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757244Ab0ICSdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 14:33:46 -0400
In-Reply-To: <1283538822-25718-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Remove code that trimmed excess trailing info from incoming messages
arriving over an Ethernet interface.  TIPC now ignores the extra info
while the message is being processed by the node, and only trims it off
if the message is retransmitted to another node.  (This latter step is
done to ensure the extra info doesn't cause the sk_buff to exceed the
outgoing interface's MTU limit.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/eth_media.c |   13 +++----------
 net/tipc/net.c       |    1 +
 2 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 81253d0..ff50a17 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -101,15 +101,12 @@ static int send_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr,
  * Accept only packets explicitly sent to this node, or broadcast packets;
  * ignores packets sent using Ethernet multicast, and traffic sent to other
  * nodes (which can happen if interface is running in promiscuous mode).
- * Routine truncates any Ethernet padding/CRC appended to the message,
- * and ensures message size matches actual length
  */
 
 static int recv_msg(struct sk_buff *buf, struct net_device *dev,
 		    struct packet_type *pt, struct net_device *orig_dev)
 {
 	struct eth_bearer *eb_ptr = (struct eth_bearer *)pt->af_packet_priv;
-	u32 size;
 
 	if (!net_eq(dev_net(dev), &init_net)) {
 		kfree_skb(buf);
@@ -118,13 +115,9 @@ static int recv_msg(struct sk_buff *buf, struct net_device *dev,
 
 	if (likely(eb_ptr->bearer)) {
 		if (likely(buf->pkt_type <= PACKET_BROADCAST)) {
-			size = msg_size((struct tipc_msg *)buf->data);
-			skb_trim(buf, size);
-			if (likely(buf->len == size)) {
-				buf->next = NULL;
-				tipc_recv_msg(buf, eb_ptr->bearer);
-				return 0;
-			}
+			buf->next = NULL;
+			tipc_recv_msg(buf, eb_ptr->bearer);
+			return 0;
 		}
 	}
 	kfree_skb(buf);
diff --git a/net/tipc/net.c b/net/tipc/net.c
index f61b769..14bd109 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -248,6 +248,7 @@ void tipc_net_route_msg(struct sk_buff *buf)
 
 	/* Handle message for another node */
 	msg_dbg(msg, "NET>SEND>: ");
+	pskb_trim(buf, msg_size(msg));
 	tipc_link_send(buf, dnode, msg_link_selector(msg));
 }
 
-- 
1.7.2.1

