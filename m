From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 2/5] net/mlx5: Don't save PCI state when PCI error is detected
Date: Fri, 10 Mar 2017 14:33:02 +0200
Message-ID: <20170310123305.2185-3-saeedm@mellanox.com>
References: <20170310123305.2185-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Daniel Jurgens <danielj@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38693 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S937255AbdCJMdc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 07:33:32 -0500
In-Reply-To: <20170310123305.2185-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Jurgens <danielj@mellanox.com>

When a PCI error is detected the PCI state could be corrupt, don't save
it in that flow. Save the state after initialization. After restoring the
PCI state during slot reset save it again, restoring the state destroys
the previously saved state info.

Fixes: 05ac2c0b7438 ('net/mlx5: Fix race between PCI error handlers and
health work')
Signed-off-by: Daniel Jurgens <danielj@mellanox.com>

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index c4242a4e8130..e2bd600d19de 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1352,6 +1352,7 @@ static int init_one(struct pci_dev *pdev,
 	if (err)
 		goto clean_load;
 
+	pci_save_state(pdev);
 	return 0;
 
 clean_load:
@@ -1407,9 +1408,8 @@ static pci_ers_result_t mlx5_pci_err_detected(struct pci_dev *pdev,
 
 	mlx5_enter_error_state(dev);
 	mlx5_unload_one(dev, priv, false);
-	/* In case of kernel call save the pci state and drain the health wq */
+	/* In case of kernel call drain the health wq */
 	if (state) {
-		pci_save_state(pdev);
 		mlx5_drain_health_wq(dev);
 		mlx5_pci_disable_device(dev);
 	}
@@ -1461,6 +1461,7 @@ static pci_ers_result_t mlx5_pci_slot_reset(struct pci_dev *pdev)
 
 	pci_set_master(pdev);
 	pci_restore_state(pdev);
+	pci_save_state(pdev);
 
 	if (wait_vital(pdev)) {
 		dev_err(&pdev->dev, "%s: wait_vital timed out\n", __func__);
-- 
2.11.0
