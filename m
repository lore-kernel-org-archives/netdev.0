From: Julian Anastasov <ja@ssi.bg>
Subject: Re: IP fragmentation broken in 3.6-rc ?
Date: Tue, 21 Aug 2012 19:34:07 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1208211815550.2149@ja.ssi.bg>
References: <CAF6-1L6DTXPGi4kbcPqbOXrrafMmZ6K1QdcAa=PxJBzZWkvojg@mail.gmail.com>  <1345555336.5158.493.camel@edumazet-glaptop> <1345560131.5158.500.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sylvain Munaut <s.munaut@whatever-company.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:57325 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756147Ab2HUQcR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2012 12:32:17 -0400
In-Reply-To: <1345560131.5158.500.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 21 Aug 2012, Eric Dumazet wrote:

> Following patch should help :
> 
> diff --git a/include/net/dst.h b/include/net/dst.h
> index 621e351..a04aa37 100644
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -435,7 +435,7 @@ static inline void dst_set_expires(struct dst_entry *dst, int timeout)
>  	if (expires == 0)
>  		expires = 1;
>  

	In theory, restart of PMTUD should not lead to
fatal problems, we will get new MTUs. But with such
change should be better, not much, because all MTU
events will come at same time, later timer will expire
and we will get again events from routers. The gain
will be an increased period (with milliseconds to seconds)
between PMTUD restarts. Compared to the 600-second timer,
this should be gain below 1% in reduced traffic for PMTUD.
Before now we started timer from first router, now we
will start/update timer period after event from last router.

	But ipv4_link_failure and ip6_link_failure want to stop
this timer by setting it to NOW (0). May be we have to add
also a !timeout check here or to leave the code as before?

> -	if (dst->expires == 0 || time_before(expires, dst->expires))
> +	if (dst->expires == 0 || time_after(expires, dst->expires))
>  		dst->expires = expires;
>  }

	The original problem should be somewhere else, I think.

Regards

--
Julian Anastasov <ja@ssi.bg>
