From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next v2 4/9] Documentation: networking: Add Altera Ethernet (TSE) Documentation
Date: Mon, 10 Mar 2014 18:14:32 -0500
Message-ID: <1394493277-2105-5-git-send-email-vbridgers2013@gmail.com>
References: <1394493277-2105-1-git-send-email-vbridgers2013@gmail.com>
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	rob@landley.net, vbridgers2013@gmail.com
To: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:35718 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753899AbaCJXT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 19:19:29 -0400
In-Reply-To: <1394493277-2105-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a bindings description for the Altera Triple Speed Ethernet
(TSE) driver. The bindings support the legacy SGDMA soft IP as well as the
preferred MSGDMA soft IP. The TSE can be configured and synthesized in soft
logic using Altera's Quartus toolchain. Please consult the bindings document
for supported options.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
V2: - Minor edits. No substantial changes to this file.
---
 Documentation/networking/altera_tse.txt |  119 +++++++++++++++++++++++++++++++
 1 file changed, 119 insertions(+)
 create mode 100644 Documentation/networking/altera_tse.txt

diff --git a/Documentation/networking/altera_tse.txt b/Documentation/networking/altera_tse.txt
new file mode 100644
index 0000000..9c3810d
--- /dev/null
+++ b/Documentation/networking/altera_tse.txt
@@ -0,0 +1,119 @@
+       Altera Triple-Speed Ethernet MAC driver
+
+Copyright (C) 2008-2014 Altera Corporation
+
+This is the driver for the Altera Triple-Speed Ethernet (TSE) controllers
+using the SGDMA and MSGDMA soft DMA IP components. The driver uses the
+platform bus to obtain component resources. The designs used to test this
+driver were built for a Cyclone(R) V SOC FPGA board, a Cyclone(R) V FPGA board,
+and tested with ARM and NIOS processor hosts seperately. The anticipated use
+cases are simple communications between an embedded system and an external peer
+for status and simple configuration of the embedded system.
+
+For more information visit www.altera.com and www.rocketboards.org. Support
+forums for the driver may be found on www.rocketboards.org, and a design used
+to test this driver may be found there as well. Support is also available from
+the maintainer of this driver, found in MAINTAINERS.
+
+The Triple-Speed Ethernet, SGDMA, and MSGDMA components are all soft IP
+components that can be assembled and built into an FPGA using the Altera
+Quartus toolchain. Quartus 13.1 and 14.0 were used to build the design that
+this driver was tested against. The sopc2dts tool is used to create the
+device tree for the driver, and may be found at rocketboards.org.
+
+The driver probe function examines the device tree and determines if the
+Triple-Speed Ethernet instance is using an SGDMA or MSGDMA component. The
+probe function then installs the appropriate set of DMA routines to
+initialize, setup transmits, receives, and interrupt handling primitives for
+the respective configurations.
+
+The SGDMA component is to be deprecated in the near future (over the next 1-2
+years as of this writing in early 2014) in favor of the MSGDMA component.
+SGDMA support is included for existing designs and reference in case a
+developer wishes to support their own soft DMA logic and driver support. Any
+new designs should not use the SGDMA.
+
+The SGDMA supports only a single transmit or receive operation at a time, and
+therefore will not perform as well compared to the MSGDMA soft IP. Please
+visit www.altera.com for known, documented SGDMA errata.
+
+Scatter-gather DMA is not supported by the SGDMA or MSGDMA at this time.
+Scatter-gather DMA will be added to a future maintenance update to this
+driver.
+
+Jumbo frames are not supported at this time.
+
+The driver limits PHY operations to 10/100Mbps, and has not yet been fully
+tested for 1Gbps. This support will be added in a future maintenance update.
+
+1) Kernel Configuration
+The kernel configuration option is ALTERA_TSE:
+ Device Drivers ---> Network device support ---> Ethernet driver support --->
+ Altera Triple-Speed Ethernet MAC support (ALTERA_TSE)
+
+2) Driver parameters list:
+	debug: message level (0: no output, 16: all);
+	dma_rx_num: Number of descriptors in the RX list (default is 64);
+	dma_tx_num: Number of descriptors in the TX list (default is 64).
+
+3) Command line options
+Driver parameters can be also passed in command line by using:
+	altera_tse=dma_rx_num:128,dma_tx_num:512
+
+4) Driver information and notes
+
+4.1) Transmit process
+When the driver's transmit routine is called by the kernel, it sets up a
+transmit descriptor by calling the underlying DMA transmit routine (SGDMA or
+MSGDMA), and initites a transmit operation. Once the transmit is complete, an
+interrupt is driven by the transmit DMA logic. The driver handles the transmit
+completion in the context of the interrupt handling chain by recycling
+resource required to send and track the requested transmit operation.
+
+4.2) Receive process
+The driver will post receive buffers to the receive DMA logic during driver
+intialization. Receive buffers may or may not be queued depending upon the
+underlying DMA logic (MSGDMA is able queue receive buffers, SGDMA is not able
+to queue receive buffers to the SGDMA receive logic). When a packet is
+received, the DMA logic generates an interrupt. The driver handles a receive
+interrupt by obtaining the DMA receive logic status, reaping receive
+completions until no more receive completions are available.
+
+4.3) Interrupt Mitigation
+The driver is able to mitigate the number of its DMA interrupts
+using NAPI for receive operations. Interrupt mitigation is not yet supported
+for transmit operations, but will be added in a future maintenance release.
+
+4.4) Ethtool support
+Ethtool is supported. Driver statistics and internal errors can be taken using:
+ethtool -S ethX command. It is possible to dump registers etc.
+
+4.5) PHY Support
+The driver is compatible with PAL to work with PHY and GPHY devices.
+
+4.7) List of source files:
+ o Kconfig
+ o Makefile
+ o altera_tse_main.c: main network device driver
+ o altera_tse_ethtool.c: ethtool support
+ o altera_tse.h: private driver structure and common definitions
+ o altera_msgdma.h: MSGDMA implementation function definitions
+ o altera_sgdma.h: SGDMA implementation function definitions
+ o altera_msgdma.c: MSGDMA implementation
+ o altera_sgdma.c: SGDMA implementation
+ o altera_sgdmahw.h: SGDMA register and descriptor definitions
+ o altera_msgdmahw.h: MSGDMA register and descriptor definitions
+ o altera_utils.c: Driver utility functions
+ o altera_utils.h: Driver utility function definitions
+
+5) Debug Information
+
+The driver exports debug information such as internal statistics,
+debug information, MAC and DMA registers etc.
+
+A user may use the ethtool support to get statistics:
+e.g. using: ethtool -S ethX (that shows the statistics counters)
+or sees the MAC registers: e.g. using: ethtool -d ethX
+
+The developer can also use the "debug" module parameter to get
+further debug information.
-- 
1.7.9.5
