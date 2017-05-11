From: Manish Chopra <manish.chopra@cavium.com>
Subject: [PATCH net 1/2] qlcnic: Fix link configuration with autoneg disabled
Date: Thu, 11 May 2017 07:12:47 -0700
Message-ID: <20170511141248.996-2-manish.chopra@cavium.com>
References: <20170511141248.996-1-manish.chopra@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0087.outbound.protection.outlook.com ([104.47.41.87]:44177
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932294AbdEKONM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 11 May 2017 10:13:12 -0400
In-Reply-To: <20170511141248.996-1-manish.chopra@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently driver returns error on speed configurations
for 83xx adapter's non XGBE ports, due to this link doesn't
come up on the ports using 1000Base-T as a connector with
autoneg disabled. This patch fixes this with initializing
appropriate port type based on queried module/connector
types from hardware before any speed/autoneg configuration.

Signed-off-by: Manish Chopra <manish.chopra@cavium.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    | 34 ++++++++++++++++++++++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |  1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |  3 ++
 3 files changed, 38 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 718bf58..4fb6879 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -3168,6 +3168,40 @@ int qlcnic_83xx_flash_read32(struct qlcnic_adapter *adapter, u32 flash_addr,
 	return 0;
 }
 
+void qlcnic_83xx_get_port_type(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	struct qlcnic_cmd_args cmd;
+	u32 config;
+	int err;
+
+	err = qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_GET_LINK_STATUS);
+	if (err)
+		return;
+
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	if (err) {
+		dev_info(&adapter->pdev->dev,
+			 "Get Link Status Command failed: 0x%x\n", err);
+		goto out;
+	} else {
+		config = cmd.rsp.arg[3];
+
+		switch (QLC_83XX_SFP_MODULE_TYPE(config)) {
+		case QLC_83XX_MODULE_FIBRE_1000BASE_SX:
+		case QLC_83XX_MODULE_FIBRE_1000BASE_LX:
+		case QLC_83XX_MODULE_FIBRE_1000BASE_CX:
+		case QLC_83XX_MODULE_TP_1000BASE_T:
+			ahw->port_type = QLCNIC_GBE;
+			break;
+		default:
+			ahw->port_type = QLCNIC_XGBE;
+		}
+	}
+out:
+	qlcnic_free_mbx_args(&cmd);
+}
+
 int qlcnic_83xx_test_link(struct qlcnic_adapter *adapter)
 {
 	u8 pci_func;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 3dfe8e2..b75a812 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -637,6 +637,7 @@ void qlcnic_83xx_get_pauseparam(struct qlcnic_adapter *,
 int qlcnic_83xx_set_pauseparam(struct qlcnic_adapter *,
 			       struct ethtool_pauseparam *);
 int qlcnic_83xx_test_link(struct qlcnic_adapter *);
+void qlcnic_83xx_get_port_type(struct qlcnic_adapter *adapter);
 int qlcnic_83xx_reg_test(struct qlcnic_adapter *);
 int qlcnic_83xx_get_regs_len(struct qlcnic_adapter *);
 int qlcnic_83xx_get_registers(struct qlcnic_adapter *, u32 *);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 9a869c1..7f7deea 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -486,6 +486,9 @@ static int qlcnic_set_link_ksettings(struct net_device *dev,
 	u32 ret = 0;
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 
+	if (qlcnic_83xx_check(adapter))
+		qlcnic_83xx_get_port_type(adapter);
+
 	if (adapter->ahw->port_type != QLCNIC_GBE)
 		return -EOPNOTSUPP;
 
-- 
2.7.2
