From: Stephen Warren <swarren@wwwdotorg.org>
Subject: Re: [PATCH V2] dt: net: enhance DWC EQoS binding to support Tegra186
Date: Wed, 31 Aug 2016 15:48:08 -0600
Message-ID: <f4f85b48-4df6-4a3c-2831-e5707d35ebb6@wwwdotorg.org>
References: <20160824212046.2416-1-swarren@wwwdotorg.org>
 <20160830190152.GA25083@rob-hp-laptop>
 <54b380c4-179f-2260-55dd-4220e65f8f46@wwwdotorg.org>
 <190a6bc1-ef66-2927-e542-13c543bab3b9@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lars Persson <larper@axis.com>,
        Mark Rutland <mark.rutland@arm.com>,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-tegra@vger.kernel.org, Stephen Warren <swarren@nvidia.com>
To: Lars Persson <lars.persson@axis.com>, Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avon.wwwdotorg.org ([70.85.31.133]:53628 "EHLO
        avon.wwwdotorg.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753692AbcHaVsM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 17:48:12 -0400
In-Reply-To: <190a6bc1-ef66-2927-e542-13c543bab3b9@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2016 03:15 AM, Lars Persson wrote:
> On 08/30/2016 10:50 PM, Stephen Warren wrote:
>> On 08/30/2016 01:01 PM, Rob Herring wrote:
>>> On Wed, Aug 24, 2016 at 03:20:46PM -0600, Stephen Warren wrote:
>>>> The Synopsys DWC EQoS is a configurable IP block which supports multiple
>>>> options for bus type, clocking and reset structure, and feature list.
>>>> Extend the DT binding to define a "compatible value" for the configuration
>>>> contained in NVIDIA's Tegra186 SoC, and define some new properties and
>>>> list property entries required by that configuration.

>>>> diff --git
>>>> a/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
>>>> b/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt

>>>> +- clock-names: May contain any/all of the following depending on the IP
>>>> +  configuration, in any order:
>>>> +    The EQOS transmit path clock. The HW signal name is clk_tx_i.
>>>> +    In some configurations (e.g. GMII/RGMII), this clock also drives
>>>> the PHY TX
>>>> +    path. In other configurations, other clocks (such as tx_125,
>>>> rmii) may
>>>> +    drive the PHY TX path.
>>>> +  - "rx"
>>>> +    The EQOS receive path clock. The HW signal name is clk_rx_i.
>>>> +    In some configurations (e.g. GMII/RGMII), this clock also drives
>>>> the PHY RX
>>>> +    path. In other configurations, other clocks (such as rx_125,
>>>> pmarx_0,
>>>> +    pmarx_1, rmii) may drive the PHY RX path.
>
> It is not correct that clk_rx_i drives the PHY rx path for GMII/RGMII.
> The PHY is the source of the rx clock for these modes.

I think both of our statements are true.

There's a clock input to the EQOS module (clk_rx_i) that does drive the 
RX path in the EQOS module.

That clock also drives the PHY's RX path.

Those statements make no comment regarding the /source/ of that clock; 
either of the following might be true:

1) The PHY could generate the clock internally somehow, feed its own 
internal logic with that clock, and send the clock out to feed the EQOS 
RX path too.

or,

2)  SoC integration could drive the same clock into both the EQOS and 
PHY modules, so that both sets of logic are fed from the same external 
clock.

Perhaps the phrase "PHY RX path" is confusing; I was talking about the 
EQOS modules' RX path from the PHY more than the PHY itself, although 
given what I said above I believe either interpretation is valid and 
correct.

> Will the driver need to make any clock ops on the "rx" clock ?

Yes. The EQOS driver needs to ensure that the clock is running before 
attempting to receive data from the PHY, otherwise the EQOS's own RX 
logic won't be clocked.

Whether the phandle for this clock points at a SoC-level provider (it 
will in Tegra) or a clock provider in the PHY (it might in other SoCs), 
shouldn't matter as far as the DT binding goes, although it might affect 
device probe ordering in some implementations.

>>>> +  Note: Support for additional IP configurations may require adding the
>>>> +  following clocks to this list in the future: clk_rx_125_i, clk_tx_125_i,
>>>> +  clk_pmarx_0_i, clk_pmarx1_i, clk_rmii_i, clk_revmii_rx_i, clk_revmii_tx_i.
>>>> +
>>>> +  The following compatible values require the following set of clocks:
>>>> +  - "nvidia,tegra186-eqos", "snps,dwc-qos-ethernet-4.10":
>>>> +    - "slave_bus"
>>>> +    - "master_bus"
>>>> +    - "rx"
>>>> +    - "tx"
>>>> +    - "ptp_ref"
>>>> +  - "axis,artpec6-eqos", "snps,dwc-qos-ethernet-4.10":
>>>> +    - "phy_ref_clk"
>>>> +    - "apb_clk"
>>>
>>> It would be good if this was marked deprecated and the full set of
>>> clocks could be described and supported. Not sure if you can figure that
>>> out. Is it really only 2 clocks, or these have multiple connections to
>>> the same source.
>>
>> Lars, can you answer here?
>>
>> I deliberately didn't attempt to change the binding definition for the
>> existing use-case, since I'm not familiar with that SoC, and don't
>> relish changing DTs for a platform I can't test.
>
> For the artpec-6 the clocks are like this:
> apb_clk: It is both the master and slave bus clock.
> phy_ref_clk: It corresponds to tx clock in the proposed new binding.
>
> There is a also a ptp reference clock that will map to the new ptp_ref
> clock binding.
>
> So the full set of clocks in a new artpec-6 binding is:
> slave_bus
> master_bus
> tx
> ptp_ref

Given the discussion above, I think we should represent the rx clock too.
