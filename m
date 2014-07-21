From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 1/2] batman-adv: drop QinQ claim frames in bridge loop avoidance
Date: Mon, 21 Jul 2014 09:53:30 +0200
Message-ID: <1405929211-30187-2-git-send-email-antonio@meshcoding.com>
References: <1405929211-30187-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:21857 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136AbaGUHx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 03:53:58 -0400
In-Reply-To: <1405929211-30187-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

Since bridge loop avoidance only supports untagged or simple 802.1q
tagged VLAN claim frames, claim frames with stacked VLAN headers (QinQ)
should be detected and dropped. Transporting the over the mesh may cause
problems on the receivers, or create bogus entries in the local tt
tables.

Reported-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bridge_loop_avoidance.c | 44 ++++++++++++++++++++++++++--------
 1 file changed, 34 insertions(+), 10 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 6f0d9ec..a957c81 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -800,11 +800,6 @@ static int batadv_check_claim_group(struct batadv_priv *bat_priv,
 	bla_dst = (struct batadv_bla_claim_dst *)hw_dst;
 	bla_dst_own = &bat_priv->bla.claim_dest;
 
-	/* check if it is a claim packet in general */
-	if (memcmp(bla_dst->magic, bla_dst_own->magic,
-		   sizeof(bla_dst->magic)) != 0)
-		return 0;
-
 	/* if announcement packet, use the source,
 	 * otherwise assume it is in the hw_src
 	 */
@@ -866,12 +861,13 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 				    struct batadv_hard_iface *primary_if,
 				    struct sk_buff *skb)
 {
-	struct batadv_bla_claim_dst *bla_dst;
+	struct batadv_bla_claim_dst *bla_dst, *bla_dst_own;
 	uint8_t *hw_src, *hw_dst;
-	struct vlan_ethhdr *vhdr;
+	struct vlan_hdr *vhdr, vhdr_buf;
 	struct ethhdr *ethhdr;
 	struct arphdr *arphdr;
 	unsigned short vid;
+	int vlan_depth = 0;
 	__be16 proto;
 	int headlen;
 	int ret;
@@ -882,9 +878,24 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 	proto = ethhdr->h_proto;
 	headlen = ETH_HLEN;
 	if (vid & BATADV_VLAN_HAS_TAG) {
-		vhdr = vlan_eth_hdr(skb);
-		proto = vhdr->h_vlan_encapsulated_proto;
-		headlen += VLAN_HLEN;
+		/* Traverse the VLAN/Ethertypes.
+		 *
+		 * At this point it is known that the first protocol is a VLAN
+		 * header, so start checking at the encapsulated protocol.
+		 *
+		 * The depth of the VLAN headers is recorded to drop BLA claim
+		 * frames encapsulated into multiple VLAN headers (QinQ).
+		 */
+		do {
+			vhdr = skb_header_pointer(skb, headlen, VLAN_HLEN,
+						  &vhdr_buf);
+			if (!vhdr)
+				return 0;
+
+			proto = vhdr->h_vlan_encapsulated_proto;
+			headlen += VLAN_HLEN;
+			vlan_depth++;
+		} while (proto == htons(ETH_P_8021Q));
 	}
 
 	if (proto != htons(ETH_P_ARP))
@@ -914,6 +925,19 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 	hw_src = (uint8_t *)arphdr + sizeof(struct arphdr);
 	hw_dst = hw_src + ETH_ALEN + 4;
 	bla_dst = (struct batadv_bla_claim_dst *)hw_dst;
+	bla_dst_own = &bat_priv->bla.claim_dest;
+
+	/* check if it is a claim frame in general */
+	if (memcmp(bla_dst->magic, bla_dst_own->magic,
+		   sizeof(bla_dst->magic)) != 0)
+		return 0;
+
+	/* check if there is a claim frame encapsulated deeper in (QinQ) and
+	 * drop that, as this is not supported by BLA but should also not be
+	 * sent via the mesh.
+	 */
+	if (vlan_depth > 1)
+		return 1;
 
 	/* check if it is a claim frame. */
 	ret = batadv_check_claim_group(bat_priv, primary_if, hw_src, hw_dst,
-- 
1.8.5.5
