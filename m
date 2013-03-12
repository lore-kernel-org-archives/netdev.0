From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] packet: packet fanout rollover during socket overload
Date: Tue, 12 Mar 2013 10:55:53 -0400
Message-ID: <1363100153-24433-1-git-send-email-willemb@google.com>
Cc: Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:55251 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932275Ab3CLOz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 10:55:56 -0400
Received: by mail-qa0-f74.google.com with SMTP id o13so7043qaj.1
        for <netdev@vger.kernel.org>; Tue, 12 Mar 2013 07:55:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minimize packet drop in a fanout group. If one socket is full,
roll over packets to another from the group. The intended use is
to maintain flow affinity during normal load using an rxhash or
cpu fanout policy, while dispersing unexpected traffic storms that
hit a single cpu, such as spoofed-source DoS flows. This mechanism
breaks affinity for flows arriving at saturated sockets during
those conditions.

The patch adds a fanout policy ROLLOVER that rotates between sockets,
filling each socket before moving to the next. It also adds a fanout
flag ROLLOVER. If passed along with any other fanout policy, the
primary policy is applied until the chosen socket is full. Then,
rollover selects another socket, to delay packet drop until the
entire system is saturated.

Probing sockets is not free. Selecting the last used socket, as
rollover does, is a greedy approach that maximizes chance of
success, at the cost of extreme load imbalance. In practice, with
sufficiently long queues to handle rate, sockets are drained in
parallel and load balance looks uniform in `top`.

To avoid contention, scales counters with number of sockets and
accesses them lockfree. Values are bounds checked to ensure
correctness. An alternative would be to use atomic rr_cur.

