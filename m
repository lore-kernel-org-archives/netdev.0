From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 2/8] batman-adv: multi vlan support for
	bridge loop detection
Date: Sun,  8 May 2011 17:24:38 +0200
Message-ID: <1304868284-9364-3-git-send-email-sven@narfation.org>
References: <1304868284-9364-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1304868284-9364-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
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

From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>

The bridge loop detection for batman-adv allows the bat0 interface
to be bridged into an ethernet segment which other batman-adv nodes
are connected to. In order to also allow multiple VLANs on top of
the bat0 interface to be bridged into the ethernet segment this
patch extends the aforementioned bridge loop detection.

Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/main.c           |    3 +-
 net/batman-adv/soft-interface.c |  407 ++++++++++++++++++++++++++++-----------
 net/batman-adv/types.h          |   19 ++-
 3 files changed, 307 insertions(+), 122 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 709b33b..705e8be 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -87,11 +87,12 @@ int mesh_init(struct net_device *soft_iface)
 	spin_lock_init(&bat_priv->vis_hash_lock);
 	spin_lock_init(&bat_priv->vis_list_lock);
 	spin_lock_init(&bat_priv->softif_neigh_lock);
+	spin_lock_init(&bat_priv->softif_neigh_vid_lock);
 
 	INIT_HLIST_HEAD(&bat_priv->forw_bat_list);
 	INIT_HLIST_HEAD(&bat_priv->forw_bcast_list);
 	INIT_HLIST_HEAD(&bat_priv->gw_list);
-	INIT_HLIST_HEAD(&bat_priv->softif_neigh_list);
+	INIT_HLIST_HEAD(&bat_priv->softif_neigh_vids);
 
 	if (originator_init(bat_priv) < 1)
 		goto err;
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index ea5e58c..8cb13a0 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -90,135 +90,251 @@ static void softif_neigh_free_ref(struct softif_neigh *softif_neigh)
 		call_rcu(&softif_neigh->rcu, softif_neigh_free_rcu);
 }
 
-static struct softif_neigh *softif_neigh_get_selected(struct bat_priv *bat_priv)
+static void softif_neigh_vid_free_rcu(struct rcu_head *rcu)
 {
-	struct softif_neigh *neigh;
-
-	rcu_read_lock();
-	neigh = rcu_dereference(bat_priv->softif_neigh);
-
-	if (neigh && !atomic_inc_not_zero(&neigh->refcount))
-		neigh = NULL;
-
-	rcu_read_unlock();
-	return neigh;
-}
-
-static void softif_neigh_select(struct bat_priv *bat_priv,
-				struct softif_neigh *new_neigh)
-{
-	struct softif_neigh *curr_neigh;
-
-	spin_lock_bh(&bat_priv->softif_neigh_lock);
-
-	if (new_neigh && !atomic_inc_not_zero(&new_neigh->refcount))
-		new_neigh = NULL;
-
-	curr_neigh = bat_priv->softif_neigh;
-	rcu_assign_pointer(bat_priv->softif_neigh, new_neigh);
-
-	if (curr_neigh)
-		softif_neigh_free_ref(curr_neigh);
-
-	spin_unlock_bh(&bat_priv->softif_neigh_lock);
-}
-
-static void softif_neigh_deselect(struct bat_priv *bat_priv)
-{
-	softif_neigh_select(bat_priv, NULL);
-}
-
-void softif_neigh_purge(struct bat_priv *bat_priv)
-{
-	struct softif_neigh *softif_neigh, *curr_softif_neigh;
+	struct softif_neigh_vid *softif_neigh_vid;
+	struct softif_neigh *softif_neigh;
 	struct hlist_node *node, *node_tmp;
-	char do_deselect = 0;
+	struct bat_priv *bat_priv;
 
-	curr_softif_neigh = softif_neigh_get_selected(bat_priv);
+	softif_neigh_vid = container_of(rcu, struct softif_neigh_vid, rcu);
+	bat_priv = softif_neigh_vid->bat_priv;
 
 	spin_lock_bh(&bat_priv->softif_neigh_lock);
-
 	hlist_for_each_entry_safe(softif_neigh, node, node_tmp,
-				  &bat_priv->softif_neigh_list, list) {
-
-		if ((!time_after(jiffies, softif_neigh->last_seen +
-				msecs_to_jiffies(SOFTIF_NEIGH_TIMEOUT))) &&
-		    (atomic_read(&bat_priv->mesh_state) == MESH_ACTIVE))
-			continue;
-
-		if (curr_softif_neigh == softif_neigh) {
-			bat_dbg(DBG_ROUTES, bat_priv,
-				 "Current mesh exit point '%pM' vanished "
-				 "(vid: %d).\n",
-				 softif_neigh->addr, softif_neigh->vid);
-			do_deselect = 1;
-		}
-
+				  &softif_neigh_vid->softif_neigh_list, list) {
 		hlist_del_rcu(&softif_neigh->list);
 		softif_neigh_free_ref(softif_neigh);
 	}
-
 	spin_unlock_bh(&bat_priv->softif_neigh_lock);
 
-	/* soft_neigh_deselect() needs to acquire the softif_neigh_lock */
-	if (do_deselect)
-		softif_neigh_deselect(bat_priv);
+	kfree(softif_neigh_vid);
+}
 
