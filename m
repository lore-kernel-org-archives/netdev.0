From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 7/8] batman-adv: protect softif_neigh by rcu
Date: Sun, 17 Apr 2011 21:30:17 +0200
Message-ID: <1303068618-27928-8-git-send-email-sven@narfation.org>
References: <1303068618-27928-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>,
	Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
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

From: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>

Add get/set wrapper functions for softif_neigh and
use rcu functions to manipulate the pointers.

Signed-off-by: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/soft-interface.c |  114 +++++++++++++++++++++++++++++---------
 net/batman-adv/types.h          |    2 +-
 2 files changed, 88 insertions(+), 28 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 824e1f6..a60fd48 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -90,10 +90,51 @@ static void softif_neigh_free_ref(struct softif_neigh *softif_neigh)
 		call_rcu(&softif_neigh->rcu, softif_neigh_free_rcu);
 }
 
+static struct softif_neigh *softif_neigh_get_selected(struct bat_priv *bat_priv)
+{
+	struct softif_neigh *neigh;
+
+	rcu_read_lock();
+	neigh = rcu_dereference(bat_priv->softif_neigh);
+
+	if (neigh && !atomic_inc_not_zero(&neigh->refcount))
+		neigh = NULL;
+
+	rcu_read_unlock();
+	return neigh;
+}
+
+static void softif_neigh_select(struct bat_priv *bat_priv,
+				struct softif_neigh *new_neigh)
+{
+	struct softif_neigh *curr_neigh;
+
+	spin_lock_bh(&bat_priv->softif_neigh_lock);
+
+	if (new_neigh && !atomic_inc_not_zero(&new_neigh->refcount))
+		new_neigh = NULL;
+
+	curr_neigh = bat_priv->softif_neigh;
+	rcu_assign_pointer(bat_priv->softif_neigh, new_neigh);
+
+	if (curr_neigh)
+		softif_neigh_free_ref(curr_neigh);
+
+	spin_unlock_bh(&bat_priv->softif_neigh_lock);
+}
+
+static void softif_neigh_deselect(struct bat_priv *bat_priv)
+{
+	softif_neigh_select(bat_priv, NULL);
+}
+
 void softif_neigh_purge(struct bat_priv *bat_priv)
 {
-	struct softif_neigh *softif_neigh, *softif_neigh_tmp;
+	struct softif_neigh *softif_neigh, *curr_softif_neigh;
 	struct hlist_node *node, *node_tmp;
+	char do_deselect = 0;
+
+	curr_softif_neigh = softif_neigh_get_selected(bat_priv);
 
 	spin_lock_bh(&bat_priv->softif_neigh_lock);
 
@@ -105,22 +146,26 @@ void softif_neigh_purge(struct bat_priv *bat_priv)
 		    (atomic_read(&bat_priv->mesh_state) == MESH_ACTIVE))
 			continue;
 
-		hlist_del_rcu(&softif_neigh->list);
-
-		if (bat_priv->softif_neigh == softif_neigh) {
+		if (curr_softif_neigh == softif_neigh) {
 			bat_dbg(DBG_ROUTES, bat_priv,
 				 "Current mesh exit point '%pM' vanished "
 				 "(vid: %d).\n",
 				 softif_neigh->addr, softif_neigh->vid);
-			softif_neigh_tmp = bat_priv->softif_neigh;
-			bat_priv->softif_neigh = NULL;
-			softif_neigh_free_ref(softif_neigh_tmp);
+			do_deselect = 1;
 		}
 
+		hlist_del_rcu(&softif_neigh->list);
 		softif_neigh_free_ref(softif_neigh);
 	}
 
 	spin_unlock_bh(&bat_priv->softif_neigh_lock);
