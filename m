From: Eric Anholt <eric@anholt.net>
Subject: [PATCH v3 2/2] ARM: dts: Add the ethernet and ethernet PHY to the cygnus core DT.
Date: Fri, 28 Apr 2017 15:22:04 -0700
Message-ID: <20170428222204.7103-2-eric@anholt.net>
References: <20170428222204.7103-1-eric@anholt.net>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com, Ray Jui <rjui@broadcom.com>,
        Scott Branden <sbranden@broadcom.com>,
        Jon Mason <jonmason@broadcom.com>,
        Eric Anholt <eric@anholt.net>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from anholt.net ([50.246.234.109]:45116 "EHLO anholt.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1425924AbdD1WWJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 18:22:09 -0400
In-Reply-To: <20170428222204.7103-1-eric@anholt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cygnus has a single amac controller connected to the B53 switch with 2
PHYs.  On the BCM911360_EP platform, those two PHYs are connected to
the external ethernet jacks.

v2: Call the node "switch", just call the ports "port" (suggestions by
    Florian), drop max-speed on the phys (suggestion by Andrew Lunn),
    call the other nodes "ethernet" and "ethernet-phy" (suggestions by
    Sergei Shtylyov)
v3: Drop another max-speed (Andrew), keep mdio disabled in the shared
    dtsi (Florian)

Signed-off-by: Eric Anholt <eric@anholt.net>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 arch/arm/boot/dts/bcm-cygnus.dtsi      | 58 ++++++++++++++++++++++++++++++++++
 arch/arm/boot/dts/bcm911360_entphn.dts | 12 +++++++
 2 files changed, 70 insertions(+)

diff --git a/arch/arm/boot/dts/bcm-cygnus.dtsi b/arch/arm/boot/dts/bcm-cygnus.dtsi
index 34603bfed46a..687f5fe8aa0f 100644
--- a/arch/arm/boot/dts/bcm-cygnus.dtsi
+++ b/arch/arm/boot/dts/bcm-cygnus.dtsi
@@ -142,6 +142,55 @@
 			interrupts = <0>;
 		};
 
+		mdio: mdio@18002000 {
+			compatible = "brcm,iproc-mdio";
+			reg = <0x18002000 0x8>;
+			#size-cells = <1>;
+			#address-cells = <0>;
+			status = "disabled";
+
+			gphy0: ethernet-phy@0 {
+				reg = <0>;
+			};
+
+			gphy1: ethernet-phy@1 {
+				reg = <1>;
+			};
+		};
+
+		switch: switch@18007000 {
+			compatible = "brcm,bcm11360-srab", "brcm,cygnus-srab";
+			reg = <0x18007000 0x1000>;
+			status = "disabled";
+
+			ports {
+				#address-cells = <1>;
+				#size-cells = <0>;
+
+				port@0 {
+					reg = <0>;
+					phy-handle = <&gphy0>;
+					phy-mode = "rgmii";
+				};
+
+				port@1 {
+					reg = <1>;
+					phy-handle = <&gphy1>;
+					phy-mode = "rgmii";
+				};
+
+				port@8 {
+					reg = <8>;
+					label = "cpu";
+					ethernet = <&eth0>;
+					fixed-link {
+						speed = <1000>;
+						full-duplex;
+					};
+				};
+			};
+		};
+
 		i2c0: i2c@18008000 {
 			compatible = "brcm,cygnus-iproc-i2c", "brcm,iproc-i2c";
 			reg = <0x18008000 0x100>;
@@ -295,6 +344,15 @@
 			status = "disabled";
 		};
 
+		eth0: ethernet@18042000 {
+			compatible = "brcm,amac";
+			reg = <0x18042000 0x1000>,
+			      <0x18110000 0x1000>;
+			reg-names = "amac_base", "idm_base";
+			interrupts = <GIC_SPI 110 IRQ_TYPE_LEVEL_HIGH>;
+			status = "disabled";
+		};
+
 		nand: nand@18046000 {
 			compatible = "brcm,nand-iproc", "brcm,brcmnand-v6.1";
 			reg = <0x18046000 0x600>, <0xf8105408 0x600>,
diff --git a/arch/arm/boot/dts/bcm911360_entphn.dts b/arch/arm/boot/dts/bcm911360_entphn.dts
index 037621c13290..000f5f19215e 100644
--- a/arch/arm/boot/dts/bcm911360_entphn.dts
+++ b/arch/arm/boot/dts/bcm911360_entphn.dts
@@ -57,6 +57,18 @@
 	};
 };
 
+&eth0 {
+	status = "okay";
+};
+
+&mdio {
+	status = "okay";
+};
+
+&switch {
+	status = "okay";
+};
+
 &v3d {
 	assigned-clocks =
 		<&mipipll BCM_CYGNUS_MIPIPLL>,
-- 
2.11.0
