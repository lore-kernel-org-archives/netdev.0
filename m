From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 08/17] batman-adv: remove ogm_emit and
	ogm_schedule API calls
Date: Fri,  1 Jul 2016 15:09:00 +0200
Message-ID: <1467378549-9646-9-git-send-email-sw@simonwunderlich.de>
References: <1467378549-9646-1-git-send-email-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, Antonio Quartulli <a@unstable.cc>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1467378549-9646-1-git-send-email-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
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

The ogm_emit and ogm_schedule API calls were rather tight to the
B.A.T.M.A.N. IV logic and therefore rather difficult to use
with other algorithm implementations.

Remove such calls and move the surrounding logic into the
B.A.T.M.A.N. IV specific code.

Signed-off-by: Antonio Quartulli <a@unstable.cc>
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/bat_iv_ogm.c     | 69 ++++++++++++++++++++++++++++++++++++++---
 net/batman-adv/bat_v.c          | 10 ------
 net/batman-adv/hard-interface.c |  3 --
 net/batman-adv/main.c           |  2 --
 net/batman-adv/send.c           | 61 +-----------------------------------
 net/batman-adv/send.h           |  4 +--
 net/batman-adv/types.h          |  4 ---
 7 files changed, 67 insertions(+), 86 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index aa11296..4815db9 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -30,6 +30,7 @@
 #include <linux/if_ether.h>
 #include <linux/init.h>
 #include <linux/jiffies.h>
+#include <linux/kernel.h>
 #include <linux/list.h>
 #include <linux/kref.h>
 #include <linux/lockdep.h>
@@ -58,6 +59,8 @@
 #include "send.h"
 #include "translation-table.h"
 
+static void batadv_iv_send_outstanding_bat_ogm_packet(struct work_struct *work);
+
 /**
  * enum batadv_dup_status - duplicate status
  * @BATADV_NO_DUP: the packet is no duplicate
@@ -731,7 +734,7 @@ static void batadv_iv_ogm_aggregate_new(const unsigned char *packet_buff,
 
 	/* start timer for this packet */
 	INIT_DELAYED_WORK(&forw_packet_aggr->delayed_work,
-			  batadv_send_outstanding_bat_ogm_packet);
+			  batadv_iv_send_outstanding_bat_ogm_packet);
 	queue_delayed_work(batadv_event_workqueue,
 			   &forw_packet_aggr->delayed_work,
 			   send_time - jiffies);
@@ -938,6 +941,19 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 	u16 tvlv_len = 0;
 	unsigned long send_time;
 
