From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Thu, 29 Jan 2009 15:41:27 -0800
Message-ID: <20090129234127.GA14023@xw6200.broadcom.net>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop>
 <20090129184215.GA13459@xw6200.broadcom.net>
 <alpine.DEB.2.00.0901291700130.5149@parag-desktop>
 <200901300003.38550.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Parag Warudkar" <parag.lkml@gmail.com>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Andrew Morton" <akpm@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4749 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752864AbZA2Xlk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 18:41:40 -0500
In-Reply-To: <200901300003.38550.rjw@sisk.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 29, 2009 at 03:03:37PM -0800, Rafael J. Wysocki wrote:
> On Thursday 29 January 2009, Parag Warudkar wrote:
> > 
> > On Thu, 29 Jan 2009, Matt Carlson wrote:
> > 
> > > Can you apply the following test patch and see if it helps?  The patch
> > > does two things.  First, it enables a bit which should restore firmware
> > > communication.  If that fixes the problem, then let me know and I'll
> > > spin a proper patch.
> > > 
> > > In the event that it doesn't work, the patch goes on to test the memory
> > > mapping by simply printing the register value at offset 0x0.  The value
> > > should be the device's vendor ID and device ID.  Please post the
> > > results so that I can verify it.
> > > 
> > > 
> > > diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> > > index 8b3f846..39fce42 100644
> > > --- a/drivers/net/tg3.c
> > > +++ b/drivers/net/tg3.c
> > > @@ -7227,6 +7227,11 @@ static int tg3_init_hw(struct tg3 *tp, int reset_phy)
> > >  {
> > >  	tg3_switch_clocks(tp);
> > >  
> > > +	printk( KERN_NOTICE "%s: Reg value at offset 0x0 is 0x%x\n",
> > > +		tp->dev->name, tr32(0x0) );
> > > +
> > > +	tw32(MEMARB_MODE, tr32(MEMARB_MODE) | MEMARB_MODE_ENABLE);
> > > +
> > >  	tw32(TG3PCI_MEM_WIN_BASE_ADDR, 0);
> > >  
> > >  	return tg3_reset_hw(tp, reset_phy);
> > > 
> > 
> > Hi Matt,
> > 
> > Thanks for the patch. It didn't help with resume - but below is the 
> > output after patching, let me know if you need more details.
> 
> [--snip--]
> 
> In the meantime I tried to rework tg3 suspend/resume so that it uses the new
> PCI core capability of handling the PCI-specific parts of both operations.
> 
> The patch is appended, please see if it makes any difference.
> 
> Thanks,
> Rafael
> 
> ---
>  drivers/net/tg3.c |   70 +++++++++++++++++++-----------------------------------
>  1 file changed, 25 insertions(+), 45 deletions(-)
> 
> Index: linux-2.6/drivers/net/tg3.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/tg3.c
> +++ linux-2.6/drivers/net/tg3.c
> @@ -13330,18 +13330,13 @@ static void __devexit tg3_remove_one(str
>  	}
>  }
>  
> -static int tg3_suspend(struct pci_dev *pdev, pm_message_t state)
> +#ifdef CONFIG_PM
> +
> +static int tg3_suspend(struct device *device)
>  {
> +	struct pci_dev *pdev = to_pci_dev(device);
>  	struct net_device *dev = pci_get_drvdata(pdev);
>  	struct tg3 *tp = netdev_priv(dev);
> -	pci_power_t target_state;
> -	int err;
> -
> -	/* PCI register 4 needs to be saved whether netif_running() or not.
> -	 * MSI address and data need to be saved if using MSI and
> -	 * netif_running().
> -	 */
> -	pci_save_state(pdev);
>  
>  	if (!netif_running(dev))
>  		return 0;
> @@ -13363,50 +13358,19 @@ static int tg3_suspend(struct pci_dev *p
>  	tp->tg3_flags &= ~TG3_FLAG_INIT_COMPLETE;
>  	tg3_full_unlock(tp);
>  
> -	target_state = pdev->pm_cap ? pci_target_state(pdev) : PCI_D3hot;
> -
> -	err = tg3_set_power_state(tp, target_state);

tg3_set_power_state() does way more than configuring the power
management registers to the desired state though.  It sets up WOL,
configures the chip clocks, etc.  This isn't safe to remove.

> -	if (err) {
> -		int err2;
> -
> -		tg3_full_lock(tp, 0);
> -
> -		tp->tg3_flags |= TG3_FLAG_INIT_COMPLETE;
> -		err2 = tg3_restart_hw(tp, 1);
> -		if (err2)
> -			goto out;
> -
> -		tp->timer.expires = jiffies + tp->timer_offset;
> -		add_timer(&tp->timer);
> -
> -		netif_device_attach(dev);
> -		tg3_netif_start(tp);
> -
> -out:
> -		tg3_full_unlock(tp);
> -
> -		if (!err2)
> -			tg3_phy_start(tp);
> -	}
> -
> -	return err;
> +	return 0;
>  }
>  
> -static int tg3_resume(struct pci_dev *pdev)
> +static int tg3_resume(struct device *device)
>  {
> +	struct pci_dev *pdev = to_pci_dev(device);
>  	struct net_device *dev = pci_get_drvdata(pdev);
>  	struct tg3 *tp = netdev_priv(dev);
>  	int err;
>  
> -	pci_restore_state(tp->pdev);
> -
>  	if (!netif_running(dev))
>  		return 0;
>  
> -	err = tg3_set_power_state(tp, PCI_D0);

...and here tg3_set_power_state() restores our ability to communicate
with the chip via MMIO.  Also, after restoring the power state to D0,
the chip is switched back from VAux to VMain.  This isn't safe either.

> -	if (err)
> -		return err;
> -
>  	netif_device_attach(dev);
>  
>  	tg3_full_lock(tp, 0);
> @@ -13430,13 +13394,29 @@ out:
>  	return err;
>  }
>  
> +struct dev_pm_ops tg3_pm_ops = {
> +	.suspend = tg3_suspend,
> +	.resume = tg3_resume,
> +	.freeze = tg3_suspend,
> +	.thaw = tg3_resume,
> +	.poweroff = tg3_suspend,
> +	.restore = tg3_resume,
> +};
> +
> +#define TG3_PM_OPS	(&tg3_pm_ops)
> +
> +#else /* !CONFIG_PM */
> +
> +#define TG3_PM_OPS	NULL
> +
> +#endif /* !CONFIG_PM */
> +
>  static struct pci_driver tg3_driver = {
>  	.name		= DRV_MODULE_NAME,
>  	.id_table	= tg3_pci_tbl,
>  	.probe		= tg3_init_one,
>  	.remove		= __devexit_p(tg3_remove_one),
> -	.suspend	= tg3_suspend,
> -	.resume		= tg3_resume
> +	.driver.pm	= TG3_PM_OPS,
>  };
>  
>  static int __init tg3_init(void)
> 
> 

