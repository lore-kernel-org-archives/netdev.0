From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next 2/7] qlcnic: Enhance Tx timeout debugging.
Date: Thu, 23 Jan 2014 17:18:29 -0500
Message-ID: <eec7b2aff7e432b2f0d5cb2fa42a5ef0520468e0.1390491376.git.himanshu.madhani@qlogic.com>
References: <cover.1390491376.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:37583 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755614AbaAWWww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 17:52:52 -0500
In-Reply-To: <cover.1390491376.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

o Dump each Tx queue details with all descriptors, queue indices
  and Tx queue stats to imporve data colletion in situations
  where Tx timeout occurs.

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   | 69 ++++++++++++++++------
 2 files changed, 51 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index f19cec8..cdd33d0 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -383,7 +383,7 @@ static int qlcnic_83xx_idc_tx_soft_reset(struct qlcnic_adapter *adapter)
 	qlcnic_up(adapter, netdev);
 	netif_device_attach(netdev);
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
-	dev_err(&adapter->pdev->dev, "%s:\n", __func__);
+	netdev_info(adapter->netdev, "%s: soft reset complete.\n", __func__);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index e2ee2bb..39b6310 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2007,7 +2007,7 @@ qlcnic_reset_hw_context(struct qlcnic_adapter *adapter)
 	netif_device_attach(netdev);
 
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
-	dev_err(&adapter->pdev->dev, "%s:\n", __func__);
+	netdev_info(adapter->netdev, "%s: soft reset complete\n", __func__);
 	return 0;
 }
 
@@ -2747,12 +2747,58 @@ int qlcnic_check_temp(struct qlcnic_adapter *adapter)
 	return rv;
 }
 
-static void qlcnic_tx_timeout(struct net_device *netdev)
+static inline void dump_tx_ring_desc(struct qlcnic_host_tx_ring *tx_ring)
 {
-	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	int i;
+	struct cmd_desc_type0 *tx_desc_info;
+
+	for (i = 0; i < tx_ring->num_desc; i++) {
+		tx_desc_info = &tx_ring->desc_head[i];
+		pr_info("TX Desc: %d\n", i);
+		print_hex_dump(KERN_INFO, "TX: ", DUMP_PREFIX_OFFSET, 16, 1,
+			       &tx_ring->desc_head[i],
+			       sizeof(struct cmd_desc_type0), true);
+	}
+}
+
+static void qlcnic_dump_tx_rings(struct qlcnic_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
 	struct qlcnic_host_tx_ring *tx_ring;
 	int ring;
 
+	if (!netdev || !netif_running(netdev))
+		return;
+
+	for (ring = 0; ring < adapter->drv_tx_rings; ring++) {
+		tx_ring = &adapter->tx_ring[ring];
+		netdev_info(netdev, "Tx ring=%d Context Id=0x%x\n",
+			    ring, tx_ring->ctx_id);
+		netdev_info(netdev,
+			    "xmit_finished=%llu, xmit_called=%llu, xmit_on=%llu, xmit_off=%llu\n",
+			    tx_ring->tx_stats.xmit_finished,
+			    tx_ring->tx_stats.xmit_called,
+			    tx_ring->tx_stats.xmit_on,
+			    tx_ring->tx_stats.xmit_off);
+		netdev_info(netdev,
+			    "crb_intr_mask=%d, hw_producer=%d, sw_producer=%d sw_consumer=%d, hw_consumer=%d\n",
+			    readl(tx_ring->crb_intr_mask),
+			    readl(tx_ring->crb_cmd_producer),
+			    tx_ring->producer, tx_ring->sw_consumer,
+			    le32_to_cpu(*(tx_ring->hw_consumer)));
+
+		netdev_info(netdev, "Total desc=%d, Available desc=%d\n",
+			    tx_ring->num_desc, qlcnic_tx_avail(tx_ring));
+
+		if (netif_msg_tx_done(adapter->ahw))
+			dump_tx_ring_desc(tx_ring);
+	}
+}
+
+static void qlcnic_tx_timeout(struct net_device *netdev)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+
 	if (test_bit(__QLCNIC_RESETTING, &adapter->state))
 		return;
 
@@ -2765,22 +2811,7 @@ static void qlcnic_tx_timeout(struct net_device *netdev)
 						      QLCNIC_FORCE_FW_DUMP_KEY);
 	} else {
 		netdev_info(netdev, "Tx timeout, reset adapter context.\n");
-		for (ring = 0; ring < adapter->drv_tx_rings; ring++) {
-			tx_ring = &adapter->tx_ring[ring];
-			netdev_info(netdev, "Tx ring=%d\n", ring);
-			netdev_info(netdev,
-				    "crb_intr_mask=%d, producer=%d, sw_consumer=%d, hw_consumer=%d\n",
-				    readl(tx_ring->crb_intr_mask),
-				    readl(tx_ring->crb_cmd_producer),
-				    tx_ring->sw_consumer,
-				    le32_to_cpu(*(tx_ring->hw_consumer)));
-			netdev_info(netdev,
-				    "xmit_finished=%llu, xmit_called=%llu, xmit_on=%llu, xmit_off=%llu\n",
-				    tx_ring->tx_stats.xmit_finished,
-				    tx_ring->tx_stats.xmit_called,
-				    tx_ring->tx_stats.xmit_on,
-				    tx_ring->tx_stats.xmit_off);
-		}
+		qlcnic_dump_tx_rings(adapter);
 		adapter->ahw->reset_context = 1;
 	}
 }
-- 
1.8.1.4
