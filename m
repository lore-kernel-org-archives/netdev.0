From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 1/2] bna: Add Debugfs Interface
Date: Tue, 17 May 2011 21:57:00 -0700
Message-ID: <1305694621-28023-2-git-send-email-rmody@brocade.com>
References: <1305694621-28023-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:36679 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751226Ab1ERE54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 00:57:56 -0400
In-Reply-To: <1305694621-28023-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the debugfs interface to BNA driver for collecting both
live and saved firmware traces (saved, in case of a firmware heart beat
failure).

Signed-off-by: Debashis Dutt <ddutt@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/Makefile       |    3 +-
 drivers/net/bna/bfa_ioc.c      |  105 ++++++++++++++-
 drivers/net/bna/bfa_ioc.h      |    6 +
 drivers/net/bna/bfi.h          |    2 +
 drivers/net/bna/bna_ctrl.c     |    5 +-
 drivers/net/bna/bnad.c         |   37 +++++-
 drivers/net/bna/bnad.h         |   15 ++-
 drivers/net/bna/bnad_debugfs.c |  302 ++++++++++++++++++++++++++++++++++++++++
 8 files changed, 466 insertions(+), 9 deletions(-)
 create mode 100644 drivers/net/bna/bnad_debugfs.c

diff --git a/drivers/net/bna/Makefile b/drivers/net/bna/Makefile
index a5d604d..4bb0d5d 100644
--- a/drivers/net/bna/Makefile
+++ b/drivers/net/bna/Makefile
@@ -5,7 +5,8 @@
 
 obj-$(CONFIG_BNA) += bna.o
 
-bna-objs := bnad.o bnad_ethtool.o bna_ctrl.o bna_txrx.o
+bna-objs := bnad.o bnad_debugfs.o bnad_ethtool.o
+bna-objs += bna_ctrl.o bna_txrx.o
 bna-objs += bfa_ioc.o bfa_ioc_ct.o bfa_cee.o cna_fwimg.o
 
 EXTRA_CFLAGS := -Idrivers/net/bna
diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index fcb9bb3..15f9dec 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -1652,6 +1652,7 @@ bfa_ioc_fail_notify(struct bfa_ioc *ioc)
 {
 	struct list_head		*qe;
 	struct bfa_ioc_hbfail_notify	*notify;
+	int				tlen;
 
 	/**
 	 * Notify driver and common modules registered for notification.
@@ -1661,6 +1662,15 @@ bfa_ioc_fail_notify(struct bfa_ioc *ioc)
 		notify = (struct bfa_ioc_hbfail_notify *) qe;
 		notify->cbfn(notify->cbarg);
 	}
+
+	/* Save firmware trace if configured. */
+	if (ioc->dbg_fwsave_once) {
+		ioc->dbg_fwsave_once = false;
+		if (ioc->dbg_fwsave_len) {
+			tlen = ioc->dbg_fwsave_len;
+			bfa_nw_ioc_debug_fwtrc(ioc, ioc->dbg_fwsave, &tlen);
+		}
+	}
 }
 
 static void
@@ -1922,6 +1932,17 @@ bfa_ioc_smem_pgnum(struct bfa_ioc *ioc, u32 fmaddr)
 	return PSS_SMEM_PGNUM(ioc->ioc_regs.smem_pg0, fmaddr);
 }
 
+/*
+ * Initialize memory for saving firmware trace. Driver must initialize
+ * trace memory before call bfa_ioc_enable().
+ */
+void
+bfa_nw_ioc_debug_memclaim(struct bfa_ioc *ioc, void *dbg_fwsave)
+{
+	ioc->dbg_fwsave     = dbg_fwsave;
+	ioc->dbg_fwsave_len = (ioc->iocpf.auto_recover) ? BFA_DBG_FWTRC_LEN : 0;
+}
+
 /**
  * Register mailbox message handler function, to be called by common modules
  */
