From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 12/13] batman-adv: create helper function to get AP isolation status
Date: Thu,  9 Jan 2014 15:53:01 +0100
Message-ID: <1389279182-3256-13-git-send-email-antonio@meshcoding.com>
References: <1389279182-3256-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:10800 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266AbaAIO4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 09:56:42 -0500
In-Reply-To: <1389279182-3256-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

The AP isolation status may be evaluated in different spots.
Create an helper function to avoid code duplication.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/main.c              | 26 ++++++++++++++++++++++++++
 net/batman-adv/main.h              |  1 +
 net/batman-adv/translation-table.c | 13 +------------
 3 files changed, 28 insertions(+), 12 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 8abda42..945e441 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -1171,6 +1171,32 @@ unsigned short batadv_get_vid(struct sk_buff *skb, size_t header_len)
 	return vid;
 }
 
+/**
+ * batadv_vlan_ap_isola_get - return the AP isolation status for the given vlan
+ * @bat_priv: the bat priv with all the soft interface information
+ * @vid: the VLAN identifier for which the AP isolation attributed as to be
+ *  looked up
+ *
+ * Returns true if AP isolation is on for the VLAN idenfied by vid, false
+ * otherwise
+ */
+bool batadv_vlan_ap_isola_get(struct batadv_priv *bat_priv, unsigned short vid)
+{
+	bool ap_isolation_enabled = false;
+	struct batadv_softif_vlan *vlan;
+
+	/* if the AP isolation is requested on a VLAN, then check for its
+	 * setting in the proper VLAN private data structure
+	 */
+	vlan = batadv_softif_vlan_get(bat_priv, vid);
+	if (vlan) {
+		ap_isolation_enabled = atomic_read(&vlan->ap_isolation);
+		batadv_softif_vlan_free_ref(vlan);
+	}
+
+	return ap_isolation_enabled;
+}
+
 static int batadv_param_set_ra(const char *val, const struct kernel_param *kp)
 {
 	struct batadv_algo_ops *bat_algo_ops;
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index fa9edbf..a468760 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -369,5 +369,6 @@ void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, uint8_t *src,
 			      uint8_t *dst, uint8_t type, uint8_t version,
 			      void *tvlv_value, uint16_t tvlv_value_len);
 unsigned short batadv_get_vid(struct sk_buff *skb, size_t header_len);
+bool batadv_vlan_ap_isola_get(struct batadv_priv *bat_priv, unsigned short vid);
 
 #endif /* _NET_BATMAN_ADV_MAIN_H_ */
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index a874d08..1337b69 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1900,19 +1900,8 @@ struct batadv_orig_node *batadv_transtable_search(struct batadv_priv *bat_priv,
 	struct batadv_tt_global_entry *tt_global_entry = NULL;
 	struct batadv_orig_node *orig_node = NULL;
 	struct batadv_tt_orig_list_entry *best_entry;
-	bool ap_isolation_enabled = false;
-	struct batadv_softif_vlan *vlan;
 
-	/* if the AP isolation is requested on a VLAN, then check for its
-	 * setting in the proper VLAN private data structure
-	 */
-	vlan = batadv_softif_vlan_get(bat_priv, vid);
-	if (vlan) {
-		ap_isolation_enabled = atomic_read(&vlan->ap_isolation);
-		batadv_softif_vlan_free_ref(vlan);
-	}
-
-	if (src && ap_isolation_enabled) {
+	if (src && batadv_vlan_ap_isola_get(bat_priv, vid)) {
 		tt_local_entry = batadv_tt_local_hash_find(bat_priv, src, vid);
 		if (!tt_local_entry ||
 		    (tt_local_entry->common.flags & BATADV_TT_CLIENT_PENDING))
-- 
1.8.5.2
