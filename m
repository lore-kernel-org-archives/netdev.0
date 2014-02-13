From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 09/10] Documentation: add Device tree bindings for Broadcom GENET
Date: Thu, 13 Feb 2014 14:53:48 -0800
Message-ID: <1392332029-24669-10-git-send-email-f.fainelli@gmail.com>
References: <1392332029-24669-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree@vger.kernel.org>,
	<cernekee@gmail.com>, <mark.rutland@arm.com>,
	<romieu@fr.zoreil.com>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:29316 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbaBMWzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:55:25 -0500
In-Reply-To: <1392332029-24669-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the Device Tree bindings for the Broadcom GENET Gigabit
Ethernet controller. A bunch of examples are provided to illustrate the
versatile aspect of the hardare.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v3
- improve compatible property description to specify all compatible strings
  supported
- move MDIO bus node to a separate section, to separate from the properties
- detail which exact phy-mode strings are supported and that this refers to
  the ePAPR 'phy-connection-type' modes
- fixed MDIO bus node compatible string to match what is really provided by
  the bootloader and use the same details as for the GENET compatible string
- add address-cells and size-cells required properties for the GENET device
  tree node
- add a better description for the 'fixed-link' property with reference to
  existing binding documentation
- add a reference to the Ethernet PHY device tree binding
- add a description for the interrupts properties
- add a documentation for the optional clocks properties
- removed unused and deprecated device_type properties

Changes in v2:
- rebased against net-next/master

 .../devicetree/bindings/net/broadcom-bcmgenet.txt  | 121 +++++++++++++++++++++
 1 file changed, 121 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt

diff --git a/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
new file mode 100644
index 0000000..afd31f9
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
@@ -0,0 +1,121 @@
+* Broadcom BCM7xxx Ethernet Controller (GENET)
+
+Required properties:
+- compatible: should contain one of "brcm,genet-v1", "brcm,genet-v2",
+  "brcm,genet-v3", "brcm,genet-v4".
+- reg: address and length of the register set for the device
+- interrupts: must be two cells, the first cell is the general purpose
+  interrupt line, while the second cell is the interrupt for the ring
+  RX and TX queues operating in ring mode
+- phy-mode: String, operation mode of the PHY interface. Supported values are
+  "mii", "rgmii", "rgmii-txid", "rev-mii", "moca". Analogous to ePAPR
+  "phy-connection-type" values
+- address-cells: should be 1
+- size-cells: should be 1
+
+Optional properties:
+- clocks: When provided, must be two cells, first one is the main GENET clock
+  and the second cell is the Genet Wake-on-LAN clock.
+
+- phy-handle: A phandle to a phy node defining the PHY address (as the reg
+  property, a single integer), used to describe configurations where a PHY
+  (internal or external) is used.
+
+- fixed-link: When the GENET interface is connected to a MoCA hardware block or
+  when operating in a RGMII to RGMII type of connection, or when the MDIO bus is
+  voluntarily disabled, this property should be used to describe the "fixed link".
+  See Documentation/devicetree/bindings/net/fsl-tsec-phy.txt for information on
+  the property specifics
+
+Required child nodes:
+
+- mdio bus node: this node should always be present regarless of the PHY
+  configuration of the GENET instance
+
+MDIO bus node required properties:
+
+- compatible: should contain one of "brcm,genet-mdio-v1", "brcm,genet-mdio-v2"
+  "brcm,genet-mdio-v3", "brcm,genet-mdio-v4", the version has to match the
+  parent node compatible property (e.g: brcm,genet-v4 pairs with
+  brcm,genet-mdio-v4)
+- reg: address and length relative to the parent node base register address
+- address-cells: address cell for MDIO bus addressing, should be 1
+- size-cells: size of the cells for MDIO bus addressing, should be 0
+
+Ethernet PHY node properties:
+
+See Documentation/devicetree/bindings/net/phy.txt for the list of required and
+optional properties.
+
+Internal Gigabit PHY example:
+
+ethernet@f0b60000 {
+	phy-mode = "internal";
+	phy-handle = <&phy1>;
+	mac-address = [ 00 10 18 36 23 1a ];
+	compatible = "brcm,genet-v4";
+	#address-cells = <0x1>;
+	#size-cells = <0x1>;
+	reg = <0xf0b60000 0xfc4c>;
+	interrupts = <0x0 0x14 0x0>, <0x0 0x15 0x0>;
+
+	mdio@e14 {
+		compatible = "brcm,genet-mdio-v4";
+		#address-cells = <0x1>;
+		#size-cells = <0x0>;
+		reg = <0xe14 0x8>;
+
+		phy1: ethernet-phy@1 {
+			max-speed = <1000>;
+			reg = <0x1>;
+			compatible = "brcm,28nm-gphy", "ethernet-phy-ieee802.3-c22";
+		};
+	};
+};
+
+MoCA interface / MAC to MAC example:
+
+ethernet@f0b80000 {
+	phy-mode = "moca";
+	fixed-link = <1 0 1000 0 0>;
+	mac-address = [ 00 10 18 36 24 1a ];
+	compatible = "brcm,genet-v4";
+	#address-cells = <0x1>;
+	#size-cells = <0x1>;
+	reg = <0xf0b80000 0xfc4c>;
+	interrupts = <0x0 0x16 0x0>, <0x0 0x17 0x0>;
+
+	mdio@e14 {
+		compatible = "brcm,genet-mdio-v4";
+		#address-cells = <0x1>;
+		#size-cells = <0x0>;
+		reg = <0xe14 0x8>;
+	};
+};
+
+
+External MDIO-connected Gigabit PHY/switch:
+
+ethernet@f0ba0000 {
+	phy-mode = "rgmii";
+	phy-handle = <&phy0>;
+	mac-address = [ 00 10 18 36 26 1a ];
+	compatible = "brcm,genet-v4";
+	#address-cells = <0x1>;
+	#size-cells = <0x1>;
+	reg = <0xf0ba0000 0xfc4c>;
+	interrupts = <0x0 0x18 0x0>, <0x0 0x19 0x0>;
+
+	mdio@0e14 {
+		compatible = "brcm,genet-mdio-v4";
+		#address-cells = <0x1>;
+		#size-cells = <0x0>;
+		reg = <0xe14 0x8>;
+
+		phy0: ethernet-phy@0 {
+			max-speed = <1000>;
+			reg = <0x0>;
+			compatible = "brcm,bcm53125", "ethernet-phy-ieee802.3-c22";
+		};
+	};
+};
-- 
1.8.3.2
