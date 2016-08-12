From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 10/19] batman-adv: make GW election code
	protocol specific
Date: Fri, 12 Aug 2016 10:56:46 +0200
Message-ID: <1470992215-11009-11-git-send-email-sw@simonwunderlich.de>
References: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, Antonio Quartulli <a@unstable.cc>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1470992215-11009-1-git-send-email-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Antonio Quartulli <a@unstable.cc>

Each routing protocol may have its own specific logic about
gateway election which is potentially based on the metric being
used.

Create two GW specific API functions and move the current election
logic in the B.A.T.M.A.N. IV specific code.

Signed-off-by: Antonio Quartulli <a@unstable.cc>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/bat_iv_ogm.c     | 219 ++++++++++++++++++++++++++++++++++++++++
 net/batman-adv/gateway_client.c | 217 +++++----------------------------------
 net/batman-adv/gateway_client.h |   3 +
 net/batman-adv/gateway_common.c |   5 +-
 net/batman-adv/types.h          |  11 ++
 5 files changed, 263 insertions(+), 192 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 6af4462..d04874f 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -51,6 +51,7 @@
 
 #include "bat_algo.h"
 #include "bitarray.h"
+#include "gateway_client.h"
 #include "hard-interface.h"
 #include "hash.h"
 #include "log.h"
@@ -2106,6 +2107,219 @@ static void batadv_iv_iface_activate(struct batadv_hard_iface *hard_iface)
 	batadv_iv_ogm_schedule(hard_iface);
 }
 
