From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 2/3] net/mlx4_core: Fix when to save some qp context flags for dynamic VST to VGT transitions
Date: Mon, 16 Jan 2017 18:31:38 +0200
Message-ID: <1484584299-3950-3-git-send-email-tariqt@mellanox.com>
References: <1484584299-3950-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36310 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750886AbdAPQcA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 11:32:00 -0500
In-Reply-To: <1484584299-3950-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Save the qp context flags byte containing the flag disabling vlan stripping
in the RESET to INIT qp transition, rather than in the INIT to RTR
transition. Per the firmware spec, the flags in this byte are active
in the RESET to INIT transition.

As a result of saving the flags in the incorrect qp transition, when
switching dynamically from VGT to VST and back to VGT, the vlan
remained stripped (as is required for VST) and did not return to
not-stripped (as is required for VGT).

Fixes: f0f829bf42cd ("net/mlx4_core: Add immediate activate for VGT->VST->VGT")
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 56185a0b827d..1822382212ee 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -2980,6 +2980,9 @@ int mlx4_RST2INIT_QP_wrapper(struct mlx4_dev *dev, int slave,
 		put_res(dev, slave, srqn, RES_SRQ);
 		qp->srq = srq;
 	}
+
+	/* Save param3 for dynamic changes from VST back to VGT */
+	qp->param3 = qpc->param3;
 	put_res(dev, slave, rcqn, RES_CQ);
 	put_res(dev, slave, mtt_base, RES_MTT);
 	res_end_move(dev, slave, RES_QP, qpn);
@@ -3772,7 +3775,6 @@ int mlx4_INIT2RTR_QP_wrapper(struct mlx4_dev *dev, int slave,
 	int qpn = vhcr->in_modifier & 0x7fffff;
 	struct res_qp *qp;
 	u8 orig_sched_queue;
-	__be32	orig_param3 = qpc->param3;
 	u8 orig_vlan_control = qpc->pri_path.vlan_control;
 	u8 orig_fvl_rx = qpc->pri_path.fvl_rx;
 	u8 orig_pri_path_fl = qpc->pri_path.fl;
@@ -3814,7 +3816,6 @@ int mlx4_INIT2RTR_QP_wrapper(struct mlx4_dev *dev, int slave,
 	 */
 	if (!err) {
 		qp->sched_queue = orig_sched_queue;
-		qp->param3	= orig_param3;
 		qp->vlan_control = orig_vlan_control;
 		qp->fvl_rx	=  orig_fvl_rx;
 		qp->pri_path_fl = orig_pri_path_fl;
-- 
1.8.3.1
