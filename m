From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Sat, 31 Jan 2009 22:08:19 +0100
Message-ID: <200901312208.20850.rjw@sisk.pl>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901310138.51214.rjw@sisk.pl> <alpine.LFD.2.00.0901301714080.3150@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:54481 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752443AbZAaVJD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jan 2009 16:09:03 -0500
In-Reply-To: <alpine.LFD.2.00.0901301714080.3150@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 31 January 2009, Linus Torvalds wrote:
> 
> On Sat, 31 Jan 2009, Rafael J. Wysocki wrote:
> > 
> > Can you test the patch below, please?
> 
> Rafael, you're making this _way_ too difficult.
> 
> Don't make it use the new PM infrastructure, because that one is certainly 
> broken: pci_pm_default_suspend_generic() is total crap.

Oh my.  I beg to differ.

> It's saving the disabled state. No WAY is that correct.

So why does it work, actually?

> That "pci_disable_enabled_device()" should be removed, but even then 
> that's wrong, because if the driver suspend disabled it, you're now 
> (again) saving the disabled state.
> 
> But all of that is only called if you use the new PM infrastructure. So 
> the thing is, when you're trying to move the PCI-E drive to the new pm 
> infrastructure, you're making things _worse_.

I don't really think so (see below).

> The legacy PM infrastructure at least does the whole
> 
> 	pci_dev->state_saved = false;
> 	i = drv->suspend(pci_dev, state);
> 	..
> 	if (pci_dev->state_saved)
> 		goto Fixup;
> 
> thing, which will avoid overwriting the state if it was already saved.
> 
> HOWEVER. The problem here (I think) is that PCI-E actually does the state 
> save late, so it won't ever see the "state_saved" in the early ->suspend. 
> I think a patch like the one below at least simplifies this all, and lets 
> the PCI layer itself do all the core restore stuff.
> 
> The new PM infrastructure gets this totally wrong, and
>  (a) disables the device before saving state

pci_disable_device() does really only one thing: it clears the bus master bit.
Yes, it also calls pcibios_disable_device(), but on x86 this is a NOP.

I don't think it is SO bad, is it?

> and
>  (b) overwrites the (now corrupted) saved state that the driver perhaps 
>      already saved, after the driver may even have put it to sleep.

The driver using the new model is not supposed to save the state and power
off the device.  Still, it's probably a good idea not to trust the drivers. :-)

> So let's not use the new PM infrastructure - I don't think it's ready yet.
>
> Let's start simplifying first. Start off by getting rid of the 
> suspend_early/resume_late, since the PCI layer now does it for us.
> 
> I don't see why we don't resume with IO/MEM on, though. The legacy suspend 
> sequence shouldn't disable them, afaik.

No, it shouldn't.

However, the patch below actually may help and it really is not too different
from my "new infrastructure" patch.  It leaves the pcie_portdrv_restore_config()
in the PCIe port driver's ->resume(), but that shouldn't change things,
pci_enable_device() in there shouldn't do anything and the bus master bit
should already be set.

The "new infrastracture" patch makes pci_disable_enabled_device() be called in
the suspend code path, but that only disables the bus master bit, and
pci_reenable_device() be called in the resume code path, but that only sets the
bus master bit back again.  So, they are almost the same and I'd be surprised
if your patch didn't help.

I had that "new infrastracture" patch ready yesterday and I thought it might
help, so I sent it.  I was too tired to prepare a new patch and that would
probably look like the one below (I'd remove the pcie_portdrv_restore_config()
from ->resume too, but that's only a detail).

Thanks,
Rafael

> ---
>  drivers/pci/pcie/portdrv_pci.c |   14 --------------
>  1 files changed, 0 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/pci/pcie/portdrv_pci.c b/drivers/pci/pcie/portdrv_pci.c
> index 99a914a..08a8e3c 100644
> --- a/drivers/pci/pcie/portdrv_pci.c
> +++ b/drivers/pci/pcie/portdrv_pci.c
> @@ -55,16 +55,6 @@ static int pcie_portdrv_suspend(struct pci_dev *dev, pm_message_t state)
>  
>  }
>  
> -static int pcie_portdrv_suspend_late(struct pci_dev *dev, pm_message_t state)
> -{
> -	return pci_save_state(dev);
> -}
> -
> -static int pcie_portdrv_resume_early(struct pci_dev *dev)
> -{
> -	return pci_restore_state(dev);
> -}
> -
>  static int pcie_portdrv_resume(struct pci_dev *dev)
>  {
>  	pcie_portdrv_restore_config(dev);
> @@ -72,8 +62,6 @@ static int pcie_portdrv_resume(struct pci_dev *dev)
>  }
>  #else
>  #define pcie_portdrv_suspend NULL
> -#define pcie_portdrv_suspend_late NULL
> -#define pcie_portdrv_resume_early NULL
>  #define pcie_portdrv_resume NULL
>  #endif
>  
> @@ -292,8 +280,6 @@ static struct pci_driver pcie_portdriver = {
>  	.remove		= pcie_portdrv_remove,
>  
>  	.suspend	= pcie_portdrv_suspend,
> -	.suspend_late	= pcie_portdrv_suspend_late,
> -	.resume_early	= pcie_portdrv_resume_early,
>  	.resume		= pcie_portdrv_resume,
>  
>  	.err_handler 	= &pcie_portdrv_err_handler,
