From: John Heffner <jheffner@psc.edu>
Subject: [PATCH] Bound TSO defer time (resend)
Date: Mon, 16 Oct 2006 20:53:20 -0400 (EDT)
Message-ID: <Pine.LNX.4.58.0610162051170.12462@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:7416 "EHLO mailer2.psc.edu")
	by vger.kernel.org with ESMTP id S1030191AbWJQAxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 20:53:20 -0400
Received: from dexter.psc.edu (dexter.psc.edu [128.182.58.232])
	by mailer2.psc.edu (8.13.8/8.13.3) with ESMTP id k9H0rKA0027303
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 16 Oct 2006 20:53:20 -0400 (EDT)
Received: from dexter.psc.edu (localhost.psc.edu [127.0.0.1])
	by dexter.psc.edu (8.13.1/8.13.1) with ESMTP id k9H0rKg7012472
	for <netdev@vger.kernel.org>; Mon, 16 Oct 2006 20:53:20 -0400
Received: from localhost (jheffner@localhost)
	by dexter.psc.edu (8.13.1/8.13.1/Submit) with ESMTP id k9H0rK6j012469
	for <netdev@vger.kernel.org>; Mon, 16 Oct 2006 20:53:20 -0400
To: netdev@vger.kernel.org
Content-ID: <Pine.LNX.4.58.0610162051172.12462@dexter.psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The original message didn't show up on the list.  I'm assuming it's
because the filters didn't like the attached postscript.  I posted PDFs of
the figures on the web:

http://www.psc.edu/~jheffner/tmp/a.pdf
http://www.psc.edu/~jheffner/tmp/b.pdf
http://www.psc.edu/~jheffner/tmp/c.pdf

  -John


---------- Forwarded message ----------
Date: Mon, 16 Oct 2006 15:55:53 -0400 (EDT)
From: John Heffner <jheffner@psc.edu>
To: David Miller <davem@davemloft.net>
Cc: netdev <netdev@vger.kernel.org>
Subject: [PATCH] Bound TSO defer time

This patch limits the amount of time you will defer sending a TSO segment
to less than two clock ticks, or the time between two acks, whichever is
longer.

On slow links, deferring causes significant bursts.  See attached plots,
which show RTT through a 1 Mbps link with a 100 ms RTT and ~100 ms queue
for (a) non-TSO, (b) currnet TSO, and (c) patched TSO.  This burstiness
causes significant jitter, tends to overflow queues early (bad for short
queues), and makes delay-based congestion control more difficult.

Deferring by a couple clock ticks I believe will have a relatively small
impact on performance.


Signed-off-by: John Heffner <jheffner@psc.edu>


diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 0e058a2..27ae4b2 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -341,7 +341,9 @@ #endif
 	int			linger2;

 	unsigned long last_synq_overflow;
-
+
+	__u32	tso_deferred;
+
 /* Receiver side RTT estimation */
 	struct {
 		__u32	rtt;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 9a253fa..3ea8973 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1087,11 +1087,15 @@ static int tcp_tso_should_defer(struct s
 	u32 send_win, cong_win, limit, in_flight;

 	if (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN)
-		return 0;
+		goto send_now;

 	if (icsk->icsk_ca_state != TCP_CA_Open)
-		return 0;
+		goto send_now;

+	/* Defer for less than two clock ticks. */
+	if (!tp->tso_deferred && ((jiffies<<1)>>1) - (tp->tso_deferred>>1) > 1)
+		goto send_now;
+
 	in_flight = tcp_packets_in_flight(tp);

 	BUG_ON(tcp_skb_pcount(skb) <= 1 ||
@@ -1106,8 +1110,8 @@ static int tcp_tso_should_defer(struct s

 	/* If a full-sized TSO skb can be sent, do it. */
 	if (limit >= 65536)
-		return 0;
-
+		goto send_now;
+
 	if (sysctl_tcp_tso_win_divisor) {
 		u32 chunk = min(tp->snd_wnd, tp->snd_cwnd * tp->mss_cache);

@@ -1116,7 +1120,7 @@ static int tcp_tso_should_defer(struct s
 		 */
 		chunk /= sysctl_tcp_tso_win_divisor;
 		if (limit >= chunk)
-			return 0;
+			goto send_now;
 	} else {
 		/* Different approach, try not to defer past a single
 		 * ACK.  Receiver should ACK every other full sized
@@ -1124,11 +1128,17 @@ static int tcp_tso_should_defer(struct s
 		 * then send now.
 		 */
 		if (limit > tcp_max_burst(tp) * tp->mss_cache)
-			return 0;
+			goto send_now;
 	}
-
+
 	/* Ok, it looks like it is advisable to defer.  */
+	tp->tso_deferred = 1 | (jiffies<<1);
+
 	return 1;
+
+send_now:
+	tp->tso_deferred = 0;
+	return 0;
 }

 /* Create a new MTU probe if we are ready.
