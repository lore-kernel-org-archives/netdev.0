From: Patrick Pannuto <ppannuto@codeaurora.org>
Subject: Re: [PATCH 2/2] platform: Facilitate the creation of pseudo-platform
 buses
Date: Mon, 16 Aug 2010 11:47:12 -0700
Message-ID: <4C6987B0.7030703@codeaurora.org>
References: <1281484174-32174-1-git-send-email-ppannuto@codeaurora.org> <1281484174-32174-3-git-send-email-ppannuto@codeaurora.org> <AANLkTi=GduvsmkXpxsVoN7k3gPDjjRgqe0E_Z2YeEVS5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	magnus.damm@gmail.com, gregkh@suse.de,
	Kevin Hilman <khilman@deeprootsystems.com>,
	Paul Mundt <lethal@linux-sh.org>,
	Magnus Damm <damm@opensource.se>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Eric Miao <eric.y.miao@gmail.com>,
	Dmitry Torokhov <dtor@mail.ru>, netdev@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:37375 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021Ab0HPSrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 14:47:13 -0400
In-Reply-To: <AANLkTi=GduvsmkXpxsVoN7k3gPDjjRgqe0E_Z2YeEVS5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/13/2010 03:05 PM, Grant Likely wrote:
> On Tue, Aug 10, 2010 at 5:49 PM, Patrick Pannuto
> <ppannuto@codeaurora.org> wrote:
>> (lkml.org seems to have lost August 3rd...)
>> RFC: http://lkml.indiana.edu/hypermail//linux/kernel/1008.0/01342.html
>>  v1: http://lkml.indiana.edu/hypermail//linux/kernel/1008.0/01942.html
>>
>> Based on the idea and code originally proposed by Kevin Hilman:
>> http://www.mail-archive.com/linux-omap@vger.kernel.org/msg31161.html
> 
> Hi Patrick,
> 
> Before acking this as something that should be merged, I'd like to see
> some real device drivers converted to use this interface so I can
> better judge whether or not it is a good idea.  More comments below.
> 

Ok, I can do that.

>> diff --git a/drivers/base/platform.c b/drivers/base/platform.c
>> index b69ccb4..933e0c1 100644
>> --- a/drivers/base/platform.c
>> +++ b/drivers/base/platform.c
>> @@ -238,8 +238,12 @@ int platform_device_add(struct platform_device *pdev)
>>        if (!pdev)
>>                return -EINVAL;
>>
>> -       if (!pdev->dev.parent)
>> -               pdev->dev.parent = &platform_bus;
>> +       if (!pdev->dev.bus) {
>> +               pdev->dev.bus = &platform_bus_type;
>> +
>> +               if (!pdev->dev.parent)
>> +                       pdev->dev.parent = &platform_bus;
>> +       }
>>        pdev->dev.bus = &platform_bus_type;
>>
> 
> For safety, I think you'd want to have a separate add function for
> each new platform bus type, and change the name of this function to
> explicitly pass the bus type:
> 
> int __platform_device_add(struct platform_device *pdev)
> {
> 	if (!pdev->dev.bus)
> 		return -EINVAL;
> 	[... existing code ...]
> }
> 
> int platform_device_add(struct platform_device *pdev)
> {
>        if (!pdev->dev.parent)
>                pdev->dev.parent = &platform_bus;
>        pdev->dev.bus = &platform_bus_type;
>        __platform_device_add(pdev);
> }
> 
> And then for each bus type (in this example, I'll call it
> foo_bus_type, and assume foo_device wraps platform_device):
> 
> int foo_device_add(struct foo_device *foo)
> {
> 	foo->pdev.dev.bus = &foo_bus_type;
> 	__platform_device_add(&foo->pdev);
> }
> 
> That will allow the new bus_type code to keep foo_bus_type as an
> unexported static and will provide a bit more type safety.  For
> example, it avoids accidentally registering a plain (unwrapped)
> platform device on the foo_bus_type.
> 
> [...snip...]

Yes, this makes sense.  Originally, I was trying to avoid this due
to a misguided notion of backwards compatibility - namely that
devices could register themselves conditionally via

	.bus = HAVE_FOO_BUS,

and always call the same platform_[device|driver]_register, but
thinking about this more, such a compile (or run)-time decision can
just as easily be made in the foo_[device|driver]_register. The
impact on legacy code is the same either way, but your suggested
interface is much better.

I will modify all of these.

> 
>> @@ -1017,6 +1022,87 @@ struct bus_type platform_bus_type = {
>>  };
>>  EXPORT_SYMBOL_GPL(platform_bus_type);
>>
>> +/** pseudo_platform_bus_register - register an "almost platform bus"
> 
> Kerneldoc style error.  Should be:
> 
> +/**
> + * pseudo_platform_bus_register - register an "almost platform bus"
> 

Fixed.

>> + * @bus: partially complete bus type to register
>> + *
>> + * This init will fill in any ommitted fields in @bus, however, it
>> + * also allocates memory and replaces the pm field in @bus, since
>> + * pm is const, but some of its pointers may need this one-time
>> + * initialziation overwrite.
>> + *
>> + * @bus's registered this way should be released with
>> + * pseudo_platform_bus_unregister
>> + */
>> +int pseudo_platform_bus_register(struct bus_type *bus)
>> +{
>> +       int error;
>> +       struct dev_pm_ops* heap_pm;
> 
> Nit: heap_pm is an odd name.  Typically Linux local vars are named
> according to what they are, not where the memory is allocated from.
> How about simply 'ops'
> 

Ah yes. This was deliberate, and to draw attention to it :)

