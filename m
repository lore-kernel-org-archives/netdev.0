From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH V5 7/7] arm/dts: am33xx: Add CPSW and MDIO module nodes for AM33XX
Date: Mon, 19 Nov 2012 21:24:53 +0100
Message-ID: <877gphl4ru.fsf@dell.be.48ers.dk>
References: <1352920080-6179-1-git-send-email-mugunthanvnm@ti.com>
	<1352920080-6179-8-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<devicetree-discuss@lists.ozlabs.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <b-cousson@ti.com>, <paul@pwsan.com>,
	Vaibhav Hiremath <hvaibhav@ti.com>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:64793 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754782Ab2KSUY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 15:24:58 -0500
In-Reply-To: <1352920080-6179-8-git-send-email-mugunthanvnm@ti.com> (Mugunthan
	V. N.'s message of "Thu, 15 Nov 2012 00:38:00 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "M" == Mugunthan V N <mugunthanvnm@ti.com> writes:

 M> Add CPSW and MDIO related device tree data for AM33XX.
 M> Also enable them into board/evm dts files by providing
 M> respective phy-id.

 M> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
 M> Signed-off-by: Vaibhav Hiremath <hvaibhav@ti.com>
 M> Cc: Benoit Cousson <b-cousson@ti.com>
 M> Acked-by: Peter Korsgaard <jacmet@sunsite.dk>
 M> Acked-by: Richard Cochran <richardcochran@gmail.com>

 M> +++ b/arch/arm/boot/dts/am335x-bone.dts
 M> @@ -78,3 +78,11 @@
 M>  		};
 M>  	};
 M>  };
 M> +
 M> +&cpsw_emac0 {
 M> +	phy_id = <&davinci_mdio>, <0>;
 M> +};
 M> +
 M> +&cpsw_emac1 {
 M> +	phy_id = <&davinci_mdio>, <1>;
 M> +};

I already acked this and the problem isn't caused by this patch itself,
but it isn't really nice that you have to add a dummy emac1 even though
only the first port is used on the bone.

It would imho be nicer to get rid of the 'slaves' property in cpsw (just
let the driver count available slave children), mark both slaves in
am33xx.dtsi with status = 'disabled' and only loop over the available
slaves in cpsw_probe_dt(), similar to E.G. how the uarts/i2c are handled.

Then am335x-bone.dts would just need to add:

&cpsw_emac0 {
    status = 'ok';
    phy_id = <&davinci_mdio>, <0>;
};

I'll send a patch shortly to implement this.


 M> diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
 M> index bb31bff..a4615b4 100644
 M> --- a/arch/arm/boot/dts/am33xx.dtsi
 M> +++ b/arch/arm/boot/dts/am33xx.dtsi
 M> @@ -210,5 +210,53 @@
 M>  			interrupt-parent = <&intc>;
 M>  			interrupts = <91>;
 M>  		};
 M> +
 M> +		mac: ethernet@4a100000 {
 M> +			compatible = "ti,cpsw";
 M> +			ti,hwmods = "cpgmac0";
 M> +			cpdma_channels = <8>;
 M> +			ale_entries = <1024>;
 M> +			bd_ram_size = <0x2000>;
 M> +			no_bd_ram = <0>;
 M> +			rx_descs = <64>;
 M> +			mac_control = <0x20>;
 M> +			slaves = <2>;
 M> +			cpts_active_slave = <0>;
 M> +			cpts_clock_mult = <0x80000000>;
 M> +			cpts_clock_shift = <29>;
 M> +			reg = <0x4a100000 0x800
 M> +			       0x4a101200 0x100>;
 M> +			#address-cells = <1>;
 M> +			#size-cells = <1>;
 M> +			interrupt-parent = <&intc>;
 M> +			/*
 M> +			 * c0_rx_thresh_pend
 M> +			 * c0_rx_pend
 M> +			 * c0_tx_pend
 M> +			 * c0_misc_pend
 M> +			 */
 M> +			interrupts = <40 41 42 43>;
 M> +			ranges;
 M> +
 M> +			davinci_mdio: mdio@4a101000 {
 M> +				compatible = "ti,davinci_mdio";
 M> +				#address-cells = <1>;
 M> +				#size-cells = <0>;
 M> +				ti,hwmods = "davinci_mdio";
 M> +				bus_freq = <1000000>;
 M> +				reg = <0x4a101000 0x100>;
 M> +			};
 M> +
 M> +			cpsw_emac0: slave@4a100200 {
 M> +				/* Filled in by U-Boot */
 M> +				mac-address = [ 00 00 00 00 00 00 ];
 M> +			};
 M> +
 M> +			cpsw_emac1: slave@4a100300 {
 M> +				/* Filled in by U-Boot */
 M> +				mac-address = [ 00 00 00 00 00 00 ];
 M> +			};
 M> +
 M> +		};

-- 
Bye, Peter Korsgaard
