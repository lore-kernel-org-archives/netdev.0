From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: [PATCH] e100: Use pci_pme_active for clearing wake-up events and disabling PME# (was: Re: [regression] e100: PCI wake-up handling rework causes "Error clearing wake event")
Date: Thu, 11 Sep 2008 01:07:13 +0200
Message-ID: <200809110107.14545.rjw@sisk.pl>
References: <200809090812.37649.elendil@planet.nl> <200809091514.23817.rjw@sisk.pl> <20080910153124.8536a7db.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	e1000-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jesse.brandeburg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080910153124.8536a7db.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday, 11 of September 2008, Andrew Morton wrote:
> On Tue, 9 Sep 2008 15:14:22 +0200
> "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org> wrote:
> 
> > On Tuesday, 9 of September 2008, Frans Pop wrote:
> > > (Resending because of error in mail headers in previous attempt; sorry)
> > > 
> > > On my Toshiba Satellite A40 with 2.6.27-rc4/5 I noticed the following 
> > > error in the boot log (not there with 2.6.26):
> > > e100: 0000:01:08.0: e100_probe: Error clearing wake event
> > > 
> > > Bisection has fingered the following patch as the cause of the message.
> > > 
> > > commit eb9d0fe40e313c0a74115ef456a2e43a6c8da72f
> > > Author: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
> > > Date:   Mon Jul 7 03:34:48 2008 +0200
> > >     PCI ACPI: Rework PCI handling of wake-up
> > > 
> > > The test this error originates from in drivers/net/e100.c is old and has 
> > > not changed recently.
> > > 
> > > Surrounding messages (full dmesg attached):
> > > e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
> > > e100: Copyright(c) 1999-2006 Intel Corporation
> > > e100 0000:01:08.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
> > > e100: 0000:01:08.0: e100_probe: Error clearing wake event
> > > e100: eth0: e100_probe: addr 0xcffff000, irq 20, MAC addr 
> > > 00:08:0d:17:bf:f5
> > > 
> > > The NIC is:
> > > 01:08.0 Ethernet controller [0200]: Intel Corporation 82801DB PRO/100 VE 
> > > (MOB) Ethernet Controller [8086:103d] (rev 83)
> > >         Kernel driver in use: e100
> > 
> > The message is actually harmless, but I agree that it's confusing.
> > 
> > The appended patch should fix the problem (ISTR sending it some time ago
> > already).
> > 
> > Thanks,
> > Rafael
> > 
> > ---
> > From: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
> > 
> > e100: Use pci_pme_active for clearing wake-up events and disabling PME#
> > 
> > Currently e100 uses pci_enable_wake() to clear pending wake-up events
> > and disable PME# during intitialization, but that function is not
> > suitable for this purpose, because it immediately returns error code
> > if device_may_wakeup() returns false for given device.
> > 
> > Make e100 use pci_pme_active(), which carries out exactly the
> > required operations, instead.
> > 
> > Signed-off-by: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
> > ---
> >  drivers/net/e100.c |    4 +---
> >  1 file changed, 1 insertion(+), 3 deletions(-)
> > 
> > Index: linux-2.6/drivers/net/e100.c
> > ===================================================================
> > --- linux-2.6.orig/drivers/net/e100.c
> > +++ linux-2.6/drivers/net/e100.c
> > @@ -2738,9 +2738,7 @@ static int __devinit e100_probe(struct p
> >  		nic->flags |= wol_magic;
> >  
> >  	/* ack any pending wake events, disable PME */
> > -	err = pci_enable_wake(pdev, 0, 0);
> > -	if (err)
> > -		DPRINTK(PROBE, ERR, "Error clearing wake event\n");
> > +	pci_pme_active(pdev, false);
> >  
> >  	strcpy(netdev->name, "eth%d");
> >  	if((err = register_netdev(netdev))) {
> 
> This change is already included in
> 
> e100-adapt-to-the-reworked-pci-pm.patch:

Yes, it is.

>   From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
>   
>   Adapt the e100 driver to the reworked PCI PM
>   
>   * Use device_set_wakeup_enable() and friends as needed
>   * Use pci_pme_active() to clear PME_Status and disable PME#
>   * Use the observation that it is sufficient to call pci_enable_wake()
>     once, unless it fails
>   
>   Signed-off-by: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
>   Tested-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>   Acked-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>   Cc: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>
>   Cc: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
>   Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
>   
> 
> which I sent to Jeff on Aug 20 as a for-2.6.28 thing.
> 
> Maybe I should just mark e100-adapt-to-the-reworked-pci-pm.patch as a
> for-2.6.27 thing next time I send that (large) pile of maybe-for-2.6.27
> netdev patches.
> 
> e100-adapt-to-the-reworked-pci-pm.patch

This one shouldn't hurt, it has been tested by people with relevant hardware.

> drivers-net-skfp-pmfc-use-offsetof-macro.patch
> drivers-net-atl1e-dont-take-the-mdio_lock-in-atl1e_probe.patch
> e1000e-prevent-corruption-of-eeprom-nvm.patch
> drivers-net-mlx4-allocc-needs-mmh.patch
> net-forcedeth-call-restore-mac-addr-in-nv_shutdown-path-v2.patch

This is a (listed) regression fix that Jeff promised to have a look at.

> ehea-fix-dlpar-memory-handling.patch
> nec-fix-rmmod-platform-driver-improvements.patch
> nec-fix-suspend-and-resume-for-isa-pnp-cards.patch
