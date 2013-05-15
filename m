From: Yinghai Lu <yinghai@kernel.org>
Subject: [PATCH v2 6/7] PCI: Make sure VF's driver get attached after PF's
Date: Tue, 14 May 2013 19:48:22 -0700
Message-ID: <1368586102-17661-1-git-send-email-yinghai@kernel.org>
Cc: Gu Zheng <guz.fnst@cn.fujitsu.com>, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Yan Burman <yanb@mellanox.com>,
	Sathya Perla <Sathya.Perla@Emulex.Com>, netdev@vger.kernel.org
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24076 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932066Ab3EOCtC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 22:49:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found kernel try to load mlx4 drivers for VFs before
PF's is loaded when the drivers are built-in, and kernel
command line include probe_vfs=63, num_vfs=63.

[  169.581682] calling  mlx4_init+0x0/0x119 @ 1
[  169.595681] mlx4_core: Mellanox ConnectX core driver v1.1 (Dec, 2011)
[  169.600194] mlx4_core: Initializing 0000:02:00.0
[  169.616322] mlx4_core 0000:02:00.0: Enabling SR-IOV with 63 VFs
[  169.724084] pci 0000:02:00.1: [15b3:1002] type 00 class 0x0c0600
[  169.732442] mlx4_core: Initializing 0000:02:00.1
[  169.734345] mlx4_core 0000:02:00.1: enabling device (0000 -> 0002)
[  169.747060] mlx4_core 0000:02:00.1: enabling bus mastering
[  169.764283] mlx4_core 0000:02:00.1: Detected virtual function - running in slave mode
[  169.767409] mlx4_core 0000:02:00.1: with iommu 3 : domain 11
[  169.785589] mlx4_core 0000:02:00.1: Sending reset
[  179.790131] mlx4_core 0000:02:00.1: Got slave FLRed from Communication channel (ret:0x1)
[  181.798661] mlx4_core 0000:02:00.1: slave is currently in themiddle of FLR. retrying...(try num:1)
[  181.803336] mlx4_core 0000:02:00.1: Communication channel is not idle.my toggle is 1 (cmd:0x0)
...
[  182.078710] mlx4_core 0000:02:00.1: slave is currently in themiddle of FLR. retrying...(try num:10)
[  182.096657] mlx4_core 0000:02:00.1: Communication channel is not idle.my toggle is 1 (cmd:0x0)
[  182.104935] mlx4_core 0000:02:00.1: slave driver version is not supported by the master
[  182.118570] mlx4_core 0000:02:00.1: Communication channel is not idle.my toggle is 1 (cmd:0x0)
[  182.138190] mlx4_core 0000:02:00.1: Failed to initialize slave
[  182.141728] mlx4_core: probe of 0000:02:00.1 failed with error -5

It turns that this also happen for hotadd path even drivers are
compiled as modules and if they are loaded. Esp some VF share the
same driver with PF.

calling path:
	device driver probe
		==> pci_enable_sriov
			==> virtfn_add
				==> pci_dev_add
				==> pci_bus_device_add
when pci_bus_device_add is called, the VF's driver will be attached.
and at that time PF's driver does not finish yet.

Need to move out pci_bus_device_add from virtfn_add and call it
later.

bnx2x and qlcnic are ok, because it does not modules command line
to enable sriov. They must use sysfs to enable it.

be2net is ok, according to Sathya Perla,
he fixed this issue in be2net with the following patch (commit b4c1df93)
  http://marc.info/?l=linux-netdev&m=136801459808765&w=2

For igb and ixgbe is ok, as Alex Duyck said:
| The VF driver should be able to be loaded when the PF driver is not
| present.  We handle it in igb and ixgbe last I checked, and I don't see
| any reason why it cannot be handled in all other VF drivers.  I'm not
| saying the VF has to be able to fully functional, but it should be able
| to detect the PF becoming enabled and then bring itself to a fully
| functional state.  To not handle that case is a bug.

Looks like the patch will help enic, mlx4, efx, vxge and lpfc now.

-v2: don't use schedule_callback, and initcall after Alex's patch.
	pci: Avoid reentrant calls to work_on_cpu

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: Yan Burman <yanb@mellanox.com>
Cc: Sathya Perla <Sathya.Perla@Emulex.Com>
Cc: netdev@vger.kernel.org

