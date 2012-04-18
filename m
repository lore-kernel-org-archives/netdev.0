From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] bonding,vlan: propagate MAC failover changes
 to VLANs
Date: Wed, 18 Apr 2012 20:20:10 +0100
Message-ID: <1334776810.2426.44.camel@bwh-desktop.uk.solarflarecom.com>
References: <10757.1334772163@death.nxdomain>
	 <1334773079.2426.32.camel@bwh-desktop.uk.solarflarecom.com>
	 <11643.1334774976@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:22821 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754573Ab2DRTUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 15:20:14 -0400
In-Reply-To: <11643.1334774976@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-18 at 11:49 -0700, Jay Vosburgh wrote:
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
> >On Wed, 2012-04-18 at 11:02 -0700, Jay Vosburgh wrote:
> >> 	With bonding's fail_over_mac=active, during failover the MAC
> >> address of the bond itself changes to match that of the slave.
> >> 
> >> 	This patch adds a notifier call to cause VLANs stacked atop the
> >> bonding to also change their MAC addresses to the new address when a
> >> failover occurs.
> >> 
> >> 	While it is legal for a VLAN to have a MAC address that differs
> >> from the underlying device, at least one device (qeth) that requires the
> >> use of fail_over_mac for bonding cannot handle the VLAN's MAC differing
> >> from that of the bond; thus, it needs the MAC change to propagate up
> >> to any VLANs when fail_over_mac is set to active.
> >[...]
> >
> >This doesn't make sense to me.  You're applying the behaviour to all
> >VLANs on top of a bond, whether or not the underlying device is driven
> >by qeth, and ignoring any MAC address changes that don't involve the
> >bonding driver.
> 
> 	With the patch, the PROPAGATE event is only generated if bonding
> is set for fail_over_mac=active, which is normally only enabled on those
> devices that require it (some devices for IBM's pseries and zseries
> architectures and Infiniband, which doesn't have VLANs).

Yeah, OK, that makes sense.

> 	Devices that do not use bonding's fail_over_mac will not have
> VLANs following MAC changes.

I take it that the devices with this limitation on source MAC address
have an essentially unchangeable MAC address?  If they are limited to
single address but it's changeable then they should be emitting this
notification too.

> >I think either of these would be better fixes:
> >1. Make VLAN devices follow changes to the parent device's MAC address
> >unless they are assigned an address of their own.
> >2. Add a configuration flag for VLAN devices to follow changes to the
> >parent device's MAC address.
> 
> 	#1 would be a behavior change for all VLAN devices, which I
> sought to avoid.
> 
> 	#2 would be an additional configuration option that would have
> to be enabled just for this case (unless VLANs following MAC changes of
> the parent device is a generally desirable feature).

I don't know whether it is generally desirable.  My guess would be that
unless a VLAN device is explicitly configured to use its own address
then it is desirable.

> The patch requires
> no additional option settings beyond what are currently in use.

Right, I understand that this ought to Just Work, if possible.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
