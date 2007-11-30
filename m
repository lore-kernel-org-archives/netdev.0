From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.24 1/1]S2io: Fixed the case when the card initialization
 fails on mtu change
Date: Fri, 30 Nov 2007 01:46:08 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10711300143550.6586-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:32845 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755981AbXK3GqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2007 01:46:22 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the case when the card initialization fails on a mtu change and then 
close is called (due to ifdown), which frees non existent rx buffers.
- Returning appropriate error codes in init_nic function.
- In s2io_close function s2io_card_down is called only when device is up.
- In s2io_change_mtu function return value of s2io_card_up function
  is checked and returned if it failed.

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp patch_8/drivers/net/s2io.c patch_9/drivers/net/s2io.c
--- patch_8/drivers/net/s2io.c	2007-11-20 23:31:57.000000000 +0530
+++ patch_9/drivers/net/s2io.c	2007-11-20 23:13:24.000000000 +0530
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.8"
+#define DRV_VERSION "2.0.26.9"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -1118,7 +1118,7 @@ static int init_nic(struct s2io_nic *nic
 	/* to set the swapper controle on the card */
 	if(s2io_set_swapper(nic)) {
 		DBG_PRINT(ERR_DBG,"ERROR: Setting Swapper failed\n");
-		return -1;
+		return -EIO;
 	}
 
 	/*
@@ -1540,7 +1540,7 @@ static int init_nic(struct s2io_nic *nic
 			DBG_PRINT(ERR_DBG, "%s: failed rts ds steering",
 				dev->name);
 			DBG_PRINT(ERR_DBG, "set on codepoint %d\n", i);
-			return FAILURE;
+			return -ENODEV;
 		}
 	}
 
@@ -1607,7 +1607,7 @@ static int init_nic(struct s2io_nic *nic
 		if (time > 10) {
 			DBG_PRINT(ERR_DBG, "%s: TTI init Failed\n",
 				  dev->name);
-			return -1;
+			return -ENODEV;
 		}
 		msleep(50);
 		time++;
@@ -1660,7 +1660,7 @@ static int init_nic(struct s2io_nic *nic
 			if (time > 10) {
 				DBG_PRINT(ERR_DBG, "%s: RTI init Failed\n",
 					  dev->name);
-				return -1;
+				return -ENODEV;
 			}
 			time++;
 			msleep(50);
@@ -3946,6 +3946,12 @@ static int s2io_close(struct net_device 
 {
 	struct s2io_nic *sp = dev->priv;
 
+	/* Return if the device is already closed               *
+	*  Can happen when s2io_card_up failed in change_mtu    *
+	*/
+	if (!is_s2io_card_up(sp))
+		return 0;
+
 	netif_stop_queue(dev);
 	napi_disable(&sp->napi);
 	/* Reset card, kill tasklet and free Tx and Rx buffers. */
@@ -6373,6 +6379,7 @@ static int s2io_ioctl(struct net_device 
 static int s2io_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct s2io_nic *sp = dev->priv;
+	int ret = 0;
 
 	if ((new_mtu < MIN_MTU) || (new_mtu > S2IO_JUMBO_SIZE)) {
 		DBG_PRINT(ERR_DBG, "%s: MTU size is invalid.\n",
@@ -6384,9 +6391,11 @@ static int s2io_change_mtu(struct net_de
 	if (netif_running(dev)) {
 		s2io_card_down(sp);
 		netif_stop_queue(dev);
-		if (s2io_card_up(sp)) {
+		ret = s2io_card_up(sp);
+		if (ret) {
 			DBG_PRINT(ERR_DBG, "%s: Device bring up failed\n",
 				  __FUNCTION__);
+			return ret;
 		}
 		if (netif_queue_stopped(dev))
 			netif_wake_queue(dev);
@@ -6397,7 +6406,7 @@ static int s2io_change_mtu(struct net_de
 		writeq(vBIT(val64, 2, 14), &bar0->rmac_max_pyld_len);
 	}
 
-	return 0;
+	return ret;
 }
 
 /**
@@ -6795,6 +6804,9 @@ static void do_s2io_card_down(struct s2i
 	unsigned long flags;
 	register u64 val64 = 0;
 
+	if (!is_s2io_card_up(sp))
+		return;
+
 	del_timer_sync(&sp->alarm_timer);
 	/* If s2io_set_link task is executing, wait till it completes. */
 	while (test_and_set_bit(__S2IO_STATE_LINK_TASK, &(sp->state))) {
@@ -6868,11 +6880,13 @@ static int s2io_card_up(struct s2io_nic 
 	u16 interruptible;
 
 	/* Initialize the H/W I/O registers */
-	if (init_nic(sp) != 0) {
+	ret = init_nic(sp);
+	if (ret != 0) {
 		DBG_PRINT(ERR_DBG, "%s: H/W initialization failed\n",
 			  dev->name);
-		s2io_reset(sp);
-		return -ENODEV;
+		if (ret != -EIO)
+			s2io_reset(sp);
+		return ret;
 	}
 
 	/*

