From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [v8] net: emac: emac gigabit ethernet controller driver
Date: Thu, 11 Aug 2016 15:45:11 -0700
Message-ID: <db618958-a940-9ea2-ff52-e12c81894ad6@gmail.com>
References: <1470951245-13665-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	sdharia@codeaurora.org, shankerd@codeaurora.org,
	vikrams@codeaurora.org, cov@codeaurora.org, gavidov@codeaurora.org,
	robh+dt@kernel.org, andrew@lunn.ch, bjorn.andersson@linaro.org,
	mlangsdo@redhat.com, jcm@redhat.com, agross@codeaurora.org,
	davem@davemloft.net, LinoSanfilippo@gmx.de
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <1470951245-13665-1-git-send-email-timur@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/11/2016 02:34 PM, Timur Tabi wrote:
> Add supports for ethernet controller HW on Qualcomm Technologies, Inc. SoC.
> This driver supports the following features:
> 1) Checksum offload.
> 2) Interrupt coalescing support.
> 3) SGMII phy.
> 4) phylib interface for external phy

OK, so this is looking good now, just a few nits, feel free to submit as
clean up patches, would this one be accepted.

[snip]

> +Example:
> +soc {
> +	#address-cells = <1>;
> +	#size-cells = <1>;
> +	dma-ranges = <0 0 0xffffffff>;
> +
> +	emac0: ethernet@feb20000 {
> +		compatible = "qcom,fsm9900-emac";
> +		#address-cells = <1>;
> +		#size-cells = <1>;
> +		reg-names = "base", "csr", "ptp", "sgmii";
> +		reg =   <0xfeb20000 0x10000>,
> +			<0xfeb36000 0x1000>,
> +			<0xfeb3c000 0x4000>,
> +			<0xfeb38000 0x400>;
> +		interrupt-parent = <&emac0>;
> +		#interrupt-cells = <1>;
> +		interrupts = <76 80>;
> +		interrupt-names = "emac_core0", "sgmii_irq";
> +		phy0: ethernet-phy@0 {
> +			compatible = "qcom,fsm9900-emac-phy";
> +			reg = <0>;
> +		}

If this is an external PHY, the expectation is that it will be hanging
off a MDIO bus controller, either the MDIO bus internal to the MAC, or
an external MDIO bus (separate register range).

If such a PHY node is provided, the expectation is that your Ethernet
MAC will have a phy-handle property and a phy-mode property to specify
how to connect to this external PHY, so in your specific case, better
remove the PHY from your example, or detail further how it should be done.

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
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 952fd2a..38dabdf 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -9404,6 +9404,12 @@ T:	git git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/ath.git
>  S:	Supported
>  F:	drivers/net/wireless/ath/ath10k/
>  
> +QUALCOMM EMAC GIGABIT ETHERNET DRIVER
> +M:	Timur Tabi <timur@codeaurora.org>
> +L:	netdev@vger.kernel.org
> +S:	Supported
> +F:	drivers/net/ethernet/qualcomm/emac/
> +
>  QUALCOMM HEXAGON ARCHITECTURE
>  M:	Richard Kuo <rkuo@codeaurora.org>
>  L:	linux-hexagon@vger.kernel.org
> diff --git a/drivers/net/ethernet/qualcomm/Kconfig b/drivers/net/ethernet/qualcomm/Kconfig
> index a76e380..85b599f 100644
> --- a/drivers/net/ethernet/qualcomm/Kconfig
> +++ b/drivers/net/ethernet/qualcomm/Kconfig
> @@ -24,4 +24,15 @@ config QCA7000
>  	  To compile this driver as a module, choose M here. The module
>  	  will be called qcaspi.
>  
> +config QCOM_EMAC
> +	tristate "Qualcomm Technologies, Inc. EMAC Gigabit Ethernet support"
> +	select CRC32

select PHYLIB?

> +	---help---
> +	  This driver supports the Qualcomm Technologies, Inc. Gigabit
> +	  Ethernet Media Access Controller (EMAC). The controller
> +	  supports IEEE 802.3-2002, half-duplex mode at 10/100 Mb/s,
> +	  full-duplex mode at 10/100/1000Mb/s, Wake On LAN (WOL) for
> +	  low power, Receive-Side Scaling (RSS), and IEEE 1588-2008
> +	  Precision Clock Synchronization Protocol.
> +
>  endif # NET_VENDOR_QUALCOMM
> diff --git a/drivers/net/ethernet/qualcomm/Makefile b/drivers/net/ethernet/qualcomm/Makefile
> index 9da2d75..1b3a0ce 100644
> --- a/drivers/net/ethernet/qualcomm/Makefile
> +++ b/drivers/net/ethernet/qualcomm/Makefile
> @@ -4,3 +4,5 @@
>  
>  obj-$(CONFIG_QCA7000) += qcaspi.o
>  qcaspi-objs := qca_spi.o qca_framing.o qca_7k.o qca_debug.o
> +
> +obj-$(CONFIG_QCOM_EMAC) += emac/

Since you have a check on CONFIG_QCOM_EMAC in emac/Makefile, you could
always recurse into that directory while building (use obj-y).

> diff --git a/drivers/net/ethernet/qualcomm/emac/Makefile b/drivers/net/ethernet/qualcomm/emac/Makefile
> new file mode 100644
> index 0000000..01ee144
> --- /dev/null
> +++ b/drivers/net/ethernet/qualcomm/emac/Makefile
> @@ -0,0 +1,7 @@
> +#
> +# Makefile for the Qualcomm Technologies, Inc. EMAC Gigabit Ethernet driver
> +#
> +
> +obj-$(CONFIG_QCOM_EMAC) += qcom-emac.o

[snip]

> +
> +static void emac_adjust_link(struct net_device *netdev)
> +{
> +	struct emac_adapter *adpt = netdev_priv(netdev);
> +	struct phy_device *phydev = netdev->phydev;
> +
> +	if (phydev->link)
> +		emac_mac_start(adpt);
> +	else
> +		emac_mac_stop(adpt);

This is really excessive here, you typically don't need to completely
stop your transmitter/receiver/DMA/what have you, just reprogram the MAC
with the appropriate link speed/duplex/pause parameters.

-- 
Florian
