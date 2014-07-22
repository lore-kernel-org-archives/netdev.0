From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 3/3] enic: add ethtool support for set/get rx_copybreak
Date: Tue, 22 Jul 2014 23:01:08 +0530
Message-ID: <1406050268-13329-4-git-send-email-_govind@gmx.com>
References: <1406050268-13329-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org, ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:64731 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752620AbaGVRcR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 13:32:17 -0400
In-Reply-To: <1406050268-13329-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides set_ringparam & get_ringparam ethtool_ops to set/get
rx_copybreak.

As of now, enic does not support change of rx/tx ring size. Allow change of
rx_copybreak alone.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_ethtool.c | 31 ++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index 523c9ce..6780719 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -18,6 +18,7 @@
 
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
+#include <linux/if_vlan.h>
 
 #include "enic_res.h"
 #include "enic.h"
@@ -379,6 +380,34 @@ static int enic_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
 	return ret;
 }
 
+static void enic_get_ringparam(struct net_device *netdev,
+			       struct ethtool_ringparam *ring)
+{
+	struct enic *enic = netdev_priv(netdev);
+
+	ring->rx_max_pending = enic->rq[0].ring.desc_count;
+	ring->rx_pending = enic->rq[0].ring.desc_count;
+	ring->tx_max_pending = enic->wq[0].ring.desc_count;
+	ring->tx_pending = enic->wq[0].ring.desc_count;
+	ring->rx_copybreak_pending = enic->rx_copybreak;
+	ring->rx_max_copybreak_pending = netdev->mtu + VLAN_ETH_HLEN;
+}
+
+static int enic_set_ringparam(struct net_device *netdev,
+			      struct ethtool_ringparam *ring)
+{
+	struct enic *enic = netdev_priv(netdev);
+
+	if (ring->rx_copybreak_pending > (netdev->mtu + VLAN_ETH_HLEN) ||
+	    enic->rq[0].ring.desc_count != ring->rx_pending ||
+	    enic->wq[0].ring.desc_count != ring->tx_pending ||
+	    ring->rx_mini_pending || ring->rx_jumbo_pending)
+		return -EINVAL;
+	enic->rx_copybreak = ring->rx_copybreak_pending;
+
+	return 0;
+}
+
 static const struct ethtool_ops enic_ethtool_ops = {
 	.get_settings = enic_get_settings,
 	.get_drvinfo = enic_get_drvinfo,
@@ -391,6 +420,8 @@ static const struct ethtool_ops enic_ethtool_ops = {
 	.get_coalesce = enic_get_coalesce,
 	.set_coalesce = enic_set_coalesce,
 	.get_rxnfc = enic_get_rxnfc,
+	.get_ringparam = enic_get_ringparam,
+	.set_ringparam = enic_set_ringparam,
 };
 
 void enic_set_ethtool_ops(struct net_device *netdev)
-- 
2.0.2
