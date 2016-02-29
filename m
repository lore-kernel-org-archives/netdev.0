From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 11/15] batman-adv: B.A.T.M.A.N. V - implement neighbor comparison API calls
Date: Mon, 29 Feb 2016 19:06:04 +0800
Message-ID: <1456743968-17562-12-git-send-email-a__14881.3393935145$1456746056$gmane$org@unstable.cc>
References: <1456743968-17562-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:7369 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753848AbcB2Lku (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 06:40:50 -0500
In-Reply-To: <1456743968-17562-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/bat_v.c | 38 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 38 insertions(+)

diff --git a/net/batman-adv/bat_v.c b/net/batman-adv/bat_v.c
index ff31f2af9cfe..953c0d150231 100644
--- a/net/batman-adv/bat_v.c
+++ b/net/batman-adv/bat_v.c
@@ -19,12 +19,15 @@
 #include "main.h"
 
 #include <linux/atomic.h>
+#include <linux/bug.h>
 #include <linux/cache.h>
 #include <linux/init.h>
+#include <linux/types.h>
 #include <linux/workqueue.h>
 
 #include "bat_v_elp.h"
 #include "bat_v_ogm.h"
+#include "originator.h"
 #include "packet.h"
 
 static int batadv_v_iface_enable(struct batadv_hard_iface *hard_iface)
@@ -78,6 +81,39 @@ static void batadv_v_ogm_emit(struct batadv_forw_packet *forw_packet)
 {
 }
 
+static int batadv_v_neigh_cmp(struct batadv_neigh_node *neigh1,
+			      struct batadv_hard_iface *if_outgoing1,
+			      struct batadv_neigh_node *neigh2,
+			      struct batadv_hard_iface *if_outgoing2)
+{
+	struct batadv_neigh_ifinfo *ifinfo1, *ifinfo2;
+
+	ifinfo1 = batadv_neigh_ifinfo_get(neigh1, if_outgoing1);
+	ifinfo2 = batadv_neigh_ifinfo_get(neigh2, if_outgoing2);
+
+	if (WARN_ON(!ifinfo1 || !ifinfo2))
+		return 0;
+
+	return ifinfo1->bat_v.throughput - ifinfo2->bat_v.throughput;
+}
+
+static bool batadv_v_neigh_is_sob(struct batadv_neigh_node *neigh1,
+				  struct batadv_hard_iface *if_outgoing1,
+				  struct batadv_neigh_node *neigh2,
+				  struct batadv_hard_iface *if_outgoing2)
+{
+	struct batadv_neigh_ifinfo *ifinfo1, *ifinfo2;
+	u32 threshold;
+
+	ifinfo1 = batadv_neigh_ifinfo_get(neigh1, if_outgoing1);
+	ifinfo2 = batadv_neigh_ifinfo_get(neigh2, if_outgoing2);
+
+	threshold = ifinfo1->bat_v.throughput / 4;
+	threshold = ifinfo1->bat_v.throughput - threshold;
+
+	return ifinfo2->bat_v.throughput > threshold;
+}
+
 static struct batadv_algo_ops batadv_batman_v __read_mostly = {
 	.name = "BATMAN_V",
 	.bat_iface_enable = batadv_v_iface_enable,
@@ -87,6 +123,8 @@ static struct batadv_algo_ops batadv_batman_v __read_mostly = {
 	.bat_hardif_neigh_init = batadv_v_hardif_neigh_init,
 	.bat_ogm_emit = batadv_v_ogm_emit,
 	.bat_ogm_schedule = batadv_v_ogm_schedule,
+	.bat_neigh_cmp = batadv_v_neigh_cmp,
+	.bat_neigh_is_similar_or_better = batadv_v_neigh_is_sob,
 };
 
 /**
-- 
2.7.2
