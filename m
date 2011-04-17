From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 4/8] batman-adv: Make orig_node->router an
	rcu protected pointer
Date: Sun, 17 Apr 2011 21:30:14 +0200
Message-ID: <1303068618-27928-5-git-send-email-sven@narfation.org>
References: <1303068618-27928-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1303068618-27928-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Linus L=C3=BCssing <linus.luessing-S0/GAf8tV78@public.gmane.org>

The rcu protected macros rcu_dereference() and rcu_assign_pointer()
for the orig_node->router need to be used, as well as spin/rcu locking.
Otherwise we might end up using a router pointer pointing to already
freed memory.

Therefore this commit introduces the safe getter method
orig_node_get_router().

Signed-off-by: Linus L=C3=BCssing <linus.luessing-S0/GAf8tV78@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/gateway_client.c |   80 ++++++++++-------
 net/batman-adv/icmp_socket.c    |   18 +---
 net/batman-adv/originator.c     |   37 ++++++--
 net/batman-adv/originator.h     |    1 +
 net/batman-adv/routing.c        |  194 +++++++++++++++++++--------------=
------
 net/batman-adv/send.c           |   19 +++--
 net/batman-adv/types.h          |    4 +-
 net/batman-adv/vis.c            |   91 +++++++++---------
 8 files changed, 232 insertions(+), 212 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_cli=
ent.c
index 879ac15..42a8a7b 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -98,6 +98,7 @@ void gw_election(struct bat_priv *bat_priv)
 {
 	struct hlist_node *node;
 	struct gw_node *gw_node, *curr_gw, *curr_gw_tmp =3D NULL;
+	struct neigh_node *router;
 	uint8_t max_tq =3D 0;
 	uint32_t max_gw_factor =3D 0, tmp_gw_factor =3D 0;
 	int down, up;
@@ -133,10 +134,11 @@ void gw_election(struct bat_priv *bat_priv)
 	}
=20
 	hlist_for_each_entry_rcu(gw_node, node, &bat_priv->gw_list, list) {
-		if (!gw_node->orig_node->router)
+		if (gw_node->deleted)
 			continue;
=20
-		if (gw_node->deleted)
+		router =3D orig_node_get_router(gw_node->orig_node);
+		if (!router)
 			continue;
=20
 		switch (atomic_read(&bat_priv->gw_sel_class)) {
@@ -144,15 +146,14 @@ void gw_election(struct bat_priv *bat_priv)
 			gw_bandwidth_to_kbit(gw_node->orig_node->gw_flags,
 					     &down, &up);
=20
-			tmp_gw_factor =3D (gw_node->orig_node->router->tq_avg *
-					 gw_node->orig_node->router->tq_avg *
+			tmp_gw_factor =3D (router->tq_avg * router->tq_avg *
 					 down * 100 * 100) /
 					 (TQ_LOCAL_WINDOW_SIZE *
 					 TQ_LOCAL_WINDOW_SIZE * 64);
=20
 			if ((tmp_gw_factor > max_gw_factor) ||
 			    ((tmp_gw_factor =3D=3D max_gw_factor) &&
-			     (gw_node->orig_node->router->tq_avg > max_tq)))
+			     (router->tq_avg > max_tq)))
 				curr_gw_tmp =3D gw_node;
 			break;
=20
@@ -164,19 +165,25 @@ void gw_election(struct bat_priv *bat_priv)
 			  *     soon as a better gateway appears which has
 			  *     $routing_class more tq points)
 			  **/
-			if (gw_node->orig_node->router->tq_avg > max_tq)
+			if (router->tq_avg > max_tq)
 				curr_gw_tmp =3D gw_node;
 			break;
 		}
=20
-		if (gw_node->orig_node->router->tq_avg > max_tq)
-			max_tq =3D gw_node->orig_node->router->tq_avg;
+		if (router->tq_avg > max_tq)
+			max_tq =3D router->tq_avg;
=20
 		if (tmp_gw_factor > max_gw_factor)
 			max_gw_factor =3D tmp_gw_factor;
+
+		neigh_node_free_ref(router);
 	}
=20
 	if (curr_gw !=3D curr_gw_tmp) {
+		router =3D orig_node_get_router(curr_gw_tmp->orig_node);
+		if (!router)
+			goto out;
+
 		if ((curr_gw) && (!curr_gw_tmp))
 			bat_dbg(DBG_BATMAN, bat_priv,
 				"Removing selected gateway - "
@@ -187,45 +194,47 @@ void gw_election(struct bat_priv *bat_priv)
 				"(gw_flags: %i, tq: %i)\n",
 				curr_gw_tmp->orig_node->orig,
 				curr_gw_tmp->orig_node->gw_flags,
-				curr_gw_tmp->orig_node->router->tq_avg);
+				router->tq_avg);
 		else
 			bat_dbg(DBG_BATMAN, bat_priv,
 				"Changing route to gateway %pM "
 				"(gw_flags: %i, tq: %i)\n",
 				curr_gw_tmp->orig_node->orig,
 				curr_gw_tmp->orig_node->gw_flags,
-				curr_gw_tmp->orig_node->router->tq_avg);
+				router->tq_avg);
=20
+		neigh_node_free_ref(router);
 		gw_select(bat_priv, curr_gw_tmp);
 	}
