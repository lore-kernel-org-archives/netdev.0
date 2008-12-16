From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.29 03/14] gianfar: Convert gianfar to an of_platform_driver
Date: Tue, 16 Dec 2008 17:20:56 -0600
Message-ID: <1229469667-25002-4-git-send-email-afleming@freescale.com>
References: <1229469667-25002-1-git-send-email-afleming@freescale.com>
 <1229469667-25002-2-git-send-email-afleming@freescale.com>
 <1229469667-25002-3-git-send-email-afleming@freescale.com>
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org,
	Andy Fleming <afleming@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:39723 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752833AbYLPXVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:21:24 -0500
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id mBGNL9Eh013522
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 16:21:09 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id mBGNL82l006116
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 17:21:08 -0600 (CST)
In-Reply-To: <1229469667-25002-3-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Does the same for the accompanying MDIO driver, and then modifies the TBI
configuration method.  The old way used fields in einfo, which no longer
exists.  The new way is to create an MDIO device-tree node for each instance
of gianfar, and create a tbi-handle property to associate ethernet controllers
with the TBI PHYs they are connected to.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 Documentation/powerpc/dts-bindings/fsl/tsec.txt |   12 +-
 arch/powerpc/boot/dts/asp834x-redboot.dts       |   20 ++
 arch/powerpc/boot/dts/ksi8560.dts               |   20 ++
 arch/powerpc/boot/dts/mpc8313erdb.dts           |   20 ++
 arch/powerpc/boot/dts/mpc8315erdb.dts           |   19 ++
 arch/powerpc/boot/dts/mpc8349emitx.dts          |   18 ++
 arch/powerpc/boot/dts/mpc8349emitxgp.dts        |    5 +
 arch/powerpc/boot/dts/mpc834x_mds.dts           |   19 ++
 arch/powerpc/boot/dts/mpc8377_mds.dts           |   19 ++
 arch/powerpc/boot/dts/mpc8377_rdb.dts           |   19 ++
 arch/powerpc/boot/dts/mpc8378_mds.dts           |   19 ++
 arch/powerpc/boot/dts/mpc8378_rdb.dts           |   17 ++
 arch/powerpc/boot/dts/mpc8379_mds.dts           |   18 ++
 arch/powerpc/boot/dts/mpc8379_rdb.dts           |   18 ++
 arch/powerpc/boot/dts/mpc8536ds.dts             |   18 ++
 arch/powerpc/boot/dts/mpc8540ads.dts            |   31 +++
 arch/powerpc/boot/dts/mpc8541cds.dts            |   18 ++
 arch/powerpc/boot/dts/mpc8544ds.dts             |   20 ++
 arch/powerpc/boot/dts/mpc8548cds.dts            |   44 +++
 arch/powerpc/boot/dts/mpc8555cds.dts            |   18 ++
 arch/powerpc/boot/dts/mpc8560ads.dts            |   18 ++
 arch/powerpc/boot/dts/mpc8568mds.dts            |   18 ++
 arch/powerpc/boot/dts/mpc8572ds.dts             |   45 ++++
 arch/powerpc/boot/dts/mpc8641_hpcn.dts          |   45 ++++
 arch/powerpc/boot/dts/sbc8349.dts               |   18 ++
 arch/powerpc/boot/dts/sbc8548.dts               |   18 ++
 arch/powerpc/boot/dts/sbc8560.dts               |   18 ++
 arch/powerpc/boot/dts/sbc8641d.dts              |   44 +++
 arch/powerpc/boot/dts/stx_gp3_8560.dts          |   18 ++
 arch/powerpc/boot/dts/tqm8540.dts               |   28 ++
 arch/powerpc/boot/dts/tqm8541.dts               |   18 ++
 arch/powerpc/boot/dts/tqm8548-bigflash.dts      |   44 +++
 arch/powerpc/boot/dts/tqm8548.dts               |   44 +++
 arch/powerpc/boot/dts/tqm8555.dts               |   18 ++
 arch/powerpc/boot/dts/tqm8560.dts               |   18 ++
 arch/powerpc/sysdev/fsl_soc.c                   |  241 ++---------------
 drivers/net/gianfar.c                           |  321 +++++++++++++++--------
 drivers/net/gianfar.h                           |   21 ++-
 drivers/net/gianfar_ethtool.c                   |   22 +-
 drivers/net/gianfar_mii.c                       |  212 ++++++++++-----
 drivers/net/gianfar_mii.h                       |    2 +
 include/linux/fsl_devices.h                     |   18 +--
 42 files changed, 1217 insertions(+), 424 deletions(-)

diff --git a/Documentation/powerpc/dts-bindings/fsl/tsec.txt b/Documentation/powerpc/dts-bindings/fsl/tsec.txt
index cf55fa4..7fa4b27 100644
--- a/Documentation/powerpc/dts-bindings/fsl/tsec.txt
+++ b/Documentation/powerpc/dts-bindings/fsl/tsec.txt
@@ -2,8 +2,8 @@
 
 The MDIO is a bus to which the PHY devices are connected.  For each
 device that exists on this bus, a child node should be created.  See
-the definition of the PHY node below for an example of how to define
-a PHY.
+the definition of the PHY node in booting-without-of.txt for an example
+of how to define a PHY.
 
 Required properties:
   - reg : Offset and length of the register set for the device
@@ -21,6 +21,14 @@ Example:
 		};
 	};
 
+* TBI Internal MDIO bus
+
+As of this writing, every tsec is associated with an internal TBI PHY.
+This PHY is accessed through the local MDIO bus.  These buses are defined
+similarly to the mdio buses, except they are compatible with "fsl,gianfar-tbi".
+The TBI PHYs underneath them are similar to normal PHYs, but the reg property
+is considered instructive, rather than descriptive.  The reg property should
+be chosen so it doesn't interfere with other PHYs on the bus.
 
 * Gianfar-compatible ethernet nodes
 
diff --git a/arch/powerpc/boot/dts/asp834x-redboot.dts b/arch/powerpc/boot/dts/asp834x-redboot.dts
index 6235fca..524af7e 100644
--- a/arch/powerpc/boot/dts/asp834x-redboot.dts
+++ b/arch/powerpc/boot/dts/asp834x-redboot.dts
@@ -199,8 +199,26 @@
 				reg = <0x2>;
 				device_type = "ethernet-phy";
 			};
+
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+
 		enet0: ethernet@24000 {
 			cell-index = <0>;
 			device_type = "network";
@@ -210,6 +228,7 @@
 			local-mac-address = [ 00 08 e5 11 32 33 ];
 			interrupts = <32 0x8 33 0x8 34 0x8>;
 			interrupt-parent = <&ipic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy0>;
 			linux,network-index = <0>;
 		};
@@ -223,6 +242,7 @@
 			local-mac-address = [ 00 08 e5 11 32 34 ];
 			interrupts = <35 0x8 36 0x8 37 0x8>;
 			interrupt-parent = <&ipic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy1>;
 			linux,network-index = <1>;
 		};
diff --git a/arch/powerpc/boot/dts/ksi8560.dts b/arch/powerpc/boot/dts/ksi8560.dts
index 4973758..3bfff47 100644
--- a/arch/powerpc/boot/dts/ksi8560.dts
+++ b/arch/powerpc/boot/dts/ksi8560.dts
@@ -141,8 +141,26 @@
 				reg = <0x2>;
 				device_type = "ethernet-phy";
 			};
+
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+
 		enet0: ethernet@24000 {
 			device_type = "network";
 			model = "TSEC";
@@ -152,6 +170,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <0x1d 0x2 0x1e 0x2 0x22 0x2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&PHY1>;
 		};
 
@@ -164,6 +183,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <0x23 0x2 0x24 0x2 0x28 0x2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&PHY2>;
 		};
 
diff --git a/arch/powerpc/boot/dts/mpc8313erdb.dts b/arch/powerpc/boot/dts/mpc8313erdb.dts
index 5030317..d4df8b6 100644
--- a/arch/powerpc/boot/dts/mpc8313erdb.dts
+++ b/arch/powerpc/boot/dts/mpc8313erdb.dts
@@ -190,6 +190,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <37 0x8 36 0x8 35 0x8>;
 			interrupt-parent = <&ipic>;
+			tbi-handle = < &tbi0 >;
 			phy-handle = < &phy1 >;
 			fsl,magic-packet;
 
@@ -210,6 +211,10 @@
 					reg = <0x4>;
 					device_type = "ethernet-phy";
 				};
+				tbi0: tbi-phy@11 {
+					reg = <0x11>;
+					device_type = "tbi-phy";
+				};
 			};
 		};
 
@@ -222,9 +227,24 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <34 0x8 33 0x8 32 0x8>;
 			interrupt-parent = <&ipic>;
+			tbi-handle = < &tbi1 >;
 			phy-handle = < &phy4 >;
 			sleep = <&pmc 0x10000000>;
 			fsl,magic-packet;
+
+			mdio@25520 {
+				#address-cells = <1>;
+				#size-cells = <0>;
+				compatible = "fsl,gianfar-tbi";
+				reg = <0x25520 0x20>;
+
+				tbi1: tbi-phy@11 {
+					reg = <0x11>;
+					device_type = "tbi-phy";
+				};
+			};
+
+
 		};
 
 		serial0: serial@4500 {
diff --git a/arch/powerpc/boot/dts/mpc8315erdb.dts b/arch/powerpc/boot/dts/mpc8315erdb.dts
index 6b85067..d2cdd47 100644
--- a/arch/powerpc/boot/dts/mpc8315erdb.dts
+++ b/arch/powerpc/boot/dts/mpc8315erdb.dts
@@ -206,8 +206,25 @@
 				reg = <0x1>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
+
 		enet0: ethernet@24000 {
 			cell-index = <0>;
 			device_type = "network";
@@ -217,6 +234,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <32 0x8 33 0x8 34 0x8>;
 			interrupt-parent = <&ipic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = < &phy0 >;
 		};
 
@@ -229,6 +247,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <35 0x8 36 0x8 37 0x8>;
 			interrupt-parent = <&ipic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = < &phy1 >;
 		};
 
