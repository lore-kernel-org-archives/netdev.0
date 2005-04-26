From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6.12-rc2] bonding: partially back out dev_set_mac_address
Date: Tue, 26 Apr 2005 21:18:45 +1000
Message-ID: <20050426111845.GA8968@gondor.apana.org.au>
References: <20050426011907.GA13846@gondor.apana.org.au> <200504260411.j3Q4BYke004030@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200504260411.j3Q4BYke004030@death.nxdomain.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Apr 25, 2005 at 09:11:33PM -0700, Jay Vosburgh wrote:
> 
> 	There's a path in the "old" link monitor that does an
> SIOCGMIIREG ioctl to read the PHY registers directly; the handler
> functions typically do a copy_from_user sort of thing, and there's some
> segment switching magic done in bonding because it's calling from the
> timer.  It will give warnings if DEBUG_SPINLOCK_SLEEP is on and the
> bonding "use_carrier=0" is supplied (to turn off netif_carrier detection
> and use the MII inspection).  There's an IOCTL macro in bonding.h that
> does the nasty parts.

Indeed.  But how can this stuff work at all? Surely if use_carrier is
disabled while miimon is enabled we should get a dead-lock as soon as
this call chain is run:

dev_ioctl => bond_enslave => bond_check_dev_link => slave_dev->ioctl

So either nobody ever uses this setup or I'm missing something :)
 
> >The timers would be converted to delayed work.
> 
> 	It is better, performance-wise, to run the "main" part of the
> link monitoring in a timer, and then call out to a work queue only for
> those operations that need a context?  I.e., how expensive are work
> queues compared to timers?

For the amount of work that these timers are doing, the overhead is
pretty small.  It is also gentler on the system when the CPU load
goes up.

> 	I've been thinking in terms of rearranging the monitor system to
> have, essentially, one or more "inspectors" that check link state, and a
> single "executor" that makes link up/down decisions based on input from
> the "inspectors."  The "executor" (or perhaps one of its minions, if the
> executor itself is a timer for performance reasons) would be the work
> queue piece, as it would be doing the actual swapping around.

This sounds good.  One thing to watch out for though is that you need
to drop the bond lock between the inspector and the executor.  This
is so that the executor can acquire the rtnl.  The only other alternative
would be to always hold the rtnl.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
