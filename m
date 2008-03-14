From: Stefan Roese <sr@denx.de>
Subject: [PATCH] net: NEWEMAC: Add desc-base-addr-high property to McMAL node
Date: Fri, 14 Mar 2008 13:53:59 +0100
Message-ID: <1205499239-17959-1-git-send-email-sr@denx.de>
Cc: benh@kernel.crashing.org
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:51020 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858AbYCNMyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2008 08:54:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Upper 4 bits (35...32) of the 36bit MAL descriptor base address. This
value will be written into the MAL_TXBADDR/MAL_RXBADDR registers. It can
be used to move the descriptors into the high bandwidth PLB segment on
some platforms (e.g. 460EX/GT) for performance enhancement. Defaults to 0
when not defined.

Signed-off-by: Stefan Roese <sr@denx.de>
---
 Documentation/powerpc/booting-without-of.txt |   17 ++++++++++++-----
 drivers/net/ibm_newemac/mal.c                |   20 ++++++++++++++++++--
 drivers/net/ibm_newemac/mal.h                |    2 ++
 3 files changed, 32 insertions(+), 7 deletions(-)

diff --git a/Documentation/powerpc/booting-without-of.txt b/Documentation/powerpc/booting-without-of.txt
index 7b4e8a7..4cfa0e2 100644
--- a/Documentation/powerpc/booting-without-of.txt
+++ b/Documentation/powerpc/booting-without-of.txt
@@ -979,7 +979,7 @@ compatibility.
       translation of SOC addresses for memory mapped SOC registers.
     - bus-frequency: Contains the bus frequency for the SOC node.
       Typically, the value of this field is filled in by the boot
-      loader. 
+      loader.
 
 
   Recommended properties:
@@ -1388,7 +1388,7 @@ platforms are moved over to use the flattened-device-tree model.
    The device node for a USB controller that is part of a Freescale
    SOC is as described in the document "Open Firmware Recommended
    Practice : Universal Serial Bus" with the following modifications
-   and additions :  
+   and additions :
 
    Required properties :
     - compatible : Should be "fsl-usb2-mph" for multi port host USB
@@ -1399,11 +1399,11 @@ platforms are moved over to use the flattened-device-tree model.
     - reg : Offset and length of the register set for the device
     - port0 : boolean; if defined, indicates port0 is connected for
       fsl-usb2-mph compatible controllers.  Either this property or
-      "port1" (or both) must be defined for "fsl-usb2-mph" compatible 
+      "port1" (or both) must be defined for "fsl-usb2-mph" compatible
       controllers.
     - port1 : boolean; if defined, indicates port1 is connected for
       fsl-usb2-mph compatible controllers.  Either this property or
-      "port0" (or both) must be defined for "fsl-usb2-mph" compatible 
+      "port0" (or both) must be defined for "fsl-usb2-mph" compatible
       controllers.
     - dr_mode : indicates the working mode for "fsl-usb2-dr" compatible
       controllers.  Can be "host", "peripheral", or "otg".  Default to
@@ -2286,6 +2286,13 @@ platforms are moved over to use the flattened-device-tree model.
     - dcr-parent         : if needed for dcr-reg
     - num-tx-chans       : 1 cell, number of Tx channels
     - num-rx-chans       : 1 cell, number of Rx channels
+    - desc-base-addr-high: 1 cell, Upper 4 bits (35...32) of the 36bit MAL
+			   descriptor base address. Will be written into the
+			   MAL_TXBADDR/MAL_RXBADDR registers. Can be used to
+			   move the descriptors into the high bandwidth PLB
+			   segment on some platforms (e.g. 460EX/GT) for
+			   performance enhancement. Defaults to 0 when not
+			   defined.
 
       iii) ZMII node
 
@@ -2570,7 +2577,7 @@ platforms are moved over to use the flattened-device-tree model.
       listed above, nodes for these devices should include a phy-handle
       property, and may include other common network device properties
       like local-mac-address.
-      
+
       iv) Xilinx Uartlite
 
       Xilinx uartlite devices are simple fixed speed serial ports.
diff --git a/drivers/net/ibm_newemac/mal.c b/drivers/net/ibm_newemac/mal.c
index 6869f08..31fad11 100644
--- a/drivers/net/ibm_newemac/mal.c
+++ b/drivers/net/ibm_newemac/mal.c
@@ -477,6 +477,7 @@ static int __devinit mal_probe(struct of_device *ofdev,
 	unsigned int dcr_base;
 	const u32 *prop;
 	u32 cfg;
+	u32 desc_base_addr_high = 0;
 
 	mal = kzalloc(sizeof(struct mal_instance), GFP_KERNEL);
 	if (!mal) {
@@ -582,15 +583,30 @@ static int __devinit mal_probe(struct of_device *ofdev,
 	}
 	memset(mal->bd_virt, 0, bd_size);
 
-	for (i = 0; i < mal->num_tx_chans; ++i)
+	prop = of_get_property(ofdev->node, "desc-base-addr-high", NULL);
+	if (prop != NULL)
+		desc_base_addr_high = prop[0];
+
+	/*
+	 * To update the 36bit address for each MAL channel descriptor,
+	 * the 4 msb's in MAL_TXBADDR/MAL_RXBADDR have to be written
+	 * each time before the 32 lsb's are written
+	 */
+	for (i = 0; i < mal->num_tx_chans; ++i) {
+		if (desc_base_addr_high)
+			set_mal_dcrn(mal, MAL_TXBADDR, desc_base_addr_high);
 		set_mal_dcrn(mal, MAL_TXCTPR(i), mal->bd_dma +
 			     sizeof(struct mal_descriptor) *
 			     mal_tx_bd_offset(mal, i));
+	}
 
-	for (i = 0; i < mal->num_rx_chans; ++i)
+	for (i = 0; i < mal->num_rx_chans; ++i) {
+		if (desc_base_addr_high)
+			set_mal_dcrn(mal, MAL_RXBADDR, desc_base_addr_high);
 		set_mal_dcrn(mal, MAL_RXCTPR(i), mal->bd_dma +
 			     sizeof(struct mal_descriptor) *
 			     mal_rx_bd_offset(mal, i));
+	}
 
 	err = request_irq(mal->serr_irq, mal_serr, 0, "MAL SERR", mal);
 	if (err)
diff --git a/drivers/net/ibm_newemac/mal.h b/drivers/net/ibm_newemac/mal.h
index eaa7262..28f95bf 100644
--- a/drivers/net/ibm_newemac/mal.h
+++ b/drivers/net/ibm_newemac/mal.h
@@ -118,10 +118,12 @@
 #define MAL_TXCARR		0x05
 #define MAL_TXEOBISR		0x06
 #define MAL_TXDEIR		0x07
+#define MAL_TXBADDR		0x09
 #define MAL_RXCASR		0x10
 #define MAL_RXCARR		0x11
 #define MAL_RXEOBISR		0x12
 #define MAL_RXDEIR		0x13
+#define MAL_RXBADDR		0x15
 #define MAL_TXCTPR(n)		((n) + 0x20)
 #define MAL_RXCTPR(n)		((n) + 0x40)
 #define MAL_RCBS(n)		((n) + 0x60)
-- 
1.5.4.4

