From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: Re: "x86: allocate space within a region top-down" causes bar0 access issue
Date: Fri, 17 Dec 2010 17:17:54 -0700
Message-ID: <201012171717.55300.bjorn.helgaas@hp.com>
References: <20101217194457.GA4470@exar.com> <201012171316.12761.bjorn.helgaas@hp.com> <20101217231210.GH4622@exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>
To: Jon Mason <jon.mason@exar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:18738 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753645Ab0LRAXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 19:23:15 -0500
In-Reply-To: <20101217231210.GH4622@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, December 17, 2010 04:12:11 pm Jon Mason wrote:
> On Fri, Dec 17, 2010 at 12:16:12PM -0800, Bjorn Helgaas wrote:
> > On Friday, December 17, 2010 12:44:58 pm Jon Mason wrote:
> > > The following patch is causing problem with the vxge driver/adapter on
> > > HP x86-64 systems. Reads to bar0 to return 0xffffffffffffffff instead
> > > of their intended value.  This prevents the vxge module from loading
> > > by failing sanity checks in the driver for certain values in bar0.  We
> > > are not seeing any issues with this patch on non-HP systems in our
> > > lab.
> > >
> > > Can this patch be removed from 2.6.37 until a better solution can be
> > > found?
> >
> > There were several issues related to that patch, and it's about to
> > be reverted.  I am curious about the failure you're seeing, though,
> > and I'd like to understand the cause and make sure it's one of the
> > issues I've already investigated.
> >
> > Can you send me the complete dmesg log of a failing boot?
> 
> Below is the dmesg of a failing system.

Thanks.  This is interesting.  All the reported PCI windows are below 4GB:

> ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
> pci_root PNP0A08:00: host bridge window [io  0x0000-0x0bff]
> pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff]
> pci_root PNP0A08:00: host bridge window [mem 0x000a0000-0x000bffff]
> pci_root PNP0A08:00: host bridge window [mem 0x000d0000-0x000dffff]
> pci_root PNP0A08:00: host bridge window [mem 0xf0000000-0xffffffff]

But the BIOS configured many devices *above* 4GB (and they probably
work fine there), so we complain about them, zero out their resources,
then think they conflict with some PNP devices (which they really
don't):

> pci 0000:00:1f.3: reg 10: [mem 0xffffffc00-0xffffffcff 64bit]
> pci 0000:05:00.0: reg 10: [mem 0xfff000000-0xfff7fffff 64bit pref]
> pci 0000:05:00.0: reg 18: [mem 0xfffcfe000-0xfffcfffff 64bit pref]
> pci 0000:05:00.0: reg 20: [mem 0xfffcfc000-0xfffcfdfff 64bit pref]
> pci 0000:00:06.0: PCI bridge to [bus 05-05]
> pci 0000:00:06.0:   bridge window [mem 0xfff000000-0xfffcfffff 64bit pref]
> pci 0000:00:1c.0: PCI bridge to [bus 09-0b]
> pci 0000:00:1c.0:   bridge window [mem 0xfffd00000-0xfffefffff 64bit pref]
> pci 0000:0b:04.0: reg 10: [mem 0xfffef8000-0xfffefffff 64bit pref]
> pci 0000:0b:04.0: reg 18: [mem 0xfffd00000-0xfffdfffff 64bit pref]
> pci 0000:0b:04.0: reg 20: [mem 0xfffef7800-0xfffef7fff 64bit pref]
> pci 0000:09:00.0: PCI bridge to [bus 0b-0b]
> pci 0000:09:00.0:   bridge window [mem 0xfffd00000-0xfffefffff 64bit pref]
...
> pci 0000:00:06.0: no compatible bridge window for [mem 0xfff000000-0xfffcfffff 64bit pref]
> pci 0000:00:1c.0: no compatible bridge window for [mem 0xfffd00000-0xfffefffff 64bit pref]
> pci 0000:09:00.0: no compatible bridge window for [mem 0xfffd00000-0xfffefffff 64bit pref]
> pci 0000:00:1f.3: no compatible bridge window for [mem 0xffffffc00-0xffffffcff 64bit]
> pci 0000:05:00.0: no compatible bridge window for [mem 0xfff000000-0xfff7fffff 64bit pref]
> pci 0000:05:00.0: no compatible bridge window for [mem 0xfffcfe000-0xfffcfffff 64bit pref]
> pci 0000:05:00.0: no compatible bridge window for [mem 0xfffcfc000-0xfffcfdfff 64bit pref]
> pci 0000:0b:04.0: no compatible bridge window for [mem 0xfffef8000-0xfffefffff 64bit pref]
> pci 0000:0b:04.0: no compatible bridge window for [mem 0xfffd00000-0xfffdfffff 64bit pref]
> pci 0000:0b:04.0: no compatible bridge window for [mem 0xfffef7800-0xfffef7fff 64bit pref]
...
> pnp 00:0e: disabling [mem 0x00000000-0x0009ffff] because it overlaps 0000:05:00.0 BAR 0 [mem 0x00000000-0x007fffff 64bit pref]
> pnp 00:0e: disabling [mem 0x000c0000-0x000cffff] because it overlaps 0000:05:00.0 BAR 0 [mem 0x00000000-0x007fffff 64bit pref]

ACPI helpfully tells us that the high 6MB below 4GB is reserved, but
we don't handle that correctly:

> pnp 00:08: [mem 0xffa00000-0xfffffffe]
> system 00:08: [mem 0xffa00000-0xfffffffe] could not be reserved

And finally, we drop some of those PCI devices, including the vxge
device on top of that ACPI PNP0C02 device, which of course doesn't
work:

> pci 0000:00:06.0: BAR 9: assigned [mem 0xff000000-0xffbfffff 64bit pref]
> pci 0000:05:00.0: BAR 0: assigned [mem 0xff000000-0xff7fffff 64bit pref]
> vxge: Reading of hardware info failed.Please try upgrading the firmware.
> vxge: probe of 0000:05:00.0 failed with error -22

So there's probably a BIOS bug (not reporting the windows above 4GB),
and definitely a Linux bus (allowing PCI to allocate things on top
of ACPI devices).

This is a known Linux issue, and the top-down allocation scheme made
it much more likely that we'd run into problems like this.  Reverting
to bottom-up allocation doesn't fix the problem, but makes it much less
likely that we'll trip over it.

Thanks a lot for reporting this and collecting the dmesg!

Bjorn
