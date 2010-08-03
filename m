From: Patrick Pannuto <ppannuto@codeaurora.org>
Subject: Re: [RFC PATCH] platform: Faciliatate the creation of pseduo-platform
 busses
Date: Tue, 03 Aug 2010 16:36:48 -0700
Message-ID: <4C58A810.1060800@codeaurora.org>
References: <4C58A7AA.8020007@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@suse.de>, damm@opensource.se,
	lethal@linux-sh.org, rjw@sisk.pl, dtor@mail.ru,
	eric.y.miao@gmail.com, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:30767 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756799Ab0HCXgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 19:36:48 -0400
In-Reply-To: <4C58A7AA.8020007@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mis-typed omap's list; sorry for the resend

On 08/03/2010 04:35 PM, Patrick Pannuto wrote:
> Inspiration for this comes from:
> http://www.mail-archive.com/linux-omap@vger.kernel.org/msg31161.html
> 
> INTRO
> 
> As SOCs become more popular, the desire to quickly define a simple,
> but functional, bus type with only a few unique properties becomes
> desirable. As they become more complicated, the ability to nest these
> simple busses and otherwise orchestrate them to match the actual
> topology also becomes desirable.
> 
> EXAMPLE USAGE
> 
> /arch/ARCH/MY_ARCH/my_bus.c:
> 
> 	#include <linux/device.h>
> 	#include <linux/platform_device.h>
> 
> 	struct bus_type my_bus_type = {
> 		.name	= "mybus",
> 	};
> 	EXPORT_SYMBOL_GPL(my_bus_type);
> 
> 	struct platform_device sub_bus1 = {
> 		.name		= "sub_bus1",
> 		.id		= -1,
> 		.dev.bus	= &my_bus_type,
> 	}
> 	EXPORT_SYMBOL_GPL(sub_bus1);
> 
> 	struct platform_device sub_bus2 = {
> 		.name		= "sub_bus2",
> 		.id		= -1,
> 		.dev.bus	= &my_bus_type,
> 	}
> 	EXPORT_SYMBOL_GPL(sub_bus2);
> 
> 	static int __init my_bus_init(void)
> 	{
> 		int error;
> 		platform_bus_type_init(&my_bus_type);
> 
> 		error = bus_register(&my_bus_type);
> 		if (error)
> 			return error;
> 
> 		error = platform_device_register(&sub_bus1);
> 		if (error)
> 			goto fail_sub_bus1;
> 
> 		error = platform_device_register(&sub_bus2);
> 		if (error)
> 			goto fail_sub_bus2;
> 
> 		return error;
> 
> 	fail_sub_bus2:
> 		platform_device_unregister(&sub_bus1);
> 	fail_sub_bus2:
> 		bus_unregister(&my_bus_type);
> 
> 		return error;
> 	}
> 	postcore_initcall(my_bus_init);
> 	EXPORT_SYMBOL_CPY(my_bus_init);
> 
> /drivers/my_driver.c
> 	static struct platform_driver my_driver = {
> 		.driver	= {
> 			.name	= "my-driver",
> 			.owner	= THIS_MODULE,
> 			.bus	= &my_bus_type,
> 		},
> 	};
> 
> /somewhere/my_device.c
> 	static struct platform_device my_device = {
> 		.name		= "my-device",
> 		.id		= -1,
> 		.dev.bus	= &my_bus_type,
> 		.dev.parent	= &sub_bus_1.dev,
> 	};
> 
> Notice that for a device / driver, only 3 lines were added to
> switch from the platform bus to the new my_bus. This is
> especially valuable if we consider supporting a legacy SOCs
> and new SOCs where the same driver is used, but may need to
> be on either the platform bus or the new my_bus. The above
> code then becomes:
> 
> 	(possibly in a header)
> 	#ifdef CONFIG_MY_BUS
> 	#define MY_BUS_TYPE	&my_bus_type
> 	#else
> 	#define MY_BUS_TYPE	NULL
> 	#endif
> 
> /drivers/my_driver.c
> 	static struct platform_driver my_driver = {
> 		.driver	= {
> 			.name	= "my-driver",
> 			.owner	= THIS_MODULE,
> 			.bus	= MY_BUS_TYPE,
> 		},
> 	};
> 
> Which will allow the same driver to easily to used on either
> the platform bus or the newly defined bus type.
> 
> This will build a device tree that mirrors the actual configuration:
>     /sys/bus
>     |-- my_bus
>     |   |-- devices
>     |   |   |-- sub_bus1 -> ../../../devices/platform/sub_bus1
>     |   |   |-- sub_bus2 -> ../../../devices/platform/sub_bus2
>     |   |   |-- my-device -> ../../../devices/platform/sub_bus1/my-device
>     |   |-- drivers
>     |   |   |-- my-driver
> 
> I believe this to be a fairly elegant and simple solution to the
> problem, but humbly RFC
> 
> -Pat
> 
> Signed-off-by: Patrick Pannuto <ppannuto@codeaurora.org>
> ---
>  drivers/base/platform.c         |   30 ++++++++++++++++++++++++++----
>  include/linux/platform_device.h |    2 ++
>  2 files changed, 28 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/base/platform.c b/drivers/base/platform.c
> index 4d99c8b..c86be03 100644
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
> @@ -1017,6 +1019,26 @@ struct bus_type platform_bus_type = {
>  };
>  EXPORT_SYMBOL_GPL(platform_bus_type);
>  
> +/** platform_bus_type_init - fill in a pseudo-platform-bus
> +  * @bus: foriegn bus type
> +  *
> +  * This init is basically a selective memcpy that
> +  * won't overwrite any user-defined attributes and
> +  * only copies things that platform bus defines anyway
> +  */
> +void platform_bus_type_init(struct bus_type *bus)
> +{
> +	if (!bus->dev_attrs)
> +		bus->dev_attrs = platform_bus_type.dev_attrs;
> +	if (!bus->match)
> +		bus->match = platform_bus_type.match;
> +	if (!bus->uevent)
> +		bus->uevent = platform_bus_type.uevent;
> +	if (!bus->pm)
> +		bus->pm = platform_bus_type.pm;
> +}
> +EXPORT_SYMBOL_GPL(platform_bus_type_init);
> +
>  int __init platform_bus_init(void)
>  {
>  	int error;
> diff --git a/include/linux/platform_device.h b/include/linux/platform_device.h
> index 5417944..fa8c35a 100644
> --- a/include/linux/platform_device.h
> +++ b/include/linux/platform_device.h
> @@ -79,6 +79,8 @@ extern int platform_driver_probe(struct platform_driver *driver,
>  #define platform_get_drvdata(_dev)	dev_get_drvdata(&(_dev)->dev)
>  #define platform_set_drvdata(_dev,data)	dev_set_drvdata(&(_dev)->dev, (data))
>  
> +extern void platform_bus_type_init(struct bus_type *);
> +
>  extern struct platform_device *platform_create_bundle(struct platform_driver *driver,
>  					int (*probe)(struct platform_device *),
>  					struct resource *res, unsigned int n_res,


-- 
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum
