From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v8 02/10] dt-bindings: net: dwmac-sun8i: update documentation about integrated PHY
Date: Mon, 23 Oct 2017 20:56:18 +0200
Message-ID: <20171023185626.31793-3-clabbe.montjoie@gmail.com>
References: <20171023185626.31793-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, andrew@lunn.ch, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171023185626.31793-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch add documentation about the MDIO switch used on sun8i-h3-emac
for integrated PHY.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 .../devicetree/bindings/net/dwmac-sun8i.txt        | 139 +++++++++++++++++++--
 1 file changed, 127 insertions(+), 12 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/dwmac-sun8i.txt b/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
index 725f3b187886..3e37db10fa02 100644
--- a/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
+++ b/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
@@ -4,18 +4,18 @@ This device is a platform glue layer for stmmac.
 Please see stmmac.txt for the other unchanged properties.
 
 Required properties:
-- compatible: should be one of the following string:
+- compatible: must be one of the following string:
 		"allwinner,sun8i-a83t-emac"
 		"allwinner,sun8i-h3-emac"
 		"allwinner,sun8i-v3s-emac"
 		"allwinner,sun50i-a64-emac"
 - reg: address and length of the register for the device.
 - interrupts: interrupt for the device
-- interrupt-names: should be "macirq"
+- interrupt-names: must be "macirq"
 - clocks: A phandle to the reference clock for this device
-- clock-names: should be "stmmaceth"
+- clock-names: must be "stmmaceth"
 - resets: A phandle to the reset control for this device
-- reset-names: should be "stmmaceth"
+- reset-names: must be "stmmaceth"
 - phy-mode: See ethernet.txt
 - phy-handle: See ethernet.txt
 - #address-cells: shall be 1
@@ -39,23 +39,38 @@ Optional properties for the following compatibles:
 - allwinner,leds-active-low: EPHY LEDs are active low
 
 Required child node of emac:
-- mdio bus node: should be named mdio
+- mdio bus node: with compatible "snps,dwmac-mdio"
 
 Required properties of the mdio node:
 - #address-cells: shall be 1
 - #size-cells: shall be 0
 
-The device node referenced by "phy" or "phy-handle" should be a child node
+The device node referenced by "phy" or "phy-handle" must be a child node
 of the mdio node. See phy.txt for the generic PHY bindings.
 
-Required properties of the phy node with the following compatibles:
+The following compatibles require that the emac node have a mdio-mux child
+node called "mdio-mux":
+  - "allwinner,sun8i-h3-emac"
+  - "allwinner,sun8i-v3s-emac":
+Required properties for the mdio-mux node:
+  - compatible = "mdio-mux", "allwinner,sun8i-h3-mdio-mux"
+  - one child mdio for the integrated mdio with the compatible
+    "allwinner,sun8i-h3-mdio-internal"
+  - one child mdio for the external mdio if present (V3s have none)
+Required properties for the mdio-mux children node:
+  - reg: 1 for internal MDIO bus, 2 for external MDIO bus
+
+The following compatibles require a PHY node representing the integrated
+PHY, under the integrated MDIO bus node if an mdio-mux node is used:
   - "allwinner,sun8i-h3-emac",
   - "allwinner,sun8i-v3s-emac":
+
+Required properties of the integrated phy node:
 - clocks: a phandle to the reference clock for the EPHY
 - resets: a phandle to the reset control for the EPHY
+- Must be a child of the integrated mdio
 
-Example:
-
+Example with integrated PHY:
 emac: ethernet@1c0b000 {
 	compatible = "allwinner,sun8i-h3-emac";
 	syscon = <&syscon>;
@@ -72,13 +87,113 @@ emac: ethernet@1c0b000 {
 	phy-handle = <&int_mii_phy>;
 	phy-mode = "mii";
 	allwinner,leds-active-low;
+
+	mdio0: mdio {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		compatible = "snps,dwmac-mdio";
+	};
+
+	mdio-mux {
+		compatible = "mdio-mux", "allwinner,sun8i-h3-mdio-mux";
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		int_mdio: mdio@1 {
+			compatible = "allwinner,sun8i-h3-mdio-internal";
+			reg = <1>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+			int_mii_phy: ethernet-phy@1 {
+				reg = <1>;
+				clocks = <&ccu CLK_BUS_EPHY>;
+				resets = <&ccu RST_BUS_EPHY>;
+				phy-is-integrated;
+			};
+		};
+		ext_mdio: mdio@2 {
+			reg = <2>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+		};
+	};
+};
+
+Example with external PHY:
+emac: ethernet@1c0b000 {
+	compatible = "allwinner,sun8i-h3-emac";
+	syscon = <&syscon>;
+	reg = <0x01c0b000 0x104>;
+	interrupts = <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
+	interrupt-names = "macirq";
+	resets = <&ccu RST_BUS_EMAC>;
+	reset-names = "stmmaceth";
+	clocks = <&ccu CLK_BUS_EMAC>;
+	clock-names = "stmmaceth";
+	#address-cells = <1>;
+	#size-cells = <0>;
+
+	phy-handle = <&ext_rgmii_phy>;
+	phy-mode = "rgmii";
+	allwinner,leds-active-low;
+
+	mdio0: mdio {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		compatible = "snps,dwmac-mdio";
+	};
+
+	mdio-mux {
+		compatible = "mdio-mux", "allwinner,sun8i-h3-mdio-mux";
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		int_mdio: mdio@1 {
+			compatible = "allwinner,sun8i-h3-mdio-internal";
+			reg = <1>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+			int_mii_phy: ethernet-phy@1 {
+				reg = <1>;
+				clocks = <&ccu CLK_BUS_EPHY>;
+				resets = <&ccu RST_BUS_EPHY>;
+			};
+		};
+		ext_mdio: mdio@2 {
+			reg = <2>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+			ext_rgmii_phy: ethernet-phy@1 {
+				reg = <1>;
+			};
+		}:
+	};
+};
+
+Example with SoC without integrated PHY
+
+emac: ethernet@1c0b000 {
+	compatible = "allwinner,sun8i-a83t-emac";
+	syscon = <&syscon>;
+	reg = <0x01c0b000 0x104>;
+	interrupts = <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
+	interrupt-names = "macirq";
+	resets = <&ccu RST_BUS_EMAC>;
+	reset-names = "stmmaceth";
+	clocks = <&ccu CLK_BUS_EMAC>;
+	clock-names = "stmmaceth";
+	#address-cells = <1>;
+	#size-cells = <0>;
+
+	phy-handle = <&ext_rgmii_phy>;
+	phy-mode = "rgmii";
+
 	mdio: mdio {
+		compatible = "snps,dwmac-mdio";
 		#address-cells = <1>;
 		#size-cells = <0>;
-		int_mii_phy: ethernet-phy@1 {
+		ext_rgmii_phy: ethernet-phy@1 {
 			reg = <1>;
-			clocks = <&ccu CLK_BUS_EPHY>;
-			resets = <&ccu RST_BUS_EPHY>;
 		};
 	};
 };
-- 
2.13.6
