From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 3/7] batman-adv: add bat_neigh_free API
Date: Tue,  9 Jun 2015 12:50:16 +0200
Message-ID: <1433847020-1427-4-git-send-email-antonio@meshcoding.com>
References: <1433847020-1427-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:12622 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932210AbbFIKw3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 06:52:29 -0400
In-Reply-To: <1433847020-1427-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

This API has to be used to let any routing protocol free
neighbor specific allocated resources

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/originator.c | 6 ++++++
 net/batman-adv/types.h      | 4 ++++
 2 files changed, 10 insertions(+)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index e3900e4..aa092c3 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -197,13 +197,19 @@ static void batadv_neigh_node_free_rcu(struct rcu_head *rcu)
 	struct hlist_node *node_tmp;
 	struct batadv_neigh_node *neigh_node;
 	struct batadv_neigh_ifinfo *neigh_ifinfo;
+	struct batadv_algo_ops *bao;
 
 	neigh_node = container_of(rcu, struct batadv_neigh_node, rcu);
+	bao = neigh_node->orig_node->bat_priv->bat_algo_ops;
 
 	hlist_for_each_entry_safe(neigh_ifinfo, node_tmp,
 				  &neigh_node->ifinfo_list, list) {
 		batadv_neigh_ifinfo_free_ref_now(neigh_ifinfo);
 	}
+
+	if (bao->bat_neigh_free)
+		bao->bat_neigh_free(neigh_node);
+
 	batadv_hardif_free_ref_now(neigh_node->if_incoming);
 
 	kfree(neigh_node);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index c1000c0..336f94b 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1121,6 +1121,8 @@ struct batadv_forw_packet {
  * @bat_neigh_is_equiv_or_better: check if neigh1 is equally good or better
  *  than neigh2 for their respective outgoing interface from the metric
  *  prospective
+ * @bat_neigh_free: free the resources allocated by the routing algorithm for a
+ *  neigh_node object
  * @bat_orig_print: print the originator table (optional)
  * @bat_orig_free: free the resources allocated by the routing algorithm for an
  *  orig_node object
@@ -1138,6 +1140,7 @@ struct batadv_algo_ops {
 	void (*bat_primary_iface_set)(struct batadv_hard_iface *hard_iface);
 	void (*bat_ogm_schedule)(struct batadv_hard_iface *hard_iface);
 	void (*bat_ogm_emit)(struct batadv_forw_packet *forw_packet);
+	/* neigh_node handling API */
 	int (*bat_neigh_cmp)(struct batadv_neigh_node *neigh1,
 			     struct batadv_hard_iface *if_outgoing1,
 			     struct batadv_neigh_node *neigh2,
@@ -1147,6 +1150,7 @@ struct batadv_algo_ops {
 		 struct batadv_hard_iface *if_outgoing1,
 		 struct batadv_neigh_node *neigh2,
 		 struct batadv_hard_iface *if_outgoing2);
+	void (*bat_neigh_free)(struct batadv_neigh_node *neigh);
 	/* orig_node handling API */
 	void (*bat_orig_print)(struct batadv_priv *priv, struct seq_file *seq,
 			       struct batadv_hard_iface *hard_iface);
-- 
2.4.2
