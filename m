From: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
Subject: [PATCH 3/7] batman-adv: fix size of
	batadv_icmp_header
Date: Sat, 28 Dec 2013 17:05:56 +0100
Message-ID: <1388246760-3335-4-git-send-email-antonio@meshcoding.com>
References: <1388246760-3335-1-git-send-email-antonio@meshcoding.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>,
 Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1388246760-3335-1-git-send-email-antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

struct batadv_icmp_header currently has a size of 17, which
will be padded to 20 on some architectures. Fix this by
unrolling the header into the parent structures.

Moreover keep the ICMP parsing functions as generic as they
are now by using a stub icmp_header struct during packet
parsing.

Signed-off-by: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
---
 net/batman-adv/main.c    |  4 ++--
 net/batman-adv/packet.h  | 40 +++++++++++++++++++++++++++++++++++-----
 net/batman-adv/routing.c | 14 +++++++-------
 3 files changed, 44 insertions(+), 14 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index d87778b..1511f64 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -426,8 +426,8 @@ static void batadv_recv_handler_init(void)
 	BUILD_BUG_ON(offsetof(struct batadv_unicast_packet, dest) != 4);
 	BUILD_BUG_ON(offsetof(struct batadv_unicast_tvlv_packet, dst) != 4);
 	BUILD_BUG_ON(offsetof(struct batadv_frag_packet, dest) != 4);
-	BUILD_BUG_ON(offsetof(struct batadv_icmp_packet, icmph.dst) != 4);
-	BUILD_BUG_ON(offsetof(struct batadv_icmp_packet_rr, icmph.dst) != 4);
+	BUILD_BUG_ON(offsetof(struct batadv_icmp_packet, dst) != 4);
+	BUILD_BUG_ON(offsetof(struct batadv_icmp_packet_rr, dst) != 4);
 
 	/* broadcast packet */
 	batadv_rx_handler[BATADV_BCAST] = batadv_recv_bcast_packet;
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 175ce7d..2a857ed 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -191,7 +191,7 @@ struct batadv_ogm_packet {
 #define BATADV_OGM_HLEN sizeof(struct batadv_ogm_packet)
 
 /**
- * batadv_icmp_header - common ICMP header
+ * batadv_icmp_header - common members among all the ICMP packets
  * @packet_type: batman-adv packet type, part of the general header
  * @version: batman-adv protocol version, part of the genereal header
  * @ttl: time to live for this packet, part of the genereal header
@@ -199,6 +199,11 @@ struct batadv_ogm_packet {
  * @dst: address of the destination node
  * @orig: address of the source node
  * @uid: local ICMP socket identifier
+ * @align: not used - useful for alignment purposes only
+ *
+ * This structure is used for ICMP packets parsing only and it is never sent
+ * over the wire. The alignment field at the end is there to ensure that
+ * members are padded the same way as they are in real packets.
  */
 struct batadv_icmp_header {
 	uint8_t  packet_type;
@@ -208,16 +213,29 @@ struct batadv_icmp_header {
 	uint8_t  dst[ETH_ALEN];
 	uint8_t  orig[ETH_ALEN];
 	uint8_t  uid;
+	uint8_t  align[3];
 };
 
 /**
  * batadv_icmp_packet - ICMP packet
- * @icmph: common ICMP header
+ * @packet_type: batman-adv packet type, part of the general header
+ * @version: batman-adv protocol version, part of the genereal header
+ * @ttl: time to live for this packet, part of the genereal header
+ * @msg_type: ICMP packet type
+ * @dst: address of the destination node
+ * @orig: address of the source node
+ * @uid: local ICMP socket identifier
  * @reserved: not used - useful for alignment
  * @seqno: ICMP sequence number
  */
 struct batadv_icmp_packet {
-	struct batadv_icmp_header icmph;
+	uint8_t  packet_type;
+	uint8_t  version;
+	uint8_t  ttl;
+	uint8_t  msg_type; /* see ICMP message types above */
+	uint8_t  dst[ETH_ALEN];
+	uint8_t  orig[ETH_ALEN];
+	uint8_t  uid;
 	uint8_t  reserved;
 	__be16   seqno;
 };
@@ -226,13 +244,25 @@ struct batadv_icmp_packet {
 
 /**
  * batadv_icmp_packet_rr - ICMP RouteRecord packet
- * @icmph: common ICMP header
+ * @packet_type: batman-adv packet type, part of the general header
+ * @version: batman-adv protocol version, part of the genereal header
+ * @ttl: time to live for this packet, part of the genereal header
+ * @msg_type: ICMP packet type
+ * @dst: address of the destination node
+ * @orig: address of the source node
+ * @uid: local ICMP socket identifier
  * @rr_cur: number of entries the rr array
  * @seqno: ICMP sequence number
  * @rr: route record array
  */
 struct batadv_icmp_packet_rr {
-	struct batadv_icmp_header icmph;
+	uint8_t  packet_type;
+	uint8_t  version;
+	uint8_t  ttl;
+	uint8_t  msg_type; /* see ICMP message types above */
+	uint8_t  dst[ETH_ALEN];
+	uint8_t  orig[ETH_ALEN];
+	uint8_t  uid;
 	uint8_t  rr_cur;
 	__be16   seqno;
 	uint8_t  rr[BATADV_RR_LEN][ETH_ALEN];
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 5b52d71..46278bf 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -338,9 +338,9 @@ static int batadv_recv_icmp_ttl_exceeded(struct batadv_priv *bat_priv,
 	icmp_packet = (struct batadv_icmp_packet *)skb->data;
 
 	/* send TTL exceeded if packet is an echo request (traceroute) */
-	if (icmp_packet->icmph.msg_type != BATADV_ECHO_REQUEST) {
+	if (icmp_packet->msg_type != BATADV_ECHO_REQUEST) {
 		pr_debug("Warning - can't forward icmp packet from %pM to %pM: ttl exceeded\n",
-			 icmp_packet->icmph.orig, icmp_packet->icmph.dst);
+			 icmp_packet->orig, icmp_packet->dst);
 		goto out;
 	}
 
@@ -349,7 +349,7 @@ static int batadv_recv_icmp_ttl_exceeded(struct batadv_priv *bat_priv,
 		goto out;
 
 	/* get routing information */
-	orig_node = batadv_orig_hash_find(bat_priv, icmp_packet->icmph.orig);
+	orig_node = batadv_orig_hash_find(bat_priv, icmp_packet->orig);
 	if (!orig_node)
 		goto out;
 
@@ -359,11 +359,11 @@ static int batadv_recv_icmp_ttl_exceeded(struct batadv_priv *bat_priv,
 
 	icmp_packet = (struct batadv_icmp_packet *)skb->data;
 
-	memcpy(icmp_packet->icmph.dst, icmp_packet->icmph.orig, ETH_ALEN);
-	memcpy(icmp_packet->icmph.orig, primary_if->net_dev->dev_addr,
+	memcpy(icmp_packet->dst, icmp_packet->orig, ETH_ALEN);
+	memcpy(icmp_packet->orig, primary_if->net_dev->dev_addr,
 	       ETH_ALEN);
-	icmp_packet->icmph.msg_type = BATADV_TTL_EXCEEDED;
-	icmp_packet->icmph.ttl = BATADV_TTL;
+	icmp_packet->msg_type = BATADV_TTL_EXCEEDED;
+	icmp_packet->ttl = BATADV_TTL;
 
 	if (batadv_send_skb_to_orig(skb, orig_node, NULL) != NET_XMIT_DROP)
 		ret = NET_RX_SUCCESS;
-- 
1.8.5.2
