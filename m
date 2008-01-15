From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [Patch 2.6.24 1/1]S2io: Fixed synchronization between scheduling of
 napi with card reset and close
Date: Mon, 14 Jan 2008 20:23:04 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10801142021110.20238-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:41297 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbYAOBXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 20:23:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Fixed synchronization between scheduling of napi with card reset and close 
  by moving the enabling and disabling of napi to card up and card down 
  functions respectively instead of open and close.

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2-0-26-10/drivers/net/s2io.c 2-0-26-17/drivers/net/s2io.c
--- 2-0-26-10/drivers/net/s2io.c	2008-01-10 01:33:53.000000000 +0530
+++ 2-0-26-17/drivers/net/s2io.c	2008-01-10 04:39:15.000000000 +0530
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.10"
+#define DRV_VERSION "2.0.26.17"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -3851,8 +3851,6 @@ static int s2io_open(struct net_device *
 	netif_carrier_off(dev);
 	sp->last_link_state = 0;
 
-	napi_enable(&sp->napi);
-
 	if (sp->config.intr_type == MSI_X) {
 		int ret = s2io_enable_msi_x(sp);
 
@@ -3895,7 +3893,6 @@ static int s2io_open(struct net_device *
 	return 0;
 
 hw_init_failed:
-	napi_disable(&sp->napi);
 	if (sp->config.intr_type == MSI_X) {
 		if (sp->entries) {
 			kfree(sp->entries);
@@ -3935,7 +3932,6 @@ static int s2io_close(struct net_device 
 		return 0;
 
 	netif_stop_queue(dev);
-	napi_disable(&sp->napi);
 	/* Reset card, kill tasklet and free Tx and Rx buffers. */
 	s2io_card_down(sp);
 
@@ -6799,6 +6795,8 @@ static void do_s2io_card_down(struct s2i
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	unsigned long flags;
 	register u64 val64 = 0;
+	struct config_param *config;
+	config = &sp->config;
 
 	if (!is_s2io_card_up(sp))
 		return;
@@ -6810,6 +6808,10 @@ static void do_s2io_card_down(struct s2i
 	}
 	clear_bit(__S2IO_STATE_CARD_UP, &sp->state);
 
+	/* Disable napi */
+	if (config->napi)
+		napi_disable(&sp->napi);
+
 	/* disable Tx and Rx traffic on the NIC */
 	if (do_io)
 		stop_nic(sp);
@@ -6903,6 +6905,11 @@ static int s2io_card_up(struct s2io_nic 
 		DBG_PRINT(INFO_DBG, "Buf in ring:%d is %d:\n", i,
 			  atomic_read(&sp->rx_bufs_left[i]));
 	}
+
+	/* Initialise napi */
+	if (config->napi)
+		napi_enable(&sp->napi);
+
 	/* Maintain the state prior to the open */
 	if (sp->promisc_flg)
 		sp->promisc_flg = 0;

