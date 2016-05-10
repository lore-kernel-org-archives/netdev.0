From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 13/17] batman-adv: Use kref_get for hard_iface subfunctions
Date: Wed, 11 May 2016 03:30:01 +0800
Message-ID: <1462908605-27412-14-git-send-email-a@unstable.cc>
References: <1462908605-27412-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:22005 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752442AbcEJTjJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 15:39:09 -0400
In-Reply-To: <1462908605-27412-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The callers of the functions using batadv_hard_iface objects already make
sure that they hold a valid reference. The subfunctions don't have
to check whether the reference counter is > 0 because this was checked by
the callers.

The kref_get function instead WARNs (with debug information) when the
reference counter would still be 0. This makes a bug in batman-adv better
visible because kref_get_unless_zero would have ignored this problem.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bat_iv_ogm.c     | 14 +++-----------
 net/batman-adv/hard-interface.c |  7 +++----
 net/batman-adv/originator.c     | 30 +++++++-----------------------
 3 files changed, 13 insertions(+), 38 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 57e9962c7090..eb3435de54b5 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -681,18 +681,12 @@ static void batadv_iv_ogm_aggregate_new(const unsigned char *packet_buff,
 	unsigned char *skb_buff;
 	unsigned int skb_size;
 
-	if (!kref_get_unless_zero(&if_incoming->refcount))
-		return;
-
-	if (!kref_get_unless_zero(&if_outgoing->refcount))
-		goto out_free_incoming;
-
 	/* own packet should always be scheduled */
 	if (!own_packet) {
 		if (!batadv_atomic_dec_not_zero(&bat_priv->batman_queue_left)) {
 			batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 				   "batman packet queue full\n");
-			goto out_free_outgoing;
+			return;
 		}
 	}
 
@@ -718,6 +712,8 @@ static void batadv_iv_ogm_aggregate_new(const unsigned char *packet_buff,
 	forw_packet_aggr->packet_len = packet_len;
 	memcpy(skb_buff, packet_buff, packet_len);
 
+	kref_get(&if_incoming->refcount);
+	kref_get(&if_outgoing->refcount);
 	forw_packet_aggr->own = own_packet;
 	forw_packet_aggr->if_incoming = if_incoming;
 	forw_packet_aggr->if_outgoing = if_outgoing;
@@ -747,10 +743,6 @@ out_free_forw_packet:
 out_nomem:
 	if (!own_packet)
 		atomic_inc(&bat_priv->batman_queue_left);
-out_free_outgoing:
-	batadv_hardif_put(if_outgoing);
-out_free_incoming:
-	batadv_hardif_put(if_incoming);
 }
 
 /* aggregate a new packet into the existing ogm packet */
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index d3d37f3f99cf..7c1d8d7ac548 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -236,8 +236,8 @@ static void batadv_primary_if_select(struct batadv_priv *bat_priv,
 
 	ASSERT_RTNL();
 
-	if (new_hard_iface && !kref_get_unless_zero(&new_hard_iface->refcount))
-		new_hard_iface = NULL;
+	if (new_hard_iface)
+		kref_get(&new_hard_iface->refcount);
 
 	curr_hard_iface = rcu_dereference_protected(bat_priv->primary_if, 1);
 	rcu_assign_pointer(bat_priv->primary_if, new_hard_iface);
@@ -467,8 +467,7 @@ int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
 	if (hard_iface->if_status != BATADV_IF_NOT_IN_USE)
 		goto out;
 
-	if (!kref_get_unless_zero(&hard_iface->refcount))
-		goto out;
+	kref_get(&hard_iface->refcount);
 
 	soft_iface = dev_get_by_name(net, iface_name);
 
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 2ed2cc89a669..04fa139911c3 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -374,12 +374,8 @@ batadv_orig_ifinfo_new(struct batadv_orig_node *orig_node,
 	if (!orig_ifinfo)
 		goto out;
 
-	if (if_outgoing != BATADV_IF_DEFAULT &&
-	    !kref_get_unless_zero(&if_outgoing->refcount)) {
-		kfree(orig_ifinfo);
-		orig_ifinfo = NULL;
-		goto out;
-	}
+	if (if_outgoing != BATADV_IF_DEFAULT)
+		kref_get(&if_outgoing->refcount);
 
 	reset_time = jiffies - 1;
 	reset_time -= msecs_to_jiffies(BATADV_RESET_PROTECTION_MS);
@@ -455,11 +451,8 @@ batadv_neigh_ifinfo_new(struct batadv_neigh_node *neigh,
 	if (!neigh_ifinfo)
 		goto out;
 
-	if (if_outgoing && !kref_get_unless_zero(&if_outgoing->refcount)) {
-		kfree(neigh_ifinfo);
-		neigh_ifinfo = NULL;
-		goto out;
-	}
+	if (if_outgoing)
+		kref_get(&if_outgoing->refcount);
 
 	INIT_HLIST_NODE(&neigh_ifinfo->list);
 	kref_init(&neigh_ifinfo->refcount);
@@ -532,15 +525,11 @@ batadv_hardif_neigh_create(struct batadv_hard_iface *hard_iface,
 	if (hardif_neigh)
 		goto out;
 
-	if (!kref_get_unless_zero(&hard_iface->refcount))
-		goto out;
-
 	hardif_neigh = kzalloc(sizeof(*hardif_neigh), GFP_ATOMIC);
-	if (!hardif_neigh) {
-		batadv_hardif_put(hard_iface);
+	if (!hardif_neigh)
 		goto out;
-	}
 
+	kref_get(&hard_iface->refcount);
 	INIT_HLIST_NODE(&hardif_neigh->list);
 	ether_addr_copy(hardif_neigh->addr, neigh_addr);
 	hardif_neigh->if_incoming = hard_iface;
@@ -643,16 +632,11 @@ batadv_neigh_node_new(struct batadv_orig_node *orig_node,
 	if (!neigh_node)
 		goto out;
 
-	if (!kref_get_unless_zero(&hard_iface->refcount)) {
-		kfree(neigh_node);
-		neigh_node = NULL;
-		goto out;
-	}
-
 	INIT_HLIST_NODE(&neigh_node->list);
 	INIT_HLIST_HEAD(&neigh_node->ifinfo_list);
 	spin_lock_init(&neigh_node->ifinfo_lock);
 
+	kref_get(&hard_iface->refcount);
 	ether_addr_copy(neigh_node->addr, neigh_addr);
 	neigh_node->if_incoming = hard_iface;
 	neigh_node->orig_node = orig_node;
-- 
2.8.2
