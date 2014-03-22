From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 10/16] batman-adv: Announce new capability via multicast TVLV
Date: Sat, 22 Mar 2014 09:56:10 +0100
Message-ID: <1395478576-10999-11-git-send-email-antonio@meshcoding.com>
References: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:23001 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbaCVJN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2014 05:13:56 -0400
In-Reply-To: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@web.de>

If the soft interface of a node is not part of a bridge then a node
announces a new multicast TVLV: The existence of this TVLV
signalizes that this node is announcing all of its multicast listeners
via the translation table infrastructure.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/main.c           |   1 +
 net/batman-adv/multicast.c      | 123 ++++++++++++++++++++++++++++++++=
++++++--
 net/batman-adv/multicast.h      |  14 +++++
 net/batman-adv/originator.c     |   6 ++
 net/batman-adv/packet.h         |  12 ++++
 net/batman-adv/soft-interface.c |   4 ++
 net/batman-adv/types.h          |  13 +++++
 7 files changed, 167 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 58e98c8..8f11b67 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -149,6 +149,7 @@ int batadv_mesh_init(struct net_device *soft_iface)
 		goto err;
=20
 	batadv_gw_init(bat_priv);
+	batadv_mcast_init(bat_priv);
=20
 	atomic_set(&bat_priv->gw.reselect, 0);
 	atomic_set(&bat_priv->mesh_state, BATADV_MESH_ACTIVE);
diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index e099fd6..3ba9a18 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -178,11 +178,52 @@ static bool batadv_mcast_has_bridge(struct batadv=
_priv *bat_priv)
 }
=20
 /**
+ * batadv_mcast_mla_tvlv_update - update multicast tvlv
+ * @bat_priv: the bat priv with all the soft interface information
+ *
+ * Updates the own multicast tvlv with our current multicast related s=
ettings,
+ * capabilities and inabilities.
+ *
+ * Returns true if the tvlv container is registered afterwards. Otherw=
ise
+ * returns false.
+ */
+static bool batadv_mcast_mla_tvlv_update(struct batadv_priv *bat_priv)
+{
+	struct batadv_tvlv_mcast_data mcast_data;
+
+	mcast_data.flags =3D BATADV_NO_FLAGS;
+	memset(mcast_data.reserved, 0, sizeof(mcast_data.reserved));
+
+	/* Avoid attaching MLAs, if there is a bridge on top of our soft
+	 * interface, we don't support that yet (TODO)
+	 */
+	if (batadv_mcast_has_bridge(bat_priv)) {
+		if (bat_priv->mcast.enabled) {
+			batadv_tvlv_container_unregister(bat_priv,
+							 BATADV_TVLV_MCAST, 1);
+			bat_priv->mcast.enabled =3D false;
+		}
+
+		return false;
+	}
+
+	if (!bat_priv->mcast.enabled ||
+	    mcast_data.flags !=3D bat_priv->mcast.flags) {
+		batadv_tvlv_container_register(bat_priv, BATADV_TVLV_MCAST, 1,
+					       &mcast_data, sizeof(mcast_data));
+		bat_priv->mcast.flags =3D mcast_data.flags;
+		bat_priv->mcast.enabled =3D true;
+	}
+
+	return true;
+}
+
+/**
  * batadv_mcast_mla_update - update the own MLAs
  * @bat_priv: the bat priv with all the soft interface information
  *
- * Update the own multicast listener announcements in the translation
- * table.
+ * Updates the own multicast listener announcements in the translation
+ * table as well as the own, announced multicast tvlv container.
  */
 void batadv_mcast_mla_update(struct batadv_priv *bat_priv)
 {
@@ -190,10 +231,7 @@ void batadv_mcast_mla_update(struct batadv_priv *b=
at_priv)
 	struct hlist_head mcast_list =3D HLIST_HEAD_INIT;
 	int ret;
=20
-	/* Avoid attaching MLAs, if there is a bridge on top of our soft
-	 * interface, we don't support that yet (TODO)
-	 */
-	if (batadv_mcast_has_bridge(bat_priv))
+	if (!batadv_mcast_mla_tvlv_update(bat_priv))
 		goto update;
=20
 	ret =3D batadv_mcast_mla_softif_get(soft_iface, &mcast_list);
@@ -209,10 +247,83 @@ out:
 }
