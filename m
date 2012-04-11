From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 07/16] batman-adv: remove old bridge loop
	avoidance code
Date: Wed, 11 Apr 2012 14:50:40 +0200
Message-ID: <1334148649-25443-8-git-send-email-ordex@autistici.org>
References: <1334148649-25443-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1334148649-25443-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
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

From: Simon Wunderlich <simon.wunderlich-Y4E02TeZ33kaBlGTGt4zH4SGEyLTKazZ@public.gmane.org>

The functionality is to be replaced by an improved implementation,
so first clean up.

Signed-off-by: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/bat_debugfs.c    |    8 -
 net/batman-adv/main.c           |    5 -
 net/batman-adv/main.h           |    2 -
 net/batman-adv/originator.c     |    2 -
 net/batman-adv/routing.c        |    5 +-
 net/batman-adv/routing.h        |    1 -
 net/batman-adv/soft-interface.c |  476 +--------------------------------------
 net/batman-adv/soft-interface.h |    2 -
 net/batman-adv/types.h          |   21 --
 9 files changed, 5 insertions(+), 517 deletions(-)

diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
index c3b0548..165ff62 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -238,12 +238,6 @@ static int gateways_open(struct inode *inode, struct file *file)
 	return single_open(file, gw_client_seq_print_text, net_dev);
 }
 
-static int softif_neigh_open(struct inode *inode, struct file *file)
-{
-	struct net_device *net_dev = (struct net_device *)inode->i_private;
-	return single_open(file, softif_neigh_seq_print_text, net_dev);
-}
-
 static int transtable_global_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
@@ -282,7 +276,6 @@ struct bat_debuginfo bat_debuginfo_##_name = {	\
 static BAT_DEBUGINFO(routing_algos, S_IRUGO, bat_algorithms_open);
 static BAT_DEBUGINFO(originators, S_IRUGO, originators_open);
 static BAT_DEBUGINFO(gateways, S_IRUGO, gateways_open);
-static BAT_DEBUGINFO(softif_neigh, S_IRUGO, softif_neigh_open);
 static BAT_DEBUGINFO(transtable_global, S_IRUGO, transtable_global_open);
 static BAT_DEBUGINFO(transtable_local, S_IRUGO, transtable_local_open);
 static BAT_DEBUGINFO(vis_data, S_IRUGO, vis_data_open);
@@ -290,7 +283,6 @@ static BAT_DEBUGINFO(vis_data, S_IRUGO, vis_data_open);
 static struct bat_debuginfo *mesh_debuginfos[] = {
 	&bat_debuginfo_originators,
 	&bat_debuginfo_gateways,
-	&bat_debuginfo_softif_neigh,
 	&bat_debuginfo_transtable_global,
 	&bat_debuginfo_transtable_local,
 	&bat_debuginfo_vis_data,
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 6d51caa..94d4968 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -96,13 +96,10 @@ int mesh_init(struct net_device *soft_iface)
 	spin_lock_init(&bat_priv->gw_list_lock);
 	spin_lock_init(&bat_priv->vis_hash_lock);
 	spin_lock_init(&bat_priv->vis_list_lock);
-	spin_lock_init(&bat_priv->softif_neigh_lock);
-	spin_lock_init(&bat_priv->softif_neigh_vid_lock);
 
 	INIT_HLIST_HEAD(&bat_priv->forw_bat_list);
 	INIT_HLIST_HEAD(&bat_priv->forw_bcast_list);
 	INIT_HLIST_HEAD(&bat_priv->gw_list);
-	INIT_HLIST_HEAD(&bat_priv->softif_neigh_vids);
 	INIT_LIST_HEAD(&bat_priv->tt_changes_list);
 	INIT_LIST_HEAD(&bat_priv->tt_req_list);
 	INIT_LIST_HEAD(&bat_priv->tt_roam_list);
@@ -145,8 +142,6 @@ void mesh_free(struct net_device *soft_iface)
 
 	tt_free(bat_priv);
 
-	softif_neigh_purge(bat_priv);
-
 	atomic_set(&bat_priv->mesh_state, MESH_INACTIVE);
 }
 
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 0a20a19..7a6a25f 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -80,8 +80,6 @@
 #define MAX_AGGREGATION_BYTES 512
 #define MAX_AGGREGATION_MS 100
 
