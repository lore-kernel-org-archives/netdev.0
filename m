From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 8/9] batman-adv: Distributed ARP Table - add runtime switch
Date: Sat,  3 Nov 2012 19:48:33 +0100
Message-ID: <1351968514-12357-9-git-send-email-ordex@autistici.org>
References: <1351968514-12357-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:49794 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753092Ab2KCStd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 14:49:33 -0400
In-Reply-To: <1351968514-12357-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a runtime switch that enables the user to turn the DAT feature
on or off at runtime

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/distributed-arp-table.c | 18 ++++++++++++++++++
 net/batman-adv/soft-interface.c        |  3 +++
 net/batman-adv/sysfs.c                 |  7 +++++++
 net/batman-adv/types.h                 |  3 +++
 4 files changed, 31 insertions(+)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index f43bf8e..c1a74a1 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -621,6 +621,9 @@ out:
  */
 static void batadv_dat_hash_free(struct batadv_priv *bat_priv)
 {
+	if (!bat_priv->dat.hash)
+		return;
+
 	__batadv_dat_purge(bat_priv, NULL);
 
 	batadv_hash_destroy(bat_priv->dat.hash);
@@ -790,6 +793,9 @@ bool batadv_dat_snoop_outgoing_arp_request(struct batadv_priv *bat_priv,
 	struct sk_buff *skb_new;
 	struct batadv_hard_iface *primary_if = NULL;
 
+	if (!atomic_read(&bat_priv->distributed_arp_table))
+		goto out;
+
 	type = batadv_arp_get_type(bat_priv, skb, 0);
 	/* If the node gets an ARP_REQUEST it has to send a DHT_GET unicast
 	 * message to the selected DHT candidates
@@ -861,6 +867,9 @@ bool batadv_dat_snoop_incoming_arp_request(struct batadv_priv *bat_priv,
 	bool ret = false;
 	int err;
 
+	if (!atomic_read(&bat_priv->distributed_arp_table))
+		goto out;
+
 	type = batadv_arp_get_type(bat_priv, skb, hdr_size);
 	if (type != ARPOP_REQUEST)
 		goto out;
@@ -924,6 +933,9 @@ void batadv_dat_snoop_outgoing_arp_reply(struct batadv_priv *bat_priv,
 	__be32 ip_src, ip_dst;
 	uint8_t *hw_src, *hw_dst;
 
+	if (!atomic_read(&bat_priv->distributed_arp_table))
+		return;
+
 	type = batadv_arp_get_type(bat_priv, skb, 0);
 	if (type != ARPOP_REPLY)
 		return;
@@ -959,6 +971,9 @@ bool batadv_dat_snoop_incoming_arp_reply(struct batadv_priv *bat_priv,
 	uint8_t *hw_src, *hw_dst;
 	bool ret = false;
 
+	if (!atomic_read(&bat_priv->distributed_arp_table))
+		goto out;
+
 	type = batadv_arp_get_type(bat_priv, skb, hdr_size);
 	if (type != ARPOP_REPLY)
 		goto out;
@@ -1003,6 +1018,9 @@ bool batadv_dat_drop_broadcast_packet(struct batadv_priv *bat_priv,
 	bool ret = false;
 	const size_t bcast_len = sizeof(struct batadv_bcast_packet);
 
+	if (!atomic_read(&bat_priv->distributed_arp_table))
+		goto out;
+
 	/* If this packet is an ARP_REQUEST and the node already has the
 	 * information that it is going to ask, then the packet can be dropped
 	 */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 9dc0ae1..7b4a3a3 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -480,6 +480,9 @@ struct net_device *batadv_softif_create(const char *name)
 	atomic_set(&bat_priv->aggregated_ogms, 1);
 	atomic_set(&bat_priv->bonding, 0);
 	atomic_set(&bat_priv->bridge_loop_avoidance, 0);
+#ifdef CONFIG_BATMAN_ADV_DAT
+	atomic_set(&bat_priv->distributed_arp_table, 1);
+#endif
 	atomic_set(&bat_priv->ap_isolation, 0);
 	atomic_set(&bat_priv->vis_mode, BATADV_VIS_TYPE_CLIENT_UPDATE);
 	atomic_set(&bat_priv->gw_mode, BATADV_GW_MODE_OFF);
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 42cd09e..fa3cc1a 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -20,6 +20,7 @@
 #include "main.h"
 #include "sysfs.h"
 #include "translation-table.h"
+#include "distributed-arp-table.h"
 #include "originator.h"
 #include "hard-interface.h"
 #include "gateway_common.h"
@@ -420,6 +421,9 @@ BATADV_ATTR_SIF_BOOL(bonding, S_IRUGO | S_IWUSR, NULL);
 #ifdef CONFIG_BATMAN_ADV_BLA
 BATADV_ATTR_SIF_BOOL(bridge_loop_avoidance, S_IRUGO | S_IWUSR, NULL);
 #endif
+#ifdef CONFIG_BATMAN_ADV_DAT
+BATADV_ATTR_SIF_BOOL(distributed_arp_table, S_IRUGO | S_IWUSR, NULL);
+#endif
 BATADV_ATTR_SIF_BOOL(fragmentation, S_IRUGO | S_IWUSR, batadv_update_min_mtu);
 BATADV_ATTR_SIF_BOOL(ap_isolation, S_IRUGO | S_IWUSR, NULL);
 static BATADV_ATTR(vis_mode, S_IRUGO | S_IWUSR, batadv_show_vis_mode,
@@ -445,6 +449,9 @@ static struct batadv_attribute *batadv_mesh_attrs[] = {
 #ifdef CONFIG_BATMAN_ADV_BLA
 	&batadv_attr_bridge_loop_avoidance,
 #endif
+#ifdef CONFIG_BATMAN_ADV_DAT
+	&batadv_attr_distributed_arp_table,
+#endif
 	&batadv_attr_fragmentation,
 	&batadv_attr_ap_isolation,
 	&batadv_attr_vis_mode,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 00d3093..0afeb2b 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -275,6 +275,9 @@ struct batadv_priv {
 	atomic_t fragmentation;		/* boolean */
 	atomic_t ap_isolation;		/* boolean */
 	atomic_t bridge_loop_avoidance;	/* boolean */
+#ifdef CONFIG_BATMAN_ADV_DAT
+	atomic_t distributed_arp_table;	/* boolean */
+#endif
 	atomic_t vis_mode;		/* VIS_TYPE_* */
 	atomic_t gw_mode;		/* GW_MODE_* */
 	atomic_t gw_sel_class;		/* uint */
-- 
1.7.12.4