=20
 /**
+ * batadv_mcast_tvlv_ogm_handler_v1 - process incoming multicast tvlv =
container
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig: the orig_node of the ogm
+ * @flags: flags indicating the tvlv state (see batadv_tvlv_handler_fl=
ags)
+ * @tvlv_value: tvlv buffer containing the multicast data
+ * @tvlv_value_len: tvlv buffer length
+ */
+static void batadv_mcast_tvlv_ogm_handler_v1(struct batadv_priv *bat_p=
riv,
+					     struct batadv_orig_node *orig,
+					     uint8_t flags,
+					     void *tvlv_value,
+					     uint16_t tvlv_value_len)
+{
+	bool orig_mcast_enabled =3D !(flags & BATADV_TVLV_HANDLER_OGM_CIFNOTF=
ND);
+	uint8_t mcast_flags =3D BATADV_NO_FLAGS;
+	bool orig_initialized;
+
+	orig_initialized =3D orig->capa_initialized & BATADV_ORIG_CAPA_HAS_MC=
AST;
+
+	/* If mcast support is turned on decrease the disabled mcast node
+	 * counter only if we had increased it for this node before. If this
+	 * is a completely new orig_node no need to decrease the counter.
+	 */
+	if (orig_mcast_enabled &&
+	    !(orig->capabilities & BATADV_ORIG_CAPA_HAS_MCAST)) {
+		if (orig_initialized)
+			atomic_dec(&bat_priv->mcast.num_disabled);
+		orig->capabilities |=3D BATADV_ORIG_CAPA_HAS_MCAST;
+	/* If mcast support is being switched off increase the disabled
+	 * mcast node counter.
+	 */
+	} else if (!orig_mcast_enabled &&
+		   orig->capabilities & BATADV_ORIG_CAPA_HAS_MCAST) {
+		atomic_inc(&bat_priv->mcast.num_disabled);
+		orig->capabilities &=3D ~BATADV_ORIG_CAPA_HAS_MCAST;
+	}
+
+	orig->capa_initialized |=3D BATADV_ORIG_CAPA_HAS_MCAST;
+
+	if (orig_mcast_enabled && tvlv_value &&
+	    (tvlv_value_len >=3D sizeof(mcast_flags)))
+		mcast_flags =3D *(uint8_t *)tvlv_value;
+
+	orig->mcast_flags =3D mcast_flags;
+}
+
+/**
+ * batadv_mcast_init - initialize the multicast optimizations structur=
es
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+void batadv_mcast_init(struct batadv_priv *bat_priv)
+{
+	batadv_tvlv_handler_register(bat_priv, batadv_mcast_tvlv_ogm_handler_=
v1,
+				     NULL, BATADV_TVLV_MCAST, 1,
+				     BATADV_TVLV_HANDLER_OGM_CIFNOTFND);
+}
+
+/**
  * batadv_mcast_free - free the multicast optimizations structures
  * @bat_priv: the bat priv with all the soft interface information
  */
 void batadv_mcast_free(struct batadv_priv *bat_priv)
 {
+	batadv_tvlv_container_unregister(bat_priv, BATADV_TVLV_MCAST, 1);
+	batadv_tvlv_handler_unregister(bat_priv, BATADV_TVLV_MCAST, 1);
+
 	batadv_mcast_mla_tt_retract(bat_priv, NULL);
 }
