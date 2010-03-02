From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] Export smbios strings associated with onboard devices
 to sysfs
Date: Tue, 2 Mar 2010 10:28:52 -0800
Message-ID: <20100302182852.GB16285@kroah.com>
References: <20100225202941.GA19404@mock.linuxdev.us.dell.com>
 <20100225204905.GC20147@mdomsch-pws380.aus.amer.dell.com>
 <EDA0A4495861324DA2618B4C45DCB3EE6122A2@blrx3m08.blr.amer.dell.com>
 <20100302173302.GA20936@mock.linuxdev.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: matt_domsch@dell.com, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, linux-pci@vger.kernel.org,
	jordan_hargrave@dell.com, sandeep_k_shandilya@dell.com,
	charles_rose@dell.com, shyam_iyer@dell.com
To: Narendra K <Narendra_K@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100302173302.GA20936@mock.linuxdev.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 02, 2010 at 11:33:04AM -0600, Narendra K wrote:
> diff --git a/drivers/pci/pci-sysfs.c b/drivers/pci/pci-sysfs.c
> index 807224e..85d5d79 100644
> --- a/drivers/pci/pci-sysfs.c
> +++ b/drivers/pci/pci-sysfs.c
> @@ -142,6 +142,54 @@ static ssize_t modalias_show(struct device *dev, struct device_attribute *attr,
>  		       (u8)(pci_dev->class));
>  }
>  
> +#ifdef CONFIG_DMI
> +#include <linux/dmi.h>

#includes go at the top of the file.

Can you just create a pci-dmi.c and put this in that .c that way you
don't need any #ifdefs in a .c file?

> +static ssize_t
> +smbiosname_string_is_valid(struct device *dev, char *buf)
> +{
> +	struct pci_dev *pdev = to_pci_dev(dev);
> +  	struct dmi_device *dmi;
> +  	struct dmi_devslot *dslot;
> +  	int bus;
> +  	int devfn;
> +
> +  	bus = pdev->bus->number;
> +  	devfn = pdev->devfn;
> +
> +  	dmi = NULL;
> +  	while ((dmi = dmi_find_device(DMI_DEV_TYPE_DEVSLOT, NULL, dmi)) != NULL) {
> +    		dslot = dmi->device_data;
> +    		if (dslot && dslot->bus == bus && dslot->devfn == devfn) {
> +			if (buf)
> +      				return scnprintf(buf, PAGE_SIZE, "%s\n", dmi->name);
> +			return strlen(dmi->name);
> +		}
> +	}
> +}
> +
> +static ssize_t
> +smbiosname_show(struct device *dev, struct device_attribute *attr, char *buf)
> +{
> +	return smbiosname_string_is_valid(dev, buf);
> +
> +}
> +
> +struct smbios_attribute {
> +	struct attribute attr;
> +	ssize_t(*show) (struct device * edev, char *buf);
> +	int (*test) (struct device * edev, char *buf);
> +};

Why are you creating your own attribute type?

> +
> +#define SMBIOSNAME_DEVICE_ATTR(_name, _mode, _show, _test) \
> +struct smbios_attribute smbios_attr_##_name = { 	\
> +	.attr = {.name = __stringify(_name), .mode = _mode },	\
> +	.show	= _show,				\
> +	.test	= _test,				\
> +};
> +
> +static SMBIOSNAME_DEVICE_ATTR(smbiosname, 0444, smbiosname_show, smbiosname_string_is_valid);

Why are you creating a #define that is only used once?

What is wrong with a "normal" device attribute that you can not use it
here?

> +#endif
> +
>  static ssize_t is_enabled_store(struct device *dev,
>  				struct device_attribute *attr, const char *buf,
>  				size_t count)
> @@ -1140,6 +1188,7 @@ static int __init pci_sysfs_init(void)
>  {
>  	struct pci_dev *pdev = NULL;
>  	int retval;
> +	struct smbios_attribute *attr = &smbios_attr_smbiosname;
>  
>  	sysfs_initialized = 1;
>  	for_each_pci_dev(pdev) {
> @@ -1148,6 +1197,11 @@ static int __init pci_sysfs_init(void)
>  			pci_dev_put(pdev);
>  			return retval;
>  		}
> +#ifdef CONFIG_DMI
> +		/* if the device does not have an associated smbios string in the smbios table, do not create this attribute */ 
> +		if (attr->test && attr->test(&pdev->dev, NULL))
> +			sysfs_create_file(&pdev->dev.kobj, &attr->attr);
> +#endif

Put this in a new function and call it in a different file.

And how are you handling pci devices that are added after the pci
subsystem is initialized (think pci hotplug).

And where are you removing this sysfs file?

Why not put this in the pci_create_sysfs_dev_files function?

thanks,

greg k-h