diff --git a/arch/powerpc/boot/dts/mpc8349emitx.dts b/arch/powerpc/boot/dts/mpc8349emitx.dts
index 2c9d54a..b7bfa6e 100644
--- a/arch/powerpc/boot/dts/mpc8349emitx.dts
+++ b/arch/powerpc/boot/dts/mpc8349emitx.dts
@@ -184,6 +184,22 @@
 				reg = <0x1c>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
@@ -195,6 +211,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <32 0x8 33 0x8 34 0x8>;
 			interrupt-parent = <&ipic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy1c>;
 			linux,network-index = <0>;
 		};
@@ -211,6 +228,7 @@
 			/* Vitesse 7385 isn't on the MDIO bus */
 			fixed-link = <1 1 1000 0 0>;
 			linux,network-index = <1>;
+			tbi-handle = <&tbi1>;
 		};
 
 		serial0: serial@4500 {
diff --git a/arch/powerpc/boot/dts/mpc8349emitxgp.dts b/arch/powerpc/boot/dts/mpc8349emitxgp.dts
index fa40647..3e918af 100644
--- a/arch/powerpc/boot/dts/mpc8349emitxgp.dts
+++ b/arch/powerpc/boot/dts/mpc8349emitxgp.dts
@@ -163,6 +163,10 @@
 				reg = <0x1c>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
@@ -174,6 +178,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <32 0x8 33 0x8 34 0x8>;
 			interrupt-parent = <&ipic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy1c>;
 			linux,network-index = <0>;
 		};
diff --git a/arch/powerpc/boot/dts/mpc834x_mds.dts b/arch/powerpc/boot/dts/mpc834x_mds.dts
index c986c54..d9adba0 100644
--- a/arch/powerpc/boot/dts/mpc834x_mds.dts
+++ b/arch/powerpc/boot/dts/mpc834x_mds.dts
@@ -185,8 +185,25 @@
 				reg = <0x1>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
+
 		enet0: ethernet@24000 {
 			cell-index = <0>;
 			device_type = "network";
@@ -196,6 +213,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <32 0x8 33 0x8 34 0x8>;
 			interrupt-parent = <&ipic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy0>;
 			linux,network-index = <0>;
 		};
@@ -209,6 +227,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <35 0x8 36 0x8 37 0x8>;
 			interrupt-parent = <&ipic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy1>;
 			linux,network-index = <1>;
 		};
diff --git a/arch/powerpc/boot/dts/mpc8377_mds.dts b/arch/powerpc/boot/dts/mpc8377_mds.dts
index 0484561..1d14d70 100644
--- a/arch/powerpc/boot/dts/mpc8377_mds.dts
+++ b/arch/powerpc/boot/dts/mpc8377_mds.dts
@@ -193,8 +193,25 @@
 				reg = <0x3>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
+
 		enet0: ethernet@24000 {
 			cell-index = <0>;
 			device_type = "network";
@@ -205,6 +222,7 @@
 			interrupts = <32 0x8 33 0x8 34 0x8>;
 			phy-connection-type = "mii";
 			interrupt-parent = <&ipic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy2>;
 		};
 
@@ -218,6 +236,7 @@
 			interrupts = <35 0x8 36 0x8 37 0x8>;
 			phy-connection-type = "mii";
 			interrupt-parent = <&ipic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy3>;
 		};
 
diff --git a/arch/powerpc/boot/dts/mpc8377_rdb.dts b/arch/powerpc/boot/dts/mpc8377_rdb.dts
index 435ef3d..31f348f 100644
--- a/arch/powerpc/boot/dts/mpc8377_rdb.dts
+++ b/arch/powerpc/boot/dts/mpc8377_rdb.dts
@@ -211,8 +211,25 @@
 				reg = <0x2>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
+
 		enet0: ethernet@24000 {
 			cell-index = <0>;
 			device_type = "network";
@@ -223,6 +240,7 @@
 			interrupts = <32 0x8 33 0x8 34 0x8>;
 			phy-connection-type = "mii";
 			interrupt-parent = <&ipic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy2>;
 		};
 
@@ -237,6 +255,7 @@
 			phy-connection-type = "mii";
 			interrupt-parent = <&ipic>;
 			fixed-link = <1 1 1000 0 0>;
+			tbi-handle = <&tbi1>;
 		};
 
 		serial0: serial@4500 {
diff --git a/arch/powerpc/boot/dts/mpc8378_mds.dts b/arch/powerpc/boot/dts/mpc8378_mds.dts
index 67a08d2..b85fc02 100644
--- a/arch/powerpc/boot/dts/mpc8378_mds.dts
+++ b/arch/powerpc/boot/dts/mpc8378_mds.dts
@@ -232,8 +232,25 @@
 				reg = <0x3>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
+
 		enet0: ethernet@24000 {
 			cell-index = <0>;
 			device_type = "network";
@@ -244,6 +261,7 @@
 			interrupts = <32 0x8 33 0x8 34 0x8>;
 			phy-connection-type = "mii";
 			interrupt-parent = <&ipic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy2>;
 		};
 
@@ -257,6 +275,7 @@
 			interrupts = <35 0x8 36 0x8 37 0x8>;
 			phy-connection-type = "mii";
 			interrupt-parent = <&ipic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy3>;
 		};
 
diff --git a/arch/powerpc/boot/dts/mpc8378_rdb.dts b/arch/powerpc/boot/dts/mpc8378_rdb.dts
index b11e68f..7a2bad0 100644
--- a/arch/powerpc/boot/dts/mpc8378_rdb.dts
+++ b/arch/powerpc/boot/dts/mpc8378_rdb.dts
@@ -211,8 +211,25 @@
 				reg = <0x2>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
+
 		enet0: ethernet@24000 {
 			cell-index = <0>;
 			device_type = "network";
diff --git a/arch/powerpc/boot/dts/mpc8379_mds.dts b/arch/powerpc/boot/dts/mpc8379_mds.dts
index 323370a..acf06c4 100644
--- a/arch/powerpc/boot/dts/mpc8379_mds.dts
+++ b/arch/powerpc/boot/dts/mpc8379_mds.dts
@@ -232,6 +232,22 @@
 				reg = <0x3>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
@@ -244,6 +260,7 @@
 			interrupts = <32 0x8 33 0x8 34 0x8>;
 			phy-connection-type = "mii";
 			interrupt-parent = <&ipic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy2>;
 		};
 
@@ -257,6 +274,7 @@
 			interrupts = <35 0x8 36 0x8 37 0x8>;
 			phy-connection-type = "mii";
 			interrupt-parent = <&ipic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy3>;
 		};
 
diff --git a/arch/powerpc/boot/dts/mpc8379_rdb.dts b/arch/powerpc/boot/dts/mpc8379_rdb.dts
index 337af6e..e067616 100644
--- a/arch/powerpc/boot/dts/mpc8379_rdb.dts
+++ b/arch/powerpc/boot/dts/mpc8379_rdb.dts
@@ -211,6 +211,22 @@
 				reg = <0x2>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
@@ -223,6 +239,7 @@
 			interrupts = <32 0x8 33 0x8 34 0x8>;
 			phy-connection-type = "mii";
 			interrupt-parent = <&ipic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy2>;
 		};
 
@@ -237,6 +254,7 @@
 			phy-connection-type = "mii";
 			interrupt-parent = <&ipic>;
 			fixed-link = <1 1 1000 0 0>;
+			tbi-handle = <&tbi1>;
 		};
 
 		serial0: serial@4500 {
diff --git a/arch/powerpc/boot/dts/mpc8536ds.dts b/arch/powerpc/boot/dts/mpc8536ds.dts
index 35db1e5..3c905df 100644
--- a/arch/powerpc/boot/dts/mpc8536ds.dts
+++ b/arch/powerpc/boot/dts/mpc8536ds.dts
@@ -155,6 +155,22 @@
 				reg = <1>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@26520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x26520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		usb@22000 {
@@ -186,6 +202,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <29 2 30 2 34 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy1>;
 			phy-connection-type = "rgmii-id";
 		};
@@ -199,6 +216,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <31 2 32 2 33 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy0>;
 			phy-connection-type = "rgmii-id";
 		};
diff --git a/arch/powerpc/boot/dts/mpc8540ads.dts b/arch/powerpc/boot/dts/mpc8540ads.dts
index 9568bfa..79570ff 100644
--- a/arch/powerpc/boot/dts/mpc8540ads.dts
+++ b/arch/powerpc/boot/dts/mpc8540ads.dts
@@ -150,6 +150,34 @@
 				reg = <0x3>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@26520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x26520 0x20>;
+
+			tbi2: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
@@ -161,6 +189,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <29 2 30 2 34 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy0>;
 		};
 
@@ -173,6 +202,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <35 2 36 2 40 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy1>;
 		};
 
@@ -185,6 +215,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <41 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi2>;
 			phy-handle = <&phy3>;
 		};
 
diff --git a/arch/powerpc/boot/dts/mpc8541cds.dts b/arch/powerpc/boot/dts/mpc8541cds.dts
index 6480f4f..221036a 100644
--- a/arch/powerpc/boot/dts/mpc8541cds.dts
+++ b/arch/powerpc/boot/dts/mpc8541cds.dts
@@ -144,6 +144,22 @@
 				reg = <0x1>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
@@ -155,6 +171,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <29 2 30 2 34 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy0>;
 		};
 
@@ -167,6 +184,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <35 2 36 2 40 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy1>;
 		};
 
diff --git a/arch/powerpc/boot/dts/mpc8544ds.dts b/arch/powerpc/boot/dts/mpc8544ds.dts
index f1fb207..b9da421 100644
--- a/arch/powerpc/boot/dts/mpc8544ds.dts
+++ b/arch/powerpc/boot/dts/mpc8544ds.dts
@@ -116,8 +116,26 @@
 				reg = <0x1>;
 				device_type = "ethernet-phy";
 			};
+
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
+		mdio@26520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x26520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+
 		dma@21300 {
 			#address-cells = <1>;
 			#size-cells = <1>;
@@ -169,6 +187,7 @@
 			interrupts = <29 2 30 2 34 2>;
 			interrupt-parent = <&mpic>;
 			phy-handle = <&phy0>;
+			tbi-handle = <&tbi0>;
 			phy-connection-type = "rgmii-id";
 		};
 
@@ -182,6 +201,7 @@
 			interrupts = <31 2 32 2 33 2>;
 			interrupt-parent = <&mpic>;
 			phy-handle = <&phy1>;