Tested using an application with 9 threads pinned to CPUs, one socket
per thread and sufficient busywork per packet operation to limits each
thread to handling 32 Kpps. When sent 500 Kpps single UDP stream
packets, a FANOUT_CPU setup processes 32 Kpps in total without this
patch, 270 Kpps with the patch. Tested with read() and with a packet
ring (V1).
---
 include/linux/if_packet.h |   2 +
 net/packet/af_packet.c    | 112 ++++++++++++++++++++++++++++++++++++----------
 2 files changed, 90 insertions(+), 24 deletions(-)

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index f379929..20a77cc 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -54,6 +54,8 @@ struct sockaddr_ll {
 #define PACKET_FANOUT_HASH		0
 #define PACKET_FANOUT_LB		1
 #define PACKET_FANOUT_CPU		2
+#define PACKET_FANOUT_ROLLOVER		3
+#define PACKET_FANOUT_FLAG_ROLLOVER	0x1000
 #define PACKET_FANOUT_FLAG_DEFRAG	0x8000
 
 struct tpacket_stats {
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 1d3115c..baeb33f 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -244,6 +244,8 @@ struct packet_ring_buffer {
 
 struct packet_sock;
 static int tpacket_snd(struct packet_sock *po, struct msghdr *msg);
+static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
+		       struct packet_type *pt, struct net_device *orig_dev);
 
 static void *packet_previous_frame(struct packet_sock *po,
 		struct packet_ring_buffer *rb,
@@ -307,10 +309,11 @@ struct packet_fanout {
 	unsigned int		num_members;
 	u16			id;
 	u8			type;
-	u8			defrag;
+	u8			flags;
 	atomic_t		rr_cur;
 	struct list_head	list;
 	struct sock		*arr[PACKET_FANOUT_MAX];
+	int			next[PACKET_FANOUT_MAX];
 	spinlock_t		lock;
 	atomic_t		sk_ref;
 	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
@@ -1093,11 +1096,11 @@ static void *packet_current_rx_frame(struct packet_sock *po,
 
 static void *prb_lookup_block(struct packet_sock *po,
 				     struct packet_ring_buffer *rb,
-				     unsigned int previous,
+				     unsigned int idx,
 				     int status)
 {
 	struct tpacket_kbdq_core *pkc  = GET_PBDQC_FROM_RB(rb);
-	struct tpacket_block_desc *pbd = GET_PBLOCK_DESC(pkc, previous);
+	struct tpacket_block_desc *pbd = GET_PBLOCK_DESC(pkc, idx);
 
 	if (status != BLOCK_STATUS(pbd))
 		return NULL;
@@ -1161,6 +1164,29 @@ static void packet_increment_head(struct packet_ring_buffer *buff)
 	buff->head = buff->head != buff->frame_max ? buff->head+1 : 0;
 }
 
+static bool packet_rcv_has_room(struct packet_sock *po, struct sk_buff *skb)
+{
+	struct sock *sk = &po->sk;
+	bool has_room;
+
+	if (po->prot_hook.func != tpacket_rcv)
+		return (atomic_read(&sk->sk_rmem_alloc) + skb->truesize)
+		       <= sk->sk_rcvbuf;
+
+	spin_lock(&sk->sk_receive_queue.lock);
+	if (po->tp_version == TPACKET_V3)
+		has_room = prb_lookup_block(po, &po->rx_ring,
+					po->rx_ring.prb_bdqc.kactive_blk_num,
+					TP_STATUS_KERNEL);
+	else
+		has_room = packet_lookup_frame(po, &po->rx_ring,
+					       po->rx_ring.head,
+					       TP_STATUS_KERNEL);
+	spin_unlock(&sk->sk_receive_queue.lock);
+
+	return has_room;
+}
+
 static void packet_sock_destruct(struct sock *sk)
 {
 	skb_queue_purge(&sk->sk_error_queue);
@@ -1186,16 +1212,16 @@ static int fanout_rr_next(struct packet_fanout *f, unsigned int num)
 	return x;
 }
 
-static struct sock *fanout_demux_hash(struct packet_fanout *f, struct sk_buff *skb, unsigned int num)
+static unsigned int fanout_demux_hash(struct packet_fanout *f,
+				      struct sk_buff *skb,
+				      unsigned int num)
 {
-	u32 idx, hash = skb->rxhash;
-
-	idx = ((u64)hash * num) >> 32;
-
-	return f->arr[idx];
+	return (((u64)skb->rxhash) * num) >> 32;
 }
 
-static struct sock *fanout_demux_lb(struct packet_fanout *f, struct sk_buff *skb, unsigned int num)
+static unsigned int fanout_demux_lb(struct packet_fanout *f,
+				    struct sk_buff *skb,
+				    unsigned int num)
 {
 	int cur, old;
 
@@ -1203,14 +1229,40 @@ static struct sock *fanout_demux_lb(struct packet_fanout *f, struct sk_buff *skb
 	while ((old = atomic_cmpxchg(&f->rr_cur, cur,
 				     fanout_rr_next(f, num))) != cur)
 		cur = old;
-	return f->arr[cur];
+	return cur;
+}
+
+static unsigned int fanout_demux_cpu(struct packet_fanout *f,
+				     struct sk_buff *skb,
+				     unsigned int num)
+{
+	return smp_processor_id() % num;
 }
 
-static struct sock *fanout_demux_cpu(struct packet_fanout *f, struct sk_buff *skb, unsigned int num)
+static unsigned int fanout_demux_rollover(struct packet_fanout *f,
+					  struct sk_buff *skb,
+					  unsigned int idx, unsigned int skip,
+					  unsigned int num)
 {
-	unsigned int cpu = smp_processor_id();
+	unsigned int i, j;
 
-	return f->arr[cpu % num];
+	i = j = min(f->next[idx], (int) f->num_members - 1);
+	do {
+		if (i != skip && packet_rcv_has_room(pkt_sk(f->arr[i]), skb)) {
+			if (i != j)
+				f->next[idx] = i;
+			return i;
+		}
+		if (++i >= f->num_members)
+			i = 0;
+	} while (i != j && idx < f->num_members);
+
+	return idx;
+}
+
+static bool fanout_has_flag(struct packet_fanout *f, u16 flag)
+{
+	return f->flags & (flag >> 8);
 }
 
 static int packet_rcv_fanout(struct sk_buff *skb, struct net_device *dev,
@@ -1219,7 +1271,7 @@ static int packet_rcv_fanout(struct sk_buff *skb, struct net_device *dev,
 	struct packet_fanout *f = pt->af_packet_priv;
 	unsigned int num = f->num_members;
 	struct packet_sock *po;
-	struct sock *sk;
+	unsigned int idx;
 
 	if (!net_eq(dev_net(dev), read_pnet(&f->net)) ||
 	    !num) {
@@ -1230,23 +1282,31 @@ static int packet_rcv_fanout(struct sk_buff *skb, struct net_device *dev,
 	switch (f->type) {
 	case PACKET_FANOUT_HASH:
 	default:
-		if (f->defrag) {
+		if (fanout_has_flag(f, PACKET_FANOUT_FLAG_DEFRAG)) {
 			skb = ip_check_defrag(skb, IP_DEFRAG_AF_PACKET);
 			if (!skb)
 				return 0;
 		}
 		skb_get_rxhash(skb);
-		sk = fanout_demux_hash(f, skb, num);
+		idx = fanout_demux_hash(f, skb, num);
 		break;
 	case PACKET_FANOUT_LB:
-		sk = fanout_demux_lb(f, skb, num);
+		idx = fanout_demux_lb(f, skb, num);
 		break;
 	case PACKET_FANOUT_CPU:
-		sk = fanout_demux_cpu(f, skb, num);
+		idx = fanout_demux_cpu(f, skb, num);
+		break;
+	case PACKET_FANOUT_ROLLOVER:
+		idx = fanout_demux_rollover(f, skb, 0, (unsigned int) -1, num);
 		break;
 	}
 
-	po = pkt_sk(sk);
+	po = pkt_sk(f->arr[idx]);
+	if (fanout_has_flag(f, PACKET_FANOUT_FLAG_ROLLOVER) &&
+	    unlikely(!packet_rcv_has_room(po, skb))) {
+		idx = fanout_demux_rollover(f, skb, idx, idx, num);
+		po = pkt_sk(f->arr[idx]);
+	}
 
 	return po->prot_hook.func(skb, dev, &po->prot_hook, orig_dev);
 }
@@ -1286,10 +1346,13 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 	struct packet_sock *po = pkt_sk(sk);
 	struct packet_fanout *f, *match;
 	u8 type = type_flags & 0xff;
-	u8 defrag = (type_flags & PACKET_FANOUT_FLAG_DEFRAG) ? 1 : 0;
+	u8 flags = type_flags >> 8;
 	int err;
 
 	switch (type) {
+	case PACKET_FANOUT_ROLLOVER:
+		if (flags & PACKET_FANOUT_FLAG_ROLLOVER)
+			return -EINVAL;
 	case PACKET_FANOUT_HASH:
 	case PACKET_FANOUT_LB:
 	case PACKET_FANOUT_CPU:
@@ -1314,7 +1377,7 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 		}
 	}
 	err = -EINVAL;
-	if (match && match->defrag != defrag)
+	if (match && match->flags != flags)
 		goto out;
 	if (!match) {
 		err = -ENOMEM;
@@ -1324,7 +1387,7 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 		write_pnet(&match->net, sock_net(sk));
 		match->id = id;
 		match->type = type;
-		match->defrag = defrag;
+		match->flags = flags;
 		atomic_set(&match->rr_cur, 0);
 		INIT_LIST_HEAD(&match->list);
 		spin_lock_init(&match->lock);
@@ -3311,7 +3374,8 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 			len = sizeof(int);
 		val = (po->fanout ?
 		       ((u32)po->fanout->id |
-			((u32)po->fanout->type << 16)) :
+			((u32)po->fanout->type << 16) |
+			((u32)po->fanout->flags << 24)) :
 		       0);
 		data = &val;
 		break;
-- 
1.8.1.3
