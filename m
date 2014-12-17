From: Dan Williams <dcbw@redhat.com>
Subject: Re: Question about phys_port_id
Date: Wed, 17 Dec 2014 10:47:06 -0600
Message-ID: <1418834826.1160.35.camel@dcbw.local>
References: <CAEPrYjTZ8SU1y4TwKHYtZju+4_-O5mazAjaFKaKmR2cYuAKHnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joshua Watt <jpewdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59272 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751240AbaLQQrJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2014 11:47:09 -0500
In-Reply-To: <CAEPrYjTZ8SU1y4TwKHYtZju+4_-O5mazAjaFKaKmR2cYuAKHnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-12-17 at 10:09 -0600, Joshua Watt wrote:
> Hello,
> 
> I had a question regarding the phys_port_id attribute of net_device.
> Is that identifier supposed to be globally unique or just unique among
> devices that share a common device? For example, we have a single
> device that create two net_device s (one for each of it's macs). Would

Do the two net_device's share hardware or firmware resources?  Can they
be used independently at maximum capability, or when both are in use do
they have degraded capability?

> it be sufficient for this device to return a phys_port_id of 0 for the
> first net_device and 1 for the second? I noticed that the other

If the two netdevs share resources, then they should have the *same*
phys_port_id.  If they do not have the same physical hardware or shared
resources and are completely independent from each other at all levels,
then you can either skip phy_port_id altogether.

One good use for this (and why it was originally added) was to indicate
to userspace that it was pointless to bond two interfaces with the same
underlying hardware or resources, because that totally defeats the
purpose of both failover and aggregation.

> implementations that use phys_port_id copy their mac address into the
> phys_port_id, but I'm not sure if that is just because that is an easy
> way to get a unique number or if it is because the ID needs to be
> globally unique.

Say you have two netdevs that share the same hardware or resources.  You
assign them both a phys_port_id of "1" to indicate this.  What if
there's a second cpsw device on the system, do both of its netdevs also
get "1", or "2", or?  Or how about a card from another vendor, how do
you ensure that your device's phys_port_id won't conflict with that
vendor's device/driver?

That's why most drivers currently use the MAC address or a GUID.

Dan

> If you're wondering the driver in question is the TI cpsw driver
> (drivers/net/ethernet/ti/cpsw.c). We are running the device in
> dual-emac mode and need to uniquely identify which emac is which in
> userspace (specifically, udev rules). The physical port identifier
> seems to be the logical choice to me, but I'm not sure if I'm missing
> something.
> 
> Thanks,
> Joshua Watt
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
