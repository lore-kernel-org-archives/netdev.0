From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 12/17] batman-adv: Consume skb in batadv_send_skb_to_orig
Date: Wed,  9 Nov 2016 23:26:01 +0100
Message-ID: <20161109222606.29039-13-sw@simonwunderlich.de>
References: <20161109222606.29039-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:55531 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754358AbcKIW0g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 17:26:36 -0500
In-Reply-To: <20161109222606.29039-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Sending functions in Linux consume the supplied skbuff. Doing the same in
batadv_send_skb_to_orig avoids the hack of returning -1 (-EPERM) to signal
the caller that he is responsible for cleaning up the skb.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/routing.c  | 11 ++---------
 net/batman-adv/send.c     | 39 ++++++++++++++++++++++-----------------
 net/batman-adv/tp_meter.c |  6 ------
 net/batman-adv/tvlv.c     |  5 +----
 4 files changed, 25 insertions(+), 36 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index a4cb157..4d2679a 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -262,9 +262,6 @@ static int batadv_recv_my_icmp_packet(struct batadv_priv *bat_priv,
 		icmph->ttl = BATADV_TTL;
 
 		res = batadv_send_skb_to_orig(skb, orig_node, NULL);
-		if (res == -1)
-			goto out;
-
 		ret = NET_RX_SUCCESS;
 
 		break;
@@ -325,8 +322,7 @@ static int batadv_recv_icmp_ttl_exceeded(struct batadv_priv *bat_priv,
 	icmp_packet->ttl = BATADV_TTL;
 
 	res = batadv_send_skb_to_orig(skb, orig_node, NULL);
-	if (res != -1)
-		ret = NET_RX_SUCCESS;
+	ret = NET_RX_SUCCESS;
 
 out:
 	if (primary_if)
@@ -413,8 +409,7 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 
 	/* route it */
 	res = batadv_send_skb_to_orig(skb, orig_node, recv_if);
-	if (res != -1)
-		ret = NET_RX_SUCCESS;
+	ret = NET_RX_SUCCESS;
 
 out:
 	if (orig_node)
@@ -702,8 +697,6 @@ static int batadv_route_unicast_packet(struct sk_buff *skb,
 
 	len = skb->len;
 	res = batadv_send_skb_to_orig(skb, orig_node, recv_if);
-	if (res == -1)
-		goto out;
 
 	/* translate transmit result into receive result */
 	if (res == NET_XMIT_SUCCESS) {
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 0f86293..b00aac7 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -165,11 +165,9 @@ int batadv_send_unicast_skb(struct sk_buff *skb,
  * host, NULL can be passed as recv_if and no interface alternating is
  * attempted.
  *
- * Return: -1 on failure (and the skb is not consumed), -EINPROGRESS if the
- * skb is buffered for later transmit or the NET_XMIT status returned by the
+ * Return: negative errno code on a failure, -EINPROGRESS if the skb is
+ * buffered for later transmit or the NET_XMIT status returned by the
  * lower routine if the packet has been passed down.
- *
- * If the returning value is not -1 the skb has been consumed.
  */
 int batadv_send_skb_to_orig(struct sk_buff *skb,
 			    struct batadv_orig_node *orig_node,
@@ -177,12 +175,14 @@ int batadv_send_skb_to_orig(struct sk_buff *skb,
 {
 	struct batadv_priv *bat_priv = orig_node->bat_priv;
 	struct batadv_neigh_node *neigh_node;
-	int ret = -1;
+	int ret;
 
 	/* batadv_find_router() increases neigh_nodes refcount if found. */
 	neigh_node = batadv_find_router(bat_priv, orig_node, recv_if);
-	if (!neigh_node)
-		goto out;
+	if (!neigh_node) {
+		ret = -EINVAL;
+		goto free_skb;
+	}
 
 	/* Check if the skb is too large to send in one piece and fragment
 	 * it if needed.
@@ -191,8 +191,10 @@ int batadv_send_skb_to_orig(struct sk_buff *skb,
 	    skb->len > neigh_node->if_incoming->net_dev->mtu) {
 		/* Fragment and send packet. */
 		ret = batadv_frag_send_packet(skb, orig_node, neigh_node);
+		/* skb was consumed */
+		skb = NULL;
 
-		goto out;
+		goto put_neigh_node;
 	}
 
 	/* try to network code the packet, if it is received on an interface
@@ -204,9 +206,13 @@ int batadv_send_skb_to_orig(struct sk_buff *skb,
 	else
 		ret = batadv_send_unicast_skb(skb, neigh_node);
 
-out:
-	if (neigh_node)
-		batadv_neigh_node_put(neigh_node);
+	/* skb was consumed */
+	skb = NULL;
+
+put_neigh_node:
+	batadv_neigh_node_put(neigh_node);
+free_skb:
+	kfree_skb(skb);
 
 	return ret;
 }
@@ -327,7 +333,7 @@ int batadv_send_skb_unicast(struct batadv_priv *bat_priv,
 {
 	struct batadv_unicast_packet *unicast_packet;
 	struct ethhdr *ethhdr;
-	int res, ret = NET_XMIT_DROP;
+	int ret = NET_XMIT_DROP;
 
 	if (!orig_node)
 		goto out;
@@ -364,13 +370,12 @@ int batadv_send_skb_unicast(struct batadv_priv *bat_priv,
 	if (batadv_tt_global_client_is_roaming(bat_priv, ethhdr->h_dest, vid))
 		unicast_packet->ttvn = unicast_packet->ttvn - 1;
 
-	res = batadv_send_skb_to_orig(skb, orig_node, NULL);
-	if (res != -1)
-		ret = NET_XMIT_SUCCESS;
+	ret = batadv_send_skb_to_orig(skb, orig_node, NULL);
+	 /* skb was consumed */
+	skb = NULL;
 
 out:
-	if (ret == NET_XMIT_DROP)
-		kfree_skb(skb);
+	kfree_skb(skb);
 	return ret;
 }
 
diff --git a/net/batman-adv/tp_meter.c b/net/batman-adv/tp_meter.c
index 2333777..f156452 100644
--- a/net/batman-adv/tp_meter.c
+++ b/net/batman-adv/tp_meter.c
@@ -615,9 +615,6 @@ static int batadv_tp_send_msg(struct batadv_tp_vars *tp_vars, const u8 *src,
 	batadv_tp_fill_prerandom(tp_vars, data, data_len);
 
 	r = batadv_send_skb_to_orig(skb, orig_node, NULL);
-	if (r == -1)
-		kfree_skb(skb);
-
 	if (r == NET_XMIT_SUCCESS)
 		return 0;
 
@@ -1206,9 +1203,6 @@ static int batadv_tp_send_ack(struct batadv_priv *bat_priv, const u8 *dst,
 
 	/* send the ack */
 	r = batadv_send_skb_to_orig(skb, orig_node, NULL);
-	if (r == -1)
-		kfree_skb(skb);
-
 	if (unlikely(r < 0) || (r == NET_XMIT_DROP)) {
 		ret = BATADV_TP_REASON_DST_UNREACHABLE;
 		goto out;
diff --git a/net/batman-adv/tvlv.c b/net/batman-adv/tvlv.c
index 77654f0..a783420 100644
--- a/net/batman-adv/tvlv.c
+++ b/net/batman-adv/tvlv.c
@@ -600,7 +600,6 @@ void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, u8 *src,
 	unsigned char *tvlv_buff;
 	unsigned int tvlv_len;
 	ssize_t hdr_len = sizeof(*unicast_tvlv_packet);
-	int res;
 
 	orig_node = batadv_orig_hash_find(bat_priv, dst);
 	if (!orig_node)
@@ -633,9 +632,7 @@ void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, u8 *src,
 	tvlv_buff += sizeof(*tvlv_hdr);
 	memcpy(tvlv_buff, tvlv_value, tvlv_value_len);
 
-	res = batadv_send_skb_to_orig(skb, orig_node, NULL);
-	if (res == -1)
-		kfree_skb(skb);
+	batadv_send_skb_to_orig(skb, orig_node, NULL);
 out:
 	batadv_orig_node_put(orig_node);
 }
-- 
2.10.1
