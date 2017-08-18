From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 4/4] dt-bindings: net: dwmac-sun8i: update documentation about integrated PHY
Date: Fri, 18 Aug 2017 14:21:18 +0200
Message-ID: <20170818122118.4925-5-clabbe.montjoie@gmail.com>
References: <20170818122118.4925-1-clabbe.montjoie@gmail.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com, linux@armlinux.org.uk,
        maxime.ripard@free-electrons.com, wens@csie.org,
        peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170818122118.4925-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch add documentation about the MDIO switch used on sun8i-h3-emac
for integrated PHY.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 .../devicetree/bindings/net/dwmac-sun8i.txt        | 112 +++++++++++++++++++--
 1 file changed, 105 insertions(+), 7 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/dwmac-sun8i.txt b/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
index 725f3b187886..631084122532 100644
--- a/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
+++ b/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
@@ -39,7 +39,7 @@ Optional properties for the following compatibles:
 - allwinner,leds-active-low: EPHY LEDs are active low
 
 Required child node of emac:
-- mdio bus node: should be named mdio
+- mdio bus node: should be named mdio (or mdio_parent in case of H3)
 
 Required properties of the mdio node:
 - #address-cells: shall be 1
@@ -48,14 +48,21 @@ Required properties of the mdio node:
 The device node referenced by "phy" or "phy-handle" should be a child node
 of the mdio node. See phy.txt for the generic PHY bindings.
 
-Required properties of the phy node with the following compatibles:
+Required mdio-mux nodes for the following compatibles:
+  - "allwinner,sun8i-h3-emac",
+- a mdio-mux node with compatible = "allwinner,sun8i-h3-mdio-switch"
+  - mdio-parent-bus: The parent bus is "mdio_parent"
+  - two child mdio, one for the integrated mdio, one for the external mdio
+
+Required properties of the integrated phy node with the following compatibles:
   - "allwinner,sun8i-h3-emac",
   - "allwinner,sun8i-v3s-emac":
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
@@ -75,10 +82,101 @@ emac: ethernet@1c0b000 {
 	mdio: mdio {
 		#address-cells = <1>;
 		#size-cells = <0>;
-		int_mii_phy: ethernet-phy@1 {
+	};
+	mdio-mux {
+		compatible = "allwinner,sun8i-h3-mdio-switch";
+		mdio-parent-bus = <&mdio>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		int_mdio: mdio@1 {
+			reg = <1>;
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
+			reg = <0>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+		};
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
+	mdio: mdio {
+		#address-cells = <1>;
+		#size-cells = <0>;
+	};
+	mdio-mux {
+		compatible = "allwinner,sun8i-h3-mdio-switch";
+		mdio-parent-bus = <&mdio>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		int_mdio: mdio@1 {
+			reg = <1>;
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
+			reg = <0>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+			ext_rgmii_phy: ethernet-phy@1 {
+				reg = <1>;
+			};
+		};
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
+	mdio: mdio {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		ext_rgmii_phy: ethernet-phy@1 {
 			reg = <1>;
-			clocks = <&ccu CLK_BUS_EPHY>;
-			resets = <&ccu RST_BUS_EPHY>;
 		};
 	};
 };
-- 
2.13.0
