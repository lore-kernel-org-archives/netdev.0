From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/3] batman-adv: Less function calls in
 batadv_is_ap_isolated() after error detection
Date: Tue, 3 Nov 2015 21:56:19 +0100
Message-ID: <56391F73.7090605@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net>
 <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
 <530A086E.8010901@users.sourceforge.net>
 <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
 <530A72AA.3000601@users.sourceforge.net>
 <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
 <530B5FB6.6010207@users.sourceforge.net>
 <alpine.DEB.2.10.1402241710370.2074@hadrien>
 <530C5E18.1020800@users.sourceforge.net>
 <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net> <56391CF7.9080400@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Antonio Quartulli <antonio@meshcoding.com>,
	"David S. Miller" <davem@davemloft.net>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <56391CF7.9080400@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 3 Nov 2015 21:10:51 +0100

The variables "tt_local_entry" and "tt_global_entry" were eventually checked
again despite of a corresponding null pointer test before.
Let us avoid this double check by reordering a function call sequence
and the better selection of jump targets.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/batman-adv/translation-table.c | 21 +++++++++------------
 1 file changed, 9 insertions(+), 12 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 965a004..3ac32d9 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -3323,27 +3323,24 @@ bool batadv_is_ap_isolated(struct batadv_priv *bat_priv, u8 *src, u8 *dst,
 		return false;
 
 	if (!atomic_read(&vlan->ap_isolation))
-		goto out;
+		goto vlan_free;
 
 	tt_local_entry = batadv_tt_local_hash_find(bat_priv, dst, vid);
 	if (!tt_local_entry)
-		goto out;
+		goto vlan_free;
 
 	tt_global_entry = batadv_tt_global_hash_find(bat_priv, src, vid);
 	if (!tt_global_entry)
-		goto out;
+		goto local_entry_free;
 
-	if (!_batadv_is_ap_isolated(tt_local_entry, tt_global_entry))
-		goto out;
-
-	ret = true;
+	if (_batadv_is_ap_isolated(tt_local_entry, tt_global_entry))
+		ret = true;
 
-out:
+	batadv_tt_global_entry_free_ref(tt_global_entry);
+local_entry_free:
+	batadv_tt_local_entry_free_ref(tt_local_entry);
+vlan_free:
 	batadv_softif_vlan_free_ref(vlan);
-	if (tt_global_entry)
-		batadv_tt_global_entry_free_ref(tt_global_entry);
-	if (tt_local_entry)
-		batadv_tt_local_entry_free_ref(tt_local_entry);
 	return ret;
 }
 
-- 
2.6.2