+static struct batadv_gw_node *
+batadv_iv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
+{
+	struct batadv_neigh_node *router;
+	struct batadv_neigh_ifinfo *router_ifinfo;
+	struct batadv_gw_node *gw_node, *curr_gw = NULL;
+	u64 max_gw_factor = 0;
+	u64 tmp_gw_factor = 0;
+	u8 max_tq = 0;
+	u8 tq_avg;
+	struct batadv_orig_node *orig_node;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.list, list) {
+		orig_node = gw_node->orig_node;
+		router = batadv_orig_router_get(orig_node, BATADV_IF_DEFAULT);
+		if (!router)
+			continue;
+
+		router_ifinfo = batadv_neigh_ifinfo_get(router,
+							BATADV_IF_DEFAULT);
+		if (!router_ifinfo)
+			goto next;
+
+		if (!kref_get_unless_zero(&gw_node->refcount))
+			goto next;
+
+		tq_avg = router_ifinfo->bat_iv.tq_avg;
+
+		switch (atomic_read(&bat_priv->gw.sel_class)) {
+		case 1: /* fast connection */
+			tmp_gw_factor = tq_avg * tq_avg;
+			tmp_gw_factor *= gw_node->bandwidth_down;
+			tmp_gw_factor *= 100 * 100;
+			tmp_gw_factor >>= 18;
+
+			if ((tmp_gw_factor > max_gw_factor) ||
+			    ((tmp_gw_factor == max_gw_factor) &&
+			     (tq_avg > max_tq))) {
+				if (curr_gw)
+					batadv_gw_node_put(curr_gw);
+				curr_gw = gw_node;
+				kref_get(&curr_gw->refcount);
+			}
+			break;
+
+		default: /* 2:  stable connection (use best statistic)
+			  * 3:  fast-switch (use best statistic but change as
+			  *     soon as a better gateway appears)
+			  * XX: late-switch (use best statistic but change as
+			  *     soon as a better gateway appears which has
+			  *     $routing_class more tq points)
+			  */
+			if (tq_avg > max_tq) {
+				if (curr_gw)
+					batadv_gw_node_put(curr_gw);
+				curr_gw = gw_node;
+				kref_get(&curr_gw->refcount);
+			}
+			break;
+		}
+
+		if (tq_avg > max_tq)
+			max_tq = tq_avg;
+
+		if (tmp_gw_factor > max_gw_factor)
+			max_gw_factor = tmp_gw_factor;
+
+		batadv_gw_node_put(gw_node);
+
+next:
+		batadv_neigh_node_put(router);
+		if (router_ifinfo)
+			batadv_neigh_ifinfo_put(router_ifinfo);
+	}
+	rcu_read_unlock();
+
+	return curr_gw;
+}
+
+static bool batadv_iv_gw_is_eligible(struct batadv_priv *bat_priv,
+				     struct batadv_orig_node *curr_gw_orig,
+				     struct batadv_orig_node *orig_node)
+{
+	struct batadv_neigh_ifinfo *router_orig_ifinfo = NULL;
+	struct batadv_neigh_ifinfo *router_gw_ifinfo = NULL;
+	struct batadv_neigh_node *router_gw = NULL;
+	struct batadv_neigh_node *router_orig = NULL;
+	u8 gw_tq_avg, orig_tq_avg;
+	bool ret = false;
+
+	/* dynamic re-election is performed only on fast or late switch */
+	if (atomic_read(&bat_priv->gw.sel_class) <= 2)
+		return false;
+
+	router_gw = batadv_orig_router_get(curr_gw_orig, BATADV_IF_DEFAULT);
+	if (!router_gw) {
+		ret = true;
+		goto out;
+	}
+
+	router_gw_ifinfo = batadv_neigh_ifinfo_get(router_gw,
+						   BATADV_IF_DEFAULT);
+	if (!router_gw_ifinfo) {
+		ret = true;
+		goto out;
+	}
+
+	router_orig = batadv_orig_router_get(orig_node, BATADV_IF_DEFAULT);
+	if (!router_orig)
+		goto out;
+
+	router_orig_ifinfo = batadv_neigh_ifinfo_get(router_orig,
+						     BATADV_IF_DEFAULT);
+	if (!router_orig_ifinfo)
+		goto out;
+
+	gw_tq_avg = router_gw_ifinfo->bat_iv.tq_avg;
+	orig_tq_avg = router_orig_ifinfo->bat_iv.tq_avg;
+
+	/* the TQ value has to be better */
+	if (orig_tq_avg < gw_tq_avg)
+		goto out;
+
+	/* if the routing class is greater than 3 the value tells us how much
+	 * greater the TQ value of the new gateway must be
+	 */
+	if ((atomic_read(&bat_priv->gw.sel_class) > 3) &&
+	    (orig_tq_avg - gw_tq_avg < atomic_read(&bat_priv->gw.sel_class)))
+		goto out;
+
+	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+		   "Restarting gateway selection: better gateway found (tq curr: %i, tq new: %i)\n",
+		   gw_tq_avg, orig_tq_avg);
+
+	ret = true;
+out:
+	if (router_gw_ifinfo)
+		batadv_neigh_ifinfo_put(router_gw_ifinfo);
+	if (router_orig_ifinfo)
+		batadv_neigh_ifinfo_put(router_orig_ifinfo);
+	if (router_gw)
+		batadv_neigh_node_put(router_gw);
+	if (router_orig)
+		batadv_neigh_node_put(router_orig);
+
+	return ret;
+}
+
+/* fails if orig_node has no router */
+static int batadv_iv_gw_write_buffer_text(struct batadv_priv *bat_priv,
+					  struct seq_file *seq,
+					  const struct batadv_gw_node *gw_node)
+{
+	struct batadv_gw_node *curr_gw;
+	struct batadv_neigh_node *router;
+	struct batadv_neigh_ifinfo *router_ifinfo = NULL;
+	int ret = -1;
+
+	router = batadv_orig_router_get(gw_node->orig_node, BATADV_IF_DEFAULT);
+	if (!router)
+		goto out;
+
+	router_ifinfo = batadv_neigh_ifinfo_get(router, BATADV_IF_DEFAULT);
+	if (!router_ifinfo)
+		goto out;
+
+	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
+
+	seq_printf(seq, "%s %pM (%3i) %pM [%10s]: %u.%u/%u.%u MBit\n",
+		   (curr_gw == gw_node ? "=>" : "  "),
+		   gw_node->orig_node->orig,
+		   router_ifinfo->bat_iv.tq_avg, router->addr,
+		   router->if_incoming->net_dev->name,
+		   gw_node->bandwidth_down / 10,
+		   gw_node->bandwidth_down % 10,
+		   gw_node->bandwidth_up / 10,
+		   gw_node->bandwidth_up % 10);
+	ret = seq_has_overflowed(seq) ? -1 : 0;
+
+	if (curr_gw)
+		batadv_gw_node_put(curr_gw);
+out:
+	if (router_ifinfo)
+		batadv_neigh_ifinfo_put(router_ifinfo);
+	if (router)
+		batadv_neigh_node_put(router);
+	return ret;
+}
+
+static void batadv_iv_gw_print(struct batadv_priv *bat_priv,
+			       struct seq_file *seq)
+{
+	struct batadv_gw_node *gw_node;
+	int gw_count = 0;
+
+	seq_puts(seq,
+		 "      Gateway      (#/255)           Nexthop [outgoingIF]: advertised uplink bandwidth\n");
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.list, list) {
+		/* fails if orig_node has no router */
+		if (batadv_iv_gw_write_buffer_text(bat_priv, seq, gw_node) < 0)
+			continue;
+
+		gw_count++;
+	}
+	rcu_read_unlock();
+
+	if (gw_count == 0)
+		seq_puts(seq, "No gateways in range ...\n");
+}
+
 static struct batadv_algo_ops batadv_batman_iv __read_mostly = {
 	.name = "BATMAN_IV",
 	.iface = {
@@ -2126,6 +2340,11 @@ static struct batadv_algo_ops batadv_batman_iv __read_mostly = {
 		.add_if = batadv_iv_ogm_orig_add_if,
 		.del_if = batadv_iv_ogm_orig_del_if,
 	},
+	.gw = {
+		.get_best_gw_node = batadv_iv_gw_get_best_gw_node,
+		.is_eligible = batadv_iv_gw_is_eligible,
+		.print = batadv_iv_gw_print,
+	},
 };
 
 int __init batadv_iv_init(void)
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 63a805d..ec363f3 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -80,12 +80,12 @@ static void batadv_gw_node_release(struct kref *ref)
  * batadv_gw_node_put - decrement the gw_node refcounter and possibly release it
  * @gw_node: gateway node to free
  */
-static void batadv_gw_node_put(struct batadv_gw_node *gw_node)
+void batadv_gw_node_put(struct batadv_gw_node *gw_node)
 {
 	kref_put(&gw_node->refcount, batadv_gw_node_release);
 }
 
-static struct batadv_gw_node *
+struct batadv_gw_node *
 batadv_gw_get_selected_gw_node(struct batadv_priv *bat_priv)
 {
 	struct batadv_gw_node *gw_node;
@@ -164,86 +164,6 @@ void batadv_gw_reselect(struct batadv_priv *bat_priv)
 	atomic_set(&bat_priv->gw.reselect, 1);
 }
 
-static struct batadv_gw_node *
-batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
-{
-	struct batadv_neigh_node *router;
-	struct batadv_neigh_ifinfo *router_ifinfo;
-	struct batadv_gw_node *gw_node, *curr_gw = NULL;
-	u64 max_gw_factor = 0;
-	u64 tmp_gw_factor = 0;
-	u8 max_tq = 0;
-	u8 tq_avg;
-	struct batadv_orig_node *orig_node;
-
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.list, list) {
-		orig_node = gw_node->orig_node;
-		router = batadv_orig_router_get(orig_node, BATADV_IF_DEFAULT);
-		if (!router)
-			continue;
-
-		router_ifinfo = batadv_neigh_ifinfo_get(router,
-							BATADV_IF_DEFAULT);
-		if (!router_ifinfo)
-			goto next;
-
-		if (!kref_get_unless_zero(&gw_node->refcount))
-			goto next;
-
-		tq_avg = router_ifinfo->bat_iv.tq_avg;
-
-		switch (atomic_read(&bat_priv->gw.sel_class)) {
-		case 1: /* fast connection */
-			tmp_gw_factor = tq_avg * tq_avg;
-			tmp_gw_factor *= gw_node->bandwidth_down;
-			tmp_gw_factor *= 100 * 100;
-			tmp_gw_factor >>= 18;
-
-			if ((tmp_gw_factor > max_gw_factor) ||
-			    ((tmp_gw_factor == max_gw_factor) &&
-			     (tq_avg > max_tq))) {
-				if (curr_gw)
-					batadv_gw_node_put(curr_gw);
-				curr_gw = gw_node;
-				kref_get(&curr_gw->refcount);
-			}
-			break;
-
-		default: /* 2:  stable connection (use best statistic)
-			  * 3:  fast-switch (use best statistic but change as
-			  *     soon as a better gateway appears)
-			  * XX: late-switch (use best statistic but change as
-			  *     soon as a better gateway appears which has
-			  *     $routing_class more tq points)
-			  */
-			if (tq_avg > max_tq) {
-				if (curr_gw)
-					batadv_gw_node_put(curr_gw);
-				curr_gw = gw_node;
-				kref_get(&curr_gw->refcount);
-			}
-			break;
-		}
-
-		if (tq_avg > max_tq)
-			max_tq = tq_avg;
-
-		if (tmp_gw_factor > max_gw_factor)
-			max_gw_factor = tmp_gw_factor;
-
-		batadv_gw_node_put(gw_node);
-
-next:
-		batadv_neigh_node_put(router);
-		if (router_ifinfo)
-			batadv_neigh_ifinfo_put(router_ifinfo);
-	}
-	rcu_read_unlock();
-
-	return curr_gw;
-}
-
 /**
  * batadv_gw_check_client_stop - check if client mode has been switched off
  * @bat_priv: the bat priv with all the soft interface information
@@ -287,12 +207,19 @@ void batadv_gw_election(struct batadv_priv *bat_priv)
 	if (atomic_read(&bat_priv->gw.mode) != BATADV_GW_MODE_CLIENT)
 		goto out;
 
+	if (!bat_priv->algo_ops->gw.get_best_gw_node)
+		goto out;
+
 	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
 
 	if (!batadv_atomic_dec_not_zero(&bat_priv->gw.reselect) && curr_gw)
 		goto out;
 
-	next_gw = batadv_gw_get_best_gw_node(bat_priv);
+	/* if gw.reselect is set to 1 it means that a previous call to
+	 * gw.is_eligible() said that we have a new best GW, therefore it can
+	 * now be picked from the list and selected
+	 */
+	next_gw = bat_priv->algo_ops->gw.get_best_gw_node(bat_priv);
 
 	if (curr_gw == next_gw)
 		goto out;
