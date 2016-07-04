From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 09/11] batman-adv: return netdev status in the TX path
Date: Mon,  4 Jul 2016 15:02:57 +0200
Message-ID: <1467637379-6089-10-git-send-email-sw@simonwunderlich.de>
References: <1467637379-6089-1-git-send-email-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio.quartulli@open-mesh.com>,
	Sven Eckelmann <sven.eckelmann@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:58241 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753848AbcGDNDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 09:03:14 -0400
In-Reply-To: <1467637379-6089-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio.quartulli@open-mesh.com>

Return the proper netdev TX status along the TX path so that the tp_meter
can understand when the queue is full and should stop sending packets.

Signed-off-by: Antonio Quartulli <antonio.quartulli@open-mesh.com>
Signed-off-by: Sven Eckelmann <sven.eckelmann@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/fragmentation.c | 41 +++++++++++++++++++++++++----------------
 net/batman-adv/fragmentation.h |  6 +++---
 net/batman-adv/routing.c       | 25 ++++++++++++++-----------
 net/batman-adv/send.c          | 36 +++++++++++++++++++++++-------------
 net/batman-adv/tvlv.c          |  4 +++-
 5 files changed, 68 insertions(+), 44 deletions(-)

diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index 9f41a0a..0934730 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -433,11 +433,12 @@ err:
  * @orig_node: final destination of the created fragments
  * @neigh_node: next-hop of the created fragments
  *
- * Return: true on success, false otherwise.
+ * Return: the netdev tx status or -1 in case of error.
+ * When -1 is returned the skb is not consumed.
  */
