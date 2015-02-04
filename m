From: Jouni Malinen <jouni@codeaurora.org>
Subject: [PATCH 2/3] bridge: Selectively prevent bridge port flooding for proxy ARP
Date: Wed,  4 Feb 2015 11:51:06 +0200
Message-ID: <1423043467-11148-2-git-send-email-jouni@codeaurora.org>
References: <1423043467-11148-1-git-send-email-jouni@codeaurora.org>
Cc: netdev@vger.kernel.org, Kyeyoon Park <kyeyoonp@codeaurora.org>,
	Jouni Malinen <jouni@codeaurora.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:42401 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964915AbbBDJwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 04:52:12 -0500
In-Reply-To: <1423043467-11148-1-git-send-email-jouni@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyeyoon Park <kyeyoonp@codeaurora.org>

Rather than completely blocking the bridge port flooding when
BR_PROXYARP is enabled, selectively prevent bridge port flooding for the
proxy ARP relevant frames. This is done by marking the "skb" with this
info when proxy ARP code executes.

Signed-off-by: Kyeyoon Park <kyeyoonp@codeaurora.org>
Signed-off-by: Jouni Malinen <jouni@codeaurora.org>
---
 net/bridge/br_forward.c | 3 ++-
 net/bridge/br_input.c   | 6 +++++-
 net/bridge/br_private.h | 1 +
 3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index f96933a..81b4bed 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -186,7 +186,8 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 			continue;
 
 		/* Do not flood to ports that enable proxy ARP */
-		if (p->flags & BR_PROXYARP)
+		if (p->flags & BR_PROXYARP &&
+		    BR_INPUT_SKB_CB(skb)->proxyarp_replied)
 			continue;
 
 		prev = maybe_deliver(prev, p, skb, __packet_hook);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index cfd46c6..41d1d3f 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -68,6 +68,8 @@ static void br_do_proxy_arp(struct sk_buff *skb, struct net_bridge *br,
 	u8 *arpptr, *sha;
 	__be32 sip, tip;
 
+	BR_INPUT_SKB_CB(skb)->proxyarp_replied = false;
+
 	if (dev->flags & IFF_NOARP)
 		return;
 
@@ -105,9 +107,11 @@ static void br_do_proxy_arp(struct sk_buff *skb, struct net_bridge *br,
 		}
 
 		f = __br_fdb_get(br, n->ha, vid);
-		if (f && f->dst->flags & BR_PROXYARP)
+		if (f && f->dst->flags & BR_PROXYARP) {
 			arp_send(ARPOP_REPLY, ETH_P_ARP, sip, skb->dev, tip,
 				 sha, n->ha, sha);
+			BR_INPUT_SKB_CB(skb)->proxyarp_replied = true;
+		}
 
 		neigh_release(n);
 	}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index de09199..c32e279 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -305,6 +305,7 @@ struct br_input_skb_cb {
 #endif
 
 	u16 frag_max_size;
+	bool proxyarp_replied;
 
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	bool vlan_filtered;
-- 
1.9.1
