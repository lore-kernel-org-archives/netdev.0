From: ujhelyi.m@gmail.com
Subject: [PATCH net-next v4] net: cpsw: Add support for wake-on-lan for cpsw
Date: Tue, 20 Aug 2013 07:59:38 +0200
Message-ID: <1376978378-26096-1-git-send-email-ujhelyi.m@gmail.com>
Cc: linux-kernel@vger.kernel.org, Matus Ujhelyi <ujhelyi.m@gmail.com>
To: davem@davemloft.net, mugunthanvnm@ti.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f171.google.com ([209.85.215.171]:60665 "EHLO
	mail-ea0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403Ab3HTF7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 01:59:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matus Ujhelyi <ujhelyi.m@gmail.com>

Some phy's can be configured to enable wake on lan (e.g. at803x or marvell 88E1318S).
There is no way how to enable wol on CPSW with such connected phys. This patch
adds this support. It is provided by calling the phy's related code.

Tested on board with at8030x connected phy. Wol interrupt line is
connected to GPIO0 on am335x.

Signed-off-by: Matus Ujhelyi <ujhelyi.m@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c |   25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 0fcf212..e2a2535 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1640,6 +1640,29 @@ static int cpsw_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 		return -EOPNOTSUPP;
 }
 
+static void cpsw_get_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	int slave_no = cpsw_slave_index(priv);
+
+	wol->supported = 0;
+	wol->wolopts = 0;
+
+	if (priv->slaves[slave_no].phy)
+		phy_ethtool_get_wol(priv->slaves[slave_no].phy, wol);
+}
+
+static int cpsw_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	int slave_no = cpsw_slave_index(priv);
+
+	if (priv->slaves[slave_no].phy)
+		return phy_ethtool_set_wol(priv->slaves[slave_no].phy, wol);
+	else
+		return -EOPNOTSUPP;
+}
+
 static const struct ethtool_ops cpsw_ethtool_ops = {
 	.get_drvinfo	= cpsw_get_drvinfo,
 	.get_msglevel	= cpsw_get_msglevel,
@@ -1653,6 +1676,8 @@ static const struct ethtool_ops cpsw_ethtool_ops = {
 	.get_sset_count		= cpsw_get_sset_count,
 	.get_strings		= cpsw_get_strings,
 	.get_ethtool_stats	= cpsw_get_ethtool_stats,
+	.get_wol	= cpsw_get_wol,
+	.set_wol	= cpsw_set_wol,
 };
 
 static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_priv *priv,
-- 
1.7.9.5
