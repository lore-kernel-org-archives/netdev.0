From: John Crispin <blogic@openwrt.org>
Subject: [PATCH V2 01/12] net-next: mediatek: Document ralink/mediatek SoC ethernet binding
Date: Fri, 26 Feb 2016 15:21:33 +0100
Message-ID: <1456496504-50429-2-git-send-email-blogic@openwrt.org>
References: <1456496504-50429-1-git-send-email-blogic@openwrt.org>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
	Matthias Brugger <matthias.bgg@gmail.com>,
	=?UTF-8?q?Steven=20Liu=20=28=E5=8A=89=E4=BA=BA=E8=B1=AA=29?=
	<steven.liu@mediatek.com>,
	=?UTF-8?q?Carlos=20Huang=20=28=E9=BB=83=E5=A3=AB=E5=BD=B0=29?=
	<Carlos.Huang@mediatek.com>,
	=?UTF-8?q?Fred=20Chang=20=28=E5=BC=B5=E5=98=89=E5=AE=8F=29?=
	<Fred.Chang@mediatek.com>, John Crispin <blogic@openwrt.org>,
	Felix Fietkau <nbd@openwrt.org>,
	Michael Lee <igvtee@gmail.com>, devicetree@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456496504-50429-1-git-send-email-blogic@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add three files. One describes the actual frame engine, the other two
describe fast ethernet and gigabit switches bindings.

Signed-off-by: John Crispin <blogic@openwrt.org>
Signed-off-by: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: Michael Lee <igvtee@gmail.com>
Cc: devicetree@vger.kernel.org
---
 .../devicetree/bindings/net/mediatek-net-esw.txt   |   25 +++++
 .../devicetree/bindings/net/mediatek-net-gsw.txt   |   48 +++++++++
 .../devicetree/bindings/net/mediatek-net.txt       |  113 ++++++++++++++++++++
 3 files changed, 186 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/mediatek-net-esw.txt
 create mode 100644 Documentation/devicetree/bindings/net/mediatek-net-gsw.txt
 create mode 100644 Documentation/devicetree/bindings/net/mediatek-net.txt

