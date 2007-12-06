From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.24 1/1]S2io: Check for register initialization completion
 before accesing device registers
Date: Wed, 5 Dec 2007 23:59:28 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10712052356570.27705-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:47690 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752224AbXLFE7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 23:59:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Making sure register initialisation is complete before proceeding further.
  The driver must wait until initialization is complete before attempting to 
  access any other device registers.

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
---
diff -Nurp patch_9/drivers/net/s2io.c patch_10/drivers/net/s2io.c
--- patch_9/drivers/net/s2io.c	2007-12-04 23:29:22.000000000 +0530
+++ patch_10/drivers/net/s2io.c	2007-12-04 23:36:48.000000000 +0530
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.6"
+#define DRV_VERSION "2.0.26.10"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -1100,6 +1100,20 @@ static int init_nic(struct s2io_nic *nic
 	msleep(500);
 	val64 = readq(&bar0->sw_reset);
 
+	/* Ensure that it's safe to access registers by checking
+	 * RIC_RUNNING bit is reset. Check is valid only for XframeII.
+	 */
+	if (nic->device_type == XFRAME_II_DEVICE) {
+		for (i = 0; i < 50; i++) {
+			val64 = readq(&bar0->adapter_status);
+			if (!(val64 & ADAPTER_STATUS_RIC_RUNNING))
+				break;
+			msleep(10);
+		}
+		if (i == 50)
+			return -ENODEV;
+	}
+
 	/*  Enable Receiving broadcasts */
 	add = &bar0->mac_cfg;
 	val64 = readq(&bar0->mac_cfg);
diff -Nurp patch_9/drivers/net/s2io-regs.h patch_10/drivers/net/s2io-regs.h
--- patch_9/drivers/net/s2io-regs.h	2007-12-04 23:29:22.000000000 +0530
+++ patch_10/drivers/net/s2io-regs.h	2007-12-04 23:38:24.000000000 +0530
@@ -66,6 +66,7 @@ struct XENA_dev_config {
 #define ADAPTER_STATUS_RC_PRC_QUIESCENT    vBIT(0xFF,16,8)
 #define ADAPTER_STATUS_MC_DRAM_READY       s2BIT(24)
 #define ADAPTER_STATUS_MC_QUEUES_READY     s2BIT(25)
+#define ADAPTER_STATUS_RIC_RUNNING         s2BIT(26)
 #define ADAPTER_STATUS_M_PLL_LOCK          s2BIT(30)
 #define ADAPTER_STATUS_P_PLL_LOCK          s2BIT(31)
 

