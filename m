From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Sat, 31 Jan 2009 21:45:11 +0100
Message-ID: <200901312145.12073.rjw@sisk.pl>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <alpine.LFD.2.00.0901301741380.3150@localhost.localdomain> <alpine.LFD.2.00.0901301756360.3150@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:54418 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752279AbZAaUp5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jan 2009 15:45:57 -0500
In-Reply-To: <alpine.LFD.2.00.0901301756360.3150@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 31 January 2009, Linus Torvalds wrote:
> 
> On Fri, 30 Jan 2009, Linus Torvalds wrote:
> > 
> > I still think the patch isn't very good. See my previous email. 
> > 
> > The fact that your machine works again is good, though. But before we let 
> > this lie, I'd _really_ like to know what was broken in the legacy PM path, 
> > rather than "let's leave it behind". Because a broken legacy path will end 
> > up biting us for other drivers, and I think the new PM path will need more 
> > work before it's ready for prime-time.
> 
> Ho humm. I have a feeling..
> 
> The legacy resume basically ends up doing just
> 
> 	pci_restore_standard_config(dev)
> 
> in the resume_early path (in pci_pm_default_resume_noirq, which is shared 
> with both the legacy and the new PM model).

Well, please remember that the PCIe port driver has ->resume() too, which is
pcie_portdrv_resume(), which calls pcie_portdrv_restore_config() and that
calls pci_enable_device() (not reenable, just plain enable).

However, that sees the device has been already enabled and doesn't enable
it, although it is supposed to do that.

> The _new_ PM layer does that too (it's shared), but then in the regular 
> resume sequence it _also_ does the pci_pm_reenable_device(), and I think 
> this is key.

It well may be, but I'm not too sure.

> Why?
> 
> Look at pci_restore_standard_config(): it restores the PCI config space, 
> but it does so _before_ actually turning the device into PCI_D0. And 
> that's not actually guaranteed to work at all - if a device is in D3, you 
> can still read from config space, but writing to it may or may not 
> actually work.

Yes, I sent a patch for it to Jesse, but he hasn't pushed it yet:
http://git.kernel.org/?p=linux/kernel/git/jbarnes/pci-2.6.git;a=commit;h=48f67f54a53bb68619a63c3f38cf7f502ed74b1d

Parag, would it be possible to test this patch on top of 2.6.29-rc3?

> This may explain why your PCIE bridge works when moving over to the new 
> PM: because of the whole pci_pm_reenable_device() thing, we end up 
> doing the pci_enable_resources() thing later, and now it's in PCI_D0, so 
> now the device actually reacts to it.
> 
> This also explains why we don't care if we save the wrong state or not: 
> even if we save state with IO/MEM disabled, we'll re-enable it at 
> ->resume() time.

Nice theory, but please also look at the original 2.6.28 code in
drivers/pci/pcie/portdrv_pci.c .  It does:
(suspend):
- suspend port services
- pci_save_state

(resume):
- pci_restore_state()
- pci_enable_device() -> this doesn't enable the device, because it sees the
  non-zero refrence count end doesn't do anything.

So, according to your theory, the 2.6.28 code shouldn't work for Parag, but it
does.

Moreover, why oh why the state we save would contain IO/MEM disabled?

We _never_ _ever_ disable them, so WHY? 

> HOWEVER, that's still buggy, since it's potentially too late, since any 
> interrupts that come in before that will see the device without the IO/MEM 
> set, leading to the whole "hung interrupt" issue again even if the device 
> is now on.
> 
> So we really do want to restore the state to whatever saves state in the 
> _early_ resume phase, both for legacy and new PM rules, I think.

We do that, no?

> And we want to make sure that we restore state while the device is in D0,
> because otherwise I really think that it possibly could lose our writes.

That's what the above-mentioned patch fixes.

> (Somebody should check me on that - maybe I remember wrong, and config 
> space writes are guaranteed to take effect even when something is in 
> D3cold).

Only in D3hot, but MSI-X tables reside in memory space and we need to restore
them too.  So, we need to put the device into D0 before restoring the state, if
possible, anyway.

Still, we can't bring any device from D3cold into D0 without ACPI and we can't
use ACPI for that with interrupts off.

> So I think we should:
> 
>  - make sure that the generic PCI layer saves the right state, for the new 
>    PM model too.

I thought we did that.

>    Don't save it if the driver already did (because the 
>    driver may have turned off the device after saving the state)

