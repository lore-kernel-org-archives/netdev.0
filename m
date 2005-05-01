From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: Disable queueing when carrier is lost
Date: Sun, 1 May 2005 18:11:40 +1000
Message-ID: <20050501081140.GA20647@gondor.apana.org.au>
References: <E1DQlsn-0005yd-00@gondolin.me.apana.org.au> <426FDF8B.1030808@tpack.net> <20050427214224.GA25325@gondor.apana.org.au> <42701FFD.5000505@tpack.net> <20050427234359.GB22238@gondor.apana.org.au> <1114768308.4695.1487.camel@tsc-6.cph.tpack.net> <20050429101836.GA2237@gondor.apana.org.au> <1114777355.4695.1598.camel@tsc-6.cph.tpack.net> <20050429234512.GA22699@gondor.apana.org.au> <427380A8.2070006@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
Content-Disposition: inline
In-Reply-To: <427380A8.2070006@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Tommy:

I agree with you now that your patch is the best way to go.

On Sat, Apr 30, 2005 at 02:57:12PM +0200, Tommy Christensen wrote:
>
> Regarding the sort of NICs you mention, I came to the conclusion that
> we shouldn't try to fix this in the stack. They indicate that they can
> take more packets (by NOT calling netif_stop_queue), so we should obey
> this and leave it to the drivers to handle things, e.g. by dropping the
> packets if needed. Otherwise we deprive the drivers the option of
> maintaining their tx_carrier_errors statistics, for instance. And,
> theoretically, a driver could even depend on having its hard_start_xmit
> invoked in order to kickstart its TX engine.

We should document this so that NIC drivers are told about this.  Any
NICs that can't process their TX rings while the carrier is off needs
to stop their queue just before calling netif_carrier_off.
 
> So, I am reluctant to drop this check for netif_queue_stopped. Doing so
> would needlessly impact the drivers that work fine already (or at least
> should be handling this situation).

I don't see how those drivers are worse off without this check.  When
the carrier is off it doesn't really matter whether we're sending them
packets or not.  Besides, you didn't put this check in the link_watch
code path which would affect them a lot more than this path.

> >The other concern I have is that this code can call dev_activate
> >or dev_deactivate twice in a row.  As far as I can tell this is
> >harmless for the moment but it would be nice if we can avoid it.
> 
> Agreed, this isn't ideal. However, if this is the only downside, it
> is something that I'd be happy to live with. I don't see any easy
> way to avoid it.
> 
> Ideas, anyone?

You mean how we can avoid the double call? Here is one way.  Move
the setting of IF_RUNNING out of dev_get_flags and into dev_activate.
This would guarantee that IF_RUNNING is set iff the device has a qdisc.
Assuming that you remove the aformentioned netif_queue_stopped check,
the device has a qdisc iff the carrier is on.  So this preserves the
meaning of IF_RUNNING.

Now you can avoid the double call by returning early in dev_activate if
IF_RUNNING is set, and in dev_deactivate if IF_RUNNING is not set.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
