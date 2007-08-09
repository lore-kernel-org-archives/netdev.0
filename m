From: Brandon Philips <bphilips@suse.de>
Subject: Re: [patch 1/5][RFC] NET: Change pci_enable_device
	topci_reenable_device to keep device enable balance
Date: Thu, 9 Aug 2007 13:45:52 -0700
Message-ID: <20070809204552.GA6870@ifup.org>
References: <20070802224423.GC5181@ifup.org> <78C9135A3D2ECE4B8162EBDCE82CAD7702035646@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, teheo@suse.de,
	e1000-devel@lists.sourceforge.net, auke-jan.h.kok@intel.com
To: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:47374 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753710AbXHIUqF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 16:46:05 -0400
Content-Disposition: inline
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7702035646@nekter>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17:30 Wed 08 Aug 2007, Ramkrishna Vepa wrote:
> Before slot_reset event is called io_error_detected could be called
> (where pci_disable_device() is called), right? 

Oops!  Right, the documentation says .error_detected is _always_ called
before .slot_reset.  So, this patch is not correct.  Please don't merge
this.

>From Documentation/pci-error-recovery.txt:

STEP 1: Notification
--------------------
Platform calls the error_detected() callback on every instance of
every driver affected by the error.
...

If any driver requested a slot reset (by returning PCI_ERS_RESULT_NEED_RESET),
then recovery proceeds to STEP 4 (Slot Reset).

> The pci_reenable_device() will call enable only if the device was
> enabled before and would not be enabled if the device were disabled. Is
> this the intended behavior?

Yes, you are right.  And no it isn't.

Thanks,

	Brandon

> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org
> [mailto:netdev-owner@vger.kernel.org]
> > On Behalf Of Brandon Philips
> > Sent: Thursday, August 02, 2007 3:44 PM
> > To: netdev@vger.kernel.org
> > Cc: teheo@suse.de; Brandon Philips
> > Subject: [patch 1/5][RFC] NET: Change pci_enable_device
> > topci_reenable_device to keep device enable balance
> > 
> > On a slot_reset event pci_disable_device() is never called so calling
> > pci_enable_device() will unbalance the enable count.
> > 
> > Signed-off-by: Brandon Philips <bphilips@suse.de>
> > 
> > ---
> >  drivers/net/e100.c             |    2 +-
> >  drivers/net/e1000/e1000_main.c |    2 +-
> >  drivers/net/ixgb/ixgb_main.c   |    2 +-
> >  drivers/net/s2io.c             |    2 +-
> >  4 files changed, 4 insertions(+), 4 deletions(-)
> > 
> > Index: linux-2.6/drivers/net/e100.c
> > ===================================================================
> > --- linux-2.6.orig/drivers/net/e100.c
> > +++ linux-2.6/drivers/net/e100.c
> > @@ -2828,7 +2828,7 @@ static pci_ers_result_t e100_io_slot_res
> >  	struct net_device *netdev = pci_get_drvdata(pdev);
> >  	struct nic *nic = netdev_priv(netdev);
> > 
> > -	if (pci_enable_device(pdev)) {
> > +	if (pci_reenable_device(pdev)) {
> >  		printk(KERN_ERR "e100: Cannot re-enable PCI device after
> > reset.\n");
> >  		return PCI_ERS_RESULT_DISCONNECT;
> >  	}
> > Index: linux-2.6/drivers/net/e1000/e1000_main.c
> > ===================================================================
> > --- linux-2.6.orig/drivers/net/e1000/e1000_main.c
> > +++ linux-2.6/drivers/net/e1000/e1000_main.c
> > @@ -5270,7 +5270,7 @@ static pci_ers_result_t e1000_io_slot_re
> >  	struct net_device *netdev = pci_get_drvdata(pdev);
> >  	struct e1000_adapter *adapter = netdev->priv;
> > 
> > -	if (pci_enable_device(pdev)) {
> > +	if (pci_reenable_device(pdev)) {
> >  		printk(KERN_ERR "e1000: Cannot re-enable PCI device
> after
> > reset.\n");
> >  		return PCI_ERS_RESULT_DISCONNECT;
> >  	}
> > Index: linux-2.6/drivers/net/ixgb/ixgb_main.c
> > ===================================================================
> > --- linux-2.6.orig/drivers/net/ixgb/ixgb_main.c
> > +++ linux-2.6/drivers/net/ixgb/ixgb_main.c
> > @@ -2294,7 +2294,7 @@ static pci_ers_result_t ixgb_io_slot_res
> >  	struct net_device *netdev = pci_get_drvdata(pdev);
> >  	struct ixgb_adapter *adapter = netdev_priv(netdev);
> > 
> > -	if(pci_enable_device(pdev)) {
> > +	if(pci_reenable_device(pdev)) {
> >  		DPRINTK(PROBE, ERR, "Cannot re-enable PCI device after
> > reset.\n");
> >  		return PCI_ERS_RESULT_DISCONNECT;
> >  	}
> > Index: linux-2.6/drivers/net/s2io.c
> > ===================================================================
> > --- linux-2.6.orig/drivers/net/s2io.c
> > +++ linux-2.6/drivers/net/s2io.c
> > @@ -7833,7 +7833,7 @@ static pci_ers_result_t s2io_io_slot_res
> >  	struct net_device *netdev = pci_get_drvdata(pdev);
> >  	struct s2io_nic *sp = netdev->priv;
> > 
> > -	if (pci_enable_device(pdev)) {
> > +	if (pci_reenable_device(pdev)) {
> >  		printk(KERN_ERR "s2io: "
> >  		       "Cannot re-enable PCI device after reset.\n");
> >  		return PCI_ERS_RESULT_DISCONNECT;
> > 
> > --
> > -
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
