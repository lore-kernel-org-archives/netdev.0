From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6.12-rc2] bonding: partially back out dev_set_mac_address
Date: Sat, 9 Apr 2005 08:16:29 +1000
Message-ID: <20050408221629.GA21125@gondor.apana.org.au>
References: <E1DJsiq-0006xJ-00@gondolin.me.apana.org.au> <200504082059.j38KwhaG009173@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200504082059.j38KwhaG009173@death.nxdomain.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 08, 2005 at 01:58:43PM -0700, Jay Vosburgh wrote:
> 
> 	There are several paths from a timer context, e.g.,
> 
> timer -> bond_mii_monitor -> bond_change_active_slave ->
> bond_alb_handle_active_change -> alb_set_slave_mac_addr

Is that what it's for.  I sense an opportunity for you to
greatly clean up this section of code :)

The networking drivers are trying to switch over to using
netif_carrier_ok as the interface for notification and
monitoring of link status.  In fact, even the bonding driver
appears to do this by default.

When you're using netif_carrier_ok, you're relying on the
driver itself to monitor the physical status.  It will usually
do so in its own timer.

In other words, it's pointless to examine netif_carrier_ok
more often than the underlying driver timer.  The standard
interface to monitor its status is through a netdev
notification (NETDEV_CHANGE). That is called in process
context by net/core/link_watch.c.

So I'd suggest that we get rid of directly MII monitoring in
bonding, and always use netif_carrier_ok.  Further more,
instead of monitoring that in a timer you just move the code
into bond_netdev_event.

> 	As I said above, the timer case doesn't have an obviously good
> way to change it to do the MAC sets in a sleepable context with no
> locks.  I also wonder how expensive it is to run work queue events every
> 10ms as compared to running timer events every 10ms?

If you really want to keep monitoring the MII status directly, then
you can still schedule the changing of the MAC address via a work
queue.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
