From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.24 1/1]S2io: Fixed the case where stats_info was accessed
 after free in free_shared_mem()
Date: Tue, 11 Dec 2007 04:33:21 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10712110430490.29083-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:50514 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088AbXLKJda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 04:33:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Fixed the case where stats_info was accessed after free in free_shared_mem().

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp patch_10/drivers/net/s2io.c patch_11/drivers/net/s2io.c
--- patch_10/drivers/net/s2io.c	2007-12-04 23:36:48.000000000 +0530
+++ patch_11/drivers/net/s2io.c	2007-12-08 01:05:56.000000000 +0530
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.10"
+#define DRV_VERSION "2.0.26.11"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -941,18 +941,19 @@ static void free_shared_mem(struct s2io_
 		}
 	}
 
+	if (nic->ufo_in_band_v) {
+		nic->mac_control.stats_info->sw_stat.mem_freed
+			+= (ufo_size * sizeof(u64));
+		kfree(nic->ufo_in_band_v);
+	}
+
 	if (mac_control->stats_mem) {
+		nic->mac_control.stats_info->sw_stat.mem_freed +=
+			mac_control->stats_mem_sz;
 		pci_free_consistent(nic->pdev,
 				    mac_control->stats_mem_sz,
 				    mac_control->stats_mem,
 				    mac_control->stats_mem_phy);
-		nic->mac_control.stats_info->sw_stat.mem_freed +=
-			mac_control->stats_mem_sz;
-	}
-	if (nic->ufo_in_band_v) {
-		kfree(nic->ufo_in_band_v);
-		nic->mac_control.stats_info->sw_stat.mem_freed
-			+= (ufo_size * sizeof(u64));
 	}
 }
 

