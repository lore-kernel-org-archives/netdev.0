From: Mason <slash.tmp@free.fr>
Subject: Re: Quirks of the Atheros 8035 PHY
Date: Sat, 15 Jul 2017 00:24:53 +0200
Message-ID: <da41567d-a762-2953-0d12-3a99d0f79f4c@free.fr>
References: <06a3ad40-ad88-c456-b643-901ea964b5aa@free.fr>
 <a3d66c99-a4c6-3ce2-83cc-b0398b409107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        "David S. Miller" <davem@davemloft.net>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:3485 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751049AbdGNWZ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Jul 2017 18:25:28 -0400
In-Reply-To: <a3d66c99-a4c6-3ce2-83cc-b0398b409107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/07/2017 23:28, Florian Fainelli wrote:

> On 07/14/2017 02:08 PM, Mason wrote:
>
>> I've discussed this subject in the past, but we never reached
>> a conclusion, AFAIR.
>>
>> The Atheros 8035 GigE PHY has IMO 2 quirks wrt to clock delays.
>>
>> https://www.redeszone.net/app/uploads/2014/04/AR8035.pdf
>>
>>
>> 1) RX clock delay
>>
>> Commit 2e5f9f281ee8369f56d403b4a52942f19b6978f8
>>
>> In fact, RX clock delay is *ENABLED* by default at
>> reset. So if a board actually required it *disabled*
>> then we actually need to set the bit to 0.
>>
>> Reference:
>> 4.2.25 rgmii rx clock delay control
>>
>>
>> 2) TX clock delay
>>
>> Commit 1ca6d1b1aef4628ff0fe458135ddb008d134ad8f
>>
>> TX clock delay is DISABLED by default, so no surprises
>> there... except that it is only DISABLED after *HW reset*.
>>
>> After a SW reset, such as that performed in Linux IIUC,
>> the PHY retains the value previously set.
>>
>> So if a bootloader such a Uboot enabled TX delay, then
>> Linux would "inherit" the setting, even if it performs
>> a reset. If the PHY setting calls for no TX clock delay,
>> the Linux driver would have to actively disable it.
>>
>> Reference:
>> 4.2.26 rgmii tx clock delay control
>>
>>
>> I can (of course) send a patch fixing both issues, but
>> what was said last time was that "it's too late to
>> fix it now, since the fix risks breaking working
>> setups". Is that an accurate paraphrase?
> 
> More or less, this particular problematic PHY has come up with some many
> different platforms, and people and typically no one being able to have
> insights on its internal design that it is really hard to comment on
> what would break, it's already apparently pretty broken.

When you say broken, do you mean the situation,
or the HW? I don't think the HW is broken.

The API is confusing, and violates the principle of
least astonishment, which led several SW devs to make
implementation errors, but the documentation is
pretty clear and well-written, as far as docs go.

The fix is straight-forward:

if (PHY_INTERFACE_MODE_RGMII)
	disable_rx_delay;
	disable_tx_delay;

if (PHY_INTERFACE_MODE_RGMII_RXID)
	enable_rx_delay;
	disable_tx_delay;

if (PHY_INTERFACE_MODE_RGMII_TXID)
	disable_rx_delay;
	enable_tx_delay;

if (PHY_INTERFACE_MODE_RGMII_ID)
	enable_rx_delay;
	enable_tx_delay;

Then the setting will be as requested in the DT.

>> 3) There's also a RGMII GTX_CLK documented as
>> "RGMII transmit clock, 125 MHz digital. Adding a 22 ohm
>> damping  resistor is recommended for EMI design near MAC side"
>> => Is that TX_CLK?
>> There's a 2-bit related field called Gtx_dly_val
>> which allows tweaking the delay
>>
>> Select the delay of gtx_clk.
>> 00: 0.25ns
>> 01: 1.3ns
>> 10: 2.4ns
>> 11: 3.4ns
>> (DEFAULT 10b = 2.4 ns, BUT Retain val on SW reset,
>> so inherit bootloader value)
>> I'm not sure the current DT allows such fine-grained
>> tweaking? Should we enhance it?
> 
> What is "the current DT" in that context? There is no binding for
> at8033x defined and there is not one either for nb8800.

I meant
Documentation/devicetree/bindings/net/ethernet.txt
Documentation/devicetree/bindings/net/phy.txt

There is no prop to define the required delay,
in case the specific PHY supports multiple
delays, as the AR8035 seems to do.

This is the current DT
http://elixir.free-electrons.com/linux/latest/source/arch/arm/boot/dts/tango4-vantage-1172.dts

&eth0 {
	phy-connection-type = "rgmii";
	phy-handle = <&eth0_phy>;
	#address-cells = <1>;
	#size-cells = <0>;

	/* Atheros AR8035 */
	eth0_phy: ethernet-phy@4 {
		compatible = "ethernet-phy-id004d.d072",
			     "ethernet-phy-ieee802.3-c22";
		interrupts = <37 IRQ_TYPE_EDGE_RISING>;
		reg = <4>;
	};
};

phy-connection-type is wrong, since I need both delays.
So I will change to rgmii-id, and fix the MAC driver to
honor the doc blurb:

  * "rgmii" (RX and TX delays are added by the MAC when required)
  * "rgmii-id" (RGMII with internal RX and TX delays provided by the PHY, the
     MAC should not add the RX or TX delays in this case)
  * "rgmii-rxid" (RGMII with internal RX delay provided by the PHY, the MAC
     should not add an RX delay in this case)
  * "rgmii-txid" (RGMII with internal TX delay provided by the PHY, the MAC
     should not add an TX delay in this case)

> Some bindings do define RGMII RX/TX delay, but they can't agree on that
> either (net/cavium-pip.txt, net/apm-xgene-enet.txt and
> net/dwmac-sun8i.txt). The latest in date: net/dwmac-sun8i.txt is
> probably the best example of what should be defined and generalized.

OK, I'll take a close look at it.

>> 4) There's the whole mess of having clock delays
>> supported both by the PHY *AND* the MAC. If both
>> add a delay, things won't work as expected.
>> What's the recommended approach there?
> 
> Submit patches that fix problems for your particular use case that we
> can review and evaluate, once we have that, it's a lot easier to assess
> the impact it could have on other platforms.

OK, I will send a patch to make clear what I mean.

Regards.
