From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 2/3] IB/mlx4: Always use the correct port for mirrored multicast attachments
Date: Sun,  8 Feb 2015 11:49:33 +0200
Message-ID: <1423388974-9635-3-git-send-email-ogerlitz@mellanox.com>
References: <1423388974-9635-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@kernel.org>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:44267 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755503AbbBHJts (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Feb 2015 04:49:48 -0500
In-Reply-To: <1423388974-9635-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moni Shoua <monis@mellanox.com>

When attaching a QP to a multicast address in bonded mode, there was an
assumption that the port of the QP must be #1. This assumption isn't the
case under the flow which enables maximal usage of the physical ports.

Fix it by always checking the port of the original flow and create the
mirrored flow on the other port.

Fixes: c6215745b66a ('IB/mlx4: Load balance ports in port aggregation mode')
Signed-off-by: Moni Shoua <monis@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 2ed5b99..3140da5 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1186,6 +1186,9 @@ static struct ib_flow *mlx4_ib_create_flow(struct ib_qp *qp,
 			goto err_create_flow;
 		i++;
 		if (is_bonded) {
+			/* Application always sees one port so the mirror rule
+			 * must be on port #2
+			 */
 			flow_attr->port = 2;
 			err = __mlx4_ib_create_flow(qp, flow_attr,
 						    domain, type[j],
@@ -1286,7 +1289,8 @@ static int mlx4_ib_mcg_attach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 
 	reg_id.mirror = 0;
 	if (mlx4_is_bonded(dev)) {
-		err = mlx4_multicast_attach(mdev->dev, &mqp->mqp, gid->raw, 2,
+		err = mlx4_multicast_attach(mdev->dev, &mqp->mqp, gid->raw,
+					    (mqp->port == 1) ? 2 : 1,
 					    !!(mqp->flags &
 					    MLX4_IB_QP_BLOCK_MULTICAST_LOOPBACK),
 					    prot, &reg_id.mirror);
-- 
1.7.1
