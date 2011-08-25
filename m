From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [BUG] tcp : how many times a frame can possibly be retransmitted
 ?
Date: Thu, 25 Aug 2011 11:56:58 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1108251150050.12780@wel-95.cs.helsinki.fi>
References: <1314202918.2296.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <alpine.DEB.2.00.1108250142030.11551@melkinpaasi.cs.helsinki.fi> <1314226834.6797.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-252263359-1314262619=:12780"
Cc: netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>,
	Damian Lukowski <damian@tvk.rwth-aachen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60313 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135Ab1HYI5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 04:57:00 -0400
In-Reply-To: <1314226834.6797.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-252263359-1314262619=:12780
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Thu, 25 Aug 2011, Eric Dumazet wrote:

> Le jeudi 25 août 2011 à 01:44 +0300, Ilpo Järvinen a écrit :
> > On Wed, 24 Aug 2011, Eric Dumazet wrote:
> > 
> > > On one dev machine running net-next, I just found strange tcp sessions
> > > that retransmit a frame forever (The other peer disappeared)
> > > 
> > > # ss -emoi dst 10.2.1.1
> > > State      Recv-Q Send-Q      Local Address:Port          Peer Address:Port   
> > > ESTAB      0      816              10.2.1.2:37930             10.2.1.1:ssh      timer:(on,630ms,246) ino:60786 sk:ffff8801189aa400
> > > 	 mem:(r0,w3776,f320,t0) ts sack ecn cubic wscale:8,6 rto:1680 rtt:16.25/7.5 ato:40 ssthresh:7 send 1.4Mbps rcv_rtt:10 rcv_space:16632
> > > 
> > > 
> > > You can see the retransmit count : 246 
> > > 
> > > What possibly can be going on ?
> > > 
> > > What happened to backoff ?
> > 
> > But RTO (even without any backoffs) should be lower bounded to some not so 
> > zeroish value?
> 
> Apparently not.
> 
> The only thing that protect us from a flood is that ip_error() uses
> inetpeer cache to ratelimit the icmp_send(ICMP_DEST_UNREACH)
> 
> This is why we get retransmit period >= 1 sec
>
> vi +432 net/ipv4/tcp_ipv4.c
> 
>                 icsk->icsk_backoff--;
>                 inet_csk(sk)->icsk_rto = (tp->srtt ? __tcp_set_rto(tp) :
>                         TCP_TIMEOUT_INIT) << icsk->icsk_backoff;
>                 tcp_bound_rto(sk);
> 
> and __tcp_set_rto() uses : return (tp->srtt >> 3) + tp->rttvar;

So you think that this is not true: ?

        /* NOTE: clamping at TCP_RTO_MIN is not required, current algo
         * guarantees that rto is higher.
         */

...it would still be smaller than 1sec though, but certainly not going to 
cause flooding either. Default tcp_rto_min should be 200ms so it's 
5pkts+5ICMP sent, received and processed per second. Which doesn't sound 
that bad CPU load?!?

It is unclear to me how tp->rttvar could become smaller than 
tcp_rto_min().

-- 
 i.
--8323329-252263359-1314262619=:12780--
