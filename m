From: fgao@ikuai8.com
Subject: [PATCH net-next 1/2] net: batman-adv: Treat NET_XMIT_CN as transmit successfully
Date: Mon, 21 Nov 2016 23:00:32 +0800
Message-ID: <1479740432-3721-1-git-send-email-fgao@ikuai8.com>
To: mareklindner@neomailbox.ch, sw@simonwunderlich.de, a@unstable.cc,
        davem@davemloft.net, b.a.t.m.a.n@lists.open-mesh.org,
        netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg291.qq.com ([113.108.11.223]:33941 "EHLO smtpbg291.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754367AbcKUPBZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 10:01:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@gmail.com>

The tc could return NET_XMIT_CN as one congestion notification, but
it does not mean the packet is lost. Other modules like ipvlan,
macvlan, and others treat NET_XMIT_CN as success too.

So batman-adv should add the NET_XMIT_CN check.

Signed-off-by: Gao Feng <gfree.wind@gmail.com>
---
 net/batman-adv/distributed-arp-table.c |  2 +-
 net/batman-adv/fragmentation.c         |  2 +-
 net/batman-adv/routing.c               | 10 +++++-----
 net/batman-adv/soft-interface.c        |  2 +-
 net/batman-adv/tp_meter.c              |  2 +-
 5 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 49576c5..f6ff4de 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -659,7 +659,7 @@ static bool batadv_dat_send_data(struct batadv_priv *bat_priv,
 		}
 
 		send_status = batadv_send_unicast_skb(tmp_skb, neigh_node);
-		if (send_status == NET_XMIT_SUCCESS) {
+		if (send_status == NET_XMIT_SUCCESS || send_status == NET_XMIT_CN) {
 			/* count the sent packet */
 			switch (packet_subtype) {
 			case BATADV_P_DAT_DHT_GET:
diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index 9c561e6..5239616 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -509,7 +509,7 @@ int batadv_frag_send_packet(struct sk_buff *skb,
 		batadv_add_counter(bat_priv, BATADV_CNT_FRAG_TX_BYTES,
 				   skb_fragment->len + ETH_HLEN);
 		ret = batadv_send_unicast_skb(skb_fragment, neigh_node);
-		if (ret != NET_XMIT_SUCCESS) {
+		if (ret != NET_XMIT_SUCCESS && ret != NET_XMIT_CN) {
 			ret = NET_XMIT_DROP;
 			goto free_skb;
 		}
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 6713bdf..6b08b26 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -262,7 +262,7 @@ static int batadv_recv_my_icmp_packet(struct batadv_priv *bat_priv,
 		icmph->ttl = BATADV_TTL;
 
 		res = batadv_send_skb_to_orig(skb, orig_node, NULL);
-		if (res == NET_XMIT_SUCCESS)
+		if (res == NET_XMIT_SUCCESS || res == NET_XMIT_CN)
 			ret = NET_RX_SUCCESS;
 
 		/* skb was consumed */
@@ -330,7 +330,7 @@ static int batadv_recv_icmp_ttl_exceeded(struct batadv_priv *bat_priv,
 	icmp_packet->ttl = BATADV_TTL;
 
 	res = batadv_send_skb_to_orig(skb, orig_node, NULL);
-	if (res == NET_RX_SUCCESS)
+	if (res == NET_RX_SUCCESS || res == NET_XMIT_CN)
 		ret = NET_XMIT_SUCCESS;
 
 	/* skb was consumed */
@@ -424,7 +424,7 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 
 	/* route it */
 	res = batadv_send_skb_to_orig(skb, orig_node, recv_if);
-	if (res == NET_XMIT_SUCCESS)
+	if (res == NET_XMIT_SUCCESS || res == NET_XMIT_CN)
 		ret = NET_RX_SUCCESS;
 
 	/* skb was consumed */
@@ -719,14 +719,14 @@ static int batadv_route_unicast_packet(struct sk_buff *skb,
 
 	len = skb->len;
 	res = batadv_send_skb_to_orig(skb, orig_node, recv_if);
-	if (res == NET_XMIT_SUCCESS)
+	if (res == NET_XMIT_SUCCESS || res == NET_XMIT_CN)
 		ret = NET_RX_SUCCESS;
 
 	/* skb was consumed */
 	skb = NULL;
 
 	/* translate transmit result into receive result */
-	if (res == NET_XMIT_SUCCESS) {
+	if (res == NET_XMIT_SUCCESS || res == NET_XMIT_CN) {
 		/* skb was transmitted and consumed */
 		batadv_inc_counter(bat_priv, BATADV_CNT_FORWARD);
 		batadv_add_counter(bat_priv, BATADV_CNT_FORWARD_BYTES,
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 7b3494a..60516bb 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -386,7 +386,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 			ret = batadv_send_skb_via_tt(bat_priv, skb, dst_hint,
 						     vid);
 		}
-		if (ret != NET_XMIT_SUCCESS)
+		if (ret != NET_XMIT_SUCCESS && ret != NET_XMIT_CN)
 			goto dropped_freed;
 	}
 
diff --git a/net/batman-adv/tp_meter.c b/net/batman-adv/tp_meter.c
index f156452..44bfb1e 100644
--- a/net/batman-adv/tp_meter.c
+++ b/net/batman-adv/tp_meter.c
@@ -615,7 +615,7 @@ static int batadv_tp_send_msg(struct batadv_tp_vars *tp_vars, const u8 *src,
 	batadv_tp_fill_prerandom(tp_vars, data, data_len);
 
 	r = batadv_send_skb_to_orig(skb, orig_node, NULL);
-	if (r == NET_XMIT_SUCCESS)
+	if (r == NET_XMIT_SUCCESS || r == NET_XMIT_CN)
 		return 0;
 
 	return BATADV_TP_REASON_CANT_SEND;
-- 
1.9.1
