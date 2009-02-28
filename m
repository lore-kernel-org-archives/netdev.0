From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 12/17] tcp: add helper for AI algorithm
Date: Sat, 28 Feb 2009 16:44:37 +0200
Message-ID: <12358322831599-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12358322821815-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821434-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1235832282317-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322823783-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821182-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322832831-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831953-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831147-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322833102-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322832711-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322834113-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1235832283214-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53706 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665AbZB1Oox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 09:44:53 -0500
In-Reply-To: <1235832283214-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>

It seems that implementation in yeah was inconsistent to what
other did as it would increase cwnd one ack earlier than the
others do.

Size benefits:

  bictcp_cong_avoid |  -36
  tcp_cong_avoid_ai |  +52
  bictcp_cong_avoid |  -34
  tcp_scalable_cong_avoid |  -36
  tcp_veno_cong_avoid |  -12
  tcp_yeah_cong_avoid |  -38

=3D -104 bytes total

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h       |    1 +
 net/ipv4/tcp_bic.c      |   11 +----------
 net/ipv4/tcp_cong.c     |   21 ++++++++++++++-------
 net/ipv4/tcp_cubic.c    |   11 +----------
 net/ipv4/tcp_scalable.c |   10 ++--------
 net/ipv4/tcp_veno.c     |    7 +------
 net/ipv4/tcp_yeah.c     |    9 +--------
 7 files changed, 21 insertions(+), 49 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 218235d..0366a55 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -685,6 +685,7 @@ extern void tcp_get_allowed_congestion_control(char=
 *buf, size_t len);
 extern int tcp_set_allowed_congestion_control(char *allowed);
 extern int tcp_set_congestion_control(struct sock *sk, const char *nam=
e);
 extern void tcp_slow_start(struct tcp_sock *tp);
+extern void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w);
=20
 extern struct tcp_congestion_ops tcp_init_congestion_ops;
 extern u32 tcp_reno_ssthresh(struct sock *sk);
diff --git a/net/ipv4/tcp_bic.c b/net/ipv4/tcp_bic.c
index 7eb7636..3b53fd1 100644
--- a/net/ipv4/tcp_bic.c
+++ b/net/ipv4/tcp_bic.c
@@ -149,16 +149,7 @@ static void bictcp_cong_avoid(struct sock *sk, u32=
 ack, u32 in_flight)
 		tcp_slow_start(tp);
 	else {
 		bictcp_update(ca, tp->snd_cwnd);
-
-		/* In dangerous area, increase slowly.
-		 * In theory this is tp->snd_cwnd +=3D 1 / tp->snd_cwnd
-		 */
-		if (tp->snd_cwnd_cnt >=3D ca->cnt) {
-			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
-				tp->snd_cwnd++;
-			tp->snd_cwnd_cnt =3D 0;
-		} else
-			tp->snd_cwnd_cnt++;
+		tcp_cong_avoid_ai(tp, ca->cnt);
 	}
=20
 }
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 4ec5b4e..e92beb9 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -336,6 +336,19 @@ void tcp_slow_start(struct tcp_sock *tp)
 }
 EXPORT_SYMBOL_GPL(tcp_slow_start);
=20
+/* In theory this is tp->snd_cwnd +=3D 1 / tp->snd_cwnd (or alternativ=
e w) */
+void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w)
+{
+	if (tp->snd_cwnd_cnt >=3D w) {
+		if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+			tp->snd_cwnd++;
+		tp->snd_cwnd_cnt =3D 0;
+	} else {
+		tp->snd_cwnd_cnt++;
+	}
+}
+EXPORT_SYMBOL_GPL(tcp_cong_avoid_ai);
+
 /*
  * TCP Reno congestion control
  * This is special case used for fallback as well.
@@ -365,13 +378,7 @@ void tcp_reno_cong_avoid(struct sock *sk, u32 ack,=
 u32 in_flight)
 				tp->snd_cwnd++;
 		}
 	} else {
-		/* In theory this is tp->snd_cwnd +=3D 1 / tp->snd_cwnd */
-		if (tp->snd_cwnd_cnt >=3D tp->snd_cwnd) {
-			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
-				tp->snd_cwnd++;
-			tp->snd_cwnd_cnt =3D 0;
-		} else
-			tp->snd_cwnd_cnt++;
+		tcp_cong_avoid_ai(tp, tp->snd_cwnd);
 	}
 }
 EXPORT_SYMBOL_GPL(tcp_reno_cong_avoid);
diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index ee467ec..71d5f2f 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -294,16 +294,7 @@ static void bictcp_cong_avoid(struct sock *sk, u32=
 ack, u32 in_flight)
 		tcp_slow_start(tp);
 	} else {
 		bictcp_update(ca, tp->snd_cwnd);
-
-		/* In dangerous area, increase slowly.
-		 * In theory this is tp->snd_cwnd +=3D 1 / tp->snd_cwnd
-		 */
-		if (tp->snd_cwnd_cnt >=3D ca->cnt) {
-			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
-				tp->snd_cwnd++;
-			tp->snd_cwnd_cnt =3D 0;
-		} else
-			tp->snd_cwnd_cnt++;
+		tcp_cong_avoid_ai(tp, ca->cnt);
 	}
=20
 }
diff --git a/net/ipv4/tcp_scalable.c b/net/ipv4/tcp_scalable.c
index 4660b08..a765137 100644
--- a/net/ipv4/tcp_scalable.c
+++ b/net/ipv4/tcp_scalable.c
@@ -24,14 +24,8 @@ static void tcp_scalable_cong_avoid(struct sock *sk,=
 u32 ack, u32 in_flight)
=20
 	if (tp->snd_cwnd <=3D tp->snd_ssthresh)
 		tcp_slow_start(tp);
-	else {
-		tp->snd_cwnd_cnt++;
-		if (tp->snd_cwnd_cnt > min(tp->snd_cwnd, TCP_SCALABLE_AI_CNT)){
-			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
-				tp->snd_cwnd++;
-			tp->snd_cwnd_cnt =3D 0;
-		}
-	}
+	else
+		tcp_cong_avoid_ai(tp, min(tp->snd_cwnd, TCP_SCALABLE_AI_CNT));
 }
=20
 static u32 tcp_scalable_ssthresh(struct sock *sk)
diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
index d08b2e8..e9bbff7 100644
--- a/net/ipv4/tcp_veno.c
+++ b/net/ipv4/tcp_veno.c
@@ -159,12 +159,7 @@ static void tcp_veno_cong_avoid(struct sock *sk, u=
32 ack, u32 in_flight)
 				/* In the "non-congestive state", increase cwnd
 				 *  every rtt.
 				 */
-				if (tp->snd_cwnd_cnt >=3D tp->snd_cwnd) {
-					if (tp->snd_cwnd < tp->snd_cwnd_clamp)
-						tp->snd_cwnd++;
-					tp->snd_cwnd_cnt =3D 0;
-				} else
-					tp->snd_cwnd_cnt++;
+				tcp_cong_avoid_ai(tp, tp->snd_cwnd);
 			} else {
 				/* In the "congestive state", increase cwnd
 				 * every other rtt.
diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index 9ec843a..66b6821 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -94,14 +94,7 @@ static void tcp_yeah_cong_avoid(struct sock *sk, u32=
 ack, u32 in_flight)
=20
 	} else {
 		/* Reno */
-
-		if (tp->snd_cwnd_cnt < tp->snd_cwnd)
-			tp->snd_cwnd_cnt++;
-
-		if (tp->snd_cwnd_cnt >=3D tp->snd_cwnd) {
-			tp->snd_cwnd++;
-			tp->snd_cwnd_cnt =3D 0;
-		}
+		tcp_cong_avoid_ai(tp, tp->snd_cwnd);
 	}
=20
 	/* The key players are v_vegas.beg_snd_una and v_beg_snd_nxt.
--=20
1.5.6.5

