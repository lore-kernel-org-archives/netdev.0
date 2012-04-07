From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 12/16] batman-adv: don't let backbone gateways exchange tt entries
Date: Sat,  7 Apr 2012 20:49:54 +0200
Message-ID: <1333824598-27771-13-git-send-email-ordex@autistici.org>
References: <1333824598-27771-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:61145 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754661Ab2DGStf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Apr 2012 14:49:35 -0400
In-Reply-To: <1333824598-27771-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>

As the backbone gateways are connected to the same backbone, they
should announce the same clients on the backbone non-exclusively.

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bridge_loop_avoidance.c |   50 ++++++++++++++++++++++++++++++++
 net/batman-adv/bridge_loop_avoidance.h |    1 +
 net/batman-adv/routing.c               |    7 +++++
 net/batman-adv/translation-table.c     |   18 ++++++++++--
 4 files changed, 74 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 56b9b49..6186f6e 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -24,6 +24,7 @@
 #include "hard-interface.h"
 #include "originator.h"
 #include "bridge_loop_avoidance.h"
+#include "translation-table.h"
 #include "send.h"
 
 #include <linux/etherdevice.h>
@@ -359,6 +360,7 @@ static struct backbone_gw *bla_get_backbone_gw(struct bat_priv *bat_priv,
 					       uint8_t *orig, short vid)
 {
 	struct backbone_gw *entry;
+	struct orig_node *orig_node;
 	int hash_added;
 
 	entry = backbone_hash_find(bat_priv, orig, vid);
@@ -393,6 +395,13 @@ static struct backbone_gw *bla_get_backbone_gw(struct bat_priv *bat_priv,
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
 
@@ -1050,6 +1059,47 @@ int bla_init(struct bat_priv *bat_priv)
 }
 
 /**
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig: originator mac address
+ *
+ * check if the originator is a gateway for any VLAN ID.
+ *
+ * returns 1 if it is found, 0 otherwise
+ *
+ */
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
index a1d8c9b..1d1fd04 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -673,6 +673,13 @@ int recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_if)
 	if (!is_my_mac(roam_adv_packet->dst))
 		return route_unicast_packet(skb, recv_if);
 
+	/* check if it is a backbone gateway. we don't accept
+	 * roaming advertisement from it, as it has the same
+	 * entries as we have.
+	 */
+	if (bla_is_backbone_gw_orig(bat_priv, roam_adv_packet->src))
+		goto out;
+
 	orig_node = orig_hash_find(bat_priv, roam_adv_packet->src);
 	if (!orig_node)
 		goto out;
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 9648b0d..e16a369 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -27,6 +27,7 @@
 #include "hash.h"
 #include "originator.h"
 #include "routing.h"
+#include "bridge_loop_avoidance.h"
 
 #include <linux/crc16.h>
 
@@ -1615,10 +1616,15 @@ out:
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
@@ -1722,6 +1728,10 @@ void handle_tt_response(struct bat_priv *bat_priv,
 		tt_response->src, tt_response->ttvn, tt_response->tt_data,
 		(tt_response->flags & TT_FULL_TABLE ? 'F' : '.'));
 
+	/* we should have never asked a backbone gw */
+	if (bla_is_backbone_gw_orig(bat_priv, tt_response->src))
+		goto out;
+
 	orig_node = orig_hash_find(bat_priv, tt_response->src);
 	if (!orig_node)
 		goto out;
@@ -2052,6 +2062,10 @@ void tt_update_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
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
