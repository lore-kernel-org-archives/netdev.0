From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 4/7] vbus-proxy: add a pci-to-vbus bridge
Date: Fri, 7 Aug 2009 16:57:32 +0200
Message-ID: <200908071657.32858.arnd@arndb.de>
References: <20090803171030.17268.26962.stgit@dev.haskins.net> <200908070057.54795.arnd@arndb.de> <4A7B78580200005A00051D50@sinclair.provo.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: alacrityvm-devel@lists.sourceforge.net,
	"Ira W. Snyder" <iws@ovro.caltech.edu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Gregory Haskins" <ghaskins@novell.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932674AbZHGO54@vger.kernel.org>
In-Reply-To: <4A7B78580200005A00051D50@sinclair.provo.novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 07 August 2009, Gregory Haskins wrote:
> >>> Arnd Bergmann <arnd@arndb.de> wrote: 
> > On Thursday 06 August 2009, Gregory Haskins wrote:
> > 
> > >     2b) I also want to collapse multiple interrupts together so as to 
> > > minimize the context switch rate (inject + EIO overhead).  My design 
> > > effectively has "NAPI" for interrupt handling.  This helps when the system 
> > > needs it the most: heavy IO.
> > 
> > That sounds like a very useful concept in general, but this seems to be a
> > detail of the interrupt controller implementation. If the IO-APIC cannot
> > do what you want here, maybe we just need a paravirtual IRQ controller
> > driver, like e.g. the PS3 has.
> 
> Yeah, I agree this could be a function of the APIC code.  Do note that I
> mentioned this in passing to Avi a few months ago but FWIW he indicated
> at that time that he is not interested in making the APIC PV.
> 
> Also, I almost forgot an important one.  Add:
> 
>    2c) Interrupt prioritization.  I want to be able to assign priority
>    to interrupts and handle them in priority order.

I think this part of the interface has developed into the wrong direction
because you confused two questions:

1. should you build an advanced interrupt mechanism for virtual drivers?
2. how should you build an advanced interrupt mechanism for virtual drivers?

My guess is that when Avi said he did not want a paravirtual IO-APIC,
he implied that the existing one is good enough (maybe Avi can clarify that
point himself) answering question 1, while you took that as an indication
that the code should live elsewhere instead, answering question 2.

What you built with the shm-signal code is essentially a paravirtual nested
interrupt controller by another name, and deeply integrated into a new
bigger subsystem. I believe that this has significant disadvantages
over the approach of making it a standard interrupt controller driver:

* It completely avoids the infrastructure that we have built into Linux
  to deal with interrupts, e.g. /proc/interrupts statistics, IRQ
  balancing and CPU affinity.

* It makes it impossible to quantify the value of the feature to start with,
  which could be used to answer question 1 above.

* Less importantly, it does not work with any other drivers that might
  also benefit from a new interrupt controller -- if it is indeed better
  than the one we already have.

	Arnd <><
