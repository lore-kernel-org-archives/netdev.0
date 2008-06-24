From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch v3 08/12] DM9000: Allow the use of the NSR register to get link status.
Date: Tue, 24 Jun 2008 22:16:04 +0100
Message-ID: <20080624211905.560853599@fluff.org.uk>
References: <20080624211556.566149406@fluff.org.uk>
Cc: jeff@garzik.org, laurentp@cse-semaphore.com,
	Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:63998 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753850AbYFXVTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 17:19:07 -0400
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

Index: linux-2.6.26-rc7-next20080624/drivers/net/Kconfig
===================================================================
--- linux-2.6.26-rc7-next20080624.orig/drivers/net/Kconfig	2008-06-24 22:09:38.000000000 +0100
+++ linux-2.6.26-rc7-next20080624/drivers/net/Kconfig	2008-06-24 22:09:39.000000000 +0100
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
Index: linux-2.6.26-rc7-next20080624/drivers/net/dm9000.c
===================================================================
--- linux-2.6.26-rc7-next20080624.orig/drivers/net/dm9000.c	2008-06-24 22:09:38.000000000 +0100
+++ linux-2.6.26-rc7-next20080624/drivers/net/dm9000.c	2008-06-24 22:09:39.000000000 +0100
@@ -552,15 +552,48 @@ static const struct ethtool_ops dm9000_e
  	.set_eeprom		= dm9000_set_eeprom,
 };
 
+static void dm9000_show_carrier(board_info_t *db,
+				unsigned carrier, unsigned nsr)
+{
+	struct net_device *ndev = db->ndev;
+	unsigned ncr = dm9000_read_locked(db, DM9000_NCR);
+
+	if (carrier)
+		dev_info(db->dev, "%s: link up, %dMbps, %s-duplex, no LPA\n",
+			 ndev->name, (nsr & NSR_SPEED) ? 10 : 100,
+			 (ncr & NCR_FDX) ? "full" : "half");
+	else
+		dev_info(db->dev, "%s: link down\n", ndev->name);
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
+		unsigned nsr = dm9000_read_locked(db, DM9000_NSR);
+		unsigned old_carrier = netif_carrier_ok(ndev) ? 1 : 0;
+		unsigned new_carrier;
+
+		new_carrier = (nsr & NSR_LINKST) ? 1 : 0;
+
+		if (old_carrier != new_carrier) {
+			if (netif_msg_link(db))
+				dm9000_show_carrier(db, new_carrier, nsr);
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
 
@@ -1267,6 +1300,10 @@ dm9000_probe(struct platform_device *pde
 		db->flags = pdata->flags;
 	}
 
+#ifdef CONFIG_DM9000_FORCE_SIMPLE_PHY_POLL
+	db->flags |= DM9000_PLATF_SIMPLE_PHY;
+#endif
+
 	dm9000_reset(db);
 
 	/* try multiple times, DM9000 sometimes gets the read wrong */
Index: linux-2.6.26-rc7-next20080624/include/linux/dm9000.h
===================================================================
--- linux-2.6.26-rc7-next20080624.orig/include/linux/dm9000.h	2008-06-24 22:09:38.000000000 +0100
+++ linux-2.6.26-rc7-next20080624/include/linux/dm9000.h	2008-06-24 22:09:39.000000000 +0100
@@ -21,6 +21,7 @@
 #define DM9000_PLATF_32BITONLY	(0x0004)
 #define DM9000_PLATF_EXT_PHY	(0x0008)
 #define DM9000_PLATF_NO_EEPROM	(0x0010)
+#define DM9000_PLATF_SIMPLE_PHY (0x0020)  /* Use NSR to find LinkStatus */
 
 /* platfrom data for platfrom device structure's platfrom_data field */
 

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
