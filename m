From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: net: stmmac: DT clock parameter and behavior?
Date: Fri, 29 Nov 2013 13:43:17 +0100
Message-ID: <52988BE5.4090806@st.com>
References: <CAGb2v65G70x-nqg2pJ2dTovgT-b9n+5JCeABzD0ft1JqPm6f4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
To: Chen-Yu Tsai <wens@csie.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:49559 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752819Ab3K2MnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 07:43:25 -0500
In-Reply-To: <CAGb2v65G70x-nqg2pJ2dTovgT-b9n+5JCeABzD0ft1JqPm6f4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On 11/19/2013 3:17 PM, Chen-Yu Tsai wrote:
> I am currently porting the Linux stmmac driver to an AllWinner SoC
> board. The AllWinner A20 SoC has a GMAC, and the drivers they provided
> seems to be an early version of stmmac, with the names replaced.
> I assume the IP in the SoC is an early version of dwmac. So far I have
> managed to get a running system. I would like to clarify a few details
> to clean up the code.
>
> The stmmac core code references a clock named "stmmaceth".
> This clock does not seem to be documented in "networking/stmmac.txt"

yes you are right and I will improve the doc  for this clk soon.

Let me provide you some details. I hope useful to go head on your
porting.

The MAC Control Interface, CSR, and Station Management Agent of the MAC
run on the clock named "stmmaceth".

For example the CSR is tuned according to this main clock (as poorly
documented in the stmmac.txt ... I'll improve it as well )

> nor in "devicetree/bindings/net/stmmac.txt".
> STMicroelectronics SPEAr board DTs do not mention this clock.
> But I do see Altera SoCFPGA and Samsung Exynos DTs defining it.
>
> The latest patch series for dwmac-sti on netdev suggests that this
> clock is a 25MHz clock for the phy device. Is this true?


this is reported in

Documentation/devicetree/bindings/net/sti-dwmac.txt

The problem is that, on ST platforms, e.g. in rgmii mode, it is
necessary to dynamically change the phy clk according to the
speed that is negotiated. (e.g. speed = 1000, frq = 125MHz
25 for 100 etc)

This is a quite complex logic that has been added to manage
the phy clock that can be routed by the SoC or PHY.

There is no relationship with the stmmaceth clk.

>
> Then the driver does not consider that the dwmac might have a gated
> clock that needs to be enabled as well. I ran into problems when
> the dwmac was not initialized by the bootloader. I assume this can
> be dealt with using AUXDATA and .init/.exit callbacks?

AUXDATA is not the preferred solution.


this how we are managing stmmac from DT

ethernet1: ethernet1 {
	#address-cells = <1>;
	#size-cells = <1>;
	status 		= "disabled";
	compatible		= "st,stih416-dwmac";
	reg			= <0x7f0 0x4>;
	st,syscon		= <&syscfg_sbc>;
	resets			= <&softreset STIH416_ETH1_SOFTRESET>;
	ranges;

	dwmac@fef08000 {
		device_type = "network";
		compatible	= "snps,dwmac", "snps,dwmac-3.710";
		status 		= "disabled";
		reg		= <0xfef08000 0x8000>;
		interrupts = <0 136 0>, <0 137 0>, <0 138 0>;
		interrupt-names = "macirq", "eth_wake_irq", "eth_lpi";

		snps,pbl	= <32>;
		snps,mixed-burst;

		pinctrl-names 	= "default";
		pinctrl-0	= <&pinctrl_mii1>;
		clock-names	= "stmmaceth";
		clocks		= <&CLK_S_ETH1_PHY>;
	};
};

> Also, earlier versions of stmmac seemed to only give a warning if
> "stmmaceth" clock was not found. But in
>
>      6a81c26f  net/stmmac: remove conditional compilation of clk code
>
> the behavior changed to failing completely. Was this intended?

in the beginning, when I pushed the stmmac, we used an old approach
to manage the tx/rx processes by using an external timer.
For example for SH4 we used the TMU channel 2.
The patch you mentioned (IIRC) was for a code that has been removed
long time ago because the logic behind it became obsolete due to the
introduction of the RX watchdog inside the SYNP.

> Last, given the supported device is actually Synopsys DesignWare
> Ethernet MAC, is there any chance the driver could be renamed to dwmac?

we discussed about that long time ago when the driver was moved to
ethernet/stmicro directory. We can reopen the discussion.
I accept it because, indeed, the stmmac is really generic and for
dwmac synp chips.

BR
peppe
