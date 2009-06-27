From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH 1/4] of/mdio: Add fixed link support
Date: Sat, 27 Jun 2009 04:11:45 +0400
Message-ID: <20090627001145.GA9779@oksana.dev.rtsoft.ru>
References: <20090626222900.GA14594@oksana.dev.rtsoft.ru>
 <20090626222945.GA32487@oksana.dev.rtsoft.ru>
 <fa686aa40906261633y502f0ed2jebc58f9160c683ce@mail.gmail.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, Li Yang <leoli@freescale.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:11995 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752158AbZF0ALn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 20:11:43 -0400
Content-Disposition: inline
In-Reply-To: <fa686aa40906261633y502f0ed2jebc58f9160c683ce@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2009 at 05:33:26PM -0600, Grant Likely wrote:
> On Fri, Jun 26, 2009 at 4:29 PM, Anton
> Vorontsov<avorontsov@ru.mvista.com> wrote:
> > Currently the fixed link support is broken for all OF ethernet drivers,
> > an "OF MDIO rework" removed most of the support. Instead of re-adding
> > fixed-link stuff to the drivers, add the support to a framework, so we
> > won't duplicate any code.
> >
> > With this patch, if a node pointer is NULL, then of_phy_connect() will
> > try to find ethernet device's node, then will look for fixed-link
> > property, and if specified, it connects PHY as usual, via bus_id (fixed
> > link PHYs do not have any device tree nodes associated with them).
> >
> > Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> 
> Ugh.  I do not like this approach.  I did not intend to break fixed
> links, but I do not think that this approach is the right fix.  There
> are several problems.
> 
> I don't like the fixed.c approach of creating a dummy phy to begin
> with.  I think it is an abuse of the device model to register a dummy
> mii_bus and have dummy devices registered on it.  It is a lot of code
> for what should be a very simple thing.  In particular, if a PHY is
> not specified, then the driver should use a static link configuration.
>  This is trivial to implement in an Ethernet driver and I do not think
> the dummy phy adds anything.

Dummy PHYs add more than you think, for example you'll have to
refactor or duplicate the code that is responsible for MAC settings
for a given mode (10/100/100, duplex, pause), and you'll have to
do netif_carrier_* handling yourself.

Not a problem per se, but you'll have to address this, and you'll
have two paths in the drivers.

> It hooks into the initialization path of *all* OF enabled net drivers,
> whether it wants it or not.  ie. The MPC5200 FEC driver does not want
> it because the fixed-link property is not part of the mpc5200-fec
> binding; it uses a current-speed property instead.  'fixed-link' has
> not been agreed upon to be applicable to all Ethernet bindings, and
> I'm not convinced that the format of it won't need to be changed for
> future Ethernet bindings.  A function for parsing fixed-link should be
> a library function that a driver can choose to call out to.  It should
> not be welded into the init path.
> 
> I also think parsing the device tree at device open time (when
> of_phy_connect is usually called) is best to be avoided.  fixed-link
> parsing should really happen at probe time and the values cached IMHO.
>  It's probably not significant, but I'd like to keep device tree reads
> constrained in the cold path (driver probe time) as opposed to the hot
> (or slightly less cool) device open path.

open() time isn't a hot path at all.

> Instead, I think that each driver should be more graceful about
> missing phy pointers and the init path should call out to a fixed-link
> parser function that sets the initial link settings.  Probably less
> than 5 lines of code per driver.
> 
> I'm sorry about breaking it.  It was my fault, and I'd be happy to fix
> it if you'd like me to,

Please do.

> but I don't think that this patch is the right
> approach.

OK, fine by me if you think you can do this stuff better. :-)

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
