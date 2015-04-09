From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 3/3] amd-xgbe: Add support for the netdev Tx
 watchdog
Date: Thu, 9 Apr 2015 12:12:03 -0500
Message-ID: <20150409171203.22188.36729.stgit@tlendack-t1.amdoffice.net>
References: <20150409171145.22188.37025.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0133.outbound.protection.outlook.com ([157.56.111.133]:13537
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756006AbbDIRMI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 13:12:08 -0400
In-Reply-To: <20150409171145.22188.37025.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to be able to detect a hung Tx task by adding the netdev
ndo_tx_timeout function callback. Do not set the watchdog_timeo value
so as to use the system default time (currently 5 seconds).

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c  |    9 +++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-main.c |    3 +++
 2 files changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index e10abc7..db84ddc 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1600,6 +1600,14 @@ static int xgbe_change_mtu(struct net_device *netdev, int mtu)
 	return 0;
 }
 
+static void xgbe_tx_timeout(struct net_device *netdev)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+
+	netdev_warn(netdev, "tx timeout, device restarting\n");
+	schedule_work(&pdata->restart_work);
+}
+
 static struct rtnl_link_stats64 *xgbe_get_stats64(struct net_device *netdev,
 						  struct rtnl_link_stats64 *s)
 {
@@ -1764,6 +1772,7 @@ static const struct net_device_ops xgbe_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= xgbe_ioctl,
 	.ndo_change_mtu		= xgbe_change_mtu,
+	.ndo_tx_timeout		= xgbe_tx_timeout,
 	.ndo_get_stats64	= xgbe_get_stats64,
 	.ndo_vlan_rx_add_vid	= xgbe_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= xgbe_vlan_rx_kill_vid,
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index 2e4c22d..7149053 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -491,6 +491,9 @@ static int xgbe_probe(struct platform_device *pdev)
 
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 
+	/* Use default watchdog timeout */
+	netdev->watchdog_timeo = 0;
+
 	xgbe_init_rx_coalesce(pdata);
 	xgbe_init_tx_coalesce(pdata);
 
