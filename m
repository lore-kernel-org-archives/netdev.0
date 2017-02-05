From: Christian Lamparter <chunkeey@googlemail.com>
Subject: [RFC 1/2] dt: emac: document device-tree based phy discovery and setup
Date: Sun,  5 Feb 2017 23:25:05 +0100
Message-ID: <f57a340f615991ed2771d8af4b1a908dec436a5e.1486333475.git.chunkeey@googlemail.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Ivan Mikhaylov <ivan@de.ibm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Rob Herring <robh+dt@kernel.org>
To: netdev@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34625 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750851AbdBEW1T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 17:27:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds documentation for a new "phy-handler" property
and "mdio" sub-node. These allows the enumeration of PHYs which
are supported by the phy library under drivers/net/phy.

The EMAC ethernet controller in IBM and AMCC 4xx chips is
currently stuck with a few privately defined phy
implementations. It has no support for PHYs which
are supported by the generic phylib.

Signed-off-by: Christian Lamparter <chunkeey@googlemail.com>
---
 .../devicetree/bindings/powerpc/4xx/emac.txt       | 60 +++++++++++++++++++++-
 1 file changed, 58 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/powerpc/4xx/emac.txt b/Documentation/devicetree/bindings/powerpc/4xx/emac.txt
index 712baf6c3e24..0572d053c35a 100644
--- a/Documentation/devicetree/bindings/powerpc/4xx/emac.txt
+++ b/Documentation/devicetree/bindings/powerpc/4xx/emac.txt
@@ -71,6 +71,8 @@
 			  For Axon it can be absent, though my current driver
 			  doesn't handle phy-address yet so for now, keep
 			  0x00ffffff in it.
+    - phy-handle	: See net/ethernet.txt file; used to describe
+			  configurations where a external PHY is used.
     - rx-fifo-size-gige : 1 cell, Rx fifo size in bytes for 1000 Mb/sec
 			  operations (if absent the value is the same as
 			  rx-fifo-size).  For Axon, either absent or 2048.
@@ -82,7 +84,18 @@
     - tah-channel       : 1 cell, optional. If appropriate, channel used on the
 			  TAH engine.
 
-    Example:
+    - mdio subnode	: When the EMAC has a phy connected to its local
+			  mdio, which us supported by the kernel's network
+			  PHY library in drivers/net/phy, there must be device
+			  tree subnode with the following required properties:
+				- #address-cells: Must be <1>.
+				- #size-cells: Must be <0>.
+
+			  For each phy on the mdio bus, there must be a node
+			  with the following fields:
+				- reg: phy id used to communicate to phy.
+				- device_type: Must be "ethernet-phy".
+    Examples:
 
 	EMAC0: ethernet@40000800 {
 		device_type = "network";
@@ -104,6 +117,50 @@
 		zmii-channel = <0>;
 	};
 
+	EMAC1: ethernet@ef600c00 {
+		device_type = "network";
+		compatible = "ibm,emac-apm821xx", "ibm,emac4sync";
+		interrupt-parent = <&EMAC1>;
+		interrupts = <0 1>;
+		#interrupt-cells = <1>;
+		#address-cells = <0>;
+		#size-cells = <0>;
+		interrupt-map = <0 &UIC2 0x10 IRQ_TYPE_LEVEL_HIGH /* Status */
+				 1 &UIC2 0x14 IRQ_TYPE_LEVEL_HIGH /* Wake */>;
+		reg = <0xef600c00 0x000000c4>;
+		local-mac-address = [000000000000]; /* Filled in by U-Boot */
+		mal-device = <&MAL0>;
+		mal-tx-channel = <0>;
+		mal-rx-channel = <0>;
+		cell-index = <0>;
+		max-frame-size = <9000>;
+		rx-fifo-size = <16384>;
+		tx-fifo-size = <2048>;
+		fifo-entry-size = <10>;
+		phy-mode = "rgmii";
+		phy-map = <0x00000000>;
+		phy-handle = <&phy0>;
+		rgmii-device = <&RGMII0>;
+		rgmii-channel = <0>;
+		tah-device = <&TAH0>;
+		tah-channel = <0>;
+		has-inverted-stacr-oc;
+		has-new-stacr-staopc;
+
+	        mdio {
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			phy0: ethernet-phy@0 {
+				device_type = "ethernet-phy";
+				reg = <0>;
+
+				qca,ar8327-initvals = <
+					0x0010 0x40000000>;
+		};
+	};
+
+
       ii) McMAL node
 
     Required properties:
@@ -145,4 +202,3 @@
     - revision           : as provided by the RGMII new version register if
 			   available.
 			   For Axon: 0x0000012a
-
-- 
2.11.0
