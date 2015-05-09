From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v2 4/6] packet: rollover lock contention avoidance
Date: Sat,  9 May 2015 17:24:59 -0400
Message-ID: <1431206701-5019-5-git-send-email-willemb@google.com>
References: <1431206701-5019-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	david.laight@aculab.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:35309 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752867AbbEIVZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 17:25:09 -0400
Received: by ykec202 with SMTP id c202so28579785yke.2
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 14:25:08 -0700 (PDT)
In-Reply-To: <1431206701-5019-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Rollover has to call packet_rcv_has_room on sockets in the fanout
group to find a socket to migrate to. This operation is expensive
especially if the packet sockets use rings, when a lock has to be
acquired.

Avoid pounding on the lock by all sockets by temporarily marking a
socket as "under memory pressure" when such pressure is detected.
While set, only the socket owner may call packet_rcv_has_room on the
socket. Once it detects normal conditions, it clears the flag. The
socket is not used as a victim by any other socket in the meantime.

Under reasonably balanced load, each socket writer frequently calls
packet_rcv_has_room and clears its own pressure field. As a backup
for when the socket is rarely written to, also clear the flag on
reading (packet_recvmsg, packet_poll) if this can be done cheaply
(i.e., without calling packet_rcv_has_room). This is only for
edge cases.

Tested:
  Ran bench_rollover: a process with 8 sockets in a single fanout
  group, each pinned to a single cpu that receives one nic recv
  interrupt. RPS and RFS are disabled. The benchmark uses packet
  rx_ring, which has to take a lock when determining whether a
  socket has room.

  Sent 3.5 Mpps of UDP traffic with sufficient entropy to spread
  uniformly across the packet sockets (and inserted an iptables
  rule to drop in PREROUTING to avoid protocol stack processing).

  Without this patch, all sockets try to migrate traffic to
  neighbors, causing lock contention when searching for a non-
  empty neighbor. The lock is the top 9 entries.

    perf record -a -g sleep 5

    -  17.82%   bench_rollover  [kernel.kallsyms]    [k] _raw_spin_lock
       - _raw_spin_lock
          - 99.00% spin_lock
    	 + 81.77% packet_rcv_has_room.isra.41
    	 + 18.23% tpacket_rcv
          + 0.84% packet_rcv_has_room.isra.41
    +   5.20%      ksoftirqd/6  [kernel.kallsyms]    [k] _raw_spin_lock
    +   5.15%      ksoftirqd/1  [kernel.kallsyms]    [k] _raw_spin_lock
    +   5.14%      ksoftirqd/2  [kernel.kallsyms]    [k] _raw_spin_lock
    +   5.12%      ksoftirqd/7  [kernel.kallsyms]    [k] _raw_spin_lock
    +   5.12%      ksoftirqd/5  [kernel.kallsyms]    [k] _raw_spin_lock
    +   5.10%      ksoftirqd/4  [kernel.kallsyms]    [k] _raw_spin_lock
    +   4.66%      ksoftirqd/0  [kernel.kallsyms]    [k] _raw_spin_lock
    +   4.45%      ksoftirqd/3  [kernel.kallsyms]    [k] _raw_spin_lock
    +   1.55%   bench_rollover  [kernel.kallsyms]    [k] packet_rcv_has_room.isra.41

  On net-next with this patch, this lock contention is no longer a
  top entry. Most time is spent in the actual read function. Next up
  are other locks:

    +  15.52%  bench_rollover  bench_rollover     [.] reader
    +   4.68%         swapper  [kernel.kallsyms]  [k] memcpy_erms
    +   2.77%         swapper  [kernel.kallsyms]  [k] packet_lookup_frame.isra.51
    +   2.56%     ksoftirqd/1  [kernel.kallsyms]  [k] memcpy_erms
    +   2.16%         swapper  [kernel.kallsyms]  [k] tpacket_rcv
    +   1.93%         swapper  [kernel.kallsyms]  [k] mlx4_en_process_rx_cq

  Looking closer at the remaining _raw_spin_lock, the cost of probing
  in rollover is now comparable to the cost of taking the lock later
  in tpacket_rcv.

    -   1.51%         swapper  [kernel.kallsyms]  [k] _raw_spin_lock
       - _raw_spin_lock
          + 33.41% packet_rcv_has_room
          + 28.15% tpacket_rcv
          + 19.54% enqueue_to_backlog
          + 6.45% __free_pages_ok
          + 2.78% packet_rcv_fanout
          + 2.13% fanout_demux_rollover
          + 2.01% netif_receive_skb_internal

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 38 +++++++++++++++++++++++++++++++-------
 net/packet/internal.h  |  1 +
 2 files changed, 32 insertions(+), 7 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index fb421a8..e6b252a 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1265,14 +1265,14 @@ static bool __tpacket_v3_has_room(struct packet_sock *po, int pow_off)
 	return prb_lookup_block(po, &po->rx_ring, idx, TP_STATUS_KERNEL);
 }
 
