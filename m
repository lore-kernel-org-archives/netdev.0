From: Praveen Madhavan <praveenm@chelsio.com>
Subject: [PATCH 2/3] csiostor:Cleanup debugfs.
Date: Tue,  9 Jun 2015 18:44:45 +0530
Message-ID: <1433855686-15768-3-git-send-email-praveenm@chelsio.com>
References: <1433855686-15768-1-git-send-email-praveenm@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com,
	hariprasad@chelsio.com, praveenm@chelsio.com, varun@chelsio.com,
	rajesh.kumar@chelsio.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1433855686-15768-1-git-send-email-praveenm@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch cleanup existing debugfs. Debugfs support is moved
into to new file in next patch of this series.

Signed-off-by: Praveen Madhavan <praveenm@chelsio.com>
---
 drivers/scsi/csiostor/csio_init.c | 132 --------------------------------------
 drivers/scsi/csiostor/csio_init.h |   4 ++
 2 files changed, 4 insertions(+), 132 deletions(-)

diff --git a/drivers/scsi/csiostor/csio_init.c b/drivers/scsi/csiostor/csio_init.c
index dbe416f..48e0159 100644
--- a/drivers/scsi/csiostor/csio_init.c
+++ b/drivers/scsi/csiostor/csio_init.c
@@ -43,7 +43,6 @@
 #include <linux/notifier.h>
 #include <linux/kdebug.h>
 #include <linux/seq_file.h>
-#include <linux/debugfs.h>
 #include <linux/string.h>
 #include <linux/export.h>
 
@@ -52,141 +51,10 @@
 
 #define CSIO_MIN_MEMPOOL_SZ	64
 
-static struct dentry *csio_debugfs_root;
-
 static struct scsi_transport_template *csio_fcoe_transport;
 static struct scsi_transport_template *csio_fcoe_transport_vport;
 
 /*
- * debugfs support
- */
-static ssize_t
-csio_mem_read(struct file *file, char __user *buf, size_t count, loff_t *ppos)
-{
-	loff_t pos = *ppos;
-	loff_t avail = file_inode(file)->i_size;
-	unsigned int mem = (uintptr_t)file->private_data & 3;
-	struct csio_hw *hw = file->private_data - mem;
-
-	if (pos < 0)
-		return -EINVAL;
-	if (pos >= avail)
-		return 0;
-	if (count > avail - pos)
-		count = avail - pos;
-
-	while (count) {
-		size_t len;
-		int ret, ofst;
-		__be32 data[16];
-
-		if (mem == MEM_MC)
-			ret = hw->chip_ops->chip_mc_read(hw, 0, pos,
-							 data, NULL);
-		else
-			ret = hw->chip_ops->chip_edc_read(hw, mem, pos,
-							  data, NULL);
-		if (ret)
-			return ret;
-
-		ofst = pos % sizeof(data);
-		len = min(count, sizeof(data) - ofst);
-		if (copy_to_user(buf, (u8 *)data + ofst, len))
-			return -EFAULT;
-
-		buf += len;
-		pos += len;
-		count -= len;
-	}
-	count = pos - *ppos;
-	*ppos = pos;
-	return count;
-}
-
-static const struct file_operations csio_mem_debugfs_fops = {
-	.owner   = THIS_MODULE,
-	.open    = simple_open,
-	.read    = csio_mem_read,
-	.llseek  = default_llseek,
-};
-
-void csio_add_debugfs_mem(struct csio_hw *hw, const char *name,
-				 unsigned int idx, unsigned int size_mb)
-{
-	debugfs_create_file_size(name, S_IRUSR, hw->debugfs_root,
-				 (void *)hw + idx, &csio_mem_debugfs_fops,
-				 size_mb << 20);
-}
-
-static int csio_setup_debugfs(struct csio_hw *hw)
-{
-	int i;
-
-	if (IS_ERR_OR_NULL(hw->debugfs_root))
-		return -1;
-
-	i = csio_rd_reg32(hw, MA_TARGET_MEM_ENABLE_A);
-	if (i & EDRAM0_ENABLE_F)
-		csio_add_debugfs_mem(hw, "edc0", MEM_EDC0, 5);
-	if (i & EDRAM1_ENABLE_F)
-		csio_add_debugfs_mem(hw, "edc1", MEM_EDC1, 5);
-
-	hw->chip_ops->chip_dfs_create_ext_mem(hw);
-	return 0;
-}
-
-/*
- * csio_dfs_create - Creates and sets up per-hw debugfs.
- *
- */
-static int
-csio_dfs_create(struct csio_hw *hw)
-{
-	if (csio_debugfs_root) {
-		hw->debugfs_root = debugfs_create_dir(pci_name(hw->pdev),
-							csio_debugfs_root);
-		csio_setup_debugfs(hw);
-	}
-
-	return 0;
-}
-
-/*
- * csio_dfs_destroy - Destroys per-hw debugfs.
- */
-static int
-csio_dfs_destroy(struct csio_hw *hw)
-{
-	if (hw->debugfs_root)
-		debugfs_remove_recursive(hw->debugfs_root);
-
-	return 0;
-}
-
-/*
- * csio_dfs_init - Debug filesystem initialization for the module.
- *
- */
-static int
-csio_dfs_init(void)
-{
-	csio_debugfs_root = debugfs_create_dir(KBUILD_MODNAME, NULL);
-	if (!csio_debugfs_root)
-		pr_warn("Could not create debugfs entry, continuing\n");
-
-	return 0;
-}
-
-/*
- * csio_dfs_exit - debugfs cleanup for the module.
- */
-static void
-csio_dfs_exit(void)
-{
-	debugfs_remove(csio_debugfs_root);
-}
-
-/*
  * csio_pci_init - PCI initialization.
  * @pdev: PCI device.
  * @bars: Bitmask of bars to be requested.
diff --git a/drivers/scsi/csiostor/csio_init.h b/drivers/scsi/csiostor/csio_init.h
index 5cc5d31..5de485f 100644
--- a/drivers/scsi/csiostor/csio_init.h
+++ b/drivers/scsi/csiostor/csio_init.h
@@ -78,6 +78,10 @@ void csio_lnodes_exit(struct csio_hw *, bool);
 /* DebugFS helper routines */
 void csio_add_debugfs_mem(struct csio_hw *, const char *,
 		unsigned int, unsigned int);
+int csio_dfs_create(struct csio_hw *);
+int csio_dfs_destroy(struct csio_hw *);
+int csio_dfs_init(void);
+void csio_dfs_exit(void);
 
 static inline struct Scsi_Host *
 csio_ln_to_shost(struct csio_lnode *ln)
-- 
2.0.2

