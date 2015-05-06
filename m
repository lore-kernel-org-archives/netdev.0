From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next 5/7] packet: rollover only to socket with headroom
Date: Wed,  6 May 2015 14:27:15 -0400
Message-ID: <1430936837-22655-6-git-send-email-willemb@google.com>
References: <1430936837-22655-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:34754 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbbEFS10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 14:27:26 -0400
Received: by ykft189 with SMTP id t189so4939125ykf.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 11:27:25 -0700 (PDT)
In-Reply-To: <1430936837-22655-1-git-send-email-willemb@google.com>
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

      lpbb5:/export/hda3/willemb# ./bench_rollover -l 1000 -s -r
      Press [Enter] to exit

      cpu         rx       rx.k     drop.k   rollover     r.huge   r.failed
        0    1563828    1563828          0    8674715          0          0
        1    1212590    1212590          0          0          0          0
        2    1236807    1236808          0          0          0          0
        3    1246906    1246906          0          0          0          0
        4    1236603    1236603          0          0          0          0
        5    1238808    1238808          0          0          0          0
        6    1250217    1250217          0          0          0          0
        7    1252906    1252906          0          0          0          0

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 68 +++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 54 insertions(+), 14 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index fdb5261..d0c4c95 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1234,31 +1234,71 @@ static void packet_free_pending(struct packet_sock *po)
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
+	int ret = ROOM_NONE;
 	bool has_room;
 
 	if (po->prot_hook.func != tpacket_rcv) {
-		has_room = (atomic_read(&sk->sk_rmem_alloc) + skb->truesize)
-			   <= sk->sk_rcvbuf;
+		int avail = sk->sk_rcvbuf - atomic_read(&sk->sk_rmem_alloc)
+					  - skb->truesize;
+		if (avail > (sk->sk_rcvbuf >> ROOM_POW_OFF))
+			ret = ROOM_NORMAL;
+		else if (avail > 0)
+			ret = ROOM_LOW;
 	} else {
 		spin_lock(&sk->sk_receive_queue.lock);
-		if (po->tp_version == TPACKET_V3)
-			has_room = prb_lookup_block(po, &po->rx_ring,
-						    po->rx_ring.prb_bdqc.kactive_blk_num,
-						    TP_STATUS_KERNEL);
-		else
-			has_room = packet_lookup_frame(po, &po->rx_ring,
-						       po->rx_ring.head,
-						       TP_STATUS_KERNEL);
+		if (po->tp_version == TPACKET_V3) {
+			if (__tpacket_v3_has_room(po, ROOM_POW_OFF))
+				ret = ROOM_NORMAL;
+			else if (__tpacket_v3_has_room(po, 0))
+				ret = ROOM_LOW;
+		} else {
+			if (__tpacket_has_room(po, ROOM_POW_OFF))
+				ret = ROOM_NORMAL;
+			else if (__tpacket_has_room(po, 0))
+				ret = ROOM_LOW;
+		}
 		spin_unlock(&sk->sk_receive_queue.lock);
 	}
 
+	has_room = ret == ROOM_NORMAL;
 	if (po->pressure == has_room)
 		xchg(&po->pressure, !has_room);
 
-	return has_room;
+	return ret;
 }
 
 static void packet_sock_destruct(struct sock *sk)
@@ -1329,14 +1369,14 @@ static unsigned int fanout_demux_rollover(struct packet_fanout *f,
 	unsigned int i, j;
 
 	po = pkt_sk(f->arr[idx]);
-	if (try_self && packet_rcv_has_room(po, skb))
+	if (try_self && packet_rcv_has_room(po, skb) != ROOM_NONE)
 		return idx;
 
 	i = j = min_t(int, po->rollover->sock, num - 1);
 	do {
 		po_next = pkt_sk(f->arr[i]);
 		if (po_next != po && !po_next->pressure &&
-		    packet_rcv_has_room(po_next, skb)) {
+		    packet_rcv_has_room(po_next, skb) == ROOM_NORMAL) {
 			if (i != j)
 				po->rollover->sock = i;
 			return i;
-- 
2.2.0.rc0.207.ga3a616c
