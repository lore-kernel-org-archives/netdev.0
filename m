From: Timur Tabi <timur@freescale.com>
Subject: [PATCH 2/2] powerpc/85xx: add Fman MDIO muxing support to the P4080DS
Date: Fri, 10 Aug 2012 17:31:36 -0500
Message-ID: <1344637896-14267-2-git-send-email-timur@freescale.com>
References: <1344637896-14267-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: Andy Fleming <afleming@freescale.com>,
	Scott Wood <scottwood@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>,
	<ddaney.cavm@gmail.com>, <linuxppc-dev@ozlabs.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe002.messaging.microsoft.com ([216.32.180.185]:1709
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751620Ab2HJWbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 18:31:45 -0400
In-Reply-To: <1344637896-14267-1-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Freescale P4080 SOC contains two Fman Ethernet controllers, each of
which contains four 1G Ethernet MACs and one 10G Ethernet MAC.  The
SerDes protocol determines how the MACs are routed to various RGMII,
SGMII, or XGMII PHYs on the board, so the P4080DS reference board
provides a MDIO bus multiplexing feature that is controlled via GPIOs.

This patch adds the basic Ethernet, MDIO, mdio-mux, and PHY nodes
necessary to get MDIO bus muxing working, using Cavium's mdio-mux-gpio
driver.  The remaining DPAA nodes (Qman, Bman, etc), as well as the
DPAA device drivers, are not included.

Signed-off-by: Timur Tabi <timur@freescale.com>
---
 arch/powerpc/boot/dts/fsl/p4080si-post.dtsi |   12 +
 arch/powerpc/boot/dts/fsl/p4080si-pre.dtsi  |    3 +
 arch/powerpc/boot/dts/p4080ds.dts           |  307 +++++++++++++++++++++++++++
 arch/powerpc/platforms/85xx/Kconfig         |    3 +
 arch/powerpc/platforms/85xx/corenet_ds.c    |    7 +
 5 files changed, 332 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/boot/dts/fsl/p4080si-post.dtsi b/arch/powerpc/boot/dts/fsl/p4080si-post.dtsi
index 8d35d2c..1ce5056 100644
--- a/arch/powerpc/boot/dts/fsl/p4080si-post.dtsi
+++ b/arch/powerpc/boot/dts/fsl/p4080si-post.dtsi
@@ -347,4 +347,16 @@
 /include/ "qoriq-usb2-mph-0.dtsi"
 /include/ "qoriq-usb2-dr-0.dtsi"
 /include/ "qoriq-sec4.0-0.dtsi"
+/include/ "qoriq-fman-0.dtsi"
+/include/ "qoriq-fman-0-1g-0.dtsi"
+/include/ "qoriq-fman-0-1g-1.dtsi"
+/include/ "qoriq-fman-0-1g-2.dtsi"
+/include/ "qoriq-fman-0-1g-3.dtsi"
+/include/ "qoriq-fman-0-10g-0.dtsi"
+/include/ "qoriq-fman-1.dtsi"
+/include/ "qoriq-fman-1-1g-0.dtsi"
+/include/ "qoriq-fman-1-1g-1.dtsi"
+/include/ "qoriq-fman-1-1g-2.dtsi"
+/include/ "qoriq-fman-1-1g-3.dtsi"
+/include/ "qoriq-fman-1-10g-0.dtsi"
 };
diff --git a/arch/powerpc/boot/dts/fsl/p4080si-pre.dtsi b/arch/powerpc/boot/dts/fsl/p4080si-pre.dtsi
index b9556ee..1be6360 100644
--- a/arch/powerpc/boot/dts/fsl/p4080si-pre.dtsi
+++ b/arch/powerpc/boot/dts/fsl/p4080si-pre.dtsi
@@ -69,6 +69,9 @@
 		rtic_c = &rtic_c;
 		rtic_d = &rtic_d;
 		sec_mon = &sec_mon;
