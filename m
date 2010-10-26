From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH] qlcnic: reduce RX ring size for nic partition
Date: Tue, 26 Oct 2010 02:38:00 -0700
Message-ID: <1288085882-11988-3-git-send-email-amit.salecha@qlogic.com>
References: <1288085882-11988-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:53315 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754188Ab0JZJiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 05:38:04 -0400
In-Reply-To: <1288085882-11988-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

For NIC Partition adapter, rcv ring size can be reduce, as
physical port is partition-ed.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    4 ++++
 drivers/net/qlcnic/qlcnic_ethtool.c |   23 +++++------------------
 drivers/net/qlcnic/qlcnic_main.c    |   14 ++++++++++++--
 3 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index a60ff17..6400e6a 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -146,11 +146,13 @@
 #define MAX_CMD_DESCRIPTORS		1024
 #define MAX_RCV_DESCRIPTORS_1G		4096
 #define MAX_RCV_DESCRIPTORS_10G 	8192
+#define MAX_RCV_DESCRIPTORS_VF		2048
 #define MAX_JUMBO_RCV_DESCRIPTORS_1G	512
 #define MAX_JUMBO_RCV_DESCRIPTORS_10G	1024
 
 #define DEFAULT_RCV_DESCRIPTORS_1G	2048
 #define DEFAULT_RCV_DESCRIPTORS_10G	4096
+#define DEFAULT_RCV_DESCRIPTORS_VF	1024
 #define MAX_RDS_RINGS                   2
 
 #define get_next_index(index, length)	\
@@ -971,6 +973,8 @@ struct qlcnic_adapter {
 	u16 num_txd;
 	u16 num_rxd;
 	u16 num_jumbo_rxd;
+	u16 max_rxd;
+	u16 max_jumbo_rxd;
 
 	u8 max_rds_rings;
 	u8 max_sds_rings;
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 25e93a5..ec21d24 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -437,14 +437,8 @@ qlcnic_get_ringparam(struct net_device *dev,
 	ring->rx_jumbo_pending = adapter->num_jumbo_rxd;
 	ring->tx_pending = adapter->num_txd;
 
-	if (adapter->ahw.port_type == QLCNIC_GBE) {
-		ring->rx_max_pending = MAX_RCV_DESCRIPTORS_1G;
-		ring->rx_jumbo_max_pending = MAX_JUMBO_RCV_DESCRIPTORS_1G;
-	} else {
-		ring->rx_max_pending = MAX_RCV_DESCRIPTORS_10G;
-		ring->rx_jumbo_max_pending = MAX_JUMBO_RCV_DESCRIPTORS_10G;
-	}
-
+	ring->rx_max_pending = adapter->max_rxd;
+	ring->rx_jumbo_max_pending = adapter->max_jumbo_rxd;
 	ring->tx_max_pending = MAX_CMD_DESCRIPTORS;
 
 	ring->rx_mini_max_pending = 0;
@@ -472,24 +466,17 @@ qlcnic_set_ringparam(struct net_device *dev,
 		struct ethtool_ringparam *ring)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
-	u16 max_rcv_desc = MAX_RCV_DESCRIPTORS_10G;
-	u16 max_jumbo_desc = MAX_JUMBO_RCV_DESCRIPTORS_10G;
 	u16 num_rxd, num_jumbo_rxd, num_txd;
 
-
 	if (ring->rx_mini_pending)
 		return -EOPNOTSUPP;
 
-	if (adapter->ahw.port_type == QLCNIC_GBE) {
-		max_rcv_desc = MAX_RCV_DESCRIPTORS_1G;
-		max_jumbo_desc = MAX_JUMBO_RCV_DESCRIPTORS_10G;
-	}
-
 	num_rxd = qlcnic_validate_ringparam(ring->rx_pending,
-			MIN_RCV_DESCRIPTORS, max_rcv_desc, "rx");
+			MIN_RCV_DESCRIPTORS, adapter->max_rxd, "rx");
 
 	num_jumbo_rxd = qlcnic_validate_ringparam(ring->rx_jumbo_pending,
-			MIN_JUMBO_DESCRIPTORS, max_jumbo_desc, "rx jumbo");
+			MIN_JUMBO_DESCRIPTORS, adapter->max_jumbo_rxd,
+						"rx jumbo");
 
 	num_txd = qlcnic_validate_ringparam(ring->tx_pending,
 			MIN_CMD_DESCRIPTORS, MAX_CMD_DESCRIPTORS, "tx");
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 5a3ce08..7a298cd 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -656,13 +656,23 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 
 	dev_info(&pdev->dev, "firmware v%d.%d.%d\n",
 			fw_major, fw_minor, fw_build);
-
 	if (adapter->ahw.port_type == QLCNIC_XGBE) {
-		adapter->num_rxd = DEFAULT_RCV_DESCRIPTORS_10G;
+		if (adapter->flags & QLCNIC_ESWITCH_ENABLED) {
+			adapter->num_rxd = DEFAULT_RCV_DESCRIPTORS_VF;
+			adapter->max_rxd = MAX_RCV_DESCRIPTORS_VF;
+		} else {
+			adapter->num_rxd = DEFAULT_RCV_DESCRIPTORS_10G;
+			adapter->max_rxd = MAX_RCV_DESCRIPTORS_10G;
+		}
+
 		adapter->num_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_10G;
+		adapter->max_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_10G;
+
 	} else if (adapter->ahw.port_type == QLCNIC_GBE) {
 		adapter->num_rxd = DEFAULT_RCV_DESCRIPTORS_1G;
 		adapter->num_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_1G;
+		adapter->max_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_1G;
+		adapter->max_rxd = MAX_RCV_DESCRIPTORS_1G;
 	}
 
 	adapter->msix_supported = !!use_msi_x;
-- 
1.6.0.2

