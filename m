From: sthemmin@exchange.microsoft.com
Subject: [PATCH 3/7] hv_netvsc: simplify callback event code
Date: Thu, 22 Sep 2016 16:56:31 -0700
Message-ID: <1474588595-16054-4-git-send-email-sthemmin@exchange.microsoft.com>
References: <1474588595-16054-1-git-send-email-sthemmin@exchange.microsoft.com>
Reply-To: sthemmin@microsoft.com
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded04.prod.phx3.secureserver.net ([208.109.80.198]:54164
        "EHLO p3plsmtps2ded04.prod.phx3.secureserver.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757848AbcIVWGH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Sep 2016 18:06:07 -0400
In-Reply-To: <1474588595-16054-1-git-send-email-sthemmin@exchange.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

The callback handler for netlink events can be simplified:
 * Consolidate check for netlink callback events about this driver itself.
 * Ignore non-Ethernet devices.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |   28 ++++++++++------------------
 1 files changed, 10 insertions(+), 18 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index e74dbcc..849b566 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1238,10 +1238,6 @@ static int netvsc_register_vf(struct net_device *vf_netdev)
 	struct net_device *ndev;
 	struct net_device_context *net_device_ctx;
 	struct netvsc_device *netvsc_dev;
-	const struct ethtool_ops *eth_ops = vf_netdev->ethtool_ops;
-
-	if (eth_ops == NULL || eth_ops == &ethtool_ops)
-		return NOTIFY_DONE;
 
 	/*
 	 * We will use the MAC address to locate the synthetic interface to
@@ -1286,12 +1282,8 @@ static int netvsc_vf_up(struct net_device *vf_netdev)
 {
 	struct net_device *ndev;
 	struct netvsc_device *netvsc_dev;
-	const struct ethtool_ops *eth_ops = vf_netdev->ethtool_ops;
 	struct net_device_context *net_device_ctx;
 
-	if (eth_ops == &ethtool_ops)
-		return NOTIFY_DONE;
-
 	ndev = get_netvsc_net_device(vf_netdev->dev_addr);
 	if (!ndev)
 		return NOTIFY_DONE;
@@ -1329,10 +1321,6 @@ static int netvsc_vf_down(struct net_device *vf_netdev)
 	struct net_device *ndev;
 	struct netvsc_device *netvsc_dev;
 	struct net_device_context *net_device_ctx;
-	const struct ethtool_ops *eth_ops = vf_netdev->ethtool_ops;
-
-	if (eth_ops == &ethtool_ops)
-		return NOTIFY_DONE;
 
 	ndev = get_netvsc_net_device(vf_netdev->dev_addr);
 	if (!ndev)
@@ -1361,12 +1349,8 @@ static int netvsc_unregister_vf(struct net_device *vf_netdev)
 {
 	struct net_device *ndev;
 	struct netvsc_device *netvsc_dev;
-	const struct ethtool_ops *eth_ops = vf_netdev->ethtool_ops;
 	struct net_device_context *net_device_ctx;
 
-	if (eth_ops == &ethtool_ops)
-		return NOTIFY_DONE;
-
 	ndev = get_netvsc_net_device(vf_netdev->dev_addr);
 	if (!ndev)
 		return NOTIFY_DONE;
@@ -1542,13 +1526,21 @@ static int netvsc_netdev_event(struct notifier_block *this,
 {
 	struct net_device *event_dev = netdev_notifier_info_to_dev(ptr);
 
+	/* Skip our own events */
+	if (event_dev->netdev_ops == &device_ops)
+		return NOTIFY_DONE;
+
+	/* Avoid non-Ethernet type devices */
+	if (event_dev->type != ARPHRD_ETHER)
+		return NOTIFY_DONE;
+
 	/* Avoid Vlan dev with same MAC registering as VF */
 	if (event_dev->priv_flags & IFF_802_1Q_VLAN)
 		return NOTIFY_DONE;
 
 	/* Avoid Bonding master dev with same MAC registering as VF */
-	if (event_dev->priv_flags & IFF_BONDING &&
-	    event_dev->flags & IFF_MASTER)
+	if ((event_dev->priv_flags & IFF_BONDING) &&
+	    (event_dev->flags & IFF_MASTER))
 		return NOTIFY_DONE;
 
 	switch (event) {
-- 
1.7.4.1
