From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 2/7] be2net: fix failure case in setting flow control
Date: Tue, 20 Jan 2015 03:51:44 -0500
Message-ID: <1421743909-14716-3-git-send-email-sathya.perla@emulex.com>
References: <1421743909-14716-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:42758 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027AbbATIs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 03:48:59 -0500
In-Reply-To: <1421743909-14716-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

When the FW cmd to set flow control fails, the adapter state must simply
reflect the old values.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 14 ++++++++------
 drivers/net/ethernet/emulex/benet/be_main.c    | 12 +++++++-----
 2 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 32c53bc..4d2de47 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -705,15 +705,17 @@ be_set_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *ecmd)
 
 	if (ecmd->autoneg != adapter->phy.fc_autoneg)
 		return -EINVAL;
-	adapter->tx_fc = ecmd->tx_pause;
-	adapter->rx_fc = ecmd->rx_pause;
 
-	status = be_cmd_set_flow_control(adapter,
-					 adapter->tx_fc, adapter->rx_fc);
-	if (status)
+	status = be_cmd_set_flow_control(adapter, ecmd->tx_pause,
+					 ecmd->rx_pause);
+	if (status) {
 		dev_warn(&adapter->pdev->dev, "Pause param set failed\n");
+		return be_cmd_status(status);
+	}
 
-	return be_cmd_status(status);
+	adapter->tx_fc = ecmd->tx_pause;
+	adapter->rx_fc = ecmd->rx_pause;
+	return 0;
 }
 
 static int be_set_phys_id(struct net_device *netdev,
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index c40d7ef..f5ac35c 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3667,7 +3667,6 @@ int be_update_queues(struct be_adapter *adapter)
 static int be_setup(struct be_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
-	u32 tx_fc, rx_fc;
 	int status;
 
 	be_setup_init(adapter);
@@ -3717,11 +3716,14 @@ static int be_setup(struct be_adapter *adapter)
 
 	be_cmd_get_acpi_wol_cap(adapter);
 
-	be_cmd_get_flow_control(adapter, &tx_fc, &rx_fc);
+	status = be_cmd_set_flow_control(adapter, adapter->tx_fc,
+					 adapter->rx_fc);
+	if (status)
+		be_cmd_get_flow_control(adapter, &adapter->tx_fc,
+					&adapter->rx_fc);
 
-	if (rx_fc != adapter->rx_fc || tx_fc != adapter->tx_fc)
-		be_cmd_set_flow_control(adapter, adapter->tx_fc,
-					adapter->rx_fc);
+	dev_info(&adapter->pdev->dev, "HW Flow control - TX:%d RX:%d\n",
+		 adapter->tx_fc, adapter->rx_fc);
 
 	if (be_physfn(adapter))
 		be_cmd_set_logical_link_config(adapter,
-- 
2.2.0
