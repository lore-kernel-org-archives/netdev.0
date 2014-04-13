From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net] net/mlx4_core: Defer VF initialization till PF is fully initialized
Date: Sun, 13 Apr 2014 18:17:35 +0300
Message-ID: <1397402255-9996-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Stuart Hayes <Stuart_Hayes@Dell.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:58220 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751268AbaDMPR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Apr 2014 11:17:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix in commit [1] is not sufficient since a deferred VF initialization
could happen after pci_enable_sriov() is finished, but before the PF is
fully initialized.
Need to prevent VFs from initializing till the PF is fully ready and
comm channel is operational.

[1] - 9798935 "net/mlx4_core: mlx4_init_slave() shouldn't access comm
      channel before PF is ready"

CC: Stuart Hayes <Stuart_Hayes@Dell.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index f0ae95f..da62866 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2374,10 +2374,10 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
 			} else {
 				atomic_inc(&pf_loading);
 				err = pci_enable_sriov(pdev, total_vfs);
-				atomic_dec(&pf_loading);
 				if (err) {
 					mlx4_err(dev, "Failed to enable SR-IOV, continuing without SR-IOV (err = %d).\n",
 						 err);
+					atomic_dec(&pf_loading);
 					err = 0;
 				} else {
 					mlx4_warn(dev, "Running in master mode\n");
@@ -2538,6 +2538,9 @@ slave_start:
 	priv->pci_dev_data = pci_dev_data;
 	pci_set_drvdata(pdev, dev);
 
+	if (mlx4_is_master(dev) && dev->num_vfs)
+		atomic_dec(&pf_loading);
+
 	return 0;
 
 err_port:
@@ -2588,6 +2591,9 @@ err_rel_own:
 	if (!mlx4_is_slave(dev))
 		mlx4_free_ownership(dev);
 
+	if (mlx4_is_master(dev) && dev->num_vfs)
+		atomic_dec(&pf_loading);
+
 	kfree(priv->dev.dev_vfs);
 
 err_free_dev:
-- 
1.8.3.4
