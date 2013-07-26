From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net 2/4] qlcnic: Fix operation type and command type.
Date: Fri, 26 Jul 2013 16:24:01 -0400
Message-ID: <358ac243b596256f5c2e753933e4fa060158ff06.1374891091.git.himanshu.madhani@qlogic.com>
References: <cover.1374891091.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Pratik Pujar <pratik.pujar@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:50306 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756411Ab3GZVAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 17:00:23 -0400
In-Reply-To: <cover.1374891091.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pratik Pujar <pratik.pujar@qlogic.com>

Operation type and command type is not set correct in back channel
response.

Signed-off-by: Pratik Pujar <pratik.pujar@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c | 2 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c     | 4 +---
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index 62380ce..56e85f9 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -762,6 +762,7 @@ static int qlcnic_sriov_alloc_bc_mbx_args(struct qlcnic_cmd_args *mbx, u32 type)
 			memset(mbx->rsp.arg, 0, sizeof(u32) * mbx->rsp.num);
 			mbx->req.arg[0] = (type | (mbx->req.num << 16) |
 					   (3 << 29));
+			mbx->rsp.arg[0] = (type & 0xffff) | mbx->rsp.num << 16;
 			return 0;
 		}
 	}
@@ -813,6 +814,7 @@ static int qlcnic_sriov_prepare_bc_hdr(struct qlcnic_bc_trans *trans,
 		cmd->req.num = trans->req_pay_size / 4;
 		cmd->rsp.num = trans->rsp_pay_size / 4;
 		hdr = trans->rsp_hdr;
+		cmd->op_type = trans->req_hdr->op_type;
 	}
 
 	trans->trans_id = seq;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index 46aeb59..9bdd51e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -641,8 +641,6 @@ static int qlcnic_sriov_pf_channel_cfg_cmd(struct qlcnic_bc_trans *trans,
 	int err;
 
 	adapter = vf->adapter;
-	cmd->rsp.arg[0] = trans->req_hdr->cmd_op;
-	cmd->rsp.arg[0] |= (1 << 16);
 
 	if (trans->req_hdr->cmd_op == QLCNIC_BC_CMD_CHANNEL_INIT) {
 		err = qlcnic_sriov_pf_config_vport(adapter, 1, func);
@@ -1187,7 +1185,7 @@ static int qlcnic_sriov_pf_get_acl_cmd(struct qlcnic_bc_trans *trans,
 	u8 cmd_op, mode = vp->vlan_mode;
 
 	cmd_op = trans->req_hdr->cmd_op;
-	cmd->rsp.arg[0] = (cmd_op & 0xffff) | 14 << 16 | 1 << 25;
+	cmd->rsp.arg[0] |= 1 << 25;
 
 	switch (mode) {
 	case QLC_GUEST_VLAN_MODE:
-- 
1.8.1.4
