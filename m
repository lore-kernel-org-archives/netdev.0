From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [net-next.git 1/3] stmmac: update driver documentation
Date: Tue, 18 Nov 2014 09:46:59 +0100
Message-ID: <1416300421-25500-2-git-send-email-peppe.cavallaro@st.com>
References: <1416300421-25500-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:33683 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753469AbaKRJDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 04:03:52 -0500
Received: from pps.filterd (m0046670.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id sAI8ubqL029926
	for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 10:03:50 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 1qqxcsh6e4-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 10:03:49 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id AAEF066
	for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 09:02:49 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id C13F52C9E4
	for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 09:03:19 +0000 (GMT)
In-Reply-To: <1416300421-25500-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently many changes have been done inside the driver
so this patch updates the driver's doc for example reviewing
information for the rx and tx processes that are managed
by napi method, adding new information for missing glue-logic files
etc.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 Documentation/networking/stmmac.txt |  132 +++++++++++++++++------------------
 1 files changed, 65 insertions(+), 67 deletions(-)

diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index 2090895..e655e24 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -1,12 +1,12 @@
        STMicroelectronics 10/100/1000 Synopsys Ethernet driver
 
-Copyright (C) 2007-2013  STMicroelectronics Ltd
+Copyright (C) 2007-2014  STMicroelectronics Ltd
 Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 
 This is the driver for the MAC 10/100/1000 on-chip Ethernet controllers
 (Synopsys IP blocks).
 
-Currently this network device driver is for all STM embedded MAC/GMAC
+Currently this network device driver is for all STi embedded MAC/GMAC
 (i.e. 7xxx/5xxx SoCs), SPEAr (arm), Loongson1B (mips) and XLINX XC2V3000
 FF1152AMT0221 D1215994A VIRTEX FPGA board.
 
@@ -22,6 +22,9 @@ The kernel configuration option is STMMAC_ETH:
  Device Drivers ---> Network device support ---> Ethernet (1000 Mbit) --->
  STMicroelectronics 10/100/1000 Ethernet driver (STMMAC_ETH)
 
+CONFIG_STMMAC_PLATFORM: is to enable the platform driver.
+CONFIG_STMMAC_PCI: is to enable the pci driver.
+
 2) Driver parameters list:
 	debug: message level (0: no output, 16: all);
 	phyaddr: to manually provide the physical address to the PHY device;
@@ -45,10 +48,11 @@ Driver parameters can be also passed in command line by using:
 The xmit method is invoked when the kernel needs to transmit a packet; it sets
 the descriptors in the ring and informs the DMA engine that there is a packet
 ready to be transmitted.
-Once the controller has finished transmitting the packet, an interrupt is
-triggered; So the driver will be able to release the socket buffers.
 By default, the driver sets the NETIF_F_SG bit in the features field of the
-net_device structure enabling the scatter/gather feature.
+net_device structure enabling the scatter-gather feature. This is true on
+chips and configurations where the checksum can be done in hardware.
+Once the controller has finished transmitting the packet, napi will be
+scheduled to release the transmit resources.
 
 4.2) Receive process
 When one or more packets are received, an interrupt happens. The interrupts
@@ -58,20 +62,12 @@ This is based on NAPI so the interrupt handler signals only if there is work
 to be done, and it exits.
 Then the poll method will be scheduled at some future point.
 The incoming packets are stored, by the DMA, in a list of pre-allocated socket
-buffers in order to avoid the memcpy (Zero-copy).
+buffers in order to avoid the memcpy (zero-copy).
 
 4.3) Interrupt Mitigation
 The driver is able to mitigate the number of its DMA interrupts
 using NAPI for the reception on chips older than the 3.50.
 New chips have an HW RX-Watchdog used for this mitigation.
-
-On Tx-side, the mitigation schema is based on a SW timer that calls the
-tx function (stmmac_tx) to reclaim the resource after transmitting the
-frames.
-Also there is another parameter (like a threshold) used to program
-the descriptors avoiding to set the interrupt on completion bit in
-when the frame is sent (xmit).
-
 Mitigation parameters can be tuned by ethtool.
 
 4.4) WOL
@@ -79,7 +75,7 @@ Wake up on Lan feature through Magic and Unicast frames are supported for the
 GMAC core.
 
 4.5) DMA descriptors
