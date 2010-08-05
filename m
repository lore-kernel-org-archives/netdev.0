From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH] platform: Facilitate the creation of pseduo-platform busses
Date: Thu, 05 Aug 2010 08:57:13 -0700
Message-ID: <87fwytxdba.fsf@deeprootsystems.com>
References: <4C59E654.1090403@codeaurora.org>
	<877hk56hiy.fsf@deeprootsystems.com> <4C5A0C68.9080500@codeaurora.org>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:58064 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758370Ab0HEP5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 11:57:17 -0400
In-Reply-To: <4C5A0C68.9080500@codeaurora.org> (Patrick Pannuto's message of
	"Wed, 04 Aug 2010 17:57:12 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick Pannuto <ppannuto@codeaurora.org> writes:

> On 08/04/2010 05:16 PM, Kevin Hilman wrote:
>> Patrick Pannuto <ppannuto@codeaurora.org> writes:
>> 
>>> Inspiration for this comes from:
>>> http://www.mail-archive.com/linux-omap@vger.kernel.org/msg31161.html
>> 
>> Also, later in that thread I also wrote[1] what seems to be the core of
>> what you've done here: namely, allow platform_devices and
>> platform_drivers to to be used on custom busses.  Patch is at the end of
>> this mail with a more focused changelog.  As Greg suggested in his reply
>> to your first version, this part could be merged today, and the
>> platform_bus_init stuff could be added later, after some more review.
>> Some comments below...
>> 
>
> I can split this into 2 patches.

Yes, I think that would be better.

> Was your patch sent to linux-kernel or just linux-omap? I'm not on linux-omap...

That thread was on linux-arm-kernel and linux-omap

>
>>> [snip]
>>>
>>> Which will allow the same driver to easily to used on either
>>> the platform bus or the newly defined bus type.
>> 
>> Except it requires a re-compile.
>> 
>> Rather than doing this at compile time, it would be better to support
>> legacy devices at runtime.  You could handle this by simply registering
>> the driver on the custom bus and the platform_bus and let the bus
>> matching code handle it.  Then, the same binary would work on both
>> legacy and updated SoCs.
>> 
>
> Can you safely register a driver on more than one bus? I didn't think
> that was safe -- normally it's impossible since you're calling
>
> struct BUS_TYPE_driver mydriver;
> BUS_TYPE_driver_register(&mydriver)
>
> but now we have multiple "bus types" that are all actually platform type; still,
> at a minimum you would need:
> 	struct platform_driver mydrvier1 = {
> 		.driver.bus = &sub_bus1,
> 	};
> 	struct platform_driver mydrvier2 = {
> 		.driver.bus = &sub_bus2,
> 	};
> which would all point to the same driver functions, yet the respective devices
> attached for the "same" driver would be on different buses. I fear this might
> confuse some drivers. I don't think dynamic bus assignment is this easy
>
> In short: I do not believe the same driver can be registered on multiple
> different buses -- if this is wrong, please correct me.

It is possible, and currently done in powerpc land where some
drivers handle devices on the platform_bus and the custom OF bus.

However, as noted by Magnus, what we really need here is a way for
drivers to not care at all what kind of bus they are on.  There are an
increasing number of drivers that are re-used not just across different
SoCs in the same family, but across totally different SoCs (e.g. drivers
for hardware shared between TI OMAP and TI DaVinci, or SH and SH-Mobile/ARM)

>> 
>> Up to here, this looks exactly what I wrote in thread referenced
>> above.
>> 
>
> It is, you just went on vacation :)
>

Ah, OK.   The changelog was missing credits to that affect, but I was
more concerned that you hadn't seen my example and didn't want to be
duplicating work.

