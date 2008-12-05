From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 09/10] tcp: use tcp_write_xmit also in tcp_push_one
Date: Fri,  5 Dec 2008 22:58:55 +0200
Message-ID: <1228510736-3655-10-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1228510736-3655-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-7-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-8-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-9-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42864 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754762AbYLEU7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 15:59:02 -0500
In-Reply-To: <1228510736-3655-9-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_minshall_update is not significant difference since it only
checks for not full-sized skb which is BUG'ed one the push_one
path anyway.

tcp_snd_test is tcp_nagle_test+tcp_cwnd_test+tcp_snd_wnd_test,
just the order changed slightly.

net/ipv4/tcp_output.c:
  tcp_snd_test              |  -89
  tcp_mss_split_point       |  -91
  tcp_may_send_now          |  +53
  tcp_cwnd_validate         |  -98
  tso_fragment              | -239
  __tcp_push_pending_frames | -1340
  tcp_push_one              | -146
 7 functions changed, 53 bytes added, 2003 bytes removed, diff: -1950

net/ipv4/tcp_output.c:
  tcp_write_xmit | +1772
 1 function changed, 1772 bytes added, diff: +1772

tcp_output.o.new:
 8 functions changed, 1825 bytes added, 2003 bytes removed, diff: -178

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |   54 +++++++++++++++--------------------------=
-------
 1 files changed, 17 insertions(+), 37 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 59505ce..e65c114 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1519,7 +1519,8 @@ static int tcp_mtu_probe(struct sock *sk)
  * Returns 1, if no segments are in flight and we have queued segments=
, but
  * cannot send anything now because of SWS or another problem.
  */
-static int tcp_write_xmit(struct sock *sk, unsigned int mss_now, int n=
onagle)
+static int tcp_write_xmit(struct sock *sk, unsigned int mss_now, int n=
onagle,
+			  int push_one, gfp_t gfp)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
@@ -1529,11 +1530,14 @@ static int tcp_write_xmit(struct sock *sk, unsi=
gned int mss_now, int nonagle)
=20
 	sent_pkts =3D 0;
=20
-	/* Do MTU probing. */
-	if ((result =3D tcp_mtu_probe(sk)) =3D=3D 0) {
-		return 0;
-	} else if (result > 0) {
-		sent_pkts =3D 1;
+	if (!push_one) {
+		/* Do MTU probing. */
+		result =3D tcp_mtu_probe(sk);
+		if (!result) {
+			return 0;
+		} else if (result > 0) {
+			sent_pkts =3D 1;
+		}
 	}
=20
 	while ((skb =3D tcp_send_head(sk))) {
@@ -1555,7 +1559,7 @@ static int tcp_write_xmit(struct sock *sk, unsign=
ed int mss_now, int nonagle)
 						      nonagle : TCP_NAGLE_PUSH))))
 				break;
 		} else {
-			if (tcp_tso_should_defer(sk, skb))
+			if (!push_one && tcp_tso_should_defer(sk, skb))
 				break;
 		}
=20
@@ -1570,7 +1574,7 @@ static int tcp_write_xmit(struct sock *sk, unsign=
ed int mss_now, int nonagle)
=20
 		TCP_SKB_CB(skb)->when =3D tcp_time_stamp;
=20
-		if (unlikely(tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC)))
+		if (unlikely(tcp_transmit_skb(sk, skb, 1, gfp)))
 			break;
=20
 		/* Advance the send_head.  This one is sent out.
@@ -1580,6 +1584,9 @@ static int tcp_write_xmit(struct sock *sk, unsign=
ed int mss_now, int nonagle)
=20
 		tcp_minshall_update(tp, mss_now, skb);
 		sent_pkts++;
+
+		if (push_one)
+			break;
 	}
=20
 	if (likely(sent_pkts)) {
@@ -1608,7 +1615,7 @@ void __tcp_push_pending_frames(struct sock *sk, u=
nsigned int cur_mss,
 	if (unlikely(sk->sk_state =3D=3D TCP_CLOSE))
 		return;
=20
-	if (tcp_write_xmit(sk, cur_mss, nonagle))
+	if (tcp_write_xmit(sk, cur_mss, nonagle, 0, GFP_ATOMIC))
 		tcp_check_probe_timer(sk);
 }
=20
@@ -1617,38 +1624,11 @@ void __tcp_push_pending_frames(struct sock *sk,=
 unsigned int cur_mss,
  */
 void tcp_push_one(struct sock *sk, unsigned int mss_now)
 {
-	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb =3D tcp_send_head(sk);
-	unsigned int tso_segs, cwnd_quota;
=20
 	BUG_ON(!skb || skb->len < mss_now);
=20
-	tso_segs =3D tcp_init_tso_segs(sk, skb, mss_now);
-	cwnd_quota =3D tcp_snd_test(sk, skb, mss_now, TCP_NAGLE_PUSH);
-
-	if (likely(cwnd_quota)) {
-		unsigned int limit;
-
-		BUG_ON(!tso_segs);
-
-		limit =3D mss_now;
-		if (tso_segs > 1 && !tcp_urg_mode(tp))
-			limit =3D tcp_mss_split_point(sk, skb, mss_now,
-						    cwnd_quota);
-
-		if (skb->len > limit &&
-		    unlikely(tso_fragment(sk, skb, limit, mss_now)))
-			return;
-
-		/* Send it out now. */
-		TCP_SKB_CB(skb)->when =3D tcp_time_stamp;
-
-		if (likely(!tcp_transmit_skb(sk, skb, 1, sk->sk_allocation))) {
-			tcp_event_new_data_sent(sk, skb);
-			tcp_cwnd_validate(sk);
-			return;
-		}
-	}
+	tcp_write_xmit(sk, mss_now, TCP_NAGLE_PUSH, 1, sk->sk_allocation);
 }
=20
 /* This function returns the amount that we can raise the
--=20
1.5.2.2

