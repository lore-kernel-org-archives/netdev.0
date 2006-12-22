From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] Fix up smc911x after work_struct changes
Date: Fri, 22 Dec 2006 15:30:01 +0100
Message-ID: <87k60kf1g6.fsf@vps.korsgaard.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, dustin@sensoria.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps.korsgaard.com ([64.79.194.204]:44114 "EHLO
	vps.korsgaard.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423143AbWLVO6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Dec 2006 09:58:09 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix up the smc911x driver after the work_struct changes.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

diff -urpN linux-2.6.20-rc1/drivers/net/smc911x.c linux-2.6.20-rc1.new/drivers/net/smc911x.c
--- linux-2.6.20-rc1/drivers/net/smc911x.c	2006-11-29 22:57:37.000000000 +0100
+++ linux-2.6.20-rc1.new/drivers/net/smc911x.c	2006-12-22 15:13:15.000000000 +0100
@@ -123,6 +123,9 @@ struct smc911x_local {
 	 */
 	struct net_device_stats stats;
 
+	/* parent net device for easy reference in _phy_configure */
+	struct net_device *dev;
+
 	/* version/revision of the SMC911x chip */
 	u16 version;
 	u16 revision;
@@ -948,10 +951,11 @@ static void smc911x_phy_check_media(stru
  * of autonegotiation.)  If the RPC ANEG bit is cleared, the selection
  * is controlled by the RPC SPEED and RPC DPLX bits.
  */
-static void smc911x_phy_configure(void *data)
+static void smc911x_phy_configure(struct work_struct *work)
 {
-	struct net_device *dev = data;
-	struct smc911x_local *lp = netdev_priv(dev);
+	struct smc911x_local *lp =
+	  container_of(work, struct smc911x_local, phy_configure);
+	struct net_device *dev = lp->dev;
 	unsigned long ioaddr = dev->base_addr;
 	int phyaddr = lp->mii.phy_id;
 	int my_phy_caps; /* My PHY capabilities */
@@ -1495,6 +1499,8 @@ static void smc911x_set_multicast_list(s
 static int
 smc911x_open(struct net_device *dev)
 {
+	struct smc911x_local *lp = netdev_priv(dev);
+
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
 
 	/*
@@ -1511,7 +1517,7 @@ smc911x_open(struct net_device *dev)
 	smc911x_reset(dev);
 
 	/* Configure the PHY, initialize the link state */
-	smc911x_phy_configure(dev);
+	smc911x_phy_configure(&lp->phy_configure);
 
 	/* Turn on Tx + Rx */
 	smc911x_enable(dev);
@@ -2060,7 +2066,8 @@ static int __init smc911x_probe(struct n
 	dev->poll_controller = smc911x_poll_controller;
 #endif
 
-	INIT_WORK(&lp->phy_configure, smc911x_phy_configure, dev);
+	INIT_WORK(&lp->phy_configure, smc911x_phy_configure);
+	lp->dev = dev;
 	lp->mii.phy_id_mask = 0x1f;
 	lp->mii.reg_num_mask = 0x1f;
 	lp->mii.force_media = 0;
@@ -2275,7 +2282,7 @@ static int smc911x_drv_resume(struct pla
 			smc911x_reset(ndev);
 			smc911x_enable(ndev);
 			if (lp->phy_type != 0)
-				smc911x_phy_configure(ndev);
+				smc911x_phy_configure(&lp->phy_configure);
 			netif_device_attach(ndev);
 		}
 	}

-- 
Bye, Peter Korsgaard
