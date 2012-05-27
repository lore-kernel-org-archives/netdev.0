From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at net/ipv4/tcp.c:1610 tcp_recvmsg+0xb1b/0xc70()
Date: Sun, 27 May 2012 19:35:56 +0200
Message-ID: <1338140156.3786.10.camel@edumazet-glaptop>
References: <4FBFEACC.8040601@fastmail.fm>
	 <1337978725.10135.0.camel@edumazet-glaptop>
	 <1337979331.10135.2.camel@edumazet-glaptop> <4FC0BCE1.6070601@fastmail.fm>
	 <1338127184.3670.50.camel@edumazet-glaptop> <4FC24987.4090708@fastmail.fm>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Jack Stone <jwjstone@fastmail.fm>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FC24987.4090708@fastmail.fm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2012-05-27 at 16:34 +0100, Jack Stone wrote:
> On 05/27/2012 02:59 PM, Eric Dumazet wrote:
> > On Sat, 2012-05-26 at 12:22 +0100, Jack Stone wrote:
> > 
> >> I'm still getting this with da89fb1 which includes the above
> >>
> >> Linux hover1 3.4.0-07797-gda89fb1 #4 SMP Fri May 25 22:23:14 BST 2012 x86_64 x86_64 x86_64 GNU/Linux
> > 
> > Thanks
> > 
> > Could you add following debugging patch ?
> > 
> > diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> > index 3ba605f..b56c63c 100644
> > --- a/net/ipv4/tcp.c
> > +++ b/net/ipv4/tcp.c
> > @@ -1606,8 +1606,9 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
> >  			if (tcp_hdr(skb)->fin)
> >  				goto found_fin_ok;
> >  			WARN(!(flags & MSG_PEEK),
> > -			     "recvmsg bug 2: copied %X seq %X rcvnxt %X fl %X\n",
> > -			     *seq, TCP_SKB_CB(skb)->seq, tp->rcv_nxt, flags);
> > +			     "recvmsg bug 2: copied %X seq %X end_seq %X rcvnxt %X fl %X offset %u len %u syn %d\n",
> > +			     *seq, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq,
> > +			     tp->rcv_nxt, flags, offset, skb->len, tcp_hdr(skb)->syn);
> >  		}
> >  
> >  		/* Well, if we have backlog, try to process it now yet. */
> > 
> > 
> 
> uname: Linux hover1 3.4.0-07822-g786f02b-dirty #1 SMP Sun May 27 15:23:39 BST 2012 x86_64 x86_64 x86_64 GNU/Linux
> 
> Here's the new output:
> 
> 
> May 27 16:32:30 hover1 kernel: [ 1907.804613] ------------[ cut here ]------------
> May 27 16:32:30 hover1 kernel: [ 1907.804622] WARNING: at net/ipv4/tcp.c:1611 tcp_recvmsg+0xb36/0xc90()
> May 27 16:32:30 hover1 kernel: [ 1907.804624] Hardware name: System Product Name
> May 27 16:32:30 hover1 kernel: [ 1907.804626] recvmsg bug 2: copied 8F322DEB seq 8F322DEB end_seq 8F322F2A rcvnxt 8F322F2A fl 0 offset 4294967295 len 319 syn 1

So it seems we can queue in sk_receive_queue a packet with SYN flag set.

(A SYN or SYNACK packet contains DATA payload...)

The sequence number of such frames should be tweaked (seq++) instead of
games we do in fast path :

if (tcp_hdr(skb)->syn)
    offset--;


Oh well this can wait linux-3.6, please test following patch in the
meantime.

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b224eb8..34c8dcc 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4553,7 +4553,7 @@ static bool tcp_try_coalesce(struct sock *sk,
 
 	*fragstolen = false;
 
-	if (tcp_hdr(from)->fin)
+	if (tcp_hdr(from)->fin || tcp_hdr(to)->syn)
 		return false;
 
 	/* Its possible this segment overlaps with prior segment in queue */
