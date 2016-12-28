From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 03/12] net/mlx5: Cancel recovery work in remove flow
Date: Wed, 28 Dec 2016 14:58:33 +0200
Message-ID: <1482929922-32626-4-git-send-email-saeedm@mellanox.com>
References: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Daniel Jurgens <danielj@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32815 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751621AbcL1M66 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 07:58:58 -0500
In-Reply-To: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Jurgens <danielj@mellanox.com>

If there is pending delayed work for health recovery it must be canceled
if the device is being unloaded.

Fixes: 05ac2c0b7438 ("net/mlx5: Fix race between PCI error handlers and health work")
Signed-off-by: Daniel Jurgens <danielj@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 23c12f1..0b49739 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1196,6 +1196,8 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 {
 	int err = 0;
 
+	mlx5_drain_health_wq(dev);
+
 	mutex_lock(&dev->intf_state_mutex);
 	if (test_bit(MLX5_INTERFACE_STATE_DOWN, &dev->intf_state)) {
 		dev_warn(&dev->pdev->dev, "%s: interface is down, NOP\n",
@@ -1358,10 +1360,9 @@ static pci_ers_result_t mlx5_pci_err_detected(struct pci_dev *pdev,
 
 	mlx5_enter_error_state(dev);
 	mlx5_unload_one(dev, priv, false);
-	/* In case of kernel call save the pci state and drain health wq */
+	/* In case of kernel call save the pci state */
 	if (state) {
 		pci_save_state(pdev);
-		mlx5_drain_health_wq(dev);
 		mlx5_pci_disable_device(dev);
 	}
 
-- 
2.7.4
