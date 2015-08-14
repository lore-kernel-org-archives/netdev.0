From: Kenneth Lee <liguozhu@hisilicon.com>
Subject: [PATCH 1/5] net: add Hisilicon Network Subsystem support (config and documents)
Date: Fri, 14 Aug 2015 18:30:18 +0800
Message-ID: <1439548222-231611-2-git-send-email-liguozhu@hisilicon.com>
References: <1439548222-231611-1-git-send-email-liguozhu@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kenneth Lee <liguozhu@huawei.com>
To: <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<davem@davemloft.net>, <paul.gortmaker@windriver.com>,
	<dingtianhong@huawei.com>, <zhangfei.gao@linaro.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>, <salil.mehta@huawei.com>,
	<huangdaode@hisilicon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439548222-231611-1-git-send-email-liguozhu@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Hisilicon Network Subsystem is a long term evolution IP which is
supposed to be used in Hisilicon ICT SoC. The IP, which is called hns for
short, is a TCP/IP acceleration engine, which can directly decode TCP/IP
stream and distribute them to different ring buffers.

HNS can be configured to work on different mode for different scenario.
This patch make use only some of the mode to make it as standard ethernet
NIC.  The other mode will be added soon.

The whole function has 4 kernel sub-modules:

hnae: the HNS acceleration engine framework. It provides a abstract
interface between the engine and the upper layers which make use of the
engine by ring buffer.

hns_enet_drv: a standard ethernet driver that base on the ring buffer.

hns_dsaf: one of the implementation of HNS acceleration engine, which is
applied on Hililicon P660, Hi1610 and other later-on SoCs

hns_mdio: the mdio control to the PHY, used by acceleration engine

This submit add basic config and documents

Signed-off-by: Kenneth Lee <liguozhu@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 .../devicetree/bindings/net/hisilicon-hns-dsaf.txt |  40 +++++
 .../devicetree/bindings/net/hisilicon-hns-mdio.txt |  22 +++
 .../devicetree/bindings/net/hisilicon-hns-nic.txt  |  14 ++
 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi       | 197 +++++++++++++++++++++
 4 files changed, 273 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
 create mode 100644 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