+
+	/* soft_neigh_deselect() needs to acquire the softif_neigh_lock */
+	if (do_deselect)
+		softif_neigh_deselect(bat_priv);
+
+	if (curr_softif_neigh)
+		softif_neigh_free_ref(curr_softif_neigh);
 }
 
 static struct softif_neigh *softif_neigh_get(struct bat_priv *bat_priv,
@@ -171,6 +216,7 @@ int softif_neigh_seq_print_text(struct seq_file *seq, void *offset)
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
 	struct softif_neigh *softif_neigh;
 	struct hlist_node *node;
+	struct softif_neigh *curr_softif_neigh;
 
 	if (!bat_priv->primary_if) {
 		return seq_printf(seq, "BATMAN mesh %s disabled - "
@@ -180,14 +226,17 @@ int softif_neigh_seq_print_text(struct seq_file *seq, void *offset)
 
 	seq_printf(seq, "Softif neighbor list (%s)\n", net_dev->name);
 
+	curr_softif_neigh = softif_neigh_get_selected(bat_priv);
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(softif_neigh, node,
 				 &bat_priv->softif_neigh_list, list)
 		seq_printf(seq, "%s %pM (vid: %d)\n",
-				bat_priv->softif_neigh == softif_neigh
+				curr_softif_neigh == softif_neigh
 				? "=>" : "  ", softif_neigh->addr,
 				softif_neigh->vid);
 	rcu_read_unlock();
+	if (curr_softif_neigh)
+		softif_neigh_free_ref(curr_softif_neigh);
 
 	return 0;
 }
@@ -198,7 +247,8 @@ static void softif_batman_recv(struct sk_buff *skb, struct net_device *dev,
 	struct bat_priv *bat_priv = netdev_priv(dev);
 	struct ethhdr *ethhdr = (struct ethhdr *)skb->data;
 	struct batman_packet *batman_packet;
-	struct softif_neigh *softif_neigh, *softif_neigh_tmp;
+	struct softif_neigh *softif_neigh;
+	struct softif_neigh *curr_softif_neigh = NULL;
 
 	if (ntohs(ethhdr->h_proto) == ETH_P_8021Q)
 		batman_packet = (struct batman_packet *)
@@ -223,7 +273,8 @@ static void softif_batman_recv(struct sk_buff *skb, struct net_device *dev,
 	if (!softif_neigh)
 		goto err;
 
-	if (bat_priv->softif_neigh == softif_neigh)
+	curr_softif_neigh = softif_neigh_get_selected(bat_priv);
+	if (curr_softif_neigh == softif_neigh)
 		goto out;
 
 	/* we got a neighbor but its mac is 'bigger' than ours  */
@@ -232,38 +283,39 @@ static void softif_batman_recv(struct sk_buff *skb, struct net_device *dev,
 		goto out;
 
 	/* switch to new 'smallest neighbor' */
-	if ((bat_priv->softif_neigh) &&
-	    (memcmp(softif_neigh->addr, bat_priv->softif_neigh->addr,
+	if ((curr_softif_neigh) &&
+	    (memcmp(softif_neigh->addr, curr_softif_neigh->addr,
 							ETH_ALEN) < 0)) {
 		bat_dbg(DBG_ROUTES, bat_priv,
 			"Changing mesh exit point from %pM (vid: %d) "
 			"to %pM (vid: %d).\n",
-			 bat_priv->softif_neigh->addr,
-			 bat_priv->softif_neigh->vid,
+			 curr_softif_neigh->addr,
+			 curr_softif_neigh->vid,
 			 softif_neigh->addr, softif_neigh->vid);
-		softif_neigh_tmp = bat_priv->softif_neigh;
-		bat_priv->softif_neigh = softif_neigh;
-		softif_neigh_free_ref(softif_neigh_tmp);
-		/* we need to hold the additional reference */
-		goto err;
+
+		softif_neigh_select(bat_priv, softif_neigh);
+		goto out;
 	}
 
 	/* close own batX device and use softif_neigh as exit node */
-	if ((!bat_priv->softif_neigh) &&
+	if ((!curr_softif_neigh) &&
 	    (memcmp(softif_neigh->addr,
 		    bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN) < 0)) {
 		bat_dbg(DBG_ROUTES, bat_priv,
 			"Setting mesh exit point to %pM (vid: %d).\n",
 			softif_neigh->addr, softif_neigh->vid);
-		bat_priv->softif_neigh = softif_neigh;
-		/* we need to hold the additional reference */
-		goto err;
+
+		softif_neigh_select(bat_priv, softif_neigh);
+		goto out;
 	}
 
 out:
 	softif_neigh_free_ref(softif_neigh);
 err:
 	kfree_skb(skb);
+	if (curr_softif_neigh)
+		softif_neigh_free_ref(curr_softif_neigh);
+
 	return;
 }
 
@@ -321,6 +373,7 @@ int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
 	struct bcast_packet *bcast_packet;
 	struct vlan_ethhdr *vhdr;
+	struct softif_neigh *curr_softif_neigh = NULL;
 	int data_len = skb->len, ret;
 	short vid = -1;
 	bool do_bcast = false;
@@ -348,7 +401,8 @@ int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 	 * if we have a another chosen mesh exit node in range
 	 * it will transport the packets to the mesh
 	 */
-	if ((bat_priv->softif_neigh) && (bat_priv->softif_neigh->vid == vid))
+	curr_softif_neigh = softif_neigh_get_selected(bat_priv);
+	if ((curr_softif_neigh) && (curr_softif_neigh->vid == vid))
 		goto dropped;
 
 	/* TODO: check this for locks */
@@ -410,6 +464,8 @@ dropped:
 dropped_freed:
 	bat_priv->stats.tx_dropped++;
 end:
+	if (curr_softif_neigh)
+		softif_neigh_free_ref(curr_softif_neigh);
 	return NETDEV_TX_OK;
 }
 
@@ -421,6 +477,7 @@ void interface_rx(struct net_device *soft_iface,
 	struct unicast_packet *unicast_packet;
 	struct ethhdr *ethhdr;
 	struct vlan_ethhdr *vhdr;
+	struct softif_neigh *curr_softif_neigh = NULL;
 	short vid = -1;
 	int ret;
 
@@ -450,7 +507,8 @@ void interface_rx(struct net_device *soft_iface,
 	 * if we have a another chosen mesh exit node in range
 	 * it will transport the packets to the non-mesh network
 	 */
-	if ((bat_priv->softif_neigh) && (bat_priv->softif_neigh->vid == vid)) {
+	curr_softif_neigh = softif_neigh_get_selected(bat_priv);
+	if (curr_softif_neigh && (curr_softif_neigh->vid == vid)) {
 		skb_push(skb, hdr_size);
 		unicast_packet = (struct unicast_packet *)skb->data;
 
@@ -461,7 +519,7 @@ void interface_rx(struct net_device *soft_iface,
 		skb_reset_mac_header(skb);
 
 		memcpy(unicast_packet->dest,
-		       bat_priv->softif_neigh->addr, ETH_ALEN);
+		       curr_softif_neigh->addr, ETH_ALEN);
 		ret = route_unicast_packet(skb, recv_if);
 		if (ret == NET_RX_DROP)
 			goto dropped;
@@ -486,11 +544,13 @@ void interface_rx(struct net_device *soft_iface,
 	soft_iface->last_rx = jiffies;
 
 	netif_rx(skb);
-	return;
+	goto out;
 
 dropped:
 	kfree_skb(skb);
 out:
+	if (curr_softif_neigh)
+		softif_neigh_free_ref(curr_softif_neigh);
 	return;
 }
 
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 091476d..75123b1 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -147,7 +147,7 @@ struct bat_priv {
 	atomic_t batman_queue_left;
 	char num_ifaces;
 	struct hlist_head softif_neigh_list;
-	struct softif_neigh *softif_neigh;
+	struct softif_neigh __rcu *softif_neigh;
 	struct debug_log *debug_log;
 	struct hard_iface *primary_if;
 	struct kobject *mesh_obj;
-- 
1.7.4.4
