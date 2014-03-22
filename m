From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 04/16] batman-adv: prefer ether_addr_copy to memcpy
Date: Sat, 22 Mar 2014 09:56:04 +0100
Message-ID: <1395478576-10999-5-git-send-email-antonio@meshcoding.com>
References: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:38502 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975AbaCVI4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2014 04:56:51 -0400
In-Reply-To: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some architectures ether_addr_copy() is slightly faster
than memcpy() therefore use the former when possible.

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/bat_iv_ogm.c            | 10 +++++-----
 net/batman-adv/bridge_loop_avoidance.c | 30 +++++++++++++++---------------
 net/batman-adv/distributed-arp-table.c |  4 ++--
 net/batman-adv/fragmentation.c         |  4 ++--
 net/batman-adv/gateway_client.c        |  2 +-
 net/batman-adv/icmp_socket.c           | 11 ++++++-----
 net/batman-adv/main.c                  |  4 ++--
 net/batman-adv/network-coding.c        | 24 ++++++++++++------------
 net/batman-adv/originator.c            |  4 ++--
 net/batman-adv/routing.c               | 17 ++++++++---------
 net/batman-adv/send.c                  |  8 ++++----
 net/batman-adv/soft-interface.c        |  8 ++++----
 net/batman-adv/translation-table.c     | 15 +++++++--------
 13 files changed, 70 insertions(+), 71 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 8323bce..b3bd4ec 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -347,10 +347,10 @@ static void batadv_iv_ogm_iface_update_mac(struct batadv_hard_iface *hard_iface)
 	unsigned char *ogm_buff = hard_iface->bat_iv.ogm_buff;
 
 	batadv_ogm_packet = (struct batadv_ogm_packet *)ogm_buff;
-	memcpy(batadv_ogm_packet->orig,
-	       hard_iface->net_dev->dev_addr, ETH_ALEN);
-	memcpy(batadv_ogm_packet->prev_sender,
-	       hard_iface->net_dev->dev_addr, ETH_ALEN);
+	ether_addr_copy(batadv_ogm_packet->orig,
+			hard_iface->net_dev->dev_addr);
+	ether_addr_copy(batadv_ogm_packet->prev_sender,
+			hard_iface->net_dev->dev_addr);
 }
 
 static void
@@ -830,7 +830,7 @@ static void batadv_iv_ogm_forward(struct batadv_orig_node *orig_node,
 	tvlv_len = ntohs(batadv_ogm_packet->tvlv_len);
 
 	batadv_ogm_packet->ttl--;
-	memcpy(batadv_ogm_packet->prev_sender, ethhdr->h_source, ETH_ALEN);
+	ether_addr_copy(batadv_ogm_packet->prev_sender, ethhdr->h_source);
 
 	/* apply hop penalty */
 	batadv_ogm_packet->tq = batadv_hop_penalty(batadv_ogm_packet->tq,
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 70d781a..6f0d9ec 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -191,7 +191,7 @@ batadv_backbone_hash_find(struct batadv_priv *bat_priv,
 	if (!hash)
 		return NULL;
 
-	memcpy(search_entry.orig, addr, ETH_ALEN);
+	ether_addr_copy(search_entry.orig, addr);
 	search_entry.vid = vid;
 
 	index = batadv_choose_backbone_gw(&search_entry, hash->size);
@@ -305,7 +305,7 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, uint8_t *mac,
 		/* normal claim frame
 		 * set Ethernet SRC to the clients mac
 		 */
-		memcpy(ethhdr->h_source, mac, ETH_ALEN);
+		ether_addr_copy(ethhdr->h_source, mac);
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_send_claim(): CLAIM %pM on vid %d\n", mac,
 			   BATADV_PRINT_VID(vid));
@@ -314,7 +314,7 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, uint8_t *mac,
 		/* unclaim frame
 		 * set HW SRC to the clients mac
 		 */
-		memcpy(hw_src, mac, ETH_ALEN);
+		ether_addr_copy(hw_src, mac);
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_send_claim(): UNCLAIM %pM on vid %d\n", mac,
 			   BATADV_PRINT_VID(vid));
@@ -323,7 +323,7 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, uint8_t *mac,
 		/* announcement frame
 		 * set HW SRC to the special mac containg the crc
 		 */
-		memcpy(hw_src, mac, ETH_ALEN);
+		ether_addr_copy(hw_src, mac);
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_send_claim(): ANNOUNCE of %pM on vid %d\n",
 			   ethhdr->h_source, BATADV_PRINT_VID(vid));
