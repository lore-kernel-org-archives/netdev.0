From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: Re: quirk_e100_interrupt() called too early
Date: Thu, 28 Jun 2007 20:07:27 -0600
Message-ID: <200706282007.27841.bjorn.helgaas@hp.com>
References: <4683A80F.5020605@semihalf.com> <4683DB44.9070704@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Marian Balakowicz <m8@semihalf.com>,
	linux-pci@atrey.karlin.mff.cuni.cz, len.brown@intel.com,
	NetDev <netdev@vger.kernel.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	nils.rennebarth@packetalarm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:52573 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765058AbXF2CHg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 22:07:36 -0400
In-Reply-To: <4683DB44.9070704@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 28 June 2007 10:01:08 am Kok, Auke wrote:
> Marian Balakowicz wrote:
> > I am enabling and testing PCI on tqm5200 mpc5200 based board where I
> > faced the following issue.
> > 
> > I am using EEPRO100 PCI card for which there is specific
> > quirk_e100_interrupt that tries to disable interrupts if
> > they were left enabled by the firmware. quirk_e100_interrupts() is
> > called after PCI controller is initialized and before PCI bus
> > enumeration is performed. On some powerpc platforms, like the one I am
> > using, PCI controller configuration sets different MEM and IO windows
> > than those set by firmware. That is why quirk_e100_interrupt() is
> > causing kernel panic as it tries to read from device BAR0 offets which
> > at this time point to a invalid PCI window (set by firmware).
> > 
> > The patch below delays the quirk_100_interrupt() to pci_fixup_final
> > phase, which happens after bus enumeration and before device PCI enable
> > and device driver initialization - so, it seem to be still a good place
> > for this quirk. It works fine for me but I only tested it on a tqm5200.
> > Could someone please help and verify that on other platforms?
> 
> will try to do. This sounds indeed like the proper thing to do. Unfortunately I 
> don't have any NICs to repro this on (allthough I have a ppc box with said 
> firmware probe method).
> 
> Bjorn orignially wrote this patch, perhaps he can comment on the fixup move?

Your patch looks reasonable to me.

I don't have a machine that exhibits the original problem, so
I can't actually test this patch either.  As long as the fixup
happens before any PCI drivers claim devices, I think it should
be fine.

I copied Nils Rennebarth, who originally reported the bug:
  http://bugzilla.kernel.org/show_bug.cgi?id=5918
in case he can test your patch.

> > diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
> > index 01d8f8a..7194074 100644
> > --- a/drivers/pci/quirks.c
> > +++ b/drivers/pci/quirks.c
> > @@ -1475,7 +1475,7 @@ static void __devinit quirk_e100_interru
> > 
> >         iounmap(csr);
> >  }
> > -DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, PCI_ANY_ID,
> > quirk_e100_interrupt);
> > +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, PCI_ANY_ID,
> > quirk_e100_interrupt);
> > 
> >  static void __devinit fixup_rev1_53c810(struct pci_dev* dev)
> >  {
> 
> 


