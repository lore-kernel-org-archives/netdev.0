From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next 4/7] packet: rollover lock contention avoidance
Date: Wed,  6 May 2015 14:27:14 -0400
Message-ID: <1430936837-22655-5-git-send-email-willemb@google.com>
References: <1430936837-22655-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:34749 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116AbbEFS1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 14:27:25 -0400
Received: by ykft189 with SMTP id t189so4939019ykf.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 11:27:24 -0700 (PDT)
In-Reply-To: <1430936837-22655-1-git-send-email-willemb@google.com>
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

    +  17.51%  bench_rollover  bench_rollover      [.] reader
    +   4.95%         swapper  [kernel.kallsyms]   [k] memcpy_erms
    +   2.37%         swapper  [kernel.kallsyms]   [k] _raw_spin_lock
    +   2.31%         swapper  [kernel.kallsyms]   [k] tpacket_rcv
    +   2.20%         swapper  [kernel.kallsyms]   [k] udp4_gro_receive
    +   1.65%         swapper  [kernel.kallsyms]   [k] mlx4_en_process_rx_cq
    +   1.39%         swapper  [kernel.kallsyms]   [k] kmem_cache_alloc

    Looking closer at the remaining _raw_spin_lock, the cost of probing
    in rollover is now comparable to the cost of taking the lock later
    in tpacket_rcv.

    -   2.37%         swapper  [kernel.kallsyms]   [k] _raw_spin_lock
       - _raw_spin_lock
          + 36.86% tpacket_rcv
          + 36.72% packet_rcv_has_room.isra.54
          + 13.17% enqueue_to_backlog
          + 3.98% __free_pages_ok
          + 1.49% packet_rcv_fanout
          + 1.37% fanout_demux_rollover
          + 1.26% netif_receive_skb_internal
          + 1.16% mlx4_en_poll_rx_cq
          + 0.85% get_next_timer_interrupt
          + 0.56% handle_irq
          + 0.53% process_backlog

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 16 ++++++++++++++--
 net/packet/internal.h  |  1 +
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 8275056..fdb5261 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1255,6 +1255,9 @@ static bool packet_rcv_has_room(struct packet_sock *po, struct sk_buff *skb)
 		spin_unlock(&sk->sk_receive_queue.lock);
 	}
 
+	if (po->pressure == has_room)
+		xchg(&po->pressure, !has_room);
+
 	return has_room;
 }
 
@@ -1322,7 +1325,7 @@ static unsigned int fanout_demux_rollover(struct packet_fanout *f,
 					  unsigned int idx, bool try_self,
 					  unsigned int num)
 {
-	struct packet_sock *po;
+	struct packet_sock *po, *po_next;
 	unsigned int i, j;
 
 	po = pkt_sk(f->arr[idx]);
@@ -1331,7 +1334,9 @@ static unsigned int fanout_demux_rollover(struct packet_fanout *f,
 
 	i = j = min_t(int, po->rollover->sock, num - 1);
 	do {
-		if (i != idx && packet_rcv_has_room(pkt_sk(f->arr[i]), skb)) {
+		po_next = pkt_sk(f->arr[i]);
+		if (po_next != po && !po_next->pressure &&
+		    packet_rcv_has_room(po_next, skb)) {
 			if (i != j)
 				po->rollover->sock = i;
 			return i;
@@ -2956,6 +2961,9 @@ static int packet_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 	if (skb == NULL)
 		goto out;
 
+	if (pkt_sk(sk)->pressure && !sk_rmem_alloc_get(sk))
+		xchg(&pkt_sk(sk)->pressure, 0);
+
 	if (pkt_sk(sk)->has_vnet_hdr) {
 		struct virtio_net_hdr vnet_hdr = { 0 };
 
@@ -3718,6 +3726,10 @@ static unsigned int packet_poll(struct file *file, struct socket *sock,
 			mask |= POLLOUT | POLLWRNORM;
 	}
 	spin_unlock_bh(&sk->sk_write_queue.lock);
+
+	if (po->pressure && !(mask & POLLIN))
+		xchg(&po->pressure, 0);
+
 	return mask;
 }
 
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
