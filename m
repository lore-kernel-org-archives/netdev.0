From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 06/16] batman-adv: tvlv - add network coding container
Date: Wed,  9 Oct 2013 21:32:44 +0200
Message-ID: <1381347174-3629-7-git-send-email-antonio@meshcoding.com>
References: <1381347174-3629-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:37582 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755204Ab3JITdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 15:33:47 -0400
In-Reply-To: <1381347174-3629-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Create network coding container to announce network coding
capabilities (if enabled).

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/network-coding.c | 63 +++++++++++++++++++++++++++++++++++++++++
 net/batman-adv/network-coding.h |  5 ++++
 net/batman-adv/packet.h         |  2 ++
 net/batman-adv/sysfs.c          |  4 ++-
 net/batman-adv/types.h          |  2 ++
 5 files changed, 75 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 4ecc0b6..23f611b 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -59,6 +59,59 @@ static void batadv_nc_start_timer(struct batadv_priv *bat_priv)
 }
 
 /**
+ * batadv_nc_tvlv_container_update - update the network coding tvlv container
+ *  after network coding setting change
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+static void batadv_nc_tvlv_container_update(struct batadv_priv *bat_priv)
+{
+	char nc_mode;
+
+	nc_mode = atomic_read(&bat_priv->network_coding);
+
+	switch (nc_mode) {
+	case 0:
+		batadv_tvlv_container_unregister(bat_priv, BATADV_TVLV_NC, 1);
+		break;
+	case 1:
+		batadv_tvlv_container_register(bat_priv, BATADV_TVLV_NC, 1,
+					       NULL, 0);
+		break;
+	}
+}
+
+/**
+ * batadv_nc_status_update - update the network coding tvlv container after
+ *  network coding setting change
+ * @net_dev: the soft interface net device
+ */
+void batadv_nc_status_update(struct net_device *net_dev)
+{
+	struct batadv_priv *bat_priv = netdev_priv(net_dev);
+	batadv_nc_tvlv_container_update(bat_priv);
+}
+
+/**
+ * batadv_nc_tvlv_ogm_handler_v1 - process incoming nc tvlv container
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig: the orig_node of the ogm
+ * @flags: flags indicating the tvlv state (see batadv_tvlv_handler_flags)
+ * @tvlv_value: tvlv buffer containing the gateway data
+ * @tvlv_value_len: tvlv buffer length
+ */
+static void batadv_nc_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
+					  struct batadv_orig_node *orig,
+					  uint8_t flags,
+					  void *tvlv_value,
+					  uint16_t tvlv_value_len)
+{
+	if (flags & BATADV_TVLV_HANDLER_OGM_CIFNOTFND)
+		orig->capabilities &= ~BATADV_ORIG_CAPA_HAS_NC;
+	else
+		orig->capabilities |= BATADV_ORIG_CAPA_HAS_NC;
+}
+
+/**
  * batadv_nc_mesh_init - initialise coding hash table and start house keeping
  * @bat_priv: the bat priv with all the soft interface information
  */
@@ -87,6 +140,10 @@ int batadv_nc_mesh_init(struct batadv_priv *bat_priv)
 	INIT_DELAYED_WORK(&bat_priv->nc.work, batadv_nc_worker);
 	batadv_nc_start_timer(bat_priv);
 
+	batadv_tvlv_handler_register(bat_priv, batadv_nc_tvlv_ogm_handler_v1,
+				     NULL, BATADV_TVLV_NC, 1,
+				     BATADV_TVLV_HANDLER_OGM_CIFNOTFND);
+	batadv_nc_tvlv_container_update(bat_priv);
 	return 0;
 
 err:
