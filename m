From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 1/9] batman-adv: replace redundant primary_if_get calls
Date: Wed, 13 Mar 2013 23:56:31 +0100
Message-ID: <1363215399-18875-2-git-send-email-ordex@autistici.org>
References: <1363215399-18875-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:65411 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934356Ab3CMW55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 18:57:57 -0400
In-Reply-To: <1363215399-18875-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

The batadv_priv struct carries a pointer to its own interface
struct. Therefore, it is not necessary to retrieve the soft_iface
via the primary interface.

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/distributed-arp-table.c | 22 ++++------------------
 net/batman-adv/sysfs.c                 | 10 +---------
 net/batman-adv/translation-table.c     | 25 ++++++-------------------
 3 files changed, 11 insertions(+), 46 deletions(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index d54188a..8e15d96 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -816,7 +816,6 @@ bool batadv_dat_snoop_outgoing_arp_request(struct batadv_priv *bat_priv,
 	bool ret = false;
 	struct batadv_dat_entry *dat_entry = NULL;
 	struct sk_buff *skb_new;
-	struct batadv_hard_iface *primary_if = NULL;
 
 	if (!atomic_read(&bat_priv->distributed_arp_table))
 		goto out;
@@ -838,22 +837,18 @@ bool batadv_dat_snoop_outgoing_arp_request(struct batadv_priv *bat_priv,
 
 	dat_entry = batadv_dat_entry_hash_find(bat_priv, ip_dst);
 	if (dat_entry) {
-		primary_if = batadv_primary_if_get_selected(bat_priv);
-		if (!primary_if)
-			goto out;
-
 		skb_new = arp_create(ARPOP_REPLY, ETH_P_ARP, ip_src,
-				     primary_if->soft_iface, ip_dst, hw_src,
+				     bat_priv->soft_iface, ip_dst, hw_src,
 				     dat_entry->mac_addr, hw_src);
 		if (!skb_new)
 			goto out;
 
 		skb_reset_mac_header(skb_new);
 		skb_new->protocol = eth_type_trans(skb_new,
-						   primary_if->soft_iface);
+						   bat_priv->soft_iface);
 		bat_priv->stats.rx_packets++;
 		bat_priv->stats.rx_bytes += skb->len + ETH_HLEN;
-		primary_if->soft_iface->last_rx = jiffies;
+		bat_priv->soft_iface->last_rx = jiffies;
 
 		netif_rx(skb_new);
 		batadv_dbg(BATADV_DBG_DAT, bat_priv, "ARP request replied locally\n");
@@ -866,8 +861,6 @@ bool batadv_dat_snoop_outgoing_arp_request(struct batadv_priv *bat_priv,
 out:
 	if (dat_entry)
 		batadv_dat_entry_free_ref(dat_entry);
-	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
 	return ret;
 }
 
@@ -887,7 +880,6 @@ bool batadv_dat_snoop_incoming_arp_request(struct batadv_priv *bat_priv,
 	__be32 ip_src, ip_dst;
 	uint8_t *hw_src;
 	struct sk_buff *skb_new;
-	struct batadv_hard_iface *primary_if = NULL;
 	struct batadv_dat_entry *dat_entry = NULL;
 	bool ret = false;
 	int err;
@@ -912,12 +904,8 @@ bool batadv_dat_snoop_incoming_arp_request(struct batadv_priv *bat_priv,
 	if (!dat_entry)
 		goto out;
 
-	primary_if = batadv_primary_if_get_selected(bat_priv);
-	if (!primary_if)
-		goto out;
-
 	skb_new = arp_create(ARPOP_REPLY, ETH_P_ARP, ip_src,
-			     primary_if->soft_iface, ip_dst, hw_src,
+			     bat_priv->soft_iface, ip_dst, hw_src,
 			     dat_entry->mac_addr, hw_src);
 
 	if (!skb_new)
@@ -941,8 +929,6 @@ bool batadv_dat_snoop_incoming_arp_request(struct batadv_priv *bat_priv,
 out:
 	if (dat_entry)
 		batadv_dat_entry_free_ref(dat_entry);
-	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
 	if (ret)
 		kfree_skb(skb);
 	return ret;
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index afbba31..6a44fed 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -688,15 +688,10 @@ int batadv_throw_uevent(struct batadv_priv *bat_priv, enum batadv_uev_type type,
 			enum batadv_uev_action action, const char *data)
 {
 	int ret = -ENOMEM;
-	struct batadv_hard_iface *primary_if;
 	struct kobject *bat_kobj;
 	char *uevent_env[4] = { NULL, NULL, NULL, NULL };
 
-	primary_if = batadv_primary_if_get_selected(bat_priv);
-	if (!primary_if)
-		goto out;
-
-	bat_kobj = &primary_if->soft_iface->dev.kobj;
+	bat_kobj = &bat_priv->soft_iface->dev.kobj;
 
 	uevent_env[0] = kmalloc(strlen(BATADV_UEV_TYPE_VAR) +
 				strlen(batadv_uev_type_str[type]) + 1,
@@ -732,9 +727,6 @@ out:
 	kfree(uevent_env[1]);
 	kfree(uevent_env[2]);
 
-	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
-
 	if (ret)
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Impossible to send uevent for (%s,%s,%s) event (err: %d)\n",
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 98a66a0..7e9e264 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -385,25 +385,19 @@ static void batadv_tt_prepare_packet_buff(struct batadv_priv *bat_priv,
 					  int *packet_buff_len,
 					  int min_packet_len)
 {
-	struct batadv_hard_iface *primary_if;
 	int req_len;
 
-	primary_if = batadv_primary_if_get_selected(bat_priv);
-
 	req_len = min_packet_len;
 	req_len += batadv_tt_len(atomic_read(&bat_priv->tt.local_changes));
 
 	/* if we have too many changes for one packet don't send any
 	 * and wait for the tt table request which will be fragmented
 	 */
-	if ((!primary_if) || (req_len > primary_if->soft_iface->mtu))
+	if (req_len > bat_priv->soft_iface->mtu)
 		req_len = min_packet_len;
 
 	batadv_tt_realloc_packet_buff(packet_buff, packet_buff_len,
 				      min_packet_len, req_len);
-
-	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
 }
 
 static int batadv_tt_changes_fill_buff(struct batadv_priv *bat_priv,
@@ -1580,7 +1574,7 @@ static int batadv_tt_global_valid(const void *entry_ptr,
 static struct sk_buff *
 batadv_tt_response_fill_table(uint16_t tt_len, uint8_t ttvn,
 			      struct batadv_hashtable *hash,
-			      struct batadv_hard_iface *primary_if,
+			      struct batadv_priv *bat_priv,
 			      int (*valid_cb)(const void *, const void *),
 			      void *cb_data)
 {
@@ -1594,8 +1588,8 @@ batadv_tt_response_fill_table(uint16_t tt_len, uint8_t ttvn,
 	uint32_t i;
 	size_t len;
 
-	if (tt_query_size + tt_len > primary_if->soft_iface->mtu) {
-		tt_len = primary_if->soft_iface->mtu - tt_query_size;
+	if (tt_query_size + tt_len > bat_priv->soft_iface->mtu) {
+		tt_len = bat_priv->soft_iface->mtu - tt_query_size;
 		tt_len -= tt_len % sizeof(struct batadv_tt_change);
 	}
 	tt_tot = tt_len / sizeof(struct batadv_tt_change);
@@ -1715,7 +1709,6 @@ batadv_send_other_tt_response(struct batadv_priv *bat_priv,
 {
 	struct batadv_orig_node *req_dst_orig_node;
 	struct batadv_orig_node *res_dst_orig_node = NULL;
-	struct batadv_hard_iface *primary_if = NULL;
 	uint8_t orig_ttvn, req_ttvn, ttvn;
 	int ret = false;
 	unsigned char *tt_buff;
@@ -1740,10 +1733,6 @@ batadv_send_other_tt_response(struct batadv_priv *bat_priv,
 	if (!res_dst_orig_node)
 		goto out;
 
-	primary_if = batadv_primary_if_get_selected(bat_priv);
-	if (!primary_if)
-		goto out;
-
 	orig_ttvn = (uint8_t)atomic_read(&req_dst_orig_node->last_ttvn);
 	req_ttvn = tt_request->ttvn;
 
@@ -1791,7 +1780,7 @@ batadv_send_other_tt_response(struct batadv_priv *bat_priv,
 
 		skb = batadv_tt_response_fill_table(tt_len, ttvn,
 						    bat_priv->tt.global_hash,
-						    primary_if,
+						    bat_priv,
 						    batadv_tt_global_valid,
 						    req_dst_orig_node);
 		if (!skb)
@@ -1828,8 +1817,6 @@ out:
 		batadv_orig_node_free_ref(res_dst_orig_node);
 	if (req_dst_orig_node)
 		batadv_orig_node_free_ref(req_dst_orig_node);
-	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
 	if (!ret)
 		kfree_skb(skb);
 	return ret;
@@ -1907,7 +1894,7 @@ batadv_send_my_tt_response(struct batadv_priv *bat_priv,
 
 		skb = batadv_tt_response_fill_table(tt_len, ttvn,
 						    bat_priv->tt.local_hash,
-						    primary_if,
+						    bat_priv,
 						    batadv_tt_local_valid_entry,
 						    NULL);
 		if (!skb)
-- 
1.8.1.5
