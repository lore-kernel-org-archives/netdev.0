From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: addrconf: fix mcast route for GRE devices
Date: Wed, 30 Jul 2014 18:52:21 +0200
Message-ID: <1406739141.6757.22.camel@localhost>
References: <1406681743-104844-1-git-send-email-equinox@diac24.net>
	 <1406733282.5122.12.camel@localhost>
	 <20140730153503.GJ801478@jupiter.n2.diac24.net>
	 <1406736567.6757.14.camel@localhost>
	 <20140730163140.GL801478@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:49714 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754454AbaG3QwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 12:52:23 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway1.nyi.internal (Postfix) with ESMTP id 32201239C7
	for <netdev@vger.kernel.org>; Wed, 30 Jul 2014 12:52:23 -0400 (EDT)
In-Reply-To: <20140730163140.GL801478@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mi, 2014-07-30 at 18:31 +0200, David Lamparter wrote:
> On Wed, Jul 30, 2014 at 06:09:27PM +0200, Hannes Frederic Sowa wrote:
> [cut]
> > > On Wed, Jul 30, 2014 at 05:14:42PM +0200, Hannes Frederic Sowa wrote:
> > > > On Mi, 2014-07-30 at 02:55 +0200, David Lamparter wrote:
> > > > > GRE devices, for some reason, were coming up with an autoconfigured
> > > > > address, but no ff00::/8 route in the local table.  This breaks any kind
> > > > > of multicast, in particular OSPFv3, mDNS, - and ND.  In fact, IPv6 only
> > > > > works at all because there is little need for ND on PtP devices.
> > > > > 
> > > > > Adding any other IPv6 address on the device would rectify this issue
> > > > > through inet6_addr_add()/addrconf_add_dev() - and would leave the route
> > > > > around even if the address was later removed.  (This is probably why
> > > > > this issue was not discovered earlier.  AFAICS it has been there from
> > > > > the beginning, e.g. aee80b5 "generate link local address for GRE
> > > > > tunnel")
> > > > 
> > > > Yep, this is poor, but changing this will break user space...
> > > 
> > > How exactly will this break user space?
> > 
> > Because the multicast routes will always be restored after e.g. a route
> > flush or manual route deletion. Scripts might depend on this.
> 
> Sorry, I still don't get it.  Without this patch you end up in an
> inconsistent state, where a LL addr exists, but multicast doesn't work
> (since ff00::/8 is missing from RT6_TABLE_LOCAL).

Sure, people can remove addresses and routes at will.

> Userspace is not supposed to touch RT6_TABLE_LOCAL in general, and, the
> kernel will actually refuse installing the ff00::/8 route into the local
> table from userspace (because there will be other ff00::/8 routes from
> other interfaces, so you get "File exists").  You can delete the route
> (and thus break mcast), but not add it.  The only way to add it is to
> add an address.

People really do flush the routing table.

I'll have a look why the addition of the multicast route throws an
error.

> Not changing this behaviour keeps breaking userspace;  ospf6d among
> other things assumes an interface has working IPv6 when a link-local
> address is present.

Yeah, but in the end, people also can drop specific packets and we
cannot do anything.

Bye,
Hannes