-	if (curr_softif_neigh)
-		softif_neigh_free_ref(curr_softif_neigh);
+static void softif_neigh_vid_free_ref(struct softif_neigh_vid *softif_neigh_vid)
+{
+	if (atomic_dec_and_test(&softif_neigh_vid->refcount))
+		call_rcu(&softif_neigh_vid->rcu, softif_neigh_vid_free_rcu);
+}
+
+static struct softif_neigh_vid *softif_neigh_vid_get(struct bat_priv *bat_priv,
+						     short vid)
+{
+	struct softif_neigh_vid *softif_neigh_vid;
+	struct hlist_node *node;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(softif_neigh_vid, node,
+				 &bat_priv->softif_neigh_vids, list) {
+		if (softif_neigh_vid->vid != vid)
+			continue;
+
+		if (!atomic_inc_not_zero(&softif_neigh_vid->refcount))
+			continue;
+
+		goto out;
+	}
+
+	softif_neigh_vid = kzalloc(sizeof(struct softif_neigh_vid),
+				   GFP_ATOMIC);
+	if (!softif_neigh_vid)
+		goto out;
+
+	softif_neigh_vid->vid = vid;
+	softif_neigh_vid->bat_priv = bat_priv;
+
+	/* initialize with 2 - caller decrements counter by one */
+	atomic_set(&softif_neigh_vid->refcount, 2);
+	INIT_HLIST_HEAD(&softif_neigh_vid->softif_neigh_list);
+	INIT_HLIST_NODE(&softif_neigh_vid->list);
+	spin_lock_bh(&bat_priv->softif_neigh_vid_lock);
+	hlist_add_head_rcu(&softif_neigh_vid->list,
+			   &bat_priv->softif_neigh_vids);
+	spin_unlock_bh(&bat_priv->softif_neigh_vid_lock);
+
+out:
+	rcu_read_unlock();
+	return softif_neigh_vid;
 }
 
 static struct softif_neigh *softif_neigh_get(struct bat_priv *bat_priv,
 					     uint8_t *addr, short vid)
 {
-	struct softif_neigh *softif_neigh;
+	struct softif_neigh_vid *softif_neigh_vid;
+	struct softif_neigh *softif_neigh = NULL;
 	struct hlist_node *node;
 
+	softif_neigh_vid = softif_neigh_vid_get(bat_priv, vid);
+	if (!softif_neigh_vid)
+		goto out;
+
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(softif_neigh, node,
-				 &bat_priv->softif_neigh_list, list) {
+				 &softif_neigh_vid->softif_neigh_list,
+				 list) {
 		if (!compare_eth(softif_neigh->addr, addr))
 			continue;
 
-		if (softif_neigh->vid != vid)
-			continue;
-
 		if (!atomic_inc_not_zero(&softif_neigh->refcount))
 			continue;
 
 		softif_neigh->last_seen = jiffies;
-		goto out;
+		goto unlock;
 	}
 
 	softif_neigh = kzalloc(sizeof(struct softif_neigh), GFP_ATOMIC);
 	if (!softif_neigh)
-		goto out;
+		goto unlock;
 
 	memcpy(softif_neigh->addr, addr, ETH_ALEN);
-	softif_neigh->vid = vid;
 	softif_neigh->last_seen = jiffies;
 	/* initialize with 2 - caller decrements counter by one */
 	atomic_set(&softif_neigh->refcount, 2);
 
 	INIT_HLIST_NODE(&softif_neigh->list);
 	spin_lock_bh(&bat_priv->softif_neigh_lock);
-	hlist_add_head_rcu(&softif_neigh->list, &bat_priv->softif_neigh_list);
+	hlist_add_head_rcu(&softif_neigh->list,
+			   &softif_neigh_vid->softif_neigh_list);
 	spin_unlock_bh(&bat_priv->softif_neigh_lock);
 
+unlock:
+	rcu_read_unlock();
 out:
+	if (softif_neigh_vid)
+		softif_neigh_vid_free_ref(softif_neigh_vid);
+	return softif_neigh;
+}
+
+static struct softif_neigh *softif_neigh_get_selected(
+				struct softif_neigh_vid *softif_neigh_vid)
+{
+	struct softif_neigh *softif_neigh;
+
+	rcu_read_lock();
+	softif_neigh = rcu_dereference(softif_neigh_vid->softif_neigh);
+
+	if (softif_neigh && !atomic_inc_not_zero(&softif_neigh->refcount))
+		softif_neigh = NULL;
+
 	rcu_read_unlock();
 	return softif_neigh;
 }
 
