From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Can we remove pci_find_device() yet?
Date: Tue, 12 Jan 2010 20:53:25 +0000
Message-ID: <1263329605.3011.8.camel@achroite.uk.solarflarecom.com>
References: <20100108112236.462a3da2.sfr@canb.auug.org.au>
	 <20100108044646.GC6611@suse.de> <4B4B802A.2010709@imap.cc>
	 <20100111200136.GA29955@suse.de>  <m3fx6bxdt7.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@suse.de>, Tilman Schmidt <tilman@imap.cc>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:9762 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944Ab0ALUx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 15:53:29 -0500
In-Reply-To: <m3fx6bxdt7.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-01-12 at 21:34 +0100, Krzysztof Halasa wrote:
> Greg KH <gregkh@suse.de> writes:
> 
> > Close, but if you do this, please name the function
> > hisax_find_pci_device() or something, and change the drivers to use it
> > instead.  Also put a big fat warning in the function that calling this
> > is unsafe for any PCI hotplug type machine.
> 
> BTW, I have a driver in the works which uses these functions, and I
> wonder how to do it correctly. The problem is that the hardware is a
> dual-function PCI card (two DEC Tulip Ethernet controllers) but part of
> the first device (EEPROM interface or something like that) is used by
> both (there is an FPGA connected there, serving both channels).
> 
> This means drivers for dev#0 and dev#1 (both "normal" PCI controllers)
> need to register and access part of dev#0 BARs.

I hope you realise that this is a design error!  Linux is fairly
forgiving and allows PCI drivers to do unusual things, but other OSes
make it hard or impossible for PCI drivers to coordinate multiple
functions.

> How do I do that properly, in terms of PCI API?

One of our older controllers had a similar design error in that the two
functions would sometimes have to be reset together.  The way we look
for the second function is:

	dev = pci_dev_get(dev1);
	while ((dev = pci_get_device(vendor_id, device_id, dev))) {
		if (dev->bus == dev1->bus &&
		    dev->devfn == dev1->devfn + 1) {
			dev2 = dev;
			break;
		}
	}

I assume this is 'properly' since no-one has told me otherwise.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

