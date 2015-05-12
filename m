From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v3 6/6] packet: rollover statistics
Date: Tue, 12 May 2015 11:56:50 -0400
Message-ID: <1431446210-13286-7-git-send-email-willemb@google.com>
References: <1431446210-13286-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	david.laight@aculab.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:34786 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078AbbELP5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 11:57:01 -0400
Received: by ykft189 with SMTP id t189so4649463ykf.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 08:57:00 -0700 (PDT)
In-Reply-To: <1431446210-13286-1-git-send-email-willemb@google.com>
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
 net/packet/af_packet.c         | 19 ++++++++++++++++++-
 net/packet/internal.h          |  3 +++
 3 files changed, 28 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
index 053bd10..d3d715f8c 100644
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
+	__aligned_u64	tp_all;
+	__aligned_u64	tp_huge;
+	__aligned_u64	tp_failed;
+};
+
 union tpacket_stats_u {
 	struct tpacket_stats stats1;
 	struct tpacket_stats_v3 stats3;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 1425600..67dfdab 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1395,7 +1395,7 @@ static unsigned int fanout_demux_rollover(struct packet_fanout *f,
 					  unsigned int num)
 {
 	struct packet_sock *po, *po_next;
-	unsigned int i, j, room;
+	unsigned int i, j, room = ROOM_NONE;
 
 	po = pkt_sk(f->arr[idx]);
 
@@ -1413,6 +1413,9 @@ static unsigned int fanout_demux_rollover(struct packet_fanout *f,
 		    packet_rcv_has_room(po_next, skb) == ROOM_NORMAL) {
 			if (i != j)
 				po->rollover->sock = i;
+			atomic_long_inc(&po->rollover->num);
+			if (room == ROOM_LOW)
+				atomic_long_inc(&po->rollover->num_huge);
 			return i;
 		}
 
@@ -1420,6 +1423,7 @@ static unsigned int fanout_demux_rollover(struct packet_fanout *f,
 			i = 0;
 	} while (i != j);
 
+	atomic_long_inc(&po->rollover->num_failed);
 	return idx;
 }
 
@@ -1554,6 +1558,9 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 		po->rollover = kzalloc(sizeof(*po->rollover), GFP_KERNEL);
 		if (!po->rollover)
 			return -ENOMEM;
+		atomic_long_set(&po->rollover->num, 0);
+		atomic_long_set(&po->rollover->num_huge, 0);
+		atomic_long_set(&po->rollover->num_failed, 0);
 	}
 
 	mutex_lock(&fanout_mutex);
@@ -3581,6 +3588,7 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 	struct packet_sock *po = pkt_sk(sk);
 	void *data = &val;
 	union tpacket_stats_u st;
+	struct tpacket_rollover_stats rstats;
 
 	if (level != SOL_PACKET)
 		return -ENOPROTOOPT;
@@ -3656,6 +3664,15 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
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
index a9d30a1..c035d26 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -89,6 +89,9 @@ struct packet_fanout {
 
 struct packet_rollover {
 	int			sock;
+	atomic_long_t		num;
+	atomic_long_t		num_huge;
+	atomic_long_t		num_failed;
 #define ROLLOVER_HLEN	(L1_CACHE_BYTES / sizeof(u32))
 	u32			history[ROLLOVER_HLEN] ____cacheline_aligned;
 } ____cacheline_aligned_in_smp;
-- 
2.2.0.rc0.207.ga3a616c
