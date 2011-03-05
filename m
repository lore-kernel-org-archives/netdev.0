From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 15/28] batman-adv: protect bit operations to count OGMs with spinlock
Date: Sat,  5 Mar 2011 13:28:29 +0100
Message-ID: <1299328122-21468-16-git-send-email-sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:36310 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753293Ab1CEM34 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 07:29:56 -0500
In-Reply-To: <1299328122-21468-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Marek Lindner <lindner_marek@yahoo.de>

Reported-by: Linus L=C3=BCssing <linus.luessing@saxnet.de>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/routing.c |   61 ++++++++++++++++++++++----------------=
-------
 net/batman-adv/types.h   |    6 ++--
 2 files changed, 33 insertions(+), 34 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 9185666..29a689a 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -155,7 +155,8 @@ static int is_bidirectional_neigh(struct orig_node =
*orig_node,
 	struct neigh_node *neigh_node =3D NULL, *tmp_neigh_node =3D NULL;
 	struct hlist_node *node;
 	unsigned char total_count;
-	int ret =3D 0;
+	uint8_t orig_eq_count, neigh_rq_count, tq_own;
+	int tq_asym_penalty, ret =3D 0;
=20
 	if (orig_node =3D=3D orig_neigh_node) {
 		rcu_read_lock();
@@ -216,23 +217,25 @@ static int is_bidirectional_neigh(struct orig_nod=
e *orig_node,
=20
 	orig_node->last_valid =3D jiffies;
=20
+	spin_lock_bh(&orig_node->ogm_cnt_lock);
+	orig_eq_count =3D orig_neigh_node->bcast_own_sum[if_incoming->if_num]=
;
+	neigh_rq_count =3D neigh_node->real_packet_count;
+	spin_unlock_bh(&orig_node->ogm_cnt_lock);
+
 	/* pay attention to not get a value bigger than 100 % */
-	total_count =3D (orig_neigh_node->bcast_own_sum[if_incoming->if_num] =
>
-		       neigh_node->real_packet_count ?
-		       neigh_node->real_packet_count :
-		       orig_neigh_node->bcast_own_sum[if_incoming->if_num]);
+	total_count =3D (orig_eq_count > neigh_rq_count ?
+		       neigh_rq_count : orig_eq_count);
=20
 	/* if we have too few packets (too less data) we set tq_own to zero *=
/
 	/* if we receive too few packets it is not considered bidirectional *=
/
 	if ((total_count < TQ_LOCAL_BIDRECT_SEND_MINIMUM) ||
-	    (neigh_node->real_packet_count < TQ_LOCAL_BIDRECT_RECV_MINIMUM))
-		orig_neigh_node->tq_own =3D 0;
+	    (neigh_rq_count < TQ_LOCAL_BIDRECT_RECV_MINIMUM))
+		tq_own =3D 0;
 	else
 		/* neigh_node->real_packet_count is never zero as we
 		 * only purge old information when getting new
 		 * information */
-		orig_neigh_node->tq_own =3D (TQ_MAX_VALUE * total_count) /
-			neigh_node->real_packet_count;
+		tq_own =3D (TQ_MAX_VALUE * total_count) /	neigh_rq_count;
=20
 	/*
 	 * 1 - ((1-x) ** 3), normalized to TQ_MAX_VALUE this does
@@ -240,20 +243,16 @@ static int is_bidirectional_neigh(struct orig_nod=
e *orig_node,
 	 * punishes asymmetric links more.  This will give a value
 	 * between 0 and TQ_MAX_VALUE
 	 */
-	orig_neigh_node->tq_asym_penalty =3D
-		TQ_MAX_VALUE -
-		(TQ_MAX_VALUE *
-		 (TQ_LOCAL_WINDOW_SIZE - neigh_node->real_packet_count) *
-		 (TQ_LOCAL_WINDOW_SIZE - neigh_node->real_packet_count) *
-		 (TQ_LOCAL_WINDOW_SIZE - neigh_node->real_packet_count)) /
-		(TQ_LOCAL_WINDOW_SIZE *
-		 TQ_LOCAL_WINDOW_SIZE *
-		 TQ_LOCAL_WINDOW_SIZE);
-
-	batman_packet->tq =3D ((batman_packet->tq *
-			      orig_neigh_node->tq_own *
-			      orig_neigh_node->tq_asym_penalty) /
-			     (TQ_MAX_VALUE * TQ_MAX_VALUE));
+	tq_asym_penalty =3D TQ_MAX_VALUE - (TQ_MAX_VALUE *
+				(TQ_LOCAL_WINDOW_SIZE - neigh_rq_count) *
+				(TQ_LOCAL_WINDOW_SIZE - neigh_rq_count) *
+				(TQ_LOCAL_WINDOW_SIZE - neigh_rq_count)) /
+					(TQ_LOCAL_WINDOW_SIZE *
+					 TQ_LOCAL_WINDOW_SIZE *
+					 TQ_LOCAL_WINDOW_SIZE);
+
+	batman_packet->tq =3D ((batman_packet->tq * tq_own * tq_asym_penalty)=
 /
+						(TQ_MAX_VALUE * TQ_MAX_VALUE));
=20
 	bat_dbg(DBG_BATMAN, bat_priv,
 		"bidirectional: "
@@ -261,8 +260,7 @@ static int is_bidirectional_neigh(struct orig_node =
*orig_node,
 		"real recv =3D %2i, local tq: %3i, asym_penalty: %3i, "
 		"total tq: %3i\n",
 		orig_node->orig, orig_neigh_node->orig, total_count,
-		neigh_node->real_packet_count, orig_neigh_node->tq_own,
-		orig_neigh_node->tq_asym_penalty, batman_packet->tq);
+		neigh_rq_count, tq_own,	tq_asym_penalty, batman_packet->tq);
=20
 	/* if link has the minimum required transmission quality
 	 * consider it bidirectional */
@@ -559,18 +557,19 @@ static char count_real_packets(struct ethhdr *eth=
hdr,
 	char is_duplicate =3D 0;
 	int32_t seq_diff;
 	int need_update =3D 0;
-	int set_mark;
+	int set_mark, ret =3D -1;
=20
 	orig_node =3D get_orig_node(bat_priv, batman_packet->orig);
 	if (!orig_node)
 		return 0;
=20
+	spin_lock_bh(&orig_node->ogm_cnt_lock);
 	seq_diff =3D batman_packet->seqno - orig_node->last_real_seqno;
=20
 	/* signalize caller that the packet is to be dropped. */
 	if (window_protected(bat_priv, seq_diff,
 			     &orig_node->batman_seqno_reset))
-		goto err;
+		goto out;
=20
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(tmp_neigh_node, node,
@@ -603,12 +602,12 @@ static char count_real_packets(struct ethhdr *eth=
hdr,
 		orig_node->last_real_seqno =3D batman_packet->seqno;
 	}
=20
-	kref_put(&orig_node->refcount, orig_node_free_ref);
-	return is_duplicate;
+	ret =3D is_duplicate;
=20
-err:
+out:
+	spin_unlock_bh(&orig_node->ogm_cnt_lock);
 	kref_put(&orig_node->refcount, orig_node_free_ref);
-	return -1;
+	return ret;
 }
=20
 void receive_bat_packet(struct ethhdr *ethhdr,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index e0140c6..9a14276 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -70,8 +70,6 @@ struct orig_node {
 	struct neigh_node *router;
 	unsigned long *bcast_own;
 	uint8_t *bcast_own_sum;
-	uint8_t tq_own;
-	int tq_asym_penalty;
 	unsigned long last_valid;
 	unsigned long bcast_seqno_reset;
 	unsigned long batman_seqno_reset;
@@ -89,7 +87,9 @@ struct orig_node {
 	struct kref refcount;
 	struct bat_priv *bat_priv;
 	unsigned long last_frag_packet;
-	spinlock_t ogm_cnt_lock; /* protects ogm counter */
+	spinlock_t ogm_cnt_lock; /* protects: bcast_own, bcast_own_sum,
+				  * neigh_node->real_bits,
+				  * neigh_node->real_packet_count */
 	atomic_t bond_candidates;
 	struct list_head bond_list;
 };
--=20
1.7.2.3

