From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH] Add suspend and resume support to uli526x
Date: Mon, 4 Jun 2007 23:31:03 +0200
Message-ID: <200706042331.03933.rjw@sisk.pl>
References: <200706031237.36773.rjw@sisk.pl> <200706041549.11277.rjw@sisk.pl> <1180991794.4356.31.camel@nigel.suspend2.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Pavel Machek <pavel@ucw.cz>, linux-pm <linux-pm@lists.osdl.org>,
	netdev@vger.kernel.org, Valerie Henson <val@nmt.edu>,
	Peer Chen <peer.chen@uli.com.tw>
To: nigel@nigel.suspend2.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:40859 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751372AbXFDVZV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 17:25:21 -0400
In-Reply-To: <1180991794.4356.31.camel@nigel.suspend2.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Monday, 4 June 2007 23:16, Nigel Cunningham wrote:
> Hi.
> 
> On Mon, 2007-06-04 at 15:49 +0200, Rafael J. Wysocki wrote:
> > On Monday, 4 June 2007 13:11, Pavel Machek wrote:
> > > > From: Rafael J. Wysocki <rjw@sisk.pl>
> > > > 
> > > > Add suspend/resume support to the uli526x network driver (tested on x86_64,
> > > > with 'Ethernet controller: ALi Corporation M5263 Ethernet Controller, rev 40').
> > > > 
> > > > Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> > > 
> > > Looks ok to me.
> > > 
> > > > +#ifdef CONFIG_PM
> > > > +
> > > > +/*
> > > > + *	Suspend the interface.
> > > > + */
> > > > +
> > > > +static int uli526x_suspend(struct pci_dev *pdev, pm_message_t state)
> > > > +{
> > > > +	struct net_device *dev = pci_get_drvdata(pdev);
> > > > +
> > > > +	ULI526X_DBUG(0, "uli526x_suspend", 0);
> > > > +
> > > > +	if (dev && netdev_priv(dev)) {
> > > > +		if (netif_running(dev)) {
> > > > +			netif_device_detach(dev);
> > > > +			uli526x_down(dev);
> > > > +		}
> > > > +		pci_save_state(pdev);
> > > > +		pci_enable_wake(pdev, pci_choose_state(pdev, state), 0);
> > > > +		pci_disable_device(pdev);
> > > > +		pci_set_power_state(pdev, pci_choose_state(pdev, state));
> > > > +	}
> > > > +	return 0;
> > > > +}
> > > > +
> > > > +/*
> > > > + *	Resume the interface.
> > > > + */
> > > > +
> > > > +static int uli526x_resume(struct pci_dev *pdev)
> > > > +{
> > > > +	struct net_device *dev = pci_get_drvdata(pdev);
> > > > +	struct uli526x_board_info *db = netdev_priv(dev);
> > > > +	int err;
> > > > +
> > > > +	ULI526X_DBUG(0, "uli526x_resume", 0);
> > > > +
> > > > +	if (dev && db) {
> > > > +		pci_set_power_state(pdev, PCI_D0);
> > > > +		err = pci_enable_device(pdev);
> > > > +		if (err) {
> > > > +			printk(KERN_WARNING "%s: Could not enable device \n",
> > > > +				dev->name);
> > > > +			return err;
> > > > +		}
> > > > +		pci_restore_state(pdev);
> > > > +		pci_set_master(pdev);
> > > > +		if (netif_running(dev)) {
> > > > +			uli526x_up(dev);
> > > > +			netif_device_attach(dev);
> > > > +		}
> > > > +	}
> > > > +	return 0;
> > > > +}
> > > > +
> > > #else 
> > > #define *_resume NULL
> > > #define *_suspend NULL
> > 
> > > > +#endif /* CONFIG_PM */
> > > 
> > > > @@ -1689,6 +1775,10 @@ static struct pci_driver uli526x_driver 
> > > >  	.id_table	= uli526x_pci_tbl,
> > > >  	.probe		= uli526x_init_one,
> > > >  	.remove		= __devexit_p(uli526x_remove_one),
> > > > +#ifdef CONFIG_PM
> > > > +	.suspend	= uli526x_suspend,
> > > > +	.resume		= uli526x_resume,
> > > > +#endif
> > > 
> > > ...so that this ifdef is not needed?
> > 
> > OK, why not.
> 
> Because it's uglier and #ifdef is the established way of doing things?

Hmm, I have no strong opinion.  I slightly prefer the #ifdef, but well.

Perhaps I'll send it to Andrew 'as is' if no one else has any more comments. ;-)

Greetings,
Rafael


-- 
"Premature optimization is the root of all evil." - Donald Knuth
