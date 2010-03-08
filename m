From: Alex Chiang <achiang@hp.com>
Subject: Re: [PATCH] Export smbios strings associated with onboard devices
	to sysfs
Date: Mon, 8 Mar 2010 10:34:00 -0700
Message-ID: <20100308173400.GB20953@ldl.fc.hp.com>
References: <20100225202941.GA19404@mock.linuxdev.us.dell.com> <20100225204905.GC20147@mdomsch-pws380.aus.amer.dell.com> <EDA0A4495861324DA2618B4C45DCB3EE6122A2@blrx3m08.blr.amer.dell.com> <20100302173302.GA20936@mock.linuxdev.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: matt_domsch@dell.com, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, linux-pci@vger.kernel.org,
	jordan_hargrave@dell.com, sandeep_k_shandilya@dell.com,
	charles_rose@dell.com, shyam_iyer@dell.com
To: Narendra K <Narendra_K@dell.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100302173302.GA20936@mock.linuxdev.us.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Narendra K <Narendra_K@dell.com>:
> 
> Resending the patch with review comments incorporated.
> 
> Signed-off-by: Jordan Hargrave <Jordan_Hargrave@dell.com>
> Signed-off-by: Narendra K <Narendra_K@dell.com>
> ---
>  drivers/firmware/dmi_scan.c |   23 ++++++++++++++++++
>  drivers/pci/pci-sysfs.c     |   54 +++++++++++++++++++++++++++++++++++++++++++
>  include/linux/dmi.h         |    9 +++++++
>  3 files changed, 86 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/firmware/dmi_scan.c b/drivers/firmware/dmi_scan.c
> index 31b983d..1d10663 100644
> --- a/drivers/firmware/dmi_scan.c
> +++ b/drivers/firmware/dmi_scan.c
> @@ -278,6 +278,28 @@ static void __init dmi_save_ipmi_device(const struct dmi_header *dm)
>  	list_add_tail(&dev->list, &dmi_devices);
>  }
>  
> +static void __init dmi_save_devslot(int id, int seg, int bus, int devfn, const char *name)
> +{
> +	struct dmi_devslot *slot;
> +
> +	slot = dmi_alloc(sizeof(*slot) + strlen(name) + 1);
> +	if (!slot) {
> +		printk(KERN_ERR "dmi_save_devslot: out of memory.\n");
> +		return;
> +	}	
> +	slot->id = id;
> +	slot->seg = seg;
> +	slot->bus = bus;
> +	slot->devfn = devfn;
> +
> +	strcpy((char *)&slot[1], name);
> +	slot->dev.type = DMI_DEV_TYPE_DEVSLOT;
> +	slot->dev.name = &slot[1];

This needs a cast, else you'll get a warning:

	slot->dev.name = (char *)&slot[1];

Also, when I was playing with your patchset, I noticed that you
should probably add this hunk too:

@@ -334,6 +359,7 @@ static void __init dmi_decode(const struct dmi_header *dm, v
                break;
        case 41:        /* Onboard Devices Extended Information */
                dmi_save_extended_devices(dm);
+               break;
        }
 }
 

> +#ifdef CONFIG_DMI
> +#include <linux/dmi.h>
> +static ssize_t
> +smbiosname_string_is_valid(struct device *dev, char *buf)
> +{
> +	struct pci_dev *pdev = to_pci_dev(dev);
> +  	struct dmi_device *dmi;

This needs to be a const struct dmi_device, else you get a
warning.

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

Whitespace seems messed up here?

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
> +
> +#define SMBIOSNAME_DEVICE_ATTR(_name, _mode, _show, _test) \
> +struct smbios_attribute smbios_attr_##_name = { 	\
> +	.attr = {.name = __stringify(_name), .mode = _mode },	\
> +	.show	= _show,				\
> +	.test	= _test,				\
> +};
> +
> +static SMBIOSNAME_DEVICE_ATTR(smbiosname, 0444, smbiosname_show, smbiosname_string_is_valid);
> +#endif
> +

After a discussion on irc, some folks thought that changing the
name of this attribute to 'label' would be a much better name
than smbiosname.

/ac
