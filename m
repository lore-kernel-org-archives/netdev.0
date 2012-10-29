From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 04/16] batman-adv: consolidate duplicated primary_if checking code
Date: Mon, 29 Oct 2012 09:58:05 +0100
Message-ID: <1351501097-1289-5-git-send-email-ordex@autistici.org>
References: <1351501097-1289-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:54117 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756686Ab2J2I7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 04:59:01 -0400
In-Reply-To: <1351501097-1289-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bridge_loop_avoidance.c | 36 ++++++----------------------------
 net/batman-adv/gateway_client.c        | 19 ++++--------------
 net/batman-adv/main.c                  | 36 ++++++++++++++++++++++++++++++++++
 net/batman-adv/main.h                  |  2 ++
 net/batman-adv/originator.c            | 19 +++---------------
 net/batman-adv/translation-table.c     | 36 ++++++----------------------------
 6 files changed, 57 insertions(+), 91 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index fd8d5af..29a5542 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1585,23 +1585,11 @@ int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
 	struct hlist_head *head;
 	uint32_t i;
 	bool is_own;
-	int ret = 0;
 	uint8_t *primary_addr;
 
-	primary_if = batadv_primary_if_get_selected(bat_priv);
-	if (!primary_if) {
-		ret = seq_printf(seq,
-				 "BATMAN mesh %s disabled - please specify interfaces to enable it\n",
-				 net_dev->name);
+	primary_if = batadv_seq_print_text_primary_if_get(seq);
+	if (!primary_if)
 		goto out;
-	}
-
-	if (primary_if->if_status != BATADV_IF_ACTIVE) {
-		ret = seq_printf(seq,
-				 "BATMAN mesh %s disabled - primary interface not active\n",
-				 net_dev->name);
-		goto out;
-	}
 
 	primary_addr = primary_if->net_dev->dev_addr;
 	seq_printf(seq,
@@ -1628,7 +1616,7 @@ int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
 out:
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
-	return ret;
+	return 0;
 }
 
 int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq, void *offset)
@@ -1643,23 +1631,11 @@ int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq, void *offset)
 	int secs, msecs;
 	uint32_t i;
 	bool is_own;
-	int ret = 0;
 	uint8_t *primary_addr;
 
-	primary_if = batadv_primary_if_get_selected(bat_priv);
-	if (!primary_if) {
-		ret = seq_printf(seq,
-				 "BATMAN mesh %s disabled - please specify interfaces to enable it\n",
-				 net_dev->name);
+	primary_if = batadv_seq_print_text_primary_if_get(seq);
+	if (!primary_if)
 		goto out;
-	}
-
-	if (primary_if->if_status != BATADV_IF_ACTIVE) {
-		ret = seq_printf(seq,
-				 "BATMAN mesh %s disabled - primary interface not active\n",
-				 net_dev->name);
-		goto out;
-	}
 
 	primary_addr = primary_if->net_dev->dev_addr;
 	seq_printf(seq,
@@ -1693,5 +1669,5 @@ int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq, void *offset)
 out:
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
-	return ret;
+	return 0;
 }
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 15d67ab..dd07c7e 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -477,22 +477,11 @@ int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset)
 	struct batadv_hard_iface *primary_if;
 	struct batadv_gw_node *gw_node;
 	struct hlist_node *node;
-	int gw_count = 0, ret = 0;
+	int gw_count = 0;
 
-	primary_if = batadv_primary_if_get_selected(bat_priv);
-	if (!primary_if) {
-		ret = seq_printf(seq,
-				 "BATMAN mesh %s disabled - please specify interfaces to enable it\n",
-				 net_dev->name);
+	primary_if = batadv_seq_print_text_primary_if_get(seq);
+	if (!primary_if)
 		goto out;
-	}
-
-	if (primary_if->if_status != BATADV_IF_ACTIVE) {
-		ret = seq_printf(seq,
-				 "BATMAN mesh %s disabled - primary interface not active\n",
-				 net_dev->name);
-		goto out;
-	}
 
 	seq_printf(seq,
 		   "      %-12s (%s/%i) %17s [%10s]: gw_class ... [B.A.T.M.A.N. adv %s, MainIF/MAC: %s/%pM (%s)]\n",
@@ -519,7 +508,7 @@ int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset)
 out:
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
-	return ret;
+	return 0;
 }
 
 static bool batadv_is_type_dhcprequest(struct sk_buff *skb, int header_len)
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index b4aa470..a4a337d 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -188,6 +188,42 @@ int batadv_is_my_mac(const uint8_t *addr)
 	return 0;
 }
 