-bool batadv_frag_send_packet(struct sk_buff *skb,
-			     struct batadv_orig_node *orig_node,
-			     struct batadv_neigh_node *neigh_node)
+int batadv_frag_send_packet(struct sk_buff *skb,
+			    struct batadv_orig_node *orig_node,
+			    struct batadv_neigh_node *neigh_node)
 {
 	struct batadv_priv *bat_priv;
 	struct batadv_hard_iface *primary_if = NULL;
@@ -446,7 +447,7 @@ bool batadv_frag_send_packet(struct sk_buff *skb,
 	unsigned int mtu = neigh_node->if_incoming->net_dev->mtu;
 	unsigned int header_size = sizeof(frag_header);
 	unsigned int max_fragment_size, max_packet_size;
-	bool ret = false;
+	int ret = -1;
 
 	/* To avoid merge and refragmentation at next-hops we never send
 	 * fragments larger than BATADV_FRAG_MAX_FRAG_SIZE
@@ -457,12 +458,12 @@ bool batadv_frag_send_packet(struct sk_buff *skb,
 
 	/* Don't even try to fragment, if we need more than 16 fragments */
 	if (skb->len > max_packet_size)
-		goto out_err;
+		goto out;
 
 	bat_priv = orig_node->bat_priv;
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
-		goto out_err;
+		goto out;
 
 	/* Create one header to be copied to all fragments */
 	frag_header.packet_type = BATADV_UNICAST_FRAG;
@@ -488,23 +489,33 @@ bool batadv_frag_send_packet(struct sk_buff *skb,
 	while (skb->len > max_fragment_size) {
 		skb_fragment = batadv_frag_create(skb, &frag_header, mtu);
 		if (!skb_fragment)
-			goto out_err;
+			goto out;
 
 		batadv_inc_counter(bat_priv, BATADV_CNT_FRAG_TX);
 		batadv_add_counter(bat_priv, BATADV_CNT_FRAG_TX_BYTES,
 				   skb_fragment->len + ETH_HLEN);
-		batadv_send_unicast_skb(skb_fragment, neigh_node);
+		ret = batadv_send_unicast_skb(skb_fragment, neigh_node);
+		if (ret != NET_XMIT_SUCCESS) {
+			/* return -1 so that the caller can free the original
+			 * skb
+			 */
+			ret = -1;
+			goto out;
+		}
+
 		frag_header.no++;
 
 		/* The initial check in this function should cover this case */
-		if (frag_header.no == BATADV_FRAG_MAX_FRAGMENTS - 1)
-			goto out_err;
+		if (frag_header.no == BATADV_FRAG_MAX_FRAGMENTS - 1) {
+			ret = -1;
+			goto out;
+		}
 	}
 
 	/* Make room for the fragment header. */
 	if (batadv_skb_head_push(skb, header_size) < 0 ||
 	    pskb_expand_head(skb, header_size + ETH_HLEN, 0, GFP_ATOMIC) < 0)
-		goto out_err;
+		goto out;
 
 	memcpy(skb->data, &frag_header, header_size);
 
@@ -512,11 +523,9 @@ bool batadv_frag_send_packet(struct sk_buff *skb,
 	batadv_inc_counter(bat_priv, BATADV_CNT_FRAG_TX);
 	batadv_add_counter(bat_priv, BATADV_CNT_FRAG_TX_BYTES,
 			   skb->len + ETH_HLEN);
-	batadv_send_unicast_skb(skb, neigh_node);
+	ret = batadv_send_unicast_skb(skb, neigh_node);
 
-	ret = true;
-
-out_err:
+out:
 	if (primary_if)
 		batadv_hardif_put(primary_if);
 
diff --git a/net/batman-adv/fragmentation.h b/net/batman-adv/fragmentation.h
index 9ff77c7..3202fe3 100644
--- a/net/batman-adv/fragmentation.h
+++ b/net/batman-adv/fragmentation.h
@@ -34,9 +34,9 @@ bool batadv_frag_skb_fwd(struct sk_buff *skb,
 			 struct batadv_orig_node *orig_node_src);
 bool batadv_frag_skb_buffer(struct sk_buff **skb,
 			    struct batadv_orig_node *orig_node);
-bool batadv_frag_send_packet(struct sk_buff *skb,
-			     struct batadv_orig_node *orig_node,
-			     struct batadv_neigh_node *neigh_node);
+int batadv_frag_send_packet(struct sk_buff *skb,
+			    struct batadv_orig_node *orig_node,
+			    struct batadv_neigh_node *neigh_node);
 
 /**
  * batadv_frag_check_entry - check if a list of fragments has timed out
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 5833ab3..76de583 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -270,8 +270,10 @@ static int batadv_recv_my_icmp_packet(struct batadv_priv *bat_priv,
 		icmph->ttl = BATADV_TTL;
 
 		res = batadv_send_skb_to_orig(skb, orig_node, NULL);
-		if (res != NET_XMIT_DROP)
-			ret = NET_RX_SUCCESS;
+		if (res == -1)
+			goto out;
+
+		ret = NET_RX_SUCCESS;
 
 		break;
 	default:
@@ -292,7 +294,7 @@ static int batadv_recv_icmp_ttl_exceeded(struct batadv_priv *bat_priv,
 	struct batadv_hard_iface *primary_if = NULL;
 	struct batadv_orig_node *orig_node = NULL;
 	struct batadv_icmp_packet *icmp_packet;
-	int ret = NET_RX_DROP;
+	int res, ret = NET_RX_DROP;
 
 	icmp_packet = (struct batadv_icmp_packet *)skb->data;
 
@@ -323,7 +325,8 @@ static int batadv_recv_icmp_ttl_exceeded(struct batadv_priv *bat_priv,
 	icmp_packet->msg_type = BATADV_TTL_EXCEEDED;
 	icmp_packet->ttl = BATADV_TTL;
 
-	if (batadv_send_skb_to_orig(skb, orig_node, NULL) != NET_XMIT_DROP)
+	res = batadv_send_skb_to_orig(skb, orig_node, NULL);
+	if (res != -1)
 		ret = NET_RX_SUCCESS;
 
 out:
@@ -343,7 +346,7 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 	struct ethhdr *ethhdr;
 	struct batadv_orig_node *orig_node = NULL;
 	int hdr_size = sizeof(struct batadv_icmp_header);
-	int ret = NET_RX_DROP;
+	int res, ret = NET_RX_DROP;
 
 	/* drop packet if it has not necessary minimum size */
 	if (unlikely(!pskb_may_pull(skb, hdr_size)))
@@ -409,7 +412,8 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 	icmph->ttl--;
 
 	/* route it */
-	if (batadv_send_skb_to_orig(skb, orig_node, recv_if) != NET_XMIT_DROP)
+	res = batadv_send_skb_to_orig(skb, orig_node, recv_if);
+	if (res != -1)
 		ret = NET_RX_SUCCESS;
 
 out:
@@ -646,6 +650,8 @@ static int batadv_route_unicast_packet(struct sk_buff *skb,
 
 	len = skb->len;
 	res = batadv_send_skb_to_orig(skb, orig_node, recv_if);
+	if (res == -1)
+		goto out;
 
 	/* translate transmit result into receive result */
 	if (res == NET_XMIT_SUCCESS) {
@@ -653,13 +659,10 @@ static int batadv_route_unicast_packet(struct sk_buff *skb,
 		batadv_inc_counter(bat_priv, BATADV_CNT_FORWARD);
 		batadv_add_counter(bat_priv, BATADV_CNT_FORWARD_BYTES,
 				   len + ETH_HLEN);
-
-		ret = NET_RX_SUCCESS;
-	} else if (res == -EINPROGRESS) {
-		/* skb was buffered and consumed */
-		ret = NET_RX_SUCCESS;
 	}
 
+	ret = NET_RX_SUCCESS;
+
 out:
 	if (orig_node)
 		batadv_orig_node_put(orig_node);
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 3a59df2..3a10d87 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -20,6 +20,7 @@
 
 #include <linux/atomic.h>
 #include <linux/byteorder/generic.h>
+#include <linux/errno.h>
 #include <linux/etherdevice.h>
 #include <linux/fs.h>
 #include <linux/if.h>
@@ -72,6 +73,7 @@ int batadv_send_skb_packet(struct sk_buff *skb,
 {
 	struct batadv_priv *bat_priv;
 	struct ethhdr *ethhdr;
+	int ret;
 
 	bat_priv = netdev_priv(hard_iface->soft_iface);
 
@@ -109,8 +111,15 @@ int batadv_send_skb_packet(struct sk_buff *skb,
 	/* dev_queue_xmit() returns a negative result on error.	 However on
 	 * congestion and traffic shaping, it drops and returns NET_XMIT_DROP
 	 * (which is > 0). This will not be treated as an error.
+	 *
+	 * a negative value cannot be returned because it could be interepreted
+	 * as not consumed skb by callers of batadv_send_skb_to_orig.
 	 */
-	return dev_queue_xmit(skb);
+	ret = dev_queue_xmit(skb);
+	if (ret < 0)
+		ret = NET_XMIT_DROP;
+
+	return ret;
 send_skb_err:
 	kfree_skb(skb);
 	return NET_XMIT_DROP;
@@ -156,8 +165,11 @@ int batadv_send_unicast_skb(struct sk_buff *skb,
  * host, NULL can be passed as recv_if and no interface alternating is
  * attempted.
  *
- * Return: NET_XMIT_SUCCESS on success, NET_XMIT_DROP on failure, or
- * -EINPROGRESS if the skb is buffered for later transmit.
+ * Return: -1 on failure (and the skb is not consumed), -EINPROGRESS if the
+ * skb is buffered for later transmit or the NET_XMIT status returned by the
+ * lower routine if the packet has been passed down.
+ *
+ * If the returning value is not -1 the skb has been consumed.
  */
 int batadv_send_skb_to_orig(struct sk_buff *skb,
 			    struct batadv_orig_node *orig_node,
@@ -165,7 +177,7 @@ int batadv_send_skb_to_orig(struct sk_buff *skb,
 {
 	struct batadv_priv *bat_priv = orig_node->bat_priv;
 	struct batadv_neigh_node *neigh_node;
-	int ret = NET_XMIT_DROP;
+	int ret = -1;
 
 	/* batadv_find_router() increases neigh_nodes refcount if found. */
 	neigh_node = batadv_find_router(bat_priv, orig_node, recv_if);
@@ -178,8 +190,7 @@ int batadv_send_skb_to_orig(struct sk_buff *skb,
 	if (atomic_read(&bat_priv->fragmentation) &&
 	    skb->len > neigh_node->if_incoming->net_dev->mtu) {
 		/* Fragment and send packet. */
-		if (batadv_frag_send_packet(skb, orig_node, neigh_node))
-			ret = NET_XMIT_SUCCESS;
+		ret = batadv_frag_send_packet(skb, orig_node, neigh_node);
 
 		goto out;
 	}
@@ -188,12 +199,10 @@ int batadv_send_skb_to_orig(struct sk_buff *skb,
 	 * (i.e. being forwarded). If the packet originates from this node or if
 	 * network coding fails, then send the packet as usual.
 	 */
-	if (recv_if && batadv_nc_skb_forward(skb, neigh_node)) {
+	if (recv_if && batadv_nc_skb_forward(skb, neigh_node))
 		ret = -EINPROGRESS;
-	} else {
-		batadv_send_unicast_skb(skb, neigh_node);
-		ret = NET_XMIT_SUCCESS;
-	}
+	else
+		ret = batadv_send_unicast_skb(skb, neigh_node);
 
 out:
 	if (neigh_node)
@@ -319,7 +328,7 @@ int batadv_send_skb_unicast(struct batadv_priv *bat_priv,
 {
 	struct batadv_unicast_packet *unicast_packet;
 	struct ethhdr *ethhdr;
-	int ret = NET_XMIT_DROP;
+	int res, ret = NET_XMIT_DROP;
 
 	if (!orig_node)
 		goto out;
@@ -356,7 +365,8 @@ int batadv_send_skb_unicast(struct batadv_priv *bat_priv,
 	if (batadv_tt_global_client_is_roaming(bat_priv, ethhdr->h_dest, vid))
 		unicast_packet->ttvn = unicast_packet->ttvn - 1;
 
-	if (batadv_send_skb_to_orig(skb, orig_node, NULL) != NET_XMIT_DROP)
+	res = batadv_send_skb_to_orig(skb, orig_node, NULL);
+	if (res != -1)
 		ret = NET_XMIT_SUCCESS;
 
 out:
diff --git a/net/batman-adv/tvlv.c b/net/batman-adv/tvlv.c
index 2fd542e..3d1cf0f 100644
--- a/net/batman-adv/tvlv.c
+++ b/net/batman-adv/tvlv.c
@@ -591,6 +591,7 @@ void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, u8 *src,
 	unsigned char *tvlv_buff;
 	unsigned int tvlv_len;
 	ssize_t hdr_len = sizeof(*unicast_tvlv_packet);
+	int res;
 
 	orig_node = batadv_orig_hash_find(bat_priv, dst);
 	if (!orig_node)
@@ -623,7 +624,8 @@ void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, u8 *src,
 	tvlv_buff += sizeof(*tvlv_hdr);
 	memcpy(tvlv_buff, tvlv_value, tvlv_value_len);
 
-	if (batadv_send_skb_to_orig(skb, orig_node, NULL) == NET_XMIT_DROP)
+	res = batadv_send_skb_to_orig(skb, orig_node, NULL);
+	if (res == -1)
 		kfree_skb(skb);
 out:
 	batadv_orig_node_put(orig_node);
-- 
2.8.1
