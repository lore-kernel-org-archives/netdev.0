From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 04/16] batman-adv: add bat_neigh_cmp API function
Date: Wed, 23 Oct 2013 18:04:51 +0200
Message-ID: <1382544303-2694-5-git-send-email-antonio@meshcoding.com>
References: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:6986 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752347Ab3JWQFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 12:05:51 -0400
In-Reply-To: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

This new API allows to compare the two neighbours based on
the metric avoiding the user to deal with any routing
algorithm specific detail

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bat_iv_ogm.c | 20 ++++++++++++++++++++
 net/batman-adv/main.c       |  3 ++-
 net/batman-adv/types.h      |  3 +++
 3 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 4aabd55..b288d90 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1475,6 +1475,25 @@ next:
 		seq_puts(seq, "No batman nodes in range ...\n");
 }
 
+/**
+ * batadv_iv_ogm_neigh_cmp - compare the metrics of two neighbors
+ * @neigh1: the first neighbor object of the comparison
+ * @neigh2: the second neighbor object of the comparison
+ *
+ * Returns a value less, equal to or greater than 0 if the metric via neigh1 is
+ * lower, the same as or higher than the metric via neigh2
+ */
+static int batadv_iv_ogm_neigh_cmp(struct batadv_neigh_node *neigh1,
+				   struct batadv_neigh_node *neigh2)
+{
+	uint8_t tq1, tq2;
+
+	tq1 = neigh1->bat_iv.tq_avg;
+	tq2 = neigh2->bat_iv.tq_avg;
+
+	return tq1 - tq2;
+}
+
 static struct batadv_algo_ops batadv_batman_iv __read_mostly = {
 	.name = "BATMAN_IV",
 	.bat_iface_enable = batadv_iv_ogm_iface_enable,
@@ -1483,6 +1502,7 @@ static struct batadv_algo_ops batadv_batman_iv __read_mostly = {
 	.bat_primary_iface_set = batadv_iv_ogm_primary_iface_set,
 	.bat_ogm_schedule = batadv_iv_ogm_schedule,
 	.bat_ogm_emit = batadv_iv_ogm_emit,
+	.bat_neigh_cmp = batadv_iv_ogm_neigh_cmp,
 	.bat_orig_print = batadv_iv_ogm_orig_print,
 };
 
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 3159a14..1f2f1ac 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -501,7 +501,8 @@ int batadv_algo_register(struct batadv_algo_ops *bat_algo_ops)
 	    !bat_algo_ops->bat_iface_update_mac ||
 	    !bat_algo_ops->bat_primary_iface_set ||
 	    !bat_algo_ops->bat_ogm_schedule ||
-	    !bat_algo_ops->bat_ogm_emit) {
+	    !bat_algo_ops->bat_ogm_emit ||
+	    !bat_algo_ops->bat_neigh_cmp) {
 		pr_info("Routing algo '%s' does not implement required ops\n",
 			bat_algo_ops->name);
 		ret = -EINVAL;
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 72fd617..7a00932 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -992,6 +992,7 @@ struct batadv_forw_packet {
  * @bat_primary_iface_set: called when primary interface is selected / changed
  * @bat_ogm_schedule: prepare a new outgoing OGM for the send queue
  * @bat_ogm_emit: send scheduled OGM
+ * @bat_neigh_cmp: compare the metrics of two neighbors
  * @bat_orig_print: print the originator table (optional)
  */
 struct batadv_algo_ops {
@@ -1003,6 +1004,8 @@ struct batadv_algo_ops {
 	void (*bat_primary_iface_set)(struct batadv_hard_iface *hard_iface);
 	void (*bat_ogm_schedule)(struct batadv_hard_iface *hard_iface);
 	void (*bat_ogm_emit)(struct batadv_forw_packet *forw_packet);
+	int (*bat_neigh_cmp)(struct batadv_neigh_node *neigh1,
+			     struct batadv_neigh_node *neigh2);
 	/* orig_node handling API */
 	void (*bat_orig_print)(struct batadv_priv *priv, struct seq_file *seq);
 };
-- 
1.8.4
