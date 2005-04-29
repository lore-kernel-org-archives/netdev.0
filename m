From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: Disable queueing when carrier is lost
Date: Sat, 30 Apr 2005 09:45:12 +1000
Message-ID: <20050429234512.GA22699@gondor.apana.org.au>
References: <E1DQlsn-0005yd-00@gondolin.me.apana.org.au> <426FDF8B.1030808@tpack.net> <20050427214224.GA25325@gondor.apana.org.au> <42701FFD.5000505@tpack.net> <20050427234359.GB22238@gondor.apana.org.au> <1114768308.4695.1487.camel@tsc-6.cph.tpack.net> <20050429101836.GA2237@gondor.apana.org.au> <1114777355.4695.1598.camel@tsc-6.cph.tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
Content-Disposition: inline
In-Reply-To: <1114777355.4695.1598.camel@tsc-6.cph.tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 29, 2005 at 02:22:36PM +0200, Tommy Christensen wrote:
> 
> Calling dev->open instead of dev_open leads to this.  Probably that
> shouldn't be allowed anyway.  But since it doesn't hurt us here, I'd

That's definitely not allowed.

> rather settle for a WARN_ON.

Fine by me.

> > > +	if (!netif_carrier_ok(dev) && netif_queue_stopped(dev))
> > > +		/* Delay activation until next carrier-on event */
> > > +		return;
> > 
> > How about moving this check into dev_open?
> 
> But that would indeed leave qdisc_sleeping set to noop_qdisc, wouldn't
> it?  Besides, I wanted to catch qdisc changes done by tc as well.

You're right.  However, the netif_queue_stopped check doesn't make sense.
If the queue isn't stopped, you'd be leaving the qdisc open which means
that it can fill up later on.  Remember the problem is not just with NIC
drivers stopping the queue explicitly, some NICs simply won't process the
TX rings when the carrier is off.

The other concern I have is that this code can call dev_activate
or dev_deactivate twice in a row.  As far as I can tell this is
harmless for the moment but it would be nice if we can avoid it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
