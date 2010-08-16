From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 2/2] platform: Facilitate the creation of pseudo-platform buses
Date: Mon, 16 Aug 2010 00:43:01 -0600
Message-ID: <AANLkTi=Pm8BL+Ksq1o7MYpV7mMH10bEPu1=Am9EgT-Kk@mail.gmail.com>
References: <1281484174-32174-1-git-send-email-ppannuto@codeaurora.org>
 <1281484174-32174-3-git-send-email-ppannuto@codeaurora.org> <3F978429-F916-42E5-8B36-6AC02DAC8CA2@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
	"magnus.damm@gmail.com" <magnus.damm@gmail.com>,
	"gregkh@suse.de" <gregkh@suse.de>,
	Kevin Hilman <khilman@deeprootsystems.com>,
	Paul Mundt <lethal@linux-sh.org>,
	Magnus Damm <damm@opensource.se>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Eric Miao <eric.y.miao@gmail.com>,
	Dmitry Torokhov <dtor@mail.ru>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kyle D Moffett <kyle@moffetthome.net>
To: "Moffett, Kyle D" <Kyle.D.Moffett@boeing.com>,
	Patrick Pannuto <ppannuto@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3F978429-F916-42E5-8B36-6AC02DAC8CA2@boeing.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Moffett, Kyle D" <Kyle.D.Moffett@boeing.com> wrote:

>On Aug 10, 2010, at 19:49, Patrick Pannuto wrote:
>> As SOCs become more popular, the desire to quickly define a simple,
>> but functional, bus type with only a few unique properties becomes
>> desirable. As they become more complicated, the ability to nest these
>> simple busses and otherwise orchestrate them to match the actual
>> topology also becomes desirable.
>>
>> EXAMPLE USAGE
>>
>> /arch/ARCH/MY_ARCH/my_bus.c:
>>
>> 	#include <linux/device.h>
>> 	#include <linux/platform_device.h>
>>
>> 	struct bus_type SOC_bus_type = {
>> 		.name = "SOC-bus-type",
>> 	};
>> 	EXPORT_SYMBOL_GPL(SOC_bus_type);
>>
>> 	struct platform_device SOC_bus1 = {
>> 		.name	 = "SOC-bus1",
>> 		.id		= -1,
>> 		.dev.bus = &SOC_bus_type;
>> 	};
>> 	EXPORT_SYMBOL_GPL(SOC_bus1);
>>
>> 	struct platform_device SOC_bus2 = {
>> 		.name	 = "SOC-bus2",
>> 		.id		= -2,
>> 		.dev.bus = &SOC_bus_type;
>> 	};
>> 	EXPORT_SYMBOL_GPL(SOC_bus2);
>>
>> 	static int __init SOC_bus_init(void)
>> 	{
>> 		int error;
>>
>> 		error = pseudo_platform_bus_register(&SOC_bus_type);
>> 		if (error)
>> 			return error;
>>
>> 		error = platform_device_register(&SOC_bus1);
>> 		if (error)
>> 			goto fail_bus1;
>>
>> 		error = platform_device_register(&SOC_bus2);
>> 		if (error)
>> 			goto fail_bus2;
>>
>> 		return error;
>>
>> 		/* platform_device_unregister(&SOC_bus2); */
>> fail_bus2:
>> 		platform_device_unregister(&SOC_bus1);
>> fail_bus1:
>> 		pseudo_platform_bus_unregister(&SOC_bus_type);
>>
>> 		return error;
>> 	}
>>
>> /drivers/my_driver.c:
>> 	static struct platform_driver my_driver = {
>> 		.driver = {
>> 			.name	= "my-driver",
>> 			.owner	= THIS_MODULE,
>> 			.bus	= &SOC_bus_type,
>> 		},
>> 	};
>>
>> /somewhere/my_device.c:
>> 	static struct platform_device my_device = {
>> 		.name		= "my-device",
>> 		.id		= -1,
>> 		.dev.bus	= &my_bus_type,
>> 		.dev.parent	= &SOC_bus1.dev,
>> 	};
>>
>> This will build a device tree that mirrors the actual system:
>>
>> /sys/bus
>> |-- SOC-bus-type
>> |   |-- devices
>> |   |   |-- SOC_bus1 -> ../../../devices/SOC_bus1
>> |   |   |-- SOC_bus2 -> ../../../devices/SOC_bus2
>> |   |   |-- my-device -> ../../../devices/SOC_bus1/my-device
>> |   |-- drivers
>> |   |   |-- my-driver
>>
>> /sys/devices
>> |-- SOC_bus1
>> |   |-- my-device
>> |-- SOC_bus2
>>
>> Driver can drive any device on the SOC, which is logical, without
>> actually being registered on multiple /bus_types/, even though the
>> devices may be on different /physical buses/ (which are actually
>> just devices).
>
>Hmm...
>
>To me this seems like a really painful implementation of what the OpenFirmware-esque "Flattened Device Tree" does on many embedded systems.

Patrick and Kevin have been trying to solve a different problem.  The
FDT is really good at describing the topology and interconnections of
the system, but it doesn't solve the problem of how the different bus
behaviour is implemented in the kernel.  They need a method of
registering devices that have subtly different behaviour from the
plain-vanilla platform bus.  Whether or not the device data originates
from the FDT is irrelevant, and the problem remains the same.

