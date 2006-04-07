From: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 19/21] orinoco: reduce differences between PCI drivers, create orinoco_pci.h
Date: Sat, 8 Apr 2006 00:10:41 +0200
Message-ID: <20060407221041.GC15720@electric-eye.fr.zoreil.com>
References: <20060407081019.16107.67672.stgit@dv.roinet.com> <20060407081057.16107.82106.stgit@dv.roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20060407081057.16107.82106.stgit-fdEtzkpK75rby3iVrkZq2A@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org> :
> index 0000000..b05a9a5
> --- /dev/null
> +++ b/drivers/net/wireless/orinoco_pci.h
[...]
> +static int orinoco_pci_resume(struct pci_dev *pdev)
> +{
> +	struct net_device *dev = pci_get_drvdata(pdev);
> +	struct orinoco_private *priv = netdev_priv(dev);
> +	unsigned long flags;
> +	int err;
> +
> +	pci_set_power_state(pdev, 0);
> +	pci_enable_device(pdev);
> +	pci_restore_state(pdev);
> +
> +	err = request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
> +			  dev->name, dev);
> +	if (err) {
> +		printk(KERN_ERR "%s: cannot re-allocate IRQ on resume\n",
> +		       dev->name);
> +		pci_disable_device(pdev);
> +		return -EBUSY;
> +	}
> +
> +	err = orinoco_reinit_firmware(dev);
> +	if (err) {
> +		printk(KERN_ERR "%s: error %d re-initializing firmware "
> +		       "on resume\n", dev->name, err);
> +		return err;
> +	}
> +
> +	spin_lock_irqsave(&priv->lock, flags);

Interruptions are enabled. No need to save/restore.

> +
> +	netif_device_attach(dev);
> +
> +	priv->hw_unavailable--;
> +
> +	if (priv->open && (! priv->hw_unavailable)) {
> +		err = __orinoco_up(dev);

I wonder if it would be enough to issue hermes_set_irqmask() later
in __orinoco_up() to release this irq disabled section.

-- 
Ueimor


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
