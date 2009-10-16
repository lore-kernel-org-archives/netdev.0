From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Fri, 16 Oct 2009 07:03:10 +0200
Message-ID: <20091016050310.GA5574@1wt.eu>
References: <20091014045226.GA15655@1wt.eu> <Pine.LNX.4.58.0910140912420.2714@u.domain.uli> <20091014201706.GA24298@1wt.eu> <20091014.154349.83940908.davem@davemloft.net> <20091015060834.GB29564@1wt.eu> <Pine.LNX.4.58.0910151120340.2879@u.domain.uli> <20091015124134.GB1073@1wt.eu> <Pine.LNX.4.58.0910152257410.3047@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:50267 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751989AbZJPFD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2009 01:03:56 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0910152257410.3047@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Julian,

On Fri, Oct 16, 2009 at 01:44:34AM +0300, Julian Anastasov wrote:
(...)
> 	I was not clear enough in previous email. Your goal
> is to decrease period per client while the actually decreased
> threshold is on the listener's socket. 256 conns will be enough
> to completely disable TCP_DEFER_ACCEPT on the listener (u8).

Damn! Now that you're explaining this, it seems obvious and makes
so much sense ! Of course you're right. We should not touch the
listening socket, only the new socket being created ! Thanks for
this clarification. David, Julian is right, please drop my patch.

(...)
> 	As for new flags, may be we should not change
> TCP_DEFER_ACCEPT values because current applications can
> depend on it.

I have no problem with that, eventhough I'm really doubting
that many applications depend on its current behaviour.

> There is some free space in
> struct request_sock_queue just after u8 rskq_defer_accept.
> May be new flags/modes can go there to define another
> behavior but it means also changes in applications to support
> it.

One idea I had was to make it signed, because there is currently
no use for negative values. But let's see your proposal below.

>         /* If TCP_DEFER_ACCEPT is set, drop bare ACK. */
> -       if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
> +       if (req->retrans < inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
>             TCP_SKB_CB(skb)->end_seq == tcp_rsk(req)->rcv_isn + 1) {
>                 inet_rsk(req)->acked = 1;
>                 return NULL;
>         }

Yes, of course that looks a lot better !

(...)
> 	Such change will affect all servers that use
> TCP_DEFER_ACCEPT retransmissions less than TCP_SYNCNT. They
> will start to see wakeups without data after the TCP_DEFER_ACCEPT
> period.

Indeed. But anyway a server must always be prepared to see wakeup
without data, because there are some situations where it will still
happen. For instance, if hardware RX cksum is not possible, a data
packet will cause a wakeup and during the recv(), the copy_and_cksum
will detect a cksum error and will not send anything to userland,
so the application will get an empty read.

> 	To summarize:
> 
> SECOND	CLIENT			SERVER
> ---------------------------------------------------------
> 0	SYN			SYN-ACK
> 	if DATA => ESTABLISH
> 	if ACK => acked=1
> 3				SYN-ACK (set retrans=1)
> 	if ACK and TCP_DEFER_ACCEPT=1retrans => ESTABLISH
> 	if DATA => ESTABLISH
> 	if ACK => acked=1
> 9				if TCP_SYNCNT=1 => expire
> 				else SYN-ACK (set retrans=2)
> 	if ACK and TCP_DEFER_ACCEPT=2retrans => ESTABLISH
> 	if DATA => ESTABLISH
> 	if ACK => acked=1
> ...
> 
> PRO:
> 
> - if TCP_DEFER_ACCEPT<TCP_SYNCNT and client properly resends
> ACK on every SYN-ACK retransmission then we always will
> switch to established state on TCP_DEFER_ACCEPT expiration.

That's what I wanted to achieve :-)

> Such conns will never expire in SYN_RECV state. They
> will be terminated by client's FIN or will be accepted
> by server application and terminated properly. Of course,
> there is some chance if client delays its ACKs or if SYN-ACK
> is lost the open request to expire in SYN_RECV state.

Yes, but that must be covered by both ends stacks. Network
losses are normal and such events already happen in minor
quantities everyday.

> CON:
> 
> - if client refuses to send DATA we still need these SYN-ACKs
> to trigger ACK retransmissions from client because the only
> way to switch to established state is when packet is received,
> I don't know how TCP_DEFER_ACCEPT expiration can directly change
> the open request to established state.

Well anyway this is already better than the current situation where
an apparently established connection silently dies. With this
proposal, applications have a way to get a normal behaviour.

> 	May be it is possible to send first SYN-ACK and
> if one ACK is received to send more SYN-ACKs after
> TCP_DEFER_ACCEPT period expires. Then client still has chance
> to send ACK or DATA that will switch open request to established
> socket. So, our timer will be silent when acked=1 while
> TCP_DEFER_ACCEPT period is active, for example:
> 
> SYN
> 	SYN-ACK
> ACK
> 	...
> 	acked=1 => no SYN-ACKs retrans (assume they are sent and lost)
>
> 	...
> 	TCP_DEFER_ACCEPT expires => send 2nd SYN-ACK
> 	... If no client's ACK then resend SYN-ACK while retrans<TCP_SYNCNT
> 	...
> ACK or DATA => ESTABLISHED

On first reading I found it a bit dangerous because the client will assume
an established connection when not seeing any new SYN-ACKs. And if it has
no data to send, it will never retransmit its ACK. But after some thinking,
it still matches the purpose of TCP_DEFER_ACCEPT, without the extra
SYN-ACK / ACK dance that we currently observe. I was also worried about
middle firewalls, but they will have no problem because they'd see an
established connection (SYN,SYN-ACK,ACK), so their expiration timer will
be large enough to cover the lack of SYN-ACK during TCP_DEFER_ACCEPT.

> 	This will need little change in inet_csk_reqsk_queue_prune()
> but it saves SYN-ACK traffic during deferring period in the
> common case when client sends ACK. If such compromise is
> acceptable I can prepare and test some patch.

I would personally like this a lot ! This will satisfy people who
expect it to establish at the end of the "TCP_DEFER_ACCEPT delay"
as can be interpreted from the man page, will reduce the number of
useless SYN-ACKs that annoy other people while still making no
visible change for anyone who would rely on the current behaviour.

Regards,
Willy

