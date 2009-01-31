From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Sat, 31 Jan 2009 01:34:46 +0100
Message-ID: <200901310134.47657.rjw@sisk.pl>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901310031.37660.rjw@sisk.pl> <alpine.LFD.2.00.0901301541290.3150@localhost.localdomain>
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
Received: from ogre.sisk.pl ([217.79.144.158]:51020 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751347AbZAaAfc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 19:35:32 -0500
In-Reply-To: <alpine.LFD.2.00.0901301541290.3150@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 31 January 2009, Linus Torvalds wrote:
> 
> On Sat, 31 Jan 2009, Rafael J. Wysocki wrote:
> > 
> > I wonder if this change makes any difference:
> > 
> > --- linux-2.6.orig/drivers/pci/pci-driver.c
> > +++ linux-2.6/drivers/pci/pci-driver.c
> > @@ -501,6 +501,9 @@ static int pci_pm_suspend(struct device
> >  	if (pci_has_legacy_pm_support(pci_dev))
> >  		return pci_legacy_suspend(dev, PMSG_SUSPEND);
> >  
> > +	if (!drv || !drv->pm)
> > +		return 0;
> > +
> >  	if (drv && drv->pm && drv->pm->suspend) {
> >  		error = drv->pm->suspend(dev);
> >  		suspend_report_result(drv->pm->suspend, error);
> 
> I don't think that's right. Now you don't end up calling 
> pci_pm_default_suspend_generic() at all, and this no pci_save_state().
> 
> But I think it could easily be the call to pci_disable_enabled_device(). 
> It does that
> 
> 	if (atomic_read(&dev->enable_cnt))
> 		do_pci_disable_device(dev);
> 
> and that ends up disabling PCI_COMMAND_MASTER and then calling 
> pcibios_disable_device().

pci_disable_enabled_device() is not called for the PCIe port driver, because
it has the legacy PM support.

What happens is

pci_pm_suspend(port) ->
 		pci_legacy_suspend(port) ->
 		 		pcie_portdrv_suspend(port) [this doesn't save the state]
 		 		pci_save_state(port)

and then, with interrupts off

pci_pm_suspend_noirq(port) ->
 		pci_legacy_suspend_late(port) ->
 		 		pcie_portdrv_suspend_late(port) ->
 		 		 		pci_save_state(port)

and I suspect this last pci_save_state() breaks things.  I'm not sure why,
though.

Thanks,
Rafael
