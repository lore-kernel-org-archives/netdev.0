From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 05/18] batman-adv: Directly print to seq_file in vis
Date: Thu, 28 Jun 2012 11:34:14 +0200
Message-ID: <1340876067-28333-6-git-send-email-ordex@autistici.org>
References: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:30183 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932651Ab2F1Je3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 05:34:29 -0400
In-Reply-To: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The vis output doesn't need to be buffered in an character buffer before it can
be send to the userspace program that reads from the vis debug file.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/vis.c |  226 ++++++++++++++++++--------------------------------
 1 file changed, 82 insertions(+), 144 deletions(-)

diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 6b7a1c0..3095c41 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -140,72 +140,117 @@ static void batadv_vis_data_insert_interface(const uint8_t *interface,
 	hlist_add_head(&entry->list, if_list);
 }
 
-static ssize_t batadv_vis_prim_sec(char *buff, const struct hlist_head *if_list)
+static void batadv_vis_data_read_prim_sec(struct seq_file *seq,
+					  const struct hlist_head *if_list)
 {
 	struct if_list_entry *entry;
 	struct hlist_node *pos;
-	size_t len = 0;
 
 	hlist_for_each_entry(entry, pos, if_list, list) {
 		if (entry->primary)
-			len += sprintf(buff + len, "PRIMARY, ");
+			seq_printf(seq, "PRIMARY, ");
 		else
-			len += sprintf(buff + len,  "SEC %pM, ", entry->addr);
+			seq_printf(seq,  "SEC %pM, ", entry->addr);
 	}
-
-	return len;
-}
-
-static size_t batadv_vis_cnt_prim_sec(struct hlist_head *if_list)
-{
-	struct if_list_entry *entry;
-	struct hlist_node *pos;
-	size_t count = 0;
-
-	hlist_for_each_entry(entry, pos, if_list, list) {
-		if (entry->primary)
-			count += 9;
-		else
-			count += 23;
-	}
-
-	return count;
 }
 
 /* read an entry  */
