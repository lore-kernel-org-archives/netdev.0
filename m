From: <netanel@amazon.com>
Subject: [PATCH net-next 04/13] net: ena: add reset reason for each device FLR
Date: Sun, 18 Jun 2017 14:28:09 +0300
Message-ID: <1497785298-13468-5-git-send-email-netanel@amazon.com>
References: <1497785298-13468-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-6001.amazon.com ([52.95.48.154]:47165 "EHLO
        smtp-fw-6001.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752304AbdFRL2s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Jun 2017 07:28:48 -0400
In-Reply-To: <1497785298-13468-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

For each device reset, log to the device what is the cause
the reset occur.

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_com.c       |  5 +++-
 drivers/net/ethernet/amazon/ena/ena_com.h       |  4 +++-
 drivers/net/ethernet/amazon/ena/ena_netdev.c    | 17 +++++++++----
 drivers/net/ethernet/amazon/ena/ena_netdev.h    |  2 ++
 drivers/net/ethernet/amazon/ena/ena_regs_defs.h | 32 +++++++++++++++++++++++++
 5 files changed, 54 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
index 2721c70492a1..f6e1d30523a6 100644
--- a/drivers/net/ethernet/amazon/ena/ena_com.c
+++ b/drivers/net/ethernet/amazon/ena/ena_com.c
@@ -1825,7 +1825,8 @@ void ena_com_aenq_intr_handler(struct ena_com_dev *dev, void *data)
 	writel((u32)aenq->head, dev->reg_bar + ENA_REGS_AENQ_HEAD_DB_OFF);
 }
 
-int ena_com_dev_reset(struct ena_com_dev *ena_dev)
+int ena_com_dev_reset(struct ena_com_dev *ena_dev,
+		      enum ena_regs_reset_reason_types reset_reason)
 {
 	u32 stat, timeout, cap, reset_val;
 	int rc;
@@ -1853,6 +1854,8 @@ int ena_com_dev_reset(struct ena_com_dev *ena_dev)
 
 	/* start reset */
 	reset_val = ENA_REGS_DEV_CTL_DEV_RESET_MASK;
+	reset_val |= (reset_reason << ENA_REGS_DEV_CTL_RESET_REASON_SHIFT) &
+		     ENA_REGS_DEV_CTL_RESET_REASON_MASK;
 	writel(reset_val, ena_dev->reg_bar + ENA_REGS_DEV_CTL_OFF);
 
 	/* Write again the MMIO read request address */
diff --git a/drivers/net/ethernet/amazon/ena/ena_com.h b/drivers/net/ethernet/amazon/ena/ena_com.h
index 630c09ad35a5..7b784f8a06a6 100644
--- a/drivers/net/ethernet/amazon/ena/ena_com.h
+++ b/drivers/net/ethernet/amazon/ena/ena_com.h
@@ -420,10 +420,12 @@ void ena_com_admin_destroy(struct ena_com_dev *ena_dev);
 
 /* ena_com_dev_reset - Perform device FLR to the device.
  * @ena_dev: ENA communication layer struct
+ * @reset_reason: Specify what is the trigger for the reset in case of an error.
  *
  * @return - 0 on success, negative value on failure.
  */
-int ena_com_dev_reset(struct ena_com_dev *ena_dev);
+int ena_com_dev_reset(struct ena_com_dev *ena_dev,
+		      enum ena_regs_reset_reason_types reset_reason);
 
 /* ena_com_create_io_queue - Create io queue.
  * @ena_dev: ENA communication layer struct
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 1ee06e11654c..0d35a4cc3525 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -87,6 +87,7 @@ static void ena_tx_timeout(struct net_device *dev)
 	if (test_and_set_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags))
 		return;
 
+	adapter->reset_reason = ENA_REGS_RESET_OS_NETDEV_WD;
 	u64_stats_update_begin(&adapter->syncp);
 	adapter->dev_stats.tx_timeout++;
 	u64_stats_update_end(&adapter->syncp);
@@ -670,6 +671,7 @@ static int validate_tx_req_id(struct ena_ring *tx_ring, u16 req_id)
 	u64_stats_update_end(&tx_ring->syncp);
 
 	/* Trigger device reset */
+	tx_ring->adapter->reset_reason = ENA_REGS_RESET_INV_TX_REQ_ID;
 	set_bit(ENA_FLAG_TRIGGER_RESET, &tx_ring->adapter->flags);
 	return -EFAULT;
 }
