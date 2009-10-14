From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Wed, 14 Oct 2009 06:52:26 +0200
Message-ID: <20091014045226.GA15655@1wt.eu>
References: <20091013050705.GA2194@1wt.eu> <20091013.001106.226276168.davem@davemloft.net> <20091013071955.GA3587@1wt.eu> <Pine.LNX.4.58.0910132335390.3095@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:50197 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750724AbZJNExO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 00:53:14 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0910132335390.3095@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Julian,

On Wed, Oct 14, 2009 at 12:27:41AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 13 Oct 2009, Willy Tarreau wrote:
> 
> > >From da80c99a503bab1256706ed8d967e2ab3f71afe0 Mon Sep 17 00:00:00 2001
> > From: Willy Tarreau <w@1wt.eu>
> > Date: Tue, 13 Oct 2009 07:26:54 +0200
> > Subject: tcp: fix tcp_defer_accept to consider the timeout
> > 
> > I was trying to use TCP_DEFER_ACCEPT and noticed that if the
> > client does not talk, the connection is never accepted and
> > remains in SYN_RECV state until the retransmits expire, where
> > it finally is deleted. This is bad when some firewall such as
> 
> 	I think, this is by design, there is big comment in
> tcp_check_req().

I'm not sure. That would considerably reduce the usefulness of
the feature. The comment I see there is just a one line explaining
why we drop the ACK. It does not indicate any strategy on what to
do when the counter expires.

> > netfilter sits between the client and the server because the
> > firewall sees the connection in ESTABLISHED state while the
> > server will finally silently drop it without sending an RST.
> 
> 	Client can stay ESTABLISHED for long time but
> RST will be sent when client sends DATA or FIN.

Yes you're right. In fact, this only weakens firewalls in case of
pure scans, but attacks on SYN cookies do that too, as well as
TTL-based attacks.

> > This behaviour contradicts the man page which says it should
> > wait only for some time :
> > 
> >        TCP_DEFER_ACCEPT (since Linux 2.4)
> >           Allows a listener to be awakened only when data arrives
> >           on the socket.  Takes an integer value  (seconds), this
> >           can  bound  the  maximum  number  of attempts TCP will
> >           make to complete the connection. This option should not
> >           be used in code intended to be portable.
> 
> 	This works properly in 2.6.31.3, I set TCP_SYNCNT=1
> and TCP_DEFER_ACCEPT then only 2 SYN-ACKs are sent.

That's what I observe too, but the connection is silently dropped
afterwards and I'm clearly not sure this was the intended behaviour.

> > Also, looking at ipv4/tcp.c, a retransmit counter is correctly
> > computed :
> 
> 	rskq_defer_accept is threshold, not counter
> 
> >         case TCP_DEFER_ACCEPT:
> >                 icsk->icsk_accept_queue.rskq_defer_accept = 0;
> >                 if (val > 0) {
> >                         /* Translate value in seconds to number of
> >                          * retransmits */
> >                         while (icsk->icsk_accept_queue.rskq_defer_accept < 32 &&
> >                                val > ((TCP_TIMEOUT_INIT / HZ) <<
> >                                        icsk->icsk_accept_queue.rskq_defer_accept))
> >                                 icsk->icsk_accept_queue.rskq_defer_accept++;
> >                         icsk->icsk_accept_queue.rskq_defer_accept++;
> >                 }
> >                 break;
> > 
> > ==> rskq_defer_accept is used as a counter of retransmits.
> 
> 	as limit for retransmits, not as counter

yes if you want, that's what I mean.

> > But in tcp_minisocks.c, this counter is only checked. And in
> > fact, I have found no location which updates it. So I think
> > that what was intended was to decrease it in tcp_minisocks
> > whenever it is checked, which the trivial patch below does.
> 
> 	You can check net/ipv4/inet_connection_sock.c,
> inet_csk_reqsk_queue_prune() where TCP_DEFER_ACCEPT can extend
> the retransmission threshold for acked sockets above the
> applied 'thresh'.

So clearly this is in order to improve chances that the application
will receive the connection, no ?

> So, there are 2 options:
> 
> a) TCP_DEFER_ACCEPT is used as flag (eg. 1) or the period is below
> the TCP_SYNCNT period. In this case TCP_DEFER_ACCEPT does not
> extend the period for DATA (DATA must come before TCP_SYNCNT).
> Application is notified only when DATA comes.
> 
> or
> 
> b) TCP_DEFER_ACCEPT is set with seconds above the TCP_SYNCNT
> retrans limit and the first ACK extends the period up to
> TCP_DEFER_ACCEPT seconds (converted as retrans). By this
> way we provide more time for DATA after the empty ACKs.
> ACK again can come before TCP_SYNCNT but DATA after ACK
> can come even after TCP_SYNCNT but before TCP_DEFER_ACCEPT
> timeout. Again, application is notified only when DATA comes.

Yes this is what happens right now, but reading the man again
does not imply to me that the connection will not be accepted
once we reach the retransmit limit.

Maybe we have different usages and different interpretations of
the man can satisfy either, but I don't see what this would be
useful to in case we silently drop instead of finally accepting.

Regards,
Willy

