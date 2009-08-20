From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] ibm_newemac: emac_close() needs to call
 netif_carrier_off()
Date: Thu, 20 Aug 2009 16:02:22 +1000
Message-ID: <1250748142.10937.4.camel@pasglop>
References: <20090819210000.D56AB254211@localhost>
	 <20090819141136.74f5c266@s6510>
	 <20090819.143403.27319428.davem@davemloft.net>
	 <fc21faff0908191440p5db84f79h8bb8a73501facae1@mail.gmail.com>
	 <fc21faff0908191532i2de570a1g1a6674bf5fe64a05@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Petri Gynther <pgynther@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:34672 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752799AbZHTGC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2009 02:02:29 -0400
In-Reply-To: <fc21faff0908191532i2de570a1g1a6674bf5fe64a05@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-08-19 at 15:32 -0700, Petri Gynther wrote:
> Stephen,
> 
> I think your suggestion of adding netif_running() check to
> bond_check_dev_link() is valid and a good fix to the bonding driver.
> We can do this in a separate patch.
> 
> However, I think that the change to ibm_newemac: emac_close() is
> needed as well. ibm_newemac netdevs should not return
> netif_carrier_ok() == TRUE when they have been shut down.

Well, we definitely don't do that in sungem either, since we continue
the link polling while the interface is down... IE. interface up/down is
the data path and is orthogonal to the PHY polling in sungem. I suppose
we -could- stop the polling while the interface is down, though I think
my initial implementation did only poll the link while the interface was
up and that was causing endless problems with various laptop-net style
tools (however that was years and years ago).

Cheers,
Ben.

> On Wed, Aug 19, 2009 at 2:40 PM, Petri Gynther<pgynther@google.com> wrote:
> > I agree with David. And, that's why I propose this diff for
> > ibm_newemac driver as well.
> >
> > On Wed, Aug 19, 2009 at 2:34 PM, David Miller<davem@davemloft.net> wrote:
> >> From: Stephen Hemminger <shemminger@vyatta.com>
> >> Date: Wed, 19 Aug 2009 14:11:36 -0700
> >>
> >>> On Wed, 19 Aug 2009 14:00:00 -0700 (PDT)
> >>> Petri Gynther <pgynther@google.com> wrote:
> >>>
> >>>> When ibm_newemac netdev instance is shutdown with "ifconfig down",
> >>>> the netdev interface does not go properly down. netif_carrier_ok()
> >>>> keeps returning TRUE even after "ifconfig down".
> >>>>
> >>>> The problem can be seen when ibm_newemac instances are slaves of
> >>>> a bonding interface. The bonding interface code uses netif_carrier_ok()
> >>>> to determine the link status of its slaves. When ibm_newemac slave is
> >>>> shutdown with "ifconfig down", the bonding interface won't detect any
> >>>> link status change because netif_carrier_ok() keeps returning TRUE.
> >>>
> >>> Bonding should be testing for netif_running() && netif_carrier_ok().
> >>>
> >>> In many devices state of carrier is undefined when device is down.
> >>
> >> But if you check all of the drivers, ethernet in particular, the
> >> convention is to call netif_carrier_off() in foo_close().
> >>
> >

