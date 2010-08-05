From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] platform: Facilitate the creation of pseduo-platform
	busses
Date: Thu, 5 Aug 2010 17:16:10 -0600
Message-ID: <AANLkTimCS4RV+8E_ZzX97=r5rmQR3nmizp0JYK+syLRa@mail.gmail.com>
References: <4C59E654.1090403@codeaurora.org> <877hk56hiy.fsf@deeprootsystems.com>
	<4C5A0C68.9080500@codeaurora.org> <87fwytxdba.fsf@deeprootsystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick Pannuto <ppannuto@codeaurora.org>,
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
To: Kevin Hilman <khilman@deeprootsystems.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <87fwytxdba.fsf@deeprootsystems.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 5, 2010 at 9:57 AM, Kevin Hilman
<khilman@deeprootsystems.com> wrote:
> Patrick Pannuto <ppannuto@codeaurora.org> writes:
>
>> On 08/04/2010 05:16 PM, Kevin Hilman wrote:
>>> Patrick Pannuto <ppannuto@codeaurora.org> writes:
>>>
>>>> Inspiration for this comes from:
>>>> http://www.mail-archive.com/linux-omap@vger.kernel.org/msg31161.ht=
ml
>>>
>>> Also, later in that thread I also wrote[1] what seems to be the cor=
e of
>>> what you've done here: namely, allow platform_devices and
>>> platform_drivers to to be used on custom busses. =A0Patch is at the=
 end of
>>> this mail with a more focused changelog. =A0As Greg suggested in hi=
s reply
>>> to your first version, this part could be merged today, and the
>>> platform_bus_init stuff could be added later, after some more revie=
w.
>>> Some comments below...
>>>
>>
>> I can split this into 2 patches.
>
> Yes, I think that would be better.
>
>> Was your patch sent to linux-kernel or just linux-omap? I'm not on l=
inux-omap...
>
> That thread was on linux-arm-kernel and linux-omap
>
>>
>>>> [snip]
>>>>
>>>> Which will allow the same driver to easily to used on either
>>>> the platform bus or the newly defined bus type.
>>>
>>> Except it requires a re-compile.
>>>
>>> Rather than doing this at compile time, it would be better to suppo=
rt
>>> legacy devices at runtime. =A0You could handle this by simply regis=
tering
>>> the driver on the custom bus and the platform_bus and let the bus
>>> matching code handle it. =A0Then, the same binary would work on bot=
h
>>> legacy and updated SoCs.
>>>
>>
>> Can you safely register a driver on more than one bus? I didn't thin=
k
>> that was safe -- normally it's impossible since you're calling
>>
>> struct BUS_TYPE_driver mydriver;
>> BUS_TYPE_driver_register(&mydriver)
>>
>> but now we have multiple "bus types" that are all actually platform =
type; still,
>> at a minimum you would need:
>> =A0 =A0 =A0 struct platform_driver mydrvier1 =3D {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .driver.bus =3D &sub_bus1,
>> =A0 =A0 =A0 };
>> =A0 =A0 =A0 struct platform_driver mydrvier2 =3D {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .driver.bus =3D &sub_bus2,
>> =A0 =A0 =A0 };
>> which would all point to the same driver functions, yet the respecti=
ve devices
>> attached for the "same" driver would be on different buses. I fear t=
his might
>> confuse some drivers. I don't think dynamic bus assignment is this e=
asy
>>
>> In short: I do not believe the same driver can be registered on mult=
iple
>> different buses -- if this is wrong, please correct me.
>
> It is possible, and currently done in powerpc land where some
> drivers handle devices on the platform_bus and the custom OF bus.

As of now, the of_platform_bus_type has been removed.  It was a bad
idea because it tried to encode non-bus-specific information into
something that was just a clone of the platform_bus.  Drivers that
worked on both had to be bound to both busses.  I do actually have
code that automatically registers a driver on more than one bus, but
it is rather a hack and was only a temporary measure.

The relevant question before going down this path is, "Is the
omap/sh/other-soc behaviour something fundamentally different from the
platform bus?  Or is it something complementary that would be better
handled with a notifier or some orthogonal method of adding new
behaviour?"

I don't have a problem with multiple platform_bus instances using the
same code (I did suggest it after all), but I do worry about muddying
the Linux device model or making it overly complex.  Binding single
drivers to multiple device types could be messy.

Cheers,
g.
--
To unsubscribe from this list: send the line "unsubscribe linux-omap" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
