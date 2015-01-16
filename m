From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 05/12] amd-xgbe: Clear all state during a device
 restart
Date: Fri, 16 Jan 2015 12:46:45 -0600
Message-ID: <20150116184645.18809.13704.stgit@tlendack-t1.amdoffice.net>
References: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [165.204.77.2] ([165.204.77.2]:44032 "EHLO
	tlendack-t1.amdoffice.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756802AbbAPSyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 13:54:31 -0500
In-Reply-To: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When performing a device restart, like during an MTU change, sometimes
the device queues still have data and get hung up trying to flush
resulting in the device becoming unresponsive until brought down and
back up. To prevent this, always perform a device reset during a
restart.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c  |   18 ++++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c  |   11 +++++------
 drivers/net/ethernet/amd/xgbe/xgbe-main.c |    1 +
 3 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 53f5f66..e424997 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -2107,6 +2107,23 @@ static void xgbe_config_jumbo_enable(struct xgbe_prv_data *pdata)
 	XGMAC_IOWRITE_BITS(pdata, MAC_RCR, JE, val);
 }
 
+static void xgbe_config_mac_speed(struct xgbe_prv_data *pdata)
+{
+	switch (pdata->phy_speed) {
+	case SPEED_10000:
+		xgbe_set_xgmii_speed(pdata);
+		break;
+
+	case SPEED_2500:
+		xgbe_set_gmii_2500_speed(pdata);
+		break;
+
+	case SPEED_1000:
+		xgbe_set_gmii_speed(pdata);
+		break;
+	}
+}
+
 static void xgbe_config_checksum_offload(struct xgbe_prv_data *pdata)
 {
 	if (pdata->netdev->features & NETIF_F_RXCSUM)
@@ -2757,6 +2774,7 @@ static int xgbe_init(struct xgbe_prv_data *pdata)
 	xgbe_config_mac_address(pdata);
 	xgbe_config_jumbo_enable(pdata);
 	xgbe_config_flow_control(pdata);
+	xgbe_config_mac_speed(pdata);
 	xgbe_config_checksum_offload(pdata);
 	xgbe_config_vlan_support(pdata);
 	xgbe_config_mmc(pdata);
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index e2e9217..bdb373c 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -927,7 +927,7 @@ static void xgbe_stop(struct xgbe_prv_data *pdata)
 	DBGPR("<--xgbe_stop\n");
 }
 
-static void xgbe_restart_dev(struct xgbe_prv_data *pdata, unsigned int reset)
+static void xgbe_restart_dev(struct xgbe_prv_data *pdata)
 {
 	struct xgbe_channel *channel;
 	struct xgbe_hw_if *hw_if = &pdata->hw_if;
@@ -950,9 +950,8 @@ static void xgbe_restart_dev(struct xgbe_prv_data *pdata, unsigned int reset)
 	xgbe_free_tx_data(pdata);
 	xgbe_free_rx_data(pdata);
 
-	/* Issue software reset to device if requested */
-	if (reset)
-		hw_if->exit(pdata);
+	/* Issue software reset to device */
+	hw_if->exit(pdata);
 
 	xgbe_start(pdata);
 
@@ -967,7 +966,7 @@ static void xgbe_restart(struct work_struct *work)
 
 	rtnl_lock();
 
-	xgbe_restart_dev(pdata, 1);
+	xgbe_restart_dev(pdata);
 
 	rtnl_unlock();
 }
@@ -1587,7 +1586,7 @@ static int xgbe_change_mtu(struct net_device *netdev, int mtu)
 	pdata->rx_buf_size = ret;
 	netdev->mtu = mtu;
 
-	xgbe_restart_dev(pdata, 0);
+	xgbe_restart_dev(pdata);
 
 	DBGPR("<--xgbe_change_mtu\n");
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index dbd3850..a50dccd 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -148,6 +148,7 @@ static void xgbe_default_config(struct xgbe_prv_data *pdata)
 	pdata->pause_autoneg = 1;
 	pdata->tx_pause = 1;
 	pdata->rx_pause = 1;
+	pdata->phy_speed = SPEED_UNKNOWN;
 	pdata->power_down = 0;
 	pdata->default_autoneg = AUTONEG_ENABLE;
 	pdata->default_speed = SPEED_10000;