+
+		fman0 = &fman0;
+		fman1 = &fman1;
 	};
 
 	cpus {
diff --git a/arch/powerpc/boot/dts/p4080ds.dts b/arch/powerpc/boot/dts/p4080ds.dts
index 3e20460..68ae3bb 100644
--- a/arch/powerpc/boot/dts/p4080ds.dts
+++ b/arch/powerpc/boot/dts/p4080ds.dts
@@ -41,6 +41,44 @@
 	#size-cells = <2>;
 	interrupt-parent = <&mpic>;
 
+	aliases {
+		ethernet0 = &fm1_gb0;	// FM1@DTSEC1
+		ethernet1 = &fm1_gb1;	// FM1@DTSEC2
+		ethernet2 = &fm1_gb2;	// FM1@DTSEC3
+		ethernet3 = &fm1_gb3;	// FM1@DTSEC4
+		ethernet4 = &fm1_10g;	// FM1@TGEC1
+		ethernet5 = &fm2_gb0;	// FM2@DTSEC1
+		ethernet6 = &fm2_gb1;	// FM2@DTSEC2
+		ethernet7 = &fm2_gb2;	// FM2@DTSEC3
+		ethernet8 = &fm2_gb3;	// FM2@DTSEC4
+		ethernet9 = &fm2_10g;	// FM2@TGEC1
+
+		phy_rgmii = &phy_rgmii;
+
+		phy_sgmii_slot3_1c = &phy_sgmii_slot3_1c;
+		phy_sgmii_slot3_1d = &phy_sgmii_slot3_1d;
+		phy_sgmii_slot3_1e = &phy_sgmii_slot3_1e;
+		phy_sgmii_slot3_1f = &phy_sgmii_slot3_1f;
+
+		phy_sgmii_slot4_1c = &phy_sgmii_slot4_1c;
+		phy_sgmii_slot4_1d = &phy_sgmii_slot4_1d;
+		phy_sgmii_slot4_1e = &phy_sgmii_slot4_1e;
+		phy_sgmii_slot4_1f = &phy_sgmii_slot4_1f;
+
+		phy_sgmii_slot5_1c = &phy_sgmii_slot5_1c;
+		phy_sgmii_slot5_1d = &phy_sgmii_slot5_1d;
+		phy_sgmii_slot5_1e = &phy_sgmii_slot5_1e;
+		phy_sgmii_slot5_1f = &phy_sgmii_slot5_1f;
+
+		// Used by U-Boot to find the mdio-mux nodes
+		emi1_rgmii = &emi1_rgmii;
+		emi1_slot3 = &emi1_slot3;
+		emi1_slot4 = &emi1_slot4;
+		emi1_slot5 = &emi1_slot5;
+		emi2_slot4 = &emi2_slot4;
+		emi2_slot5 = &emi2_slot5;
+	};
+
 	memory {
 		device_type = "memory";
 	};
@@ -106,6 +144,117 @@
 			dr_mode = "host";
 			phy_type = "ulpi";
 		};
