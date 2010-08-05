From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [RFC PATCH] platform: Faciliatate the creation of pseduo-platform
	busses
Date: Thu, 5 Aug 2010 16:59:35 -0600
Message-ID: <AANLkTikVzh9=DvvUPbKmDeo6k2-pPVSnjH+GxAPdQFO4@mail.gmail.com>
References: <4C58A7AA.8020007@codeaurora.org> <20100803235631.GA17759@suse.de>
	<4C58AE15.6090900@codeaurora.org> <20100804000945.GA19729@suse.de>
	<4C58B1B6.9050005@quicinc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <gregkh@suse.de>,
	Patrick Pannuto <ppannuto@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"damm@opensource.se" <damm@opensource.se>,
	"lethal@linux-sh.org" <lethal@linux-sh.org>,
	"rjw@sisk.pl" <rjw@sisk.pl>, "dtor@mail.ru" <dtor@mail.ru>,
	"eric.y.miao@gmail.com" <eric.y.miao@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kevin Hilman <khilman@deeprootsystems.com>
To: Patrick Pannuto <ppannuto@quicinc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:62176 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756396Ab0HEW76 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 18:59:58 -0400
In-Reply-To: <4C58B1B6.9050005@quicinc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 3, 2010 at 6:17 PM, Patrick Pannuto <ppannuto@quicinc.com> =
wrote:
>>>>>
>>>>> =A0 =A0struct platform_device sub_bus1 =3D {
>>>>> =A0 =A0 =A0 =A0 =A0 =A0.name =A0 =A0 =A0 =A0 =A0 =3D "sub_bus1",
>>>>> =A0 =A0 =A0 =A0 =A0 =A0.id =A0 =A0 =A0 =A0 =A0 =A0 =3D -1,
>>>>> =A0 =A0 =A0 =A0 =A0 =A0.dev.bus =A0 =A0 =A0 =A0=3D &my_bus_type,
>>>>> =A0 =A0}
>>>>> =A0 =A0EXPORT_SYMBOL_GPL(sub_bus1);
>>>>
>>>> You really want a bus hanging off of a bus? =A0Normally you need a=
 device
>>>> to do that, which is what I think you have here, but the naming is=
 a bit
>>>> odd to me.
>>>>
>>>> What would you do with this "sub bus"? =A0It's just a device, but =
you are
>>>> wanting it to be around for something.
>>>>
>>>
>>> It's for power management stuff, basically, there are actual physic=
al buses
>>> involved that can be completely powered off IFF all of their device=
s are
>>> not in use. Plus it actually matches bus topology this way.
>>
>> Then create a real bus hanging off of a device, not another device t=
hat
>> "acts" like a bus here, right? =A0Or am I missing the point?
>>
>
> The motivation for doing it this was is that one driver could drive
> devices on two different subbusses. =A0In the example, "my-driver" co=
uld
> drive a device on sub_bus1 AND sub_bus2 (if there were 2+ devices, on=
e
> or more on each bus).
>
> From my understanding, this is not possible if they are actually
> different busses.

It sounds an awful lot like 2 separate concepts are being conflated
here.  In Linux terminology, we have two things:

/bus types/ describe the common behavour of similarly attached things.
/physical or logical busses/ are where devices are actually attached
registered to the system.

These are not the same thing.

The primary thing that a bus-type provides is the set of device driver
that can be bound to the device plus some common functionality.
Almost every struct device has the 'struct bus_type bus' field set so
that it can be bound against a device driver when it is registered.

Every struct device also has a 'struct device *parent' field.  The
parent field denotes where the device lives in the Linux device model
(see /sys/devices/*), but it says *nothing* about what the bus type of
device it is.  Remember I mentioned physical/logical busses earlier?
Well the core Linux device model doesn't really have a concept of bus
instances, it only knows about devices and bus types.  The .parent
field is the closest thing the device model has to a bus instance, but
the model places no constraints on the bus type of each child 'struct
device'.

(caveat: many bus_types do have a concept of bus instances; but that
is specific to the bus_type.  The core device model doesn't care.
Also, in practical terms, yes most sibling devices will also be of the
same bus_type, but it is not a given, and it is not enforced.)

=46or example, a system can have many physical pci busses, but all the
devices hanging off those busses are still just registered on
pci_bus_type.  The parent of those devices, however, reflects the
physical bus the device is attached to.

In fact, the bus type has absolutely no bearing on where a device
actually lives in the Linux driver model.  A common misunderstanding
is that all platform devices live under /sys/devices/platform.

This also is not true.

By default the platform bus will put devices without a parent into
/sys/devices/platform, but if parent is set, then the device will be
registered where the parent pointer tells it to be registered.  It is
totally okay to have the following structure (off the top of my head):

system_bus (platform_bus_type, registers a bunch of child devices)
|--pci_bus (platform_bus_type; implements a pci host bridge)
|  |--usb host controller 1 (pci_bus_type, implements a usb bus instanc=
e)
|  |--usb host controller 2 (pci_bus_type, implements a usb bus instanc=
e)
|  |--fpga (pci_bus_type, implements a bunch of devices)
|     |--spi controller (platform_bus_type)
|     |--custom peripheral (platform_bus_type)
|--uart (platform_bus_type)
|--uart (platform_bus_type)
|--ethernet (platform_bus_type)
|--external bus (platform_bus_type; represents and external local bus)
|  |--i2c controller (platform_bus_type)
|  |  |--eeprom (i2c_bus_type)
|  |  |--temperature sensor (i2c_bus_type)
|--gpio controller (platform_bus_type)

Platform devices can show up just about anywhere in the tree.

(On that point Greg, what is the reason for even having the
/sys/devices/platform/ parent?  Why not just let the platform devices
sit at the root of the device tree?  In the OF case (granted, I'm
biased) all of the platform_device registrations reflect the actual
device hierarchy expressed in the device tree data.)

So, the *only* reason to have a different bus_type is if the actual
behaviour of the bus is different.  A different bus type wouldn't even
cause a different topology if doing so wouldn't make sense.  For
example in the OMAP case, the topology might look like:

system_bus (platform_bus_type, registers a bunch of child devices)
|  ...
|--uart (omap_bus_type)
|--uart (omap_bus_type)
|--ethernet (platform_bus_type)

See?  Devices of different types can often be siblings at the same
device layer.  (note: not *always* true.  PCI busses for instance
always expect to only host pci_devices and visa-versa, but for simple
platform-like busses it may be true).

Now, having gone on this whole long tirade, it looks like having
separate platform bus types may not be the best approach after all.
Magnus and Kevin are exploring using devres to handle implementing the
system-specific behaviour.  It is certainly an area for more research
and experimental implementations.

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
