From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 01/12] batman-adv: Reserve extra bytes in skb for better alignment
Date: Wed,  7 Nov 2012 20:11:31 +0100
Message-ID: <1352315502-20324-2-git-send-email-ordex@autistici.org>
References: <1352315502-20324-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:44588 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753306Ab2KGTMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 14:12:31 -0500
In-Reply-To: <1352315502-20324-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The ethernet header is 14 bytes long. Therefore, the data after it is not 4
byte aligned and may cause problems on systems without unaligned data access.
Reserving NET_IP_ALIGN more byes can fix the misalignment of the ethernet
header.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c        |  8 +++++---
 net/batman-adv/icmp_socket.c       |  4 ++--
 net/batman-adv/translation-table.c | 20 ++++++++++----------
 net/batman-adv/vis.c               |  9 +++++----
 4 files changed, 22 insertions(+), 19 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 75403a4..9f3925a 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -411,9 +411,11 @@ static void batadv_iv_ogm_aggregate_new(const unsigned char *packet_buff,
 
 	if ((atomic_read(&bat_priv->aggregated_ogms)) &&
 	    (packet_len < BATADV_MAX_AGGREGATION_BYTES))
-		skb_size = BATADV_MAX_AGGREGATION_BYTES + ETH_HLEN;
+		skb_size = BATADV_MAX_AGGREGATION_BYTES;
 	else
-		skb_size = packet_len + ETH_HLEN;
+		skb_size = packet_len;
+
+	skb_size += ETH_HLEN + NET_IP_ALIGN;
 
 	forw_packet_aggr->skb = dev_alloc_skb(skb_size);
 	if (!forw_packet_aggr->skb) {
@@ -422,7 +424,7 @@ static void batadv_iv_ogm_aggregate_new(const unsigned char *packet_buff,
 		kfree(forw_packet_aggr);
 		goto out;
 	}
-	skb_reserve(forw_packet_aggr->skb, ETH_HLEN);
+	skb_reserve(forw_packet_aggr->skb, ETH_HLEN + NET_IP_ALIGN);
 
 	INIT_HLIST_NODE(&forw_packet_aggr->list);
 
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 5874c0e..87ca809 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -177,13 +177,13 @@ static ssize_t batadv_socket_write(struct file *file, const char __user *buff,
 	if (len >= sizeof(struct batadv_icmp_packet_rr))
 		packet_len = sizeof(struct batadv_icmp_packet_rr);
 
-	skb = dev_alloc_skb(packet_len + ETH_HLEN);
+	skb = dev_alloc_skb(packet_len + ETH_HLEN + NET_IP_ALIGN);
 	if (!skb) {
 		len = -ENOMEM;
 		goto out;
 	}
 
-	skb_reserve(skb, ETH_HLEN);
+	skb_reserve(skb, ETH_HLEN + NET_IP_ALIGN);
 	icmp_packet = (struct batadv_icmp_packet_rr *)skb_put(skb, packet_len);
 
 	if (copy_from_user(icmp_packet, buff, packet_len)) {
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index a570d95..f8b9c32 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1472,11 +1472,11 @@ batadv_tt_response_fill_table(uint16_t tt_len, uint8_t ttvn,
 	tt_tot = tt_len / sizeof(struct batadv_tt_change);
 
 	len = tt_query_size + tt_len;
-	skb = dev_alloc_skb(len + ETH_HLEN);
+	skb = dev_alloc_skb(len + ETH_HLEN + NET_IP_ALIGN);
 	if (!skb)
 		goto out;
 
-	skb_reserve(skb, ETH_HLEN);
+	skb_reserve(skb, ETH_HLEN + NET_IP_ALIGN);
 	tt_response = (struct batadv_tt_query_packet *)skb_put(skb, len);
 	tt_response->ttvn = ttvn;
 
@@ -1538,11 +1538,11 @@ static int batadv_send_tt_request(struct batadv_priv *bat_priv,
 	if (!tt_req_node)
 		goto out;
 
-	skb = dev_alloc_skb(sizeof(*tt_request) + ETH_HLEN);
+	skb = dev_alloc_skb(sizeof(*tt_request) + ETH_HLEN + NET_IP_ALIGN);
 	if (!skb)
 		goto out;
 
-	skb_reserve(skb, ETH_HLEN);
+	skb_reserve(skb, ETH_HLEN + NET_IP_ALIGN);
 
 	tt_req_len = sizeof(*tt_request);
 	tt_request = (struct batadv_tt_query_packet *)skb_put(skb, tt_req_len);
@@ -1653,11 +1653,11 @@ batadv_send_other_tt_response(struct batadv_priv *bat_priv,
 		tt_tot = tt_len / sizeof(struct batadv_tt_change);
 
 		len = sizeof(*tt_response) + tt_len;
-		skb = dev_alloc_skb(len + ETH_HLEN);
+		skb = dev_alloc_skb(len + ETH_HLEN + NET_IP_ALIGN);
 		if (!skb)
 			goto unlock;
 
-		skb_reserve(skb, ETH_HLEN);
+		skb_reserve(skb, ETH_HLEN + NET_IP_ALIGN);
 		packet_pos = skb_put(skb, len);
 		tt_response = (struct batadv_tt_query_packet *)packet_pos;
 		tt_response->ttvn = req_ttvn;
@@ -1780,11 +1780,11 @@ batadv_send_my_tt_response(struct batadv_priv *bat_priv,
 		tt_tot = tt_len / sizeof(struct batadv_tt_change);
 
 		len = sizeof(*tt_response) + tt_len;
-		skb = dev_alloc_skb(len + ETH_HLEN);
+		skb = dev_alloc_skb(len + ETH_HLEN + NET_IP_ALIGN);
 		if (!skb)
 			goto unlock;
 
-		skb_reserve(skb, ETH_HLEN);
+		skb_reserve(skb, ETH_HLEN + NET_IP_ALIGN);
 		packet_pos = skb_put(skb, len);
 		tt_response = (struct batadv_tt_query_packet *)packet_pos;
 		tt_response->ttvn = req_ttvn;
@@ -2118,11 +2118,11 @@ static void batadv_send_roam_adv(struct batadv_priv *bat_priv, uint8_t *client,
 	if (!batadv_tt_check_roam_count(bat_priv, client))
 		goto out;
 
-	skb = dev_alloc_skb(sizeof(*roam_adv_packet) + ETH_HLEN);
+	skb = dev_alloc_skb(sizeof(*roam_adv_packet) + ETH_HLEN + NET_IP_ALIGN);
 	if (!skb)
 		goto out;
 
-	skb_reserve(skb, ETH_HLEN);
+	skb_reserve(skb, ETH_HLEN + NET_IP_ALIGN);
 
 	roam_adv_packet = (struct batadv_roam_adv_packet *)skb_put(skb, len);
 
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 5abd145..ad14a6c 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -396,12 +396,12 @@ batadv_add_packet(struct batadv_priv *bat_priv,
 		return NULL;
 
 	len = sizeof(*packet) + vis_info_len;
-	info->skb_packet = dev_alloc_skb(len + ETH_HLEN);
+	info->skb_packet = dev_alloc_skb(len + ETH_HLEN + NET_IP_ALIGN);
 	if (!info->skb_packet) {
 		kfree(info);
 		return NULL;
 	}
-	skb_reserve(info->skb_packet, ETH_HLEN);
+	skb_reserve(info->skb_packet, ETH_HLEN + NET_IP_ALIGN);
 	packet = (struct batadv_vis_packet *)skb_put(info->skb_packet, len);
 
 	kref_init(&info->refcount);
@@ -873,12 +873,13 @@ int batadv_vis_init(struct batadv_priv *bat_priv)
 	if (!bat_priv->vis.my_info)
 		goto err;
 
-	len = sizeof(*packet) + BATADV_MAX_VIS_PACKET_SIZE + ETH_HLEN;
+	len = sizeof(*packet) + BATADV_MAX_VIS_PACKET_SIZE;
+	len += ETH_HLEN + NET_IP_ALIGN;
 	bat_priv->vis.my_info->skb_packet = dev_alloc_skb(len);
 	if (!bat_priv->vis.my_info->skb_packet)
 		goto free_info;
 
-	skb_reserve(bat_priv->vis.my_info->skb_packet, ETH_HLEN);
+	skb_reserve(bat_priv->vis.my_info->skb_packet, ETH_HLEN + NET_IP_ALIGN);
 	tmp_skb = bat_priv->vis.my_info->skb_packet;
 	packet = (struct batadv_vis_packet *)skb_put(tmp_skb, sizeof(*packet));
 
-- 
1.8.0
