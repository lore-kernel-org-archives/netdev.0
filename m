From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 10/13] net/mlx4_en: Cleanups suggested by clang static checker
Date: Mon, 27 Oct 2014 11:37:44 +0200
Message-ID: <1414402667-8841-11-git-send-email-amirv@mellanox.com>
References: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:32861 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752265AbaJ0Jia (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 05:38:30 -0400
In-Reply-To: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

clang flagged the following. All are actually cosmetic cleanups, not really bugs:

drivers/net/ethernet/mellanox/mlx4/en_main.c:233:3: warning: Value stored to 'err' is never read
                err = -ENOMEM;
                ^     ~~~~~~~
drivers/net/ethernet/mellanox/mlx4/en_main.c:293:3: warning: Value stored to 'err' is never read
                err = -ENOMEM;

drivers/net/ethernet/mellanox/mlx4/en_netdev.c:648:16: warning: Assigned value is garbage or undefined
        entry->reg_id = reg_id;
                      ^ ~~~~~~
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:659:2: warning: Function call argument is an uninitialized value
        mlx4_en_uc_steer_release(priv, priv->dev->dev_addr, *qpn, reg_id);
(NOTE: reg_id is only used in the device-managed flow steering path, in which is it always initialized.
 This is not a bug. Cleanup here is therefore cosmetic only).

drivers/net/ethernet/mellanox/mlx4/en_rx.c:122:3: warning: Value stored to 'frag_info' is never read
                frag_info = &priv->frag_info[i];
                ^           ~~~~~~~~~~~~~~~~~~~


Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_main.c   | 12 +++---------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |  1 -
 3 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index 2091ae88..9f16f75 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -221,15 +221,12 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 {
 	struct mlx4_en_dev *mdev;
 	int i;
-	int err;
 
 	printk_once(KERN_INFO "%s", mlx4_en_version);
 
 	mdev = kzalloc(sizeof(*mdev), GFP_KERNEL);
-	if (!mdev) {
-		err = -ENOMEM;
+	if (!mdev)
 		goto err_free_res;
-	}
 
 	if (mlx4_pd_alloc(dev, &mdev->priv_pdn))
 		goto err_free_dev;
@@ -264,8 +261,7 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 	}
 
 	/* Build device profile according to supplied module parameters */
-	err = mlx4_en_get_profile(mdev);
-	if (err) {
+	if (mlx4_en_get_profile(mdev)) {
 		mlx4_err(mdev, "Bad module parameters, aborting\n");
 		goto err_mr;
 	}
@@ -286,10 +282,8 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 	 * Note: we cannot use the shared workqueue because of deadlocks caused
 	 *       by the rtnl lock */
 	mdev->workqueue = create_singlethread_workqueue("mlx4_en");
-	if (!mdev->workqueue) {
-		err = -ENOMEM;
+	if (!mdev->workqueue)
 		goto err_mr;
-	}
 
 	/* At this stage all non-port specific tasks are complete:
 	 * mark the card state as up */
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 5d60882..c4450be 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -575,7 +575,7 @@ static int mlx4_en_get_qp(struct mlx4_en_priv *priv)
 	struct mlx4_mac_entry *entry;
 	int index = 0;
 	int err = 0;
-	u64 reg_id;
+	u64 reg_id = 0;
 	int *qpn = &priv->base_qpn;
 	u64 mac = mlx4_mac_to_u64(priv->dev->dev_addr);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 01660c5..c8e75da 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -119,7 +119,6 @@ static int mlx4_en_alloc_frags(struct mlx4_en_priv *priv,
 
 out:
 	while (i--) {
-		frag_info = &priv->frag_info[i];
 		if (page_alloc[i].page != ring_alloc[i].page) {
 			dma_unmap_page(priv->ddev, page_alloc[i].dma,
 				page_alloc[i].page_size, PCI_DMA_FROMDEVICE);
-- 
1.8.3.4
