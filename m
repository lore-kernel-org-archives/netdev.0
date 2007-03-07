From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [PATCH 2/2] S2IO: Save/Restore unused buffer mappings in 2/3
	buffer mode
Date: 06 Mar 2007 17:01:00 -0800
Message-ID: <1173229260.5431.41.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org, santosh.rastapur@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:42090 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932510AbXCGBJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 20:09:47 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Save/Restore unused buffer mappings in 2/3 buffer mode to avoid
frequent mapping

- Save/Restore adapter reset count during adapter reset

  (Resending; forgot to cc netdev)

Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
---
diff -Nurp patch1/drivers/net/s2io.c patch2/drivers/net/s2io.c
--- patch1/drivers/net/s2io.c	2007-03-06 03:29:18.000000000 -0800
+++ patch2/drivers/net/s2io.c	2007-03-06 04:00:41.000000000 -0800
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.17.1"
+#define DRV_VERSION "2.0.19.1"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -2242,6 +2242,7 @@ static int fill_rx_buffers(struct s2io_n
 	struct buffAdd *ba;
 	unsigned long flags;
 	struct RxD_t *first_rxdp = NULL;
+	u64 Buffer0_ptr = 0, Buffer1_ptr = 0;
 
 	mac_control = &nic->mac_control;
 	config = &nic->config;
@@ -2342,7 +2343,14 @@ static int fill_rx_buffers(struct s2io_n
 			 * payload
 			 */
 
+			/* save the buffer pointers to avoid frequent dma mapping */
+			Buffer0_ptr = ((struct RxD3*)rxdp)->Buffer0_ptr;
+			Buffer1_ptr = ((struct RxD3*)rxdp)->Buffer1_ptr;
 			memset(rxdp, 0, sizeof(struct RxD3));
+			/* restore the buffer pointers for dma sync*/
+			((struct RxD3*)rxdp)->Buffer0_ptr = Buffer0_ptr;
+			((struct RxD3*)rxdp)->Buffer1_ptr = Buffer1_ptr;
+
 			ba = &mac_control->rings[ring_no].ba[block_no][off];
 			skb_reserve(skb, BUF0_LEN);
 			tmp = (u64)(unsigned long) skb->data;
@@ -3307,6 +3315,7 @@ static void s2io_reset(struct s2io_nic *
 	u16 subid, pci_cmd;
 	int i;
 	u16 val16;
+	unsigned long long reset_cnt = 0;
 	DBG_PRINT(INIT_DBG,"%s - Resetting XFrame card %s\n",
 			__FUNCTION__, sp->dev->name);
 
@@ -3372,6 +3381,11 @@ new_way:
 
 	/* Reset device statistics maintained by OS */
 	memset(&sp->stats, 0, sizeof (struct net_device_stats));
+	/* save reset count */
+	reset_cnt = sp->mac_control.stats_info->sw_stat.soft_reset_cnt;
+	memset(sp->mac_control.stats_info, 0, sizeof(struct stat_block));
+	/* restore reset count */
+	sp->mac_control.stats_info->sw_stat.soft_reset_cnt = reset_cnt;
 
 	/* SXE-002: Configure link and activity LED to turn it off */
 	subid = sp->pdev->subsystem_device;
@@ -4279,9 +4293,7 @@ static void s2io_updt_stats(struct s2io_
 			if (cnt == 5)
 				break; /* Updt failed */
 		} while(1);
-	} else {
-		memset(sp->mac_control.stats_info, 0, sizeof(struct stat_block));
-	}
+	} 
 }
 
 /**



