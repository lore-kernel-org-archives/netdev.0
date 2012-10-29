From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] tcp: better retrans tracking for defer-accept
Date: Mon, 29 Oct 2012 11:21:31 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1210291000140.1692@ja.ssi.bg>
References: <1351238750-13611-1-git-send-email-subramanian.vijay@gmail.com>  <1351339032.30380.222.camel@edumazet-glaptop>  <alpine.LFD.2.00.1210271556250.1628@ja.ssi.bg>  <1351344725.30380.286.camel@edumazet-glaptop>  <1351347537.30380.315.camel@edumazet-glaptop>
  <alpine.LFD.2.00.1210272324020.1628@ja.ssi.bg>  <1351415713.30380.398.camel@edumazet-glaptop>  <alpine.LFD.2.00.1210281657050.9279@ja.ssi.bg> <1351454568.30380.630.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	netdev@vger.kernel.org, ncardwell@google.com,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Elliott Hughes <enh@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:49633 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751664Ab2J2JVq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 05:21:46 -0400
In-Reply-To: <1351454568.30380.630.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sun, 28 Oct 2012, Eric Dumazet wrote:

> On Sun, 2012-10-28 at 18:51 +0200, Julian Anastasov wrote:
> 
> > 	The idea is:
> > 
> > - expire request_sock as before, based on num_timeout with
> > the idea to catch many SYN retransmissions and to reduce
> > SYN-ACK rate from 2*SYN_rate to 1*SYN_rate, up to
> > tcp_synack_retries SYN-ACKs
> > 
> > - num_retrans accounts sent SYN-ACKs, they can be sent in
> > response to SYN retr or from timer. If num_retrans increases
> > faster than num_timeout it means client uses lower
> > TCP_TIMEOUT_INIT value and sending SYN-ACKs from
> > tcp_check_req is enough because we apply tcp_synack_retries
> > once as a SYN-ACK limit and second time as expiration
> > period.
> > 
> > - If we get 10 SYNs in 1 second, we will send 5 SYN-ACKs
> > immediately (will be restricted in tcp_check_req), from
> > second +1 to +31 we will not send SYN-ACKs if
> > tcp_synack_retries is reached, we will wait for ACK and
> > for more SYNs to drop, silently. Finally, at +63 we expire
> > the request_sock. inet_csk_reqsk_queue_prune still
> > can reduce the expiration period (thresh value) under load.
> > 
> > 	Of course, this is material for separate patch,
> > if idea is liked at all.
> > 
> > Regards
> 
> On a SYNFLOOD attack, we end up sending one SYNACK per SYN message
> anyway ?

	I assume you are referring to want_cookie set by
tcp_syn_flood_action

> If we want to address a non SYNFLOOD attack, why not resetting
> req->expire when we send a SYNACK to a retransmitted SYN ?
> 
> tcp_check_req()
> ...
> 	if (!inet_rtx_syn_ack(sk, req)) {
> 		req->expire = jiffies +
> 			min(TCP_TIMEOUT_INIT << req->num_timeout,
> 			    TCP_RTO_MAX);
> 	}

	This is a good trick, only that it affects the
TCP_DEFER_ACCEPT timing, num_timeout will be increased
in different time.

	But your example reveals another place where
we can optimize: time_after_eq(now, req->expires)
check in inet_csk_reqsk_queue_prune() is immune to
the thresh reduction on load, we do not touch for long
periods of time entries with num_timeout above the desired
thresh. May be we have to use:

time_after_eq(now, req->expires) ||
(req->num_timeout > thresh && !inet_rsk(req)->acked)

	for immediate expire of requests before end of
current period because they already exceed the threshold.
We avoid it only for defer_accept entries with received ACK.
But such checks are not cheap if most of the time we are
not under load.

Regards

--
Julian Anastasov <ja@ssi.bg>
