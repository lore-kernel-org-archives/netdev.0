From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: fix an infinite loop in tcp_slow_start()
Date: Sat, 02 Feb 2013 07:23:16 -0800
Message-ID: <1359818596.30177.84.camel@edumazet-glaptop>
References: <20130123161238.GE8912@reaktio.net>
	 <20130123214445.GA16641@order.stressinduktion.org>
	 <20130123215151.GF8912@reaktio.net>
	 <20130123152642.4a8389ba@nehalam.linuxnetplumber.net>
	 <20130123234116.GC16641@order.stressinduktion.org>
	 <1358984831.12374.1227.camel@edumazet-glaptop>
	 <20130124135120.GD16641@order.stressinduktion.org>
	 <1359777110.30177.58.camel@edumazet-glaptop>
	 <20130202142832.GP8912@reaktio.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Pasi =?ISO-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:61439 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752730Ab3BBPXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2013 10:23:19 -0500
Received: by mail-pa0-f44.google.com with SMTP id hz11so2674785pad.3
        for <netdev@vger.kernel.org>; Sat, 02 Feb 2013 07:23:18 -0800 (PST)
In-Reply-To: <20130202142832.GP8912@reaktio.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

Since commit 9dc274151a548 (tcp: fix ABC in tcp_slow_start()),
a nul snd_cwnd triggers an infinite loop in tcp_slow_start()

Avoid this infinite loop and log a one time error for further
analysis. FRTO code is suspected to cause this bug.

Reported-by: Pasi K=C3=A4rkk=C3=A4inen <pasik@iki.fi>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_cong.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 291f2ed..cdf2e70 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -310,6 +310,12 @@ void tcp_slow_start(struct tcp_sock *tp)
 {
 	int cnt; /* increase in packets */
 	unsigned int delta =3D 0;
+	u32 snd_cwnd =3D tp->snd_cwnd;
+
+	if (unlikely(!snd_cwnd)) {
+		pr_err_once("snd_cwnd is nul, please report this bug.\n");
+		snd_cwnd =3D 1U;
+	}
=20
 	/* RFC3465: ABC Slow start
 	 * Increase only after a full MSS of bytes is acked
@@ -324,7 +330,7 @@ void tcp_slow_start(struct tcp_sock *tp)
 	if (sysctl_tcp_max_ssthresh > 0 && tp->snd_cwnd > sysctl_tcp_max_ssth=
resh)
 		cnt =3D sysctl_tcp_max_ssthresh >> 1;	/* limited slow start */
 	else
-		cnt =3D tp->snd_cwnd;			/* exponential increase */
+		cnt =3D snd_cwnd;				/* exponential increase */
=20
 	/* RFC3465: ABC
 	 * We MAY increase by 2 if discovered delayed ack
@@ -334,11 +340,11 @@ void tcp_slow_start(struct tcp_sock *tp)
 	tp->bytes_acked =3D 0;
=20
 	tp->snd_cwnd_cnt +=3D cnt;
-	while (tp->snd_cwnd_cnt >=3D tp->snd_cwnd) {
-		tp->snd_cwnd_cnt -=3D tp->snd_cwnd;
+	while (tp->snd_cwnd_cnt >=3D snd_cwnd) {
+		tp->snd_cwnd_cnt -=3D snd_cwnd;
 		delta++;
 	}
-	tp->snd_cwnd =3D min(tp->snd_cwnd + delta, tp->snd_cwnd_clamp);
+	tp->snd_cwnd =3D min(snd_cwnd + delta, tp->snd_cwnd_clamp);
 }
 EXPORT_SYMBOL_GPL(tcp_slow_start);
=20
