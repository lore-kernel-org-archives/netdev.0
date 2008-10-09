From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 6/8 2.6.28] cxgb3 - commnonize LASI phy code
Date: Wed, 08 Oct 2008 17:34:24 -0700
Message-ID: <20081009003424.13446.70530.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:26658 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757381AbYJIAea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 20:34:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Add generic code to manage interrupt driven PHYs.
Do not reset the phy after link parameters update,
the new values might get lost.
Return early from link change notification
when the link parameters remain unchanged.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/ael1002.c    |   46 +++++++---------------------------------
 drivers/net/cxgb3/common.h     |   19 ++++++++++++++++-
 drivers/net/cxgb3/cxgb3_main.c |   19 +++++++++++++----
 drivers/net/cxgb3/t3_hw.c      |   41 +++++++++++++++++++++++++++++++-----
 4 files changed, 77 insertions(+), 48 deletions(-)

diff --git a/drivers/net/cxgb3/ael1002.c b/drivers/net/cxgb3/ael1002.c
index f4e046e..f6e575f 100644
--- a/drivers/net/cxgb3/ael1002.c
+++ b/drivers/net/cxgb3/ael1002.c
@@ -39,9 +39,6 @@ enum {
 	AEL1002_PWR_DOWN_LO = 0xc012,
 	AEL1002_XFI_EQL = 0xc015,
 	AEL1002_LB_EN = 0xc017,
-
-	LASI_CTRL = 0x9002,
-	LASI_STAT = 0x9005
 };
 
 static void ael100x_txon(struct cphy *phy)
@@ -134,33 +131,6 @@ static int ael1006_reset(struct cphy *phy, int wait)
 	return t3_phy_reset(phy, MDIO_DEV_PMA_PMD, wait);
 }
 
