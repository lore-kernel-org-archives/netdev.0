From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH v4 net-next] mdio_bus: Issue GPIO RESET to PHYs.
Date: Wed, 26 Apr 2017 13:46:49 +0300
Message-ID: <acb28e07-0066-e4fe-6479-5edc3ee32d80@ti.com>
References: <1491381237-24635-1-git-send-email-rogerq@ti.com>
 <64d6494d-41d2-0faf-a434-057f796637fe@ti.com>
 <daa29a99-0a17-d316-57eb-3e6162938d8d@ti.com>
 <f372db02-a919-55b4-9200-20726cd13482@ti.com>
 <fe0b7ec5-2f83-ba06-579f-3ea0d5c4990c@ti.com>
 <1c36aab1-3411-f76d-67f7-e3f6d9e9fda5@metafoo.de>
 <20170423233553.GA23498@lunn.ch>
 <551ee7a0-d153-3a36-e025-2c1f70f866b7@ti.com>
 <5954130c-c08c-1555-4d34-83307ed68d92@metafoo.de>
 <7c443bf0-03ac-cc1c-3776-a36287801e96@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <tony@atomide.com>, <nsekhar@ti.com>,
        <jsarha@ti.com>, <netdev@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Lars-Peter Clausen <lars@metafoo.de>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx193.ext.ti.com ([198.47.27.77]:43371 "EHLO
        lelnx193.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1957356AbdDZKrO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 06:47:14 -0400
In-Reply-To: <7c443bf0-03ac-cc1c-3776-a36287801e96@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/04/17 19:31, Florian Fainelli wrote:
> On 04/25/2017 09:22 AM, Lars-Peter Clausen wrote:
>> On 04/24/2017 11:04 AM, Roger Quadros wrote:
>>> On 24/04/17 02:35, Andrew Lunn wrote:
>>>> On Fri, Apr 21, 2017 at 03:31:09PM +0200, Lars-Peter Clausen wrote:
>>>>> On 04/21/2017 03:15 PM, Roger Quadros wrote:
>>>>>> diff --git a/Documentation/devicetree/bindings/net/mdio.txt b/Documentation/devicetree/bindings/net/mdio.txt
>>>>>> new file mode 100644
>>>>>> index 0000000..4ffbbac
>>>>>> --- /dev/null
>>>>>> +++ b/Documentation/devicetree/bindings/net/mdio.txt
>>>>>> @@ -0,0 +1,33 @@
>>>>>> +Common MDIO bus properties.
>>>>>> +
>>>>>> +These are generic properties that can apply to any MDIO bus.
>>>>>> +
>>>>>> +Optional properties:
>>>>>> +- reset-gpios: List of one or more GPIOs that control the RESET lines
>>>>>> +  of the PHYs on that MDIO bus.
>>>>>> +- reset-delay-us: RESET pulse width in microseconds as per PHY datasheet.
>>>>>> +
>>>>>> +A list of child nodes, one per device on the bus is expected. These
>>>>>> +should follow the generic phy.txt, or a device specific binding document.
>>>>>> +
>>>>>> +Example :
>>>>>> +This example shows these optional properties, plus other properties
>>>>>> +required for the TI Davinci MDIO driver.
>>>>>> +
>>>>>> +	davinci_mdio: ethernet@0x5c030000 {
>>>>>> +		compatible = "ti,davinci_mdio";
>>>>>> +		reg = <0x5c030000 0x1000>;
>>>>>> +		#address-cells = <1>;
>>>>>> +		#size-cells = <0>;
>>>>>> +
>>>>>> +		reset-gpios = <&gpio2 5 GPIO_ACTIVE_LOW>;
>>>>>> +		reset-delay-us = <2>;   /* PHY datasheet states 1us min */
>>>>>
>>>>> If this is the reset line of the PHY shouldn't it be a property of the PHY
>>>>> node rather than of the MDIO controller node (which might have a reset on
>>>>> its own)?
>>>>>> +
>>>>>> +		ethphy0: ethernet-phy@1 {
>>>>>> +			reg = <1>;
>>>>>> +		};
>>>>>> +
>>>>>> +		ethphy1: ethernet-phy@3 {
>>>>>> +			reg = <3>;
>>>>>> +		};
>>>>
>>>> Hi Lars-Peter
>>>>
>>>> We discussed this when the first proposal was made. There are two
>>>> cases, to consider.
>>>>
>>>> 1) Here, one GPIO line resets all PHYs on the same MDIO bus. In this
>>>> example, two PHYs.
>>>>
>>>> 2) There is one GPIO line per PHY. That is a separate case, and as you
>>>> say, the reset line should probably be considered a PHY property, not
>>>> an MDIO property. However, it can be messy, since in order to probe
>>>> the MDIO bus, you probably need to take the PHY out of reset.
>>>>
>>
>> But the DT binding documentation says something else "List of one or more
>> GPIOs that control the RESET lines of the PHYs on that MDIO bus".
> 
> I agree, it should be defined more strictly as:
> 
> "One GPIO that controls the reset line of *all* PHYs populated on that
> MDIO bus"

Patch is already in net-next. How can we get this fixed? Should I send a v5?

> 
> If there are separate lines, these automatically become properties of
> the PHY nodes.
> 
>>
>>>> Anyway, this patch addresses the first case, so should be accepted. If
>>>> anybody wants to address the second case, they are free to do so.
>>
>> I think we all know that that's not going to happen. Once there is a working
>> kludge there is no incentive to do a proper implementation anymore.
>>
>>
>>> Thanks for the explanation Andrew.
>>>
>>> For the second case, even if the RESET GPIO property is specified
>>> in the PHY node, the RESET *will* have to be done by the MDIO bus driver
>>> else the PHY might not be probed at all.
>>
>> I'm not arguing with that, just that the hardware description should be
>> truthful to the hardware topology and not to the software topology, i.e. the
>> implementation details of the Linux kernel in this case. Reset GPIOs are not
>> the only resource that is connected to the PHY that needs to be enabled
>> before they can be enumerated. E.g. clocks and regulators fall into the same
>> realm. And while you might argue that with a on-SoC phy controller node
>> there wont be any conflicts in regard to the reset-gpios property, this not
>> so very true for the clocks property.
> 
> Agreed, but with the exception of the unfortunate choice of words here
> (single vs. multiple) there is not a really a divergence in how the
> shared reset line is represented compared to other similar control
> busses, is there?
> 
>>
>> And MDIO is not really special in this regard, other discoverable buses
>> (like USB, SDIO, ULPI) have the very same issue. Having a standardized
>> binding approach where the resources are declared as part as the child child
>> is preferable in my opinion.
>>
>>>
>>> Whether we need additional code to just to make the DT look prettier is
>>> questionable and if required can come as a separate patch.
>>
>> Unfortunately not, once it is merged it can't be changed anymore.
> 
> There are no in tree users yet, so let's get the different things fixed
> right now.
> 

-- 
cheers,
-roger