+
+/**
+ * batadv_mcast_purge_orig - reset originator global mcast state modif=
ications
+ * @orig: the originator which is going to get purged
+ */
+void batadv_mcast_purge_orig(struct batadv_orig_node *orig)
+{
+	struct batadv_priv *bat_priv =3D orig->bat_priv;
+
+	if (!(orig->capabilities & BATADV_ORIG_CAPA_HAS_MCAST))
+		atomic_dec(&bat_priv->mcast.num_disabled);
+}
diff --git a/net/batman-adv/multicast.h b/net/batman-adv/multicast.h
index 7513e02..c029eac 100644
--- a/net/batman-adv/multicast.h
+++ b/net/batman-adv/multicast.h
@@ -22,8 +22,12 @@
=20
 void batadv_mcast_mla_update(struct batadv_priv *bat_priv);
=20
+void batadv_mcast_init(struct batadv_priv *bat_priv);
+
 void batadv_mcast_free(struct batadv_priv *bat_priv);
=20
+void batadv_mcast_purge_orig(struct batadv_orig_node *orig_node);
+
 #else
=20
 static inline void batadv_mcast_mla_update(struct batadv_priv *bat_pri=
v)
@@ -31,11 +35,21 @@ static inline void batadv_mcast_mla_update(struct b=
atadv_priv *bat_priv)
 	return;
 }
=20
+static inline int batadv_mcast_init(struct batadv_priv *bat_priv)
+{
+	return 0;
+}
+
 static inline void batadv_mcast_free(struct batadv_priv *bat_priv)
 {
 	return;
 }
=20
+static inline void batadv_mcast_purge_orig(struct batadv_orig_node *or=
ig_node)
+{
+	return;
+}
+
 #endif /* CONFIG_BATMAN_ADV_MCAST */
=20
 #endif /* _NET_BATMAN_ADV_MULTICAST_H_ */
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 24a9300..ffd9dfb 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -27,6 +27,7 @@
 #include "bridge_loop_avoidance.h"
 #include "network-coding.h"
 #include "fragmentation.h"
+#include "multicast.h"
=20
 /* hash class keys */
 static struct lock_class_key batadv_orig_hash_lock_class_key;
@@ -557,6 +558,8 @@ static void batadv_orig_node_free_rcu(struct rcu_he=
ad *rcu)
 	}
 	spin_unlock_bh(&orig_node->neigh_list_lock);
=20
+	batadv_mcast_purge_orig(orig_node);
+
 	/* Free nc_nodes */
 	batadv_nc_purge_orig(orig_node->bat_priv, orig_node, NULL);
