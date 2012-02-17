From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 01/10] batman-adv: add tt_initialised flag to the orig_node struct
Date: Fri, 17 Feb 2012 15:18:21 +0800
Message-ID: <1329463110-856-2-git-send-email-lindner_marek@yahoo.de>
References: <1329463110-856-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm17.bullet.mail.ukl.yahoo.com ([217.146.183.191]:23977 "HELO
	nm17.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751163Ab2BQHSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 02:18:49 -0500
In-Reply-To: <1329463110-856-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

(ttvn == 0) is currently used as initial condition. However this is not a good
idea because ttvn gets the vale zero each time after reaching the maximum value
(wrap around). For this reason a new flag is added in order to define whether a
node has an initialised table or not. Moreover, after invoking
tt_global_del_orig(), tt_initialised has to be set to false

Reported-by: Alexey Fisher <bug-track@fisher-privat.net>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Tested-by: Alexey Fisher <bug-track@fisher-privat.net>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/originator.c        |    1 +
 net/batman-adv/translation-table.c |   11 ++++++++---
 net/batman-adv/types.h             |    1 +
 3 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 0bc2045..847ff7e 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -219,6 +219,7 @@ struct orig_node *get_orig_node(struct bat_priv *bat_priv, const uint8_t *addr)
 	/* extra reference for return */
 	atomic_set(&orig_node->refcount, 2);
 
+	orig_node->tt_initialised = false;
 	orig_node->tt_poss_change = false;
 	orig_node->bat_priv = bat_priv;
 	memcpy(orig_node->orig, addr, ETH_ALEN);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index ab8dea8..c632475 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -733,6 +733,7 @@ void tt_global_del_orig(struct bat_priv *bat_priv,
 		spin_unlock_bh(list_lock);
 	}
 	atomic_set(&orig_node->tt_size, 0);
+	orig_node->tt_initialised = false;
 }
 
 static void tt_global_roam_purge(struct bat_priv *bat_priv)
@@ -1450,6 +1451,7 @@ static void _tt_update_changes(struct bat_priv *bat_priv,
 				 */
 				return;
 	}
+	orig_node->tt_initialised = true;
 }
 
 static void tt_fill_gtable(struct bat_priv *bat_priv,
@@ -1854,8 +1856,10 @@ void tt_update_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
 	uint8_t orig_ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
 	bool full_table = true;
 
-	/* the ttvn increased by one -> we can apply the attached changes */
-	if (ttvn - orig_ttvn == 1) {
+	/* orig table not initialised AND first diff is in the OGM OR the ttvn
+	 * increased by one -> we can apply the attached changes */
+	if ((!orig_node->tt_initialised && ttvn == 1) ||
+	    ttvn - orig_ttvn == 1) {
 		/* the OGM could not contain the changes due to their size or
 		 * because they have already been sent TT_OGM_APPEND_MAX times.
 		 * In this case send a tt request */
@@ -1889,7 +1893,8 @@ void tt_update_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
 	} else {
 		/* if we missed more than one change or our tables are not
 		 * in sync anymore -> request fresh tt data */
-		if (ttvn != orig_ttvn || orig_node->tt_crc != tt_crc) {
+		if (!orig_node->tt_initialised || ttvn != orig_ttvn ||
+		    orig_node->tt_crc != tt_crc) {
 request_table:
 			bat_dbg(DBG_TT, bat_priv, "TT inconsistency for %pM. "
 				"Need to retrieve the correct information "
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index e9eb043..35085f41 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -81,6 +81,7 @@ struct orig_node {
 	int16_t tt_buff_len;
 	spinlock_t tt_buff_lock; /* protects tt_buff */
 	atomic_t tt_size;
+	bool tt_initialised;
 	/* The tt_poss_change flag is used to detect an ongoing roaming phase.
 	 * If true, then I sent a Roaming_adv to this orig_node and I have to
 	 * inspect every packet directed to it to check whether it is still
-- 
1.7.9