-static int ael1006_intr_enable(struct cphy *phy)
-{
-	return mdio_write(phy, MDIO_DEV_PMA_PMD, LASI_CTRL, 1);
-}
-
-static int ael1006_intr_disable(struct cphy *phy)
-{
-	return mdio_write(phy, MDIO_DEV_PMA_PMD, LASI_CTRL, 0);
-}
-
-static int ael1006_intr_clear(struct cphy *phy)
-{
-	u32 val;
-
-	return mdio_read(phy, MDIO_DEV_PMA_PMD, LASI_STAT, &val);
-}
-
-static int ael1006_intr_handler(struct cphy *phy)
-{
-	unsigned int status;
-	int err = mdio_read(phy, MDIO_DEV_PMA_PMD, LASI_STAT, &status);
-
-	if (err)
-		return err;
-	return (status & 1) ? cphy_cause_link_change : 0;
-}
-
 static int ael1006_power_down(struct cphy *phy, int enable)
 {
 	return t3_mdio_change_bits(phy, MDIO_DEV_PMA_PMD, MII_BMCR,
@@ -169,10 +139,10 @@ static int ael1006_power_down(struct cphy *phy, int enable)
 
 static struct cphy_ops ael1006_ops = {
 	.reset = ael1006_reset,
-	.intr_enable = ael1006_intr_enable,
-	.intr_disable = ael1006_intr_disable,
-	.intr_clear = ael1006_intr_clear,
-	.intr_handler = ael1006_intr_handler,
+	.intr_enable = t3_phy_lasi_intr_enable,
+	.intr_disable = t3_phy_lasi_intr_disable,
+	.intr_clear = t3_phy_lasi_intr_clear,
+	.intr_handler = t3_phy_lasi_intr_handler,
 	.get_link_status = ael100x_get_link_status,
 	.power_down = ael1006_power_down,
 };
@@ -189,10 +159,10 @@ int t3_ael1006_phy_prep(struct cphy *phy, struct adapter *adapter,
 
 static struct cphy_ops qt2045_ops = {
 	.reset = ael1006_reset,
-	.intr_enable = ael1006_intr_enable,
-	.intr_disable = ael1006_intr_disable,
-	.intr_clear = ael1006_intr_clear,
-	.intr_handler = ael1006_intr_handler,
+	.intr_enable = t3_phy_lasi_intr_enable,
+	.intr_disable = t3_phy_lasi_intr_disable,
+	.intr_clear = t3_phy_lasi_intr_clear,
+	.intr_handler = t3_phy_lasi_intr_handler,
 	.get_link_status = ael100x_get_link_status,
 	.power_down = ael1006_power_down,
 };
diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 75b5ee6..d1b6b1e 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -522,7 +522,20 @@ enum {
 	MDIO_DEV_PMA_PMD = 1,
 	MDIO_DEV_WIS = 2,
 	MDIO_DEV_PCS = 3,
-	MDIO_DEV_XGXS = 4
+	MDIO_DEV_XGXS = 4,
+	MDIO_DEV_ANEG = 7,
+	MDIO_DEV_VEND1 = 30,
+	MDIO_DEV_VEND2 = 31
+};
+
+/* LASI control and status registers */
+enum {
+	RX_ALARM_CTRL = 0x9000,
+	TX_ALARM_CTRL = 0x9001,
+	LASI_CTRL = 0x9002,
+	RX_ALARM_STAT = 0x9003,
+	TX_ALARM_STAT = 0x9004,
+	LASI_STAT = 0x9005
 };
 
 /* PHY loopback direction */
@@ -665,6 +678,10 @@ int t3_mdio_change_bits(struct cphy *phy, int mmd, int reg, unsigned int clear,
 int t3_phy_reset(struct cphy *phy, int mmd, int wait);
 int t3_phy_advertise(struct cphy *phy, unsigned int advert);
 int t3_set_phy_speed_duplex(struct cphy *phy, int speed, int duplex);
+int t3_phy_lasi_intr_enable(struct cphy *phy);
+int t3_phy_lasi_intr_disable(struct cphy *phy);
+int t3_phy_lasi_intr_clear(struct cphy *phy);
+int t3_phy_lasi_intr_handler(struct cphy *phy);
 
 void t3_intr_enable(struct adapter *adapter);
 void t3_intr_disable(struct adapter *adapter);
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 5b8251d..bddcf94 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1516,11 +1516,22 @@ static int speed_duplex_to_caps(int speed, int duplex)
 
 static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
+	int cap;
 	struct port_info *p = netdev_priv(dev);
 	struct link_config *lc = &p->link_config;
 
-	if (!(lc->supported & SUPPORTED_Autoneg))
-		return -EOPNOTSUPP;     /* can't change speed/duplex */
+	if (!(lc->supported & SUPPORTED_Autoneg)) {
+		/*
+		 * PHY offers a single speed/duplex.  See if that's what's
+		 * being requested.
+		 */
+		if (cmd->autoneg == AUTONEG_DISABLE) {
+			cap = speed_duplex_to_caps(cmd->speed, cmd->duplex);
+			if (lc->supported & cap)
+				return 0;
+		}
+		return -EINVAL;
+	}
 
 	if (cmd->autoneg == AUTONEG_DISABLE) {
 		int cap = speed_duplex_to_caps(cmd->speed, cmd->duplex);
@@ -2195,7 +2206,7 @@ static int cxgb_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 			mmd = data->phy_id >> 8;
 			if (!mmd)
 				mmd = MDIO_DEV_PCS;
-			else if (mmd > MDIO_DEV_XGXS)
+			else if (mmd > MDIO_DEV_VEND2)
 				return -EINVAL;
 
 			ret =
@@ -2221,7 +2232,7 @@ static int cxgb_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 			mmd = data->phy_id >> 8;
 			if (!mmd)
 				mmd = MDIO_DEV_PCS;
-			else if (mmd > MDIO_DEV_XGXS)
+			else if (mmd > MDIO_DEV_VEND2)
 				return -EINVAL;
 
 			ret =
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index bfce761..58a3097 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -442,6 +442,33 @@ int t3_set_phy_speed_duplex(struct cphy *phy, int speed, int duplex)
 	return mdio_write(phy, 0, MII_BMCR, ctl);
 }
 
+int t3_phy_lasi_intr_enable(struct cphy *phy)
+{
+	return mdio_write(phy, MDIO_DEV_PMA_PMD, LASI_CTRL, 1);
+}
+
+int t3_phy_lasi_intr_disable(struct cphy *phy)
+{
+	return mdio_write(phy, MDIO_DEV_PMA_PMD, LASI_CTRL, 0);
+}
+
+int t3_phy_lasi_intr_clear(struct cphy *phy)
+{
+	u32 val;
+
+	return mdio_read(phy, MDIO_DEV_PMA_PMD, LASI_STAT, &val);
+}
+
+int t3_phy_lasi_intr_handler(struct cphy *phy)
+{
+	unsigned int status;
+	int err = mdio_read(phy, MDIO_DEV_PMA_PMD, LASI_STAT, &status);
+
+	if (err)
+		return err;
+	return (status & 1) ?  cphy_cause_link_change : 0;
+}
+
 static const struct adapter_info t3_adap_info[] = {
 	{2, 0,
 	 F_GPIO2_OEN | F_GPIO4_OEN |
@@ -1132,6 +1159,15 @@ void t3_link_changed(struct adapter *adapter, int port_id)
 
 	phy->ops->get_link_status(phy, &link_ok, &speed, &duplex, &fc);
 
+	if (lc->requested_fc & PAUSE_AUTONEG)
+		fc &= lc->requested_fc;
+	else
+		fc = lc->requested_fc & (PAUSE_RX | PAUSE_TX);
+
+	if (link_ok == lc->link_ok && speed == lc->speed &&
+	    duplex == lc->duplex && fc == lc->fc)
+		return;                            /* nothing changed */
+
 	if (link_ok != lc->link_ok && adapter->params.rev > 0 &&
 	    uses_xaui(adapter)) {
 		if (link_ok)
@@ -1142,10 +1178,6 @@ void t3_link_changed(struct adapter *adapter, int port_id)
 	lc->link_ok = link_ok;
 	lc->speed = speed < 0 ? SPEED_INVALID : speed;
 	lc->duplex = duplex < 0 ? DUPLEX_INVALID : duplex;
-	if (lc->requested_fc & PAUSE_AUTONEG)
-		fc &= lc->requested_fc;
-	else
-		fc = lc->requested_fc & (PAUSE_RX | PAUSE_TX);
 
 	if (link_ok && speed >= 0 && lc->autoneg == AUTONEG_ENABLE) {
 		/* Set MAC speed, duplex, and flow control to match PHY. */
@@ -1191,7 +1223,6 @@ int t3_link_start(struct cphy *phy, struct cmac *mac, struct link_config *lc)
 						   fc);
 			/* Also disables autoneg */
 			phy->ops->set_speed_duplex(phy, lc->speed, lc->duplex);
-			phy->ops->reset(phy, 0);
 		} else
 			phy->ops->autoneg_enable(phy);
 	} else {

