From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: Disable queueing when carrier is lost
Date: Fri, 29 Apr 2005 20:18:36 +1000
Message-ID: <20050429101836.GA2237@gondor.apana.org.au>
References: <E1DQlsn-0005yd-00@gondolin.me.apana.org.au> <426FDF8B.1030808@tpack.net> <20050427214224.GA25325@gondor.apana.org.au> <42701FFD.5000505@tpack.net> <20050427234359.GB22238@gondor.apana.org.au> <1114768308.4695.1487.camel@tsc-6.cph.tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
Content-Disposition: inline
In-Reply-To: <1114768308.4695.1487.camel@tsc-6.cph.tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 29, 2005 at 11:51:48AM +0200, Tommy Christensen wrote:
> 
> Originally, I was afraid it could get too trigger happy, so I left
> this idea. Perhaps that's not such a big deal afterall.

Even if it does flap we've still got the built-in one second
flap-protection of link_watch.

> How does this look?

Much better :)

> @@ -74,6 +75,12 @@
>  		clear_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state);
>  
>  		if (dev->flags & IFF_UP) {
> +			if (netif_carrier_ok(dev)) {
> +				if (dev->qdisc_sleeping != &noop_qdisc)
> +					dev_activate(dev);

I don't see how qdisc_sleeping can be noop_qdisc unless there is a bug.
So why not convert this to a BUG_ON?

> diff -ru linux-2.6.12-rc3/net/sched/sch_generic.c linux-2.6.12-work/net/sched/sch_generic.c
> --- linux-2.6.12-rc3/net/sched/sch_generic.c	2005-03-04 09:55:44.000000000 +0100
> +++ linux-2.6.12-work/net/sched/sch_generic.c	2005-04-29 11:22:05.420250195 +0200
> @@ -539,6 +539,10 @@
>  		write_unlock_bh(&qdisc_tree_lock);
>  	}
>  
> +	if (!netif_carrier_ok(dev) && netif_queue_stopped(dev))
> +		/* Delay activation until next carrier-on event */
> +		return;

How about moving this check into dev_open?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
