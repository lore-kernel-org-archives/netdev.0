From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH net-next] ipv6: addrconf: fix mcast route for GRE devices
Date: Wed, 30 Jul 2014 17:35:03 +0200
Message-ID: <20140730153503.GJ801478@jupiter.n2.diac24.net>
References: <1406681743-104844-1-git-send-email-equinox@diac24.net>
 <1406733282.5122.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:59053 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754842AbaG3PfW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 11:35:22 -0400
Content-Disposition: inline
In-Reply-To: <1406733282.5122.12.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(New patch following in separate mail - I haven't touched
addrconf_sit_config since I have no clue about ISATAP & the likes.)

On Wed, Jul 30, 2014 at 05:14:42PM +0200, Hannes Frederic Sowa wrote:
> On Mi, 2014-07-30 at 02:55 +0200, David Lamparter wrote:
> > GRE devices, for some reason, were coming up with an autoconfigured
> > address, but no ff00::/8 route in the local table.  This breaks any kind
> > of multicast, in particular OSPFv3, mDNS, - and ND.  In fact, IPv6 only
> > works at all because there is little need for ND on PtP devices.
> > 
> > Adding any other IPv6 address on the device would rectify this issue
> > through inet6_addr_add()/addrconf_add_dev() - and would leave the route
> > around even if the address was later removed.  (This is probably why
> > this issue was not discovered earlier.  AFAICS it has been there from
> > the beginning, e.g. aee80b5 "generate link local address for GRE
> > tunnel")
> 
> Yep, this is poor, but changing this will break user space...

How exactly will this break user space?

> > (Note: multicast is supported on GRE devices of all kinds, including PtP
> > GRE, P-t-Mcast GRE and NBMA-GRE.)
> > 
> > Fixes: aee80b54b235 (ipv6: generate link local address for GRE tunnel)
> > Signed-off-by: David Lamparter <equinox@diac24.net>
> > Cc: Stephen Hemminger <stephen@networkplumber.org>
> 
> We should install routes before joining LL, I would go with
> 
>         idev = addrconf_add_dev(dev);
>         if (IS_ERR(idev))
>                 return;
> 
> in addrconf_gre_config etc.

Well, yeah, to be honest I have no clue why these functions are
separated as they are.  Once fixed up, the only difference between
addrconf_gre_config and addrconf_dev_config is the true/false value on
prefix_route for addrconf_addr_gen...  and what the rationale for that
is, I can only consult an oracle for.

How about pushing the switch(dev->type) down from addrconf_notify into
addrconf_dev_config()?

> Looks like we don't correctly configure ARPHRD_IP6GRE gre tunnels...

IP6GRE doesn't currently auto-generate a link-local address at all, is
that what you meant?  (Yeah we could/should add that too...)


-David
