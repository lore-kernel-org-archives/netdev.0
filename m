From: Greg KH <gregkh@suse.de>
Subject: Re: [RFC PATCH] platform: Faciliatate the creation of
 pseduo-platform busses
Date: Tue, 3 Aug 2010 16:56:31 -0700
Message-ID: <20100803235631.GA17759@suse.de>
References: <4C58A7AA.8020007@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	linux-omap@vger.kernel.org, damm@opensource.se,
	lethal@linux-sh.org, rjw@sisk.pl, dtor@mail.ru,
	eric.y.miao@gmail.com, netdev@vger.kernel.org
To: Patrick Pannuto <ppannuto@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46118 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756886Ab0HCX6M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 19:58:12 -0400
Content-Disposition: inline
In-Reply-To: <4C58A7AA.8020007@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 03, 2010 at 04:35:06PM -0700, Patrick Pannuto wrote:
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

You really want a bus hanging off of a bus?  Normally you need a device
to do that, which is what I think you have here, but the naming is a bit
odd to me.

What would you do with this "sub bus"?  It's just a device, but you are
wanting it to be around for something.

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

Ah, you put devices on this "sub bus".  But why?  Why not just put it on
your "normal" bus that you created?  What's with the extra level of
nesting here?

Other than that, it looks like a nice idea, are there portions of kernel
code that can be simplified because of this?

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

I'm guessing that this chunk can be applied now, right?

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

Watch out for things in "write only" memory here.  That could cause
problems.

thanks,

greg k-h
