From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 2.6.12-rc2] bonding: partially back out dev_set_mac_address
Date: Fri, 08 Apr 2005 16:55:53 -0700
Message-ID: <200504082356.j38Ntr7k010144@death.nxdomain.ibm.com>
References: <herbert@gondor.apana.org.au>
Cc: davem@davemloft.net, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: Message from Herbert Xu <herbert@gondor.apana.org.au>
   of "Sat, 09 Apr 2005 08:16:29 +1000." <20050408221629.GA21125@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> wrote:

[...]
>The networking drivers are trying to switch over to using
>netif_carrier_ok as the interface for notification and
>monitoring of link status.  In fact, even the bonding driver
>appears to do this by default.

	Yep.  It's been that way for a couple of years, as I recall.

[...]
>In other words, it's pointless to examine netif_carrier_ok
>more often than the underlying driver timer.  The standard
>interface to monitor its status is through a netdev
>notification (NETDEV_CHANGE). That is called in process
>context by net/core/link_watch.c.

	Looking at link_watch.c, it appears that it issues events on a
one second timer, so there could be a lag of up to one second between
the time a driver does "netif_carrier_off" and the time bonding would
receive the event from link_watch.

	So, yes, it's pointless to check netif_carrier more often that
the driver updates it, but it's not pointless to check netif_carrier on
a timer if the granularity of events from link_watch is too slow (which
it appears to be for a "hot standby" type of application).

>So I'd suggest that we get rid of directly MII monitoring in
>bonding, and always use netif_carrier_ok.  Further more,
>instead of monitoring that in a timer you just move the code
>into bond_netdev_event.

	The direct MII monitor option has stayed because some drivers
update netif_carrier at fairly long intervals; the extreme example is
3c59x, which checks every 60 seconds.  For a hot standby use, even one
second is a pretty long time.

	FWIW, It's been a while since a user has reported trouble with
bonding link detection with a driver because it didn't support
netif_carrier; lately, when it comes up it's the notification interval.

	We've also not been discussing the bonding "arp monitor," which
does link integrity checking by means of detecting traffic flow across
the link(s) (generating traffic, via ARP requests, when the link is
idle).  It will trigger the same kinds of failovers that the mii monitor
does; the saving grace right now is that it doesn't currently run with
the alb/tlb modes that do the MAC address swapping from the failover.

	My other question here is how much time is there left to get
changes for this into 2.6.12?  Rearchitecting the link monitor /
failover gizmos is reasonably nontrivial; I don't know if it's feasible
to make those kind of substantial changes this late in the cycle.  So,
either 2.6.12 goes out with the potential sleep from timer / with lock,
the bonding MAC notifier change is partially backed out, the "gfp_any()"
change goes into rtnetlink.c, or some other solution that eludes me
occurs.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