diff --git a/Documentation/devicetree/bindings/net/mediatek-net-esw.txt b/Documentation/devicetree/bindings/net/mediatek-net-esw.txt
new file mode 100644
index 0000000..84c51a0
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/mediatek-net-esw.txt
@@ -0,0 +1,25 @@
+Ralink Fast Ethernet Embedded Switch
+====================================
+
+The ralink fast ethernet embedded switch can be found on Ralink and Mediatek
+SoCs (RT3x5x, RT5350, MT76x8).
+
+Required properties:
+- compatible: Should be "ralink,rt3050-esw"
+- reg: Address and length of the register set for the device
+- interrupts: Should contain the embedded switches interrupt
+
+Optional properties:
+- mediatek,led_polarity: override the active high/low settings of the leds
+- interrupt-parent: Should be the phandle for the interrupt controller
+  that services interrupts for this device
+
+Example:
+
+esw@10110000 {
+	compatible = "ralink,rt3050-esw";
+	reg = <0x10110000 8000>;
+
+	interrupt-parent = <&intc>;
+	interrupts = <17>;
+};
diff --git a/Documentation/devicetree/bindings/net/mediatek-net-gsw.txt b/Documentation/devicetree/bindings/net/mediatek-net-gsw.txt
new file mode 100644
index 0000000..596b385
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/mediatek-net-gsw.txt
@@ -0,0 +1,48 @@
+Mediatek Gigabit Switch
+=======================
+
+The mediatek gigabit switch can be found on Mediatek SoCs.
+
+Required properties:
+- compatible: Should be "mediatek,mt7620-gsw", "mediatek,mt7621-gsw",
+  "mediatek,mt7623-gsw"
+- reg: Address and length of the register set for the device
+- interrupts: Should contain the gigabit switches interrupt
+
+
+Additional required properties for ARM based SoCs:
+- mediatek,reset-pin: phandle describing the reset GPIO
+- clocks: the clocks used by the switch
+- clock-names: the names of the clocks listed in the clocks property
+  these should be "trgpll", "esw", "gp2", "gp1"
+- mt7530-supply: the phandle of the regulator used to power the switch
+- mediatek,pctl-regmap: phandle to the port control regmap. this is used to
+  setup the drive current
+
+
+Optional properties:
+- interrupt-parent: Should be the phandle for the interrupt controller
+  that services interrupts for this device
+
+Example:
+
+gsw: switch@1b100000 {
+	compatible = "mediatek,mt7623-gsw";
+	reg = <0 0x1b110000 0 0x300000>;
+
+	interrupt-parent = <&pio>;
+	interrupts = <168 IRQ_TYPE_EDGE_RISING>;
+
+	clocks = <&apmixedsys CLK_APMIXED_TRGPLL>,
+		 <&ethsys CLK_ETHSYS_ESW>,
+		 <&ethsys CLK_ETHSYS_GP2>,
+		 <&ethsys CLK_ETHSYS_GP1>;
+	clock-names = "trgpll", "esw", "gp2", "gp1";
+
+	mt7530-supply = <&mt6323_vpa_reg>;
+
+	mediatek,pctl-regmap = <&syscfg_pctl_a>;
+	mediatek,reset-pin = <&pio 15 0>;
+
+	status = "okay";
+};
diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
new file mode 100644
index 0000000..f8c5747
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
@@ -0,0 +1,113 @@
+iMEdiatek Frame Engine Ethernet controller
+=======================================
+
+The frame engine ethernet controller can be found on Ralink and Mediatek SoCs
+(RT288x, RT3x5x, RT366x, RT388x, rt5350, mt7620, mt7621, mt76x8).
+
+Depending on the SoC, there is a number of ports connected to the CPU port
+directly and/or via a (gigabit-)switch. Newer gigabit SoCs can support
+a dual MAC setup.
+
+* Ethernet controller node
+
+Required properties:
+- compatible: Should be one of "ralink,rt2880-eth", "ralink,rt3050-eth",
+  "ralink,rt3050-eth", "ralink,rt3883-eth", "ralink,rt5350-eth",
+  "mediatek,mt7620-eth", "mediatek,mt7621-eth", "mediatek,mt7623-eth"
+- reg: Address and length of the register set for the device
+- interrupts: Should contain the frame engines interrupt
+- mediatek,ethsys: phandle to the syscon node that handles the port setup
+
+Required properties for ARM based SoCs:
+- clocks: the clock used by the core
+- clock-names: the names of the clock listed in the clocks property
+- power-domains: phandle the to power domain that the ethernet is part of
+
+Optional properties:
+- interrupt-parent: Should be the phandle for the interrupt controller
+  that services interrupts for this device
+- mediatek,switch : phandle pointing at the device node of the switch device
+
+
+* Ethernet port node for MT7620
+
+We need to define which physical port is wired and how it should be setup.
+
+Required properties:
+- compatible: Should be "mediatek,eth-port"
+- reg: The number of the physical port
+- phy-handle: reference to the node describing the phy
+
+
+* Ethernet MAC node - dual MAC SoCs only
+
+Required properties:
+- compatible: Should be "mediatek,eth-mac"
+- reg: The number of the MAC
+
+
+Example for singel MAC SoC:
+
+mdio-bus {
+	status = "okay";
+
+	phy4: ethernet-phy@4 {
+		reg = <4>;
+		phy-mode = "rgmii";
+	};
+};
+
+eth: ethernet@10100000 {
+	compatible = "mediatek,mt7620-eth";
+	reg = <0x10100000 10000>;
+
+	#address-cells = <1>;
+	#size-cells = <0>;
+
+	interrupt-parent = <&cpuintc>;
+	interrupts = <5>;
+
+	mediatek,switch = <&gsw>;
+
+	port@4 {
+		status = "okay";
+		phy-mode = "rgmii";
+		phy-handle = <&phy4>;
+	};
+};
+
+
+Example for dual MAC SoC:
+
+eth: ethernet@1b100000 {
+	compatible = "mediatek,mt7623-eth";
+	reg = <0 0x1b100000 0 0x10000>;
+
+	clocks = <&topckgen CLK_TOP_ETHIF_SEL>;
+	clock-names = "ethif";
+
+	interrupts = <GIC_SPI 200 IRQ_TYPE_LEVEL_LOW>;
+	power-domains = <&scpsys MT2701_POWER_DOMAIN_ETH>;
+
+	mediatek,ethsys = <&ethsys>;
+	mediatek,switch = <&gsw>;
+
+	#address-cells = <1>;
+	#size-cells = <0>;
+
+	status = "disabled";
+
+	gmac1: mac@0 {
+		compatible = "mediatek,eth-mac";
+		reg = <0>;
+
+		status = "okay";
+	};
+
+	gmac2: mac@1 {
+		compatible = "mediatek,eth-mac";
+		reg = <1>;
+
+		status = "okay";
+	};
+};
-- 
1.7.10.4
