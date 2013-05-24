From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 01/12] qlcnic: Support spoof check config.
Date: Fri, 24 May 2013 03:04:25 -0400
Message-ID: <1369379076-4718-2-git-send-email-shahed.shaikh@qlogic.com>
References: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0187.outbound.messaging.microsoft.com ([213.199.154.187]:47942
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757260Ab3EXH3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 03:29:47 -0400
In-Reply-To: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

o Add support for spoof check configuration per VF using
  iproute2 tool.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h  |    2 +
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |    1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |   36 ++++++++++++++++++++
 4 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 8fb836d..5d42ec1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -454,6 +454,7 @@ static const struct net_device_ops qlcnic_netdev_ops = {
 	.ndo_set_vf_tx_rate	= qlcnic_sriov_set_vf_tx_rate,
 	.ndo_get_vf_config	= qlcnic_sriov_get_vf_config,
 	.ndo_set_vf_vlan	= qlcnic_sriov_set_vf_vlan,
+	.ndo_set_vf_spoofchk	= qlcnic_sriov_set_vf_spoofchk,
 #endif
 };
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
index d85fbb5..9176cb0 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
@@ -129,6 +129,7 @@ struct qlcnic_vport {
 	u8			vlan_mode;
 	u16			vlan;
 	u8			qos;
+	bool			spoofchk;
 	u8			mac[6];
 };
 
@@ -225,6 +226,7 @@ int qlcnic_sriov_set_vf_tx_rate(struct net_device *, int, int);
 int qlcnic_sriov_get_vf_config(struct net_device *, int ,
 			       struct ifla_vf_info *);
 int qlcnic_sriov_set_vf_vlan(struct net_device *, int, u16, u8);
+int qlcnic_sriov_set_vf_spoofchk(struct net_device *, int, bool);
 #else
 static inline void qlcnic_sriov_pf_disable(struct qlcnic_adapter *adapter) {}
 static inline void qlcnic_sriov_pf_cleanup(struct qlcnic_adapter *adapter) {}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index 3869c38..a49bce7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -187,6 +187,7 @@ int qlcnic_sriov_init(struct qlcnic_adapter *adapter, int num_vfs)
 			}
 			sriov->vf_info[i].vp = vp;
 			vp->max_tx_bw = MAX_BW;
+			vp->spoofchk = true;
 			random_ether_addr(vp->mac);
 			dev_info(&adapter->pdev->dev,
 				 "MAC Address %pM is configured for VF %d\n",
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index 1a66ccd..ee0c1d3 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -580,6 +580,7 @@ static int qlcnic_sriov_set_vf_acl(struct qlcnic_adapter *adapter, u8 func)
 	struct qlcnic_cmd_args cmd;
 	struct qlcnic_vport *vp;
 	int err, id;
+	u8 *mac;
 
 	id = qlcnic_sriov_func_to_index(adapter, func);
 	if (id < 0)
@@ -591,6 +592,14 @@ static int qlcnic_sriov_set_vf_acl(struct qlcnic_adapter *adapter, u8 func)
 		return err;
 
 	cmd.req.arg[1] = 0x3 | func << 16;
+	if (vp->spoofchk == true) {
+		mac = vp->mac;
+		cmd.req.arg[2] |= BIT_1 | BIT_3 | BIT_8;
+		cmd.req.arg[4] = mac[5] | mac[4] << 8 | mac[3] << 16 |
+				 mac[2] << 24;
+		cmd.req.arg[5] = mac[1] | mac[0] << 8;
+	}
+
 	if (vp->vlan_mode == QLC_PVID_MODE) {
 		cmd.req.arg[2] |= BIT_6;
 		cmd.req.arg[3] |= vp->vlan << 8;
@@ -1767,6 +1776,7 @@ int qlcnic_sriov_get_vf_config(struct net_device *netdev,
 	memcpy(&ivi->mac, vp->mac, ETH_ALEN);
 	ivi->vlan = vp->vlan;
 	ivi->qos = vp->qos;
+	ivi->spoofchk = vp->spoofchk;
 	if (vp->max_tx_bw == MAX_BW)
 		ivi->tx_rate = 0;
 	else
@@ -1775,3 +1785,29 @@ int qlcnic_sriov_get_vf_config(struct net_device *netdev,
 	ivi->vf = vf;
 	return 0;
 }
+
+int qlcnic_sriov_set_vf_spoofchk(struct net_device *netdev, int vf, bool chk)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	struct qlcnic_sriov *sriov = adapter->ahw->sriov;
+	struct qlcnic_vf_info *vf_info;
+	struct qlcnic_vport *vp;
+
+	if (!qlcnic_sriov_pf_check(adapter))
+		return -EOPNOTSUPP;
+
+	if (vf >= sriov->num_vfs)
+		return -EINVAL;
+
+	vf_info = &sriov->vf_info[vf];
+	vp = vf_info->vp;
+	if (test_bit(QLC_BC_VF_STATE, &vf_info->state)) {
+		netdev_err(netdev,
+			   "Spoof check change failed for VF %d, as VF driver is loaded. Please unload VF driver and retry the operation\n",
+			   vf);
+		return -EOPNOTSUPP;
+	}
+
+	vp->spoofchk = chk;
+	return 0;
+}
-- 
1.5.6