=20
+out:
 	rcu_read_unlock();
 }
=20
 void gw_check_election(struct bat_priv *bat_priv, struct orig_node *orig=
_node)
 {
 	struct orig_node *curr_gw_orig;
+	struct neigh_node *router_gw =3D NULL, *router_orig =3D NULL;
 	uint8_t gw_tq_avg, orig_tq_avg;
=20
 	curr_gw_orig =3D gw_get_selected(bat_priv);
 	if (!curr_gw_orig)
 		goto deselect;
=20
-	rcu_read_lock();
-	if (!curr_gw_orig->router)
-		goto deselect_rcu;
+	router_gw =3D orig_node_get_router(curr_gw_orig);
+	if (!router_gw)
+		goto deselect;
=20
 	/* this node already is the gateway */
 	if (curr_gw_orig =3D=3D orig_node)
-		goto out_rcu;
+		goto out;
=20
-	if (!orig_node->router)
-		goto out_rcu;
+	router_orig =3D orig_node_get_router(orig_node);
+	if (!router_orig)
+		goto out;
=20
-	gw_tq_avg =3D curr_gw_orig->router->tq_avg;
-	rcu_read_unlock();
-
-	orig_tq_avg =3D orig_node->router->tq_avg;
+	gw_tq_avg =3D router_gw->tq_avg;
+	orig_tq_avg =3D router_orig->tq_avg;
=20
 	/* the TQ value has to be better */
 	if (orig_tq_avg < gw_tq_avg)
@@ -243,18 +252,16 @@ void gw_check_election(struct bat_priv *bat_priv, s=
truct orig_node *orig_node)
 		"Restarting gateway selection: better gateway found (tq curr: "
 		"%i, tq new: %i)\n",
 		gw_tq_avg, orig_tq_avg);
-	goto deselect;
=20
-out_rcu:
-	rcu_read_unlock();
-	goto out;
-deselect_rcu:
-	rcu_read_unlock();
 deselect:
 	gw_deselect(bat_priv);
 out:
 	if (curr_gw_orig)
 		orig_node_free_ref(curr_gw_orig);
+	if (router_gw)
+		neigh_node_free_ref(router_gw);
+	if (router_orig)
+		neigh_node_free_ref(router_orig);
=20
 	return;
 }
@@ -362,23 +369,30 @@ void gw_node_purge(struct bat_priv *bat_priv)
 	spin_unlock_bh(&bat_priv->gw_list_lock);
 }
