From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix tcp_hybla zero congestion window growth with small
 rho and large cwnd
Date: Tue, 07 Oct 2008 15:58:59 -0700 (PDT)
Message-ID: <20081007.155859.64412560.davem@davemloft.net>
References: <48E78D21.4020908@danielinux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ccaini@arces.unibo.it,
	rfirrincieli@arces.unibo.it
To: root@danielinux.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51466
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753390AbYJGW7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 18:59:24 -0400
In-Reply-To: <48E78D21.4020908@danielinux.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniele Lacamera <root@danielinux.net>
Date: Sat, 04 Oct 2008 17:34:57 +0200

> Because of rounding, in certain conditions, i.e. when in congestion
> avoidance state rho is smaller than 1/128 of the current cwnd, TCP
> Hybla congestion control starves and the cwnd is kept constant
> forever.
>
> This patch forces an increment by one segment after #send_cwnd calls
> without increments(newreno behavior).
>
> Signed-off-by: Daniele Lacamera <root@danielinux.net>

I mad a slight coding style fix and then applied
your patch to net-2.6 as follows.

tcp: Fix tcp_hybla zero congestion window growth with small rho and large cwnd.

Because of rounding, in certain conditions, i.e. when in congestion
avoidance state rho is smaller than 1/128 of the current cwnd, TCP
Hybla congestion control starves and the cwnd is kept constant
forever.

This patch forces an increment by one segment after #send_cwnd calls
without increments(newreno behavior).

Signed-off-by: Daniele Lacamera <root@danielinux.net>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp_hybla.c b/net/ipv4/tcp_hybla.c
index bfcbd14..c209e05 100644
--- a/net/ipv4/tcp_hybla.c
+++ b/net/ipv4/tcp_hybla.c
@@ -150,7 +150,11 @@ static void hybla_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 		ca->snd_cwnd_cents -= 128;
 		tp->snd_cwnd_cnt = 0;
 	}
-
+	/* check when cwnd has not been incremented for a while */
+	if (increment == 0 && odd == 0 && tp->snd_cwnd_cnt >= tp->snd_cwnd) {
+		tp->snd_cwnd++;
+		tp->snd_cwnd_cnt = 0;
+	}
 	/* clamp down slowstart cwnd to ssthresh value. */
 	if (is_slowstart)
 		tp->snd_cwnd = min(tp->snd_cwnd, tp->snd_ssthresh);
