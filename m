From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH net] bridge: allow receiption on disabled port
Date: Thu, 10 Oct 2013 14:52:50 +0200
Message-ID: <1381409570-1892-1-git-send-email-nbd@openwrt.org>
Cc: stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:40022 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752326Ab3JJMw5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Oct 2013 08:52:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an ethernet device is enslaved to a bridge, and the bridge STP
detects loss of carrier (or operational state down), then normally
packet receiption is blocked.

This breaks control applications like WPA which maybe expecting to
receive packets to negotiate to bring link up. The bridge needs to
block forwarding packets from these disabled ports, but there is no
hard requirement to not allow local packet delivery.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Felix Fietkau <nbd@openwrt.org>
---
 net/bridge/br_input.c | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index a2fd37e..0a8a8cd 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -146,9 +146,11 @@ static int br_handle_local_finish(struct sk_buff *skb)
 	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
 	u16 vid = 0;
 
-	br_vlan_get_tag(skb, &vid);
-	if (p->flags & BR_LEARNING)
-		br_fdb_update(p->br, p, eth_hdr(skb)->h_source, vid);
+	if (p->state != BR_STATE_DISABLED) {
+		br_vlan_get_tag(skb, &vid);
+		if (p->flags & BR_LEARNING)
+			br_fdb_update(p->br, p, eth_hdr(skb)->h_source, vid);
+	}
 	return 0;	 /* process further */
 }
 
@@ -218,6 +220,18 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 
 forward:
 	switch (p->state) {
+	case BR_STATE_DISABLED:
+		if (ether_addr_equal(p->br->dev->dev_addr, dest))
+			skb->pkt_type = PACKET_HOST;
+
+		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
+			br_handle_local_finish))
+			break;
+
+		BR_INPUT_SKB_CB(skb)->brdev = p->br->dev;
+		br_pass_frame_up(skb);
+		break;
+
 	case BR_STATE_FORWARDING:
 		rhook = rcu_dereference(br_should_route_hook);
 		if (rhook) {
-- 
1.8.0.2
