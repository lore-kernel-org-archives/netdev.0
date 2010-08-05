From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH] platform: Facilitate the creation of pseduo-platform busses
Date: Wed, 04 Aug 2010 17:16:05 -0700
Message-ID: <877hk56hiy.fsf@deeprootsystems.com>
References: <4C59E654.1090403@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-msm\@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
	"linux-omap\@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"damm\@opensource.se" <damm@opensource.se>,
	"lethal\@linux-sh.org" <lethal@linux-sh.org>,
	"rjw\@sisk.pl" <rjw@sisk.pl>,
	"eric.y.miao\@gmail.com" <eric.y.miao@gmail.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>, alan@lxorguk.ukuu.org.uk,
	zt.tmzt@gmail.com, grant.likely@secretlab.ca, magnus.damm@gmail.com
To: Patrick Pannuto <ppannuto@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C59E654.1090403@codeaurora.org> (Patrick Pannuto's message of
	"Wed, 04 Aug 2010 15:14:44 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick Pannuto <ppannuto@codeaurora.org> writes:

> Inspiration for this comes from:
> http://www.mail-archive.com/linux-omap@vger.kernel.org/msg31161.html

Also, later in that thread I also wrote[1] what seems to be the core of
what you've done here: namely, allow platform_devices and
platform_drivers to to be used on custom busses.  Patch is at the end of
this mail with a more focused changelog.  As Greg suggested in his reply
to your first version, this part could be merged today, and the
platform_bus_init stuff could be added later, after some more review.
Some comments below...

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
> 	EXPORT_SYMBOL_GPL(my_bus_init);
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

Except it requires a re-compile.

Rather than doing this at compile time, it would be better to support
legacy devices at runtime.  You could handle this by simply registering
the driver on the custom bus and the platform_bus and let the bus
matching code handle it.  Then, the same binary would work on both
legacy and updated SoCs.

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

Up to here, this looks exactly what I wrote in thread referenced above.

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

minor nit: kernel doc style has wrong indentation

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

With this approach, you should note in the comments/changelog that
any selective customization of the bus PM methods must be done after 
calling platform_bus_type_init().

Also, You've left out the legacy PM methods here.  That implies that
moving a driver from the platform_bus to the custom bus is not entirely
transparent.  If the driver still has legacy PM methods, it would stop
working on the custom bus.

While this is good motivation for converting a driver to dev_pm_ops, at
a minimum it should be clear in the changelog that the derivative busses
do not support legacy PM methods.  However, since it's quite easy to do,
and you want the derivative busses to be *exactly* like the platform bus
except where explicitly changed, I'd suggest you also check/copy the
legacy PM methods.

In addition, you've missed several fields in 'struct bus_type'
(bus_attr, drv_attr, p, etc.)  Without digging deeper into the driver
core, I'm not sure if they are all needed at init time, but it should be
clear in the comments why they can be excluded.

Kevin

[1] http://www.mail-archive.com/linux-omap@vger.kernel.org/msg31289.html


>From b784009af1d0a7065dc5e58a13ce29afa3432d3e Mon Sep 17 00:00:00 2001
From: Kevin Hilman <khilman@deeprootsystems.com>
Date: Mon, 28 Jun 2010 16:08:14 -0700
Subject: [PATCH] driver core: allow platform_devices and platform_drivers on custom busses

This allows platform_devices and platform_drivers to be registered onto
custom busses that are compatible with the platform_bus.

Signed-off-by: Kevin Hilman <khilman@deeprootsystems.com>
---
 drivers/base/platform.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/base/platform.c b/drivers/base/platform.c
index 4d99c8b..2cf55e2 100644
--- a/drivers/base/platform.c
+++ b/drivers/base/platform.c
@@ -241,7 +241,8 @@ int platform_device_add(struct platform_device *pdev)
 	if (!pdev->dev.parent)
 		pdev->dev.parent = &platform_bus;
 
-	pdev->dev.bus = &platform_bus_type;
+	if (!pdev->dev.bus)
+		pdev->dev.bus = &platform_bus_type;
 
 	if (pdev->id != -1)
 		dev_set_name(&pdev->dev, "%s.%d", pdev->name,  pdev->id);
@@ -482,7 +483,8 @@ static void platform_drv_shutdown(struct device *_dev)
  */
 int platform_driver_register(struct platform_driver *drv)
 {
-	drv->driver.bus = &platform_bus_type;
+	if (!drv->driver.bus)
+		drv->driver.bus = &platform_bus_type;
 	if (drv->probe)
 		drv->driver.probe = platform_drv_probe;
 	if (drv->remove)
@@ -539,12 +541,12 @@ int __init_or_module platform_driver_probe(struct platform_driver *drv,
 	 * if the probe was successful, and make sure any forced probes of
 	 * new devices fail.
 	 */
-	spin_lock(&platform_bus_type.p->klist_drivers.k_lock);
+	spin_lock(&drv->driver.bus->p->klist_drivers.k_lock);
 	drv->probe = NULL;
 	if (code == 0 && list_empty(&drv->driver.p->klist_devices.k_list))
 		retval = -ENODEV;
 	drv->driver.probe = platform_drv_probe_fail;
-	spin_unlock(&platform_bus_type.p->klist_drivers.k_lock);
+	spin_unlock(&drv->driver.bus->p->klist_drivers.k_lock);
 
 	if (code != retval)
 		platform_driver_unregister(drv);
-- 
1.7.2.1
