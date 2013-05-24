From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 04/12] qlcnic: Remove qlcnic_config_npars module parameter
Date: Fri, 24 May 2013 03:04:28 -0400
Message-ID: <1369379076-4718-5-git-send-email-shahed.shaikh@qlogic.com>
References: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe004.messaging.microsoft.com ([207.46.163.27]:2151 "EHLO
	co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759920Ab3EXH3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 03:29:52 -0400
In-Reply-To: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

  qlcnic_config_npars module parameter is used to configure NPAR
  operational modes where NPAR function is used for PCI passthrough.
  Removing this paramter as PCI passthrough is not supported for
  NPAR functions.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    1 -
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c  |   21 +++++------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   24 ++++---------------
 3 files changed, 11 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 019c5f7..e8127c2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -303,7 +303,6 @@ extern int qlcnic_use_msi;
 extern int qlcnic_use_msi_x;
 extern int qlcnic_auto_fw_reset;
 extern int qlcnic_load_fw_file;
-extern int qlcnic_config_npars;
 
 /* Number of status descriptors to handle per interrupt */
 #define MAX_STATUS_HANDLE	(64)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
index b0c3de9..55e5e1b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
@@ -42,27 +42,18 @@ int qlcnic_83xx_disable_vnic_mode(struct qlcnic_adapter *adapter, int lock)
 static int qlcnic_83xx_set_vnic_opmode(struct qlcnic_adapter *adapter)
 {
 	u8 id;
-	int i, ret = -EBUSY;
+	int ret = -EBUSY;
 	u32 data = QLCNIC_MGMT_FUNC;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	if (qlcnic_83xx_lock_driver(adapter))
 		return ret;
 
-	if (qlcnic_config_npars) {
-		for (i = 0; i < ahw->act_pci_func; i++) {
-			id = adapter->npars[i].pci_func;
-			if (id == ahw->pci_func)
-				continue;
-			data |= qlcnic_config_npars &
-				QLC_83XX_SET_FUNC_OPMODE(0x3, id);
-		}
-	} else {
-		data = QLCRDX(adapter->ahw, QLC_83XX_DRV_OP_MODE);
-		data = (data & ~QLC_83XX_SET_FUNC_OPMODE(0x3, ahw->pci_func)) |
-		       QLC_83XX_SET_FUNC_OPMODE(QLCNIC_MGMT_FUNC,
-						ahw->pci_func);
-	}
+	id = ahw->pci_func;
+	data = QLCRDX(adapter->ahw, QLC_83XX_DRV_OP_MODE);
+	data = (data & ~QLC_83XX_SET_FUNC_OPMODE(0x3, id)) |
+	       QLC_83XX_SET_FUNC_OPMODE(QLCNIC_MGMT_FUNC, id);
+
 	QLCWRX(adapter->ahw, QLC_83XX_DRV_OP_MODE, data);
 
 	qlcnic_83xx_unlock_driver(adapter);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 4099cf2..bf78903 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -52,10 +52,6 @@ int qlcnic_load_fw_file;
 MODULE_PARM_DESC(load_fw_file, "Load firmware from (0=flash, 1=file)");
 module_param_named(load_fw_file, qlcnic_load_fw_file, int, 0444);
 
-int qlcnic_config_npars;
-module_param(qlcnic_config_npars, int, 0444);
-MODULE_PARM_DESC(qlcnic_config_npars, "Configure NPARs (0=disabled, 1=enabled)");
-
 static int qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent);
 static void qlcnic_remove(struct pci_dev *pdev);
 static int qlcnic_open(struct net_device *netdev);
@@ -774,7 +770,7 @@ static int
 qlcnic_set_function_modes(struct qlcnic_adapter *adapter)
 {
 	u8 id;
-	int i, ret = 1;
+	int ret;
 	u32 data = QLCNIC_MGMT_FUNC;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
@@ -782,20 +778,10 @@ qlcnic_set_function_modes(struct qlcnic_adapter *adapter)
 	if (ret)
 		goto err_lock;
 
-	if (qlcnic_config_npars) {
-		for (i = 0; i < ahw->act_pci_func; i++) {
-			id = adapter->npars[i].pci_func;
-			if (id == ahw->pci_func)
-				continue;
-			data |= (qlcnic_config_npars &
-					QLC_DEV_SET_DRV(0xf, id));
-		}
-	} else {
-		data = QLC_SHARED_REG_RD32(adapter, QLCNIC_DRV_OP_MODE);
-		data = (data & ~QLC_DEV_SET_DRV(0xf, ahw->pci_func)) |
-			(QLC_DEV_SET_DRV(QLCNIC_MGMT_FUNC,
-					 ahw->pci_func));
-	}
+	id = ahw->pci_func;
+	data = QLC_SHARED_REG_RD32(adapter, QLCNIC_DRV_OP_MODE);
+	data = (data & ~QLC_DEV_SET_DRV(0xf, id)) |
+	       QLC_DEV_SET_DRV(QLCNIC_MGMT_FUNC, id);
 	QLC_SHARED_REG_WR32(adapter, QLCNIC_DRV_OP_MODE, data);
 	qlcnic_api_unlock(adapter);
 err_lock:
-- 
1.5.6
