From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: sndbuf autotuning improvements
Date: Tue, 01 Oct 2013 10:23:44 -0700
Message-ID: <1380648224.19002.32.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:47111 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752624Ab3JARXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 13:23:47 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc17so7422633pbc.18
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 10:23:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

tcp_fixup_sndbuf() is underestimating initial send buffer requirements.

It was not noticed because big GSO packets were escaping the limitation=
,
but with smaller TSO packets (or TSO/GSO/SG off), application hits
sk_sndbuf before having a chance to fill enough packets in socket write
queue.

- initial cwnd can be bigger than 10 for specific routes

- SKB_TRUESIZE() is a bit under real needs in some cases,
  because of power-of-two rounding in kmalloc()

- Fast Recovery (RFC 5681 3.2) : Cubic needs 70% factor

- Extra cushion (application might react slowly to POLLOUT)

tcp_v4_conn_req_fastopen() needs to call tcp_init_metrics() before
calling tcp_init_buffer_space()

Then we realize tcp_new_space() should call tcp_fixup_sndbuf()
instead of duplicating this stuff.

Rename tcp_fixup_sndbuf() to tcp_sndbuf_expand() to be more
descriptive.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Acked-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 net/ipv4/tcp_input.c |   38 +++++++++++++++++++++++++-------------
 net/ipv4/tcp_ipv4.c  |    2 +-
 2 files changed, 26 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 66aa816..cd65674 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -267,11 +267,31 @@ static bool TCP_ECN_rcv_ecn_echo(const struct tcp=
_sock *tp, const struct tcphdr
  * 1. Tuning sk->sk_sndbuf, when connection enters established state.
  */
=20
-static void tcp_fixup_sndbuf(struct sock *sk)
+static void tcp_sndbuf_expand(struct sock *sk)
 {
-	int sndmem =3D SKB_TRUESIZE(tcp_sk(sk)->rx_opt.mss_clamp + MAX_TCP_HE=
ADER);
+	const struct tcp_sock *tp =3D tcp_sk(sk);
+	int sndmem, per_mss;
+	u32 nr_segs;
+
+	/* Worst case is non GSO/TSO : each frame consumes one skb
+	 * and skb->head is kmalloced using power of two area of memory
+	 */
+	per_mss =3D max_t(u32, tp->rx_opt.mss_clamp, tp->mss_cache) +
+		  MAX_TCP_HEADER +
+		  SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+
+	per_mss =3D roundup_pow_of_two(per_mss) +
+		  SKB_DATA_ALIGN(sizeof(struct sk_buff));
+
+	nr_segs =3D max_t(u32, TCP_INIT_CWND, tp->snd_cwnd);
+	nr_segs =3D max_t(u32, nr_segs, tp->reordering + 1);
+
+	/* Fast Recovery (RFC 5681 3.2) :
+	 * Cubic needs 1.7 factor, rounded to 2 to include
+	 * extra cushion (application might react slowly to POLLOUT)
+	 */
+	sndmem =3D 2 * nr_segs * per_mss;
=20
-	sndmem *=3D TCP_INIT_CWND;
 	if (sk->sk_sndbuf < sndmem)
 		sk->sk_sndbuf =3D min(sndmem, sysctl_tcp_wmem[2]);
 }
@@ -376,7 +396,7 @@ void tcp_init_buffer_space(struct sock *sk)
 	if (!(sk->sk_userlocks & SOCK_RCVBUF_LOCK))
 		tcp_fixup_rcvbuf(sk);
 	if (!(sk->sk_userlocks & SOCK_SNDBUF_LOCK))
-		tcp_fixup_sndbuf(sk);
+		tcp_sndbuf_expand(sk);
=20
 	tp->rcvq_space.space =3D tp->rcv_wnd;
 	tp->rcvq_space.time =3D tcp_time_stamp;
@@ -4723,15 +4743,7 @@ static void tcp_new_space(struct sock *sk)
 	struct tcp_sock *tp =3D tcp_sk(sk);
=20
 	if (tcp_should_expand_sndbuf(sk)) {
-		int sndmem =3D SKB_TRUESIZE(max_t(u32,
-						tp->rx_opt.mss_clamp,
-						tp->mss_cache) +
-					  MAX_TCP_HEADER);
-		int demanded =3D max_t(unsigned int, tp->snd_cwnd,
-				     tp->reordering + 1);
-		sndmem *=3D 2 * demanded;
-		if (sndmem > sk->sk_sndbuf)
-			sk->sk_sndbuf =3D min(sndmem, sysctl_tcp_wmem[2]);
+		tcp_sndbuf_expand(sk);
 		tp->snd_cwnd_stamp =3D tcp_time_stamp;
 	}
=20
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b14266b..5d6b1a6 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1410,8 +1410,8 @@ static int tcp_v4_conn_req_fastopen(struct sock *=
sk,
 	inet_csk(child)->icsk_af_ops->rebuild_header(child);
 	tcp_init_congestion_control(child);
 	tcp_mtup_init(child);
-	tcp_init_buffer_space(child);
 	tcp_init_metrics(child);
+	tcp_init_buffer_space(child);
=20
 	/* Queue the data carried in the SYN packet. We need to first
 	 * bump skb's refcnt because the caller will attempt to free it.
