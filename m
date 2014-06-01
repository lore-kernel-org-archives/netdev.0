From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH 3.2-stable 1/2] mlx4_core: Stash PCI ID driver_data in mlx4_priv structure
Date: Sun,  1 Jun 2014 15:25:40 +0800
Message-ID: <1401607541-8519-1-git-send-email-weiyang@linux.vnet.ibm.com>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>,
	Roland Dreier <roland@purestorage.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp02.au.ibm.com ([202.81.31.144]:53862 "EHLO
	e23smtp02.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755641AbaFAHZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 03:25:50 -0400
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Sun, 1 Jun 2014 17:25:48 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 8ADDB2CE8047
	for <netdev@vger.kernel.org>; Sun,  1 Jun 2014 17:25:45 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5173ubY11010516
	for <netdev@vger.kernel.org>; Sun, 1 Jun 2014 17:03:56 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s517PiLD004228
	for <netdev@vger.kernel.org>; Sun, 1 Jun 2014 17:25:45 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That way we can check flags later on, when we've finished with the
pci_device_id structure.

This is a backport.

Signed-off-by: Roland Dreier <roland@purestorage.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |   12 +++++++++---
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |    2 ++
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 94bbc85..dd18373 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1220,7 +1220,7 @@ static void mlx4_clear_steering(struct mlx4_dev *dev)
 	kfree(priv->steer);
 }
 
-static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
+static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
 {
 	struct mlx4_priv *priv;
 	struct mlx4_dev *dev;
@@ -1362,6 +1362,7 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	mlx4_sense_init(dev);
 	mlx4_start_sense(dev);
 
+	priv->pci_dev_data = pci_dev_data;
 	pci_set_drvdata(pdev, dev);
 
 	return 0;
@@ -1414,7 +1415,7 @@ static int __devinit mlx4_init_one(struct pci_dev *pdev,
 {
 	printk_once(KERN_INFO "%s", mlx4_version);
 
-	return __mlx4_init_one(pdev, id);
+	return __mlx4_init_one(pdev, id->driver_data);
 }
 
 static void mlx4_remove_one(struct pci_dev *pdev)
@@ -1463,8 +1464,13 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 
 int mlx4_restart_one(struct pci_dev *pdev)
 {
+	struct mlx4_dev  *dev  = pci_get_drvdata(pdev);
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int               pci_dev_data;
+
+	pci_dev_data = priv->pci_dev_data;
 	mlx4_remove_one(pdev);
-	return __mlx4_init_one(pdev, NULL);
+	return __mlx4_init_one(pdev, pci_dev_data);
 }
 
 static DEFINE_PCI_DEVICE_TABLE(mlx4_pci_table) = {
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 5dfa68f..dc1b925 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -328,6 +328,8 @@ struct mlx4_priv {
 	struct list_head	ctx_list;
 	spinlock_t		ctx_lock;
 
+	int                     pci_dev_data;
+
 	struct list_head        pgdir_list;
 	struct mutex            pgdir_mutex;
 
-- 
1.7.9.5
