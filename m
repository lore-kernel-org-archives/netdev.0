From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] 3c59x: Rework suspend and resume
Date: Fri, 25 Sep 2009 23:54:34 +0200
Message-ID: <200909252354.34511.rjw@sisk.pl>
References: <20090925205206.GA9270@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-pm@lists.linux-foundation.org, netdev@vger.kernel.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:54427 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751823AbZIYVxU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2009 17:53:20 -0400
In-Reply-To: <20090925205206.GA9270@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 25 September 2009, Anton Vorontsov wrote:
> As noticed by Alan Stern, there is still one issue with the driver:
> we disable PCI IRQ on suspend, but other devices on the same IRQ
> line might still need the IRQ enabled to suspend properly.
> 
> Nowadays, PCI core handles all power management work by itself, with
> one condition though: if we use dev_pm_ops. So, rework the driver to
> only quiesce 3c59x internal logic on suspend, while PCI core will
> manage PCI device power state with IRQs disabled.
> 
> Suggested-by: Rafael J. Wysocki <rjw@sisk.pl>

Acked-by: Rafael J. Wysocki <rjw@sisk.pl>

> Suggested-by: Alan Stern <stern@rowland.harvard.edu>
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> ---
>  drivers/net/3c59x.c |   77 +++++++++++++++++++++++++--------------------------
>  1 files changed, 38 insertions(+), 39 deletions(-)
> 
> diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
> index 7cdd4b0..dee2320 100644
> --- a/drivers/net/3c59x.c
> +++ b/drivers/net/3c59x.c
> @@ -799,52 +799,54 @@ static void poll_vortex(struct net_device *dev)
>  
>  #ifdef CONFIG_PM
>  
> -static int vortex_suspend(struct pci_dev *pdev, pm_message_t state)
> +static int vortex_suspend(struct device *dev)
>  {
> -	struct net_device *dev = pci_get_drvdata(pdev);
> +	struct pci_dev *pdev = to_pci_dev(dev);
> +	struct net_device *ndev = pci_get_drvdata(pdev);
> +
> +	if (!ndev || !netif_running(ndev))
> +		return 0;
> +
> +	netif_device_detach(ndev);
> +	vortex_down(ndev, 1);
>  
> -	if (dev && netdev_priv(dev)) {
> -		if (netif_running(dev)) {
> -			netif_device_detach(dev);
> -			vortex_down(dev, 1);
> -			disable_irq(dev->irq);
> -		}
> -		pci_save_state(pdev);
> -		pci_enable_wake(pdev, pci_choose_state(pdev, state), 0);
> -		pci_disable_device(pdev);
> -		pci_set_power_state(pdev, pci_choose_state(pdev, state));
> -	}
>  	return 0;
>  }
>  
> -static int vortex_resume(struct pci_dev *pdev)
> +static int vortex_resume(struct device *dev)
>  {
> -	struct net_device *dev = pci_get_drvdata(pdev);
> -	struct vortex_private *vp = netdev_priv(dev);
> +	struct pci_dev *pdev = to_pci_dev(dev);
> +	struct net_device *ndev = pci_get_drvdata(pdev);
>  	int err;
>  
> -	if (dev && vp) {
> -		pci_set_power_state(pdev, PCI_D0);
> -		pci_restore_state(pdev);
> -		err = pci_enable_device(pdev);
> -		if (err) {
> -			pr_warning("%s: Could not enable device\n",
> -				dev->name);
> -			return err;
> -		}
> -		pci_set_master(pdev);
> -		if (netif_running(dev)) {
> -			err = vortex_up(dev);
> -			if (err)
> -				return err;
> -			enable_irq(dev->irq);
> -			netif_device_attach(dev);
> -		}
> -	}
> +	if (!ndev || !netif_running(ndev))
> +		return 0;
> +
> +	err = vortex_up(ndev);
> +	if (err)
> +		return err;
> +
> +	netif_device_attach(ndev);
> +
>  	return 0;
>  }
>  
> -#endif /* CONFIG_PM */
> +static struct dev_pm_ops vortex_pm_ops = {
> +	.suspend = vortex_suspend,
> +	.resume = vortex_resume,
> +	.freeze = vortex_suspend,
> +	.thaw = vortex_resume,
> +	.poweroff = vortex_suspend,
> +	.restore = vortex_resume,
> +};
> +
> +#define VORTEX_PM_OPS (&vortex_pm_ops)
> +
> +#else /* !CONFIG_PM */
> +
> +#define VORTEX_PM_OPS NULL
> +
> +#endif /* !CONFIG_PM */
>  
>  #ifdef CONFIG_EISA
>  static struct eisa_device_id vortex_eisa_ids[] = {
> @@ -3191,10 +3193,7 @@ static struct pci_driver vortex_driver = {
>  	.probe		= vortex_init_one,
>  	.remove		= __devexit_p(vortex_remove_one),
>  	.id_table	= vortex_pci_tbl,
> -#ifdef CONFIG_PM
> -	.suspend	= vortex_suspend,
> -	.resume		= vortex_resume,
> -#endif
> +	.driver.pm	= VORTEX_PM_OPS,
>  };

Thanks,
Rafael
