From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next 3/4] tipc: Optimize handling excess content on
 incoming messages
Date: Wed, 8 Sep 2010 19:31:24 -0400
Message-ID: <20100908233124.GA20563@windriver.com>
References: <1283538822-25718-1-git-send-email-paul.gortmaker@windriver.com>
 <1283538822-25718-3-git-send-email-paul.gortmaker@windriver.com>
 <20100903.125533.173857867.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:38415 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753697Ab0IHXb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 19:31:27 -0400
Content-Disposition: inline
In-Reply-To: <20100903.125533.173857867.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [PATCH net-next 3/4] tipc: Optimize handling excess content on incoming messages] On 03/09/2010 (Fri 12:55) David Miller wrote:

> From: Paul Gortmaker <paul.gortmaker@windriver.com>
> Date: Fri,  3 Sep 2010 14:33:41 -0400
> 
> > @@ -248,6 +248,7 @@ void tipc_net_route_msg(struct sk_buff *buf)
> >  
> >  	/* Handle message for another node */
> >  	msg_dbg(msg, "NET>SEND>: ");
> > +	pskb_trim(buf, msg_size(msg));
> >  	tipc_link_send(buf, dnode, msg_link_selector(msg));
> >  }
> 
> 1) pskb_trim() can fail, you need to check the return value
>    and act appropriately.
> 
> 2) pskb_trim() can change all of the packet data pointers, so
>    after you call it you need to reload any pointers to the
>    packet data area.  At a minimum, you woull need to
>    reload 'msg' in this code snippet.
> 
>    Otherwise 'msg' can point to freed up memory after the call.

Looking at it again, it isn't clear to me why this change switched over
to using pskb_trim in the 1st place.  The rework below just stays with
the simpler skb_trim that it was using previously.

Thanks,
Paul.

>From 3a93344bd2cad3142c81f0304fdb28404c0d7ff1 Mon Sep 17 00:00:00 2001
From: Allan Stephens <allan.stephens@windriver.com>
Date: Wed, 8 Sep 2010 10:30:42 -0400
Subject: [PATCH] tipc: Optimize handling excess content on incoming messages

Remove code that trimmed excess trailing info from incoming messages
arriving over an Ethernet interface.  TIPC now ignores the extra info
while the message is being processed by the node, and only trims it off
if the message is retransmitted to another node.  (This latter step is
done to ensure the extra info doesn't cause the sk_buff to exceed the
outgoing interface's MTU limit.) The outgoing buffer is guaranteed to
be linear.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---

V2: maintain skb_trim usage; dont invoke pskb_trim needlessly

 net/tipc/eth_media.c |   13 +++----------
 net/tipc/net.c       |    1 +
 2 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 673fdf0..6e988ba 100644
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
index f61b769..7e05af4 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -248,6 +248,7 @@ void tipc_net_route_msg(struct sk_buff *buf)
 
 	/* Handle message for another node */
 	msg_dbg(msg, "NET>SEND>: ");
+	skb_trim(buf, msg_size(msg));
 	tipc_link_send(buf, dnode, msg_link_selector(msg));
 }
 
-- 
1.7.2.1

