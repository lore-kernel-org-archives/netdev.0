From: Martin Pool <mbp@samba.org>
Subject: Re: FIN_WAIT1 / TCP_CORK / 2.2 -- reproducible bug and test case
Date: Thu, 26 Sep 2002 15:47:46 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020926054721.GA6039@samba.org>
References: <20020918020927.GB2285@samba.org> <200209182338.DAA00778@mops.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, ak@muc.de, netdev@oss.sgi.com, Alan.Cox@linux.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <200209182338.DAA00778@mops.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 19 Sep 2002, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:
> Hello!
> 
> > I can't reproduce it on 2.4.18 or .19.  It looked to me like
> > tcp_snd_test() and related stuff had been substantially rewritten.
> 
> No, tcp_snd_test() in 2.2 is backport and it is accurate.
> Apparently, the problem remained in another place, which was not backported.
> 
> I think this is tcp_send_fin(). It is obscure and apparently incorrect
> at least on corked sockets. I would kill all the dubious "if" after
> 
> /* Special case to avoid Nagle bogosity....
> 
> and replaced it with straight tcp_push_pending_frames() like it was
> made in 2.4. Please, try.

Thanks for the hint!  The change you suggested seems to reliably fix
the problem but I saw something else as well.

I was also a bit confused by the purpose of the (skb->len < mss_now)
term in tcp_send_fin().  As far as I can see, that if statement is to
do with deciding whether to make up a new FIN packet, or whether to
set the FIN bit on the final packet that is already queued.

It seems to me that in 2.2.21, if we ever have frames queued in
tp->send_head, and altogether they are more than the MSS, then it will
go through to the else branch, and make up and send a FIN packet
straight away.  The FIN packet will be transmitted before the other
packets that are queued, even though they are earlier in sequence.
So, assuming no selective ACK, it will arrive out of order and just
have to be retransmitted later on.

I see that that test is gone in 2.4.18, and the expression is simply
(tp->send_head != NULL).

The patch is just below.  It works with 2.2.22 too.  If somebody could
let me know if it's OK I would appreciate it.

> BTW your tcpdump contains less than 25% of packets. And all the interesting
> piece is absent completely. :-)

I think the interesting bit is absent from the dump because it really
*is* absent -- the machine just never sends a FIN.  (Or perhaps
tcpdump missed some packets?)

--- linux-2.2.21-cork/net/ipv4/tcp_output.c.orig	Thu Sep 26 07:34:52 2002
+++ linux-2.2.21-cork/net/ipv4/tcp_output.c	Thu Sep 26 07:59:52 2002
@@ -753,38 +753,23 @@ void tcp_send_fin(struct sock *sk)
 {
 	struct tcp_opt *tp = &(sk->tp_pinfo.af_tcp);	
 	struct sk_buff *skb = skb_peek_tail(&sk->write_queue);
-	unsigned int mss_now;
 	
-	/* Optimization, tack on the FIN if we have a queue of
-	 * unsent frames.  But be careful about outgoing SACKS
-	 * and IP options.
-	 */
-	mss_now = tcp_current_mss(sk); 
+	if ((tp->send_head != NULL)) {
+		/* Optimization, tack on the FIN if we have a queue of
+		 * unsent frames.  But be careful about outgoing SACKS
+		 * and IP options.  Then send all outstanding frames,
+		 * or turn on probe timer.  */
 
-	if((tp->send_head != NULL) && (skb->len < mss_now)) {
 		/* tcp_write_xmit() takes care of the rest. */
 		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_FIN;
 		TCP_SKB_CB(skb)->end_seq++;
 		tp->write_seq++;
 
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
+		/* Nothing is currently pending on this socket; make a
+		 * FIN packet and send it directly. */
+	  
 		/* Socket is locked, keep trying until memory is available. */
 		for (;;) {
 			skb = sock_wmalloc(sk,


-- 
Martin 
Want a faster compiler?  http://distcc.samba.org/
