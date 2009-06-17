From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [ofa-general][PATCH] mlx4: ConnectX multi functional device support
Date: Wed, 17 Jun 2009 17:22:01 +0300
Message-ID: <4A38FC09.4010800@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:33103 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752989AbZFQNcJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 09:32:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch adds new device ID,
Another change is that the device can open multiple physical functions.
The current driver can only work with one (primary) pf.
For all other functions, QUERY_FW command would fail with
CMD_STAT_MULTI_FUNC_REQ error code. We should not work on those
devices, but they should remain in the driver's ownership.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/cmd.c      |    5 ++++-
 drivers/net/mlx4/main.c     |   21 +++++++++++++++++----
 include/linux/mlx4/device.h |    1 +
 3 files changed, 22 insertions(+), 5 deletions(-)

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
index 018348c..541243e 100644
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
@@ -1285,6 +1297,7 @@ static struct pci_device_id mlx4_pci_table[] = {
 	{ PCI_VDEVICE(MELLANOX, 0x6750) }, /* MT25408 "Hermon" EN 10GigE PCIe gen2 */
 	{ PCI_VDEVICE(MELLANOX, 0x6372) }, /* MT25458 ConnectX EN 10GBASE-T 10GigE */
 	{ PCI_VDEVICE(MELLANOX, 0x675a) }, /* MT25458 ConnectX EN 10GBASE-T+Gen2 10GigE */
+	{ PCI_VDEVICE(MELLANOX, 0x6764) }, /* MT26468 ConnectX EN 10GigE, PCIe, 2.0 5Gt/s */
 	{ 0, }
 };
 
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

