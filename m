From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 2/8] qlcnic: Enable VF flood bit on PF.
Date: Fri, 10 Jan 2014 11:48:53 -0500
Message-ID: <1389372539-13753-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1389372539-13753-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:16434 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752170AbaAJRWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 12:22:55 -0500
In-Reply-To: <1389372539-13753-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o On enabling VF flood bit, PF driver will  be able to receive traffic
  from all its VFs.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   | 30 ++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index c588286..09acf15 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -15,6 +15,8 @@
 #define QLC_MAC_OPCODE_MASK	0x7
 #define QLC_MAC_STAR_ADD	6
 #define QLC_MAC_STAR_DEL	7
+#define QLC_VF_FLOOD_BIT	BIT_16
+#define QLC_FLOOD_MODE		0x5
 
 static int qlcnic_sriov_pf_get_vport_handle(struct qlcnic_adapter *, u8);
 
@@ -347,6 +349,28 @@ static int qlcnic_sriov_pf_cfg_vlan_filtering(struct qlcnic_adapter *adapter,
 	return err;
 }
 
+/* On configuring VF flood bit, PFD will receive traffic from all VFs */
+static int qlcnic_sriov_pf_cfg_flood(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_cmd_args cmd;
+	int err;
+
+	err = qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_SET_NIC_INFO);
+	if (err)
+		return err;
+
+	cmd.req.arg[1] = QLC_FLOOD_MODE | QLC_VF_FLOOD_BIT;
+
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	if (err)
+		dev_err(&adapter->pdev->dev,
+			"Failed to configure VF Flood bit on PF, err=%d\n",
+			err);
+
+	qlcnic_free_mbx_args(&cmd);
+	return err;
+}
+
 static int qlcnic_sriov_pf_cfg_eswitch(struct qlcnic_adapter *adapter,
 				       u8 func, u8 enable)
 {
@@ -474,6 +498,12 @@ static int qlcnic_sriov_pf_init(struct qlcnic_adapter *adapter)
 	if (err)
 		return err;
 
+	if (qlcnic_84xx_check(adapter)) {
+		err = qlcnic_sriov_pf_cfg_flood(adapter);
+		if (err)
+			goto disable_vlan_filtering;
+	}
+
 	err = qlcnic_sriov_pf_cfg_eswitch(adapter, func, 1);
 	if (err)
 		goto disable_vlan_filtering;
-- 
1.8.3.1
