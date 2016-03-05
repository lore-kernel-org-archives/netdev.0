From: cooldavid@cooldavid.org
Subject: [PATCH net 1/2] jme: Do not enable NIC WoL functions on S0
Date: Sat,  5 Mar 2016 08:11:55 +0800
Message-ID: <1457136716-7251-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>,
	"Diego Viola" <diego.viola@gmail.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:56903 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760388AbcCEAGt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 19:06:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

Otherwise it might be back on resume right after going to suspend in
some hardware.

Reported-by: Diego Viola <diego.viola@gmail.com>
Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/ethernet/jme.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 8adbe8f..74b9c9d 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -270,11 +270,17 @@ jme_reset_mac_processor(struct jme_adapter *jme)
 }
 
 static inline void
-jme_clear_pm(struct jme_adapter *jme)
+jme_clear_pm_enable_wol(struct jme_adapter *jme)
 {
 	jwrite32(jme, JME_PMCS, PMCS_STMASK | jme->reg_pmcs);
 }
 
+static inline void
+jme_clear_pm_disable_wol(struct jme_adapter *jme)
+{
+	jwrite32(jme, JME_PMCS, PMCS_STMASK);
+}
+
 static int
 jme_reload_eeprom(struct jme_adapter *jme)
 {
@@ -1853,7 +1859,7 @@ jme_open(struct net_device *netdev)
 	struct jme_adapter *jme = netdev_priv(netdev);
 	int rc;
 
-	jme_clear_pm(jme);
+	jme_clear_pm_disable_wol(jme);
 	JME_NAPI_ENABLE(jme);
 
 	tasklet_init(&jme->linkch_task, jme_link_change_tasklet,
@@ -1929,7 +1935,7 @@ jme_powersave_phy(struct jme_adapter *jme)
 		jme_set_100m_half(jme);
 		if (jme->reg_pmcs & (PMCS_LFEN | PMCS_LREN))
 			jme_wait_link(jme);
-		jme_clear_pm(jme);
+		jme_clear_pm_enable_wol(jme);
 	} else {
 		jme_phy_off(jme);
 	}
@@ -2646,7 +2652,6 @@ jme_set_wol(struct net_device *netdev,
 	if (wol->wolopts & WAKE_MAGIC)
 		jme->reg_pmcs |= PMCS_MFEN;
 
-	jwrite32(jme, JME_PMCS, jme->reg_pmcs);
 	device_set_wakeup_enable(&jme->pdev->dev, !!(jme->reg_pmcs));
 
 	return 0;
@@ -3172,7 +3177,7 @@ jme_init_one(struct pci_dev *pdev,
 	jme->mii_if.mdio_read = jme_mdio_read;
 	jme->mii_if.mdio_write = jme_mdio_write;
 
-	jme_clear_pm(jme);
+	jme_clear_pm_disable_wol(jme);
 	device_set_wakeup_enable(&pdev->dev, true);
 
 	jme_set_phyfifo_5level(jme);
@@ -3304,7 +3309,7 @@ jme_resume(struct device *dev)
 	if (!netif_running(netdev))
 		return 0;
 
-	jme_clear_pm(jme);
+	jme_clear_pm_disable_wol(jme);
 	jme_phy_on(jme);
 	if (test_bit(JME_FLAG_SSET, &jme->flags))
 		jme_set_settings(netdev, &jme->old_ecmd);
-- 
1.8.5.5
