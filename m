From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 4/9] qlcnic: Store firmware dump state in CAMRAM register
Date: Fri, 30 Aug 2013 13:51:19 -0400
Message-ID: <1377885084-6441-5-git-send-email-shahed.shaikh@qlogic.com>
References: <1377885084-6441-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:37820 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756665Ab3H3SU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 14:20:26 -0400
In-Reply-To: <1377885084-6441-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

-Use CAMRAM register to store firmware dump state in adapter
 instead of maintaining it in each function driver separately.
-Return appropriate error code on failure

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    4 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |  152 ++++++++++++++++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |    8 +-
 5 files changed, 135 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 6c360d7..8ae725f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -392,7 +392,7 @@ struct qlcnic_dump_template_hdr {
 
 struct qlcnic_fw_dump {
 	u8	clr;	/* flag to indicate if dump is cleared */
-	u8	enable; /* enable/disable dump */
+	bool	enable; /* enable/disable dump */
 	u32	size;	/* total size of the dump */
 	void	*data;	/* dump data area */
 	struct	qlcnic_dump_template_hdr *tmpl_hdr;
@@ -1477,6 +1477,8 @@ int qlcnic_wol_supported(struct qlcnic_adapter *adapter);
 void qlcnic_prune_lb_filters(struct qlcnic_adapter *adapter);
 void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter);
 int qlcnic_dump_fw(struct qlcnic_adapter *);
+int qlcnic_enable_fw_dump_state(struct qlcnic_adapter *);
+bool qlcnic_check_fw_dump_state(struct qlcnic_adapter *);
 
 /* Functions from qlcnic_init.c */
 void qlcnic_schedule_work(struct qlcnic_adapter *, work_func_t, int);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 0fc5616..053a3a1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -297,6 +297,7 @@ struct qlc_83xx_reset {
 
 #define QLC_83XX_IDC_DISABLE_FW_RESET_RECOVERY		0x1
 #define QLC_83XX_IDC_GRACEFULL_RESET			0x2
+#define QLC_83XX_IDC_DISABLE_FW_DUMP			0x4
 #define QLC_83XX_IDC_TIMESTAMP				0
 #define QLC_83XX_IDC_DURATION				1
 #define QLC_83XX_IDC_INIT_TIMEOUT_SECS			30
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 7b0c90e..332aa71 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -1509,6 +1509,68 @@ static void qlcnic_set_msglevel(struct net_device *netdev, u32 msglvl)
 	adapter->ahw->msg_enable = msglvl;
 }
 
+int qlcnic_enable_fw_dump_state(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
+	u32 val;
+
+	if (qlcnic_84xx_check(adapter)) {
+		if (qlcnic_83xx_lock_driver(adapter))
+			return -EBUSY;
+
+		val = QLCRDX(adapter->ahw, QLC_83XX_IDC_CTRL);
+		val &= ~QLC_83XX_IDC_DISABLE_FW_DUMP;
+		QLCWRX(adapter->ahw, QLC_83XX_IDC_CTRL, val);
+
+		qlcnic_83xx_unlock_driver(adapter);
+	} else {
+		fw_dump->enable = true;
+	}
+
+	dev_info(&adapter->pdev->dev, "FW dump enabled\n");
+
+	return 0;
+}
+
+static int qlcnic_disable_fw_dump_state(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
+	u32 val;
+
+	if (qlcnic_84xx_check(adapter)) {
+		if (qlcnic_83xx_lock_driver(adapter))
+			return -EBUSY;
+
+		val = QLCRDX(adapter->ahw, QLC_83XX_IDC_CTRL);
+		val |= QLC_83XX_IDC_DISABLE_FW_DUMP;
+		QLCWRX(adapter->ahw, QLC_83XX_IDC_CTRL, val);
+
+		qlcnic_83xx_unlock_driver(adapter);
+	} else {
+		fw_dump->enable = false;
+	}
+
+	dev_info(&adapter->pdev->dev, "FW dump disabled\n");
+
+	return 0;
+}
+
+bool qlcnic_check_fw_dump_state(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
+	bool state;
+	u32 val;
+
+	if (qlcnic_84xx_check(adapter)) {
+		val = QLCRDX(adapter->ahw, QLC_83XX_IDC_CTRL);
+		state = (val & QLC_83XX_IDC_DISABLE_FW_DUMP) ? false : true;
+	} else {
+		state = fw_dump->enable;
+	}
+
+	return state;
+}
+
 static int
 qlcnic_get_dump_flag(struct net_device *netdev, struct ethtool_dump *dump)
 {
@@ -1525,7 +1587,7 @@ qlcnic_get_dump_flag(struct net_device *netdev, struct ethtool_dump *dump)
 	else
 		dump->len = 0;
 
-	if (!fw_dump->enable)
+	if (!qlcnic_check_fw_dump_state(adapter))
 		dump->flag = ETH_FW_DUMP_DISABLE;
 	else
 		dump->flag = fw_dump->tmpl_hdr->drv_cap_mask;
@@ -1573,77 +1635,111 @@ qlcnic_get_dump_data(struct net_device *netdev, struct ethtool_dump *dump,
 	return 0;
 }
 
+static int qlcnic_set_dump_mask(struct qlcnic_adapter *adapter, u32 mask)
+{
+	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
+	struct net_device *netdev = adapter->netdev;
+
+	if (!qlcnic_check_fw_dump_state(adapter)) {
+		netdev_info(netdev,
+			    "Can not change driver mask to 0x%x. FW dump not enabled\n",
+			    mask);
+		return -EOPNOTSUPP;
+	}
+
+	fw_dump->tmpl_hdr->drv_cap_mask = mask;
+	netdev_info(netdev, "Driver mask changed to: 0x%x\n", mask);
+	return 0;
+}
+
 static int
 qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 {
-	int i;
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
+	bool valid_mask = false;
+	int i, ret = 0;
 	u32 state;
 
 	switch (val->flag) {
 	case QLCNIC_FORCE_FW_DUMP_KEY:
 		if (!fw_dump->tmpl_hdr) {
 			netdev_err(netdev, "FW dump not supported\n");
-			return -ENOTSUPP;
+			ret = -EOPNOTSUPP;
+			break;
 		}
-		if (!fw_dump->enable) {
+
+		if (!qlcnic_check_fw_dump_state(adapter)) {
 			netdev_info(netdev, "FW dump not enabled\n");
-			return 0;
+			ret = -EOPNOTSUPP;
+			break;
 		}
+
 		if (fw_dump->clr) {
 			netdev_info(netdev,
-			"Previous dump not cleared, not forcing dump\n");
-			return 0;
+				    "Previous dump not cleared, not forcing dump\n");
+			break;
 		}
+
 		netdev_info(netdev, "Forcing a FW dump\n");
 		qlcnic_dev_request_reset(adapter, val->flag);
 		break;
 	case QLCNIC_DISABLE_FW_DUMP:
-		if (fw_dump->enable && fw_dump->tmpl_hdr) {
-			netdev_info(netdev, "Disabling FW dump\n");
-			fw_dump->enable = 0;
+		if (!fw_dump->tmpl_hdr) {
+			netdev_err(netdev, "FW dump not supported\n");
+			ret = -EOPNOTSUPP;
+			break;
 		}
-		return 0;
+
+		ret = qlcnic_disable_fw_dump_state(adapter);
+		break;
+
 	case QLCNIC_ENABLE_FW_DUMP:
 		if (!fw_dump->tmpl_hdr) {
 			netdev_err(netdev, "FW dump not supported\n");
-			return -ENOTSUPP;
-		}
-		if (!fw_dump->enable) {
-			netdev_info(netdev, "Enabling FW dump\n");
-			fw_dump->enable = 1;
+			ret = -EOPNOTSUPP;
+			break;
 		}
-		return 0;
+
+		ret = qlcnic_enable_fw_dump_state(adapter);
+		break;
+
 	case QLCNIC_FORCE_FW_RESET:
 		netdev_info(netdev, "Forcing a FW reset\n");
 		qlcnic_dev_request_reset(adapter, val->flag);
 		adapter->flags &= ~QLCNIC_FW_RESET_OWNER;
-		return 0;
+		break;
+;
 	case QLCNIC_SET_QUIESCENT:
 	case QLCNIC_RESET_QUIESCENT:
 		state = QLC_SHARED_REG_RD32(adapter, QLCNIC_CRB_DEV_STATE);
 		if (state == QLCNIC_DEV_FAILED || (state == QLCNIC_DEV_BADBAD))
 			netdev_info(netdev, "Device in FAILED state\n");
-		return 0;
+		break;
+
 	default:
 		if (!fw_dump->tmpl_hdr) {
 			netdev_err(netdev, "FW dump not supported\n");
-			return -ENOTSUPP;
+			ret = -EOPNOTSUPP;
+			break;
 		}
+
 		for (i = 0; i < ARRAY_SIZE(qlcnic_fw_dump_level); i++) {
 			if (val->flag == qlcnic_fw_dump_level[i]) {
-				fw_dump->tmpl_hdr->drv_cap_mask =
-							val->flag;
-				netdev_info(netdev, "Driver mask changed to: 0x%x\n",
-					fw_dump->tmpl_hdr->drv_cap_mask);
-				return 0;
+				valid_mask = true;
+				break;
 			}
 		}
-		netdev_info(netdev, "Invalid dump level: 0x%x\n", val->flag);
-		return -EINVAL;
+
+		if (valid_mask) {
+			ret = qlcnic_set_dump_mask(adapter, val->flag);
+		} else {
+			netdev_info(netdev, "Invalid dump level: 0x%x\n",
+				    val->flag);
+			ret = -EINVAL;
+		}
 	}
-	return 0;
+	return ret;
 }
 
 const struct ethtool_ops qlcnic_ethtool_ops = {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index c99cee8..9fe6a2d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -3045,7 +3045,7 @@ skip_ack_check:
 		qlcnic_api_unlock(adapter);
 
 		rtnl_lock();
-		if (adapter->ahw->fw_dump.enable &&
+		if (qlcnic_check_fw_dump_state(adapter) &&
 		    (adapter->flags & QLCNIC_FW_RESET_OWNER)) {
 			QLCDB(adapter, DRV, "Take FW dump\n");
 			qlcnic_dump_fw(adapter);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
index b7871fe..1551360 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
@@ -1092,7 +1092,7 @@ flash_temp:
 	else
 		ahw->fw_dump.use_pex_dma = false;
 
-	ahw->fw_dump.enable = 1;
+	qlcnic_enable_fw_dump_state(adapter);
 
 	return 0;
 }
@@ -1115,7 +1115,11 @@ int qlcnic_dump_fw(struct qlcnic_adapter *adapter)
 
 	ahw = adapter->ahw;
 
-	if (!fw_dump->enable) {
+	/* Return if we don't have firmware dump template header */
+	if (!tmpl_hdr)
+		return -EIO;
+
+	if (!qlcnic_check_fw_dump_state(adapter)) {
 		dev_info(&adapter->pdev->dev, "Dump not enabled\n");
 		return -EIO;
 	}
-- 
1.5.6