+/**
+ * batadv_seq_print_text_primary_if_get - called from debugfs table printing
+ *  function that requires the primary interface
+ * @seq: debugfs table seq_file struct
+ *
+ * Returns primary interface if found or NULL otherwise.
+ */
+struct batadv_hard_iface *
+batadv_seq_print_text_primary_if_get(struct seq_file *seq)
+{
+	struct net_device *net_dev = (struct net_device *)seq->private;
+	struct batadv_priv *bat_priv = netdev_priv(net_dev);
+	struct batadv_hard_iface *primary_if;
+
+	primary_if = batadv_primary_if_get_selected(bat_priv);
+
+	if (!primary_if) {
+		seq_printf(seq,
+			   "BATMAN mesh %s disabled - please specify interfaces to enable it\n",
+			   net_dev->name);
+		goto out;
+	}
+
+	if (primary_if->if_status == BATADV_IF_ACTIVE)
+		goto out;
+
+	seq_printf(seq,
+		   "BATMAN mesh %s disabled - primary interface not active\n",
+		   net_dev->name);
+	batadv_hardif_free_ref(primary_if);
+	primary_if = NULL;
+
+out:
+	return primary_if;
+}
+
 static int batadv_recv_unhandled_packet(struct sk_buff *skb,
 					struct batadv_hard_iface *recv_if)
 {
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index d57b746..5c0be5b 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -153,6 +153,8 @@ void batadv_mesh_free(struct net_device *soft_iface);
 void batadv_inc_module_count(void);
 void batadv_dec_module_count(void);
 int batadv_is_my_mac(const uint8_t *addr);
+struct batadv_hard_iface *
+batadv_seq_print_text_primary_if_get(struct seq_file *seq);
 int batadv_batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 			   struct packet_type *ptype,
 			   struct net_device *orig_dev);
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index ac9bdf8..d9c14b8 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -415,23 +415,10 @@ int batadv_orig_seq_print_text(struct seq_file *seq, void *offset)
 	int last_seen_msecs;
 	unsigned long last_seen_jiffies;
 	uint32_t i;
-	int ret = 0;
 
-	primary_if = batadv_primary_if_get_selected(bat_priv);
-
-	if (!primary_if) {
-		ret = seq_printf(seq,
-				 "BATMAN mesh %s disabled - please specify interfaces to enable it\n",
-				 net_dev->name);
-		goto out;
-	}
-
-	if (primary_if->if_status != BATADV_IF_ACTIVE) {
-		ret = seq_printf(seq,
-				 "BATMAN mesh %s disabled - primary interface not active\n",
-				 net_dev->name);
+	primary_if = batadv_seq_print_text_primary_if_get(seq);
+	if (!primary_if)
 		goto out;
-	}
 
 	seq_printf(seq, "[B.A.T.M.A.N. adv %s, MainIF/MAC: %s/%pM (%s)]\n",
 		   BATADV_SOURCE_VERSION, primary_if->net_dev->name,
@@ -485,7 +472,7 @@ next:
 out:
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
-	return ret;
+	return 0;
 }
 
 static int batadv_orig_node_add_if(struct batadv_orig_node *orig_node,
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 112edd3..d87d9b4 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -434,22 +434,10 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 	struct hlist_node *node;
 	struct hlist_head *head;
 	uint32_t i;
-	int ret = 0;
 
-	primary_if = batadv_primary_if_get_selected(bat_priv);
-	if (!primary_if) {
-		ret = seq_printf(seq,
-				 "BATMAN mesh %s disabled - please specify interfaces to enable it\n",
-				 net_dev->name);
+	primary_if = batadv_seq_print_text_primary_if_get(seq);
+	if (!primary_if)
 		goto out;
-	}
-
-	if (primary_if->if_status != BATADV_IF_ACTIVE) {
-		ret = seq_printf(seq,
-				 "BATMAN mesh %s disabled - primary interface not active\n",
-				 net_dev->name);
-		goto out;
-	}
 
 	seq_printf(seq,
 		   "Locally retrieved addresses (from %s) announced via TT (TTVN: %u):\n",
@@ -479,7 +467,7 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 out:
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
-	return ret;
+	return 0;
 }
 
 static void
@@ -842,22 +830,10 @@ int batadv_tt_global_seq_print_text(struct seq_file *seq, void *offset)
 	struct hlist_node *node;
 	struct hlist_head *head;
 	uint32_t i;
-	int ret = 0;
 
-	primary_if = batadv_primary_if_get_selected(bat_priv);
-	if (!primary_if) {
-		ret = seq_printf(seq,
-				 "BATMAN mesh %s disabled - please specify interfaces to enable it\n",
-				 net_dev->name);
+	primary_if = batadv_seq_print_text_primary_if_get(seq);
+	if (!primary_if)
 		goto out;
-	}
-
-	if (primary_if->if_status != BATADV_IF_ACTIVE) {
-		ret = seq_printf(seq,
-				 "BATMAN mesh %s disabled - primary interface not active\n",
-				 net_dev->name);
-		goto out;
-	}
 
 	seq_printf(seq,
 		   "Globally announced TT entries received via the mesh %s\n",
@@ -881,7 +857,7 @@ int batadv_tt_global_seq_print_text(struct seq_file *seq, void *offset)
 out:
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
-	return ret;
+	return 0;
 }
 
 /* deletes the orig list of a tt_global_entry */
-- 
1.7.12.4
