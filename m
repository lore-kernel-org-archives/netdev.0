From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 05/16] batman-adv: tvlv - add distributed arp table container
Date: Wed,  9 Oct 2013 21:32:43 +0200
Message-ID: <1381347174-3629-6-git-send-email-antonio@meshcoding.com>
References: <1381347174-3629-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:27610 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471Ab3JITdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 15:33:36 -0400
In-Reply-To: <1381347174-3629-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Create DAT container to announce DAT capabilities (if enabled).

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/distributed-arp-table.c | 64 ++++++++++++++++++++++++++++++++++
 net/batman-adv/distributed-arp-table.h |  5 +++
 net/batman-adv/packet.h                |  2 ++
 net/batman-adv/sysfs.c                 |  3 +-
 net/batman-adv/types.h                 | 10 ++++++
 5 files changed, 83 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 06345d4..f07ec32 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -419,6 +419,10 @@ static bool batadv_is_orig_node_eligible(struct batadv_dat_candidate *res,
 	bool ret = false;
 	int j;
 
+	/* check if orig node candidate is running DAT */
+	if (!(candidate->capabilities & BATADV_ORIG_CAPA_HAS_DAT))
+		goto out;
+
 	/* Check if this node has already been selected... */
 	for (j = 0; j < select; j++)
 		if (res[j].orig_node == candidate)
@@ -626,6 +630,59 @@ out:
 }
 
 /**
+ * batadv_dat_tvlv_container_update - update the dat tvlv container after dat
+ *  setting change
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+static void batadv_dat_tvlv_container_update(struct batadv_priv *bat_priv)
+{
+	char dat_mode;
+
+	dat_mode = atomic_read(&bat_priv->distributed_arp_table);
+
+	switch (dat_mode) {
+	case 0:
+		batadv_tvlv_container_unregister(bat_priv, BATADV_TVLV_DAT, 1);
+		break;
+	case 1:
+		batadv_tvlv_container_register(bat_priv, BATADV_TVLV_DAT, 1,
+					       NULL, 0);
+		break;
+	}
+}
+
+/**
+ * batadv_dat_status_update - update the dat tvlv container after dat
+ *  setting change
+ * @net_dev: the soft interface net device
+ */
+void batadv_dat_status_update(struct net_device *net_dev)
+{
+	struct batadv_priv *bat_priv = netdev_priv(net_dev);
+	batadv_dat_tvlv_container_update(bat_priv);
+}
+
+/**
+ * batadv_gw_tvlv_ogm_handler_v1 - process incoming dat tvlv container
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig: the orig_node of the ogm
+ * @flags: flags indicating the tvlv state (see batadv_tvlv_handler_flags)
+ * @tvlv_value: tvlv buffer containing the gateway data
+ * @tvlv_value_len: tvlv buffer length
+ */
+static void batadv_dat_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
+					   struct batadv_orig_node *orig,
+					   uint8_t flags,
+					   void *tvlv_value,
+					   uint16_t tvlv_value_len)
+{
+	if (flags & BATADV_TVLV_HANDLER_OGM_CIFNOTFND)
+		orig->capabilities &= ~BATADV_ORIG_CAPA_HAS_DAT;
+	else
+		orig->capabilities |= BATADV_ORIG_CAPA_HAS_DAT;
+}
+
+/**
  * batadv_dat_hash_free - free the local DAT hash table
  * @bat_priv: the bat priv with all the soft interface information
  */
@@ -657,6 +714,10 @@ int batadv_dat_init(struct batadv_priv *bat_priv)
 
 	batadv_dat_start_timer(bat_priv);
 
+	batadv_tvlv_handler_register(bat_priv, batadv_dat_tvlv_ogm_handler_v1,
+				     NULL, BATADV_TVLV_DAT, 1,
+				     BATADV_TVLV_HANDLER_OGM_CIFNOTFND);
+	batadv_dat_tvlv_container_update(bat_priv);
 	return 0;
 }
 
