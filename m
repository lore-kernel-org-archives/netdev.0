From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 2/2] batman-adv: Initialize gw sel_class via batadv_algo
Date: Thu, 16 Mar 2017 13:55:12 +0100
Message-ID: <20170316125512.30364-3-sw@simonwunderlich.de>
References: <20170316125512.30364-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:51832 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751924AbdCPMzR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 08:55:17 -0400
In-Reply-To: <20170316125512.30364-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The gateway selection class variable is shared between different algorithm
versions. But the interpretation of the content is algorithm specific. The
initialization is therefore also algorithm specific.

But this was implemented incorrectly and the initialization for BATMAN_V
always overwrote the value previously written for BATMAN_IV. This could
only be avoided when BATMAN_V was disabled during compile time.

Using a special batadv_algo hook for this initialization avoids this
problem.

Fixes: 50164d8f500f ("batman-adv: B.A.T.M.A.N. V - implement GW selection logic")
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bat_iv_ogm.c     | 11 +++++++++++
 net/batman-adv/bat_v.c          | 14 +++++++++++---
 net/batman-adv/gateway_common.c |  5 +++++
 net/batman-adv/soft-interface.c |  1 -
 net/batman-adv/types.h          |  2 ++
 5 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index f00f666e2ccd..7bfd0d7ef49d 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -2477,6 +2477,16 @@ static void batadv_iv_iface_activate(struct batadv_hard_iface *hard_iface)
 	batadv_iv_ogm_schedule(hard_iface);
 }
 
+/**
+ * batadv_iv_init_sel_class - initialize GW selection class
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+static void batadv_iv_init_sel_class(struct batadv_priv *bat_priv)
+{
+	/* set default TQ difference threshold to 20 */
+	atomic_set(&bat_priv->gw.sel_class, 20);
+}
+
 static struct batadv_gw_node *
 batadv_iv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 {
@@ -2823,6 +2833,7 @@ static struct batadv_algo_ops batadv_batman_iv __read_mostly = {
 		.del_if = batadv_iv_ogm_orig_del_if,
 	},
 	.gw = {
+		.init_sel_class = batadv_iv_init_sel_class,
 		.get_best_gw_node = batadv_iv_gw_get_best_gw_node,
 		.is_eligible = batadv_iv_gw_is_eligible,
 #ifdef CONFIG_BATMAN_ADV_DEBUGFS
diff --git a/net/batman-adv/bat_v.c b/net/batman-adv/bat_v.c
index 2ac612d7bab4..2e2471ca84e3 100644
--- a/net/batman-adv/bat_v.c
+++ b/net/batman-adv/bat_v.c
@@ -668,6 +668,16 @@ static bool batadv_v_neigh_is_sob(struct batadv_neigh_node *neigh1,
 	return ret;
 }
 
+/**
+ * batadv_v_init_sel_class - initialize GW selection class
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+static void batadv_v_init_sel_class(struct batadv_priv *bat_priv)
+{
+	/* set default throughput difference threshold to 5Mbps */
+	atomic_set(&bat_priv->gw.sel_class, 50);
+}
+
 static ssize_t batadv_v_store_sel_class(struct batadv_priv *bat_priv,
 					char *buff, size_t count)
 {
@@ -1052,6 +1062,7 @@ static struct batadv_algo_ops batadv_batman_v __read_mostly = {
 		.dump = batadv_v_orig_dump,
 	},
 	.gw = {
+		.init_sel_class = batadv_v_init_sel_class,
 		.store_sel_class = batadv_v_store_sel_class,
 		.show_sel_class = batadv_v_show_sel_class,
 		.get_best_gw_node = batadv_v_gw_get_best_gw_node,
@@ -1092,9 +1103,6 @@ int batadv_v_mesh_init(struct batadv_priv *bat_priv)
 	if (ret < 0)
 		return ret;
 
-	/* set default throughput difference threshold to 5Mbps */
-	atomic_set(&bat_priv->gw.sel_class, 50);
-
 	return 0;
 }
 
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index 21184810d89f..3e3f91ab694f 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -253,6 +253,11 @@ static void batadv_gw_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
  */
 void batadv_gw_init(struct batadv_priv *bat_priv)
 {
+	if (bat_priv->algo_ops->gw.init_sel_class)
+		bat_priv->algo_ops->gw.init_sel_class(bat_priv);
+	else
+		atomic_set(&bat_priv->gw.sel_class, 1);
+
 	batadv_tvlv_handler_register(bat_priv, batadv_gw_tvlv_ogm_handler_v1,
 				     NULL, BATADV_TVLV_GW, 1,
 				     BATADV_TVLV_HANDLER_OGM_CIFNOTFND);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 7b3494ae6ad9..2e0b3463ab4a 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -820,7 +820,6 @@ static int batadv_softif_init_late(struct net_device *dev)
 	atomic_set(&bat_priv->mcast.num_want_all_ipv6, 0);
 #endif
 	atomic_set(&bat_priv->gw.mode, BATADV_GW_MODE_OFF);
-	atomic_set(&bat_priv->gw.sel_class, 20);
 	atomic_set(&bat_priv->gw.bandwidth_down, 100);
 	atomic_set(&bat_priv->gw.bandwidth_up, 20);
 	atomic_set(&bat_priv->orig_interval, 1000);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index e913aee28c98..5137d859694c 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1489,6 +1489,7 @@ struct batadv_algo_orig_ops {
 
 /**
  * struct batadv_algo_gw_ops - mesh algorithm callbacks (GW specific)
+ * @init_sel_class: initialize GW selection class (optional)
  * @store_sel_class: parse and stores a new GW selection class (optional)
  * @show_sel_class: prints the current GW selection class (optional)
  * @get_best_gw_node: select the best GW from the list of available nodes
@@ -1499,6 +1500,7 @@ struct batadv_algo_orig_ops {
  * @dump: dump gateways to a netlink socket (optional)
  */
 struct batadv_algo_gw_ops {
+	void (*init_sel_class)(struct batadv_priv *bat_priv);
 	ssize_t (*store_sel_class)(struct batadv_priv *bat_priv, char *buff,
 				   size_t count);
 	ssize_t (*show_sel_class)(struct batadv_priv *bat_priv, char *buff);
-- 
2.11.0