-#define SOFTIF_NEIGH_TIMEOUT 180000 /* 3 minutes */
-
 /* don't reset again within 30 seconds */
 #define RESET_PROTECTION_MS 30000
 #define EXPECTED_SEQNO_RANGE	65536
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 43c0a4f..8239081 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -375,8 +375,6 @@ static void _purge_orig(struct bat_priv *bat_priv)
 
 	gw_node_purge(bat_priv);
 	gw_election(bat_priv);
-
-	softif_neigh_purge(bat_priv);
 }
 
 static void purge_orig(struct work_struct *work)
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index b0370e3..71d4211 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -30,6 +30,9 @@
 #include "vis.h"
 #include "unicast.h"
 
+static int route_unicast_packet(struct sk_buff *skb,
+				struct hard_iface *recv_if);
+
 void slide_own_bcast_window(struct hard_iface *hard_iface)
 {
 	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
@@ -798,7 +801,7 @@ static int check_unicast_packet(struct sk_buff *skb, int hdr_size)
 	return 0;
 }
 
-int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
+static int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 {
 	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct orig_node *orig_node = NULL;
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 92ac100..3d729cb 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -25,7 +25,6 @@
 void slide_own_bcast_window(struct hard_iface *hard_iface);
 void update_route(struct bat_priv *bat_priv, struct orig_node *orig_node,
 		  struct neigh_node *neigh_node);
-int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_ucast_frag_packet(struct sk_buff *skb, struct hard_iface *recv_if);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 82c097d..e56cb88 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -73,439 +73,6 @@ int my_skb_head_push(struct sk_buff *skb, unsigned int len)
 	return 0;
 }
 
