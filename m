From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] net: neighbour: use source address of last enqueued packet for solicitation
Date: Sat, 21 Sep 2013 06:32:34 +0200
Message-ID: <20130921043234.GA13307@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, ja@ssi.bg
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:41526 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692Ab3IUEcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 00:32:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we always use the first member of the arp_queue to determine
the sender ip address of the arp packet (or in case of IPv6 - source
address of the ndisc packet). This skb is fixed as long as the queue is
not drained by a complete purge because of a timeout or by a successful
response.

If the first packet enqueued on the arp_queue is from a local application
with a manually set source address and the to be discovered system
does some kind of uRPF checks on the source address in the arp packet
the resolving process hangs until a timeout and restarts. This hurts
communication with the participating network node.

This could be mitigated a bit if we use the latest enqueued skb's
source address for the resolving process, which is not as static as
the arp_queue's head. This change of the source address could result in
better recovery of a failed solicitation.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Julian Anastasov <ja@ssi.bg>
Reviewed-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/core/neighbour.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 6072610..ca15f32 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -867,7 +867,7 @@ static void neigh_invalidate(struct neighbour *neigh)
 static void neigh_probe(struct neighbour *neigh)
 	__releases(neigh->lock)
 {
-	struct sk_buff *skb = skb_peek(&neigh->arp_queue);
+	struct sk_buff *skb = skb_peek_tail(&neigh->arp_queue);
 	/* keep skb alive even if arp_queue overflows */
 	if (skb)
 		skb = skb_copy(skb, GFP_ATOMIC);
-- 
1.8.3.1