=20
+/**
+ * fails if orig_node has no router
+ */
 static int _write_buffer_text(struct bat_priv *bat_priv,
 			      struct seq_file *seq, struct gw_node *gw_node)
 {
 	struct gw_node *curr_gw;
-	int down, up, ret;
+	struct neigh_node *router;
+	int down, up, ret =3D -1;
=20
 	gw_bandwidth_to_kbit(gw_node->orig_node->gw_flags, &down, &up);
=20
+	router =3D orig_node_get_router(gw_node->orig_node);
+	if (!router)
+		goto out;
+
 	rcu_read_lock();
 	curr_gw =3D rcu_dereference(bat_priv->curr_gw);
=20
 	ret =3D seq_printf(seq, "%s %pM (%3i) %pM [%10s]: %3i - %i%s/%i%s\n",
 		       (curr_gw =3D=3D gw_node ? "=3D>" : "  "),
 		       gw_node->orig_node->orig,
-		       gw_node->orig_node->router->tq_avg,
-		       gw_node->orig_node->router->addr,
-		       gw_node->orig_node->router->if_incoming->net_dev->name,
+		       router->tq_avg, router->addr,
+		       router->if_incoming->net_dev->name,
 		       gw_node->orig_node->gw_flags,
 		       (down > 2048 ? down / 1024 : down),
 		       (down > 2048 ? "MBit" : "KBit"),
@@ -386,6 +400,8 @@ static int _write_buffer_text(struct bat_priv *bat_pr=
iv,
 		       (up > 2048 ? "MBit" : "KBit"));
=20
 	rcu_read_unlock();
+	neigh_node_free_ref(router);
+out:
 	return ret;
 }
=20
@@ -423,10 +439,10 @@ int gw_client_seq_print_text(struct seq_file *seq, =
void *offset)
 		if (gw_node->deleted)
 			continue;
=20
-		if (!gw_node->orig_node->router)
+		/* fails if orig_node has no router */
+		if (_write_buffer_text(bat_priv, seq, gw_node) < 0)
 			continue;
=20
-		_write_buffer_text(bat_priv, seq, gw_node);
 		gw_count++;
 	}
 	rcu_read_unlock();
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 34ce56c..49079c2 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -218,23 +218,13 @@ static ssize_t bat_socket_write(struct file *file, =
const char __user *buff,
 	if (atomic_read(&bat_priv->mesh_state) !=3D MESH_ACTIVE)
 		goto dst_unreach;
=20
-	rcu_read_lock();
 	orig_node =3D orig_hash_find(bat_priv, icmp_packet->dst);
-
 	if (!orig_node)
-		goto unlock;
-
-	neigh_node =3D orig_node->router;
+		goto dst_unreach;
=20
+	neigh_node =3D orig_node_get_router(orig_node);
 	if (!neigh_node)
-		goto unlock;
-
-	if (!atomic_inc_not_zero(&neigh_node->refcount)) {
-		neigh_node =3D NULL;
-		goto unlock;
-	}
-
-	rcu_read_unlock();
+		goto dst_unreach;
=20
 	if (!neigh_node->if_incoming)
 		goto dst_unreach;
@@ -252,8 +242,6 @@ static ssize_t bat_socket_write(struct file *file, co=
nst char __user *buff,
 	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
 	goto out;
=20
-unlock:
-	rcu_read_unlock();
 dst_unreach:
 	icmp_packet->msg_type =3D DESTINATION_UNREACHABLE;
 	bat_socket_add_packet(socket_client, icmp_packet, packet_len);
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 0b91330..b4cfe36 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -70,6 +70,21 @@ void neigh_node_free_ref(struct neigh_node *neigh_node=
)
 		call_rcu(&neigh_node->rcu, neigh_node_free_rcu);
 }
=20
+/* increases the refcounter of a found router */
+struct neigh_node *orig_node_get_router(struct orig_node *orig_node)
+{
+	struct neigh_node *router;
+
+	rcu_read_lock();
+	router =3D rcu_dereference(orig_node->router);
+
+	if (router && !atomic_inc_not_zero(&router->refcount))
+		router =3D NULL;
+
+	rcu_read_unlock();
+	return router;
+}
+
 struct neigh_node *create_neighbor(struct orig_node *orig_node,
 				   struct orig_node *orig_neigh_node,
 				   uint8_t *neigh,
@@ -390,7 +405,7 @@ int orig_seq_print_text(struct seq_file *seq, void *o=
ffset)
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
 	struct orig_node *orig_node;
-	struct neigh_node *neigh_node;
+	struct neigh_node *neigh_node, *neigh_node_tmp;
 	int batman_count =3D 0;
 	int last_seen_secs;
 	int last_seen_msecs;
@@ -421,37 +436,41 @@ int orig_seq_print_text(struct seq_file *seq, void =
*offset)
=20
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(orig_node, node, head, hash_entry) {
-			if (!orig_node->router)
+			neigh_node =3D orig_node_get_router(orig_node);
+			if (!neigh_node)
 				continue;
=20
-			if (orig_node->router->tq_avg =3D=3D 0)
-				continue;
+			if (neigh_node->tq_avg =3D=3D 0)
+				goto next;
=20
 			last_seen_secs =3D jiffies_to_msecs(jiffies -
 						orig_node->last_valid) / 1000;
 			last_seen_msecs =3D jiffies_to_msecs(jiffies -
 						orig_node->last_valid) % 1000;
=20
-			neigh_node =3D orig_node->router;
 			seq_printf(seq, "%pM %4i.%03is   (%3i) %pM [%10s]:",
 				   orig_node->orig, last_seen_secs,
 				   last_seen_msecs, neigh_node->tq_avg,
 				   neigh_node->addr,
 				   neigh_node->if_incoming->net_dev->name);
=20
-			hlist_for_each_entry_rcu(neigh_node, node_tmp,
+			hlist_for_each_entry_rcu(neigh_node_tmp, node_tmp,
 						 &orig_node->neigh_list, list) {
-				seq_printf(seq, " %pM (%3i)", neigh_node->addr,
-						neigh_node->tq_avg);
+				seq_printf(seq, " %pM (%3i)",
+					   neigh_node_tmp->addr,
+					   neigh_node_tmp->tq_avg);
 			}
=20
 			seq_printf(seq, "\n");
 			batman_count++;
+
+next:
+			neigh_node_free_ref(neigh_node);
 		}
 		rcu_read_unlock();
 	}
=20
-	if ((batman_count =3D=3D 0))
+	if (batman_count =3D=3D 0)
 		seq_printf(seq, "No batman nodes in range ...\n");
=20
 	return 0;
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 5cc0110..e1d641f 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -34,6 +34,7 @@ struct neigh_node *create_neighbor(struct orig_node *or=
ig_node,
 				   uint8_t *neigh,
 				   struct hard_iface *if_incoming);
 void neigh_node_free_ref(struct neigh_node *neigh_node);
+struct neigh_node *orig_node_get_router(struct orig_node *orig_node);
 int orig_seq_print_text(struct seq_file *seq, void *offset);
 int orig_hash_add_if(struct hard_iface *hard_iface, int max_if_num);
 int orig_hash_del_if(struct hard_iface *hard_iface, int max_if_num);
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index f212abe..b7d43ca 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -87,18 +87,20 @@ static void update_route(struct bat_priv *bat_priv,
 			 struct neigh_node *neigh_node,
 			 unsigned char *hna_buff, int hna_buff_len)
 {
-	struct neigh_node *neigh_node_tmp;
+	struct neigh_node *curr_router;
+
+	curr_router =3D orig_node_get_router(orig_node);
=20
 	/* route deleted */
-	if ((orig_node->router) && (!neigh_node)) {
+	if ((curr_router) && (!neigh_node)) {
=20
 		bat_dbg(DBG_ROUTES, bat_priv, "Deleting route towards: %pM\n",
 			orig_node->orig);
 		hna_global_del_orig(bat_priv, orig_node,
 				    "originator timed out");
=20
-		/* route added */
-	} else if ((!orig_node->router) && (neigh_node)) {
+	/* route added */
+	} else if ((!curr_router) && (neigh_node)) {
=20
 		bat_dbg(DBG_ROUTES, bat_priv,
 			"Adding route towards: %pM (via %pM)\n",
@@ -106,21 +108,29 @@ static void update_route(struct bat_priv *bat_priv,
 		hna_global_add_orig(bat_priv, orig_node,
 				    hna_buff, hna_buff_len);
=20
-		/* route changed */
+	/* route changed */
 	} else {
 		bat_dbg(DBG_ROUTES, bat_priv,
 			"Changing route towards: %pM "
 			"(now via %pM - was via %pM)\n",
 			orig_node->orig, neigh_node->addr,
-			orig_node->router->addr);
+			curr_router->addr);
 	}
=20
+	if (curr_router)
+		neigh_node_free_ref(curr_router);
+
+	/* increase refcount of new best neighbor */
 	if (neigh_node && !atomic_inc_not_zero(&neigh_node->refcount))
 		neigh_node =3D NULL;
-	neigh_node_tmp =3D orig_node->router;
-	orig_node->router =3D neigh_node;
-	if (neigh_node_tmp)
-		neigh_node_free_ref(neigh_node_tmp);
+
+	spin_lock_bh(&orig_node->neigh_list_lock);
+	rcu_assign_pointer(orig_node->router, neigh_node);
+	spin_unlock_bh(&orig_node->neigh_list_lock);
+
+	/* decrease refcount of previous best neighbor */
+	if (curr_router)
+		neigh_node_free_ref(curr_router);
 }
=20
=20
@@ -128,16 +138,23 @@ void update_routes(struct bat_priv *bat_priv, struc=
t orig_node *orig_node,
 		   struct neigh_node *neigh_node, unsigned char *hna_buff,
 		   int hna_buff_len)
 {
+	struct neigh_node *router =3D NULL;
=20
 	if (!orig_node)
-		return;
+		goto out;
=20
-	if (orig_node->router !=3D neigh_node)
+	router =3D orig_node_get_router(orig_node);
+
+	if (router !=3D neigh_node)
 		update_route(bat_priv, orig_node, neigh_node,
 			     hna_buff, hna_buff_len);
 	/* may be just HNA changed */
 	else
 		update_HNA(bat_priv, orig_node, hna_buff, hna_buff_len);
+
+out:
+	if (router)
+		neigh_node_free_ref(router);
 }
=20
 static int is_bidirectional_neigh(struct orig_node *orig_node,
@@ -288,8 +305,8 @@ static void bonding_candidate_add(struct orig_node *o=
rig_node,
 				  struct neigh_node *neigh_node)
 {
 	struct hlist_node *node;
-	struct neigh_node *tmp_neigh_node;
-	uint8_t best_tq, interference_candidate =3D 0;
+	struct neigh_node *tmp_neigh_node, *router =3D NULL;
+	uint8_t interference_candidate =3D 0;
=20
 	spin_lock_bh(&orig_node->neigh_list_lock);
=20
@@ -298,13 +315,12 @@ static void bonding_candidate_add(struct orig_node =
*orig_node,
 			 neigh_node->orig_node->primary_addr))
 		goto candidate_del;
=20
-	if (!orig_node->router)
+	router =3D orig_node_get_router(orig_node);
+	if (!router)
 		goto candidate_del;
=20
-	best_tq =3D orig_node->router->tq_avg;
-
 	/* ... and is good enough to be considered */
-	if (neigh_node->tq_avg < best_tq - BONDING_TQ_THRESHOLD)
+	if (neigh_node->tq_avg < router->tq_avg - BONDING_TQ_THRESHOLD)
 		goto candidate_del;
=20
 	/**
@@ -350,7 +366,9 @@ candidate_del:
=20
 out:
 	spin_unlock_bh(&orig_node->neigh_list_lock);
-	return;
+
+	if (router)
+		neigh_node_free_ref(router);
 }
=20
 /* copy primary address for bonding */
@@ -373,6 +391,7 @@ static void update_orig(struct bat_priv *bat_priv,
 			char is_duplicate)
 {
 	struct neigh_node *neigh_node =3D NULL, *tmp_neigh_node =3D NULL;
+	struct neigh_node *router =3D NULL;
 	struct orig_node *orig_node_tmp;
 	struct hlist_node *node;
 	int tmp_hna_buff_len;
@@ -441,19 +460,18 @@ static void update_orig(struct bat_priv *bat_priv,
=20
 	/* if this neighbor already is our next hop there is nothing
 	 * to change */
-	if (orig_node->router =3D=3D neigh_node)
+	router =3D orig_node_get_router(orig_node);
+	if (router =3D=3D neigh_node)
 		goto update_hna;
=20
 	/* if this neighbor does not offer a better TQ we won't consider it */
-	if ((orig_node->router) &&
-	    (orig_node->router->tq_avg > neigh_node->tq_avg))
+	if (router && (router->tq_avg > neigh_node->tq_avg))
 		goto update_hna;
=20
 	/* if the TQ is the same and the link not more symetric we
 	 * won't consider it either */
-	if ((orig_node->router) &&
-	     (neigh_node->tq_avg =3D=3D orig_node->router->tq_avg)) {
-		orig_node_tmp =3D orig_node->router->orig_node;
+	if (router && (neigh_node->tq_avg =3D=3D router->tq_avg)) {
+		orig_node_tmp =3D router->orig_node;
 		spin_lock_bh(&orig_node_tmp->ogm_cnt_lock);
 		bcast_own_sum_orig =3D
 			orig_node_tmp->bcast_own_sum[if_incoming->if_num];
@@ -474,7 +492,7 @@ static void update_orig(struct bat_priv *bat_priv,
 	goto update_gw;
=20
 update_hna:
-	update_routes(bat_priv, orig_node, orig_node->router,
+	update_routes(bat_priv, orig_node, router,
 		      hna_buff, tmp_hna_buff_len);
=20
 update_gw:
@@ -496,6 +514,8 @@ unlock:
 out:
 	if (neigh_node)
 		neigh_node_free_ref(neigh_node);
+	if (router)
+		neigh_node_free_ref(router);
 }
=20
 /* checks whether the host restarted and is in the protection time.
@@ -603,6 +623,8 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 	struct bat_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface);
 	struct hard_iface *hard_iface;
 	struct orig_node *orig_neigh_node, *orig_node;
+	struct neigh_node *router =3D NULL, *router_router =3D NULL;
+	struct neigh_node *orig_neigh_router =3D NULL;
 	char has_directlink_flag;
 	char is_my_addr =3D 0, is_my_orig =3D 0, is_my_oldorig =3D 0;
 	char is_broadcast =3D 0, is_bidirectional, is_single_hop_neigh;
@@ -747,14 +769,15 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 		goto out;
 	}
=20
+	router =3D orig_node_get_router(orig_node);
+	if (router)
+		router_router =3D orig_node_get_router(router->orig_node);
+
 	/* avoid temporary routing loops */
-	if ((orig_node->router) &&
-	    (orig_node->router->orig_node->router) &&
-	    (compare_eth(orig_node->router->addr,
-			 batman_packet->prev_sender)) &&
+	if (router && router_router &&
+	    (compare_eth(router->addr, batman_packet->prev_sender)) &&
 	    !(compare_eth(batman_packet->orig, batman_packet->prev_sender)) &&
-	    (compare_eth(orig_node->router->addr,
-			 orig_node->router->orig_node->router->addr))) {
+	    (compare_eth(router->addr, router_router->addr))) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Drop packet: ignoring all rebroadcast packets that "
 			"may make me loop (sender: %pM)\n", ethhdr->h_source);
@@ -769,9 +792,11 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 	if (!orig_neigh_node)
 		goto out;
=20
+	orig_neigh_router =3D orig_node_get_router(orig_neigh_node);
+
 	/* drop packet if sender is not a direct neighbor and if we
 	 * don't route towards it */
-	if (!is_single_hop_neigh && (!orig_neigh_node->router)) {
+	if (!is_single_hop_neigh && (!orig_neigh_router)) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Drop packet: OGM via unknown neighbor!\n");
 		goto out_neigh;
@@ -825,6 +850,13 @@ out_neigh:
 	if ((orig_neigh_node) && (!is_single_hop_neigh))
 		orig_node_free_ref(orig_neigh_node);
 out:
+	if (router)
+		neigh_node_free_ref(router);
+	if (router_router)
+		neigh_node_free_ref(router_router);
+	if (orig_neigh_router)
+		neigh_node_free_ref(orig_neigh_router);
+
 	orig_node_free_ref(orig_node);
 }
=20
@@ -869,7 +901,7 @@ static int recv_my_icmp_packet(struct bat_priv *bat_p=
riv,
 			       struct sk_buff *skb, size_t icmp_len)
 {
 	struct orig_node *orig_node =3D NULL;
-	struct neigh_node *neigh_node =3D NULL;
+	struct neigh_node *router =3D NULL;
 	struct icmp_packet_rr *icmp_packet;
 	int ret =3D NET_RX_DROP;
=20
@@ -886,23 +918,13 @@ static int recv_my_icmp_packet(struct bat_priv *bat=
_priv,
=20
 	/* answer echo request (ping) */
 	/* get routing information */
-	rcu_read_lock();
 	orig_node =3D orig_hash_find(bat_priv, icmp_packet->orig);
-
 	if (!orig_node)
-		goto unlock;
+		goto out;
=20
-	neigh_node =3D orig_node->router;
-
-	if (!neigh_node)
-		goto unlock;
-
-	if (!atomic_inc_not_zero(&neigh_node->refcount)) {
-		neigh_node =3D NULL;
-		goto unlock;
-	}
-
-	rcu_read_unlock();
+	router =3D orig_node_get_router(orig_node);
+	if (!router)
+		goto out;
=20
 	/* create a copy of the skb, if needed, to modify it. */
 	if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
@@ -916,15 +938,12 @@ static int recv_my_icmp_packet(struct bat_priv *bat=
_priv,
 	icmp_packet->msg_type =3D ECHO_REPLY;
 	icmp_packet->ttl =3D TTL;
=20
-	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
+	send_skb_packet(skb, router->if_incoming, router->addr);
 	ret =3D NET_RX_SUCCESS;
-	goto out;
=20
-unlock:
-	rcu_read_unlock();
 out:
-	if (neigh_node)
-		neigh_node_free_ref(neigh_node);
+	if (router)
+		neigh_node_free_ref(router);
 	if (orig_node)
 		orig_node_free_ref(orig_node);
 	return ret;
@@ -934,7 +953,7 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *ba=
t_priv,
 				  struct sk_buff *skb)
 {
 	struct orig_node *orig_node =3D NULL;
-	struct neigh_node *neigh_node =3D NULL;
+	struct neigh_node *router =3D NULL;
 	struct icmp_packet *icmp_packet;
 	int ret =3D NET_RX_DROP;
=20
@@ -952,23 +971,13 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *=
bat_priv,
 		goto out;
=20
 	/* get routing information */
-	rcu_read_lock();
 	orig_node =3D orig_hash_find(bat_priv, icmp_packet->orig);
-
 	if (!orig_node)
-		goto unlock;
+		goto out;
=20
-	neigh_node =3D orig_node->router;
-
-	if (!neigh_node)
-		goto unlock;
-
-	if (!atomic_inc_not_zero(&neigh_node->refcount)) {
-		neigh_node =3D NULL;
-		goto unlock;
-	}
-
-	rcu_read_unlock();
+	router =3D orig_node_get_router(orig_node);
+	if (!router)
+		goto out;
=20
 	/* create a copy of the skb, if needed, to modify it. */
 	if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
@@ -982,15 +991,12 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *=
bat_priv,
 	icmp_packet->msg_type =3D TTL_EXCEEDED;
 	icmp_packet->ttl =3D TTL;
=20
-	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
+	send_skb_packet(skb, router->if_incoming, router->addr);
 	ret =3D NET_RX_SUCCESS;
-	goto out;
=20
-unlock:
-	rcu_read_unlock();
 out:
-	if (neigh_node)
-		neigh_node_free_ref(neigh_node);
+	if (router)
+		neigh_node_free_ref(router);
 	if (orig_node)
 		orig_node_free_ref(orig_node);
 	return ret;
@@ -1003,7 +1009,7 @@ int recv_icmp_packet(struct sk_buff *skb, struct ha=
rd_iface *recv_if)
 	struct icmp_packet_rr *icmp_packet;
 	struct ethhdr *ethhdr;
 	struct orig_node *orig_node =3D NULL;
-	struct neigh_node *neigh_node =3D NULL;
+	struct neigh_node *router =3D NULL;
 	int hdr_size =3D sizeof(struct icmp_packet);
 	int ret =3D NET_RX_DROP;
=20
@@ -1050,23 +1056,13 @@ int recv_icmp_packet(struct sk_buff *skb, struct =
hard_iface *recv_if)
 		return recv_icmp_ttl_exceeded(bat_priv, skb);
=20
 	/* get routing information */
-	rcu_read_lock();
 	orig_node =3D orig_hash_find(bat_priv, icmp_packet->dst);
-
 	if (!orig_node)
-		goto unlock;
+		goto out;
=20
-	neigh_node =3D orig_node->router;
-
-	if (!neigh_node)
-		goto unlock;
-
-	if (!atomic_inc_not_zero(&neigh_node->refcount)) {
-		neigh_node =3D NULL;
-		goto unlock;
-	}
-
-	rcu_read_unlock();
+	router =3D orig_node_get_router(orig_node);
+	if (!router)
+		goto out;
=20
 	/* create a copy of the skb, if needed, to modify it. */
 	if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
@@ -1078,15 +1074,12 @@ int recv_icmp_packet(struct sk_buff *skb, struct =
hard_iface *recv_if)
 	icmp_packet->ttl--;
=20
 	/* route it */
-	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
+	send_skb_packet(skb, router->if_incoming, router->addr);
 	ret =3D NET_RX_SUCCESS;
-	goto out;
=20
-unlock:
-	rcu_read_unlock();
 out:
-	if (neigh_node)
-		neigh_node_free_ref(neigh_node);
+	if (router)
+		neigh_node_free_ref(router);
 	if (orig_node)
 		orig_node_free_ref(orig_node);
 	return ret;
@@ -1208,7 +1201,8 @@ struct neigh_node *find_router(struct bat_priv *bat=
_priv,
 	if (!orig_node)
 		return NULL;
=20
-	if (!orig_node->router)
+	router =3D orig_node_get_router(orig_node);
+	if (!router)
 		return NULL;
=20
 	/* without bonding, the first node should
@@ -1217,9 +1211,8 @@ struct neigh_node *find_router(struct bat_priv *bat=
_priv,
=20
 	rcu_read_lock();
 	/* select default router to output */
-	router =3D orig_node->router;
-	router_orig =3D orig_node->router->orig_node;
-	if (!router_orig || !atomic_inc_not_zero(&router->refcount)) {
+	router_orig =3D router->orig_node;
+	if (!router_orig) {
 		rcu_read_unlock();
 		return NULL;
 	}
@@ -1251,7 +1244,6 @@ struct neigh_node *find_router(struct bat_priv *bat=
_priv,
 	if (atomic_read(&primary_orig_node->bond_candidates) < 2)
 		goto return_router;
=20
-
 	/* all nodes between should choose a candidate which
 	 * is is not on the interface where the packet came
 	 * in. */
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index d49e54d..e78670c 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -308,6 +308,7 @@ void schedule_forward_packet(struct orig_node *orig_n=
ode,
 			     struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv =3D netdev_priv(if_incoming->soft_iface);
+	struct neigh_node *router;
 	unsigned char in_tq, in_ttl, tq_avg =3D 0;
 	unsigned long send_time;
=20
@@ -316,6 +317,8 @@ void schedule_forward_packet(struct orig_node *orig_n=
ode,
 		return;
 	}
=20
+	router =3D orig_node_get_router(orig_node);
+
 	in_tq =3D batman_packet->tq;
 	in_ttl =3D batman_packet->ttl;
=20
@@ -324,20 +327,22 @@ void schedule_forward_packet(struct orig_node *orig=
_node,
=20
 	/* rebroadcast tq of our best ranking neighbor to ensure the rebroadcas=
t
 	 * of our best tq value */
-	if ((orig_node->router) && (orig_node->router->tq_avg !=3D 0)) {
+	if (router && router->tq_avg !=3D 0) {
=20
 		/* rebroadcast ogm of best ranking neighbor as is */
-		if (!compare_eth(orig_node->router->addr, ethhdr->h_source)) {
-			batman_packet->tq =3D orig_node->router->tq_avg;
+		if (!compare_eth(router->addr, ethhdr->h_source)) {
+			batman_packet->tq =3D router->tq_avg;
=20
-			if (orig_node->router->last_ttl)
-				batman_packet->ttl =3D orig_node->router->last_ttl
-							- 1;
+			if (router->last_ttl)
+				batman_packet->ttl =3D router->last_ttl - 1;
 		}
=20
-		tq_avg =3D orig_node->router->tq_avg;
+		tq_avg =3D router->tq_avg;
 	}
=20
+	if (router)
+		neigh_node_free_ref(router);
+
 	/* apply hop penalty */
 	batman_packet->tq =3D hop_penalty(batman_packet->tq, bat_priv);
=20
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 83445cf..1854cbb 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -67,7 +67,7 @@ struct hard_iface {
 struct orig_node {
 	uint8_t orig[ETH_ALEN];
 	uint8_t primary_addr[ETH_ALEN];
-	struct neigh_node *router;
+	struct neigh_node __rcu *router; /* rcu protected pointer */
 	unsigned long *bcast_own;
 	uint8_t *bcast_own_sum;
 	unsigned long last_valid;
@@ -83,7 +83,7 @@ struct orig_node {
 	uint32_t last_bcast_seqno;
 	struct hlist_head neigh_list;
 	struct list_head frag_list;
-	spinlock_t neigh_list_lock; /* protects neighbor list */
+	spinlock_t neigh_list_lock; /* protects neigh_list and router */
 	atomic_t refcount;
 	struct rcu_head rcu;
 	struct hlist_node hash_entry;
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index f90212f..d4cc4f5 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -558,6 +558,7 @@ static int find_best_vis_server(struct bat_priv *bat_=
priv,
 				struct vis_info *info)
 {
 	struct hashtable_t *hash =3D bat_priv->orig_hash;
+	struct neigh_node *router;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	struct orig_node *orig_node;
@@ -571,13 +572,17 @@ static int find_best_vis_server(struct bat_priv *ba=
t_priv,
=20
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(orig_node, node, head, hash_entry) {
-			if ((orig_node) && (orig_node->router) &&
-			    (orig_node->flags & VIS_SERVER) &&
-			    (orig_node->router->tq_avg > best_tq)) {
-				best_tq =3D orig_node->router->tq_avg;
+			router =3D orig_node_get_router(orig_node);
+			if (!router)
+				continue;
+
+			if ((orig_node->flags & VIS_SERVER) &&
+			    (router->tq_avg > best_tq)) {
+				best_tq =3D router->tq_avg;
 				memcpy(packet->target_orig, orig_node->orig,
 				       ETH_ALEN);
 			}
+			neigh_node_free_ref(router);
 		}
 		rcu_read_unlock();
 	}
@@ -605,7 +610,7 @@ static int generate_vis_packet(struct bat_priv *bat_p=
riv)
 	struct hlist_node *node;
 	struct hlist_head *head;
 	struct orig_node *orig_node;
-	struct neigh_node *neigh_node;
+	struct neigh_node *router;
 	struct vis_info *info =3D (struct vis_info *)bat_priv->my_vis_info;
 	struct vis_packet *packet =3D (struct vis_packet *)info->skb_packet->da=
ta;
 	struct vis_info_entry *entry;
@@ -633,30 +638,32 @@ static int generate_vis_packet(struct bat_priv *bat=
_priv)
=20
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(orig_node, node, head, hash_entry) {
-			neigh_node =3D orig_node->router;
-
-			if (!neigh_node)
+			router =3D orig_node_get_router(orig_node);
+			if (!router)
 				continue;
=20
-			if (!compare_eth(neigh_node->addr, orig_node->orig))
-				continue;
+			if (!compare_eth(router->addr, orig_node->orig))
+				goto next;
=20
-			if (neigh_node->if_incoming->if_status !=3D IF_ACTIVE)
-				continue;
+			if (router->if_incoming->if_status !=3D IF_ACTIVE)
+				goto next;
=20
-			if (neigh_node->tq_avg < 1)
-				continue;
+			if (router->tq_avg < 1)
+				goto next;
=20
 			/* fill one entry into buffer. */
 			entry =3D (struct vis_info_entry *)
 				      skb_put(info->skb_packet, sizeof(*entry));
 			memcpy(entry->src,
-			       neigh_node->if_incoming->net_dev->dev_addr,
+			       router->if_incoming->net_dev->dev_addr,
 			       ETH_ALEN);
 			memcpy(entry->dest, orig_node->orig, ETH_ALEN);
-			entry->quality =3D neigh_node->tq_avg;
+			entry->quality =3D router->tq_avg;
 			packet->entries++;
=20
+next:
+			neigh_node_free_ref(router);
+
 			if (vis_packet_full(info))
 				goto unlock;
 		}
@@ -725,6 +732,7 @@ static void purge_vis_packets(struct bat_priv *bat_pr=
iv)
 static void broadcast_vis_packet(struct bat_priv *bat_priv,
 				 struct vis_info *info)
 {
+	struct neigh_node *router;
 	struct hashtable_t *hash =3D bat_priv->orig_hash;
 	struct hlist_node *node;
 	struct hlist_head *head;
@@ -745,19 +753,26 @@ static void broadcast_vis_packet(struct bat_priv *b=
at_priv,
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(orig_node, node, head, hash_entry) {
 			/* if it's a vis server and reachable, send it. */
-			if ((!orig_node) || (!orig_node->router))
-				continue;
 			if (!(orig_node->flags & VIS_SERVER))
 				continue;
+
+			router =3D orig_node_get_router(orig_node);
+			if (!router)
+				continue;
+
 			/* don't send it if we already received the packet from
-			* this node. */
+			 * this node. */
 			if (recv_list_is_in(bat_priv, &info->recv_list,
-					    orig_node->orig))
+					    orig_node->orig)) {
+				neigh_node_free_ref(router);
 				continue;
+			}
=20
 			memcpy(packet->target_orig, orig_node->orig, ETH_ALEN);
-			hard_iface =3D orig_node->router->if_incoming;
-			memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
+			hard_iface =3D router->if_incoming;
+			memcpy(dstaddr, router->addr, ETH_ALEN);
+
+			neigh_node_free_ref(router);
=20
 			skb =3D skb_clone(info->skb_packet, GFP_ATOMIC);
 			if (skb)
@@ -772,45 +787,29 @@ static void unicast_vis_packet(struct bat_priv *bat=
_priv,
 			       struct vis_info *info)
 {
 	struct orig_node *orig_node;
-	struct neigh_node *neigh_node =3D NULL;
+	struct neigh_node *router =3D NULL;
 	struct sk_buff *skb;
 	struct vis_packet *packet;
=20
 	packet =3D (struct vis_packet *)info->skb_packet->data;
=20
-	rcu_read_lock();
 	orig_node =3D orig_hash_find(bat_priv, packet->target_orig);
-
 	if (!orig_node)
-		goto unlock;
+		goto out;
=20
-	neigh_node =3D orig_node->router;
-
-	if (!neigh_node)
-		goto unlock;
-
-	if (!atomic_inc_not_zero(&neigh_node->refcount)) {
-		neigh_node =3D NULL;
-		goto unlock;
-	}
-
-	rcu_read_unlock();
+	router =3D orig_node_get_router(orig_node);
+	if (!router)
+		goto out;
=20
 	skb =3D skb_clone(info->skb_packet, GFP_ATOMIC);
 	if (skb)
-		send_skb_packet(skb, neigh_node->if_incoming,
-				neigh_node->addr);
+		send_skb_packet(skb, router->if_incoming, router->addr);
=20
-	goto out;
-
-unlock:
-	rcu_read_unlock();
 out:
-	if (neigh_node)
-		neigh_node_free_ref(neigh_node);
+	if (router)
+		neigh_node_free_ref(router);
 	if (orig_node)
 		orig_node_free_ref(orig_node);
-	return;
 }
=20
 /* only send one vis packet. called from send_vis_packets() */
--=20
1.7.4.4