@@ -1055,6 +1057,7 @@ static int ena_clean_rx_irq(struct ena_ring *rx_ring, struct napi_struct *napi,
 	u64_stats_update_end(&rx_ring->syncp);
 
 	/* Too many desc from the device. Trigger reset */
+	adapter->reset_reason = ENA_REGS_RESET_TOO_MANY_RX_DESCS;
 	set_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags);
 
 	return 0;
@@ -1720,7 +1723,7 @@ static void ena_down(struct ena_adapter *adapter)
 	if (test_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags)) {
 		int rc;
 
-		rc = ena_com_dev_reset(adapter->ena_dev);
+		rc = ena_com_dev_reset(adapter->ena_dev, adapter->reset_reason);
 		if (rc)
 			dev_err(&adapter->pdev->dev, "Device reset failed\n");
 	}
@@ -2353,7 +2356,7 @@ static int ena_device_init(struct ena_com_dev *ena_dev, struct pci_dev *pdev,
 	readless_supported = !(pdev->revision & ENA_MMIO_DISABLE_REG_READ);
 	ena_com_set_mmio_read_mode(ena_dev, readless_supported);
 
-	rc = ena_com_dev_reset(ena_dev);
+	rc = ena_com_dev_reset(ena_dev, ENA_REGS_RESET_NORMAL);
 	if (rc) {
 		dev_err(dev, "Can not reset device\n");
 		goto err_mmio_read_less;
@@ -2512,6 +2515,7 @@ static void ena_fw_reset_device(struct work_struct *work)
 
 	ena_com_mmio_reg_read_request_destroy(ena_dev);
 
+	adapter->reset_reason = ENA_REGS_RESET_NORMAL;
 	clear_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags);
 
 	/* Finish with the destroy part. Start the init part */
@@ -2591,6 +2595,8 @@ static int check_missing_comp_in_queue(struct ena_adapter *adapter,
 					  "The number of lost tx completions is above the threshold (%d > %d). Reset the device\n",
 					  missed_tx,
 					  adapter->missing_tx_completion_threshold);
+				adapter->reset_reason =
+					ENA_REGS_RESET_MISS_TX_CMPL;
 				set_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags);
 				return -EIO;
 			}
@@ -2705,6 +2711,7 @@ static void check_for_missing_keep_alive(struct ena_adapter *adapter)
 		u64_stats_update_begin(&adapter->syncp);
 		adapter->dev_stats.wd_expired++;
 		u64_stats_update_end(&adapter->syncp);
+		adapter->reset_reason = ENA_REGS_RESET_KEEP_ALIVE_TO;
 		set_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags);
 	}
 }
@@ -2717,6 +2724,7 @@ static void check_for_admin_com_state(struct ena_adapter *adapter)
 		u64_stats_update_begin(&adapter->syncp);
 		adapter->dev_stats.admin_q_pause++;
 		u64_stats_update_end(&adapter->syncp);
+		adapter->reset_reason = ENA_REGS_RESET_ADMIN_TO;
 		set_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags);
 	}
 }
@@ -3121,6 +3129,7 @@ static int ena_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	ena_set_conf_feat_params(adapter, &get_feat_ctx);
 
 	adapter->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
+	adapter->reset_reason = ENA_REGS_RESET_NORMAL;
 
 	adapter->tx_ring_size = queue_size;
 	adapter->rx_ring_size = queue_size;
