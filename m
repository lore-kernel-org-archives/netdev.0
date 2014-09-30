From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/4] net/mlx4_core: New init and exit flow for mlx4_core
Date: Tue, 30 Sep 2014 12:03:48 +0300
Message-ID: <1412067830-30438-3-git-send-email-ogerlitz@mellanox.com>
References: <1412067830-30438-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Majd Dibbiny <majd@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:42463 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751346AbaI3JD7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2014 05:03:59 -0400
In-Reply-To: <1412067830-30438-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

In the new flow, we separate the pci initialization and teardown
from the initialization and teardown of the other resources.

__mlx4_init_one handles the pci resources initialization. It then
calls mlx4_load_one to initialize the remainder of the resources.

When removing a device, mlx4_remove_one is invoked. However, now
mlx4_remove_one calls mlx4_unload_one to free all the resources except the pci
resources. When mlx4_unload_one returns, mlx4_remove_one then frees the
pci resources.

The above separation will allow us to implement 'reset flow' in the future.
It will also enable more EQs for VFs and is a pre-step to the modern API to
enable/disable SRIOV.

Also added nvfs; an integer array of size MLX4_MAX_PORTS + 1; to the mlx4_dev
struct. This new field is used to avoid parsing the num_vfs module parameter
each time the mlx4_restart_one is called.

Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |  393 ++++++++++++++++-------------
 include/linux/mlx4/device.h               |    1 +
 2 files changed, 220 insertions(+), 174 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 4e9857b..f6c32a9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2259,116 +2259,18 @@ static void mlx4_free_ownership(struct mlx4_dev *dev)
 	iounmap(owner);
 }
 
