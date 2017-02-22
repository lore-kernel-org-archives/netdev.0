From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net V2 4/5] net/mlx4_core: Use cq quota in SRIOV when creating completion EQs
Date: Wed, 22 Feb 2017 18:25:28 +0200
Message-ID: <1487780729-8798-5-git-send-email-tariqt@mellanox.com>
References: <1487780729-8798-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Dexuan Cui <decui@microsoft.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39988 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932807AbdBVQZ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 11:25:59 -0500
In-Reply-To: <1487780729-8798-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

When creating EQs to handle CQ completion events for the PF
or for VFs, we create enough EQE entries to handle completions
for the max number of CQs that can use that EQ.

When SRIOV is activated, the max number of CQs a VF (or the PF) can
obtain is its CQ quota (determined by the Hypervisor resource tracker).
Therefore, when creating an EQ, the number of EQE entries that the VF
should request for that EQ is the CQ quota value (and not the total
number of CQs available in the FW).

Under SRIOV, the PF, also must use its CQ quota, because
the resource tracker also controls how many CQs the PF can obtain.

Using the FW total CQs instead of the CQ quota when creating EQs resulted
wasting MTT entries, due to allocating more EQEs than were needed.

Fixes: 5a0d0a6161ae ("mlx4: Structures and init/teardown for VF resource quotas")
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Reported-by: Dexuan Cui <decui@microsoft.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/eq.c   | 5 ++---
 drivers/net/ethernet/mellanox/mlx4/main.c | 3 ++-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 0509996957d9..232f46db0dce 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -1256,9 +1256,8 @@ int mlx4_init_eq_table(struct mlx4_dev *dev)
 					mlx4_warn(dev, "Failed adding irq rmap\n");
 			}
 #endif
-			err = mlx4_create_eq(dev, dev->caps.num_cqs -
-						  dev->caps.reserved_cqs +
-						  MLX4_NUM_SPARE_EQE,
+			err = mlx4_create_eq(dev, dev->quotas.cq +
+					     MLX4_NUM_SPARE_EQE,
 					     (dev->flags & MLX4_FLAG_MSI_X) ?
 					     i + 1 - !!(i > MLX4_EQ_ASYNC) : 0,
 					     eq);
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 7a030d10ff3e..094cfd8a1a18 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -3501,6 +3501,8 @@ static int mlx4_load_one(struct pci_dev *pdev, int pci_dev_data,
 			goto err_disable_msix;
 	}
 
+	mlx4_init_quotas(dev);
+
 	err = mlx4_setup_hca(dev);
 	if (err == -EBUSY && (dev->flags & MLX4_FLAG_MSI_X) &&
 	    !mlx4_is_mfunc(dev)) {
@@ -3513,7 +3515,6 @@ static int mlx4_load_one(struct pci_dev *pdev, int pci_dev_data,
 	if (err)
 		goto err_steer;
 
-	mlx4_init_quotas(dev);
 	/* When PF resources are ready arm its comm channel to enable
 	 * getting commands
 	 */
-- 
1.8.3.1
