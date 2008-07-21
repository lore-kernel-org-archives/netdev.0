From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 3/3] bunch of drivers: avoid BUG at net/core/dev.c:1328
Date: Mon, 21 Jul 2008 19:17:58 +0400
Message-ID: <20080721151758.GC7989@polina.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:13571 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756702AbYGUPSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 11:18:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The drivers were touching net queue before it has been started, so without
this patch, the drivers will potentially BUG at net/core/dev.c:1328.

I don't have the hardware for the drivers below, so this patch is untested,
and thus should be carefully peer reviewed.

tc35815.c
au1000_eth.c
bfin_mac.c
macb.c
^ The four drivers are using phylib, they're calling netif_start_queue()
in open() callback. So trivially remove netif_tx_schedule_all().
Phylib will handle netif_carrier_*().

cpmac.c
fec_mpc52xx.c
fs_enet/fs_enet-main.c
sh_eth.c
^ The same as above, but these were also needlessly calling
netif_carrier_*() functions. So removed queue calls and also remove
carrier calls, since phylib will handle it. fs_enet-main.c also didn't
call netif_start_queue() at open(), this is fixed now.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/au1000_eth.c           |    5 ++---
 drivers/net/bfin_mac.c             |    1 -
 drivers/net/cpmac.c                |    2 --
 drivers/net/fec_mpc52xx.c          |    5 -----
 drivers/net/fs_enet/fs_enet-main.c |    7 ++-----
 drivers/net/macb.c                 |    4 +---
 drivers/net/sh_eth.c               |    5 -----
 drivers/net/tc35815.c              |    1 -
 8 files changed, 5 insertions(+), 25 deletions(-)

diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 3ab61e4..cb8be49 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -911,9 +911,8 @@ au1000_adjust_link(struct net_device *dev)
 	if(phydev->link != aup->old_link) {
 		// link state changed
 
-		if (phydev->link) // link went up
-			netif_tx_schedule_all(dev);
-		else { // link went down
+		if (!phydev->link) {
+			/* link went down */
 			aup->old_speed = 0;
 			aup->old_duplex = -1;
 		}
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index a6a3da8..a8ec60e 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -357,7 +357,6 @@ static void bfin_mac_adjust_link(struct net_device *dev)
 		if (!lp->old_link) {
 			new_state = 1;
 			lp->old_link = 1;
-			netif_tx_schedule_all(dev);
 		}
 	} else if (lp->old_link) {
 		new_state = 1;
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index fbd4280..a7800e5 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -945,10 +945,8 @@ static void cpmac_adjust_link(struct net_device *dev)
 		if (!priv->oldlink) {
 			new_state = 1;
 			priv->oldlink = 1;
-			netif_tx_schedule_all(dev);
 		}
 	} else if (priv->oldlink) {
-		netif_tx_stop_all_queues(dev);
 		new_state = 1;
 		priv->oldlink = 0;
 		priv->oldspeed = 0;
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index ae9ecb7..4e4f683 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -197,9 +197,6 @@ static void mpc52xx_fec_adjust_link(struct net_device *dev)
 		if (priv->link == PHY_DOWN) {
 			new_state = 1;
 			priv->link = phydev->link;
-			netif_tx_schedule_all(dev);
-			netif_carrier_on(dev);
-			netif_start_queue(dev);
 		}
 
 	} else if (priv->link) {
@@ -207,8 +204,6 @@ static void mpc52xx_fec_adjust_link(struct net_device *dev)
 		priv->link = PHY_DOWN;
 		priv->speed = 0;
 		priv->duplex = -1;
-		netif_stop_queue(dev);
-		netif_carrier_off(dev);
 	}
 
 	if (new_state && netif_msg_link(priv))
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 445763e..5291188 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -738,9 +738,6 @@ static void generic_adjust_link(struct  net_device *dev)
 		if (!fep->oldlink) {
 			new_state = 1;
 			fep->oldlink = 1;
-			netif_tx_schedule_all(dev);
-			netif_carrier_on(dev);
-			netif_start_queue(dev);
 		}
 
 		if (new_state)
@@ -750,8 +747,6 @@ static void generic_adjust_link(struct  net_device *dev)
 		fep->oldlink = 0;
 		fep->oldspeed = 0;
 		fep->oldduplex = -1;
-		netif_carrier_off(dev);
-		netif_stop_queue(dev);
 	}
 
 	if (new_state && netif_msg_link(fep))
@@ -826,6 +821,8 @@ static int fs_enet_open(struct net_device *dev)
 	}
 	phy_start(fep->phydev);
 
+	netif_start_queue(dev);
+
 	return 0;
 }
 
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 0496d16..daba82b 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -164,9 +164,7 @@ static void macb_handle_link_change(struct net_device *dev)
 	}
 
 	if (phydev->link != bp->link) {
-		if (phydev->link)
-			netif_tx_schedule_all(dev);
-		else {
+		if (!phydev->link) {
 			bp->speed = 0;
 			bp->duplex = -1;
 		}
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index a4bc812..c69ba13 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -642,17 +642,12 @@ static void sh_eth_adjust_link(struct net_device *ndev)
 					| ECMR_DM, ioaddr + ECMR);
 			new_state = 1;
 			mdp->link = phydev->link;
-			netif_tx_schedule_all(ndev);
-			netif_carrier_on(ndev);
-			netif_start_queue(ndev);
 		}
 	} else if (mdp->link) {
 		new_state = 1;
 		mdp->link = PHY_DOWN;
 		mdp->speed = 0;
 		mdp->duplex = -1;
-		netif_stop_queue(ndev);
-		netif_carrier_off(ndev);
 	}
 
 	if (new_state)
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 41d3ac4..a645e50 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -672,7 +672,6 @@ static void tc_handle_link_change(struct net_device *dev)
 			if (dev->flags & IFF_PROMISC)
 				tc35815_set_multicast_list(dev);
 #endif
-			netif_tx_schedule_all(dev);
 		} else {
 			lp->speed = 0;
 			lp->duplex = -1;
-- 
1.5.5.4
