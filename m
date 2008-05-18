From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: hibernate event order question
Date: Sun, 18 May 2008 12:45:13 +0200
Message-ID: <200805181245.13899.rjw@sisk.pl>
References: <20080517175046.GA9032@yamamaya.is-a-geek.org> <20080517223622.GA2668@yamamaya.is-a-geek.org> <20080517232411.GA8792@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>
To: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756428AbYERKpg@vger.kernel.org>
In-Reply-To: <20080517232411.GA8792@yamamaya.is-a-geek.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday, 18 of May 2008, Tobias Diedrich wrote:
> Tobias Diedrich wrote:
> > > > Shouldn't there be a 'prepare for poweroff'-callback, which gets
> > > > called
> > > > before the system is powered off for real?
> > > 
> > > Yes, it should and it's called in recent kernels.
> > 
> > For what values of 'recent'?
> > I'm running 2.6.26-rc2 here. :)
> > How do I hook into this callback?
> > (suspend_late maybe? Going to try that one next...)
> 
> Ok, this patch fixes the 'regression' introduced by the previous
> patch (at least for me ;)):

Well, what exactly do you do to hibernate the box?


> Index: linux-2.6.26-rc2.forcedwol/drivers/net/forcedeth.c
> ===================================================================
> --- linux-2.6.26-rc2.forcedwol.orig/drivers/net/forcedeth.c	2008-05-18 01:10:18.000000000 +0200
> +++ linux-2.6.26-rc2.forcedwol/drivers/net/forcedeth.c	2008-05-18 01:11:33.000000000 +0200
> @@ -5828,8 +5828,24 @@
>  out:
>  	return rc;
>  }
> +
> +static void nv_shutdown(struct pci_dev *pdev)
> +{
> +	struct net_device *dev = pci_get_drvdata(pdev);
> +	struct fe_priv *np = netdev_priv(dev);
> +	u8 __iomem *base = get_hwbase(dev);
> +
> +	if (netif_running(dev))
> +		nv_close(dev);
> +
> +	pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
> +	pci_enable_wake(pdev, PCI_D3cold, np->wolenabled);
> +	pci_disable_device(pdev);
> +	pci_set_power_state(pdev, PCI_D3hot);
> +}
>  #else
>  #define nv_suspend NULL
> +#define nv_shutdown NULL
>  #define nv_resume NULL
>  #endif /* CONFIG_PM */
>  
> @@ -6000,6 +6016,7 @@
>  	.remove		= __devexit_p(nv_remove),
>  	.suspend	= nv_suspend,
>  	.resume		= nv_resume,
> +	.shutdown	= nv_shutdown,
>  };
>  
>  static int __init init_nic(void)
> 
