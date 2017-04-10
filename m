From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH] net: davinci_mdio: add GPIO reset logic
Date: Mon, 10 Apr 2017 10:52:08 +0300
Message-ID: <e2b35825-05b6-461e-b8ac-fdbc04ecd97d@ti.com>
References: <1491381237-24635-1-git-send-email-rogerq@ti.com>
 <20170408.065545.2057882592764132853.davem@davemloft.net>
 <20170408151050.GA30797@lunn.ch>
 <3d50d82b-ca03-5e53-dec7-f44f5f0430bb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <tony@atomide.com>, <nsekhar@ti.com>, <jsarha@ti.com>,
        <netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3d50d82b-ca03-5e53-dec7-f44f5f0430bb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/04/17 18:18, Florian Fainelli wrote:
> 
> 
> On 04/08/2017 08:10 AM, Andrew Lunn wrote:
>> On Sat, Apr 08, 2017 at 06:55:45AM -0700, David Miller wrote:
>>> From: Roger Quadros <rogerq@ti.com>
>>> Date: Wed, 5 Apr 2017 11:33:57 +0300
>>>
>>>> Some boards [1] leave the PHYs at an invalid state
>>>> during system power-up or reset thus causing unreliability
>>>> issues with the PHY like not being detected by the mdio bus
>>>> or link not functional. To work around these boards have
>>>> a GPIO connected to the PHY's reset pin.
>>>>
>>>> Implement GPIO reset handling for such cases.
>>>>
>>>> [1] - am572x-idk, am571x-idk, a437x-idk.
>>>>
>>>> Signed-off-by: Roger Quadros <rogerq@ti.com>
>>>> Signed-off-by: Sekhar Nori <nsekhar@ti.com>
>>>
>>> I have not seen a resolution in this discussion.
>>>
>>> My understanding is that there are several cases (single MDIO bus whose
>>> reset does a reset on all that MDIO bus's PHYs, etc.) and it's unclear
>>> how to handle all such cases cleanly.
>>
>> I see it falling into two cases.
>>
>> 1) We have a GPIO which resets one PHY. In this case, the GPIO is a
>> PHY property, it should be documented in
>> Documentation/devicetree/bindings/net/phy.txt. Hopefully there is
>> nothing PHY driver specific here, so all the handling can be placed in
>> the core PHY code.
> 
> I suspect we would have to release the PHY GPIO reset line within a
> mii_bus::reset callback, which occurs before the PHY registers are read.
> There is this chicken and egg problem where you can't probe for a PHY
> unless you can successfully read from it, and you can't do the PHY reset
> in the PHY drivers' probe function unless you were able to find a PHY
> device.

+1
This is the exact problem we were facing so the reset has to be done at
MDIO bus level, before PHY probe.

> 
> NB: you can work around that by using an Ethernet PHY device compatible
> string in Device Tree that already has the PHY OUI specified, although
> that usually does not scale to many different boards/designs.
> 
>>
>> 2) We have one or more GPIOs which reset more than one PHY. In this
>> case, the GPIOs are MDIO bus properties. Again, there should not be
>> anything which is MDIO bus driver specific, so all the handling can be
>> placed in the core MDIO bus code.
> 
> Agreed.
> 
> I would do something like:
> 
> - if the MDIO bus node has a "gpio" reset property, use it and release
> the device from reset
> - for each available child node:
> 	- if the PHY/MDIO device's node have a "gpio" reset property use it and
> release the PHYs from reset.
> 
> All of this should probably be placed somewhere in drivers/of/of_mdio.c
> and deal with conditional GPIO/RESET controller support.
> 

I agree with this proposal. Just need to spend some time to rework this patch.

cheers,
-roger
