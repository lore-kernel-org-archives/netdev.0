From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 05/16] batman-adv: add bat_neigh_is_equiv_or_better API function
Date: Wed, 23 Oct 2013 18:04:52 +0200
Message-ID: <1382544303-2694-6-git-send-email-antonio@meshcoding.com>
References: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:38566 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416Ab3JWQFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 12:05:51 -0400
In-Reply-To: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Each routing protocol has its own metric semantic and
therefore is the protocol itself the only component able to
compare two metrics to check their "similarity".

This new API allows each routing protocol to implement its
own logic and make the external code protocol agnostic.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bat_iv_ogm.c | 18 ++++++++++++++++++
 net/batman-adv/main.c       |  3 ++-
 net/batman-adv/main.h       |  6 ++++++
 net/batman-adv/types.h      |  4 ++++
 4 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index b288d90..4376fe7 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1494,6 +1494,23 @@ static int batadv_iv_ogm_neigh_cmp(struct batadv_neigh_node *neigh1,
 	return tq1 - tq2;
 }
 
+/**
+ * batadv_iv_ogm_neigh_is_eob - check if neigh1 is equally good or better than
+ *  neigh2 from the metric prospective
+ * @neigh1: the first neighbor object of the comparison
+ * @neigh2: the second neighbor object of the comparison
+ *
+ * Returns true if the metric via neigh1 is equally good or better than the
+ * metric via neigh2, false otherwise.
+ */
+static bool batadv_iv_ogm_neigh_is_eob(struct batadv_neigh_node *neigh1,
+				       struct batadv_neigh_node *neigh2)
+{
+	int diff = batadv_iv_ogm_neigh_cmp(neigh1, neigh2);
+
+	return diff > -BATADV_TQ_SIMILARITY_THRESHOLD;
+}
+
 static struct batadv_algo_ops batadv_batman_iv __read_mostly = {
 	.name = "BATMAN_IV",
 	.bat_iface_enable = batadv_iv_ogm_iface_enable,
@@ -1503,6 +1520,7 @@ static struct batadv_algo_ops batadv_batman_iv __read_mostly = {
 	.bat_ogm_schedule = batadv_iv_ogm_schedule,
 	.bat_ogm_emit = batadv_iv_ogm_emit,
 	.bat_neigh_cmp = batadv_iv_ogm_neigh_cmp,
+	.bat_neigh_is_equiv_or_better = batadv_iv_ogm_neigh_is_eob,
 	.bat_orig_print = batadv_iv_ogm_orig_print,
 };
 
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 1f2f1ac..c51a5e5 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -502,7 +502,8 @@ int batadv_algo_register(struct batadv_algo_ops *bat_algo_ops)
 	    !bat_algo_ops->bat_primary_iface_set ||
 	    !bat_algo_ops->bat_ogm_schedule ||
 	    !bat_algo_ops->bat_ogm_emit ||
-	    !bat_algo_ops->bat_neigh_cmp) {
+	    !bat_algo_ops->bat_neigh_cmp ||
+	    !bat_algo_ops->bat_neigh_is_equiv_or_better) {
 		pr_info("Routing algo '%s' does not implement required ops\n",
 			bat_algo_ops->name);
 		ret = -EINVAL;
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index d7dfafe..773301a 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -86,6 +86,12 @@
 /* numbers of originator to contact for any PUT/GET DHT operation */
 #define BATADV_DAT_CANDIDATES_NUM 3
 
+/**
+ * BATADV_TQ_SIMILARITY_THRESHOLD - TQ points that a secondary metric can differ
+ *  at most from the primary one in order to be still considered acceptable
+ */
+#define BATADV_TQ_SIMILARITY_THRESHOLD 50
+
 /* how much worse secondary interfaces may be to be considered as bonding
  * candidates
  */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 7a00932..d0e64d2 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -993,6 +993,8 @@ struct batadv_forw_packet {
  * @bat_ogm_schedule: prepare a new outgoing OGM for the send queue
  * @bat_ogm_emit: send scheduled OGM
  * @bat_neigh_cmp: compare the metrics of two neighbors
+ * @bat_neigh_is_equiv_or_better: check if neigh1 is equally good or
+ *  better than neigh2 from the metric prospective
  * @bat_orig_print: print the originator table (optional)
  */
 struct batadv_algo_ops {
@@ -1006,6 +1008,8 @@ struct batadv_algo_ops {
 	void (*bat_ogm_emit)(struct batadv_forw_packet *forw_packet);
 	int (*bat_neigh_cmp)(struct batadv_neigh_node *neigh1,
 			     struct batadv_neigh_node *neigh2);
+	bool (*bat_neigh_is_equiv_or_better)(struct batadv_neigh_node *neigh1,
+					     struct batadv_neigh_node *neigh2);
 	/* orig_node handling API */
 	void (*bat_orig_print)(struct batadv_priv *priv, struct seq_file *seq);
 };
-- 
1.8.4