---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c    |    7 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c      |    4 +
 drivers/net/ethernet/cisco/enic/enic_main.c          |    2 
 drivers/net/ethernet/emulex/benet/be_main.c          |    4 +
 drivers/net/ethernet/intel/igb/igb_main.c            |   11 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c        |    2 
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c       |    9 ++-
 drivers/net/ethernet/mellanox/mlx4/main.c            |    3 +
 drivers/net/ethernet/neterion/vxge/vxge-main.c       |    3 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c |    5 +-
 drivers/net/ethernet/sfc/efx.c                       |    1 
 drivers/pci/iov.c                                    |   47 ++++++++++++++++---
 drivers/scsi/lpfc/lpfc_init.c                        |    2 
 include/linux/pci.h                                  |    4 +
 14 files changed, 90 insertions(+), 14 deletions(-)

Index: linux-2.6/drivers/net/ethernet/mellanox/mlx4/main.c
===================================================================
--- linux-2.6.orig/drivers/net/ethernet/mellanox/mlx4/main.c
+++ linux-2.6/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2308,6 +2308,9 @@ slave_start:
 	priv->pci_dev_data = pci_dev_data;
 	pci_set_drvdata(pdev, dev);
 
+	if (dev->flags & MLX4_FLAG_SRIOV)
+		pci_bus_add_device_vfs(pdev);
+
 	return 0;
 
 err_port:
Index: linux-2.6/drivers/pci/iov.c
===================================================================
--- linux-2.6.orig/drivers/pci/iov.c
+++ linux-2.6/drivers/pci/iov.c
@@ -66,7 +66,8 @@ static void virtfn_remove_bus(struct pci
 		pci_remove_bus(child);
 }
 