new file mode 100644
index 0000000..038c03d
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
@@ -0,0 +1,40 @@
+Hisilicon DSA Fabric device controller
+
+Required properties:
+- compatible: should be "hisilicon,dsaf".
+- dsa-name: dsa fabric name who provide this interface
+- interrupt-parent: the interrupt parent of this device.
+- interrupts: should contain the DSA Fabric and rcb interrupt.
+- reg: specifies base physical address(es) and size of the device registers.
+  The first region is external interface control register base and size.
+  The second region is SerDes base register and size.
+  The third region is the PPE register base and size.
+  The fourth region is dsa fabric base register and size.
+- phy-handle: phy handle of physicl port, 0 if not any phy device. see ethernet.txt [1].
+- buf-size: rx buffer size, should be 16-1024.
+- desc-num: number of description in TX and RX queue, should be 512, 1024, 2048 or 4096.
+
+[1] Documentation/devicetree/bindings/net/phy.txt
+
+Example:
+
+dsa: dsa@c7000000 {
+	compatible = "hisilicon,dsaf";
+	dsa_name = "soc0-n4";
+	interrupt-parent = <&mbigen_dsa>;
+	reg = <0x0 0xC0000000 0x0 0x420000
+	       0x0 0xC2000000 0x0 0x300000
+	       0x0 0xc5000000 0x0 0x890000
+	       0x0 0xc7000000 0x0 0x60000>;
+	phy-handle = <0 0 0 0 &soc0_phy4 &soc0_phy5 0 0>;
+	interrupts = <131 4>,<132 4>, <133 4>,<134 4>,
+		     <135 4>,<136 4>, <137 4>,<138 4>,
+		     <139 4>,<140 4>, <141 4>,<142 4>,
+		     <143 4>,<144 4>, <145 4>,<146 4>,
+		     <147 4>,<148 4>, <384 1>,<385 1>,
+		     <386 1>,<387 1>, <388 1>,<389 1>,
+		     <390 1>,<391 1>,
+	buf-size = <4096>;
+	desc-num = <1024>;
+	dma-coherent;
+};
diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt
new file mode 100644
index 0000000..205e803
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt
@@ -0,0 +1,22 @@
+Hisilicon MDIO bus controller
+
+Properties:
+- compatible: "hisilicon,mdio"
+- reg: The base address of the MDIO bus controller register bank.
+- #address-cells: Must be <1>.
+- #size-cells: Must be <0>.  MDIO addresses have no size component.
+
+Typically an MDIO bus might have several children.
+
+Example:
+         mdio@803c0000 {
+                   #address-cells = <1>;
+                   #size-cells = <0>;
+                   compatible = "hisilicon,mdio";
+                   reg = <0x0 0x803c0000 0x0 0x10000>;
+
+                   ethernet-phy@0 {
+                            ...
+                            reg = <0>;
+                   };
+         };
diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
new file mode 100644
index 0000000..5ab6969
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
@@ -0,0 +1,14 @@
+Hisilicon Network Subsystem NIC controller
+
+Required properties:
+- compatible: hisilicon,hns-nic
+- ae-name: accelerator name who provide this interface
+- ae-opts: options (string) to the accelerator. e.g. the index interface
+
+Example:
+
+	ethernet@0{
+		compatible = "hisilicon,hns-nic";
+		ae-name = "soc0-n4";
+		ae-opts = "0";
+	};
diff --git a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
new file mode 100644
index 0000000..80fd017
--- /dev/null
+++ b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
@@ -0,0 +1,197 @@
+soc0: soc@000000000 {
+	#address-cells = <2>;
+	#size-cells = <2>;
+	device_type = "soc";
+	compatible = "simple-bus";
+	ranges = <0x0 0x0 0x0 0x0 0x1 0x0>;
+	chip-id = <0>;
+
+	soc0_mdio0: mdio@803c0000 {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		compatible = "hisilicon,mdio";
+		reg = <0x0 0x803c0000 0x0 0x10000>;
+		irq-num = <9383>;
+
+		soc0_phy4: ethernet-phy@4 {
+			reg = <0x0>;
+			device_type = "ethernet-phy";
+			compatible = "ethernet-phy-ieee802.3-c22";
+		};
+		soc0_phy5: ethernet-phy@5 {
+			reg = <0x1>;
+			device_type = "ethernet-phy";
+			compatible = "ethernet-phy-ieee802.3-c22";
+		};
+	};
+
+	dsa: dsa@c7000000 {
+		compatible = "hisilicon,dsaf";
+		dsa_name = "soc0-n4";
+		interrupt-parent = <&mbigen_dsa>;
+
+		reg = <0x0 0xC0000000 0x0 0x420000
+		       0x0 0xC2000000 0x0 0x300000
+		       0x0 0xc5000000 0x0 0x890000
+		       0x0 0xc7000000 0x0 0x60000
+		       >;
+
+		phy-handle = <0 0 0 0 &soc0_phy4 &soc0_phy5 0 0>;
+
+		interrupts =	<131 4>,<132 4>, /* 0 : dsa 0 -17  */
+				<133 4>,<134 4>,
+				<135 4>,<136 4>,
+				<137 4>,<138 4>,
+				<139 4>,<140 4>,
+				<141 4>,<142 4>,
+				<143 4>,<144 4>,
+				<145 4>,<146 4>,
+				<147 4>,<148 4>, /* 17 :dsa end   */
+				<384 1>,<385 1>, /* 18: rcb 0  16*2*6  */
+				<386 1>,<387 1>,
+				<388 1>,<389 1>,
+				<390 1>,<391 1>,
+				<392 1>,<393 1>,
+				<394 1>,<395 1>,
+				<396 1>,<397 1>,
+				<398 1>,<399 1>,
+				<400 1>,<401 1>,
+				<402 1>,<403 1>,
+				<404 1>,<405 1>,
+				<406 1>,<407 1>,
+				<408 1>,<409 1>,
+				<410 1>,<411 1>,
+				<412 1>,<413 1>,
+				<414 1>,<415 1>, /*    */
+				<416 1>,<417 1>,
+				<418 1>,<419 1>,
+				<420 1>,<421 1>,
+				<422 1>,<423 1>,
+				<424 1>,<425 1>,
+				<426 1>,<427 1>,
+				<428 1>,<429 1>,
+				<430 1>,<431 1>,
+				<432 1>,<433 1>,
+				<434 1>,<435 1>,
+				<436 1>,<437 1>,
+				<438 1>,<439 1>,
+				<440 1>,<441 1>,
+				<442 1>,<443 1>,
+				<444 1>,<445 1>,
+				<446 1>,<447 1>,
+				<448 1>,<449 1>,
+				<450 1>,<451 1>,
+				<452 1>,<453 1>,
+				<454 1>,<455 1>,
+				<456 1>,<457 1>,
+				<458 1>,<459 1>,
+				<460 1>,<461 1>,
+				<462 1>,<463 1>,
+				<464 1>,<465 1>,
+				<466 1>,<467 1>,
+				<468 1>,<469 1>,
+				<470 1>,<471 1>,
+				<472 1>,<473 1>,
+				<474 1>,<475 1>,
+				<476 1>,<477 1>,
+				<478 1>,<479 1>,
+				<480 1>,<481 1>,
+				<482 1>,<483 1>,
+				<484 1>,<485 1>,
+				<486 1>,<487 1>,
+				<488 1>,<489 1>,
+				<490 1>,<491 1>,
+				<492 1>,<493 1>,
+				<494 1>,<495 1>,
+				<496 1>,<497 1>,
+				<498 1>,<499 1>,
+				<500 1>,<501 1>,
+				<502 1>,<503 1>,
+				<504 1>,<505 1>,
+				<506 1>,<507 1>,
+				<508 1>,<509 1>,
+				<510 1>,<511 1>,
+				<512 1>,<513 1>,
+				<514 1>,<515 1>,
+				<516 1>,<517 1>,
+				<518 1>,<519 1>,
+				<520 1>,<521 1>,
+				<522 1>,<523 1>,
+				<524 1>,<525 1>,
+				<526 1>,<527 1>,
+				<528 1>,<529 1>,
+				<530 1>,<531 1>,
+				<532 1>,<533 1>,
+				<534 1>,<535 1>,
+				<536 1>,<537 1>,
+				<538 1>,<539 1>,
+				<540 1>,<541 1>,
+				<542 1>,<543 1>,
+				<544 1>,<545 1>,
+				<546 1>,<547 1>,
+				<548 1>,<549 1>,
+				<550 1>,<551 1>,
+				<552 1>,<553 1>,
+				<554 1>,<555 1>,
+				<556 1>,<557 1>,
+				<558 1>,<559 1>,
+				<560 1>,<561 1>,
+				<562 1>,<563 1>,
+				<564 1>,<565 1>,
+				<566 1>,<567 1>,
+				<568 1>,<569 1>,
+				<570 1>,<571 1>,
+				<572 1>,<573 1>,
+				<574 1>,<575 1>, /* rcb 96*2end  */
+				<14  1>,<15  1>,
+				<20  1>,<21  1>;
+		buf-size = <4096>;
+		desc-num = <1024>;
+		dma-coherent;
+	};
+
+	ethernet@0{
+		compatible = "hisilicon,hns-nic";
+		ae-name = "soc0-n4";
+		ae-opts = "0";
+	};
+	ethernet@1{
+		compatible = "hisilicon,hns-nic";
+		ae-name = "soc0-n4";
+		ae-opts = "1";
+	};
+	ethernet@2{
+		compatible = "hisilicon,hns-nic";
+		ae-name = "soc0-n4";
+		ae-opts = "2";
+	};
+	ethernet@3{
+		compatible = "hisilicon,hns-nic";
+		ae-name = "soc0-n4";
+		ae-opts = "3";
+	};
+	ethernet@4{
+		compatible = "hisilicon,hns-nic";
+		ae-name = "soc0-n4";
+		ae-opts = "4";
+	};
+	ethernet@5{
+		compatible = "hisilicon,hns-nic";
+		ae-name = "soc0-n4";
+		ae-opts = "5";
+	};
+	ethernet@6{
+		compatible = "hisilicon,hns-nic";
+		ae-name = "soc0-n4";
+		ae-opts = "6";
+	};
+	ethernet@7{
+		compatible = "hisilicon,hns-nic";
+		ae-name = "soc0-n4";
+		ae-opts = "7";
+	};
+
+
+
+
+};
-- 
1.9.1