+	if ((hard_iface->if_status == BATADV_IF_NOT_IN_USE) ||
+	    (hard_iface->if_status == BATADV_IF_TO_BE_REMOVED))
+		return;
+
+	/* the interface gets activated here to avoid race conditions between
+	 * the moment of activating the interface in
+	 * hardif_activate_interface() where the originator mac is set and
+	 * outdated packets (especially uninitialized mac addresses) in the
+	 * packet queue
+	 */
+	if (hard_iface->if_status == BATADV_IF_TO_BE_ACTIVATED)
+		hard_iface->if_status = BATADV_IF_ACTIVE;
+
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 
 	if (hard_iface == primary_if) {
@@ -1779,6 +1795,45 @@ static void batadv_iv_ogm_process(const struct sk_buff *skb, int ogm_offset,
 	batadv_orig_node_put(orig_node);
 }
 
+static void batadv_iv_send_outstanding_bat_ogm_packet(struct work_struct *work)
+{
+	struct delayed_work *delayed_work;
+	struct batadv_forw_packet *forw_packet;
+	struct batadv_priv *bat_priv;
+
+	delayed_work = to_delayed_work(work);
+	forw_packet = container_of(delayed_work, struct batadv_forw_packet,
+				   delayed_work);
+	bat_priv = netdev_priv(forw_packet->if_incoming->soft_iface);
+	spin_lock_bh(&bat_priv->forw_bat_list_lock);
+	hlist_del(&forw_packet->list);
+	spin_unlock_bh(&bat_priv->forw_bat_list_lock);
+
+	if (atomic_read(&bat_priv->mesh_state) == BATADV_MESH_DEACTIVATING)
+		goto out;
+
+	batadv_iv_ogm_emit(forw_packet);
+
+	/* we have to have at least one packet in the queue to determine the
+	 * queues wake up time unless we are shutting down.
+	 *
+	 * only re-schedule if this is the "original" copy, e.g. the OGM of the
+	 * primary interface should only be rescheduled once per period, but
+	 * this function will be called for the forw_packet instances of the
+	 * other secondary interfaces as well.
+	 */
+	if (forw_packet->own &&
+	    forw_packet->if_incoming == forw_packet->if_outgoing)
+		batadv_iv_ogm_schedule(forw_packet->if_incoming);
+
+out:
+	/* don't count own packet */
+	if (!forw_packet->own)
+		atomic_inc(&bat_priv->batman_queue_left);
+
+	batadv_forw_packet_free(forw_packet);
+}
+
 static int batadv_iv_ogm_receive(struct sk_buff *skb,
 				 struct batadv_hard_iface *if_incoming)
 {
@@ -1795,7 +1850,8 @@ static int batadv_iv_ogm_receive(struct sk_buff *skb,
 	/* did we receive a B.A.T.M.A.N. IV OGM packet on an interface
 	 * that does not have B.A.T.M.A.N. IV enabled ?
 	 */
-	if (bat_priv->bat_algo_ops->bat_ogm_emit != batadv_iv_ogm_emit)
+	if (bat_priv->bat_algo_ops->bat_iface_enable !=
+	    batadv_iv_ogm_iface_enable)
 		return NET_RX_DROP;
 
 	batadv_inc_counter(bat_priv, BATADV_CNT_MGMT_RX);
@@ -2053,14 +2109,19 @@ out:
 	return ret;
 }
 
+static void batadv_iv_iface_activate(struct batadv_hard_iface *hard_iface)
+{
+	/* begin scheduling originator messages on that interface */
+	batadv_iv_ogm_schedule(hard_iface);
+}
+
 static struct batadv_algo_ops batadv_batman_iv __read_mostly = {
 	.name = "BATMAN_IV",
+	.bat_iface_activate = batadv_iv_iface_activate,
 	.bat_iface_enable = batadv_iv_ogm_iface_enable,
 	.bat_iface_disable = batadv_iv_ogm_iface_disable,
 	.bat_iface_update_mac = batadv_iv_ogm_iface_update_mac,
 	.bat_primary_iface_set = batadv_iv_ogm_primary_iface_set,
-	.bat_ogm_schedule = batadv_iv_ogm_schedule,
-	.bat_ogm_emit = batadv_iv_ogm_emit,
 	.bat_neigh_cmp = batadv_iv_ogm_neigh_cmp,
 	.bat_neigh_is_similar_or_better = batadv_iv_ogm_neigh_is_sob,
 	.bat_neigh_print = batadv_iv_neigh_print,
diff --git a/net/batman-adv/bat_v.c b/net/batman-adv/bat_v.c
index 0a12e5c..c16cd44 100644
--- a/net/batman-adv/bat_v.c
+++ b/net/batman-adv/bat_v.c
@@ -119,14 +119,6 @@ batadv_v_hardif_neigh_init(struct batadv_hardif_neigh_node *hardif_neigh)
 		  batadv_v_elp_throughput_metric_update);
 }
 
-static void batadv_v_ogm_schedule(struct batadv_hard_iface *hard_iface)
-{
-}
-
-static void batadv_v_ogm_emit(struct batadv_forw_packet *forw_packet)
-{
-}
-
 /**
  * batadv_v_orig_print_neigh - print neighbors for the originator table
  * @orig_node: the orig_node for which the neighbors are printed
@@ -340,8 +332,6 @@ static struct batadv_algo_ops batadv_batman_v __read_mostly = {
 	.bat_iface_update_mac = batadv_v_iface_update_mac,
 	.bat_primary_iface_set = batadv_v_primary_iface_set,
 	.bat_hardif_neigh_init = batadv_v_hardif_neigh_init,
-	.bat_ogm_emit = batadv_v_ogm_emit,
-	.bat_ogm_schedule = batadv_v_ogm_schedule,
 	.bat_orig_print = batadv_v_orig_print,
 	.bat_neigh_cmp = batadv_v_neigh_cmp,
 	.bat_neigh_is_similar_or_better = batadv_v_neigh_is_sob,
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 8c2f399..db2009d 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -553,9 +553,6 @@ int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
 
 	batadv_hardif_recalc_extra_skbroom(soft_iface);
 
-	/* begin scheduling originator messages on that interface */
-	batadv_schedule_bat_ogm(hard_iface);
-
 out:
 	return 0;
 
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 5f2974b..627d14e 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -569,8 +569,6 @@ int batadv_algo_register(struct batadv_algo_ops *bat_algo_ops)
 	    !bat_algo_ops->bat_iface_disable ||
 	    !bat_algo_ops->bat_iface_update_mac ||
 	    !bat_algo_ops->bat_primary_iface_set ||
-	    !bat_algo_ops->bat_ogm_schedule ||
-	    !bat_algo_ops->bat_ogm_emit ||
 	    !bat_algo_ops->bat_neigh_cmp ||
 	    !bat_algo_ops->bat_neigh_is_similar_or_better) {
 		pr_info("Routing algo '%s' does not implement required ops\n",
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index b1a4e8a..59e695b 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -428,27 +428,7 @@ int batadv_send_skb_via_gw(struct batadv_priv *bat_priv, struct sk_buff *skb,
 				       orig_node, vid);
 }
 
-void batadv_schedule_bat_ogm(struct batadv_hard_iface *hard_iface)
-{
-	struct batadv_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
-
-	if ((hard_iface->if_status == BATADV_IF_NOT_IN_USE) ||
-	    (hard_iface->if_status == BATADV_IF_TO_BE_REMOVED))
-		return;
-
-	/* the interface gets activated here to avoid race conditions between
-	 * the moment of activating the interface in
-	 * hardif_activate_interface() where the originator mac is set and
-	 * outdated packets (especially uninitialized mac addresses) in the
-	 * packet queue
-	 */
-	if (hard_iface->if_status == BATADV_IF_TO_BE_ACTIVATED)
-		hard_iface->if_status = BATADV_IF_ACTIVE;
-
-	bat_priv->bat_algo_ops->bat_ogm_schedule(hard_iface);
-}
-
-static void batadv_forw_packet_free(struct batadv_forw_packet *forw_packet)
+void batadv_forw_packet_free(struct batadv_forw_packet *forw_packet)
 {
 	kfree_skb(forw_packet->skb);
 	if (forw_packet->if_incoming)
@@ -604,45 +584,6 @@ out:
 	atomic_inc(&bat_priv->bcast_queue_left);
 }
 
-void batadv_send_outstanding_bat_ogm_packet(struct work_struct *work)
-{
-	struct delayed_work *delayed_work;
-	struct batadv_forw_packet *forw_packet;
-	struct batadv_priv *bat_priv;
-
-	delayed_work = to_delayed_work(work);
-	forw_packet = container_of(delayed_work, struct batadv_forw_packet,
-				   delayed_work);
-	bat_priv = netdev_priv(forw_packet->if_incoming->soft_iface);
-	spin_lock_bh(&bat_priv->forw_bat_list_lock);
-	hlist_del(&forw_packet->list);
-	spin_unlock_bh(&bat_priv->forw_bat_list_lock);
-
-	if (atomic_read(&bat_priv->mesh_state) == BATADV_MESH_DEACTIVATING)
-		goto out;
-
-	bat_priv->bat_algo_ops->bat_ogm_emit(forw_packet);
-
-	/* we have to have at least one packet in the queue to determine the
-	 * queues wake up time unless we are shutting down.
-	 *
-	 * only re-schedule if this is the "original" copy, e.g. the OGM of the
-	 * primary interface should only be rescheduled once per period, but
-	 * this function will be called for the forw_packet instances of the
-	 * other secondary interfaces as well.
-	 */
-	if (forw_packet->own &&
-	    forw_packet->if_incoming == forw_packet->if_outgoing)
-		batadv_schedule_bat_ogm(forw_packet->if_incoming);
-
-out:
-	/* don't count own packet */
-	if (!forw_packet->own)
-		atomic_inc(&bat_priv->batman_queue_left);
-
-	batadv_forw_packet_free(forw_packet);
-}
-
 void
 batadv_purge_outstanding_packets(struct batadv_priv *bat_priv,
 				 const struct batadv_hard_iface *hard_iface)
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 6fd7270..7cecb75 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -26,8 +26,8 @@
 #include "packet.h"
 
 struct sk_buff;
-struct work_struct;
 
+void batadv_forw_packet_free(struct batadv_forw_packet *forw_packet);
 int batadv_send_skb_to_orig(struct sk_buff *skb,
 			    struct batadv_orig_node *orig_node,
 			    struct batadv_hard_iface *recv_if);
@@ -38,11 +38,9 @@ int batadv_send_broadcast_skb(struct sk_buff *skb,
 			      struct batadv_hard_iface *hard_iface);
 int batadv_send_unicast_skb(struct sk_buff *skb,
 			    struct batadv_neigh_node *neigh_node);
-void batadv_schedule_bat_ogm(struct batadv_hard_iface *hard_iface);
 int batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 				    const struct sk_buff *skb,
 				    unsigned long delay);
