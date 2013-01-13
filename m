From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 04/15] batman-adv: improve local translation table output
Date: Mon, 14 Jan 2013 09:41:09 +1000
Message-ID: <1358120480-25960-5-git-send-email-ordex@autistici.org>
References: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:49517 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755594Ab3AMXml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 18:42:41 -0500
In-Reply-To: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a nice header to the local translation table and
the last_seen time for each local entry

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/translation-table.c | 27 +++++++++++++++++++++++----
 1 file changed, 23 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 22457a7..426a3ae 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -472,10 +472,16 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 	struct batadv_priv *bat_priv = netdev_priv(net_dev);
 	struct batadv_hashtable *hash = bat_priv->tt.local_hash;
 	struct batadv_tt_common_entry *tt_common_entry;
+	struct batadv_tt_local_entry *tt_local;
 	struct batadv_hard_iface *primary_if;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	uint32_t i;
+	int last_seen_secs;
+	int last_seen_msecs;
+	unsigned long last_seen_jiffies;
+	bool no_purge;
+	uint16_t np_flag = BATADV_TT_CLIENT_NOPURGE;
 
 	primary_if = batadv_seq_print_text_primary_if_get(seq);
 	if (!primary_if)
@@ -484,6 +490,8 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 	seq_printf(seq,
 		   "Locally retrieved addresses (from %s) announced via TT (TTVN: %u):\n",
 		   net_dev->name, (uint8_t)atomic_read(&bat_priv->tt.vn));
+	seq_printf(seq, "       %-13s %-7s %-10s\n", "Client", "Flags",
+		   "Last seen");
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -491,18 +499,29 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(tt_common_entry, node,
 					 head, hash_entry) {
-			seq_printf(seq, " * %pM [%c%c%c%c%c]\n",
+			tt_local = container_of(tt_common_entry,
+						struct batadv_tt_local_entry,
+						common);
+			last_seen_jiffies = jiffies - tt_local->last_seen;
+			last_seen_msecs = jiffies_to_msecs(last_seen_jiffies);
+			last_seen_secs = last_seen_msecs / 1000;
+			last_seen_msecs = last_seen_msecs % 1000;
+
+			no_purge = tt_common_entry->flags & np_flag;
+
+			seq_printf(seq, " * %pM [%c%c%c%c%c] %3u.%03u\n",
 				   tt_common_entry->addr,
 				   (tt_common_entry->flags &
 				    BATADV_TT_CLIENT_ROAM ? 'R' : '.'),
-				   (tt_common_entry->flags &
-				    BATADV_TT_CLIENT_NOPURGE ? 'P' : '.'),
+				   no_purge ? 'P' : '.',
 				   (tt_common_entry->flags &
 				    BATADV_TT_CLIENT_NEW ? 'N' : '.'),
 				   (tt_common_entry->flags &
 				    BATADV_TT_CLIENT_PENDING ? 'X' : '.'),
 				   (tt_common_entry->flags &
-				    BATADV_TT_CLIENT_WIFI ? 'W' : '.'));
+				    BATADV_TT_CLIENT_WIFI ? 'W' : '.'),
+				   no_purge ? last_seen_secs : 0,
+				   no_purge ? last_seen_msecs : 0);
 		}
 		rcu_read_unlock();
 	}
-- 
1.8.0.2
