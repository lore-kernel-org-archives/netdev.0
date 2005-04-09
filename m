From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6.12-rc2] bonding: partially back out dev_set_mac_address
Date: Sat, 9 Apr 2005 10:21:37 +1000
Message-ID: <20050409002137.GA21726@gondor.apana.org.au>
References: <20050408221629.GA21125@gondor.apana.org.au> <200504082356.j38Ntr7k010144@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200504082356.j38Ntr7k010144@death.nxdomain.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 08, 2005 at 04:55:53PM -0700, Jay Vosburgh wrote:
>
> 	Looking at link_watch.c, it appears that it issues events on a
> one second timer, so there could be a lag of up to one second between
> the time a driver does "netif_carrier_off" and the time bonding would
> receive the event from link_watch.

Events are delivered immediately except when there are multiple failures
within a second.  Even then it will delay the subsequent failures only
if they occured after the queue run has already started.

Remember that whenever the queue run does trigger, it will update all
devices that's on the linked list.

We can easily change this to do something different if it really
bothers you.

> 	The direct MII monitor option has stayed because some drivers
> update netif_carrier at fairly long intervals; the extreme example is
> 3c59x, which checks every 60 seconds.  For a hot standby use, even one
> second is a pretty long time.

Wouldn't it be better to modify those drivers so that they updated
their status more frequently? That way everybody would benefit and
not just bonding.
 
> 	We've also not been discussing the bonding "arp monitor," which
> does link integrity checking by means of detecting traffic flow across
> the link(s) (generating traffic, via ARP requests, when the link is
> idle).  It will trigger the same kinds of failovers that the mii monitor
> does; the saving grace right now is that it doesn't currently run with
> the alb/tlb modes that do the MAC address swapping from the failover.

The ARP monitor would presumably start changing MAC addresses only after
a longish timeout.  In that event, I don't see any problems with delaying
it a little bit more by putting it into a work queue.

> 	My other question here is how much time is there left to get
> changes for this into 2.6.12?  Rearchitecting the link monitor /
> failover gizmos is reasonably nontrivial; I don't know if it's feasible
> to make those kind of substantial changes this late in the cycle.  So,
> either 2.6.12 goes out with the potential sleep from timer / with lock,
> the bonding MAC notifier change is partially backed out, the "gfp_any()"
> change goes into rtnetlink.c, or some other solution that eludes me
> occurs.

It's up to Dave of course.

Personally I'd rather we aimed for a proper solution that will be in
2.6.13 since the current symptom is only a warning which doesn't
really hurt anyone.

After all, we have lived with this problem for years so a few more
weeks can't be fatal :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
