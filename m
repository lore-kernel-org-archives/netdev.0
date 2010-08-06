From: Patrick Pannuto <ppannuto@codeaurora.org>
Subject: Re: [PATCH] platform: Facilitate the creation of pseduo-platform
 	busses
Date: Thu, 05 Aug 2010 18:25:00 -0700
Message-ID: <4C5B646C.1030308@codeaurora.org>
References: <4C59E654.1090403@codeaurora.org> <877hk56hiy.fsf@deeprootsystems.com> 	<4C5A0C68.9080500@codeaurora.org> <87fwytxdba.fsf@deeprootsystems.com> <AANLkTimCS4RV+8E_ZzX97=r5rmQR3nmizp0JYK+syLRa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Kevin Hilman <khilman@deeprootsystems.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"damm@opensource.se" <damm@opensource.se>,
	"lethal@linux-sh.org" <lethal@linux-sh.org>,
	"rjw@sisk.pl" <rjw@sisk.pl>,
	"eric.y.miao@gmail.com" <eric.y.miao@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>, alan@lxorguk.ukuu.org.uk,
	zt.tmzt@gmail.com, magnus.damm@gmail.com
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <AANLkTimCS4RV+8E_ZzX97=r5rmQR3nmizp0JYK+syLRa@mail.gmail.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/05/2010 04:16 PM, Grant Likely wrote:
> On Thu, Aug 5, 2010 at 9:57 AM, Kevin Hilman
> <khilman@deeprootsystems.com> wrote:
>> Patrick Pannuto <ppannuto@codeaurora.org> writes:
>>
>>> On 08/04/2010 05:16 PM, Kevin Hilman wrote:
>>>> Patrick Pannuto <ppannuto@codeaurora.org> writes:
>>>>
>>>>> Inspiration for this comes from:
>>>>> http://www.mail-archive.com/linux-omap@vger.kernel.org/msg31161.html
>>>>
>>>> Also, later in that thread I also wrote[1] what seems to be the core of
>>>> what you've done here: namely, allow platform_devices and
>>>> platform_drivers to to be used on custom busses.  Patch is at the end of
>>>> this mail with a more focused changelog.  As Greg suggested in his reply
>>>> to your first version, this part could be merged today, and the
>>>> platform_bus_init stuff could be added later, after some more review.
>>>> Some comments below...
>>>>
>>>
>>> I can split this into 2 patches.
>>
>> Yes, I think that would be better.
>>
>>> Was your patch sent to linux-kernel or just linux-omap? I'm not on linux-omap...
>>
>> That thread was on linux-arm-kernel and linux-omap
>>
>>>
>>>>> [snip]
>>>>>
>>>>> Which will allow the same driver to easily to used on either
>>>>> the platform bus or the newly defined bus type.
>>>>
>>>> Except it requires a re-compile.
>>>>
>>>> Rather than doing this at compile time, it would be better to support
>>>> legacy devices at runtime.  You could handle this by simply registering
>>>> the driver on the custom bus and the platform_bus and let the bus
>>>> matching code handle it.  Then, the same binary would work on both
>>>> legacy and updated SoCs.
>>>>
>>>
>>> Can you safely register a driver on more than one bus? I didn't think
>>> that was safe -- normally it's impossible since you're calling
>>>
>>> struct BUS_TYPE_driver mydriver;
>>> BUS_TYPE_driver_register(&mydriver)
>>>
>>> but now we have multiple "bus types" that are all actually platform type; still,
>>> at a minimum you would need:
>>>       struct platform_driver mydrvier1 = {
>>>               .driver.bus = &sub_bus1,
>>>       };
>>>       struct platform_driver mydrvier2 = {
>>>               .driver.bus = &sub_bus2,
>>>       };
>>> which would all point to the same driver functions, yet the respective devices
>>> attached for the "same" driver would be on different buses. I fear this might
>>> confuse some drivers. I don't think dynamic bus assignment is this easy
>>>
>>> In short: I do not believe the same driver can be registered on multiple
>>> different buses -- if this is wrong, please correct me.
>>
>> It is possible, and currently done in powerpc land where some
>> drivers handle devices on the platform_bus and the custom OF bus.
> 
> As of now, the of_platform_bus_type has been removed.  It was a bad
> idea because it tried to encode non-bus-specific information into
> something that was just a clone of the platform_bus.  Drivers that
> worked on both had to be bound to both busses.  I do actually have
> code that automatically registers a driver on more than one bus, but
> it is rather a hack and was only a temporary measure.
> 
> The relevant question before going down this path is, "Is the
> omap/sh/other-soc behaviour something fundamentally different from the
> platform bus?  Or is it something complementary that would be better
> handled with a notifier or some orthogonal method of adding new
> behaviour?"
> 
> I don't have a problem with multiple platform_bus instances using the
> same code (I did suggest it after all), but I do worry about muddying
> the Linux device model or making it overly complex.  Binding single
> drivers to multiple device types could be messy.
> 
> Cheers,
> g.

>From your other email, the distinction of /bus_types/ versus /physical
or logical buses/ was very valuable (thanks). I am becoming less
convinced that I need this infrastructure or the ability to create
pseudo-platform buses. Let me outline some thoughts below, which I
think at least solves my problems ( ;) ), and if some of the OMAP folks
and Alan could chime in as to whether they can apply something similar,
or if they still have need of creating actual new bus types?


As we are exploring all of this, let me put a concrete (ish) scenario
out there to discuss:

        SUB_BUS1---DEVICE1
       /
CPU ---
       \
        SUB_BUS2---DEVICE2

DEVICE1 and DEVICE2 are the same device (say, usb host controller, or
whatever), and they should be driven by the same driver. However,
physically they are attached to different buses.

SUB_BUS1 and SUB_BUS2 are *different* and let's say require a different
suspend method. If I understand correctly, the right way to build the
topology would be:

struct device_type SUB_BUS1_type = {
	.name = "sub-bus1-type",
	.pm   = &sub_bus1_pm_ops;
};

struct platform_device SUB_BUS1 = {
	.init_name = "sub-bus1",
	.dev.type  = &sub_bus1_type,
};

struct platform_device DEVICE1 = {
	.name       = "device1",
	.dev.parent = &SUB_BUS1.dev,
};

platform_device_register(&SUB_BUS1);
platform_device_register(&DEVICE1);

[analogous for *2]

which would yield:

/sys/bus/platform/devices/
 |
 |-SUB_BUS1
 |  |
 |  |-DEVICE1
 |
 |-SUB_BUS2
 |  |
 |  |-DEVICE2

Which is the correct topology, and logically provides all the correct
interfaces.  The only thing that becomes confusing now, is that SUB_BUS*
is *actually* a physically different bus, yet it's not in /sys/bus;
although I suppose this is actually how the world works presently (you
don't see an individual entry in /sys/bus for each usb host controller,
which is technically defining a sub-bus...)

Thoughts? Am I understanding everything correctly?

Is there anything more not covered by co-opting the device-type of SUB_BUS
that people would still need the pseduo-platform-bus extensions for?

-- 
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum
