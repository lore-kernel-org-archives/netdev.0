From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: introduce tcp_try_coalesce
Date: Mon, 23 Apr 2012 19:11:42 +0200
Message-ID: <1335201102.5205.28.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49558 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754816Ab2DWRLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:11:47 -0400
Received: by bkcik5 with SMTP id ik5so8836015bkc.19
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2012 10:11:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

commit c8628155ece3 (tcp: reduce out_of_order memory use) took care of
coalescing tcp segments provided by legacy devices (linear skbs)

We extend this idea to fragged skbs, as their truesize can be heavy.

ixgbe for example uses 256+1024+PAGE_SIZE/2 =3D 3328 bytes per segment.

Use this coalescing strategy for receive queue too.

This contributes to reduce number of tcp collapses, at minimal cost, an=
d
reduces memory overhead and packets drops.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   79 ++++++++++++++++++++++++++++++++---------
 1 file changed, 62 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 37e1c5c..bd7aef5 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4449,6 +4449,58 @@ static inline int tcp_try_rmem_schedule(struct s=
ock *sk, unsigned int size)
 	return 0;
 }
=20
+/**
+ * tcp_try_coalesce - try to merge skb to prior one
+ * @sk: socket
+ * @to: prior buffer
+ * @from: buffer to add in queue
+ *
+ * Before queueing skb @from after @to, try to merge them
+ * to reduce overall memory use and queue lengths, if cost is small.
+ * Packets in ofo or receive queues can stay a long time.
+ * Better try to coalesce them right now to avoid future collapses.
+ * Returns > 0 value if caller should free @from instead of queueing i=
t
+ */
+static int tcp_try_coalesce(struct sock *sk,
+			    struct sk_buff *to,
+			    struct sk_buff *from)
+{
+	int len =3D from->len;
+
+	if (tcp_hdr(from)->fin)
+		return 0;
+	if (len <=3D skb_tailroom(to)) {
+		BUG_ON(skb_copy_bits(from, 0, skb_put(to, len), len));
+merge:
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRCVCOALESCE);
+		TCP_SKB_CB(to)->end_seq =3D TCP_SKB_CB(from)->end_seq;
+		TCP_SKB_CB(to)->ack_seq =3D TCP_SKB_CB(from)->ack_seq;
+		return 1;
+	}
+	if (skb_headlen(from) =3D=3D 0 &&
+	    !skb_has_frag_list(to) &&
+	    !skb_has_frag_list(from) &&
+	    (skb_shinfo(to)->nr_frags +
+	     skb_shinfo(from)->nr_frags <=3D MAX_SKB_FRAGS)) {
+		int delta =3D from->truesize - ksize(from->head) -
+			    SKB_DATA_ALIGN(sizeof(struct sk_buff));
+
+		WARN_ON_ONCE(delta < len);
+		memcpy(skb_shinfo(to)->frags + skb_shinfo(to)->nr_frags,
+		       skb_shinfo(from)->frags,
+		       skb_shinfo(from)->nr_frags * sizeof(skb_frag_t));
+		skb_shinfo(to)->nr_frags +=3D skb_shinfo(from)->nr_frags;
+		skb_shinfo(from)->nr_frags =3D 0;
+		to->truesize +=3D delta;
+		atomic_add(delta, &sk->sk_rmem_alloc);
+		sk_mem_charge(sk, delta);
+		to->len +=3D len;
+		to->data_len +=3D len;
+		goto merge;
+	}
+	return 0;
+}
+
 static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -4487,23 +4539,11 @@ static void tcp_data_queue_ofo(struct sock *sk,=
 struct sk_buff *skb)
 	end_seq =3D TCP_SKB_CB(skb)->end_seq;
=20
 	if (seq =3D=3D TCP_SKB_CB(skb1)->end_seq) {
-		/* Packets in ofo can stay in queue a long time.
-		 * Better try to coalesce them right now
-		 * to avoid future tcp_collapse_ofo_queue(),
-		 * probably the most expensive function in tcp stack.
-		 */
-		if (skb->len <=3D skb_tailroom(skb1) && !tcp_hdr(skb)->fin) {
-			NET_INC_STATS_BH(sock_net(sk),
-					 LINUX_MIB_TCPRCVCOALESCE);
-			BUG_ON(skb_copy_bits(skb, 0,
-					     skb_put(skb1, skb->len),
-					     skb->len));
-			TCP_SKB_CB(skb1)->end_seq =3D end_seq;
-			TCP_SKB_CB(skb1)->ack_seq =3D TCP_SKB_CB(skb)->ack_seq;
+		if (tcp_try_coalesce(sk, skb1, skb) <=3D 0) {
+			__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
+		} else {
 			__kfree_skb(skb);
 			skb =3D NULL;
-		} else {
-			__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
 		}
=20
 		if (!tp->rx_opt.num_sacks ||
@@ -4624,13 +4664,18 @@ static void tcp_data_queue(struct sock *sk, str=
uct sk_buff *skb)
 		}
=20
 		if (eaten <=3D 0) {
+			struct sk_buff *tail;
 queue_and_out:
 			if (eaten < 0 &&
 			    tcp_try_rmem_schedule(sk, skb->truesize))
 				goto drop;
=20
-			skb_set_owner_r(skb, sk);
-			__skb_queue_tail(&sk->sk_receive_queue, skb);
+			tail =3D skb_peek_tail(&sk->sk_receive_queue);
+			eaten =3D tail ? tcp_try_coalesce(sk, tail, skb) : -1;
+			if (eaten <=3D 0) {
+				skb_set_owner_r(skb, sk);
+				__skb_queue_tail(&sk->sk_receive_queue, skb);
+			}
 		}
 		tp->rcv_nxt =3D TCP_SKB_CB(skb)->end_seq;
 		if (skb->len)