+static struct softif_neigh *softif_neigh_vid_get_selected(
+						struct bat_priv *bat_priv,
+						short vid)
+{
+	struct softif_neigh_vid *softif_neigh_vid;
+	struct softif_neigh *softif_neigh = NULL;
+
+	softif_neigh_vid = softif_neigh_vid_get(bat_priv, vid);
+	if (!softif_neigh_vid)
+		goto out;
+
+	softif_neigh = softif_neigh_get_selected(softif_neigh_vid);
+out:
+	if (softif_neigh_vid)
+		softif_neigh_vid_free_ref(softif_neigh_vid);
+	return softif_neigh;
+}
+
+static void softif_neigh_vid_select(struct bat_priv *bat_priv,
+				    struct softif_neigh *new_neigh,
+				    short vid)
+{
+	struct softif_neigh_vid *softif_neigh_vid;
+	struct softif_neigh *curr_neigh;
+
+	softif_neigh_vid = softif_neigh_vid_get(bat_priv, vid);
+	if (!softif_neigh_vid)
+		goto out;
+
+	spin_lock_bh(&bat_priv->softif_neigh_lock);
+
+	if (new_neigh && !atomic_inc_not_zero(&new_neigh->refcount))
+		new_neigh = NULL;
+
+	curr_neigh = softif_neigh_vid->softif_neigh;
+	rcu_assign_pointer(softif_neigh_vid->softif_neigh, new_neigh);
+
+	if ((curr_neigh) && (!new_neigh))
+		bat_dbg(DBG_ROUTES, bat_priv,
+			"Removing mesh exit point on vid: %d (prev: %pM).\n",
+			vid, curr_neigh->addr);
+	else if ((curr_neigh) && (new_neigh))
+		bat_dbg(DBG_ROUTES, bat_priv,
+			"Changing mesh exit point on vid: %d from %pM "
+			"to %pM.\n", vid, curr_neigh->addr, new_neigh->addr);
+	else if ((!curr_neigh) && (new_neigh))
+		bat_dbg(DBG_ROUTES, bat_priv,
+			"Setting mesh exit point on vid: %d to %pM.\n",
+			vid, new_neigh->addr);
+
+	if (curr_neigh)
+		softif_neigh_free_ref(curr_neigh);
+
+	spin_unlock_bh(&bat_priv->softif_neigh_lock);
+
+out:
+	if (softif_neigh_vid)
+		softif_neigh_vid_free_ref(softif_neigh_vid);
+}
+
+static void softif_neigh_vid_deselect(struct bat_priv *bat_priv,
+				      struct softif_neigh_vid *softif_neigh_vid)
+{
+	struct softif_neigh *curr_neigh;
+	struct softif_neigh *softif_neigh = NULL, *softif_neigh_tmp;
+	struct hard_iface *primary_if = NULL;
+	struct hlist_node *node;
+
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		goto out;
+
+	/* find new softif_neigh immediately to avoid temporary loops */
+	rcu_read_lock();
+	curr_neigh = rcu_dereference(softif_neigh_vid->softif_neigh);
+
+	hlist_for_each_entry_rcu(softif_neigh_tmp, node,
+				 &softif_neigh_vid->softif_neigh_list,
+				 list) {
+		if (softif_neigh_tmp == curr_neigh)
+			continue;
+
+		/* we got a neighbor but its mac is 'bigger' than ours  */
+		if (memcmp(primary_if->net_dev->dev_addr,
+			   softif_neigh_tmp->addr, ETH_ALEN) < 0)
+			continue;
+
+		if (!atomic_inc_not_zero(&softif_neigh_tmp->refcount))
+			continue;
+
+		softif_neigh = softif_neigh_tmp;
+		goto unlock;
+	}
+
+unlock:
+	rcu_read_unlock();
+out:
+	softif_neigh_vid_select(bat_priv, softif_neigh, softif_neigh_vid->vid);
+
+	if (primary_if)
+		hardif_free_ref(primary_if);
+	if (softif_neigh)
+		softif_neigh_free_ref(softif_neigh);
+}
+
 int softif_neigh_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct net_device *net_dev = (struct net_device *)seq->private;
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
+	struct softif_neigh_vid *softif_neigh_vid;
 	struct softif_neigh *softif_neigh;
 	struct hard_iface *primary_if;
