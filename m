From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix ICMP-RTO war
Date: Mon, 25 Jan 2010 23:45:57 -0800 (PST)
Message-ID: <20100125.234557.00486980.davem@davemloft.net>
References: <alpine.DEB.2.00.1001240007530.16552@melkinpaasi.cs.helsinki.fi>
	<201001240045.52846.denys@visp.net.lb>
	<4B5DB3BF.1080409@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: damian@tvk.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42313
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752730Ab0AZHpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 02:45:45 -0500
In-Reply-To: <4B5DB3BF.1080409@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Date: Mon, 25 Jan 2010 16:07:43 +0100

> @@ -530,7 +530,11 @@ static inline void tcp_bound_rto(const struct sock *sk)
>  
>  static inline u32 __tcp_set_rto(const struct tcp_sock *tp)
>  {
> -	return (tp->srtt >> 3) + tp->rttvar;
> +	u32 rto = (tp->srtt >> 3) + tp->rttvar;
> +	if (unlikely(rto < TCP_RTO_MIN))
> +		return TCP_RTO_MIN;
> +	else
> +		return rto;
>  }

The min RTO is now a runtime variable, TCP_RTO_MIN is merely the
default, so we should use tcp_rto_min() for obtaining that value.

And if we make this change, we might want to delete the comment in
tcp_set_rto() which claims:

	/* NOTE: clamping at TCP_RTO_MIN is not required, current algo
	 * guarantees that rto is higher.
	 */
	tcp_bound_rto(sk);

And we have shown here at least one case where that is not true.
:-)

I've looked at Denys's traces and your analysis, and I still
can't figure out who the true culprit is that lets us get into
such a state that RTO is evaluated so low...
