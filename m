From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 02/16] batman-adv: split hard_iface struct
	for each routing protocol
Date: Mon, 29 Oct 2012 09:58:03 +0100
Message-ID: <1351501097-1289-3-git-send-email-ordex@autistici.org>
References: <1351501097-1289-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1351501097-1289-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>

Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/bat_iv_ogm.c     | 43 +++++++++++++++++++++++------------------
 net/batman-adv/hard-interface.c |  4 ++--
 net/batman-adv/types.h          | 16 ++++++++++++---
 3 files changed, 39 insertions(+), 24 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index b02b75d..75403a4 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -57,20 +57,22 @@ out:
 static int batadv_iv_ogm_iface_enable(struct batadv_hard_iface *hard_iface)
 {
 	struct batadv_ogm_packet *batadv_ogm_packet;
+	unsigned char *ogm_buff;
 	uint32_t random_seqno;
 	int res = -ENOMEM;
 
 	/* randomize initial seqno to avoid collision */
 	get_random_bytes(&random_seqno, sizeof(random_seqno));
-	atomic_set(&hard_iface->seqno, random_seqno);
+	atomic_set(&hard_iface->bat_iv.ogm_seqno, random_seqno);
 
-	hard_iface->packet_len = BATADV_OGM_HLEN;
-	hard_iface->packet_buff = kmalloc(hard_iface->packet_len, GFP_ATOMIC);
-
-	if (!hard_iface->packet_buff)
+	hard_iface->bat_iv.ogm_buff_len = BATADV_OGM_HLEN;
+	ogm_buff = kmalloc(hard_iface->bat_iv.ogm_buff_len, GFP_ATOMIC);
+	if (!ogm_buff)
 		goto out;
 
-	batadv_ogm_packet = (struct batadv_ogm_packet *)hard_iface->packet_buff;
+	hard_iface->bat_iv.ogm_buff = ogm_buff;
+
+	batadv_ogm_packet = (struct batadv_ogm_packet *)ogm_buff;
 	batadv_ogm_packet->header.packet_type = BATADV_IV_OGM;
 	batadv_ogm_packet->header.version = BATADV_COMPAT_VERSION;
 	batadv_ogm_packet->header.ttl = 2;
@@ -87,15 +89,16 @@ out:
 
 static void batadv_iv_ogm_iface_disable(struct batadv_hard_iface *hard_iface)
 {
-	kfree(hard_iface->packet_buff);
-	hard_iface->packet_buff = NULL;
+	kfree(hard_iface->bat_iv.ogm_buff);
+	hard_iface->bat_iv.ogm_buff = NULL;
 }
 
 static void batadv_iv_ogm_iface_update_mac(struct batadv_hard_iface *hard_iface)
 {
 	struct batadv_ogm_packet *batadv_ogm_packet;
+	unsigned char *ogm_buff = hard_iface->bat_iv.ogm_buff;
 
-	batadv_ogm_packet = (struct batadv_ogm_packet *)hard_iface->packet_buff;
+	batadv_ogm_packet = (struct batadv_ogm_packet *)ogm_buff;
 	memcpy(batadv_ogm_packet->orig,
 	       hard_iface->net_dev->dev_addr, ETH_ALEN);
 	memcpy(batadv_ogm_packet->prev_sender,
@@ -106,8 +109,9 @@ static void
 batadv_iv_ogm_primary_iface_set(struct batadv_hard_iface *hard_iface)
 {
 	struct batadv_ogm_packet *batadv_ogm_packet;
+	unsigned char *ogm_buff = hard_iface->bat_iv.ogm_buff;
 
-	batadv_ogm_packet = (struct batadv_ogm_packet *)hard_iface->packet_buff;
+	batadv_ogm_packet = (struct batadv_ogm_packet *)ogm_buff;
 	batadv_ogm_packet->flags = BATADV_PRIMARIES_FIRST_HOP;
 	batadv_ogm_packet->header.ttl = BATADV_TTL;
 }
@@ -590,8 +594,10 @@ static void batadv_iv_ogm_forward(struct batadv_orig_node *orig_node,
 static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 {
 	struct batadv_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
+	unsigned char **ogm_buff = &hard_iface->bat_iv.ogm_buff;
 	struct batadv_ogm_packet *batadv_ogm_packet;
 	struct batadv_hard_iface *primary_if;
+	int *ogm_buff_len = &hard_iface->bat_iv.ogm_buff_len;
 	int vis_server, tt_num_changes = 0;
 	uint32_t seqno;
 	uint8_t bandwidth;
@@ -600,17 +606,16 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 
 	if (hard_iface == primary_if)
-		tt_num_changes = batadv_tt_append_diff(bat_priv,
-						       &hard_iface->packet_buff,
-						       &hard_iface->packet_len,
+		tt_num_changes = batadv_tt_append_diff(bat_priv, ogm_buff,
+						       ogm_buff_len,
 						       BATADV_OGM_HLEN);
 
-	batadv_ogm_packet = (struct batadv_ogm_packet *)hard_iface->packet_buff;
+	batadv_ogm_packet = (struct batadv_ogm_packet *)(*ogm_buff);
 
 	/* change sequence number to network order */
-	seqno = (uint32_t)atomic_read(&hard_iface->seqno);
+	seqno = (uint32_t)atomic_read(&hard_iface->bat_iv.ogm_seqno);
 	batadv_ogm_packet->seqno = htonl(seqno);
-	atomic_inc(&hard_iface->seqno);
+	atomic_inc(&hard_iface->bat_iv.ogm_seqno);
 
 	batadv_ogm_packet->ttvn = atomic_read(&bat_priv->tt.vn);
 	batadv_ogm_packet->tt_crc = htons(bat_priv->tt.local_crc);
@@ -631,8 +636,8 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 	}
 
 	batadv_slide_own_bcast_window(hard_iface);
-	batadv_iv_ogm_queue_add(bat_priv, hard_iface->packet_buff,
-				hard_iface->packet_len, hard_iface, 1,
+	batadv_iv_ogm_queue_add(bat_priv, hard_iface->bat_iv.ogm_buff,
+				hard_iface->bat_iv.ogm_buff_len, hard_iface, 1,
 				batadv_iv_ogm_emit_send_time(bat_priv));
 
 	if (primary_if)
@@ -1015,7 +1020,7 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 		return;
 
 	/* could be changed by schedule_own_packet() */
-	if_incoming_seqno = atomic_read(&if_incoming->seqno);
+	if_incoming_seqno = atomic_read(&if_incoming->bat_iv.ogm_seqno);
 
 	if (batadv_ogm_packet->flags & BATADV_DIRECTLINK)
 		has_directlink_flag = 1;
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index d112fd6..fab9e41 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -450,8 +450,8 @@ batadv_hardif_add_interface(struct net_device *net_dev)
 	/* This can't be called via a bat_priv callback because
 	 * we have no bat_priv yet.
 	 */
-	atomic_set(&hard_iface->seqno, 1);
-	hard_iface->packet_buff = NULL;
+	atomic_set(&hard_iface->bat_iv.ogm_seqno, 1);
+	hard_iface->bat_iv.ogm_buff = NULL;
 
 	return hard_iface;
 
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index ac1e07a..faaebd6 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -28,20 +28,30 @@
 	(ETH_HLEN + max(sizeof(struct batadv_unicast_packet), \
 			sizeof(struct batadv_bcast_packet)))
 
+/**
+ * struct batadv_hard_iface_bat_iv - per hard interface B.A.T.M.A.N. IV data
+ * @ogm_buff: buffer holding the OGM packet
+ * @ogm_buff_len: length of the OGM packet buffer
+ * @ogm_seqno: OGM sequence number - used to identify each OGM
+ */
+struct batadv_hard_iface_bat_iv {
+	unsigned char *ogm_buff;
+	int ogm_buff_len;
+	atomic_t ogm_seqno;
+};
+
 struct batadv_hard_iface {
 	struct list_head list;
 	int16_t if_num;
 	char if_status;
 	struct net_device *net_dev;
-	atomic_t seqno;
 	atomic_t frag_seqno;
-	unsigned char *packet_buff;
-	int packet_len;
 	struct kobject *hardif_obj;
 	atomic_t refcount;
 	struct packet_type batman_adv_ptype;
 	struct net_device *soft_iface;
 	struct rcu_head rcu;
+	struct batadv_hard_iface_bat_iv bat_iv;
 };
 
 /**
-- 
1.7.12.4
