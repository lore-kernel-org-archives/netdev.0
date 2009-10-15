From: Julian Anastasov <ja@ssi.bg>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Fri, 16 Oct 2009 01:44:34 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0910152257410.3047@u.domain.uli>
References: <20091014045226.GA15655@1wt.eu> <Pine.LNX.4.58.0910140912420.2714@u.domain.uli>
 <20091014201706.GA24298@1wt.eu> <20091014.154349.83940908.davem@davemloft.net>
 <20091015060834.GB29564@1wt.eu> <Pine.LNX.4.58.0910151120340.2879@u.domain.uli>
 <20091015124134.GB1073@1wt.eu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:59087 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762340AbZJOWo1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2009 18:44:27 -0400
In-Reply-To: <20091015124134.GB1073@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 15 Oct 2009, Willy Tarreau wrote:

> Hello Julian,
> 
> On Thu, Oct 15, 2009 at 11:47:51AM +0300, Julian Anastasov wrote:
> (...)
> > 	If one changes TCP_DEFER_ACCEPT to create socket it
> > will save wakeups but not resources. I'm wondering if the
> > behavior should be changed at all. For me the options are two:
> > 
> > a) you want to save resources: use TCP_DEFER_ACCEPT. To help
> > proxies use large values for TCP_SYNCNT and TCP_DEFER_ACCEPT.
> > 
> > b) you can live with wakeups and many sockets: do not use
> > TCP_DEFER_ACCEPT. Suitable for servers using short timeouts
> > for first request.
> 
> and c) you want to avoid wakeups as much as possible and you'd like
> to drop just one empty ACK packet, so that as soon as you accept a
> an HTTP connection, you can read the request without polling at all.
> 
> Right now I'm able to process a complete HTTP request without
> registering the any FD in epoll *at all* for most requests if the first
> two ACKs are close enough and the server responds quickly. This saves a
> substantial amount of CPU cycles. Epoll is fast, but calling epoll_ctl()
> 100000 times a second still has a measurable cost. Doing an accept() on
> an empty connection implies this cost. Waiting for data always saves this
> cost, but causes the undesirable side effects that have been reported.
> Waiting for data just a few milliseconds is enough to save this cost
> 99.99% of the time, just as skipping the first empty packet.
> 
> Since you're saying that updating the value is wrong when it's used as
> a flag, would a patch to implement a specific option for this usage be
> accepted ?  Either by passing a negative value to TCP_DEFER_ACCEPT, or
> by using another flag ?

	Sorry for the long mail ...

	I was not clear enough in previous email. Your goal
is to decrease period per client while the actually decreased
threshold is on the listener's socket. 256 conns will be enough
to completely disable TCP_DEFER_ACCEPT on the listener (u8). I'm not
sure that you tested what happens after Nth client (where
N matches your TCP_DEFER_ACCEPT value as retransmissions), do you
still see accept deferring for next clients? Now if your patch
is applied the deferring will be disabled soon after server start.

	The open requests are just 64 bytes for me:
cat /proc/slabinfo | grep request_sock_TCP
and there is no rskq_defer_accept flag in struct tcp_request_sock,
struct inet_request_sock or struct request_sock. It is
present only for normal sockets. These open connection
requests have only 'retrans' and 'acked' flag. Please,
check again what your patch does and test it with some simple
client that sleeps after connect().

	As for new flags, may be we should not change
TCP_DEFER_ACCEPT values because current applications can
depend on it. There is some free space in
struct request_sock_queue just after u8 rskq_defer_accept.
May be new flags/modes can go there to define another
behavior but it means also changes in applications to support
it.

	Because using TCP_DEFER_ACCEPT as flag is not documented
one solution can be the following change, may be it matches your
idea but implemented correctly:

        /* If TCP_DEFER_ACCEPT is set, drop bare ACK. */
-       if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
+       if (req->retrans < inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
            TCP_SKB_CB(skb)->end_seq == tcp_rsk(req)->rcv_isn + 1) {
                inet_rsk(req)->acked = 1;
                return NULL;
        }

	with the meaning "When TCP_DEFER_ACCEPT retransmission
period is shorter than SYN-ACK retrans period (eg. TCP_SYNCNT
or sysctl_tcp_synack_retries) move the open request as
established on client's packet after the TCP_DEFER_ACCEPT
period has expired". Then if you set TCP_SYNCNT=5 and
TCP_DEFER_ACCEPT=1retrans first ACK will set inet_rsk(req)->acked=1
because req->retrans is 0 and rskq_defer_accept is 1,
later timer will send one SYN-ACK (which marks the end
of TCP_DEFER_ACCEPT period), then client will send DATA or it
will be forced by our SYN-ACK retransmission to send 2nd
ACK packet for which we will create established socket.

	Such change will affect all servers that use
TCP_DEFER_ACCEPT retransmissions less than TCP_SYNCNT. They
will start to see wakeups without data after the TCP_DEFER_ACCEPT
period.

	To summarize:

SECOND	CLIENT			SERVER
---------------------------------------------------------
0	SYN			SYN-ACK
	if DATA => ESTABLISH
	if ACK => acked=1
3				SYN-ACK (set retrans=1)
	if ACK and TCP_DEFER_ACCEPT=1retrans => ESTABLISH
	if DATA => ESTABLISH
	if ACK => acked=1
9				if TCP_SYNCNT=1 => expire
				else SYN-ACK (set retrans=2)
	if ACK and TCP_DEFER_ACCEPT=2retrans => ESTABLISH
	if DATA => ESTABLISH
	if ACK => acked=1
...

PRO:

- if TCP_DEFER_ACCEPT<TCP_SYNCNT and client properly resends
ACK on every SYN-ACK retransmission then we always will
switch to established state on TCP_DEFER_ACCEPT expiration.
Such conns will never expire in SYN_RECV state. They
will be terminated by client's FIN or will be accepted
by server application and terminated properly. Of course,
there is some chance if client delays its ACKs or if SYN-ACK
is lost the open request to expire in SYN_RECV state.

CON:

- if client refuses to send DATA we still need these SYN-ACKs
to trigger ACK retransmissions from client because the only
way to switch to established state is when packet is received,
I don't know how TCP_DEFER_ACCEPT expiration can directly change
the open request to established state.

	May be it is possible to send first SYN-ACK and
if one ACK is received to send more SYN-ACKs after
TCP_DEFER_ACCEPT period expires. Then client still has chance
to send ACK or DATA that will switch open request to established
socket. So, our timer will be silent when acked=1 while
TCP_DEFER_ACCEPT period is active, for example:

SYN
	SYN-ACK
ACK
	...
	acked=1 => no SYN-ACKs retrans (assume they are sent and lost)
	...
	TCP_DEFER_ACCEPT expires => send 2nd SYN-ACK
	... If no client's ACK then resend SYN-ACK while retrans<TCP_SYNCNT
	...
ACK or DATA => ESTABLISHED

	This will need little change in inet_csk_reqsk_queue_prune()
but it saves SYN-ACK traffic during deferring period in the
common case when client sends ACK. If such compromise is
acceptable I can prepare and test some patch.

Regards

--
Julian Anastasov <ja@ssi.bg>
