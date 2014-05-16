From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 2/2] tlan: Enable link monitoring
Date: Fri, 16 May 2014 20:00:30 +0200
Message-ID: <1400263230-2599-2-git-send-email-linux@rainbow-software.org>
References: <1400263230-2599-1-git-send-email-linux@rainbow-software.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400263230-2599-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable old link monitoring code and modify it:
 - control LINK LED
 - use separate timer so it does not interfere with ACT LED
 - reset adapter on link loss to restart autonegotiation
   (required to switch between 10/100 Mbps on OC-2326)

Tested with Olicom OC-2326.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/ethernet/ti/tlan.c |  115 +++++++++++++++++-----------------------
 drivers/net/ethernet/ti/tlan.h |    3 +-
 2 files changed, 50 insertions(+), 68 deletions(-)

diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index e7449cb..43aa904 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -69,10 +69,6 @@ MODULE_AUTHOR("Maintainer: Samuel Chessman <chessman@tux.org>");
 MODULE_DESCRIPTION("Driver for TI ThunderLAN based ethernet PCI adapters");
 MODULE_LICENSE("GPL");
 
-
-/* Define this to enable Link beat monitoring */
-#undef MONITOR
-
 /* Turn on debugging. See Documentation/networking/tlan.txt for details */
 static  int		debug;
 module_param(debug, int, 0);
@@ -194,9 +190,7 @@ static void	tlan_phy_power_up(struct net_device *);
 static void	tlan_phy_reset(struct net_device *);
 static void	tlan_phy_start_link(struct net_device *);
 static void	tlan_phy_finish_auto_neg(struct net_device *);
-#ifdef MONITOR
-static void     tlan_phy_monitor(struct net_device *);
-#endif
+static void     tlan_phy_monitor(unsigned long);
 
 /*
   static int	tlan_phy_nop(struct net_device *);
@@ -340,6 +334,7 @@ static void tlan_stop(struct net_device *dev)
 {
 	struct tlan_priv *priv = netdev_priv(dev);
 
+	del_timer_sync(&priv->media_timer);
 	tlan_read_and_clear_stats(dev, TLAN_RECORD);
 	outl(TLAN_HC_AD_RST, dev->base_addr + TLAN_HOST_CMD);
 	/* Reset and power down phy */
@@ -889,6 +884,7 @@ static int tlan_open(struct net_device *dev)
 	}
 
 	init_timer(&priv->timer);
+	init_timer(&priv->media_timer);
 
 	tlan_start(dev);
 
@@ -1811,11 +1807,6 @@ static void tlan_timer(unsigned long data)
 	priv->timer.function = NULL;
 
 	switch (priv->timer_type) {
-#ifdef MONITOR
-	case TLAN_TIMER_LINK_BEAT:
-		tlan_phy_monitor(dev);
-		break;
-#endif
 	case TLAN_TIMER_PHY_PDOWN:
 		tlan_phy_power_down(dev);
 		break;
@@ -1859,8 +1850,6 @@ static void tlan_timer(unsigned long data)
 }
 
 
-
-
 /*****************************************************************************
 ******************************************************************************
 
@@ -2258,42 +2247,39 @@ tlan_finish_reset(struct net_device *dev)
 		tlan_mii_read_reg(dev, phy, MII_GEN_STS, &status);
 		udelay(1000);
 		tlan_mii_read_reg(dev, phy, MII_GEN_STS, &status);
-		if ((status & MII_GS_LINK) &&
-		    /* We only support link info on Nat.Sem. PHY's */
-		    (tlphy_id1 == NAT_SEM_ID1) &&
-		    (tlphy_id2 == NAT_SEM_ID2)) {
-			tlan_mii_read_reg(dev, phy, MII_AN_LPA, &partner);
-			tlan_mii_read_reg(dev, phy, TLAN_TLPHY_PAR, &tlphy_par);
-
-			netdev_info(dev,
-				    "Link active with %s %uMbps %s-Duplex\n",
-				    !(tlphy_par & TLAN_PHY_AN_EN_STAT)
-				    ? "forced" : "Autonegotiation enabled,",
-				    tlphy_par & TLAN_PHY_SPEED_100
-				    ? 100 : 10,
-				    tlphy_par & TLAN_PHY_DUPLEX_FULL
-				    ? "Full" : "Half");
-
-			if (tlphy_par & TLAN_PHY_AN_EN_STAT) {
-				netdev_info(dev, "Partner capability:");
-				for (i = 5; i < 10; i++)
-					if (partner & (1 << i))
-						pr_cont(" %s", media[i-5]);
-				pr_cont("\n");
-			}
-
-			tlan_dio_write8(dev->base_addr, TLAN_LED_REG,
-					TLAN_LED_LINK);
-#ifdef MONITOR
-			/* We have link beat..for now anyway */
-			priv->link = 1;
-			/*Enabling link beat monitoring */
-			tlan_set_timer(dev, (10*HZ), TLAN_TIMER_LINK_BEAT);
-#endif
-		} else if (status & MII_GS_LINK)  {
-			netdev_info(dev, "Link active\n");
-			tlan_dio_write8(dev->base_addr, TLAN_LED_REG,
-					TLAN_LED_LINK);
+		if (status & MII_GS_LINK) {
+			/* We only support link info on Nat.Sem. PHY's */
+			if ((tlphy_id1 == NAT_SEM_ID1) &&
+			    (tlphy_id2 == NAT_SEM_ID2)) {
+				tlan_mii_read_reg(dev, phy, MII_AN_LPA,
+					&partner);
+				tlan_mii_read_reg(dev, phy, TLAN_TLPHY_PAR,
+					&tlphy_par);
+
+				netdev_info(dev,
+					"Link active, %s %uMbps %s-Duplex\n",
+					!(tlphy_par & TLAN_PHY_AN_EN_STAT)
+					? "forced" : "Autonegotiation enabled,",
+					tlphy_par & TLAN_PHY_SPEED_100
+					? 100 : 10,
+					tlphy_par & TLAN_PHY_DUPLEX_FULL
+					? "Full" : "Half");
+
+				if (tlphy_par & TLAN_PHY_AN_EN_STAT) {
+					netdev_info(dev, "Partner capability:");
+					for (i = 5; i < 10; i++)
+						if (partner & (1 << i))
+							pr_cont(" %s",
+								media[i-5]);
+					pr_cont("\n");
+				}
+			} else
+				netdev_info(dev, "Link active\n");
+			/* Enabling link beat monitoring */
+			priv->media_timer.function = tlan_phy_monitor;
+			priv->media_timer.data = (unsigned long) dev;
+			priv->media_timer.expires = jiffies + HZ;
+			add_timer(&priv->media_timer);
 		}
 	}
 