+			tbi-handle = <&tbi1>;
 			phy-connection-type = "rgmii-id";
 		};
 
diff --git a/arch/powerpc/boot/dts/mpc8548cds.dts b/arch/powerpc/boot/dts/mpc8548cds.dts
index 431b496..df774a7 100644
--- a/arch/powerpc/boot/dts/mpc8548cds.dts
+++ b/arch/powerpc/boot/dts/mpc8548cds.dts
@@ -172,6 +172,46 @@
 				reg = <0x3>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@26520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x26520 0x20>;
+
+			tbi2: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@27520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x27520 0x20>;
+
+			tbi3: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
@@ -183,6 +223,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <29 2 30 2 34 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy0>;
 		};
 
@@ -195,6 +236,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <35 2 36 2 40 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy1>;
 		};
 
@@ -208,6 +250,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <31 2 32 2 33 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi2>;
 			phy-handle = <&phy2>;
 		};
 
@@ -220,6 +263,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <37 2 38 2 39 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi3>;
 			phy-handle = <&phy3>;
 		};
  */
diff --git a/arch/powerpc/boot/dts/mpc8555cds.dts b/arch/powerpc/boot/dts/mpc8555cds.dts
index d833a5c..053b01e 100644
--- a/arch/powerpc/boot/dts/mpc8555cds.dts
+++ b/arch/powerpc/boot/dts/mpc8555cds.dts
@@ -144,6 +144,22 @@
 				reg = <0x1>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
@@ -155,6 +171,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <29 2 30 2 34 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy0>;
 		};
 
@@ -167,6 +184,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <35 2 36 2 40 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy1>;
 		};
 
diff --git a/arch/powerpc/boot/dts/mpc8560ads.dts b/arch/powerpc/boot/dts/mpc8560ads.dts
index 4d1f2f2..11b1bcb 100644
--- a/arch/powerpc/boot/dts/mpc8560ads.dts
+++ b/arch/powerpc/boot/dts/mpc8560ads.dts
@@ -145,6 +145,22 @@
 				reg = <0x3>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
@@ -156,6 +172,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <29 2 30 2 34 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy0>;
 		};
 
@@ -168,6 +185,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <35 2 36 2 40 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy1>;
 		};
 
diff --git a/arch/powerpc/boot/dts/mpc8568mds.dts b/arch/powerpc/boot/dts/mpc8568mds.dts
index c80158f..1955bd9 100644
--- a/arch/powerpc/boot/dts/mpc8568mds.dts
+++ b/arch/powerpc/boot/dts/mpc8568mds.dts
@@ -179,6 +179,22 @@
 				reg = <0x3>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
@@ -190,6 +206,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
  			interrupts = <29 2 30 2 34 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy2>;
 		};
 
@@ -202,6 +219,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
  			interrupts = <35 2 36 2 40 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy3>;
 		};
 
diff --git a/arch/powerpc/boot/dts/mpc8572ds.dts b/arch/powerpc/boot/dts/mpc8572ds.dts
index cadd465..60ea9ea 100644
--- a/arch/powerpc/boot/dts/mpc8572ds.dts
+++ b/arch/powerpc/boot/dts/mpc8572ds.dts
@@ -225,6 +225,47 @@
 				interrupts = <10 1>;
 				reg = <0x3>;
 			};
+
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@26520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x26520 0x20>;
+
+			tbi2: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@27520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x27520 0x20>;
+
+			tbi3: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
@@ -236,6 +277,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <29 2 30 2 34 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy0>;
 			phy-connection-type = "rgmii-id";
 		};
@@ -249,6 +291,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <35 2 36 2 40 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy1>;
 			phy-connection-type = "rgmii-id";
 		};
@@ -262,6 +305,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <31 2 32 2 33 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi2>;
 			phy-handle = <&phy2>;
 			phy-connection-type = "rgmii-id";
 		};
@@ -275,6 +319,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <37 2 38 2 39 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi3>;
 			phy-handle = <&phy3>;
 			phy-connection-type = "rgmii-id";
 		};
diff --git a/arch/powerpc/boot/dts/mpc8641_hpcn.dts b/arch/powerpc/boot/dts/mpc8641_hpcn.dts
index d665e76..35d5e24 100644
--- a/arch/powerpc/boot/dts/mpc8641_hpcn.dts
+++ b/arch/powerpc/boot/dts/mpc8641_hpcn.dts
@@ -205,8 +205,49 @@
 				reg = <3>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@26520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x26520 0x20>;
+
+			tbi2: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@27520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x27520 0x20>;
+
+			tbi3: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
+
 		enet0: ethernet@24000 {
 			cell-index = <0>;
 			device_type = "network";
@@ -216,6 +257,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <29 2 30  2 34 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy0>;
 			phy-connection-type = "rgmii-id";
 		};
@@ -229,6 +271,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <35 2 36 2 40 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy1>;
 			phy-connection-type = "rgmii-id";
 		};
@@ -242,6 +285,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <31 2 32 2 33 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi2>;
 			phy-handle = <&phy2>;
 			phy-connection-type = "rgmii-id";
 		};
@@ -255,6 +299,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <37 2 38 2 39 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi3>;
 			phy-handle = <&phy3>;
 			phy-connection-type = "rgmii-id";
 		};
diff --git a/arch/powerpc/boot/dts/sbc8349.dts b/arch/powerpc/boot/dts/sbc8349.dts
index 0f941f3..8d365a5 100644
--- a/arch/powerpc/boot/dts/sbc8349.dts
+++ b/arch/powerpc/boot/dts/sbc8349.dts
@@ -177,6 +177,22 @@
 				reg = <0x1a>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
@@ -188,6 +204,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <32 0x8 33 0x8 34 0x8>;
 			interrupt-parent = <&ipic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy0>;
 			linux,network-index = <0>;
 		};
@@ -201,6 +218,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <35 0x8 36 0x8 37 0x8>;
 			interrupt-parent = <&ipic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy1>;
 			linux,network-index = <1>;
 		};
diff --git a/arch/powerpc/boot/dts/sbc8548.dts b/arch/powerpc/boot/dts/sbc8548.dts
index 333552b..2baf4a5 100644
--- a/arch/powerpc/boot/dts/sbc8548.dts
+++ b/arch/powerpc/boot/dts/sbc8548.dts
@@ -252,6 +252,22 @@
 				reg = <0x1a>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
@@ -263,6 +279,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <0x1d 0x2 0x1e 0x2 0x22 0x2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy0>;
 		};
 
@@ -275,6 +292,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <0x23 0x2 0x24 0x2 0x28 0x2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy1>;
 		};
 
diff --git a/arch/powerpc/boot/dts/sbc8560.dts b/arch/powerpc/boot/dts/sbc8560.dts
index db3632e..01542f7 100644
--- a/arch/powerpc/boot/dts/sbc8560.dts
+++ b/arch/powerpc/boot/dts/sbc8560.dts
@@ -168,6 +168,22 @@
 				reg = <0x1c>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
@@ -179,6 +195,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <0x1d 0x2 0x1e 0x2 0x22 0x2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy0>;
 		};
 
@@ -191,6 +208,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <0x23 0x2 0x24 0x2 0x28 0x2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy1>;
 		};
 
diff --git a/arch/powerpc/boot/dts/sbc8641d.dts b/arch/powerpc/boot/dts/sbc8641d.dts
index 9652456..36db981 100644
--- a/arch/powerpc/boot/dts/sbc8641d.dts
+++ b/arch/powerpc/boot/dts/sbc8641d.dts
@@ -222,6 +222,46 @@
 				reg = <2>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@26520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x26520 0x20>;
+
+			tbi2: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@27520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x27520 0x20>;
+
+			tbi3: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
@@ -233,6 +273,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <29 2 30  2 34 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy0>;
 			phy-connection-type = "rgmii-id";
 		};
@@ -246,6 +287,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <35 2 36 2 40 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy1>;
 			phy-connection-type = "rgmii-id";
 		};
@@ -259,6 +301,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <31 2 32 2 33 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi2>;
 			phy-handle = <&phy2>;
 			phy-connection-type = "rgmii-id";
 		};
@@ -272,6 +315,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <37 2 38 2 39 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi3>;
 			phy-handle = <&phy3>;
 			phy-connection-type = "rgmii-id";
 		};
diff --git a/arch/powerpc/boot/dts/stx_gp3_8560.dts b/arch/powerpc/boot/dts/stx_gp3_8560.dts
index fcd1db6..fff33fe 100644
--- a/arch/powerpc/boot/dts/stx_gp3_8560.dts
+++ b/arch/powerpc/boot/dts/stx_gp3_8560.dts
@@ -142,6 +142,22 @@
 				reg = <4>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
@@ -153,6 +169,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <29 2 30 2 34 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy2>;
 		};
 
@@ -165,6 +182,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <35 2 36 2 40 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy4>;
 		};
 
diff --git a/arch/powerpc/boot/dts/tqm8540.dts b/arch/powerpc/boot/dts/tqm8540.dts
index e1d260b..a693f01 100644
--- a/arch/powerpc/boot/dts/tqm8540.dts
+++ b/arch/powerpc/boot/dts/tqm8540.dts
@@ -155,6 +155,34 @@
 				reg = <3>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@26520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x26520 0x20>;
+
+			tbi2: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
diff --git a/arch/powerpc/boot/dts/tqm8541.dts b/arch/powerpc/boot/dts/tqm8541.dts
index d76441e..9e3f5f0 100644
--- a/arch/powerpc/boot/dts/tqm8541.dts
+++ b/arch/powerpc/boot/dts/tqm8541.dts
@@ -154,6 +154,22 @@
 				reg = <3>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
@@ -165,6 +181,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <29 2 30 2 34 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy2>;
 		};
 
@@ -177,6 +194,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <35 2 36 2 40 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy1>;
 		};
 
diff --git a/arch/powerpc/boot/dts/tqm8548-bigflash.dts b/arch/powerpc/boot/dts/tqm8548-bigflash.dts
index 4199e89..15086eb 100644
--- a/arch/powerpc/boot/dts/tqm8548-bigflash.dts
+++ b/arch/powerpc/boot/dts/tqm8548-bigflash.dts
@@ -179,6 +179,46 @@
 				reg = <5>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@26520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x26520 0x20>;
