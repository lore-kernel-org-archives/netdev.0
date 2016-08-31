From: Lars Persson <lars.persson-VrBV9hrLPhE@public.gmane.org>
Subject: Re: [PATCH V2] dt: net: enhance DWC EQoS binding to support Tegra186
Date: Wed, 31 Aug 2016 11:15:15 +0200
Message-ID: <190a6bc1-ef66-2927-e542-13c543bab3b9@axis.com>
References: <20160824212046.2416-1-swarren@wwwdotorg.org>
 <20160830190152.GA25083@rob-hp-laptop>
 <54b380c4-179f-2260-55dd-4220e65f8f46@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lars Persson <larper-VrBV9hrLPhE@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephen Warren <swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
To: Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>,
        Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54b380c4-179f-2260-55dd-4220e65f8f46-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 08/30/2016 10:50 PM, Stephen Warren wrote:
> On 08/30/2016 01:01 PM, Rob Herring wrote:
>> On Wed, Aug 24, 2016 at 03:20:46PM -0600, Stephen Warren wrote:
>>> From: Stephen Warren <swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
>>>
>>> The Synopsys DWC EQoS is a configurable IP block which supports multiple
>>> options for bus type, clocking and reset structure, and feature list.
>>> Extend the DT binding to define a "compatible value" for the
>>> configuration
>>> contained in NVIDIA's Tegra186 SoC, and define some new properties and
>>> list property entries required by that configuration.
>
>>> diff --git
>>> a/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
>>> b/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
>
>>>  Required properties:
>
>>> -- clocks: Phandles to the reference clock and the bus clock
>>> -- clock-names: Should be "phy_ref_clk" for the reference clock and
>>> "apb_pclk"
>>> -  for the bus clock.
>>> +- clocks: Phandle and clock specifiers for each entry in
>>> clock-names, in the
>>> +  same order. See ../clock/clock-bindings.txt.
>>> +- clock-names: May contain any/all of the following depending on the IP
>>> +  configuration, in any order:
>>
>> No, they should be in a defined order.
>
> If the binding only defines "clocks", then yes the order must be specified.
>
> If the binding defines clock-names too, then the order is arbitrary
> since all clocks must be looked up via clock-names. That's the entire
> point of having a clock-names property.
>
> ...
>>> +    The EQOS transmit path clock. The HW signal name is clk_tx_i.
>>> +    In some configurations (e.g. GMII/RGMII), this clock also drives
>>> the PHY TX
>>> +    path. In other configurations, other clocks (such as tx_125,
>>> rmii) may
>>> +    drive the PHY TX path.
>>> +  - "rx"
>>> +    The EQOS receive path clock. The HW signal name is clk_rx_i.
>>> +    In some configurations (e.g. GMII/RGMII), this clock also drives
>>> the PHY RX
>>> +    path. In other configurations, other clocks (such as rx_125,
>>> pmarx_0,
>>> +    pmarx_1, rmii) may drive the PHY RX path.

It is not correct that clk_rx_i drives the PHY rx path for GMII/RGMII. 
The PHY is the source of the rx clock for these modes.

Will the driver need to make any clock ops on the "rx" clock ?


>>> +  - "slave_bus"
>>> +    (Alternate name "apb_pclk"; only one alternate must appear.)
>>> +    The CPU/slave-bus (CSR) interface clock. Despite the name, this
>>> applies to
>>> +    any bus type; APB, AHB, AXI, etc. The HW signal name is hclk_i
>>> (AHB) or
>>> +    clk_csr_i (other buses).
>>
>> Sounds like 2 clocks here.
>>
>>> +  - "master_bus"
>>> +    The master bus interface clock. Only required in configurations
>>> that use a
>>> +    separate clock for the master and slave bus interfaces. The HW
>>> signal name
>>> +    is hclk_i (AHB) or aclk_i (AXI).
>>
>> Sounds like 2 clocks. I'm guessing these are mutually exclusive based on
>> whether you configure the IP for AHB or AXI?
>
> Yes, my understanding is that the two clocks are mutually exclusive in
> both cases.
>
> It seems simpler to have an entry in clocks/clock-names for each logical
> purpose, so that the driver can always retrieve a "slave bus clock" and
> a "master bus clock". That way, there's never any conditional code in
> the driver; it just gets two fixed clock names and enables them, no
> matter what the HW configuration.
>
> If the binding specifies 3 clocks, hclk_i, clk_csr_i, and aclk_i, then
> the driver needs to know which subset of clocks to retrieve based on
> compatible value or HW configuration. That seems like unnecessary
> complexity. I suppose the driver could just attempt to retrieve all 3
> clocks, and ignore any missing clocks, but that would allow malformed
> DTs not to be noticed since the driver wouldn't validate the set of
> clocks present, and could lead to the driver touching the HW without all
> required clocks active, which at least in Tegra can lead to a HW hang.
>

I agree, keep the logical names.

>>> +  Note: Support for additional IP configurations may require adding the
>>> +  following clocks to this list in the future: clk_rx_125_i,
>>> clk_tx_125_i,
>>> +  clk_pmarx_0_i, clk_pmarx1_i, clk_rmii_i, clk_revmii_rx_i,
>>> clk_revmii_tx_i.
>>> +
>>> +  The following compatible values require the following set of clocks:
>>> +  - "nvidia,tegra186-eqos", "snps,dwc-qos-ethernet-4.10":
>>> +    - "slave_bus"
>>> +    - "master_bus"
>>> +    - "rx"
>>> +    - "tx"
>>> +    - "ptp_ref"
>>> +  - "axis,artpec6-eqos", "snps,dwc-qos-ethernet-4.10":
>>> +    - "phy_ref_clk"
>>> +    - "apb_clk"
>>
>> It would be good if this was marked deprecated and the full set of
>> clocks could be described and supported. Not sure if you can figure that
>> out. Is it really only 2 clocks, or these have multiple connections to
>> the same source.
>
> Lars, can you answer here?
>
> I deliberately didn't attempt to change the binding definition for the
> existing use-case, since I'm not familiar with that SoC, and don't
> relish changing DTs for a platform I can't test.

For the artpec-6 the clocks are like this:
apb_clk: It is both the master and slave bus clock.
phy_ref_clk: It corresponds to tx clock in the proposed new binding.

There is a also a ptp reference clock that will map to the new ptp_ref 
clock binding.

So the full set of clocks in a new artpec-6 binding is:
slave_bus
master_bus
tx
ptp_ref


BR,
  Lars
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