>>>  
>>>  	if (code != retval)
>>>  		platform_driver_unregister(drv);
>>> @@ -1017,6 +1019,26 @@ struct bus_type platform_bus_type = {
>>>  };
>>>  EXPORT_SYMBOL_GPL(platform_bus_type);
>>>  
>>> +/** platform_bus_type_init - fill in a pseudo-platform-bus
>>> +  * @bus: foriegn bus type
>>> +  *
>>> +  * This init is basically a selective memcpy that
>>> +  * won't overwrite any user-defined attributes and
>>> +  * only copies things that platform bus defines anyway
>>> +  */
>> 
>> minor nit: kernel doc style has wrong indentation
>> 
>
> will fix
>
>>> +void platform_bus_type_init(struct bus_type *bus)
>>> +{
>>> +	if (!bus->dev_attrs)
>>> +		bus->dev_attrs = platform_bus_type.dev_attrs;
>>> +	if (!bus->match)
>>> +		bus->match = platform_bus_type.match;
>>> +	if (!bus->uevent)
>>> +		bus->uevent = platform_bus_type.uevent;
>>> +	if (!bus->pm)
>>> +		bus->pm = platform_bus_type.pm;
>>> +}
>>> +EXPORT_SYMBOL_GPL(platform_bus_type_init);
>> 
>> With this approach, you should note in the comments/changelog that
>> any selective customization of the bus PM methods must be done after 
>> calling platform_bus_type_init().
>
> No they don't. If you call platform_bus_type_init first then you'll
> just overwrite them with new values; 

Yes.

> if you call it second then they will all already be well-defined and
> thus not overwritten.

Right, they will not be overwritten, but you'll be left with a mostly
empty dev_pm_ops on the custom bus.

IOW, Most of these custom busses will only want to customize a small
subset of the dev_pm_ops methods (e.g. only the runtime PM methods.)  If
you setup your sparsly populated custom dev_pm_ops and then call
platform_bus_type_init() second, dev_pm_ops on the new buswill have *only*
your custom fields, and none of the defaults from platform_dev_pm_ops.

So, what I was getting at is that it should probably be clearer to the
users of platform_bus_type_init() that any customization of dev_pm_ops
should be done after.

>> 
>> Also, You've left out the legacy PM methods here.  That implies that
>> moving a driver from the platform_bus to the custom bus is not entirely
>> transparent.  If the driver still has legacy PM methods, it would stop
>> working on the custom bus.
>> 
>> While this is good motivation for converting a driver to dev_pm_ops, at
>> a minimum it should be clear in the changelog that the derivative busses
>> do not support legacy PM methods.  However, since it's quite easy to do,
>> and you want the derivative busses to be *exactly* like the platform bus
>> except where explicitly changed, I'd suggest you also check/copy the
>> legacy PM methods.
>> 
>> In addition, you've missed several fields in 'struct bus_type'
>> (bus_attr, drv_attr, p, etc.)  Without digging deeper into the driver
>> core, I'm not sure if they are all needed at init time, but it should be
>> clear in the comments why they can be excluded.
>> 
>
> I copied everything that was defined for platform_bus_type:
>
> struct bus_type platform_bus_type = {
> 	.name		= "platform",
> 	.dev_attrs	= platform_dev_attrs,
> 	.match		= platform_match,
> 	.uevent		= platform_uevent,
> 	.pm		= &platform_dev_pm_ops,
> };
> EXPORT_SYMBOL_GPL(platform_bus_type);
>
> struct bus_type {
> 	const char		*name;
> 	struct bus_attribute	*bus_attrs;
> 	struct device_attribute	*dev_attrs;
> 	struct driver_attribute	*drv_attrs;
>
> 	int (*match)(struct device *dev, struct device_driver *drv);
> 	int (*uevent)(struct device *dev, struct kobj_uevent_env *env);
> 	int (*probe)(struct device *dev);
> 	int (*remove)(struct device *dev);
> 	void (*shutdown)(struct device *dev);
>
> 	int (*suspend)(struct device *dev, pm_message_t state);
> 	int (*resume)(struct device *dev);
>
> 	const struct dev_pm_ops *pm;
>
> 	struct bus_type_private *p;
> };
>
> It is my understanding that everything that I did not copy *should* remain
> unique to each bus; remaining fields will be filled in by bus_register and
> should not be copied.
>

[...]

>
> If you would like to lead this effort, please do so; I did not mean to step
> on your toes, it's just that this is an issue for me as well. 

No worries there, my toes are fine.   :) 

> You had indicated that you were going on vacation for a month and I
> had not seen any more follow-up on this issue, so I forged ahead.

Great, I'm glad you forged ahead.  There is definitely a broader need
for something like this, and I have no personal attachment to the code.

I have no problems with you continuing the work (in fact, I'd prefer it.
I have lots of other things to catch up on after my vacation.)

In the future though, it's common (and kind) to note the original author
in the changelog when basing a patch on previous work.  Something like
"originally written by..."  or "based on the work of..." etc.

Thanks,

Kevin
