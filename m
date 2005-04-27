From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: Disable queueing when carrier is lost
Date: Thu, 28 Apr 2005 09:43:59 +1000
Message-ID: <20050427234359.GB22238@gondor.apana.org.au>
References: <E1DQlsn-0005yd-00@gondolin.me.apana.org.au> <426FDF8B.1030808@tpack.net> <20050427214224.GA25325@gondor.apana.org.au> <42701FFD.5000505@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
Content-Disposition: inline
In-Reply-To: <42701FFD.5000505@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Apr 28, 2005 at 01:27:57AM +0200, Tommy Christensen wrote:
> 
> Hmm, maybe this is more common than I thought. But do any of these really
> have a problem? I.e. do they call netif_stop_queue on link down?
> That's the case I'm trying to address with the patch.

You're still assuming that the hardware will continue to drain packets
when the carrier goes off.  This may be true for a lot of NICs, but it
is certainly not universal.
 
> This is indeed possible, but hopefully you can agree that this would be
> a driver bug. As stated above, I'm not trying to solve everything. We
> have to assume some level of sanity of the drivers. E.g. for a NIC that
> stalls the TX engine on carrier off, the driver would have to flush the
> TX ring and either call netif_stop_queue or discard packets in their
> hard_start_xmit function.  At present, even such well-behaving drivers
> would hit the problem, because packets were piling up in the qdisc.

I am not saying that there is nothing to fix.  I'm simply stating
that doing it in the watchdog is not ideal for two reasons:

1) The watchdog is not always there.
2) The delay introduced by the watchdog is driver-dependent and
varies wildly.  For the purpose of shutting down the qdisc after
a carrier off we want everything to use the same delay (if we're
going to delay at all).

So instead of doing it in the watchdog, just do both actions in
the link_watch worker.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
