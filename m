From: Julian Anastasov <ja@ssi.bg>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Wed, 14 Oct 2009 00:27:41 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0910132335390.3095@u.domain.uli>
References: <20091013050705.GA2194@1wt.eu> <20091013.001106.226276168.davem@davemloft.net>
 <20091013071955.GA3587@1wt.eu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:60422 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753505AbZJMV15 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2009 17:27:57 -0400
In-Reply-To: <20091013071955.GA3587@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 13 Oct 2009, Willy Tarreau wrote:

> >From da80c99a503bab1256706ed8d967e2ab3f71afe0 Mon Sep 17 00:00:00 2001
> From: Willy Tarreau <w@1wt.eu>
> Date: Tue, 13 Oct 2009 07:26:54 +0200
> Subject: tcp: fix tcp_defer_accept to consider the timeout
> 
> I was trying to use TCP_DEFER_ACCEPT and noticed that if the
> client does not talk, the connection is never accepted and
> remains in SYN_RECV state until the retransmits expire, where
> it finally is deleted. This is bad when some firewall such as

	I think, this is by design, there is big comment in
tcp_check_req().

> netfilter sits between the client and the server because the
> firewall sees the connection in ESTABLISHED state while the
> server will finally silently drop it without sending an RST.

	Client can stay ESTABLISHED for long time but
RST will be sent when client sends DATA or FIN.

> This behaviour contradicts the man page which says it should
> wait only for some time :
> 
>        TCP_DEFER_ACCEPT (since Linux 2.4)
>           Allows a listener to be awakened only when data arrives
>           on the socket.  Takes an integer value  (seconds), this
>           can  bound  the  maximum  number  of attempts TCP will
>           make to complete the connection. This option should not
>           be used in code intended to be portable.

	This works properly in 2.6.31.3, I set TCP_SYNCNT=1
and TCP_DEFER_ACCEPT then only 2 SYN-ACKs are sent.

> Also, looking at ipv4/tcp.c, a retransmit counter is correctly
> computed :

	rskq_defer_accept is threshold, not counter

>         case TCP_DEFER_ACCEPT:
>                 icsk->icsk_accept_queue.rskq_defer_accept = 0;
>                 if (val > 0) {
>                         /* Translate value in seconds to number of
>                          * retransmits */
>                         while (icsk->icsk_accept_queue.rskq_defer_accept < 32 &&
>                                val > ((TCP_TIMEOUT_INIT / HZ) <<
>                                        icsk->icsk_accept_queue.rskq_defer_accept))
>                                 icsk->icsk_accept_queue.rskq_defer_accept++;
>                         icsk->icsk_accept_queue.rskq_defer_accept++;
>                 }
>                 break;
> 
> ==> rskq_defer_accept is used as a counter of retransmits.

	as limit for retransmits, not as counter

> But in tcp_minisocks.c, this counter is only checked. And in
> fact, I have found no location which updates it. So I think
> that what was intended was to decrease it in tcp_minisocks
> whenever it is checked, which the trivial patch below does.

	You can check net/ipv4/inet_connection_sock.c,
inet_csk_reqsk_queue_prune() where TCP_DEFER_ACCEPT can extend
the retransmission threshold for acked sockets above the
applied 'thresh'. So, there are 2 options:

a) TCP_DEFER_ACCEPT is used as flag (eg. 1) or the period is below
the TCP_SYNCNT period. In this case TCP_DEFER_ACCEPT does not
extend the period for DATA (DATA must come before TCP_SYNCNT).
Application is notified only when DATA comes.

or

b) TCP_DEFER_ACCEPT is set with seconds above the TCP_SYNCNT
retrans limit and the first ACK extends the period up to
TCP_DEFER_ACCEPT seconds (converted as retrans). By this
way we provide more time for DATA after the empty ACKs.
ACK again can come before TCP_SYNCNT but DATA after ACK
can come even after TCP_SYNCNT but before TCP_DEFER_ACCEPT
timeout. Again, application is notified only when DATA comes.

> Signed-off-by: Willy Tarreau <w@1wt.eu>
> ---
>  net/ipv4/tcp_minisocks.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index f8d67cc..2f676f3 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -644,6 +644,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
>  	/* If TCP_DEFER_ACCEPT is set, drop bare ACK. */
>  	if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
>  	    TCP_SKB_CB(skb)->end_seq == tcp_rsk(req)->rcv_isn + 1) {

	This is wrong considering inet_csk_reqsk_queue_prune()
and patch should not be applied except if I'm missing something:

> +		inet_csk(sk)->icsk_accept_queue.rskq_defer_accept--;
>  		inet_rsk(req)->acked = 1;
>  		return NULL;
>  	}

Regards

--
Julian Anastasov <ja@ssi.bg>
