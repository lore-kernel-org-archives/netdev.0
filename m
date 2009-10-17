From: Julian Anastasov <ja@ssi.bg>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Sat, 17 Oct 2009 17:20:30 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0910171709190.10440@u.domain.uli>
References: <20091014045226.GA15655@1wt.eu> <Pine.LNX.4.58.0910140912420.2714@u.domain.uli>
 <20091014201706.GA24298@1wt.eu> <20091014.154349.83940908.davem@davemloft.net>
 <20091015060834.GB29564@1wt.eu> <Pine.LNX.4.58.0910151120340.2879@u.domain.uli>
 <20091015124134.GB1073@1wt.eu> <Pine.LNX.4.58.0910152257410.3047@u.domain.uli>
 <20091016050310.GA5574@1wt.eu> <Pine.LNX.4.58.0910161137490.3886@u.domain.uli>
 <4AD84D8B.5020103@gmail.com> <Pine.LNX.4.58.0910171417260.7818@u.domain.uli>
 <4AD9B37A.3090606@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:54376 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751539AbZJQOTi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2009 10:19:38 -0400
In-Reply-To: <4AD9B37A.3090606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sat, 17 Oct 2009, Eric Dumazet wrote:

> I really like this, but please define helper functions out of do_tcp_setsockopt()
> 
> /* Translate value in seconds to number of SYN-ACK retransmits */
> static u8 secs_to_retrans(int seconds)
> {
> 	u8 res = 0;
> 
> 	if (seconds > 0) {
> 		int timeout = TCP_TIMEOUT_INIT / HZ;
> 		int period = timeout;
> 
> 		res = 1;
> 		while (res < 255 && seconds > period) {
> 			res++;
> 			timeout <<= 1;
> 			if (timeout > TCP_RTO_MAX / HZ)
> 				timeout = TCP_RTO_MAX / HZ;
> 			period += timeout;
> 		}
> 	}
> 	return res;
> }
> 
> You also need the reverse function for getsockopt()...

	Yes, I forgot that. Here is what I tested, should
I split it later to 2 patches? May be it should go somewhere
in net/core/sock.c as extern funcs with EXPORT_SYMBOL to
allow other protocols one day to use it?

Signed-off-by: Julian Anastasov <ja@ssi.bg>

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

Regards

--
Julian Anastasov <ja@ssi.bg>
