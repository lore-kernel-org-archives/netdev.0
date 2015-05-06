From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next 7/7] packet: rollover statistics
Date: Wed,  6 May 2015 14:27:17 -0400
Message-ID: <1430936837-22655-8-git-send-email-willemb@google.com>
References: <1430936837-22655-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f49.google.com ([209.85.213.49]:35660 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752741AbbEFS12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 14:27:28 -0400
Received: by yhda23 with SMTP id a23so4711871yhd.2
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 11:27:27 -0700 (PDT)
In-Reply-To: <1430936837-22655-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Rollover indicates exceptional conditions. Export a counter to inform
socket owners of this state.

If no socket with sufficient room is found, rollover fails. Also count
these events.

Finally, also count when flows are rolled over early thanks to huge
flow detection, to validate its correctness.

Tested:
  Read counters in bench_rollover on all other tests in the patchset

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/uapi/linux/if_packet.h |  7 +++++++
 net/packet/af_packet.c         | 17 +++++++++++++++++
 net/packet/internal.h          |  3 +++
 3 files changed, 27 insertions(+)

diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
index 053bd10..52b6501 100644
--- a/include/uapi/linux/if_packet.h
+++ b/include/uapi/linux/if_packet.h
@@ -54,6 +54,7 @@ struct sockaddr_ll {
 #define PACKET_FANOUT			18
 #define PACKET_TX_HAS_OFF		19
 #define PACKET_QDISC_BYPASS		20
+#define PACKET_ROLLOVER_STATS		21
 
 #define PACKET_FANOUT_HASH		0
 #define PACKET_FANOUT_LB		1
@@ -75,6 +76,12 @@ struct tpacket_stats_v3 {
 	unsigned int	tp_freeze_q_cnt;
 };
 
+struct tpacket_rollover_stats {
+	unsigned long	tp_all;
+	unsigned long	tp_huge;
+	unsigned long	tp_failed;
+};
+
 union tpacket_stats_u {
 	struct tpacket_stats stats1;
 	struct tpacket_stats_v3 stats3;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 4e54b6b..9a82196 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1402,6 +1402,9 @@ static unsigned int fanout_demux_rollover(struct packet_fanout *f,
 		    packet_rcv_has_room(po_next, skb) == ROOM_NORMAL) {
 			if (i != j)
 				po->rollover->sock = i;
+			atomic_long_inc(&po->rollover->num);
+			if (room == ROOM_LOW)
+				atomic_long_inc(&po->rollover->num_huge);
 			return i;
 		}
 
@@ -1409,6 +1412,7 @@ static unsigned int fanout_demux_rollover(struct packet_fanout *f,
 			i = 0;
 	} while (i != j);
 
+	atomic_long_inc(&po->rollover->num_failed);
 	return idx;
 }
 
@@ -1544,6 +1548,9 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 		if (!po->rollover)
 			return -ENOMEM;
 		spin_lock_init(&po->rollover->hist_lock);
+		atomic_long_set(&po->rollover->num, 0);
+		atomic_long_set(&po->rollover->num_huge, 0);
+		atomic_long_set(&po->rollover->num_failed, 0);
 	}
 
 	mutex_lock(&fanout_mutex);
@@ -3571,6 +3578,7 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 	struct packet_sock *po = pkt_sk(sk);
 	void *data = &val;
 	union tpacket_stats_u st;
+	struct tpacket_rollover_stats rstats;
 
 	if (level != SOL_PACKET)
 		return -ENOPROTOOPT;
@@ -3646,6 +3654,15 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 			((u32)po->fanout->flags << 24)) :
 		       0);
 		break;
+	case PACKET_ROLLOVER_STATS:
+		if (!po->rollover)
+			return -EINVAL;
+		rstats.tp_all = atomic_long_read(&po->rollover->num);
+		rstats.tp_huge = atomic_long_read(&po->rollover->num_huge);
+		rstats.tp_failed = atomic_long_read(&po->rollover->num_failed);
+		data = &rstats;
+		lv = sizeof(rstats);
+		break;
 	case PACKET_TX_HAS_OFF:
 		val = po->tp_tx_has_off;
 		break;
diff --git a/net/packet/internal.h b/net/packet/internal.h
index 6f479c4..5d51b7b 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -89,6 +89,9 @@ struct packet_fanout {
 
 struct packet_rollover {
 	int			sock;
+	atomic_long_t		num;
+	atomic_long_t		num_huge;
+	atomic_long_t		num_failed;
 	int			hist_idx;
 #define ROLLOVER_HLEN	(L1_CACHE_BYTES / sizeof(u32))
 	u32			history[ROLLOVER_HLEN] ____cacheline_aligned;
-- 
2.2.0.rc0.207.ga3a616c
