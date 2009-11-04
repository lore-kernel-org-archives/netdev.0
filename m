From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH 16/25] mlx4_core: boot sriov
Date: Wed, 04 Nov 2009 17:31:41 +0200
Message-ID: <4AF19E5D.1060806@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org,
	yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add virtual function device ids.
Establish comm channel when sriov is enabled, and boot vfs through it.
Each slave gets one msi-X for completions, the master also gets one for
async events.

Signed-off-by: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Signed-off-by: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/net/mlx4/eq.c   |   21 ++--
 drivers/net/mlx4/main.c |  315 +++++++++++++++++++++++++++++++++++++----------
 2 files changed, 260 insertions(+), 76 deletions(-)

diff --git a/drivers/net/mlx4/eq.c b/drivers/net/mlx4/eq.c
index b0c8022..29b2cd6 100644
--- a/drivers/net/mlx4/eq.c
+++ b/drivers/net/mlx4/eq.c
@@ -770,16 +770,18 @@ int mlx4_init_eq_table(struct mlx4_dev *dev)
 			goto err_out_unmap;
 	}
 
-	err = mlx4_create_eq(dev, MLX4_NUM_ASYNC_EQE + MLX4_NUM_SPARE_EQE,
-			     (dev->flags & MLX4_FLAG_MSI_X) ? dev->caps.num_comp_vectors : 0,
-			     &priv->eq_table.eq[dev->caps.num_comp_vectors]);
-	if (err)
-		goto err_out_comp;
+	if (!mlx4_is_slave(dev)) {
+		err = mlx4_create_eq(dev, MLX4_NUM_ASYNC_EQE + MLX4_NUM_SPARE_EQE,
+				     (dev->flags & MLX4_FLAG_MSI_X) ? dev->caps.num_comp_vectors : 0,
+				     &priv->eq_table.eq[dev->caps.num_comp_vectors]);
+		if (err)
+			goto err_out_comp;
+	}
 
 	if (dev->flags & MLX4_FLAG_MSI_X) {
 		const char *eq_name;
 
-		for (i = 0; i < dev->caps.num_comp_vectors + 1; ++i) {
+		for (i = 0; i < dev->caps.num_comp_vectors + !(mlx4_is_slave(dev)); ++i) {
 			if (i < dev->caps.num_comp_vectors) {
 				snprintf(priv->eq_table.irq_names +
 					 i * MLX4_IRQNAME_SIZE,
@@ -825,13 +827,14 @@ int mlx4_init_eq_table(struct mlx4_dev *dev)
 				   priv->eq_table.eq[dev->caps.num_comp_vectors].eqn, err);
 	}
 
-	for (i = 0; i < dev->caps.num_comp_vectors + 1; ++i)
+	for (i = 0; i < dev->caps.num_comp_vectors + !(mlx4_is_slave(dev)); ++i)
 		eq_set_ci(&priv->eq_table.eq[i], 1);
 
 	return 0;
 
 err_out_async:
-	mlx4_free_eq(dev, &priv->eq_table.eq[dev->caps.num_comp_vectors]);
+	if (!mlx4_is_slave(dev))
+		mlx4_free_eq(dev, &priv->eq_table.eq[dev->caps.num_comp_vectors]);
 
 err_out_comp:
 	i = dev->caps.num_comp_vectors;
@@ -866,7 +869,7 @@ void mlx4_cleanup_eq_table(struct mlx4_dev *dev)
 
 	mlx4_free_irqs(dev);
 
-	for (i = 0; i < dev->caps.num_comp_vectors + 1; ++i)
+	for (i = 0; i < dev->caps.num_comp_vectors + !mlx4_is_slave(dev); ++i)
 		mlx4_free_eq(dev, &priv->eq_table.eq[i]);
 
 	if (!mlx4_is_slave(dev))
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 2852445..c2b6b35 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -73,6 +73,18 @@ MODULE_PARM_DESC(msi_x, "attempt to use MSI-X if nonzero");
 
 #endif /* CONFIG_PCI_MSI */
 
+#ifdef CONFIG_PCI_IOV
+
+static int sr_iov;
+module_param(sr_iov, int, 0444);
+MODULE_PARM_DESC(sr_iov, "enable #sr_iov functions if sr_iov > 0");
+
+static int probe_vf;
+module_param(probe_vf, int, 0444);
+MODULE_PARM_DESC(probe_vf, "number of vfs to probe by pf driver (sr_iov > 0)");
+
+#endif /* CONFIG_PCI_IOV */
+
 static char mlx4_version[] __devinitdata =
 	DRV_NAME ": Mellanox ConnectX core driver v"
 	DRV_VERSION " (" DRV_RELDATE ")\n";
@@ -779,12 +791,56 @@ static void mlx4_free_icms(struct mlx4_dev *dev)
 	mlx4_free_icm(dev, priv->fw.aux_icm, 0);
 }
 
+static void mlx4_slave_exit(struct mlx4_dev *dev)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+
+	down(&priv->cmd.poll_sem);
+	if (mlx4_comm_cmd(dev, MLX4_COMM_CMD_RESET, 0, MLX4_COMM_TIME))
+		mlx4_warn(dev, "Failed to close slave function.\n");
+	up(&priv->cmd.poll_sem);
+}
+
 static void mlx4_close_hca(struct mlx4_dev *dev)
 {
-	mlx4_CLOSE_HCA(dev, 0);
-	mlx4_free_icms(dev);
-	mlx4_UNMAP_FA(dev);
-	mlx4_free_icm(dev, mlx4_priv(dev)->fw.fw_icm, 0);
+	if (mlx4_is_slave(dev))
+		mlx4_slave_exit(dev);
+	else {
+		mlx4_CLOSE_HCA(dev, 0);
+		mlx4_free_icms(dev);
+		mlx4_UNMAP_FA(dev);
+		mlx4_free_icm(dev, mlx4_priv(dev)->fw.fw_icm, 0);
+	}
+}
+
+static int mlx4_init_slave(struct mlx4_dev *dev)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	u64 dma = (u64) priv->mfunc.vhcr_dma;
+
+	down(&priv->cmd.poll_sem);
+	mlx4_warn(dev, "Sending reset\n");
+	if (mlx4_comm_cmd(dev, MLX4_COMM_CMD_RESET, 0, MLX4_COMM_TIME))
+		goto err;
+	mlx4_warn(dev, "Sending vhcr0\n");
+	if (mlx4_comm_cmd(dev, MLX4_COMM_CMD_VHCR0, dma >> 48,
+						    MLX4_COMM_TIME))
+		goto err;
+	if (mlx4_comm_cmd(dev, MLX4_COMM_CMD_VHCR1, dma >> 32,
+						    MLX4_COMM_TIME))
+		goto err;
+	if (mlx4_comm_cmd(dev, MLX4_COMM_CMD_VHCR2, dma >> 16,
+						    MLX4_COMM_TIME))
+		goto err;
+	if (mlx4_comm_cmd(dev, MLX4_COMM_CMD_VHCR_EN, dma, MLX4_COMM_TIME))
+		goto err;
+	up(&priv->cmd.poll_sem);
+	return 0;
+
+err:
+	mlx4_comm_cmd(dev, MLX4_COMM_CMD_RESET, 0, 0);
+	up(&priv->cmd.poll_sem);
+	return -EIO;
 }
 
 static int mlx4_init_hca(struct mlx4_dev *dev)
