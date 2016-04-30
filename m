From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 1/4] batman-adv: fix DAT candidate selection (must use vid)
Date: Sun,  1 May 2016 01:06:00 +0800
Message-ID: <1462035963-28970-2-git-send-email-a@unstable.cc>
References: <1462035963-28970-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <a@unstable.cc>,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:34385 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751910AbcD3RGj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Apr 2016 13:06:39 -0400
In-Reply-To: <1462035963-28970-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that DAT is VLAN aware, it must use the VID when
computing the DHT address of the candidate nodes where
an entry is going to be stored/retrieved.

Fixes: be1db4f6615b ("batman-adv: make the Distributed ARP Table vlan aware")
Signed-off-by: Antonio Quartulli <a@unstable.cc>
[sven@narfation.org: fix conflicts with current version]
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/distributed-arp-table.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index e96d7c745b4a..3e6b2624f980 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -568,6 +568,7 @@ static void batadv_choose_next_candidate(struct batadv_priv *bat_priv,
  * be sent to
  * @bat_priv: the bat priv with all the soft interface information
  * @ip_dst: ipv4 to look up in the DHT
+ * @vid: VLAN identifier
  *
  * An originator O is selected if and only if its DHT_ID value is one of three
  * closest values (from the LEFT, with wrap around if needed) then the hash
@@ -576,7 +577,8 @@ static void batadv_choose_next_candidate(struct batadv_priv *bat_priv,
  * Return: the candidate array of size BATADV_DAT_CANDIDATE_NUM.
  */
 static struct batadv_dat_candidate *
-batadv_dat_select_candidates(struct batadv_priv *bat_priv, __be32 ip_dst)
+batadv_dat_select_candidates(struct batadv_priv *bat_priv, __be32 ip_dst,
+			     unsigned short vid)
 {
 	int select;
 	batadv_dat_addr_t last_max = BATADV_DAT_ADDR_MAX, ip_key;
@@ -592,7 +594,7 @@ batadv_dat_select_candidates(struct batadv_priv *bat_priv, __be32 ip_dst)
 		return NULL;
 
 	dat.ip = ip_dst;
-	dat.vid = 0;
+	dat.vid = vid;
 	ip_key = (batadv_dat_addr_t)batadv_hash_dat(&dat,
 						    BATADV_DAT_ADDR_MAX);
 
@@ -612,6 +614,7 @@ batadv_dat_select_candidates(struct batadv_priv *bat_priv, __be32 ip_dst)
  * @bat_priv: the bat priv with all the soft interface information
  * @skb: payload to send
  * @ip: the DHT key
+ * @vid: VLAN identifier
  * @packet_subtype: unicast4addr packet subtype to use
  *
  * This function copies the skb with pskb_copy() and is sent as unicast packet
@@ -622,7 +625,7 @@ batadv_dat_select_candidates(struct batadv_priv *bat_priv, __be32 ip_dst)
  */
 static bool batadv_dat_send_data(struct batadv_priv *bat_priv,
 				 struct sk_buff *skb, __be32 ip,
-				 int packet_subtype)
+				 unsigned short vid, int packet_subtype)
 {
 	int i;
 	bool ret = false;
@@ -631,7 +634,7 @@ static bool batadv_dat_send_data(struct batadv_priv *bat_priv,
 	struct sk_buff *tmp_skb;
 	struct batadv_dat_candidate *cand;
 
-	cand = batadv_dat_select_candidates(bat_priv, ip);
+	cand = batadv_dat_select_candidates(bat_priv, ip, vid);
 	if (!cand)
 		goto out;
 
@@ -1022,7 +1025,7 @@ bool batadv_dat_snoop_outgoing_arp_request(struct batadv_priv *bat_priv,
 		ret = true;
 	} else {
 		/* Send the request to the DHT */
-		ret = batadv_dat_send_data(bat_priv, skb, ip_dst,
+		ret = batadv_dat_send_data(bat_priv, skb, ip_dst, vid,
 					   BATADV_P_DAT_DHT_GET);
 	}
 out:
@@ -1150,8 +1153,8 @@ void batadv_dat_snoop_outgoing_arp_reply(struct batadv_priv *bat_priv,
 	/* Send the ARP reply to the candidates for both the IP addresses that
 	 * the node obtained from the ARP reply
 	 */
-	batadv_dat_send_data(bat_priv, skb, ip_src, BATADV_P_DAT_DHT_PUT);
-	batadv_dat_send_data(bat_priv, skb, ip_dst, BATADV_P_DAT_DHT_PUT);
+	batadv_dat_send_data(bat_priv, skb, ip_src, vid, BATADV_P_DAT_DHT_PUT);
+	batadv_dat_send_data(bat_priv, skb, ip_dst, vid, BATADV_P_DAT_DHT_PUT);
 }
 
 /**
-- 
2.8.1