-Driver handles both normal and enhanced descriptors. The latter has been only
+Driver handles both normal and alternate descriptors. The latter has been only
 tested on DWC Ether MAC 10/100/1000 Universal version 3.41a and later.
 
 STMMAC supports DMA descriptor to operate both in dual buffer (RING)
@@ -91,9 +87,20 @@ In CHAINED mode each descriptor will have pointer to next descriptor in
 the list, hence creating the explicit chaining in the descriptor itself,
 whereas such explicit chaining is not possible in RING mode.
 
+4.5.1) Extended descriptors
+	The extended descriptors give us information about the Ethernet payload
+	when it is carrying PTP packets or TCP/UDP/ICMP over IP.
+	These are not available on GMAC Synopsys chips older than the 3.50.
+	At probe time the driver will decide if these can be actually used.
+	This support also is mandatory for PTPv2 because the extra descriptors
+	are used for saving the hardware timestamps and Extended Status.
+
 4.6) Ethtool support
-Ethtool is supported. Driver statistics and internal errors can be taken using:
-ethtool -S ethX command. It is possible to dump registers etc.
+Ethtool is supported.
+
+For example, driver statistics (including RMON), internal errors can be taken
+using:
+  # ethtool -S ethX command
 
 4.7) Jumbo and Segmentation Offloading
 Jumbo frames are supported and tested for the GMAC.
@@ -101,12 +108,11 @@ The GSO has been also added but it's performed in software.
 LRO is not supported.
 
 4.8) Physical
-The driver is compatible with PAL to work with PHY and GPHY devices.
+The driver is compatible with Physical Abstraction Layer to be connected with
+PHY and GPHY devices.
 
 4.9) Platform information
-Several driver's information can be passed through the platform
-These are included in the include/linux/stmmac.h header file
-and detailed below as well:
+Several information can be passed through the platform and device-tree.
 
 struct plat_stmmacenet_data {
 	char *phy_bus_name;
@@ -125,15 +131,18 @@ struct plat_stmmacenet_data {
 	int force_sf_dma_mode;
 	int force_thresh_dma_mode;
 	int riwt_off;
+	int max_speed;
+	int maxmtu;
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
 	void (*bus_setup)(void __iomem *ioaddr);
 	void *(*setup)(struct platform_device *pdev);
+	void (*free)(struct platform_device *pdev, void *priv);
 	int (*init)(struct platform_device *pdev, void *priv);
 	void (*exit)(struct platform_device *pdev, void *priv);
 	void *custom_cfg;
 	void *custom_data;
 	void *bsp_priv;
- };
+};
 
 Where:
  o phy_bus_name: phy bus name to attach to the stmmac.
@@ -258,32 +267,43 @@ and the second one, with a real PHY device attached to the bus,
 by using the stmmac_mdio_bus_data structure (to provide the id, the
 reset procedure etc).
 
-4.10) List of source files:
- o Kconfig
- o Makefile
- o stmmac_main.c: main network device driver;
- o stmmac_mdio.c: mdio functions;
- o stmmac_pci: PCI driver;
- o stmmac_platform.c: platform driver
- o stmmac_ethtool.c: ethtool support;
- o stmmac_timer.[ch]: timer code used for mitigating the driver dma interrupts
-		      (only tested on ST40 platforms based);
+Note that, starting from new chips, where it is available the HW capability
+register, many configurations are discovered at run-time for example to
+understand if EEE, HW csum, PTP, enhanced descriptor etc are actually
+available. As strategy adopted in this driver, the information from the HW
+capability register can replace what has been passed from the platform.
+
+4.10) Device-tree support.
+
+Please see the following document:
+	Documentation/devicetree/bindings/net/stmmac.txt
+
+and the stmmac_of_data structure inside the include/linux/stmmac.h header file.
+
+4.11) This is a summary of the content of some relevant files:
+ o stmmac_main.c: to implement the main network device driver;
+ o stmmac_mdio.c: to provide mdio functions;
+ o stmmac_pci: this the PCI driver;
+ o stmmac_platform.c: this the platform driver (OF supported)
+ o stmmac_ethtool.c: to implement the ethtool support;
  o stmmac.h: private driver structure;
  o common.h: common definitions and VFTs;
  o descs.h: descriptor structure definitions;
