From: Ben Dooks <ben-linux@fluff.org>
Subject: DM9000: Add timer to check PHY status
Date: Mon, 14 Apr 2008 14:57:40 +0100
Message-ID: <20080414135740.173350582@fluff.org.uk>
Cc: Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:50788 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756313AbYDNO3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 10:29:09 -0400
Content-Disposition: inline; filename=simtec/simtec-drivers-dm9000-phypoll.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Periodically check the MII PHY status to ensure that the
network layer's link status is updated and the user informed
of any changes.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>


Index: linux-2.6.24-quilt16/drivers/net/dm9000.c
===================================================================
--- linux-2.6.24-quilt16.orig/drivers/net/dm9000.c
+++ linux-2.6.24-quilt16/drivers/net/dm9000.c
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
@@ -881,6 +905,8 @@ dm9000_stop(struct net_device *ndev)
 	if (netif_msg_ifdown(db))
 		dev_dbg(db->dev, "shutting down %s\n", ndev->name);
 
+	cancel_delayed_work(&db->phy_poll);
+
 	netif_stop_queue(ndev);
 	netif_carrier_off(ndev);
 

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