-static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
+static int mlx4_load_one(struct pci_dev *pdev, int pci_dev_data,
+			 int total_vfs, int *nvfs, struct mlx4_priv *priv)
 {
-	struct mlx4_priv *priv;
 	struct mlx4_dev *dev;
+	unsigned sum = 0;
 	int err;
 	int port;
-	int nvfs[MLX4_MAX_PORTS + 1] = {0, 0, 0};
-	int prb_vf[MLX4_MAX_PORTS + 1] = {0, 0, 0};
-	const int param_map[MLX4_MAX_PORTS + 1][MLX4_MAX_PORTS + 1] = {
-		{2, 0, 0}, {0, 1, 2}, {0, 1, 2} };
-	unsigned total_vfs = 0;
-	int sriov_initialized = 0;
-	unsigned int i;
+	int i;
 	int existing_vfs = 0;
 
-	pr_info(DRV_NAME ": Initializing %s\n", pci_name(pdev));
-
-	err = pci_enable_device(pdev);
-	if (err) {
-		dev_err(&pdev->dev, "Cannot enable PCI device, aborting\n");
-		return err;
-	}
-
-	/* Due to requirement that all VFs and the PF are *guaranteed* 2 MACS
-	 * per port, we must limit the number of VFs to 63 (since their are
-	 * 128 MACs)
-	 */
-	for (i = 0; i < sizeof(nvfs)/sizeof(nvfs[0]) && i < num_vfs_argc;
-	     total_vfs += nvfs[param_map[num_vfs_argc - 1][i]], i++) {
-		nvfs[param_map[num_vfs_argc - 1][i]] = num_vfs[i];
-		if (nvfs[i] < 0) {
-			dev_err(&pdev->dev, "num_vfs module parameter cannot be negative\n");
-			return -EINVAL;
-		}
-	}
-	for (i = 0; i < sizeof(prb_vf)/sizeof(prb_vf[0]) && i < probe_vfs_argc;
-	     i++) {
-		prb_vf[param_map[probe_vfs_argc - 1][i]] = probe_vf[i];
-		if (prb_vf[i] < 0 || prb_vf[i] > nvfs[i]) {
-			dev_err(&pdev->dev, "probe_vf module parameter cannot be negative or greater than num_vfs\n");
-			return -EINVAL;
-		}
-	}
-	if (total_vfs >= MLX4_MAX_NUM_VF) {
-		dev_err(&pdev->dev,
-			"Requested more VF's (%d) than allowed (%d)\n",
-			total_vfs, MLX4_MAX_NUM_VF - 1);
-		return -EINVAL;
-	}
-
-	for (i = 0; i < MLX4_MAX_PORTS; i++) {
-		if (nvfs[i] + nvfs[2] >= MLX4_MAX_NUM_VF_P_PORT) {
-			dev_err(&pdev->dev,
-				"Requested more VF's (%d) for port (%d) than allowed (%d)\n",
-				nvfs[i] + nvfs[2], i + 1,
-				MLX4_MAX_NUM_VF_P_PORT - 1);
-			return -EINVAL;
-		}
-	}
-
-
-	/*
-	 * Check for BARs.
-	 */
-	if (!(pci_dev_data & MLX4_PCI_DEV_IS_VF) &&
-	    !(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
-		dev_err(&pdev->dev, "Missing DCS, aborting (driver_data: 0x%x, pci_resource_flags(pdev, 0):0x%lx)\n",
-			pci_dev_data, pci_resource_flags(pdev, 0));
-		err = -ENODEV;
-		goto err_disable_pdev;
-	}
-	if (!(pci_resource_flags(pdev, 2) & IORESOURCE_MEM)) {
-		dev_err(&pdev->dev, "Missing UAR, aborting\n");
-		err = -ENODEV;
-		goto err_disable_pdev;
-	}
-
-	err = pci_request_regions(pdev, DRV_NAME);
-	if (err) {
-		dev_err(&pdev->dev, "Couldn't get PCI resources, aborting\n");
-		goto err_disable_pdev;
-	}
-
-	pci_set_master(pdev);
+	dev = &priv->dev;
 
-	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
-	if (err) {
-		dev_warn(&pdev->dev, "Warning: couldn't set 64-bit PCI DMA mask\n");
-		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
-		if (err) {
-			dev_err(&pdev->dev, "Can't set PCI DMA mask, aborting\n");
-			goto err_release_regions;
-		}
-	}
-	err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
-	if (err) {
-		dev_warn(&pdev->dev, "Warning: couldn't set 64-bit consistent PCI DMA mask\n");
-		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
-		if (err) {
-			dev_err(&pdev->dev, "Can't set consistent PCI DMA mask, aborting\n");
-			goto err_release_regions;
-		}
-	}
-
-	/* Allow large DMA segments, up to the firmware limit of 1 GB */
-	dma_set_max_seg_size(&pdev->dev, 1024 * 1024 * 1024);
-
-	dev       = pci_get_drvdata(pdev);
-	priv      = mlx4_priv(dev);
-	dev->pdev = pdev;
 	INIT_LIST_HEAD(&priv->ctx_list);
 	spin_lock_init(&priv->ctx_lock);
 
@@ -2382,28 +2284,9 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
 
 	dev->rev_id = pdev->revision;
 	dev->numa_node = dev_to_node(&pdev->dev);
+
 	/* Detect if this device is a virtual function */
 	if (pci_dev_data & MLX4_PCI_DEV_IS_VF) {
-		/* When acting as pf, we normally skip vfs unless explicitly
-		 * requested to probe them. */
-		if (total_vfs) {
-			unsigned vfs_offset = 0;
-			for (i = 0; i < sizeof(nvfs)/sizeof(nvfs[0]) &&
-				     vfs_offset + nvfs[i] < extended_func_num(pdev);
-			     vfs_offset += nvfs[i], i++)
-				;
-			if (i == sizeof(nvfs)/sizeof(nvfs[0])) {
-				err = -ENODEV;
-				goto err_free_dev;
-			}
-			if ((extended_func_num(pdev) - vfs_offset)
-			    > prb_vf[i]) {
-				mlx4_warn(dev, "Skipping virtual function:%d\n",
-					  extended_func_num(pdev));
-				err = -ENODEV;
-				goto err_free_dev;
-			}
-		}
 		mlx4_warn(dev, "Detected virtual function - running in slave mode\n");
 		dev->flags |= MLX4_FLAG_SLAVE;
 	} else {
@@ -2413,11 +2296,10 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
 		err = mlx4_get_ownership(dev);
 		if (err) {
 			if (err < 0)
-				goto err_free_dev;
+				return err;
 			else {
 				mlx4_warn(dev, "Multiple PFs not yet supported - Skipping PF\n");
-				err = -EINVAL;
-				goto err_free_dev;
+				return -EINVAL;
 			}
 		}
 
@@ -2429,7 +2311,8 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
 				GFP_KERNEL);
 			if (NULL == dev->dev_vfs) {
 				mlx4_err(dev, "Failed to allocate memory for VFs\n");
-				err = 0;
+				err = -ENOMEM;
+				goto err_free_own;
 			} else {
 				atomic_inc(&pf_loading);
 				existing_vfs = pci_num_vf(pdev);
@@ -2445,13 +2328,11 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
 					mlx4_err(dev, "Failed to enable SR-IOV, continuing without SR-IOV (err = %d)\n",
 						 err);
 					atomic_dec(&pf_loading);
-					err = 0;
 				} else {
 					mlx4_warn(dev, "Running in master mode\n");
 					dev->flags |= MLX4_FLAG_SRIOV |
 						MLX4_FLAG_MASTER;
 					dev->num_vfs = total_vfs;
-					sriov_initialized = 1;
 				}
 			}
 		}
@@ -2467,7 +2348,7 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
 		err = mlx4_reset(dev);
 		if (err) {
 			mlx4_err(dev, "Failed to reset HCA, aborting\n");
-			goto err_rel_own;
+			goto err_sriov;
 		}
 	}
 
@@ -2517,34 +2398,46 @@ slave_start:
 	/* In master functions, the communication channel must be initialized
 	 * after obtaining its address from fw */
 	if (mlx4_is_master(dev)) {
-		unsigned sum = 0;
-		err = mlx4_multi_func_init(dev);
-		if (err) {
-			mlx4_err(dev, "Failed to init master mfunc interface, aborting\n");
+		int ib_ports = 0;
+
+		mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_IB)
+			ib_ports++;
+
+		if (ib_ports &&
+		    (num_vfs_argc > 1 || probe_vfs_argc > 1)) {
+			mlx4_err(dev,
+				 "Invalid syntax of num_vfs/probe_vfs with IB port - single port VFs syntax is only supported when all ports are configured as ethernet\n");
+			err = -EINVAL;
+			goto err_close;
+		}
+		if (dev->caps.num_ports < 2 &&
+		    num_vfs_argc > 1) {
+			err = -EINVAL;
+			mlx4_err(dev,
+				 "Error: Trying to configure VFs on port 2, but HCA has only %d physical ports\n",
+				 dev->caps.num_ports);
 			goto err_close;
 		}
-		if (sriov_initialized) {
-			int ib_ports = 0;
-			mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_IB)
-				ib_ports++;
+		memcpy(dev->nvfs, nvfs, sizeof(dev->nvfs));
 
-			if (ib_ports &&
-			    (num_vfs_argc > 1 || probe_vfs_argc > 1)) {
-				mlx4_err(dev,
-					 "Invalid syntax of num_vfs/probe_vfs with IB port - single port VFs syntax is only supported when all ports are configured as ethernet\n");
-				err = -EINVAL;
-				goto err_master_mfunc;
-			}
-			for (i = 0; i < sizeof(nvfs)/sizeof(nvfs[0]); i++) {
-				unsigned j;
-				for (j = 0; j < nvfs[i]; ++sum, ++j) {
-					dev->dev_vfs[sum].min_port =
-						i < 2 ? i + 1 : 1;
-					dev->dev_vfs[sum].n_ports = i < 2 ? 1 :
-						dev->caps.num_ports;
-				}
+		for (i = 0; i < sizeof(dev->nvfs)/sizeof(dev->nvfs[0]); i++) {
+			unsigned j;
+
+			for (j = 0; j < dev->nvfs[i]; ++sum, ++j) {
+				dev->dev_vfs[sum].min_port = i < 2 ? i + 1 : 1;
+				dev->dev_vfs[sum].n_ports = i < 2 ? 1 :
+					dev->caps.num_ports;
 			}
 		}
+
+		/* In master functions, the communication channel
+		 * must be initialized after obtaining its address from fw
+		 */
+		err = mlx4_multi_func_init(dev);
+		if (err) {
+			mlx4_err(dev, "Failed to init master mfunc interface, aborting.\n");
+			goto err_close;
+		}
 	}
 
 	err = mlx4_alloc_eq_table(dev);
@@ -2565,7 +2458,7 @@ slave_start:
 	if (!mlx4_is_slave(dev)) {
 		err = mlx4_init_steering(dev);
 		if (err)
-			goto err_free_eq;
+			goto err_disable_msix;
 	}
 
 	err = mlx4_setup_hca(dev);
@@ -2625,6 +2518,10 @@ err_steer:
 	if (!mlx4_is_slave(dev))
 		mlx4_clear_steering(dev);
 
+err_disable_msix:
+	if (dev->flags & MLX4_FLAG_MSI_X)
+		pci_disable_msix(pdev);
+
 err_free_eq:
 	mlx4_free_eq_table(dev);
 
@@ -2641,9 +2538,6 @@ err_master_mfunc:
 	}
 
 err_close:
