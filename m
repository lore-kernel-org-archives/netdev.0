From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 07/10] net/mlx4_core: Do not access comm channel if it has not yet been initialized
Date: Thu, 27 Oct 2016 16:27:19 +0300
Message-ID: <1477574842-29688-8-git-send-email-tariqt@mellanox.com>
References: <1477574842-29688-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57538 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S941581AbcJ0NyW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 09:54:22 -0400
In-Reply-To: <1477574842-29688-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

In the Hypervisor, there are several FW commands which are invoked
before the comm channel is initialized (in mlx4_multi_func_init).
These include MOD_STAT_CONFIG, QUERY_DEV_CAP, INIT_HCA, and others.

If any of these commands fails, say with a timeout, the Hypervisor
driver enters the internal error reset flow. In this flow, the driver
attempts to notify all slaves via the comm channel that an internal error
has occurred.

Since the comm channel has not yet been initialized (i.e., mapped via
ioremap), this will cause dereferencing a NULL pointer.

To fix this, do not access the comm channel in the internal error flow
if it has not yet been initialized.

Fixes: 55ad359225b2 ("net/mlx4_core: Enable device recovery flow with SRIOV")
Fixes: ab9c17a009ee ("mlx4_core: Modify driver initialization flow to accommodate SRIOV for Ethernet")
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index b1cef7a0f7ca..e36bebcab3f2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -2469,6 +2469,7 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 	kfree(priv->mfunc.master.slave_state);
 err_comm:
 	iounmap(priv->mfunc.comm);
+	priv->mfunc.comm = NULL;
 err_vhcr:
 	dma_free_coherent(&dev->persist->pdev->dev, PAGE_SIZE,
 			  priv->mfunc.vhcr,
@@ -2537,6 +2538,13 @@ void mlx4_report_internal_err_comm_event(struct mlx4_dev *dev)
 	int slave;
 	u32 slave_read;
 
+	/* If the comm channel has not yet been initialized,
+	 * skip reporting the internal error event to all
+	 * the communication channels.
+	 */
+	if (!priv->mfunc.comm)
+		return;
+
 	/* Report an internal error event to all
 	 * communication channels.
 	 */
@@ -2571,6 +2579,7 @@ void mlx4_multi_func_cleanup(struct mlx4_dev *dev)
 	}
 
 	iounmap(priv->mfunc.comm);
+	priv->mfunc.comm = NULL;
 }
 
 void mlx4_cmd_cleanup(struct mlx4_dev *dev, int cleanup_mask)
-- 
1.8.3.1
