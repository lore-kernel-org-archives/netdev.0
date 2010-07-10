From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] Export SMBIOS provided firmware instance and label to
 sysfs
Date: Sat, 10 Jul 2010 10:49:38 -0700
Message-ID: <20100710174938.GA22779@kroah.com>
References: <20100710171445.GA24568@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, matt_domsch@dell.com,
	charles_rose@dell.com, jordan_hargrave@dell.com,
	vijay_nijhawan@dell.com
To: Narendra K <Narendra_K@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:60259 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750757Ab0GJRwI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jul 2010 13:52:08 -0400
Content-Disposition: inline
In-Reply-To: <20100710171445.GA24568@auslistsprd01.us.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 10, 2010 at 12:14:45PM -0500, Narendra K wrote:
> +static char smbios_attr[4096];

Interesting size, too bad you don't reference it again:

> +			if (attribute == SMBIOS_ATTR_INSTANCE_SHOW)
> +				return scnprintf(smbios_attr, PAGE_SIZE,
> +						"%d\n", donboard->instance);
> +			else if (attribute == SMBIOS_ATTR_LABEL_SHOW)
> +				return scnprintf(smbios_attr, PAGE_SIZE,
> +						"%s\n", dmi->name);

PAGE_SIZE here?

Which is it (note, some arches PAGE_SIZE is not 4k...)

> +			return strlen(dmi->name);
> +		}
> +	}
> +	return 0;
> +}
> +
> +static ssize_t
> +smbiosname_show(struct device *dev, struct device_attribute *attr, char *buf)
> +{
> +	ssize_t result;
> +	result = smbios_instance_string_exist(&dev->kobj, &attr->attr,
> +					      SMBIOS_ATTR_LABEL_SHOW);
> +	strncpy(buf, smbios_attr, result);
> +	return result;
> +}
> +
> +static ssize_t
> +smbiosinstance_show(struct device *dev,
> +		    struct device_attribute *attr, char *buf)
> +{
> +	ssize_t result;
> +	result = smbios_instance_string_exist(&dev->kobj, &attr->attr,
> +					      SMBIOS_ATTR_INSTANCE_SHOW);
> +	strncpy(buf, smbios_attr, result);
> +	return result;
> +}
> +
> +static struct device_attribute smbios_attr_label = {
> +	.attr = {.name = "label", .mode = 0444, .owner = THIS_MODULE},
> +	.show = smbiosname_show,
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
> +	if (smbios_attr_group.is_visible &&

You set .is_visable above, how could it not be set?

> +		smbios_attr_group.is_visible(&pdev->dev.kobj, NULL, 0)) {
> +		if (!sysfs_create_group(&pdev->dev.kobj, &smbios_attr_group))
> +			return 0;

No, sysfs_create_group will call .is_visable, right?  You shouldn't need
to call it yourself or check it, at all.

> +static int
> +pci_remove_smbiosname_file(struct pci_dev *pdev)
> +{
> +	if (smbios_attr_group.is_visible &&
> +		smbios_attr_group.is_visible(&pdev->dev.kobj, NULL, 0)) {
> +		sysfs_remove_group(&pdev->dev.kobj, &smbios_attr_group);
> +		return 0;

Same here, you shouldn't have to check .is_visable.

> +	}
> +	return -1;

Why -1?  Please use a real error value.

thanks,

greg k-h
