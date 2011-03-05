From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 17/28] batman-adv: Make bat_priv->curr_gw an rcu protected pointer
Date: Sat,  5 Mar 2011 13:28:31 +0100
Message-ID: <1299328122-21468-18-git-send-email-sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@ascom.ch>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:36317 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753290Ab1CEMaA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 07:30:00 -0500
In-Reply-To: <1299328122-21468-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@ascom.ch>

The rcu protected macros rcu_dereference() and rcu_assign_pointer()
for the bat_priv->curr_gw need to be used, as well as spin/rcu locking.

Otherwise we might end up using a curr_gw pointer pointing to already
freed memory.

Reported-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Linus L=C3=BCssing <linus.luessing@ascom.ch>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/gateway_client.c |  100 +++++++++++++++++++++++++++----=
--------
 net/batman-adv/types.h          |    4 +-
 2 files changed, 72 insertions(+), 32 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_c=
lient.c
index 517e001..a3e842f 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -44,19 +44,29 @@ static void gw_node_free_ref(struct gw_node *gw_nod=
e)
=20
 void *gw_get_selected(struct bat_priv *bat_priv)
 {
-	struct gw_node *curr_gateway_tmp =3D bat_priv->curr_gw;
+	struct gw_node *curr_gateway_tmp;
+	struct orig_node *orig_node =3D NULL;
=20
+	rcu_read_lock();
+	curr_gateway_tmp =3D rcu_dereference(bat_priv->curr_gw);
 	if (!curr_gateway_tmp)
-		return NULL;
+		goto out;
+
+	orig_node =3D curr_gateway_tmp->orig_node;
=20
-	return curr_gateway_tmp->orig_node;
+out:
+	rcu_read_unlock();
+	return orig_node;
 }
