From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [BUG?] bonding, slave selection, carrier loss, etc.
Date: Mon, 13 Feb 2012 20:24:04 +0000
Message-ID: <1329164644.2697.49.camel@bwh-desktop>
References: <49CD5B93.7010407@nortel.com>
	 <31087.1238198438@death.nxdomain.ibm.com> <4F35AC78.3010907@genband.com>
	 <28766.1328925233@death.nxdomain> <1328986371.325.7.camel@deadeye>
	 <4F39539B.5060507@genband.com>
	 <20120213104810.158d714a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chris Friesen <chris.friesen@genband.com>,
	Jay Vosburgh <fubar@us.ibm.com>, <andy@greyhouse.net>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:21382 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757957Ab2BMUYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 15:24:09 -0500
In-Reply-To: <20120213104810.158d714a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-02-13 at 10:48 -0800, Stephen Hemminger wrote:
> On Mon, 13 Feb 2012 12:16:59 -0600
> Chris Friesen <chris.friesen@genband.com> wrote:
> 
> > On 02/11/2012 12:52 PM, Ben Hutchings wrote:
> > > On Fri, 2012-02-10 at 17:53 -0800, Jay Vosburgh wrote:
> > >> Chris Friesen<chris.friesen@genband.com>  wrote:
> > 
> > >>> The best solution would be for bonding to just register for notification
> > >>> of the link going down.  Presumably most drivers should be doing that
> > >>> properly by now, and for devices that get interrupt-driven notification
> > >>> of link status changes this would allow the bonding code to react much
> > >>> quicker.
> > >>
> > >> 	A quick look at some drivers shows that at least acenic still
> > >> doesn't do netif_carrier_off, so converting entirely to a notifier-based
> > >> failover mechanism would break drivers that work today.
> > > [...]
> > >
> > > It might be worth having some sort of feature flag (in priv_flags) that
> > > indicates whether the driver updates the link state.  Alternately,
> > > disable polling of a device once you see a notification.
> 
> Just fix the drivers to update link state.
> The whole mii polling method of bonding is really leftover from the era of
> 10 years ago when network drivers were stupid and didn't handle carrier.

Lots of hardware doesn't generate link interrupts.  Our SFC4000 was
supposed to generate events for link changes, but this didn't work
reliably and so we poll regularly in the driver.  I think the older
drivers fail to update carrier because of similar hardware limitations.

If you want to remove link polling from the bonding driver then it has
to live *somewhere*.  Rather than requiring every affected driver to
implement the timer or delayed work item, I would suggest you put that
in the networking core and then require drivers to either provide a link
polling function or specify that they don't require polling.  Then
export the obvious implementations using ethtool or MII so that drivers
don't have to replicate those.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
