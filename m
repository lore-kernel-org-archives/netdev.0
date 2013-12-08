From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 04/12] net/mlx4_core: Introduce nic_info new flag in QUERY_FUNC_CAP
Date: Sun,  8 Dec 2013 14:35:44 +0200
Message-ID: <1386506152-10298-5-git-send-email-amirv@mellanox.com>
References: <1386506152-10298-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:59490 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754670Ab3LHMgO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Dec 2013 07:36:14 -0500
In-Reply-To: <1386506152-10298-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Set nic_info field in QUERY_FUNC_CAP, which designates
supplementary NIC information is provided by the hypervisor.
When set, the following fields are valid: nic_num_rings,
nic_indirection_tbl_sz, cur_mac and phys_port_id.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 11 ++++++++---
 drivers/net/ethernet/mellanox/mlx4/fw.h |  1 +
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 58ca7de..bfe91ae 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -217,10 +217,15 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 
 #define QUERY_FUNC_CAP_FLAGS1_FORCE_MAC		0x40
 #define QUERY_FUNC_CAP_FLAGS1_FORCE_VLAN	0x80
+#define QUERY_FUNC_CAP_FLAGS1_NIC_INFO			0x10
 
 #define QUERY_FUNC_CAP_FLAGS0_FORCE_PHY_WQE_GID 0x80
 
 	if (vhcr->op_modifier == 1) {
+		/* Set nic_info bit to mark new fields support */
+		field  = QUERY_FUNC_CAP_FLAGS1_NIC_INFO;
+		MLX4_PUT(outbox->buf, field, QUERY_FUNC_CAP_FLAGS1_OFFSET);
+
 		field = vhcr->in_modifier; /* phys-port = logical-port */
 		MLX4_PUT(outbox->buf, field, QUERY_FUNC_CAP_PHYS_PORT_OFFSET);
 
@@ -385,15 +390,15 @@ int mlx4_QUERY_FUNC_CAP(struct mlx4_dev *dev, u32 gen_or_port,
 		goto out;
 	}
 
+	MLX4_GET(func_cap->flags1, outbox, QUERY_FUNC_CAP_FLAGS1_OFFSET);
 	if (dev->caps.port_type[gen_or_port] == MLX4_PORT_TYPE_ETH) {
-		MLX4_GET(field, outbox, QUERY_FUNC_CAP_FLAGS1_OFFSET);
-		if (field & QUERY_FUNC_CAP_FLAGS1_FORCE_VLAN) {
+		if (func_cap->flags1 & QUERY_FUNC_CAP_FLAGS1_OFFSET) {
 			mlx4_err(dev, "VLAN is enforced on this port\n");
 			err = -EPROTONOSUPPORT;
 			goto out;
 		}
 
-		if (field & QUERY_FUNC_CAP_FLAGS1_FORCE_MAC) {
+		if (func_cap->flags1 & QUERY_FUNC_CAP_FLAGS1_FORCE_MAC) {
 			mlx4_err(dev, "Force mac is enabled on this port\n");
 			err = -EPROTONOSUPPORT;
 			goto out;
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index a0a368b..9d95298 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -140,6 +140,7 @@ struct mlx4_func_cap {
 	u32	qp1_proxy_qpn;
 	u8	physical_port;
 	u8	port_flags;
+	u8	flags1;
 };
 
 struct mlx4_adapter {
-- 
1.8.3.4