=20
 void gw_deselect(struct bat_priv *bat_priv)
 {
-	struct gw_node *gw_node =3D bat_priv->curr_gw;
+	struct gw_node *gw_node;
=20
-	bat_priv->curr_gw =3D NULL;
+	spin_lock_bh(&bat_priv->gw_list_lock);
+	gw_node =3D rcu_dereference(bat_priv->curr_gw);
+	rcu_assign_pointer(bat_priv->curr_gw, NULL);
+	spin_unlock_bh(&bat_priv->gw_list_lock);
=20
 	if (gw_node)
 		gw_node_free_ref(gw_node);
@@ -64,12 +74,15 @@ void gw_deselect(struct bat_priv *bat_priv)
=20
 static void gw_select(struct bat_priv *bat_priv, struct gw_node *new_g=
w_node)
 {
-	struct gw_node *curr_gw_node =3D bat_priv->curr_gw;
+	struct gw_node *curr_gw_node;
=20
 	if (new_gw_node && !atomic_inc_not_zero(&new_gw_node->refcount))
 		new_gw_node =3D NULL;
=20
-	bat_priv->curr_gw =3D new_gw_node;
+	spin_lock_bh(&bat_priv->gw_list_lock);
+	curr_gw_node =3D rcu_dereference(bat_priv->curr_gw);
+	rcu_assign_pointer(bat_priv->curr_gw, new_gw_node);
+	spin_unlock_bh(&bat_priv->gw_list_lock);
=20
 	if (curr_gw_node)
 		gw_node_free_ref(curr_gw_node);
@@ -78,7 +91,7 @@ static void gw_select(struct bat_priv *bat_priv, stru=
ct gw_node *new_gw_node)
 void gw_election(struct bat_priv *bat_priv)
 {
 	struct hlist_node *node;
-	struct gw_node *gw_node, *curr_gw_tmp =3D NULL;
+	struct gw_node *gw_node, *curr_gw, *curr_gw_tmp =3D NULL;
 	uint8_t max_tq =3D 0;
 	uint32_t max_gw_factor =3D 0, tmp_gw_factor =3D 0;
 	int down, up;
@@ -92,19 +105,23 @@ void gw_election(struct bat_priv *bat_priv)
 	if (atomic_read(&bat_priv->gw_mode) !=3D GW_MODE_CLIENT)
 		return;
=20
-	if (bat_priv->curr_gw)
+	rcu_read_lock();
+	curr_gw =3D rcu_dereference(bat_priv->curr_gw);
+	if (curr_gw) {
+		rcu_read_unlock();
 		return;
+	}
=20
-	rcu_read_lock();
 	if (hlist_empty(&bat_priv->gw_list)) {
-		rcu_read_unlock();
=20
-		if (bat_priv->curr_gw) {
+		if (curr_gw) {
+			rcu_read_unlock();
 			bat_dbg(DBG_BATMAN, bat_priv,
 				"Removing selected gateway - "
 				"no gateway in range\n");
 			gw_deselect(bat_priv);
-		}
+		} else
+			rcu_read_unlock();
=20
 		return;
 	}
@@ -153,12 +170,12 @@ void gw_election(struct bat_priv *bat_priv)
 			max_gw_factor =3D tmp_gw_factor;
 	}
=20
-	if (bat_priv->curr_gw !=3D curr_gw_tmp) {
-		if ((bat_priv->curr_gw) && (!curr_gw_tmp))
+	if (curr_gw !=3D curr_gw_tmp) {
+		if ((curr_gw) && (!curr_gw_tmp))
 			bat_dbg(DBG_BATMAN, bat_priv,
 				"Removing selected gateway - "
 				"no gateway in range\n");
-		else if ((!bat_priv->curr_gw) && (curr_gw_tmp))
+		else if ((!curr_gw) && (curr_gw_tmp))
 			bat_dbg(DBG_BATMAN, bat_priv,
 				"Adding route to gateway %pM "
 				"(gw_flags: %i, tq: %i)\n",
@@ -181,31 +198,35 @@ void gw_election(struct bat_priv *bat_priv)
=20
 void gw_check_election(struct bat_priv *bat_priv, struct orig_node *or=
ig_node)
 {
-	struct gw_node *curr_gateway_tmp =3D bat_priv->curr_gw;
+	struct gw_node *curr_gateway_tmp;
 	uint8_t gw_tq_avg, orig_tq_avg;
=20
+	rcu_read_lock();
+	curr_gateway_tmp =3D rcu_dereference(bat_priv->curr_gw);
 	if (!curr_gateway_tmp)
-		return;
+		goto out_rcu;
=20
 	if (!curr_gateway_tmp->orig_node)
-		goto deselect;
+		goto deselect_rcu;
=20
 	if (!curr_gateway_tmp->orig_node->router)
-		goto deselect;
+		goto deselect_rcu;
=20
 	/* this node already is the gateway */
 	if (curr_gateway_tmp->orig_node =3D=3D orig_node)
-		return;
+		goto out_rcu;
=20
 	if (!orig_node->router)
-		return;
+		goto out_rcu;
=20
 	gw_tq_avg =3D curr_gateway_tmp->orig_node->router->tq_avg;
+	rcu_read_unlock();
+
 	orig_tq_avg =3D orig_node->router->tq_avg;
=20
 	/* the TQ value has to be better */
 	if (orig_tq_avg < gw_tq_avg)
-		return;
+		goto out;
=20
 	/**
 	 * if the routing class is greater than 3 the value tells us how much
@@ -213,15 +234,23 @@ void gw_check_election(struct bat_priv *bat_priv,=
 struct orig_node *orig_node)
 	 **/
 	if ((atomic_read(&bat_priv->gw_sel_class) > 3) &&
 	    (orig_tq_avg - gw_tq_avg < atomic_read(&bat_priv->gw_sel_class)))
-		return;
+		goto out;
=20
 	bat_dbg(DBG_BATMAN, bat_priv,
 		"Restarting gateway selection: better gateway found (tq curr: "
 		"%i, tq new: %i)\n",
 		gw_tq_avg, orig_tq_avg);
+	goto deselect;
=20
+out_rcu:
+	rcu_read_unlock();
+	goto out;
+deselect_rcu:
+	rcu_read_unlock();
 deselect:
 	gw_deselect(bat_priv);
+out:
+	return;
 }
=20
 static void gw_node_add(struct bat_priv *bat_priv,
@@ -278,7 +307,7 @@ void gw_node_update(struct bat_priv *bat_priv,
 				"Gateway %pM removed from gateway list\n",
 				orig_node->orig);
=20
-			if (gw_node =3D=3D bat_priv->curr_gw) {
+			if (gw_node =3D=3D rcu_dereference(bat_priv->curr_gw)) {
 				rcu_read_unlock();
 				gw_deselect(bat_priv);
 				return;
@@ -316,7 +345,7 @@ void gw_node_purge(struct bat_priv *bat_priv)
 		    atomic_read(&bat_priv->mesh_state) =3D=3D MESH_ACTIVE)
 			continue;
=20
-		if (bat_priv->curr_gw =3D=3D gw_node)
+		if (rcu_dereference(bat_priv->curr_gw) =3D=3D gw_node)
 			gw_deselect(bat_priv);
=20
 		hlist_del_rcu(&gw_node->list);
@@ -330,12 +359,16 @@ void gw_node_purge(struct bat_priv *bat_priv)
 static int _write_buffer_text(struct bat_priv *bat_priv,
 			      struct seq_file *seq, struct gw_node *gw_node)
 {
-	int down, up;
+	struct gw_node *curr_gw;
+	int down, up, ret;
=20
 	gw_bandwidth_to_kbit(gw_node->orig_node->gw_flags, &down, &up);
=20
-	return seq_printf(seq, "%s %pM (%3i) %pM [%10s]: %3i - %i%s/%i%s\n",
-		       (bat_priv->curr_gw =3D=3D gw_node ? "=3D>" : "  "),
+	rcu_read_lock();
+	curr_gw =3D rcu_dereference(bat_priv->curr_gw);
+
+	ret =3D seq_printf(seq, "%s %pM (%3i) %pM [%10s]: %3i - %i%s/%i%s\n",
+		       (curr_gw =3D=3D gw_node ? "=3D>" : "  "),
 		       gw_node->orig_node->orig,
 		       gw_node->orig_node->router->tq_avg,
 		       gw_node->orig_node->router->addr,
@@ -345,6 +378,9 @@ static int _write_buffer_text(struct bat_priv *bat_=
priv,
 		       (down > 2048 ? "MBit" : "KBit"),
 		       (up > 2048 ? up / 1024 : up),
 		       (up > 2048 ? "MBit" : "KBit"));
+
+	rcu_read_unlock();
+	return ret;
 }
=20
 int gw_client_seq_print_text(struct seq_file *seq, void *offset)
@@ -465,8 +501,12 @@ int gw_is_target(struct bat_priv *bat_priv, struct=
 sk_buff *skb)
 	if (atomic_read(&bat_priv->gw_mode) =3D=3D GW_MODE_SERVER)
 		return -1;
=20
-	if (!bat_priv->curr_gw)
+	rcu_read_lock();
+	if (!rcu_dereference(bat_priv->curr_gw)) {
+		rcu_read_unlock();
 		return 0;
+	}
+	rcu_read_unlock();
=20
 	return 1;
 }
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index e1f3e5e..3dd5e77 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -162,7 +162,7 @@ struct bat_priv {
 	spinlock_t forw_bcast_list_lock; /* protects  */
 	spinlock_t hna_lhash_lock; /* protects hna_local_hash */
 	spinlock_t hna_ghash_lock; /* protects hna_global_hash */
-	spinlock_t gw_list_lock; /* protects gw_list */
+	spinlock_t gw_list_lock; /* protects gw_list and curr_gw */
 	spinlock_t vis_hash_lock; /* protects vis_hash */
 	spinlock_t vis_list_lock; /* protects vis_info::recv_list */
 	spinlock_t softif_neigh_lock; /* protects soft-interface neigh list *=
/
@@ -171,7 +171,7 @@ struct bat_priv {
 	struct delayed_work hna_work;
 	struct delayed_work orig_work;
 	struct delayed_work vis_work;
-	struct gw_node *curr_gw;
+	struct gw_node __rcu *curr_gw;  /* rcu protected pointer */
 	struct vis_info *my_vis_info;
 };
=20
--=20
1.7.2.3

