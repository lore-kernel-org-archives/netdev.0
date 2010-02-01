From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3][v2] tcp: fix ICMP-RTO war: Check lower bound
Date: Sun, 31 Jan 2010 23:32:28 -0800 (PST)
Message-ID: <20100131.233228.48469829.davem@davemloft.net>
References: <4B635E1A.7040100@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: damian@tvk.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52374
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754112Ab0BAHcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2010 02:32:16 -0500
In-Reply-To: <4B635E1A.7040100@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Date: Fri, 29 Jan 2010 23:15:54 +0100

> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 34f5cc2..ff6cbaa 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -528,9 +528,12 @@ static inline void tcp_bound_rto(const struct sock *sk)
>  		inet_csk(sk)->icsk_rto = TCP_RTO_MAX;
>  }
>  
> +static inline u32 tcp_rto_min(struct sock *sk);
>  static inline u32 __tcp_set_rto(const struct tcp_sock *tp)
>  {
> -	return (tp->srtt >> 3) + tp->rttvar;
> +	u32 rto = (tp->srtt >> 3) + tp->rttvar;
> +	u32 min = tcp_rto_min((struct sock *)tp);
> +	return unlikely(rto < min) ? min : rto;
>  }
>  
>  static inline void __tcp_fast_path_on(struct tcp_sock *tp, u32 snd_wnd)

Don't make assumptions about the layout and relationships
between struct sock and struct tcp_sock without using
the interfaces create for this purpose.

For this case, simply add a "struct sock *" first argument to
__tcp_set_rto() and update the callers.

Thanks.