@@ -360,70 +287,31 @@ out:
 void batadv_gw_check_election(struct batadv_priv *bat_priv,
 			      struct batadv_orig_node *orig_node)
 {
-	struct batadv_neigh_ifinfo *router_orig_tq = NULL;
-	struct batadv_neigh_ifinfo *router_gw_tq = NULL;
 	struct batadv_orig_node *curr_gw_orig;
-	struct batadv_neigh_node *router_gw = NULL;
-	struct batadv_neigh_node *router_orig = NULL;
-	u8 gw_tq_avg, orig_tq_avg;
+
+	/* abort immediately if the routing algorithm does not support gateway
+	 * election
+	 */
+	if (!bat_priv->algo_ops->gw.is_eligible)
+		return;
 
 	curr_gw_orig = batadv_gw_get_selected_orig(bat_priv);
 	if (!curr_gw_orig)
 		goto reselect;
 
-	router_gw = batadv_orig_router_get(curr_gw_orig, BATADV_IF_DEFAULT);
-	if (!router_gw)
-		goto reselect;
-
-	router_gw_tq = batadv_neigh_ifinfo_get(router_gw,
-					       BATADV_IF_DEFAULT);
-	if (!router_gw_tq)
-		goto reselect;
-
 	/* this node already is the gateway */
 	if (curr_gw_orig == orig_node)
 		goto out;
 
-	router_orig = batadv_orig_router_get(orig_node, BATADV_IF_DEFAULT);
-	if (!router_orig)
-		goto out;
-
-	router_orig_tq = batadv_neigh_ifinfo_get(router_orig,
-						 BATADV_IF_DEFAULT);
-	if (!router_orig_tq)
-		goto out;
-
-	gw_tq_avg = router_gw_tq->bat_iv.tq_avg;
-	orig_tq_avg = router_orig_tq->bat_iv.tq_avg;
-
-	/* the TQ value has to be better */
-	if (orig_tq_avg < gw_tq_avg)
+	if (!bat_priv->algo_ops->gw.is_eligible(bat_priv, curr_gw_orig,
+						orig_node))
 		goto out;
 
-	/* if the routing class is greater than 3 the value tells us how much
-	 * greater the TQ value of the new gateway must be
-	 */
-	if ((atomic_read(&bat_priv->gw.sel_class) > 3) &&
-	    (orig_tq_avg - gw_tq_avg < atomic_read(&bat_priv->gw.sel_class)))
-		goto out;
-
-	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-		   "Restarting gateway selection: better gateway found (tq curr: %i, tq new: %i)\n",
-		   gw_tq_avg, orig_tq_avg);
-
 reselect:
 	batadv_gw_reselect(bat_priv);
 out:
 	if (curr_gw_orig)
 		batadv_orig_node_put(curr_gw_orig);
