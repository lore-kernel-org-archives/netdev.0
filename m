From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v5 05/10] dt-bindings: net: dwmac-sun8i: update documentation about integrated PHY
Date: Fri,  8 Sep 2017 09:11:51 +0200
Message-ID: <20170908071156.5115-6-clabbe.montjoie@gmail.com>
References: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, andrew@lunn.ch, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch add documentation about the MDIO switch used on sun8i-h3-emac
for integrated PHY.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 .../devicetree/bindings/net/dwmac-sun8i.txt        | 127 +++++++++++++++++++--
 1 file changed, 120 insertions(+), 7 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/dwmac-sun8i.txt b/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
index 725f3b187886..3fa0e54825ea 100644
--- a/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
+++ b/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
@@ -39,7 +39,7 @@ Optional properties for the following compatibles:
 - allwinner,leds-active-low: EPHY LEDs are active low
 
 Required child node of emac:
-- mdio bus node: should be named mdio
+- mdio bus node: should be labelled mdio
 
 Required properties of the mdio node:
 - #address-cells: shall be 1
@@ -48,14 +48,28 @@ Required properties of the mdio node:
 The device node referenced by "phy" or "phy-handle" should be a child node
 of the mdio node. See phy.txt for the generic PHY bindings.
 
-Required properties of the phy node with the following compatibles:
+The following compatibles require an mdio-mux node called "mdio-mux":
+  - "allwinner,sun8i-h3-emac"
+  - "allwinner,sun8i-v3s-emac":
+Required properties for the mdio-mux node:
+  - compatible = "mdio-mux"
+  - one child mdio for the integrated mdio
+  - one child mdio for the external mdio if present (V3s have none)
+Required properties for the mdio-mux children node:
+  - reg: 0 for internal MDIO bus, 1 for external MDIO bus
+
+The following compatibles require a PHY node representing the integrated
+PHY, under the integrated MDIO bus node if an mdio-mux node is used:
   - "allwinner,sun8i-h3-emac",
   - "allwinner,sun8i-v3s-emac":
+
+Required properties of the integrated phy node:
 - clocks: a phandle to the reference clock for the EPHY
 - resets: a phandle to the reset control for the EPHY
+- phy-is-integrated
+- Should be a child of the integrated mdio
 
-Example:
-
+Example with integrated PHY:
 emac: ethernet@1c0b000 {
 	compatible = "allwinner,sun8i-h3-emac";
 	syscon = <&syscon>;
@@ -72,13 +86,112 @@ emac: ethernet@1c0b000 {
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
+		compatible = "mdio-mux";
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		int_mdio: mdio@1 {
+			reg = <0>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+			int_mii_phy: ethernet-phy@1 {
+				reg = <1>;
+				clocks = <&ccu CLK_BUS_EPHY>;
+				resets = <&ccu RST_BUS_EPHY>;
+				phy-is-integrated
+			};
+		};
+		ext_mdio: mdio@0 {
+			reg = <1>;
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
+		compatible = "mdio-mux";
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		int_mdio: mdio@1 {
+			reg = <0>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+			int_mii_phy: ethernet-phy@1 {
+				reg = <1>;
+				clocks = <&ccu CLK_BUS_EPHY>;
+				resets = <&ccu RST_BUS_EPHY>;
+				phy-is-integrated
+			};
+		};
+		ext_mdio: mdio@0 {
+			reg = <1>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+			ext_rgmii_phy: ethernet-phy@1 {
+				reg = <1>;
+			};
+		};
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
2.13.5
