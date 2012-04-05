From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 12/16] batman-adv: don't let backbone
	gateways exchange tt entries
Date: Thu,  5 Apr 2012 12:38:58 +0200
Message-ID: <1333622342-6128-13-git-send-email-ordex@autistici.org>
References: <1333622342-6128-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1333622342-6128-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
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

As the backbone gateways are connected to the same backbone, they
should announce the same clients on the backbone non-exclusively.

Signed-off-by: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/bridge_loop_avoidance.c |   50 ++++++++++++++++++++++++++++++++
 net/batman-adv/bridge_loop_avoidance.h |    1 +
 net/batman-adv/routing.c               |    6 ++++
 net/batman-adv/translation-table.c     |   18 ++++++++++--
 4 files changed, 73 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index e8b4435..264ac65 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -24,6 +24,7 @@
 #include "hard-interface.h"
 #include "originator.h"
 #include "bridge_loop_avoidance.h"
+#include "translation-table.h"
 #include "send.h"
 
 #include <linux/etherdevice.h>
@@ -362,6 +363,7 @@ static struct backbone_gw *bla_get_backbone_gw(struct bat_priv *bat_priv,
 					       uint8_t *orig, short vid)
 {
 	struct backbone_gw *entry;
+	struct orig_node *orig_node;
 	int hash_added;
 
 	entry = backbone_hash_find(bat_priv, orig, vid);
@@ -396,6 +398,13 @@ static struct backbone_gw *bla_get_backbone_gw(struct bat_priv *bat_priv,
 		return NULL;
 	}
 
+	/* this is a gateway now, remove any tt entries */
+	orig_node = orig_hash_find(bat_priv, orig);
+	if (orig_node) {
+		tt_global_del_orig(bat_priv, orig_node,
+				   "became a backbone gateway");
+		orig_node_free_ref(orig_node);
+	}
 	return entry;
 }
 
@@ -1049,6 +1058,47 @@ int bla_init(struct bat_priv *bat_priv)
 }
 
 /**
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig: originator mac address
+ *
+ * check if the originator is a gateway for any VLAN ID.
+ *
+ * returns 1 if it is found, 0 otherwise
+ *
+ **/
+
+int bla_is_backbone_gw_orig(struct bat_priv *bat_priv, uint8_t *orig)
+{
+	struct hashtable_t *hash = bat_priv->backbone_hash;
+	struct hlist_head *head;
+	struct hlist_node *node;
+	struct backbone_gw *backbone_gw;
+	int i;
+
+	if (!atomic_read(&bat_priv->bridge_loop_avoidance))
+		return 0;
+
+	if (!hash)
+		return 0;
+
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(backbone_gw, node, head, hash_entry) {
+			if (compare_eth(backbone_gw->orig, orig)) {
+				rcu_read_unlock();
+				return 1;
+			}
+		}
+		rcu_read_unlock();
+	}
+
+	return 0;
+}
+
+
+/**
  * @skb: the frame to be checked
  * @orig_node: the orig_node of the frame
  * @hdr_size: maximum length of the frame
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index d9e3480..b74940f 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -27,6 +27,7 @@ int bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid);
 int bla_is_backbone_gw(struct sk_buff *skb,
 		       struct orig_node *orig_node, int hdr_size);
 int bla_claim_table_seq_print_text(struct seq_file *seq, void *offset);
+int bla_is_backbone_gw_orig(struct bat_priv *bat_priv, uint8_t *orig);
 void bla_update_orig_address(struct bat_priv *bat_priv,
 			     struct hard_iface *primary_if,
 			     struct hard_iface *oldif);
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index e70c37a..fb5e9f3 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -673,6 +673,12 @@ int recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_if)
 	if (!is_my_mac(roam_adv_packet->dst))
 		return route_unicast_packet(skb, recv_if);
 
+	/* check if it is a backbone gateway. we don't accept
+	 * roaming advertisement from it, as it has the same
+	 * entries as we have. */
+	if (bla_is_backbone_gw_orig(bat_priv, roam_adv_packet->src))
+		goto out;
+
 	orig_node = orig_hash_find(bat_priv, roam_adv_packet->src);
 	if (!orig_node)
 		goto out;
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 37b4569..b889806 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -27,6 +27,7 @@
 #include "hash.h"
 #include "originator.h"
 #include "routing.h"
+#include "bridge_loop_avoidance.h"
 
 #include <linux/crc16.h>
 
@@ -1611,10 +1612,15 @@ out:
 bool send_tt_response(struct bat_priv *bat_priv,
 		      struct tt_query_packet *tt_request)
 {
-	if (is_my_mac(tt_request->dst))
+	if (is_my_mac(tt_request->dst)) {
+		/* don't answer backbone gws! */
+		if (bla_is_backbone_gw_orig(bat_priv, tt_request->src))
+			return true;
+
 		return send_my_tt_response(bat_priv, tt_request);
-	else
+	} else {
 		return send_other_tt_response(bat_priv, tt_request);
+	}
 }
 
 static void _tt_update_changes(struct bat_priv *bat_priv,
@@ -1718,6 +1724,10 @@ void handle_tt_response(struct bat_priv *bat_priv,
 		tt_response->src, tt_response->ttvn, tt_response->tt_data,
 		(tt_response->flags & TT_FULL_TABLE ? 'F' : '.'));
 
+	/* we should have never asked a backbone gw */
+	if (bla_is_backbone_gw_orig(bat_priv, tt_response->src))
+		goto out;
+
 	orig_node = orig_hash_find(bat_priv, tt_response->src);
 	if (!orig_node)
 		goto out;
@@ -2048,6 +2058,10 @@ void tt_update_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
 	uint8_t orig_ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
 	bool full_table = true;
 
+	/* don't care about a backbone gateways updates. */
+	if (bla_is_backbone_gw_orig(bat_priv, orig_node->orig))
+		return;
+
 	/* orig table not initialised AND first diff is in the OGM OR the ttvn
 	 * increased by one -> we can apply the attached changes */
 	if ((!orig_node->tt_initialised && ttvn == 1) ||
-- 
1.7.9.4