+
+			tbi2: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@27520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x27520 0x20>;
+
+			tbi3: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
@@ -190,6 +230,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <29 2 30 2 34 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy2>;
 		};
 
@@ -202,6 +243,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <35 2 36 2 40 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy1>;
 		};
 
@@ -214,6 +256,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <31 2 32 2 33 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi2>;
 			phy-handle = <&phy3>;
 		};
 
@@ -226,6 +269,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <37 2 38 2 39 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi3>;
 			phy-handle = <&phy4>;
 		};
 
diff --git a/arch/powerpc/boot/dts/tqm8548.dts b/arch/powerpc/boot/dts/tqm8548.dts
index 58ee418..b7b65f5 100644
--- a/arch/powerpc/boot/dts/tqm8548.dts
+++ b/arch/powerpc/boot/dts/tqm8548.dts
@@ -179,6 +179,46 @@
 				reg = <5>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@26520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x26520 0x20>;
+
+			tbi2: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@27520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x27520 0x20>;
+
+			tbi3: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
@@ -190,6 +230,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <29 2 30 2 34 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy2>;
 		};
 
@@ -202,6 +243,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <35 2 36 2 40 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy1>;
 		};
 
@@ -214,6 +256,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <31 2 32 2 33 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi2>;
 			phy-handle = <&phy3>;
 		};
 
@@ -226,6 +269,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <37 2 38 2 39 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi3>;
 			phy-handle = <&phy4>;
 		};
 
diff --git a/arch/powerpc/boot/dts/tqm8555.dts b/arch/powerpc/boot/dts/tqm8555.dts
index 6f7ea59..cf92b4e 100644
--- a/arch/powerpc/boot/dts/tqm8555.dts
+++ b/arch/powerpc/boot/dts/tqm8555.dts
@@ -154,6 +154,22 @@
 				reg = <3>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
@@ -165,6 +181,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <29 2 30 2 34 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy2>;
 		};
 
@@ -177,6 +194,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <35 2 36 2 40 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy1>;
 		};
 
diff --git a/arch/powerpc/boot/dts/tqm8560.dts b/arch/powerpc/boot/dts/tqm8560.dts
index 3fe3520..9e1ab2d 100644
--- a/arch/powerpc/boot/dts/tqm8560.dts
+++ b/arch/powerpc/boot/dts/tqm8560.dts
@@ -156,6 +156,22 @@
 				reg = <3>;
 				device_type = "ethernet-phy";
 			};
+			tbi0: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
+		};
+
+		mdio@25520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "fsl,gianfar-tbi";
+			reg = <0x25520 0x20>;
+
+			tbi1: tbi-phy@11 {
+				reg = <0x11>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet0: ethernet@24000 {
@@ -167,6 +183,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <29 2 30 2 34 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi0>;
 			phy-handle = <&phy2>;
 		};
 
@@ -179,6 +196,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <35 2 36 2 40 2>;
 			interrupt-parent = <&mpic>;
+			tbi-handle = <&tbi1>;
 			phy-handle = <&phy1>;
 		};
 
diff --git a/arch/powerpc/sysdev/fsl_soc.c b/arch/powerpc/sysdev/fsl_soc.c
index 26ecb96..115cb16 100644
--- a/arch/powerpc/sysdev/fsl_soc.c
+++ b/arch/powerpc/sysdev/fsl_soc.c
@@ -207,236 +207,51 @@ static int __init of_add_fixed_phys(void)
 arch_initcall(of_add_fixed_phys);
 #endif /* CONFIG_FIXED_PHY */
 
