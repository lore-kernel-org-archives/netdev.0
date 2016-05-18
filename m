From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 3/8] batman-adv: Fix refcnt leak in batadv_v_neigh_*
Date: Wed, 18 May 2016 13:04:47 +0800
Message-ID: <1463547892-11290-4-git-send-email-a@unstable.cc>
References: <1463547892-11290-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:42052 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751218AbcERFGN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2016 01:06:13 -0400
In-Reply-To: <1463547892-11290-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The functions batadv_neigh_ifinfo_get increase the reference counter of the
batadv_neigh_ifinfo. These have to be reduced again when the reference is
not used anymore to correctly free the objects.

Fixes: 9786906022eb ("batman-adv: B.A.T.M.A.N. V - implement neighbor comparison API calls")
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bat_v.c | 32 +++++++++++++++++++++++++-------
 1 file changed, 25 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/bat_v.c b/net/batman-adv/bat_v.c
index 50bfcf87f569..4f626a6b8ebd 100644
--- a/net/batman-adv/bat_v.c
+++ b/net/batman-adv/bat_v.c
@@ -256,14 +256,23 @@ static int batadv_v_neigh_cmp(struct batadv_neigh_node *neigh1,
 			      struct batadv_hard_iface *if_outgoing2)
 {
 	struct batadv_neigh_ifinfo *ifinfo1, *ifinfo2;
+	int ret = 0;
 
 	ifinfo1 = batadv_neigh_ifinfo_get(neigh1, if_outgoing1);
+	if (WARN_ON(!ifinfo1))
+		goto err_ifinfo1;
+
 	ifinfo2 = batadv_neigh_ifinfo_get(neigh2, if_outgoing2);
+	if (WARN_ON(!ifinfo2))
+		goto err_ifinfo2;
 
-	if (WARN_ON(!ifinfo1 || !ifinfo2))
-		return 0;
+	ret = ifinfo1->bat_v.throughput - ifinfo2->bat_v.throughput;
 
-	return ifinfo1->bat_v.throughput - ifinfo2->bat_v.throughput;
+	batadv_neigh_ifinfo_put(ifinfo2);
+err_ifinfo2:
+	batadv_neigh_ifinfo_put(ifinfo1);
+err_ifinfo1:
+	return ret;
 }
 
 static bool batadv_v_neigh_is_sob(struct batadv_neigh_node *neigh1,
@@ -273,17 +282,26 @@ static bool batadv_v_neigh_is_sob(struct batadv_neigh_node *neigh1,
 {
 	struct batadv_neigh_ifinfo *ifinfo1, *ifinfo2;
 	u32 threshold;
+	bool ret = false;
 
 	ifinfo1 = batadv_neigh_ifinfo_get(neigh1, if_outgoing1);
-	ifinfo2 = batadv_neigh_ifinfo_get(neigh2, if_outgoing2);
+	if (WARN_ON(!ifinfo1))
+		goto err_ifinfo1;
 
-	if (WARN_ON(!ifinfo1 || !ifinfo2))
-		return false;
+	ifinfo2 = batadv_neigh_ifinfo_get(neigh2, if_outgoing2);
+	if (WARN_ON(!ifinfo2))
+		goto err_ifinfo2;
 
 	threshold = ifinfo1->bat_v.throughput / 4;
 	threshold = ifinfo1->bat_v.throughput - threshold;
 
-	return ifinfo2->bat_v.throughput > threshold;
+	ret = ifinfo2->bat_v.throughput > threshold;
+
+	batadv_neigh_ifinfo_put(ifinfo2);
+err_ifinfo2:
+	batadv_neigh_ifinfo_put(ifinfo1);
+err_ifinfo1:
+	return ret;
 }
 
 static struct batadv_algo_ops batadv_batman_v __read_mostly = {
-- 
2.8.2
