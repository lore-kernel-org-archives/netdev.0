From: James Morris <jmorris@intercode.com.au>
Subject: Re: FIN_WAIT1 / TCP_CORK / 2.2 -- reproducible bug and test case
Date: Fri, 11 Oct 2002 02:36:41 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0210110220230.3139-100000@blackbird.intercode.com.au>
References: <Mutt.LNX.4.44.0210052152400.25151-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Pool <mbp@samba.org>
In-Reply-To: <Mutt.LNX.4.44.0210052152400.25151-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Martin,

Below is a simplified version of your patch, which maintains the 
(skb->len < mss_now) check per Alexey's comments.

Note that I've not been able to reproduce the problem with network
configurations from 10-1000Gbps and various combinations of hosts, kernels
and 'server' applications.  I did run into what looked like stalled
ESTABLISHED/FIN_WAIT1 connections, although these turned out to be the
(valid) result of the server advertising zero windows after it ran out of
resources.  The FIN_WAIT1 states on the client were running timers and
performing zero window probes.  A further check showed that it didn't
matter if the client socket sockets were corked or not.

Would you please give this patch some testing?  (It would be really great
if any of the RH 6.2 distcc users who reported problems could test it 
also).


Thanks,

- James
-- 
James Morris
<jmorris@intercode.com.au>

diff -urN -X dontdiff linux-2.2.22.orig/net/ipv4/tcp_output.c linux-2.2.22.corkfix/net/ipv4/tcp_output.c
--- linux-2.2.22.orig/net/ipv4/tcp_output.c	Fri May 10 12:10:08 2002
+++ linux-2.2.22.corkfix/net/ipv4/tcp_output.c	Fri Oct 11 01:22:33 2002
@@ -766,24 +766,7 @@
 		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_FIN;
 		TCP_SKB_CB(skb)->end_seq++;
 		tp->write_seq++;
-
-		/* Special case to avoid Nagle bogosity.  If this
-		 * segment is the last segment, and it was queued
-		 * due to Nagle/SWS-avoidance, send it out now.
-		 */
-		if(tp->send_head == skb &&
-		   !sk->nonagle &&
-		   skb->len < (tp->mss_cache >> 1) &&
-		   tp->packets_out &&
-		   !(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_URG)) {
-			update_send_head(sk);
-			TCP_SKB_CB(skb)->when = tcp_time_stamp;
-			tp->snd_nxt = TCP_SKB_CB(skb)->end_seq;
-			tp->packets_out++;
-			tcp_transmit_skb(sk, skb_clone(skb, GFP_ATOMIC));
-			if(!tcp_timer_is_set(sk, TIME_RETRANS))
-				tcp_reset_xmit_timer(sk, TIME_RETRANS, tp->rto);
-		}
+		tcp_push_pending_frames(sk, tp);
 	} else {
 		/* Socket is locked, keep trying until memory is available. */
 		for (;;) {