@@ -333,8 +333,8 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, uint8_t *mac,
 		 * set HW SRC and header destination to the receiving backbone
 		 * gws mac
 		 */
-		memcpy(hw_src, mac, ETH_ALEN);
-		memcpy(ethhdr->h_dest, mac, ETH_ALEN);
+		ether_addr_copy(hw_src, mac);
+		ether_addr_copy(ethhdr->h_dest, mac);
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_send_claim(): REQUEST of %pM to %pM on vid %d\n",
 			   ethhdr->h_source, ethhdr->h_dest,
@@ -395,7 +395,7 @@ batadv_bla_get_backbone_gw(struct batadv_priv *bat_priv, uint8_t *orig,
 	entry->bat_priv = bat_priv;
 	atomic_set(&entry->request_sent, 0);
 	atomic_set(&entry->wait_periods, 0);
-	memcpy(entry->orig, orig, ETH_ALEN);
+	ether_addr_copy(entry->orig, orig);
 
 	/* one for the hash, one for returning */
 	atomic_set(&entry->refcount, 2);
@@ -563,7 +563,7 @@ static void batadv_bla_add_claim(struct batadv_priv *bat_priv,
 	struct batadv_bla_claim search_claim;
 	int hash_added;
 
-	memcpy(search_claim.addr, mac, ETH_ALEN);
+	ether_addr_copy(search_claim.addr, mac);
 	search_claim.vid = vid;
 	claim = batadv_claim_hash_find(bat_priv, &search_claim);
 
@@ -573,7 +573,7 @@ static void batadv_bla_add_claim(struct batadv_priv *bat_priv,
 		if (!claim)
 			return;
 
-		memcpy(claim->addr, mac, ETH_ALEN);
+		ether_addr_copy(claim->addr, mac);
 		claim->vid = vid;
 		claim->lasttime = jiffies;
 		claim->backbone_gw = backbone_gw;
@@ -624,7 +624,7 @@ static void batadv_bla_del_claim(struct batadv_priv *bat_priv,
 {
 	struct batadv_bla_claim search_claim, *claim;
 
-	memcpy(search_claim.addr, mac, ETH_ALEN);
+	ether_addr_copy(search_claim.addr, mac);
 	search_claim.vid = vid;
 	claim = batadv_claim_hash_find(bat_priv, &search_claim);
 	if (!claim)
@@ -1103,8 +1103,8 @@ void batadv_bla_update_orig_address(struct batadv_priv *bat_priv,
 						oldif->net_dev->dev_addr))
 				continue;
 
-			memcpy(backbone_gw->orig,
-			       primary_if->net_dev->dev_addr, ETH_ALEN);
+			ether_addr_copy(backbone_gw->orig,
+					primary_if->net_dev->dev_addr);
 			/* send an announce frame so others will ask for our
 			 * claims and update their tables.
 			 */
@@ -1310,7 +1310,7 @@ int batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
 	entry = &bat_priv->bla.bcast_duplist[curr];
 	entry->crc = crc;
 	entry->entrytime = jiffies;
-	memcpy(entry->orig, bcast_packet->orig, ETH_ALEN);
+	ether_addr_copy(entry->orig, bcast_packet->orig);
 	bat_priv->bla.bcast_duplist_curr = curr;
 
 out:
@@ -1458,7 +1458,7 @@ int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb,
 		if (is_multicast_ether_addr(ethhdr->h_dest) && is_bcast)
 			goto handled;
 
-	memcpy(search_claim.addr, ethhdr->h_source, ETH_ALEN);
+	ether_addr_copy(search_claim.addr, ethhdr->h_source);
 	search_claim.vid = vid;
 	claim = batadv_claim_hash_find(bat_priv, &search_claim);
 
@@ -1557,7 +1557,7 @@ int batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb,
 		if (is_multicast_ether_addr(ethhdr->h_dest))
 			goto handled;
 
-	memcpy(search_claim.addr, ethhdr->h_source, ETH_ALEN);
+	ether_addr_copy(search_claim.addr, ethhdr->h_source);
 	search_claim.vid = vid;
 
 	claim = batadv_claim_hash_find(bat_priv, &search_claim);
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 5bb37a8..b25fd64 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -277,7 +277,7 @@ static void batadv_dat_entry_add(struct batadv_priv *bat_priv, __be32 ip,
 	/* if this entry is already known, just update it */
 	if (dat_entry) {
 		if (!batadv_compare_eth(dat_entry->mac_addr, mac_addr))
-			memcpy(dat_entry->mac_addr, mac_addr, ETH_ALEN);
+			ether_addr_copy(dat_entry->mac_addr, mac_addr);
 		dat_entry->last_update = jiffies;
 		batadv_dbg(BATADV_DBG_DAT, bat_priv,
 			   "Entry updated: %pI4 %pM (vid: %d)\n",
@@ -292,7 +292,7 @@ static void batadv_dat_entry_add(struct batadv_priv *bat_priv, __be32 ip,
 
 	dat_entry->ip = ip;
 	dat_entry->vid = vid;
-	memcpy(dat_entry->mac_addr, mac_addr, ETH_ALEN);
+	ether_addr_copy(dat_entry->mac_addr, mac_addr);
 	dat_entry->last_update = jiffies;
 	atomic_set(&dat_entry->refcount, 2);
 
diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index 88df9b1..bcc4bea 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -449,8 +449,8 @@ bool batadv_frag_send_packet(struct sk_buff *skb,
 	frag_header.reserved = 0;
 	frag_header.no = 0;
 	frag_header.total_size = htons(skb->len);
-	memcpy(frag_header.orig, primary_if->net_dev->dev_addr, ETH_ALEN);
-	memcpy(frag_header.dest, orig_node->orig, ETH_ALEN);
+	ether_addr_copy(frag_header.orig, primary_if->net_dev->dev_addr);
+	ether_addr_copy(frag_header.dest, orig_node->orig);
 
 	/* Eat and send fragments from the tail of skb */
 	while (skb->len > max_fragment_size) {
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 07c7f21..c835e13 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -763,7 +763,7 @@ batadv_gw_dhcp_recipient_get(struct sk_buff *skb, unsigned int *header_len,
 		if (*p != ETH_ALEN)
 			return BATADV_DHCP_NO;
 
-		memcpy(chaddr, skb->data + chaddr_offset, ETH_ALEN);
+		ether_addr_copy(chaddr, skb->data + chaddr_offset);
 	}
 
 	return ret;
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index abb9d6e..161ef8f 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -158,6 +158,7 @@ static ssize_t batadv_socket_write(struct file *file, const char __user *buff,
 	struct batadv_orig_node *orig_node = NULL;
 	struct batadv_neigh_node *neigh_node = NULL;
 	size_t packet_len = sizeof(struct batadv_icmp_packet);
+	uint8_t *addr;
 
 	if (len < sizeof(struct batadv_icmp_header)) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
@@ -227,10 +228,10 @@ static ssize_t batadv_socket_write(struct file *file, const char __user *buff,
 			goto dst_unreach;
 
 		icmp_packet_rr = (struct batadv_icmp_packet_rr *)icmp_header;
-		if (packet_len == sizeof(*icmp_packet_rr))
-			memcpy(icmp_packet_rr->rr,
-			       neigh_node->if_incoming->net_dev->dev_addr,
-			       ETH_ALEN);
+		if (packet_len == sizeof(*icmp_packet_rr)) {
+			addr = neigh_node->if_incoming->net_dev->dev_addr;
+			ether_addr_copy(icmp_packet_rr->rr[0], addr);
+		}
 
 		break;
 	default:
@@ -250,7 +251,7 @@ static ssize_t batadv_socket_write(struct file *file, const char __user *buff,
 		goto free_skb;
 	}
 
-	memcpy(icmp_header->orig, primary_if->net_dev->dev_addr, ETH_ALEN);
+	ether_addr_copy(icmp_header->orig, primary_if->net_dev->dev_addr);
 
 	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
 	goto out;
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 66ae135..fbeaebd 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -1133,8 +1133,8 @@ void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, uint8_t *src,
 	unicast_tvlv_packet->reserved = 0;
 	unicast_tvlv_packet->tvlv_len = htons(tvlv_len);
 	unicast_tvlv_packet->align = 0;
-	memcpy(unicast_tvlv_packet->src, src, ETH_ALEN);
-	memcpy(unicast_tvlv_packet->dst, dst, ETH_ALEN);
+	ether_addr_copy(unicast_tvlv_packet->src, src);
+	ether_addr_copy(unicast_tvlv_packet->dst, dst);
 
 	tvlv_buff = (unsigned char *)(unicast_tvlv_packet + 1);
 	tvlv_hdr = (struct batadv_tvlv_hdr *)tvlv_buff;
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 801ece6..a9546fe 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -819,7 +819,7 @@ static struct batadv_nc_node
 
 	/* Initialize nc_node */
 	INIT_LIST_HEAD(&nc_node->list);
-	memcpy(nc_node->addr, orig_node->orig, ETH_ALEN);
+	ether_addr_copy(nc_node->addr, orig_node->orig);
 	nc_node->orig_node = orig_neigh_node;
 	atomic_set(&nc_node->refcount, 2);
 
@@ -941,8 +941,8 @@ static struct batadv_nc_path *batadv_nc_get_path(struct batadv_priv *bat_priv,
 	spin_lock_init(&nc_path->packet_list_lock);
 	atomic_set(&nc_path->refcount, 2);
 	nc_path->last_valid = jiffies;
-	memcpy(nc_path->next_hop, dst, ETH_ALEN);
-	memcpy(nc_path->prev_hop, src, ETH_ALEN);
+	ether_addr_copy(nc_path->next_hop, dst);
+	ether_addr_copy(nc_path->prev_hop, src);
 
 	batadv_dbg(BATADV_DBG_NC, bat_priv, "Adding nc_path %pM -> %pM\n",
 		   nc_path->prev_hop,
@@ -1114,15 +1114,15 @@ static bool batadv_nc_code_packets(struct batadv_priv *bat_priv,
 	coded_packet->ttl = packet1->ttl;
 
 	/* Info about first unicast packet */
-	memcpy(coded_packet->first_source, first_source, ETH_ALEN);
-	memcpy(coded_packet->first_orig_dest, packet1->dest, ETH_ALEN);
+	ether_addr_copy(coded_packet->first_source, first_source);
+	ether_addr_copy(coded_packet->first_orig_dest, packet1->dest);
 	coded_packet->first_crc = packet_id1;
 	coded_packet->first_ttvn = packet1->ttvn;
 
 	/* Info about second unicast packet */
-	memcpy(coded_packet->second_dest, second_dest, ETH_ALEN);
-	memcpy(coded_packet->second_source, second_source, ETH_ALEN);
-	memcpy(coded_packet->second_orig_dest, packet2->dest, ETH_ALEN);
+	ether_addr_copy(coded_packet->second_dest, second_dest);
+	ether_addr_copy(coded_packet->second_source, second_source);
+	ether_addr_copy(coded_packet->second_orig_dest, packet2->dest);
 	coded_packet->second_crc = packet_id2;
 	coded_packet->second_ttl = packet2->ttl;
 	coded_packet->second_ttvn = packet2->ttvn;
@@ -1349,8 +1349,8 @@ static void batadv_nc_skb_store_before_coding(struct batadv_priv *bat_priv,
 
 	/* Set the mac header as if we actually sent the packet uncoded */
 	ethhdr = eth_hdr(skb);
-	memcpy(ethhdr->h_source, ethhdr->h_dest, ETH_ALEN);
-	memcpy(ethhdr->h_dest, eth_dst_new, ETH_ALEN);
+	ether_addr_copy(ethhdr->h_source, ethhdr->h_dest);
+	ether_addr_copy(ethhdr->h_dest, eth_dst_new);
 
 	/* Set data pointer to MAC header to mimic packets from our tx path */
 	skb_push(skb, ETH_HLEN);
@@ -1646,7 +1646,7 @@ batadv_nc_skb_decode_packet(struct batadv_priv *bat_priv, struct sk_buff *skb,
 		 * so the Ethernet address must be copied to h_dest and
 		 * pkt_type changed from PACKET_OTHERHOST to PACKET_HOST
 		 */
-		memcpy(ethhdr->h_dest, coded_packet_tmp.second_dest, ETH_ALEN);
+		ether_addr_copy(ethhdr->h_dest, coded_packet_tmp.second_dest);
 		skb->pkt_type = PACKET_HOST;
 
 		orig_dest = coded_packet_tmp.second_orig_dest;
@@ -1682,7 +1682,7 @@ batadv_nc_skb_decode_packet(struct batadv_priv *bat_priv, struct sk_buff *skb,
 	unicast_packet->packet_type = BATADV_UNICAST;
 	unicast_packet->version = BATADV_COMPAT_VERSION;
 	unicast_packet->ttl = ttl;
-	memcpy(unicast_packet->dest, orig_dest, ETH_ALEN);
+	ether_addr_copy(unicast_packet->dest, orig_dest);
 	unicast_packet->ttvn = ttvn;
 
 	batadv_nc_packet_free(nc_packet);
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 8539416..9f2da37 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -446,7 +446,7 @@ batadv_neigh_node_new(struct batadv_hard_iface *hard_iface,
 	INIT_HLIST_HEAD(&neigh_node->ifinfo_list);
 	spin_lock_init(&neigh_node->ifinfo_lock);
 
-	memcpy(neigh_node->addr, neigh_addr, ETH_ALEN);
+	ether_addr_copy(neigh_node->addr, neigh_addr);
 	neigh_node->if_incoming = hard_iface;
 	neigh_node->orig_node = orig_node;
 
@@ -666,7 +666,7 @@ struct batadv_orig_node *batadv_orig_node_new(struct batadv_priv *bat_priv,
 
 	orig_node->tt_initialised = false;
 	orig_node->bat_priv = bat_priv;
-	memcpy(orig_node->orig, addr, ETH_ALEN);
+	ether_addr_copy(orig_node->orig, addr);
 	batadv_dat_init_orig_node_addr(orig_node);
 	atomic_set(&orig_node->last_ttvn, 0);
 	orig_node->tt_buff = NULL;
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index a953d5b..3514153 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -222,8 +222,8 @@ static int batadv_recv_my_icmp_packet(struct batadv_priv *bat_priv,
 
 		icmph = (struct batadv_icmp_header *)skb->data;
 
-		memcpy(icmph->dst, icmph->orig, ETH_ALEN);
-		memcpy(icmph->orig, primary_if->net_dev->dev_addr, ETH_ALEN);
+		ether_addr_copy(icmph->dst, icmph->orig);
+		ether_addr_copy(icmph->orig, primary_if->net_dev->dev_addr);
 		icmph->msg_type = BATADV_ECHO_REPLY;
 		icmph->ttl = BATADV_TTL;
 
@@ -276,9 +276,8 @@ static int batadv_recv_icmp_ttl_exceeded(struct batadv_priv *bat_priv,
 
 	icmp_packet = (struct batadv_icmp_packet *)skb->data;
 
-	memcpy(icmp_packet->dst, icmp_packet->orig, ETH_ALEN);
-	memcpy(icmp_packet->orig, primary_if->net_dev->dev_addr,
-	       ETH_ALEN);
+	ether_addr_copy(icmp_packet->dst, icmp_packet->orig);
+	ether_addr_copy(icmp_packet->orig, primary_if->net_dev->dev_addr);
 	icmp_packet->msg_type = BATADV_TTL_EXCEEDED;
 	icmp_packet->ttl = BATADV_TTL;
 
@@ -341,8 +340,8 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 		if (icmp_packet_rr->rr_cur >= BATADV_RR_LEN)
 			goto out;
 
-		memcpy(&(icmp_packet_rr->rr[icmp_packet_rr->rr_cur]),
-		       ethhdr->h_dest, ETH_ALEN);
+		ether_addr_copy(icmp_packet_rr->rr[icmp_packet_rr->rr_cur],
+				ethhdr->h_dest);
 		icmp_packet_rr->rr_cur++;
 	}
 
@@ -664,7 +663,7 @@ batadv_reroute_unicast_packet(struct batadv_priv *bat_priv,
 	}
 
 	/* update the packet header */
-	memcpy(unicast_packet->dest, orig_addr, ETH_ALEN);
+	ether_addr_copy(unicast_packet->dest, orig_addr);
 	unicast_packet->ttvn = orig_ttvn;
 
 	ret = true;
@@ -774,7 +773,7 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 	if (!primary_if)
 		return 0;
 
-	memcpy(unicast_packet->dest, primary_if->net_dev->dev_addr, ETH_ALEN);
+	ether_addr_copy(unicast_packet->dest, primary_if->net_dev->dev_addr);
 
 	batadv_hardif_free_ref(primary_if);
 
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 1703a2e..0e4831f 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -59,8 +59,8 @@ int batadv_send_skb_packet(struct sk_buff *skb,
 	skb_reset_mac_header(skb);
 
 	ethhdr = eth_hdr(skb);
-	memcpy(ethhdr->h_source, hard_iface->net_dev->dev_addr, ETH_ALEN);
-	memcpy(ethhdr->h_dest, dst_addr, ETH_ALEN);
+	ether_addr_copy(ethhdr->h_source, hard_iface->net_dev->dev_addr);
+	ether_addr_copy(ethhdr->h_dest, dst_addr);
 	ethhdr->h_proto = htons(ETH_P_BATMAN);
 
 	skb_set_network_header(skb, ETH_HLEN);
@@ -165,7 +165,7 @@ batadv_send_skb_push_fill_unicast(struct sk_buff *skb, int hdr_size,
 	/* set unicast ttl */
 	unicast_packet->ttl = BATADV_TTL;
 	/* copy the destination for faster routing */
-	memcpy(unicast_packet->dest, orig_node->orig, ETH_ALEN);
+	ether_addr_copy(unicast_packet->dest, orig_node->orig);
 	/* set the destination tt version number */
 	unicast_packet->ttvn = ttvn;
 
@@ -220,7 +220,7 @@ bool batadv_send_skb_prepare_unicast_4addr(struct batadv_priv *bat_priv,
 
 	uc_4addr_packet = (struct batadv_unicast_4addr_packet *)skb->data;
 	uc_4addr_packet->u.packet_type = BATADV_UNICAST_4ADDR;
-	memcpy(uc_4addr_packet->src, primary_if->net_dev->dev_addr, ETH_ALEN);
+	ether_addr_copy(uc_4addr_packet->src, primary_if->net_dev->dev_addr);
 	uc_4addr_packet->subtype = packet_subtype;
 	uc_4addr_packet->reserved = 0;
 
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index c4392fc..db3e467 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -111,8 +111,8 @@ static int batadv_interface_set_mac_addr(struct net_device *dev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
-	memcpy(old_addr, dev->dev_addr, ETH_ALEN);
-	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+	ether_addr_copy(old_addr, dev->dev_addr);
+	ether_addr_copy(dev->dev_addr, addr->sa_data);
 
 	/* only modify transtable if it has been initialized before */
 	if (atomic_read(&bat_priv->mesh_state) == BATADV_MESH_ACTIVE) {
@@ -279,8 +279,8 @@ send:
 		/* hw address of first interface is the orig mac because only
 		 * this mac is known throughout the mesh
 		 */
-		memcpy(bcast_packet->orig,
-		       primary_if->net_dev->dev_addr, ETH_ALEN);
+		ether_addr_copy(bcast_packet->orig,
+				primary_if->net_dev->dev_addr);
 
 		/* set broadcast sequence number */
 		seqno = atomic_inc_return(&bat_priv->bcast_seqno);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 959dde7..6d0da58 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -96,7 +96,7 @@ batadv_tt_hash_find(struct batadv_hashtable *hash, const uint8_t *addr,
 	if (!hash)
 		return NULL;
 
-	memcpy(to_search.addr, addr, ETH_ALEN);
+	ether_addr_copy(to_search.addr, addr);
 	to_search.vid = vid;
 
 	index = batadv_choose_tt(&to_search, hash->size);
@@ -333,7 +333,7 @@ static void batadv_tt_local_event(struct batadv_priv *bat_priv,
 	tt_change_node->change.flags = flags;
 	memset(tt_change_node->change.reserved, 0,
 	       sizeof(tt_change_node->change.reserved));
-	memcpy(tt_change_node->change.addr, common->addr, ETH_ALEN);
+	ether_addr_copy(tt_change_node->change.addr, common->addr);
 	tt_change_node->change.vid = htons(common->vid);
 
 	del_op_requested = flags & BATADV_TT_CLIENT_DEL;
@@ -549,7 +549,7 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 		   addr, BATADV_PRINT_VID(vid),
 		   (uint8_t)atomic_read(&bat_priv->tt.vn));
 
-	memcpy(tt_local->common.addr, addr, ETH_ALEN);
+	ether_addr_copy(tt_local->common.addr, addr);
 	/* The local entry has to be marked as NEW to avoid to send it in
 	 * a full table response going out before the next ttvn increment
 	 * (consistency check)
@@ -1277,7 +1277,7 @@ static bool batadv_tt_global_add(struct batadv_priv *bat_priv,
 			goto out;
 
 		common = &tt_global_entry->common;
-		memcpy(common->addr, tt_addr, ETH_ALEN);
+		ether_addr_copy(common->addr, tt_addr);
 		common->vid = vid;
 
 		common->flags = flags;
@@ -2160,7 +2160,7 @@ batadv_new_tt_req_node(struct batadv_priv *bat_priv,
 	if (!tt_req_node)
 		goto unlock;
 
-	memcpy(tt_req_node->addr, orig_node->orig, ETH_ALEN);
+	ether_addr_copy(tt_req_node->addr, orig_node->orig);
 	tt_req_node->issued_at = jiffies;
 
 	list_add(&tt_req_node->list, &bat_priv->tt.req_list);
@@ -2240,8 +2240,7 @@ static void batadv_tt_tvlv_generate(struct batadv_priv *bat_priv,
 			if ((valid_cb) && (!valid_cb(tt_common_entry, cb_data)))
 				continue;
 
-			memcpy(tt_change->addr, tt_common_entry->addr,
-			       ETH_ALEN);
+			ether_addr_copy(tt_change->addr, tt_common_entry->addr);
 			tt_change->flags = tt_common_entry->flags;
 			tt_change->vid = htons(tt_common_entry->vid);
 			memset(tt_change->reserved, 0,
@@ -2932,7 +2931,7 @@ static bool batadv_tt_check_roam_count(struct batadv_priv *bat_priv,
 		tt_roam_node->first_time = jiffies;
 		atomic_set(&tt_roam_node->counter,
 			   BATADV_ROAMING_MAX_COUNT - 1);
-		memcpy(tt_roam_node->addr, client, ETH_ALEN);
+		ether_addr_copy(tt_roam_node->addr, client);
 
 		list_add(&tt_roam_node->list, &bat_priv->tt.roam_list);
 		ret = true;
-- 
1.8.3.2
