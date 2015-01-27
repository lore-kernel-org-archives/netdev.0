From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 02/11] net/mlx4_core: Add reserved lkey for VFs to QUERY_FUNC_CAP
Date: Tue, 27 Jan 2015 15:58:00 +0200
Message-ID: <1422367089-13419-3-git-send-email-amirv@mellanox.com>
References: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46357 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757611AbbA0N7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 08:59:16 -0500
In-Reply-To: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

The reserved lKey is different for each VF.
A base lkey value is returned in QUERY_DEV_CAP at offset 0x98.

The reserved L_key value for a VF is:
    VF_lkey = base_lkey + (VF_number << 8).

This VF L_key value should be returned in QUERY_FUNC_CAP
(opcode-modifier = 0) at offset 0x48.

To indicate that the lkey value at offset 0x48 is valid, the Hypervisor
sets a flag bit in dword 0x0, offset 27 in the QUERY_FUNC_CAP wrapper
function.

When the VF calls QUERY_FUNC_CAP, it should check if this flag bit is set.
If it is set, the VF should take the reserved lkey value at offset 0x48.
If the bit is not set, the VF should not use a reserved lkey
(i.e., should set its reserved lkey value to 0).


Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c   | 19 +++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx4/fw.h   |  1 +
 drivers/net/ethernet/mellanox/mlx4/main.c |  1 +
 3 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 2eadc28..2aa7c23 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -260,6 +260,7 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 #define QUERY_FUNC_CAP_MCG_QUOTA_OFFSET_DEP	0x28
 #define QUERY_FUNC_CAP_MAX_EQ_OFFSET		0x2c
 #define QUERY_FUNC_CAP_RESERVED_EQ_OFFSET	0x30
+#define QUERY_FUNC_CAP_QP_RESD_LKEY_OFFSET	0x48
 
 #define QUERY_FUNC_CAP_QP_QUOTA_OFFSET		0x50
 #define QUERY_FUNC_CAP_CQ_QUOTA_OFFSET		0x54
@@ -274,6 +275,7 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 #define QUERY_FUNC_CAP_FLAG_RDMA		0x40
 #define QUERY_FUNC_CAP_FLAG_ETH			0x80
 #define QUERY_FUNC_CAP_FLAG_QUOTAS		0x10
+#define QUERY_FUNC_CAP_FLAG_RESD_LKEY		0x08
 #define QUERY_FUNC_CAP_FLAG_VALID_MAILBOX	0x04
 
 #define QUERY_FUNC_CAP_EXTRA_FLAGS_BF_QP_ALLOC_FLAG	(1UL << 31)
@@ -345,9 +347,12 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 	} else if (vhcr->op_modifier == 0) {
 		struct mlx4_active_ports actv_ports =
 			mlx4_get_active_ports(dev, slave);
-		/* enable rdma and ethernet interfaces, and new quota locations */
+		/* enable rdma and ethernet interfaces, new quota locations,
+		 * and reserved lkey
+		 */
 		field = (QUERY_FUNC_CAP_FLAG_ETH | QUERY_FUNC_CAP_FLAG_RDMA |
-			 QUERY_FUNC_CAP_FLAG_QUOTAS | QUERY_FUNC_CAP_FLAG_VALID_MAILBOX);
+			 QUERY_FUNC_CAP_FLAG_QUOTAS | QUERY_FUNC_CAP_FLAG_VALID_MAILBOX |
+			 QUERY_FUNC_CAP_FLAG_RESD_LKEY);
 		MLX4_PUT(outbox->buf, field, QUERY_FUNC_CAP_FLAGS_OFFSET);
 
 		field = min(
@@ -412,6 +417,9 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 		size = QUERY_FUNC_CAP_EXTRA_FLAGS_BF_QP_ALLOC_FLAG |
 			QUERY_FUNC_CAP_EXTRA_FLAGS_A0_QP_ALLOC_FLAG;
 		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_EXTRA_FLAGS_OFFSET);
+
+		size = dev->caps.reserved_lkey + ((slave << 8) & 0xFF00);
+		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_QP_RESD_LKEY_OFFSET);
 	} else
 		err = -EINVAL;
 
@@ -504,6 +512,13 @@ int mlx4_QUERY_FUNC_CAP(struct mlx4_dev *dev, u8 gen_or_port,
 		MLX4_GET(size, outbox, QUERY_FUNC_CAP_RESERVED_EQ_OFFSET);
 		func_cap->reserved_eq = size & 0xFFFFFF;
 
+		if (func_cap->flags & QUERY_FUNC_CAP_FLAG_RESD_LKEY) {
+			MLX4_GET(size, outbox, QUERY_FUNC_CAP_QP_RESD_LKEY_OFFSET);
+			func_cap->reserved_lkey = size;
+		} else {
+			func_cap->reserved_lkey = 0;
+		}
+
 		func_cap->extra_flags = 0;
 
 		/* Mailbox data from 0x6c and onward should only be treated if
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index 62562b6..f44f7f6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -147,6 +147,7 @@ struct mlx4_func_cap {
 	u32	qp0_proxy_qpn;
 	u32	qp1_tunnel_qpn;
 	u32	qp1_proxy_qpn;
+	u32	reserved_lkey;
 	u8	physical_port;
 	u8	port_flags;
 	u8	flags1;
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 9c7ef0b..46531c2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -797,6 +797,7 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 	dev->caps.num_mpts		= 1 << hca_param.log_mpt_sz;
 	dev->caps.num_eqs		= func_cap.max_eq;
 	dev->caps.reserved_eqs		= func_cap.reserved_eq;
+	dev->caps.reserved_lkey		= func_cap.reserved_lkey;
 	dev->caps.num_pds               = MLX4_NUM_PDS;
 	dev->caps.num_mgms              = 0;
 	dev->caps.num_amgms             = 0;
-- 
1.9.3
