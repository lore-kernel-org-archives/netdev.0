From: Michael Weiser <michael.weiser@gmx.de>
Subject: [PATCH 2/3] net: ethernet: sun4i-emac: Allow to enable netif messages
Date: Mon, 14 Nov 2016 18:58:06 +0100
Message-ID: <20161114175807.4747-3-michael.weiser@gmx.de>
References: <20161114175807.4747-1-michael.weiser@gmx.de>
Cc: Michael Weiser <michael.weiser@gmx.de>,
        Maxime Ripard <maxime.ripard@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from heinz.dinsnail.net ([85.214.155.104]:46516 "EHLO
        heinz.dinsnail.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935674AbcKNTAX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 14:00:23 -0500
In-Reply-To: <20161114175807.4747-1-michael.weiser@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sun4i-emac has the ability to print a number of diagnostic messages using
dev_dbg depending on message level settings implemented using netif_msg_*
macros. But there's no way to actually enable them.

Add the ability to switch diagnostic messages on using either a module
parameter debug or ethtool -s <netif> msglvl <flags>.

Signed-off-by: Michael Weiser <michael.weiser@gmx.de>
Cc: Maxime Ripard <maxime.ripard@free-electrons.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/allwinner/sun4i-emac.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index 6ffdff6..cd08885 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -37,6 +37,11 @@
 
 #define EMAC_MAX_FRAME_LEN	0x0600
 
+#define EMAC_DEFAULT_MSG_ENABLE 0x0000
+static int debug = -1;     /* defaults above */;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "debug message flags");
+
 /* Transmit timeout, default 5 seconds. */
 static int watchdog = 5000;
 module_param(watchdog, int, 0400);
@@ -225,11 +230,27 @@ static void emac_get_drvinfo(struct net_device *dev,
 	strlcpy(info->bus_info, dev_name(&dev->dev), sizeof(info->bus_info));
 }
 
+static u32 emac_get_msglevel(struct net_device *dev)
+{
+	struct emac_board_info *db = netdev_priv(dev);
+
+	return db->msg_enable;
+}
+
+static void emac_set_msglevel(struct net_device *dev, u32 value)
+{
+	struct emac_board_info *db = netdev_priv(dev);
+
+	db->msg_enable = value;
+}
+
 static const struct ethtool_ops emac_ethtool_ops = {
 	.get_drvinfo	= emac_get_drvinfo,
 	.get_link	= ethtool_op_get_link,
 	.get_link_ksettings = phy_ethtool_get_link_ksettings,
 	.set_link_ksettings = phy_ethtool_set_link_ksettings,
+	.get_msglevel	= emac_get_msglevel,
+	.set_msglevel	= emac_set_msglevel,
 };
 
 static unsigned int emac_setup(struct net_device *ndev)
@@ -805,6 +826,7 @@ static int emac_probe(struct platform_device *pdev)
 	db->dev = &pdev->dev;
 	db->ndev = ndev;
 	db->pdev = pdev;
+	db->msg_enable = netif_msg_init(debug, EMAC_DEFAULT_MSG_ENABLE);
 
 	spin_lock_init(&db->lock);
 
-- 
2.9.3 (Apple Git-75)
