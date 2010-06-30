From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 1/2] Export firmware assigned labels of network devices
 to sysfs
Date: Wed, 30 Jun 2010 08:42:20 -0700
Message-ID: <20100630154220.GA12045@kroah.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE612AB6@blrx3m08.blr.amer.dell.com>
 <20100629162818.GA17099@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: matt_domsch@dell.com, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, linux-pci@vger.kernel.org,
	jordan_hargrave@dell.com, charles_rose@dell.com,
	vijay_nijhawan@dell.com
To: Narendra K <Narendra_K@dell.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100629162818.GA17099@auslistsprd01.us.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 29, 2010 at 11:28:18AM -0500, Narendra K wrote:
> --- a/drivers/pci/Makefile
> +++ b/drivers/pci/Makefile
> @@ -4,7 +4,7 @@
>  
>  obj-y		+= access.o bus.o probe.o remove.o pci.o \
>  			pci-driver.o search.o pci-sysfs.o rom.o setup-res.o \
> -			irq.o vpd.o
> +			irq.o vpd.o pci-label.o

No, only build this if CONFIG_DMI is set.

> diff --git a/drivers/pci/pci-label.c b/drivers/pci/pci-label.c
> new file mode 100644
> index 0000000..0f824d6
> --- /dev/null
> +++ b/drivers/pci/pci-label.c
> @@ -0,0 +1,140 @@
> +/*
> + * Purpose: Export the firmware instance/index and label associated with 
> + * a pci device to sysfs
> + * Copyright (C) 2010 Dell Inc.
> + * by Narendra K <Narendra_K@dell.com>, Jordan Hargrave <Jordan_Hargrave@dell.com>
> + *
> + * SMBIOS defines type 41 for onboard pci devices. This code retrieves
> + * the instance number and string from the type 41 record and exports 
> + * it to sysfs.
> + *
> + * Please see http://linux.dell.com/wiki/index.php/Oss/libnetdevname for more
> + * information.
> + */
> +
> +#include <linux/dmi.h>
> +#include <linux/sysfs.h>
> +#include <linux/pci.h>
> +#include <linux/pci_ids.h>
> +#include <linux/module.h>
> +#include "pci.h"
> +
> +#ifndef CONFIG_DMI
> +
> +static inline int 
> +pci_create_smbiosname_file(struct pci_dev *pdev)
> +{
> +	return -1;
> +}
> +
> +static inline int 
> +pci_remove_smbiosname_file(struct pci_dev *pdev)
> +{
> +	return -1;
> +}
> +
> +#else

The above Makefile change will allow you to remove these, right?  You
don't want to create the files if there is nothing that can be in them,
right?

> +pci_create_smbiosname_file(struct pci_dev *pdev)
> +{
> +	if (smbios_attr_label.test && smbios_attr_label.test(&pdev->dev, NULL, NULL)) {
> +		if (sysfs_create_file(&pdev->dev.kobj, &smbios_attr_label.attr))
> +			return -1;

What's wrong with the 'device_create_file' calls?

thanks,

greg k-h
