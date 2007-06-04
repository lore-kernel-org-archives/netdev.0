From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC][PATCH] Add suspend and resume support to uli526x
Date: Mon, 4 Jun 2007 13:11:12 +0200
Message-ID: <20070604111112.GP4363@elf.ucw.cz>
References: <200706031237.36773.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pm <linux-pm@lists.osdl.org>, netdev@vger.kernel.org,
	Valerie Henson <val@nmt.edu>,
	Nigel Cunningham <nigel@nigel.suspend2.net>,
	Peer Chen <peer.chen@uli.com.tw>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:41585 "EHLO amd.ucw.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752972AbXFDLLS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 07:11:18 -0400
Content-Disposition: inline
In-Reply-To: <200706031237.36773.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> From: Rafael J. Wysocki <rjw@sisk.pl>
> 
> Add suspend/resume support to the uli526x network driver (tested on x86_64,
> with 'Ethernet controller: ALi Corporation M5263 Ethernet Controller, rev 40').
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>

Looks ok to me.

> +#ifdef CONFIG_PM
> +
> +/*
> + *	Suspend the interface.
> + */
> +
> +static int uli526x_suspend(struct pci_dev *pdev, pm_message_t state)
> +{
> +	struct net_device *dev = pci_get_drvdata(pdev);
> +
> +	ULI526X_DBUG(0, "uli526x_suspend", 0);
> +
> +	if (dev && netdev_priv(dev)) {
> +		if (netif_running(dev)) {
> +			netif_device_detach(dev);
> +			uli526x_down(dev);
> +		}
> +		pci_save_state(pdev);
> +		pci_enable_wake(pdev, pci_choose_state(pdev, state), 0);
> +		pci_disable_device(pdev);
> +		pci_set_power_state(pdev, pci_choose_state(pdev, state));
> +	}
> +	return 0;
> +}
> +
> +/*
> + *	Resume the interface.
> + */
> +
> +static int uli526x_resume(struct pci_dev *pdev)
> +{
> +	struct net_device *dev = pci_get_drvdata(pdev);
> +	struct uli526x_board_info *db = netdev_priv(dev);
> +	int err;
> +
> +	ULI526X_DBUG(0, "uli526x_resume", 0);
> +
> +	if (dev && db) {
> +		pci_set_power_state(pdev, PCI_D0);
> +		err = pci_enable_device(pdev);
> +		if (err) {
> +			printk(KERN_WARNING "%s: Could not enable device \n",
> +				dev->name);
> +			return err;
> +		}
> +		pci_restore_state(pdev);
> +		pci_set_master(pdev);
> +		if (netif_running(dev)) {
> +			uli526x_up(dev);
> +			netif_device_attach(dev);
> +		}
> +	}
> +	return 0;
> +}
> +
#else 
#define *_resume NULL
#define *_suspend NULL

> +#endif /* CONFIG_PM */

> @@ -1689,6 +1775,10 @@ static struct pci_driver uli526x_driver 
>  	.id_table	= uli526x_pci_tbl,
>  	.probe		= uli526x_init_one,
>  	.remove		= __devexit_p(uli526x_remove_one),
> +#ifdef CONFIG_PM
> +	.suspend	= uli526x_suspend,
> +	.resume		= uli526x_resume,
> +#endif

...so that this ifdef is not needed?
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
