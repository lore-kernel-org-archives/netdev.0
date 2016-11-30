From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next 8/8] net/mlx5e: Support adding ingress tc rule when egress device flag is set
Date: Wed, 30 Nov 2016 16:41:35 +0200
Message-ID: <1480516895-29545-9-git-send-email-hadarh@mellanox.com>
References: <1480516895-29545-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46046 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755709AbcK3PhO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 10:37:14 -0500
In-Reply-To: <1480516895-29545-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When ndo_setup_tc is called with an egress_dev flag set, it means that
the ndo call was executed on the mirred action (egress) device and not
on the ingress device.

In order to support this kind of ndo_setup_tc call, and insert the
correct decap rule to the hardware, the uplink device on the same eswitch
should be found.

Currently, we use this resolution between the mirred device and the
uplink on the same eswitch to offload vxlan shared device decap rules.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 0868677..8503788 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -289,6 +289,14 @@ static int mlx5e_rep_ndo_setup_tc(struct net_device *dev, u32 handle,
 	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
 		return -EOPNOTSUPP;
 
+	if (tc->egress_dev) {
+		struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+		struct net_device *uplink_dev = mlx5_eswitch_get_uplink_netdev(esw);
+
+		return uplink_dev->netdev_ops->ndo_setup_tc(uplink_dev, handle,
+							    proto, tc);
+	}
+
 	switch (tc->type) {
 	case TC_SETUP_CLSFLOWER:
 		switch (tc->cls_flower->command) {
-- 
1.8.3.1
