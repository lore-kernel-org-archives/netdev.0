From: Chen-Yu Tsai <wens@csie.org>
Subject: Re: net: stmmac: DT clock parameter and behavior?
Date: Fri, 29 Nov 2013 23:00:14 +0800
Message-ID: <CAGb2v66kEmysHmLuV-mwwkR=VY-=_=ijwVzU7ie5CnCJJM6jXQ@mail.gmail.com>
References: <CAGb2v65G70x-nqg2pJ2dTovgT-b9n+5JCeABzD0ft1JqPm6f4Q@mail.gmail.com>
 <52988BE5.4090806@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org,
	Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f169.google.com ([209.85.220.169]:43904 "EHLO
	mail-vc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756491Ab3K2PAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 10:00:35 -0500
Received: by mail-vc0-f169.google.com with SMTP id hu19so6940647vcb.28
        for <netdev@vger.kernel.org>; Fri, 29 Nov 2013 07:00:34 -0800 (PST)
In-Reply-To: <52988BE5.4090806@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> The stmmac core code references a clock named "stmmaceth".
>> This clock does not seem to be documented in "networking/stmmac.txt"
> The MAC Control Interface, CSR, and Station Management Agent of the MAC
> run on the clock named "stmmaceth".
>
> For example the CSR is tuned according to this main clock (as poorly
> documented in the stmmac.txt ... I'll improve it as well )

I assume the MDIO bus registers and MDC are also derived from this
main clock?

The issue I ran into is that in the clock is not enabled during *_probe,
stmmac_dvr_probe() to be exact. The stmmac driver probes the MAC hardware
version, feature flags, and the MDIO bus for PHY devices. If the clock was
not previously enabled by the boot loader, the driver gets bogus results.

In my opinion, either the clock has to be enabled before or in
stmmac_dvr_probe(), or the clock was intended for something else than
the MAC's main clock.

I was not provided with any documentation for the MAC.
What is the CSR for exactly?

>> The latest patch series for dwmac-sti on netdev suggests that this
>> clock is a 25MHz clock for the phy device. Is this true?
> this is reported in
> Documentation/devicetree/bindings/net/sti-dwmac.txt
>
> The problem is that, on ST platforms, e.g. in rgmii mode, it is
> necessary to dynamically change the phy clk according to the
> speed that is negotiated. (e.g. speed = 1000, frq = 125MHz
> 25 for 100 etc)
>
> This is a quite complex logic that has been added to manage
> the phy clock that can be routed by the SoC or PHY.

Are you refering to the "st,tx-retime-src" property for sti-dwmac?
The Allwinner SoCs have a similar mechanism for TX clock selection
and division.

My original question was, the DTs for STiH415 and ST416 both use
<&CLK_S_GMAC0_PHY> and <&CLK_S_ETH1_PHY> as "stmmaceth" clock.
Both of them are defined as 25 MHz fixed rate clocks.

Without schematics, I can only guess that they might be external
crystal oscillators that run the phy device's internals, but not
the MII/RGMII interface. Hence they are only enabled when the net
device is opened, i.e. when needed.

> AUXDATA is not the preferred solution.
> this how we are managing stmmac from DT

Adding a glue layer device seems like a good way.
Thank you for pointing me in that direction.

>> Also, earlier versions of stmmac seemed to only give a warning if
>> "stmmaceth" clock was not found. But in
>>
>>      6a81c26f  net/stmmac: remove conditional compilation of clk code
>>
>> the behavior changed to failing completely. Was this intended?
> in the beginning, when I pushed the stmmac, we used an old approach
> to manage the tx/rx processes by using an external timer.
> For example for SH4 we used the TMU channel 2.
> The patch you mentioned (IIRC) was for a code that has been removed
> long time ago because the logic behind it became obsolete due to the
> introduction of the RX watchdog inside the SYNP.

The patch looks more like common clock framework code cleanup to me.

>> Last, given the supported device is actually Synopsys DesignWare
>> Ethernet MAC, is there any chance the driver could be renamed to dwmac?
> we discussed about that long time ago when the driver was moved to
> ethernet/stmicro directory. We can reopen the discussion.
> I accept it because, indeed, the stmmac is really generic and for
> dwmac synp chips.

I see. We could discuss this after my code is is submitted and accepted.


Cheers
wens
