From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 11/13] batman-adv: use ETH_HLEN instead of sizeof(struct ethhdr)
Date: Wed, 18 Apr 2012 12:00:08 +0200
Message-ID: <1334743210-12338-12-git-send-email-ordex@autistici.org>
References: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:25084 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752781Ab2DRJ7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 05:59:43 -0400
In-Reply-To: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using sizeof(struct ethhdr) it is strongly recommended to use the
kernel macro ETH_HLEN. This patch substitute each occurrence of the former
expressione with the latter one.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c            |    7 +++----
 net/batman-adv/bridge_loop_avoidance.c |   10 ++++------
 net/batman-adv/hard-interface.c        |    3 +--
 net/batman-adv/icmp_socket.c           |    4 ++--
 net/batman-adv/routing.c               |    8 ++++----
 net/batman-adv/send.c                  |    2 +-
 net/batman-adv/soft-interface.c        |    2 +-
 net/batman-adv/types.h                 |    2 +-
 net/batman-adv/vis.c                   |    8 ++++----
 9 files changed, 21 insertions(+), 25 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 98f7182..d7fa8af 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -355,10 +355,9 @@ static void bat_iv_ogm_aggregate_new(const unsigned char *packet_buff,
 	if ((atomic_read(&bat_priv->aggregated_ogms)) &&
 	    (packet_len < MAX_AGGREGATION_BYTES))
 		forw_packet_aggr->skb = dev_alloc_skb(MAX_AGGREGATION_BYTES +
-						      sizeof(struct ethhdr));
+						      ETH_HLEN);
 	else
