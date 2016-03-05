From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v2] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Fri, 4 Mar 2016 22:30:10 -0600
Message-ID: <20160305043010.GC13525@rob-hp-laptop>
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1457019515-21158-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mkl@pengutronix.de, wg@grandegger.com, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, corbet@lwn.net,
	linux-renesas-soc@vger.kernel.org, devicetree@vger.kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, geert+renesas@glider.be,
	chris.paterson2@renesas.com
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1457019515-21158-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 03, 2016 at 03:38:35PM +0000, Ramesh Shanmugasundaram wrote:
> This patch adds support for the CAN FD controller found in Renesas R-Car
> SoCs. The controller operates in CAN FD mode by default.
> 
> CAN FD mode supports both Classical CAN & CAN FD frame formats. The
> controller supports ISO 11898-1:2015 CAN FD format only.
> 
> This controller supports two channels and the driver can enable either
> or both of the channels.
> 
> Driver uses Rx FIFOs (one per channel) for reception & Common FIFOs (one
> per channel) for transmission. Rx filter rules are configured to the
> minimum (one per channel) and it accepts Standard, Extended, Data &
> Remote Frame combinations.
> 
> Note: There are few documentation errors in R-Car Gen3 Hardware User
> Manual v0.5E with respect to CAN FD controller. They are listed below:
> 
> 1. CAN FD interrupt numbers 29 & 30 are listed as per channel
> interrupts. However, they are common to both channels (i.e.) they are
> global and channel interrupts respectively.
> 
> 2. CANFD clock is derived from PLL1. This is not documented.
> 
> 3. CANFD clock is further divided by (1/2) within the CAN FD controller.
> This is not documented.
> 
> 4. The minimum value of NTSEG1 in RSCFDnCFDCmNCFG register is 2 Tq. It
> is mentioned 4 Tq in the manual.
> 
> 5. The maximum number of message RAM area the controller can use is 3584
> bytes. It is specified 10752 bytes in the manual.
> 
> Signed-off-by: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
> ---
> Changes since v1:
> 	* Removed testmodes & debugfs code (suggested by Oliver H)
> 	* Fixed tx path race issue by introducing lock (suggested by Marc K)
> 	* Removed __maybe_unused attribute of rcar_canfd_of_table
> 
> Thanks,
> Ramesh
> ---
>  .../devicetree/bindings/net/can/rcar_canfd.txt     |   86 ++
>  drivers/net/can/Kconfig                            |   10 +
>  drivers/net/can/Makefile                           |    1 +
>  drivers/net/can/rcar_canfd.c                       | 1624 ++++++++++++++++++++
>  4 files changed, 1721 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/can/rcar_canfd.txt
>  create mode 100644 drivers/net/can/rcar_canfd.c
> 
> diff --git a/Documentation/devicetree/bindings/net/can/rcar_canfd.txt b/Documentation/devicetree/bindings/net/can/rcar_canfd.txt
> new file mode 100644
> index 0000000..4299bd8
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/can/rcar_canfd.txt
> @@ -0,0 +1,86 @@
> +Renesas R-Car CAN FD controller Device Tree Bindings
> +----------------------------------------------------
> +
> +Required properties:
> +- compatible: Must contain one or more of the following:
> +  - "renesas,rcar-gen3-canfd" for R-Car Gen3 compatible controller.
> +  - "renesas,r8a7795-canfd" for R8A7795 (R-Car H3) compatible controller.
> +
> +  When compatible with the generic version, nodes must list the
> +  SoC-specific version corresponding to the platform first, followed by the
> +  family-specific and/or generic versions.
> +
> +- reg: physical base address and size of the R-Car CAN FD register map.
> +- interrupts: interrupt specifier for the Global & Channel interrupts
> +- clocks: phandles and clock specifiers for 3 clock inputs.
> +- clock-names: 3 clock input name strings: "fck", "canfd", "can_clk".
> +- pinctrl-0: pin control group to be used for this controller.
> +- pinctrl-names: must be "default".
> +
> +Required properties for "renesas,r8a7795-canfd" compatible:
> +In R8A7795 SoC, canfd clock is a div6 clock and can be used by both CAN
> +and CAN FD controller at the same time. It needs to be scaled to maximum
> +frequency if any of these controllers use it. This is done using the
> +below properties.
> +
> +- assigned-clocks: phandle of canfd clock.
> +- assigned-clock-rates: maximum frequency of this clock.
> +
> +Each channel is represented as a child node. They can be enabled/disabled
> +using "status" property.

How many channels? Required or optional?

> +
> +Example
> +-------
> +
> +SoC common .dtsi file:
> +
> +		canfd: canfd@e66c0000 {

can@e66c0000

> +			compatible = "renesas,r8a7795-canfd",
> +				     "renesas,rcar-gen3-canfd";
> +			reg = <0 0xe66c0000 0 0x8000>;
> +			interrupts = <GIC_SPI 29 IRQ_TYPE_LEVEL_HIGH>,
> +				   <GIC_SPI 30 IRQ_TYPE_LEVEL_HIGH>;
> +			clocks = <&cpg CPG_MOD 914>,
> +			       <&cpg CPG_CORE R8A7795_CLK_CANFD>,
> +			       <&can_clk>;
> +			clock-names = "fck", "canfd", "can_clk";
> +			assigned-clocks = <&cpg CPG_CORE R8A7795_CLK_CANFD>;
> +			assigned-clock-rates = <40000000>;
> +			power-domains = <&cpg>;
> +			status = "disabled";
> +
> +			channel0 {
> +				status = "disabled";
> +			};
> +
> +			channel1 {
> +				status = "disabled";
> +			};
> +		};
> +
> +Board specific .dts file:
> +
> +E.g. below enables Channel 1 alone in the board.
> +
> +&canfd {
> +        pinctrl-0 = <&canfd1_pins>;
> +        pinctrl-names = "default";
> +        status = "okay";
> +
> +	channel1 {
> +		status = "okay";
> +	};
> +};
> +
> +E.g. below enables Channel 0 alone in the board using External clock
> +as fCAN clock.
> +
> +&canfd {
> +        pinctrl-0 = <&canfd0_pins &can_clk_pins>;
> +        pinctrl-names = "default";
> +        status = "okay";
> +
> +	channel0 {
> +		status = "okay";
> +	};
> +};
