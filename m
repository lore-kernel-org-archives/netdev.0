From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Subject: Re: [PATCH 3/7] net: phy: spi_ks8995: add register initialization
Date: Mon, 8 Feb 2016 09:28:56 +0100
Message-ID: <56B851C8.4080401@gmail.com>
References: <1454884753-4560-1-git-send-email-helmut.buchsbaum@gmail.com>
 <1454884753-4560-4-git-send-email-helmut.buchsbaum@gmail.com>
 <56B81BC1.6090904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34358 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbcBHI3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 03:29:01 -0500
Received: by mail-wm0-f67.google.com with SMTP id p63so14372821wmp.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 00:29:00 -0800 (PST)
In-Reply-To: <56B81BC1.6090904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/08/2016 05:38 AM, Florian Fainelli wrote:
> On 07/02/2016 14:39, Helmut Buchsbaum wrote:
>> Since several use cases need to setup at least some basic control
>> registers add the ability to configure an array containing such
>> register initialization values within the platform data of the switch.
>> Furthermore expose this capabilty to the devicetree.
>>
>> Platform data now contains a pointer to an array and the array length
>> where each member contains the register to be initialized, the
>> initialization value and a register mask, since in many use cases there
>> is only the need to init some bits of a register, e.g. disabling unused
>> ports.
>>
>> The devicetree notation add the property 'settings' to the SPI node of the
>> ks8985 driver, which is a list of triple values (register, value, mask),
>> e.g.:
>>
>> settings = <0x4D 0x08 0x08
>>              0x5D 0x08 0x08>;
>
> You encode way too much in the Device Tree that should be knowledge to
> the driver on how to configure the switch. This is very tempting,
> because you do not dictate any use case and let people define it based
> on their Device Tree source, but at the same time, this is very error
> prone and does not provide what a proper device driver needs to be doing
> by defining a standard and predictable behavior.
>
> Right now this driver is a PHY driver, but it should be moved to a DSA
> driver eventually such that each port is exposed as a network interface,
> and you have hooks to power on/off ports based on whether a
> corresponding network interface is up/down.
> --
> Florian
>
The way I built these initialization settings was inspired by the way it 
is done in the pinctrl subsystem: there you also configure the pin 
functions in a very hardware specific way (dependent on the underlying 
pinctrl hardware). Thus this was just extending a principle we can find 
in other subsystems of the kernel to this driver. Furthermore the 
register interface is already exposed to the user space via sysfs, 
which, in my opinion, is even more error prone then setting up the 
Device Tree carefully.

Nevertheless, I can perfectly understand your point of view. This is 
just what thought when I saw all registers are accessible from user space!

At the moment I use this driver with a KSZ8795CLX, port 5 directly 
connected to a MACB/GEM of a Zynq SOC, with the need to enable the RGMII 
internal clock delay (register 0x56,  bit 4), otherwise the the Zynq 
cannot talk to the switch on its RGMII interface (being able to switch 
off unused ports is just a nice add-on I use). Using the sysfs 
capabilities of this driver might be an alternative, but contradicts our 
requirement to set up the network interfaces as fast as possible. 
Furthermore stuff like IP_PNP or nfs root won't work. But maybe I should 
try to move this kind of basic setup to bootloader - I'll investigate 
this idea!

Since I'm not at all (yet) familiar with the DSA subsystem I wonder how 
I could manage setting the clock delay bit with DSA. Would this be a 
driver specific setting or can it be fulfilled within the subsystem?

Since I still want to share my work for the PHY only driver, is it ok if 
I'll resend the patch series just without part 3 to get support for the 
KSZ8795? Let's talk about the part 3 functionality and moving the driver 
to DSA separately!

BTW, are there any additional links about DSA complementing the kernel
documentation?

Thanks for your comments,
Helmut