+
+		fman0: fman@400000 {
+			fm1_gb0: ethernet@e0000 {
+				tbi-handle = <&tbi0>;
+				phy-connection-type = "sgmii";
+			};
+
+			mdio0: mdio@e1120 {
+				tbi0: tbi-phy@8 {
+					reg = <0x8>;
+					device_type = "tbi-phy";
+				};
+			};
+
+			fm1_gb1: ethernet@e2000 {
+				tbi-handle = <&tbi1>;
+				phy-connection-type = "sgmii";
+			};
+
+			mdio@e3120 {
+				tbi1: tbi-phy@8 {
+					reg = <8>;
+					device_type = "tbi-phy";
+				};
+			};
+
+			fm1_gb2: ethernet@e4000 {
+				tbi-handle = <&tbi2>;
+				phy-connection-type = "sgmii";
+			};
+
+			mdio@e5120 {
+				tbi2: tbi-phy@8 {
+					reg = <8>;
+					device_type = "tbi-phy";
+				};
+			};
+
+			fm1_gb3: ethernet@e6000 {
+				tbi-handle = <&tbi3>;
+				phy-connection-type = "sgmii";
+			};
+
+			mdio@e7120 {
+				tbi3: tbi-phy@8 {
+					reg = <8>;
+					device_type = "tbi-phy";
+				};
+			};
+
+			fm1_10g: ethernet@f0000 {
+				phy-handle = <&phy_xgmii_slot5>;
+				phy-connection-type = "xgmii";
+			};
+		};
+
+		fman1: fman@500000 {
+			fm2_gb0: ethernet@e0000 {
+				tbi-handle = <&tbi5>;
+				phy-connection-type = "sgmii";
+			};
+
+			mdio@e1120 {
+				tbi5: tbi-phy@8 {
+					reg = <8>;
+					device_type = "tbi-phy";
+				};
+			};
+
+			fm2_gb1: ethernet@e2000 {
+				tbi-handle = <&tbi6>;
+				phy-connection-type = "sgmii";
+			};
+
+			mdio@e3120 {
+				tbi6: tbi-phy@8 {
+					reg = <8>;
+					device_type = "tbi-phy";
+				};
+			};
+
+			fm2_gb2: ethernet@e4000 {
+				tbi-handle = <&tbi7>;
+				phy-connection-type = "sgmii";
+			};
+
+			mdio@e5120 {
+				tbi7: tbi-phy@8 {
+					reg = <8>;
+					device_type = "tbi-phy";
+				};
+			};
+
+			fm2_gb3: ethernet@e6000 {
+				tbi-handle = <&tbi8>;
+				phy-connection-type = "sgmii";
+			};
+
+			mdio@e7120 {
+				tbi8: tbi-phy@8 {
+					reg = <8>;
+					device_type = "tbi-phy";
+				};
+			};
+
+			fm2_10g: ethernet@f0000 {
+				phy-handle = <&phy_xgmii_slot4>;
+				phy-connection-type = "xgmii";
+			};
+		};
+
 	};
 
 	rio: rapidio@ffe0c0000 {
@@ -182,6 +331,164 @@
 		};
 	};
 
