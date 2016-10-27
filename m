From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 12/17] batman-adv: Less function calls in batadv_is_ap_isolated() after error detection
Date: Thu, 27 Oct 2016 21:01:45 +0200
Message-ID: <20161027190150.7880-13-sw@simonwunderlich.de>
References: <20161027190150.7880-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Markus Elfring <elfring@users.sourceforge.net>,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:38350 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942590AbcJ0TB7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 15:01:59 -0400
In-Reply-To: <20161027190150.7880-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>

The variables "tt_local_entry" and "tt_global_entry" were eventually
checked again despite of a corresponding null pointer test before.

* Avoid this double check by reordering a function call sequence
  and the better selection of jump targets.

* Omit the initialisation for these variables at the beginning then.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/translation-table.c | 25 +++++++++++--------------
 1 file changed, 11 insertions(+), 14 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 7f66309..ad1e3bc 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -3835,8 +3835,8 @@ void batadv_tt_local_commit_changes(struct batadv_priv *bat_priv)
 bool batadv_is_ap_isolated(struct batadv_priv *bat_priv, u8 *src, u8 *dst,
 			   unsigned short vid)
 {
-	struct batadv_tt_local_entry *tt_local_entry = NULL;
-	struct batadv_tt_global_entry *tt_global_entry = NULL;
+	struct batadv_tt_local_entry *tt_local_entry;
+	struct batadv_tt_global_entry *tt_global_entry;
 	struct batadv_softif_vlan *vlan;
 	bool ret = false;
 
@@ -3845,27 +3845,24 @@ bool batadv_is_ap_isolated(struct batadv_priv *bat_priv, u8 *src, u8 *dst,
 		return false;
 
 	if (!atomic_read(&vlan->ap_isolation))
-		goto out;
+		goto vlan_put;
 
 	tt_local_entry = batadv_tt_local_hash_find(bat_priv, dst, vid);
 	if (!tt_local_entry)
-		goto out;
+		goto vlan_put;
 
 	tt_global_entry = batadv_tt_global_hash_find(bat_priv, src, vid);
 	if (!tt_global_entry)
-		goto out;
-
-	if (!_batadv_is_ap_isolated(tt_local_entry, tt_global_entry))
-		goto out;
+		goto local_entry_put;
 
-	ret = true;
+	if (_batadv_is_ap_isolated(tt_local_entry, tt_global_entry))
+		ret = true;
 
-out:
+	batadv_tt_global_entry_put(tt_global_entry);
+local_entry_put:
+	batadv_tt_local_entry_put(tt_local_entry);
+vlan_put:
 	batadv_softif_vlan_put(vlan);
-	if (tt_global_entry)
-		batadv_tt_global_entry_put(tt_global_entry);
-	if (tt_local_entry)
-		batadv_tt_local_entry_put(tt_local_entry);
 	return ret;
 }
 
-- 
2.10.1
