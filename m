From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at net/ipv4/tcp.c:1610 tcp_recvmsg+0xb1b/0xc70()
Date: Sun, 27 May 2012 21:36:14 +0200
Message-ID: <1338147374.3786.43.camel@edumazet-glaptop>
References: <4FBFEACC.8040601@fastmail.fm>
	 <1337978725.10135.0.camel@edumazet-glaptop>
	 <1337979331.10135.2.camel@edumazet-glaptop> <4FC0BCE1.6070601@fastmail.fm>
	 <1338127184.3670.50.camel@edumazet-glaptop> <4FC24987.4090708@fastmail.fm>
	 <1338140156.3786.10.camel@edumazet-glaptop>  <4FC27CE7.20604@fastmail.fm>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Jack Stone <jwjstone@fastmail.fm>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FC27CE7.20604@fastmail.fm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2012-05-27 at 20:13 +0100, Jack Stone wrote:
> On 05/27/2012 06:35 PM, Eric Dumazet wrote:
> > So it seems we can queue in sk_receive_queue a packet with SYN flag set.
> > 
> > (A SYN or SYNACK packet contains DATA payload...)
> > 
> > The sequence number of such frames should be tweaked (seq++) instead of
> > games we do in fast path :
> > 
> > if (tcp_hdr(skb)->syn)
> >     offset--;
> > 
> > 
> > Oh well this can wait linux-3.6, please test following patch in the
> > meantime.
> > 
> > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > index b224eb8..34c8dcc 100644
> > --- a/net/ipv4/tcp_input.c
> > +++ b/net/ipv4/tcp_input.c
> > @@ -4553,7 +4553,7 @@ static bool tcp_try_coalesce(struct sock *sk,
> >  
> >  	*fragstolen = false;
> >  
> > -	if (tcp_hdr(from)->fin)
> > +	if (tcp_hdr(from)->fin || tcp_hdr(to)->syn)
> >  		return false;
> >  
> >  	/* Its possible this segment overlaps with prior segment in queue */
> > 
> > 
> 
> Still seems to fire with the above applied, it also sets of the warn just above it...
> 
> Could it be something to do with my staging network driver?


Yes it could be memory corruption.

(making tcp _think_ tcp_hdr(skb)->syn is set, while it was not at all.

Please replace debugging patch by following, because tcp flags are
copied elsewhere, so we can double check.

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3ba605f..22e4c9a 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1606,8 +1606,10 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			if (tcp_hdr(skb)->fin)
 				goto found_fin_ok;
 			WARN(!(flags & MSG_PEEK),
-			     "recvmsg bug 2: copied %X seq %X rcvnxt %X fl %X\n",
-			     *seq, TCP_SKB_CB(skb)->seq, tp->rcv_nxt, flags);
+			     "recvmsg bug 2: copied %X seq %X end_seq %X rcvnxt %X fl %X offset %u len %u syn %d tcp_flags %X\n",
+			     *seq, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq,
+			     tp->rcv_nxt, flags, offset, skb->len, tcp_hdr(skb)->syn,
+				 TCP_SKB_CB(skb)->tcp_flags);
 		}
 
 		/* Well, if we have backlog, try to process it now yet. */
