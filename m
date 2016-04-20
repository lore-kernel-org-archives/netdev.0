From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 3/4] net/mlx4_core: Don't allow to VF change global pause settings
Date: Wed, 20 Apr 2016 16:01:17 +0300
Message-ID: <1461157278-18528-4-git-send-email-ogerlitz@mellanox.com>
References: <1461157278-18528-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:51089 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751726AbcDTNCB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2016 09:02:01 -0400
In-Reply-To: <1461157278-18528-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Currently changing global pause settings is done via SET_PORT
command with input modifier GENERAL. This command is allowed
for each VF since MTU setting is done via the same command.

Change the above to the following scheme: before passing the
request to the FW, the PF will check whether it was issued
by a slave. If yes, don't change global pause and warn,
otherwise change to the requested value and store for
further reference.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |  2 ++
 drivers/net/ethernet/mellanox/mlx4/port.c | 13 +++++++++++++
 2 files changed, 15 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index ef96831..c9d7fc51 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -586,6 +586,8 @@ struct mlx4_mfunc_master_ctx {
 	struct mlx4_master_qp0_state qp0_state[MLX4_MAX_PORTS + 1];
 	int			init_port_ref[MLX4_MAX_PORTS + 1];
 	u16			max_mtu[MLX4_MAX_PORTS + 1];
+	u8			pptx;
+	u8			pprx;
 	int			disable_mcast_ref[MLX4_MAX_PORTS + 1];
 	struct mlx4_resource_tracker res_tracker;
 	struct workqueue_struct *comm_wq;
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 211c650..087b23b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -1317,6 +1317,19 @@ static int mlx4_common_set_port(struct mlx4_dev *dev, int slave, u32 in_mod,
 			}
 
 			gen_context->mtu = cpu_to_be16(master->max_mtu[port]);
+			/* Slave cannot change Global Pause configuration */
+			if (slave != mlx4_master_func_num(dev) &&
+			    ((gen_context->pptx != master->pptx) ||
+			     (gen_context->pprx != master->pprx))) {
+				gen_context->pptx = master->pptx;
+				gen_context->pprx = master->pprx;
+				mlx4_warn(dev,
+					  "denying Global Pause change for slave:%d\n",
+					  slave);
+			} else {
+				master->pptx = gen_context->pptx;
+				master->pprx = gen_context->pprx;
+			}
 			break;
 		case MLX4_SET_PORT_GID_TABLE:
 			/* change to MULTIPLE entries: number of guest's gids
-- 
2.3.7
