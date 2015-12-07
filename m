From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 26/26] sfp/phylink: hook up eeprom functions
Date: Mon, 07 Dec 2015 17:39:24 +0000
Message-ID: <E1a5zky-00077F-Rn@rmk-PC.arm.linux.org.uk>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:60333 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932743AbbLGRj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 12:39:28 -0500
In-Reply-To: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/phy/sfp.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/sfp.c b/drivers/net/phy/sfp.c
index 678298844203..feb5f7062b2c 100644
--- a/drivers/net/phy/sfp.c
+++ b/drivers/net/phy/sfp.c
@@ -902,11 +902,9 @@ static void sfp_sm_event(struct sfp *sfp, unsigned int event)
 	mutex_unlock(&sfp->sm_mutex);
 }
 
-#if 0
-static int sfp_phy_module_info(struct phy_device *phy,
-			       struct ethtool_modinfo *modinfo)
+static int sfp_module_info(void *priv, struct ethtool_modinfo *modinfo)
 {
-	struct sfp *sfp = phy->priv;
+	struct sfp *sfp = priv;
 
 	/* locking... and check module is present */
 
@@ -920,10 +918,9 @@ static int sfp_phy_module_info(struct phy_device *phy,
 	return 0;
 }
 
-static int sfp_phy_module_eeprom(struct phy_device *phy,
-	struct ethtool_eeprom *ee, u8 *data)
+static int sfp_module_eeprom(void *priv, struct ethtool_eeprom *ee, u8 *data)
 {
-	struct sfp *sfp = phy->priv;
+	struct sfp *sfp = priv;
 	unsigned int first, last, len;
 	int ret;
 
@@ -954,7 +951,11 @@ static int sfp_phy_module_eeprom(struct phy_device *phy,
 	}
 	return 0;
 }
-#endif
+
+static const struct phylink_module_ops sfp_module_ops = {
+	.get_module_info = sfp_module_info,
+	.get_module_eeprom = sfp_module_eeprom,
+};
 
 static void sfp_timeout(struct work_struct *work)
 {
@@ -1030,6 +1031,7 @@ static int sfp_netdev_notify(struct notifier_block *nb, unsigned long act, void
 	case NETDEV_UNREGISTER:
 		if (sfp->mod_phy && sfp->phylink)
 			phylink_disconnect_phy(sfp->phylink);
+		phylink_unregister_module(sfp->phylink, sfp);
 		sfp->phylink = NULL;
 		dev_put(sfp->ndev);
 		sfp->ndev = NULL;
@@ -1146,6 +1148,7 @@ static int sfp_probe(struct platform_device *pdev)
 		}
 
 		phylink_disable(sfp->phylink);
+		phylink_register_module(sfp->phylink, sfp, &sfp_module_ops);
 	}
 
 	sfp->state = sfp_get_state(sfp);
-- 
2.1.0
