From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: question about tulip/winbond-840.c
Date: Thu, 2 Jan 2014 17:16:00 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1401021641230.2088@hadrien>
References: <alpine.DEB.2.10.1401021520280.2088@hadrien> <CAP6odjj2jPfgEBdHv+GGDhVaHt4KEm_DWCX3PdCxCjUbApWc8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Grant Grundler <grundler@parisc-linux.org>,
	"open list:TULIP NETWORK DRI..." <netdev@vger.kernel.org>
To: Grant Grundler <grantgrundler@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:61361
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751386AbaABQQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 11:16:17 -0500
In-Reply-To: <CAP6odjj2jPfgEBdHv+GGDhVaHt4KEm_DWCX3PdCxCjUbApWc8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 2 Jan 2014, Grant Grundler wrote:

> On Thu, Jan 2, 2014 at 6:24 AM, Julia Lawall <julia.lawall@lip6.fr> wrote:
> > I don't know if you want to bother about this, because it is very old code
> > and is apparently not hurting anyone, but I don't see the point of the
> > call to pci_enable_device in the function w840_resume.
>
> I believe the call to pci_enable_device is required:
>     http://lxr.free-electrons.com/source/Documentation/PCI/pci.txt
>
>
> 254 3.1 Enable the PCI device
> 255 ~~~~~~~~~~~~~~~~~~~~~~~~~
> 256 Before touching any device registers, the driver needs to enable
> 257 the PCI device by calling pci_enable_device(). This will:
> 258         o wake up the device if it was in suspended state,
> 259         o allocate I/O and memory regions of the device (if BIOS did not),
> 260         o allocate an IRQ (if BIOS did not).
>
> > The driver had a
> > call to pci_enable_device in its probe function, but it contains no call
> > to pci_disable_device, unlike some other tulip drivers.
>
> I think the bug is the pci_disable_device is not called. The driver
> should call pci_disable_device in suspend function and on failure path
> in the resume function. I've never looked at this code before and I
> believe has existed before PCI API was "mature". That's probably why
> it's not using the API correctly.
>
> >  Perhaps the call has a small functionality,
>
> Yes - assuming pci.txt isn't stale. :)
>
> > but it seems like it can at least never return
> > a value other than 0, because the result of
> > atomic_inc_return(&dev->enable_cnt) in pci_enable_device_flags should
> > be greater than 1.
>
> Off hand I don't recall..pci_enable_device used to setup alot more
> stuff including power state and many of those could fail.

It does set up more things.  But it doesn't do much if the device has not
been disabled.
http://lxr.free-electrons.com/source/drivers/pci/pci.c#L1190

Looking across the entire Linux kernel, I see cases where there are
enables but no disables, and cases where there are disables and no
enables.  So I wouldn't really know whether a change is needed.

julia