-static int packet_rcv_has_room(struct packet_sock *po, struct sk_buff *skb)
+static int __packet_rcv_has_room(struct packet_sock *po, struct sk_buff *skb)
 {
 	struct sock *sk = &po->sk;
 	int ret = ROOM_NONE;
 
 	if (po->prot_hook.func != tpacket_rcv) {
 		int avail = sk->sk_rcvbuf - atomic_read(&sk->sk_rmem_alloc)
-					  - skb->truesize;
+					  - (skb ? skb->truesize : 0);
 		if (avail > (sk->sk_rcvbuf >> ROOM_POW_OFF))
 			return ROOM_NORMAL;
 		else if (avail > 0)
@@ -1281,7 +1281,6 @@ static int packet_rcv_has_room(struct packet_sock *po, struct sk_buff *skb)
 			return ROOM_NONE;
 	}
 
-	spin_lock(&sk->sk_receive_queue.lock);
 	if (po->tp_version == TPACKET_V3) {
 		if (__tpacket_v3_has_room(po, ROOM_POW_OFF))
 			ret = ROOM_NORMAL;
@@ -1293,7 +1292,26 @@ static int packet_rcv_has_room(struct packet_sock *po, struct sk_buff *skb)
 		else if (__tpacket_has_room(po, 0))
 			ret = ROOM_LOW;
 	}
-	spin_unlock(&sk->sk_receive_queue.lock);
+
+	return ret;
+}
+
+static int packet_rcv_has_room(struct packet_sock *po, struct sk_buff *skb)
+{
+	int ret;
+	bool has_room;
+
+	if (po->prot_hook.func == tpacket_rcv) {
+		spin_lock(&po->sk.sk_receive_queue.lock);
+		ret = __packet_rcv_has_room(po, skb);
+		spin_unlock(&po->sk.sk_receive_queue.lock);
+	} else {
+		ret = __packet_rcv_has_room(po, skb);
+	}
+
+	has_room = ret == ROOM_NORMAL;
+	if (po->pressure == has_room)
+		xchg(&po->pressure, !has_room);
 
 	return ret;
 }
@@ -1362,7 +1380,7 @@ static unsigned int fanout_demux_rollover(struct packet_fanout *f,
 					  unsigned int idx, bool try_self,
 					  unsigned int num)
 {
-	struct packet_sock *po;
+	struct packet_sock *po, *po_next;
 	unsigned int i, j;
 
 	po = pkt_sk(f->arr[idx]);
@@ -1371,8 +1389,9 @@ static unsigned int fanout_demux_rollover(struct packet_fanout *f,
 
 	i = j = min_t(int, po->rollover->sock, num - 1);
 	do {
-		if (i != idx &&
-		    packet_rcv_has_room(pkt_sk(f->arr[i]), skb) == ROOM_NORMAL) {
+		po_next = pkt_sk(f->arr[i]);
+		if (po_next != po && !po_next->pressure &&
+		    packet_rcv_has_room(po_next, skb) == ROOM_NORMAL) {
 			if (i != j)
 				po->rollover->sock = i;
 			return i;
@@ -2997,6 +3016,9 @@ static int packet_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 	if (skb == NULL)
 		goto out;
 
+	if (pkt_sk(sk)->pressure)
+		packet_rcv_has_room(pkt_sk(sk), NULL);
+
 	if (pkt_sk(sk)->has_vnet_hdr) {
 		struct virtio_net_hdr vnet_hdr = { 0 };
 
@@ -3752,6 +3774,8 @@ static unsigned int packet_poll(struct file *file, struct socket *sock,
 			TP_STATUS_KERNEL))
 			mask |= POLLIN | POLLRDNORM;
 	}
+	if (po->pressure && __packet_rcv_has_room(po, NULL) == ROOM_NORMAL)
+		xchg(&po->pressure, 0);
 	spin_unlock_bh(&sk->sk_receive_queue.lock);
 	spin_lock_bh(&sk->sk_write_queue.lock);
 	if (po->tx_ring.pg_vec) {
diff --git a/net/packet/internal.h b/net/packet/internal.h
index a9d33a2..22d7d77 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -105,6 +105,7 @@ struct packet_sock {
 				auxdata:1,
 				origdev:1,
 				has_vnet_hdr:1;
+	int			pressure;
 	int			ifindex;	/* bound device		*/
 	__be16			num;
 	struct packet_rollover	*rollover;
-- 
2.2.0.rc0.207.ga3a616c