@@ -2209,13 +2230,95 @@ bfa_nw_ioc_get_mac(struct bfa_ioc *ioc)
 	return ioc->attr->mac;
 }
 
+static int
+bfa_ioc_smem_read(struct bfa_ioc *ioc, void *tbuf, u32 soff, u32 sz)
+{
+	u32 pgnum, loff;
+	__be32 r32;
+	int i, len;
+	u32 *buf = tbuf;
+
+	pgnum = PSS_SMEM_PGNUM(ioc->ioc_regs.smem_pg0, soff);
+	loff = PSS_SMEM_PGOFF(soff);
+
+	/*
+	 *  Hold semaphore to serialize pll init and fwtrc.
+	 */
+	if (!(bfa_nw_ioc_sem_get(ioc->ioc_regs.ioc_init_sem_reg)))
+		return 1;
+
+	writel(pgnum, ioc->ioc_regs.host_page_num_fn);
+
+	len = sz/sizeof(u32);
+	for (i = 0; i < len; i++) {
+		r32 = swab32(readl(ioc->ioc_regs.smem_page_start + loff));
+		buf[i] = be32_to_cpu(r32);
+		loff += sizeof(u32);
+
+		/*
+		 * handle page offset wrap around
+		 */
+		loff = PSS_SMEM_PGOFF(loff);
+		if (loff == 0) {
+			pgnum++;
+			writel(pgnum, ioc->ioc_regs.host_page_num_fn);
+		}
+	}
+	writel(PSS_SMEM_PGNUM(ioc->ioc_regs.smem_pg0, 0),
+			ioc->ioc_regs.host_page_num_fn);
+	/*
+	 *  release semaphore.
+	 */
+	writel(1, ioc->ioc_regs.ioc_init_sem_reg);
+
+	return 0;
+}
+
+int
+bfa_nw_ioc_debug_fwtrc(struct bfa_ioc *ioc, void *trcdata, int *trclen)
+{
+	u32 loff = (BFI_IOC_TRC_OFF + BFA_DBG_FWTRC_LEN * (ioc->port_id));
+	int tlen, status = 0;
+
+	tlen = *trclen;
+	if (tlen > BFA_DBG_FWTRC_LEN)
+		tlen = BFA_DBG_FWTRC_LEN;
+
+	status = bfa_ioc_smem_read(ioc, trcdata, loff, tlen);
+	*trclen = tlen;
+	return status;
+}
+
+/**
+ * Retrieve saved firmware trace from a prior IOC failure.
+ */
+int
+bfa_nw_ioc_debug_fwsave(struct bfa_ioc *ioc, void *trcdata, int *trclen)
+{
+	int	tlen;
+
+	if (ioc->iocpf.auto_recover)
+		ioc->dbg_fwsave_len = BFA_DBG_FWTRC_LEN;
+	else
+		return BFA_STATUS_ENOFSAVE;
+
+	tlen = *trclen;
+	if (tlen > ioc->dbg_fwsave_len)
+		tlen = ioc->dbg_fwsave_len;
+
+	memcpy(trcdata, ioc->dbg_fwsave, tlen);
+	*trclen = tlen;
+	return BFA_STATUS_OK;
+}
+
 /**
  * Firmware failure detected. Start recovery actions.
  */
 static void
 bfa_ioc_recover(struct bfa_ioc *ioc)
 {
-	pr_crit("Heart Beat of IOC has failed\n");
+	pr_crit("bna: Heart Beat of IOC has failed for pci funtion %u\n",
+		ioc->pcidev.pci_func);
 	bfa_ioc_stats(ioc, ioc_hbfails);
 	bfa_fsm_send_event(ioc, IOC_E_HBFAIL);
 }
diff --git a/drivers/net/bna/bfa_ioc.h b/drivers/net/bna/bfa_ioc.h
index bd48abe..49739cd 100644
--- a/drivers/net/bna/bfa_ioc.h
+++ b/drivers/net/bna/bfa_ioc.h
@@ -19,6 +19,9 @@
 #ifndef __BFA_IOC_H__
 #define __BFA_IOC_H__
 
