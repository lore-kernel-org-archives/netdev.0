From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/4] tg3: Prevent spurious tx timeout by
 setting carrier off before tx disable.
Date: Wed, 14 Nov 2012 16:44:27 -0800
Message-ID: <1352940269-23821-2-git-send-email-mchan@broadcom.com>
References: <1352940269-23821-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4035 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755455Ab2KOAa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2012 19:30:27 -0500
In-Reply-To: <1352940269-23821-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nithin Nayak Sujir <nsujir@broadcom.com>

The watchdog will not trigger when the carrier is off when reconfiguring
the device.  Because carrier state is now off during reset, we need to
introduce a link_up flag to keep track of link state during PHY setup.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   98 ++++++++++++++++++++---------------
 drivers/net/ethernet/broadcom/tg3.h |    1 +
 2 files changed, 57 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 8d4581b..f533e17 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -2473,6 +2473,18 @@ static int tg3_phy_reset_5703_4_5(struct tg3 *tp)
 	return err;
 }
 
+static void tg3_carrier_on(struct tg3 *tp)
+{
+	netif_carrier_on(tp->dev);
+	tp->link_up = true;
+}
+
+static void tg3_carrier_off(struct tg3 *tp)
+{
+	netif_carrier_off(tp->dev);
+	tp->link_up = false;
+}
+
 /* This will reset the tigon3 PHY if there is no valid
  * link unless the FORCE argument is non-zero.
  */
@@ -2491,8 +2503,8 @@ static int tg3_phy_reset(struct tg3 *tp)
 	if (err != 0)
 		return -EBUSY;
 
-	if (netif_running(tp->dev) && netif_carrier_ok(tp->dev)) {
-		netif_carrier_off(tp->dev);
+	if (netif_running(tp->dev) && tp->link_up) {
+		tg3_carrier_off(tp);
 		tg3_link_report(tp);
 	}
 
@@ -4186,6 +4198,24 @@ static bool tg3_phy_copper_fetch_rmtadv(struct tg3 *tp, u32 *rmtadv)
 	return true;
 }
 
+static bool tg3_test_and_report_link_chg(struct tg3 *tp, int curr_link_up)
+{
+	if (curr_link_up != tp->link_up) {
+		if (curr_link_up) {
+			tg3_carrier_on(tp);
+		} else {
+			tg3_carrier_off(tp);
+			if (tp->phy_flags & TG3_PHYFLG_MII_SERDES)
+				tp->phy_flags &= ~TG3_PHYFLG_PARALLEL_DETECT;
+		}
+
+		tg3_link_report(tp);
+		return true;
+	}
+
+	return false;
+}
+
 static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 {
 	int current_link_up;
@@ -4218,7 +4248,7 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703 ||
 	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704 ||
 	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) &&
-	    netif_carrier_ok(tp->dev)) {
+	    tp->link_up) {
 		tg3_readphy(tp, MII_BMSR, &bmsr);
 		if (!tg3_readphy(tp, MII_BMSR, &bmsr) &&
 		    !(bmsr & BMSR_LSTATUS))
@@ -4460,13 +4490,7 @@ relink:
 						 PCI_EXP_LNKCTL_CLKREQ_EN);
 	}
 
-	if (current_link_up != netif_carrier_ok(tp->dev)) {
-		if (current_link_up)
-			netif_carrier_on(tp->dev);
-		else
-			netif_carrier_off(tp->dev);
-		tg3_link_report(tp);
-	}
+	tg3_test_and_report_link_chg(tp, current_link_up);
 
 	return 0;
 }
@@ -5106,7 +5130,7 @@ static int tg3_setup_fiber_phy(struct tg3 *tp, int force_reset)
 	orig_active_duplex = tp->link_config.active_duplex;
 
 	if (!tg3_flag(tp, HW_AUTONEG) &&
-	    netif_carrier_ok(tp->dev) &&
+	    tp->link_up &&
 	    tg3_flag(tp, INIT_COMPLETE)) {
 		mac_status = tr32(MAC_STATUS);
 		mac_status &= (MAC_STATUS_PCS_SYNCED |
@@ -5184,13 +5208,7 @@ static int tg3_setup_fiber_phy(struct tg3 *tp, int force_reset)
 				    LED_CTRL_TRAFFIC_OVERRIDE));
 	}
 
