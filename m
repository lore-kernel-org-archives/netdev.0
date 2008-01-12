From: "=?utf-8?q?Ilpo_J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/8] [TCP]: Uninline tcp_is_cwnd_limited
Date: Sat, 12 Jan 2008 11:40:11 +0200
Message-ID: <12001308173014-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12001308173969-git-send-email-ilpo.jarvinen@helsinki.fi> <12001308171262-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35414 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760811AbYALJkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 04:40:19 -0500
In-Reply-To: <12001308171262-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/ipv4/tcp_cong.c:
  tcp_reno_cong_avoid |  -65
 1 function changed, 65 bytes removed, diff: -65

net/ipv4/arp.c:
  arp_ignore |   -5
 1 function changed, 5 bytes removed, diff: -5

net/ipv4/tcp_bic.c:
  bictcp_cong_avoid |  -57
 1 function changed, 57 bytes removed, diff: -57

net/ipv4/tcp_cubic.c:
  bictcp_cong_avoid |  -61
 1 function changed, 61 bytes removed, diff: -61

net/ipv4/tcp_highspeed.c:
  hstcp_cong_avoid |  -63
 1 function changed, 63 bytes removed, diff: -63

net/ipv4/tcp_hybla.c:
  hybla_cong_avoid |  -85
 1 function changed, 85 bytes removed, diff: -85

net/ipv4/tcp_htcp.c:
  htcp_cong_avoid |  -57
 1 function changed, 57 bytes removed, diff: -57

net/ipv4/tcp_veno.c:
  tcp_veno_cong_avoid |  -52
 1 function changed, 52 bytes removed, diff: -52

net/ipv4/tcp_scalable.c:
  tcp_scalable_cong_avoid |  -61
 1 function changed, 61 bytes removed, diff: -61

net/ipv4/tcp_yeah.c:
  tcp_yeah_cong_avoid |  -75
 1 function changed, 75 bytes removed, diff: -75

net/ipv4/tcp_illinois.c:
  tcp_illinois_cong_avoid |  -54
 1 function changed, 54 bytes removed, diff: -54

net/dccp/ccids/ccid3.c:
  ccid3_update_send_interval |   -7
  ccid3_hc_tx_packet_recv    |   +7
 2 functions changed, 7 bytes added, 7 bytes removed, diff: +0

net/ipv4/tcp_cong.c:
  tcp_is_cwnd_limited |  +88
 1 function changed, 88 bytes added, diff: +88

built-in.o:
 14 functions changed, 95 bytes added, 642 bytes removed, diff: -547

=2E..Again some gcc artifacts visible as well.

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h   |   22 +---------------------
 net/ipv4/tcp_cong.c |   21 +++++++++++++++++++++
 2 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 306580c..7de4ea3 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -786,27 +786,7 @@ static inline u32 tcp_wnd_end(const struct tcp_soc=
k *tp)
 {
 	return tp->snd_una + tp->snd_wnd;
 }
-
-/* RFC2861 Check whether we are limited by application or congestion w=
indow
- * This is the inverse of cwnd check in tcp_tso_should_defer
- */
-static inline int tcp_is_cwnd_limited(const struct sock *sk, u32 in_fl=
ight)
-{
-	const struct tcp_sock *tp =3D tcp_sk(sk);
-	u32 left;
-
-	if (in_flight >=3D tp->snd_cwnd)
-		return 1;
-
-	if (!sk_can_gso(sk))
-		return 0;
-
-	left =3D tp->snd_cwnd - in_flight;
-	if (sysctl_tcp_tso_win_divisor)
-		return left * sysctl_tcp_tso_win_divisor < tp->snd_cwnd;
-	else
-		return left <=3D tcp_max_burst(tp);
-}
+extern int tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight);
=20
 static inline void tcp_minshall_update(struct tcp_sock *tp, unsigned i=
nt mss,
 				       const struct sk_buff *skb)
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 4451750..3a6be23 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -274,6 +274,27 @@ int tcp_set_congestion_control(struct sock *sk, co=
nst char *name)
 	return err;
 }
=20
+/* RFC2861 Check whether we are limited by application or congestion w=
indow
+ * This is the inverse of cwnd check in tcp_tso_should_defer
+ */
+int tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight)
+{
+	const struct tcp_sock *tp =3D tcp_sk(sk);
+	u32 left;
+
+	if (in_flight >=3D tp->snd_cwnd)
+		return 1;
+
+	if (!sk_can_gso(sk))
+		return 0;
+
+	left =3D tp->snd_cwnd - in_flight;
+	if (sysctl_tcp_tso_win_divisor)
+		return left * sysctl_tcp_tso_win_divisor < tp->snd_cwnd;
+	else
+		return left <=3D tcp_max_burst(tp);
+}
+EXPORT_SYMBOL_GPL(tcp_is_cwnd_limited);
=20
 /*
  * Slow start is used when congestion window is less than slow start
--=20
1.5.0.6

