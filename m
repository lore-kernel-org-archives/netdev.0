From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 08/14] batman-adv: Fix potential synchronization issues in mcast tvlv handler
Date: Tue,  4 Aug 2015 18:35:28 +0200
Message-ID: <1438706134-3492-9-git-send-email-antonio__20379.9700750553$1438707339$gmane$org@meshcoding.com>
References: <1438706134-3492-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:30771 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753602AbbHDQzJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 12:55:09 -0400
In-Reply-To: <1438706134-3492-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@c0d3.blue>

So far the mcast tvlv handler did not anticipate the processing of
multiple incoming OGMs from the same originator at the same time. This
can lead to various issues:

* Broken refcounting: For instance two mcast handlers might both assume
  that an originator just got multicast capabilities and will together
  wrongly decrease mcast.num_disabled by two, potentially leading to
  an integer underflow.

* Potential kernel panic on hlist_del_rcu(): Two mcast handlers might
  one after another try to do an
  hlist_del_rcu(&orig->mcast_want_all_*_node). The second one will
  cause memory corruption / crashes.
  (Reported by: Sven Eckelmann <sven@narfation.org>)

Right in the beginning the code path makes assumptions about the curren=
t
multicast related state of an originator and bases all updates on that.=
 The
easiest and least error prune way to fix the issues in this case is to
serialize multiple mcast handler invocations with a spinlock.

