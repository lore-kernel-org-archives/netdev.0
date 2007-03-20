From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/3] bridge: don't route packets while learning
Date: Tue, 20 Mar 2007 14:15:52 -0700
Message-ID: <20070320141552.53d39130@dxpl.pdx.osdl.net>
References: <20070320141251.3760d87f@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:60763 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751682AbXCTVUN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 17:20:13 -0400
In-Reply-To: <20070320141251.3760d87f@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While in the STP learning state, don't route packets; wait until
forwarding delay has expired. The purpose of the forwarding delay
is to detect loops in the network, and if a brouter started up
and started forwarding, it could cause a flood.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/bridge/br_input.c |   17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

--- netem.orig/net/bridge/br_input.c
+++ netem/net/bridge/br_input.c
@@ -129,7 +129,7 @@ struct sk_buff *br_handle_frame(struct n
 	const unsigned char *dest = eth_hdr(skb)->h_dest;
 
 	if (!is_valid_ether_addr(eth_hdr(skb)->h_source))
-		goto err;
+		goto drop;
 
 	if (unlikely(is_link_local(dest))) {
 		skb->pkt_type = PACKET_HOST;
@@ -138,22 +138,25 @@ struct sk_buff *br_handle_frame(struct n
 				NULL, br_handle_local_finish) == 0) ? skb : NULL;
 	}
 
-	if (p->state == BR_STATE_FORWARDING || p->state == BR_STATE_LEARNING) {
+	switch (p->state) {
+	case BR_STATE_FORWARDING:
+
 		if (br_should_route_hook) {
 			if (br_should_route_hook(&skb))
 				return skb;
 			dest = eth_hdr(skb)->h_dest;
 		}
-
+		/* fall through */
+	case BR_STATE_LEARNING:
 		if (!compare_ether_addr(p->br->dev->dev_addr, dest))
 			skb->pkt_type = PACKET_HOST;
 
 		NF_HOOK(PF_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
 			br_handle_frame_finish);
-		return NULL;
+		break;
+	default:
+drop:
+		kfree_skb(skb);
 	}
-
-err:
-	kfree_skb(skb);
 	return NULL;
 }
