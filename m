From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [ofa-general][PATCH 2/2] mlx4: ConnectX multi functional device
	support
Date: Thu, 18 Jun 2009 15:37:09 +0300
Message-ID: <4A3A34F5.9030800@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

MT26468 (0x6764) device can open multiple physical functions.
The current driver can only work with one (primary) pf.
For all other functions, QUERY_FW command would fail with
CMD_STAT_MULTI_FUNC_REQ error code. We should not work on those
devices, but they should remain in the driver's ownership.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/cmd.c      |    5 ++++-
 drivers/net/mlx4/main.c     |   20 ++++++++++++++++----
 include/linux/mlx4/device.h |    1 +
 3 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/drivers/net/mlx4/cmd.c b/drivers/net/mlx4/cmd.c
index 2845a05..92d649c 100644
--- a/drivers/net/mlx4/cmd.c
+++ b/drivers/net/mlx4/cmd.c
@@ -80,7 +80,9 @@ enum {
 	/* Bad management packet (silently discarded): */
 	CMD_STAT_BAD_PKT	= 0x30,
 	/* More outstanding CQEs in CQ than new CQ size: */
-	CMD_STAT_BAD_SIZE	= 0x40
+	CMD_STAT_BAD_SIZE	= 0x40,
+	/* Multi Function device support required: */
+	CMD_STAT_MULTI_FUNC_REQ	= 0x50
 };
 
 enum {
@@ -128,6 +130,7 @@ static int mlx4_status_to_errno(u8 status)
 		[CMD_STAT_LAM_NOT_PRE]	  = -EAGAIN,
 		[CMD_STAT_BAD_PKT]	  = -EINVAL,
 		[CMD_STAT_BAD_SIZE]	  = -ENOMEM,
+		[CMD_STAT_MULTI_FUNC_REQ] = -EACCES,
 	};
 
 	if (status >= ARRAY_SIZE(trans_table) ||
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 57326f9..541243e 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -729,7 +729,10 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 
 	err = mlx4_QUERY_FW(dev);
 	if (err) {
-		mlx4_err(dev, "QUERY_FW command failed, aborting.\n");
+		if (err == -EACCES)
+			mlx4_dbg(dev, "Function disabled.\n");
+		else
+			mlx4_err(dev, "QUERY_FW command failed, aborting.\n");
 		return err;
 	}
 
@@ -1137,8 +1140,14 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	}
 
 	err = mlx4_init_hca(dev);
-	if (err)
-		goto err_cmd;
+	if (err) {
+		if (err == -EACCES) {
+			dev->flags |= MLX4_FLAG_NOT_PRIME;
+			pci_set_drvdata(pdev, dev);
+			return 0;
+		} else
+			goto err_cmd;
+	}
 
 	err = mlx4_alloc_eq_table(dev);
 	if (err)
@@ -1234,6 +1243,8 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 	int p;
 
 	if (dev) {
+		if (dev->flags & MLX4_FLAG_NOT_PRIME)
+			goto cmd_cleanup;
 		mlx4_stop_sense(dev);
 		mlx4_unregister_device(dev);
 
@@ -1256,11 +1267,12 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 		mlx4_cleanup_uar_table(dev);
 		mlx4_free_eq_table(dev);
 		mlx4_close_hca(dev);
-		mlx4_cmd_cleanup(dev);
 
 		if (dev->flags & MLX4_FLAG_MSI_X)
 			pci_disable_msix(pdev);
 
+cmd_cleanup:
+		mlx4_cmd_cleanup(dev);
 		kfree(priv);
 		pci_release_region(pdev, 2);
 		pci_release_region(pdev, 0);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index ce7cc6c..637e72c 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -42,6 +42,7 @@
 enum {
 	MLX4_FLAG_MSI_X		= 1 << 0,
 	MLX4_FLAG_OLD_PORT_CMDS	= 1 << 1,
+	MLX4_FLAG_NOT_PRIME	= 1 << 2,
 };
 
 enum {
-- 
1.6.0
