From: "Kevin Lahey" <kml@patheticgeek.net>
Subject: [PATCH]  tcp_ack_update_window window scaling bug
Date: Tue, 28 Oct 2003 08:17:59 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031028161759.14346.qmail@patheticgeek.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Using ttcp to test TSO on 2.5.75, I noticed an odd problem with
receiver windows larger than 64KB.  The initial data packet after
the three-way handshake was delayed by around 200 milliseconds.

Further investigation revealed that TSO support for the connection
was being turned off at the same time by the SWS avoidance code.
The same ttcp transfer without the large receiver window showed no
delay, and didn't turn off TSO.

It appears that tcp_ack_update_window is window scaling the offered
TCP receiver window even on the SYN packet.  As noted in no less
than two other places in the networking code, RFC 1323 insists that
initial window advertisements are unscaled.

This meant that tp->max_window was too large initially, resulting
in an inappropriately large TSO segment size.  The initial TSO segment 
was delayed by the SWS code, causing the 200ms pause.  I'm not sure
whether this bug could ever be tickled by anything *but* TSO, but
I suppose in some contrived situations with non-Linux remote hosts,
it could wind up being significant.

Here's a patch that solves my performance problem:

--- linux-2.5.75/net/ipv4/tcp_input.c.orig	Mon Oct 27 19:02:55 2003
+++ linux-2.5.75/net/ipv4/tcp_input.c	Mon Oct 27 19:04:34 2003
@@ -1966,7 +1966,8 @@
 				 struct sk_buff *skb, u32 ack, u32 ack_seq)
 {
 	int flag = 0;
-	u32 nwin = ntohs(skb->h.th->window) << tp->snd_wscale;
+	u32 nwin = (skb->h.th->syn ? ntohs(skb->h.th->window) :
+			ntohs(skb->h.th->window) << tp->snd_wscale);
 
 	if (tcp_may_update_window(tp, ack, ack_seq, nwin)) {
 		flag |= FLAG_WIN_UPDATE;

Thanks,

Kevin
kml@patheticgeek.net
