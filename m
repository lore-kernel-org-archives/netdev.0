From: Lars Persson <lars.persson@axis.com>
Subject: Re: [PATCH] dt: net: enhance DWC EQoS binding to support Tegra186
Date: Wed, 24 Aug 2016 10:10:42 +0200
Message-ID: <259bfaa8-6dcb-eafc-da9c-c16ec7d39d24@axis.com>
References: <20160823204757.17998-1-swarren@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-tegra@vger.kernel.org>, Stephen Warren <swarren@nvidia.com>
To: Stephen Warren <swarren@wwwdotorg.org>,
        Lars Persson <larper@axis.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:45715 "EHLO
        bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754046AbcHXIKv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 04:10:51 -0400
In-Reply-To: <20160823204757.17998-1-swarren@wwwdotorg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

Nice to see the driver used in other chips. I have some comments below.

Best Regards,
  Lars


On 08/23/2016 10:47 PM, Stephen Warren wrote:
> From: Stephen Warren <swarren@nvidia.com>
>
> The Synopsys DWC EQoS is a configurable IP block which supports multiple
> options for bus type, clocking and reset structure, and feature list.
> Extend the DT binding to define a "compatible value" for the configuration
> contained in NVIDIA's Tegra186 SoC, and define some new properties and
> list property entries required by that configuration.
>
> Signed-off-by: Stephen Warren <swarren@nvidia.com>
> ---
>  .../bindings/net/snps,dwc-qos-ethernet.txt         | 60 ++++++++++++++++++++--
>  1 file changed, 56 insertions(+), 4 deletions(-)
>
> diff --git a/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt b/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
> index 51f8d2eba8d8..6cd4129364a9 100644
> --- a/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
> +++ b/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
> @@ -1,21 +1,72 @@
>  * Synopsys DWC Ethernet QoS IP version 4.10 driver (GMAC)
>
> +This binding supports the Synopsys Designware Ethernet QoS (Quality Of Service)
> +IP block. The IP supports multiple options for bus type, clocking and reset
> +structure, and feature list. Consequently, a number of properties and list
> +entries in properties are marked as optional, or only required in specific HW
> +configurations.
>
>  Required properties:
> -- compatible: Should be "snps,dwc-qos-ethernet-4.10"
> +- compatible: One of:
> +  - "snps,dwc-qos-ethernet-4.10"
> +  - "nvidia,tegra186-eqos", "snps,dwc-qos-ethernet-4.10"
>  - reg: Address and length of the register set for the device
> -- clocks: Phandles to the reference clock and the bus clock
> -- clock-names: Should be "phy_ref_clk" for the reference clock and "apb_pclk"
> -  for the bus clock.
> +- clocks: Phandle and clock specifiers for each entry in clock-names, in the
> +  same order. See ../clock/clock-bindings.txt.
> +- clock-names: May contain any/all of the following depending on the IP
> +  configuration, in any order:
> +  - "phy_ref_clk". The reference clock provided directly to the PHY.
> +    Only required if under SW control, i.e. not provided by some fixed source
> +    such as a crystal.

I realize now that the clock name phy_ref_clock is slightly misleading. 
It represents the source of the GMII GTXCLK signal to the phy.

In our chip it is the same clock that drives clk_tx_i for GMII 1 Gb/s 
modes, but I agree that we should have a separate binding for the tx clock.

So update the description of phy_ref_clk to mention GTXCLK.

> +  - "apb_pclk" (alternate name "slave_bus"; only one alternate must appear).
> +    The CPU/slave-bus (CSR) interface clock. Despite the name, this applies to
> +    any bus type; APB, AHB, AXI, etc. The HW signal name is hclk_i (AHB) or
> +    clk_csr_i (other buses).
> +  - "master_bus". The master bus interface clock. Only required in
> +    configurations that use a separate clock for the master and slave bus
> +    interfaces. The HW signal name is hclk_i (AHB) or aclk_i (AXI).
> +  - "rx". The receive path clock. The HW signal name is clk_rx_i.
> +  - "tx". The transmit path clock. The HW signal name is clk_tx_i.
> +  - "ptp_ref". The PTP reference clock. The HW signal name is clk_ptp_ref_i.
> +
> +  Note: Support for additional HW configurations may require adding the
> +  following clocks to this list in the future: clk_rx_125_i, clk_tx_125_i,
> +  clk_pmarx_0_i, clk_pmarx1_i, clk_rmii_i.
> +
> +  The following compatible values require the following set of clocks:
> +  - "nvidia,tegra186-eqos", "snps,dwc-qos-ethernet-4.10":
> +    - "slave_bus"
> +    - "master_bus"
> +    - "rx"
> +    - "tx"
> +    - "ptp_ref"
> +  - "snps,dwc-qos-ethernet-4.10":
> +    - "phy_ref_clk"
> +    - "apb_clk"
>  - interrupt-parent: Should be the phandle for the interrupt controller
>    that services interrupts for this device
>  - interrupts: Should contain the core's combined interrupt signal
>  - phy-mode: See ethernet.txt file in the same directory
> +- resets: Phandle and reset specifiers for each entry in reset-names, in the
> +  same order. See ../reset/reset.txt.
> +- reset-names: May contain any/all of the following depending on the IP
> +  configuration, in any order:
> +  - "eqos". The reset to the entire module. The HW signal name is hreset_n
> +    (AHB) or aresetn_i (AXI).
> +
> +  The following compatible values require the following set of clocks:
s/clocks/resets/

> +  (the reset properties may be omitted if empty)
> +  - "nvidia,tegra186-eqos", "snps,dwc-qos-ethernet-4.10":
> +    - "eqos".
> +  - "snps,dwc-qos-ethernet-4.10":
> +    - None.
>
>  Optional properties:
>  - dma-coherent: Present if dma operations are coherent
>  - mac-address: See ethernet.txt in the same directory
>  - local-mac-address: See ethernet.txt in the same directory
> +- phy-reset-gpios: Phandle and specifier for any GPIO used to reset the PHY.
> +  See ../gpio/gpio.txt.

IMHO the phy reset gpio belongs in the binding for the PHY. I notice 
some other ethernet drivers have this, but the PHY should be managed 
entirely through the phylib and any special handling for reset can be 
hidden in phy specific drivers.


>  - snps,en-lpi: If present it enables use of the AXI low-power interface
>  - snps,write-requests: Number of write requests that the AXI port can issue.
>    It depends on the SoC configuration.
> @@ -52,6 +103,7 @@ ethernet2@40010000 {
>  	reg = <0x40010000 0x4000>;
>  	phy-handle = <&phy2>;
>  	phy-mode = "gmii";
> +	phy-reset-gpios = <&gpioctlr 43 GPIO_ACTIVE_LOW>;
>
>  	snps,en-tx-lpi-clockgating;
>  	snps,en-lpi;
>
