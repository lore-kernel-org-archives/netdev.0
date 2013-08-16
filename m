From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next 2/5] qlcnic: Add PVID support for 84xx adapters
Date: Fri, 16 Aug 2013 19:07:14 -0400
Message-ID: <da12fa388cd93b90458daa17363dffaf6417f535.1376720973.git.himanshu.madhani@qlogic.com>
References: <cover.1376720973.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:34629 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752657Ab3HPX6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 19:58:14 -0400
In-Reply-To: <cover.1376720973.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o 84xx adapters support VLAN stripping for PVID. Packets don't have
  VLAN tag inserted in case of PVID. So packet should follow non vlan path.

o Use capability bit to set PVID mode.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h  |  1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c | 20 +++++++++++++-------
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index dd22ef3..b89b074 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -404,6 +404,7 @@ enum qlcnic_83xx_states {
 #define QLC_83XX_MAX_MC_COUNT			38
 #define QLC_83XX_MAX_UC_COUNT			4096
 
+#define QLC_83XX_PVID_STRIP_CAPABILITY		BIT_22
 #define QLC_83XX_GET_FUNC_MODE_FROM_NPAR_INFO(val)	(val & 0x80000000)
 #define QLC_83XX_GET_LRO_CAPABILITY(val)		(val & 0x20)
 #define QLC_83XX_GET_LSO_CAPABILITY(val)		(val & 0x40)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index dc24979..b2fbefc 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -398,10 +398,14 @@ int qlcnic_sriov_get_vf_vport_info(struct qlcnic_adapter *adapter,
 }
 
 static int qlcnic_sriov_set_pvid_mode(struct qlcnic_adapter *adapter,
-				      struct qlcnic_cmd_args *cmd)
+				      struct qlcnic_cmd_args *cmd, u32 cap)
 {
-	adapter->rx_pvid = (cmd->rsp.arg[1] >> 16) & 0xffff;
-	adapter->flags &= ~QLCNIC_TAGGING_ENABLED;
+	if (cap & QLC_83XX_PVID_STRIP_CAPABILITY) {
+		adapter->rx_pvid = 0;
+	} else {
+		adapter->rx_pvid = (cmd->rsp.arg[1] >> 16) & 0xffff;
+		adapter->flags &= ~QLCNIC_TAGGING_ENABLED;
+	}
 	return 0;
 }
 
@@ -432,12 +436,14 @@ static int qlcnic_sriov_set_guest_vlan_mode(struct qlcnic_adapter *adapter,
 	return 0;
 }
 
-static int qlcnic_sriov_get_vf_acl(struct qlcnic_adapter *adapter)
+static int qlcnic_sriov_get_vf_acl(struct qlcnic_adapter *adapter,
+				   struct qlcnic_info *info)
 {
 	struct qlcnic_sriov *sriov = adapter->ahw->sriov;
 	struct qlcnic_cmd_args cmd;
-	int ret;
+	int ret, cap;
 
+	cap = info->capabilities;
 	ret = qlcnic_sriov_alloc_bc_mbx_args(&cmd, QLCNIC_BC_CMD_GET_ACL);
 	if (ret)
 		return ret;
@@ -453,7 +459,7 @@ static int qlcnic_sriov_get_vf_acl(struct qlcnic_adapter *adapter)
 			ret = qlcnic_sriov_set_guest_vlan_mode(adapter, &cmd);
 			break;
 		case QLC_PVID_MODE:
-			ret = qlcnic_sriov_set_pvid_mode(adapter, &cmd);
+			ret = qlcnic_sriov_set_pvid_mode(adapter, &cmd, cap);
 			break;
 		}
 	}
@@ -476,7 +482,7 @@ static int qlcnic_sriov_vf_init_driver(struct qlcnic_adapter *adapter)
 	if (err)
 		return -EIO;
 
-	err = qlcnic_sriov_get_vf_acl(adapter);
+	err = qlcnic_sriov_get_vf_acl(adapter, &nic_info);
 	if (err)
 		return err;
 
-- 
1.8.1.4
