From: Santosh Shilimkar <santosh.shilimkar-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v2 0/3] net: Add Keystone NetCP ethernet driver support
Date: Fri, 22 Aug 2014 15:45:09 -0400
Message-ID: <53F79DC5.8030003@ti.com>
References: <1408115562-22487-1-git-send-email-santosh.shilimkar@ti.com> <20140821.163612.282672926741753926.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<sandeep_n-l0cyMroinI0@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140821.163612.282672926741753926.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,

On Thursday 21 August 2014 07:36 PM, David Miller wrote:
> From: Santosh Shilimkar <santosh.shilimkar-l0cyMroinI0@public.gmane.org>
> Date: Fri, 15 Aug 2014 11:12:39 -0400
> 
>> Update version after incorporating David Miller's comment from earlier
>> posting [1]. I would like to get these merged for upcoming 3.18 merge
>> window if there are no concerns on this version.
>>
>> The network coprocessor (NetCP) is a hardware accelerator that processes
>> Ethernet packets. NetCP has a gigabit Ethernet (GbE) subsystem with a ethernet
>> switch sub-module to send and receive packets. NetCP also includes a packet
>> accelerator (PA) module to perform packet classification operations such as
>> header matching, and packet modification operations such as checksum
>> generation. NetCP can also optionally include a Security Accelerator(SA)
>> capable of performing IPSec operations on ingress/egress packets.
>>     
>> Keystone SoC's also have a 10 Gigabit Ethernet Subsystem (XGbE) which
>> includes a 3-port Ethernet switch sub-module capable of 10Gb/s and
>> 1Gb/s rates per Ethernet port.
>>     
>> NetCP driver has a plug-in module architecture where each of the NetCP
>> sub-modules exist as a loadable kernel module which plug in to the netcp
>> core. These sub-modules are represented as "netcp-devices" in the dts
>> bindings. It is mandatory to have the ethernet switch sub-module for
>> the ethernet interface to be operational. Any other sub-module like the
>> PA is optional.
>>
>> Both GBE and XGBE network processors supported using common driver. It
>> is also designed to handle future variants of NetCP.
> 
> I don't want to see an offload driver that doesn't plug into the existing
> generic frameworks for configuration et al.
> 
> If no existing facility exists to support what you need, you must work
> with the upstream maintainers to design and create one.
> 
> It is absolutely no reasonable for every "switch on a chip" driver to
> export it's own configuration knob, we need a standard interface all
> such drivers will plug into and provide.
> 
The NetCP plugin module infrastructure use all the standard kernel
infrastructure and its very tiny. To best represent the Network processor
and its sub module hardware which have inter dependency and ordering
needs, we needed such infrastructure. This lets us handle all the
hardware needs without any code duplication per module.

To elaborate more, there are 4 variants of network switch modules and
then few accelerator modules like Packet accelerator, QOS and Security
accelerator. There can be multiple instances of switches on same SOC.
Example 1 Gbe and 10 Gbe switches. Then additional accelerator modules
are inter connected with switch, streaming fabric and packet DMA.
Packet routing changes based on the various offload modules presence and hence
needs hooks for tx/rx to be called in particular order with special
handling. This scheme is very hardware specific and doesn't have ways
to isolate the modules from each other.

On the other hand, we definitely wanted to have minimal code
instead of duplicating ndo operations and core packet processing logic
in multiple drivers or layers. The module approach helps
to isolate the code based on the customer choice who can choose
say not to build 10 Gbe hardware or say don't need QOS or Security
accelerators. That way we keep the packet processing hot path as
what we need without any overhead.

As you can see, the tiny module handling was added more to represent
the hardware, keep the modularity and avoid code duplication. The
infrastructure is very minimal and NETCP specific. With this small
infrastructure we are able to re-use code for NetCP1.0, NetCP1.5,
10 GBe and upcoming NetCP variants from just *one* driver.

Hope this gives you a better idea and rationale behind the design.

Regards,
Santosh
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
