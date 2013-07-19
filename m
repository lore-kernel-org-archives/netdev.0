From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net 9/9] qlcnic: Fix guest VLAN
Date: Fri, 19 Jul 2013 16:56:34 -0400
Message-ID: <1374267394-27697-10-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1374267394-27697-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0252.outbound.messaging.microsoft.com ([213.199.154.252]:36454
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752155Ab3GSVYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 17:24:06 -0400
In-Reply-To: <1374267394-27697-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o Clear cached vport vlan variable(vp->vlan) in PF on PCI FLR and
  back-channel termination which will allow to configure guest VLAN
  on VF after force off/shut down the guest VM.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index b9b88f3..46aeb59 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -635,10 +635,12 @@ static int qlcnic_sriov_pf_channel_cfg_cmd(struct qlcnic_bc_trans *trans,
 					   struct qlcnic_cmd_args *cmd)
 {
 	struct qlcnic_vf_info *vf = trans->vf;
-	struct qlcnic_adapter *adapter = vf->adapter;
-	int err;
+	struct qlcnic_vport *vp = vf->vp;
+	struct qlcnic_adapter *adapter;
 	u16 func = vf->pci_func;
+	int err;
 
+	adapter = vf->adapter;
 	cmd->rsp.arg[0] = trans->req_hdr->cmd_op;
 	cmd->rsp.arg[0] |= (1 << 16);
 
@@ -650,6 +652,8 @@ static int qlcnic_sriov_pf_channel_cfg_cmd(struct qlcnic_bc_trans *trans,
 				qlcnic_sriov_pf_config_vport(adapter, 0, func);
 		}
 	} else {
+		if (vp->vlan_mode == QLC_GUEST_VLAN_MODE)
+			vp->vlan = 0;
 		err = qlcnic_sriov_pf_config_vport(adapter, 0, func);
 	}
 
@@ -1561,6 +1565,7 @@ void qlcnic_sriov_pf_handle_flr(struct qlcnic_sriov *sriov,
 				struct qlcnic_vf_info *vf)
 {
 	struct net_device *dev = vf->adapter->netdev;
+	struct qlcnic_vport *vp = vf->vp;
 
 	if (!test_and_clear_bit(QLC_BC_VF_STATE, &vf->state)) {
 		clear_bit(QLC_BC_VF_FLR, &vf->state);
@@ -1573,6 +1578,9 @@ void qlcnic_sriov_pf_handle_flr(struct qlcnic_sriov *sriov,
 		return;
 	}
 
+	if (vp->vlan_mode == QLC_GUEST_VLAN_MODE)
+		vp->vlan = 0;
+
 	qlcnic_sriov_schedule_flr(sriov, vf, qlcnic_sriov_pf_process_flr);
 	netdev_info(dev, "FLR received for PCI func %d\n", vf->pci_func);
 }
-- 
1.7.1
