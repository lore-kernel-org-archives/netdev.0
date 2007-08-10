From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Subject: [PATCH 2.6.24]S2io: Default to IntA interrupt type when there are
 less than 4 CPUs in the system.
Date: Fri, 10 Aug 2007 01:04:00 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10708100059390.18391-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:52692 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715AbXHJFEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 01:04:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Default to IntA interrupt type when there are less than 4 CPUs in the system.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2.0.26.2/drivers/net/s2io.c 2.0.26.3/drivers/net/s2io.c
--- 2.0.26.2/drivers/net/s2io.c	2007-08-07 13:39:45.000000000 -0700
+++ 2.0.26.3/drivers/net/s2io.c	2007-08-07 15:51:45.000000000 -0700
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.2"
+#define DRV_VERSION "2.0.26.3"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -452,7 +452,7 @@ S2IO_PARM_INT(l3l4hdr_size, 128);
 /* Frequency of Rx desc syncs expressed as power of 2 */
 S2IO_PARM_INT(rxsync_frequency, 3);
 /* Interrupt type. Values can be 0(INTA), 2(MSI_X) */
-S2IO_PARM_INT(intr_type, 2);
+S2IO_PARM_INT(intr_type, DEF_MSI_X);
 /* Large receive offload feature */
 S2IO_PARM_INT(lro, 0);
 /* Max pkts to be aggregated by LRO at one time. If not specified,
@@ -7671,10 +7671,11 @@ static int s2io_verify_parm(struct pci_d
 	if (*dev_intr_type != INTA)
 		napi = 0;
 
-	if ((*dev_intr_type != INTA) && (*dev_intr_type != MSI_X)) {
+	if ((intr_type != INTA) && (intr_type != MSI_X)) {
 		DBG_PRINT(ERR_DBG, "s2io: Wrong intr_type requested. "
 			  "Defaulting to INTA\n");
 		*dev_intr_type = INTA;
+		intr_type = INTA;
 	}
 
 	if ((*dev_intr_type == MSI_X) &&
@@ -7752,8 +7753,19 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	struct mac_info *mac_control;
 	struct config_param *config;
 	int mode;
-	u8 dev_intr_type = intr_type;
+	u8 dev_intr_type;
+	int no_cpus = 1;
 
+	no_cpus = num_online_cpus();
+	if(DEF_MSI_X == intr_type) {
+		/* Don't enable MSI-X if there are less than 4 CPUs */
+		if(no_cpus < 4)
+			intr_type = INTA;
+		else
+			intr_type = MSI_X;
+	}
+
+	dev_intr_type = intr_type;
 	if ((ret = s2io_verify_parm(pdev, &dev_intr_type)))
 		return ret;
 
diff -Nurp 2.0.26.2/drivers/net/s2io.h 2.0.26.3/drivers/net/s2io.h
--- 2.0.26.2/drivers/net/s2io.h	2007-08-07 13:39:45.000000000 -0700
+++ 2.0.26.3/drivers/net/s2io.h	2007-08-07 13:40:18.000000000 -0700
@@ -433,6 +433,7 @@ struct config_param {
 	u64 tx_intr_type;
 #define INTA	0
 #define MSI_X	2
+#define	DEF_MSI_X	99
 	u8 intr_type;
 	u8 napi;
 

