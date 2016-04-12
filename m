From: Chen-Yu Tsai <wens@csie.org>
Subject: Re: [PATCH RFC 1/5] net: phy: sun8i-h3-ephy: Add bindings for
 Allwinner H3 Ethernet PHY
Date: Tue, 12 Apr 2016 09:38:46 +0800
Message-ID: <CAGb2v662vHfYox2Ff9Mm=sXq4UHg92SQe2ihnKY9Aa4X9yss4Q@mail.gmail.com>
References: <1459786954-12649-1-git-send-email-wens@csie.org>
 <1459786954-12649-2-git-send-email-wens@csie.org> <570BF9B0.2090602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chen-Yu Tsai <wens@csie.org>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	devicetree <devicetree@vger.kernel.org>,
	LABBE Corentin <clabbe.montjoie@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <570BF9B0.2090602@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 12, 2016 at 3:23 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 04/04/16 09:22, Chen-Yu Tsai wrote:
>> The Allwinner H3 SoC incorporates an Ethernet PHY. This is enabled and
>> configured through a memory mapped hardware register.
>>
>> This same register also configures the MAC interface mode and TX clock
>> source. Also covered by the register, but not supported in these bindings,
>> are TX/RX clock delay chains and inverters, and an RMII module.
>>
>> Signed-off-by: Chen-Yu Tsai <wens@csie.org>
>> ---
>>  .../bindings/net/allwinner,sun8i-h3-ephy.txt       | 44 ++++++++++++++++++++++
>>  1 file changed, 44 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/net/allwinner,sun8i-h3-ephy.txt
>>
>> diff --git a/Documentation/devicetree/bindings/net/allwinner,sun8i-h3-ephy.txt b/Documentation/devicetree/bindings/net/allwinner,sun8i-h3-ephy.txt
>> new file mode 100644
>> index 000000000000..146f227e6d88
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/allwinner,sun8i-h3-ephy.txt
>> @@ -0,0 +1,44 @@
>> +* Allwinner H3 E(thernet) PHY
>> +
>> +The Allwinner H3 integrates an MII ethernet PHY. As with external PHYs,
>> +before it can be configured over the MDIO bus and used, certain hardware
>> +features must be configured, such as the PHY address and LED polarity.
>
> Is the internal PHY address really configurable? Not that there is
> anything wrong with it, this is good.

It is. Things that are configured or provided to a discrete PHY are routed
to registers in the SoC, things such as PHY address, clocks, resets.

>> +The PHY must also be powered on and brought out of reset.
>> +
>> +This is accomplished with regulators and pull-up/downs for external PHYs.
>> +For this internal PHY, a hardware register is programmed.
>> +
>> +The same hardware register also contains clock and interface controls
>> +for the MAC. This is also present in earlier SoCs, and is covered by
>> +"allwinner,sun7i-a20-gmac-clk". The controls in the H3 are slightly
>> +different due to the inclusion of what appears to be an RMII-MII
>> +bridge.
>> +
>> +Required properties:
>> +- compatible: should be "allwinner,sun8i-h3-ephy"
>> +- reg: address and length of the register set for the device
>> +- clocks: A phandle to the reference clock for this device
>> +- resets: A phandle to the reset control for this device
>> +
>> +Ethernet PHY related properties:
>> +- allwinner,ephy-addr: the MDIO bus address the PHY should respond to.
>> +                    If this is not set, the external PHY is used, and
>> +                    everything else in this section is ignored.
>
> So we are going to put the same value here, and in the actual Ethernet
> PHY device tree node that should be hanging off the EMAC/MDIO bus
> controller, this is confusing and error prone.

Yes, that would be an issue when writing the DTS.
>
>> +- allwinner,leds-active-low: LEDs are active low. Without this, LEDs are
>> +                          active high.
>> +
>> +Ethernet MAC clock related properties:
>> +- #clock-cells: should be 0
>> +- clock-output-names: "mac_tx"
>> +
>> +Example:
>> +
>> +ethernet-phy@01c00030 {
>> +     compatible = "allwinner,sun8i-h3-ephy";
>> +     reg = <0x01c00030 0x4>;
>
> Looking at this register space this looks more like an internal PHY SHIM
> that is needed to be configured before the internal PHY can be access,
> not a proper Ethernet PHY per-se, see replies in aptch 2.
>
> Should not this block be a second cell associated with the Ethernet MAC
> block? One or the other are not going to be very useful without
> knowledge of each other.

True. However the lower half of the same register also controls the
MAC interface mode and TX clock source and delays. This we had a clock
driver that was used in conjuction with stmmac on earlier SoCs. I was
hoping to keep that model with the newer EMAC. At the time it was
argued that what seemed like a clock should be handled by a clock
driver, instead of just a "syscon". If this is reaching too far to
handle this new use case, I will happily just provide patches to merge
this into the MAC.

I would like to know how to deal with things like a PHY requiring
some sort of shim driver, be it an internal one, or an external mfd
chip that happens to have an Ethernet PHY included? How do we tie
this into the PHY node under the MDIO bus?


Regards
ChenYu
