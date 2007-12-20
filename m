From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 1/8] tg3: Separate requested and actual flow control
 parameters
Date: Thu, 20 Dec 2007 15:21:31 -0800
Message-ID: <1198192891.0@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1627 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751438AbXLTXUm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 18:20:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the TX and RX flow control flags from tg3_flags and
adds two new flow control variables, flowctrl and active_flowctrl.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4942f7d..d503214 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1602,17 +1602,19 @@ static void tg3_link_report(struct tg3 *tp)
 		       (tp->link_config.active_duplex == DUPLEX_FULL ?
 			"full" : "half"));
 
-		printk(KERN_INFO PFX "%s: Flow control is %s for TX and "
-		       "%s for RX.\n",
+		printk(KERN_INFO PFX
+		       "%s: Flow control is %s for TX and %s for RX.\n",
 		       tp->dev->name,
-		       (tp->tg3_flags & TG3_FLAG_TX_PAUSE) ? "on" : "off",
-		       (tp->tg3_flags & TG3_FLAG_RX_PAUSE) ? "on" : "off");
+		       (tp->link_config.active_flowctrl & TG3_FLOW_CTRL_TX) ?
+		       "on" : "off",
+		       (tp->link_config.active_flowctrl & TG3_FLOW_CTRL_RX) ?
+		       "on" : "off");
 	}
 }
 
 static void tg3_setup_flow_control(struct tg3 *tp, u32 local_adv, u32 remote_adv)
 {
-	u32 new_tg3_flags = 0;
+	u8 new_tg3_flags = 0;
 	u32 old_rx_mode = tp->rx_mode;
 	u32 old_tx_mode = tp->tx_mode;
 
@@ -1639,31 +1641,27 @@ static void tg3_setup_flow_control(struct tg3 *tp, u32 local_adv, u32 remote_adv
 		if (local_adv & ADVERTISE_PAUSE_CAP) {
 			if (local_adv & ADVERTISE_PAUSE_ASYM) {
 				if (remote_adv & LPA_PAUSE_CAP)
-					new_tg3_flags |=
-						(TG3_FLAG_RX_PAUSE |
-					 	TG3_FLAG_TX_PAUSE);
+					new_tg3_flags = TG3_FLOW_CTRL_RX |
+							TG3_FLOW_CTRL_TX;
 				else if (remote_adv & LPA_PAUSE_ASYM)
-					new_tg3_flags |=
-						(TG3_FLAG_RX_PAUSE);
+					new_tg3_flags = TG3_FLOW_CTRL_RX;
 			} else {
 				if (remote_adv & LPA_PAUSE_CAP)
-					new_tg3_flags |=
-						(TG3_FLAG_RX_PAUSE |
-					 	TG3_FLAG_TX_PAUSE);
+					new_tg3_flags = TG3_FLOW_CTRL_RX |
+							TG3_FLOW_CTRL_TX;
 			}
 		} else if (local_adv & ADVERTISE_PAUSE_ASYM) {
 			if ((remote_adv & LPA_PAUSE_CAP) &&
-		    	(remote_adv & LPA_PAUSE_ASYM))
-				new_tg3_flags |= TG3_FLAG_TX_PAUSE;
+			    (remote_adv & LPA_PAUSE_ASYM))
+				new_tg3_flags = TG3_FLOW_CTRL_TX;
 		}
-
-		tp->tg3_flags &= ~(TG3_FLAG_RX_PAUSE | TG3_FLAG_TX_PAUSE);
-		tp->tg3_flags |= new_tg3_flags;
 	} else {
-		new_tg3_flags = tp->tg3_flags;
+		new_tg3_flags = tp->link_config.flowctrl;
 	}
 
-	if (new_tg3_flags & TG3_FLAG_RX_PAUSE)
+	tp->link_config.active_flowctrl = new_tg3_flags;
+
+	if (new_tg3_flags & TG3_FLOW_CTRL_RX)
 		tp->rx_mode |= RX_MODE_FLOW_CTRL_ENABLE;
 	else
 		tp->rx_mode &= ~RX_MODE_FLOW_CTRL_ENABLE;
@@ -1672,7 +1670,7 @@ static void tg3_setup_flow_control(struct tg3 *tp, u32 local_adv, u32 remote_adv
 		tw32_f(MAC_RX_MODE, tp->rx_mode);
 	}
 
-	if (new_tg3_flags & TG3_FLAG_TX_PAUSE)
+	if (new_tg3_flags & TG3_FLOW_CTRL_TX)
 		tp->tx_mode |= TX_MODE_FLOW_CTRL_ENABLE;
 	else
 		tp->tx_mode &= ~TX_MODE_FLOW_CTRL_ENABLE;
