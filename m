From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 13/18] batman-adv: Use BIT(x) macro to calculate bit positions
Date: Thu, 23 Aug 2012 15:10:22 +0200
Message-ID: <1345727427-20805-14-git-send-email-ordex@autistici.org>
References: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:28925 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933706Ab2HWNLC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:11:02 -0400
In-Reply-To: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c |   12 +++++++-----
 net/batman-adv/main.h       |   18 +++++++++---------
 net/batman-adv/packet.h     |   30 +++++++++++++++---------------
 3 files changed, 31 insertions(+), 29 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index eb507c9..daaccc1 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -181,8 +181,8 @@ static void batadv_iv_ogm_send_to_if(struct batadv_forw_packet *forw_packet,
 		/* we might have aggregated direct link packets with an
 		 * ordinary base packet
 		 */
-		if ((forw_packet->direct_link_flags & (1 << packet_num)) &&
-		    (forw_packet->if_incoming == hard_iface))
+		if (forw_packet->direct_link_flags & BIT(packet_num) &&
+		    forw_packet->if_incoming == hard_iface)
 			batadv_ogm_packet->flags |= BATADV_DIRECTLINK;
 		else
 			batadv_ogm_packet->flags &= ~BATADV_DIRECTLINK;
@@ -454,6 +454,7 @@ static void batadv_iv_ogm_aggregate(struct batadv_forw_packet *forw_packet_aggr,
 				    int packet_len, bool direct_link)
 {
 	unsigned char *skb_buff;
+	unsigned long new_direct_link_flag;
 
 	skb_buff = skb_put(forw_packet_aggr->skb, packet_len);
 	memcpy(skb_buff, packet_buff, packet_len);
@@ -461,9 +462,10 @@ static void batadv_iv_ogm_aggregate(struct batadv_forw_packet *forw_packet_aggr,
 	forw_packet_aggr->num_packets++;
 
 	/* save packet direct link flag status */
-	if (direct_link)
-		forw_packet_aggr->direct_link_flags |=
-			(1 << forw_packet_aggr->num_packets);
+	if (direct_link) {
+		new_direct_link_flag = BIT(forw_packet_aggr->num_packets);
+		forw_packet_aggr->direct_link_flags |= new_direct_link_flag;
+	}
 }
 
 static void batadv_iv_ogm_queue_add(struct batadv_priv *bat_priv,
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 4dfeae5..574fca1 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -123,15 +123,6 @@ enum batadv_uev_type {
 /* Append 'batman-adv: ' before kernel messages */
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
-/* all messages related to routing / flooding / broadcasting / etc */
-enum batadv_dbg_level {
-	BATADV_DBG_BATMAN = 1 << 0,
-	BATADV_DBG_ROUTES = 1 << 1, /* route added / changed / deleted */
-	BATADV_DBG_TT	  = 1 << 2, /* translation table operations */
-	BATADV_DBG_BLA    = 1 << 3, /* bridge loop avoidance */
-	BATADV_DBG_ALL    = 15,
-};
-
 /* Kernel headers */
 
 #include <linux/mutex.h>	/* mutex */
@@ -173,6 +164,15 @@ int batadv_algo_register(struct batadv_algo_ops *bat_algo_ops);
 int batadv_algo_select(struct batadv_priv *bat_priv, char *name);
 int batadv_algo_seq_print_text(struct seq_file *seq, void *offset);
 
+/* all messages related to routing / flooding / broadcasting / etc */
+enum batadv_dbg_level {
+	BATADV_DBG_BATMAN = BIT(0),
+	BATADV_DBG_ROUTES = BIT(1), /* route added / changed / deleted */
+	BATADV_DBG_TT	  = BIT(2), /* translation table operations */
+	BATADV_DBG_BLA    = BIT(3), /* bridge loop avoidance */
+	BATADV_DBG_ALL    = 15,
+};
+
 #ifdef CONFIG_BATMAN_ADV_DEBUG
 int batadv_debug_log(struct batadv_priv *bat_priv, const char *fmt, ...)
 __printf(2, 3);
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 65d66e4..eb45934 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -37,10 +37,10 @@ enum batadv_packettype {
 #define BATADV_COMPAT_VERSION 14
 
 enum batadv_iv_flags {
-	BATADV_NOT_BEST_NEXT_HOP   = 1 << 3,
-	BATADV_PRIMARIES_FIRST_HOP = 1 << 4,
-	BATADV_VIS_SERVER	   = 1 << 5,
-	BATADV_DIRECTLINK	   = 1 << 6,
+	BATADV_NOT_BEST_NEXT_HOP   = BIT(3),
+	BATADV_PRIMARIES_FIRST_HOP = BIT(4),
+	BATADV_VIS_SERVER	   = BIT(5),
+	BATADV_DIRECTLINK	   = BIT(6),
 };
 
 /* ICMP message types */
@@ -60,8 +60,8 @@ enum batadv_vis_packettype {
 
 /* fragmentation defines */
 enum batadv_unicast_frag_flags {
-	BATADV_UNI_FRAG_HEAD	  = 1 << 0,
-	BATADV_UNI_FRAG_LARGETAIL = 1 << 1,
+	BATADV_UNI_FRAG_HEAD	  = BIT(0),
+	BATADV_UNI_FRAG_LARGETAIL = BIT(1),
 };
 
 /* TT_QUERY subtypes */
@@ -74,20 +74,20 @@ enum batadv_tt_query_packettype {
 
 /* TT_QUERY flags */
 enum batadv_tt_query_flags {
-	BATADV_TT_FULL_TABLE = 1 << 2,
+	BATADV_TT_FULL_TABLE = BIT(2),
 };
 
 /* BATADV_TT_CLIENT flags.
- * Flags from 1 to 1 << 7 are sent on the wire, while flags from 1 << 8 to
- * 1 << 15 are used for local computation only
+ * Flags from BIT(0) to BIT(7) are sent on the wire, while flags from BIT(8) to
+ * BIT(15) are used for local computation only
  */
 enum batadv_tt_client_flags {
-	BATADV_TT_CLIENT_DEL     = 1 << 0,
-	BATADV_TT_CLIENT_ROAM    = 1 << 1,
-	BATADV_TT_CLIENT_WIFI    = 1 << 2,
-	BATADV_TT_CLIENT_NOPURGE = 1 << 8,
-	BATADV_TT_CLIENT_NEW     = 1 << 9,
-	BATADV_TT_CLIENT_PENDING = 1 << 10,
+	BATADV_TT_CLIENT_DEL     = BIT(0),
+	BATADV_TT_CLIENT_ROAM    = BIT(1),
+	BATADV_TT_CLIENT_WIFI    = BIT(2),
+	BATADV_TT_CLIENT_NOPURGE = BIT(8),
+	BATADV_TT_CLIENT_NEW     = BIT(9),
+	BATADV_TT_CLIENT_PENDING = BIT(10),
 };
 
 /* claim frame types for the bridge loop avoidance */
-- 
1.7.9.4
