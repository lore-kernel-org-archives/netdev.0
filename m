From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 4/9] [TCP]: Introduce tcp_wnd_end() to reduce line lengths
Date: Mon, 31 Dec 2007 12:47:52 +0200
Message-ID: <11990980772309-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11990980772344-git-send-email-ilpo.jarvinen@helsinki.fi> <1199098077874-git-send-email-ilpo.jarvinen@helsinki.fi> <11990980773391-git-send-email-ilpo.jarvinen@helsinki.fi> <11990980771495-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45709 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755893AbXLaKsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 05:48:01 -0500
In-Reply-To: <11990980771495-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |    6 ++++++
 net/ipv4/tcp_input.c  |    3 +--
 net/ipv4/tcp_output.c |   20 ++++++++++----------
 3 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 76286e8..6a732d4 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -785,6 +785,12 @@ static __inline__ __u32 tcp_max_burst(const struct=
 tcp_sock *tp)
 	return 3;
 }
=20
+/* Returns end sequence number of the receiver's advertised window */
+static inline u32 tcp_wnd_end(const struct tcp_sock *tp)
+{
+	return tp->snd_una + tp->snd_wnd;
+}
+
 /* RFC2861 Check whether we are limited by application or congestion w=
indow
  * This is the inverse of cwnd check in tcp_tso_should_defer
  */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 41f4b86..366f63a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2921,8 +2921,7 @@ static void tcp_ack_probe(struct sock *sk)
=20
 	/* Was it a usable window open? */
=20
-	if (!after(TCP_SKB_CB(tcp_send_head(sk))->end_seq,
-		   tp->snd_una + tp->snd_wnd)) {
+	if (!after(TCP_SKB_CB(tcp_send_head(sk))->end_seq, tcp_wnd_end(tp))) =
{
 		icsk->icsk_backoff =3D 0;
 		inet_csk_clear_xmit_timer(sk, ICSK_TIME_PROBE0);
 		/* Socket must be waked up by subsequent tcp_data_snd_check().
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 025dddf..202d60c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -89,10 +89,10 @@ static inline __u32 tcp_acceptable_seq(struct sock =
*sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
=20
-	if (!before(tp->snd_una+tp->snd_wnd, tp->snd_nxt))
+	if (!before(tcp_wnd_end(tp), tp->snd_nxt))
 		return tp->snd_nxt;
 	else
-		return tp->snd_una+tp->snd_wnd;
+		return tcp_wnd_end(tp);
 }
=20
 /* Calculate mss to advertise in SYN segment.
@@ -1023,7 +1023,7 @@ static unsigned int tcp_mss_split_point(struct so=
ck *sk, struct sk_buff *skb,
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	u32 needed, window, cwnd_len;
=20
-	window =3D (tp->snd_una + tp->snd_wnd - TCP_SKB_CB(skb)->seq);
+	window =3D tcp_wnd_end(tp) - TCP_SKB_CB(skb)->seq;
 	cwnd_len =3D mss_now * cwnd;
=20
 	if (likely(cwnd_len <=3D window && skb !=3D tcp_write_queue_tail(sk))=
)
@@ -1129,7 +1129,7 @@ static inline int tcp_snd_wnd_test(struct tcp_soc=
k *tp, struct sk_buff *skb, uns
 	if (skb->len > cur_mss)
 		end_seq =3D TCP_SKB_CB(skb)->seq + cur_mss;
=20
-	return !after(end_seq, tp->snd_una + tp->snd_wnd);
+	return !after(end_seq, tcp_wnd_end(tp));
 }
=20
 /* This checks if the data bearing packet SKB (usually tcp_send_head(s=
k))
@@ -1246,7 +1246,7 @@ static int tcp_tso_should_defer(struct sock *sk, =
struct sk_buff *skb)
 	BUG_ON(tcp_skb_pcount(skb) <=3D 1 ||
 	       (tp->snd_cwnd <=3D in_flight));
=20
-	send_win =3D (tp->snd_una + tp->snd_wnd) - TCP_SKB_CB(skb)->seq;
+	send_win =3D tcp_wnd_end(tp) - TCP_SKB_CB(skb)->seq;
=20
 	/* From in_flight test above, we know that cwnd > in_flight.  */
 	cong_win =3D (tp->snd_cwnd - in_flight) * tp->mss_cache;
@@ -1327,7 +1327,7 @@ static int tcp_mtu_probe(struct sock *sk)
=20
 	if (tp->snd_wnd < size_needed)
 		return -1;
-	if (after(tp->snd_nxt + size_needed, tp->snd_una + tp->snd_wnd))
+	if (after(tp->snd_nxt + size_needed, tcp_wnd_end(tp)))
 		return 0;
=20
 	/* Do we need to wait to drain cwnd? With none in flight, don't stall=
 */
@@ -1682,7 +1682,7 @@ static void tcp_retrans_try_collapse(struct sock =
*sk, struct sk_buff *skb, int m
 			return;
=20
 		/* Next skb is out of window. */
-		if (after(TCP_SKB_CB(next_skb)->end_seq, tp->snd_una+tp->snd_wnd))
+		if (after(TCP_SKB_CB(next_skb)->end_seq, tcp_wnd_end(tp)))
 			return;
=20
 		/* Punt if not enough space exists in the first SKB for
@@ -1826,7 +1826,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk=
_buff *skb)
 	 * case, when window is shrunk to zero. In this case
 	 * our retransmit serves as a zero window probe.
 	 */
-	if (!before(TCP_SKB_CB(skb)->seq, tp->snd_una+tp->snd_wnd)
+	if (!before(TCP_SKB_CB(skb)->seq, tcp_wnd_end(tp))
 	    && TCP_SKB_CB(skb)->seq !=3D tp->snd_una)
 		return -EAGAIN;
=20
@@ -2492,10 +2492,10 @@ int tcp_write_wakeup(struct sock *sk)
 		struct sk_buff *skb;
=20
 		if ((skb =3D tcp_send_head(sk)) !=3D NULL &&
-		    before(TCP_SKB_CB(skb)->seq, tp->snd_una+tp->snd_wnd)) {
+		    before(TCP_SKB_CB(skb)->seq, tcp_wnd_end(tp))) {
 			int err;
 			unsigned int mss =3D tcp_current_mss(sk, 0);
-			unsigned int seg_size =3D tp->snd_una+tp->snd_wnd-TCP_SKB_CB(skb)->=
seq;
+			unsigned int seg_size =3D tcp_wnd_end(tp) - TCP_SKB_CB(skb)->seq;
=20
 			if (before(tp->pushed_seq, TCP_SKB_CB(skb)->end_seq))
 				tp->pushed_seq =3D TCP_SKB_CB(skb)->end_seq;
--=20
1.5.0.6