-static void softif_neigh_free_ref(struct softif_neigh *softif_neigh)
-{
-	if (atomic_dec_and_test(&softif_neigh->refcount))
-		kfree_rcu(softif_neigh, rcu);
-}
-
-static void softif_neigh_vid_free_rcu(struct rcu_head *rcu)
-{
-	struct softif_neigh_vid *softif_neigh_vid;
-	struct softif_neigh *softif_neigh;
-	struct hlist_node *node, *node_tmp;
-	struct bat_priv *bat_priv;
-
-	softif_neigh_vid = container_of(rcu, struct softif_neigh_vid, rcu);
-	bat_priv = softif_neigh_vid->bat_priv;
-
-	spin_lock_bh(&bat_priv->softif_neigh_lock);
-	hlist_for_each_entry_safe(softif_neigh, node, node_tmp,
-				  &softif_neigh_vid->softif_neigh_list, list) {
-		hlist_del_rcu(&softif_neigh->list);
-		softif_neigh_free_ref(softif_neigh);
-	}
-	spin_unlock_bh(&bat_priv->softif_neigh_lock);
-
-	kfree(softif_neigh_vid);
-}
-
-static void softif_neigh_vid_free_ref(struct softif_neigh_vid *softif_neigh_vid)
-{
-	if (atomic_dec_and_test(&softif_neigh_vid->refcount))
-		call_rcu(&softif_neigh_vid->rcu, softif_neigh_vid_free_rcu);
-}
-
-static struct softif_neigh_vid *softif_neigh_vid_get(struct bat_priv *bat_priv,
-						     short vid)
-{
-	struct softif_neigh_vid *softif_neigh_vid;
-	struct hlist_node *node;
-
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(softif_neigh_vid, node,
-				 &bat_priv->softif_neigh_vids, list) {
-		if (softif_neigh_vid->vid != vid)
-			continue;
-
-		if (!atomic_inc_not_zero(&softif_neigh_vid->refcount))
-			continue;
-
-		goto out;
-	}
-
-	softif_neigh_vid = kzalloc(sizeof(*softif_neigh_vid), GFP_ATOMIC);
-	if (!softif_neigh_vid)
-		goto out;
-
-	softif_neigh_vid->vid = vid;
-	softif_neigh_vid->bat_priv = bat_priv;
-
-	/* initialize with 2 - caller decrements counter by one */
-	atomic_set(&softif_neigh_vid->refcount, 2);
-	INIT_HLIST_HEAD(&softif_neigh_vid->softif_neigh_list);
-	INIT_HLIST_NODE(&softif_neigh_vid->list);
-	spin_lock_bh(&bat_priv->softif_neigh_vid_lock);
-	hlist_add_head_rcu(&softif_neigh_vid->list,
-			   &bat_priv->softif_neigh_vids);
-	spin_unlock_bh(&bat_priv->softif_neigh_vid_lock);
-
-out:
-	rcu_read_unlock();
-	return softif_neigh_vid;
-}
-
-static struct softif_neigh *softif_neigh_get(struct bat_priv *bat_priv,
-					     const uint8_t *addr, short vid)
-{
-	struct softif_neigh_vid *softif_neigh_vid;
-	struct softif_neigh *softif_neigh = NULL;
-	struct hlist_node *node;
-
-	softif_neigh_vid = softif_neigh_vid_get(bat_priv, vid);
-	if (!softif_neigh_vid)
-		goto out;
-
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(softif_neigh, node,
-				 &softif_neigh_vid->softif_neigh_list,
-				 list) {
-		if (!compare_eth(softif_neigh->addr, addr))
-			continue;
-
-		if (!atomic_inc_not_zero(&softif_neigh->refcount))
-			continue;
-
-		softif_neigh->last_seen = jiffies;
-		goto unlock;
-	}
-
-	softif_neigh = kzalloc(sizeof(*softif_neigh), GFP_ATOMIC);
-	if (!softif_neigh)
-		goto unlock;
-
-	memcpy(softif_neigh->addr, addr, ETH_ALEN);
-	softif_neigh->last_seen = jiffies;
-	/* initialize with 2 - caller decrements counter by one */
-	atomic_set(&softif_neigh->refcount, 2);
-
-	INIT_HLIST_NODE(&softif_neigh->list);
-	spin_lock_bh(&bat_priv->softif_neigh_lock);
-	hlist_add_head_rcu(&softif_neigh->list,
-			   &softif_neigh_vid->softif_neigh_list);
-	spin_unlock_bh(&bat_priv->softif_neigh_lock);
-
-unlock:
-	rcu_read_unlock();
-out:
-	if (softif_neigh_vid)
-		softif_neigh_vid_free_ref(softif_neigh_vid);
-	return softif_neigh;
-}
-
-static struct softif_neigh *softif_neigh_get_selected(
-				struct softif_neigh_vid *softif_neigh_vid)
-{
-	struct softif_neigh *softif_neigh;
-
-	rcu_read_lock();
-	softif_neigh = rcu_dereference(softif_neigh_vid->softif_neigh);
-
-	if (softif_neigh && !atomic_inc_not_zero(&softif_neigh->refcount))
-		softif_neigh = NULL;
-
-	rcu_read_unlock();
-	return softif_neigh;
-}
-
-static struct softif_neigh *softif_neigh_vid_get_selected(
-						struct bat_priv *bat_priv,
-						short vid)
-{
-	struct softif_neigh_vid *softif_neigh_vid;
-	struct softif_neigh *softif_neigh = NULL;
-
-	softif_neigh_vid = softif_neigh_vid_get(bat_priv, vid);
-	if (!softif_neigh_vid)
-		goto out;
-
-	softif_neigh = softif_neigh_get_selected(softif_neigh_vid);
-out:
-	if (softif_neigh_vid)
-		softif_neigh_vid_free_ref(softif_neigh_vid);
-	return softif_neigh;
-}
-
-static void softif_neigh_vid_select(struct bat_priv *bat_priv,
-				    struct softif_neigh *new_neigh,
-				    short vid)
-{
-	struct softif_neigh_vid *softif_neigh_vid;
-	struct softif_neigh *curr_neigh;
-
-	softif_neigh_vid = softif_neigh_vid_get(bat_priv, vid);
-	if (!softif_neigh_vid)
-		goto out;
-
-	spin_lock_bh(&bat_priv->softif_neigh_lock);
-
-	if (new_neigh && !atomic_inc_not_zero(&new_neigh->refcount))
-		new_neigh = NULL;
-
-	curr_neigh = rcu_dereference_protected(softif_neigh_vid->softif_neigh,
-					       1);
-	rcu_assign_pointer(softif_neigh_vid->softif_neigh, new_neigh);
-
-	if ((curr_neigh) && (!new_neigh))
-		bat_dbg(DBG_ROUTES, bat_priv,
-			"Removing mesh exit point on vid: %d (prev: %pM).\n",
-			vid, curr_neigh->addr);
-	else if ((curr_neigh) && (new_neigh))
-		bat_dbg(DBG_ROUTES, bat_priv,
-			"Changing mesh exit point on vid: %d from %pM to %pM.\n",
-			vid, curr_neigh->addr, new_neigh->addr);
-	else if ((!curr_neigh) && (new_neigh))
-		bat_dbg(DBG_ROUTES, bat_priv,
-			"Setting mesh exit point on vid: %d to %pM.\n",
-			vid, new_neigh->addr);
-
-	if (curr_neigh)
-		softif_neigh_free_ref(curr_neigh);
-
-	spin_unlock_bh(&bat_priv->softif_neigh_lock);
-
-out:
-	if (softif_neigh_vid)
-		softif_neigh_vid_free_ref(softif_neigh_vid);
-}
-
-static void softif_neigh_vid_deselect(struct bat_priv *bat_priv,
-				      struct softif_neigh_vid *softif_neigh_vid)
-{
-	struct softif_neigh *curr_neigh;
-	struct softif_neigh *softif_neigh = NULL, *softif_neigh_tmp;
-	struct hard_iface *primary_if = NULL;
-	struct hlist_node *node;
-
-	primary_if = primary_if_get_selected(bat_priv);
-	if (!primary_if)
-		goto out;
-
-	/* find new softif_neigh immediately to avoid temporary loops */
-	rcu_read_lock();
-	curr_neigh = rcu_dereference(softif_neigh_vid->softif_neigh);
-
-	hlist_for_each_entry_rcu(softif_neigh_tmp, node,
-				 &softif_neigh_vid->softif_neigh_list,
-				 list) {
-		if (softif_neigh_tmp == curr_neigh)
-			continue;
-
-		/* we got a neighbor but its mac is 'bigger' than ours  */
-		if (memcmp(primary_if->net_dev->dev_addr,
-			   softif_neigh_tmp->addr, ETH_ALEN) < 0)
-			continue;
-
-		if (!atomic_inc_not_zero(&softif_neigh_tmp->refcount))
-			continue;
-
-		softif_neigh = softif_neigh_tmp;
-		goto unlock;
-	}
-
-unlock:
-	rcu_read_unlock();
-out:
-	softif_neigh_vid_select(bat_priv, softif_neigh, softif_neigh_vid->vid);
-
-	if (primary_if)
-		hardif_free_ref(primary_if);
-	if (softif_neigh)
-		softif_neigh_free_ref(softif_neigh);
-}
-
-int softif_neigh_seq_print_text(struct seq_file *seq, void *offset)
-{
-	struct net_device *net_dev = (struct net_device *)seq->private;
-	struct bat_priv *bat_priv = netdev_priv(net_dev);
-	struct softif_neigh_vid *softif_neigh_vid;
-	struct softif_neigh *softif_neigh;
-	struct hard_iface *primary_if;
-	struct hlist_node *node, *node_tmp;
-	struct softif_neigh *curr_softif_neigh;
-	int ret = 0, last_seen_secs, last_seen_msecs;
-
-	primary_if = primary_if_get_selected(bat_priv);
-	if (!primary_if) {
-		ret = seq_printf(seq,
-				 "BATMAN mesh %s disabled - please specify interfaces to enable it\n",
-				 net_dev->name);
-		goto out;
-	}
-
-	if (primary_if->if_status != IF_ACTIVE) {
-		ret = seq_printf(seq,
-				 "BATMAN mesh %s disabled - primary interface not active\n",
-				 net_dev->name);
-		goto out;
-	}
-
-	seq_printf(seq, "Softif neighbor list (%s)\n", net_dev->name);
-
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(softif_neigh_vid, node,
-				 &bat_priv->softif_neigh_vids, list) {
-		seq_printf(seq, "     %-15s %s on vid: %d\n",
-			   "Originator", "last-seen", softif_neigh_vid->vid);
-
-		curr_softif_neigh = softif_neigh_get_selected(softif_neigh_vid);
-
-		hlist_for_each_entry_rcu(softif_neigh, node_tmp,
-					 &softif_neigh_vid->softif_neigh_list,
-					 list) {
-			last_seen_secs = jiffies_to_msecs(jiffies -
-						softif_neigh->last_seen) / 1000;
-			last_seen_msecs = jiffies_to_msecs(jiffies -
-						softif_neigh->last_seen) % 1000;
-			seq_printf(seq, "%s %pM  %3i.%03is\n",
-				   curr_softif_neigh == softif_neigh
-				   ? "=>" : "  ", softif_neigh->addr,
-				   last_seen_secs, last_seen_msecs);
-		}
-
-		if (curr_softif_neigh)
-			softif_neigh_free_ref(curr_softif_neigh);
-
-		seq_printf(seq, "\n");
-	}
-	rcu_read_unlock();
-
-out:
-	if (primary_if)
-		hardif_free_ref(primary_if);
-	return ret;
-}
-
-void softif_neigh_purge(struct bat_priv *bat_priv)
-{
-	struct softif_neigh *softif_neigh, *curr_softif_neigh;
-	struct softif_neigh_vid *softif_neigh_vid;
-	struct hlist_node *node, *node_tmp, *node_tmp2;
-	int do_deselect;
-
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(softif_neigh_vid, node,
-				 &bat_priv->softif_neigh_vids, list) {
-		if (!atomic_inc_not_zero(&softif_neigh_vid->refcount))
-			continue;
-
-		curr_softif_neigh = softif_neigh_get_selected(softif_neigh_vid);
-		do_deselect = 0;
-
-		spin_lock_bh(&bat_priv->softif_neigh_lock);
-		hlist_for_each_entry_safe(softif_neigh, node_tmp, node_tmp2,
-					  &softif_neigh_vid->softif_neigh_list,
-					  list) {
-			if ((!has_timed_out(softif_neigh->last_seen,
-					    SOFTIF_NEIGH_TIMEOUT)) &&
-			    (atomic_read(&bat_priv->mesh_state) == MESH_ACTIVE))
-				continue;
-
-			if (curr_softif_neigh == softif_neigh) {
-				bat_dbg(DBG_ROUTES, bat_priv,
-					"Current mesh exit point on vid: %d '%pM' vanished.\n",
-					softif_neigh_vid->vid,
-					softif_neigh->addr);
-				do_deselect = 1;
-			}
-
-			hlist_del_rcu(&softif_neigh->list);
-			softif_neigh_free_ref(softif_neigh);
-		}
-		spin_unlock_bh(&bat_priv->softif_neigh_lock);
-
-		/* soft_neigh_vid_deselect() needs to acquire the
-		 * softif_neigh_lock */
-		if (do_deselect)
-			softif_neigh_vid_deselect(bat_priv, softif_neigh_vid);
-
-		if (curr_softif_neigh)
-			softif_neigh_free_ref(curr_softif_neigh);
-
-		softif_neigh_vid_free_ref(softif_neigh_vid);
-	}
-	rcu_read_unlock();
-
-	spin_lock_bh(&bat_priv->softif_neigh_vid_lock);
-	hlist_for_each_entry_safe(softif_neigh_vid, node, node_tmp,
-				  &bat_priv->softif_neigh_vids, list) {
-		if (!hlist_empty(&softif_neigh_vid->softif_neigh_list))
-			continue;
-
-		hlist_del_rcu(&softif_neigh_vid->list);
-		softif_neigh_vid_free_ref(softif_neigh_vid);
-	}
-	spin_unlock_bh(&bat_priv->softif_neigh_vid_lock);
-
-}
-
-static void softif_batman_recv(struct sk_buff *skb, struct net_device *dev,
-			       short vid)
-{
-	struct bat_priv *bat_priv = netdev_priv(dev);
-	struct ethhdr *ethhdr = (struct ethhdr *)skb->data;
-	struct batman_ogm_packet *batman_ogm_packet;
-	struct softif_neigh *softif_neigh = NULL;
-	struct hard_iface *primary_if = NULL;
-	struct softif_neigh *curr_softif_neigh = NULL;
-
-	if (ntohs(ethhdr->h_proto) == ETH_P_8021Q)
-		batman_ogm_packet = (struct batman_ogm_packet *)
-					(skb->data + ETH_HLEN + VLAN_HLEN);
-	else
-		batman_ogm_packet = (struct batman_ogm_packet *)
-							(skb->data + ETH_HLEN);
-
-	if (batman_ogm_packet->header.version != COMPAT_VERSION)
-		goto out;
-
-	if (batman_ogm_packet->header.packet_type != BAT_OGM)
-		goto out;
-
-	if (!(batman_ogm_packet->flags & PRIMARIES_FIRST_HOP))
-		goto out;
-
-	if (is_my_mac(batman_ogm_packet->orig))
-		goto out;
-
-	softif_neigh = softif_neigh_get(bat_priv, batman_ogm_packet->orig, vid);
-	if (!softif_neigh)
-		goto out;
-
-	curr_softif_neigh = softif_neigh_vid_get_selected(bat_priv, vid);
-	if (curr_softif_neigh == softif_neigh)
-		goto out;
-
-	primary_if = primary_if_get_selected(bat_priv);
-	if (!primary_if)
-		goto out;
-
-	/* we got a neighbor but its mac is 'bigger' than ours  */
-	if (memcmp(primary_if->net_dev->dev_addr,
-		   softif_neigh->addr, ETH_ALEN) < 0)
-		goto out;
-
-	/* close own batX device and use softif_neigh as exit node */
-	if (!curr_softif_neigh) {
-		softif_neigh_vid_select(bat_priv, softif_neigh, vid);
-		goto out;
-	}
-
-	/* switch to new 'smallest neighbor' */
-	if (memcmp(softif_neigh->addr, curr_softif_neigh->addr, ETH_ALEN) < 0)
-		softif_neigh_vid_select(bat_priv, softif_neigh, vid);
-
-out:
-	kfree_skb(skb);
-	if (softif_neigh)
-		softif_neigh_free_ref(softif_neigh);
-	if (curr_softif_neigh)
-		softif_neigh_free_ref(curr_softif_neigh);
-	if (primary_if)
-		hardif_free_ref(primary_if);
-	return;
-}
-
 static int interface_open(struct net_device *dev)
 {
 	netif_start_queue(dev);
@@ -562,7 +129,6 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 	struct hard_iface *primary_if = NULL;
 	struct bcast_packet *bcast_packet;
 	struct vlan_ethhdr *vhdr;
-	struct softif_neigh *curr_softif_neigh = NULL;
 	unsigned int header_len = 0;
 	int data_len = skb->len, ret;
 	short vid = -1;
@@ -583,17 +149,8 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 
 		/* fall through */
 	case ETH_P_BATMAN:
-		softif_batman_recv(skb, soft_iface, vid);
-		goto end;
-	}
-
-	/**
-	 * if we have a another chosen mesh exit node in range
-	 * it will transport the packets to the mesh
-	 */
-	curr_softif_neigh = softif_neigh_vid_get_selected(bat_priv, vid);
-	if (curr_softif_neigh)
 		goto dropped;
