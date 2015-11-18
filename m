From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH 3/3] dl2k: Implement suspend
Date: Wed, 18 Nov 2015 10:10:41 +0100
Message-ID: <201511181010.41920.linux@rainbow-software.org>
References: <1447781298-19785-1-git-send-email-linux@rainbow-software.org> <1447781298-19785-3-git-send-email-linux@rainbow-software.org> <20151117225610.GB3362@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Kernel development list <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151117225610.GB3362@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 17 November 2015, Francois Romieu wrote:
> Ondrej Zary <linux@rainbow-software.org> :
> [...]
>
> > diff --git a/drivers/net/ethernet/dlink/dl2k.c
> > b/drivers/net/ethernet/dlink/dl2k.c index 9e9baa0..b53dfa7 100644
> > --- a/drivers/net/ethernet/dlink/dl2k.c
> > +++ b/drivers/net/ethernet/dlink/dl2k.c
> > @@ -1824,11 +1824,57 @@ rio_remove1 (struct pci_dev *pdev)
> >  	}
> >  }
> >
> > +#ifdef CONFIG_PM
> > +static int rio_suspend(struct pci_dev *pdev, pm_message_t state)
> > +{
> > +	struct net_device *dev = pci_get_drvdata(pdev);
> > +	struct netdev_private *np = netdev_priv(dev);
> > +
> > +	pci_save_state(pdev);
>
> Cargo-cultism ?
>
> > +
> > +	if (netif_running(dev)) {
> > +		netif_device_detach(dev);
> > +		del_timer_sync(&np->timer);
> > +		rio_hw_stop(dev);
> > +		free_list(dev);
>
> If free_list is used here, so must alloc_list be in resume, whence
> an extra failure opportunity.
>
> You may not need to free both Tx and Rx here.

I'll better drop the free_list/alloc_list from suspend/resume (as you 
suggested before).

> [...]
>
> >  static struct pci_driver rio_driver = {
> >  	.name		= "dl2k",
> >  	.id_table	= rio_pci_tbl,
> >  	.probe		= rio_probe1,
> >  	.remove		= rio_remove1,
> > +#ifdef CONFIG_PM
> > +	.suspend	= rio_suspend,
> > +	.resume		= rio_resume,
> > +#endif /* CONFIG_PM */
>
> It looks a bit old school.
>
> See Documentation/power/pci.txt and drivers/net/ethernet/via/via-rhine.c
> for an instance of SIMPLE_DEV_PM_OPS.
>
> At some point you'll probably support runtime power management though.

Thanks for suggestion, I've been looking at the wrong drivers as none of them 
used dev_pm_ops.

-- 
Ondrej Zary