-	struct hlist_node *node;
+	struct hlist_node *node, *node_tmp;
 	struct softif_neigh *curr_softif_neigh;
-	int ret = 0;
+	int ret = 0, last_seen_secs, last_seen_msecs;
 
 	primary_if = primary_if_get_selected(bat_priv);
 	if (!primary_if) {
@@ -237,17 +353,33 @@ int softif_neigh_seq_print_text(struct seq_file *seq, void *offset)
 
 	seq_printf(seq, "Softif neighbor list (%s)\n", net_dev->name);
 
-	curr_softif_neigh = softif_neigh_get_selected(bat_priv);
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(softif_neigh, node,
-				 &bat_priv->softif_neigh_list, list)
-		seq_printf(seq, "%s %pM (vid: %d)\n",
-				curr_softif_neigh == softif_neigh
-				? "=>" : "  ", softif_neigh->addr,
-				softif_neigh->vid);
+	hlist_for_each_entry_rcu(softif_neigh_vid, node,
+				 &bat_priv->softif_neigh_vids, list) {
+		seq_printf(seq, "     %-15s %s on vid: %d\n",
+			   "Originator", "last-seen", softif_neigh_vid->vid);
+
+		curr_softif_neigh = softif_neigh_get_selected(softif_neigh_vid);
+
+		hlist_for_each_entry_rcu(softif_neigh, node_tmp,
+					 &softif_neigh_vid->softif_neigh_list,
+					 list) {
+			last_seen_secs = jiffies_to_msecs(jiffies -
+						softif_neigh->last_seen) / 1000;
+			last_seen_msecs = jiffies_to_msecs(jiffies -
+						softif_neigh->last_seen) % 1000;
+			seq_printf(seq, "%s %pM  %3i.%03is\n",
+				   curr_softif_neigh == softif_neigh
+				   ? "=>" : "  ", softif_neigh->addr,
+				   last_seen_secs, last_seen_msecs);
+		}
+
+		if (curr_softif_neigh)
+			softif_neigh_free_ref(curr_softif_neigh);
+
+		seq_printf(seq, "\n");
+	}
 	rcu_read_unlock();
-	if (curr_softif_neigh)
-		softif_neigh_free_ref(curr_softif_neigh);
 
 out:
 	if (primary_if)
@@ -255,6 +387,70 @@ out:
 	return ret;
 }
 
