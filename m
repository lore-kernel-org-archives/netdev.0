From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 5/6] batman-adv: aggregation checks should use the primary_if pointer
Date: Tue,  5 Jul 2011 15:43:59 +0200
Message-ID: <1309873440-11704-6-git-send-email-lindner_marek@yahoo.de>
References: <1309873440-11704-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm9.bullet.mail.ukl.yahoo.com ([217.146.182.250]:24343 "HELO
	nm9.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751725Ab1GENo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 09:44:26 -0400
In-Reply-To: <1309873440-11704-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The packet aggregation needs to ensure that only compatible packets
are aggregated. Some of the checks are based on the interface number
while assuming that the first interface also is the primary interface
which is not always the case.
This patch addresses the issue by using the primary_if pointer.

Reported-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/aggregation.c |   25 ++++++++++++++++++++-----
 1 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/aggregation.c b/net/batman-adv/aggregation.c
index c583e04..69467fe 100644
--- a/net/batman-adv/aggregation.c
+++ b/net/batman-adv/aggregation.c
@@ -28,6 +28,7 @@
 
 /* return true if new_packet can be aggregated with forw_packet */
 static bool can_aggregate_with(const struct batman_packet *new_batman_packet,
+			       struct bat_priv *bat_priv,
 			       int packet_len,
 			       unsigned long send_time,
 			       bool directlink,
@@ -37,6 +38,8 @@ static bool can_aggregate_with(const struct batman_packet *new_batman_packet,
 	struct batman_packet *batman_packet =
 		(struct batman_packet *)forw_packet->skb->data;
 	int aggregated_bytes = forw_packet->packet_len + packet_len;
+	struct hard_iface *primary_if = NULL;
+	bool res = false;
 
 	/**
 	 * we can aggregate the current packet to this aggregated packet
@@ -61,6 +64,10 @@ static bool can_aggregate_with(const struct batman_packet *new_batman_packet,
 		 *    packet
 		 */
 
+		primary_if = primary_if_get_selected(bat_priv);
+		if (!primary_if)
+			goto out;
+
 		/* packets without direct link flag and high TTL
 		 * are flooded through the net  */
 		if ((!directlink) &&
@@ -70,8 +77,10 @@ static bool can_aggregate_with(const struct batman_packet *new_batman_packet,
 		    /* own packets originating non-primary
 		     * interfaces leave only that interface */
 		    ((!forw_packet->own) ||
-		     (forw_packet->if_incoming->if_num == 0)))
-			return true;
+		     (forw_packet->if_incoming == primary_if))) {
+			res = true;
+			goto out;
+		}
 
 		/* if the incoming packet is sent via this one
 		 * interface only - we still can aggregate */
@@ -84,11 +93,16 @@ static bool can_aggregate_with(const struct batman_packet *new_batman_packet,
 		     * (= secondary interface packets in general) */
 		    (batman_packet->flags & DIRECTLINK ||
 		     (forw_packet->own &&
-		      forw_packet->if_incoming->if_num != 0)))
-			return true;
+		      forw_packet->if_incoming != primary_if))) {
+			res = true;
+			goto out;
+		}
 	}
 
-	return false;
+out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
+	return res;
 }
 
 /* create a new aggregated packet and add this packet to it */
@@ -210,6 +224,7 @@ void add_bat_packet_to_list(struct bat_priv *bat_priv,
 		hlist_for_each_entry(forw_packet_pos, tmp_node,
 				     &bat_priv->forw_bat_list, list) {
 			if (can_aggregate_with(batman_packet,
+					       bat_priv,
 					       packet_len,
 					       send_time,
 					       direct_link,
-- 
1.7.5.3