-	if (router_gw)
-		batadv_neigh_node_put(router_gw);
-	if (router_orig)
-		batadv_neigh_node_put(router_orig);
-	if (router_gw_tq)
-		batadv_neigh_ifinfo_put(router_gw_tq);
-	if (router_orig_tq)
-		batadv_neigh_ifinfo_put(router_orig_tq);
 }
 
 /**
@@ -585,80 +473,31 @@ void batadv_gw_node_free(struct batadv_priv *bat_priv)
 	spin_unlock_bh(&bat_priv->gw.list_lock);
 }
 
-/* fails if orig_node has no router */
-static int batadv_write_buffer_text(struct batadv_priv *bat_priv,
-				    struct seq_file *seq,
-				    const struct batadv_gw_node *gw_node)
-{
-	struct batadv_gw_node *curr_gw;
-	struct batadv_neigh_node *router;
-	struct batadv_neigh_ifinfo *router_ifinfo = NULL;
-	int ret = -1;
-
-	router = batadv_orig_router_get(gw_node->orig_node, BATADV_IF_DEFAULT);
-	if (!router)
-		goto out;
-
-	router_ifinfo = batadv_neigh_ifinfo_get(router, BATADV_IF_DEFAULT);
-	if (!router_ifinfo)
-		goto out;
-
-	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
-
-	seq_printf(seq, "%s %pM (%3i) %pM [%10s]: %u.%u/%u.%u MBit\n",
-		   (curr_gw == gw_node ? "=>" : "  "),
-		   gw_node->orig_node->orig,
-		   router_ifinfo->bat_iv.tq_avg, router->addr,
-		   router->if_incoming->net_dev->name,
-		   gw_node->bandwidth_down / 10,
-		   gw_node->bandwidth_down % 10,
-		   gw_node->bandwidth_up / 10,
-		   gw_node->bandwidth_up % 10);
-	ret = seq_has_overflowed(seq) ? -1 : 0;
-
-	if (curr_gw)
-		batadv_gw_node_put(curr_gw);
-out:
-	if (router_ifinfo)
-		batadv_neigh_ifinfo_put(router_ifinfo);
-	if (router)
-		batadv_neigh_node_put(router);
-	return ret;
-}
-
 int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct net_device *net_dev = (struct net_device *)seq->private;
 	struct batadv_priv *bat_priv = netdev_priv(net_dev);
 	struct batadv_hard_iface *primary_if;
