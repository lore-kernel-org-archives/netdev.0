From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] batman-adv: Less function calls in batadv_is_ap_isolated()
 after error detection
Date: Fri, 11 Mar 2016 13:40:56 +0100
Message-ID: <56E2BCD8.9010200@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net>
 <564EDE1D.7070809@meshcoding.com> <564EFC67.7050307@users.sourceforge.net>
 <1655341.WCvHHx7pqD@bentobox>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	Antonio Quartulli <a@unstable.cc>,
	"David S. Miller" <davem@davemloft.net>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Sven Eckelmann <sven@narfation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:60119 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752320AbcCKMlQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 07:41:16 -0500
In-Reply-To: <1655341.WCvHHx7pqD@bentobox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 11 Mar 2016 13:10:20 +0100

The variables "tt_local_entry" and "tt_global_entry" were eventually
checked again despite of a corresponding null pointer test before.

* Avoid this double check by reordering a function call sequence
  and the better selection of jump targets.

* Omit the initialisation for these variables at the beginning then.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/batman-adv/translation-table.c | 25 +++++++++++--------------
 1 file changed, 11 insertions(+), 14 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 0b43e86..9c0193ee 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -3403,8 +3403,8 @@ void batadv_tt_local_commit_changes(struct batadv_priv *bat_priv)
 bool batadv_is_ap_isolated(struct batadv_priv *bat_priv, u8 *src, u8 *dst,
 			   unsigned short vid)
 {
-	struct batadv_tt_local_entry *tt_local_entry = NULL;
-	struct batadv_tt_global_entry *tt_global_entry = NULL;
+	struct batadv_tt_local_entry *tt_local_entry;
+	struct batadv_tt_global_entry *tt_global_entry;
 	struct batadv_softif_vlan *vlan;
 	bool ret = false;
 
@@ -3413,27 +3413,24 @@ bool batadv_is_ap_isolated(struct batadv_priv *bat_priv, u8 *src, u8 *dst,
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
2.7.2