+#define BFA_DBG_FWTRC_LEN	(BFI_IOC_TRC_ENTS * BFI_IOC_TRC_ENT_SZ + \
+				BFI_IOC_TRC_HDR_SZ)
+
 #include "bfa_sm.h"
 #include "bfi.h"
 #include "cna.h"
@@ -274,6 +277,9 @@ void bfa_nw_ioc_fwver_get(struct bfa_ioc *ioc,
 bool bfa_nw_ioc_fwver_cmp(struct bfa_ioc *ioc,
 			struct bfi_ioc_image_hdr *fwhdr);
 mac_t bfa_nw_ioc_get_mac(struct bfa_ioc *ioc);
+void bfa_nw_ioc_debug_memclaim(struct bfa_ioc *ioc, void *dbg_fwsave);
+int bfa_nw_ioc_debug_fwtrc(struct bfa_ioc *ioc, void *trcdata, int *trclen);
+int bfa_nw_ioc_debug_fwsave(struct bfa_ioc *ioc, void *trcdata, int *trclen);
 
 /*
  * Timeout APIs
diff --git a/drivers/net/bna/bfi.h b/drivers/net/bna/bfi.h
index 6050379..ee73b6f 100644
--- a/drivers/net/bna/bfi.h
+++ b/drivers/net/bna/bfi.h
@@ -277,6 +277,8 @@ struct bfi_ioc_getattr_reply {
  */
 #define BFI_IOC_TRC_OFF		(0x4b00)
 #define BFI_IOC_TRC_ENTS	256
+#define BFI_IOC_TRC_ENT_SZ	16
+#define BFI_IOC_TRC_HDR_SZ	32
 
 #define BFI_IOC_FW_SIGNATURE	(0xbfadbfad)
 #define BFI_IOC_MD5SUM_SZ	4
diff --git a/drivers/net/bna/bna_ctrl.c b/drivers/net/bna/bna_ctrl.c
index 53b1416..a4833e3 100644
--- a/drivers/net/bna/bna_ctrl.c
+++ b/drivers/net/bna/bna_ctrl.c
@@ -1681,6 +1681,7 @@ bna_adv_device_init(struct bna_device *device, struct bna *bna,
 	device->bna = bna;
 
 	kva = res_info[BNA_RES_MEM_T_FWTRC].res_u.mem_info.mdl[0].kva;
+	bfa_nw_ioc_debug_memclaim(&device->ioc, kva);
 
 	/**
 	 * Attach common modules (Diag, SFP, CEE, Port) and claim respective
@@ -1820,8 +1821,8 @@ bna_adv_res_req(struct bna_res_info *res_info)
 	/* Virtual memory for retreiving fw_trc */
 	res_info[BNA_RES_MEM_T_FWTRC].res_type = BNA_RES_T_MEM;
 	res_info[BNA_RES_MEM_T_FWTRC].res_u.mem_info.mem_type = BNA_MEM_T_KVA;
-	res_info[BNA_RES_MEM_T_FWTRC].res_u.mem_info.num = 0;
-	res_info[BNA_RES_MEM_T_FWTRC].res_u.mem_info.len = 0;
+	res_info[BNA_RES_MEM_T_FWTRC].res_u.mem_info.num = 1;
+	res_info[BNA_RES_MEM_T_FWTRC].res_u.mem_info.len = BFA_DBG_FWTRC_LEN;
 
 	/* DMA memory for retreiving stats */
 	res_info[BNA_RES_MEM_T_STATS].res_type = BNA_RES_T_MEM;
diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index e588511..a997276 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -44,8 +44,12 @@ MODULE_PARM_DESC(bnad_ioc_auto_recover, "Enable / Disable auto recovery");
 /*
  * Global variables
  */
+u32 bna_id;
 u32 bnad_rxqs_per_cq = 2;
 
+struct mutex bnad_list_mutex;
+LIST_HEAD(bnad_list);
+
 static const u8 bnad_bcast_addr[] =  {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 
 /*
@@ -72,6 +76,23 @@ do {								\
 
 #define BNAD_TXRX_SYNC_MDELAY	250	/* 250 msecs */
 
+static void
+bnad_add_to_list(struct bnad *bnad)
+{
+	mutex_lock(&bnad_list_mutex);
+	list_add_tail(&bnad->list_entry, &bnad_list);
+	bnad->id = bna_id++;
+	mutex_unlock(&bnad_list_mutex);
+}
+
+static void
+bnad_remove_from_list(struct bnad *bnad)
+{
+	mutex_lock(&bnad_list_mutex);
+	list_del(&bnad->list_entry);
+	mutex_unlock(&bnad_list_mutex);
+}
+
 /*
  * Reinitialize completions in CQ, once Rx is taken down
  */
@@ -3087,6 +3108,8 @@ bnad_pci_probe(struct pci_dev *pdev,
 	}
 	bnad = netdev_priv(netdev);
 
+	bnad_add_to_list(bnad);
+
 	/*
 	 * PCI initialization
 	 * 	Output : using_dac = 1 for 64 bit DMA
@@ -3129,6 +3152,8 @@ bnad_pci_probe(struct pci_dev *pdev,
 	pcidev_info.device_id = bnad->pcidev->device;
 	pcidev_info.pci_bar_kva = bnad->bar0;
 
+	bnad_debugfs_init(bnad);
+
 	mutex_lock(&bnad->conf_mutex);
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
@@ -3169,7 +3194,7 @@ bnad_pci_probe(struct pci_dev *pdev,
 	/* Finally, reguister with net_device layer */
 	err = register_netdev(netdev);
 	if (err) {
-		pr_err("BNA : Registering with netdev failed\n");
+		pr_err("bna: Registering with netdev failed\n");
 		goto disable_device;
 	}
 
@@ -3189,6 +3214,8 @@ disable_device:
 	bnad_res_free(bnad);
 	bnad_disable_msix(bnad);
 pci_uninit:
+	bnad_debugfs_uninit(bnad);
+	bnad_remove_from_list(bnad);
 	bnad_pci_uninit(pdev);
 	bnad_lock_uninit(bnad);
 	bnad_uninit(bnad);
@@ -3226,6 +3253,8 @@ bnad_pci_remove(struct pci_dev *pdev)
 
 	bnad_res_free(bnad);
 	bnad_disable_msix(bnad);
+	bnad_debugfs_uninit(bnad);
+	bnad_remove_from_list(bnad);
 	bnad_pci_uninit(pdev);
 	bnad_lock_uninit(bnad);
 	bnad_uninit(bnad);
@@ -3255,13 +3284,14 @@ bnad_module_init(void)
 {
 	int err;
 
-	pr_info("Brocade 10G Ethernet driver\n");
+	pr_info("Brocade 10G Ethernet driver  - version: %s\n", BNAD_VERSION);
 
+	mutex_init(&bnad_list_mutex);
 	bfa_nw_ioc_auto_recover(bnad_ioc_auto_recover);
 
 	err = pci_register_driver(&bnad_pci_driver);
 	if (err < 0) {
-		pr_err("bna : PCI registration failed in module init "
+		pr_err("bna: PCI registration failed in module init "
 		       "(%d)\n", err);
 		return err;
 	}
@@ -3273,6 +3303,7 @@ static void __exit
 bnad_module_exit(void)
 {
 	pci_unregister_driver(&bnad_pci_driver);
+	mutex_destroy(&bnad_list_mutex);
 
 	if (bfi_fw)
 		release_firmware(bfi_fw);
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index ccdabad..2c1f283 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -279,13 +279,20 @@ struct bnad {
 	char			adapter_name[BNAD_NAME_LEN];
 	char 			port_name[BNAD_NAME_LEN];
 	char			mbox_irq_name[BNAD_NAME_LEN];
+
+	int			id;
+	struct list_head	list_entry;
+	struct dentry		*port_debugfs_root;
+	struct dentry		*bnad_dentry_files[2];
 };
 
 /*
  * EXTERN VARIABLES
  */
-extern struct firmware *bfi_fw;
-extern u32 		bnad_rxqs_per_cq;
+extern struct firmware		*bfi_fw;
+extern struct mutex		bnad_list_mutex;
+extern struct list_head		bnad_list;
+extern u32			bnad_rxqs_per_cq;
 
 /*
  * EXTERN PROTOTYPES
@@ -306,6 +313,10 @@ extern void bnad_cleanup_rx(struct bnad *bnad, uint rx_id);
 /* Timer start/stop protos */
 extern void bnad_dim_timer_start(struct bnad *bnad);
 
+/* Debugfs */
+extern void bnad_debugfs_init(struct bnad *bnad);
+extern void bnad_debugfs_uninit(struct bnad *bnad);
+
 /* Statistics */
 extern void bnad_netdev_qstats_fill(struct bnad *bnad,
 		struct rtnl_link_stats64 *stats);
diff --git a/drivers/net/bna/bnad_debugfs.c b/drivers/net/bna/bnad_debugfs.c
new file mode 100644
index 0000000..4351ca5
--- /dev/null
+++ b/drivers/net/bna/bnad_debugfs.c
@@ -0,0 +1,302 @@
+/*
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2011 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ */
+
+/*
+ * BNAD debufs interface
+ *
+ * To access the interface, debugfs file system should be mounted
+ * if not already mounted using:
+ *	mount -t debugfs none /sys/kernel/debug
+ *
+ * BNAD Hierarchy:
+ *	- bnad/pci_dev:<pci_name>
+ *	  where the pci_name corresponds to the one under
+ *	  /sys/bus/pci/drivers/bnad
+ *
+ * Debugging service available per pci_dev:
+ *	fwtrc:  To collect current firmware trace.
+ *	fwsave: To collect last saved fw trace as a result of firmware crash.
+ */
+#include <linux/debugfs.h>
+
+#include "bnad.h"
+
+struct bnad_debug_info {
+	char *debug_buffer;
+	int buffer_len;
+};
+
+struct bnad_debugfs_entry {
+	const char *name;
+	mode_t	mode;
+	const struct file_operations *fops;
+};
+
+static int
+bnad_debugfs_open_fwtrc(struct inode *inode, struct file *file)
+{
+	struct bnad *bnad = inode->i_private;
+	struct bnad_debug_info *fw_debug;
+	unsigned long flags;
+	int rc;
+
+	fw_debug = kzalloc(sizeof(struct bnad_debug_info), GFP_KERNEL);
+	if (!fw_debug)
+		return -ENOMEM;
+
+	fw_debug->buffer_len = BFA_DBG_FWTRC_LEN;
+
+	fw_debug->debug_buffer = kzalloc(fw_debug->buffer_len, GFP_KERNEL);
+	if (!fw_debug->debug_buffer) {
+		kfree(fw_debug);
+		fw_debug = NULL;
+		pr_warn("bnad[%d]: Failed to allocate fwtrc buffer\n",
+			bnad->id);
+		return -ENOMEM;
+	}
+
+	spin_lock_irqsave(&bnad->bna_lock, flags);
+	rc = bfa_nw_ioc_debug_fwtrc(&bnad->bna.device.ioc,
+			fw_debug->debug_buffer,
+			&fw_debug->buffer_len);
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
+	if (rc != BFA_STATUS_OK) {
+		kfree(fw_debug->debug_buffer);
+		fw_debug->debug_buffer = NULL;
+		kfree(fw_debug);
+		fw_debug = NULL;
+		pr_warn("bnad[%d]: Failed to collect fwtrc\n", bnad->id);
+		return -ENOMEM;
+	}
+
+	file->private_data = fw_debug;
+
+	return 0;
+}
+
+static int
+bnad_debugfs_open_fwsave(struct inode *inode, struct file *file)
+{
+	struct bnad *bnad = inode->i_private;
+	struct bnad_debug_info *fw_debug;
+	unsigned long flags;
+	int rc;
+
+	fw_debug = kzalloc(sizeof(struct bnad_debug_info), GFP_KERNEL);
+	if (!fw_debug)
+		return -ENOMEM;
+
+	fw_debug->buffer_len = BFA_DBG_FWTRC_LEN;
+
+	fw_debug->debug_buffer = kzalloc(fw_debug->buffer_len, GFP_KERNEL);
+	if (!fw_debug->debug_buffer) {
+		kfree(fw_debug);
+		fw_debug = NULL;
+		pr_warn("bnad[%d]: Failed to allocate fwsave buffer\n",
+			bnad->id);
+		return -ENOMEM;
+	}
+
+	spin_lock_irqsave(&bnad->bna_lock, flags);
+	rc = bfa_nw_ioc_debug_fwsave(&bnad->bna.device.ioc,
+			fw_debug->debug_buffer,
+			&fw_debug->buffer_len);
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
+	if (rc != BFA_STATUS_OK && rc != BFA_STATUS_ENOFSAVE) {
+		kfree(fw_debug->debug_buffer);
+		fw_debug->debug_buffer = NULL;
+		kfree(fw_debug);
+		fw_debug = NULL;
+		pr_warn("bnad[%d]: Failed to collect fwsave\n", bnad->id);
+		return -ENOMEM;
+	}
+
+	file->private_data = fw_debug;
+
+	return 0;
+}
+
+/* Changes the current file position */
+static loff_t
+bnad_debugfs_lseek(struct file *file, loff_t offset, int orig)
+{
+	loff_t pos = file->f_pos;
+	struct bnad_debug_info *debug = file->private_data;
+
+	if (!debug)
+		return -EINVAL;
+
+	switch (orig) {
+	case 0:
+		file->f_pos = offset;
+		break;
+	case 1:
+		file->f_pos += offset;
+		break;
+	case 2:
+		file->f_pos = debug->buffer_len - offset;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	if (file->f_pos < 0 || file->f_pos > debug->buffer_len) {
+		file->f_pos = pos;
+		return -EINVAL;
+	}
+
+	return file->f_pos;
+}
+
+static ssize_t
+bnad_debugfs_read(struct file *file, char __user *buf,
+			size_t nbytes, loff_t *pos)
+{
+	struct bnad_debug_info *debug = file->private_data;
+
+	if (!debug || !debug->debug_buffer)
+		return 0;
+
+	return simple_read_from_buffer(buf, nbytes, pos,
+				debug->debug_buffer, debug->buffer_len);
+}
+
+static int
+bnad_debugfs_release_fwtrc(struct inode *inode, struct file *file)
+{
+	struct bnad_debug_info *fw_debug = file->private_data;
+
+	if (!fw_debug)
+		return 0;
+
+	kfree(fw_debug->debug_buffer);
+
+	file->private_data = NULL;
+	kfree(fw_debug);
+	fw_debug = NULL;
+	return 0;
+}
+
+static const struct file_operations bnad_debugfs_op_fwtrc = {
+	.owner		=	THIS_MODULE,
+	.open		=	bnad_debugfs_open_fwtrc,
+	.llseek		=	bnad_debugfs_lseek,
+	.read		=	bnad_debugfs_read,
+	.release	=	bnad_debugfs_release_fwtrc,
+};
+
+static const struct file_operations bnad_debugfs_op_fwsave = {
+	.owner		=	THIS_MODULE,
+	.open		=	bnad_debugfs_open_fwsave,
+	.llseek		=	bnad_debugfs_lseek,
+	.read		=	bnad_debugfs_read,
+	.release	=	bnad_debugfs_release_fwtrc,
+};
+
+static const struct bnad_debugfs_entry bnad_debugfs_files[] = {
+	{ "fwtrc",  S_IFREG|S_IRUGO, &bnad_debugfs_op_fwtrc,  },
+	{ "fwsave", S_IFREG|S_IRUGO, &bnad_debugfs_op_fwsave, },
+};
+
+/* Global varibales */
+static struct dentry *bnad_debugfs_root;
+static atomic_t bnad_debugfs_port_count;
+
+/* Initialize debugfs interface for BNAD */
+void
+bnad_debugfs_init(struct bnad *bnad)
+{
+	const struct bnad_debugfs_entry *file;
+	char name[64];
+	int i;
+
+	/* Setup the BNAD debugfs root directory*/
+	mutex_lock(&bnad_list_mutex);
+	if (!bnad_debugfs_root) {
+		bnad_debugfs_root = debugfs_create_dir("bnad", NULL);
+		atomic_set(&bnad_debugfs_port_count, 0);
+		if (!bnad_debugfs_root) {
+			mutex_unlock(&bnad_list_mutex);
+			pr_warn("BNAD debugfs root dir creation failed\n");
+			return;
+		}
+	}
+	mutex_unlock(&bnad_list_mutex);
+
+	/* Setup the pci_dev debugfs directory for the port */
+	snprintf(name, sizeof(name), "pci_dev:%s", pci_name(bnad->pcidev));
+	if (!bnad->port_debugfs_root) {
+		bnad->port_debugfs_root =
+			debugfs_create_dir(name, bnad_debugfs_root);
+		if (!bnad->port_debugfs_root) {
+			pr_warn("BNAD pci_dev:%s root dir creation failed\n",
+			       pci_name(bnad->pcidev));
+			return;
+		}
+
+		atomic_inc(&bnad_debugfs_port_count);
+
+		for (i = 0; i < ARRAY_SIZE(bnad_debugfs_files); i++) {
+			file = &bnad_debugfs_files[i];
+			bnad->bnad_dentry_files[i] =
+					debugfs_create_file(file->name,
+							file->mode,
+							bnad->port_debugfs_root,
+							bnad,
+							file->fops);
+			if (!bnad->bnad_dentry_files[i]) {
+				pr_warn(
+				       "BNAD pci_dev:%s: create %s entry \
+failed\n", pci_name(bnad->pcidev), file->name);
+				return;
+			}
+		}
+	}
+
+	pr_info("bnad[%d]: Initialized debugfs interface\n", bnad->id);
+}
+
+/* Uninitialize debugfs interface for BNAD */
+void
+bnad_debugfs_uninit(struct bnad *bnad)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(bnad_debugfs_files); i++) {
+		if (bnad->bnad_dentry_files[i]) {
+			debugfs_remove(bnad->bnad_dentry_files[i]);
+			bnad->bnad_dentry_files[i] = NULL;
+		}
+	}
+
+	/* Remove the pci_dev debugfs directory for the port */
+	if (bnad->port_debugfs_root) {
+		debugfs_remove(bnad->port_debugfs_root);
+		bnad->port_debugfs_root = NULL;
+		atomic_dec(&bnad_debugfs_port_count);
+	}
+
+	/* Remove the BNAD debugfs root directory */
+	mutex_lock(&bnad_list_mutex);
+	if (atomic_read(&bnad_debugfs_port_count) == 0) {
+		debugfs_remove(bnad_debugfs_root);
+		bnad_debugfs_root = NULL;
+	}
+	mutex_unlock(&bnad_list_mutex);
+	pr_info("bnad[%d]: Uninitialized debugfs interface\n", bnad->id);
+}
-- 
1.7.1