-	if (current_link_up != netif_carrier_ok(tp->dev)) {
-		if (current_link_up)
-			netif_carrier_on(tp->dev);
-		else
-			netif_carrier_off(tp->dev);
-		tg3_link_report(tp);
-	} else {
+	if (!tg3_test_and_report_link_chg(tp, current_link_up)) {
 		u32 now_pause_cfg = tp->link_config.active_flowctrl;
 		if (orig_pause_cfg != now_pause_cfg ||
 		    orig_active_speed != tp->link_config.active_speed ||
@@ -5283,7 +5301,7 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 			new_bmcr |= BMCR_SPEED1000;
 
 			/* Force a linkdown */
-			if (netif_carrier_ok(tp->dev)) {
+			if (tp->link_up) {
 				u32 adv;
 
 				err |= tg3_readphy(tp, MII_ADVERTISE, &adv);
@@ -5295,7 +5313,7 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 							   BMCR_ANRESTART |
 							   BMCR_ANENABLE);
 				udelay(10);
-				netif_carrier_off(tp->dev);
+				tg3_carrier_off(tp);
 			}
 			tg3_writephy(tp, MII_BMCR, new_bmcr);
 			bmcr = new_bmcr;
@@ -5361,15 +5379,7 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 	tp->link_config.active_speed = current_speed;
 	tp->link_config.active_duplex = current_duplex;
 
-	if (current_link_up != netif_carrier_ok(tp->dev)) {
-		if (current_link_up)
-			netif_carrier_on(tp->dev);
-		else {
-			netif_carrier_off(tp->dev);
-			tp->phy_flags &= ~TG3_PHYFLG_PARALLEL_DETECT;
-		}
-		tg3_link_report(tp);
-	}
+	tg3_test_and_report_link_chg(tp, current_link_up);
 	return err;
 }
 
@@ -5381,7 +5391,7 @@ static void tg3_serdes_parallel_detect(struct tg3 *tp)
 		return;
 	}
 
-	if (!netif_carrier_ok(tp->dev) &&
+	if (!tp->link_up &&
 	    (tp->link_config.autoneg == AUTONEG_ENABLE)) {
 		u32 bmcr;
 
@@ -5411,7 +5421,7 @@ static void tg3_serdes_parallel_detect(struct tg3 *tp)
 				tp->phy_flags |= TG3_PHYFLG_PARALLEL_DETECT;
 			}
 		}
-	} else if (netif_carrier_ok(tp->dev) &&
+	} else if (tp->link_up &&
 		   (tp->link_config.autoneg == AUTONEG_ENABLE) &&
 		   (tp->phy_flags & TG3_PHYFLG_PARALLEL_DETECT)) {
 		u32 phy2;
@@ -5477,7 +5487,7 @@ static int tg3_setup_phy(struct tg3 *tp, int force_reset)
 		     (32 << TX_LENGTHS_SLOT_TIME_SHIFT));
 
 	if (!tg3_flag(tp, 5705_PLUS)) {
-		if (netif_carrier_ok(tp->dev)) {
+		if (tp->link_up) {
 			tw32(HOSTCC_STAT_COAL_TICKS,
 			     tp->coal.stats_block_coalesce_usecs);
 		} else {
@@ -5487,7 +5497,7 @@ static int tg3_setup_phy(struct tg3 *tp, int force_reset)
 
 	if (tg3_flag(tp, ASPM_WORKAROUND)) {
 		val = tr32(PCIE_PWR_MGMT_THRESH);
-		if (!netif_carrier_ok(tp->dev))
+		if (!tp->link_up)
 			val = (val & ~PCIE_PWR_MGMT_L1_THRESH_MSK) |
 			      tp->pwrmgmt_thresh;
 		else
@@ -6503,6 +6513,7 @@ static inline void tg3_netif_stop(struct tg3 *tp)
 {
 	tp->dev->trans_start = jiffies;	/* prevent tx timeout */
 	tg3_napi_disable(tp);
+	netif_carrier_off(tp->dev);
 	netif_tx_disable(tp->dev);
 }
 
@@ -6514,6 +6525,9 @@ static inline void tg3_netif_start(struct tg3 *tp)
 	 */
 	netif_tx_wake_all_queues(tp->dev);
 
+	if (tp->link_up)
+		netif_carrier_on(tp->dev);
+
 	tg3_napi_enable(tp);
 	tp->napi[0].hw_status->status |= SD_STATUS_UPDATED;
 	tg3_enable_ints(tp);
@@ -8412,7 +8426,7 @@ static void __tg3_set_coalesce(struct tg3 *tp, struct ethtool_coalesce *ec)
 		tw32(HOSTCC_RXCOAL_TICK_INT, ec->rx_coalesce_usecs_irq);
 		tw32(HOSTCC_TXCOAL_TICK_INT, ec->tx_coalesce_usecs_irq);
 
-		if (!netif_carrier_ok(tp->dev))
+		if (!tp->link_up)
 			val = 0;
 
 		tw32(HOSTCC_STAT_COAL_TICKS, val);
@@ -9705,7 +9719,7 @@ static void tg3_periodic_fetch_stats(struct tg3 *tp)
 {
 	struct tg3_hw_stats *sp = tp->hw_stats;
 
-	if (!netif_carrier_ok(tp->dev))
+	if (!tp->link_up)
 		return;
 
 	TG3_STAT_ADD32(&sp->tx_octets, MAC_TX_STATS_OCTETS);
@@ -9849,11 +9863,11 @@ static void tg3_timer(unsigned long __opaque)
 			u32 mac_stat = tr32(MAC_STATUS);
 			int need_setup = 0;
 
-			if (netif_carrier_ok(tp->dev) &&
+			if (tp->link_up &&
 			    (mac_stat & MAC_STATUS_LNKSTATE_CHANGED)) {
 				need_setup = 1;
 			}
-			if (!netif_carrier_ok(tp->dev) &&
+			if (!tp->link_up &&
 			    (mac_stat & (MAC_STATUS_PCS_SYNCED |
 					 MAC_STATUS_SIGNAL_DET))) {
 				need_setup = 1;
@@ -10505,7 +10519,7 @@ static int tg3_open(struct net_device *dev)
 		}
 	}
 
-	netif_carrier_off(tp->dev);
+	tg3_carrier_off(tp);
 
 	err = tg3_power_up(tp);
 	if (err)
@@ -10538,7 +10552,7 @@ static int tg3_close(struct net_device *dev)
 
 	tg3_power_down(tp);
 
-	netif_carrier_off(tp->dev);
+	tg3_carrier_off(tp);
 
 	return 0;
 }
@@ -10912,7 +10926,7 @@ static int tg3_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			cmd->advertising |= ADVERTISED_Asym_Pause;
 		}
 	}
-	if (netif_running(dev) && netif_carrier_ok(dev)) {
+	if (netif_running(dev) && tp->link_up) {
 		ethtool_cmd_speed_set(cmd, tp->link_config.active_speed);
 		cmd->duplex = tp->link_config.active_duplex;
 		cmd->lp_advertising = tp->link_config.rmt_adv;
@@ -11430,7 +11444,7 @@ static int tg3_set_channels(struct net_device *dev,
 
 	tg3_stop(tp);
 
-	netif_carrier_off(dev);
+	tg3_carrier_off(tp);
 
 	tg3_start(tp, true, false);
 
@@ -11779,7 +11793,7 @@ static int tg3_test_link(struct tg3 *tp)
 		max = TG3_COPPER_TIMEOUT_SEC;
 
 	for (i = 0; i < max; i++) {
-		if (netif_carrier_ok(tp->dev))
+		if (tp->link_up)
 			return 0;
 
 		if (msleep_interruptible(1000))
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 6ff9964..4534804 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -3269,6 +3269,7 @@ struct tg3 {
 #if IS_ENABLED(CONFIG_HWMON)
 	struct device			*hwmon_dev;
 #endif
+	bool				link_up;
 };
 
 #endif /* !(_T3_H) */
-- 
1.7.1
