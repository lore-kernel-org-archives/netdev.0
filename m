From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next v2 2/7] qlcnic: Enable Interrupt Coalescing for 83xx adapter
Date: Wed, 17 Apr 2013 13:05:54 -0400
Message-ID: <1366218359-17701-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1366218359-17701-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:23094 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S935915Ab3DQRab (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Apr 2013 13:30:31 -0400
In-Reply-To: <1366218359-17701-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

Enable Interrupt coalescing through ethtool on 83xx adapter.

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   12 +++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   16 ++++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   68 ++++++++++++++++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   13 +++-
 4 files changed, 87 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index ef55718..16ed1a6 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -347,8 +347,14 @@ struct qlcnic_rx_buffer {
  * Interrupt coalescing defaults. The defaults are for 1500 MTU. It is
  * adjusted based on configured MTU.
  */
-#define QLCNIC_DEFAULT_INTR_COALESCE_RX_TIME_US	3
-#define QLCNIC_DEFAULT_INTR_COALESCE_RX_PACKETS	256
+#define QLCNIC_INTR_COAL_TYPE_RX		1
+#define QLCNIC_INTR_COAL_TYPE_TX		2
+
+#define QLCNIC_DEF_INTR_COALESCE_RX_TIME_US	3
+#define QLCNIC_DEF_INTR_COALESCE_RX_PACKETS	256
+
+#define QLCNIC_DEF_INTR_COALESCE_TX_TIME_US	64
+#define QLCNIC_DEF_INTR_COALESCE_TX_PACKETS	64
 
 #define QLCNIC_INTR_DEFAULT			0x04
 #define QLCNIC_CONFIG_INTR_COALESCE		3
@@ -359,6 +365,8 @@ struct qlcnic_nic_intr_coalesce {
 	u8	sts_ring_mask;
 	u16	rx_packets;
 	u16	rx_time_us;
+	u16	tx_packets;
+	u16	tx_time_us;
 	u16	flag;
 	u32	timer_out;
 };
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index e741f8c..e07aea8 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -1870,7 +1870,7 @@ int qlcnic_83xx_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
 void qlcnic_83xx_config_intr_coal(struct qlcnic_adapter *adapter)
 {
 	int err;
-	u32 temp;
+	u16 temp;
 	struct qlcnic_cmd_args cmd;
 	struct qlcnic_nic_intr_coalesce *coal = &adapter->ahw->coal;
 
@@ -1878,10 +1878,18 @@ void qlcnic_83xx_config_intr_coal(struct qlcnic_adapter *adapter)
 		return;
 
 	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_CONFIG_INTR_COAL);
-	cmd.req.arg[1] = 1 | (adapter->recv_ctx->context_id << 16);
+	if (coal->type == QLCNIC_INTR_COAL_TYPE_RX) {
+		temp = adapter->recv_ctx->context_id;
+		cmd.req.arg[1] = (QLCNIC_INTR_COAL_TYPE_RX | (temp << 16));
+		temp = coal->rx_time_us;
+		cmd.req.arg[2] = (coal->rx_packets | (temp << 16));
+	} else if (coal->type == QLCNIC_INTR_COAL_TYPE_TX) {
+		temp = adapter->tx_ring->ctx_id;
+		cmd.req.arg[1] = (QLCNIC_INTR_COAL_TYPE_TX | (temp << 16));
+		temp = coal->tx_time_us;
+		cmd.req.arg[2] = (coal->tx_packets | (temp << 16));
+	}
 	cmd.req.arg[3] = coal->flag;
-	temp = coal->rx_time_us << 16;
-	cmd.req.arg[2] = coal->rx_packets | temp;
 	err = qlcnic_issue_cmd(adapter, &cmd);
 	if (err != QLCNIC_RCODE_SUCCESS)
 		dev_info(&adapter->pdev->dev,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index f4f279d..7b56a50 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -1294,6 +1294,9 @@ static int qlcnic_set_intr_coalesce(struct net_device *netdev,
 			struct ethtool_coalesce *ethcoal)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	struct qlcnic_nic_intr_coalesce *coal;
+	u32 rx_coalesce_usecs, rx_max_frames;
+	u32 tx_coalesce_usecs, tx_max_frames;
 
 	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
 		return -EINVAL;
@@ -1304,8 +1307,8 @@ static int qlcnic_set_intr_coalesce(struct net_device *netdev,
 	*/
 	if (ethcoal->rx_coalesce_usecs > 0xffff ||
 		ethcoal->rx_max_coalesced_frames > 0xffff ||
-		ethcoal->tx_coalesce_usecs ||
-		ethcoal->tx_max_coalesced_frames ||
+		ethcoal->tx_coalesce_usecs > 0xffff ||
+		ethcoal->tx_max_coalesced_frames > 0xffff ||
 		ethcoal->rx_coalesce_usecs_irq ||
 		ethcoal->rx_max_coalesced_frames_irq ||
 		ethcoal->tx_coalesce_usecs_irq ||
@@ -1325,18 +1328,55 @@ static int qlcnic_set_intr_coalesce(struct net_device *netdev,
 		ethcoal->tx_max_coalesced_frames_high)
 		return -EINVAL;
 
-	if (!ethcoal->rx_coalesce_usecs ||
-		!ethcoal->rx_max_coalesced_frames) {
-		adapter->ahw->coal.flag = QLCNIC_INTR_DEFAULT;
-		adapter->ahw->coal.rx_time_us =
-			QLCNIC_DEFAULT_INTR_COALESCE_RX_TIME_US;
-		adapter->ahw->coal.rx_packets =
-			QLCNIC_DEFAULT_INTR_COALESCE_RX_PACKETS;
+	coal = &adapter->ahw->coal;
+
+	if (qlcnic_83xx_check(adapter)) {
+		if (!ethcoal->tx_coalesce_usecs ||
+		    !ethcoal->tx_max_coalesced_frames ||
+		    !ethcoal->rx_coalesce_usecs ||
+		    !ethcoal->rx_max_coalesced_frames) {
+			coal->flag = QLCNIC_INTR_DEFAULT;
+			coal->type = QLCNIC_INTR_COAL_TYPE_RX;
+			coal->rx_time_us = QLCNIC_DEF_INTR_COALESCE_RX_TIME_US;
+			coal->rx_packets = QLCNIC_DEF_INTR_COALESCE_RX_PACKETS;
+			coal->tx_time_us = QLCNIC_DEF_INTR_COALESCE_TX_TIME_US;
+			coal->tx_packets = QLCNIC_DEF_INTR_COALESCE_TX_PACKETS;
+		} else {
+			tx_coalesce_usecs = ethcoal->tx_coalesce_usecs;
+			tx_max_frames = ethcoal->tx_max_coalesced_frames;
+			rx_coalesce_usecs = ethcoal->rx_coalesce_usecs;
+			rx_max_frames = ethcoal->rx_max_coalesced_frames;
+			coal->flag = 0;
+
+			if ((coal->rx_time_us == rx_coalesce_usecs) &&
+			    (coal->rx_packets == rx_max_frames)) {
+				coal->type = QLCNIC_INTR_COAL_TYPE_TX;
+				coal->tx_time_us = tx_coalesce_usecs;
+				coal->tx_packets = tx_max_frames;
+			} else if ((coal->tx_time_us == tx_coalesce_usecs) &&
+				   (coal->tx_packets == tx_max_frames)) {
+				coal->type = QLCNIC_INTR_COAL_TYPE_RX;
+				coal->rx_time_us = rx_coalesce_usecs;
+				coal->rx_packets = rx_max_frames;
+			} else {
+				coal->type = QLCNIC_INTR_COAL_TYPE_RX;
+				coal->rx_time_us = rx_coalesce_usecs;
+				coal->rx_packets = rx_max_frames;
+				coal->tx_time_us = tx_coalesce_usecs;
+				coal->tx_packets = tx_max_frames;
+			}
+		}
 	} else {
-		adapter->ahw->coal.flag = 0;
-		adapter->ahw->coal.rx_time_us = ethcoal->rx_coalesce_usecs;
-		adapter->ahw->coal.rx_packets =
-			ethcoal->rx_max_coalesced_frames;
+		if (!ethcoal->rx_coalesce_usecs ||
+		    !ethcoal->rx_max_coalesced_frames) {
+			coal->flag = QLCNIC_INTR_DEFAULT;
+			coal->rx_time_us = QLCNIC_DEF_INTR_COALESCE_RX_TIME_US;
+			coal->rx_packets = QLCNIC_DEF_INTR_COALESCE_RX_PACKETS;
+		} else {
+			coal->flag = 0;
+			coal->rx_time_us = ethcoal->rx_coalesce_usecs;
+			coal->rx_packets = ethcoal->rx_max_coalesced_frames;
+		}
 	}
 
 	qlcnic_config_intr_coalesce(adapter);
@@ -1354,6 +1394,8 @@ static int qlcnic_get_intr_coalesce(struct net_device *netdev,
 
 	ethcoal->rx_coalesce_usecs = adapter->ahw->coal.rx_time_us;
 	ethcoal->rx_max_coalesced_frames = adapter->ahw->coal.rx_packets;
+	ethcoal->tx_coalesce_usecs = adapter->ahw->coal.tx_time_us;
+	ethcoal->tx_max_coalesced_frames = adapter->ahw->coal.tx_packets;
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 0d00b2b..edbc85f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1554,7 +1554,9 @@ out:
 
 static int qlcnic_alloc_adapter_resources(struct qlcnic_adapter *adapter)
 {
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	int err = 0;
+
 	adapter->recv_ctx = kzalloc(sizeof(struct qlcnic_recv_context),
 				GFP_KERNEL);
 	if (!adapter->recv_ctx) {
@@ -1562,9 +1564,14 @@ static int qlcnic_alloc_adapter_resources(struct qlcnic_adapter *adapter)
 		goto err_out;
 	}
 	/* Initialize interrupt coalesce parameters */
-	adapter->ahw->coal.flag = QLCNIC_INTR_DEFAULT;
-	adapter->ahw->coal.rx_time_us = QLCNIC_DEFAULT_INTR_COALESCE_RX_TIME_US;
-	adapter->ahw->coal.rx_packets = QLCNIC_DEFAULT_INTR_COALESCE_RX_PACKETS;
+	ahw->coal.flag = QLCNIC_INTR_DEFAULT;
+	ahw->coal.type = QLCNIC_INTR_COAL_TYPE_RX;
+	ahw->coal.rx_time_us = QLCNIC_DEF_INTR_COALESCE_RX_TIME_US;
+	ahw->coal.rx_packets = QLCNIC_DEF_INTR_COALESCE_RX_PACKETS;
+	if (qlcnic_83xx_check(adapter)) {
+		ahw->coal.tx_time_us = QLCNIC_DEF_INTR_COALESCE_TX_TIME_US;
+		ahw->coal.tx_packets = QLCNIC_DEF_INTR_COALESCE_TX_PACKETS;
+	}
 	/* clear stats */
 	memset(&adapter->stats, 0, sizeof(adapter->stats));
 err_out:
-- 
1.5.6
