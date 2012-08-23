From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 02/18] batman-adv: Add the backbone gateway list to debugfs
Date: Thu, 23 Aug 2012 15:10:11 +0200
Message-ID: <1345727427-20805-3-git-send-email-ordex@autistici.org>
References: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:28722 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933002Ab2HWNKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:10:48 -0400
In-Reply-To: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>

This is especially useful if there are no claims yet, but we still want
to know which gateways are using bridge loop avoidance in the network.

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 Documentation/networking/batman-adv.txt |    7 ++--
 net/batman-adv/bridge_loop_avoidance.c  |   65 +++++++++++++++++++++++++++++++
 net/batman-adv/bridge_loop_avoidance.h  |    8 ++++
 net/batman-adv/debugfs.c                |   12 ++++++
 4 files changed, 89 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/batman-adv.txt b/Documentation/networking/batman-adv.txt
index 8f3ae4a..a173d2a 100644
--- a/Documentation/networking/batman-adv.txt
+++ b/Documentation/networking/batman-adv.txt
@@ -75,9 +75,10 @@ folder:
 
 There is a special folder for debugging information:
 
-#  ls /sys/kernel/debug/batman_adv/bat0/
-# bla_claim_table    log                socket             transtable_local
-# gateways           originators        transtable_global  vis_data
+# ls /sys/kernel/debug/batman_adv/bat0/
+# bla_backbone_table  log                 transtable_global
+# bla_claim_table     originators         transtable_local
+# gateways            socket              vis_data
 
 Some of the files contain all sort of status information  regard-
 ing  the  mesh  network.  For  example, you can view the table of
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 6705d35..7e60466 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1616,3 +1616,68 @@ out:
 		batadv_hardif_free_ref(primary_if);
 	return ret;
 }
+
+int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq, void *offset)
+{
+	struct net_device *net_dev = (struct net_device *)seq->private;
+	struct batadv_priv *bat_priv = netdev_priv(net_dev);
+	struct batadv_hashtable *hash = bat_priv->backbone_hash;
+	struct batadv_backbone_gw *backbone_gw;
+	struct batadv_hard_iface *primary_if;
+	struct hlist_node *node;
+	struct hlist_head *head;
+	int secs, msecs;
+	uint32_t i;
+	bool is_own;
+	int ret = 0;
+	uint8_t *primary_addr;
+
+	primary_if = batadv_primary_if_get_selected(bat_priv);
+	if (!primary_if) {
+		ret = seq_printf(seq,
+				 "BATMAN mesh %s disabled - please specify interfaces to enable it\n",
+				 net_dev->name);
+		goto out;
+	}
+
+	if (primary_if->if_status != BATADV_IF_ACTIVE) {
+		ret = seq_printf(seq,
+				 "BATMAN mesh %s disabled - primary interface not active\n",
+				 net_dev->name);
+		goto out;
+	}
+
+	primary_addr = primary_if->net_dev->dev_addr;
+	seq_printf(seq,
+		   "Backbones announced for the mesh %s (orig %pM, group id %04x)\n",
+		   net_dev->name, primary_addr,
+		   ntohs(bat_priv->claim_dest.group));
+	seq_printf(seq, "   %-17s    %-5s %-9s (%-4s)\n",
+		   "Originator", "VID", "last seen", "CRC");
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(backbone_gw, node, head, hash_entry) {
+			msecs = jiffies_to_msecs(jiffies -
+						 backbone_gw->lasttime);
+			secs = msecs / 1000;
+			msecs = msecs % 1000;
+
+			is_own = batadv_compare_eth(backbone_gw->orig,
+						    primary_addr);
+			if (is_own)
+				continue;
+
+			seq_printf(seq,
+				   " * %pM on % 5d % 4i.%03is (%04x)\n",
+				   backbone_gw->orig, backbone_gw->vid,
+				   secs, msecs, backbone_gw->crc);
+		}
+		rcu_read_unlock();
+	}
+out:
+	if (primary_if)
+		batadv_hardif_free_ref(primary_if);
+	return ret;
+}
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index 3f0dfa2..789cb73 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -27,6 +27,8 @@ int batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb, short vid);
 int batadv_bla_is_backbone_gw(struct sk_buff *skb,
 			      struct batadv_orig_node *orig_node, int hdr_size);
 int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset);
+int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq,
+					     void *offset);
 int batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv, uint8_t *orig);
 int batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
 				   struct batadv_bcast_packet *bcast_packet,
@@ -65,6 +67,12 @@ static inline int batadv_bla_claim_table_seq_print_text(struct seq_file *seq,
 	return 0;
 }
 
+static inline int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq,
+							   void *offset)
+{
+	return 0;
+}
+
 static inline int batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv,
 						 uint8_t *orig)
 {
diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 34fbb16..391d4fb 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -267,6 +267,15 @@ static int batadv_bla_claim_table_open(struct inode *inode, struct file *file)
 	return single_open(file, batadv_bla_claim_table_seq_print_text,
 			   net_dev);
 }
+
+static int batadv_bla_backbone_table_open(struct inode *inode,
+					  struct file *file)
+{
+	struct net_device *net_dev = (struct net_device *)inode->i_private;
+	return single_open(file, batadv_bla_backbone_table_seq_print_text,
+			   net_dev);
+}
+
 #endif
 
 static int batadv_transtable_local_open(struct inode *inode, struct file *file)
@@ -305,6 +314,8 @@ static BATADV_DEBUGINFO(transtable_global, S_IRUGO,
 			batadv_transtable_global_open);
 #ifdef CONFIG_BATMAN_ADV_BLA
 static BATADV_DEBUGINFO(bla_claim_table, S_IRUGO, batadv_bla_claim_table_open);
+static BATADV_DEBUGINFO(bla_backbone_table, S_IRUGO,
+			batadv_bla_backbone_table_open);
 #endif
 static BATADV_DEBUGINFO(transtable_local, S_IRUGO,
 			batadv_transtable_local_open);
@@ -316,6 +327,7 @@ static struct batadv_debuginfo *batadv_mesh_debuginfos[] = {
 	&batadv_debuginfo_transtable_global,
 #ifdef CONFIG_BATMAN_ADV_BLA
 	&batadv_debuginfo_bla_claim_table,
+	&batadv_debuginfo_bla_backbone_table,
 #endif
 	&batadv_debuginfo_transtable_local,
 	&batadv_debuginfo_vis_data,
-- 
1.7.9.4
