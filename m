From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH net-next] ipv6: addrconf: fix mcast route for GRE devices
Date: Wed, 30 Jul 2014 18:31:40 +0200
Message-ID: <20140730163140.GL801478@jupiter.n2.diac24.net>
References: <1406681743-104844-1-git-send-email-equinox@diac24.net>
 <1406733282.5122.12.camel@localhost>
 <20140730153503.GJ801478@jupiter.n2.diac24.net>
 <1406736567.6757.14.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:59846 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753921AbaG3Qb5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 12:31:57 -0400
Content-Disposition: inline
In-Reply-To: <1406736567.6757.14.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 30, 2014 at 06:09:27PM +0200, Hannes Frederic Sowa wrote:
[cut]
> > On Wed, Jul 30, 2014 at 05:14:42PM +0200, Hannes Frederic Sowa wrote:
> > > On Mi, 2014-07-30 at 02:55 +0200, David Lamparter wrote:
> > > > GRE devices, for some reason, were coming up with an autoconfigured
> > > > address, but no ff00::/8 route in the local table.  This breaks any kind
> > > > of multicast, in particular OSPFv3, mDNS, - and ND.  In fact, IPv6 only
> > > > works at all because there is little need for ND on PtP devices.
> > > > 
> > > > Adding any other IPv6 address on the device would rectify this issue
> > > > through inet6_addr_add()/addrconf_add_dev() - and would leave the route
> > > > around even if the address was later removed.  (This is probably why
> > > > this issue was not discovered earlier.  AFAICS it has been there from
> > > > the beginning, e.g. aee80b5 "generate link local address for GRE
> > > > tunnel")
> > > 
> > > Yep, this is poor, but changing this will break user space...
> > 
> > How exactly will this break user space?
> 
> Because the multicast routes will always be restored after e.g. a route
> flush or manual route deletion. Scripts might depend on this.

Sorry, I still don't get it.  Without this patch you end up in an
inconsistent state, where a LL addr exists, but multicast doesn't work
(since ff00::/8 is missing from RT6_TABLE_LOCAL).

Userspace is not supposed to touch RT6_TABLE_LOCAL in general, and, the
kernel will actually refuse installing the ff00::/8 route into the local
table from userspace (because there will be other ff00::/8 routes from
other interfaces, so you get "File exists").  You can delete the route
(and thus break mcast), but not add it.  The only way to add it is to
add an address.

Not changing this behaviour keeps breaking userspace;  ospf6d among
other things assumes an interface has working IPv6 when a link-local
address is present.


-David