-	struct batadv_gw_node *gw_node;
-	int gw_count = 0;
 
 	primary_if = batadv_seq_print_text_primary_if_get(seq);
 	if (!primary_if)
-		goto out;
+		return 0;
 
-	seq_printf(seq,
-		   "      Gateway      (#/255)           Nexthop [outgoingIF]: advertised uplink bandwidth ... [B.A.T.M.A.N. adv %s, MainIF/MAC: %s/%pM (%s)]\n",
+	seq_printf(seq, "[B.A.T.M.A.N. adv %s, MainIF/MAC: %s/%pM (%s %s)]\n",
 		   BATADV_SOURCE_VERSION, primary_if->net_dev->name,
-		   primary_if->net_dev->dev_addr, net_dev->name);
+		   primary_if->net_dev->dev_addr, net_dev->name,
+		   bat_priv->algo_ops->name);
 
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.list, list) {
-		/* fails if orig_node has no router */
-		if (batadv_write_buffer_text(bat_priv, seq, gw_node) < 0)
-			continue;
+	batadv_hardif_put(primary_if);
 
-		gw_count++;
+	if (!bat_priv->algo_ops->gw.print) {
+		seq_puts(seq,
+			 "No printing function for this routing protocol\n");
+		return 0;
 	}
-	rcu_read_unlock();
 
-	if (gw_count == 0)
-		seq_puts(seq, "No gateways in range ...\n");
+	bat_priv->algo_ops->gw.print(bat_priv, seq);
 
-out:
-	if (primary_if)
-		batadv_hardif_put(primary_if);
 	return 0;
 }
 
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_client.h
index 582dd8c..4c9edde 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -39,6 +39,9 @@ void batadv_gw_node_update(struct batadv_priv *bat_priv,
 void batadv_gw_node_delete(struct batadv_priv *bat_priv,
 			   struct batadv_orig_node *orig_node);
 void batadv_gw_node_free(struct batadv_priv *bat_priv);
+void batadv_gw_node_put(struct batadv_gw_node *gw_node);
+struct batadv_gw_node *
+batadv_gw_get_selected_gw_node(struct batadv_priv *bat_priv);
 int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset);
 bool batadv_gw_out_of_range(struct batadv_priv *bat_priv, struct sk_buff *skb);
 enum batadv_dhcp_recipient
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index d7bc6a8..2118481 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -241,10 +241,9 @@ static void batadv_gw_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
 
 	batadv_gw_node_update(bat_priv, orig, &gateway);
 
