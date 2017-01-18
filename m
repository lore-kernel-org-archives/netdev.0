From: Robin Murphy <robin.murphy@arm.com>
Subject: Re: Initializing MAC address at run-time
Date: Wed, 18 Jan 2017 15:35:09 +0000
Message-ID: <f902209c-268b-5abe-4527-c8d0e56bce79@arm.com>
References: <e083ed68-0e8e-380e-23bd-5ad387c88575@free.fr>
 <20170118144528.GH3231@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>,
        DT <devicetree@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>,
        Kevin Hilman <khilman@kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
        Uwe Kleine-Konig <u.kleine-koenig@pengutronix.de>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:56736 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751999AbdARPf1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 10:35:27 -0500
In-Reply-To: <20170118144528.GH3231@leverpostej>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/01/17 14:45, Mark Rutland wrote:
> On Wed, Jan 18, 2017 at 03:03:57PM +0100, Mason wrote:
>> Hello,
>>
>> When my system boots up, eth0 is given a seemingly random MAC address.
>>
>> [    0.950734] nb8800 26000.ethernet eth0: MAC address ba:de:d6:38:b8:38
>> [    0.957334] nb8800 26000.ethernet eth0: MAC address 6e:f1:48:de:d6:c4
>>
>>
>> The DT node for eth0 is:
>>
>> 	eth0: ethernet@26000 {
>> 		compatible = "sigma,smp8734-ethernet";
>> 		reg = <0x26000 0x800>;
>> 		interrupts = <38 IRQ_TYPE_LEVEL_HIGH>;
>> 		clocks = <&clkgen SYS_CLK>;
>> 	};
>>
>> Documentation/devicetree/bindings/net/ethernet.txt mentions
>> - local-mac-address: array of 6 bytes, specifies the MAC address that was
>>   assigned to the network device;
>>
>> And indeed, if I define this property, eth0 ends up with the MAC address
>> I specify in the device tree. But of course, I don't want all my boards
>> to share the same MAC address. Every interface has a unique MAC address.
>>
>> In fact, the boot loader (not Uboot, a custom non-DT boot loader) stores
>> the MAC address somewhere in MMIO space, in some weird custom format.
>>
>> So, at init, I can find the MAC address, and dynamically insert the
>> "local-mac-address" property in the eth0 node.
> 
> To me it sounds very convoluted to do this from the kernel, to pass
> information back to itself. I don't think this is the best way to handle
> this.
> 
>> Is there another (better) way to do this?
>>
>> I'll post my code below, for illustration purpose.
>>
>> Mark suggested this can be done from user-space, but I can't do that,
>> because I'm using an NFS rootfs, so I need the network before I even
>> have a user-space. And the DHCP server is configured to serve different
>> root filesystems, based on the MAC address.
> 
> That's not quite what I said. I asked whether your information was
> coming from userspace or from a kernel driver.
> 
> My suggestion was that this should be done in the probe path somehow,
> by describing the relationship between the ethernet controller and the
> device containing the MAC information.
> 
> e.g. on the ethernet device, have a phandle (and perhaps some other
> args) describinng the device containing the MAC, and how to extract it.
> 
> That way, in the ethernet probe path we can go and look up the MAC
> address from the provider of that information.

See Documentation/devicetree/bindings/mfd/syscon.txt and
bindings/drivers with syscon dependencies. Essentially, you would use a
syscon node to describe "somewhere in MMIO space", then your ethernet
driver probe routine simply grabs the regmap, pulls out the MAC and goes
from there.

Be warned that the above represents the totality of my technical
knowledge on the subject ;) My experience is in hacking up DTs for
drivers which already use this mechanism, rather than in implementing it.

Robin.

>> I need to do something similar with the NAND partitions. The boot loader
>> stores the partition offsets somewhere, and I need to pass this info
>> to the NAND framework, so I assumed that inserting the corresponding
>> properties at run-time was the correct way to do it.
> 
> I would say similar could happen here.
> 
> Thanks,
> Mark.
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 
