From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 03/16] batman-adv: add bat_orig_print API function
Date: Wed, 23 Oct 2013 18:04:50 +0200
Message-ID: <1382544303-2694-4-git-send-email-antonio@meshcoding.com>
References: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:16616 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752319Ab3JWQFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 12:05:50 -0400
In-Reply-To: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Each routing protocol has its own metric and private
variables, therefore it is useful to introduce a new API
for originator information printing.

This API needs to be implemented by each protocol in order
to provide its specific originator table output.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bat_iv_ogm.c | 65 ++++++++++++++++++++++++++++++++++++++++++++
 net/batman-adv/originator.c | 66 +++++++--------------------------------------
 net/batman-adv/types.h      |  3 +++
 3 files changed, 78 insertions(+), 56 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 0b1343d..4aabd55 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1411,6 +1411,70 @@ static int batadv_iv_ogm_receive(struct sk_buff *skb,
 	return NET_RX_SUCCESS;
 }
 
+/**
+ * batadv_iv_ogm_orig_print - print the originator table
+ * @bat_priv: the bat priv with all the soft interface information
+ * @seq: debugfs table seq_file struct
+ */
+static void batadv_iv_ogm_orig_print(struct batadv_priv *bat_priv,
+				     struct seq_file *seq)
+{
+	struct batadv_neigh_node *neigh_node, *neigh_node_tmp;
+	struct batadv_hashtable *hash = bat_priv->orig_hash;
+	int last_seen_msecs, last_seen_secs;
+	struct batadv_orig_node *orig_node;
+	unsigned long last_seen_jiffies;
+	struct hlist_head *head;
+	int batman_count = 0;
+	uint32_t i;
+
+	seq_printf(seq, "  %-15s %s (%s/%i) %17s [%10s]: %20s ...\n",
+		   "Originator", "last-seen", "#", BATADV_TQ_MAX_VALUE,
+		   "Nexthop", "outgoingIF", "Potential nexthops");
+
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
+			neigh_node = batadv_orig_node_get_router(orig_node);
+			if (!neigh_node)
+				continue;
+
+			if (neigh_node->bat_iv.tq_avg == 0)
+				goto next;
+
+			last_seen_jiffies = jiffies - orig_node->last_seen;
+			last_seen_msecs = jiffies_to_msecs(last_seen_jiffies);
+			last_seen_secs = last_seen_msecs / 1000;
+			last_seen_msecs = last_seen_msecs % 1000;
+
+			seq_printf(seq, "%pM %4i.%03is   (%3i) %pM [%10s]:",
+				   orig_node->orig, last_seen_secs,
+				   last_seen_msecs, neigh_node->bat_iv.tq_avg,
+				   neigh_node->addr,
+				   neigh_node->if_incoming->net_dev->name);
+
+			hlist_for_each_entry_rcu(neigh_node_tmp,
+						 &orig_node->neigh_list, list) {
+				seq_printf(seq, " %pM (%3i)",
+					   neigh_node_tmp->addr,
+					   neigh_node_tmp->bat_iv.tq_avg);
+			}
+
+			seq_puts(seq, "\n");
+			batman_count++;
+
+next:
+			batadv_neigh_node_free_ref(neigh_node);
+		}
+		rcu_read_unlock();
+	}
+
+	if (batman_count == 0)
+		seq_puts(seq, "No batman nodes in range ...\n");
+}
+
 static struct batadv_algo_ops batadv_batman_iv __read_mostly = {
 	.name = "BATMAN_IV",
 	.bat_iface_enable = batadv_iv_ogm_iface_enable,
@@ -1419,6 +1483,7 @@ static struct batadv_algo_ops batadv_batman_iv __read_mostly = {
 	.bat_primary_iface_set = batadv_iv_ogm_primary_iface_set,
 	.bat_ogm_schedule = batadv_iv_ogm_schedule,
 	.bat_ogm_emit = batadv_iv_ogm_emit,
+	.bat_orig_print = batadv_iv_ogm_orig_print,
 };
 
 int __init batadv_iv_init(void)
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index aa14094..8d1b16e 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -513,73 +513,27 @@ int batadv_orig_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct net_device *net_dev = (struct net_device *)seq->private;
 	struct batadv_priv *bat_priv = netdev_priv(net_dev);
-	struct batadv_hashtable *hash = bat_priv->orig_hash;
-	struct hlist_head *head;
 	struct batadv_hard_iface *primary_if;
-	struct batadv_orig_node *orig_node;
-	struct batadv_neigh_node *neigh_node, *neigh_node_tmp;
-	int batman_count = 0;
-	int last_seen_secs;
-	int last_seen_msecs;
-	unsigned long last_seen_jiffies;
-	uint32_t i;
 
 	primary_if = batadv_seq_print_text_primary_if_get(seq);
 	if (!primary_if)
-		goto out;
+		return 0;
 
-	seq_printf(seq, "[B.A.T.M.A.N. adv %s, MainIF/MAC: %s/%pM (%s)]\n",
+	seq_printf(seq, "[B.A.T.M.A.N. adv %s, MainIF/MAC: %s/%pM (%s %s)]\n",
 		   BATADV_SOURCE_VERSION, primary_if->net_dev->name,
-		   primary_if->net_dev->dev_addr, net_dev->name);
-	seq_printf(seq, "  %-15s %s (%s/%i) %17s [%10s]: %20s ...\n",
-		   "Originator", "last-seen", "#", BATADV_TQ_MAX_VALUE,
-		   "Nexthop", "outgoingIF", "Potential nexthops");
-
-	for (i = 0; i < hash->size; i++) {
-		head = &hash->table[i];
-
-		rcu_read_lock();
-		hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
-			neigh_node = batadv_orig_node_get_router(orig_node);
-			if (!neigh_node)
-				continue;
-
-			if (neigh_node->bat_iv.tq_avg == 0)
-				goto next;
-
-			last_seen_jiffies = jiffies - orig_node->last_seen;
-			last_seen_msecs = jiffies_to_msecs(last_seen_jiffies);
-			last_seen_secs = last_seen_msecs / 1000;
-			last_seen_msecs = last_seen_msecs % 1000;
-
-			seq_printf(seq, "%pM %4i.%03is   (%3i) %pM [%10s]:",
-				   orig_node->orig, last_seen_secs,
-				   last_seen_msecs, neigh_node->bat_iv.tq_avg,
-				   neigh_node->addr,
-				   neigh_node->if_incoming->net_dev->name);
-
-			hlist_for_each_entry_rcu(neigh_node_tmp,
-						 &orig_node->neigh_list, list) {
-				seq_printf(seq, " %pM (%3i)",
-					   neigh_node_tmp->addr,
-					   neigh_node_tmp->bat_iv.tq_avg);
-			}
+		   primary_if->net_dev->dev_addr, net_dev->name,
+		   bat_priv->bat_algo_ops->name);
 
-			seq_puts(seq, "\n");
-			batman_count++;
+	batadv_hardif_free_ref(primary_if);
 
-next:
-			batadv_neigh_node_free_ref(neigh_node);
-		}
-		rcu_read_unlock();
+	if (!bat_priv->bat_algo_ops->bat_orig_print) {
+		seq_puts(seq,
+			 "No printing function for this routing protocol\n");
+		return 0;
 	}
 
-	if (batman_count == 0)
-		seq_puts(seq, "No batman nodes in range ...\n");
+	bat_priv->bat_algo_ops->bat_orig_print(bat_priv, seq);
 
-out:
-	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
 	return 0;
 }
 
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 97bde51..72fd617 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -992,6 +992,7 @@ struct batadv_forw_packet {
  * @bat_primary_iface_set: called when primary interface is selected / changed
  * @bat_ogm_schedule: prepare a new outgoing OGM for the send queue
  * @bat_ogm_emit: send scheduled OGM
+ * @bat_orig_print: print the originator table (optional)
  */
 struct batadv_algo_ops {
 	struct hlist_node list;
@@ -1002,6 +1003,8 @@ struct batadv_algo_ops {
 	void (*bat_primary_iface_set)(struct batadv_hard_iface *hard_iface);
 	void (*bat_ogm_schedule)(struct batadv_hard_iface *hard_iface);
 	void (*bat_ogm_emit)(struct batadv_forw_packet *forw_packet);
+	/* orig_node handling API */
+	void (*bat_orig_print)(struct batadv_priv *priv, struct seq_file *seq);
 };
 
 /**
-- 
1.8.4
