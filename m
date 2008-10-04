From: Daniele Lacamera <root@danielinux.net>
Subject: [PATCH] Fix tcp_hybla zero congestion window growth with small rho
 and large cwnd
Date: Sat, 04 Oct 2008 17:34:57 +0200
Message-ID: <48E78D21.4020908@danielinux.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090506030401030504010609"
Cc: Carlo Caini <ccaini@arces.unibo.it>, rfirrincieli@arces.unibo.it
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from danielinux.vm.bytemark.co.uk ([80.68.95.85]:1062 "EHLO
	mail.danielinux.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751278AbYJDPeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2008 11:34:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090506030401030504010609
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Because of rounding, in certain conditions, i.e. when in congestion 
avoidance state rho is smaller than 1/128 of the current cwnd, TCP Hybla 
congestion control starves and the cwnd is kept constant forever.

This patch forces an increment by one segment after #send_cwnd calls
without increments(newreno behavior).

Please apply.

Signed-off-by: Daniele Lacamera <root@danielinux.net>



--------------090506030401030504010609
Content-Type: text/x-diff;
 name="hybla_not_incrementing_cwnd.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hybla_not_incrementing_cwnd.patch"

diff -ruN a/net/ipv4/tcp_hybla.c b/net/ipv4/tcp_hybla.c
--- a/net/ipv4/tcp_hybla.c	2008-07-13 23:51:29.000000000 +0200
+++ b/net/ipv4/tcp_hybla.c	2008-10-04 16:57:54.000000000 +0200
@@ -150,7 +150,12 @@
 		ca->snd_cwnd_cents -= 128;
 		tp->snd_cwnd_cnt = 0;
 	}
-
+	/* check when cwnd has not been incremented for a while */
+	if (increment == 0 && odd == 0 && tp->snd_cwnd_cnt >= tp->snd_cwnd)
+	{
+		tp->snd_cwnd++;
+		tp->snd_cwnd_cnt = 0;
+	}
 	/* clamp down slowstart cwnd to ssthresh value. */
 	if (is_slowstart)
 		tp->snd_cwnd = min(tp->snd_cwnd, tp->snd_ssthresh);


--------------090506030401030504010609--
