From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH 2/2] Blackfin EMAC Driver: Initial version of ethtool support was checked in and more ethtool operations will be supported in the future.
Date: Fri, 25 Apr 2008 11:53:11 +0800
Message-ID: <1209095591-20920-3-git-send-email-cooloney@kernel.org>
References: <1209095591-20920-1-git-send-email-cooloney@kernel.org>
Cc: Bryan Wu <cooloney@kernel.org>
To: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:33643 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751668AbYDYDxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 23:53:35 -0400
In-Reply-To: <1209095591-20920-1-git-send-email-cooloney@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 drivers/net/bfin_mac.c |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index fdd361c..8762b96 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -27,6 +27,7 @@
 #include <linux/phy.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/ethtool.h>
 #include <linux/skbuff.h>
 #include <linux/platform_device.h>
 
@@ -453,6 +454,51 @@ static int mii_probe(struct net_device *dev)
 	return 0;
 }
 
+/*
+ * Ethtool support
+ */
+
+static int
+bfin_mac_ethtool_getsettings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct bfin_mac_local *lp = netdev_priv(dev);
+
+	if (lp->phydev)
+		return phy_ethtool_gset(lp->phydev, cmd);
+
+	return -EINVAL;
+}
+
+static int
+bfin_mac_ethtool_setsettings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct bfin_mac_local *lp = netdev_priv(dev);
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (lp->phydev)
+		return phy_ethtool_sset(lp->phydev, cmd);
+
+	return -EINVAL;
+}
+
+static void bfin_mac_ethtool_getdrvinfo(struct net_device *dev,
+					struct ethtool_drvinfo *info)
+{
+	strcpy(info->driver, DRV_NAME);
+	strcpy(info->version, DRV_VERSION);
+	strcpy(info->fw_version, "N/A");
+	strcpy(info->bus_info, dev->dev.bus_id);
+}
+
+static struct ethtool_ops bfin_mac_ethtool_ops = {
+	.get_settings = bfin_mac_ethtool_getsettings,
+	.set_settings = bfin_mac_ethtool_setsettings,
+	.get_link = ethtool_op_get_link,
+	.get_drvinfo = bfin_mac_ethtool_getdrvinfo,
+};
+
 /**************************************************************************/
 void setup_system_regs(struct net_device *dev)
 {
@@ -996,6 +1042,7 @@ static int __init bfin_mac_probe(struct platform_device *pdev)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	ndev->poll_controller = bfin_mac_poll;
 #endif
+	ndev->ethtool_ops = &bfin_mac_ethtool_ops;
 
 	spin_lock_init(&lp->lock);
 
-- 
1.5.5
