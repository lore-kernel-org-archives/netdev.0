From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 08/14] batman-adv: add debugfs support to view multiif tables
Date: Mon, 13 Jan 2014 23:31:32 +0100
Message-ID: <1389652298-472-9-git-send-email-antonio@meshcoding.com>
References: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:23947 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbaAMWd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 17:33:58 -0500
In-Reply-To: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

Show tables for the multi interface operation. Originator tables
are added per hard interface.

This patch also changes the API by adding the interface to the
bat_orig_print() parameters.

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c | 12 +++++++-----
 net/batman-adv/debugfs.c    | 16 +++++++++++++++
 net/batman-adv/originator.c | 48 ++++++++++++++++++++++++++++++++++++++++++++-
 net/batman-adv/originator.h |  1 +
 net/batman-adv/types.h      |  3 ++-
 5 files changed, 73 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index a9b7e82..fb196a0 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1777,9 +1777,11 @@ batadv_iv_ogm_orig_print_neigh(struct batadv_orig_node *orig_node,
  * batadv_iv_ogm_orig_print - print the originator table
  * @bat_priv: the bat priv with all the soft interface information
  * @seq: debugfs table seq_file struct
+ * @if_outgoing: the outgoing interface for which this should be printed
  */
 static void batadv_iv_ogm_orig_print(struct batadv_priv *bat_priv,
-				     struct seq_file *seq)
+				     struct seq_file *seq,
+				     struct batadv_hard_iface *if_outgoing)
 {
 	struct batadv_neigh_node *neigh_node;
 	struct batadv_hashtable *hash = bat_priv->orig_hash;
@@ -1801,12 +1803,12 @@ static void batadv_iv_ogm_orig_print(struct batadv_priv *bat_priv,
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
 			neigh_node = batadv_orig_router_get(orig_node,
-							    BATADV_IF_DEFAULT);
+							    if_outgoing);
 			if (!neigh_node)
 				continue;
 
 			n_ifinfo = batadv_neigh_ifinfo_get(neigh_node,
-							   BATADV_IF_DEFAULT);
+							   if_outgoing);
 			if (!n_ifinfo)
 				goto next;
 
@@ -1824,8 +1826,8 @@ static void batadv_iv_ogm_orig_print(struct batadv_priv *bat_priv,
 				   neigh_node->addr,
 				   neigh_node->if_incoming->net_dev->name);
 
-			batadv_iv_ogm_orig_print_neigh(orig_node,
-						       BATADV_IF_DEFAULT, seq);
+			batadv_iv_ogm_orig_print_neigh(orig_node, if_outgoing,
+						       seq);
 			seq_puts(seq, "\n");
 			batman_count++;
 
diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 2ea3695..26cbf34 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -248,6 +248,19 @@ static int batadv_originators_open(struct inode *inode, struct file *file)
 	return single_open(file, batadv_orig_seq_print_text, net_dev);
 }
 
+/**
+ * batadv_originators_hardif_open - handles debugfs output for the
+ *  originator table of an hard interface
+ * @inode: inode pointer to debugfs file
+ * @file: pointer to the seq_file
+ */
+static int batadv_originators_hardif_open(struct inode *inode,
+					  struct file *file)
+{
+	struct net_device *net_dev = (struct net_device *)inode->i_private;
+	return single_open(file, batadv_orig_hardif_seq_print_text, net_dev);
+}
+
 static int batadv_gateways_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
@@ -383,8 +396,11 @@ struct batadv_debuginfo batadv_hardif_debuginfo_##_name = {	\
 		.release = single_release,			\
 	},							\
 };
+static BATADV_HARDIF_DEBUGINFO(originators, S_IRUGO,
+			       batadv_originators_hardif_open);
 
 static struct batadv_debuginfo *batadv_hardif_debuginfos[] = {
+	&batadv_hardif_debuginfo_originators,
 	NULL,
 };
 
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index bd88780..5ed037f 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -940,11 +940,57 @@ int batadv_orig_seq_print_text(struct seq_file *seq, void *offset)
 		return 0;
 	}
 
-	bat_priv->bat_algo_ops->bat_orig_print(bat_priv, seq);
+	bat_priv->bat_algo_ops->bat_orig_print(bat_priv, seq,
+					       BATADV_IF_DEFAULT);
 
 	return 0;
 }
 
+/**
+ * batadv_orig_hardif_seq_print_text - writes originator infos for a specific
+ *  outgoing interface
+ * @seq: debugfs table seq_file struct
+ * @offset: not used
+ *
+ * Returns 0
+ */
+int batadv_orig_hardif_seq_print_text(struct seq_file *seq, void *offset)
+{
+	struct net_device *net_dev = (struct net_device *)seq->private;
+	struct batadv_hard_iface *hard_iface;
+	struct batadv_priv *bat_priv;
+
+	hard_iface = batadv_hardif_get_by_netdev(net_dev);
+
+	if (!hard_iface || !hard_iface->soft_iface) {
+		seq_puts(seq, "Interface not known to B.A.T.M.A.N.\n");
+		goto out;
+	}
+
+	bat_priv = netdev_priv(hard_iface->soft_iface);
+	if (!bat_priv->bat_algo_ops->bat_orig_print) {
+		seq_puts(seq,
+			 "No printing function for this routing protocol\n");
+		goto out;
+	}
+
+	if (hard_iface->if_status != BATADV_IF_ACTIVE) {
+		seq_puts(seq, "Interface not active\n");
+		goto out;
+	}
+
+	seq_printf(seq, "[B.A.T.M.A.N. adv %s, IF/MAC: %s/%pM (%s %s)]\n",
+		   BATADV_SOURCE_VERSION, hard_iface->net_dev->name,
+		   hard_iface->net_dev->dev_addr,
+		   hard_iface->soft_iface->name, bat_priv->bat_algo_ops->name);
+
+	bat_priv->bat_algo_ops->bat_orig_print(bat_priv, seq, hard_iface);
+
+out:
+	batadv_hardif_free_ref(hard_iface);
+	return 0;
+}
+
 int batadv_orig_hash_add_if(struct batadv_hard_iface *hard_iface,
 			    int max_if_num)
 {
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 75a4d7b..ad17c3c 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -53,6 +53,7 @@ batadv_orig_ifinfo_new(struct batadv_orig_node *orig_node,
 void batadv_orig_ifinfo_free_ref(struct batadv_orig_ifinfo *orig_ifinfo);
 
 int batadv_orig_seq_print_text(struct seq_file *seq, void *offset);
+int batadv_orig_hardif_seq_print_text(struct seq_file *seq, void *offset);
 int batadv_orig_hash_add_if(struct batadv_hard_iface *hard_iface,
 			    int max_if_num);
 int batadv_orig_hash_del_if(struct batadv_hard_iface *hard_iface,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 529b374..8a1fa16 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1083,7 +1083,8 @@ struct batadv_algo_ops {
 		 struct batadv_neigh_node *neigh2,
 		 struct batadv_hard_iface *if_outgoing2);
 	/* orig_node handling API */
-	void (*bat_orig_print)(struct batadv_priv *priv, struct seq_file *seq);
+	void (*bat_orig_print)(struct batadv_priv *priv, struct seq_file *seq,
+			       struct batadv_hard_iface *hard_iface);
 	void (*bat_orig_free)(struct batadv_orig_node *orig_node);
 	int (*bat_orig_add_if)(struct batadv_orig_node *orig_node,
 			       int max_if_num);
-- 
1.8.5.2
