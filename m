From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 1/5] net/mlx4_core: Use-after-free causes a resource leak in flow-steering detach
Date: Thu, 29 Dec 2016 18:37:09 +0200
Message-ID: <1483029433-3624-2-git-send-email-tariqt@mellanox.com>
References: <1483029433-3624-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51878 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752905AbcL2Qh6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 11:37:58 -0500
In-Reply-To: <1483029433-3624-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

mlx4_QP_FLOW_STEERING_DETACH_wrapper first removes the steering
rule (which results in freeing the rule structure), and then
references a field in this struct (the qp number) when releasing the
busy-status on the rule's qp.

Since this memory was freed, it could reallocated and changed.
Therefore, the qp number in the struct may be incorrect,
so that we are releasing the incorrect qp. This leaves the rule's qp
in the busy state (and could possibly release an incorrect qp as well).

Fix this by saving the qp number in a local variable, for use after
removing the steering rule.

Fixes: 2c473ae7e582 ("net/mlx4_core: Disallow releasing VF QPs which have steering rules")
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index c548beaaf910..4b3e139e9c82 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -4473,6 +4473,7 @@ int mlx4_QP_FLOW_STEERING_DETACH_wrapper(struct mlx4_dev *dev, int slave,
 	struct res_qp *rqp;
 	struct res_fs_rule *rrule;
 	u64 mirr_reg_id;
+	int qpn;
 
 	if (dev->caps.steering_mode !=
 	    MLX4_STEERING_MODE_DEVICE_MANAGED)
@@ -4489,10 +4490,11 @@ int mlx4_QP_FLOW_STEERING_DETACH_wrapper(struct mlx4_dev *dev, int slave,
 	}
 	mirr_reg_id = rrule->mirr_rule_id;
 	kfree(rrule->mirr_mbox);
+	qpn = rrule->qpn;
 
 	/* Release the rule form busy state before removal */
 	put_res(dev, slave, vhcr->in_param, RES_FS_RULE);
-	err = get_res(dev, slave, rrule->qpn, RES_QP, &rqp);
+	err = get_res(dev, slave, qpn, RES_QP, &rqp);
 	if (err)
 		return err;
 
@@ -4517,7 +4519,7 @@ int mlx4_QP_FLOW_STEERING_DETACH_wrapper(struct mlx4_dev *dev, int slave,
 	if (!err)
 		atomic_dec(&rqp->ref_count);
 out:
-	put_res(dev, slave, rrule->qpn, RES_QP);
+	put_res(dev, slave, qpn, RES_QP);
 	return err;
 }
 
-- 
1.8.3.1