-void batadv_send_outstanding_bat_ogm_packet(struct work_struct *work);
 void
 batadv_purge_outstanding_packets(struct batadv_priv *bat_priv,
 				 const struct batadv_hard_iface *hard_iface);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 114d150..b70b6ae 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1269,8 +1269,6 @@ struct batadv_forw_packet {
  * @bat_iface_update_mac: (re-)init mac addresses of the protocol information
  *  belonging to this hard-interface
  * @bat_primary_iface_set: called when primary interface is selected / changed
- * @bat_ogm_schedule: prepare a new outgoing OGM for the send queue
- * @bat_ogm_emit: send scheduled OGM
  * @bat_hardif_neigh_init: called on creation of single hop entry
  * @bat_neigh_cmp: compare the metrics of two neighbors for their respective
  *  outgoing interfaces
@@ -1294,8 +1292,6 @@ struct batadv_algo_ops {
 	void (*bat_iface_disable)(struct batadv_hard_iface *hard_iface);
 	void (*bat_iface_update_mac)(struct batadv_hard_iface *hard_iface);
 	void (*bat_primary_iface_set)(struct batadv_hard_iface *hard_iface);
-	void (*bat_ogm_schedule)(struct batadv_hard_iface *hard_iface);
-	void (*bat_ogm_emit)(struct batadv_forw_packet *forw_packet);
 	/* neigh_node handling API */
 	void (*bat_hardif_neigh_init)(struct batadv_hardif_neigh_node *neigh);
 	int (*bat_neigh_cmp)(struct batadv_neigh_node *neigh1,
-- 
2.8.1