-static ssize_t batadv_vis_data_read_entry(char *buff,
+static ssize_t batadv_vis_data_read_entry(struct seq_file *seq,
 					  const struct vis_info_entry *entry,
 					  const uint8_t *src, bool primary)
 {
-	/* maximal length: max(4+17+2, 3+17+1+3+2) == 26 */
 	if (primary && entry->quality == 0)
-		return sprintf(buff, "TT %pM, ", entry->dest);
+		return seq_printf(seq, "TT %pM, ", entry->dest);
 	else if (batadv_compare_eth(entry->src, src))
-		return sprintf(buff, "TQ %pM %d, ", entry->dest,
-			       entry->quality);
+		return seq_printf(seq, "TQ %pM %d, ", entry->dest,
+				  entry->quality);
 
 	return 0;
 }
 
-int batadv_vis_seq_print_text(struct seq_file *seq, void *offset)
+static void batadv_vis_data_insert_interfaces(struct hlist_head *list,
+					      struct vis_packet *packet,
+					      struct vis_info_entry *entries)
+{
+	int i;
+
+	for (i = 0; i < packet->entries; i++) {
+		if (entries[i].quality == 0)
+			continue;
+
+		if (batadv_compare_eth(entries[i].src, packet->vis_orig))
+			continue;
+
+		batadv_vis_data_insert_interface(entries[i].src, list, false);
+	}
+}
+
+static void batadv_vis_data_read_entries(struct seq_file *seq,
+					 struct hlist_head *list,
+					 struct vis_packet *packet,
+					 struct vis_info_entry *entries)
+{
+	int i;
+	struct if_list_entry *entry;
+	struct hlist_node *pos;
+
+	hlist_for_each_entry(entry, pos, list, list) {
+		seq_printf(seq, "%pM,", entry->addr);
+
+		for (i = 0; i < packet->entries; i++)
+			batadv_vis_data_read_entry(seq, &entries[i],
+						   entry->addr, entry->primary);
+
+		/* add primary/secondary records */
+		if (batadv_compare_eth(entry->addr, packet->vis_orig))
+			batadv_vis_data_read_prim_sec(seq, list);
+
+		seq_printf(seq, "\n");
+	}
+}
+
+static void batadv_vis_seq_print_text_bucket(struct seq_file *seq,
+					     const struct hlist_head *head)
 {
-	struct hard_iface *primary_if;
 	struct hlist_node *node;
-	struct hlist_head *head;
 	struct vis_info *info;
 	struct vis_packet *packet;
+	uint8_t *entries_pos;
 	struct vis_info_entry *entries;
+	struct if_list_entry *entry;
+	struct hlist_node *pos, *n;
+
+	HLIST_HEAD(vis_if_list);
+
+	hlist_for_each_entry_rcu(info, node, head, hash_entry) {
+		packet = (struct vis_packet *)info->skb_packet->data;
+		entries_pos = (uint8_t *)packet + sizeof(*packet);
+		entries = (struct vis_info_entry *)entries_pos;
+
+		batadv_vis_data_insert_interface(packet->vis_orig, &vis_if_list,
+						 true);
+		batadv_vis_data_insert_interfaces(&vis_if_list, packet,
+						  entries);
+		batadv_vis_data_read_entries(seq, &vis_if_list, packet,
+					     entries);
+
+		hlist_for_each_entry_safe(entry, pos, n, &vis_if_list, list) {
+			hlist_del(&entry->list);
+			kfree(entry);
+		}
+	}
+}
+
+int batadv_vis_seq_print_text(struct seq_file *seq, void *offset)
+{
+	struct hard_iface *primary_if;
+	struct hlist_head *head;
 	struct net_device *net_dev = (struct net_device *)seq->private;
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
 	struct hashtable_t *hash = bat_priv->vis_hash;
-	HLIST_HEAD(vis_if_list);
-	struct if_list_entry *entry;
-	struct hlist_node *pos, *n;
 	uint32_t i;
-	int j, ret = 0;
+	int ret = 0;
 	int vis_server = atomic_read(&bat_priv->vis_mode);
-	size_t buff_pos, buf_size;
-	char *buff;
 
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
@@ -214,120 +259,13 @@ int batadv_vis_seq_print_text(struct seq_file *seq, void *offset)
 	if (vis_server == VIS_TYPE_CLIENT_UPDATE)
 		goto out;
 
-	buf_size = 1;
-	/* Estimate length */
 	spin_lock_bh(&bat_priv->vis_hash_lock);
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
-
-		rcu_read_lock();
-		hlist_for_each_entry_rcu(info, node, head, hash_entry) {
-			packet = (struct vis_packet *)info->skb_packet->data;
-			entries = (struct vis_info_entry *)
-				((char *)packet + sizeof(*packet));
-
-			batadv_vis_data_insert_interface(packet->vis_orig,
-							 &vis_if_list, true);
-
-			for (j = 0; j < packet->entries; j++) {
-				if (entries[j].quality == 0)
-					continue;
-				if (batadv_compare_eth(entries[j].src,
-						       packet->vis_orig))
-					continue;
-				batadv_vis_data_insert_interface(entries[j].src,
-								 &vis_if_list,
-								 false);
-			}
-
-			hlist_for_each_entry(entry, pos, &vis_if_list, list) {
-				buf_size += 18 + 26 * packet->entries;
-
-				/* add primary/secondary records */
-				if (batadv_compare_eth(entry->addr,
-						       packet->vis_orig))
-					buf_size +=
-					  batadv_vis_cnt_prim_sec(&vis_if_list);
-
-				buf_size += 1;
-			}
-
-			hlist_for_each_entry_safe(entry, pos, n, &vis_if_list,
-						  list) {
-				hlist_del(&entry->list);
-				kfree(entry);
-			}
-		}
-		rcu_read_unlock();
+		batadv_vis_seq_print_text_bucket(seq, head);
 	}
-
-	buff = kmalloc(buf_size, GFP_ATOMIC);
-	if (!buff) {
-		spin_unlock_bh(&bat_priv->vis_hash_lock);
-		ret = -ENOMEM;
-		goto out;
-	}
-	buff[0] = '\0';
-	buff_pos = 0;
-
-	for (i = 0; i < hash->size; i++) {
-		head = &hash->table[i];
-
-		rcu_read_lock();
-		hlist_for_each_entry_rcu(info, node, head, hash_entry) {
-			packet = (struct vis_packet *)info->skb_packet->data;
-			entries = (struct vis_info_entry *)
-				((char *)packet + sizeof(*packet));
-
-			batadv_vis_data_insert_interface(packet->vis_orig,
-							 &vis_if_list, true);
-
-			for (j = 0; j < packet->entries; j++) {
-				if (entries[j].quality == 0)
-					continue;
-				if (batadv_compare_eth(entries[j].src,
-						       packet->vis_orig))
-					continue;
-				batadv_vis_data_insert_interface(entries[j].src,
-								 &vis_if_list,
-								 false);
-			}
-
-			hlist_for_each_entry(entry, pos, &vis_if_list, list) {
-				buff_pos += sprintf(buff + buff_pos, "%pM,",
-						entry->addr);
-
-				for (j = 0; j < packet->entries; j++)
-					buff_pos += batadv_vis_data_read_entry(
-							buff + buff_pos,
-							&entries[j],
-							entry->addr,
-							entry->primary);
-
-				/* add primary/secondary records */
-				if (batadv_compare_eth(entry->addr,
-						       packet->vis_orig))
-					buff_pos +=
-					 batadv_vis_prim_sec(buff + buff_pos,
-							     &vis_if_list);
-
-				buff_pos += sprintf(buff + buff_pos, "\n");
-			}
-
-			hlist_for_each_entry_safe(entry, pos, n, &vis_if_list,
-						  list) {
-				hlist_del(&entry->list);
-				kfree(entry);
-			}
-		}
-		rcu_read_unlock();
-	}
-
 	spin_unlock_bh(&bat_priv->vis_hash_lock);
 
-	seq_printf(seq, "%s", buff);
-	kfree(buff);
-
 out:
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
-- 
1.7.9.4
