From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] batman-adv: Use net_device_stats from struct net_device
Date: Wed,  5 Apr 2017 13:46:31 +0200
Message-ID: <1491392791-30041-1-git-send-email-tklauser@distanz.ch>
Cc: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org
To: Marek Lindner <mareklindner@neomailbox.ch>,
        Simon Wunderlich <sw@simonwunderlich.de>,
        Antonio Quartulli <a@unstable.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:39955 "EHLO sym2.noone.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933583AbdDELqe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 07:46:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a private copy of struct net_device_stats in struct
batadv_priv, use stats from struct net_device.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/batman-adv/distributed-arp-table.c | 9 +++++----
 net/batman-adv/soft-interface.c        | 2 +-
 net/batman-adv/types.h                 | 2 --
 3 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 1bfd1dbc2feb..936b08ee5b45 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -1002,6 +1002,7 @@ bool batadv_dat_snoop_outgoing_arp_request(struct batadv_priv *bat_priv,
 	bool ret = false;
 	struct batadv_dat_entry *dat_entry = NULL;
 	struct sk_buff *skb_new;
+	struct net_device *soft_iface = bat_priv->soft_iface;
 	int hdr_size = 0;
 	unsigned short vid;
 
@@ -1046,10 +1047,10 @@ bool batadv_dat_snoop_outgoing_arp_request(struct batadv_priv *bat_priv,
 		if (!skb_new)
 			goto out;
 
-		skb_new->protocol = eth_type_trans(skb_new,
-						   bat_priv->soft_iface);
-		bat_priv->stats.rx_packets++;
-		bat_priv->stats.rx_bytes += skb->len + ETH_HLEN + hdr_size;
+		skb_new->protocol = eth_type_trans(skb_new, soft_iface);
+
+		soft_iface->stats.rx_packets++;
+		soft_iface->stats.rx_bytes += skb->len + ETH_HLEN + hdr_size;
 
 		netif_rx(skb_new);
 		batadv_dbg(BATADV_DBG_DAT, bat_priv, "ARP request replied locally\n");
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index d042c99af028..71895c58e6d8 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -140,7 +140,7 @@ static u64 batadv_sum_counter(struct batadv_priv *bat_priv,  size_t idx)
 static struct net_device_stats *batadv_interface_stats(struct net_device *dev)
 {
 	struct batadv_priv *bat_priv = netdev_priv(dev);
-	struct net_device_stats *stats = &bat_priv->stats;
+	struct net_device_stats *stats = &dev->stats;
 
 	stats->tx_packets = batadv_sum_counter(bat_priv, BATADV_CNT_TX);
 	stats->tx_bytes = batadv_sum_counter(bat_priv, BATADV_CNT_TX_BYTES);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 246f21b4973b..5c55e48d8941 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1000,7 +1000,6 @@ struct batadv_priv_bat_v {
  * struct batadv_priv - per mesh interface data
  * @mesh_state: current status of the mesh (inactive/active/deactivating)
  * @soft_iface: net device which holds this struct as private data
- * @stats: structure holding the data for the ndo_get_stats() call
  * @bat_counters: mesh internal traffic statistic counters (see batadv_counters)
  * @aggregated_ogms: bool indicating whether OGM aggregation is enabled
  * @bonding: bool indicating whether traffic bonding is enabled
@@ -1055,7 +1054,6 @@ struct batadv_priv_bat_v {
 struct batadv_priv {
 	atomic_t mesh_state;
 	struct net_device *soft_iface;
-	struct net_device_stats stats;
 	u64 __percpu *bat_counters; /* Per cpu counters */
 	atomic_t aggregated_ogms;
 	atomic_t bonding;
-- 
2.12.2.399.g034667a45805
