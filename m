From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 09/14] batman-adv: fix kernel crash due to missing NULL checks
Date: Tue,  4 Aug 2015 18:35:29 +0200
Message-ID: <1438706134-3492-10-git-send-email-antonio__22710.3738267489$1438707383$gmane$org@meshcoding.com>
References: <1438706134-3492-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:34658 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751972AbbHDQ4L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 12:56:11 -0400
In-Reply-To: <1438706134-3492-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

batadv_softif_vlan_get() may return NULL which has to be verified
by the caller.

Fixes: 35df3b298fc8 ("batman-adv: fix TT VLAN inconsistency on VLAN re-add")
Reported-by: Ryan Thompson <ryan@eero.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/soft-interface.c    |  3 +++
 net/batman-adv/translation-table.c | 18 ++++++++++++++----
 2 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index c002961..a2fc843 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -479,6 +479,9 @@ out:
  */
 void batadv_softif_vlan_free_ref(struct batadv_softif_vlan *vlan)
 {
+	if (!vlan)
+		return;
+
 	if (atomic_dec_and_test(&vlan->refcount)) {
 		spin_lock_bh(&vlan->bat_priv->softif_vlan_list_lock);
 		hlist_del_rcu(&vlan->list);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 1573489..2db3093 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -595,6 +595,9 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 
 	/* increase the refcounter of the related vlan */
 	vlan = batadv_softif_vlan_get(bat_priv, vid);
+	if (WARN(!vlan, "adding TT local entry %pM to non-existent VLAN %d",
+		 addr, BATADV_PRINT_VID(vid)))
+		goto out;
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Creating new local tt entry: %pM (vid: %d, ttvn: %d)\n",
@@ -1067,6 +1070,9 @@ uint16_t batadv_tt_local_remove(struct batadv_priv *bat_priv,
 
 	/* decrease the reference held for this vlan */
 	vlan = batadv_softif_vlan_get(bat_priv, vid);
+	if (!vlan)
+		goto out;
+
 	batadv_softif_vlan_free_ref(vlan);
 	batadv_softif_vlan_free_ref(vlan);
 
@@ -1167,8 +1173,10 @@ static void batadv_tt_local_table_free(struct batadv_priv *bat_priv)
 			/* decrease the reference held for this vlan */
 			vlan = batadv_softif_vlan_get(bat_priv,
 						      tt_common_entry->vid);
-			batadv_softif_vlan_free_ref(vlan);
-			batadv_softif_vlan_free_ref(vlan);
+			if (vlan) {
+				batadv_softif_vlan_free_ref(vlan);
+				batadv_softif_vlan_free_ref(vlan);
+			}
 
 			batadv_tt_local_entry_free_ref(tt_local);
 		}
@@ -3208,8 +3216,10 @@ static void batadv_tt_local_purge_pending_clients(struct batadv_priv *bat_priv)
 
 			/* decrease the reference held for this vlan */
 			vlan = batadv_softif_vlan_get(bat_priv, tt_common->vid);
-			batadv_softif_vlan_free_ref(vlan);
-			batadv_softif_vlan_free_ref(vlan);
+			if (vlan) {
+				batadv_softif_vlan_free_ref(vlan);
+				batadv_softif_vlan_free_ref(vlan);
+			}
 
 			batadv_tt_local_entry_free_ref(tt_local);
 		}
-- 
2.5.0
