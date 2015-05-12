From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v3 5/6] packet: rollover huge flows before small flows
Date: Tue, 12 May 2015 11:56:49 -0400
Message-ID: <1431446210-13286-6-git-send-email-willemb@google.com>
References: <1431446210-13286-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	david.laight@aculab.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:34779 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753377AbbELP5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 11:57:00 -0400
Received: by ykft189 with SMTP id t189so4649321ykf.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 08:56:59 -0700 (PDT)
In-Reply-To: <1431446210-13286-1-git-send-email-willemb@google.com>
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
    cpu         rx       rx.k     drop.k   rollover     r.huge   r.failed
      0         14         14          0          0          0          0
      1         20         20          0          0          0          0
      2         16         16          0          0          0          0
      3    6168824    6168824          0    4867721    4867721          0
      4    4867741    4867741          0          0          0          0
      5         12         12          0          0          0          0
      6         15         15          0          0          0          0
      7         17         17          0          0          0          0

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 25 ++++++++++++++++++++++---
 net/packet/internal.h  |  2 ++
 2 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 5f5fe1a..1425600 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1341,6 +1341,20 @@ static int fanout_rr_next(struct packet_fanout *f, unsigned int num)
 	return x;
 }
 
+static bool fanout_flow_is_huge(struct packet_sock *po, struct sk_buff *skb)
+{
+	u32 rxhash;
+	int i, count = 0;
+
+	rxhash = skb_get_hash(skb);
+	for (i = 0; i < ROLLOVER_HLEN; i++)
+		if (po->rollover->history[i] == rxhash)
+			count++;
+
+	po->rollover->history[prandom_u32() % ROLLOVER_HLEN] = rxhash;
+	return count > (ROLLOVER_HLEN >> 1);
+}
+
 static unsigned int fanout_demux_hash(struct packet_fanout *f,
 				      struct sk_buff *skb,
 				      unsigned int num)
@@ -1381,11 +1395,16 @@ static unsigned int fanout_demux_rollover(struct packet_fanout *f,
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
diff --git a/net/packet/internal.h b/net/packet/internal.h
index 22d7d77..a9d30a1 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -89,6 +89,8 @@ struct packet_fanout {
 
 struct packet_rollover {
 	int			sock;
+#define ROLLOVER_HLEN	(L1_CACHE_BYTES / sizeof(u32))
+	u32			history[ROLLOVER_HLEN] ____cacheline_aligned;
 } ____cacheline_aligned_in_smp;
 
 struct packet_sock {
-- 
2.2.0.rc0.207.ga3a616c
