From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch v2 07/11] DM9000: Allow the use of the NSR register to get link status.
Date: Sun, 22 Jun 2008 21:16:52 +0100
Message-ID: <20080622201905.832364471@fluff.org.uk>
References: <20080622201645.041001353@fluff.org.uk>
Cc: jeff@garzik.org, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:56677 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754599AbYFVUTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2008 16:19:08 -0400
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

Index: linux-2.6.26-rc7-next20080620/drivers/net/Kconfig
===================================================================
--- linux-2.6.26-rc7-next20080620.orig/drivers/net/Kconfig	2008-06-22 21:08:46.000000000 +0100
+++ linux-2.6.26-rc7-next20080620/drivers/net/Kconfig	2008-06-22 21:12:24.000000000 +0100
@@ -938,6 +938,15 @@ config DM9000
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
Index: linux-2.6.26-rc7-next20080620/drivers/net/dm9000.c
===================================================================
--- linux-2.6.26-rc7-next20080620.orig/drivers/net/dm9000.c	2008-06-22 21:12:23.000000000 +0100
+++ linux-2.6.26-rc7-next20080620/drivers/net/dm9000.c	2008-06-22 21:12:24.000000000 +0100
@@ -552,15 +552,43 @@ static const struct ethtool_ops dm9000_e
  	.set_eeprom		= dm9000_set_eeprom,
 };
 
+static const char *dm9000_conv_carrier(unsigned status)
+{
+	return status ? "up" : "down";
+}
+
 static void
 dm9000_poll_work(struct work_struct *w)
 {
 	struct delayed_work *dw = container_of(w, struct delayed_work, work);
 	board_info_t *db = container_of(dw, board_info_t, phy_poll);
+	struct net_device *ndev = db->ndev;
 
-	mii_check_media(&db->mii, netif_msg_link(db), 0);
+	if (db->flags & DM9000_PLATF_SIMPLE_PHY &&
+	    !(db->flags & DM9000_PLATF_EXT_PHY)) {
+		unsigned status = dm9000_read_locked(db, DM9000_NSR);
+		unsigned old_carrier = netif_carrier_ok(ndev) ? 1 : 0;
+		unsigned new_carrier;
+
+		new_carrier = (status & NSR_LINKST) ? 1 : 0;
+
+		if (old_carrier != new_carrier) {
+			if (netif_msg_link(db))
+				dev_info(db->dev,
+					 "%s: link changed from %s to %s\n",
+					 ndev->name,
+					 dm9000_conv_carrier(old_carrier),
+					 dm9000_conv_carrier(new_carrier));
+
+			if (!new_carrier)
+				netif_carrier_off(ndev);
+			else
+				netif_carrier_on(ndev);
+		}
+	} else
+		mii_check_media(&db->mii, netif_msg_link(db), 0);
 	
-	if (netif_running(db->ndev))
+	if (netif_running(ndev))
 		dm9000_schedule_poll(db);
 }
 
@@ -1269,6 +1297,10 @@ dm9000_probe(struct platform_device *pde
 		db->flags = pdata->flags;
 	}
 
+#ifdef CONFIG_DM9000_FORCE_SIMPLE_PHY_POLL
+	db->flags |= DM9000_PLATF_SIMPLE_PHY;
+#endif
+
 	dm9000_reset(db);
 
 	/* try multiple times, DM9000 sometimes gets the read wrong */
Index: linux-2.6.26-rc7-next20080620/include/linux/dm9000.h
===================================================================
--- linux-2.6.26-rc7-next20080620.orig/include/linux/dm9000.h	2008-06-22 21:08:46.000000000 +0100
+++ linux-2.6.26-rc7-next20080620/include/linux/dm9000.h	2008-06-22 21:12:24.000000000 +0100
@@ -21,6 +21,7 @@
 #define DM9000_PLATF_32BITONLY	(0x0004)
 #define DM9000_PLATF_EXT_PHY	(0x0008)
 #define DM9000_PLATF_NO_EEPROM	(0x0010)
+#define DM9000_PLATF_SIMPLE_PHY (0x0020)  /* Use NSR to find LinkStatus */
 
 /* platfrom data for platfrom device structure's platfrom_data field */
 

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
