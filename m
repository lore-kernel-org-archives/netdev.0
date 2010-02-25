From: "Domsch, Matt" <Matt_Domsch@Dell.com>
Subject: Re: [PATCH] Export smbios strings associated with onboard devices to
 sysfs
Date: Thu, 25 Feb 2010 14:49:05 -0600
Message-ID: <20100225204905.GC20147@mdomsch-pws380.aus.amer.dell.com>
References: <20100225202941.GA19404@mock.linuxdev.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"Hargrave, Jordan" <Jordan_Hargrave@Dell.com>,
	"Shandilya, Sandeep K" <Sandeep_K_Shandilya@Dell.com>,
	"Rose, Charles" <Charles_Rose@Dell.com>,
	"Iyer, Shyam" <Shyam_Iyer@Dell.com>
To: "K, Narendra" <Narendra_K@Dell.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100225202941.GA19404@mock.linuxdev.us.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 25, 2010 at 02:29:42PM -0600, K, Narendra wrote:
> 1.Export smbios strings of onboard devices, to sysfs. For example -

I like the idea in this patch, which exports this additional
smbios-provided string in sysfs.  This removes the need to parse the
SMBIOS table in userspace, which requires root privs.

The concept is also extensible to other methods (e.g. ACPI) that I
expect will appear for the platform BIOS to provide naming hints to
the OS - I want those to appear in sysfs also.

now, for the patch:

> diff --git a/drivers/base/bus.c b/drivers/base/bus.c
> index c0c5a43..ad0fcfb 100644
> --- a/drivers/base/bus.c
> +++ b/drivers/base/bus.c
> @@ -419,6 +419,11 @@ static int device_add_attrs(struct bus_type *bus, struct device *dev)
>  		return 0;
>  
>  	for (i = 0; attr_name(bus->dev_attrs[i]); i++) {
> +		/* if the device does not have an associated smbios string in the smbios table, do not create this attribute */ 
> +		if (!(strcmp(attr_name(bus->dev_attrs[i]), "smbiosname"))) {
> +			if (!smbiosname_string_is_valid(dev, NULL)) 
> +				continue;
> +		}
>  		error = device_create_file(dev, &bus->dev_attrs[i]);
>  		if (error) {
>  			while (--i >= 0)

This cannot go in bus.c.  It needs to go in pci-sysfs.c.

> diff --git a/drivers/pci/pci-sysfs.c b/drivers/pci/pci-sysfs.c
> index c5df94e..a3b9bf9 100644
> --- a/drivers/pci/pci-sysfs.c
> +++ b/drivers/pci/pci-sysfs.c
> @@ -324,6 +359,9 @@ struct device_attribute pci_dev_attrs[] = {
>  	__ATTR_RO(class),
>  	__ATTR_RO(irq),
>  	__ATTR_RO(local_cpus),
> +#ifdef CONFIG_DMI
> +	__ATTR_RO(smbiosname),
> +#endif
>  	__ATTR_RO(local_cpulist),

Here, instead of __ATTR_RO(smbiosname), and then finding and ignoring
it in the device core, you need to make the addition of this dynamic.
drivers/firmware/edd.c does something quite like this:

#define __ATTR_RO_TEST(_name, _test) { \
        .attr   = { .name = __stringify(_name), .mode = 0444 }, \
        .show   = _name##_show,                                 \
	.test   = _test,                                        \
}

so it defines a test function to apply before creating the attribute.
See edd.c:edd_populate_dir() for how the .test is evaluated before
calling sysfs_create_file().

Can this be genericized?  I'm sure these two places aren't the only
places where attributes may or may not exist on an object.

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
