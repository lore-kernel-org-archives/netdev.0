From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 13/16] batman-adv: add broadcast duplicate
	check
Date: Thu,  5 Apr 2012 12:38:59 +0200
Message-ID: <1333622342-6128-14-git-send-email-ordex@autistici.org>
References: <1333622342-6128-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1333622342-6128-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Simon Wunderlich <simon.wunderlich-Y4E02TeZ33kaBlGTGt4zH4SGEyLTKazZ@public.gmane.org>

When multiple backbone gateways relay the same broadcast from the
backbone into the mesh, other nodes in the mesh may receive this
broadcast multiple times. To avoid this, the crc checksums of
received broadcasts are recorded and new broadcast packets with
the same content may be dropped if received by another gateway.

Signed-off-by: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/bridge_loop_avoidance.c |   73 ++++++++++++++++++++++++++++++++
 net/batman-adv/bridge_loop_avoidance.h |    2 +
 net/batman-adv/main.h                  |    3 ++
 net/batman-adv/routing.c               |    4 ++
 net/batman-adv/types.h                 |    7 +++
 5 files changed, 89 insertions(+)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 264ac65..ee9f912 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1040,8 +1040,16 @@ out:
 /* initialize all bla structures */
 int bla_init(struct bat_priv *bat_priv)
 {
+	int i;
+
 	bat_dbg(DBG_BLA, bat_priv, "bla hash registering\n");
 
+	/* initialize the duplicate list */
+	for (i = 0; i < DUPLIST_SIZE; i++)
+		bat_priv->bcast_duplist[i].entrytime =
+			jiffies - msecs_to_jiffies(DUPLIST_TIMEOUT);
+	bat_priv->bcast_duplist_curr = 0;
+
 	if (bat_priv->claim_hash)
 		return 1;
 
@@ -1059,6 +1067,71 @@ int bla_init(struct bat_priv *bat_priv)
 
 /**
  * @bat_priv: the bat priv with all the soft interface information
+ * @bcast_packet: originator mac address
+ * @hdr_size: maximum length of the frame
+ *
+ * check if it is on our broadcast list. Another gateway might
+ * have sent the same packet because it is connected to the same backbone,
+ * so we have to remove this duplicate.
+ *
+ * This is performed by checking the CRC, which will tell us
+ * with a good chance that it is the same packet. If it is furthermore
+ * sent by another host, drop it. We allow equal packets from
+ * the same host however as this might be intended.
+ *
+ **/
+
+int bla_check_bcast_duplist(struct bat_priv *bat_priv,
+			    struct bcast_packet *bcast_packet,
+			    int hdr_size)
+{
+	int i, length, curr;
+	uint8_t *content;
+	uint16_t crc;
+	struct bcast_duplist_entry *entry;
+
+	length = hdr_size - sizeof(*bcast_packet);
+	content = (uint8_t *)bcast_packet;
+	content += sizeof(*bcast_packet);
+
+	/* calculate the crc ... */
+	crc = crc16(0, content, length);
+
+	for (i = 0 ; i < DUPLIST_SIZE; i++) {
+		curr = (bat_priv->bcast_duplist_curr + i) % DUPLIST_SIZE;
+		entry = &bat_priv->bcast_duplist[curr];
+
+		/* we can stop searching if the entry is too old ;
+		 * later entries will be even older */
+		if (has_timed_out(entry->entrytime, DUPLIST_TIMEOUT))
+			break;
+
+		if (entry->crc != crc)
+			continue;
+
+		if (compare_eth(entry->orig, bcast_packet->orig))
+			continue;
+
+		/* this entry seems to match: same crc, not too old,
+		 * and from another gw. therefore return 1 to forbid it. */
+		return 1;
+	}
+	/* not found, add a new entry (overwrite the oldest entry) */
+	curr = (bat_priv->bcast_duplist_curr + DUPLIST_SIZE - 1) % DUPLIST_SIZE;
+	entry = &bat_priv->bcast_duplist[curr];
+	entry->crc = crc;
+	entry->entrytime = jiffies;
+	memcpy(entry->orig, bcast_packet->orig, ETH_ALEN);
+	bat_priv->bcast_duplist_curr = curr;
+
+	/* allow it, its the first occurence. */
+	return 0;
+}
+
+
+
+/**
+ * @bat_priv: the bat priv with all the soft interface information
  * @orig: originator mac address
  *
  * check if the originator is a gateway for any VLAN ID.
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index b74940f..9468c24 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -28,6 +28,8 @@ int bla_is_backbone_gw(struct sk_buff *skb,
 		       struct orig_node *orig_node, int hdr_size);
 int bla_claim_table_seq_print_text(struct seq_file *seq, void *offset);
 int bla_is_backbone_gw_orig(struct bat_priv *bat_priv, uint8_t *orig);
+int bla_check_bcast_duplist(struct bat_priv *bat_priv,
+			    struct bcast_packet *bcast_packet, int hdr_size);
 void bla_update_orig_address(struct bat_priv *bat_priv,
 			     struct hard_iface *primary_if,
 			     struct hard_iface *oldif);
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 82723b5..d9832ac 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -83,6 +83,9 @@
 #define BLA_PERIOD_LENGTH	10000	/* 10 seconds */
 #define BLA_BACKBONE_TIMEOUT	(BLA_PERIOD_LENGTH * 3)
 #define BLA_CLAIM_TIMEOUT	(BLA_PERIOD_LENGTH * 10)
+
+#define DUPLIST_SIZE		16
+#define DUPLIST_TIMEOUT		500	/* 500 ms */
 /* don't reset again within 30 seconds */
 #define RESET_PROTECTION_MS 30000
 #define EXPECTED_SEQNO_RANGE	65536
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index fb5e9f3..f1adef8 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -1075,6 +1075,10 @@ int recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 
 	spin_unlock_bh(&orig_node->bcast_seqno_lock);
 
+	/* check whether this has been sent by another originator before */
+	if (bla_check_bcast_duplist(bat_priv, bcast_packet, hdr_size))
+		goto out;
+
 	/* rebroadcast packet */
 	add_bcast_packet_to_list(bat_priv, skb, 1);
 
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 35cd831..ad97e87 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -140,6 +140,11 @@ struct neigh_node {
 	spinlock_t tq_lock;	/* protects: tq_recv, tq_index */
 };
 
+struct bcast_duplist_entry {
+	uint8_t orig[ETH_ALEN];
+	uint16_t crc;
+	unsigned long entrytime;
+};
 
 struct bat_priv {
 	atomic_t mesh_state;
@@ -186,6 +191,8 @@ struct bat_priv {
 	struct list_head tt_req_list; /* list of pending tt_requests */
 	struct list_head tt_roam_list;
 	struct hashtable_t *vis_hash;
+	struct bcast_duplist_entry bcast_duplist[DUPLIST_SIZE];
+	int bcast_duplist_curr;
 	spinlock_t forw_bat_list_lock; /* protects forw_bat_list */
 	spinlock_t forw_bcast_list_lock; /* protects  */
 	spinlock_t tt_changes_list_lock; /* protects tt_changes */
-- 
1.7.9.4
