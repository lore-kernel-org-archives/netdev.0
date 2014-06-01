From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH 3.4-stable 1/2] mlx4_core: Stash PCI ID driver_data in mlx4_priv structure
Date: Sun,  1 Jun 2014 15:25:19 +0800
Message-ID: <1401607520-8471-1-git-send-email-weiyang@linux.vnet.ibm.com>
Cc: Roland Dreier <roland@purestorage.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([122.248.162.8]:58828 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754974AbaFAHZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 03:25:32 -0400
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Sun, 1 Jun 2014 12:55:30 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id D1F851258048
	for <netdev@vger.kernel.org>; Sun,  1 Jun 2014 12:54:42 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s517PcRP63635478
	for <netdev@vger.kernel.org>; Sun, 1 Jun 2014 12:55:38 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s517PRD3018066
	for <netdev@vger.kernel.org>; Sun, 1 Jun 2014 12:55:27 +0530
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <roland@purestorage.com>

That way we can check flags later on, when we've finished with the
pci_device_id structure.  Also convert the "is VF" flag to an enum:
"Never do in the preprocessor what can be done in C."

Signed-off-by: Roland Dreier <roland@purestorage.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |   27 +++++++++++++++------------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |    6 ++++++
 2 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 8bb05b4..746b367 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -92,8 +92,6 @@ MODULE_PARM_DESC(log_num_mgm_entry_size, "log mgm size, that defines the num"
 					 " 10 gives 248.range: 9<="
 					 " log_num_mgm_entry_size <= 12");
 
-#define MLX4_VF                                        (1 << 0)
-
 #define HCA_GLOBAL_CAP_MASK            0
 #define PF_CONTEXT_BEHAVIOUR_MASK      0
 
@@ -1738,7 +1736,7 @@ static void mlx4_free_ownership(struct mlx4_dev *dev)
 	iounmap(owner);
 }
 
-static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
+static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
 {
 	struct mlx4_priv *priv;
 	struct mlx4_dev *dev;
@@ -1761,12 +1759,11 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	/*
 	 * Check for BARs.
 	 */
-	if (((id == NULL) || !(id->driver_data & MLX4_VF)) &&
+	if (!(pci_dev_data & MLX4_PCI_DEV_IS_VF) &&
 	    !(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
 		dev_err(&pdev->dev, "Missing DCS, aborting."
-			"(id == 0X%p, id->driver_data: 0x%lx,"
-			" pci_resource_flags(pdev, 0):0x%lx)\n", id,
-			id ? id->driver_data : 0, pci_resource_flags(pdev, 0));
+			"(driver_data: 0x%x, pci_resource_flags(pdev, 0):0x%lx)\n",
+			pci_dev_data, pci_resource_flags(pdev, 0));
 		err = -ENODEV;
 		goto err_disable_pdev;
 	}
@@ -1831,7 +1828,7 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	dev->rev_id = pdev->revision;
 	/* Detect if this device is a virtual function */
-	if (id && id->driver_data & MLX4_VF) {
+	if (pci_dev_data & MLX4_PCI_DEV_IS_VF) {
 		/* When acting as pf, we normally skip vfs unless explicitly
 		 * requested to probe them. */
 		if (num_vfs && extended_func_num(pdev) > probe_vf) {
@@ -1977,6 +1974,7 @@ slave_start:
 	mlx4_sense_init(dev);
 	mlx4_start_sense(dev);
 
+	priv->pci_dev_data = pci_dev_data;
 	pci_set_drvdata(pdev, dev);
 
 	return 0;
@@ -2046,7 +2044,7 @@ static int __devinit mlx4_init_one(struct pci_dev *pdev,
 {
 	printk_once(KERN_INFO "%s", mlx4_version);
 
-	return __mlx4_init_one(pdev, id);
+	return __mlx4_init_one(pdev, id->driver_data);
 }
 
 static void mlx4_remove_one(struct pci_dev *pdev)
@@ -2115,8 +2113,13 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 
 int mlx4_restart_one(struct pci_dev *pdev)
 {
+	struct mlx4_dev	 *dev  = pci_get_drvdata(pdev);
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int		  pci_dev_data;
+
+	pci_dev_data = priv->pci_dev_data;
 	mlx4_remove_one(pdev);
-	return __mlx4_init_one(pdev, NULL);
+	return __mlx4_init_one(pdev, pci_dev_data);
 }
 
 static DEFINE_PCI_DEVICE_TABLE(mlx4_pci_table) = {
@@ -2145,11 +2148,11 @@ static DEFINE_PCI_DEVICE_TABLE(mlx4_pci_table) = {
 	/* MT26478 ConnectX2 40GigE PCIe gen2 */
 	{ PCI_VDEVICE(MELLANOX, 0x676e), 0 },
 	/* MT25400 Family [ConnectX-2 Virtual Function] */
-	{ PCI_VDEVICE(MELLANOX, 0x1002), MLX4_VF },
+	{ PCI_VDEVICE(MELLANOX, 0x1002), MLX4_PCI_DEV_IS_VF },
 	/* MT27500 Family [ConnectX-3] */
 	{ PCI_VDEVICE(MELLANOX, 0x1003), 0 },
 	/* MT27500 Family [ConnectX-3 Virtual Function] */
-	{ PCI_VDEVICE(MELLANOX, 0x1004), MLX4_VF },
+	{ PCI_VDEVICE(MELLANOX, 0x1004), MLX4_PCI_DEV_IS_VF },
 	{ PCI_VDEVICE(MELLANOX, 0x1005), 0 }, /* MT27510 Family */
 	{ PCI_VDEVICE(MELLANOX, 0x1006), 0 }, /* MT27511 Family */
 	{ PCI_VDEVICE(MELLANOX, 0x1007), 0 }, /* MT27520 Family */
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 2a0ff2c..8eb8f8a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -711,6 +711,10 @@ struct mlx4_steer {
 	struct list_head steer_entries[MLX4_NUM_STEERS];
 };
 
+enum {
+	MLX4_PCI_DEV_IS_VF              = 1 << 0,
+};
+
 struct mlx4_priv {
 	struct mlx4_dev		dev;
 
@@ -718,6 +722,8 @@ struct mlx4_priv {
 	struct list_head	ctx_list;
 	spinlock_t		ctx_lock;
 
+	int			pci_dev_data;
+
 	struct list_head        pgdir_list;
 	struct mutex            pgdir_mutex;
 
-- 
1.7.9.5
