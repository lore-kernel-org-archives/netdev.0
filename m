From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next 6/7] packet: rollover huge flows before small flows
Date: Wed,  6 May 2015 14:27:16 -0400
Message-ID: <1430936837-22655-7-git-send-email-willemb@google.com>
References: <1430936837-22655-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f45.google.com ([209.85.213.45]:35654 "EHLO
	mail-yh0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbbEFS11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 14:27:27 -0400
Received: by yhda23 with SMTP id a23so4711750yhd.2
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 11:27:26 -0700 (PDT)
In-Reply-To: <1430936837-22655-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Migrate flows from a socket to another socket in the fanout group not
only when the socket is full. Start migrating huge flows early, to
divert possible 4-tuple attacks without affecting normal traffic.

Introduce fanout_flow_is_huge(). This detects huge flows, which are
defined as taking up more than half the load. It does so cheaply, by
storing the rxhashes of the N most recent packets. If over half of
these are the same rxhash as the current packet, then drop it. This
only protects against 4-tuple attacks. N is chosen to fit all data in
a single cache line.

Tested:
  Ran bench_rollover for 10 sec with 1.5 Mpps of single flow input.

      lpbb5:/export/hda3/willemb# ./bench_rollover -l 1000 -r -s
      cpu        rx       rx.k     drop.k   rollover     r.huge   r.failed
       0    1202599    1202599          0          0          0          0
       1    1221096    1221096          0          0          0          0
       2    1202296    1202296          0          0          0          0
       3    1229998    1229998          0          0          0          0
       4    1229551    1229551          0          0          0          0
       5    1221097    1221097          0          0          0          0
       6    1223496    1223496          0          0          0          0
       7    1616768    1616768          0    8530027    8530027          0

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 30 +++++++++++++++++++++++++++---
 net/packet/internal.h  |  4 ++++
 2 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index d0c4c95..4e54b6b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1326,6 +1326,24 @@ static int fanout_rr_next(struct packet_fanout *f, unsigned int num)
 	return x;
 }
 
+static bool fanout_flow_is_huge(struct packet_sock *po, struct sk_buff *skb)
+{
+	u32 rxhash;
+	int i, count = 0;
+
+	rxhash = skb_get_hash(skb);
+	spin_lock(&po->rollover->hist_lock);
+	for (i = 0; i < ROLLOVER_HLEN; i++)
+		if (po->rollover->history[i] == rxhash)
+			count++;
+
+	i = po->rollover->hist_idx++ & (ROLLOVER_HLEN - 1);
+	po->rollover->history[i] = rxhash;
+	spin_unlock(&po->rollover->hist_lock);
+
+	return count > (ROLLOVER_HLEN >> 1);
+}
+
 static unsigned int fanout_demux_hash(struct packet_fanout *f,
 				      struct sk_buff *skb,
 				      unsigned int num)
@@ -1366,11 +1384,16 @@ static unsigned int fanout_demux_rollover(struct packet_fanout *f,
 					  unsigned int num)
 {
 	struct packet_sock *po, *po_next;
-	unsigned int i, j;
+	unsigned int i, j, room;
 
 	po = pkt_sk(f->arr[idx]);
-	if (try_self && packet_rcv_has_room(po, skb) != ROOM_NONE)
-		return idx;
+
+	if (try_self) {
+		room = packet_rcv_has_room(po, skb);
+		if (room == ROOM_NORMAL ||
+		    (room == ROOM_LOW && !fanout_flow_is_huge(po, skb)))
+			return idx;
+	}
 
 	i = j = min_t(int, po->rollover->sock, num - 1);
 	do {
@@ -1520,6 +1543,7 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 		po->rollover = kzalloc(sizeof(*po->rollover), GFP_KERNEL);
 		if (!po->rollover)
 			return -ENOMEM;
+		spin_lock_init(&po->rollover->hist_lock);
 	}
 
 	mutex_lock(&fanout_mutex);
diff --git a/net/packet/internal.h b/net/packet/internal.h
index 22d7d77..6f479c4 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -89,6 +89,10 @@ struct packet_fanout {
 
 struct packet_rollover {
 	int			sock;
+	int			hist_idx;
+#define ROLLOVER_HLEN	(L1_CACHE_BYTES / sizeof(u32))
+	u32			history[ROLLOVER_HLEN] ____cacheline_aligned;
+	spinlock_t		hist_lock;
 } ____cacheline_aligned_in_smp;
 
 struct packet_sock {
-- 
2.2.0.rc0.207.ga3a616c
