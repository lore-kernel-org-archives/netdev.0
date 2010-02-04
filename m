From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 12/23 v3] mlx4_core: boot sriov
Date: Thu, 04 Feb 2010 17:55:57 +0200
Message-ID: <4B6AEE0D.1050804@mellanox.co.il>
References: <49BFC313.1030901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49757 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933198Ab0BDP4A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 10:56:00 -0500
In-Reply-To: <49BFC313.1030901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add virtual function device ids. Setting VF flag to device private data
Establish comm channel when sriov is enabled, and boot vfs through it.
Each slave gets one msi-X for completions, the master also gets one for
async events.

Signed-off-by: Liran Liss <liranl@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/eq.c   |   22 ++--
 drivers/net/mlx4/main.c |  326 +++++++++++++++++++++++++++++++++++-----------
 drivers/net/mlx4/mlx4.h |    4 +
 3 files changed, 265 insertions(+), 87 deletions(-)

diff --git a/drivers/net/mlx4/eq.c b/drivers/net/mlx4/eq.c
index 08af60c..b4726ae 100644
--- a/drivers/net/mlx4/eq.c
+++ b/drivers/net/mlx4/eq.c
@@ -760,16 +760,19 @@ int mlx4_init_eq_table(struct mlx4_dev *dev)
 			goto err_out_unmap;
 	}
 
