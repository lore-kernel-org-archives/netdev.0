From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 7/9] vxge: Disable fcs stripping.
Date: Thu, 2 Jul 2009 03:17:24 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10907020316390.13763-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:37657 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540AbZGBHRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 03:17:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Disable fcs stripping. The minimum frame size that can be received by the
hardware is 57 Bytes. A 64 Byte Ethernet frame with the vlan tag and fcs
stripped will result in a 56 Byte frame which will lock up the receive 
engine. The work around is to disable fcs stripping in the hardware which 
is done with a firmware upgrade. The fixes are -
1. Ensure that the correct firmware version is used.
2. Decrement the indicated packet length of the receive packet by 4 bytes
(FCS length).

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
diff -pNur patch-net-next-2.6/drivers/net/vxge/vxge-main.c patch-7-net-next-2.6/drivers/net/vxge/vxge-main.c
--- patch-net-next-2.6/drivers/net/vxge/vxge-main.c	2009-06-30 14:00:28.000000000 -0700
+++ patch-7-net-next-2.6/drivers/net/vxge/vxge-main.c	2009-06-30 17:18:17.000000000 -0700
@@ -454,6 +454,8 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *
 		vxge_hw_ring_rxd_1b_get(ringh, dtr, &dma_sizes);
 		pkt_length = dma_sizes;
 
+		pkt_length -= ETH_FCS_LEN;
+
 		vxge_debug_rx(VXGE_TRACE,
 			"%s: %s:%d  Packet Length = %d",
 			ring->ndev->name, __func__, __LINE__, pkt_length);
@@ -4163,11 +4165,11 @@ vxge_probe(struct pci_dev *pdev, const s
 	}
 
 	if (ll_config.device_hw_info.fw_version.major !=
-		VXGE_DRIVER_VERSION_MAJOR) {
+		VXGE_DRIVER_FW_VERSION_MAJOR) {
 		vxge_debug_init(VXGE_ERR,
-			"FW Ver.(maj): %d not driver's expected version: %d",
-			ll_config.device_hw_info.fw_version.major,
-			VXGE_DRIVER_VERSION_MAJOR);
+			"%s: Incorrect firmware version."
+			"Please upgrade the firmware to version 1.x.x",
+			VXGE_DRIVER_NAME);
 		ret = -EINVAL;
 		goto _exit3;
 	}
diff -pNur patch-net-next-2.6/drivers/net/vxge/vxge-main.h patch-7-net-next-2.6/drivers/net/vxge/vxge-main.h
--- patch-net-next-2.6/drivers/net/vxge/vxge-main.h	2009-06-30 14:00:28.000000000 -0700
+++ patch-7-net-next-2.6/drivers/net/vxge/vxge-main.h	2009-06-30 15:28:04.000000000 -0700
@@ -21,7 +21,7 @@
 
 #define VXGE_DRIVER_NAME		"vxge"
 #define VXGE_DRIVER_VENDOR		"Neterion, Inc"
-#define VXGE_DRIVER_VERSION_MAJOR 0
+#define VXGE_DRIVER_FW_VERSION_MAJOR	1
 
 #define DRV_VERSION	VXGE_VERSION_MAJOR"."VXGE_VERSION_MINOR"."\
 	VXGE_VERSION_FIX"."VXGE_VERSION_BUILD"-"\

