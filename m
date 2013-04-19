From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/2] packet: account statistics only in tpacket_stats_u
Date: Fri, 19 Apr 2013 18:12:29 +0200
Message-ID: <1366387949-9161-2-git-send-email-dborkman@redhat.com>
References: <1366387949-9161-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31600 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757401Ab3DSQMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 12:12:34 -0400
In-Reply-To: <1366387949-9161-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, packet_sock has a struct tpacket_stats stats member for
TPACKET_V1 and TPACKET_V2 statistic accounting, and with TPACKET_V3
``union tpacket_stats_u stats_u'' was introduced, where however only
statistics for TPACKET_V3 are held, and when copied to user space,
TPACKET_V3 does some hackery and access also tpacket_stats' stats,
although everything could have been done within the union itself.

Unify accounting within the tpacket_stats_u union so that we can
remove 8 bytes from packet_sock that are there unnecessary. Note that
even if we switch to TPACKET_V3 and would use non mmap(2)ed option,
this still works due to the union with same types + offsets, that are
exposed to the user space.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/packet/af_packet.c | 37 ++++++++++++++++---------------------
 net/packet/internal.h  |  3 +--
 2 files changed, 17 insertions(+), 23 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 7e387ff..3d8c017 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -475,7 +475,7 @@ static void init_prb_bdqc(struct packet_sock *po,
 	p1->hdrlen = po->tp_hdrlen;
 	p1->version = po->tp_version;
 	p1->last_kactive_blk_num = 0;
-	po->stats_u.stats3.tp_freeze_q_cnt = 0;
+	po->stats.stats3.tp_freeze_q_cnt = 0;
 	if (req_u->req3.tp_retire_blk_tov)
 		p1->retire_blk_tov = req_u->req3.tp_retire_blk_tov;
 	else
@@ -643,7 +643,7 @@ static void prb_close_block(struct tpacket_kbdq_core *pkc1,
 	struct tpacket3_hdr *last_pkt;
 	struct tpacket_hdr_v1 *h1 = &pbd1->hdr.bh1;
 
-	if (po->stats.tp_drops)
+	if (po->stats.stats3.tp_drops)
 		status |= TP_STATUS_LOSING;
 
 	last_pkt = (struct tpacket3_hdr *)pkc1->prev;
@@ -748,7 +748,7 @@ static void prb_freeze_queue(struct tpacket_kbdq_core *pkc,
 				  struct packet_sock *po)
 {
 	pkc->reset_pending_on_curr_blk = 1;
-	po->stats_u.stats3.tp_freeze_q_cnt++;
+	po->stats.stats3.tp_freeze_q_cnt++;
 }
 
 #define TOTAL_PKT_LEN_INCL_ALIGN(length) (ALIGN((length), V3_ALIGNMENT))
@@ -1634,7 +1634,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 	nf_reset(skb);
 
 	spin_lock(&sk->sk_receive_queue.lock);
-	po->stats.tp_packets++;
+	po->stats.stats1.tp_packets++;
 	skb->dropcount = atomic_read(&sk->sk_drops);
 	__skb_queue_tail(&sk->sk_receive_queue, skb);
 	spin_unlock(&sk->sk_receive_queue.lock);
@@ -1643,7 +1643,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 
 drop_n_acct:
 	spin_lock(&sk->sk_receive_queue.lock);
-	po->stats.tp_drops++;
+	po->stats.stats1.tp_drops++;
 	atomic_inc(&sk->sk_drops);
 	spin_unlock(&sk->sk_receive_queue.lock);
 
@@ -1762,10 +1762,10 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	 * Anyways, moving it for V1/V2 only as V3 doesn't need this
 	 * at packet level.
 	 */
-		if (po->stats.tp_drops)
+		if (po->stats.stats1.tp_drops)
 			status |= TP_STATUS_LOSING;
 	}
-	po->stats.tp_packets++;
+	po->stats.stats1.tp_packets++;
 	if (copy_skb) {
 		status |= TP_STATUS_COPY;
 		__skb_queue_tail(&sk->sk_receive_queue, copy_skb);
@@ -1860,7 +1860,7 @@ drop:
 	return 0;
 
 ring_is_full:
-	po->stats.tp_drops++;
+	po->stats.stats1.tp_drops++;
 	spin_unlock(&sk->sk_receive_queue.lock);
 
 	sk->sk_data_ready(sk, 0);
@@ -3204,8 +3204,7 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 	struct sock *sk = sock->sk;
 	struct packet_sock *po = pkt_sk(sk);
 	void *data = &val;
-	struct tpacket_stats st;
-	union tpacket_stats_u st_u;
+	union tpacket_stats_u st;
 
 	if (level != SOL_PACKET)
 		return -ENOPROTOOPT;
@@ -3219,22 +3218,18 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 	switch (optname) {
 	case PACKET_STATISTICS:
 		spin_lock_bh(&sk->sk_receive_queue.lock);
+		memcpy(&st, &po->stats, sizeof(st));
+		memset(&po->stats, 0, sizeof(po->stats));
+		spin_unlock_bh(&sk->sk_receive_queue.lock);
+
 		if (po->tp_version == TPACKET_V3) {
 			lv = sizeof(struct tpacket_stats_v3);
-			memcpy(&st_u.stats3, &po->stats,
-			       sizeof(struct tpacket_stats));
-			st_u.stats3.tp_freeze_q_cnt =
-					po->stats_u.stats3.tp_freeze_q_cnt;
-			st_u.stats3.tp_packets += po->stats.tp_drops;
-			data = &st_u.stats3;
+			data = &st.stats3;
 		} else {
 			lv = sizeof(struct tpacket_stats);
-			st = po->stats;
-			st.tp_packets += st.tp_drops;
-			data = &st;
+			data = &st.stats1;
 		}
-		memset(&po->stats, 0, sizeof(st));
-		spin_unlock_bh(&sk->sk_receive_queue.lock);
+
 		break;
 	case PACKET_AUXDATA:
 		val = po->auxdata;
diff --git a/net/packet/internal.h b/net/packet/internal.h
index 650751b..c4e4b45 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -93,8 +93,7 @@ struct packet_sock {
 	/* struct sock has to be the first member of packet_sock */
 	struct sock		sk;
 	struct packet_fanout	*fanout;
-	struct tpacket_stats	stats;
-	union  tpacket_stats_u	stats_u;
+	union  tpacket_stats_u	stats;
 	struct packet_ring_buffer	rx_ring;
 	struct packet_ring_buffer	tx_ring;
 	int			copy_thresh;
-- 
1.7.11.7
