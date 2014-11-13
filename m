From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 7/7] net/mlx4_core: Support more than 64 VFs
Date: Thu, 13 Nov 2014 14:45:33 +0200
Message-ID: <1415882733-3084-8-git-send-email-ogerlitz@mellanox.com>
References: <1415882733-3084-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46655 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932969AbaKMMqG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2014 07:46:06 -0500
In-Reply-To: <1415882733-3084-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

We now allow up to 126 VFs. Note though that certain firmware
versions only allow up to 80 VFs. Moreover, old HCAs only support 64 VFs.
In these cases, we limit the maximum number of VFs to 64.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c   |    5 ++++-
 drivers/net/ethernet/mellanox/mlx4/main.c |   24 ++++++++++++++++++++++++
 include/linux/mlx4/device.h               |    5 +++--
 3 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index d2f594f..4251f81 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -143,7 +143,8 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[14] = "Ethernet protocol control support",
 		[15] = "Ethernet Backplane autoneg support",
 		[16] = "CONFIG DEV support",
-		[17] = "Asymmetric EQs support"
+		[17] = "Asymmetric EQs support",
+		[18] = "More than 80 VFs support"
 	};
 	int i;
 
@@ -860,6 +861,8 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_VLAN_CONTROL;
 	if (field32 & (1 << 20))
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_FSM;
+	if (field32 & (1 << 21))
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_80_VFS;
 
 	if (dev->flags & MLX4_FLAG_OLD_PORT_CMDS) {
 		for (i = 1; i <= dev_cap->num_ports; ++i) {
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index ebb2790..3044f9e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2373,6 +2373,24 @@ disable_sriov:
 	return dev_flags & ~MLX4_FLAG_MASTER;
 }
 
+enum {
+	MLX4_DEV_CAP_CHECK_NUM_VFS_ABOVE_64 = -1,
+};
+
+static int mlx4_check_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap,
+			      int *nvfs)
+{
+	int requested_vfs = nvfs[0] + nvfs[1] + nvfs[2];
+	/* Checking for 64 VFs as a limitation of CX2 */
+	if (!(dev_cap->flags2 & MLX4_DEV_CAP_FLAG2_80_VFS) &&
+	    requested_vfs >= 64) {
+		mlx4_err(dev, "Requested %d VFs, but FW does not support more than 64\n",
+			 requested_vfs);
+		return MLX4_DEV_CAP_CHECK_NUM_VFS_ABOVE_64;
+	}
+	return 0;
+}
+
 static int mlx4_load_one(struct pci_dev *pdev, int pci_dev_data,
 			 int total_vfs, int *nvfs, struct mlx4_priv *priv)
 {
@@ -2484,6 +2502,9 @@ slave_start:
 				goto err_fw;
 			}
 
+			if (mlx4_check_dev_cap(dev, dev_cap, nvfs))
+				goto err_fw;
+
 			if (!(dev_cap->flags2 & MLX4_DEV_CAP_FLAG2_SYS_EQS)) {
 				u64 dev_flags = mlx4_enable_sriov(dev, pdev, total_vfs,
 								  existing_vfs);
@@ -2512,6 +2533,9 @@ slave_start:
 				mlx4_err(dev, "QUERY_DEV_CAP command failed, aborting.\n");
 				goto err_fw;
 			}
+
+			if (mlx4_check_dev_cap(dev, dev_cap, nvfs))
+				goto err_fw;
 		}
 	}
 
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 1c560eb..cf09e65 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -95,7 +95,7 @@ enum {
 
 enum {
 	MLX4_MAX_NUM_PF		= 16,
-	MLX4_MAX_NUM_VF		= 64,
+	MLX4_MAX_NUM_VF		= 126,
 	MLX4_MAX_NUM_VF_P_PORT  = 64,
 	MLX4_MFUNC_MAX		= 80,
 	MLX4_MAX_EQ_NUM		= 1024,
@@ -190,7 +190,8 @@ enum {
 	MLX4_DEV_CAP_FLAG2_ETH_PROT_CTRL        = 1LL <<  14,
 	MLX4_DEV_CAP_FLAG2_ETH_BACKPL_AN_REP	= 1LL <<  15,
 	MLX4_DEV_CAP_FLAG2_CONFIG_DEV		= 1LL <<  16,
-	MLX4_DEV_CAP_FLAG2_SYS_EQS		= 1LL <<  17
+	MLX4_DEV_CAP_FLAG2_SYS_EQS		= 1LL <<  17,
+	MLX4_DEV_CAP_FLAG2_80_VFS		= 1LL <<  18
 };
 
 enum {
-- 
1.7.1