=46ixes: 60432d756cf0 ("batman-adv: Announce new capability via multica=
st TVLV")
Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/multicast.c  | 63 +++++++++++++++++++++++++++++++++++--=
--------
 net/batman-adv/originator.c |  5 ++++
 net/batman-adv/types.h      |  3 +++
 3 files changed, 58 insertions(+), 13 deletions(-)

diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index f92473d..7d2b1f8 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -20,6 +20,7 @@
=20
 #include <linux/atomic.h>
 #include <linux/bitops.h>
+#include <linux/bug.h>
 #include <linux/byteorder/generic.h>
 #include <linux/errno.h>
 #include <linux/etherdevice.h>
@@ -589,19 +590,26 @@ batadv_mcast_forw_mode(struct batadv_priv *bat_pr=
iv, struct sk_buff *skb,
  *
  * If the BATADV_MCAST_WANT_ALL_UNSNOOPABLES flag of this originator,
  * orig, has toggled then this method updates counter and list accordi=
ngly.
+ *
+ * Caller needs to hold orig->mcast_handler_lock.
  */
 static void batadv_mcast_want_unsnoop_update(struct batadv_priv *bat_p=
riv,
 					     struct batadv_orig_node *orig,
 					     uint8_t mcast_flags)
 {
+	struct hlist_node *node =3D &orig->mcast_want_all_unsnoopables_node;
+	struct hlist_head *head =3D &bat_priv->mcast.want_all_unsnoopables_li=
st;
+
 	/* switched from flag unset to set */
 	if (mcast_flags & BATADV_MCAST_WANT_ALL_UNSNOOPABLES &&
 	    !(orig->mcast_flags & BATADV_MCAST_WANT_ALL_UNSNOOPABLES)) {
 		atomic_inc(&bat_priv->mcast.num_want_all_unsnoopables);
=20
 		spin_lock_bh(&bat_priv->mcast.want_lists_lock);
-		hlist_add_head_rcu(&orig->mcast_want_all_unsnoopables_node,
-				   &bat_priv->mcast.want_all_unsnoopables_list);
+		/* flag checks above + mcast_handler_lock prevents this */
+		WARN_ON(!hlist_unhashed(node));
+
+		hlist_add_head_rcu(node, head);
 		spin_unlock_bh(&bat_priv->mcast.want_lists_lock);
 	/* switched from flag set to unset */
 	} else if (!(mcast_flags & BATADV_MCAST_WANT_ALL_UNSNOOPABLES) &&
@@ -609,7 +617,10 @@ static void batadv_mcast_want_unsnoop_update(struc=
t batadv_priv *bat_priv,
 		atomic_dec(&bat_priv->mcast.num_want_all_unsnoopables);
=20
 		spin_lock_bh(&bat_priv->mcast.want_lists_lock);
-		hlist_del_rcu(&orig->mcast_want_all_unsnoopables_node);
+		/* flag checks above + mcast_handler_lock prevents this */
+		WARN_ON(hlist_unhashed(node));
+
+		hlist_del_init_rcu(node);
 		spin_unlock_bh(&bat_priv->mcast.want_lists_lock);
 	}
 }
@@ -622,19 +633,26 @@ static void batadv_mcast_want_unsnoop_update(stru=
ct batadv_priv *bat_priv,
  *
  * If the BATADV_MCAST_WANT_ALL_IPV4 flag of this originator, orig, ha=
s
  * toggled then this method updates counter and list accordingly.
+ *
+ * Caller needs to hold orig->mcast_handler_lock.
  */
 static void batadv_mcast_want_ipv4_update(struct batadv_priv *bat_priv=
,
 					  struct batadv_orig_node *orig,
 					  uint8_t mcast_flags)
 {
+	struct hlist_node *node =3D &orig->mcast_want_all_ipv4_node;
+	struct hlist_head *head =3D &bat_priv->mcast.want_all_ipv4_list;
+
 	/* switched from flag unset to set */
 	if (mcast_flags & BATADV_MCAST_WANT_ALL_IPV4 &&
 	    !(orig->mcast_flags & BATADV_MCAST_WANT_ALL_IPV4)) {
 		atomic_inc(&bat_priv->mcast.num_want_all_ipv4);
=20
 		spin_lock_bh(&bat_priv->mcast.want_lists_lock);
-		hlist_add_head_rcu(&orig->mcast_want_all_ipv4_node,
-				   &bat_priv->mcast.want_all_ipv4_list);
+		/* flag checks above + mcast_handler_lock prevents this */
+		WARN_ON(!hlist_unhashed(node));
+
+		hlist_add_head_rcu(node, head);
 		spin_unlock_bh(&bat_priv->mcast.want_lists_lock);
 	/* switched from flag set to unset */
 	} else if (!(mcast_flags & BATADV_MCAST_WANT_ALL_IPV4) &&
@@ -642,7 +660,10 @@ static void batadv_mcast_want_ipv4_update(struct b=
atadv_priv *bat_priv,
 		atomic_dec(&bat_priv->mcast.num_want_all_ipv4);
=20
 		spin_lock_bh(&bat_priv->mcast.want_lists_lock);
-		hlist_del_rcu(&orig->mcast_want_all_ipv4_node);
+		/* flag checks above + mcast_handler_lock prevents this */
+		WARN_ON(hlist_unhashed(node));
+
+		hlist_del_init_rcu(node);
 		spin_unlock_bh(&bat_priv->mcast.want_lists_lock);
 	}
 }
@@ -655,19 +676,26 @@ static void batadv_mcast_want_ipv4_update(struct =
batadv_priv *bat_priv,
  *
  * If the BATADV_MCAST_WANT_ALL_IPV6 flag of this originator, orig, ha=
s
  * toggled then this method updates counter and list accordingly.
+ *
+ * Caller needs to hold orig->mcast_handler_lock.
  */
 static void batadv_mcast_want_ipv6_update(struct batadv_priv *bat_priv=
,
 					  struct batadv_orig_node *orig,
 					  uint8_t mcast_flags)
 {
+	struct hlist_node *node =3D &orig->mcast_want_all_ipv6_node;
+	struct hlist_head *head =3D &bat_priv->mcast.want_all_ipv6_list;
+
 	/* switched from flag unset to set */
 	if (mcast_flags & BATADV_MCAST_WANT_ALL_IPV6 &&
 	    !(orig->mcast_flags & BATADV_MCAST_WANT_ALL_IPV6)) {
 		atomic_inc(&bat_priv->mcast.num_want_all_ipv6);
=20
 		spin_lock_bh(&bat_priv->mcast.want_lists_lock);
-		hlist_add_head_rcu(&orig->mcast_want_all_ipv6_node,
-				   &bat_priv->mcast.want_all_ipv6_list);
+		/* flag checks above + mcast_handler_lock prevents this */
+		WARN_ON(!hlist_unhashed(node));
+
+		hlist_add_head_rcu(node, head);
 		spin_unlock_bh(&bat_priv->mcast.want_lists_lock);
 	/* switched from flag set to unset */
 	} else if (!(mcast_flags & BATADV_MCAST_WANT_ALL_IPV6) &&
@@ -675,7 +703,10 @@ static void batadv_mcast_want_ipv6_update(struct b=
atadv_priv *bat_priv,
 		atomic_dec(&bat_priv->mcast.num_want_all_ipv6);
=20
 		spin_lock_bh(&bat_priv->mcast.want_lists_lock);
-		hlist_del_rcu(&orig->mcast_want_all_ipv6_node);
+		/* flag checks above + mcast_handler_lock prevents this */
+		WARN_ON(hlist_unhashed(node));
+
+		hlist_del_init_rcu(node);
 		spin_unlock_bh(&bat_priv->mcast.want_lists_lock);
 	}
 }
@@ -698,6 +729,11 @@ static void batadv_mcast_tvlv_ogm_handler_v1(struc=
t batadv_priv *bat_priv,
 	uint8_t mcast_flags =3D BATADV_NO_FLAGS;
 	bool orig_initialized;
=20
+	if (orig_mcast_enabled && tvlv_value &&
+	    (tvlv_value_len >=3D sizeof(mcast_flags)))
+		mcast_flags =3D *(uint8_t *)tvlv_value;
+
+	spin_lock_bh(&orig->mcast_handler_lock);
 	orig_initialized =3D test_bit(BATADV_ORIG_CAPA_HAS_MCAST,
 				    &orig->capa_initialized);
=20
@@ -723,15 +759,12 @@ static void batadv_mcast_tvlv_ogm_handler_v1(stru=
ct batadv_priv *bat_priv,
=20
 	set_bit(BATADV_ORIG_CAPA_HAS_MCAST, &orig->capa_initialized);
=20
-	if (orig_mcast_enabled && tvlv_value &&
-	    (tvlv_value_len >=3D sizeof(mcast_flags)))
-		mcast_flags =3D *(uint8_t *)tvlv_value;
-
 	batadv_mcast_want_unsnoop_update(bat_priv, orig, mcast_flags);
 	batadv_mcast_want_ipv4_update(bat_priv, orig, mcast_flags);
 	batadv_mcast_want_ipv6_update(bat_priv, orig, mcast_flags);
=20
 	orig->mcast_flags =3D mcast_flags;
+	spin_unlock_bh(&orig->mcast_handler_lock);
 }
=20
 /**
@@ -765,6 +798,8 @@ void batadv_mcast_purge_orig(struct batadv_orig_nod=
e *orig)
 {
 	struct batadv_priv *bat_priv =3D orig->bat_priv;
=20
+	spin_lock_bh(&orig->mcast_handler_lock);
+
 	if (!(test_bit(BATADV_ORIG_CAPA_HAS_MCAST, &orig->capabilities)) &&
 	    test_bit(BATADV_ORIG_CAPA_HAS_MCAST, &orig->capa_initialized))
 		atomic_dec(&bat_priv->mcast.num_disabled);
@@ -772,4 +807,6 @@ void batadv_mcast_purge_orig(struct batadv_orig_nod=
e *orig)
 	batadv_mcast_want_unsnoop_update(bat_priv, orig, BATADV_NO_FLAGS);
 	batadv_mcast_want_ipv4_update(bat_priv, orig, BATADV_NO_FLAGS);
 	batadv_mcast_want_ipv6_update(bat_priv, orig, BATADV_NO_FLAGS);
+
+	spin_unlock_bh(&orig->mcast_handler_lock);
 }
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 018b749..32a0fcf 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -696,8 +696,13 @@ struct batadv_orig_node *batadv_orig_node_new(stru=
ct batadv_priv *bat_priv,
 	orig_node->last_seen =3D jiffies;
 	reset_time =3D jiffies - 1 - msecs_to_jiffies(BATADV_RESET_PROTECTION=
_MS);
 	orig_node->bcast_seqno_reset =3D reset_time;
+
 #ifdef CONFIG_BATMAN_ADV_MCAST
 	orig_node->mcast_flags =3D BATADV_NO_FLAGS;
+	INIT_HLIST_NODE(&orig_node->mcast_want_all_unsnoopables_node);
+	INIT_HLIST_NODE(&orig_node->mcast_want_all_ipv4_node);
+	INIT_HLIST_NODE(&orig_node->mcast_want_all_ipv6_node);
+	spin_lock_init(&orig_node->mcast_handler_lock);
 #endif
=20
 	/* create a vlan object for the "untagged" LAN */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 1eeed18..55610a8 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -221,6 +221,7 @@ struct batadv_orig_bat_iv {
  * @batadv_dat_addr_t:  address of the orig node in the distributed ha=
sh
  * @last_seen: time when last packet from this node was received
  * @bcast_seqno_reset: time when the broadcast seqno window was reset
+ * @mcast_handler_lock: synchronizes mcast-capability and -flag change=
s
  * @mcast_flags: multicast flags announced by the orig node
  * @mcast_want_all_unsnoop_node: a list node for the
  *  mcast.want_all_unsnoopables list
@@ -268,6 +269,8 @@ struct batadv_orig_node {
 	unsigned long last_seen;
 	unsigned long bcast_seqno_reset;
 #ifdef CONFIG_BATMAN_ADV_MCAST
+	/* synchronizes mcast tvlv specific orig changes */
+	spinlock_t mcast_handler_lock;
 	uint8_t mcast_flags;
 	struct hlist_node mcast_want_all_unsnoopables_node;
 	struct hlist_node mcast_want_all_ipv4_node;
--=20
2.5.0
