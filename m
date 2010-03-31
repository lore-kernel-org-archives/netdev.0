From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 6/8] qlcnic: add driver debug support
Date: Wed, 31 Mar 2010 05:03:44 -0700
Message-ID: <1270037026-9062-7-git-send-email-amit.salecha@qlogic.com>
References: <1270037026-9062-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:20938 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S932222Ab0CaMDt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 08:03:49 -0400
In-Reply-To: <1270037026-9062-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    9 ++++++++-
 drivers/net/qlcnic/qlcnic_ethtool.c |   16 ++++++++++++++++
 drivers/net/qlcnic/qlcnic_hw.c      |    6 +++++-
 drivers/net/qlcnic/qlcnic_main.c    |   23 ++++++++++++++++++++---
 4 files changed, 49 insertions(+), 5 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 87cd1a7..dbf6335 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -960,7 +960,7 @@ struct qlcnic_adapter {
 	u8 diag_cnt;
 	u8 reset_ack_timeo;
 	u8 dev_init_timeo;
-	u8 rsrd1;
+	u8 msglvl;
 
 	u8 mac_addr[ETH_ALEN];
 
@@ -1135,4 +1135,11 @@ static inline u32 qlcnic_tx_avail(struct qlcnic_host_tx_ring *tx_ring)
 
 extern const struct ethtool_ops qlcnic_ethtool_ops;
 
+#define QLCDB(adapter, _fmt, _args...) do { \
+	if (adapter->msglvl) \
+		printk(KERN_INFO "%s: %s: " _fmt,		\
+			dev_name(&adapter->pdev->dev),\
+			__func__, ##_args);		\
+	} while (0)
+
 #endif				/* __QLCNIC_H_ */
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index f83e15f..1cf3e59 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -998,6 +998,20 @@ static int qlcnic_set_flags(struct net_device *netdev, u32 data)
 	return 0;
 }
 
+static u32 qlcnic_get_msglevel(struct net_device *netdev)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+
+	return adapter->msglvl;
+}
+
+static void qlcnic_set_msglevel(struct net_device *netdev, u32 msglvl)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+
+	adapter->msglvl = !!msglvl;
+}
+
 const struct ethtool_ops qlcnic_ethtool_ops = {
 	.get_settings = qlcnic_get_settings,
 	.set_settings = qlcnic_set_settings,
@@ -1029,4 +1043,6 @@ const struct ethtool_ops qlcnic_ethtool_ops = {
 	.get_flags = ethtool_op_get_flags,
 	.set_flags = qlcnic_set_flags,
 	.phys_id = qlcnic_blink_led,
+	.set_msglevel = qlcnic_set_msglevel,
+	.get_msglevel = qlcnic_get_msglevel,
 };
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 0933c2d..14c999a 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -294,8 +294,12 @@ qlcnic_pcie_sem_lock(struct qlcnic_adapter *adapter, int sem, u32 id_reg)
 		done = QLCRD32(adapter, QLCNIC_PCIE_REG(PCIE_SEM_LOCK(sem)));
 		if (done == 1)
 			break;
-		if (++timeout >= QLCNIC_PCIE_SEM_TIMEOUT)
+		if (++timeout >= QLCNIC_PCIE_SEM_TIMEOUT) {
+			dev_err(&adapter->pdev->dev,
+				"Failed to acquire sem=%d lock;reg_id=%d\n",
+				sem, id_reg);
 			return -EIO;
+		}
 		msleep(1);
 	}
 
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 38e0829..87511f1 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1742,6 +1742,7 @@ static void qlcnic_tx_timeout_task(struct work_struct *work)
 request_reset:
 	adapter->need_fw_reset = 1;
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
+	QLCDB(adapter, "Resetting adapter\n");
 }
 
 static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev)
@@ -2046,6 +2047,7 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 	}
 
 	prev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	QLCDB(adapter, "Device state = %u\n", prev_state);
 
 	switch (prev_state) {
 	case QLCNIC_DEV_COLD:
@@ -2082,8 +2084,11 @@ start_fw:
 	} while ((QLCRD32(adapter, QLCNIC_CRB_DEV_STATE) != QLCNIC_DEV_READY)
 			&& --dev_init_timeo);
 
-	if (!dev_init_timeo)
+	if (!dev_init_timeo) {
+		dev_err(&adapter->pdev->dev,
+			"Waiting for device to initialize timeout\n");
 		return -1;
+	}
 
 	if (qlcnic_api_lock(adapter))
 		return -1;
@@ -2113,6 +2118,7 @@ qlcnic_fwinit_work(struct work_struct *work)
 			return;
 		}
 
+		QLCDB(adapter, "Resetting FW\n");
 		if (!qlcnic_start_firmware(adapter)) {
 			qlcnic_schedule_work(adapter, qlcnic_attach_work, 0);
 			return;
@@ -2121,10 +2127,15 @@ qlcnic_fwinit_work(struct work_struct *work)
 		goto err_ret;
 	}
 
-	if (adapter->fw_wait_cnt++ > (adapter->dev_init_timeo / 2))
+	if (adapter->fw_wait_cnt++ > (adapter->dev_init_timeo / 2)) {
+		dev_err(&adapter->pdev->dev,
+				"Waiting for device to reset timeout\n");
 		goto err_ret;
+	}
 
 	dev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	QLCDB(adapter, "Func waiting: Device state=%d\n", dev_state);
+
 	switch (dev_state) {
 	case QLCNIC_DEV_READY:
 		if (!qlcnic_start_firmware(adapter)) {
@@ -2177,6 +2188,8 @@ qlcnic_detach_work(struct work_struct *work)
 	return;
 
 err_ret:
+	dev_err(&adapter->pdev->dev, "detach failed; status=%d temp=%d\n",
+			status, adapter->temp);
 	qlcnic_clr_all_drv_state(adapter);
 
 }
@@ -2194,6 +2207,7 @@ qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
 	if (state != QLCNIC_DEV_INITALIZING && state != QLCNIC_DEV_NEED_RESET) {
 		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_NEED_RESET);
 		set_bit(__QLCNIC_START_FW, &adapter->state);
+		QLCDB(adapter, "NEED_RESET state set\n");
 	}
 
 	qlcnic_api_unlock(adapter);
@@ -2290,8 +2304,11 @@ detach:
 		QLCNIC_DEV_NEED_RESET;
 
 	if ((auto_fw_reset == AUTO_FW_RESET_ENABLED) &&
-			!test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
+		!test_and_set_bit(__QLCNIC_RESETTING, &adapter->state)) {
+
 		qlcnic_schedule_work(adapter, qlcnic_detach_work, 0);
+		QLCDB(adapter, "fw recovery scheduled.\n");
+	}
 
 	return 1;
 }
-- 
1.6.0.2