>> +       heap_pm = kmalloc(sizeof (*heap_pm), GFP_KERNEL);
>> +
>> +       if (!heap_pm)
>> +               return -ENOMEM;
>> +
>> +       if (!bus->dev_attrs)
>> +               bus->dev_attrs = platform_bus_type.dev_attrs;
>> +       if (!bus->match)
>> +               bus->match = platform_bus_type.match;
>> +       if (!bus->uevent)
>> +               bus->uevent = platform_bus_type.uevent;
>> +       if (!bus->pm)
>> +               memcpy(heap_pm, &platform_bus_type.pm, sizeof(*heap_pm));
>> +       else {
>> +               heap_pm->prepare = (bus->pm->prepare) ?
>> +                       bus->pm->prepare : platform_pm_prepare;
>> +               heap_pm->complete = (bus->pm->complete) ?
>> +                       bus->pm->complete : platform_pm_complete;
>> +               heap_pm->suspend = (bus->pm->suspend) ?
>> +                       bus->pm->suspend : platform_pm_suspend;
>> +               heap_pm->resume = (bus->pm->resume) ?
>> +                       bus->pm->resume : platform_pm_resume;
>> +               heap_pm->freeze = (bus->pm->freeze) ?
>> +                       bus->pm->freeze : platform_pm_freeze;
>> +               heap_pm->thaw = (bus->pm->thaw) ?
>> +                       bus->pm->thaw : platform_pm_thaw;
>> +               heap_pm->poweroff = (bus->pm->poweroff) ?
>> +                       bus->pm->poweroff : platform_pm_poweroff;
>> +               heap_pm->restore = (bus->pm->restore) ?
>> +                       bus->pm->restore : platform_pm_restore;
>> +               heap_pm->suspend_noirq = (bus->pm->suspend_noirq) ?
>> +                       bus->pm->suspend_noirq : platform_pm_suspend_noirq;
>> +               heap_pm->resume_noirq = (bus->pm->resume_noirq) ?
>> +                       bus->pm->resume_noirq : platform_pm_resume_noirq;
>> +               heap_pm->freeze_noirq = (bus->pm->freeze_noirq) ?
>> +                       bus->pm->freeze_noirq : platform_pm_freeze_noirq;
>> +               heap_pm->thaw_noirq = (bus->pm->thaw_noirq) ?
>> +                       bus->pm->thaw_noirq : platform_pm_thaw_noirq;
>> +               heap_pm->poweroff_noirq = (bus->pm->poweroff_noirq) ?
>> +                       bus->pm->poweroff_noirq : platform_pm_poweroff_noirq;
>> +               heap_pm->restore_noirq = (bus->pm->restore_noirq) ?
>> +                       bus->pm->restore_noirq : platform_pm_restore_noirq;
>> +               heap_pm->runtime_suspend = (bus->pm->runtime_suspend) ?
>> +                       bus->pm->runtime_suspend : platform_pm_runtime_suspend;
>> +               heap_pm->runtime_resume = (bus->pm->runtime_resume) ?
>> +                       bus->pm->runtime_resume : platform_pm_runtime_resume;
>> +               heap_pm->runtime_idle = (bus->pm->runtime_idle) ?
>> +                       bus->pm->runtime_idle : platform_pm_runtime_idle;
>> +       }
>> +       bus->pm = heap_pm;
>> +
>> +       error = bus_register(bus);
>> +       if (error)
>> +               kfree(bus->pm);
>> +
>> +       return error;
>> +}
>> +EXPORT_SYMBOL_GPL(pseudo_platform_bus_register);
> 
> Ick, this is a nasty list of conditional statements.  :-)  Instead it
> could have an unconditional initialize function which sets it up just
> like the platform bus without registering.  Then allow the
> foo_bus_type initialization code override the ones it cares about, and
> then register directly.
> 

No, this won't work. (Unless, every pseudo_bus_type author did this same
kludge to work around const - better to do once IMHO)

struct bus_type {
	...
	const struct dev_pm_ops *pm;
	...
};

That const is there to *prevent* device/driver writers from overriding
pm ops on accident, and to that end, it has value. What we would really
like here is 'const after registered' semantics, where the bus author
can fill in half the structure, and the platform code can fill in the
rest. However, allowing subclasses to modify private data elements isn't
possible in C :)

I believe the 'const' here provides valuable safety. My original attempt
at doing this removed the const, and I overwrote one of the pointers in
platform_dev_pm_ops on my first try at implementing it!

This was the best solution I could come up with while preserving the const
nature of the pm_ops and introducing minimal complexity / potential to
screw up for pseudo-bus-type authors.


>> +
>> +void pseudo_platform_bus_unregister(struct bus_type *bus)
>> +{
>> +       bus_unregister(bus);
>> +       kfree(bus->pm);
>> +}
>> +EXPORT_SYMBOL_GPL(pseudo_platform_bus_unregister);
>> +
>>  int __init platform_bus_init(void)
>>  {
>>        int error;
>> diff --git a/include/linux/platform_device.h b/include/linux/platform_device.h
>> index 5417944..5ec827c 100644
>> --- a/include/linux/platform_device.h
>> +++ b/include/linux/platform_device.h
>> @@ -79,6 +79,9 @@ extern int platform_driver_probe(struct platform_driver *driver,
>>  #define platform_get_drvdata(_dev)     dev_get_drvdata(&(_dev)->dev)
>>  #define platform_set_drvdata(_dev,data)        dev_set_drvdata(&(_dev)->dev, (data))
>>
>> +extern int pseudo_platform_bus_register(struct bus_type *);
>> +extern void pseudo_platform_bus_unregister(struct bus_type *);
>> +
>>  extern struct platform_device *platform_create_bundle(struct platform_driver *driver,
>>                                        int (*probe)(struct platform_device *),
>>                                        struct resource *res, unsigned int n_res,
>> --
>> 1.7.2
>>
>>
> 
> 
> 


-- 
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum
