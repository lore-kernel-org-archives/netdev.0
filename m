From: ddaney.cavm@gmail.com
Subject: [PATCH 3/3] MIPS: Octeon: Rearrange CVMX files in preperation for device tree
Date: Thu, 10 Nov 2011 16:29:47 -0800
Message-ID: <1320971387-29343-4-git-send-email-ddaney.cavm@gmail.com>
References: <1320971387-29343-1-git-send-email-ddaney.cavm@gmail.com>
Cc: David Daney <david.daney@cavium.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de, devel@driverdev.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:36019 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755696Ab1KKA3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 19:29:55 -0500
Received: by ggnb2 with SMTP id b2so3632177ggn.19
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2011 16:29:54 -0800 (PST)
In-Reply-To: <1320971387-29343-1-git-send-email-ddaney.cavm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <david.daney@cavium.com>

Signed-off-by: David Daney <david.daney@cavium.com>
---
 .../cavium-octeon/executive/cvmx-helper-sgmii.c    |    6 +-
 .../mips/cavium-octeon/executive/cvmx-helper-spi.c |   10 ++
 .../cavium-octeon/executive/cvmx-helper-xaui.c     |   22 +++--
 arch/mips/cavium-octeon/executive/cvmx-helper.c    |   93 ++++++++++++++++---
 arch/mips/include/asm/octeon/cvmx-helper-loop.h    |    1 +
 arch/mips/include/asm/octeon/cvmx-helper-npi.h     |    1 +
 arch/mips/include/asm/octeon/cvmx-helper-rgmii.h   |    1 +
 arch/mips/include/asm/octeon/cvmx-helper-sgmii.h   |    1 +
 arch/mips/include/asm/octeon/cvmx-helper-spi.h     |    1 +
 arch/mips/include/asm/octeon/cvmx-helper-xaui.h    |    1 +
 arch/mips/include/asm/octeon/cvmx-helper.h         |    1 +
 11 files changed, 114 insertions(+), 24 deletions(-)

diff --git a/arch/mips/cavium-octeon/executive/cvmx-helper-sgmii.c b/arch/mips/cavium-octeon/executive/cvmx-helper-sgmii.c
index 464347f..0c0bf5d 100644
--- a/arch/mips/cavium-octeon/executive/cvmx-helper-sgmii.c
+++ b/arch/mips/cavium-octeon/executive/cvmx-helper-sgmii.c
@@ -326,6 +326,10 @@ static int __cvmx_helper_sgmii_hardware_init(int interface, int num_ports)
 	return 0;
 }
 
+int __cvmx_helper_sgmii_enumerate(int interface)
+{
+	return 4;
+}
 /**
  * Probe a SGMII interface and determine the number of ports
  * connected to it. The SGMII interface should still be down after
@@ -347,7 +351,7 @@ int __cvmx_helper_sgmii_probe(int interface)
 	mode.u64 = cvmx_read_csr(CVMX_GMXX_INF_MODE(interface));
 	mode.s.en = 1;
 	cvmx_write_csr(CVMX_GMXX_INF_MODE(interface), mode.u64);
-	return 4;
+	return __cvmx_helper_sgmii_enumerate(interface);
 }
 
 /**
diff --git a/arch/mips/cavium-octeon/executive/cvmx-helper-spi.c b/arch/mips/cavium-octeon/executive/cvmx-helper-spi.c
index 02a4442..2830e4b 100644
--- a/arch/mips/cavium-octeon/executive/cvmx-helper-spi.c
+++ b/arch/mips/cavium-octeon/executive/cvmx-helper-spi.c
@@ -51,6 +51,16 @@ void __cvmx_interrupt_stxx_int_msk_enable(int index);
 #define CVMX_HELPER_SPI_TIMEOUT 10
 #endif
 
+int __cvmx_helper_spi_enumerate(int interface)
+{
+	if ((cvmx_sysinfo_get()->board_type != CVMX_BOARD_TYPE_SIM) &&
+	    cvmx_spi4000_is_present(interface)) {
+		return 10;
+	} else {
+		return 16;
+	}
+}
+
 /**
  * Probe a SPI interface and determine the number of ports
  * connected to it. The SPI interface should still be down after
diff --git a/arch/mips/cavium-octeon/executive/cvmx-helper-xaui.c b/arch/mips/cavium-octeon/executive/cvmx-helper-xaui.c
index 667a8e3..1723248e 100644
--- a/arch/mips/cavium-octeon/executive/cvmx-helper-xaui.c
+++ b/arch/mips/cavium-octeon/executive/cvmx-helper-xaui.c
@@ -44,6 +44,19 @@
 void __cvmx_interrupt_gmxx_enable(int interface);
 void __cvmx_interrupt_pcsx_intx_en_reg_enable(int index, int block);
 void __cvmx_interrupt_pcsxx_int_en_reg_enable(int index);
+
+int __cvmx_helper_xaui_enumerate(int interface)
+{
+	union cvmx_gmxx_hg2_control gmx_hg2_control;
+
+	/* If HiGig2 is enabled return 16 ports, otherwise return 1 port */
+	gmx_hg2_control.u64 = cvmx_read_csr(CVMX_GMXX_HG2_CONTROL(interface));
+	if (gmx_hg2_control.s.hg2tx_en)
+		return 16;
+	else
+		return 1;
+}
+
 /**
  * Probe a XAUI interface and determine the number of ports
  * connected to it. The XAUI interface should still be down
@@ -56,7 +69,6 @@ void __cvmx_interrupt_pcsxx_int_en_reg_enable(int index);
 int __cvmx_helper_xaui_probe(int interface)
 {
 	int i;
-	union cvmx_gmxx_hg2_control gmx_hg2_control;
 	union cvmx_gmxx_inf_mode mode;
 
 	/*
@@ -90,13 +102,7 @@ int __cvmx_helper_xaui_probe(int interface)
 		pko_mem_port_ptrs.s.pid = interface * 16 + i;
 		cvmx_write_csr(CVMX_PKO_MEM_PORT_PTRS, pko_mem_port_ptrs.u64);
 	}
-
-	/* If HiGig2 is enabled return 16 ports, otherwise return 1 port */
-	gmx_hg2_control.u64 = cvmx_read_csr(CVMX_GMXX_HG2_CONTROL(interface));
-	if (gmx_hg2_control.s.hg2tx_en)
-		return 16;
-	else
-		return 1;
+	return __cvmx_helper_xaui_enumerate(interface);
 }
 
 /**
diff --git a/arch/mips/cavium-octeon/executive/cvmx-helper.c b/arch/mips/cavium-octeon/executive/cvmx-helper.c
index daa8c8b..fa49638 100644
--- a/arch/mips/cavium-octeon/executive/cvmx-helper.c
+++ b/arch/mips/cavium-octeon/executive/cvmx-helper.c
@@ -234,21 +234,16 @@ static int __cvmx_helper_port_setup_ipd(int ipd_port)
 }
 
 /**
- * This function probes an interface to determine the actual
- * number of hardware ports connected to it. It doesn't setup the
- * ports or enable them. The main goal here is to set the global
- * interface_port_count[interface] correctly. Hardware setup of the
- * ports will be performed later.
+ * This function sets the interface_port_count[interface] correctly,
+ * without modifying any hardware configuration.  Hardware setup of
+ * the ports will be performed later.
  *
  * @interface: Interface to probe
  *
  * Returns Zero on success, negative on failure
  */
-int cvmx_helper_interface_probe(int interface)
+int cvmx_helper_interface_enumerate(int interface)
 {
-	/* At this stage in the game we don't want packets to be moving yet.
-	   The following probe calls should perform hardware setup
-	   needed to determine port counts. Receive must still be disabled */
 	switch (cvmx_helper_interface_get_mode(interface)) {
 		/* These types don't support ports to IPD/PKO */
 	case CVMX_HELPER_INTERFACE_MODE_DISABLED:
@@ -258,7 +253,7 @@ int cvmx_helper_interface_probe(int interface)
 		/* XAUI is a single high speed port */
 	case CVMX_HELPER_INTERFACE_MODE_XAUI:
 		interface_port_count[interface] =
-		    __cvmx_helper_xaui_probe(interface);
+		    __cvmx_helper_xaui_enumerate(interface);
 		break;
 		/*
 		 * RGMII/GMII/MII are all treated about the same. Most
@@ -267,7 +262,7 @@ int cvmx_helper_interface_probe(int interface)
 	case CVMX_HELPER_INTERFACE_MODE_RGMII:
 	case CVMX_HELPER_INTERFACE_MODE_GMII:
 		interface_port_count[interface] =
-		    __cvmx_helper_rgmii_probe(interface);
+		    __cvmx_helper_rgmii_enumerate(interface);
 		break;
 		/*
 		 * SPI4 can have 1-16 ports depending on the device at
@@ -275,7 +270,7 @@ int cvmx_helper_interface_probe(int interface)
 		 */
 	case CVMX_HELPER_INTERFACE_MODE_SPI:
 		interface_port_count[interface] =
-		    __cvmx_helper_spi_probe(interface);
+		    __cvmx_helper_spi_enumerate(interface);
 		break;
 		/*
 		 * SGMII can have 1-4 ports depending on how many are
@@ -284,12 +279,12 @@ int cvmx_helper_interface_probe(int interface)
 	case CVMX_HELPER_INTERFACE_MODE_SGMII:
 	case CVMX_HELPER_INTERFACE_MODE_PICMG:
 		interface_port_count[interface] =
-		    __cvmx_helper_sgmii_probe(interface);
+		    __cvmx_helper_sgmii_enumerate(interface);
 		break;
 		/* PCI target Network Packet Interface */
 	case CVMX_HELPER_INTERFACE_MODE_NPI:
 		interface_port_count[interface] =
-		    __cvmx_helper_npi_probe(interface);
+		    __cvmx_helper_npi_enumerate(interface);
 		break;
 		/*
 		 * Special loopback only ports. These are not the same
@@ -297,7 +292,7 @@ int cvmx_helper_interface_probe(int interface)
 		 */
 	case CVMX_HELPER_INTERFACE_MODE_LOOP:
 		interface_port_count[interface] =
-		    __cvmx_helper_loop_probe(interface);
+		    __cvmx_helper_loop_enumerate(interface);
 		break;
 	}
 
@@ -313,6 +308,74 @@ int cvmx_helper_interface_probe(int interface)
 }
 
 /**
+ * This function probes an interface to determine the actual
+ * number of hardware ports connected to it. It doesn't setup the
+ * ports or enable them. The main goal here is to set the global
+ * interface_port_count[interface] correctly. Hardware setup of the
+ * ports will be performed later.
+ *
+ * @interface: Interface to probe
+ *
+ * Returns Zero on success, negative on failure
+ */
+int cvmx_helper_interface_probe(int interface)
+{
+	cvmx_helper_interface_enumerate(interface);
+	/* At this stage in the game we don't want packets to be moving yet.
+	   The following probe calls should perform hardware setup
+	   needed to determine port counts. Receive must still be disabled */
+	switch (cvmx_helper_interface_get_mode(interface)) {
+		/* These types don't support ports to IPD/PKO */
+	case CVMX_HELPER_INTERFACE_MODE_DISABLED:
+	case CVMX_HELPER_INTERFACE_MODE_PCIE:
+		break;
+		/* XAUI is a single high speed port */
+	case CVMX_HELPER_INTERFACE_MODE_XAUI:
+		__cvmx_helper_xaui_probe(interface);
+		break;
+		/*
+		 * RGMII/GMII/MII are all treated about the same. Most
+		 * functions refer to these ports as RGMII.
+		 */
+	case CVMX_HELPER_INTERFACE_MODE_RGMII:
+	case CVMX_HELPER_INTERFACE_MODE_GMII:
+		__cvmx_helper_rgmii_probe(interface);
+		break;
+		/*
+		 * SPI4 can have 1-16 ports depending on the device at
+		 * the other end.
+		 */
+	case CVMX_HELPER_INTERFACE_MODE_SPI:
+		__cvmx_helper_spi_probe(interface);
+		break;
+		/*
+		 * SGMII can have 1-4 ports depending on how many are
+		 * hooked up.
+		 */
+	case CVMX_HELPER_INTERFACE_MODE_SGMII:
+	case CVMX_HELPER_INTERFACE_MODE_PICMG:
+		__cvmx_helper_sgmii_probe(interface);
+		break;
+		/* PCI target Network Packet Interface */
+	case CVMX_HELPER_INTERFACE_MODE_NPI:
+		__cvmx_helper_npi_probe(interface);
+		break;
+		/*
+		 * Special loopback only ports. These are not the same
+		 * as other ports in loopback mode.
+		 */
+	case CVMX_HELPER_INTERFACE_MODE_LOOP:
+		__cvmx_helper_loop_probe(interface);
+		break;
+	}
+
+	/* Make sure all global variables propagate to other cores */
+	CVMX_SYNCWS;
+
+	return 0;
+}
+
+/**
  * Setup the IPD/PIP for the ports on an interface. Packet
  * classification and tagging are set for every port on the
  * interface. The number of ports on the interface must already
diff --git a/arch/mips/include/asm/octeon/cvmx-helper-loop.h b/arch/mips/include/asm/octeon/cvmx-helper-loop.h
index e646a6c..077f0e9 100644
--- a/arch/mips/include/asm/octeon/cvmx-helper-loop.h
+++ b/arch/mips/include/asm/octeon/cvmx-helper-loop.h
@@ -44,6 +44,7 @@
  * Returns Number of ports on the interface. Zero to disable.
  */
 extern int __cvmx_helper_loop_probe(int interface);
+static inline int __cvmx_helper_loop_enumerate(int interface) {return 4; }
 
 /**
  * Bringup and enable a LOOP interface. After this call packet
diff --git a/arch/mips/include/asm/octeon/cvmx-helper-npi.h b/arch/mips/include/asm/octeon/cvmx-helper-npi.h
index 908e7b0..8df4c7f 100644
--- a/arch/mips/include/asm/octeon/cvmx-helper-npi.h
+++ b/arch/mips/include/asm/octeon/cvmx-helper-npi.h
@@ -45,6 +45,7 @@
  * Returns Number of ports on the interface. Zero to disable.
  */
 extern int __cvmx_helper_npi_probe(int interface);
+#define __cvmx_helper_npi_enumerate __cvmx_helper_npi_probe
 
 /**
  * Bringup and enable a NPI interface. After this call packet
diff --git a/arch/mips/include/asm/octeon/cvmx-helper-rgmii.h b/arch/mips/include/asm/octeon/cvmx-helper-rgmii.h
index ea26526..78295ba 100644
--- a/arch/mips/include/asm/octeon/cvmx-helper-rgmii.h
+++ b/arch/mips/include/asm/octeon/cvmx-helper-rgmii.h
@@ -43,6 +43,7 @@
  * Returns Number of RGMII/GMII/MII ports (0-4).
  */
 extern int __cvmx_helper_rgmii_probe(int interface);
+#define __cvmx_helper_rgmii_enumerate __cvmx_helper_rgmii_probe
 
 /**
  * Put an RGMII interface in loopback mode. Internal packets sent
diff --git a/arch/mips/include/asm/octeon/cvmx-helper-sgmii.h b/arch/mips/include/asm/octeon/cvmx-helper-sgmii.h
index 19b48d6..9a9b6c1 100644
--- a/arch/mips/include/asm/octeon/cvmx-helper-sgmii.h
+++ b/arch/mips/include/asm/octeon/cvmx-helper-sgmii.h
@@ -45,6 +45,7 @@
  * Returns Number of ports on the interface. Zero to disable.
  */
 extern int __cvmx_helper_sgmii_probe(int interface);
+extern int __cvmx_helper_sgmii_enumerate(int interface);
 
 /**
  * Bringup and enable a SGMII interface. After this call packet
diff --git a/arch/mips/include/asm/octeon/cvmx-helper-spi.h b/arch/mips/include/asm/octeon/cvmx-helper-spi.h
index 69bac03..9f1c6b9 100644
--- a/arch/mips/include/asm/octeon/cvmx-helper-spi.h
+++ b/arch/mips/include/asm/octeon/cvmx-helper-spi.h
@@ -42,6 +42,7 @@
  * Returns Number of ports on the interface. Zero to disable.
  */
 extern int __cvmx_helper_spi_probe(int interface);
+extern int __cvmx_helper_spi_enumerate(int interface);
 
 /**
  * Bringup and enable a SPI interface. After this call packet I/O
diff --git a/arch/mips/include/asm/octeon/cvmx-helper-xaui.h b/arch/mips/include/asm/octeon/cvmx-helper-xaui.h
index 4b4db2f..f6fbc4f 100644
--- a/arch/mips/include/asm/octeon/cvmx-helper-xaui.h
+++ b/arch/mips/include/asm/octeon/cvmx-helper-xaui.h
@@ -45,6 +45,7 @@
  * Returns Number of ports on the interface. Zero to disable.
  */
 extern int __cvmx_helper_xaui_probe(int interface);
+extern int __cvmx_helper_xaui_enumerate(int interface);
 
 /**
  * Bringup and enable a XAUI interface. After this call packet
diff --git a/arch/mips/include/asm/octeon/cvmx-helper.h b/arch/mips/include/asm/octeon/cvmx-helper.h
index 51916f3..3169cd7 100644
--- a/arch/mips/include/asm/octeon/cvmx-helper.h
+++ b/arch/mips/include/asm/octeon/cvmx-helper.h
@@ -207,6 +207,7 @@ extern int cvmx_helper_link_set(int ipd_port,
  * Returns Zero on success, negative on failure
  */
 extern int cvmx_helper_interface_probe(int interface);
+extern int cvmx_helper_interface_enumerate(int interface);
 
 /**
  * Configure a port for internal and/or external loopback. Internal loopback
-- 
1.7.2.3
