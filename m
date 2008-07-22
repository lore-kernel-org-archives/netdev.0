From: David Miller <davem@davemloft.net>
Subject: Re: netif_schedule and mpc5200_fec
Date: Tue, 22 Jul 2008 15:42:01 -0700 (PDT)
Message-ID: <20080722.154201.234654750.davem@davemloft.net>
References: <9e4733910807221247r38509c76uf625195b712a1145@mail.gmail.com>
	<9e4733910807221403g512f6e37s6722c7950f881224@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, davem@redhat.com
To: jonsmirl@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42461
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750961AbYGVWmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 18:42:01 -0400
In-Reply-To: <9e4733910807221403g512f6e37s6722c7950f881224@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jon Smirl" <jonsmirl@gmail.com>
Date: Tue, 22 Jul 2008 17:03:32 -0400

> On 7/22/08, Jon Smirl <jonsmirl@gmail.com> wrote:
> > I just updated to linus/master and mpc5200_fec won't boot.
> 
> It does boot, but this badness looks like it is coming from this
> patch. I don't know enough about networking to debug it.

I just applied the following patch from Anton Vorontsov which
will fix this.

netdev: bunch of drivers: avoid WARN at net/core/dev.c:1328

The drivers were touching net queue before it has been started, so
without this patch, the drivers will potentially WARN at
net/core/dev.c:1328.

I don't have the hardware for the drivers below, so this patch is
untested, and thus should be carefully peer reviewed.

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
Signed-off-by: David S. Miller <davem@davemloft.net>
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
1.5.6.4.433.g09651

