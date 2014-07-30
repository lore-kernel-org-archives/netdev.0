From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: addrconf: fix mcast route for GRE devices
Date: Wed, 30 Jul 2014 18:09:27 +0200
Message-ID: <1406736567.6757.14.camel@localhost>
References: <1406681743-104844-1-git-send-email-equinox@diac24.net>
	 <1406733282.5122.12.camel@localhost>
	 <20140730153503.GJ801478@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:60304 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753705AbaG3QJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 12:09:30 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway1.nyi.internal (Postfix) with ESMTP id 55DCC2341C
	for <netdev@vger.kernel.org>; Wed, 30 Jul 2014 12:09:29 -0400 (EDT)
In-Reply-To: <20140730153503.GJ801478@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mi, 2014-07-30 at 17:35 +0200, David Lamparter wrote:
> (New patch following in separate mail - I haven't touched
> addrconf_sit_config since I have no clue about ISATAP & the likes.)

isatap shouldn't use multicast and afaik output path does block
multicast tx. sit in non-ptp mainly depends on 2002:: or 6rd prefix and
drops others packets. sit-ptp can use multicast.

> 
> On Wed, Jul 30, 2014 at 05:14:42PM +0200, Hannes Frederic Sowa wrote:
> > On Mi, 2014-07-30 at 02:55 +0200, David Lamparter wrote:
> > > GRE devices, for some reason, were coming up with an autoconfigured
> > > address, but no ff00::/8 route in the local table.  This breaks any kind
> > > of multicast, in particular OSPFv3, mDNS, - and ND.  In fact, IPv6 only
> > > works at all because there is little need for ND on PtP devices.
> > > 
> > > Adding any other IPv6 address on the device would rectify this issue
> > > through inet6_addr_add()/addrconf_add_dev() - and would leave the route
> > > around even if the address was later removed.  (This is probably why
> > > this issue was not discovered earlier.  AFAICS it has been there from
> > > the beginning, e.g. aee80b5 "generate link local address for GRE
> > > tunnel")
> > 
> > Yep, this is poor, but changing this will break user space...
> 
> How exactly will this break user space?

Because the multicast routes will always be restored after e.g. a route
flush or manual route deletion. Scripts might depend on this.

> > > (Note: multicast is supported on GRE devices of all kinds, including PtP
> > > GRE, P-t-Mcast GRE and NBMA-GRE.)
> > > 
> > > Fixes: aee80b54b235 (ipv6: generate link local address for GRE tunnel)
> > > Signed-off-by: David Lamparter <equinox@diac24.net>
> > > Cc: Stephen Hemminger <stephen@networkplumber.org>
> > 
> > We should install routes before joining LL, I would go with
> > 
> >         idev = addrconf_add_dev(dev);
> >         if (IS_ERR(idev))
> >                 return;
> > 
> > in addrconf_gre_config etc.
> 
> Well, yeah, to be honest I have no clue why these functions are
> separated as they are.  Once fixed up, the only difference between
> addrconf_gre_config and addrconf_dev_config is the true/false value on
> prefix_route for addrconf_addr_gen...  and what the rationale for that
> is, I can only consult an oracle for.

Basically this is a slalom run to keep exisisting behaviour and clean up
the code a little bit.

> How about pushing the switch(dev->type) down from addrconf_notify into
> addrconf_dev_config()?
> 
> > Looks like we don't correctly configure ARPHRD_IP6GRE gre tunnels...
> 
> IP6GRE doesn't currently auto-generate a link-local address at all, is
> that what you meant?  (Yeah we could/should add that too...)

Exactly. 

Thanks,
Hannes
