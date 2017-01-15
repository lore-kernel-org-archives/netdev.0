From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: jme: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 15 Jan 2017 23:18:21 +0100
Message-ID: <1484518701-27039-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: cooldavid@cooldavid.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35916 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751068AbdAOWSu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 17:18:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/jme.c |   34 +++++++++++++++++-----------------
 drivers/net/ethernet/jme.h |    6 +++---
 2 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index f9fcab5..f580b49 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -1879,7 +1879,7 @@
 
 	jme_phy_on(jme);
 	if (test_bit(JME_FLAG_SSET, &jme->flags))
-		jme_set_settings(netdev, &jme->old_ecmd);
+		jme_set_link_ksettings(netdev, &jme->old_cmd);
 	else
 		jme_reset_phy_processor(jme);
 	jme_phy_calibration(jme);
@@ -2374,7 +2374,7 @@ static void jme_drop_tx_map(struct jme_adapter *jme, int startidx, int count)
 	jme->phylink = 0;
 	jme_reset_phy_processor(jme);
 	if (test_bit(JME_FLAG_SSET, &jme->flags))
-		jme_set_settings(netdev, &jme->old_ecmd);
+		jme_set_link_ksettings(netdev, &jme->old_cmd);
 
 	/*
 	 * Force to Reset the link again
@@ -2648,27 +2648,27 @@ static inline void jme_resume_rx(struct jme_adapter *jme)
 }
 
 static int
-jme_get_settings(struct net_device *netdev,
-		     struct ethtool_cmd *ecmd)
+jme_get_link_ksettings(struct net_device *netdev,
+		       struct ethtool_link_ksettings *cmd)
 {
 	struct jme_adapter *jme = netdev_priv(netdev);
 	int rc;
 
 	spin_lock_bh(&jme->phy_lock);
-	rc = mii_ethtool_gset(&(jme->mii_if), ecmd);
+	rc = mii_ethtool_get_link_ksettings(&jme->mii_if, cmd);
 	spin_unlock_bh(&jme->phy_lock);
 	return rc;
 }
 
 static int
-jme_set_settings(struct net_device *netdev,
-		     struct ethtool_cmd *ecmd)
+jme_set_link_ksettings(struct net_device *netdev,
+		       const struct ethtool_link_ksettings *cmd)
 {
 	struct jme_adapter *jme = netdev_priv(netdev);
 	int rc, fdc = 0;
 
-	if (ethtool_cmd_speed(ecmd) == SPEED_1000
-	    && ecmd->autoneg != AUTONEG_ENABLE)
+	if (cmd->base.speed == SPEED_1000 &&
+	    cmd->base.autoneg != AUTONEG_ENABLE)
 		return -EINVAL;
 
 	/*
@@ -2676,18 +2676,18 @@ static inline void jme_resume_rx(struct jme_adapter *jme)
 	 * Hardware would not generate link change interrupt.
 	 */
 	if (jme->mii_if.force_media &&
-	ecmd->autoneg != AUTONEG_ENABLE &&
-	(jme->mii_if.full_duplex != ecmd->duplex))
+	    cmd->base.autoneg != AUTONEG_ENABLE &&
+	    (jme->mii_if.full_duplex != cmd->base.duplex))
 		fdc = 1;
 
 	spin_lock_bh(&jme->phy_lock);
-	rc = mii_ethtool_sset(&(jme->mii_if), ecmd);
+	rc = mii_ethtool_set_link_ksettings(&jme->mii_if, cmd);
 	spin_unlock_bh(&jme->phy_lock);
 
 	if (!rc) {
 		if (fdc)
 			jme_reset_link(jme);
-		jme->old_ecmd = *ecmd;
+		jme->old_cmd = *cmd;
 		set_bit(JME_FLAG_SSET, &jme->flags);
 	}
 
@@ -2716,7 +2716,7 @@ static inline void jme_resume_rx(struct jme_adapter *jme)
 	if (!rc && (cmd == SIOCSMIIREG)) {
 		if (duplex_chg)
 			jme_reset_link(jme);
-		jme_get_settings(netdev, &jme->old_ecmd);
+		jme_get_link_ksettings(netdev, &jme->old_cmd);
 		set_bit(JME_FLAG_SSET, &jme->flags);
 	}
 
@@ -2915,8 +2915,6 @@ static void jme_netpoll(struct net_device *dev)
 	.set_pauseparam		= jme_set_pauseparam,
 	.get_wol		= jme_get_wol,
 	.set_wol		= jme_set_wol,
-	.get_settings		= jme_get_settings,
-	.set_settings		= jme_set_settings,
 	.get_link		= jme_get_link,
 	.get_msglevel           = jme_get_msglevel,
 	.set_msglevel           = jme_set_msglevel,
@@ -2924,6 +2922,8 @@ static void jme_netpoll(struct net_device *dev)
 	.get_eeprom_len		= jme_get_eeprom_len,
 	.get_eeprom		= jme_get_eeprom,
 	.set_eeprom		= jme_set_eeprom,
+	.get_link_ksettings	= jme_get_link_ksettings,
+	.set_link_ksettings	= jme_set_link_ksettings,
 };
 
 static int
@@ -3306,7 +3306,7 @@ static void jme_netpoll(struct net_device *dev)
 	jme_clear_pm_disable_wol(jme);
 	jme_phy_on(jme);
 	if (test_bit(JME_FLAG_SSET, &jme->flags))
-		jme_set_settings(netdev, &jme->old_ecmd);
+		jme_set_link_ksettings(netdev, &jme->old_cmd);
 	else
 		jme_reset_phy_processor(jme);
 	jme_phy_calibration(jme);
diff --git a/drivers/net/ethernet/jme.h b/drivers/net/ethernet/jme.h
index 58cd67c..89535c0 100644
--- a/drivers/net/ethernet/jme.h
+++ b/drivers/net/ethernet/jme.h
@@ -447,7 +447,7 @@ struct jme_adapter {
 	u8			chip_sub_rev;
 	u8			pcirev;
 	u32			msg_enable;
-	struct ethtool_cmd	old_ecmd;
+	struct ethtool_link_ksettings old_cmd;
 	unsigned int		old_mtu;
 	struct dynpcc_info	dpi;
 	atomic_t		intr_sem;
@@ -1270,8 +1270,8 @@ static inline int new_phy_power_ctrl(u8 chip_main_rev)
 /*
  * Function prototypes
  */
-static int jme_set_settings(struct net_device *netdev,
-				struct ethtool_cmd *ecmd);
+static int jme_set_link_ksettings(struct net_device *netdev,
+				  const struct ethtool_link_ksettings *cmd);
 static void jme_set_unicastaddr(struct net_device *netdev);
 static void jme_set_multi(struct net_device *netdev);
 
-- 
1.7.4.4
