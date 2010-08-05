From: Patrick Pannuto <ppannuto@codeaurora.org>
Subject: Re: [PATCH] platform: Facilitate the creation of pseduo-platform
 busses
Date: Wed, 04 Aug 2010 17:57:12 -0700
Message-ID: <4C5A0C68.9080500@codeaurora.org>
References: <4C59E654.1090403@codeaurora.org> <877hk56hiy.fsf@deeprootsystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"damm@opensource.se" <damm@opensource.se>,
	"lethal@linux-sh.org" <lethal@linux-sh.org>,
	"rjw@sisk.pl" <rjw@sisk.pl>,
	"eric.y.miao@gmail.com" <eric.y.miao@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>, alan@lxorguk.ukuu.org.uk,
	zt.tmzt@gmail.com, grant.likely@secretlab.ca, magnus.damm@gmail.com
To: Kevin Hilman <khilman@deeprootsystems.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <877hk56hiy.fsf@deeprootsystems.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/04/2010 05:16 PM, Kevin Hilman wrote:
> Patrick Pannuto <ppannuto@codeaurora.org> writes:
> 
>> Inspiration for this comes from:
>> http://www.mail-archive.com/linux-omap@vger.kernel.org/msg31161.html
> 
> Also, later in that thread I also wrote[1] what seems to be the core of
> what you've done here: namely, allow platform_devices and
> platform_drivers to to be used on custom busses.  Patch is at the end of
> this mail with a more focused changelog.  As Greg suggested in his reply
> to your first version, this part could be merged today, and the
> platform_bus_init stuff could be added later, after some more review.
> Some comments below...
> 

I can split this into 2 patches.

Was your patch sent to linux-kernel or just linux-omap? I'm not on linux-omap...


>> [snip]
>>
>> Which will allow the same driver to easily to used on either
>> the platform bus or the newly defined bus type.
> 
> Except it requires a re-compile.
> 
> Rather than doing this at compile time, it would be better to support
> legacy devices at runtime.  You could handle this by simply registering
> the driver on the custom bus and the platform_bus and let the bus
> matching code handle it.  Then, the same binary would work on both
> legacy and updated SoCs.
> 

Can you safely register a driver on more than one bus? I didn't think
that was safe -- normally it's impossible since you're calling

struct BUS_TYPE_driver mydriver;
BUS_TYPE_driver_register(&mydriver)

but now we have multiple "bus types" that are all actually platform type; still,
at a minimum you would need:
	struct platform_driver mydrvier1 = {
		.driver.bus = &sub_bus1,
	};
	struct platform_driver mydrvier2 = {
		.driver.bus = &sub_bus2,
	};
which would all point to the same driver functions, yet the respective devices
attached for the "same" driver would be on different buses. I fear this might
confuse some drivers. I don't think dynamic bus assignment is this easy

In short: I do not believe the same driver can be registered on multiple
different buses -- if this is wrong, please correct me.

> 
> Up to here, this looks exactly what I wrote in thread referenced above.
> 

It is, you just went on vacation :)

>>  
>>  	if (code != retval)
>>  		platform_driver_unregister(drv);
>> @@ -1017,6 +1019,26 @@ struct bus_type platform_bus_type = {
>>  };
>>  EXPORT_SYMBOL_GPL(platform_bus_type);
>>  
>> +/** platform_bus_type_init - fill in a pseudo-platform-bus
>> +  * @bus: foriegn bus type
>> +  *
>> +  * This init is basically a selective memcpy that
>> +  * won't overwrite any user-defined attributes and
>> +  * only copies things that platform bus defines anyway
>> +  */
> 
> minor nit: kernel doc style has wrong indentation
> 

will fix

>> +void platform_bus_type_init(struct bus_type *bus)
>> +{
>> +	if (!bus->dev_attrs)
>> +		bus->dev_attrs = platform_bus_type.dev_attrs;
>> +	if (!bus->match)
>> +		bus->match = platform_bus_type.match;
>> +	if (!bus->uevent)
>> +		bus->uevent = platform_bus_type.uevent;
>> +	if (!bus->pm)
>> +		bus->pm = platform_bus_type.pm;
>> +}
>> +EXPORT_SYMBOL_GPL(platform_bus_type_init);
> 
> With this approach, you should note in the comments/changelog that
> any selective customization of the bus PM methods must be done after 
> calling platform_bus_type_init().

No they don't. If you call platform_bus_type_init first then you'll
just overwrite them with new values; if you call it second then they
will all already be well-defined and thus not overwritten.

