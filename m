From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 05/12] qlcnic: Initialize trans_work and idc_aen_work at VF probe.
Date: Fri, 24 May 2013 03:04:29 -0400
Message-ID: <1369379076-4718-6-git-send-email-shahed.shaikh@qlogic.com>
References: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe005.messaging.microsoft.com ([207.46.163.28]:32948
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759970Ab3EXH3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 03:29:53 -0400
In-Reply-To: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o work_struct should be initialized before cancel_delayed_work
  call to destroy it.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index a49bce7..f8e3a74 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -35,6 +35,7 @@ static void qlcnic_sriov_vf_cancel_fw_work(struct qlcnic_adapter *);
 static void qlcnic_sriov_cleanup_transaction(struct qlcnic_bc_trans *);
 static int qlcnic_sriov_vf_mbx_op(struct qlcnic_adapter *,
 				  struct qlcnic_cmd_args *);
+static void qlcnic_sriov_process_bc_cmd(struct work_struct *);
 
 static struct qlcnic_hardware_ops qlcnic_sriov_vf_hw_ops = {
 	.read_crb			= qlcnic_83xx_read_crb,
@@ -179,6 +180,8 @@ int qlcnic_sriov_init(struct qlcnic_adapter *adapter, int num_vfs)
 		spin_lock_init(&vf->rcv_pend.lock);
 		init_completion(&vf->ch_free_cmpl);
 
+		INIT_WORK(&vf->trans_work, qlcnic_sriov_process_bc_cmd);
+
 		if (qlcnic_sriov_pf_check(adapter)) {
 			vp = kzalloc(sizeof(struct qlcnic_vport), GFP_KERNEL);
 			if (!vp) {
@@ -653,6 +656,8 @@ int qlcnic_sriov_vf_init(struct qlcnic_adapter *adapter, int pci_using_dac)
 	if (qlcnic_read_mac_addr(adapter))
 		dev_warn(&adapter->pdev->dev, "failed to read mac addr\n");
 
+	INIT_DELAYED_WORK(&adapter->idc_aen_work, qlcnic_83xx_idc_aen_work);
+
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 	return 0;
 }
@@ -865,7 +870,6 @@ static void qlcnic_sriov_schedule_bc_cmd(struct qlcnic_sriov *sriov,
 	    vf->adapter->need_fw_reset)
 		return;
 
-	INIT_WORK(&vf->trans_work, func);
 	queue_work(sriov->bc.bc_trans_wq, &vf->trans_work);
 }
 
-- 
1.5.6