-	if (dev->flags & MLX4_FLAG_MSI_X)
-		pci_disable_msix(pdev);
-
 	mlx4_close_hca(dev);
 
 err_mfunc:
@@ -2657,17 +2551,151 @@ err_sriov:
 	if (dev->flags & MLX4_FLAG_SRIOV && !existing_vfs)
 		pci_disable_sriov(pdev);
 
-err_rel_own:
-	if (!mlx4_is_slave(dev))
-		mlx4_free_ownership(dev);
-
 	if (mlx4_is_master(dev) && dev->num_vfs)
 		atomic_dec(&pf_loading);
 
 	kfree(priv->dev.dev_vfs);
 
-err_free_dev:
-	kfree(priv);
+err_free_own:
+	if (!mlx4_is_slave(dev))
+		mlx4_free_ownership(dev);
+
+	return err;
+}
+
+static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data,
+			   struct mlx4_priv *priv)
+{
+	int err;
+	int nvfs[MLX4_MAX_PORTS + 1] = {0, 0, 0};
+	int prb_vf[MLX4_MAX_PORTS + 1] = {0, 0, 0};
+	const int param_map[MLX4_MAX_PORTS + 1][MLX4_MAX_PORTS + 1] = {
+		{2, 0, 0}, {0, 1, 2}, {0, 1, 2} };
+	unsigned total_vfs = 0;
+	unsigned int i;
+
+	pr_info(DRV_NAME ": Initializing %s\n", pci_name(pdev));
+
+	err = pci_enable_device(pdev);
+	if (err) {
+		dev_err(&pdev->dev, "Cannot enable PCI device, aborting\n");
+		return err;
+	}
+
+	/* Due to requirement that all VFs and the PF are *guaranteed* 2 MACS
+	 * per port, we must limit the number of VFs to 63 (since their are
+	 * 128 MACs)
+	 */
+	for (i = 0; i < sizeof(nvfs)/sizeof(nvfs[0]) && i < num_vfs_argc;
+	     total_vfs += nvfs[param_map[num_vfs_argc - 1][i]], i++) {
+		nvfs[param_map[num_vfs_argc - 1][i]] = num_vfs[i];
+		if (nvfs[i] < 0) {
+			dev_err(&pdev->dev, "num_vfs module parameter cannot be negative\n");
+			err = -EINVAL;
+			goto err_disable_pdev;
+		}
+	}
+	for (i = 0; i < sizeof(prb_vf)/sizeof(prb_vf[0]) && i < probe_vfs_argc;
+	     i++) {
+		prb_vf[param_map[probe_vfs_argc - 1][i]] = probe_vf[i];
+		if (prb_vf[i] < 0 || prb_vf[i] > nvfs[i]) {
+			dev_err(&pdev->dev, "probe_vf module parameter cannot be negative or greater than num_vfs\n");
+			err = -EINVAL;
+			goto err_disable_pdev;
+		}
+	}
+	if (total_vfs >= MLX4_MAX_NUM_VF) {
+		dev_err(&pdev->dev,
+			"Requested more VF's (%d) than allowed (%d)\n",
+			total_vfs, MLX4_MAX_NUM_VF - 1);
+		err = -EINVAL;
+		goto err_disable_pdev;
+	}
+
+	for (i = 0; i < MLX4_MAX_PORTS; i++) {
+		if (nvfs[i] + nvfs[2] >= MLX4_MAX_NUM_VF_P_PORT) {
+			dev_err(&pdev->dev,
+				"Requested more VF's (%d) for port (%d) than allowed (%d)\n",
+				nvfs[i] + nvfs[2], i + 1,
+				MLX4_MAX_NUM_VF_P_PORT - 1);
+			err = -EINVAL;
+			goto err_disable_pdev;
+		}
+	}
+
+	/* Check for BARs. */
+	if (!(pci_dev_data & MLX4_PCI_DEV_IS_VF) &&
+	    !(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
+		dev_err(&pdev->dev, "Missing DCS, aborting (driver_data: 0x%x, pci_resource_flags(pdev, 0):0x%lx)\n",
+			pci_dev_data, pci_resource_flags(pdev, 0));
+		err = -ENODEV;
+		goto err_disable_pdev;
+	}
+	if (!(pci_resource_flags(pdev, 2) & IORESOURCE_MEM)) {
+		dev_err(&pdev->dev, "Missing UAR, aborting\n");
+		err = -ENODEV;
+		goto err_disable_pdev;
+	}
+
+	err = pci_request_regions(pdev, DRV_NAME);
+	if (err) {
+		dev_err(&pdev->dev, "Couldn't get PCI resources, aborting\n");
+		goto err_disable_pdev;
+	}
+
+	pci_set_master(pdev);
+
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
+	if (err) {
+		dev_warn(&pdev->dev, "Warning: couldn't set 64-bit PCI DMA mask\n");
+		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
+		if (err) {
+			dev_err(&pdev->dev, "Can't set PCI DMA mask, aborting\n");
+			goto err_release_regions;
+		}
+	}
+	err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
+	if (err) {
+		dev_warn(&pdev->dev, "Warning: couldn't set 64-bit consistent PCI DMA mask\n");
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
+		if (err) {
+			dev_err(&pdev->dev, "Can't set consistent PCI DMA mask, aborting\n");
+			goto err_release_regions;
+		}
+	}
+
+	/* Allow large DMA segments, up to the firmware limit of 1 GB */
+	dma_set_max_seg_size(&pdev->dev, 1024 * 1024 * 1024);
+	/* Detect if this device is a virtual function */
+	if (pci_dev_data & MLX4_PCI_DEV_IS_VF) {
+		/* When acting as pf, we normally skip vfs unless explicitly
+		 * requested to probe them.
+		 */
+		if (total_vfs) {
+			unsigned vfs_offset = 0;
+
+			for (i = 0; i < sizeof(nvfs)/sizeof(nvfs[0]) &&
+			     vfs_offset + nvfs[i] < extended_func_num(pdev);
+			     vfs_offset += nvfs[i], i++)
+				;
+			if (i == sizeof(nvfs)/sizeof(nvfs[0])) {
+				err = -ENODEV;
+				goto err_release_regions;
+			}
+			if ((extended_func_num(pdev) - vfs_offset)
+			    > prb_vf[i]) {
+				dev_warn(&pdev->dev, "Skipping virtual function:%d\n",
+					 extended_func_num(pdev));
+				err = -ENODEV;
+				goto err_release_regions;
+			}
+		}
+	}
+
+	err = mlx4_load_one(pdev, pci_dev_data, total_vfs, nvfs, priv);
+	if (err)
+		goto err_release_regions;
+	return 0;
 
 err_release_regions:
 	pci_release_regions(pdev);
@@ -2682,6 +2710,7 @@ static int mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 {
 	struct mlx4_priv *priv;
 	struct mlx4_dev *dev;
+	int ret;
 
 	printk_once(KERN_INFO "%s", mlx4_version);
 
@@ -2690,13 +2719,18 @@ static int mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 		return -ENOMEM;
 
 	dev       = &priv->dev;
+	dev->pdev = pdev;
 	pci_set_drvdata(pdev, dev);
 	priv->pci_dev_data = id->driver_data;
 
-	return __mlx4_init_one(pdev, id->driver_data);
+	ret =  __mlx4_init_one(pdev, id->driver_data, priv);
+	if (ret)
+		kfree(priv);
+
+	return ret;
 }
 
-static void __mlx4_remove_one(struct pci_dev *pdev)
+static void mlx4_unload_one(struct pci_dev *pdev)
 {
 	struct mlx4_dev  *dev  = pci_get_drvdata(pdev);
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -2775,8 +2809,6 @@ static void __mlx4_remove_one(struct pci_dev *pdev)
 	kfree(dev->caps.qp1_proxy);
 	kfree(dev->dev_vfs);
 
-	pci_release_regions(pdev);
-	pci_disable_device(pdev);
 	memset(priv, 0, sizeof(*priv));
 	priv->pci_dev_data = pci_dev_data;
 	priv->removed = 1;
@@ -2787,7 +2819,9 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 	struct mlx4_dev  *dev  = pci_get_drvdata(pdev);
 	struct mlx4_priv *priv = mlx4_priv(dev);
 
-	__mlx4_remove_one(pdev);
+	mlx4_unload_one(pdev);
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
 	kfree(priv);
 	pci_set_drvdata(pdev, NULL);
 }
@@ -2796,11 +2830,22 @@ int mlx4_restart_one(struct pci_dev *pdev)
 {
 	struct mlx4_dev	 *dev  = pci_get_drvdata(pdev);
 	struct mlx4_priv *priv = mlx4_priv(dev);
-	int		  pci_dev_data;
+	int nvfs[MLX4_MAX_PORTS + 1] = {0, 0, 0};
+	int pci_dev_data, err, total_vfs;
 
 	pci_dev_data = priv->pci_dev_data;
-	__mlx4_remove_one(pdev);
-	return __mlx4_init_one(pdev, pci_dev_data);
+	total_vfs = dev->num_vfs;
+	memcpy(nvfs, dev->nvfs, sizeof(dev->nvfs));
+
+	mlx4_unload_one(pdev);
+	err = mlx4_load_one(pdev, pci_dev_data, total_vfs, nvfs, priv);
+	if (err) {
+		mlx4_err(dev, "%s: ERROR: mlx4_load_one failed, pci_name=%s, err=%d\n",
+			 __func__, pci_name(pdev), err);
+		return err;
+	}
+
+	return err;
 }
 
 static const struct pci_device_id mlx4_pci_table[] = {
@@ -2854,7 +2899,7 @@ MODULE_DEVICE_TABLE(pci, mlx4_pci_table);
 static pci_ers_result_t mlx4_pci_err_detected(struct pci_dev *pdev,
 					      pci_channel_state_t state)
 {
-	__mlx4_remove_one(pdev);
+	mlx4_unload_one(pdev);
 
 	return state == pci_channel_io_perm_failure ?
 		PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_NEED_RESET;
@@ -2866,7 +2911,7 @@ static pci_ers_result_t mlx4_pci_slot_reset(struct pci_dev *pdev)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	int               ret;
 
-	ret = __mlx4_init_one(pdev, priv->pci_dev_data);
+	ret = __mlx4_init_one(pdev, priv->pci_dev_data, priv);
 
 	return ret ? PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_RECOVERED;
 }
@@ -2880,7 +2925,7 @@ static struct pci_driver mlx4_driver = {
 	.name		= DRV_NAME,
 	.id_table	= mlx4_pci_table,
 	.probe		= mlx4_init_one,
-	.shutdown	= __mlx4_remove_one,
+	.shutdown	= mlx4_unload_one,
 	.remove		= mlx4_remove_one,
 	.err_handler    = &mlx4_err_handler,
 };
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 03b5608..b2f8ab9 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -707,6 +707,7 @@ struct mlx4_dev {
 	u64			regid_promisc_array[MLX4_MAX_PORTS + 1];
 	u64			regid_allmulti_array[MLX4_MAX_PORTS + 1];
 	struct mlx4_vf_dev     *dev_vfs;
+	int                     nvfs[MLX4_MAX_PORTS + 1];
 };
 
 struct mlx4_eqe {
-- 
1.7.1