> 
> Also, You've left out the legacy PM methods here.  That implies that
> moving a driver from the platform_bus to the custom bus is not entirely
> transparent.  If the driver still has legacy PM methods, it would stop
> working on the custom bus.
> 
> While this is good motivation for converting a driver to dev_pm_ops, at
> a minimum it should be clear in the changelog that the derivative busses
> do not support legacy PM methods.  However, since it's quite easy to do,
> and you want the derivative busses to be *exactly* like the platform bus
> except where explicitly changed, I'd suggest you also check/copy the
> legacy PM methods.
> 
> In addition, you've missed several fields in 'struct bus_type'
> (bus_attr, drv_attr, p, etc.)  Without digging deeper into the driver
> core, I'm not sure if they are all needed at init time, but it should be
> clear in the comments why they can be excluded.
> 

I copied everything that was defined for platform_bus_type:

struct bus_type platform_bus_type = {
	.name		= "platform",
	.dev_attrs	= platform_dev_attrs,
	.match		= platform_match,
	.uevent		= platform_uevent,
	.pm		= &platform_dev_pm_ops,
};
EXPORT_SYMBOL_GPL(platform_bus_type);

struct bus_type {
	const char		*name;
	struct bus_attribute	*bus_attrs;
	struct device_attribute	*dev_attrs;
	struct driver_attribute	*drv_attrs;

	int (*match)(struct device *dev, struct device_driver *drv);
	int (*uevent)(struct device *dev, struct kobj_uevent_env *env);
	int (*probe)(struct device *dev);
	int (*remove)(struct device *dev);
	void (*shutdown)(struct device *dev);

	int (*suspend)(struct device *dev, pm_message_t state);
	int (*resume)(struct device *dev);

	const struct dev_pm_ops *pm;

	struct bus_type_private *p;
};

It is my understanding that everything that I did not copy *should* remain
unique to each bus; remaining fields will be filled in by bus_register and
should not be copied.

> Kevin
> 
> [1] http://www.mail-archive.com/linux-omap@vger.kernel.org/msg31289.html
> 
> 
> From b784009af1d0a7065dc5e58a13ce29afa3432d3e Mon Sep 17 00:00:00 2001
> From: Kevin Hilman <khilman@deeprootsystems.com>
> Date: Mon, 28 Jun 2010 16:08:14 -0700
> Subject: [PATCH] driver core: allow platform_devices and platform_drivers on custom busses
> 
> This allows platform_devices and platform_drivers to be registered onto
> custom busses that are compatible with the platform_bus.
> 
> Signed-off-by: Kevin Hilman <khilman@deeprootsystems.com>
> ---
>  drivers/base/platform.c |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/base/platform.c b/drivers/base/platform.c
> index 4d99c8b..2cf55e2 100644
> --- a/drivers/base/platform.c
> +++ b/drivers/base/platform.c
> @@ -241,7 +241,8 @@ int platform_device_add(struct platform_device *pdev)
>  	if (!pdev->dev.parent)
>  		pdev->dev.parent = &platform_bus;
>  
> -	pdev->dev.bus = &platform_bus_type;
> +	if (!pdev->dev.bus)
> +		pdev->dev.bus = &platform_bus_type;
>  
>  	if (pdev->id != -1)
>  		dev_set_name(&pdev->dev, "%s.%d", pdev->name,  pdev->id);
> @@ -482,7 +483,8 @@ static void platform_drv_shutdown(struct device *_dev)
>   */
>  int platform_driver_register(struct platform_driver *drv)
>  {
> -	drv->driver.bus = &platform_bus_type;
> +	if (!drv->driver.bus)
> +		drv->driver.bus = &platform_bus_type;
>  	if (drv->probe)
>  		drv->driver.probe = platform_drv_probe;
>  	if (drv->remove)
> @@ -539,12 +541,12 @@ int __init_or_module platform_driver_probe(struct platform_driver *drv,
>  	 * if the probe was successful, and make sure any forced probes of
>  	 * new devices fail.
>  	 */
> -	spin_lock(&platform_bus_type.p->klist_drivers.k_lock);
> +	spin_lock(&drv->driver.bus->p->klist_drivers.k_lock);
>  	drv->probe = NULL;
>  	if (code == 0 && list_empty(&drv->driver.p->klist_devices.k_list))
>  		retval = -ENODEV;
>  	drv->driver.probe = platform_drv_probe_fail;
> -	spin_unlock(&platform_bus_type.p->klist_drivers.k_lock);
> +	spin_unlock(&drv->driver.bus->p->klist_drivers.k_lock);
>  
>  	if (code != retval)
>  		platform_driver_unregister(drv);

If you would like to lead this effort, please do so; I did not mean to step
on your toes, it's just that this is an issue for me as well. You had
indicated that you were going on vacation for a month and I had not seen any
more follow-up on this issue, so I forged ahead.  If you'd like me to drop it,
please let me know and I will - but also please send stuff like this to wider
distribution than just linux-omap; it has much greater reach (and interest).

Thanks,
-Pat

-- 
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum
