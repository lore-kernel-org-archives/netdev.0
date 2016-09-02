From: Lars Persson <lars.persson-VrBV9hrLPhE@public.gmane.org>
Subject: Re: [PATCH V3] dt: net: enhance DWC EQoS binding to support Tegra186
Date: Fri, 2 Sep 2016 09:56:41 +0200
Message-ID: <d15011d4-6dba-6e84-a139-6cd1a64ff05b@axis.com>
References: <20160901190216.5643-1-swarren@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephen Warren <swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
To: Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>,
        Lars Persson <larper-VrBV9hrLPhE@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160901190216.5643-1-swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 09/01/2016 09:02 PM, Stephen Warren wrote:
> From: Stephen Warren <swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
>
> The Synopsys DWC EQoS is a configurable IP block which supports multiple
> options for bus type, clocking and reset structure, and feature list.
> Extend the DT binding to define a "compatible value" for the configuration
> contained in NVIDIA's Tegra186 SoC, and define some new properties and
> list property entries required by that configuration.
>
> Signed-off-by: Stephen Warren <swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> ---
> v3:
> * Document legacy clock-names entries separately, and make it obvious
>   they're deprecated.
> * Reword the description of the "rx" clock to better describe the HW.
> * Add some extra guidance for future extensions of the binding to cover
>   configurations where additional RX clocks are required.
> * Explicitly document the list of clocks and resets for every compatible
>   value; don't miss any out.
> v2:
> * Add an explicit compatible value for the Axis SoC's version of the EQOS
>   IP; this allows the driver to handle any SoC-specific integration quirks
>   that are required, rather than only knowing about the IP block in
>   isolation. This is good general DT practice. The existing value is still
>   documented to support existing DTs.
> * Reworked the list of clocks the binding requires:
>   - Combined "tx" and "phy_ref_clk"; for GMII/RGMII configurations, these
>     are the same thing.
>   - Added extra description to the "rx" and "tx" clocks, to make it clear
>     exactly which HW clock they represent.
>   - Made the new "tx" and "slave_bus" names more prominent than the
>     original "phy_ref_clk" and "apb_pclk". The new names are more generic
>     and should work for any enhanced version of the binding (e.g. to
>     support additional PHY types). New compatible values will hopefully
>     choose to require the new names.
> * Added a couple extra clocks to the list that may need to be supported in
>   future binding revisions.
> * Fixed a typo; "clocks" -> "resets".
> ---
>  .../bindings/net/snps,dwc-qos-ethernet.txt         | 99 +++++++++++++++++++++-
>  1 file changed, 95 insertions(+), 4 deletions(-)
>
> diff --git a/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt b/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
> index 51f8d2eba8d8..d93f71ce8346 100644
> --- a/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
> +++ b/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
> @@ -1,21 +1,111 @@
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
> +  - "axis,artpec6-eqos", "snps,dwc-qos-ethernet-4.10"
> +    Represents the IP core when integrated into the Axis ARTPEC-6 SoC.
> +  - "nvidia,tegra186-eqos", "snps,dwc-qos-ethernet-4.10"
> +    Represents the IP core when integrated into the NVIDIA Tegra186 SoC.
> +  - "snps,dwc-qos-ethernet-4.10"
> +    This combination is deprecated. It should be treated as equivalent to
> +    "axis,artpec6-eqos", "snps,dwc-qos-ethernet-4.10". It is supported to be
> +    compatible with earlier revisions of this binding.
>  - reg: Address and length of the register set for the device
> -- clocks: Phandles to the reference clock and the bus clock
> -- clock-names: Should be "phy_ref_clk" for the reference clock and "apb_pclk"
> -  for the bus clock.
> +- clocks: Phandle and clock specifiers for each entry in clock-names, in the
> +  same order. See ../clock/clock-bindings.txt.
> +- clock-names: May contain any/all of the following depending on the IP
> +  configuration, in any order:
> +  - "tx"
> +    The EQOS transmit path clock. The HW signal name is clk_tx_i.
> +    In some configurations (e.g. GMII/RGMII), this clock also drives the PHY TX
> +    path. In other configurations, other clocks (such as tx_125, rmii) may
> +    drive the PHY TX path.
> +  - "rx"
> +    The EQOS receive path clock. The HW signal name is clk_rx_i.
> +    In some configurations (e.g. GMII/RGMII), this clock is derived from the
> +    PHY's RX clock output. In other configurations, other clocks (such as
> +    rx_125, rmii) may drive the EQOS RX path.
> +    In cases where the PHY clock is directly fed into the EQOS receive path
> +    without intervening logic, the DT need not represent this clock, since it
> +    is assumed to be fully under the control of the PHY device/driver. In
> +    cases where SoC integration adds additional logic to this path, such as a
> +    SW-controlled clock gate, this clock should be represented in DT.
> +  - "slave_bus"
> +    The CPU/slave-bus (CSR) interface clock. This applies to any bus type;
> +    APB, AHB, AXI, etc. The HW signal name is hclk_i (AHB) or clk_csr_i (other
> +    buses).
> +  - "master_bus"
> +    The master bus interface clock. Only required in configurations that use a
> +    separate clock for the master and slave bus interfaces. The HW signal name
> +    is hclk_i (AHB) or aclk_i (AXI).
> +  - "ptp_ref"
> +    The PTP reference clock. The HW signal name is clk_ptp_ref_i.
> +  - "phy_ref_clk"
> +    This clock is deprecated and should not be used by new compatible values.
> +    It is equivalent to "tx".
> +  - "apb_pclk"
> +    This clock is deprecated and should not be used by new compatible values.
> +    It is equivalent to "slave_bus".
> +
> +  Note: Support for additional IP configurations may require adding the
> +  following clocks to this list in the future: clk_rx_125_i, clk_tx_125_i,
> +  clk_pmarx_0_i, clk_pmarx1_i, clk_rmii_i, clk_revmii_rx_i, clk_revmii_tx_i.
> +  Configurations exist where multiple similar clocks are used at once, e.g. all
> +  of clk_rx_125_i, clk_pmarx_0_i, clk_pmarx1_i. For this reason it is best to
> +  extend the binding with a separate clock-names entry for each of those RX
> +  clocks, rather than repurposing the existing "rx" clock-names entry as a
> +  generic/logical clock in a similar fashion to "master_bus" and "slave_bus".
> +  This will allow easy support for configurations that support multiple PHY
> +  interfaces using a mux, and hence need to have explicit control over
> +  specific RX clocks.
> +
> +  The following compatible values require the following set of clocks:
> +  - "nvidia,tegra186-eqos", "snps,dwc-qos-ethernet-4.10":
> +    - "slave_bus"
> +    - "master_bus"
> +    - "rx"
> +    - "tx"
> +    - "ptp_ref"
> +  - "axis,artpec6-eqos", "snps,dwc-qos-ethernet-4.10":
> +    - "slave_bus"
> +    - "master_bus"
> +    - "tx"
> +    - "ptp_ref"
> +  - "snps,dwc-qos-ethernet-4.10" (deprecated):
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
> +  The following compatible values require the following set of resets:
> +  (the reset properties may be omitted if empty)
> +  - "nvidia,tegra186-eqos", "snps,dwc-qos-ethernet-4.10":
> +    - "eqos".
> +  - "axis,artpec6-eqos", "snps,dwc-qos-ethernet-4.10":
> +    - None.
> +  - "snps,dwc-qos-ethernet-4.10" (deprecated):
> +    - None.
>
>  Optional properties:
>  - dma-coherent: Present if dma operations are coherent
>  - mac-address: See ethernet.txt in the same directory
>  - local-mac-address: See ethernet.txt in the same directory
> +- phy-reset-gpios: Phandle and specifier for any GPIO used to reset the PHY.
> +  See ../gpio/gpio.txt.
>  - snps,en-lpi: If present it enables use of the AXI low-power interface
>  - snps,write-requests: Number of write requests that the AXI port can issue.
>    It depends on the SoC configuration.
> @@ -52,6 +142,7 @@ ethernet2@40010000 {
>  	reg = <0x40010000 0x4000>;
>  	phy-handle = <&phy2>;
>  	phy-mode = "gmii";
> +	phy-reset-gpios = <&gpioctlr 43 GPIO_ACTIVE_LOW>;
>
>  	snps,en-tx-lpi-clockgating;
>  	snps,en-lpi;
>

Acked-by: Lars Persson <larper-VrBV9hrLPhE@public.gmane.org>
