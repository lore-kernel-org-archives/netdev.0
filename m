From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 13/19] batman-adv: iv_ogm, Reduce code duplication
Date: Fri, 12 Aug 2016 10:56:49 +0200
Message-ID: <1470992215-11009-14-git-send-email-sw@simonwunderlich.de>
References: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Markus Pargmann <mpa@pengutronix.de>,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:35023 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752420AbcHLI5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 04:57:31 -0400
In-Reply-To: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Pargmann <mpa@pengutronix.de>

The difference between tq1 and tq2 are calculated the same way in two
separate functions.

This patch moves the common code to a separate function
'batadv_iv_ogm_neigh_diff' which handles everything necessary. The other
two functions can then handle errors and use the difference directly.

Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
[sven@narfation.org: rebased on current version, initialize return variable
in batadv_iv_ogm_neigh_diff, add kerneldoc, convert to bool return type]
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bat_iv_ogm.c | 77 +++++++++++++++++++++++++++------------------
 1 file changed, 47 insertions(+), 30 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index d04874f..57e0af9 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -2019,35 +2019,40 @@ static void batadv_iv_neigh_print(struct batadv_priv *bat_priv,
 }
 
 /**
- * batadv_iv_ogm_neigh_cmp - compare the metrics of two neighbors
+ * batadv_iv_ogm_neigh_diff - calculate tq difference of two neighbors
  * @neigh1: the first neighbor object of the comparison
  * @if_outgoing1: outgoing interface for the first neighbor
  * @neigh2: the second neighbor object of the comparison
  * @if_outgoing2: outgoing interface for the second neighbor
+ * @diff: pointer to integer receiving the calculated difference
  *
- * Return: a value less, equal to or greater than 0 if the metric via neigh1 is
- * lower, the same as or higher than the metric via neigh2
+ * The content of *@diff is only valid when this function returns true.
+ * It is less, equal to or greater than 0 if the metric via neigh1 is lower,
+ * the same as or higher than the metric via neigh2
+ *
+ * Return: true when the difference could be calculated, false otherwise
  */
-static int batadv_iv_ogm_neigh_cmp(struct batadv_neigh_node *neigh1,
-				   struct batadv_hard_iface *if_outgoing1,
-				   struct batadv_neigh_node *neigh2,
-				   struct batadv_hard_iface *if_outgoing2)
+static bool batadv_iv_ogm_neigh_diff(struct batadv_neigh_node *neigh1,
+				     struct batadv_hard_iface *if_outgoing1,
+				     struct batadv_neigh_node *neigh2,
+				     struct batadv_hard_iface *if_outgoing2,
+				     int *diff)
 {
 	struct batadv_neigh_ifinfo *neigh1_ifinfo, *neigh2_ifinfo;
 	u8 tq1, tq2;
-	int diff;
+	bool ret = true;
 
 	neigh1_ifinfo = batadv_neigh_ifinfo_get(neigh1, if_outgoing1);
 	neigh2_ifinfo = batadv_neigh_ifinfo_get(neigh2, if_outgoing2);
 
 	if (!neigh1_ifinfo || !neigh2_ifinfo) {
-		diff = 0;
+		ret = false;
 		goto out;
 	}
 
 	tq1 = neigh1_ifinfo->bat_iv.tq_avg;
 	tq2 = neigh2_ifinfo->bat_iv.tq_avg;
-	diff = tq1 - tq2;
+	*diff = (int)tq1 - (int)tq2;
 
 out:
 	if (neigh1_ifinfo)
@@ -2055,6 +2060,32 @@ out:
 	if (neigh2_ifinfo)
 		batadv_neigh_ifinfo_put(neigh2_ifinfo);
 
+	return ret;
+}
+
+/**
+ * batadv_iv_ogm_neigh_cmp - compare the metrics of two neighbors
+ * @neigh1: the first neighbor object of the comparison
+ * @if_outgoing1: outgoing interface for the first neighbor
+ * @neigh2: the second neighbor object of the comparison
+ * @if_outgoing2: outgoing interface for the second neighbor
+ *
+ * Return: a value less, equal to or greater than 0 if the metric via neigh1 is
+ * lower, the same as or higher than the metric via neigh2
+ */
+static int batadv_iv_ogm_neigh_cmp(struct batadv_neigh_node *neigh1,
+				   struct batadv_hard_iface *if_outgoing1,
+				   struct batadv_neigh_node *neigh2,
+				   struct batadv_hard_iface *if_outgoing2)
+{
+	bool ret;
+	int diff;
+
+	ret = batadv_iv_ogm_neigh_diff(neigh1, if_outgoing1, neigh2,
+				       if_outgoing2, &diff);
+	if (!ret)
+		return 0;
+
 	return diff;
 }
 
@@ -2075,29 +2106,15 @@ batadv_iv_ogm_neigh_is_sob(struct batadv_neigh_node *neigh1,
 			   struct batadv_neigh_node *neigh2,
 			   struct batadv_hard_iface *if_outgoing2)
 {
-	struct batadv_neigh_ifinfo *neigh1_ifinfo, *neigh2_ifinfo;
-	u8 tq1, tq2;
 	bool ret;
+	int diff;
 
-	neigh1_ifinfo = batadv_neigh_ifinfo_get(neigh1, if_outgoing1);
-	neigh2_ifinfo = batadv_neigh_ifinfo_get(neigh2, if_outgoing2);
-
-	/* we can't say that the metric is better */
-	if (!neigh1_ifinfo || !neigh2_ifinfo) {
-		ret = false;
-		goto out;
-	}
-
-	tq1 = neigh1_ifinfo->bat_iv.tq_avg;
-	tq2 = neigh2_ifinfo->bat_iv.tq_avg;
-	ret = (tq1 - tq2) > -BATADV_TQ_SIMILARITY_THRESHOLD;
-
-out:
-	if (neigh1_ifinfo)
-		batadv_neigh_ifinfo_put(neigh1_ifinfo);
-	if (neigh2_ifinfo)
-		batadv_neigh_ifinfo_put(neigh2_ifinfo);
+	ret = batadv_iv_ogm_neigh_diff(neigh1, if_outgoing1, neigh2,
+				       if_outgoing2, &diff);
+	if (!ret)
+		return false;
 
+	ret = diff > -BATADV_TQ_SIMILARITY_THRESHOLD;
 	return ret;
 }
 
-- 
2.8.1
