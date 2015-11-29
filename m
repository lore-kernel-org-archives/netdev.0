From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 04/18] net/mlx5: Update access functions to Query/Modify vport MAC address
Date: Sun, 29 Nov 2015 17:37:12 +0200
Message-ID: <1448811446-18598-5-git-send-email-ogerlitz@mellanox.com>
References: <1448811446-18598-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Don Dutile <ddutile@redhat.com>,
	Doug Ledford <dledford@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34964 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751779AbbK2PiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Nov 2015 10:38:25 -0500
In-Reply-To: <1448811446-18598-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

In preparation for SR-IOV we add here an API to enable each e-switch
client (PF/VF) to configure its L2 MAC addresses and for the e-switch
manager (usually the PF) to access them in order to be able to
configure them into the e-switch.
Therefore we now pass vport num parameter to
mlx5_query_nic_vport_context, so PF can access other vports contexts.

preperation for ethernet sriov and l2 table management.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/vport.c   | 87 ++++++++++++++++++++---
 include/linux/mlx5/vport.h                        |  5 +-
 3 files changed, 81 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index f6a8cc7..2ef717f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2028,7 +2028,7 @@ static void mlx5e_set_netdev_dev_addr(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 
-	mlx5_query_nic_vport_mac_address(priv->mdev, netdev->dev_addr);
+	mlx5_query_nic_vport_mac_address(priv->mdev, 0, netdev->dev_addr);
 }
 
 static void mlx5e_build_netdev(struct net_device *netdev)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vport.c b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
index b94177e..442916e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vport.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
@@ -57,33 +57,98 @@ u8 mlx5_query_vport_state(struct mlx5_core_dev *mdev, u8 opmod)
 }
 EXPORT_SYMBOL(mlx5_query_vport_state);
 
-void mlx5_query_nic_vport_mac_address(struct mlx5_core_dev *mdev, u8 *addr)
+static int mlx5_query_nic_vport_context(struct mlx5_core_dev *mdev, u16 vport,
+					u32 *out, int outlen)
+{
+	u32 in[MLX5_ST_SZ_DW(query_nic_vport_context_in)];
+
+	memset(in, 0, sizeof(in));
+
+	MLX5_SET(query_nic_vport_context_in, in, opcode,
+		 MLX5_CMD_OP_QUERY_NIC_VPORT_CONTEXT);
+
+	MLX5_SET(query_nic_vport_context_in, in, vport_number, vport);
+	if (vport)
+		MLX5_SET(query_nic_vport_context_in, in, other_vport, 1);
+
+	return mlx5_cmd_exec_check_status(mdev, in, sizeof(in), out, outlen);
+}
+
+static int mlx5_modify_nic_vport_context(struct mlx5_core_dev *mdev, void *in,
+					 int inlen)
+{
+	u32 out[MLX5_ST_SZ_DW(modify_nic_vport_context_out)];
+
+	MLX5_SET(modify_nic_vport_context_in, in, opcode,
+		 MLX5_CMD_OP_MODIFY_NIC_VPORT_CONTEXT);
+
+	memset(out, 0, sizeof(out));
+	return mlx5_cmd_exec_check_status(mdev, in, inlen, out, sizeof(out));
+}
+
+int mlx5_query_nic_vport_mac_address(struct mlx5_core_dev *mdev,
+				     u16 vport, u8 *addr)
 {
-	u32  in[MLX5_ST_SZ_DW(query_nic_vport_context_in)];
 	u32 *out;
 	int outlen = MLX5_ST_SZ_BYTES(query_nic_vport_context_out);
 	u8 *out_addr;
+	int err;
 
 	out = mlx5_vzalloc(outlen);
 	if (!out)
-		return;
+		return -ENOMEM;
 
 	out_addr = MLX5_ADDR_OF(query_nic_vport_context_out, out,
 				nic_vport_context.permanent_address);
 
-	memset(in, 0, sizeof(in));
-
-	MLX5_SET(query_nic_vport_context_in, in, opcode,
-		 MLX5_CMD_OP_QUERY_NIC_VPORT_CONTEXT);
-
-	memset(out, 0, outlen);
-	mlx5_cmd_exec_check_status(mdev, in, sizeof(in), out, outlen);
+	err = mlx5_query_nic_vport_context(mdev, vport, out, outlen);
+	if (err)
+		goto out;
 
 	ether_addr_copy(addr, &out_addr[2]);
 
+out:
 	kvfree(out);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_query_nic_vport_mac_address);
+
+int mlx5_modify_nic_vport_mac_address(struct mlx5_core_dev *mdev,
+				      u16 vport, u8 *addr)
+{
+	void *in;
+	int inlen = MLX5_ST_SZ_BYTES(modify_nic_vport_context_in);
+	int err;
+	void *nic_vport_ctx;
+	u8 *perm_mac;
+
+	in = mlx5_vzalloc(inlen);
+	if (!in) {
+		mlx5_core_warn(mdev, "failed to allocate inbox\n");
+		return -ENOMEM;
+	}
+
+	MLX5_SET(modify_nic_vport_context_in, in,
+		 field_select.permanent_address, 1);
+	MLX5_SET(modify_nic_vport_context_in, in, vport_number, vport);
+
+	if (vport)
+		MLX5_SET(modify_nic_vport_context_in, in, other_vport, 1);
+
+	nic_vport_ctx = MLX5_ADDR_OF(modify_nic_vport_context_in,
+				     in, nic_vport_context);
+	perm_mac = MLX5_ADDR_OF(nic_vport_context, nic_vport_ctx,
+				permanent_address);
+
+	ether_addr_copy(&perm_mac[2], addr);
+
+	err = mlx5_modify_nic_vport_context(mdev, in, inlen);
+
+	kvfree(in);
+
+	return err;
 }
-EXPORT_SYMBOL(mlx5_query_nic_vport_mac_address);
+EXPORT_SYMBOL(mlx5_modify_nic_vport_mac_address);
 
 int mlx5_query_hca_vport_gid(struct mlx5_core_dev *dev, u8 other_vport,
 			     u8 port_num, u16  vf_num, u16 gid_index,
diff --git a/include/linux/mlx5/vport.h b/include/linux/mlx5/vport.h
index 967e0fd..43e82d9 100644
--- a/include/linux/mlx5/vport.h
+++ b/include/linux/mlx5/vport.h
@@ -36,7 +36,10 @@
 #include <linux/mlx5/driver.h>
 
 u8 mlx5_query_vport_state(struct mlx5_core_dev *mdev, u8 opmod);
-void mlx5_query_nic_vport_mac_address(struct mlx5_core_dev *mdev, u8 *addr);
+int mlx5_query_nic_vport_mac_address(struct mlx5_core_dev *mdev,
+				     u16 vport, u8 *addr);
+int mlx5_modify_nic_vport_mac_address(struct mlx5_core_dev *dev,
+				      u16 vport, u8 *addr);
 int mlx5_query_hca_vport_gid(struct mlx5_core_dev *dev, u8 other_vport,
 			     u8 port_num, u16  vf_num, u16 gid_index,
 			     union ib_gid *gid);
-- 
2.3.7
