From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 05/18] batman-adv: convert remaining packet counters to per_cpu_ptr() infrastructure
Date: Thu, 23 Aug 2012 15:10:14 +0200
Message-ID: <1345727427-20805-6-git-send-email-ordex@autistici.org>
References: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:28737 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932993Ab2HWNKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:10:51 -0400
In-Reply-To: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bridge_loop_avoidance.c |    5 ++--
 net/batman-adv/soft-interface.c        |   51 +++++++++++++++++++++---=
--------
 net/batman-adv/types.h                 |    5 ++++
 3 files changed, 42 insertions(+), 19 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/br=
idge_loop_avoidance.c
index 84dd841..c9732ac 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -340,8 +340,9 @@ static void batadv_bla_send_claim(struct batadv_pri=
v *bat_priv, uint8_t *mac,
=20
 	skb_reset_mac_header(skb);
 	skb->protocol =3D eth_type_trans(skb, soft_iface);
-	bat_priv->stats.rx_packets++;
-	bat_priv->stats.rx_bytes +=3D skb->len + ETH_HLEN;
+	batadv_inc_counter(bat_priv, BATADV_CNT_RX);
+	batadv_add_counter(bat_priv, BATADV_CNT_RX_BYTES,
+			   skb->len + ETH_HLEN);
 	soft_iface->last_rx =3D jiffies;
=20
 	netif_rx(skb);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 109ea2a..2b3842b 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -93,7 +93,14 @@ static int batadv_interface_release(struct net_devic=
e *dev)
 static struct net_device_stats *batadv_interface_stats(struct net_devi=
ce *dev)
 {
 	struct batadv_priv *bat_priv =3D netdev_priv(dev);
-	return &bat_priv->stats;
+	struct net_device_stats *stats =3D &bat_priv->stats;
+
+	stats->tx_packets =3D batadv_sum_counter(bat_priv, BATADV_CNT_TX);
+	stats->tx_bytes =3D batadv_sum_counter(bat_priv, BATADV_CNT_TX_BYTES)=
;
+	stats->tx_dropped =3D batadv_sum_counter(bat_priv, BATADV_CNT_TX_DROP=
PED);
+	stats->rx_packets =3D batadv_sum_counter(bat_priv, BATADV_CNT_RX);
+	stats->rx_bytes =3D batadv_sum_counter(bat_priv, BATADV_CNT_RX_BYTES)=
;
+	return stats;
 }
=20
 static int batadv_interface_set_mac_addr(struct net_device *dev, void =
*p)
@@ -246,14 +253,14 @@ static int batadv_interface_tx(struct sk_buff *sk=
b,
 			goto dropped_freed;
 	}
=20
-	bat_priv->stats.tx_packets++;
-	bat_priv->stats.tx_bytes +=3D data_len;
+	batadv_inc_counter(bat_priv, BATADV_CNT_TX);
+	batadv_add_counter(bat_priv, BATADV_CNT_TX_BYTES, data_len);
 	goto end;
=20
 dropped:
 	kfree_skb(skb);
 dropped_freed:
-	bat_priv->stats.tx_dropped++;
+	batadv_inc_counter(bat_priv, BATADV_CNT_TX_DROPPED);
 end:
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
@@ -308,8 +315,9 @@ void batadv_interface_rx(struct net_device *soft_if=
ace,
=20
 	/* skb->ip_summed =3D CHECKSUM_UNNECESSARY; */
=20
-	bat_priv->stats.rx_packets++;
-	bat_priv->stats.rx_bytes +=3D skb->len + ETH_HLEN;
+	batadv_inc_counter(bat_priv, BATADV_CNT_RX);
+	batadv_add_counter(bat_priv, BATADV_CNT_RX_BYTES,
+			   skb->len + ETH_HLEN);
=20
 	soft_iface->last_rx =3D jiffies;
=20
@@ -379,15 +387,22 @@ struct net_device *batadv_softif_create(const cha=
r *name)
 	if (!soft_iface)
 		goto out;
=20
+	bat_priv =3D netdev_priv(soft_iface);
+
+	/* batadv_interface_stats() needs to be available as soon as
+	 * register_netdevice() has been called
+	 */
+	bat_priv->bat_counters =3D __alloc_percpu(cnt_len, __alignof__(uint64=
_t));
+	if (!bat_priv->bat_counters)
+		goto free_soft_iface;
+
 	ret =3D register_netdevice(soft_iface);
 	if (ret < 0) {
 		pr_err("Unable to register the batman interface '%s': %i\n",
 		       name, ret);
-		goto free_soft_iface;
+		goto free_bat_counters;
 	}
=20
-	bat_priv =3D netdev_priv(soft_iface);
-
 	atomic_set(&bat_priv->aggregated_ogms, 1);
 	atomic_set(&bat_priv->bonding, 0);
 	atomic_set(&bat_priv->bridge_loop_avoidance, 0);
@@ -417,17 +432,13 @@ struct net_device *batadv_softif_create(const cha=
r *name)
 	bat_priv->primary_if =3D NULL;
 	bat_priv->num_ifaces =3D 0;
=20
-	bat_priv->bat_counters =3D __alloc_percpu(cnt_len, __alignof__(uint64=
_t));
-	if (!bat_priv->bat_counters)
-		goto unreg_soft_iface;
-
 	ret =3D batadv_algo_select(bat_priv, batadv_routing_algo);
 	if (ret < 0)
-		goto free_bat_counters;
+		goto unreg_soft_iface;
=20
 	ret =3D batadv_sysfs_add_meshif(soft_iface);
 	if (ret < 0)
-		goto free_bat_counters;
+		goto unreg_soft_iface;
=20
 	ret =3D batadv_debugfs_add_meshif(soft_iface);
 	if (ret < 0)
@@ -443,12 +454,13 @@ unreg_debugfs:
 	batadv_debugfs_del_meshif(soft_iface);
 unreg_sysfs:
 	batadv_sysfs_del_meshif(soft_iface);
-free_bat_counters:
-	free_percpu(bat_priv->bat_counters);
 unreg_soft_iface:
+	free_percpu(bat_priv->bat_counters);
 	unregister_netdevice(soft_iface);
 	return NULL;
=20
+free_bat_counters:
+	free_percpu(bat_priv->bat_counters);
 free_soft_iface:
 	free_netdev(soft_iface);
 out:
@@ -518,6 +530,11 @@ static u32 batadv_get_link(struct net_device *dev)
 static const struct {
 	const char name[ETH_GSTRING_LEN];
 } batadv_counters_strings[] =3D {
+	{ "tx" },
+	{ "tx_bytes" },
+	{ "tx_dropped" },
+	{ "rx" },
+	{ "rx_bytes" },
 	{ "forward" },
 	{ "forward_bytes" },
 	{ "mgmt_tx" },
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 12635fd..7812b6e 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -145,6 +145,11 @@ struct batadv_bcast_duplist_entry {
 #endif
=20
 enum batadv_counters {
+	BATADV_CNT_TX,
+	BATADV_CNT_TX_BYTES,
+	BATADV_CNT_TX_DROPPED,
+	BATADV_CNT_RX,
+	BATADV_CNT_RX_BYTES,
 	BATADV_CNT_FORWARD,
 	BATADV_CNT_FORWARD_BYTES,
 	BATADV_CNT_MGMT_TX,
--=20
1.7.9.4
