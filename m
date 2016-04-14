From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller
 driver
Date: Thu, 14 Apr 2016 11:32:40 -0500
Message-ID: <20160414163240.GB15303@rob-hp-laptop>
References: <1460570393-19838-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	sdharia@codeaurora.org,
	Shanker Donthineni <shankerd@codeaurora.org>,
	Greg Kroah-Hartman <greg@kroah.com>, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, andrew@lunn.ch,
	bjorn.andersson@linaro.org, Mark Langsdorf <mlangsdo@redhat.com>,
	Jon Masters <jcm@redhat.com>,
	Andy Gross <agross@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>
To: Timur Tabi <timur@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1460570393-19838-1-git-send-email-timur@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 13, 2016 at 12:59:52PM -0500, Timur Tabi wrote:
> From: Gilad Avidov <gavidov@codeaurora.org>
> 
> Add supports for ethernet controller HW on Qualcomm Technologies, Inc. SoC.
> This driver supports the following features:
> 1) Checksum offload.
> 2) Runtime power management support.
> 3) Interrupt coalescing support.
> 4) SGMII phy.
> 5) SGMII direct connection without external phy.
> 
> Based on a driver by Niranjana Vishwanathapura
> <nvishwan@codeaurora.org>.
> 
> Signed-off-by: Gilad Avidov <gavidov@codeaurora.org>
> Signed-off-by: Timur Tabi <timur@codeaurora.org>
> ---
> 
> v4:
>  - add missing ipv6 header file
>  - correct compatible string
>  - fix spacing in emac_reg_write arrays
>  - drop unnecessary cell-index property
>  - remove unsupported DT properties from docs
>  - remove GPIO initialization and update docs
> 
> v3:
>  - remove most of the memory barriers by using the non xxx_relaxed() api.
>  - remove RSS and WOL support.
>  - correct comments from physical address to dma address.
>  - rearrange structs to make them packed.
>  - replace polling loops with readl_poll_timeout().
>  - remove unnecessary wrapper functions from phy layer.
>  - add blank line before return statements.
>  - set to null clocks after clk_put().
>  - use module_platform_driver() and dma_set_mask_and_coherent()
>  - replace long hex bitmasks with BIT() macro.
> 
> v2:
>  - replace hw bit fields to macros with bitwise operations.
>  - change all iterators to unsized types (int)
>  - some minor code flow improvements.
>  - change return type to void for functions which return value is never
>    used.
>  - replace instance of xxxxl_relaxed() io followed by mb() with a
>    readl()/writel().
> 
> ---
>  .../devicetree/bindings/net/qcom-emac.txt          |   65 +
>  drivers/net/ethernet/qualcomm/Kconfig              |   11 +
>  drivers/net/ethernet/qualcomm/Makefile             |    2 +
>  drivers/net/ethernet/qualcomm/emac/Makefile        |    7 +
>  drivers/net/ethernet/qualcomm/emac/emac-mac.c      | 1782 ++++++++++++++++++++
>  drivers/net/ethernet/qualcomm/emac/emac-mac.h      |  286 ++++
>  drivers/net/ethernet/qualcomm/emac/emac-phy.c      |  484 ++++++
>  drivers/net/ethernet/qualcomm/emac/emac-phy.h      |   68 +
>  drivers/net/ethernet/qualcomm/emac/emac-sgmii.c    |  683 ++++++++
>  drivers/net/ethernet/qualcomm/emac/emac-sgmii.h    |   30 +
>  drivers/net/ethernet/qualcomm/emac/emac.c          | 1206 +++++++++++++
>  drivers/net/ethernet/qualcomm/emac/emac.h          |  382 +++++
>  12 files changed, 5006 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/qcom-emac.txt
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/Makefile
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-mac.c
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-mac.h
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-phy.c
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-phy.h
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-sgmii.h
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac.c
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac.h
> 
> diff --git a/Documentation/devicetree/bindings/net/qcom-emac.txt b/Documentation/devicetree/bindings/net/qcom-emac.txt
> new file mode 100644
> index 0000000..df5e7c0
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/qcom-emac.txt
> @@ -0,0 +1,65 @@
> +Qualcomm EMAC Gigabit Ethernet Controller
> +
> +Required properties:
> +- compatible : Should be "qcom,emac".

Come on... Can you guess what I'm going to say here.

> +- reg : Offset and length of the register regions for the device
> +- reg-names : Register region names referenced in 'reg' above.
> +	Required register resource entries are:
> +	"base"   : EMAC controller base register block.
> +	"csr"    : EMAC wrapper register block.
> +	Optional register resource entries are:
> +	"ptp"    : EMAC PTP (1588) register block.
> +		   Required if 'qcom,emac-tstamp-en' is present.
> +	"sgmii"  : EMAC SGMII PHY register block.
> +- interrupts : Interrupt numbers used by this controller
> +- interrupt-names : Interrupt resource names referenced in 'interrupts' above.
> +	Required interrupt resource entries are:
> +	"emac_core0"   : EMAC core0 interrupt.
> +	"sgmii_irq"   : EMAC SGMII interrupt.
> +- phy-addr            : Specifies phy address on MDIO bus.
> +			Required if the optional property "qcom,no-external-phy"
> +			is not specified.

As I mentioned in the last version, you should still describe this with 
a standard MDIO bus binding even if you can't use the generic code.

> +
> +Optional properties:
> +- qcom,emac-tstamp-en       : Enables the PTP (1588) timestamping feature.
> +			      Include this only if PTP (1588) timestamping
> +			      feature is needed. If included, "ptp" register
> +			      base should be specified.
> +- mac-address               : The 6-byte MAC address. If present, it is the
> +			      default MAC address.
> +- qcom,no-external-phy      : Indicates there is no external PHY connected to
> +			      EMAC. Include this only if the EMAC is directly
> +			      connected to the peer end without EPHY.
> +Example:
> +	emac0: qcom,emac@feb20000 {

ethernet@

> +		compatible = "qcom,fsm9900-emac";

Ah, I see you fixed it here...

> +		reg-names = "base", "csr", "ptp", "sgmii";
> +		reg =   <0xfeb20000 0x10000>,
> +			<0xfeb36000 0x1000>,
> +			<0xfeb3c000 0x4000>,
> +			<0xfeb38000 0x400>;
> +		#address-cells = <0>;
> +		interrupt-parent = <&emac0>;
> +		#interrupt-cells = <1>;
> +		interrupts = <0 1>;
> +		interrupt-map-mask = <0xffffffff>;
> +		interrupt-map = <0 &intc 0 76 0
> +				 1 &intc 0 80 0>;
> +		interrupt-names = "emac_core0", "sgmii_irq";
> +		qcom,emac-tstamp-en;
> +		phy-addr = <0>;
> +
> +		pinctrl-names = "default";
> +		pinctrl-0 = <&mdio_pins_a>;
> +	};
> +
> +	tlmm: pinctrl@fd510000 {
> +		compatible = "qcom,fsm9900-pinctrl";
> +
> +		mdio_pins_a: mdio {
> +			state {
> +				pins = "gpio123", "gpio124";
> +				function = "mdio";
> +			};
> +		};
> +	};
