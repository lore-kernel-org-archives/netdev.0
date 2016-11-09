From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 13/17] batman-adv: Consume skb in receive handlers
Date: Wed,  9 Nov 2016 23:26:02 +0100
Message-ID: <20161109222606.29039-14-sw@simonwunderlich.de>
References: <20161109222606.29039-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:55512 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754711AbcKIW0f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 17:26:35 -0500
In-Reply-To: <20161109222606.29039-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Receiving functions in Linux consume the supplied skbuff. Doing the same in
the batadv_rx_handler functions makes the behavior more similar to the rest
of the Linux network code.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bat_iv_ogm.c     |  22 ++++--
 net/batman-adv/bat_v_elp.c      |  30 ++++----
 net/batman-adv/bat_v_ogm.c      |  15 ++--
 net/batman-adv/main.c           |  11 +--
 net/batman-adv/network-coding.c |  11 +--
 net/batman-adv/routing.c        | 149 +++++++++++++++++++++++++++-------------
 6 files changed, 153 insertions(+), 85 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 310f391..bd39247 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1823,17 +1823,18 @@ static int batadv_iv_ogm_receive(struct sk_buff *skb,
 	struct batadv_ogm_packet *ogm_packet;
 	u8 *packet_pos;
 	int ogm_offset;
-	bool ret;
+	bool res;
+	int ret = NET_RX_DROP;
 
-	ret = batadv_check_management_packet(skb, if_incoming, BATADV_OGM_HLEN);
-	if (!ret)
-		return NET_RX_DROP;
+	res = batadv_check_management_packet(skb, if_incoming, BATADV_OGM_HLEN);
+	if (!res)
+		goto free_skb;
 
 	/* did we receive a B.A.T.M.A.N. IV OGM packet on an interface
 	 * that does not have B.A.T.M.A.N. IV enabled ?
 	 */
 	if (bat_priv->algo_ops->iface.enable != batadv_iv_ogm_iface_enable)
-		return NET_RX_DROP;
+		goto free_skb;
 
 	batadv_inc_counter(bat_priv, BATADV_CNT_MGMT_RX);
 	batadv_add_counter(bat_priv, BATADV_CNT_MGMT_RX_BYTES,
@@ -1854,8 +1855,15 @@ static int batadv_iv_ogm_receive(struct sk_buff *skb,
 		ogm_packet = (struct batadv_ogm_packet *)packet_pos;
 	}
 
-	consume_skb(skb);
-	return NET_RX_SUCCESS;
+	ret = NET_RX_SUCCESS;
+
+free_skb:
+	if (ret == NET_RX_SUCCESS)
+		consume_skb(skb);
+	else
+		kfree_skb(skb);
+
+	return ret;
 }
 
 #ifdef CONFIG_BATMAN_ADV_DEBUGFS
diff --git a/net/batman-adv/bat_v_elp.c b/net/batman-adv/bat_v_elp.c
index ee08540..54bdd41 100644
--- a/net/batman-adv/bat_v_elp.c
+++ b/net/batman-adv/bat_v_elp.c
@@ -492,20 +492,21 @@ int batadv_v_elp_packet_recv(struct sk_buff *skb,
 	struct batadv_elp_packet *elp_packet;
 	struct batadv_hard_iface *primary_if;
 	struct ethhdr *ethhdr = (struct ethhdr *)skb_mac_header(skb);
-	bool ret;
+	bool res;
+	int ret = NET_RX_DROP;
 
-	ret = batadv_check_management_packet(skb, if_incoming, BATADV_ELP_HLEN);
-	if (!ret)
-		return NET_RX_DROP;
+	res = batadv_check_management_packet(skb, if_incoming, BATADV_ELP_HLEN);
+	if (!res)
+		goto free_skb;
 
 	if (batadv_is_my_mac(bat_priv, ethhdr->h_source))
-		return NET_RX_DROP;
+		goto free_skb;
 
 	/* did we receive a B.A.T.M.A.N. V ELP packet on an interface
 	 * that does not have B.A.T.M.A.N. V ELP enabled ?
 	 */
 	if (strcmp(bat_priv->algo_ops->name, "BATMAN_V") != 0)
-		return NET_RX_DROP;
+		goto free_skb;
 
 	elp_packet = (struct batadv_elp_packet *)skb->data;
 
@@ -516,14 +517,19 @@ int batadv_v_elp_packet_recv(struct sk_buff *skb,
 
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
-		goto out;
+		goto free_skb;
 
 	batadv_v_elp_neigh_update(bat_priv, ethhdr->h_source, if_incoming,
 				  elp_packet);
 
-out:
-	if (primary_if)
-		batadv_hardif_put(primary_if);
-	consume_skb(skb);
-	return NET_RX_SUCCESS;
+	ret = NET_RX_SUCCESS;
+	batadv_hardif_put(primary_if);
+
+free_skb:
+	if (ret == NET_RX_SUCCESS)
+		consume_skb(skb);
+	else
+		kfree_skb(skb);
+
+	return ret;
 }
diff --git a/net/batman-adv/bat_v_ogm.c b/net/batman-adv/bat_v_ogm.c
index 9922ccd..38b9aab 100644
--- a/net/batman-adv/bat_v_ogm.c
+++ b/net/batman-adv/bat_v_ogm.c
@@ -810,18 +810,18 @@ int batadv_v_ogm_packet_recv(struct sk_buff *skb,
 	 * B.A.T.M.A.N. V enabled ?
 	 */
 	if (strcmp(bat_priv->algo_ops->name, "BATMAN_V") != 0)
-		return NET_RX_DROP;
+		goto free_skb;
 
 	if (!batadv_check_management_packet(skb, if_incoming, BATADV_OGM2_HLEN))
-		return NET_RX_DROP;
+		goto free_skb;
 
 	if (batadv_is_my_mac(bat_priv, ethhdr->h_source))
-		return NET_RX_DROP;
+		goto free_skb;
 
 	ogm_packet = (struct batadv_ogm2_packet *)skb->data;
 
 	if (batadv_is_my_mac(bat_priv, ogm_packet->orig))
-		return NET_RX_DROP;
+		goto free_skb;
 
 	batadv_inc_counter(bat_priv, BATADV_CNT_MGMT_RX);
 	batadv_add_counter(bat_priv, BATADV_CNT_MGMT_RX_BYTES,
@@ -842,7 +842,12 @@ int batadv_v_ogm_packet_recv(struct sk_buff *skb,
 	}
 
 	ret = NET_RX_SUCCESS;
-	consume_skb(skb);
+
+free_skb:
+	if (ret == NET_RX_SUCCESS)
+		consume_skb(skb);
+	else
+		kfree_skb(skb);
 
 	return ret;
 }
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 5e4e818..6b5dae6 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -402,6 +402,8 @@ void batadv_skb_set_priority(struct sk_buff *skb, int offset)
 static int batadv_recv_unhandled_packet(struct sk_buff *skb,
 					struct batadv_hard_iface *recv_if)
 {
+	kfree_skb(skb);
+
 	return NET_RX_DROP;
 }
 
@@ -416,7 +418,6 @@ int batadv_batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	struct batadv_ogm_packet *batadv_ogm_packet;
 	struct batadv_hard_iface *hard_iface;
 	u8 idx;
-	int ret;
 
 	hard_iface = container_of(ptype, struct batadv_hard_iface,
 				  batman_adv_ptype);
@@ -466,14 +467,8 @@ int batadv_batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	/* reset control block to avoid left overs from previous users */
 	memset(skb->cb, 0, sizeof(struct batadv_skb_cb));
 
-	/* all receive handlers return whether they received or reused
-	 * the supplied skb. if not, we have to free the skb.
-	 */
 	idx = batadv_ogm_packet->packet_type;
-	ret = (*batadv_rx_handler[idx])(skb, hard_iface);
-
-	if (ret == NET_RX_DROP)
-		kfree_skb(skb);
+	(*batadv_rx_handler[idx])(skb, hard_iface);
 
 	batadv_hardif_put(hard_iface);
 
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 3af66d3..ab5a3bf 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -1819,11 +1819,11 @@ static int batadv_nc_recv_coded_packet(struct sk_buff *skb,
 
 	/* Check if network coding is enabled */
 	if (!atomic_read(&bat_priv->network_coding))
-		return NET_RX_DROP;
+		goto free_skb;
 
 	/* Make sure we can access (and remove) header */
 	if (unlikely(!pskb_may_pull(skb, hdr_size)))
-		return NET_RX_DROP;
+		goto free_skb;
 
 	coded_packet = (struct batadv_coded_packet *)skb->data;
 	ethhdr = eth_hdr(skb);
@@ -1831,7 +1831,7 @@ static int batadv_nc_recv_coded_packet(struct sk_buff *skb,
 	/* Verify frame is destined for us */
 	if (!batadv_is_my_mac(bat_priv, ethhdr->h_dest) &&
 	    !batadv_is_my_mac(bat_priv, coded_packet->second_dest))
-		return NET_RX_DROP;
+		goto free_skb;
 
 	/* Update stat counter */
 	if (batadv_is_my_mac(bat_priv, coded_packet->second_dest))
@@ -1841,7 +1841,7 @@ static int batadv_nc_recv_coded_packet(struct sk_buff *skb,
 						   coded_packet);
 	if (!nc_packet) {
 		batadv_inc_counter(bat_priv, BATADV_CNT_NC_DECODE_FAILED);
-		return NET_RX_DROP;
+		goto free_skb;
 	}
 
 	/* Make skb's linear, because decoding accesses the entire buffer */
@@ -1867,6 +1867,9 @@ static int batadv_nc_recv_coded_packet(struct sk_buff *skb,
 
 free_nc_packet:
 	batadv_nc_packet_free(nc_packet, true);
+free_skb:
+	kfree_skb(skb);
+
 	return NET_RX_DROP;
 }
 
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 4d2679a..105d4fc 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -262,8 +262,11 @@ static int batadv_recv_my_icmp_packet(struct batadv_priv *bat_priv,
 		icmph->ttl = BATADV_TTL;
 
 		res = batadv_send_skb_to_orig(skb, orig_node, NULL);
-		ret = NET_RX_SUCCESS;
+		if (res == NET_XMIT_SUCCESS)
+			ret = NET_RX_SUCCESS;
 
+		/* skb was consumed */
+		skb = NULL;
 		break;
 	case BATADV_TP:
 		if (!pskb_may_pull(skb, sizeof(struct batadv_icmp_tp_packet)))
@@ -271,6 +274,8 @@ static int batadv_recv_my_icmp_packet(struct batadv_priv *bat_priv,
 
 		batadv_tp_meter_recv(bat_priv, skb);
 		ret = NET_RX_SUCCESS;
+		/* skb was consumed */
+		skb = NULL;
 		goto out;
 	default:
 		/* drop unknown type */
@@ -281,6 +286,9 @@ static int batadv_recv_my_icmp_packet(struct batadv_priv *bat_priv,
 		batadv_hardif_put(primary_if);
 	if (orig_node)
 		batadv_orig_node_put(orig_node);
+
+	kfree_skb(skb);
+
 	return ret;
 }
 
@@ -322,13 +330,20 @@ static int batadv_recv_icmp_ttl_exceeded(struct batadv_priv *bat_priv,
 	icmp_packet->ttl = BATADV_TTL;
 
 	res = batadv_send_skb_to_orig(skb, orig_node, NULL);
-	ret = NET_RX_SUCCESS;
+	if (res == NET_RX_SUCCESS)
+		ret = NET_XMIT_SUCCESS;
+
+	/* skb was consumed */
+	skb = NULL;
 
 out:
 	if (primary_if)
 		batadv_hardif_put(primary_if);
 	if (orig_node)
 		batadv_orig_node_put(orig_node);
+
+	kfree_skb(skb);
+
 	return ret;
 }
 
@@ -345,21 +360,21 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 
 	/* drop packet if it has not necessary minimum size */
 	if (unlikely(!pskb_may_pull(skb, hdr_size)))
-		goto out;
+		goto free_skb;
 
 	ethhdr = eth_hdr(skb);
 
 	/* packet with unicast indication but broadcast recipient */
 	if (is_broadcast_ether_addr(ethhdr->h_dest))
-		goto out;
+		goto free_skb;
 
 	/* packet with broadcast sender address */
 	if (is_broadcast_ether_addr(ethhdr->h_source))
-		goto out;
+		goto free_skb;
 
 	/* not for me */
 	if (!batadv_is_my_mac(bat_priv, ethhdr->h_dest))
-		goto out;
+		goto free_skb;
 
 	icmph = (struct batadv_icmp_header *)skb->data;
 
@@ -368,17 +383,17 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 	     icmph->msg_type == BATADV_ECHO_REQUEST) &&
 	    (skb->len >= sizeof(struct batadv_icmp_packet_rr))) {
 		if (skb_linearize(skb) < 0)
-			goto out;
+			goto free_skb;
 
 		/* create a copy of the skb, if needed, to modify it. */
 		if (skb_cow(skb, ETH_HLEN) < 0)
-			goto out;
+			goto free_skb;
 
 		ethhdr = eth_hdr(skb);
 		icmph = (struct batadv_icmp_header *)skb->data;
 		icmp_packet_rr = (struct batadv_icmp_packet_rr *)icmph;
 		if (icmp_packet_rr->rr_cur >= BATADV_RR_LEN)
-			goto out;
+			goto free_skb;
 
 		ether_addr_copy(icmp_packet_rr->rr[icmp_packet_rr->rr_cur],
 				ethhdr->h_dest);
@@ -396,11 +411,11 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 	/* get routing information */
 	orig_node = batadv_orig_hash_find(bat_priv, icmph->dst);
 	if (!orig_node)
-		goto out;
+		goto free_skb;
 
 	/* create a copy of the skb, if needed, to modify it. */
 	if (skb_cow(skb, ETH_HLEN) < 0)
-		goto out;
+		goto put_orig_node;
 
 	icmph = (struct batadv_icmp_header *)skb->data;
 
@@ -409,11 +424,18 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 
 	/* route it */
 	res = batadv_send_skb_to_orig(skb, orig_node, recv_if);
-	ret = NET_RX_SUCCESS;
+	if (res == NET_XMIT_SUCCESS)
+		ret = NET_RX_SUCCESS;
 
-out:
+	/* skb was consumed */
+	skb = NULL;
+
+put_orig_node:
 	if (orig_node)
 		batadv_orig_node_put(orig_node);
+free_skb:
+	kfree_skb(skb);
+
 	return ret;
 }
 
@@ -662,18 +684,18 @@ static int batadv_route_unicast_packet(struct sk_buff *skb,
 	if (unicast_packet->ttl < 2) {
 		pr_debug("Warning - can't forward unicast packet from %pM to %pM: ttl exceeded\n",
 			 ethhdr->h_source, unicast_packet->dest);
-		goto out;
+		goto free_skb;
 	}
 
 	/* get routing information */
 	orig_node = batadv_orig_hash_find(bat_priv, unicast_packet->dest);
 
 	if (!orig_node)
-		goto out;
+		goto free_skb;
 
 	/* create a copy of the skb, if needed, to modify it. */
 	if (skb_cow(skb, ETH_HLEN) < 0)
-		goto out;
+		goto put_orig_node;
 
 	/* decrement ttl */
 	unicast_packet = (struct batadv_unicast_packet *)skb->data;
@@ -697,6 +719,11 @@ static int batadv_route_unicast_packet(struct sk_buff *skb,
 
 	len = skb->len;
 	res = batadv_send_skb_to_orig(skb, orig_node, recv_if);
+	if (res == NET_XMIT_SUCCESS)
+		ret = NET_RX_SUCCESS;
+
+	/* skb was consumed */
+	skb = NULL;
 
 	/* translate transmit result into receive result */
 	if (res == NET_XMIT_SUCCESS) {
@@ -706,11 +733,11 @@ static int batadv_route_unicast_packet(struct sk_buff *skb,
 				   len + ETH_HLEN);
 	}
 
-	ret = NET_RX_SUCCESS;
+put_orig_node:
+	batadv_orig_node_put(orig_node);
+free_skb:
+	kfree_skb(skb);
 
-out:
-	if (orig_node)
-		batadv_orig_node_put(orig_node);
 	return ret;
 }
 
@@ -895,14 +922,18 @@ int batadv_recv_unhandled_unicast_packet(struct sk_buff *skb,
 
 	check = batadv_check_unicast_packet(bat_priv, skb, hdr_size);
 	if (check < 0)
-		return NET_RX_DROP;
+		goto free_skb;
 
 	/* we don't know about this type, drop it. */
 	unicast_packet = (struct batadv_unicast_packet *)skb->data;
 	if (batadv_is_my_mac(bat_priv, unicast_packet->dest))
-		return NET_RX_DROP;
+		goto free_skb;
 
 	return batadv_route_unicast_packet(skb, recv_if);
+
+free_skb:
+	kfree_skb(skb);
+	return NET_RX_DROP;
 }
 
 int batadv_recv_unicast_packet(struct sk_buff *skb,
@@ -916,6 +947,7 @@ int batadv_recv_unicast_packet(struct sk_buff *skb,
 	int check, hdr_size = sizeof(*unicast_packet);
 	enum batadv_subtype subtype;
 	bool is4addr;
+	int ret = NET_RX_DROP;
 
 	unicast_packet = (struct batadv_unicast_packet *)skb->data;
 	unicast_4addr_packet = (struct batadv_unicast_4addr_packet *)skb->data;
@@ -935,9 +967,9 @@ int batadv_recv_unicast_packet(struct sk_buff *skb,
 		batadv_nc_skb_store_sniffed_unicast(bat_priv, skb);
 
 	if (check < 0)
-		return NET_RX_DROP;
+		goto free_skb;
 	if (!batadv_check_unicast_ttvn(bat_priv, skb, hdr_size))
-		return NET_RX_DROP;
+		goto free_skb;
 
 	/* packet for me */
 	if (batadv_is_my_mac(bat_priv, unicast_packet->dest)) {
@@ -975,7 +1007,14 @@ int batadv_recv_unicast_packet(struct sk_buff *skb,
 		return NET_RX_SUCCESS;
 	}
 
-	return batadv_route_unicast_packet(skb, recv_if);
+	ret = batadv_route_unicast_packet(skb, recv_if);
+	/* skb was consumed */
+	skb = NULL;
+
+free_skb:
+	kfree_skb(skb);
+
+	return ret;
 }
 
 /**
@@ -997,15 +1036,15 @@ int batadv_recv_unicast_tvlv(struct sk_buff *skb,
 	int ret = NET_RX_DROP;
 
 	if (batadv_check_unicast_packet(bat_priv, skb, hdr_size) < 0)
-		return NET_RX_DROP;
+		goto free_skb;
 
 	/* the header is likely to be modified while forwarding */
 	if (skb_cow(skb, hdr_size) < 0)
-		return NET_RX_DROP;
+		goto free_skb;
 
 	/* packet needs to be linearized to access the tvlv content */
 	if (skb_linearize(skb) < 0)
-		return NET_RX_DROP;
+		goto free_skb;
 
 	unicast_tvlv_packet = (struct batadv_unicast_tvlv_packet *)skb->data;
 
@@ -1013,17 +1052,21 @@ int batadv_recv_unicast_tvlv(struct sk_buff *skb,
 	tvlv_buff_len = ntohs(unicast_tvlv_packet->tvlv_len);
 
 	if (tvlv_buff_len > skb->len - hdr_size)
-		return NET_RX_DROP;
+		goto free_skb;
 
 	ret = batadv_tvlv_containers_process(bat_priv, false, NULL,
 					     unicast_tvlv_packet->src,
 					     unicast_tvlv_packet->dst,
 					     tvlv_buff, tvlv_buff_len);
 
-	if (ret != NET_RX_SUCCESS)
+	if (ret != NET_RX_SUCCESS) {
 		ret = batadv_route_unicast_packet(skb, recv_if);
-	else
-		consume_skb(skb);
+		/* skb was consumed */
+		skb = NULL;
+	}
+
+free_skb:
+	kfree_skb(skb);
 
 	return ret;
 }
@@ -1049,20 +1092,22 @@ int batadv_recv_frag_packet(struct sk_buff *skb,
 
 	if (batadv_check_unicast_packet(bat_priv, skb,
 					sizeof(*frag_packet)) < 0)
-		goto out;
+		goto free_skb;
 
 	frag_packet = (struct batadv_frag_packet *)skb->data;
 	orig_node_src = batadv_orig_hash_find(bat_priv, frag_packet->orig);
 	if (!orig_node_src)
-		goto out;
+		goto free_skb;
 
 	skb->priority = frag_packet->priority + 256;
 
 	/* Route the fragment if it is not for us and too big to be merged. */
 	if (!batadv_is_my_mac(bat_priv, frag_packet->dest) &&
 	    batadv_frag_skb_fwd(skb, recv_if, orig_node_src)) {
+		/* skb was consumed */
+		skb = NULL;
 		ret = NET_RX_SUCCESS;
-		goto out;
+		goto put_orig_node;
 	}
 
 	batadv_inc_counter(bat_priv, BATADV_CNT_FRAG_RX);
@@ -1070,20 +1115,24 @@ int batadv_recv_frag_packet(struct sk_buff *skb,
 
 	/* Add fragment to buffer and merge if possible. */
 	if (!batadv_frag_skb_buffer(&skb, orig_node_src))
-		goto out;
+		goto put_orig_node;
 
 	/* Deliver merged packet to the appropriate handler, if it was
 	 * merged
 	 */
-	if (skb)
+	if (skb) {
 		batadv_batman_skb_recv(skb, recv_if->net_dev,
 				       &recv_if->batman_adv_ptype, NULL);
+		/* skb was consumed */
+		skb = NULL;
+	}
 
 	ret = NET_RX_SUCCESS;
 
-out:
-	if (orig_node_src)
-		batadv_orig_node_put(orig_node_src);
+put_orig_node:
+	batadv_orig_node_put(orig_node_src);
+free_skb:
+	kfree_skb(skb);
 
 	return ret;
 }
@@ -1102,35 +1151,35 @@ int batadv_recv_bcast_packet(struct sk_buff *skb,
 
 	/* drop packet if it has not necessary minimum size */
 	if (unlikely(!pskb_may_pull(skb, hdr_size)))
-		goto out;
+		goto free_skb;
 
 	ethhdr = eth_hdr(skb);
 
 	/* packet with broadcast indication but unicast recipient */
 	if (!is_broadcast_ether_addr(ethhdr->h_dest))
-		goto out;
+		goto free_skb;
 
 	/* packet with broadcast sender address */
 	if (is_broadcast_ether_addr(ethhdr->h_source))
-		goto out;
+		goto free_skb;
 
 	/* ignore broadcasts sent by myself */
 	if (batadv_is_my_mac(bat_priv, ethhdr->h_source))
-		goto out;
+		goto free_skb;
 
 	bcast_packet = (struct batadv_bcast_packet *)skb->data;
 
 	/* ignore broadcasts originated by myself */
 	if (batadv_is_my_mac(bat_priv, bcast_packet->orig))
-		goto out;
+		goto free_skb;
 
 	if (bcast_packet->ttl < 2)
-		goto out;
+		goto free_skb;
 
 	orig_node = batadv_orig_hash_find(bat_priv, bcast_packet->orig);
 
 	if (!orig_node)
-		goto out;
+		goto free_skb;
 
 	spin_lock_bh(&orig_node->bcast_seqno_lock);
 
@@ -1158,7 +1207,7 @@ int batadv_recv_bcast_packet(struct sk_buff *skb,
 
 	/* check whether this has been sent by another originator before */
 	if (batadv_bla_check_bcast_duplist(bat_priv, skb))
-		goto out;
+		goto free_skb;
 
 	batadv_skb_set_priority(skb, sizeof(struct batadv_bcast_packet));
 
@@ -1169,7 +1218,7 @@ int batadv_recv_bcast_packet(struct sk_buff *skb,
 	 * from the same backbone.
 	 */
 	if (batadv_bla_is_backbone_gw(skb, orig_node, hdr_size))
-		goto out;
+		goto free_skb;
 
 	if (batadv_dat_snoop_incoming_arp_request(bat_priv, skb, hdr_size))
 		goto rx_success;
@@ -1185,6 +1234,8 @@ int batadv_recv_bcast_packet(struct sk_buff *skb,
 
 spin_unlock:
 	spin_unlock_bh(&orig_node->bcast_seqno_lock);
+free_skb:
+	kfree_skb(skb);
 out:
 	if (orig_node)
 		batadv_orig_node_put(orig_node);
-- 
2.10.1