In the new PM model the idea is that drivers won't do that.  The core is
supposed to both save the state and turn the device off.

>  - make sure that the legacy PM layer turns the device on before it 
>    restores the state, to make sure that it "takes".

With the above-mentioned patch from the Jesse's tree, it should work this way.

Still, as I said before, I don't think this is relevant in this particular
case, because the original 2.6.28 code evidently works for Parag.

> I dunno. I haven't really walked through all the states, but _something_ 
> like this might do it. Note the change to pci_pm_default_suspend_generic: 
> we save the state only if the driver didn't do it already (which is also 
> why I ended up having to move all the "dev->state_saved = false" things 
> around), and we do not disable the device (because for all we know, the 
> low-level drivers will still need access to the IO/MEM space even at the 
> suspend_late stage!).
> 
> Rafael? 

I think something different from what you told is happening here.  I'm not sure
what it is, I need more information.

I'm very much interested in whether your patch below makes any difference for
Parag.

Thanks,
Rafael


> ---
>  drivers/pci/pci-driver.c       |   20 +++++++++++++-------
>  drivers/pci/pci.c              |    3 +++
>  drivers/pci/pcie/portdrv_pci.c |   14 --------------
>  3 files changed, 16 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/pci/pci-driver.c b/drivers/pci/pci-driver.c
> index 9de07b7..5611f22 100644
> --- a/drivers/pci/pci-driver.c
> +++ b/drivers/pci/pci-driver.c
> @@ -355,8 +355,6 @@ static int pci_legacy_suspend(struct device *dev, pm_message_t state)
>  	int i = 0;
>  
>  	if (drv && drv->suspend) {
> -		pci_dev->state_saved = false;
> -
>  		i = drv->suspend(pci_dev, state);
>  		suspend_report_result(drv->suspend, i);
>  		if (i)
> @@ -434,13 +432,18 @@ static int pci_pm_default_resume(struct pci_dev *pci_dev)
>  
>  static void pci_pm_default_suspend_generic(struct pci_dev *pci_dev)
>  {
> -	/* If device is enabled at this point, disable it */
> -	pci_disable_enabled_device(pci_dev);
>  	/*
> -	 * Save state with interrupts enabled, because in principle the bus the
> -	 * device is on may be put into a low power state after this code runs.
> +	 * If the driver didn't save state, do it here with interrupts enabled,
> +	 * because in principle the bus the device is on may be put into a
> +	 * low power state after this code runs.
>  	 */
> -	pci_save_state(pci_dev);
> +	if (!pci_dev->state_saved)
> +		pci_save_state(pci_dev);
> +
> +#if 0 /* Why? */
> +	/* If device is enabled at this point, disable it */
> +	pci_disable_enabled_device(pci_dev);
> +#endif
>  }
>  
>  static void pci_pm_default_suspend(struct pci_dev *pci_dev)
> @@ -498,6 +501,7 @@ static int pci_pm_suspend(struct device *dev)
>  	struct device_driver *drv = dev->driver;
>  	int error = 0;
>  
> +	dev->state_saved = false;
>  	if (pci_has_legacy_pm_support(pci_dev))
>  		return pci_legacy_suspend(dev, PMSG_SUSPEND);
>  
> @@ -583,6 +587,7 @@ static int pci_pm_freeze(struct device *dev)
>  	struct device_driver *drv = dev->driver;
>  	int error = 0;
>  
> +	pci_dev->state_saved = false;
>  	if (pci_has_legacy_pm_support(pci_dev))
>  		return pci_legacy_suspend(dev, PMSG_FREEZE);
>  
> @@ -657,6 +662,7 @@ static int pci_pm_poweroff(struct device *dev)
>  	struct device_driver *drv = dev->driver;
>  	int error = 0;
>  
> +	pci_dev->state_saved = false;	/* Do we care? */
>  	if (pci_has_legacy_pm_support(pci_dev))
>  		return pci_legacy_suspend(dev, PMSG_HIBERNATE);
>  
> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
> index 17bd932..d16af49 100644
> --- a/drivers/pci/pci.c
> +++ b/drivers/pci/pci.c
> @@ -1421,6 +1421,9 @@ int pci_restore_standard_config(struct pci_dev *dev)
>  
>  	dev->current_state = PCI_D0;
>  
> +	/* Restore state _again_, now that the device is actually on */
> +	pci_restore_state(dev);
> +
>  	return 0;
>  }
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
