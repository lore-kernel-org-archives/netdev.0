From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/4] net/mlx4_core: Fix wrong index in propagating port change event to VFs
Date: Wed, 22 Jul 2015 16:53:47 +0300
Message-ID: <1437573229-13127-3-git-send-email-ogerlitz@mellanox.com>
References: <1437573229-13127-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:54950 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965072AbbGVNyV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 09:54:21 -0400
In-Reply-To: <1437573229-13127-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

The port-change event processing in procedure mlx4_eq_int() uses "slave"
as the vf_oper array index. Since the value of "slave" is the PF function
index, the result is that the PF link state is used for deciding to
propagate the event for all the VFs. The VF link state should be used,
so the VF function index should be used here.

Fixes: 948e306d7d64 ('net/mlx4: Add VF link state support')
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/eq.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index aae13ad..8e81e53 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -601,7 +601,7 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 							continue;
 						mlx4_dbg(dev, "%s: Sending MLX4_PORT_CHANGE_SUBTYPE_DOWN to slave: %d, port:%d\n",
 							 __func__, i, port);
-						s_info = &priv->mfunc.master.vf_oper[slave].vport[port].state;
+						s_info = &priv->mfunc.master.vf_oper[i].vport[port].state;
 						if (IFLA_VF_LINK_STATE_AUTO == s_info->link_state) {
 							eqe->event.port_change.port =
 								cpu_to_be32(
@@ -640,7 +640,7 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 							continue;
 						if (i == mlx4_master_func_num(dev))
 							continue;
-						s_info = &priv->mfunc.master.vf_oper[slave].vport[port].state;
+						s_info = &priv->mfunc.master.vf_oper[i].vport[port].state;
 						if (IFLA_VF_LINK_STATE_AUTO == s_info->link_state) {
 							eqe->event.port_change.port =
 								cpu_to_be32(
-- 
2.3.7
