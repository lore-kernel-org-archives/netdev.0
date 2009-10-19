From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] tcp: fix TCP_DEFER_ACCEPT retrans calculation
Date: Mon, 19 Oct 2009 23:10:40 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0910192304060.2971@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:45928 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752134AbZJSUJH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2009 16:09:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Fix TCP_DEFER_ACCEPT conversion between seconds and
retransmission to match the TCP SYN-ACK retransmission periods
because the time is converted to such retransmissions. The old
algorithm selects one more retransmission in some cases. Allow
up to 255 retransmissions.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

	Not sure if this is the right place to put both
functions ...

diff -urp v2.6.31/linux/net/ipv4/tcp.c linux/net/ipv4/tcp.c
--- v2.6.31/linux/net/ipv4/tcp.c	2009-09-11 10:27:17.000000000 +0300
+++ linux/net/ipv4/tcp.c	2009-10-17 16:37:48.000000000 +0300
@@ -326,6 +326,43 @@ void tcp_enter_memory_pressure(struct so
 
 EXPORT_SYMBOL(tcp_enter_memory_pressure);
 
+/* Convert seconds to retransmits based on initial and max timeout */
+static u8 secs_to_retrans(int seconds, int timeout, int rto_max)
+{
+	u8 res = 0;
+
+	if (seconds > 0) {
+		int period = timeout;
+
+		res = 1;
+		while (seconds > period && res < 255) {
+			res++;
+			timeout <<= 1;
+			if (timeout > rto_max)
+				timeout = rto_max;
+			period += timeout;
+		}
+	}
+	return res;
+}
+
+/* Convert retransmits to seconds based on initial and max timeout */
+static int retrans_to_secs(u8 retrans, int timeout, int rto_max)
+{
+	int period = 0;
+
+	if (retrans > 0) {
+		period = timeout;
+		while (--retrans) {
+			timeout <<= 1;
+			if (timeout > rto_max)
+				timeout = rto_max;
+			period += timeout;
+		}
+	}
+	return period;
+}
+
 /*
  *	Wait for a TCP event.
  *
@@ -2163,16 +2200,10 @@ static int do_tcp_setsockopt(struct sock
 		break;
 
 	case TCP_DEFER_ACCEPT:
-		icsk->icsk_accept_queue.rskq_defer_accept = 0;
-		if (val > 0) {
-			/* Translate value in seconds to number of
-			 * retransmits */
-			while (icsk->icsk_accept_queue.rskq_defer_accept < 32 &&
-			       val > ((TCP_TIMEOUT_INIT / HZ) <<
-				       icsk->icsk_accept_queue.rskq_defer_accept))
-				icsk->icsk_accept_queue.rskq_defer_accept++;
-			icsk->icsk_accept_queue.rskq_defer_accept++;
-		}
+		/* Translate value in seconds to number of retransmits */
+		icsk->icsk_accept_queue.rskq_defer_accept =
+			secs_to_retrans(val, TCP_TIMEOUT_INIT / HZ,
+					TCP_RTO_MAX / HZ);
 		break;
 
 	case TCP_WINDOW_CLAMP:
@@ -2353,8 +2384,8 @@ static int do_tcp_getsockopt(struct sock
 			val = (val ? : sysctl_tcp_fin_timeout) / HZ;
 		break;
 	case TCP_DEFER_ACCEPT:
-		val = !icsk->icsk_accept_queue.rskq_defer_accept ? 0 :
-			((TCP_TIMEOUT_INIT / HZ) << (icsk->icsk_accept_queue.rskq_defer_accept - 1));
+		val = retrans_to_secs(icsk->icsk_accept_queue.rskq_defer_accept,
+				      TCP_TIMEOUT_INIT / HZ, TCP_RTO_MAX / HZ);
 		break;
 	case TCP_WINDOW_CLAMP:
 		val = tp->window_clamp;