@@ -2812,9 +2810,7 @@ static int tg3_setup_fiber_phy(struct tg3 *tp, int force_reset)
 	int current_link_up;
 	int i;
 
-	orig_pause_cfg =
-		(tp->tg3_flags & (TG3_FLAG_RX_PAUSE |
-				  TG3_FLAG_TX_PAUSE));
+	orig_pause_cfg = tp->link_config.active_flowctrl;
 	orig_active_speed = tp->link_config.active_speed;
 	orig_active_duplex = tp->link_config.active_duplex;
 
@@ -2903,9 +2899,7 @@ static int tg3_setup_fiber_phy(struct tg3 *tp, int force_reset)
 			netif_carrier_off(tp->dev);
 		tg3_link_report(tp);
 	} else {
-		u32 now_pause_cfg =
-			tp->tg3_flags & (TG3_FLAG_RX_PAUSE |
-					 TG3_FLAG_TX_PAUSE);
+		u32 now_pause_cfg = tp->link_config.active_flowctrl;
 		if (orig_pause_cfg != now_pause_cfg ||
 		    orig_active_speed != tp->link_config.active_speed ||
 		    orig_active_duplex != tp->link_config.active_duplex)
@@ -8571,8 +8565,16 @@ static void tg3_get_pauseparam(struct net_device *dev, struct ethtool_pauseparam
 	struct tg3 *tp = netdev_priv(dev);
 
 	epause->autoneg = (tp->tg3_flags & TG3_FLAG_PAUSE_AUTONEG) != 0;
-	epause->rx_pause = (tp->tg3_flags & TG3_FLAG_RX_PAUSE) != 0;
-	epause->tx_pause = (tp->tg3_flags & TG3_FLAG_TX_PAUSE) != 0;
+
+	if (tp->link_config.active_flowctrl & TG3_FLOW_CTRL_RX)
+		epause->rx_pause = 1;
+	else
+		epause->rx_pause = 0;
+
+	if (tp->link_config.active_flowctrl & TG3_FLOW_CTRL_TX)
+		epause->tx_pause = 1;
+	else
+		epause->tx_pause = 0;
 }
 
 static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam *epause)
@@ -8592,13 +8594,13 @@ static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam
 	else
 		tp->tg3_flags &= ~TG3_FLAG_PAUSE_AUTONEG;
 	if (epause->rx_pause)
-		tp->tg3_flags |= TG3_FLAG_RX_PAUSE;
+		tp->link_config.flowctrl |= TG3_FLOW_CTRL_RX;
 	else
-		tp->tg3_flags &= ~TG3_FLAG_RX_PAUSE;
+		tp->link_config.flowctrl &= ~TG3_FLOW_CTRL_RX;
 	if (epause->tx_pause)
-		tp->tg3_flags |= TG3_FLAG_TX_PAUSE;
+		tp->link_config.flowctrl |= TG3_FLOW_CTRL_TX;
 	else
-		tp->tg3_flags &= ~TG3_FLAG_TX_PAUSE;
+		tp->link_config.flowctrl &= ~TG3_FLOW_CTRL_TX;
 
 	if (netif_running(dev)) {
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
@@ -12620,6 +12622,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	/* flow control autonegotiation is default behavior */
 	tp->tg3_flags |= TG3_FLAG_PAUSE_AUTONEG;
+	tp->link_config.flowctrl = TG3_FLOW_CTRL_TX | TG3_FLOW_CTRL_RX;
 
 	tg3_init_coal(tp);
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index da18fb2..ac47c17 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2103,13 +2103,18 @@ struct tg3_link_config {
 	u16				speed;
 	u8				duplex;
 	u8				autoneg;
+	u8				flowctrl;
+#define TG3_FLOW_CTRL_TX		0x01
+#define TG3_FLOW_CTRL_RX		0x02
 
 	/* Describes what we actually have. */
-	u16				active_speed;
+	u8				active_flowctrl;
+
 	u8				active_duplex;
 #define SPEED_INVALID		0xffff
 #define DUPLEX_INVALID		0xff
 #define AUTONEG_INVALID		0xff
+	u16				active_speed;
 
 	/* When we go in and out of low power mode we need
 	 * to swap with this state.
@@ -2337,8 +2342,6 @@ struct tg3 {
 #define TG3_FLAG_EEPROM_WRITE_PROT	0x00001000
 #define TG3_FLAG_NVRAM			0x00002000
 #define TG3_FLAG_NVRAM_BUFFERED		0x00004000
-#define TG3_FLAG_RX_PAUSE		0x00008000
-#define TG3_FLAG_TX_PAUSE		0x00010000
 #define TG3_FLAG_PCIX_MODE		0x00020000
 #define TG3_FLAG_PCI_HIGH_SPEED		0x00040000
 #define TG3_FLAG_PCI_32BIT		0x00080000