+	fsl,dpaa {
+		compatible = "fsl,p4080-dpaa", "fsl,dpaa";
+
+		ethernet@0 {
+			compatible = "fsl,p4080-dpa-ethernet", "fsl,dpa-ethernet";
+			fsl,fman-mac = <&fm1_gb0>;
+		};
+		ethernet@1 {
+			compatible = "fsl,p4080-dpa-ethernet", "fsl,dpa-ethernet";
+			fsl,fman-mac = <&fm1_gb1>;
+		};
+		ethernet@2 {
+			compatible = "fsl,p4080-dpa-ethernet", "fsl,dpa-ethernet";
+			fsl,fman-mac = <&fm1_gb2>;
+		};
+		ethernet@3 {
+			compatible = "fsl,p4080-dpa-ethernet", "fsl,dpa-ethernet";
+			fsl,fman-mac = <&fm1_gb3>;
+		};
+		ethernet@4 {
+			compatible = "fsl,p4080-dpa-ethernet", "fsl,dpa-ethernet";
+			fsl,fman-mac = <&fm1_10g>;
+		};
+		ethernet@5 {
+			compatible = "fsl,p4080-dpa-ethernet", "fsl,dpa-ethernet";
+			fsl,fman-mac = <&fm2_gb0>;
+		};
+		ethernet@6 {
+			compatible = "fsl,p4080-dpa-ethernet", "fsl,dpa-ethernet";
+			fsl,fman-mac = <&fm2_gb1>;
+		};
+		ethernet@7 {
+			compatible = "fsl,p4080-dpa-ethernet", "fsl,dpa-ethernet";
+			fsl,fman-mac = <&fm2_gb2>;
+		};
+		ethernet@8 {
+			compatible = "fsl,p4080-dpa-ethernet", "fsl,dpa-ethernet";
+			fsl,fman-mac = <&fm2_gb3>;
+		};
+		ethernet@9 {
+			compatible = "fsl,p4080-dpa-ethernet", "fsl,dpa-ethernet";
+			fsl,fman-mac = <&fm2_10g>;
+		};
+	};
+
+	mdio-mux-emi1 {
+		compatible = "mdio-mux-gpio", "mdio-mux";
+		// The 'reg' property of the MDIO nodes is written to the
+		// GPIOs as a single number, but the driver parses the number
+		// in little-endian order, so these GPIO pins need to be in
+		// little-endian order.
+		gpios = <&gpio0 1 0>, <&gpio0 0 0>;
+		mdio-parent-bus = <&mdio0>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		emi1_rgmii: mdio@0 {	// RGMII
+			status = "disabled";
+			reg = <0>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			phy_rgmii: ethernet-phy@0 {
+				reg = <0x0>;
+			};
+		};
+
+		emi1_slot3: mdio@2 {	// Slot 3 SGMII
+			status = "disabled";
+			reg = <2>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			phy_sgmii_slot3_1c: ethernet-phy@1c {
+				reg = <0x1c>;
+			};
+			phy_sgmii_slot3_1d: ethernet-phy@1d {
+				reg = <0x1d>;
+			};
+			phy_sgmii_slot3_1e: ethernet-phy@1e {
+				reg = <0x1e>;
+			};
+			phy_sgmii_slot3_1f: ethernet-phy@1f {
+				reg = <0x1f>;
+			};
+		};
+
+		emi1_slot4: mdio@1 {	// Slot 4 SGMII
+			status = "disabled";
+			reg = <1>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			phy_sgmii_slot4_1c: ethernet-phy@1c {
+				reg = <0x1c>;
+			};
+			phy_sgmii_slot4_1d: ethernet-phy@1d {
+				reg = <0x1d>;
+			};
+			phy_sgmii_slot4_1e: ethernet-phy@1e {
+				reg = <0x1e>;
+			};
+			phy_sgmii_slot4_1f: ethernet-phy@1f {
+				reg = <0x1f>;
+			};
+		};
+
+		emi1_slot5: mdio@3 {	// Slot 5 SGMII
+			status = "disabled";
+			reg = <3>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			phy_sgmii_slot5_1c: ethernet-phy@1c {
+				reg = <0x1c>;
+			};
+			phy_sgmii_slot5_1d: ethernet-phy@1d {
+				reg = <0x1d>;
+			};
+			phy_sgmii_slot5_1e: ethernet-phy@1e {
+				reg = <0x1e>;
+			};
+			phy_sgmii_slot5_1f: ethernet-phy@1f {
+				reg = <0x1f>;
+			};
+		};
+	};
+
+	mdio-mux-emi2 {
+		compatible = "mdio-mux-gpio", "mdio-mux";
+		// The mdio-mux-gpio driver wants GPIOs in little-endian order
+		gpios = <&gpio0 3 0>, <&gpio0 2 0>;
+		mdio-parent-bus = <&xmdio0>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		emi2_slot4: mdio@1 {	// Slot 4 XAUI (FM2)
+			status = "disabled";
+			reg = <1>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			phy_xgmii_slot4: ethernet-phy@0 {
+				reg = <0>;
+			};
+		};
+
+		emi2_slot5: mdio@3 {	// Slot 5 XAUI (FM1)
+			status = "disabled";
+			reg = <3>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			phy_xgmii_slot5: ethernet-phy@4 {
+				reg = <4>;
+			};
+		};
+	};
 };
 
 /include/ "fsl/p4080si-post.dtsi"
diff --git a/arch/powerpc/platforms/85xx/Kconfig b/arch/powerpc/platforms/85xx/Kconfig
index 159c01e..591ec5e 100644
--- a/arch/powerpc/platforms/85xx/Kconfig
+++ b/arch/powerpc/platforms/85xx/Kconfig
@@ -235,6 +235,9 @@ config P4080_DS
 	select GPIO_MPC8XXX
 	select HAS_RAPIDIO
 	select PPC_EPAPR_HV_PIC
+	select MPC8xxx_GPIO if PHYLIB
+	select MDIO_BUS_MUX if PHYLIB
+	select MDIO_BUS_MUX_GPIO if PHYLIB
 	help
 	  This option enables support for the P4080 DS board
 
diff --git a/arch/powerpc/platforms/85xx/corenet_ds.c b/arch/powerpc/platforms/85xx/corenet_ds.c
index 925b028..a79fc79 100644
--- a/arch/powerpc/platforms/85xx/corenet_ds.c
+++ b/arch/powerpc/platforms/85xx/corenet_ds.c
@@ -106,6 +106,13 @@ static const struct of_device_id of_device_ids[] __devinitconst = {
 	{
 		.name		= "handles",
 	},
+	{
+		/*
+		 * Warning: this entry might need to be located before those
+		 * for the Fman Ethernet nodes.
+		 */
+		.compatible	= "mdio-mux",
+	},
 	{}
 };
 
-- 
1.7.3.4
