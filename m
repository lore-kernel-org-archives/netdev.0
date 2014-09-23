From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH v4 3/9] Documentation: bindings: net: add the Marvell
 PXA168 Ethernet controller
Date: Tue, 23 Sep 2014 17:45:52 +0200
Message-ID: <542195B0.6080706@gmail.com>
References: <1411474536-22626-1-git-send-email-antoine.tenart@free-electrons.com> <20140923140113.GC18924@kwain> <20140923142922.GE18924@kwain> <4014272.rJbSfrLcuB@wuerfel>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
	jszhang@marvell.com
To: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4014272.rJbSfrLcuB@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/23/2014 04:37 PM, Arnd Bergmann wrote:
> On Tuesday 23 September 2014 16:29:22 Antoine Tenart wrote:
>>
>> So I had a look on other Ethernet bindings. Would you agree with
>> something like the following?
>>
>>          eth0: ethernet@f7b90000 {
>>                  ...
>>                  #address-cells = <1>;
>>                  #size-cells = <0>;
>>                  phy-handle = <&ethphy0>;
>>
>>                  ethphy0: ethernet-phy@0 {
>>                          reg = <0>;
>>                  };
>>          };
>
> Yes, that looks good.

nit: ethernet-phy@0 should not be part of the ethernet controller
but either part of a separate mdio-ctrl node or a separate node itself.

AFAIKS, Berlin SoCs have internal PHYs, i.e. no MII/MDIO-pins exposed
but only MLT-3 differential pairs. At least BG2CD also can connect its
ethernet IP to a PHY capable of HDMI Ethernet Channel (HEC).

So for BG2CD this has to look something like:

eth0: ethernet@f7b90000 {
	...
	phy-handle = <&hec>;
};

cec: cec@f7f00baa {
	compatible = "marvell,berlin-cec";
	reg = <0xf7f00baa 0x1234>;

	/* CEC unit contains HEC PHY */
	hec: ethernet-phy {
		bla;
	};
}

For reference, this is what we have for MVEBU SoCs with multiple ports
per controller:

eth: ethernet-ctrl@72000 {
	compatible = "marvell,orion-eth";
	#address-cells = <1>;
	#size-cells = <0>;
	reg = <0x72000 0x4000>;
	clocks = <&gate_clk 2>;
	marvell,tx-checksum-limit = <1600>;
	status = "disabled";

	ethernet-port@0 {
		compatible = "marvell,orion-eth-port";
		reg = <0>;
		interrupts = <29>;
		/* overwrite MAC address in bootloader */
		local-mac-address = [00 00 00 00 00 00];
		phy-handle = <&ethphy>;
	};
};

mdio: mdio-bus@72004 {
	compatible = "marvell,orion-mdio";
	#address-cells = <1>;
	#size-cells = <0>;
	reg = <0x72004 0x84>;
	interrupts = <30>;
	clocks = <&gate_clk 2>;
	status = "disabled";
	ethphy: ethernet-phy {
		/* set phy address in board file */
	};
};

Sebastian
