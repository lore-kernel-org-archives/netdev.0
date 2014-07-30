From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH net-next] ipv6: addrconf: fix mcast route for GRE devices
Date: Wed, 30 Jul 2014 13:20:00 -0500
Message-ID: <1406744400.1908.20.camel@dcbw.local>
References: <1406681743-104844-1-git-send-email-equinox@diac24.net>
	 <1406733282.5122.12.camel@localhost>
	 <20140730153503.GJ801478@jupiter.n2.diac24.net>
	 <1406736567.6757.14.camel@localhost>
	 <20140730163140.GL801478@jupiter.n2.diac24.net>
	 <1406739141.6757.22.camel@localhost>
	 <20140730173544.GM801478@jupiter.n2.diac24.net>
	 <1406743380.1228508.147383982.0ACFF791@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64099 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755561AbaG3SUh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 14:20:37 -0400
In-Reply-To: <1406743380.1228508.147383982.0ACFF791@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-07-30 at 20:03 +0200, Hannes Frederic Sowa wrote:
> On Wed, Jul 30, 2014, at 19:35, David Lamparter wrote:
> > On Wed, Jul 30, 2014 at 06:52:21PM +0200, Hannes Frederic Sowa wrote:
> > > On Mi, 2014-07-30 at 18:31 +0200, David Lamparter wrote:
> > > > On Wed, Jul 30, 2014 at 06:09:27PM +0200, Hannes Frederic Sowa wrote:
> > > > [cut]
> > > > > > On Wed, Jul 30, 2014 at 05:14:42PM +0200, Hannes Frederic Sowa wrote:
> > > > > > > On Mi, 2014-07-30 at 02:55 +0200, David Lamparter wrote:
> > > > > > > > GRE devices, for some reason, were coming up with an autoconfigured
> > > > > > > > address, but no ff00::/8 route in the local table.  This breaks any kind
> > > > > > > > of multicast, in particular OSPFv3, mDNS, - and ND.  In fact, IPv6 only
> > > > > > > > works at all because there is little need for ND on PtP devices.
> > > > > > > > 
> > > > > > > > Adding any other IPv6 address on the device would rectify this issue
> > > > > > > > through inet6_addr_add()/addrconf_add_dev() - and would leave the route
> > > > > > > > around even if the address was later removed.  (This is probably why
> > > > > > > > this issue was not discovered earlier.  AFAICS it has been there from
> > > > > > > > the beginning, e.g. aee80b5 "generate link local address for GRE
> > > > > > > > tunnel")
> > > > > > > 
> > > > > > > Yep, this is poor, but changing this will break user space...
> > > > > > 
> > > > > > How exactly will this break user space?
> > > > > 
> > > > > Because the multicast routes will always be restored after e.g. a route
> > > > > flush or manual route deletion. Scripts might depend on this.
> > > > 
> > > > Sorry, I still don't get it.  Without this patch you end up in an
> > > > inconsistent state, where a LL addr exists, but multicast doesn't work
> > > > (since ff00::/8 is missing from RT6_TABLE_LOCAL).
> > > 
> > > Sure, people can remove addresses and routes at will.
> > 
> > That's not the point.
> > 
> > user manually adds address on any if: ff00::/8 added.
> > kernel link-up autoconf addr on !gre: ff00::/8 added.
> > kernel link-up autoconf addr on gre:  no ff00::/8.
> 
> Ah sorry, I am ok with your patch that we generate a ff00::/8 multicast
> route if we set a gre interface up. Getting rid of the logic, that we
> try to add the ff00::/8 on every addition of an address to an interface
> would be a change which concerns because of backward compatibility
> reasons.

With IPv6LL address generation modes (IFLA_INET6_ADDR_GEN_MODE) the
kernel might not be handling the LL address, so I'd like to keep
addrconf_add_dev() in the inet6_addr_add() codepath.  Having the
multicast route is useful/correct no matter who adds the LL address to
the interface.

I think you alluded to this earlier, but I just wanted to bring it up.

Dan

> Especially this also creates multicast routes on sit-non-ptp/isatap
> routes, which actually don't need one.
> 
> > This is about automatic kernel behaviour in device up/change
> > notifications.  The user can always shoot himself in the foot.  This is
> > the kernel shooting the user in the foot in one particular and quite
> > specific instance and without a request to do so.
> 
> Agreed.
> 
> > > > Userspace is not supposed to touch RT6_TABLE_LOCAL in general, and, the
> > > > kernel will actually refuse installing the ff00::/8 route into the local
> > > > table from userspace (because there will be other ff00::/8 routes from
> > > > other interfaces, so you get "File exists").  You can delete the route
> > > > (and thus break mcast), but not add it.  The only way to add it is to
> > > > add an address.
> > > 
> > > People really do flush the routing table.
> > 
> > This is RT6_TABLE_LOCAL.  Most people aren't even aware it exists.  And
> > even though I can't find a reference for it, my memory tells me that
> > "table local" is supposed to be under the kernel's authority.
> 
> Yep, but still provide ip -6 route flush table all, which also clears
> the local table. And I guess people depend on ff00:: multicast routes
> being inserted as soon as they add addresses.
> 
> Bye,
> Hannes
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
