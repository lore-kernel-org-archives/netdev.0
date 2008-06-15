From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 6/9] DM9000: Allow the use of the NSR register to get link status.
Date: Mon, 16 Jun 2008 00:26:59 +0100
Message-ID: <20080615232815.765902209@fluff.org.uk>
References: <20080615232653.642837440@fluff.org.uk>
Cc: Jeff Garzik <jeff@garzik.org>, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:54117 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756514AbYFOX2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 19:28:17 -0400
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-linkstatus2.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DM9000's internal PHY reports a copy of the link status
in the NSR register of the chip. Reading the status when
polling for link status is faster as it eliminates the need
to sleep, but does not print as much information.

Add an platform flag to force this behaviour, and a Kconfig
option to allow it to be forced to the faster method always.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.26-rc6-quilt1/drivers/net/Kconfig
===================================================================
--- linux-2.6.26-rc6-quilt1.orig/drivers/net/Kconfig	2008-06-15 23:43:43.000000000 +0100
+++ linux-2.6.26-rc6-quilt1/drivers/net/Kconfig	2008-06-15 23:45:20.000000000 +0100
@@ -926,6 +926,15 @@ config DM9000
 	  To compile this driver as a module, choose M here.  The module
 	  will be called dm9000.
 
+config DM9000_FORCE_SIMPLE_PHY_POLL
+	bool "Force simple NSR based PHY polling"
+	depends on DM9000
+	---help---
+	  This configuration forces the DM9000 to use the NSR's LinkStatus
+	  bit to determine if the link is up or down instead of the more
+	  costly MII PHY reads. Note, this will not work if the chip is
+	  operating with an external PHY.
+
 config ENC28J60
 	tristate "ENC28J60 support"
 	depends on EXPERIMENTAL && SPI && NET_ETHERNET
Index: linux-2.6.26-rc6-quilt1/drivers/net/dm9000.c
===================================================================
--- linux-2.6.26-rc6-quilt1.orig/drivers/net/dm9000.c	2008-06-15 23:41:24.000000000 +0100
+++ linux-2.6.26-rc6-quilt1/drivers/net/dm9000.c	2008-06-15 23:43:18.000000000 +0100
@@ -558,7 +558,11 @@ dm9000_poll_work(struct work_struct *w)
 	struct delayed_work *dw = container_of(w, struct delayed_work, work);
 	board_info_t *db = container_of(dw, board_info_t, phy_poll);
 
-	mii_check_media(&db->mii, netif_msg_link(db), 0);
+	if (db->flags & DM9000_PLATF_SIMPLE_PHY &&
+	    !(db->flags & DM9000_PLATF_EXT_PHY)) {
+		
+	} else
+		mii_check_media(&db->mii, netif_msg_link(db), 0);
 	
 	if (netif_running(db->ndev))
 		dm9000_schedule_poll(db);
Index: linux-2.6.26-rc6-quilt1/include/linux/dm9000.h
===================================================================
--- linux-2.6.26-rc6-quilt1.orig/include/linux/dm9000.h	2008-06-15 23:42:01.000000000 +0100
+++ linux-2.6.26-rc6-quilt1/include/linux/dm9000.h	2008-06-15 23:42:47.000000000 +0100
@@ -21,6 +21,7 @@
 #define DM9000_PLATF_32BITONLY	(0x0004)
 #define DM9000_PLATF_EXT_PHY	(0x0008)
 #define DM9000_PLATF_NO_EEPROM	(0x0010)
+#define DM9000_PLATF_SIMPLE_PHY (0x0020)  /* Use NSR to find LinkStatus */
 
 /* platfrom data for platfrom device structure's platfrom_data field */
 

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
