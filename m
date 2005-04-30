From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] net: Disable queueing when carrier is lost
Date: Sat, 30 Apr 2005 14:57:12 +0200
Message-ID: <427380A8.2070006@tpack.net>
References: <E1DQlsn-0005yd-00@gondolin.me.apana.org.au> <426FDF8B.1030808@tpack.net> <20050427214224.GA25325@gondor.apana.org.au> <42701FFD.5000505@tpack.net> <20050427234359.GB22238@gondor.apana.org.au> <1114768308.4695.1487.camel@tsc-6.cph.tpack.net> <20050429101836.GA2237@gondor.apana.org.au> <1114777355.4695.1598.camel@tsc-6.cph.tpack.net> <20050429234512.GA22699@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050429234512.GA22699@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> You're right.  However, the netif_queue_stopped check doesn't make sense.
> If the queue isn't stopped, you'd be leaving the qdisc open which means
> that it can fill up later on.  Remember the problem is not just with NIC
> drivers stopping the queue explicitly, some NICs simply won't process the
> TX rings when the carrier is off.

I know. I've given this a lot of thought already - and failed to come
up with a solution for everything.

Regarding the sort of NICs you mention, I came to the conclusion that
we shouldn't try to fix this in the stack. They indicate that they can
take more packets (by NOT calling netif_stop_queue), so we should obey
this and leave it to the drivers to handle things, e.g. by dropping the
packets if needed. Otherwise we deprive the drivers the option of
maintaining their tx_carrier_errors statistics, for instance. And,
theoretically, a driver could even depend on having its hard_start_xmit
invoked in order to kickstart its TX engine.

As stated earlier: if a driver holds on to packets "indefinitely", it
is buggy. This should be fixed, rather than the core having to jump
through loops trying to remedy things.

So, I am reluctant to drop this check for netif_queue_stopped. Doing so
would needlessly impact the drivers that work fine already (or at least
should be handling this situation).

> The other concern I have is that this code can call dev_activate
> or dev_deactivate twice in a row.  As far as I can tell this is
> harmless for the moment but it would be nice if we can avoid it.

Agreed, this isn't ideal. However, if this is the only downside, it
is something that I'd be happy to live with. I don't see any easy
way to avoid it.

Ideas, anyone?


-Tommy
