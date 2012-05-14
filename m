From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 5/8] net/mlx4_core: Do not reset module-parameter num_vfs when fail to enable sriov
Date: Mon, 14 May 2012 23:04:10 +0300
Message-ID: <1337025853-26685-6-git-send-email-ogerlitz@mellanox.com>
References: <1337025853-26685-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:55922 "HELO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757747Ab2ENUEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 16:04:25 -0400
In-Reply-To: <1337025853-26685-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Consider the following scenario: 2 HCAs, where only one of which can run SRIOV.

If we reset the module parameter, all the VFs of the SRIOV HCA will be
claimed by the PPF host (-- the code relies on num_vfs being non-zero
to avoid this claiming, and num_vfs was reset when pci_enable_sriov failed
for the non-SRIOV HCA).

The solution is not to touch the num_vfs parameter.

Also, eliminate the unneeded check of num_vfs when disabling sriov
(the dev flag bit is sufficient).

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 8bb05b4..8eed1f2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1865,7 +1865,6 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 				mlx4_err(dev, "Failed to enable sriov,"
 					 "continuing without sriov enabled"
 					 " (err = %d).\n", err);
-				num_vfs = 0;
 				err = 0;
 			} else {
 				mlx4_warn(dev, "Running in master mode\n");
@@ -2022,7 +2021,7 @@ err_cmd:
 	mlx4_cmd_cleanup(dev);
 
 err_sriov:
-	if (num_vfs && (dev->flags & MLX4_FLAG_SRIOV))
+	if (dev->flags & MLX4_FLAG_SRIOV)
 		pci_disable_sriov(pdev);
 
 err_rel_own:
@@ -2099,7 +2098,7 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 
 		if (dev->flags & MLX4_FLAG_MSI_X)
 			pci_disable_msix(pdev);
-		if (num_vfs && (dev->flags & MLX4_FLAG_SRIOV)) {
+		if (dev->flags & MLX4_FLAG_SRIOV) {
 			mlx4_warn(dev, "Disabling sriov\n");
 			pci_disable_sriov(pdev);
 		}
-- 
1.7.1