@@ -798,51 +854,67 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 	u64 icm_size;
 	int err;
 
-	err = mlx4_QUERY_FW(dev);
-	if (err) {
-		if (err == -EACCES)
-			mlx4_info(dev, "non-primary physical function, skipping.\n");
-		else
-			mlx4_err(dev, "QUERY_FW command failed, aborting.\n");
-		return err;
-	}
+	if (!mlx4_is_slave(dev)) {
+		err = mlx4_QUERY_FW(dev); /* TODO: verify FW version in slaves as well */
+		if (err) {
+			if (err == -EACCES)
+				mlx4_info(dev, "non-primary physical function, skipping.\n");
+			else {
+				mlx4_err(dev, "QUERY_FW command failed, aborting.\n");
+				if (mlx4_is_master(dev))
+					mlx4_err(dev, "Are you using SRIOV-enabled firmware?\n");
+			}
+			return err;
+		}
 
-	err = mlx4_load_fw(dev);
-	if (err) {
-		mlx4_err(dev, "Failed to start FW, aborting.\n");
-		return err;
-	}
+		err = mlx4_load_fw(dev);
+		if (err) {
+			mlx4_err(dev, "Failed to start FW, aborting.\n");
+			return err;
+		}
 
-	mlx4_cfg.log_pg_sz_m = 1;
-	mlx4_cfg.log_pg_sz = 0;
-	err = mlx4_MOD_STAT_CFG(dev, &mlx4_cfg);
-	if (err)
-		mlx4_warn(dev, "Failed to override log_pg_sz parameter\n");
+		mlx4_cfg.log_pg_sz_m = 1;
+		mlx4_cfg.log_pg_sz = 0;
+		err = mlx4_MOD_STAT_CFG(dev, &mlx4_cfg);
+		if (err)
+			mlx4_warn(dev, "Failed to override log_pg_sz parameter\n");
 
-	err = mlx4_dev_cap(dev, &dev_cap);
-	if (err) {
-		mlx4_err(dev, "QUERY_DEV_CAP command failed, aborting.\n");
-		goto err_stop_fw;
-	}
+		err = mlx4_dev_cap(dev, &dev_cap);
+		if (err) {
+			mlx4_err(dev, "QUERY_DEV_CAP command failed, aborting.\n");
+			goto err_stop_fw;
+		}
 
-	profile = default_profile;
+		profile = default_profile;
+		icm_size = mlx4_make_profile(dev, &profile, &dev_cap, &init_hca);
+		if ((long long) icm_size < 0) {
+			err = icm_size;
+			goto err_stop_fw;
+		}
 
-	icm_size = mlx4_make_profile(dev, &profile, &dev_cap, &init_hca);
-	if ((long long) icm_size < 0) {
-		err = icm_size;
-		goto err_stop_fw;
-	}
+		init_hca.log_uar_sz = ilog2(dev->caps.num_uars);
 
-	init_hca.log_uar_sz = ilog2(dev->caps.num_uars);
+		err = mlx4_init_icm(dev, &dev_cap, &init_hca, icm_size);
+		if (err)
+			goto err_stop_fw;
 
-	err = mlx4_init_icm(dev, &dev_cap, &init_hca, icm_size);
-	if (err)
-		goto err_stop_fw;
+		err = mlx4_INIT_HCA(dev, &init_hca);
+		if (err) {
+			mlx4_err(dev, "INIT_HCA command failed, aborting.\n");
+			goto err_free_icm;
+		}
+	} else {
+		err = mlx4_init_slave(dev);
+		if (err) {
+			mlx4_err(dev, "Failed to initialize slave\n");
+			return err;
+		}
 
-	err = mlx4_INIT_HCA(dev, &init_hca);
-	if (err) {
-		mlx4_err(dev, "INIT_HCA command failed, aborting.\n");
-		goto err_free_icm;
+		err = mlx4_slave_cap(dev);
+		if (err) {
+			mlx4_err(dev, "Failed to obtain slave caps\n");
+			goto err_close;
+		}
 	}
 
 	err = mlx4_QUERY_ADAPTER(dev, &adapter);
@@ -857,15 +929,17 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 	return 0;
 
 err_close:
-	mlx4_CLOSE_HCA(dev, 0);
+	mlx4_close_hca(dev);
 
 err_free_icm:
-	mlx4_free_icms(dev);
+	if (!mlx4_is_slave(dev))
+		mlx4_free_icms(dev);
 
 err_stop_fw:
-	mlx4_UNMAP_FA(dev);
-	mlx4_free_icm(dev, priv->fw.fw_icm, 0);
-
+	if (!mlx4_is_slave(dev)) {
+		mlx4_UNMAP_FA(dev);
+		mlx4_free_icm(dev, priv->fw.fw_icm, 0);
+	}
 	return err;
 }
 
