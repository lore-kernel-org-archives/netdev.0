From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 05/10] be2net: don't enable PAUSE by default
Date: Mon,  4 May 2015 02:47:17 -0400
Message-ID: <1430722042-26449-6-git-send-email-sathya.perla@emulex.com>
References: <1430722042-26449-1-git-send-email-sathya.perla@emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:63199 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752209AbbEDG7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 02:59:39 -0400
In-Reply-To: <1430722042-26449-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

The driver so far, on load, always tried to enable RX/TX general pause.
This setting always fails on certain profiles (like FCoE) where PFC is
needed. Such failures cannot be effectively communicated to the stack or
user. To fix this unpredictability in state, this patch changes the driver
behavior by not configuring pause at load time.
The user can configure it via ethtool and if the setting is disallowed,
an appropriate error is returned.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c |  5 ++++-
 drivers/net/ethernet/emulex/benet/be_main.c    | 12 ------------
 2 files changed, 4 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 61321de..8b50021 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -717,7 +717,10 @@ be_set_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *ecmd)
 	status = be_cmd_set_flow_control(adapter, ecmd->tx_pause,
 					 ecmd->rx_pause);
 	if (status) {
-		dev_warn(&adapter->pdev->dev, "Pause param set failed\n");
+		dev_warn(&adapter->pdev->dev,
+			 "Failed to set Ethernet flow control parameters\n");
+		if (base_status(status) == MCC_STATUS_FEATURE_NOT_SUPPORTED)
+			return -EOPNOTSUPP;
 		return be_cmd_status(status);
 	}
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index b25c509..66749d0 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4248,15 +4248,6 @@ static int be_setup(struct be_adapter *adapter)
 
 	be_set_rx_mode(adapter->netdev);
 
-	status = be_cmd_set_flow_control(adapter, adapter->tx_fc,
-					 adapter->rx_fc);
-	if (status)
-		be_cmd_get_flow_control(adapter, &adapter->tx_fc,
-					&adapter->rx_fc);
-
-	dev_info(&adapter->pdev->dev, "HW Flow control - TX:%d RX:%d\n",
-		 adapter->tx_fc, adapter->rx_fc);
-
 	if (be_physfn(adapter))
 		be_cmd_set_logical_link_config(adapter,
 					       IFLA_VF_LINK_STATE_AUTO, 0);
@@ -5441,9 +5432,6 @@ static int be_drv_init(struct be_adapter *adapter)
 	INIT_DELAYED_WORK(&adapter->be_err_detection_work,
 			  be_err_detection_task);
 
-	adapter->rx_fc = true;
-	adapter->tx_fc = true;
-
 	/* Must be a power of 2 or else MODULO will BUG_ON */
 	adapter->be_get_temp_freq = 64;
 
-- 
2.2.0