+void softif_neigh_purge(struct bat_priv *bat_priv)
+{
+	struct softif_neigh *softif_neigh, *curr_softif_neigh;
+	struct softif_neigh_vid *softif_neigh_vid;
+	struct hlist_node *node, *node_tmp, *node_tmp2;
+	char do_deselect;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(softif_neigh_vid, node,
+				 &bat_priv->softif_neigh_vids, list) {
+		if (!atomic_inc_not_zero(&softif_neigh_vid->refcount))
+			continue;
+
+		curr_softif_neigh = softif_neigh_get_selected(softif_neigh_vid);
+		do_deselect = 0;
+
+		spin_lock_bh(&bat_priv->softif_neigh_lock);
+		hlist_for_each_entry_safe(softif_neigh, node_tmp, node_tmp2,
+					  &softif_neigh_vid->softif_neigh_list,
+					  list) {
+			if ((!time_after(jiffies, softif_neigh->last_seen +
+				msecs_to_jiffies(SOFTIF_NEIGH_TIMEOUT))) &&
+			    (atomic_read(&bat_priv->mesh_state) == MESH_ACTIVE))
+				continue;
+
+			if (curr_softif_neigh == softif_neigh) {
+				bat_dbg(DBG_ROUTES, bat_priv,
+					"Current mesh exit point on vid: %d "
+					"'%pM' vanished.\n",
+					softif_neigh_vid->vid,
+					softif_neigh->addr);
+				do_deselect = 1;
+			}
+
+			hlist_del_rcu(&softif_neigh->list);
+			softif_neigh_free_ref(softif_neigh);
+		}
+		spin_unlock_bh(&bat_priv->softif_neigh_lock);
+
+		/* soft_neigh_vid_deselect() needs to acquire the
+		 * softif_neigh_lock */
+		if (do_deselect)
+			softif_neigh_vid_deselect(bat_priv, softif_neigh_vid);
+
+		if (curr_softif_neigh)
+			softif_neigh_free_ref(curr_softif_neigh);
+
+		softif_neigh_vid_free_ref(softif_neigh_vid);
+	}
+	rcu_read_unlock();
+
+	spin_lock_bh(&bat_priv->softif_neigh_vid_lock);
+	hlist_for_each_entry_safe(softif_neigh_vid, node, node_tmp,
+				  &bat_priv->softif_neigh_vids, list) {
+		if (!hlist_empty(&softif_neigh_vid->softif_neigh_list))
+			continue;
+
+		hlist_del_rcu(&softif_neigh_vid->list);
+		softif_neigh_vid_free_ref(softif_neigh_vid);
+	}
+	spin_unlock_bh(&bat_priv->softif_neigh_vid_lock);
+
+}
+
 static void softif_batman_recv(struct sk_buff *skb, struct net_device *dev,
 			       short vid)
 {
@@ -287,10 +483,7 @@ static void softif_batman_recv(struct sk_buff *skb, struct net_device *dev,
 	if (!softif_neigh)
 		goto out;
 
-	curr_softif_neigh = softif_neigh_get_selected(bat_priv);
-	if (!curr_softif_neigh)
-		goto out;
-
+	curr_softif_neigh = softif_neigh_vid_get_selected(bat_priv, vid);
 	if (curr_softif_neigh == softif_neigh)
 		goto out;
 
@@ -303,33 +496,16 @@ static void softif_batman_recv(struct sk_buff *skb, struct net_device *dev,
 		   softif_neigh->addr, ETH_ALEN) < 0)
 		goto out;
 
-	/* switch to new 'smallest neighbor' */
-	if ((curr_softif_neigh) &&
-	    (memcmp(softif_neigh->addr, curr_softif_neigh->addr,
-							ETH_ALEN) < 0)) {
-		bat_dbg(DBG_ROUTES, bat_priv,
-			"Changing mesh exit point from %pM (vid: %d) "
-			"to %pM (vid: %d).\n",
-			 curr_softif_neigh->addr,
-			 curr_softif_neigh->vid,
-			 softif_neigh->addr, softif_neigh->vid);
-
-		softif_neigh_select(bat_priv, softif_neigh);
-		goto out;
-	}
-
 	/* close own batX device and use softif_neigh as exit node */
-	if ((!curr_softif_neigh) &&
-	    (memcmp(softif_neigh->addr,
-		    primary_if->net_dev->dev_addr, ETH_ALEN) < 0)) {
-		bat_dbg(DBG_ROUTES, bat_priv,
-			"Setting mesh exit point to %pM (vid: %d).\n",
-			softif_neigh->addr, softif_neigh->vid);
-
-		softif_neigh_select(bat_priv, softif_neigh);
+	if (!curr_softif_neigh) {
+		softif_neigh_vid_select(bat_priv, softif_neigh, vid);
 		goto out;
 	}
 
+	/* switch to new 'smallest neighbor' */
+	if (memcmp(softif_neigh->addr, curr_softif_neigh->addr, ETH_ALEN) < 0)
+		softif_neigh_vid_select(bat_priv, softif_neigh, vid);
+
 out:
 	kfree_skb(skb);
 	if (softif_neigh)
@@ -424,8 +600,8 @@ int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 	 * if we have a another chosen mesh exit node in range
 	 * it will transport the packets to the mesh
 	 */
-	curr_softif_neigh = softif_neigh_get_selected(bat_priv);
-	if ((curr_softif_neigh) && (curr_softif_neigh->vid == vid))
+	curr_softif_neigh = softif_neigh_vid_get_selected(bat_priv, vid);
+	if (curr_softif_neigh)
 		goto dropped;
 
 	/* TODO: check this for locks */
@@ -533,8 +709,8 @@ void interface_rx(struct net_device *soft_iface,
 	 * if we have a another chosen mesh exit node in range
 	 * it will transport the packets to the non-mesh network
 	 */
-	curr_softif_neigh = softif_neigh_get_selected(bat_priv);
-	if (curr_softif_neigh && (curr_softif_neigh->vid == vid)) {
+	curr_softif_neigh = softif_neigh_vid_get_selected(bat_priv, vid);
+	if (curr_softif_neigh) {
 		skb_push(skb, hdr_size);
 		unicast_packet = (struct unicast_packet *)skb->data;
 
@@ -671,7 +847,6 @@ struct net_device *softif_create(char *name)
 
 	bat_priv->primary_if = NULL;
 	bat_priv->num_ifaces = 0;
-	bat_priv->softif_neigh = NULL;
 
 	ret = sysfs_add_meshif(soft_iface);
 	if (ret < 0)
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 947bafc..9ae507a 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -146,14 +146,13 @@ struct bat_priv {
 	atomic_t bcast_queue_left;
 	atomic_t batman_queue_left;
 	char num_ifaces;
-	struct hlist_head softif_neigh_list;
-	struct softif_neigh __rcu *softif_neigh;
 	struct debug_log *debug_log;
 	struct kobject *mesh_obj;
 	struct dentry *debug_dir;
 	struct hlist_head forw_bat_list;
 	struct hlist_head forw_bcast_list;
 	struct hlist_head gw_list;
+	struct hlist_head softif_neigh_vids;
 	struct list_head vis_send_list;
 	struct hashtable_t *orig_hash;
 	struct hashtable_t *hna_local_hash;
@@ -167,6 +166,7 @@ struct bat_priv {
 	spinlock_t vis_hash_lock; /* protects vis_hash */
 	spinlock_t vis_list_lock; /* protects vis_info::recv_list */
 	spinlock_t softif_neigh_lock; /* protects soft-interface neigh list */
+	spinlock_t softif_neigh_vid_lock; /* protects soft-interface vid list */
 	int16_t num_local_hna;
 	atomic_t hna_local_changed;
 	struct delayed_work hna_work;
@@ -270,12 +270,21 @@ struct recvlist_node {
 	uint8_t mac[ETH_ALEN];
 };
 
-struct softif_neigh {
+struct softif_neigh_vid {
 	struct hlist_node list;
-	uint8_t addr[ETH_ALEN];
-	unsigned long last_seen;
+	struct bat_priv *bat_priv;
 	short vid;
 	atomic_t refcount;
+	struct softif_neigh __rcu *softif_neigh;
+	struct rcu_head rcu;
+	struct hlist_head softif_neigh_list;
+};
+
+struct softif_neigh {
+	struct hlist_node list;
+	uint8_t addr[ETH_ALEN];
+	unsigned long last_seen;
+	atomic_t refcount;
 	struct rcu_head rcu;
 };
 
-- 
1.7.5.1