I'm not convinced (yet) that this is the right approach, and I'd like
to see a few sample drivers converted to the new approach.  Creating
new bus_types that "inherit" from the platform_bus is actually not a
bad idea, and it is an elegant way to change the behaviour (for
example, how power management is implemented) for devices connected in
a different way.

A problem with the approach that Kevin pointed out is that drivers
that need to work on both the platform_bus_type and the new
soc_bus_type must explicitly register themselves on both bus types.
There is no mechanism to allow drivers from one bus type to also be
made available to another bus type. Certainly it would be possible to
invent a mechanism, but the more I think about it, them more I think
it will be a bad idea.  The runtime-PM use-case that kicked this
discussion off makes the assumption that a driver will behave
identically when attached to either the platform_bus_type or the
soc_bus_type.  However, I think that in the general case that
assumption will prove to be false.  I strongly suspect that the new
bus type will turn out to be not as similar to the platform_bus_type
as originally assumed and that there will still be bus-type-specific
impact on device drivers (but I digress; this paragraph is more
directed to Patrick and Kevin, and doesn't address your comments).

More below...

>For example, to build an equivalent device tree using an OpenFirmware FDT file, I'd just use this:
>
>/dts-v1/;
>/ {
>	#address-cells = <1>;
>	#size-cells = <1>;
>	[...snip...]
>
>	soc-bus-1@fc000000 {
>		/* of_platform driver matches against this: */
>		compatible = "my-company-name,soc-bus-type";
>
>		/* Define base address and size of the bus */
>		reg = <0xfc000000 0x01000000>;
>		#address-cells = <1>;
>		#size-cells = <1>;
>
>		/*
>		 * Define logical memory mapping relative to the bus addr:
>		 * First field is the relative base address for children,
>		 * second field is the address in the parent's memory map,
>		 * third field is the size of the range.
>		 */
>		ranges = <0x0 0xfc000000 0x01000000>;
>
>		/* Now for sub-devices */
>		my-device@0x10000 {
>			compatible = "my-company-name,my-driver";
>			reg = <0x10000 0x100>; /* Address and size */
>		};
>	};
>
>	soc-bus-2@fd000000 {
>		/* of_platform driver matches against this: */
>		compatible = "my-company-name,soc-bus-type";
>
>		/* Define base address and size of the bus */
>		reg = <0xfd000000 0x01000000>;
>		#address-cells = <1>;
>		#size-cells = <1>;
>
>		/*
>		 * Define logical memory mapping relative to the bus addr:
>		 * First field is the relative base address for children,
>		 * second field is the address in the parent's memory map,
>		 * third field is the size of the range.
>		 */
>		ranges = <0x0 0xfd000000 0x01000000>;
>	};
>};
>
>If you don't need to actually do anything special at the bus level, you can just:
>	static struct of_device_id soc_bus_ids[] = {
>		{ .compatible = "soc-bus-type", },
>		{},
>	};
>	of_platform_bus_probe(NULL, &soc_bus_ids, NULL);
>
>Any of_platform driver that matches something on one of those busses is automatically probed.  Alternatively, if you need special bus behavior:
>
>	static struct of_device_id soc_bus_ids[] = {
>		{ .compatible = "soc-bus-type", },
>		{},
>	};
>	static struct of_platform_driver soc_bus_type = {
>		.name = "soc-bus-type",
>		.match_table = &soc_bus_ids,
>		.owner = THIS_MODULE,
>		.probe = mybus_probe,
>		.remove = mybus_remove,
>		.suspend = mybus_suspend,
>		.resume = mybus_resume,
>		.shutdown = mybus_shutdown,
>	};
>
>Then your .probe function actually registers a new OF bus.

Be careful!  This is actually a confusing example.  Linux already has
a concept of a bus_type, and it is not the same as what is shown in
this example.  Part of the problem is that Patrick's explanation leads
the reader to conflate two separate concepts; device topology and
bus_types (but I believe that Patrick understands the difference
between the two).  Topology is the tree of struct devices in the LInux
device model (specified by the .parent pointer).  It is represented by
the /sys/devices/* directory tree.

bus_type groups devices that use the same bus infrastructure, but it
says nothing about topology.  bus_types are represented by the
/sys/bus directory.  For example, a device on the i2c_bus_type must be
an i2c_device, is accessed with the i2c infrastructure, and can be
bound to an i2c_driver.  There can be multiple physical i2c busses in
a system, but all i2c_devices are grouped together in
/sys/bus/i2c/devices (as symlinks to the real location in
/sys/devices).

Using the name "soc-bus-type" in this example makes it easy to confuse
this of_platform_driver with an actual bus_type.

BTW, you'll probably be interested to know that as of about a week
ago, Linus pulled my tree which replaces of_platform_bus_type with the
regular platform_bus_type.  There no longer is any differentiation
between OF and non-OF devices.  Any device may have a pointer to an OF
device tree node regardless of bus_type.  Existing of_platform_drivers
do still work, but a shim is used to register them onto the platform
driver.  Next step is to convert existing of_platform_drivers (like
your example above) into normal platform_drivers.

>The best part is... all devices registered as "of_platform" devices can be used to support many entirely different board models from the exact same kernel.
>
>Fully commented and with actual physical addresses in, my FDT example is comparable to your sample code.  Furthermore, all of the error handling is automatically done, a bunch of device drivers are already ported over, and all the kinks regarding interrupts, etc are already taken care of.  I highly recommend taking a look to see if you can use the very nice existing OF bus code to solve your problem instead of writing yet another half-hard-coded platform bus type.
>
>Cheers,
>Kyle Moffett
>