@@ -2315,6 +2301,7 @@ tlan_finish_reset(struct net_device *dev)
 			     dev->base_addr + TLAN_HOST_CMD + 1);
 		outl(priv->rx_list_dma, dev->base_addr + TLAN_CH_PARM);
 		outl(TLAN_HC_GO | TLAN_HC_RT, dev->base_addr + TLAN_HOST_CMD);
+		tlan_dio_write8(dev->base_addr, TLAN_LED_REG, TLAN_LED_LINK);
 		netif_carrier_on(dev);
 	} else {
 		netdev_info(dev, "Link inactive, will retry in 10 secs...\n");
@@ -2720,7 +2707,6 @@ static void tlan_phy_finish_auto_neg(struct net_device *dev)
 
 }
 
-#ifdef MONITOR
 
 /*********************************************************************
  *
@@ -2730,18 +2716,18 @@ static void tlan_phy_finish_auto_neg(struct net_device *dev)
  *	      None
  *
  *     Params:
- *	      dev	     The device structure of this device.
+ *	      data	     The device structure of this device.
  *
  *
  *     This function monitors PHY condition by reading the status
- *     register via the MII bus. This can be used to give info
- *     about link changes (up/down), and possible switch to alternate
- *     media.
+ *     register via the MII bus, controls LINK LED and notifies the
+ *     kernel about link state.
  *
  *******************************************************************/
 
-void tlan_phy_monitor(struct net_device *dev)
+static void tlan_phy_monitor(unsigned long data)
 {
+	struct net_device *dev = (struct net_device *) data;
 	struct tlan_priv *priv = netdev_priv(dev);
 	u16     phy;
 	u16     phy_status;
@@ -2753,30 +2739,27 @@ void tlan_phy_monitor(struct net_device *dev)
 
 	/* Check if link has been lost */
 	if (!(phy_status & MII_GS_LINK)) {
-		if (priv->link) {
-			priv->link = 0;
+		if (netif_carrier_ok(dev)) {
 			printk(KERN_DEBUG "TLAN: %s has lost link\n",
 			       dev->name);
+			tlan_dio_write8(dev->base_addr, TLAN_LED_REG, 0);
 			netif_carrier_off(dev);
-			tlan_set_timer(dev, (2*HZ), TLAN_TIMER_LINK_BEAT);
+			tlan_reset_adapter(dev);
 			return;
 		}
 	}
 
 	/* Link restablished? */
-	if ((phy_status & MII_GS_LINK) && !priv->link) {
-		priv->link = 1;
+	if ((phy_status & MII_GS_LINK) && !netif_carrier_ok(dev)) {
+		tlan_dio_write8(dev->base_addr, TLAN_LED_REG, TLAN_LED_LINK);
 		printk(KERN_DEBUG "TLAN: %s has reestablished link\n",
 		       dev->name);
 		netif_carrier_on(dev);
 	}
-
-	/* Setup a new monitor */
-	tlan_set_timer(dev, (2*HZ), TLAN_TIMER_LINK_BEAT);
+	priv->media_timer.expires = jiffies + HZ;
+	add_timer(&priv->media_timer);
 }
 
-#endif /* MONITOR */
-
 
 /*****************************************************************************
 ******************************************************************************
diff --git a/drivers/net/ethernet/ti/tlan.h b/drivers/net/ethernet/ti/tlan.h
index 2eb33a2..4ced905 100644
--- a/drivers/net/ethernet/ti/tlan.h
+++ b/drivers/net/ethernet/ti/tlan.h
@@ -195,6 +195,7 @@ struct tlan_priv {
 	u32			timer_set_at;
 	u32			timer_type;
 	struct timer_list	timer;
+	struct timer_list	media_timer;
 	struct board		*adapter;
 	u32			adapter_rev;
 	u32			aui;
@@ -206,7 +207,6 @@ struct tlan_priv {
 	u8			tlan_rev;
 	u8			tlan_full_duplex;
 	spinlock_t		lock;
-	u8			link;
 	struct work_struct			tlan_tqueue;
 	u8			neg_be_verbose;
 };
@@ -219,7 +219,6 @@ struct tlan_priv {
 	 *
 	 ****************************************************************/
 
-#define TLAN_TIMER_LINK_BEAT		1
 #define TLAN_TIMER_ACTIVITY		2
 #define TLAN_TIMER_PHY_PDOWN		3
 #define TLAN_TIMER_PHY_PUP		4
-- 
Ondrej Zary