@@ -802,6 +859,10 @@ void batadv_nc_update_nc_node(struct batadv_priv *bat_priv,
 	if (!atomic_read(&bat_priv->network_coding))
 		goto out;
 
+	/* check if orig node is network coding enabled */
+	if (!(orig_node->capabilities & BATADV_ORIG_CAPA_HAS_NC))
+		goto out;
+
 	/* accept ogms from 'good' neighbors and single hop neighbors */
 	if (!batadv_can_nc_with_orig(bat_priv, orig_node, ogm_packet) &&
 	    !is_single_hop_neigh)
@@ -1735,6 +1796,8 @@ free_nc_packet:
  */
 void batadv_nc_mesh_free(struct batadv_priv *bat_priv)
 {
+	batadv_tvlv_container_unregister(bat_priv, BATADV_TVLV_NC, 1);
+	batadv_tvlv_handler_unregister(bat_priv, BATADV_TVLV_NC, 1);
 	cancel_delayed_work_sync(&bat_priv->nc.work);
 
 	batadv_nc_purge_paths(bat_priv, bat_priv->nc.coding_hash, NULL);
diff --git a/net/batman-adv/network-coding.h b/net/batman-adv/network-coding.h
index ddfa618..d4fd315 100644
--- a/net/batman-adv/network-coding.h
+++ b/net/batman-adv/network-coding.h
@@ -22,6 +22,7 @@
 
 #ifdef CONFIG_BATMAN_ADV_NC
 
+void batadv_nc_status_update(struct net_device *net_dev);
 int batadv_nc_init(void);
 int batadv_nc_mesh_init(struct batadv_priv *bat_priv);
 void batadv_nc_mesh_free(struct batadv_priv *bat_priv);
@@ -47,6 +48,10 @@ int batadv_nc_init_debugfs(struct batadv_priv *bat_priv);
 
 #else /* ifdef CONFIG_BATMAN_ADV_NC */
 
+static inline void batadv_nc_status_update(struct net_device *net_dev)
+{
+}
+
 static inline int batadv_nc_init(void)
 {
 	return 0;
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 8d470b2..55deb4d 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -122,10 +122,12 @@ enum batadv_bla_claimframe {
  * enum batadv_tvlv_type - tvlv type definitions
  * @BATADV_TVLV_GW: gateway tvlv
  * @BATADV_TVLV_DAT: distributed arp table tvlv
+ * @BATADV_TVLV_NC: network coding tvlv
  */
 enum batadv_tvlv_type {
 	BATADV_TVLV_GW		= 0x01,
 	BATADV_TVLV_DAT		= 0x02,
+	BATADV_TVLV_NC		= 0x03,
 };
 
 /* the destination hardware field in the ARP frame is used to
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index e1a826e..fbc1c25 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -21,6 +21,7 @@
 #include "sysfs.h"
 #include "translation-table.h"
 #include "distributed-arp-table.h"
+#include "network-coding.h"
 #include "originator.h"
 #include "hard-interface.h"
 #include "gateway_common.h"
@@ -447,7 +448,8 @@ static BATADV_ATTR(gw_bandwidth, S_IRUGO | S_IWUSR, batadv_show_gw_bwidth,
 BATADV_ATTR_SIF_UINT(log_level, S_IRUGO | S_IWUSR, 0, BATADV_DBG_ALL, NULL);
 #endif
 #ifdef CONFIG_BATMAN_ADV_NC
-BATADV_ATTR_SIF_BOOL(network_coding, S_IRUGO | S_IWUSR, NULL);
+BATADV_ATTR_SIF_BOOL(network_coding, S_IRUGO | S_IWUSR,
+		     batadv_nc_status_update);
 #endif
 
 static struct batadv_attribute *batadv_mesh_attrs[] = {
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 35ce834..fa5cb0d 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -188,9 +188,11 @@ struct batadv_orig_node {
 /**
  * enum batadv_orig_capabilities - orig node capabilities
  * @BATADV_ORIG_CAPA_HAS_DAT: orig node has distributed arp table enabled
+ * @BATADV_ORIG_CAPA_HAS_NC: orig node has network coding enabled
  */
 enum batadv_orig_capabilities {
 	BATADV_ORIG_CAPA_HAS_DAT = BIT(0),
+	BATADV_ORIG_CAPA_HAS_NC = BIT(1),
 };
 
 /**
-- 
1.8.3.2
