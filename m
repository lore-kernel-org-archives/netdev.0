From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 3/3] dl2k: Implement suspend
Date: Tue, 17 Nov 2015 23:56:10 +0100
Message-ID: <20151117225610.GB3362@electric-eye.fr.zoreil.com>
References: <1447781298-19785-1-git-send-email-linux@rainbow-software.org>
 <1447781298-19785-3-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Kernel development list <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1447781298-19785-3-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ondrej Zary <linux@rainbow-software.org> :
[...]
> diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
> index 9e9baa0..b53dfa7 100644
> --- a/drivers/net/ethernet/dlink/dl2k.c
> +++ b/drivers/net/ethernet/dlink/dl2k.c
> @@ -1824,11 +1824,57 @@ rio_remove1 (struct pci_dev *pdev)
>  	}
>  }
>  
> +#ifdef CONFIG_PM
> +static int rio_suspend(struct pci_dev *pdev, pm_message_t state)
> +{
> +	struct net_device *dev = pci_get_drvdata(pdev);
> +	struct netdev_private *np = netdev_priv(dev);
> +
> +	pci_save_state(pdev);

Cargo-cultism ?

> +
> +	if (netif_running(dev)) {
> +		netif_device_detach(dev);
> +		del_timer_sync(&np->timer);
> +		rio_hw_stop(dev);
> +		free_list(dev);

If free_list is used here, so must alloc_list be in resume, whence
an extra failure opportunity.

You may not need to free both Tx and Rx here.

[...]
>  static struct pci_driver rio_driver = {
>  	.name		= "dl2k",
>  	.id_table	= rio_pci_tbl,
>  	.probe		= rio_probe1,
>  	.remove		= rio_remove1,
> +#ifdef CONFIG_PM
> +	.suspend	= rio_suspend,
> +	.resume		= rio_resume,
> +#endif /* CONFIG_PM */

It looks a bit old school.

See Documentation/power/pci.txt and drivers/net/ethernet/via/via-rhine.c
for an instance of SIMPLE_DEV_PM_OPS.

At some point you'll probably support runtime power management though.

-- 
Ueimor
