From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 12/15] batman-adv: B.A.T.M.A.N. V - implement bat_orig_print API
Date: Mon, 29 Feb 2016 19:06:05 +0800
Message-ID: <1456743968-17562-13-git-send-email-a__11549.6594961316$1456746034$gmane$org@unstable.cc>
References: <1456743968-17562-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:7850 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752321AbcB2LkN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 06:40:13 -0500
In-Reply-To: <1456743968-17562-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/bat_v.c | 105 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 105 insertions(+)

diff --git a/net/batman-adv/bat_v.c b/net/batman-adv/bat_v.c
index 953c0d150231..a90117c9a861 100644
--- a/net/batman-adv/bat_v.c
+++ b/net/batman-adv/bat_v.c
@@ -22,11 +22,17 @@
 #include <linux/bug.h>
 #include <linux/cache.h>
 #include <linux/init.h>
+#include <linux/jiffies.h>
+#include <linux/netdevice.h>
+#include <linux/rculist.h>
+#include <linux/rcupdate.h>
+#include <linux/seq_file.h>
 #include <linux/types.h>
 #include <linux/workqueue.h>
 
 #include "bat_v_elp.h"
 #include "bat_v_ogm.h"
+#include "hash.h"
 #include "originator.h"
 #include "packet.h"
 
@@ -81,6 +87,104 @@ static void batadv_v_ogm_emit(struct batadv_forw_packet *forw_packet)
 {
 }
 
+/**
+ * batadv_v_orig_print_neigh - print neighbors for the originator table
+ * @orig_node: the orig_node for which the neighbors are printed
+ * @if_outgoing: outgoing interface for these entries
+ * @seq: debugfs table seq_file struct
+ *
+ * Must be called while holding an rcu lock.
+ */
+static void
+batadv_v_orig_print_neigh(struct batadv_orig_node *orig_node,
+			  struct batadv_hard_iface *if_outgoing,
+			  struct seq_file *seq)
+{
+	struct batadv_neigh_node *neigh_node;
+	struct batadv_neigh_ifinfo *n_ifinfo;
+
+	hlist_for_each_entry_rcu(neigh_node, &orig_node->neigh_list, list) {
+		n_ifinfo = batadv_neigh_ifinfo_get(neigh_node, if_outgoing);
+		if (!n_ifinfo)
+			continue;
+
+		seq_printf(seq, " %pM (%9u.%1u)",
+			   neigh_node->addr,
+			   n_ifinfo->bat_v.throughput / 10,
+			   n_ifinfo->bat_v.throughput % 10);
+
+		batadv_neigh_ifinfo_put(n_ifinfo);
+	}
+}
+
+/**
+ * batadv_v_orig_print - print the originator table
+ * @bat_priv: the bat priv with all the soft interface information
+ * @seq: debugfs table seq_file struct
+ * @if_outgoing: the outgoing interface for which this should be printed
+ */
+static void batadv_v_orig_print(struct batadv_priv *bat_priv,
+				struct seq_file *seq,
+				struct batadv_hard_iface *if_outgoing)
+{
+	struct batadv_neigh_node *neigh_node;
+	struct batadv_hashtable *hash = bat_priv->orig_hash;
+	int last_seen_msecs, last_seen_secs;
+	struct batadv_orig_node *orig_node;
+	struct batadv_neigh_ifinfo *n_ifinfo;
+	unsigned long last_seen_jiffies;
+	struct hlist_head *head;
+	int batman_count = 0;
+	u32 i;
+
+	seq_printf(seq, "  %-15s %s (%11s) %17s [%10s]: %20s ...\n",
+		   "Originator", "last-seen", "throughput", "Nexthop",
+		   "outgoingIF", "Potential nexthops");
+
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
+			neigh_node = batadv_orig_router_get(orig_node,
+							    if_outgoing);
+			if (!neigh_node)
+				continue;
+
+			n_ifinfo = batadv_neigh_ifinfo_get(neigh_node,
+							   if_outgoing);
+			if (!n_ifinfo)
+				goto next;
+
+			last_seen_jiffies = jiffies - orig_node->last_seen;
+			last_seen_msecs = jiffies_to_msecs(last_seen_jiffies);
+			last_seen_secs = last_seen_msecs / 1000;
+			last_seen_msecs = last_seen_msecs % 1000;
+
+			seq_printf(seq, "%pM %4i.%03is (%9u.%1u) %pM [%10s]:",
+				   orig_node->orig, last_seen_secs,
+				   last_seen_msecs,
+				   n_ifinfo->bat_v.throughput / 10,
+				   n_ifinfo->bat_v.throughput % 10,
+				   neigh_node->addr,
+				   neigh_node->if_incoming->net_dev->name);
+
+			batadv_v_orig_print_neigh(orig_node, if_outgoing, seq);
+			seq_puts(seq, "\n");
+			batman_count++;
+
+next:
+			batadv_neigh_node_put(neigh_node);
+			if (n_ifinfo)
+				batadv_neigh_ifinfo_put(n_ifinfo);
+		}
+		rcu_read_unlock();
+	}
+
+	if (batman_count == 0)
+		seq_puts(seq, "No batman nodes in range ...\n");
+}
+
 static int batadv_v_neigh_cmp(struct batadv_neigh_node *neigh1,
 			      struct batadv_hard_iface *if_outgoing1,
 			      struct batadv_neigh_node *neigh2,
@@ -123,6 +227,7 @@ static struct batadv_algo_ops batadv_batman_v __read_mostly = {
 	.bat_hardif_neigh_init = batadv_v_hardif_neigh_init,
 	.bat_ogm_emit = batadv_v_ogm_emit,
 	.bat_ogm_schedule = batadv_v_ogm_schedule,
+	.bat_orig_print = batadv_v_orig_print,
 	.bat_neigh_cmp = batadv_v_neigh_cmp,
 	.bat_neigh_is_similar_or_better = batadv_v_neigh_is_sob,
 };
-- 
2.7.2