=20
@@ -672,6 +675,9 @@ struct batadv_orig_node *batadv_orig_node_new(struc=
t batadv_priv *bat_priv,
 	orig_node->tt_buff_len =3D 0;
 	reset_time =3D jiffies - 1 - msecs_to_jiffies(BATADV_RESET_PROTECTION=
_MS);
 	orig_node->bcast_seqno_reset =3D reset_time;
+#ifdef CONFIG_BATMAN_ADV_MCAST
+	orig_node->mcast_flags =3D BATADV_NO_FLAGS;
+#endif
=20
 	/* create a vlan object for the "untagged" LAN */
 	vlan =3D batadv_orig_node_vlan_new(orig_node, BATADV_NO_FLAGS);
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 0a381d1..e8c483d 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -145,6 +145,7 @@ enum batadv_bla_claimframe {
  * @BATADV_TVLV_NC: network coding tvlv
  * @BATADV_TVLV_TT: translation table tvlv
  * @BATADV_TVLV_ROAM: roaming advertisement tvlv
+ * @BATADV_TVLV_MCAST: multicast capability tvlv
  */
 enum batadv_tvlv_type {
 	BATADV_TVLV_GW		=3D 0x01,
@@ -152,6 +153,7 @@ enum batadv_tvlv_type {
 	BATADV_TVLV_NC		=3D 0x03,
 	BATADV_TVLV_TT		=3D 0x04,
 	BATADV_TVLV_ROAM	=3D 0x05,
+	BATADV_TVLV_MCAST	=3D 0x06,
 };
=20
 #pragma pack(2)
@@ -504,4 +506,14 @@ struct batadv_tvlv_roam_adv {
 	__be16 vid;
 };
=20
+/**
+ * struct batadv_tvlv_mcast_data - payload of a multicast tvlv
+ * @flags: multicast flags announced by the orig node
+ * @reserved: reserved field
+ */
+struct batadv_tvlv_mcast_data {
+	uint8_t	flags;
+	uint8_t reserved[3];
+};
+
 #endif /* _NET_BATMAN_ADV_PACKET_H_ */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 633e9d6..8ff47b7 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -689,6 +689,10 @@ static int batadv_softif_init_late(struct net_devi=
ce *dev)
 #ifdef CONFIG_BATMAN_ADV_DAT
 	atomic_set(&bat_priv->distributed_arp_table, 1);
 #endif
+#ifdef CONFIG_BATMAN_ADV_MCAST
+	bat_priv->mcast.flags =3D BATADV_NO_FLAGS;
+	atomic_set(&bat_priv->mcast.num_disabled, 0);
+#endif
 	atomic_set(&bat_priv->gw_mode, BATADV_GW_MODE_OFF);
 	atomic_set(&bat_priv->gw_sel_class, 20);
 	atomic_set(&bat_priv->gw.bandwidth_down, 100);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index b46117c..96ee0d2 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -204,6 +204,7 @@ struct batadv_orig_bat_iv {
  * @batadv_dat_addr_t:  address of the orig node in the distributed ha=
sh
  * @last_seen: time when last packet from this node was received
  * @bcast_seqno_reset: time when the broadcast seqno window was reset
+ * @mcast_flags: multicast flags announced by the orig node
  * @capabilities: announced capabilities of this originator
  * @capa_initialized: bitfield to remember whether a capability was in=
itialized
  * @last_ttvn: last seen translation table version number
@@ -246,6 +247,9 @@ struct batadv_orig_node {
 #endif
 	unsigned long last_seen;
 	unsigned long bcast_seqno_reset;
+#ifdef CONFIG_BATMAN_ADV_MCAST
+	uint8_t mcast_flags;
+#endif
 	uint8_t capabilities;
 	uint8_t capa_initialized;
 	atomic_t last_ttvn;
@@ -282,11 +286,14 @@ struct batadv_orig_node {
  * @BATADV_ORIG_CAPA_HAS_DAT: orig node has distributed arp table enab=
led
  * @BATADV_ORIG_CAPA_HAS_NC: orig node has network coding enabled
  * @BATADV_ORIG_CAPA_HAS_TT: orig node has tt capability
+ * @BATADV_ORIG_CAPA_HAS_MCAST: orig node has some multicast capabilit=
y
+ *  (=3D orig node announces a tvlv of type BATADV_TVLV_MCAST)
  */
 enum batadv_orig_capabilities {
 	BATADV_ORIG_CAPA_HAS_DAT =3D BIT(0),
 	BATADV_ORIG_CAPA_HAS_NC =3D BIT(1),
 	BATADV_ORIG_CAPA_HAS_TT =3D BIT(2),
+	BATADV_ORIG_CAPA_HAS_MCAST =3D BIT(3),
 };
=20
 /**
@@ -612,9 +619,15 @@ struct batadv_priv_dat {
 /**
  * struct batadv_priv_mcast - per mesh interface mcast data
  * @mla_list: list of multicast addresses we are currently announcing =
via TT
+ * @flags: the flags we have last sent in our mcast tvlv
+ * @enabled: whether the multicast tvlv is currently enabled
+ * @num_disabled: number of nodes that have no mcast tvlv
  */
 struct batadv_priv_mcast {
 	struct hlist_head mla_list;
+	uint8_t flags;
+	bool enabled;
+	atomic_t num_disabled;
 };
 #endif
=20
--=20
1.8.3.2
