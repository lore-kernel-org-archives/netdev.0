From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 14/21] batman-adv: don't deal with NET_IP_ALIGN manually
Date: Wed, 29 May 2013 10:10:44 +0200
Message-ID: <1369815051-708-15-git-send-email-ordex@autistici.org>
References: <1369815051-708-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:40030 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965067Ab3E2INE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 04:13:04 -0400
In-Reply-To: <1369815051-708-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of dealing with NET_IP_ALIGN during allocation and
headroom reservation, it is possible to use
netdev_alloc_skb_ip_align() which transparently allocate
and reserve the correct amount of data

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bat_iv_ogm.c        |  6 +++---
 net/batman-adv/icmp_socket.c       |  4 ++--
 net/batman-adv/translation-table.c | 20 ++++++++++----------
 net/batman-adv/vis.c               | 12 ++++++------
 4 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 42b7a94..5b0a043 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -453,16 +453,16 @@ static void batadv_iv_ogm_aggregate_new(const unsigned char *packet_buff,
 	else
 		skb_size = packet_len;
 
-	skb_size += ETH_HLEN + NET_IP_ALIGN;
+	skb_size += ETH_HLEN;
 
-	forw_packet_aggr->skb = dev_alloc_skb(skb_size);
+	forw_packet_aggr->skb = netdev_alloc_skb_ip_align(NULL, skb_size);
 	if (!forw_packet_aggr->skb) {
 		if (!own_packet)
 			atomic_inc(&bat_priv->batman_queue_left);
 		kfree(forw_packet_aggr);
 		goto out;
 	}
-	skb_reserve(forw_packet_aggr->skb, ETH_HLEN + NET_IP_ALIGN);
+	skb_reserve(forw_packet_aggr->skb, ETH_HLEN);
 
 	INIT_HLIST_NODE(&forw_packet_aggr->list);
 
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 0ba6c89..b27508b 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -177,13 +177,13 @@ static ssize_t batadv_socket_write(struct file *file, const char __user *buff,
 	if (len >= sizeof(struct batadv_icmp_packet_rr))
 		packet_len = sizeof(struct batadv_icmp_packet_rr);
 
-	skb = dev_alloc_skb(packet_len + ETH_HLEN + NET_IP_ALIGN);
+	skb = netdev_alloc_skb_ip_align(NULL, packet_len + ETH_HLEN);
 	if (!skb) {
 		len = -ENOMEM;
 		goto out;
 	}
 
-	skb_reserve(skb, ETH_HLEN + NET_IP_ALIGN);
+	skb_reserve(skb, ETH_HLEN);
 	icmp_packet = (struct batadv_icmp_packet_rr *)skb_put(skb, packet_len);
 
 	if (copy_from_user(icmp_packet, buff, packet_len)) {
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index d35b739..52808c4 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1607,11 +1607,11 @@ batadv_tt_response_fill_table(uint16_t tt_len, uint8_t ttvn,
 	tt_tot = tt_len / sizeof(struct batadv_tt_change);
 
 	len = tt_query_size + tt_len;
-	skb = dev_alloc_skb(len + ETH_HLEN + NET_IP_ALIGN);
+	skb = netdev_alloc_skb_ip_align(NULL, len + ETH_HLEN);
 	if (!skb)
 		goto out;
 
-	skb_reserve(skb, ETH_HLEN + NET_IP_ALIGN);
+	skb_reserve(skb, ETH_HLEN);
 	tt_response = (struct batadv_tt_query_packet *)skb_put(skb, len);
 	tt_response->ttvn = ttvn;
 
@@ -1672,11 +1672,11 @@ static int batadv_send_tt_request(struct batadv_priv *bat_priv,
 	if (!tt_req_node)
 		goto out;
 
-	skb = dev_alloc_skb(sizeof(*tt_request) + ETH_HLEN + NET_IP_ALIGN);
+	skb = netdev_alloc_skb_ip_align(NULL, sizeof(*tt_request) + ETH_HLEN);
 	if (!skb)
 		goto out;
 
-	skb_reserve(skb, ETH_HLEN + NET_IP_ALIGN);
+	skb_reserve(skb, ETH_HLEN);
 
 	tt_req_len = sizeof(*tt_request);
 	tt_request = (struct batadv_tt_query_packet *)skb_put(skb, tt_req_len);
@@ -1769,11 +1769,11 @@ batadv_send_other_tt_response(struct batadv_priv *bat_priv,
 		tt_tot = tt_len / sizeof(struct batadv_tt_change);
 
 		len = sizeof(*tt_response) + tt_len;
-		skb = dev_alloc_skb(len + ETH_HLEN + NET_IP_ALIGN);
+		skb = netdev_alloc_skb_ip_align(NULL, len + ETH_HLEN);
 		if (!skb)
 			goto unlock;
 
-		skb_reserve(skb, ETH_HLEN + NET_IP_ALIGN);
+		skb_reserve(skb, ETH_HLEN);
 		packet_pos = skb_put(skb, len);
 		tt_response = (struct batadv_tt_query_packet *)packet_pos;
 		tt_response->ttvn = req_ttvn;
@@ -1885,11 +1885,11 @@ batadv_send_my_tt_response(struct batadv_priv *bat_priv,
 		tt_tot = tt_len / sizeof(struct batadv_tt_change);
 
 		len = sizeof(*tt_response) + tt_len;
-		skb = dev_alloc_skb(len + ETH_HLEN + NET_IP_ALIGN);
+		skb = netdev_alloc_skb_ip_align(NULL, len + ETH_HLEN);
 		if (!skb)
 			goto unlock;
 
-		skb_reserve(skb, ETH_HLEN + NET_IP_ALIGN);
+		skb_reserve(skb, ETH_HLEN);
 		packet_pos = skb_put(skb, len);
 		tt_response = (struct batadv_tt_query_packet *)packet_pos;
 		tt_response->ttvn = req_ttvn;
@@ -2219,11 +2219,11 @@ static void batadv_send_roam_adv(struct batadv_priv *bat_priv, uint8_t *client,
 	if (!batadv_tt_check_roam_count(bat_priv, client))
 		goto out;
 
-	skb = dev_alloc_skb(sizeof(*roam_adv_packet) + ETH_HLEN + NET_IP_ALIGN);
+	skb = netdev_alloc_skb_ip_align(NULL, len + ETH_HLEN);
 	if (!skb)
 		goto out;
 
-	skb_reserve(skb, ETH_HLEN + NET_IP_ALIGN);
+	skb_reserve(skb, ETH_HLEN);
 
 	roam_adv_packet = (struct batadv_roam_adv_packet *)skb_put(skb, len);
 
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 1625e57..94eaeb5 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -392,12 +392,12 @@ batadv_add_packet(struct batadv_priv *bat_priv,
 		return NULL;
 
 	len = sizeof(*packet) + vis_info_len;
-	info->skb_packet = dev_alloc_skb(len + ETH_HLEN + NET_IP_ALIGN);
+	info->skb_packet = netdev_alloc_skb_ip_align(NULL, len + ETH_HLEN);
 	if (!info->skb_packet) {
 		kfree(info);
 		return NULL;
 	}
-	skb_reserve(info->skb_packet, ETH_HLEN + NET_IP_ALIGN);
+	skb_reserve(info->skb_packet, ETH_HLEN);
 	packet = (struct batadv_vis_packet *)skb_put(info->skb_packet, len);
 
 	kref_init(&info->refcount);
@@ -854,13 +854,13 @@ int batadv_vis_init(struct batadv_priv *bat_priv)
 	if (!bat_priv->vis.my_info)
 		goto err;
 
-	len = sizeof(*packet) + BATADV_MAX_VIS_PACKET_SIZE;
-	len += ETH_HLEN + NET_IP_ALIGN;
-	bat_priv->vis.my_info->skb_packet = dev_alloc_skb(len);
+	len = sizeof(*packet) + BATADV_MAX_VIS_PACKET_SIZE + ETH_HLEN;
+	bat_priv->vis.my_info->skb_packet = netdev_alloc_skb_ip_align(NULL,
+								      len);
 	if (!bat_priv->vis.my_info->skb_packet)
 		goto free_info;
 
-	skb_reserve(bat_priv->vis.my_info->skb_packet, ETH_HLEN + NET_IP_ALIGN);
+	skb_reserve(bat_priv->vis.my_info->skb_packet, ETH_HLEN);
 	tmp_skb = bat_priv->vis.my_info->skb_packet;
 	packet = (struct batadv_vis_packet *)skb_put(tmp_skb, sizeof(*packet));
 
-- 
1.8.1.5