-	/* restart gateway selection if fast or late switching was enabled */
+	/* restart gateway selection */
 	if ((gateway.bandwidth_down != 0) &&
-	    (atomic_read(&bat_priv->gw.mode) == BATADV_GW_MODE_CLIENT) &&
-	    (atomic_read(&bat_priv->gw.sel_class) > 2))
+	    (atomic_read(&bat_priv->gw.mode) == BATADV_GW_MODE_CLIENT))
 		batadv_gw_check_election(bat_priv, orig);
 }
 
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index deaadba..54710c7 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1453,11 +1453,22 @@ struct batadv_algo_orig_ops {
  * struct batadv_algo_gw_ops - mesh algorithm callbacks (GW specific)
  * @store_sel_class: parse and stores a new GW selection class (optional)
  * @show_sel_class: prints the current GW selection class (optional)
+ * @get_best_gw_node: select the best GW from the list of available nodes
+ *  (optional)
+ * @is_eligible: check if a newly discovered GW is a potential candidate for
+ *  the election as best GW (optional)
+ * @print: print the gateway table (optional)
  */
 struct batadv_algo_gw_ops {
 	ssize_t (*store_sel_class)(struct batadv_priv *bat_priv, char *buff,
 				   size_t count);
 	ssize_t (*show_sel_class)(struct batadv_priv *bat_priv, char *buff);
+	struct batadv_gw_node *(*get_best_gw_node)
+		(struct batadv_priv *bat_priv);
+	bool (*is_eligible)(struct batadv_priv *bat_priv,
+			    struct batadv_orig_node *curr_gw_orig,
+			    struct batadv_orig_node *orig_node);
+	void (*print)(struct batadv_priv *bat_priv, struct seq_file *seq);
 };
 
 /**
-- 
2.8.1
