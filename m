From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v3 net 2/2] bridge: use is_skb_forwardable in forward path
Date: Thu, 27 Mar 2014 17:32:30 -0400
Message-ID: <1395955950-17630-3-git-send-email-vyasevic@redhat.com>
References: <1395955950-17630-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, shemminger@vyatta.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15555 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757010AbaC0Vcg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 17:32:36 -0400
In-Reply-To: <1395955950-17630-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use existing function instead of trying to use our own.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_forward.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index d3409e6..056b67b 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -35,16 +35,11 @@ static inline int should_deliver(const struct net_bridge_port *p,
 		p->state == BR_STATE_FORWARDING;
 }
 
-static inline unsigned int packet_length(const struct sk_buff *skb)
-{
-	return skb->len - (skb->protocol == htons(ETH_P_8021Q) ? VLAN_HLEN : 0);
-}
-
 int br_dev_queue_push_xmit(struct sk_buff *skb)
 {
 	/* ip_fragment doesn't copy the MAC header */
 	if (nf_bridge_maybe_copy_header(skb) ||
-	    (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))) {
+	    !is_skb_forwardable(skb->dev, skb)) {
 		kfree_skb(skb);
 	} else {
 		skb_push(skb, ETH_HLEN);
@@ -71,7 +66,7 @@ static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 	skb->dev = to->dev;
 
 	if (unlikely(netpoll_tx_running(to->br->dev))) {
-		if (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))
+		if (!is_skb_forwardable(skb->dev, skb))
 			kfree_skb(skb);
 		else {
 			skb_push(skb, ETH_HLEN);
-- 
1.8.5.3
