From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 10/10] net/mlx5: Only cancel recovery work when cleaning up device
Date: Tue, 10 Jan 2017 22:33:39 +0200
Message-ID: <1484080419-24256-11-git-send-email-saeedm@mellanox.com>
References: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Daniel Jurgens <danielj@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52051 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751118AbdAJUe1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:34:27 -0500
In-Reply-To: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Jurgens <danielj@mellanox.com>

Do not attempt to drain the health workqueue when unloading the device in
the recovery flow, this can cause a deadlock when the recovery work
tries to cancel itself with sync.

Because the work is no longer unconditionally canceled when unloading, it
must be explicitly canceled in the AER flow.

fixes: 689a248df83b ("net/mlx5: Cancel recovery work in remove flow")
Signed-off-by: Daniel Jurgens <danielj@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 6547f22..d01e9f2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1195,7 +1195,8 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 {
 	int err = 0;
 
-	mlx5_drain_health_wq(dev);
+	if (cleanup)
+		mlx5_drain_health_wq(dev);
 
 	mutex_lock(&dev->intf_state_mutex);
 	if (test_bit(MLX5_INTERFACE_STATE_DOWN, &dev->intf_state)) {
@@ -1359,9 +1360,10 @@ static pci_ers_result_t mlx5_pci_err_detected(struct pci_dev *pdev,
 
 	mlx5_enter_error_state(dev);
 	mlx5_unload_one(dev, priv, false);
-	/* In case of kernel call save the pci state */
+	/* In case of kernel call save the pci state and drain the health wq */
 	if (state) {
 		pci_save_state(pdev);
+		mlx5_drain_health_wq(dev);
 		mlx5_pci_disable_device(dev);
 	}
 
-- 
2.7.4