-static int virtfn_add(struct pci_dev *dev, int id, int reset)
+static int virtfn_add(struct pci_dev *dev, int id, int reset,
+			struct pci_dev **ret)
 {
 	int i;
 	int rc;
@@ -116,7 +117,6 @@ static int virtfn_add(struct pci_dev *de
 	pci_device_add(virtfn, virtfn->bus);
 	mutex_unlock(&iov->dev->sriov->lock);
 
-	rc = pci_bus_add_device(virtfn);
 	sprintf(buf, "virtfn%u", id);
 	rc = sysfs_create_link(&dev->dev.kobj, &virtfn->dev.kobj, buf);
 	if (rc)
@@ -127,6 +127,8 @@ static int virtfn_add(struct pci_dev *de
 
 	kobject_uevent(&virtfn->dev.kobj, KOBJ_CHANGE);
 
+	if (ret)
+		*ret = virtfn;
 	return 0;
 
 failed2:
@@ -141,6 +143,26 @@ failed1:
 	return rc;
 }
 
+void pci_bus_add_device_vfs(struct pci_dev *pdev)
+{
+	int rc;
+	struct pci_dev *dev;
+
+       /* only search if it is a PF */
+	if (!pdev->is_physfn)
+		return;
+
+	/* loop through all the VFs to see if we own and is not added yet*/
+	dev = pci_get_device(pdev->vendor, PCI_ANY_ID, NULL);
+	while (dev) {
+		if (dev->is_virtfn && dev->physfn == pdev && !dev->is_added)
+			rc = pci_bus_add_device(dev);
+
+		dev = pci_get_device(pdev->vendor, PCI_ANY_ID, dev);
+	}
+}
+EXPORT_SYMBOL_GPL(pci_bus_add_device_vfs);
+
 static void virtfn_remove(struct pci_dev *dev, int id, int reset)
 {
 	char buf[VIRTFN_ID_LEN];
@@ -204,6 +226,7 @@ static int sriov_migration(struct pci_de
 static void sriov_migration_task(struct work_struct *work)
 {
 	int i;
+	int rc;
 	u8 state;
 	u16 status;
 	struct pci_sriov *iov = container_of(work, struct pci_sriov, mtask);
@@ -213,14 +236,24 @@ static void sriov_migration_task(struct
 		if (state == PCI_SRIOV_VFM_MI) {
 			writeb(PCI_SRIOV_VFM_AV, iov->mstate + i);
 			state = readb(iov->mstate + i);
-			if (state == PCI_SRIOV_VFM_AV)
-				virtfn_add(iov->self, i, 1);
+			if (state == PCI_SRIOV_VFM_AV) {
+				struct pci_dev *virtfn = NULL;
+
+				virtfn_add(iov->self, i, 1, &virtfn);
+				if (virtfn)
+					rc = pci_bus_add_device(virtfn);
+			}
 		} else if (state == PCI_SRIOV_VFM_MO) {
 			virtfn_remove(iov->self, i, 1);
 			writeb(PCI_SRIOV_VFM_UA, iov->mstate + i);
 			state = readb(iov->mstate + i);
-			if (state == PCI_SRIOV_VFM_AV)
-				virtfn_add(iov->self, i, 0);
+			if (state == PCI_SRIOV_VFM_AV) {
+				struct pci_dev *virtfn = NULL;
+
+				virtfn_add(iov->self, i, 0, &virtfn);
+				if (virtfn)
+					rc = pci_bus_add_device(virtfn);
+			}
 		}
 	}
 
@@ -356,7 +389,7 @@ static int sriov_enable(struct pci_dev *
 		initial = nr_virtfn;
 
 	for (i = 0; i < initial; i++) {
-		rc = virtfn_add(dev, i, 0);
+		rc = virtfn_add(dev, i, 0, NULL);
 		if (rc)
 			goto failed;
 	}
Index: linux-2.6/include/linux/pci.h
===================================================================
--- linux-2.6.orig/include/linux/pci.h
+++ linux-2.6/include/linux/pci.h
@@ -1659,6 +1659,7 @@ void __iomem *pci_ioremap_bar(struct pci
 
 #ifdef CONFIG_PCI_IOV
 int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn);
+void pci_bus_add_device_vfs(struct pci_dev *dev);
 void pci_disable_sriov(struct pci_dev *dev);
 irqreturn_t pci_sriov_migration(struct pci_dev *dev);
 int pci_num_vf(struct pci_dev *dev);
@@ -1670,6 +1671,9 @@ static inline int pci_enable_sriov(struc
 {
 	return -ENODEV;
 }
+static inline void pci_bus_add_device_vfs(struct pci_dev *dev)
+{
+}
 static inline void pci_disable_sriov(struct pci_dev *dev)
 {
 }
Index: linux-2.6/drivers/net/ethernet/intel/igb/igb_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ethernet/intel/igb/igb_main.c
+++ linux-2.6/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2366,6 +2366,9 @@ static int igb_probe(struct pci_dev *pde
 	}
 
 	pm_runtime_put_noidle(&pdev->dev);
+
+	pci_bus_add_device_vfs(pdev);
+
 	return 0;
 
 err_register:
@@ -7278,8 +7281,12 @@ static int igb_pci_sriov_configure(struc
 #ifdef CONFIG_PCI_IOV
 	if (num_vfs == 0)
 		return igb_pci_disable_sriov(dev);
-	else
-		return igb_pci_enable_sriov(dev, num_vfs);
+	else {
+		int ret = igb_pci_enable_sriov(dev, num_vfs);
+		if (ret > 0)
+			pci_bus_add_device_vfs(dev);
+		return ret;
+	}
 #endif
 	return 0;
 }
Index: linux-2.6/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
===================================================================
--- linux-2.6.orig/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ linux-2.6/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -346,8 +346,13 @@ int ixgbe_pci_sriov_configure(struct pci
 {
 	if (num_vfs == 0)
 		return ixgbe_pci_sriov_disable(dev);
-	else
-		return ixgbe_pci_sriov_enable(dev, num_vfs);
+	else {
+		int ret = ixgbe_pci_sriov_enable(dev, num_vfs);
+
+		if (ret > 0)
+			pci_bus_add_device_vfs(dev);
+		return ret;
+	}
 }
 
 static int ixgbe_set_vf_multicasts(struct ixgbe_adapter *adapter,
Index: linux-2.6/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ linux-2.6/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7658,6 +7658,8 @@ skip_sriov:
 			IXGBE_LINK_SPEED_10GB_FULL | IXGBE_LINK_SPEED_1GB_FULL,
 			true);
 
+	pci_bus_add_device_vfs(pdev);
+
 	return 0;
 
 err_register:
Index: linux-2.6/drivers/scsi/lpfc/lpfc_init.c
===================================================================
--- linux-2.6.orig/drivers/scsi/lpfc/lpfc_init.c
+++ linux-2.6/drivers/scsi/lpfc/lpfc_init.c
@@ -10582,6 +10582,8 @@ lpfc_pci_probe_one(struct pci_dev *pdev,
 	else
 		rc = lpfc_pci_probe_one_s3(pdev, pid);
 
+	pci_bus_add_device_vfs(pdev);
+
 	return rc;
 }
 
Index: linux-2.6/drivers/net/ethernet/emulex/benet/be_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ethernet/emulex/benet/be_main.c
+++ linux-2.6/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4111,6 +4111,7 @@ static int lancer_recover_func(struct be
 	if (status)
 		goto err;
 
+	pci_bus_add_device_vfs(adapter->pdev);
 	if (netif_running(adapter->netdev)) {
 		status = be_open(adapter->netdev);
 		if (status)
@@ -4327,6 +4328,8 @@ static int be_probe(struct pci_dev *pdev
 	dev_info(&pdev->dev, "%s: %s %s port %c\n", nic_name(pdev),
 		 func_name(adapter), mc_name(adapter), port_name);
 
+	pci_bus_add_device_vfs(pdev);
+
 	return 0;
 
 unsetup:
@@ -4398,6 +4401,7 @@ static int be_resume(struct pci_dev *pde
 		rtnl_unlock();
 	}
 
+	pci_bus_add_device_vfs(adapter->pdev);
 	schedule_delayed_work(&adapter->func_recovery_work,
 			      msecs_to_jiffies(1000));
 	netif_device_attach(netdev);
Index: linux-2.6/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
===================================================================
--- linux-2.6.orig/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ linux-2.6/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -568,8 +568,11 @@ int qlcnic_pci_sriov_configure(struct pc
 
 	if (num_vfs == 0)
 		err = qlcnic_pci_sriov_disable(adapter);
-	else
+	else {
 		err = qlcnic_pci_sriov_enable(adapter, num_vfs);
+		if (err > 0)
+			pci_bus_add_device_vfs(dev);
+	}
 
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 	return err;
Index: linux-2.6/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
===================================================================
--- linux-2.6.orig/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ linux-2.6/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -3048,7 +3048,12 @@ int bnx2x_sriov_configure(struct pci_dev
 		pci_disable_sriov(dev);
 		return 0;
 	} else {
-		return bnx2x_enable_sriov(bp);
+		int ret = bnx2x_enable_sriov(bp);
+
+		if (ret > 0)
+			pci_bus_add_device_vfs(dev);
+
+		return 0;
 	}
 }
 
Index: linux-2.6/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ linux-2.6/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -5749,10 +5749,12 @@ static int init_one(struct pci_dev *pdev
 sriov:
 #ifdef CONFIG_PCI_IOV
 	if (func < ARRAY_SIZE(num_vf) && num_vf[func] > 0)
-		if (pci_enable_sriov(pdev, num_vf[func]) == 0)
+		if (pci_enable_sriov(pdev, num_vf[func]) == 0) {
 			dev_info(&pdev->dev,
 				 "instantiated %u virtual functions\n",
 				 num_vf[func]);
+			pci_bus_add_device_vfs(pdev);
+		}
 #endif
 	return 0;
 
Index: linux-2.6/drivers/net/ethernet/cisco/enic/enic_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ethernet/cisco/enic/enic_main.c
+++ linux-2.6/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2524,6 +2524,8 @@ static int enic_probe(struct pci_dev *pd
 		goto err_out_dev_deinit;
 	}
 
+	pci_bus_add_device_vfs(pdev);
+
 	return 0;
 
 err_out_dev_deinit:
Index: linux-2.6/drivers/net/ethernet/neterion/vxge/vxge-main.c
===================================================================
--- linux-2.6.orig/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ linux-2.6/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -4731,6 +4731,9 @@ vxge_probe(struct pci_dev *pdev, const s
 		vxge_hw_device_trace_level_get(hldev));
 
 	kfree(ll_config);
+
+	pci_bus_add_device_vfs(pdev);
+
 	return 0;
 
 _exit6:
Index: linux-2.6/drivers/net/ethernet/sfc/efx.c
===================================================================
--- linux-2.6.orig/drivers/net/ethernet/sfc/efx.c
+++ linux-2.6/drivers/net/ethernet/sfc/efx.c
@@ -2824,6 +2824,7 @@ static int efx_pci_probe(struct pci_dev
 		netif_warn(efx, probe, efx->net_dev,
 			   "pci_enable_pcie_error_reporting failed (%d)\n", rc);
 
+	pci_bus_add_device_vfs(pci_dev);
 	return 0;
 
  fail4:
