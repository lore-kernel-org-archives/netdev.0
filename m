From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 5/6] net/mlx4_core: Adjust the schedule queue port in reset-to-init too
Date: Thu, 21 May 2015 15:14:09 +0300
Message-ID: <1432210450-23408-6-git-send-email-ogerlitz@mellanox.com>
References: <1432210450-23408-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:56591 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755896AbbEUMPA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 08:15:00 -0400
In-Reply-To: <1432210450-23408-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's legal for drivers to provide the QP port through the
QPC schedule-queue field on the reset-to-init QP state change.

Add adjusting of the schedule queue port in the SRIOV wrapper
for that operation too.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 5e2ea03..93b6da9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -2703,6 +2703,10 @@ static void adjust_proxy_tun_qkey(struct mlx4_dev *dev, struct mlx4_vhcr *vhcr,
 	context->qkey = cpu_to_be32(qkey);
 }
 
+static int adjust_qp_sched_queue(struct mlx4_dev *dev, int slave,
+				 struct mlx4_qp_context *qpc,
+				 struct mlx4_cmd_mailbox *inbox);
+
 int mlx4_RST2INIT_QP_wrapper(struct mlx4_dev *dev, int slave,
 			     struct mlx4_vhcr *vhcr,
 			     struct mlx4_cmd_mailbox *inbox,
@@ -2725,6 +2729,10 @@ int mlx4_RST2INIT_QP_wrapper(struct mlx4_dev *dev, int slave,
 	struct res_srq *srq;
 	int local_qpn = be32_to_cpu(qpc->local_qpn) & 0xffffff;
 
+	err = adjust_qp_sched_queue(dev, slave, qpc, inbox);
+	if (err)
+		return err;
+
 	err = qp_res_start_move_to(dev, slave, qpn, RES_QP_HW, &qp, 0);
 	if (err)
 		return err;
-- 
1.7.1
