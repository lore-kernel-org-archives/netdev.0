From: Simon Kirby <sim@hostway.ca>
Subject: Re: [3.1] Divide by zero in __tcp_select_window()
Date: Wed, 16 Nov 2011 11:54:19 -0800
Message-ID: <20111116195419.GE24411@hostway.ca>
References: <20111108205411.GA23642@hostway.ca> <1320787405.26025.10.camel@edumazet-laptop> <20111114.153608.2064552703690099046.davem@davemloft.net> <1321304216.2719.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, tglx@linutronix.de,
	netdev@vger.kernel.org, a.p.zijlstra@chello.nl,
	linux-kernel@vger.kernel.org, davej@redhat.com,
	schwidefsky@de.ibm.com, mingo@elte.hu
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1321304216.2719.23.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 14, 2011 at 09:56:56PM +0100, Eric Dumazet wrote:

> Le lundi 14 novembre 2011 ?? 15:36 -0500, David Miller a ??crit :
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Tue, 08 Nov 2011 22:23:25 +0100
> > 
> > > OK, it seems we let a timer running while we free the socket (same error
> > > path than your previous bug report, because of the NULL route)
> > > 
> > > We arm this keepalive timer in tcp_create_openreq_child()
> > > 
> > > net/ipv4/tcp_minisocks.c:513
> > > 	if (sock_flag(newsk, SOCK_KEEPOPEN))
> > > 		inet_csk_reset_keepalive_timer(newsk,
> > > 			keepalive_time_when(newtp));
> > > 
> > > I would try to add a call to tcp_clear_xmit_timers() as well
> > > 
> > > Please try following patch :
> > 
> > We've been waiting quite some time to get some testing validation on
> > this patch, but I think it's correct.
> > 
> > Eric can you formally submit this?  Thanks!
> 
> Sure, here it is.
> 
> Please Simon feel free to add your "Tested-by" signature 
> 
> Thanks

Looks good, thanks! Working on ~25 boxes without issue for >36 hours.

Simon-

Tested-by: Simon Kirby <sim@hostway.ca>

> [PATCH] tcp: clear xmit timers in tcp_v4_syn_recv_sock()
> 
> Simon Kirby reported divides by zero errors in __tcp_select_window()
> 
> This happens when inet_csk_route_child_sock() returns a NULL pointer :
> 
> We free new socket while we eventually armed keepalive timer in
> tcp_create_openreq_child()
> 
> Fix this by a call to tcp_clear_xmit_timers()
> 
> [ This is a followup to commit 918eb39962dff (net: add missing
> bh_unlock_sock() calls) ]
> 
> Reported-by: Simon Kirby <sim@hostway.ca>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/ipv4/tcp_ipv4.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index a744315..a9db4b1 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1510,6 +1510,7 @@ exit:
>  	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
>  	return NULL;
>  put_and_exit:
> +	tcp_clear_xmit_timers(newsk);
>  	bh_unlock_sock(newsk);
>  	sock_put(newsk);
>  	goto exit;
> 
> 