-		forw_packet_aggr->skb = dev_alloc_skb(packet_len +
-						      sizeof(struct ethhdr));
+		forw_packet_aggr->skb = dev_alloc_skb(packet_len + ETH_HLEN);
 
 	if (!forw_packet_aggr->skb) {
 		if (!own_packet)
@@ -366,7 +365,7 @@ static void bat_iv_ogm_aggregate_new(const unsigned char *packet_buff,
 		kfree(forw_packet_aggr);
 		goto out;
 	}
-	skb_reserve(forw_packet_aggr->skb, sizeof(struct ethhdr));
+	skb_reserve(forw_packet_aggr->skb, ETH_HLEN);
 
 	INIT_HLIST_NODE(&forw_packet_aggr->list);
 
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index c8642b5..ad394c6 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -290,9 +290,7 @@ static void bla_send_claim(struct bat_priv *bat_priv, uint8_t *mac,
 		goto out;
 
 	ethhdr = (struct ethhdr *)skb->data;
-	hw_src = (uint8_t *)ethhdr +
-		 sizeof(struct ethhdr) +
-		 sizeof(struct arphdr);
+	hw_src = (uint8_t *)ethhdr + ETH_HLEN + sizeof(struct arphdr);
 
 	/* now we pretend that the client would have sent this ... */
 	switch (claimtype) {
@@ -340,7 +338,7 @@ static void bla_send_claim(struct bat_priv *bat_priv, uint8_t *mac,
 	skb_reset_mac_header(skb);
 	skb->protocol = eth_type_trans(skb, soft_iface);
 	bat_priv->stats.rx_packets++;
-	bat_priv->stats.rx_bytes += skb->len + sizeof(struct ethhdr);
+	bat_priv->stats.rx_bytes += skb->len + ETH_HLEN;
 	soft_iface->last_rx = jiffies;
 
 	netif_rx(skb);
@@ -844,7 +842,7 @@ static int bla_process_claim(struct bat_priv *bat_priv,
 		headlen = sizeof(*vhdr);
 	} else {
 		proto = ntohs(ethhdr->h_proto);
-		headlen = sizeof(*ethhdr);
+		headlen = ETH_HLEN;
 	}
 
 	if (proto != ETH_P_ARP)
@@ -1302,7 +1300,7 @@ int bla_is_backbone_gw(struct sk_buff *skb,
 		return 0;
 
 	/* first, find out the vid. */
-	if (!pskb_may_pull(skb, hdr_size + sizeof(struct ethhdr)))
+	if (!pskb_may_pull(skb, hdr_size + ETH_HLEN))
 		return 0;
 
 	ethhdr = (struct ethhdr *)(((uint8_t *)skb->data) + hdr_size);
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index e8c5da3..47c79d7 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -574,8 +574,7 @@ static int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		goto err_free;
 
 	/* expect a valid ethernet header here. */
-	if (unlikely(skb->mac_len != sizeof(struct ethhdr) ||
-		     !skb_mac_header(skb)))
+	if (unlikely(skb->mac_len != ETH_HLEN || !skb_mac_header(skb)))
 		goto err_free;
 
 	if (!hard_iface->soft_iface)
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index b87518e..2e98a57 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -175,13 +175,13 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 	if (len >= sizeof(struct icmp_packet_rr))
 		packet_len = sizeof(struct icmp_packet_rr);
 
-	skb = dev_alloc_skb(packet_len + sizeof(struct ethhdr));
+	skb = dev_alloc_skb(packet_len + ETH_HLEN);
 	if (!skb) {
 		len = -ENOMEM;
 		goto out;
 	}
 
-	skb_reserve(skb, sizeof(struct ethhdr));
+	skb_reserve(skb, ETH_HLEN);
 	icmp_packet = (struct icmp_packet_rr *)skb_put(skb, packet_len);
 
 	if (copy_from_user(icmp_packet, buff, packet_len)) {
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index ac13a6a..ff56086 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -313,7 +313,7 @@ static int recv_my_icmp_packet(struct bat_priv *bat_priv,
 		goto out;
 
 	/* create a copy of the skb, if needed, to modify it. */
-	if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
+	if (skb_cow(skb, ETH_HLEN) < 0)
 		goto out;
 
 	icmp_packet = (struct icmp_packet_rr *)skb->data;
@@ -368,7 +368,7 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
 		goto out;
 
 	/* create a copy of the skb, if needed, to modify it. */
-	if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
+	if (skb_cow(skb, ETH_HLEN) < 0)
 		goto out;
 
 	icmp_packet = (struct icmp_packet *)skb->data;
@@ -454,7 +454,7 @@ int recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 		goto out;
 
 	/* create a copy of the skb, if needed, to modify it. */
-	if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
+	if (skb_cow(skb, ETH_HLEN) < 0)
 		goto out;
 
 	icmp_packet = (struct icmp_packet_rr *)skb->data;
@@ -841,7 +841,7 @@ static int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 		goto out;
 
 	/* create a copy of the skb, if needed, to modify it. */
-	if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
+	if (skb_cow(skb, ETH_HLEN) < 0)
 		goto out;
 
 	unicast_packet = (struct unicast_packet *)skb->data;
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index b5f078c..7c66b61 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -51,7 +51,7 @@ int send_skb_packet(struct sk_buff *skb, struct hard_iface *hard_iface,
 	}
 
 	/* push to the ethernet header. */
-	if (my_skb_head_push(skb, sizeof(*ethhdr)) < 0)
+	if (my_skb_head_push(skb, ETH_HLEN) < 0)
 		goto send_skb_err;
 
 	skb_reset_mac_header(skb);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index efe0fba..6e2530b 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -292,7 +292,7 @@ void interface_rx(struct net_device *soft_iface,
 /*	skb->ip_summed = CHECKSUM_UNNECESSARY;*/
 
 	bat_priv->stats.rx_packets++;
-	bat_priv->stats.rx_bytes += skb->len + sizeof(struct ethhdr);
+	bat_priv->stats.rx_bytes += skb->len + ETH_HLEN;
 
 	soft_iface->last_rx = jiffies;
 
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 4d93aad..2f4848b 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -27,7 +27,7 @@
 #include "packet.h"
 #include "bitarray.h"
 
-#define BAT_HEADER_LEN (sizeof(struct ethhdr) + \
+#define BAT_HEADER_LEN (ETH_HLEN + \
 	((sizeof(struct unicast_packet) > sizeof(struct bcast_packet) ? \
 	 sizeof(struct unicast_packet) : \
 	 sizeof(struct bcast_packet))))
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index c4a5b8c..cec216f 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -434,12 +434,12 @@ static struct vis_info *add_packet(struct bat_priv *bat_priv,
 		return NULL;
 
 	info->skb_packet = dev_alloc_skb(sizeof(*packet) + vis_info_len +
-					 sizeof(struct ethhdr));
+					 ETH_HLEN);
 	if (!info->skb_packet) {
 		kfree(info);
 		return NULL;
 	}
-	skb_reserve(info->skb_packet, sizeof(struct ethhdr));
+	skb_reserve(info->skb_packet, ETH_HLEN);
 	packet = (struct vis_packet *)skb_put(info->skb_packet, sizeof(*packet)
 					      + vis_info_len);
 
@@ -894,11 +894,11 @@ int vis_init(struct bat_priv *bat_priv)
 
 	bat_priv->my_vis_info->skb_packet = dev_alloc_skb(sizeof(*packet) +
 							  MAX_VIS_PACKET_SIZE +
-							 sizeof(struct ethhdr));
+							  ETH_HLEN);
 	if (!bat_priv->my_vis_info->skb_packet)
 		goto free_info;
 
-	skb_reserve(bat_priv->my_vis_info->skb_packet, sizeof(struct ethhdr));
+	skb_reserve(bat_priv->my_vis_info->skb_packet, ETH_HLEN);
 	packet = (struct vis_packet *)skb_put(bat_priv->my_vis_info->skb_packet,
 					      sizeof(*packet));
 
-- 
1.7.9.4
