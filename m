From: Valerie Henson <val_henson@linux.intel.com>
Subject: Re: Proper pci_enable_device() error handling in resume routine
Date: Mon, 21 Aug 2006 16:10:37 -0700
Message-ID: <20060821231036.GJ20111@goober>
References: <20060820052922.GH20111@goober> <44E9F773.1070007@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:55851 "EHLO
	orsmga101.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751295AbWHUXMA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 19:12:00 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
Content-Disposition: inline
In-Reply-To: <44E9F773.1070007@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2006 at 11:12:03AM -0700, Auke Kok wrote:
> Valerie Henson wrote:
> >I'm trying to properly handle pci_enable_device() errors in the resume
> >routines of a couple of tulip drivers.  I noticed that several drivers
> >pay attention to errors from pci_enable_device() in the init routine
> >but ignore it on resume; other drivers vary wildly.  What's proper
> >behavior when resuming?  Extant examples:
> >
> >0. Don't call pci_enable_device() at all (8139too)
> >1. Ignore the return value (eepro100, many others)
> >2. Check for failure and bail out, but return success (sungem)
> 
> Digging through e1000 I spot that we even pci_enable_device after a PCI 
> error, so it is good practice I think to make sure the device is up. I 
> suppose that most people can live without explicit re-enabling the device 
> (most NICs are on anyway), but if we do enable it explicitly we should 
> certainly check the result code. Interestingly enough we failed to do this 
> in e1000, so I'll submit a patch for that later.

For people looking for how to implement this in their own driver,
here's how I solved it in tulip (will submit later):

---
 drivers/net/tulip/tulip_core.c  |    5 ++++-
 drivers/net/tulip/winbond-840.c |   10 +++++++---
 2 files changed, 11 insertions(+), 4 deletions(-)

--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1780,7 +1780,10 @@ static int tulip_resume(struct pci_dev *
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 
-	pci_enable_device(pdev);
+	if ((retval = pci_enable_device(pdev))) {
+		printk (KERN_ERR "tulip: pci_enable_device failed in resume\n");
+		return retval;
+	}
 
 	if ((retval = request_irq(dev->irq, &tulip_interrupt, IRQF_SHARED, dev->name, dev))) {
 		printk (KERN_ERR "tulip: request_irq failed in resume\n");



-VAL
