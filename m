From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: what's in a bus_info
Date: Fri, 4 Nov 2011 23:42:47 +0000
Message-ID: <1320450167.2753.39.camel@bwh-desktop>
References: <4EB466CB.2040506@hp.com> <1320447726.2753.30.camel@bwh-desktop>
	 <4EB475CC.1000601@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <rusty@rustcorp.com.au>, <mst@redhat.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:16797 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290Ab1KDXmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 19:42:52 -0400
In-Reply-To: <4EB475CC.1000601@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-11-04 at 16:31 -0700, Rick Jones wrote:
> On 11/04/2011 04:02 PM, Ben Hutchings wrote:
> > On Fri, 2011-11-04 at 15:27 -0700, Rick Jones wrote:
> >> ...or would an interface name smell as sweet? (as PCI bus addressing)
> >>
> >> Is there a "standard" for what is returned in bus_info of
> >> ethtool_drvinfo?  I have been very used to seeing PCI bus addressing
> >> information in that field (at least as displayed by ethtool -i) and when
> >> I went to "leverage how to" from other drivers, to add "native" ethtool
> >> -i support to virtio_net, I ended-up with "eth0" rather than the PCI
> >> information I see in lspci output and in ethtool -i against other
> >> devices.  Including an emulated e1000 interface in the same kernel.
> >>
> >> What I'm doing is calling pci_name(), feeding it with to_pci_dev() from
> >> the address of the struct device in the struct net_device.
> >
> > to_pci_dev() just uses container_of() to find a pci_dev when you have a
> > pointer to the generic device structure embedded in it.  However, you're
> > passing a pointer to the device embedded in a net_device.  The net
> > device is a child of the PCI device, so you need to do:
> >
> > 	dev_dev = dev->dev.parent;
> >
> > And you don't even have to assume that the parent is a PCI device,
> > because you can use the generic dev_name().
> >
> > But you don't even need to this, since the ethtool core has a default
> > implementation that does this...
> 
> Yes, I noticed that.  For a little while I was confused because ethtool 
> -i was emitting something even before I added a ".get_drvinfo" - though 
> what it ends-up returning in my case is "virtio0." Which is also what I 
> get if I take the path through the virtio_device to the struct device 
> therein instead of the path through the struct net_device alone.
> 
> I guess that wraps back around to the question of whether there is a 
> "standard" for what should be in bus_info.  And if it is impractical to 
> get the PCI bus information,

I'm not that familiar with virtio, but would I be right in thinking that
the virtio 'bus' device is likely to be the child of a PCI device?  So
then you mgiht want to get bus_name() for the grandparent of the net
device:
	dev_dev = dev->dev.parent->parent;
(possibly checking for nulls).

If there's some reasonable way to distinguish a 'real' from a virtual
bus then we could have the generic implementation try to follow parents
until it finds a bus device.  However I think the device model
maintainers have been gradually moving away from the bus/class
distinction and so we may not be able to do that.

> whether it is better to return virtioN or 
> ethN.  Or perhaps something else entirely.
[...]

Returning the device name seems entirely unhelpful since the user
already has that.  'virtioN' is perhaps not much better though.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
