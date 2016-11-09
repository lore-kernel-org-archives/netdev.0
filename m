From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 11/17] batman-adv: Consume skb in batadv_frag_send_packet
Date: Wed,  9 Nov 2016 23:26:00 +0100
Message-ID: <20161109222606.29039-12-sw@simonwunderlich.de>
References: <20161109222606.29039-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:55527 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752796AbcKIW0f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 17:26:35 -0500
In-Reply-To: <20161109222606.29039-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Sending functions in Linux consume the supplied skbuff. Doing the same in
batadv_frag_send_packet avoids the hack of returning -1 (-EPERM) to signal
the caller that he is responsible for cleaning up the skb.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/fragmentation.c | 50 ++++++++++++++++++++++++------------------
 1 file changed, 29 insertions(+), 21 deletions(-)

diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index a2e28a1..9c561e6 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -20,6 +20,7 @@
 
 #include <linux/atomic.h>
 #include <linux/byteorder/generic.h>
+#include <linux/errno.h>
 #include <linux/etherdevice.h>
 #include <linux/fs.h>
 #include <linux/if_ether.h>
@@ -441,8 +442,7 @@ static struct sk_buff *batadv_frag_create(struct sk_buff *skb,
  * @orig_node: final destination of the created fragments
  * @neigh_node: next-hop of the created fragments
  *
- * Return: the netdev tx status or -1 in case of error.
- * When -1 is returned the skb is not consumed.
+ * Return: the netdev tx status or a negative errno code on a failure
  */
 int batadv_frag_send_packet(struct sk_buff *skb,
 			    struct batadv_orig_node *orig_node,
@@ -455,7 +455,7 @@ int batadv_frag_send_packet(struct sk_buff *skb,
 	unsigned int mtu = neigh_node->if_incoming->net_dev->mtu;
 	unsigned int header_size = sizeof(frag_header);
 	unsigned int max_fragment_size, max_packet_size;
-	int ret = -1;
+	int ret;
 
 	/* To avoid merge and refragmentation at next-hops we never send
 	 * fragments larger than BATADV_FRAG_MAX_FRAG_SIZE
@@ -465,13 +465,17 @@ int batadv_frag_send_packet(struct sk_buff *skb,
 	max_packet_size = max_fragment_size * BATADV_FRAG_MAX_FRAGMENTS;
 
 	/* Don't even try to fragment, if we need more than 16 fragments */
-	if (skb->len > max_packet_size)
-		goto out;
+	if (skb->len > max_packet_size) {
+		ret = -EAGAIN;
+		goto free_skb;
+	}
 
 	bat_priv = orig_node->bat_priv;
 	primary_if = batadv_primary_if_get_selected(bat_priv);
-	if (!primary_if)
-		goto out;
+	if (!primary_if) {
+		ret = -EINVAL;
+		goto put_primary_if;
+	}
 
 	/* Create one header to be copied to all fragments */
 	frag_header.packet_type = BATADV_UNICAST_FRAG;
@@ -496,34 +500,35 @@ int batadv_frag_send_packet(struct sk_buff *skb,
 	/* Eat and send fragments from the tail of skb */
 	while (skb->len > max_fragment_size) {
 		skb_fragment = batadv_frag_create(skb, &frag_header, mtu);
-		if (!skb_fragment)
-			goto out;
+		if (!skb_fragment) {
+			ret = -ENOMEM;
+			goto free_skb;
+		}
 
 		batadv_inc_counter(bat_priv, BATADV_CNT_FRAG_TX);
 		batadv_add_counter(bat_priv, BATADV_CNT_FRAG_TX_BYTES,
 				   skb_fragment->len + ETH_HLEN);
 		ret = batadv_send_unicast_skb(skb_fragment, neigh_node);
 		if (ret != NET_XMIT_SUCCESS) {
-			/* return -1 so that the caller can free the original
-			 * skb
-			 */
-			ret = -1;
-			goto out;
+			ret = NET_XMIT_DROP;
+			goto free_skb;
 		}
 
 		frag_header.no++;
 
 		/* The initial check in this function should cover this case */
 		if (frag_header.no == BATADV_FRAG_MAX_FRAGMENTS - 1) {
-			ret = -1;
-			goto out;
+			ret = -EINVAL;
+			goto free_skb;
 		}
 	}
 
 	/* Make room for the fragment header. */
 	if (batadv_skb_head_push(skb, header_size) < 0 ||
-	    pskb_expand_head(skb, header_size + ETH_HLEN, 0, GFP_ATOMIC) < 0)
-		goto out;
+	    pskb_expand_head(skb, header_size + ETH_HLEN, 0, GFP_ATOMIC) < 0) {
+		ret = -ENOMEM;
+		goto free_skb;
+	}
 
 	memcpy(skb->data, &frag_header, header_size);
 
@@ -532,10 +537,13 @@ int batadv_frag_send_packet(struct sk_buff *skb,
 	batadv_add_counter(bat_priv, BATADV_CNT_FRAG_TX_BYTES,
 			   skb->len + ETH_HLEN);
 	ret = batadv_send_unicast_skb(skb, neigh_node);
+	/* skb was consumed */
+	skb = NULL;
 
-out:
-	if (primary_if)
-		batadv_hardif_put(primary_if);
+put_primary_if:
+	batadv_hardif_put(primary_if);
+free_skb:
+	kfree_skb(skb);
 
 	return ret;
 }
-- 
2.10.1
