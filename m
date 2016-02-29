From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 10/15] batman-adv: ELP - send unicast ELP packets for throughput sampling
Date: Mon, 29 Feb 2016 19:06:03 +0800
Message-ID: <1456743968-17562-11-git-send-email-a__32087.8212609843$1456745913$gmane$org@unstable.cc>
References: <1456743968-17562-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:1185 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752180AbcB2LiY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 06:38:24 -0500
In-Reply-To: <1456743968-17562-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

In case of an unused wireless link, the mac80211 throughput estimation
won't get updated further. Consequently, the reported throughput metric
will become obsolete.

With this patch unicast sampling is introduced by periodically sending
unicast ELP packets to each neighbor on idle WiFi links. These sampling
packets will fill an entire frame, so that the measurement is as
reliable as possible

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/bat_v_elp.c | 69 ++++++++++++++++++++++++++++++++++++++++++++++
 net/batman-adv/main.h      |  3 ++
 2 files changed, 72 insertions(+)

diff --git a/net/batman-adv/bat_v_elp.c b/net/batman-adv/bat_v_elp.c
index 8376730ebd69..3844e7efd0b0 100644
--- a/net/batman-adv/bat_v_elp.c
+++ b/net/batman-adv/bat_v_elp.c
@@ -165,6 +165,69 @@ void batadv_v_elp_throughput_metric_update(struct work_struct *work)
 }
 
 /**
+ * batadv_v_elp_wifi_neigh_probe - send link probing packets to a neighbour
+ * @neigh: the neighbour to probe
+ *
+ * Sends a predefined number of unicast wifi packets to a given neighbour in
+ * order to trigger the throughput estimation on this link by the RC algorithm.
+ * Packets are sent only if there there is not enough payload unicast traffic
+ * towards this neighbour..
+ *
+ * Return: True on success and false in case of error during skb preparation.
+ */
+static bool
+batadv_v_elp_wifi_neigh_probe(struct batadv_hardif_neigh_node *neigh)
+{
+	struct batadv_hard_iface *hard_iface = neigh->if_incoming;
+	struct batadv_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
+	unsigned long last_tx_diff;
+	struct sk_buff *skb;
+	int probe_len, i;
+	int elp_skb_len;
+
+	/* this probing routine is for Wifi neighbours only */
+	if (!batadv_is_wifi_netdev(hard_iface->net_dev))
+		return true;
+
+	/* probe the neighbor only if no unicast packets have been sent
+	 * to it in the last 100 milliseconds: this is the rate control
+	 * algorithm sampling interval (minstrel). In this way, if not
+	 * enough traffic has been sent to the neighbor, batman-adv can
+	 * generate 2 probe packets and push the RC algorithm to perform
+	 * the sampling
+	 */
+	last_tx_diff = jiffies_to_msecs(jiffies - neigh->bat_v.last_unicast_tx);
+	if (last_tx_diff <= BATADV_ELP_PROBE_MAX_TX_DIFF)
+		return true;
+
+	probe_len = max_t(int, sizeof(struct batadv_elp_packet),
+			  BATADV_ELP_MIN_PROBE_SIZE);
+
+	for (i = 0; i < BATADV_ELP_PROBES_PER_NODE; i++) {
+		elp_skb_len = hard_iface->bat_v.elp_skb->len;
+		skb = skb_copy_expand(hard_iface->bat_v.elp_skb, 0,
+				      probe_len - elp_skb_len,
+				      GFP_ATOMIC);
+		if (!skb)
+			return false;
+
+		/* Tell the skb to get as big as the allocated space (we want
+		 * the packet to be exactly of that size to make the link
+		 * throughput estimation effective.
+		 */
+		skb_put(skb, probe_len - hard_iface->bat_v.elp_skb->len);
+
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+			   "Sending unicast (probe) ELP packet on interface %s to %pM\n",
+			   hard_iface->net_dev->name, neigh->addr);
+
+		batadv_send_skb_packet(skb, hard_iface, neigh->addr);
+	}
+
+	return true;
+}
+
+/**
  * batadv_v_elp_periodic_work - ELP periodic task per interface
  * @work: work queue item
  *
@@ -227,6 +290,12 @@ static void batadv_v_elp_periodic_work(struct work_struct *work)
 	 */
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(hardif_neigh, &hard_iface->neigh_list, list) {
+		if (!batadv_v_elp_wifi_neigh_probe(hardif_neigh))
+			/* if something goes wrong while probing, better to stop
+			 * sending packets immediately and reschedule the task
+			 */
+			break;
+
 		if (!kref_get_unless_zero(&hardif_neigh->refcount))
 			continue;
 
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 5c68bf2618c7..878c35974845 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -63,6 +63,9 @@
 
 /* B.A.T.M.A.N. V */
 #define BATADV_THROUGHPUT_DEFAULT_VALUE 10 /* 1 Mbps */
+#define BATADV_ELP_PROBES_PER_NODE 2
+#define BATADV_ELP_MIN_PROBE_SIZE 200 /* bytes */
+#define BATADV_ELP_PROBE_MAX_TX_DIFF 100 /* milliseconds */
 #define BATADV_ELP_MAX_AGE 64
 #define BATADV_OGM_MAX_ORIGDIFF 5
 #define BATADV_OGM_MAX_AGE 64
-- 
2.7.2
