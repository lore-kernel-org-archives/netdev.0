From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v2 3/3] enic: add ethtool support set/show rx_copybreak
Date: Tue, 29 Jul 2014 17:10:39 +0530
Message-ID: <1406634039-15030-4-git-send-email-_govind@gmx.com>
References: <1406634039-15030-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, ben@decadent.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:56930 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753487AbaG2Lln (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2014 07:41:43 -0400
In-Reply-To: <1406634039-15030-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ethtools support for get/set_buffparam.

This is used to set the driver rx_copybreak value. Do not allow rx_copybreak
value to be set more than max frame size.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_ethtool.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index 523c9ce..4c9eb52 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -18,6 +18,7 @@
 
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
+#include <linux/if_vlan.h>
 
 #include "enic_res.h"
 #include "enic.h"
@@ -379,6 +380,27 @@ static int enic_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
 	return ret;
 }
 
+static void enic_get_buffparam(struct net_device *netdev,
+			       struct ethtool_buffparam *data)
+{
+	struct enic *enic = netdev_priv(netdev);
+
+	data->rx_copybreak_cur = enic->rx_copybreak;
+	data->rx_copybreak_max = netdev->mtu + VLAN_ETH_HLEN;
+}
+
+static int enic_set_buffparam(struct net_device *netdev,
+			      struct ethtool_buffparam *data)
+{
+	struct enic *enic = netdev_priv(netdev);
+
+	if (data->rx_copybreak_cur > netdev->mtu + VLAN_ETH_HLEN)
+		return -EINVAL;
+	enic->rx_copybreak = data->rx_copybreak_cur;
+
+	return 0;
+}
+
 static const struct ethtool_ops enic_ethtool_ops = {
 	.get_settings = enic_get_settings,
 	.get_drvinfo = enic_get_drvinfo,
@@ -391,6 +413,8 @@ static const struct ethtool_ops enic_ethtool_ops = {
 	.get_coalesce = enic_get_coalesce,
 	.set_coalesce = enic_set_coalesce,
 	.get_rxnfc = enic_get_rxnfc,
+	.get_buffparam = enic_get_buffparam,
+	.set_buffparam = enic_set_buffparam,
 };
 
 void enic_set_ethtool_ops(struct net_device *netdev)
-- 
2.0.3
