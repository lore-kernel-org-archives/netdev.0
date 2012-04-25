From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next] bonding,vlan: propagate MAC failover changes to VLANs
Date: Wed, 25 Apr 2012 08:51:16 -0700
Message-ID: <32057.1335369076@death.nxdomain>
References: <10757.1334772163@death.nxdomain> <1334773079.2426.32.camel@bwh-desktop.uk.solarflarecom.com> <11643.1334774976@death.nxdomain> <1334776810.2426.44.camel@bwh-desktop.uk.solarflarecom.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:35181 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755573Ab2DYPw1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 11:52:27 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 25 Apr 2012 11:52:26 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 8B5FE6E804B
	for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 11:52:23 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3PFqKjQ123354
	for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 11:52:20 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3PFpJiJ003601
	for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 09:51:20 -0600
In-reply-to: <1334776810.2426.44.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Please do not apply this patch; we've found an alternate
solution that doesn't require this change.

Ben Hutchings <bhutchings@solarflare.com> wrote:

>On Wed, 2012-04-18 at 11:49 -0700, Jay Vosburgh wrote:
>> Ben Hutchings <bhutchings@solarflare.com> wrote:
>> 
>> >On Wed, 2012-04-18 at 11:02 -0700, Jay Vosburgh wrote:
>> >> 	With bonding's fail_over_mac=active, during failover the MAC
>> >> address of the bond itself changes to match that of the slave.
>> >> 
>> >> 	This patch adds a notifier call to cause VLANs stacked atop the
>> >> bonding to also change their MAC addresses to the new address when a
>> >> failover occurs.
>> >> 
>> >> 	While it is legal for a VLAN to have a MAC address that differs
>> >> from the underlying device, at least one device (qeth) that requires the
>> >> use of fail_over_mac for bonding cannot handle the VLAN's MAC differing
>> >> from that of the bond; thus, it needs the MAC change to propagate up
>> >> to any VLANs when fail_over_mac is set to active.
>> >[...]
>> >
>> >This doesn't make sense to me.  You're applying the behaviour to all
>> >VLANs on top of a bond, whether or not the underlying device is driven
>> >by qeth, and ignoring any MAC address changes that don't involve the
>> >bonding driver.
>> 
>> 	With the patch, the PROPAGATE event is only generated if bonding
>> is set for fail_over_mac=active, which is normally only enabled on those
>> devices that require it (some devices for IBM's pseries and zseries
>> architectures and Infiniband, which doesn't have VLANs).
>
>Yeah, OK, that makes sense.
>
>> 	Devices that do not use bonding's fail_over_mac will not have
>> VLANs following MAC changes.
>
>I take it that the devices with this limitation on source MAC address
>have an essentially unchangeable MAC address?  If they are limited to
>single address but it's changeable then they should be emitting this
>notification too.

	It's not that it can't change the MAC, the issue has to do with
the packet forwarding logic on the actual device that services the
various virtual devices configured on the LPARs.  This being s390, it's
not quite that simple, but that's the short version.

>> >I think either of these would be better fixes:
>> >1. Make VLAN devices follow changes to the parent device's MAC address
>> >unless they are assigned an address of their own.
>> >2. Add a configuration flag for VLAN devices to follow changes to the
>> >parent device's MAC address.
>> 
>> 	#1 would be a behavior change for all VLAN devices, which I
>> sought to avoid.
>> 
>> 	#2 would be an additional configuration option that would have
>> to be enabled just for this case (unless VLANs following MAC changes of
>> the parent device is a generally desirable feature).
>
>I don't know whether it is generally desirable.  My guess would be that
>unless a VLAN device is explicitly configured to use its own address
>then it is desirable.
>
>> The patch requires
>> no additional option settings beyond what are currently in use.
>
>Right, I understand that this ought to Just Work, if possible.
>
>Ben.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
