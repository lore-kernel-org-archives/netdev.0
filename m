From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: dp83867: Fix for automatically detected PHYs
Date: Fri, 3 Feb 2017 10:34:26 -0800
Message-ID: <9d81d661-de8d-5854-e352-d570bbb3aa43@gmail.com>
References: <20170203165237.22452-1-abrodkin@synopsys.com>
 <20170203171031.GC15900@lunn.ch> <1486143058.2853.27.camel@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "nsekhar@ti.com" <nsekhar@ti.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "m-karicheri2@ti.com" <m-karicheri2@ti.com>,
        "linux-snps-arc@lists.infradead.org"
        <linux-snps-arc@lists.infradead.org>,
        "grygorii.strashko@ti.com" <grygorii.strashko@ti.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
        "andrew@lunn.ch" <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486143058.2853.27.camel@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/03/2017 09:30 AM, Alexey Brodkin wrote:
> Hi Andrew,
> 
> On Fri, 2017-02-03 at 18:10 +0100, Andrew Lunn wrote:
>> On Fri, Feb 03, 2017 at 07:52:37PM +0300, Alexey Brodkin wrote:
>>>
>>> Current implemntation returns ENODEV if device tree node for
>>> phy is absent. But in reality there're many boards with the one
>>> and only PHY on board and MACs that may find a PHY by querying
>>> MDIO bus. One good example is STMMAC.
>>
>> Humm, not so sure about that. That check for an OF node has always
>> been there, since day one for this driver.
>>
>> What has changed recently is where it looks for these device tree
>> properties. It used to wrongly look in the MAC node. It was changed to
>> look in the PHY node. So this is probably the reason you are having
>> problems.
> 
> Well we don't mention PHY node in our device trees because with
> 1 PHY connected via MDIO bus there's no point in spending electrons
> on adding extra stuff. 

That's a terrible justification, you are running Linux on devices, if
you care about electrons run a tiny RTOS ;)

> Well in case if default settings work fine -
> which up until now was the case for us.

You should really consider listing your Ethernet PHY as a child node of
dwmac MDIO bus because that will be a correct and accurate
representation of the hardware, and if the PHY driver needs specific
properties to be given (e.g: random TX/RX delays, etc.) that is the only
way you could communicate those properly to the PHY driver.

> 
> Just in case that's a typical example:
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/arch/arc/boot/dts/axs10x_mb.dtsi#n58
> 
> ----------------------->8-----------------------
> 	ethernet@0x18000 {
> 		#interrupt-cells = <1>;
> 		compatible = "snps,dwmac";
> 		reg = < 0x18000 0x2000 >;
> 		interrupts = < 4 >;
> 		interrupt-names = "macirq";
> 		phy-mode = "rgmii";
> 		snps,pbl = < 32 >;
> 		clocks = <&apbclk>;
> 		clock-names = "stmmaceth";
> 		max-speed = <100>;
> 	};
> ----------------------->8-----------------------
> 
> This is especially nice because we may change the base-board and use
> there another PHY and as long we have drivers for all possible PHY built
> in the kernel (or available via modules) proper driver will be instantiated
> based on PHY ID read from MDIO. I.e. having no PHY node in DT adds flexibility.

The of_mdio code can automatically scan PHYs on the bus, and try to
associate them with a proper Device Tree node reference, would that
exist, but this is really fragile.
-- 
Florian
