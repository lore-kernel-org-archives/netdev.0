From: fgao@ikuai8.com
Subject: [PATCH net v2 1/1] net: batman-adv: Treat NET_XMIT_CN as transmit successfully
Date: Mon, 21 Nov 2016 18:58:42 +0800
Message-ID: <1479725922-5112-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: mareklindner@neomailbox.ch, sw@simonwunderlich.de, a@unstable.cc,
        davem@davemloft.net, b.a.t.m.a.n@lists.open-mesh.org,
        netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg278.qq.com ([113.108.11.203]:38492 "EHLO smtpbg278.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752075AbcKUK7b (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 05:59:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

The tc could return NET_XMIT_CN as one congestion notification, but
it does not mean the packet is lost. Other modules like ipvlan,
macvlan, and others treat NET_XMIT_CN as success too.

So batman-adv should add the NET_XMIT_CN check.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v2: Correct two typo "packe" and "ret"
 v1: Initial version

 net/batman-adv/distributed-arp-table.c | 2 +-
 net/batman-adv/fragmentation.c         | 2 +-
 net/batman-adv/routing.c               | 2 +-
 net/batman-adv/tp_meter.c              | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index e257efd..4bf0622 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -660,7 +660,7 @@ static bool batadv_dat_send_data(struct batadv_priv *bat_priv,
 		}
 
 		send_status = batadv_send_unicast_skb(tmp_skb, neigh_node);
-		if (send_status == NET_XMIT_SUCCESS) {
+		if (send_status == NET_XMIT_SUCCESS || send_status == NET_XMIT_CN) {
 			/* count the sent packet */
 			switch (packet_subtype) {
 			case BATADV_P_DAT_DHT_GET:
diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index 0934730..4714b8f 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -495,7 +495,7 @@ int batadv_frag_send_packet(struct sk_buff *skb,
 		batadv_add_counter(bat_priv, BATADV_CNT_FRAG_TX_BYTES,
 				   skb_fragment->len + ETH_HLEN);
 		ret = batadv_send_unicast_skb(skb_fragment, neigh_node);
-		if (ret != NET_XMIT_SUCCESS) {
+		if (ret != NET_XMIT_SUCCESS && ret != NET_XMIT_CN) {
 			/* return -1 so that the caller can free the original
 			 * skb
 			 */
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 7e8dc64..f44fb07 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -706,7 +706,7 @@ static int batadv_route_unicast_packet(struct sk_buff *skb,
 		goto out;
 
 	/* translate transmit result into receive result */
-	if (res == NET_XMIT_SUCCESS) {
+	if (res == NET_XMIT_SUCCESS || res == NET_XMIT_CN) {
 		/* skb was transmitted and consumed */
 		batadv_inc_counter(bat_priv, BATADV_CNT_FORWARD);
 		batadv_add_counter(bat_priv, BATADV_CNT_FORWARD_BYTES,
diff --git a/net/batman-adv/tp_meter.c b/net/batman-adv/tp_meter.c
index 8af1611..461dbad 100644
--- a/net/batman-adv/tp_meter.c
+++ b/net/batman-adv/tp_meter.c
@@ -618,7 +618,7 @@ static int batadv_tp_send_msg(struct batadv_tp_vars *tp_vars, const u8 *src,
 	if (r == -1)
 		kfree_skb(skb);
 
-	if (r == NET_XMIT_SUCCESS)
+	if (r == NET_XMIT_SUCCESS || r == NET_XMIT_CN)
 		return 0;
 
 	return BATADV_TP_REASON_CANT_SEND;
-- 
1.9.1
