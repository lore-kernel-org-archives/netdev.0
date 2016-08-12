From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 11/19] batman-adv: B.A.T.M.A.N. V - implement
	GW selection logic
Date: Fri, 12 Aug 2016 10:56:47 +0200
Message-ID: <1470992215-11009-12-git-send-email-sw@simonwunderlich.de>
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

Since the GW selection logic has been made routing protocol specific
it is now possible for B.A.T.M.A.N V to have its own mechanism by
providing the API implementation.

Implement the GW specific API in the B.A.T.M.A.N. V protocol in
order to provide a working GW selection mechanism.

Signed-off-by: Antonio Quartulli <a@unstable.cc>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/bat_v.c          | 223 +++++++++++++++++++++++++++++++++++++++-
 net/batman-adv/gateway_client.c |   5 +-
 net/batman-adv/gateway_client.h |   2 +
 3 files changed, 226 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/bat_v.c b/net/batman-adv/bat_v.c
index 90fd5ee..1d777b1 100644
--- a/net/batman-adv/bat_v.c
+++ b/net/batman-adv/bat_v.c
@@ -25,6 +25,7 @@
 #include <linux/init.h>
 #include <linux/jiffies.h>
 #include <linux/kernel.h>
+#include <linux/kref.h>
 #include <linux/netdevice.h>
 #include <linux/rculist.h>
 #include <linux/rcupdate.h>
@@ -40,6 +41,7 @@
 #include "gateway_common.h"
 #include "hard-interface.h"
 #include "hash.h"
+#include "log.h"
 #include "originator.h"
 #include "packet.h"
 
@@ -350,6 +352,213 @@ static ssize_t batadv_v_show_sel_class(struct batadv_priv *bat_priv, char *buff)
 	return sprintf(buff, "%u.%u MBit\n", class / 10, class % 10);
 }
 
