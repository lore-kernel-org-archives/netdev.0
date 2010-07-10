From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] Export SMBIOS provided firmware instance and label to
 sysfs
Date: Sat, 10 Jul 2010 10:52:01 -0700
Message-ID: <20100710175201.GB22779@kroah.com>
References: <20100710171445.GA24568@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, matt_domsch@dell.com,
	charles_rose@dell.com, jordan_hargrave@dell.com,
	vijay_nijhawan@dell.com
To: Narendra K <Narendra_K@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100710171445.GA24568@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 10, 2010 at 12:14:45PM -0500, Narendra K wrote:
> +static char smbios_attr[4096];
> +
> +enum smbios_attr_enum {
> +	SMBIOS_ATTR_LABEL_SHOW = 1,
> +	SMBIOS_ATTR_INSTANCE_SHOW,
> +};
> +
> +static mode_t
> +smbios_instance_string_exist(struct kobject *kobj, struct attribute *attr,
> +			     int attribute)
> +{
> +	struct device *dev;
> +	struct pci_dev *pdev;
> +	const struct dmi_device *dmi;
> +	struct dmi_dev_onboard *donboard;
> +	int bus;
> +	int devfn;
> +
> +	dev = container_of(kobj, struct device, kobj);
> +	pdev = to_pci_dev(dev);
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
> +			if (attribute == SMBIOS_ATTR_INSTANCE_SHOW)
> +				return scnprintf(smbios_attr, PAGE_SIZE,
> +						"%d\n", donboard->instance);
> +			else if (attribute == SMBIOS_ATTR_LABEL_SHOW)
> +				return scnprintf(smbios_attr, PAGE_SIZE,
> +						"%s\n", dmi->name);

Wait, depending on the attribute you are looking at, you are placing the
data in a single buffer?  What happens if userspace opens and reads both
files at once?

Please don't use this function for your show attributes, just properly
copy the correct string into the userspace buffer.  This logic just
complicates things a lot more, right?

thanks,

greg k-h
