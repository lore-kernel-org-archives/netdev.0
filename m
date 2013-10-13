From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 14/16] batman-adv: implement batadv_tt_entries
Date: Sun, 13 Oct 2013 13:22:59 +0200
Message-ID: <1381663381-626-15-git-send-email-antonio@meshcoding.com>
References: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:13178 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753246Ab3JMLwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 07:52:50 -0400
In-Reply-To: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Implement batadv_tt_entries() to get the number of entries
fitting in a given amount of bytes. This computation is done
several times in the code and therefore it is useful to have
an helper function.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/translation-table.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 34fa6cc..58636a7 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -232,6 +232,17 @@ static int batadv_tt_len(int changes_num)
 	return changes_num * sizeof(struct batadv_tvlv_tt_change);
 }
 
+/**
+ * batadv_tt_entries - compute the number of entries fitting in tt_len bytes
+ * @tt_len: available space
+ *
+ * Returns the number of entries.
+ */
+static uint16_t batadv_tt_entries(uint16_t tt_len)
+{
+	return tt_len / batadv_tt_len(1);
+}
+
 static int batadv_tt_local_init(struct batadv_priv *bat_priv)
 {
 	if (bat_priv->tt.local_hash)
@@ -406,7 +417,7 @@ static void batadv_tt_tvlv_container_update(struct batadv_priv *bat_priv)
 	if (tt_diff_len == 0)
 		goto container_register;
 
-	tt_diff_entries_num = tt_diff_len / batadv_tt_len(1);
+	tt_diff_entries_num = batadv_tt_entries(tt_diff_len);
 
 	spin_lock_bh(&bat_priv->tt.changes_list_lock);
 	atomic_set(&bat_priv->tt.local_changes, 0);
@@ -1616,7 +1627,7 @@ batadv_tt_tvlv_generate(struct batadv_priv *bat_priv,
 		tt_len -= tt_len % sizeof(struct batadv_tvlv_tt_change);
 	}
 
-	tt_tot = tt_len / sizeof(struct batadv_tvlv_tt_change);
+	tt_tot = batadv_tt_entries(tt_len);
 
 	tvlv_tt_data = kzalloc(sizeof(*tvlv_tt_data) + tt_len,
 			       GFP_ATOMIC);
@@ -2567,7 +2578,7 @@ static void batadv_tt_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
 	tt_data = (struct batadv_tvlv_tt_data *)tvlv_value;
 	tvlv_value_len -= sizeof(*tt_data);
 
-	num_entries = tvlv_value_len / batadv_tt_len(1);
+	num_entries = batadv_tt_entries(tvlv_value_len);
 
 	batadv_tt_update_orig(bat_priv, orig,
 			      (unsigned char *)(tt_data + 1),
@@ -2602,7 +2613,7 @@ static int batadv_tt_tvlv_unicast_handler_v1(struct batadv_priv *bat_priv,
 	tt_data = (struct batadv_tvlv_tt_data *)tvlv_value;
 	tvlv_value_len -= sizeof(*tt_data);
 
-	num_entries = tvlv_value_len / batadv_tt_len(1);
+	num_entries = batadv_tt_entries(tvlv_value_len);
 
 	switch (tt_data->flags & BATADV_TT_DATA_TYPE_MASK) {
 	case BATADV_TT_REQUEST:
-- 
1.8.3.2