@@ -666,6 +727,9 @@ int batadv_dat_init(struct batadv_priv *bat_priv)
  */
 void batadv_dat_free(struct batadv_priv *bat_priv)
 {
+	batadv_tvlv_container_unregister(bat_priv, BATADV_TVLV_DAT, 1);
+	batadv_tvlv_handler_unregister(bat_priv, BATADV_TVLV_DAT, 1);
+
 	cancel_delayed_work_sync(&bat_priv->dat.work);
 
 	batadv_dat_hash_free(bat_priv);
diff --git a/net/batman-adv/distributed-arp-table.h b/net/batman-adv/distributed-arp-table.h
index 125c8c6..60d853b 100644
--- a/net/batman-adv/distributed-arp-table.h
+++ b/net/batman-adv/distributed-arp-table.h
@@ -29,6 +29,7 @@
 
 #define BATADV_DAT_ADDR_MAX ((batadv_dat_addr_t)~(batadv_dat_addr_t)0)
 
+void batadv_dat_status_update(struct net_device *net_dev);
 bool batadv_dat_snoop_outgoing_arp_request(struct batadv_priv *bat_priv,
 					   struct sk_buff *skb);
 bool batadv_dat_snoop_incoming_arp_request(struct batadv_priv *bat_priv,
@@ -98,6 +99,10 @@ static inline void batadv_dat_inc_counter(struct batadv_priv *bat_priv,
 
 #else
 
+static inline void batadv_dat_status_update(struct net_device *net_dev)
+{
+}
+
 static inline bool
 batadv_dat_snoop_outgoing_arp_request(struct batadv_priv *bat_priv,
 				      struct sk_buff *skb)
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 6d0b3a7..8d470b2 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -121,9 +121,11 @@ enum batadv_bla_claimframe {
 /**
  * enum batadv_tvlv_type - tvlv type definitions
  * @BATADV_TVLV_GW: gateway tvlv
+ * @BATADV_TVLV_DAT: distributed arp table tvlv
  */
 enum batadv_tvlv_type {
 	BATADV_TVLV_GW		= 0x01,
+	BATADV_TVLV_DAT		= 0x02,
 };
 
 /* the destination hardware field in the ARP frame is used to
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 68793f5..e1a826e 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -425,7 +425,8 @@ BATADV_ATTR_SIF_BOOL(bonding, S_IRUGO | S_IWUSR, NULL);
 BATADV_ATTR_SIF_BOOL(bridge_loop_avoidance, S_IRUGO | S_IWUSR, NULL);
 #endif
 #ifdef CONFIG_BATMAN_ADV_DAT
-BATADV_ATTR_SIF_BOOL(distributed_arp_table, S_IRUGO | S_IWUSR, NULL);
+BATADV_ATTR_SIF_BOOL(distributed_arp_table, S_IRUGO | S_IWUSR,
+		     batadv_dat_status_update);
 #endif
 BATADV_ATTR_SIF_BOOL(fragmentation, S_IRUGO | S_IWUSR, batadv_update_min_mtu);
 BATADV_ATTR_SIF_BOOL(ap_isolation, S_IRUGO | S_IWUSR, NULL);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index b22a043..35ce834 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -100,6 +100,7 @@ struct batadv_hard_iface {
  * @bcast_seqno_reset: time when the broadcast seqno window was reset
  * @batman_seqno_reset: time when the batman seqno window was reset
  * @flags: for now only VIS_SERVER flag
+ * @capabilities: announced capabilities of this originator
  * @last_ttvn: last seen translation table version number
  * @tt_crc: CRC of the translation table
  * @tt_buff: last tt changeset this node received from the orig node
@@ -147,6 +148,7 @@ struct batadv_orig_node {
 	unsigned long bcast_seqno_reset;
 	unsigned long batman_seqno_reset;
 	uint8_t flags;
+	uint8_t capabilities;
 	atomic_t last_ttvn;
 	uint16_t tt_crc;
 	unsigned char *tt_buff;
@@ -184,6 +186,14 @@ struct batadv_orig_node {
 };
 
 /**
+ * enum batadv_orig_capabilities - orig node capabilities
+ * @BATADV_ORIG_CAPA_HAS_DAT: orig node has distributed arp table enabled
+ */
+enum batadv_orig_capabilities {
+	BATADV_ORIG_CAPA_HAS_DAT = BIT(0),
+};
+
+/**
  * struct batadv_gw_node - structure for orig nodes announcing gw capabilities
  * @list: list node for batadv_priv_gw::list
  * @orig_node: pointer to corresponding orig node
-- 
1.8.3.2