-static int gfar_mdio_of_init_one(struct device_node *np)
-{
-	int k;
-	struct device_node *child = NULL;
-	struct gianfar_mdio_data mdio_data;
-	struct platform_device *mdio_dev;
-	struct resource res;
-	int ret;
-
-	memset(&res, 0, sizeof(res));
-	memset(&mdio_data, 0, sizeof(mdio_data));
-
-	ret = of_address_to_resource(np, 0, &res);
-	if (ret)
-		return ret;
-
-	/* The gianfar device will try to use the same ID created below to find
-	 * this bus, to coordinate register access (since they share).  */
-	mdio_dev = platform_device_register_simple("fsl-gianfar_mdio",
-			res.start&0xfffff, &res, 1);
-	if (IS_ERR(mdio_dev))
-		return PTR_ERR(mdio_dev);
-
-	for (k = 0; k < 32; k++)
-		mdio_data.irq[k] = PHY_POLL;
-
-	while ((child = of_get_next_child(np, child)) != NULL) {
-		int irq = irq_of_parse_and_map(child, 0);
-		if (irq != NO_IRQ) {
-			const u32 *id = of_get_property(child, "reg", NULL);
-			mdio_data.irq[*id] = irq;
-		}
-	}
-
-	ret = platform_device_add_data(mdio_dev, &mdio_data,
-				sizeof(struct gianfar_mdio_data));
-	if (ret)
-		platform_device_unregister(mdio_dev);
-
-	return ret;
-}
-
-static int __init gfar_mdio_of_init(void)
-{
-	struct device_node *np = NULL;
-
-	for_each_compatible_node(np, NULL, "fsl,gianfar-mdio")
-		gfar_mdio_of_init_one(np);
-
-	/* try the deprecated version */
-	for_each_compatible_node(np, "mdio", "gianfar");
-		gfar_mdio_of_init_one(np);
-
-	return 0;
-}
-
-arch_initcall(gfar_mdio_of_init);
-
-static const char *gfar_tx_intr = "tx";
-static const char *gfar_rx_intr = "rx";
-static const char *gfar_err_intr = "error";
-
-static int __init gfar_of_init(void)
+#ifdef CONFIG_PPC_83xx
+static int __init mpc83xx_wdt_init(void)
 {
+	struct resource r;
 	struct device_node *np;
-	unsigned int i;
-	struct platform_device *gfar_dev;
-	struct resource res;
+	struct platform_device *dev;
+	u32 freq = fsl_get_sys_freq();
 	int ret;
 
-	for (np = NULL, i = 0;
-	     (np = of_find_compatible_node(np, "network", "gianfar")) != NULL;
-	     i++) {
-		struct resource r[4];
-		struct device_node *phy, *mdio;
-		struct gianfar_platform_data gfar_data;
-		const unsigned int *id;
-		const char *model;
-		const char *ctype;
-		const void *mac_addr;
-		const phandle *ph;
-		int n_res = 2;
-
-		if (!of_device_is_available(np))
-			continue;
-
-		memset(r, 0, sizeof(r));
-		memset(&gfar_data, 0, sizeof(gfar_data));
-
-		ret = of_address_to_resource(np, 0, &r[0]);
-		if (ret)
-			goto err;
-
-		of_irq_to_resource(np, 0, &r[1]);
-
-		model = of_get_property(np, "model", NULL);
-
-		/* If we aren't the FEC we have multiple interrupts */
-		if (model && strcasecmp(model, "FEC")) {
-			r[1].name = gfar_tx_intr;
-
-			r[2].name = gfar_rx_intr;
-			of_irq_to_resource(np, 1, &r[2]);
+	np = of_find_compatible_node(NULL, "watchdog", "mpc83xx_wdt");
 
-			r[3].name = gfar_err_intr;
-			of_irq_to_resource(np, 2, &r[3]);
-
-			n_res += 2;
-		}
-
-		gfar_dev =
-		    platform_device_register_simple("fsl-gianfar", i, &r[0],
-						    n_res);
-
-		if (IS_ERR(gfar_dev)) {
-			ret = PTR_ERR(gfar_dev);
-			goto err;
-		}
-
-		mac_addr = of_get_mac_address(np);
-		if (mac_addr)
-			memcpy(gfar_data.mac_addr, mac_addr, 6);
-
-		if (model && !strcasecmp(model, "TSEC"))
-			gfar_data.device_flags =
-			    FSL_GIANFAR_DEV_HAS_GIGABIT |
-			    FSL_GIANFAR_DEV_HAS_COALESCE |
-			    FSL_GIANFAR_DEV_HAS_RMON |
-			    FSL_GIANFAR_DEV_HAS_MULTI_INTR;
-		if (model && !strcasecmp(model, "eTSEC"))
-			gfar_data.device_flags =
-			    FSL_GIANFAR_DEV_HAS_GIGABIT |
-			    FSL_GIANFAR_DEV_HAS_COALESCE |
-			    FSL_GIANFAR_DEV_HAS_RMON |
-			    FSL_GIANFAR_DEV_HAS_MULTI_INTR |
-			    FSL_GIANFAR_DEV_HAS_CSUM |
-			    FSL_GIANFAR_DEV_HAS_VLAN |
-			    FSL_GIANFAR_DEV_HAS_EXTENDED_HASH;
-
-		ctype = of_get_property(np, "phy-connection-type", NULL);
-
-		/* We only care about rgmii-id.  The rest are autodetected */
-		if (ctype && !strcmp(ctype, "rgmii-id"))
-			gfar_data.interface = PHY_INTERFACE_MODE_RGMII_ID;
-		else
-			gfar_data.interface = PHY_INTERFACE_MODE_MII;
-
-		if (of_get_property(np, "fsl,magic-packet", NULL))
-			gfar_data.device_flags |= FSL_GIANFAR_DEV_HAS_MAGIC_PACKET;
-
-		ph = of_get_property(np, "phy-handle", NULL);
-		if (ph == NULL) {
-			u32 *fixed_link;
-
-			fixed_link = (u32 *)of_get_property(np, "fixed-link",
-							   NULL);
-			if (!fixed_link) {
-				ret = -ENODEV;
-				goto unreg;
-			}
-
-			snprintf(gfar_data.bus_id, MII_BUS_ID_SIZE, "0");
-			gfar_data.phy_id = fixed_link[0];
-		} else {
-			phy = of_find_node_by_phandle(*ph);
-
-			if (phy == NULL) {
-				ret = -ENODEV;
-				goto unreg;
-			}
-
-			mdio = of_get_parent(phy);
-
-			id = of_get_property(phy, "reg", NULL);
-			ret = of_address_to_resource(mdio, 0, &res);
-			if (ret) {
-				of_node_put(phy);
-				of_node_put(mdio);
-				goto unreg;
-			}
-
-			gfar_data.phy_id = *id;
-			snprintf(gfar_data.bus_id, MII_BUS_ID_SIZE, "%llx",
-				 (unsigned long long)res.start&0xfffff);
+	if (!np) {
+		ret = -ENODEV;
+		goto nodev;
+	}
 
-			of_node_put(phy);
-			of_node_put(mdio);
-		}
+	memset(&r, 0, sizeof(r));
 
-		/* Get MDIO bus controlled by this eTSEC, if any.  Normally only
-		 * eTSEC 1 will control an MDIO bus, not necessarily the same
-		 * bus that its PHY is on ('mdio' above), so we can't just use
-		 * that.  What we do is look for a gianfar mdio device that has
-		 * overlapping registers with this device.  That's really the
-		 * whole point, to find the device sharing our registers to
-		 * coordinate access with it.
-		 */
-		for_each_compatible_node(mdio, NULL, "fsl,gianfar-mdio") {
-			if (of_address_to_resource(mdio, 0, &res))
-				continue;
-
-			if (res.start >= r[0].start && res.end <= r[0].end) {
-				/* Get the ID the mdio bus platform device was
-				 * registered with.  gfar_data.bus_id is
-				 * different because it's for finding a PHY,
-				 * while this is for finding a MII bus.
-				 */
-				gfar_data.mdio_bus = res.start&0xfffff;
-				of_node_put(mdio);
-				break;
-			}
-		}
+	ret = of_address_to_resource(np, 0, &r);
+	if (ret)
+		goto err;
 
-		ret =
-		    platform_device_add_data(gfar_dev, &gfar_data,
-					     sizeof(struct
-						    gianfar_platform_data));
-		if (ret)
-			goto unreg;
+	dev = platform_device_register_simple("mpc83xx_wdt", 0, &r, 1);
+	if (IS_ERR(dev)) {
+		ret = PTR_ERR(dev);
+		goto err;
 	}
 
+	ret = platform_device_add_data(dev, &freq, sizeof(freq));
+	if (ret)
+		goto unreg;
+
+	of_node_put(np);
 	return 0;
 
 unreg:
-	platform_device_unregister(gfar_dev);
+	platform_device_unregister(dev);
 err:
+	of_node_put(np);
+nodev:
 	return ret;
 }
 
-arch_initcall(gfar_of_init);
+arch_initcall(mpc83xx_wdt_init);
+#endif
 
 static enum fsl_usb2_phy_modes determine_usb_phy(const char *phy_type)
 {
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 7040a17..ad222bf 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -25,11 +25,8 @@
  *
  *  Theory of operation
  *
- *  The driver is initialized through platform_device.  Structures which
- *  define the configuration needed by the board are defined in a
- *  board structure in arch/ppc/platforms (though I do not
- *  discount the possibility that other architectures could one
- *  day be supported.
+ *  The driver is initialized through of_device. Configuration information
+ *  is therefore conveyed through an OF-style device tree.
  *
  *  The Gianfar Ethernet Controller uses a ring of buffer
  *  descriptors.  The beginning is indicated by a register
@@ -78,7 +75,7 @@
 #include <linux/if_vlan.h>
 #include <linux/spinlock.h>
 #include <linux/mm.h>
-#include <linux/platform_device.h>
+#include <linux/of_platform.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
@@ -92,6 +89,8 @@
 #include <linux/crc32.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
+#include <linux/phy_fixed.h>
+#include <linux/of.h>
 
 #include "gianfar.h"
 #include "gianfar_mii.h"
@@ -119,8 +118,9 @@ static irqreturn_t gfar_interrupt(int irq, void *dev_id);
 static void adjust_link(struct net_device *dev);
 static void init_registers(struct net_device *dev);
 static int init_phy(struct net_device *dev);
-static int gfar_probe(struct platform_device *pdev);
-static int gfar_remove(struct platform_device *pdev);
+static int gfar_probe(struct of_device *ofdev,
+		const struct of_device_id *match);
+static int gfar_remove(struct of_device *ofdev);
 static void free_skb_resources(struct gfar_private *priv);
 static void gfar_set_multi(struct net_device *dev);
 static void gfar_set_hash_for_addr(struct net_device *dev, u8 *addr);
@@ -152,25 +152,158 @@ static inline int gfar_uses_fcb(struct gfar_private *priv)
 	return (priv->vlan_enable || priv->rx_csum_enable);
 }
 
+static int gfar_of_init(struct net_device *dev)
+{
+	struct device_node *phy, *mdio;
+	const unsigned int *id;
+	const char *model;
+	const char *ctype;
+	const void *mac_addr;
+	const phandle *ph;
+	u64 addr, size;
+	int err = 0;
+	struct gfar_private *priv = netdev_priv(dev);
+	struct device_node *np = priv->node;
+	char bus_name[MII_BUS_ID_SIZE];
+
+	if (!np || !of_device_is_available(np))
+		return -ENODEV;
+
+	/* get a pointer to the register memory */
+	addr = of_translate_address(np, of_get_address(np, 0, &size, NULL));
+	priv->regs = ioremap(addr, size);
+
+	if (priv->regs == NULL)
+		return -ENOMEM;
+
+	priv->interruptTransmit = irq_of_parse_and_map(np, 0);
+
+	model = of_get_property(np, "model", NULL);
+
+	/* If we aren't the FEC we have multiple interrupts */
+	if (model && strcasecmp(model, "FEC")) {
+		priv->interruptReceive = irq_of_parse_and_map(np, 1);
+
+		priv->interruptError = irq_of_parse_and_map(np, 2);
+
+		if (priv->interruptTransmit < 0 ||
+				priv->interruptReceive < 0 ||
+				priv->interruptError < 0) {
+			err = -EINVAL;
+			goto err_out;
+		}
+	}
+
+	mac_addr = of_get_mac_address(np);
+	if (mac_addr)
+		memcpy(dev->dev_addr, mac_addr, MAC_ADDR_LEN);
+
+	if (model && !strcasecmp(model, "TSEC"))
+		priv->device_flags =
+			FSL_GIANFAR_DEV_HAS_GIGABIT |
+			FSL_GIANFAR_DEV_HAS_COALESCE |
+			FSL_GIANFAR_DEV_HAS_RMON |
+			FSL_GIANFAR_DEV_HAS_MULTI_INTR;
+	if (model && !strcasecmp(model, "eTSEC"))
+		priv->device_flags =
+			FSL_GIANFAR_DEV_HAS_GIGABIT |
+			FSL_GIANFAR_DEV_HAS_COALESCE |
+			FSL_GIANFAR_DEV_HAS_RMON |
+			FSL_GIANFAR_DEV_HAS_MULTI_INTR |
+			FSL_GIANFAR_DEV_HAS_CSUM |
+			FSL_GIANFAR_DEV_HAS_VLAN |
+			FSL_GIANFAR_DEV_HAS_MAGIC_PACKET |
+			FSL_GIANFAR_DEV_HAS_EXTENDED_HASH;
+
+	ctype = of_get_property(np, "phy-connection-type", NULL);
+
+	/* We only care about rgmii-id.  The rest are autodetected */
+	if (ctype && !strcmp(ctype, "rgmii-id"))
+		priv->interface = PHY_INTERFACE_MODE_RGMII_ID;
+	else
+		priv->interface = PHY_INTERFACE_MODE_MII;
+
+	if (of_get_property(np, "fsl,magic-packet", NULL))
+		priv->device_flags |= FSL_GIANFAR_DEV_HAS_MAGIC_PACKET;
+
+	ph = of_get_property(np, "phy-handle", NULL);
+	if (ph == NULL) {
+		u32 *fixed_link;
+
+		fixed_link = (u32 *)of_get_property(np, "fixed-link", NULL);
+		if (!fixed_link) {
+			err = -ENODEV;
+			goto err_out;
+		}
+
+		snprintf(priv->phy_bus_id, BUS_ID_SIZE, PHY_ID_FMT, "0",
+				fixed_link[0]);
+	} else {
+		phy = of_find_node_by_phandle(*ph);
+
+		if (phy == NULL) {
+			err = -ENODEV;
+			goto err_out;
+		}
+
+		mdio = of_get_parent(phy);
+
+		id = of_get_property(phy, "reg", NULL);
+
+		of_node_put(phy);
+		of_node_put(mdio);
+
+		gfar_mdio_bus_name(bus_name, mdio);
+		snprintf(priv->phy_bus_id, BUS_ID_SIZE, "%s:%02x",
+				bus_name, *id);
+	}
+
+	/* Find the TBI PHY.  If it's not there, we don't support SGMII */
+	ph = of_get_property(np, "tbi-handle", NULL);
+	if (ph) {
+		struct device_node *tbi = of_find_node_by_phandle(*ph);
+		struct of_device *ofdev;
+		struct mii_bus *bus;
+
+		if (!tbi)
+			return 0;
+
+		mdio = of_get_parent(tbi);
+		if (!mdio)
+			return 0;
+
+		ofdev = of_find_device_by_node(mdio);
+
+		of_node_put(mdio);
+
+		id = of_get_property(tbi, "reg", NULL);
+		if (!id)
+			return 0;
+
+		of_node_put(tbi);
+
+		bus = dev_get_drvdata(&ofdev->dev);
+
+		priv->tbiphy = bus->phy_map[*id];
+	}
+
+	return 0;
+
+err_out:
+	iounmap(priv->regs);
+	return err;
+}
+
 /* Set up the ethernet device structure, private data,
  * and anything else we need before we start */
-static int gfar_probe(struct platform_device *pdev)
+static int gfar_probe(struct of_device *ofdev,
+		const struct of_device_id *match)
 {
 	u32 tempval;
 	struct net_device *dev = NULL;
 	struct gfar_private *priv = NULL;
-	struct gianfar_platform_data *einfo;
-	struct resource *r;
-	int err = 0, irq;
-
-	einfo = (struct gianfar_platform_data *) pdev->dev.platform_data;
-
-	if (NULL == einfo) {
-		printk(KERN_ERR "gfar %d: Missing additional data!\n",
-		       pdev->id);
-
-		return -ENODEV;
-	}
+	int err = 0;
+	DECLARE_MAC_BUF(mac);
 
 	/* Create an ethernet device instance */
 	dev = alloc_etherdev(sizeof (*priv));
@@ -180,48 +313,19 @@ static int gfar_probe(struct platform_device *pdev)
 
 	priv = netdev_priv(dev);
 	priv->dev = dev;
+	priv->node = ofdev->node;
 
-	/* Set the info in the priv to the current info */
-	priv->einfo = einfo;
-
-	/* fill out IRQ fields */
-	if (einfo->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
-		irq = platform_get_irq_byname(pdev, "tx");
-		if (irq < 0)
-			goto regs_fail;
-		priv->interruptTransmit = irq;
-
-		irq = platform_get_irq_byname(pdev, "rx");
-		if (irq < 0)
-			goto regs_fail;
-		priv->interruptReceive = irq;
-
-		irq = platform_get_irq_byname(pdev, "error");
-		if (irq < 0)
-			goto regs_fail;
-		priv->interruptError = irq;
-	} else {
-		irq = platform_get_irq(pdev, 0);
-		if (irq < 0)
-			goto regs_fail;
-		priv->interruptTransmit = irq;
-	}
-
-	/* get a pointer to the register memory */
-	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	priv->regs = ioremap(r->start, sizeof (struct gfar));
+	err = gfar_of_init(dev);
 
-	if (NULL == priv->regs) {
-		err = -ENOMEM;
+	if (err)
 		goto regs_fail;
-	}
 
 	spin_lock_init(&priv->txlock);
 	spin_lock_init(&priv->rxlock);
 	spin_lock_init(&priv->bflock);
 	INIT_WORK(&priv->reset_task, gfar_reset_task);
 
-	platform_set_drvdata(pdev, dev);
+	dev_set_drvdata(&ofdev->dev, priv);
 
 	/* Stop the DMA engine now, in case it was running before */
 	/* (The firmware could have used it, and left it running). */
@@ -239,13 +343,10 @@ static int gfar_probe(struct platform_device *pdev)
 	/* Initialize ECNTRL */
 	gfar_write(&priv->regs->ecntrl, ECNTRL_INIT_SETTINGS);
 
-	/* Copy the station address into the dev structure, */
-	memcpy(dev->dev_addr, einfo->mac_addr, MAC_ADDR_LEN);
-
 	/* Set the dev->base_addr to the gfar reg region */
 	dev->base_addr = (unsigned long) (priv->regs);
 
-	SET_NETDEV_DEV(dev, &pdev->dev);
+	SET_NETDEV_DEV(dev, &ofdev->dev);
 
 	/* Fill in the dev structure */
 	dev->open = gfar_enet_open;
@@ -263,7 +364,7 @@ static int gfar_probe(struct platform_device *pdev)
 
 	dev->ethtool_ops = &gfar_ethtool_ops;
 
-	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_CSUM) {
+	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM) {
 		priv->rx_csum_enable = 1;
 		dev->features |= NETIF_F_IP_CSUM;
 	} else
@@ -271,7 +372,7 @@ static int gfar_probe(struct platform_device *pdev)
 
 	priv->vlgrp = NULL;
 
-	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_VLAN) {
+	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_VLAN) {
 		dev->vlan_rx_register = gfar_vlan_rx_register;
 
 		dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
@@ -279,7 +380,7 @@ static int gfar_probe(struct platform_device *pdev)
 		priv->vlan_enable = 1;
 	}
 
-	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_EXTENDED_HASH) {
+	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_EXTENDED_HASH) {
 		priv->extended_hash = 1;
 		priv->hash_width = 9;
 
@@ -314,7 +415,7 @@ static int gfar_probe(struct platform_device *pdev)
 		priv->hash_regs[7] = &priv->regs->gaddr7;
 	}
 
