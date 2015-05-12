From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v3 3/6] packet: rollover only to socket with headroom
Date: Tue, 12 May 2015 11:56:47 -0400
Message-ID: <1431446210-13286-4-git-send-email-willemb@google.com>
References: <1431446210-13286-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	david.laight@aculab.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f41.google.com ([209.85.213.41]:33513 "EHLO
	mail-yh0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753175AbbELP46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 11:56:58 -0400
Received: by yhcb70 with SMTP id b70so4382423yhc.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 08:56:57 -0700 (PDT)
In-Reply-To: <1431446210-13286-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Only migrate flows to sockets that have sufficient headroom, where
sufficient is defined as having at least 25% empty space.

The kernel has three different buffer types: a regular socket, a ring
with frames (TPACKET_V[12]) or a ring with blocks (TPACKET_V3). The
latter two do not expose a read pointer to the kernel, so headroom is
not computed easily. All three needs a different implementation to
estimate free space.

Tested:
  Ran bench_rollover for 10 sec with 1.5 Mpps of single flow input.

  bench_rollover has as many sockets as there are NIC receive queues
  in the system. Each socket is owned by a process that is pinned to
  one of the receive cpus. RFS is disabled. RPS is enabled with an
  identity mapping (cpu x -> cpu x), to count drops with softnettop.

    lpbb5:/export/hda3/willemb# ./bench_rollover -r -l 1000 -s
    Press [Enter] to exit

    cpu         rx       rx.k     drop.k   rollover     r.huge   r.failed
      0         16         16          0          0          0          0
      1         21         21          0          0          0          0
      2    5227502    5227502          0          0          0          0
      3         18         18          0          0          0          0
      4    6083289    6083289          0    5227496          0          0
      5         22         22          0          0          0          0
      6         21         21          0          0          0          0
      7          9          9          0          0          0          0

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 74 +++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 58 insertions(+), 16 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 6f1b939..7c046d7 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1234,27 +1234,68 @@ static void packet_free_pending(struct packet_sock *po)
 	free_percpu(po->tx_ring.pending_refcnt);
 }
 
-static bool packet_rcv_has_room(struct packet_sock *po, struct sk_buff *skb)
+#define ROOM_POW_OFF	2
+#define ROOM_NONE	0x0
+#define ROOM_LOW	0x1
+#define ROOM_NORMAL	0x2
+
+static bool __tpacket_has_room(struct packet_sock *po, int pow_off)
+{
+	int idx, len;
+
+	len = po->rx_ring.frame_max + 1;
+	idx = po->rx_ring.head;
+	if (pow_off)
+		idx += len >> pow_off;
+	if (idx >= len)
+		idx -= len;
+	return packet_lookup_frame(po, &po->rx_ring, idx, TP_STATUS_KERNEL);
+}
+
+static bool __tpacket_v3_has_room(struct packet_sock *po, int pow_off)
+{
+	int idx, len;
+
+	len = po->rx_ring.prb_bdqc.knum_blocks;
+	idx = po->rx_ring.prb_bdqc.kactive_blk_num;
+	if (pow_off)
+		idx += len >> pow_off;
+	if (idx >= len)
+		idx -= len;
+	return prb_lookup_block(po, &po->rx_ring, idx, TP_STATUS_KERNEL);
+}
+
+static int packet_rcv_has_room(struct packet_sock *po, struct sk_buff *skb)
 {
 	struct sock *sk = &po->sk;
-	bool has_room;
+	int ret = ROOM_NONE;
 
-	if (po->prot_hook.func != tpacket_rcv)
-		return (atomic_read(&sk->sk_rmem_alloc) + skb->truesize)
-			<= sk->sk_rcvbuf;
+	if (po->prot_hook.func != tpacket_rcv) {
+		int avail = sk->sk_rcvbuf - atomic_read(&sk->sk_rmem_alloc)
+					  - skb->truesize;
+		if (avail > (sk->sk_rcvbuf >> ROOM_POW_OFF))
+			return ROOM_NORMAL;
+		else if (avail > 0)
+			return ROOM_LOW;
+		else
+			return ROOM_NONE;
+	}
 
 	spin_lock(&sk->sk_receive_queue.lock);
-	if (po->tp_version == TPACKET_V3)
-		has_room = prb_lookup_block(po, &po->rx_ring,
-					    po->rx_ring.prb_bdqc.kactive_blk_num,
-					    TP_STATUS_KERNEL);
-	else
-		has_room = packet_lookup_frame(po, &po->rx_ring,
-					       po->rx_ring.head,
-					       TP_STATUS_KERNEL);
+	if (po->tp_version == TPACKET_V3) {
+		if (__tpacket_v3_has_room(po, ROOM_POW_OFF))
+			ret = ROOM_NORMAL;
+		else if (__tpacket_v3_has_room(po, 0))
+			ret = ROOM_LOW;
+	} else {
+		if (__tpacket_has_room(po, ROOM_POW_OFF))
+			ret = ROOM_NORMAL;
+		else if (__tpacket_has_room(po, 0))
+			ret = ROOM_LOW;
+	}
 	spin_unlock(&sk->sk_receive_queue.lock);
 
-	return has_room;
+	return ret;
 }
 
 static void packet_sock_destruct(struct sock *sk)
@@ -1325,12 +1366,13 @@ static unsigned int fanout_demux_rollover(struct packet_fanout *f,
 	unsigned int i, j;
 
 	po = pkt_sk(f->arr[idx]);
-	if (try_self && packet_rcv_has_room(po, skb))
+	if (try_self && packet_rcv_has_room(po, skb) != ROOM_NONE)
 		return idx;
 
 	i = j = min_t(int, po->rollover->sock, num - 1);
 	do {
-		if (i != idx && packet_rcv_has_room(pkt_sk(f->arr[i]), skb)) {
+		if (i != idx &&
+		    packet_rcv_has_room(pkt_sk(f->arr[i]), skb) == ROOM_NORMAL) {
 			if (i != j)
 				po->rollover->sock = i;
 			return i;
-- 
2.2.0.rc0.207.ga3a616c
