From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 13/15] batman-adv: B.A.T.M.A.N. V - implement bat_neigh_print API
Date: Mon, 29 Feb 2016 19:06:06 +0800
Message-ID: <1456743968-17562-14-git-send-email-a__10036.7865096361$1456744830$gmane$org@unstable.cc>
References: <1456743968-17562-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Linus Luessing <linus.luessing@web.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@open-mesh.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:11706 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754351AbcB2LUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 06:20:16 -0500
In-Reply-To: <1456743968-17562-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Luessing <linus.luessing@web.de>

Lists all neighbours detected by the Echo Locating Protocol
(ELP) and their throughput metric.

Initially Developed by Linus during a 6 months trainee study
period in Ascom (Switzerland) AG.

Signed-off-by: Linus Luessing <linus.luessing@web.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
---
 net/batman-adv/bat_v.c | 55 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 55 insertions(+)

diff --git a/net/batman-adv/bat_v.c b/net/batman-adv/bat_v.c
index a90117c9a861..3315b9a598af 100644
--- a/net/batman-adv/bat_v.c
+++ b/net/batman-adv/bat_v.c
@@ -118,6 +118,60 @@ batadv_v_orig_print_neigh(struct batadv_orig_node *orig_node,
 }
 
 /**
+ * batadv_v_hardif_neigh_print - print a single ELP neighbour node
+ * @seq: neighbour table seq_file struct
+ * @hardif_neigh: hardif neighbour information
+ */
+static void
+batadv_v_hardif_neigh_print(struct seq_file *seq,
+			    struct batadv_hardif_neigh_node *hardif_neigh)
+{
+	int last_secs, last_msecs;
+	u32 throughput;
+
+	last_secs = jiffies_to_msecs(jiffies - hardif_neigh->last_seen) / 1000;
+	last_msecs = jiffies_to_msecs(jiffies - hardif_neigh->last_seen) % 1000;
+	throughput = ewma_throughput_read(&hardif_neigh->bat_v.throughput);
+
+	seq_printf(seq, "%pM %4i.%03is (%9u.%1u) [%10s]\n",
+		   hardif_neigh->addr, last_secs, last_msecs, throughput / 10,
+		   throughput % 10, hardif_neigh->if_incoming->net_dev->name);
+}
+
+/**
+ * batadv_v_neigh_print - print the single hop neighbour list
+ * @bat_priv: the bat priv with all the soft interface information
+ * @seq: neighbour table seq_file struct
+ */
+static void batadv_v_neigh_print(struct batadv_priv *bat_priv,
+				 struct seq_file *seq)
+{
+	struct net_device *net_dev = (struct net_device *)seq->private;
+	struct batadv_hardif_neigh_node *hardif_neigh;
+	struct batadv_hard_iface *hard_iface;
+	int batman_count = 0;
+
+	seq_printf(seq, "  %-15s %s (%11s) [%10s]\n", "Neighbor",
+		   "last-seen", "throughput", "IF");
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
+		if (hard_iface->soft_iface != net_dev)
+			continue;
+
+		hlist_for_each_entry_rcu(hardif_neigh,
+					 &hard_iface->neigh_list, list) {
+			batadv_v_hardif_neigh_print(seq, hardif_neigh);
+			batman_count++;
+		}
+	}
+	rcu_read_unlock();
+
+	if (batman_count == 0)
+		seq_puts(seq, "No batman nodes in range ...\n");
+}
+
+/**
  * batadv_v_orig_print - print the originator table
  * @bat_priv: the bat priv with all the soft interface information
  * @seq: debugfs table seq_file struct
@@ -230,6 +284,7 @@ static struct batadv_algo_ops batadv_batman_v __read_mostly = {
 	.bat_orig_print = batadv_v_orig_print,
 	.bat_neigh_cmp = batadv_v_neigh_cmp,
 	.bat_neigh_is_similar_or_better = batadv_v_neigh_is_sob,
+	.bat_neigh_print = batadv_v_neigh_print,
 };
 
 /**
-- 
2.7.2
