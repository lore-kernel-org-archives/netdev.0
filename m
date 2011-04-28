From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 2/2] qlcnic: Support for GBE port settings
Date: Thu, 28 Apr 2011 15:33:08 -0700
Message-ID: <1304029988-18936-3-git-send-email-amit.salecha@qlogic.com>
References: <1304029988-18936-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:22504 "EHLO
	dut4145.unminc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751946Ab1D1Vd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 17:33:28 -0400
In-Reply-To: <1304029988-18936-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Enable setting speed and auto negotiation parameters for GbE ports.
Hardware do not support half duplex setting currently.

o Update driver version to 5.0.17.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    9 ++--
 drivers/net/qlcnic/qlcnic_ctx.c     |   26 ++-----------
 drivers/net/qlcnic/qlcnic_ethtool.c |   72 ++++++++++++++++-------------------
 3 files changed, 42 insertions(+), 65 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 1934ed9..f729363 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -36,8 +36,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
-#define _QLCNIC_LINUX_SUBVERSION 16
-#define QLCNIC_LINUX_VERSIONID  "5.0.16"
+#define _QLCNIC_LINUX_SUBVERSION 17
+#define QLCNIC_LINUX_VERSIONID  "5.0.17"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
@@ -573,8 +573,10 @@ struct qlcnic_recv_context {
 #define QLCNIC_CDRP_CMD_CONFIGURE_ESWITCH	0x00000028
 #define QLCNIC_CDRP_CMD_GET_ESWITCH_PORT_CONFIG	0x00000029
 #define QLCNIC_CDRP_CMD_GET_ESWITCH_STATS	0x0000002a
+#define QLCNIC_CDRP_CMD_CONFIG_PORT		0x0000002E
 
 #define QLCNIC_RCODE_SUCCESS		0
+#define QLCNIC_RCODE_NOT_SUPPORTED	9
 #define QLCNIC_RCODE_TIMEOUT		17
 #define QLCNIC_DESTROY_CTX_RESET	0
 
@@ -1155,8 +1157,7 @@ struct qlcnic_esw_statistics {
 	struct __qlcnic_esw_statistics tx;
 };
 
-int qlcnic_fw_cmd_query_phy(struct qlcnic_adapter *adapter, u32 reg, u32 *val);
-int qlcnic_fw_cmd_set_phy(struct qlcnic_adapter *adapter, u32 reg, u32 val);
+int qlcnic_fw_cmd_set_port(struct qlcnic_adapter *adapter, u32 config);
 
 u32 qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off);
 int qlcnic_hw_write_wx_2M(struct qlcnic_adapter *, ulong off, u32 data);
diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index 050fa5a..3a99886 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -359,33 +359,15 @@ qlcnic_fw_cmd_destroy_tx_ctx(struct qlcnic_adapter *adapter)
 }
 
 int
-qlcnic_fw_cmd_query_phy(struct qlcnic_adapter *adapter, u32 reg, u32 *val)
-{
-
-	if (qlcnic_issue_cmd(adapter,
-			adapter->ahw->pci_func,
-			adapter->fw_hal_version,
-			reg,
-			0,
-			0,
-			QLCNIC_CDRP_CMD_READ_PHY)) {
-
-		return -EIO;
-	}
-
-	return QLCRD32(adapter, QLCNIC_ARG1_CRB_OFFSET);
-}
-
-int
-qlcnic_fw_cmd_set_phy(struct qlcnic_adapter *adapter, u32 reg, u32 val)
+qlcnic_fw_cmd_set_port(struct qlcnic_adapter *adapter, u32 config)
 {
 	return qlcnic_issue_cmd(adapter,
 			adapter->ahw->pci_func,
 			adapter->fw_hal_version,
-			reg,
-			val,
+			config,
+			0,
 			0,
-			QLCNIC_CDRP_CMD_WRITE_PHY);
+			QLCNIC_CDRP_CMD_CONFIG_PORT);
 }
 
 int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 8db1d19..27726eb 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -284,50 +284,44 @@ skip:
 static int
 qlcnic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
+	u32 config = 0;
+	u32 ret = 0;
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
-	__u32 status;
+
+	if (adapter->ahw->port_type != QLCNIC_GBE)
+		return -EOPNOTSUPP;
 
 	/* read which mode */
-	if (adapter->ahw->port_type == QLCNIC_GBE) {
-		/* autonegotiation */
-		if (qlcnic_fw_cmd_set_phy(adapter,
-			       QLCNIC_NIU_GB_MII_MGMT_ADDR_AUTONEG,
-			       ecmd->autoneg) != 0)
-			return -EIO;
-		else
-			adapter->link_autoneg = ecmd->autoneg;
+	if (ecmd->duplex)
+		config |= 0x1;
 
-		if (qlcnic_fw_cmd_query_phy(adapter,
-			      QLCNIC_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
-			      &status) != 0)
-			return -EIO;
+	if (ecmd->autoneg)
+		config |= 0x2;
 
-		switch (ecmd->speed) {
-		case SPEED_10:
-			qlcnic_set_phy_speed(status, 0);
-			break;
-		case SPEED_100:
-			qlcnic_set_phy_speed(status, 1);
-			break;
-		case SPEED_1000:
-			qlcnic_set_phy_speed(status, 2);
-			break;
-		}
+	switch (ethtool_cmd_speed(ecmd)) {
+	case SPEED_10:
+		config |= (0 << 8);
+		break;
+	case SPEED_100:
+		config |= (1 << 8);
+		break;
+	case SPEED_1000:
+		config |= (10 << 8);
+		break;
+	default:
+		return -EIO;
+	}
 
-		if (ecmd->duplex == DUPLEX_HALF)
-			qlcnic_clear_phy_duplex(status);
-		if (ecmd->duplex == DUPLEX_FULL)
-			qlcnic_set_phy_duplex(status);
-		if (qlcnic_fw_cmd_set_phy(adapter,
-			       QLCNIC_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
-			       *((int *)&status)) != 0)
-			return -EIO;
-		else {
-			adapter->link_speed = ecmd->speed;
-			adapter->link_duplex = ecmd->duplex;
-		}
-	} else
+	ret = qlcnic_fw_cmd_set_port(adapter, config);
+
+	if (ret == QLCNIC_RCODE_NOT_SUPPORTED)
 		return -EOPNOTSUPP;
+	else if (ret)
+		return -EIO;
+
+	adapter->link_speed = ethtool_cmd_speed(ecmd);
+	adapter->link_duplex = ecmd->duplex;
+	adapter->link_autoneg = ecmd->autoneg;
 
 	if (!netif_running(dev))
 		return 0;
-- 
1.7.3.3

