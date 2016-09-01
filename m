From: Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
Subject: Re: [PATCH V2] dt: net: enhance DWC EQoS binding to support Tegra186
Date: Thu, 1 Sep 2016 12:15:11 -0600
Message-ID: <a86d0be6-8efb-0180-675f-032bfdf1044c@wwwdotorg.org>
References: <20160824212046.2416-1-swarren@wwwdotorg.org>
 <20160830190152.GA25083@rob-hp-laptop>
 <54b380c4-179f-2260-55dd-4220e65f8f46@wwwdotorg.org>
 <190a6bc1-ef66-2927-e542-13c543bab3b9@axis.com>
 <f4f85b48-4df6-4a3c-2831-e5707d35ebb6@wwwdotorg.org>
 <d60d2deb-49dd-2561-bbde-20d2ff13ca4b@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Stephen Warren <swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
To: Lars Persson <lars.persson-VrBV9hrLPhE@public.gmane.org>,
        Lars Persson <larper-VrBV9hrLPhE@public.gmane.org>, Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <d60d2deb-49dd-2561-bbde-20d2ff13ca4b-VrBV9hrLPhE@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/01/2016 01:50 AM, Lars Persson wrote:
>
>
> On 08/31/2016 11:48 PM, Stephen Warren wrote:
>> On 08/31/2016 03:15 AM, Lars Persson wrote:
>>> On 08/30/2016 10:50 PM, Stephen Warren wrote:
>>>> On 08/30/2016 01:01 PM, Rob Herring wrote:
>>>>> On Wed, Aug 24, 2016 at 03:20:46PM -0600, Stephen Warren wrote:
>>>>>> The Synopsys DWC EQoS is a configurable IP block which supports
>>>>>> multiple
>>>>>> options for bus type, clocking and reset structure, and feature list.
>>>>>> Extend the DT binding to define a "compatible value" for the
>>>>>> configuration
>>>>>> contained in NVIDIA's Tegra186 SoC, and define some new properties
>>>>>> and
>>>>>> list property entries required by that configuration.
>>
>>>>>> diff --git
>>>>>> a/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
>>>>>> b/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
>>
>>>>>> +- clock-names: May contain any/all of the following depending on
>>>>>> the IP
>>>>>> +  configuration, in any order:
>>>>>> +    The EQOS transmit path clock. The HW signal name is clk_tx_i.
>>>>>> +    In some configurations (e.g. GMII/RGMII), this clock also drives
>>>>>> the PHY TX
>>>>>> +    path. In other configurations, other clocks (such as tx_125,
>>>>>> rmii) may
>>>>>> +    drive the PHY TX path.
>>>>>> +  - "rx"
>>>>>> +    The EQOS receive path clock. The HW signal name is clk_rx_i.
>>>>>> +    In some configurations (e.g. GMII/RGMII), this clock also drives
>>>>>> the PHY RX
>>>>>> +    path. In other configurations, other clocks (such as rx_125,
>>>>>> pmarx_0,
>>>>>> +    pmarx_1, rmii) may drive the PHY RX path.
>>>
>>> It is not correct that clk_rx_i drives the PHY rx path for GMII/RGMII.
>>> The PHY is the source of the rx clock for these modes.
>>
>> I think both of our statements are true.
>>
>> There's a clock input to the EQOS module (clk_rx_i) that does drive the
>> RX path in the EQOS module.
>>
>> That clock also drives the PHY's RX path.
>>
>> Those statements make no comment regarding the /source/ of that clock;
>> either of the following might be true:
>>
>> 1) The PHY could generate the clock internally somehow, feed its own
>> internal logic with that clock, and send the clock out to feed the EQOS
>> RX path too.
>>
>> or,
>>
>> 2)  SoC integration could drive the same clock into both the EQOS and
>> PHY modules, so that both sets of logic are fed from the same external
>> clock.
>>
>> Perhaps the phrase "PHY RX path" is confusing; I was talking about the
>> EQOS modules' RX path from the PHY more than the PHY itself, although
>> given what I said above I believe either interpretation is valid and
>> correct.
>>
>>> Will the driver need to make any clock ops on the "rx" clock ?
>>
>> Yes. The EQOS driver needs to ensure that the clock is running before
>> attempting to receive data from the PHY, otherwise the EQOS's own RX
>> logic won't be clocked.
>>
>> Whether the phandle for this clock points at a SoC-level provider (it
>> will in Tegra) or a clock provider in the PHY (it might in other SoCs),
>> shouldn't matter as far as the DT binding goes, although it might affect
>> device probe ordering in some implementations.
>>
>
> I understand your point. The lines between PHY, MAC and SoC gets blurred
> with high integration.
>
> The thing is that when we talk about standard PHY interfaces the clock
> is a well defined part of the interface and it should not be mixed up
> with SoC-specific implementations that deviate from this. Please update
> the description of the rx clock to only cover cases when the clock is
> not implicitly sourced from the PHY.
>
> When the PHY is the source of the clock then it is managed by the phy
> library and the phy driver so it does not need to be also handled by the
> common clock framework.

Ah, I've found the source of confusion. We don't have an SoC-level clock 
that feeds both the MAC and the PHY RX logic, but simply a clock gate 
that sits between the RX clock output of the PHY and the RX clock input 
of the MAC (clk_rx_i). This gate is what's currently represented by the 
"rx" clock name the binding mentions.

tl;dr is that yes I agree to update the description of this rx clock 
along the lines you ask for.