@@ -1019,8 +1093,13 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 	int i;
 
 	if (msi_x) {
-		nreq = min_t(int, dev->caps.num_eqs - dev->caps.reserved_eqs,
-			     num_possible_cpus() + 1);
+		/* The master only uses en event EQ,
+		 * Each one of the slaves have 1 completion eq */
+		if (mlx4_is_mfunc(dev))
+			nreq = 1;
+		else
+			nreq = min_t(int, dev->caps.num_eqs - dev->caps.reserved_eqs,
+				     num_possible_cpus() + 1);
 		entries = kcalloc(nreq, sizeof *entries, GFP_KERNEL);
 		if (!entries)
 			goto no_msi;
@@ -1029,8 +1108,10 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 			entries[i].entry = i;
 
 	retry:
+		printk("Requesting %d MSIX vectors\n", nreq);
 		err = pci_enable_msix(dev->pdev, entries, nreq);
 		if (err) {
+			printk("pci_enable_msix failed\n");
 			/* Try again if at least 2 vectors are available */
 			if (err > 1) {
 				mlx4_info(dev, "Requested %d vectors, "
@@ -1043,7 +1124,7 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 			goto no_msi;
 		}
 
-		dev->caps.num_comp_vectors = nreq - 1;
+		dev->caps.num_comp_vectors = nreq - !mlx4_is_slave(dev);
 		for (i = 0; i < nreq; ++i)
 			priv->eq_table.eq[i].irq = entries[i].vector;
 
@@ -1054,7 +1135,9 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 	}
 
 no_msi:
-	dev->caps.num_comp_vectors = 1;
+	/* CX1: no completion vectors needed for the master since it doesn't
+	 * have interfaces */
+	dev->caps.num_comp_vectors = mlx4_is_master(dev) ? 0 : 1;
 
 	for (i = 0; i < 2; ++i)
 		priv->eq_table.eq[i].irq = dev->pdev->irq;
@@ -1111,10 +1194,9 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	}
 
 	/*
-	 * Check for BARs.  We expect 0: 1MB
+	 * Check for BARs.
 	 */
-	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM) ||
-	    pci_resource_len(pdev, 0) != 1 << 20) {
+	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
 		dev_err(&pdev->dev, "Missing DCS, aborting.\n");
 		err = -ENODEV;
 		goto err_disable_pdev;
@@ -1172,34 +1254,98 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	INIT_LIST_HEAD(&priv->pgdir_list);
 	mutex_init(&priv->pgdir_mutex);
 
-	/*
-	 * Now reset the HCA before we touch the PCI capabilities or
-	 * attempt a firmware command, since a boot ROM may have left
-	 * the HCA in an undefined state.
-	 */
-	err = mlx4_reset(dev);
-	if (err) {
-		mlx4_err(dev, "Failed to reset HCA, aborting.\n");
-		goto err_free_dev;
+	/* Detect if this device is a virtual function */
+	switch (id->device) {
+	case 0x6341:
+	case 0x634b:
+	case 0x6733:
+	case 0x673d:
+	case 0x6369:
+	case 0x6751:
+	case 0x6765:
+#ifdef CONFIG_PCI_IOV
+		/* When acting as pf, we normally skip vfs unless explicitly
+		 * requested to probe them.
+		 * TODO: add ARI support */
+		if (sr_iov && PCI_FUNC(pdev->devfn) > probe_vf) {
+			mlx4_warn(dev, "Skipping virtual function:%d\n",
+						PCI_FUNC(pdev->devfn));
+			err = -ENODEV;
+			goto err_free_dev;
+		}
+#endif /* CONFIG_PCI_IOV */
+		mlx4_warn(dev, "Detected virtual function - running in slave mode\n");
+		dev->flags |= MLX4_FLAG_SLAVE;
+		break;
+	default:
+		;
+	}
+
+	/* We reset the device and enable SRIOV only for physical devices */
+	if (!mlx4_is_slave(dev)) {
+		/*
+		 * Now reset the HCA before we touch the PCI capabilities or
+		 * attempt a firmware command, since a boot ROM may have left
+		 * the HCA in an undefined state.
+		 */
+		err = mlx4_reset(dev);
+		if (err) {
+			mlx4_err(dev, "Failed to reset HCA, aborting.\n");
+			goto err_free_dev;
+		}
+#ifdef CONFIG_PCI_IOV
+		if (sr_iov) {
+			mlx4_warn(dev, "Enabling sriov with:%d vfs\n", sr_iov);
+			if (pci_enable_sriov(pdev, sr_iov)) {
+				mlx4_err(dev, "Failed to enable sriov, aborting.\n");
+				goto err_free_dev;
+			}
+			mlx4_warn(dev, "Running in master mode\n");
+			dev->flags |= MLX4_FLAG_SRIOV | MLX4_FLAG_MASTER;
+			dev->num_slaves = sr_iov;
+		}
+#endif /* CONFIG_PCI_IOV */
 	}
 
 	if (mlx4_cmd_init(dev)) {
 		mlx4_err(dev, "Failed to init command interface, aborting.\n");
-		goto err_free_dev;
+		goto err_sriov;
+	}
+
+	/* In slave functions, the communication channel must be initialized before
+	 * posting commands */
+	if (mlx4_is_slave(dev)) {
+		if (mlx4_multi_func_init(dev)) {
+			mlx4_err(dev, "Failed to init slave mfunc interface, aborting.\n");
+			goto err_cmd;
+		}
 	}
 
 	err = mlx4_init_hca(dev);
 	if (err)
 		goto err_cmd;
 
+	/* In master functions, the communication channel must be initialized after obtaining
+	 * its address from fw */
+	if (mlx4_is_master(dev)) {
+		if (mlx4_multi_func_init(dev)) {
+			mlx4_err(dev, "Failed to init master mfunc interface, aborting.\n");
+			goto err_close;
+		}
+	}
+
 	err = mlx4_alloc_eq_table(dev);
 	if (err)
 		goto err_close;
 
 	mlx4_enable_msi_x(dev);
+	if (mlx4_is_slave(dev) && !(dev->flags & MLX4_FLAG_MSI_X)) {
+		mlx4_err(dev, "INTx is not supported in slave mode, aborting.\n");
+		goto err_free_eq;
+	}
 
 	err = mlx4_setup_hca(dev);
-	if (err == -EBUSY && (dev->flags & MLX4_FLAG_MSI_X)) {
+	if (err == -EBUSY && (dev->flags & MLX4_FLAG_MSI_X) && !mlx4_is_slave(dev)) {
 		dev->flags &= ~MLX4_FLAG_MSI_X;
 		pci_disable_msix(pdev);
 		err = mlx4_setup_hca(dev);
@@ -1223,6 +1369,12 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	pci_set_drvdata(pdev, dev);
 
+	/* Start serving comm channel:
+	 * - In master function: poll for commands
+	 * - in slave functions: poll for events
+	 * TODO - enable comm channel interrupts */
+	if (mlx4_is_master(dev) || mlx4_is_slave(dev))
+		queue_delayed_work(priv->mfunc.comm_wq, &priv->mfunc.comm_work, 0);
 	return 0;
 
 err_port:
@@ -1233,7 +1385,8 @@ err_port:
 	mlx4_cleanup_qp_table(dev);
 	mlx4_cleanup_srq_table(dev);
 	mlx4_cleanup_cq_table(dev);
-	mlx4_cmd_use_polling(dev);
+	if (!mlx4_is_master(dev) && !mlx4_is_slave(dev))
+		mlx4_cmd_use_polling(dev);
 	mlx4_cleanup_eq_table(dev);
 	mlx4_cleanup_mr_table(dev);
 	mlx4_cleanup_pd_table(dev);
@@ -1251,6 +1404,14 @@ err_close:
 err_cmd:
 	mlx4_cmd_cleanup(dev);
 
+err_sriov:
+	if (mlx4_is_master(dev) || mlx4_is_slave(dev))
+		mlx4_multi_func_cleanup(dev);
+#ifdef CONFIG_PCI_IOV
+	if (dev->flags & MLX4_FLAG_SRIOV)
+		pci_disable_sriov(pdev);
+#endif /* CONFIG_PCI_IOV */
+
 err_free_dev:
 	kfree(priv);
 
@@ -1283,19 +1444,24 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 	int p;
 
 	if (dev) {
+		/* Stop serving commands and events over comm channel */
+		if (mlx4_is_master(dev) || mlx4_is_slave(dev))
+			cancel_delayed_work_sync(&priv->mfunc.comm_work);
 		mlx4_stop_sense(dev);
 		mlx4_unregister_device(dev);
 
 		for (p = 1; p <= dev->caps.num_ports; p++) {
 			mlx4_cleanup_port_info(&priv->port[p]);
-			mlx4_CLOSE_PORT(dev, p);
+			if (!mlx4_is_slave(dev))
+				mlx4_CLOSE_PORT(dev, p);
 		}
 
 		mlx4_cleanup_mcg_table(dev);
 		mlx4_cleanup_qp_table(dev);
 		mlx4_cleanup_srq_table(dev);
 		mlx4_cleanup_cq_table(dev);
-		mlx4_cmd_use_polling(dev);
+		if (!mlx4_is_master(dev) && !mlx4_is_slave(dev))
+			mlx4_cmd_use_polling(dev);
 		mlx4_cleanup_eq_table(dev);
 		mlx4_cleanup_mr_table(dev);
 		mlx4_cleanup_pd_table(dev);
@@ -1303,10 +1469,18 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 		mlx4_cleanup_uar_table(dev);
 		mlx4_free_eq_table(dev);
 		mlx4_close_hca(dev);
+		if (mlx4_is_master(dev) || mlx4_is_slave(dev))
+			mlx4_multi_func_cleanup(dev);
 		mlx4_cmd_cleanup(dev);
 
 		if (dev->flags & MLX4_FLAG_MSI_X)
 			pci_disable_msix(pdev);
+#ifdef CONFIG_PCI_IOV
+		if (dev->flags & MLX4_FLAG_SRIOV) {
+			mlx4_warn(dev, "Disabling sriov\n");
+			pci_disable_sriov(pdev);
+		}
+#endif /* CONFIG_PCI_IOV */
 
 		kfree(priv);
 		pci_release_regions(pdev);
@@ -1321,14 +1495,21 @@ int mlx4_restart_one(struct pci_dev *pdev)
 	return __mlx4_init_one(pdev, NULL);
 }
 
+
 static struct pci_device_id mlx4_pci_table[] = {
 	{ PCI_VDEVICE(MELLANOX, 0x6340) }, /* MT25408 "Hermon" SDR */
+	{ PCI_VDEVICE(MELLANOX, 0x6341) }, /* MT25408 "Hermon" SDR VF */
 	{ PCI_VDEVICE(MELLANOX, 0x634a) }, /* MT25408 "Hermon" DDR */
+	{ PCI_VDEVICE(MELLANOX, 0x634b) }, /* MT25408 "Hermon" DDR VF */
 	{ PCI_VDEVICE(MELLANOX, 0x6354) }, /* MT25408 "Hermon" QDR */
 	{ PCI_VDEVICE(MELLANOX, 0x6732) }, /* MT25408 "Hermon" DDR PCIe gen2 */
+	{ PCI_VDEVICE(MELLANOX, 0x6733) }, /* MT25408 "Hermon" DDR PCIe gen2 VF */
 	{ PCI_VDEVICE(MELLANOX, 0x673c) }, /* MT25408 "Hermon" QDR PCIe gen2 */
+	{ PCI_VDEVICE(MELLANOX, 0x673d) }, /* MT25408 "Hermon" QDR PCIe gen2 VF */
 	{ PCI_VDEVICE(MELLANOX, 0x6368) }, /* MT25408 "Hermon" EN 10GigE */
+	{ PCI_VDEVICE(MELLANOX, 0x6369) }, /* MT25408 "Hermon" EN 10GigE VF */
 	{ PCI_VDEVICE(MELLANOX, 0x6750) }, /* MT25408 "Hermon" EN 10GigE PCIe gen2 */
+	{ PCI_VDEVICE(MELLANOX, 0x6751) }, /* MT25408 "Hermon" EN 10GigE PCIe gen2 VF */
 	{ PCI_VDEVICE(MELLANOX, 0x6372) }, /* MT25458 ConnectX EN 10GBASE-T 10GigE */
 	{ PCI_VDEVICE(MELLANOX, 0x675a) }, /* MT25458 ConnectX EN 10GBASE-T+Gen2 10GigE */
 	{ PCI_VDEVICE(MELLANOX, 0x6764) }, /* MT26468 ConnectX EN 10GigE PCIe gen2*/
-- 
1.6.1.3




--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
