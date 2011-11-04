From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: what's in a bus_info
Date: Fri, 4 Nov 2011 23:02:06 +0000
Message-ID: <1320447726.2753.30.camel@bwh-desktop>
References: <4EB466CB.2040506@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <rusty@rustcorp.com.au>, <mst@redhat.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12566 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891Ab1KDXCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 19:02:11 -0400
In-Reply-To: <4EB466CB.2040506@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-11-04 at 15:27 -0700, Rick Jones wrote:
> ...or would an interface name smell as sweet? (as PCI bus addressing)
> 
> Is there a "standard" for what is returned in bus_info of 
> ethtool_drvinfo?  I have been very used to seeing PCI bus addressing 
> information in that field (at least as displayed by ethtool -i) and when 
> I went to "leverage how to" from other drivers, to add "native" ethtool 
> -i support to virtio_net, I ended-up with "eth0" rather than the PCI 
> information I see in lspci output and in ethtool -i against other 
> devices.  Including an emulated e1000 interface in the same kernel.
>
> What I'm doing is calling pci_name(), feeding it with to_pci_dev() from 
> the address of the struct device in the struct net_device.

to_pci_dev() just uses container_of() to find a pci_dev when you have a
pointer to the generic device structure embedded in it.  However, you're
passing a pointer to the device embedded in a net_device.  The net
device is a child of the PCI device, so you need to do:

	dev_dev = dev->dev.parent;

And you don't even have to assume that the parent is a PCI device,
because you can use the generic dev_name().

But you don't even need to this, since the ethtool core has a default
implementation that does this...

[...]
> BTW, I notice some drivers call strlcpy and some strncpy, and some even 
> call strcpy.  Is there one that is meant to be preferred over the others?

strlcpy() is preferred - if it has to truncate, it will at least leave a
null terminator, as clients may expect.  Back when drivers handled
SIOCETHTOOL directly strncpy() may have been preferable since they were
responsible for initialising the entire structure returned to
user-space.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