+/**
+ * batadv_v_gw_throughput_get - retrieve the GW-bandwidth for a given GW
+ * @gw_node: the GW to retrieve the metric for
+ * @bw: the pointer where the metric will be stored. The metric is computed as
+ *  the minimum between the GW advertised throughput and the path throughput to
+ *  it in the mesh
+ *
+ * Return: 0 on success, -1 on failure
+ */
+static int batadv_v_gw_throughput_get(struct batadv_gw_node *gw_node, u32 *bw)
+{
+	struct batadv_neigh_ifinfo *router_ifinfo = NULL;
+	struct batadv_orig_node *orig_node;
+	struct batadv_neigh_node *router;
+	int ret = -1;
+
+	orig_node = gw_node->orig_node;
+	router = batadv_orig_router_get(orig_node, BATADV_IF_DEFAULT);
+	if (!router)
+		goto out;
+
+	router_ifinfo = batadv_neigh_ifinfo_get(router, BATADV_IF_DEFAULT);
+	if (!router_ifinfo)
+		goto out;
+
+	/* the GW metric is computed as the minimum between the path throughput
+	 * to reach the GW itself and the advertised bandwidth.
+	 * This gives us an approximation of the effective throughput that the
+	 * client can expect via this particular GW node
+	 */
+	*bw = router_ifinfo->bat_v.throughput;
+	*bw = min_t(u32, *bw, gw_node->bandwidth_down);
+
+	ret = 0;
+out:
+	if (router)
+		batadv_neigh_node_put(router);
+	if (router_ifinfo)
+		batadv_neigh_ifinfo_put(router_ifinfo);
+
+	return ret;
+}
+
+/**
+ * batadv_v_gw_get_best_gw_node - retrieve the best GW node
+ * @bat_priv: the bat priv with all the soft interface information
+ *
+ * Return: the GW node having the best GW-metric, NULL if no GW is known
+ */
+static struct batadv_gw_node *
+batadv_v_gw_get_best_gw_node(struct batadv_priv *bat_priv)
+{
+	struct batadv_gw_node *gw_node, *curr_gw = NULL;
+	u32 max_bw = 0, bw;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.list, list) {
+		if (!kref_get_unless_zero(&gw_node->refcount))
+			continue;
+
+		if (batadv_v_gw_throughput_get(gw_node, &bw) < 0)
+			goto next;
+
+		if (curr_gw && (bw <= max_bw))
+			goto next;
+
+		if (curr_gw)
+			batadv_gw_node_put(curr_gw);
+
+		curr_gw = gw_node;
+		kref_get(&curr_gw->refcount);
+		max_bw = bw;
+
+next:
+		batadv_gw_node_put(gw_node);
+	}
+	rcu_read_unlock();
+
+	return curr_gw;
+}
+
+/**
+ * batadv_v_gw_is_eligible - check if a originator would be selected as GW
+ * @bat_priv: the bat priv with all the soft interface information
+ * @curr_gw_orig: originator representing the currently selected GW
+ * @orig_node: the originator representing the new candidate
+ *
+ * Return: true if orig_node can be selected as current GW, false otherwise
+ */
+static bool batadv_v_gw_is_eligible(struct batadv_priv *bat_priv,
+				    struct batadv_orig_node *curr_gw_orig,
+				    struct batadv_orig_node *orig_node)
+{
+	struct batadv_gw_node *curr_gw = NULL, *orig_gw = NULL;
+	u32 gw_throughput, orig_throughput, threshold;
+	bool ret = false;
+
+	threshold = atomic_read(&bat_priv->gw.sel_class);
+
+	curr_gw = batadv_gw_node_get(bat_priv, curr_gw_orig);
+	if (!curr_gw) {
+		ret = true;
+		goto out;
+	}
+
+	if (batadv_v_gw_throughput_get(curr_gw, &gw_throughput) < 0) {
+		ret = true;
+		goto out;
+	}
+
+	orig_gw = batadv_gw_node_get(bat_priv, orig_node);
+	if (!orig_node)
+		goto out;
+
+	if (batadv_v_gw_throughput_get(orig_gw, &orig_throughput) < 0)
+		goto out;
+
+	if (orig_throughput < gw_throughput)
+		goto out;
+
+	if ((orig_throughput - gw_throughput) < threshold)
+		goto out;
+
+	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+		   "Restarting gateway selection: better gateway found (throughput curr: %u, throughput new: %u)\n",
+		   gw_throughput, orig_throughput);
+
+	ret = true;
+out:
+	if (curr_gw)
+		batadv_gw_node_put(curr_gw);
+	if (orig_gw)
+		batadv_gw_node_put(orig_gw);
+
+	return ret;
+}
+
+/* fails if orig_node has no router */
+static int batadv_v_gw_write_buffer_text(struct batadv_priv *bat_priv,
+					 struct seq_file *seq,
+					 const struct batadv_gw_node *gw_node)
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
+	seq_printf(seq, "%s %pM (%9u.%1u) %pM [%10s]: %u.%u/%u.%u MBit\n",
+		   (curr_gw == gw_node ? "=>" : "  "),
+		   gw_node->orig_node->orig,
+		   router_ifinfo->bat_v.throughput / 10,
+		   router_ifinfo->bat_v.throughput % 10, router->addr,
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
+/**
+ * batadv_v_gw_print - print the gateway list
+ * @bat_priv: the bat priv with all the soft interface information
+ * @seq: gateway table seq_file struct
+ */
+static void batadv_v_gw_print(struct batadv_priv *bat_priv,
+			      struct seq_file *seq)
+{
+	struct batadv_gw_node *gw_node;
+	int gw_count = 0;
+
+	seq_puts(seq,
+		 "      Gateway        ( throughput)           Nexthop [outgoingIF]: advertised uplink bandwidth\n");
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.list, list) {
+		/* fails if orig_node has no router */
+		if (batadv_v_gw_write_buffer_text(bat_priv, seq, gw_node) < 0)
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
 static struct batadv_algo_ops batadv_batman_v __read_mostly = {
 	.name = "BATMAN_V",
 	.iface = {
@@ -371,6 +580,9 @@ static struct batadv_algo_ops batadv_batman_v __read_mostly = {
 	.gw = {
 		.store_sel_class = batadv_v_store_sel_class,
 		.show_sel_class = batadv_v_show_sel_class,
+		.get_best_gw_node = batadv_v_gw_get_best_gw_node,
+		.is_eligible = batadv_v_gw_is_eligible,
+		.print = batadv_v_gw_print,
 	},
 };
 
@@ -397,7 +609,16 @@ void batadv_v_hardif_init(struct batadv_hard_iface *hard_iface)
  */
 int batadv_v_mesh_init(struct batadv_priv *bat_priv)
 {
-	return batadv_v_ogm_init(bat_priv);
+	int ret = 0;
+
+	ret = batadv_v_ogm_init(bat_priv);
+	if (ret < 0)
+		return ret;
+
+	/* set default throughput difference threshold to 5Mbps */
+	atomic_set(&bat_priv->gw.sel_class, 50);
+
+	return 0;
 }
 
 /**
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index ec363f3..a77a179 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -360,9 +360,8 @@ static void batadv_gw_node_add(struct batadv_priv *bat_priv,
  *
  * Return: gateway node if found or NULL otherwise.
  */
-static struct batadv_gw_node *
-batadv_gw_node_get(struct batadv_priv *bat_priv,
-		   struct batadv_orig_node *orig_node)
+struct batadv_gw_node *batadv_gw_node_get(struct batadv_priv *bat_priv,
+					  struct batadv_orig_node *orig_node)
 {
 	struct batadv_gw_node *gw_node_tmp, *gw_node = NULL;
 
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_client.h
index 4c9edde..6b40432 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -47,5 +47,7 @@ bool batadv_gw_out_of_range(struct batadv_priv *bat_priv, struct sk_buff *skb);
 enum batadv_dhcp_recipient
 batadv_gw_dhcp_recipient_get(struct sk_buff *skb, unsigned int *header_len,
 			     u8 *chaddr);
+struct batadv_gw_node *batadv_gw_node_get(struct batadv_priv *bat_priv,
+					  struct batadv_orig_node *orig_node);
 
 #endif /* _NET_BATMAN_ADV_GATEWAY_CLIENT_H_ */
-- 
2.8.1
