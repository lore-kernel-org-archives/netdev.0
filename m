From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] Export SMBIOS provided firmware instance and label to
	sysfs
Date: Tue, 20 Jul 2010 20:59:43 -0700
Message-ID: <20100721035943.GF16676@kroah.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE612B93@blrx3m08.blr.amer.dell.com> <20100714121345.GA20411@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, matt_domsch@dell.com,
	charles_rose@dell.com, jordan_hargrave@dell.com,
	vijay_nijhawan@dell.com
To: Narendra K <Narendra_K@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100714121345.GA20411@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 14, 2010 at 07:13:45AM -0500, Narendra K wrote:
> @@ -333,6 +358,7 @@ static void __init dmi_decode(const struct dmi_header *dm, void *dummy)
>  		break;
>  	case 41:	/* Onboard Devices Extended Information */
>  		dmi_save_extended_devices(dm);
> +		break;

Why make this change?  It's not relevant to your patch, right?

> +enum smbios_attr_enum {
> +	SMBIOS_ATTR_NONE = 0,
> +	SMBIOS_ATTR_LABEL_SHOW,
> +	SMBIOS_ATTR_INSTANCE_SHOW,
> +};
> +
> +static mode_t
> +find_smbios_instance_string(struct pci_dev *pdev, char *buf, int attribute)

Why isn't 'attribute' an enumerated type like you just defined above?
Extra type-checking is always good, especially as the variable name
'attribute' means something totally different in other parts of this
file.

> +{
> +	const struct dmi_device *dmi;
> +	struct dmi_dev_onboard *donboard;
> +	int bus;
> +	int devfn;
> +
> +	bus = pdev->bus->number;
> +	devfn = pdev->devfn;
> +
> +	dmi = NULL;
> +	while ((dmi = dmi_find_device(DMI_DEV_TYPE_DEV_ONBOARD,
> +				      NULL, dmi)) != NULL) {
> +		donboard = dmi->device_data;
> +		if (donboard && donboard->bus == bus &&
> +					donboard->devfn == devfn) {
> +			if (buf) {
> +				if (attribute == SMBIOS_ATTR_INSTANCE_SHOW)
> +					return scnprintf(buf, PAGE_SIZE,
> +							 "%d\n",
> +							 donboard->instance);
> +				else if (attribute == SMBIOS_ATTR_LABEL_SHOW)
> +					return scnprintf(buf, PAGE_SIZE,
> +							 "%s\n",
> +							 dmi->name);
> +			}
> +			return strlen(dmi->name);
> +		}
> +	}
> +	return 0;
> +}
> +
> +static mode_t
> +smbios_instance_string_exist(struct kobject *kobj, struct attribute *attr,
> +			     int n)
> +{
> +	struct device *dev;
> +	struct pci_dev *pdev;
> +
> +	dev = container_of(kobj, struct device, kobj);
> +	pdev = to_pci_dev(dev);
> +
> +	return find_smbios_instance_string(pdev, NULL, SMBIOS_ATTR_NONE);
> +}
> +
> +static ssize_t
> +smbioslabel_show(struct device *dev, struct device_attribute *attr, char *buf)
> +{
> +	struct pci_dev *pdev;
> +	pdev = to_pci_dev(dev);
> +
> +	return find_smbios_instance_string(pdev, buf,
> +					   SMBIOS_ATTR_LABEL_SHOW);
> +}
> +
> +static ssize_t
> +smbiosinstance_show(struct device *dev,
> +		    struct device_attribute *attr, char *buf)
> +{
> +	struct pci_dev *pdev;
> +	pdev = to_pci_dev(dev);
> +
> +	return find_smbios_instance_string(pdev, buf,
> +					   SMBIOS_ATTR_INSTANCE_SHOW);
> +}
> +
> +static struct device_attribute smbios_attr_label = {
> +	.attr = {.name = "label", .mode = 0444, .owner = THIS_MODULE},
> +	.show = smbioslabel_show,
> +};
> +
> +static struct device_attribute smbios_attr_instance = {
> +	.attr = {.name = "index", .mode = 0444, .owner = THIS_MODULE},
> +	.show = smbiosinstance_show,
> +};
> +
> +static struct attribute *smbios_attributes[] = {
> +	&smbios_attr_label.attr,
> +	&smbios_attr_instance.attr,
> +	NULL,
> +};
> +
> +static struct attribute_group smbios_attr_group = {
> +	.attrs = smbios_attributes,
> +	.is_visible = smbios_instance_string_exist,
> +};
> +
> +static int
> +pci_create_smbiosname_file(struct pci_dev *pdev)
> +{
> +	if (!sysfs_create_group(&pdev->dev.kobj, &smbios_attr_group))
> +		return 0;
> +	return -ENODEV;
> +}
> +
> +static int
> +pci_remove_smbiosname_file(struct pci_dev *pdev)
> +{
> +		sysfs_remove_group(&pdev->dev.kobj, &smbios_attr_group);
> +		return 0;
> +}

What's with the extra indentation?

Why return a value at all here?

> +
> +int pci_create_firmware_label_files(struct pci_dev *pdev)
> +{
> +	if (!pci_create_smbiosname_file(pdev))
> +		return 0;
> +	return -ENODEV;
> +}
> +
> +int pci_remove_firmware_label_files(struct pci_dev *pdev)
> +{
> +	if (!pci_remove_smbiosname_file(pdev))
> +		return 0;
> +	return -ENODEV;
> +}

Why return values for these two functions if you never check them
anywhere?  Either check the return value and do something with it, or
just make them 'void'.

Also, you need to add documentation for what this sysfs file is and does
in the Documentation/ABI/ directory.  That must be in this patch to have
it acceptable.

thanks,

greg k-h
