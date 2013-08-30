From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 1/9] qlcnic: Enhance PVID handling for 84xx adapters
Date: Fri, 30 Aug 2013 13:51:16 -0400
Message-ID: <1377885084-6441-2-git-send-email-shahed.shaikh@qlogic.com>
References: <1377885084-6441-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:37796 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756725Ab3H3SUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 14:20:19 -0400
In-Reply-To: <1377885084-6441-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o PF driver should not indicate PVID configuration to VF driver.
  As adapter supports VLAN stripping, VF driver should stay agnostic
  to any PVID configuration.

o Return "QLC_NO_VLAN_MODE(= 0)" to VFD when PVID is configured.
  VF driver should be in no VLAN configuration mode.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    8 ++++++++
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |   15 +++++----------
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |    9 +++++++++
 3 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 156a78e..f6aea7d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -2069,6 +2069,14 @@ static inline bool qlcnic_82xx_check(struct qlcnic_adapter *adapter)
 	return (device == PCI_DEVICE_ID_QLOGIC_QLE824X) ? true : false;
 }
 
+static inline bool qlcnic_84xx_check(struct qlcnic_adapter *adapter)
+{
+	unsigned short device = adapter->pdev->device;
+
+	return ((device == PCI_DEVICE_ID_QLOGIC_QLE844X) ||
+		(device == PCI_DEVICE_ID_QLOGIC_VF_QLE844X)) ? true : false;
+}
+
 static inline bool qlcnic_83xx_check(struct qlcnic_adapter *adapter)
 {
 	unsigned short device = adapter->pdev->device;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index 26f9aa6..652cc13 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -398,14 +398,10 @@ int qlcnic_sriov_get_vf_vport_info(struct qlcnic_adapter *adapter,
 }
 
 static int qlcnic_sriov_set_pvid_mode(struct qlcnic_adapter *adapter,
-				      struct qlcnic_cmd_args *cmd, u32 cap)
+				      struct qlcnic_cmd_args *cmd)
 {
-	if (cap & QLC_83XX_PVID_STRIP_CAPABILITY) {
-		adapter->rx_pvid = 0;
-	} else {
-		adapter->rx_pvid = (cmd->rsp.arg[1] >> 16) & 0xffff;
-		adapter->flags &= ~QLCNIC_TAGGING_ENABLED;
-	}
+	adapter->rx_pvid = MSW(cmd->rsp.arg[1]) & 0xffff;
+	adapter->flags &= ~QLCNIC_TAGGING_ENABLED;
 	return 0;
 }
 
@@ -441,9 +437,8 @@ static int qlcnic_sriov_get_vf_acl(struct qlcnic_adapter *adapter,
 {
 	struct qlcnic_sriov *sriov = adapter->ahw->sriov;
 	struct qlcnic_cmd_args cmd;
-	int ret, cap;
+	int ret = 0;
 
-	cap = info->capabilities;
 	ret = qlcnic_sriov_alloc_bc_mbx_args(&cmd, QLCNIC_BC_CMD_GET_ACL);
 	if (ret)
 		return ret;
@@ -459,7 +454,7 @@ static int qlcnic_sriov_get_vf_acl(struct qlcnic_adapter *adapter,
 			ret = qlcnic_sriov_set_guest_vlan_mode(adapter, &cmd);
 			break;
 		case QLC_PVID_MODE:
-			ret = qlcnic_sriov_set_pvid_mode(adapter, &cmd, cap);
+			ret = qlcnic_sriov_set_pvid_mode(adapter, &cmd);
 			break;
 		}
 	}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index 2d6faf0..95b7710 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -1183,10 +1183,19 @@ static int qlcnic_sriov_pf_get_acl_cmd(struct qlcnic_bc_trans *trans,
 	struct qlcnic_vf_info *vf = trans->vf;
 	struct qlcnic_vport *vp = vf->vp;
 	u8 cmd_op, mode = vp->vlan_mode;
+	struct qlcnic_adapter *adapter;
+
+	adapter = vf->adapter;
 
 	cmd_op = trans->req_hdr->cmd_op;
 	cmd->rsp.arg[0] |= 1 << 25;
 
+	/* For 84xx adapter in case of PVID , PFD should send vlan mode as
+	 * QLC_NO_VLAN_MODE to VFD which is zero in mailbox response
+	 */
+	if (qlcnic_84xx_check(adapter) && mode == QLC_PVID_MODE)
+		return 0;
+
 	switch (mode) {
 	case QLC_GUEST_VLAN_MODE:
 		cmd->rsp.arg[1] = mode | 1 << 8;
-- 
1.5.6
