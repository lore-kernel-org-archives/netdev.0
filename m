From: Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
Subject: [PATCH V2] dt: net: enhance DWC EQoS binding to support Tegra186
Date: Wed, 24 Aug 2016 15:20:46 -0600
Message-ID: <20160824212046.2416-1-swarren@wwwdotorg.org>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stephen Warren <swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
To: Lars Persson <lars.persson-VrBV9hrLPhE@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Stephen Warren <swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>

The Synopsys DWC EQoS is a configurable IP block which supports multiple
options for bus type, clocking and reset structure, and feature list.
Extend the DT binding to define a "compatible value" for the configuration
contained in NVIDIA's Tegra186 SoC, and define some new properties and
list property entries required by that configuration.

Signed-off-by: Stephen Warren <swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
---
v2:
* Add an explicit compatible value for the Axis SoC's version of the EQOS
  IP; this allows the driver to handle any SoC-specific integration quirks
  that are required, rather than only knowing about the IP block in
  isolation. This is good general DT practice. The existing value is still
  documented to support existing DTs.
* Reworked the list of clocks the binding requires:
  - Combined "tx" and "phy_ref_clk"; for GMII/RGMII configurations, these
    are the same thing.
  - Added extra description to the "rx" and "tx" clocks, to make it clear
    exactly which HW clock they represent.
  - Made the new "tx" and "slave_bus" names more prominent than the
    original "phy_ref_clk" and "apb_pclk". The new names are more generic
    and should work for any enhanced version of the binding (e.g. to
    support additional PHY types). New compatible values will hopefully
    choose to require the new names.
* Added a couple extra clocks to the list that may need to be supported in
  future binding revisions.
* Fixed a typo; "clocks" -> "resets".
---
 .../bindings/net/snps,dwc-qos-ethernet.txt         | 75 ++++++++++++++++++++--
 1 file changed, 71 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt b/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
index 51f8d2eba8d8..1d028259824a 100644
--- a/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
+++ b/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
@@ -1,21 +1,87 @@
 * Synopsys DWC Ethernet QoS IP version 4.10 driver (GMAC)
 
+This binding supports the Synopsys Designware Ethernet QoS (Quality Of Service)
+IP block. The IP supports multiple options for bus type, clocking and reset
+structure, and feature list. Consequently, a number of properties and list
+entries in properties are marked as optional, or only required in specific HW
+configurations.
 
 Required properties:
-- compatible: Should be "snps,dwc-qos-ethernet-4.10"
+- compatible: One of:
+  - "axis,artpec6-eqos", "snps,dwc-qos-ethernet-4.10"
+    Represents the IP core when integrated into the Axis ARTPEC-6 SoC.
+  - "nvidia,tegra186-eqos", "snps,dwc-qos-ethernet-4.10"
+    Represents the IP core when integrated into the NVIDIA Tegra186 SoC.
+  - "snps,dwc-qos-ethernet-4.10"
+    This combination is deprecated. It should be treated as equivalent to
+    "axis,artpec6-eqos", "snps,dwc-qos-ethernet-4.10". It is supported to be
+    compatible with earlier revisions of this binding.
 - reg: Address and length of the register set for the device
-- clocks: Phandles to the reference clock and the bus clock
-- clock-names: Should be "phy_ref_clk" for the reference clock and "apb_pclk"
-  for the bus clock.
+- clocks: Phandle and clock specifiers for each entry in clock-names, in the
+  same order. See ../clock/clock-bindings.txt.
+- clock-names: May contain any/all of the following depending on the IP
+  configuration, in any order:
+  - "tx"
+    (Alternate name "phy_ref_clk"; only one alternate must appear.)
+    The EQOS transmit path clock. The HW signal name is clk_tx_i.
+    In some configurations (e.g. GMII/RGMII), this clock also drives the PHY TX
+    path. In other configurations, other clocks (such as tx_125, rmii) may
+    drive the PHY TX path.
+  - "rx"
+    The EQOS receive path clock. The HW signal name is clk_rx_i.
+    In some configurations (e.g. GMII/RGMII), this clock also drives the PHY RX
+    path. In other configurations, other clocks (such as rx_125, pmarx_0,
+    pmarx_1, rmii) may drive the PHY RX path.
+  - "slave_bus"
+    (Alternate name "apb_pclk"; only one alternate must appear.)
+    The CPU/slave-bus (CSR) interface clock. Despite the name, this applies to
+    any bus type; APB, AHB, AXI, etc. The HW signal name is hclk_i (AHB) or
+    clk_csr_i (other buses).
+  - "master_bus"
+    The master bus interface clock. Only required in configurations that use a
+    separate clock for the master and slave bus interfaces. The HW signal name
+    is hclk_i (AHB) or aclk_i (AXI).
+  - "ptp_ref"
+    The PTP reference clock. The HW signal name is clk_ptp_ref_i.
+
+  Note: Support for additional IP configurations may require adding the
+  following clocks to this list in the future: clk_rx_125_i, clk_tx_125_i,
+  clk_pmarx_0_i, clk_pmarx1_i, clk_rmii_i, clk_revmii_rx_i, clk_revmii_tx_i.
+
+  The following compatible values require the following set of clocks:
+  - "nvidia,tegra186-eqos", "snps,dwc-qos-ethernet-4.10":
+    - "slave_bus"
+    - "master_bus"
+    - "rx"
+    - "tx"
+    - "ptp_ref"
+  - "axis,artpec6-eqos", "snps,dwc-qos-ethernet-4.10":
+    - "phy_ref_clk"
+    - "apb_clk"
 - interrupt-parent: Should be the phandle for the interrupt controller
   that services interrupts for this device
 - interrupts: Should contain the core's combined interrupt signal
 - phy-mode: See ethernet.txt file in the same directory
+- resets: Phandle and reset specifiers for each entry in reset-names, in the
+  same order. See ../reset/reset.txt.
+- reset-names: May contain any/all of the following depending on the IP
+  configuration, in any order:
+  - "eqos". The reset to the entire module. The HW signal name is hreset_n
+    (AHB) or aresetn_i (AXI).
+
+  The following compatible values require the following set of resets:
+  (the reset properties may be omitted if empty)
+  - "nvidia,tegra186-eqos", "snps,dwc-qos-ethernet-4.10":
+    - "eqos".
+  - "axis,artpec6-eqos", "snps,dwc-qos-ethernet-4.10":
+    - None.
 
 Optional properties:
 - dma-coherent: Present if dma operations are coherent
 - mac-address: See ethernet.txt in the same directory
 - local-mac-address: See ethernet.txt in the same directory
+- phy-reset-gpios: Phandle and specifier for any GPIO used to reset the PHY.
+  See ../gpio/gpio.txt.
 - snps,en-lpi: If present it enables use of the AXI low-power interface
 - snps,write-requests: Number of write requests that the AXI port can issue.
   It depends on the SoC configuration.
@@ -52,6 +118,7 @@ ethernet2@40010000 {
 	reg = <0x40010000 0x4000>;
 	phy-handle = <&phy2>;
 	phy-mode = "gmii";
+	phy-reset-gpios = <&gpioctlr 43 GPIO_ACTIVE_LOW>;
 
 	snps,en-tx-lpi-clockgating;
 	snps,en-lpi;
-- 
2.9.3