-	err = mlx4_create_eq(dev, MLX4_NUM_ASYNC_EQE + MLX4_NUM_SPARE_EQE,
-			     (dev->flags & MLX4_FLAG_MSI_X) ? dev->caps.num_comp_vectors : 0,
-			     &priv->eq_table.eq[dev->caps.num_comp_vectors]);
-	if (err)
-		goto err_out_comp;
+	if (!mlx4_is_slave(dev)) {
+		err = mlx4_create_eq(dev, MLX4_NUM_ASYNC_EQE + MLX4_NUM_SPARE_EQE,
+				     (dev->flags & MLX4_FLAG_MSI_X) ?
+					dev->caps.num_comp_vectors : 0,
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
@@ -815,13 +818,14 @@ int mlx4_init_eq_table(struct mlx4_dev *dev)
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
@@ -856,7 +860,7 @@ void mlx4_cleanup_eq_table(struct mlx4_dev *dev)
 
 	mlx4_free_irqs(dev);
 
-	for (i = 0; i < dev->caps.num_comp_vectors + 1; ++i)
+	for (i = 0; i < dev->caps.num_comp_vectors + !mlx4_is_slave(dev); ++i)
 		mlx4_free_eq(dev, &priv->eq_table.eq[i]);
 
 	if (!mlx4_is_slave(dev))
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 23dae5b..6d5a8de 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -73,6 +73,23 @@ MODULE_PARM_DESC(msi_x, "attempt to use MSI-X if nonzero");
 
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
+#else /* CONFIG_PCI_IOV */
+
+#define sr_iov 0
+#define probe_vf 0
+
+#endif /* CONFIG_PCI_IOV */
+
 static char mlx4_version[] __devinitdata =
 	DRV_NAME ": Mellanox ConnectX core driver v"
 	DRV_VERSION " (" DRV_RELDATE ")\n";
@@ -782,12 +799,56 @@ static void mlx4_free_icms(struct mlx4_dev *dev)
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
@@ -801,51 +862,67 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
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
@@ -860,15 +937,17 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
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
 
@@ -1042,8 +1121,13 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 	int i;
 
 	if (msi_x) {
-		nreq = min_t(int, dev->caps.num_eqs - dev->caps.reserved_eqs,
-			     num_possible_cpus() + 1);
+		/* The master only uses en event EQ,
+		 * Each one of the slaves have 1 completion eq */
+		if (mlx4_is_mfunc(dev))
+			nreq = 1 + !!mlx4_is_master(dev);
+		else
+			nreq = min_t(int, dev->caps.num_eqs - dev->caps.reserved_eqs,
+				     num_possible_cpus() + 1);
 		entries = kcalloc(nreq, sizeof *entries, GFP_KERNEL);
 		if (!entries)
 			goto no_msi;
@@ -1066,7 +1150,7 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 			goto no_msi;
 		}
 
-		dev->caps.num_comp_vectors = nreq - 1;
+		dev->caps.num_comp_vectors = nreq - !mlx4_is_slave(dev);
 		for (i = 0; i < nreq; ++i)
 			priv->eq_table.eq[i].irq = entries[i].vector;
 
@@ -1137,10 +1221,10 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	}
 
 	/*
-	 * Check for BARs.  We expect 0: 1MB
+	 * Check for BARs.
 	 */
-	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM) ||
-	    pci_resource_len(pdev, 0) != 1 << 20) {
+	if (((id == NULL) || !(id->driver_data & MLX4_VF)) &&
+	    !(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
 		dev_err(&pdev->dev, "Missing DCS, aborting.\n");
 		err = -ENODEV;
 		goto err_disable_pdev;
@@ -1198,34 +1282,83 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
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
+	if (id && id->driver_data & MLX4_VF) {
+		/* When acting as pf, we normally skip vfs unless explicitly
+		 * requested to probe them. */
+		if (sr_iov && PCI_FUNC(pdev->devfn) > probe_vf) {
+			mlx4_warn(dev, "Skipping virtual function:%d\n",
+						PCI_FUNC(pdev->devfn));
+			err = -ENODEV;
+			goto err_free_dev;
+		}
+		mlx4_warn(dev, "Detected virtual function - running in slave mode\n");
+		dev->flags |= MLX4_FLAG_SLAVE;
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
+		if (sr_iov) {
+			mlx4_warn(dev, "Enabling sriov with:%d vfs\n", sr_iov);
+			if (pci_enable_sriov(pdev, sr_iov)) {
+				mlx4_err(dev, "Failed to enable sriov, aborting.\n");
+				goto err_free_dev;
+			}
+			mlx4_warn(dev, "Running in master mode\n");
+			dev->flags |= MLX4_FLAG_SRIOV | MLX4_FLAG_MASTER;
+		}
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
+		dev->num_slaves = MLX4_MAX_NUM_SLAVES;
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
@@ -1249,6 +1382,12 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	pci_set_drvdata(pdev, dev);
 
+	/* Start serving comm channel:
+	 * - In master function: poll for commands
+	 * - in slave functions: poll for events
+	 * TODO - enable comm channel interrupts */
+	if (mlx4_is_mfunc(dev))
+		queue_delayed_work(priv->mfunc.comm_wq, &priv->mfunc.comm_work, 0);
 	return 0;
 
 err_port:
@@ -1259,7 +1398,8 @@ err_port:
 	mlx4_cleanup_qp_table(dev);
 	mlx4_cleanup_srq_table(dev);
 	mlx4_cleanup_cq_table(dev);
-	mlx4_cmd_use_polling(dev);
+	if (!mlx4_is_slave(dev))
+		mlx4_cmd_use_polling(dev);
 	mlx4_cleanup_eq_table(dev);
 	mlx4_cleanup_mr_table(dev);
 	mlx4_cleanup_pd_table(dev);
@@ -1277,6 +1417,12 @@ err_close:
 err_cmd:
 	mlx4_cmd_cleanup(dev);
 
+err_sriov:
+	if (mlx4_is_mfunc(dev))
+		mlx4_multi_func_cleanup(dev);
+	if (sr_iov && (dev->flags & MLX4_FLAG_SRIOV))
+		pci_disable_sriov(pdev);
+
 err_free_dev:
 	kfree(priv);
 
@@ -1309,19 +1455,24 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 	int p;
 
 	if (dev) {
+		/* Stop serving commands and events over comm channel */
+		if (mlx4_is_mfunc(dev))
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
+		if (!mlx4_is_slave(dev))
+			mlx4_cmd_use_polling(dev);
 		mlx4_cleanup_eq_table(dev);
 		mlx4_cleanup_mr_table(dev);
 		mlx4_cleanup_pd_table(dev);
@@ -1331,10 +1482,16 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 		mlx4_cleanup_uar_table(dev);
 		mlx4_free_eq_table(dev);
 		mlx4_close_hca(dev);
+		if (mlx4_is_mfunc(dev))
+			mlx4_multi_func_cleanup(dev);
 		mlx4_cmd_cleanup(dev);
 
 		if (dev->flags & MLX4_FLAG_MSI_X)
 			pci_disable_msix(pdev);
+		if (sr_iov && (dev->flags & MLX4_FLAG_SRIOV)) {
+			mlx4_warn(dev, "Disabling sriov\n");
+			pci_disable_sriov(pdev);
+		}
 
 		kfree(priv);
 		pci_release_regions(pdev);
@@ -1350,18 +1507,31 @@ int mlx4_restart_one(struct pci_dev *pdev)
 }
 
 static struct pci_device_id mlx4_pci_table[] = {
-	{ PCI_VDEVICE(MELLANOX, 0x6340) }, /* MT25408 "Hermon" SDR */
-	{ PCI_VDEVICE(MELLANOX, 0x634a) }, /* MT25408 "Hermon" DDR */
-	{ PCI_VDEVICE(MELLANOX, 0x6354) }, /* MT25408 "Hermon" QDR */
-	{ PCI_VDEVICE(MELLANOX, 0x6732) }, /* MT25408 "Hermon" DDR PCIe gen2 */
-	{ PCI_VDEVICE(MELLANOX, 0x673c) }, /* MT25408 "Hermon" QDR PCIe gen2 */
-	{ PCI_VDEVICE(MELLANOX, 0x6368) }, /* MT25408 "Hermon" EN 10GigE */
-	{ PCI_VDEVICE(MELLANOX, 0x6750) }, /* MT25408 "Hermon" EN 10GigE PCIe gen2 */
-	{ PCI_VDEVICE(MELLANOX, 0x6372) }, /* MT25458 ConnectX EN 10GBASE-T 10GigE */
-	{ PCI_VDEVICE(MELLANOX, 0x675a) }, /* MT25458 ConnectX EN 10GBASE-T+Gen2 10GigE */
-	{ PCI_VDEVICE(MELLANOX, 0x6764) }, /* MT26468 ConnectX EN 10GigE PCIe gen2*/
-	{ PCI_VDEVICE(MELLANOX, 0x6746) }, /* MT26438 ConnectX EN 40GigE PCIe gen2 5GT/s */
-	{ PCI_VDEVICE(MELLANOX, 0x676e) }, /* MT26478 ConnectX2 40GigE PCIe gen2 */
+	{ MLX4_VDEVICE(MELLANOX, 0x6340, 0) }, /* MT25408 "Hermon" SDR */
+	{ MLX4_VDEVICE(MELLANOX, 0x6341, MLX4_VF) }, /* MT25408 "Hermon" SDR VF */
+	{ MLX4_VDEVICE(MELLANOX, 0x634a, 0) }, /* MT25408 "Hermon" DDR */
+	{ MLX4_VDEVICE(MELLANOX, 0x634b, MLX4_VF) }, /* MT25408 "Hermon" DDR VF */
+	{ MLX4_VDEVICE(MELLANOX, 0x6354, 0) }, /* MT25408 "Hermon" QDR */
+	{ MLX4_VDEVICE(MELLANOX, 0x6732, 0) }, /* MT25408 "Hermon" DDR PCIe gen2 */
+	{ MLX4_VDEVICE(MELLANOX, 0x6733, MLX4_VF) }, /* MT25408 "Hermon" DDR PCIe gen2 VF */
+	{ MLX4_VDEVICE(MELLANOX, 0x673c, 0) }, /* MT25408 "Hermon" QDR PCIe gen2 */
+	{ MLX4_VDEVICE(MELLANOX, 0x673d, MLX4_VF) }, /* MT25408 "Hermon" QDR PCIe gen2 VF */
+	{ MLX4_VDEVICE(MELLANOX, 0x6368, 0) }, /* MT25408 "Hermon" EN 10GigE */
+	{ MLX4_VDEVICE(MELLANOX, 0x6369, MLX4_VF) }, /* MT25408 "Hermon" EN 10GigE VF */
+	{ MLX4_VDEVICE(MELLANOX, 0x6750, 0) }, /* MT25408 "Hermon" EN 10GigE PCIe gen2 */
+	{ MLX4_VDEVICE(MELLANOX, 0x6751, MLX4_VF) }, /* MT25408 "Hermon" EN 10GigE PCIe gen2 VF */
+	{ MLX4_VDEVICE(MELLANOX, 0x6372, 0) }, /* MT25458 ConnectX EN 10GBASE-T 10GigE */
+	{ MLX4_VDEVICE(MELLANOX, 0x6373, MLX4_VF) }, /* MT25458 ConnectX EN 10GBASE-T 10GigE */
+	{ MLX4_VDEVICE(MELLANOX, 0x675a, 0) }, /* MT25458 ConnectX EN 10GBASE-T+Gen2 10GigE */
+	{ MLX4_VDEVICE(MELLANOX, 0x675b, MLX4_VF) }, /* MT25458 ConnectX EN 10GBASE-T+Gen2 10GigE */
+	{ MLX4_VDEVICE(MELLANOX, 0x6764, 0) }, /* MT26468 ConnectX EN 10GigE PCIe gen2*/
+	{ MLX4_VDEVICE(MELLANOX, 0x6765, MLX4_VF) }, /* MT26468 ConnectX EN 10GigE PCIe gen2 VF*/
+	{ MLX4_VDEVICE(MELLANOX, 0x6746, 0) }, /* MT26438 ConnectX VPI PCIe 2.0 5GT/s - IB QDR / 10GigE Virt+ */
+	{ MLX4_VDEVICE(MELLANOX, 0x6747, MLX4_VF) }, /* MT26438 ConnectX VPI PCIe 2.0 5GT/s - IB QDR / 10GigE Virt+ VF*/
+	{ MLX4_VDEVICE(MELLANOX, 0x676e, 0) }, /* MT26478 ConnectX EN 40GigE PCIe 2.0 5GT/s */
+	{ MLX4_VDEVICE(MELLANOX, 0x676f, MLX4_VF) }, /* MT26478 ConnectX EN 40GigE PCIe 2.0 5GT/s VF*/
+	{ MLX4_VDEVICE(MELLANOX, 0x6778, 0) }, /* MT26488 ConnectX VPI PCIe 2.0 5GT/s - IB DDR / 10GigE Virt+ */
+	{ MLX4_VDEVICE(MELLANOX, 0x6779, MLX4_VF) }, /* MT26488 ConnectX VPI PCIe 2.0 5GT/s - IB DDR / 10GigE Virt+ VF*/
 	{ 0, }
 };
 
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index a243ac7..6421932 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -144,6 +144,10 @@ extern int mlx4_debug_level;
 #define MLX4_MAX_NUM_VF		64
 #define MLX4_MAX_NUM_SLAVES	(MLX4_MAX_NUM_PF + MLX4_MAX_NUM_VF)
 
+#define MLX4_VF					(1 << 0)
+#define MLX4_VDEVICE(vendor, device, flags)	\
+	PCI_VDEVICE(vendor, device), (flags)
+
 struct mlx4_bitmap {
 	u32			last;
 	u32			top;
-- 
1.6.1.3


