From: Ben Dooks <ben-linux@fluff.org>
Subject: DM9000: Use delayed work to update MII PHY state
Date: Thu, 8 May 2008 11:36:42 +0100
Message-ID: <20080508103642.GE30439@fluff.org.uk>
References: <20080428151309.GA30439@fluff.org.uk> <4820865F.70703@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Dooks <ben-linux@fluff.org>,
	Linux Networking <netdev@vger.kernel.org>,
	akpm@linux-foundation.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:54552 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1761111AbYEHKgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 06:36:50 -0400
Content-Disposition: inline
In-Reply-To: <4820865F.70703@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Periodically check the MII PHY status to ensure that the
network layer's link status is updated and the user informed
of any changes.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.25-rc9-quilt2/drivers/net/dm9000.c
===================================================================
--- linux-2.6.25-rc9-quilt2.orig/drivers/net/dm9000.c	2008-04-14 16:41:12.000000000 +0100
+++ linux-2.6.25-rc9-quilt2/drivers/net/dm9000.c	2008-04-15 00:33:08.000000000 +0100
@@ -117,6 +117,9 @@ typedef struct board_info {
 
 	struct mutex	 addr_lock;	/* phy and eeprom access lock */
 
+	struct delayed_work phy_poll;
+	struct net_device  *ndev;
+
 	spinlock_t lock;
 
 	struct mii_if_info mii;
@@ -297,6 +300,10 @@ static void dm9000_set_io(struct board_i
 	}
 }
 
+static void dm9000_schedule_poll(board_info_t *db)
+{
+	schedule_delayed_work(&db->phy_poll, HZ * 2);
+}
 
 /* Our watchdog timed out. Called by the networking layer */
 static void dm9000_timeout(struct net_device *dev)
@@ -465,6 +472,17 @@ static const struct ethtool_ops dm9000_e
  	.set_eeprom		= dm9000_set_eeprom,
 };
 
+static void
+dm9000_poll_work(struct work_struct *w)
+{
+	struct delayed_work *dw = container_of(w, struct delayed_work, work);
+	board_info_t *db = container_of(dw, board_info_t, phy_poll);
+
+	mii_check_media(&db->mii, netif_msg_link(db), 0);
+	
+	if (netif_running(db->ndev))
+		dm9000_schedule_poll(db);
+}
 
 /* dm9000_release_board
  *
@@ -532,10 +550,14 @@ dm9000_probe(struct platform_device *pde
 	memset(db, 0, sizeof (*db));
 
 	db->dev = &pdev->dev;
+	db->ndev = ndev;
 
 	spin_lock_init(&db->lock);
 	mutex_init(&db->addr_lock);
 
+	INIT_DELAYED_WORK(&db->phy_poll, dm9000_poll_work);
+
+
 	if (pdev->num_resources < 2) {
 		ret = -ENODEV;
 		goto out;
@@ -761,6 +783,8 @@ dm9000_open(struct net_device *dev)
 
 	mii_check_media(&db->mii, netif_msg_link(db), 1);
 	netif_start_queue(dev);
+	
+	dm9000_schedule_poll(db);
 
 	return 0;
 }
@@ -879,6 +903,8 @@ dm9000_stop(struct net_device *ndev)
 	if (netif_msg_ifdown(db))
 		dev_dbg(db->dev, "shutting down %s\n", ndev->name);
 
+	cancel_delayed_work(&db->phy_poll);
+
 	netif_stop_queue(ndev);
 	netif_carrier_off(ndev);
 