- o dwmac1000_core.c: GMAC core functions;
- o dwmac1000_dma.c:  dma functions for the GMAC chip;
- o dwmac1000.h: specific header file for the GMAC;
- o dwmac100_core: MAC 100 core and dma code;
- o dwmac100_dma.c: dma functions for the MAC chip;
+ o dwmac1000_core.c: dwmac GiGa core functions;
+ o dwmac1000_dma.c: dma functions for the GMAC chip;
+ o dwmac1000.h: specific header file for the dwmac GiGa;
+ o dwmac100_core: dwmac 100 core code;
+ o dwmac100_dma.c: dma functions for the dwmac 100 chip;
  o dwmac1000.h: specific header file for the MAC;
- o dwmac_lib.c: generic DMA functions shared among chips;
+ o dwmac_lib.c: generic DMA functions;
  o enh_desc.c: functions for handling enhanced descriptors;
  o norm_desc.c: functions for handling normal descriptors;
  o chain_mode.c/ring_mode.c:: functions to manage RING/CHAINED modes;
  o mmc_core.c/mmc.h: Management MAC Counters;
- o stmmac_hwtstamp.c: HW timestamp support for PTP
- o stmmac_ptp.c: PTP 1588 clock
+ o stmmac_hwtstamp.c: HW timestamp support for PTP;
+ o stmmac_ptp.c: PTP 1588 clock;
+ o dwmac-<XXX>.c: these are for the platform glue-logic file; e.g. dwmac-sti.c
+   for STMicroelectronics SoCs.
 
 5) Debug Information
 
@@ -298,23 +318,14 @@ to get statistics: e.g. using: ethtool -S ethX
 (that shows the Management counters (MMC) if supported)
 or sees the MAC/DMA registers: e.g. using: ethtool -d ethX
 
-Compiling the Kernel with CONFIG_DEBUG_FS and enabling the
-STMMAC_DEBUG_FS option the driver will export the following
+Compiling the Kernel with CONFIG_DEBUG_FS the driver will export the following
 debugfs entries:
 
 /sys/kernel/debug/stmmaceth/descriptors_status
   To show the DMA TX/RX descriptor rings
 
-Developer can also use the "debug" module parameter to get
-further debug information.
-
-In the end, there are other macros (that cannot be enabled
-via menuconfig) to turn-on the RX/TX DMA debugging,
-specific MAC core debug printk etc. Others to enable the
-debug in the TX and RX processes.
-All these are only useful during the developing stage
-and should never enabled inside the code for general usage.
-In fact, these can generate an huge amount of debug messages.
+Developer can also use the "debug" module parameter to get further debug
+information (please see: NETIF Msg Level).
 
 6) Energy Efficient Ethernet
 
@@ -337,15 +348,7 @@ To enter in Tx LPI mode the driver needs to have a software timer
 that enable and disable the LPI mode when there is nothing to be
 transmitted.
 
-7) Extended descriptors
-The extended descriptors give us information about the receive Ethernet payload
-when it is carrying PTP packets or TCP/UDP/ICMP over IP.
-These are not available on GMAC Synopsys chips older than the 3.50.
-At probe time the driver will decide if these can be actually used.
-This support also is mandatory for PTPv2 because the extra descriptors 6 and 7
-are used for saving the hardware timestamps.
-
-8) Precision Time Protocol (PTP)
+7) Precision Time Protocol (PTP)
 The driver supports the IEEE 1588-2002, Precision Time Protocol (PTP),
 which enables precise synchronization of clocks in measurement and
 control systems implemented with technologies such as network
@@ -355,7 +358,7 @@ In addition to the basic timestamp features mentioned in IEEE 1588-2002
 Timestamps, new GMAC cores support the advanced timestamp features.
 IEEE 1588-2008 that can be enabled when configure the Kernel.
 
-9) SGMII/RGMII supports
+8) SGMII/RGMII supports
 New GMAC devices provide own way to manage RGMII/SGMII.
 This information is available at run-time by looking at the
 HW capability register. This means that the stmmac can manage
@@ -364,8 +367,3 @@ In fact, the HW provides a subset of extended registers to
 restart the ANE, verify Full/Half duplex mode and Speed.
 Also thanks to these registers it is possible to look at the
 Auto-negotiated Link Parter Ability.
-
-10) TODO:
- o XGMAC is not supported.
- o Complete the TBI & RTBI support.
- o extend VLAN support for 3.70a SYNP GMAC.
-- 
1.7.4.4
