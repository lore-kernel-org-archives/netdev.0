From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 1/8] batman-adv: fix skb deref after free
Date: Wed, 18 May 2016 13:04:45 +0800
Message-ID: <1463547892-11290-2-git-send-email-a@unstable.cc>
References: <1463547892-11290-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Florian Westphal <fw@strlen.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:19449 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751218AbcERFGG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2016 01:06:06 -0400
In-Reply-To: <1463547892-11290-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

batadv_send_skb_to_orig() calls dev_queue_xmit() so we can't use skb->len.

Fixes: 953324776d6d ("batman-adv: network coding - buffer unicast packets before forward")
Signed-off-by: Florian Westphal <fw@strlen.de>
Reviewed-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/routing.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index ae850f2d11cb..e3857ed4057f 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -601,6 +601,7 @@ static int batadv_route_unicast_packet(struct sk_buff *skb,
 	struct batadv_unicast_packet *unicast_packet;
 	struct ethhdr *ethhdr = eth_hdr(skb);
 	int res, hdr_len, ret = NET_RX_DROP;
+	unsigned int len;
 
 	unicast_packet = (struct batadv_unicast_packet *)skb->data;
 
@@ -641,6 +642,7 @@ static int batadv_route_unicast_packet(struct sk_buff *skb,
 	if (hdr_len > 0)
 		batadv_skb_set_priority(skb, hdr_len);
 
+	len = skb->len;
 	res = batadv_send_skb_to_orig(skb, orig_node, recv_if);
 
 	/* translate transmit result into receive result */
@@ -648,7 +650,7 @@ static int batadv_route_unicast_packet(struct sk_buff *skb,
 		/* skb was transmitted and consumed */
 		batadv_inc_counter(bat_priv, BATADV_CNT_FORWARD);
 		batadv_add_counter(bat_priv, BATADV_CNT_FORWARD_BYTES,
-				   skb->len + ETH_HLEN);
+				   len + ETH_HLEN);
 
 		ret = NET_RX_SUCCESS;
 	} else if (res == NET_XMIT_POLICED) {
-- 
2.8.2
