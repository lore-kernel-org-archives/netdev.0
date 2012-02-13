From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [BUG?] bonding, slave selection, carrier loss, etc.
Date: Mon, 13 Feb 2012 12:37:29 -0800
Message-ID: <10446.1329165449@death.nxdomain>
References: <49CD5B93.7010407@nortel.com> <31087.1238198438@death.nxdomain.ibm.com> <4F35AC78.3010907@genband.com> <28766.1328925233@death.nxdomain> <1328986371.325.7.camel@deadeye> <4F39539B.5060507@genband.com> <20120213104810.158d714a@nehalam.linuxnetplumber.net> <1329164644.2697.49.camel@bwh-desktop>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Chris Friesen <chris.friesen@genband.com>, andy@greyhouse.net,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:37370 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757987Ab2BMUhy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 15:37:54 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Mon, 13 Feb 2012 15:37:52 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id C364138C8076
	for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 15:37:36 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1DKba9H224568
	for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 15:37:36 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1DKbWMd017618
	for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 15:37:34 -0500
In-reply-to: <1329164644.2697.49.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> wrote:

>On Mon, 2012-02-13 at 10:48 -0800, Stephen Hemminger wrote:
>> On Mon, 13 Feb 2012 12:16:59 -0600
>> Chris Friesen <chris.friesen@genband.com> wrote:
>> 
>> > On 02/11/2012 12:52 PM, Ben Hutchings wrote:
>> > > On Fri, 2012-02-10 at 17:53 -0800, Jay Vosburgh wrote:
>> > >> Chris Friesen<chris.friesen@genband.com>  wrote:
>> > 
>> > >>> The best solution would be for bonding to just register for notification
>> > >>> of the link going down.  Presumably most drivers should be doing that
>> > >>> properly by now, and for devices that get interrupt-driven notification
>> > >>> of link status changes this would allow the bonding code to react much
>> > >>> quicker.
>> > >>
>> > >> 	A quick look at some drivers shows that at least acenic still
>> > >> doesn't do netif_carrier_off, so converting entirely to a notifier-based
>> > >> failover mechanism would break drivers that work today.
>> > > [...]
>> > >
>> > > It might be worth having some sort of feature flag (in priv_flags) that
>> > > indicates whether the driver updates the link state.  Alternately,
>> > > disable polling of a device once you see a notification.
>> 
>> Just fix the drivers to update link state.
>> The whole mii polling method of bonding is really leftover from the era of
>> 10 years ago when network drivers were stupid and didn't handle carrier.
>
>Lots of hardware doesn't generate link interrupts.  Our SFC4000 was
>supposed to generate events for link changes, but this didn't work
>reliably and so we poll regularly in the driver.  I think the older
>drivers fail to update carrier because of similar hardware limitations.
>
>If you want to remove link polling from the bonding driver then it has
>to live *somewhere*.  Rather than requiring every affected driver to
>implement the timer or delayed work item, I would suggest you put that
>in the networking core and then require drivers to either provide a link
>polling function or specify that they don't require polling.  Then
>export the obvious implementations using ethtool or MII so that drivers
>don't have to replicate those.

	I think it's probably better all around to leave the miimon
(link polling) stuff in bonding alone for those drivers that need it,
and then add a notifier check that will do link down/up on demand if the
particular device does netif_carrier (which will be the majority).

	If bonding is running miimon and gets a notifier from a driver,
then it can stop the polling (as Ben suggests).  For the usual case
(drivers that support netif_carrier), this will be right after the
device is enslaved, because devices are enslaved in a down state and are
set administratively up as part of the enslavement process.

	The only tricky bits are:

	- insuring that the arp monitor and the notifiers don't conflict
if there is disagreement about the link state and cause flapping of the
perceived link state.

	- handling drivers like 3c59x that do their own handling, but
run on a very long poll in the driver (5 seconds for 3c59x).  I suspect
that if use_carrier=0 is set in bonding, then continuing to run the
miimon poll would handle this for most devices (because use_carrier=0
instructs bonding to check the device mii registers rather than relying
on the driver to set carrier).  If use_carrier=0 doesn't work, then
bonding wouldn't detect a link change any faster than the driver is
reporting it anyway.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