-	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_PADDING)
+	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_PADDING)
 		priv->padding = DEFAULT_PADDING;
 	else
 		priv->padding = 0;
@@ -368,29 +469,28 @@ regs_fail:
 	return err;
 }
 
-static int gfar_remove(struct platform_device *pdev)
+static int gfar_remove(struct of_device *ofdev)
 {
-	struct net_device *dev = platform_get_drvdata(pdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = dev_get_drvdata(&ofdev->dev);
 
-	platform_set_drvdata(pdev, NULL);
+	dev_set_drvdata(&ofdev->dev, NULL);
 
 	iounmap(priv->regs);
-	free_netdev(dev);
+	free_netdev(priv->dev);
 
 	return 0;
 }
 
 #ifdef CONFIG_PM
-static int gfar_suspend(struct platform_device *pdev, pm_message_t state)
+static int gfar_suspend(struct of_device *ofdev, pm_message_t state)
 {
-	struct net_device *dev = platform_get_drvdata(pdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = dev_get_drvdata(&ofdev->dev);
+	struct net_device *dev = priv->dev;
 	unsigned long flags;
 	u32 tempval;
 
 	int magic_packet = priv->wol_en &&
-		(priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
+		(priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
 
 	netif_device_detach(dev);
 
@@ -431,14 +531,14 @@ static int gfar_suspend(struct platform_device *pdev, pm_message_t state)
 	return 0;
 }
 
-static int gfar_resume(struct platform_device *pdev)
+static int gfar_resume(struct of_device *ofdev)
 {
-	struct net_device *dev = platform_get_drvdata(pdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = dev_get_drvdata(&ofdev->dev);
+	struct net_device *dev = priv->dev;
 	unsigned long flags;
 	u32 tempval;
 	int magic_packet = priv->wol_en &&
-		(priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
+		(priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
 
 	if (!netif_running(dev)) {
 		netif_device_attach(dev);
@@ -497,7 +597,7 @@ static phy_interface_t gfar_get_interface(struct net_device *dev)
 		if (ecntrl & ECNTRL_REDUCED_MII_MODE)
 			return PHY_INTERFACE_MODE_RMII;
 		else {
-			phy_interface_t interface = priv->einfo->interface;
+			phy_interface_t interface = priv->interface;
 
 			/*
 			 * This isn't autodetected right now, so it must
@@ -510,7 +610,7 @@ static phy_interface_t gfar_get_interface(struct net_device *dev)
 		}
 	}
 
-	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_GIGABIT)
+	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_GIGABIT)
 		return PHY_INTERFACE_MODE_GMII;
 
 	return PHY_INTERFACE_MODE_MII;
@@ -524,21 +624,18 @@ static int init_phy(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	uint gigabit_support =
-		priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_GIGABIT ?
+		priv->device_flags & FSL_GIANFAR_DEV_HAS_GIGABIT ?
 		SUPPORTED_1000baseT_Full : 0;
 	struct phy_device *phydev;
-	char phy_id[BUS_ID_SIZE];
 	phy_interface_t interface;
 
 	priv->oldlink = 0;
 	priv->oldspeed = 0;
 	priv->oldduplex = -1;
 
-	snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT, priv->einfo->bus_id, priv->einfo->phy_id);
-
 	interface = gfar_get_interface(dev);
 
-	phydev = phy_connect(dev, phy_id, &adjust_link, 0, interface);
+	phydev = phy_connect(dev, priv->phy_bus_id, &adjust_link, 0, interface);
 
 	if (interface == PHY_INTERFACE_MODE_SGMII)
 		gfar_configure_serdes(dev);
@@ -569,35 +666,31 @@ static int init_phy(struct net_device *dev)
 static void gfar_configure_serdes(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	struct gfar_mii __iomem *regs =
-			(void __iomem *)&priv->regs->gfar_mii_regs;
-	int tbipa = gfar_read(&priv->regs->tbipa);
-	struct mii_bus *bus = gfar_get_miibus(priv);
 
-	if (bus)
-		mutex_lock(&bus->mdio_lock);
+	if (!priv->tbiphy) {
+		printk(KERN_WARNING "SGMII mode requires that the device "
+				"tree specify a tbi-handle\n");
+		return;
+	}
 
-	/* If the link is already up, we must already be ok, and don't need to
+	/*
+	 * If the link is already up, we must already be ok, and don't need to
 	 * configure and reset the TBI<->SerDes link.  Maybe U-Boot configured
 	 * everything for us?  Resetting it takes the link down and requires
 	 * several seconds for it to come back.
 	 */
-	if (gfar_local_mdio_read(regs, tbipa, MII_BMSR) & BMSR_LSTATUS)
-		goto done;
+	if (phy_read(priv->tbiphy, MII_BMSR) & BMSR_LSTATUS)
+		return;
 
 	/* Single clk mode, mii mode off(for serdes communication) */
-	gfar_local_mdio_write(regs, tbipa, MII_TBICON, TBICON_CLK_SELECT);
+	phy_write(priv->tbiphy, MII_TBICON, TBICON_CLK_SELECT);
 
-	gfar_local_mdio_write(regs, tbipa, MII_ADVERTISE,
+	phy_write(priv->tbiphy, MII_ADVERTISE,
 			ADVERTISE_1000XFULL | ADVERTISE_1000XPAUSE |
 			ADVERTISE_1000XPSE_ASYM);
 
-	gfar_local_mdio_write(regs, tbipa, MII_BMCR, BMCR_ANENABLE |
+	phy_write(priv->tbiphy, MII_BMCR, BMCR_ANENABLE |
 			BMCR_ANRESTART | BMCR_FULLDPLX | BMCR_SPEED1000);
-
-	done:
-	if (bus)
-		mutex_unlock(&bus->mdio_lock);
 }
 
 static void init_registers(struct net_device *dev)
@@ -630,7 +723,7 @@ static void init_registers(struct net_device *dev)
 	gfar_write(&priv->regs->gaddr7, 0);
 
 	/* Zero out the rmon mib registers if it has them */
-	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_RMON) {
+	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_RMON) {
 		memset_io(&(priv->regs->rmon), 0, sizeof (struct rmon_mib));
 
 		/* Mask off the CAM interrupts */
@@ -705,7 +798,7 @@ void stop_gfar(struct net_device *dev)
 	spin_unlock_irqrestore(&priv->txlock, flags);
 
 	/* Free the IRQs */
-	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
+	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
 		free_irq(priv->interruptError, dev);
 		free_irq(priv->interruptTransmit, dev);
 		free_irq(priv->interruptReceive, dev);
@@ -919,7 +1012,7 @@ int startup_gfar(struct net_device *dev)
 
 	/* If the device has multiple interrupts, register for
 	 * them.  Otherwise, only register for the one */
-	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
+	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
 		/* Install our interrupt handlers for Error,
 		 * Transmit, and Receive */
 		if (request_irq(priv->interruptError, gfar_error,
@@ -1749,7 +1842,7 @@ static void gfar_netpoll(struct net_device *dev)
 	struct gfar_private *priv = netdev_priv(dev);
 
 	/* If the device has multiple interrupts, run tx/rx */
-	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
+	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
 		disable_irq(priv->interruptTransmit);
 		disable_irq(priv->interruptReceive);
 		disable_irq(priv->interruptError);
@@ -2043,7 +2136,7 @@ static irqreturn_t gfar_error(int irq, void *dev_id)
 	gfar_write(&priv->regs->ievent, events & IEVENT_ERR_MASK);
 
 	/* Magic Packet is not an error. */
-	if ((priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET) &&
+	if ((priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET) &&
 	    (events & IEVENT_MAG))
 		events &= ~IEVENT_MAG;
 
@@ -2109,16 +2202,24 @@ static irqreturn_t gfar_error(int irq, void *dev_id)
 /* work with hotplug and coldplug */
 MODULE_ALIAS("platform:fsl-gianfar");
 
+static struct of_device_id gfar_match[] =
+{
+	{
+		.type = "network",
+		.compatible = "gianfar",
+	},
+	{},
+};
+
 /* Structure for a device driver */
-static struct platform_driver gfar_driver = {
+static struct of_platform_driver gfar_driver = {
+	.name = "fsl-gianfar",
+	.match_table = gfar_match,
+
 	.probe = gfar_probe,
 	.remove = gfar_remove,
 	.suspend = gfar_suspend,
 	.resume = gfar_resume,
-	.driver	= {
-		.name = "fsl-gianfar",
-		.owner = THIS_MODULE,
-	},
 };
 
 static int __init gfar_init(void)
@@ -2128,7 +2229,7 @@ static int __init gfar_init(void)
 	if (err)
 		return err;
 
-	err = platform_driver_register(&gfar_driver);
+	err = of_register_platform_driver(&gfar_driver);
 
 	if (err)
 		gfar_mdio_exit();
@@ -2138,7 +2239,7 @@ static int __init gfar_init(void)
 
 static void __exit gfar_exit(void)
 {
-	platform_driver_unregister(&gfar_driver);
+	of_unregister_platform_driver(&gfar_driver);
 	gfar_mdio_exit();
 }
 
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index f46e9b6..ca7f0a6 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -657,6 +657,19 @@ struct gfar {
 
 };
 
+/* Flags related to gianfar device features */
+#define FSL_GIANFAR_DEV_HAS_GIGABIT		0x00000001
+#define FSL_GIANFAR_DEV_HAS_COALESCE		0x00000002
+#define FSL_GIANFAR_DEV_HAS_RMON		0x00000004
+#define FSL_GIANFAR_DEV_HAS_MULTI_INTR		0x00000008
+#define FSL_GIANFAR_DEV_HAS_CSUM		0x00000010
+#define FSL_GIANFAR_DEV_HAS_VLAN		0x00000020
+#define FSL_GIANFAR_DEV_HAS_EXTENDED_HASH	0x00000040
+#define FSL_GIANFAR_DEV_HAS_PADDING		0x00000080
+#define FSL_GIANFAR_DEV_HAS_MAGIC_PACKET	0x00000100
+#define FSL_GIANFAR_DEV_HAS_BD_STASHING		0x00000200
+#define FSL_GIANFAR_DEV_HAS_BUF_STASHING	0x00000400
+
 /* Struct stolen almost completely (and shamelessly) from the FCC enet source
  * (Ok, that's not so true anymore, but there is a family resemblence)
  * The GFAR buffer descriptors track the ring buffers.  The rx_bd_base
@@ -694,6 +707,7 @@ struct gfar_private {
 	/* RX Locked fields */
 	spinlock_t rxlock;
 
+	struct device_node *node;
 	struct net_device *dev;
 	struct napi_struct napi;
 
@@ -733,6 +747,9 @@ struct gfar_private {
 	/* Bitfield update lock */
 	spinlock_t bflock;
 
+	phy_interface_t interface;
+	char	phy_bus_id[BUS_ID_SIZE];
+	u32 device_flags;
 	unsigned char vlan_enable:1,
 		rx_csum_enable:1,
 		extended_hash:1,
@@ -744,11 +761,9 @@ struct gfar_private {
 	unsigned int interruptReceive;
 	unsigned int interruptError;
 
-	/* info structure initialized by platform code */
-	struct gianfar_platform_data *einfo;
-
 	/* PHY stuff */
 	struct phy_device *phydev;
+	struct phy_device *tbiphy;
 	struct mii_bus *mii_bus;
 	int oldspeed;
 	int oldduplex;
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index fb7d3cc..53944b1 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -121,7 +121,7 @@ static void gfar_gstrings(struct net_device *dev, u32 stringset, u8 * buf)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 
-	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_RMON)
+	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_RMON)
 		memcpy(buf, stat_gstrings, GFAR_STATS_LEN * ETH_GSTRING_LEN);
 	else
 		memcpy(buf, stat_gstrings,
@@ -138,7 +138,7 @@ static void gfar_fill_stats(struct net_device *dev, struct ethtool_stats *dummy,
 	struct gfar_private *priv = netdev_priv(dev);
 	u64 *extra = (u64 *) & priv->extra_stats;
 
-	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_RMON) {
+	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_RMON) {
 		u32 __iomem *rmon = (u32 __iomem *) & priv->regs->rmon;
 		struct gfar_stats *stats = (struct gfar_stats *) buf;
 
@@ -158,7 +158,7 @@ static int gfar_sset_count(struct net_device *dev, int sset)
 
 	switch (sset) {
 	case ETH_SS_STATS:
-		if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_RMON)
+		if (priv->device_flags & FSL_GIANFAR_DEV_HAS_RMON)
 			return GFAR_STATS_LEN;
 		else
 			return GFAR_EXTRA_STATS_LEN;
@@ -280,7 +280,7 @@ static int gfar_gcoalesce(struct net_device *dev, struct ethtool_coalesce *cvals
 {
 	struct gfar_private *priv = netdev_priv(dev);
 
-	if (!(priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_COALESCE))
+	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_COALESCE))
 		return -EOPNOTSUPP;
 
 	if (NULL == priv->phydev)
@@ -332,7 +332,7 @@ static int gfar_scoalesce(struct net_device *dev, struct ethtool_coalesce *cvals
 {
 	struct gfar_private *priv = netdev_priv(dev);
 
-	if (!(priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_COALESCE))
+	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_COALESCE))
 		return -EOPNOTSUPP;
 
 	/* Set up rx coalescing */
@@ -482,7 +482,7 @@ static int gfar_set_rx_csum(struct net_device *dev, uint32_t data)
 	unsigned long flags;
 	int err = 0;
 
-	if (!(priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_CSUM))
+	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM))
 		return -EOPNOTSUPP;
 
 	if (dev->flags & IFF_UP) {
@@ -515,7 +515,7 @@ static uint32_t gfar_get_rx_csum(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 
-	if (!(priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_CSUM))
+	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM))
 		return 0;
 
 	return priv->rx_csum_enable;
@@ -526,7 +526,7 @@ static int gfar_set_tx_csum(struct net_device *dev, uint32_t data)
 	unsigned long flags;
 	struct gfar_private *priv = netdev_priv(dev);
 
-	if (!(priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_CSUM))
+	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM))
 		return -EOPNOTSUPP;
 
 	spin_lock_irqsave(&priv->txlock, flags);
@@ -547,7 +547,7 @@ static uint32_t gfar_get_tx_csum(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 
-	if (!(priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_CSUM))
+	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM))
 		return 0;
 
 	return (dev->features & NETIF_F_IP_CSUM) != 0;
@@ -570,7 +570,7 @@ static void gfar_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 
-	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET) {
+	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET) {
 		wol->supported = WAKE_MAGIC;
 		wol->wolopts = priv->wol_en ? WAKE_MAGIC : 0;
 	} else {
@@ -583,7 +583,7 @@ static int gfar_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	struct gfar_private *priv = netdev_priv(dev);
 	unsigned long flags;
 
-	if (!(priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET) &&
+	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET) &&
 	    wol->wolopts != 0)
 		return -EINVAL;
 
diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index 0e2595d..f3706e4 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -34,6 +34,8 @@
 #include <linux/crc32.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
+#include <linux/of.h>
+#include <linux/of_platform.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -150,19 +152,83 @@ static int gfar_mdio_reset(struct mii_bus *bus)
 	return 0;
 }
 
+/* Allocate an array which provides irq #s for each PHY on the given bus */
+static int *create_irq_map(struct device_node *np)
+{
+	int *irqs;
+	int i;
+	struct device_node *child = NULL;
+
+	irqs = kcalloc(PHY_MAX_ADDR, sizeof(int), GFP_KERNEL);
+
+	if (!irqs)
+		return NULL;
+
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		irqs[i] = PHY_POLL;
+
+	while ((child = of_get_next_child(np, child)) != NULL) {
+		int irq = irq_of_parse_and_map(child, 0);
+		const u32 *id;
+
+		if (irq == NO_IRQ)
+			continue;
+
+		id = of_get_property(child, "reg", NULL);
+
+		if (!id)
+			continue;
+
+		if (*id < PHY_MAX_ADDR && *id >= 0)
+			irqs[*id] = irq;
+		else
+			printk(KERN_WARNING "%s: "
+					"%d is not a valid PHY address\n",
+					np->full_name, *id);
+	}
+
+	return irqs;
+}
+
+
+void gfar_mdio_bus_name(char *name, struct device_node *np)
+{
+	const u32 *reg;
+
+	reg = of_get_property(np, "reg", NULL);
 
-static int gfar_mdio_probe(struct device *dev)
+	snprintf(name, MII_BUS_ID_SIZE, "%s@%x", np->name, reg ? *reg : 0);
+}
+
+/* Scan the bus in reverse, looking for an empty spot */
+static int gfar_mdio_find_free(struct mii_bus *new_bus)
+{
+	int i;
+
+	for (i = PHY_MAX_ADDR; i > 0; i--) {
+		u32 phy_id;
+
+		if (get_phy_id(new_bus, i, &phy_id))
+			return -1;
+
+		if (phy_id == 0xffffffff)
+			break;
+	}
+
+	return i;
+}
+
+static int gfar_mdio_probe(struct of_device *ofdev,
+		const struct of_device_id *match)
 {
-	struct platform_device *pdev = to_platform_device(dev);
-	struct gianfar_mdio_data *pdata;
 	struct gfar_mii __iomem *regs;
 	struct gfar __iomem *enet_regs;
 	struct mii_bus *new_bus;
-	struct resource *r;
-	int i, err = 0;
-
-	if (NULL == dev)
-		return -EINVAL;
+	int err = 0;
+	u64 addr, size;
+	struct device_node *np = ofdev->node;
+	struct device_node *tbi;
+	int tbiaddr = -1;
 
 	new_bus = mdiobus_alloc();
 	if (NULL == new_bus)
@@ -172,31 +238,28 @@ static int gfar_mdio_probe(struct device *dev)
 	new_bus->read = &gfar_mdio_read,
 	new_bus->write = &gfar_mdio_write,
 	new_bus->reset = &gfar_mdio_reset,
-	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", pdev->id);
-
-	pdata = (struct gianfar_mdio_data *)pdev->dev.platform_data;
-
-	if (NULL == pdata) {
-		printk(KERN_ERR "gfar mdio %d: Missing platform data!\n", pdev->id);
-		return -ENODEV;
-	}
-
-	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	gfar_mdio_bus_name(new_bus->id, np);
 
 	/* Set the PHY base address */
-	regs = ioremap(r->start, sizeof (struct gfar_mii));
+	addr = of_translate_address(np, of_get_address(np, 0, &size, NULL));
+	regs = ioremap(addr, size);
 
 	if (NULL == regs) {
 		err = -ENOMEM;
-		goto reg_map_fail;
+		goto err_free_bus;
 	}
 
 	new_bus->priv = (void __force *)regs;
 
-	new_bus->irq = pdata->irq;
+	new_bus->irq = create_irq_map(np);
+
+	if (new_bus->irq == NULL) {
+		err = -ENOMEM;
+		goto err_unmap_regs;
+	}
 
-	new_bus->parent = dev;
-	dev_set_drvdata(dev, new_bus);
+	new_bus->parent = &ofdev->dev;
+	dev_set_drvdata(&ofdev->dev, new_bus);
 
 	/*
 	 * This is mildly evil, but so is our hardware for doing this.
@@ -206,96 +269,109 @@ static int gfar_mdio_probe(struct device *dev)
 	enet_regs = (struct gfar __iomem *)
 		((char *)regs - offsetof(struct gfar, gfar_mii_regs));
 
-	/* Scan the bus, looking for an empty spot for TBIPA */
-	gfar_write(&enet_regs->tbipa, 0);
-	for (i = PHY_MAX_ADDR; i > 0; i--) {
-		u32 phy_id;
+	for_each_child_of_node(np, tbi) {
+		if (!strncmp(tbi->type, "tbi-phy", 8))
+			break;
+	}
 
-		err = get_phy_id(new_bus, i, &phy_id);
-		if (err)
-			goto bus_register_fail;
+	if (tbi) {
+		const u32 *prop = of_get_property(tbi, "reg", NULL);
 
-		if (phy_id == 0xffffffff)
-			break;
+		if (prop)
+			tbiaddr = *prop;
 	}
 
-	/* The bus is full.  We don't support using 31 PHYs, sorry */
-	if (i == 0) {
+	if (tbiaddr == -1) {
+		gfar_write(&enet_regs->tbipa, 0);
+
+		tbiaddr = gfar_mdio_find_free(new_bus);
+	}
+
+	/*
+	 * We define TBIPA at 0 to be illegal, opting to fail for boards that
+	 * have PHYs at 1-31, rather than change tbipa and rescan.
+	 */
+	if (tbiaddr == 0) {
 		err = -EBUSY;
 
-		goto bus_register_fail;
+		goto err_free_irqs;
 	}
 
-	gfar_write(&enet_regs->tbipa, i);
+	gfar_write(&enet_regs->tbipa, tbiaddr);
+
+	/*
+	 * The TBIPHY-only buses will find PHYs at every address,
+	 * so we mask them all but the TBI
+	 */
+	if (!of_device_is_compatible(np, "fsl,gianfar-mdio"))
+		new_bus->phy_mask = ~(1 << tbiaddr);
 
 	err = mdiobus_register(new_bus);
 
-	if (0 != err) {
+	if (err != 0) {
 		printk (KERN_ERR "%s: Cannot register as MDIO bus\n",
 				new_bus->name);
-		goto bus_register_fail;
+		goto err_free_irqs;
 	}
 
 	return 0;
 
-bus_register_fail:
+err_free_irqs:
+	kfree(new_bus->irq);
+err_unmap_regs:
 	iounmap(regs);
-reg_map_fail:
+err_free_bus:
 	mdiobus_free(new_bus);
 
 	return err;
 }
 
 
-static int gfar_mdio_remove(struct device *dev)
+static int gfar_mdio_remove(struct of_device *ofdev)
 {
-	struct mii_bus *bus = dev_get_drvdata(dev);
+	struct mii_bus *bus = dev_get_drvdata(&ofdev->dev);
 
 	mdiobus_unregister(bus);
 
-	dev_set_drvdata(dev, NULL);
+	dev_set_drvdata(&ofdev->dev, NULL);
 
 	iounmap((void __iomem *)bus->priv);
 	bus->priv = NULL;
+	kfree(bus->irq);
 	mdiobus_free(bus);
 
 	return 0;
 }
 
-static struct device_driver gianfar_mdio_driver = {
+static struct of_device_id gfar_mdio_match[] =
+{
+	{
+		.compatible = "fsl,gianfar-mdio",
+	},
+	{
+		.compatible = "fsl,gianfar-tbi",
+	},
+	{
+		.type = "mdio",
+		.compatible = "gianfar",
+	},
+	{},
+};
+
+static struct of_platform_driver gianfar_mdio_driver = {
 	.name = "fsl-gianfar_mdio",
-	.bus = &platform_bus_type,
+	.match_table = gfar_mdio_match,
+
 	.probe = gfar_mdio_probe,
 	.remove = gfar_mdio_remove,
 };
 
-static int match_mdio_bus(struct device *dev, void *data)
-{
-	const struct gfar_private *priv = data;
-	const struct platform_device *pdev = to_platform_device(dev);
-
-	return !strcmp(pdev->name, gianfar_mdio_driver.name) &&
-		pdev->id == priv->einfo->mdio_bus;
-}
-
-/* Given a gfar_priv structure, find the mii_bus controlled by this device (not
- * necessarily the same as the bus the gfar's PHY is on), if one exists.
- * Normally only the first gianfar controls a mii_bus.  */
-struct mii_bus *gfar_get_miibus(const struct gfar_private *priv)
-{
-	/*const*/ struct device *d;
-
-	d = bus_find_device(gianfar_mdio_driver.bus, NULL, (void *)priv,
-			    match_mdio_bus);
-	return d ? dev_get_drvdata(d) : NULL;
-}
-
 int __init gfar_mdio_init(void)
 {
-	return driver_register(&gianfar_mdio_driver);
+	return of_register_platform_driver(&gianfar_mdio_driver);
 }
 
 void gfar_mdio_exit(void)
 {
-	driver_unregister(&gianfar_mdio_driver);
+	of_unregister_platform_driver(&gianfar_mdio_driver);
 }
diff --git a/drivers/net/gianfar_mii.h b/drivers/net/gianfar_mii.h
index 02dc970..65c242c 100644
--- a/drivers/net/gianfar_mii.h
+++ b/drivers/net/gianfar_mii.h
@@ -49,4 +49,6 @@ int gfar_local_mdio_read(struct gfar_mii __iomem *regs, int mii_id, int regnum);
 struct mii_bus *gfar_get_miibus(const struct gfar_private *priv);
 int __init gfar_mdio_init(void);
 void gfar_mdio_exit(void);
+
+void gfar_mdio_bus_name(char *name, struct device_node *np);
 #endif /* GIANFAR_PHY_H */
diff --git a/include/linux/fsl_devices.h b/include/linux/fsl_devices.h
index 708bab5..d9051d7 100644
--- a/include/linux/fsl_devices.h
+++ b/include/linux/fsl_devices.h
@@ -47,12 +47,7 @@
 struct gianfar_platform_data {
 	/* device specific information */
 	u32	device_flags;
-	/* board specific information */
-	u32	board_flags;
-	int	mdio_bus;			/* Bus controlled by us */
-	char	bus_id[MII_BUS_ID_SIZE];	/* Bus PHY is on */
-	u32	phy_id;
-	u8	mac_addr[6];
+	char	bus_id[BUS_ID_SIZE];
 	phy_interface_t interface;
 };
 
@@ -61,17 +56,6 @@ struct gianfar_mdio_data {
 	int	irq[32];
 };
 
-/* Flags related to gianfar device features */
-#define FSL_GIANFAR_DEV_HAS_GIGABIT		0x00000001
-#define FSL_GIANFAR_DEV_HAS_COALESCE		0x00000002
-#define FSL_GIANFAR_DEV_HAS_RMON		0x00000004
-#define FSL_GIANFAR_DEV_HAS_MULTI_INTR		0x00000008
-#define FSL_GIANFAR_DEV_HAS_CSUM		0x00000010
-#define FSL_GIANFAR_DEV_HAS_VLAN		0x00000020
-#define FSL_GIANFAR_DEV_HAS_EXTENDED_HASH	0x00000040
-#define FSL_GIANFAR_DEV_HAS_PADDING		0x00000080
-#define FSL_GIANFAR_DEV_HAS_MAGIC_PACKET	0x00000100
-
 /* Flags in gianfar_platform_data */
 #define FSL_GIANFAR_BRD_HAS_PHY_INTR	0x00000001 /* set or use a timer */
 #define FSL_GIANFAR_BRD_IS_REDUCED	0x00000002 /* Set if RGMII, RMII */
-- 
1.5.4.GIT

