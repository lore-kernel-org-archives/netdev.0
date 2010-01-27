From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: fix ICMP-RTO war
Date: Wed, 27 Jan 2010 14:41:56 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1001260957540.17103@melkinpaasi.cs.helsinki.fi>
References: <alpine.DEB.2.00.1001240007530.16552@melkinpaasi.cs.helsinki.fi> <201001240045.52846.denys@visp.net.lb> <4B5DB3BF.1080409@tvk.rwth-aachen.de> <20100125.234557.00486980.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: damian@tvk.rwth-aachen.de, denys@visp.net.lb,
	Netdev <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52812 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753936Ab0A0Ml5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 07:41:57 -0500
In-Reply-To: <20100125.234557.00486980.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Jan 2010, David Miller wrote:

> From: Damian Lukowski <damian@tvk.rwth-aachen.de>
> Date: Mon, 25 Jan 2010 16:07:43 +0100
> 
> > @@ -530,7 +530,11 @@ static inline void tcp_bound_rto(const struct sock *sk)
> >  
> >  static inline u32 __tcp_set_rto(const struct tcp_sock *tp)
> >  {
> > -	return (tp->srtt >> 3) + tp->rttvar;
> > +	u32 rto = (tp->srtt >> 3) + tp->rttvar;
> > +	if (unlikely(rto < TCP_RTO_MIN))
> > +		return TCP_RTO_MIN;
> > +	else
> > +		return rto;
> >  }
> 
> The min RTO is now a runtime variable, TCP_RTO_MIN is merely the
> default, so we should use tcp_rto_min() for obtaining that value.
> 
> And if we make this change, we might want to delete the comment in
> tcp_set_rto() which claims:
> 
> 	/* NOTE: clamping at TCP_RTO_MIN is not required, current algo
> 	 * guarantees that rto is higher.
> 	 */
> 	tcp_bound_rto(sk);
> 
> And we have shown here at least one case where that is not true.
> :-)

I went through some history, it seems that this comment about the lower 
bound originates from Alexey [1]:

commit 893e1302654a9bcdc0e7d9ac95159657a8f5e0e8
Author: davem <davem>
Date:   Wed Dec 13 04:10:12 2000 +0000

    Fix numerous RTO bugs.
    Withdraw CWR when DSACKs are seen.
    Do not allow recvmsg on unbound socket, it is
    senseless.

    All from Alexey.


> I've looked at Denys's traces and your analysis, and I still
> can't figure out who the true culprit is that lets us get into
> such a state that RTO is evaluated so low...



-- 
 i.

[1] http://git.kernel.org/?p=linux/kernel/git/davem/netdev-vger-cvs.git;a=commit;h=893e1302654a9bcdc0e7d9ac95159657a8f5e0e8
