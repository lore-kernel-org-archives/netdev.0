From: wendy xiong <wendyx@us.ibm.com>
Subject: Re: [ PATCH 1/1 2.6.25-rc9] bnx2: Add EEH support in bnx2x driver
Date: Tue, 22 Apr 2008 14:44:01 -0500
Message-ID: <1208893442.7339.17.camel@wendyx.austin.ibm.com>
References: <1208812834.24768.40.camel@wendyx.austin.ibm.com>
	 <1208823296.16633.230.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, jeff@garzik.org,
	davem@davemloft.net
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:57910 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755266AbYDVToE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2008 15:44:04 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3MJi3K2017340
	for <netdev@vger.kernel.org>; Tue, 22 Apr 2008 15:44:03 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3MJi3Ag245832
	for <netdev@vger.kernel.org>; Tue, 22 Apr 2008 15:44:03 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3MJi3si007745
	for <netdev@vger.kernel.org>; Tue, 22 Apr 2008 15:44:03 -0400
In-Reply-To: <1208823296.16633.230.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael Chan,

Thanks for your comments!

>I think it is better to add rtnl_lock() here to prevent racing with
> other functions such as ethtool and close that can be resetting the
> chip.  The same should be done in the other 2 functions below.

Yes. Most of network interface functions called by net/core/dev.c layer
which hold rtnl_lock()/rtcl_unlock(). We may need to add
rtnl_lock()/rtnl_unlcok() in those callback functions.

>Shouldn't we attach first before netif_start?

>From my understanding, network interface function dev->open will call
device driver's open function to initialize internal data structures and
enable interrupt, then driver starts the receive queue by calling
netif_start_queue.

Looks bnx2_netif_start() enables hardware interrupt and receive polling
interrupt. So I think we can do netif_device_attach after
bnx2_netif_start() according to dev->open route concept.

Thanks,
Wendy
On Mon, 2008-04-21 at 17:14 -0700, Michael Chan wrote:
> On Mon, 2008-04-21 at 16:20 -0500, wendy xiong wrote:
> 
> > 
> > diff -Nuarp linux-2.6.25-rc9.orig/drivers/net/bnx2.c linux-2.6.25-rc9.eeh/drivers/net/bnx2.c
> > --- linux-2.6.25-rc9.orig/drivers/net/bnx2.c    2008-04-18 22:12:53.000000000 -0500
> > +++ linux-2.6.25-rc9.eeh/drivers/net/bnx2.c     2008-04-18 22:28:42.000000000 -0500
> > @@ -7108,6 +7108,7 @@ bnx2_init_board(struct pci_dev *pdev, st
> >         }
> > 
> >         pci_set_master(pdev);
> > +       pci_save_state(pdev);
> > 
> >         bp->pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
> >         if (bp->pm_cap == 0) {
> > @@ -7617,6 +7618,85 @@ bnx2_resume(struct pci_dev *pdev)
> >         return 0;
> >  }
> > 
> > +/**
> > + * bnx2_io_error_detected - called when PCI error is detected
> > + * @pdev: Pointer to PCI device
> > + * @state: The current pci connection state
> > + *
> > + * This function is called after a PCI bus error affecting
> > + * this device has been detected.
> > + */
> > +static pci_ers_result_t bnx2_io_error_detected(struct pci_dev *pdev,
> > +                                               pci_channel_state_t state)
> > +{
> > +       struct net_device *dev = pci_get_drvdata(pdev);
> > +       struct bnx2 *bp = netdev_priv(dev);
> 
> I think it is better to add rtnl_lock() here to prevent racing with
> other functions such as ethtool and close that can be resetting the
> chip.  The same should be done in the other 2 functions below.
> 
> > +
> > +       netif_device_detach(dev);
> > +
> > +       if (netif_running(dev)) {
> > +               bnx2_netif_stop(bp);
> > +               del_timer_sync(&bp->timer);
> > +               bnx2_reset_nic(bp, BNX2_DRV_MSG_CODE_RESET);
> > +       }
> > +
> > +       pci_disable_device(pdev);
> > +
> 
> Add rtnl_unlock() here.
> 
> > +       /* Request a slot slot reset. */
> > +       return PCI_ERS_RESULT_NEED_RESET;
> > +}
> > +
> > +/**
> > + * bnx2_io_slot_reset - called after the pci bus has been reset.
> > + * @pdev: Pointer to PCI device
> > + *
> > + * Restart the card from scratch, as if from a cold-boot.
> > + */
> > +static pci_ers_result_t bnx2_io_slot_reset(struct pci_dev *pdev)
> > +{
> > +       struct net_device *dev = pci_get_drvdata(pdev);
> > +       struct bnx2 *bp = netdev_priv(dev);
> > +
> > +       if (pci_enable_device(pdev)) {
> > +               dev_err(&pdev->dev,
> > +                       "Cannot re-enable PCI device after reset.\n");
> > +               return PCI_ERS_RESULT_DISCONNECT;
> > +       }
> > +       pci_set_master(pdev);
> > +       pci_restore_state(pdev);
> > +
> > +       if (netif_running(dev)) {
> > +               bnx2_set_power_state(bp, PCI_D0);
> > +               bnx2_init_nic(bp);
> > +       }
> > +
> > +       return PCI_ERS_RESULT_RECOVERED;
> > +}
> > +
> > +/**
> > + * bnx2_io_resume - called when traffic can start flowing again.
> > + * @pdev: Pointer to PCI device
> > + *
> > + * This callback is called when the error recovery driver tells us that
> > + * its OK to resume normal operation.
> > + */
> > +static void bnx2_io_resume(struct pci_dev *pdev)
> > +{
> > +       struct net_device *dev = pci_get_drvdata(pdev);
> > +       struct bnx2 *bp = netdev_priv(dev);
> > +
> > +       if (netif_running(dev))
> > +               bnx2_netif_start(bp);
> > +
> > +       netif_device_attach(dev);
> 
> Shouldn't we attach first before netif_start?
> 
> Thanks.
> 
> 

