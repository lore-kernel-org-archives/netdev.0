From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] platform: Facilitate the creation of pseduo-platform
	busses
Date: Sat, 7 Aug 2010 00:53:01 -0600
Message-ID: <AANLkTi=JDPy4SCL_wW1A8xjnr9xs=XhPe3dsLX_9rLUH@mail.gmail.com>
References: <4C59E654.1090403@codeaurora.org> <877hk56hiy.fsf@deeprootsystems.com>
	<4C5A0C68.9080500@codeaurora.org> <87fwytxdba.fsf@deeprootsystems.com>
	<AANLkTimCS4RV+8E_ZzX97=r5rmQR3nmizp0JYK+syLRa@mail.gmail.com>
	<4C5B646C.1030308@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
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
To: Patrick Pannuto <ppannuto@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:44489 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752935Ab0HGGxX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Aug 2010 02:53:23 -0400
In-Reply-To: <4C5B646C.1030308@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 5, 2010 at 7:25 PM, Patrick Pannuto <ppannuto@codeaurora.or=
g> wrote:
> On 08/05/2010 04:16 PM, Grant Likely wrote:
>> The relevant question before going down this path is, "Is the
>> omap/sh/other-soc behaviour something fundamentally different from t=
he
>> platform bus? =A0Or is it something complementary that would be bett=
er
>> handled with a notifier or some orthogonal method of adding new
>> behaviour?"
>>
>> I don't have a problem with multiple platform_bus instances using th=
e
>> same code (I did suggest it after all), but I do worry about muddyin=
g
>> the Linux device model or making it overly complex. =A0Binding singl=
e
>> drivers to multiple device types could be messy.
>>
>> Cheers,
>> g.
>
> From your other email, the distinction of /bus_types/ versus /physica=
l
> or logical buses/ was very valuable (thanks). I am becoming less
> convinced that I need this infrastructure or the ability to create
> pseudo-platform buses. Let me outline some thoughts below, which I
> think at least solves my problems ( ;) ), and if some of the OMAP fol=
ks
> and Alan could chime in as to whether they can apply something simila=
r,
> or if they still have need of creating actual new bus types?
>
>
> As we are exploring all of this, let me put a concrete (ish) scenario
> out there to discuss:
>
> =A0 =A0 =A0 =A0SUB_BUS1---DEVICE1
> =A0 =A0 =A0 /
> CPU ---
> =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0SUB_BUS2---DEVICE2
>
> DEVICE1 and DEVICE2 are the same device (say, usb host controller, or
> whatever), and they should be driven by the same driver. However,
> physically they are attached to different buses.
>
> SUB_BUS1 and SUB_BUS2 are *different* and let's say require a differe=
nt
> suspend method. If I understand correctly, the right way to build the
> topology would be:
>
> struct device_type SUB_BUS1_type =3D {
> =A0 =A0 =A0 =A0.name =3D "sub-bus1-type",
> =A0 =A0 =A0 =A0.pm =A0 =3D &sub_bus1_pm_ops;
> };
>
> struct platform_device SUB_BUS1 =3D {
> =A0 =A0 =A0 =A0.init_name =3D "sub-bus1",
> =A0 =A0 =A0 =A0.dev.type =A0=3D &sub_bus1_type,
> };
>
> struct platform_device DEVICE1 =3D {
> =A0 =A0 =A0 =A0.name =A0 =A0 =A0 =3D "device1",
> =A0 =A0 =A0 =A0.dev.parent =3D &SUB_BUS1.dev,
> };
>
> platform_device_register(&SUB_BUS1);
> platform_device_register(&DEVICE1);
>
> [analogous for *2]

Not quite.  The device_type is intended to collect similar, but
different things (ie, all keyboards, regardless of how they are
attached to the system).  Trying to capture the device-specific
behavour really belongs in the specific device driver attached to the
SUB_BUS* device.  In fact, the way you've constructed your example,
SUB_BUS1 and SUB_BUS2 don't really need to be platform_devices at all;
you could have used a plain struct device because in this example you
aren't binding them to a device driver).

That being said, because each bus *does* have custom behaviour, it
probably does make sense to either bind each to a device driver, or to
do something to each child device that changes the PM behaviour.  I
haven't dug into the problem domain deep enough to give you absolute
answers, but the devres approach looks promising, as does creating a
derived platform_bus_type (although I'm not fond of sharing device
drivers between multiple bus_types).  Another option might be giving
the parent struct device some runtime PM operations that it performs
per-child.  I'm just throwing out ideas here though.

> which would yield:
>
> /sys/bus/platform/devices/
> =A0|
> =A0|-SUB_BUS1
> =A0| =A0|
> =A0| =A0|-DEVICE1
> =A0|
> =A0|-SUB_BUS2
> =A0| =A0|
> =A0| =A0|-DEVICE2

You're looking in the wrong place.  Look in /sys/devices instead of
/sys/bus... (see comments below)

> Which is the correct topology, and logically provides all the correct
> interfaces. =A0The only thing that becomes confusing now, is that SUB=
_BUS*
> is *actually* a physically different bus, yet it's not in /sys/bus;
> although I suppose this is actually how the world works presently (yo=
u
> don't see an individual entry in /sys/bus for each usb host controlle=
r,
> which is technically defining a sub-bus...)

/sys/bus is for bus_types, not bus instances.  All USB devices will be
listed in /sys/bus/usb/devices regardless of the bus instance that
they attached to.

However, look carefully at the files in /sys/bus/*/devices.  Notice
that they are all symlinks?  Notice that the all of them point to
directories in /sys/devices?  /sys/bus tells you which devices are
registered against each bus type, but /sys/devices is the actual
structure.  Always look in /sys/devices when you want to know the
topology of the system.

Cheers,
g.