@@ -3205,7 +3214,7 @@ static int ena_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	ena_com_delete_debug_area(ena_dev);
 	ena_com_rss_destroy(ena_dev);
 err_free_msix:
-	ena_com_dev_reset(ena_dev);
+	ena_com_dev_reset(ena_dev, ENA_REGS_RESET_INIT_ERR);
 	ena_free_mgmnt_irq(adapter);
 	pci_free_irq_vectors(adapter->pdev);
 err_worker_destroy:
@@ -3288,7 +3297,7 @@ static void ena_remove(struct pci_dev *pdev)
 
 	/* Reset the device only if the device is running. */
 	if (test_bit(ENA_FLAG_DEVICE_RUNNING, &adapter->flags))
-		ena_com_dev_reset(ena_dev);
+		ena_com_dev_reset(ena_dev, adapter->reset_reason);
 
 	ena_free_mgmnt_irq(adapter);
 
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.h b/drivers/net/ethernet/amazon/ena/ena_netdev.h
index c5fe4aa926ae..ccbb14cc3038 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.h
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.h
@@ -327,6 +327,8 @@ struct ena_adapter {
 
 	/* last queue index that was checked for uncompleted tx packets */
 	u32 last_monitored_tx_qid;
+
+	enum ena_regs_reset_reason_types reset_reason;
 };
 
 void ena_set_ethtool_ops(struct net_device *netdev);
diff --git a/drivers/net/ethernet/amazon/ena/ena_regs_defs.h b/drivers/net/ethernet/amazon/ena/ena_regs_defs.h
index c3891c521075..9aec43c5bba8 100644
--- a/drivers/net/ethernet/amazon/ena/ena_regs_defs.h
+++ b/drivers/net/ethernet/amazon/ena/ena_regs_defs.h
@@ -32,6 +32,36 @@
 #ifndef _ENA_REGS_H_
 #define _ENA_REGS_H_
 
+enum ena_regs_reset_reason_types {
+	ENA_REGS_RESET_NORMAL			= 0,
+
+	ENA_REGS_RESET_KEEP_ALIVE_TO		= 1,
+
+	ENA_REGS_RESET_ADMIN_TO			= 2,
+
+	ENA_REGS_RESET_MISS_TX_CMPL		= 3,
+
+	ENA_REGS_RESET_INV_RX_REQ_ID		= 4,
+
+	ENA_REGS_RESET_INV_TX_REQ_ID		= 5,
+
+	ENA_REGS_RESET_TOO_MANY_RX_DESCS	= 6,
+
+	ENA_REGS_RESET_INIT_ERR			= 7,
+
+	ENA_REGS_RESET_DRIVER_INVALID_STATE	= 8,
+
+	ENA_REGS_RESET_OS_TRIGGER		= 9,
+
+	ENA_REGS_RESET_OS_NETDEV_WD		= 10,
+
+	ENA_REGS_RESET_SHUTDOWN			= 11,
+
+	ENA_REGS_RESET_USER_TRIGGER		= 12,
+
+	ENA_REGS_RESET_GENERIC			= 13,
+};
+
 /* ena_registers offsets */
 #define ENA_REGS_VERSION_OFF		0x0
 #define ENA_REGS_CONTROLLER_VERSION_OFF		0x4
@@ -104,6 +134,8 @@
 #define ENA_REGS_DEV_CTL_QUIESCENT_MASK		0x4
 #define ENA_REGS_DEV_CTL_IO_RESUME_SHIFT		3
 #define ENA_REGS_DEV_CTL_IO_RESUME_MASK		0x8
+#define ENA_REGS_DEV_CTL_RESET_REASON_SHIFT		28
+#define ENA_REGS_DEV_CTL_RESET_REASON_MASK		0xf0000000
 
 /* dev_sts register */
 #define ENA_REGS_DEV_STS_READY_MASK		0x1
-- 
2.7.4
