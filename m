From: Christoph Hellwig <hch@infradead.org>
Subject: Re: how about the following to elminate pci_find_device() in fore200e?
Date: Mon, 25 Oct 2004 13:56:48 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041025125648.GA32619@infradead.org>
References: <200410251156.i9PBuwV6016648@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Content-Disposition: inline
In-Reply-To: <200410251156.i9PBuwV6016648@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Oct 25, 2004 at 07:56:59AM -0400, chas williams (contractor) wrote:
> we need to keep the linked list around for the sbus devices.  there doesnt
> seem to be something similar to pci_module_init() for sbus devices.
> 
> ===== drivers/atm/fore200e.c 1.30 vs edited =====
> --- 1.30/drivers/atm/fore200e.c	2004-07-29 18:27:53 -04:00
> +++ edited/drivers/atm/fore200e.c	2004-10-24 22:12:20 -04:00
> @@ -113,7 +113,7 @@
>  static const struct atmdev_ops   fore200e_ops;
>  static const struct fore200e_bus fore200e_bus[];
>  
> -static struct fore200e* fore200e_boards = NULL;
> +LIST_HEAD(fore200e_boards);

should still be static (yes, static LIST_HEAD(foo); is okay)

> +static int __devinit
> +fore200e_pca_detect(struct pci_dev *pci_dev, const struct pci_device_id *pci_ent)
> +{
> +    const struct fore200e_bus* bus = (struct fore200e_bus*) pci_ent->driver_data;
> +    struct fore200e* fore200e;
> +    int err = 0;
> +    static int index = 0;
> +
> +    if (pci_enable_device(pci_dev)) {
> +	err = -EINVAL;
> +	goto out;
> +    }
>

indentation looks messed but, but I assume you did this to match the
rest of the file?

> +#ifdef CONFIG_ATM_FORE200E_PCA
> +    if (!pci_module_init(&fore200e_pca_driver))
> +	return 0;
> +#endif
> +
> +    if (!list_empty(&fore200e_boards))
> +	return 0;

the driver only supports either sbus or pci at the same time?