+	}
 
 	/* Register the client MAC in the transtable */
 	tt_local_add(soft_iface, ethhdr->h_source, skb->skb_iif);
@@ -675,8 +232,6 @@ dropped:
 dropped_freed:
 	bat_priv->stats.tx_dropped++;
 end:
-	if (curr_softif_neigh)
-		softif_neigh_free_ref(curr_softif_neigh);
 	if (primary_if)
 		hardif_free_ref(primary_if);
 	return NETDEV_TX_OK;
@@ -687,12 +242,9 @@ void interface_rx(struct net_device *soft_iface,
 		  int hdr_size)
 {
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
-	struct unicast_packet *unicast_packet;
 	struct ethhdr *ethhdr;
 	struct vlan_ethhdr *vhdr;
-	struct softif_neigh *curr_softif_neigh = NULL;
 	short vid = -1;
-	int ret;
 
 	/* check if enough space is available for pulling, and pull */
 	if (!pskb_may_pull(skb, hdr_size))
@@ -716,30 +268,6 @@ void interface_rx(struct net_device *soft_iface,
 		goto dropped;
 	}
 
-	/**
-	 * if we have a another chosen mesh exit node in range
-	 * it will transport the packets to the non-mesh network
-	 */
-	curr_softif_neigh = softif_neigh_vid_get_selected(bat_priv, vid);
-	if (curr_softif_neigh) {
-		skb_push(skb, hdr_size);
-		unicast_packet = (struct unicast_packet *)skb->data;
-
-		if ((unicast_packet->header.packet_type != BAT_UNICAST) &&
-		    (unicast_packet->header.packet_type != BAT_UNICAST_FRAG))
-			goto dropped;
-
-		skb_reset_mac_header(skb);
-
-		memcpy(unicast_packet->dest,
-		       curr_softif_neigh->addr, ETH_ALEN);
-		ret = route_unicast_packet(skb, recv_if);
-		if (ret == NET_RX_DROP)
-			goto dropped;
-
-		goto out;
-	}
-
 	/* skb->dev & skb->pkt_type are set here */
 	if (unlikely(!pskb_may_pull(skb, ETH_HLEN)))
 		goto dropped;
@@ -765,8 +293,6 @@ void interface_rx(struct net_device *soft_iface,
 dropped:
 	kfree_skb(skb);
 out:
-	if (curr_softif_neigh)
-		softif_neigh_free_ref(curr_softif_neigh);
 	return;
 }
 
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index 756eab5..0203006 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -23,8 +23,6 @@
 #define _NET_BATMAN_ADV_SOFT_INTERFACE_H_
 
 int my_skb_head_push(struct sk_buff *skb, unsigned int len);
-int softif_neigh_seq_print_text(struct seq_file *seq, void *offset);
-void softif_neigh_purge(struct bat_priv *bat_priv);
 void interface_rx(struct net_device *soft_iface,
 		  struct sk_buff *skb, struct hard_iface *recv_if,
 		  int hdr_size);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 24c8a31..feac2f4 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -174,7 +174,6 @@ struct bat_priv {
 	struct hlist_head forw_bat_list;
 	struct hlist_head forw_bcast_list;
 	struct hlist_head gw_list;
-	struct hlist_head softif_neigh_vids;
 	struct list_head tt_changes_list; /* tracks changes in a OGM int */
 	struct list_head vis_send_list;
 	struct hashtable_t *orig_hash;
@@ -191,8 +190,6 @@ struct bat_priv {
 	spinlock_t gw_list_lock; /* protects gw_list and curr_gw */
 	spinlock_t vis_hash_lock; /* protects vis_hash */
 	spinlock_t vis_list_lock; /* protects vis_info::recv_list */
-	spinlock_t softif_neigh_lock; /* protects soft-interface neigh list */
-	spinlock_t softif_neigh_vid_lock; /* protects soft-interface vid list */
 	atomic_t num_local_tt;
 	/* Checksum of the local table, recomputed before sending a new OGM */
 	atomic_t tt_crc;
@@ -327,24 +324,6 @@ struct recvlist_node {
 	uint8_t mac[ETH_ALEN];
 };
 
-struct softif_neigh_vid {
-	struct hlist_node list;
-	struct bat_priv *bat_priv;
-	short vid;
-	atomic_t refcount;
-	struct softif_neigh __rcu *softif_neigh;
-	struct rcu_head rcu;
-	struct hlist_head softif_neigh_list;
-};
-
-struct softif_neigh {
-	struct hlist_node list;
-	uint8_t addr[ETH_ALEN];
-	unsigned long last_seen;
-	atomic_t refcount;
-	struct rcu_head rcu;
-};
-
 struct bat_algo_ops {
 	struct hlist_node list;
 	char *name;
-- 
1.7.9.4
