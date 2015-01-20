From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/2] cxgb4: Add debugfs entry to dump the contents of the flash
Date: Tue, 20 Jan 2015 12:02:20 +0530
Message-ID: <1421735541-32400-2-git-send-email-hariprasad@chelsio.com>
References: <1421735541-32400-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:3987 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752799AbbATG0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 01:26:50 -0500
In-Reply-To: <1421735541-32400-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support to dump the contents of the flash in the adapter

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    3 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   73 +++++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h |    3 +
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |   28 +++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |    6 ++
 5 files changed, 110 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index e468f92..29c5232 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1008,7 +1008,10 @@ static inline int t4_memory_write(struct adapter *adap, int mtype, u32 addr,
 
 int t4_seeprom_wp(struct adapter *adapter, bool enable);
 int get_vpd_params(struct adapter *adapter, struct vpd_params *p);
+int t4_read_flash(struct adapter *adapter, unsigned int addr,
+		  unsigned int nwords, u32 *data, int byte_oriented);
 int t4_load_fw(struct adapter *adapter, const u8 *fw_data, unsigned int size);
+int t4_fwcache(struct adapter *adap, enum fw_params_param_dev_fwcache op);
 int t4_fw_upgrade(struct adapter *adap, unsigned int mbox,
 		  const u8 *fw_data, unsigned int size, int force);
 unsigned int t4_flash_cfg_addr(struct adapter *adapter);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 6dabfe5..8b2e230 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -434,6 +434,51 @@ static const struct file_operations devlog_fops = {
 	.release = seq_release_private
 };
 
+static ssize_t flash_read(struct file *file, char __user *buf, size_t count,
+			  loff_t *ppos)
+{
+	loff_t pos = *ppos;
+	loff_t avail = FILE_DATA(file)->i_size;
+	struct adapter *adap = file->private_data;
+
+	if (pos < 0)
+		return -EINVAL;
+	if (pos >= avail)
+		return 0;
+	if (count > avail - pos)
+		count = avail - pos;
+
+	while (count) {
+		size_t len;
+		int ret, ofst;
+		u8 data[256];
+
+		ofst = pos & 3;
+		len = min(count + ofst, sizeof(data));
+		ret = t4_read_flash(adap, pos - ofst, (len + 3) / 4,
+				    (u32 *)data, 1);
+		if (ret)
+			return ret;
+
+		len -= ofst;
+		if (copy_to_user(buf, data + ofst, len))
+			return -EFAULT;
+
+		buf += len;
+		pos += len;
+		count -= len;
+	}
+	count = pos - *ppos;
+	*ppos = pos;
+	return count;
+}
+
+static const struct file_operations flash_debugfs_fops = {
+	.owner   = THIS_MODULE,
+	.open    = mem_open,
+	.read    = flash_read,
+};
+
 static inline void tcamxy2valmask(u64 x, u64 y, u8 *addr, u64 *mask)
 {
 	*mask = x | y;
@@ -579,6 +624,21 @@ static const struct file_operations clip_tbl_debugfs_fops = {
 };
 #endif
 
+int mem_open(struct inode *inode, struct file *file)
+{
+	unsigned int mem;
+	struct adapter *adap;
+
+	file->private_data = inode->i_private;
+
+	mem = (uintptr_t)file->private_data & 0x3;
+	adap = file->private_data - mem;
+
+	(void)t4_fwcache(adap, FW_PARAM_DEV_FWCACHE_FLUSH);
+
+	return 0;
+}
+
 static ssize_t mem_read(struct file *file, char __user *buf, size_t count,
 			loff_t *ppos)
 {
@@ -616,7 +676,6 @@ static ssize_t mem_read(struct file *file, char __user *buf, size_t count,
 	*ppos = pos + count;
 	return count;
 }
-
 static const struct file_operations mem_debugfs_fops = {
 	.owner   = THIS_MODULE,
 	.open    = simple_open,
@@ -624,6 +683,12 @@ static const struct file_operations mem_debugfs_fops = {
 	.llseek  = default_llseek,
 };
 
+static void set_debugfs_file_size(struct dentry *de, loff_t size)
+{
+	if (!IS_ERR(de) && de->d_inode)
+		de->d_inode->i_size = size;
+}
+
 static void add_debugfs_mem(struct adapter *adap, const char *name,
 			    unsigned int idx, unsigned int size_mb)
 {
@@ -655,6 +720,7 @@ int t4_setup_debugfs(struct adapter *adap)
 {
 	int i;
 	u32 size;
+	struct dentry *de;
 
 	static struct t4_debugfs_entry t4_debugfs_files[] = {
 		{ "cim_la", &cim_la_fops, S_IRUSR, 0 },
@@ -697,5 +763,10 @@ int t4_setup_debugfs(struct adapter *adap)
 					EXT_MEM1_SIZE_G(size));
 		}
 	}
+
+	de = debugfs_create_file("flash", S_IRUSR, adap->debugfs_root, adap,
+				 &flash_debugfs_fops);
+	set_debugfs_file_size(de, adap->params.sf_size);
+
 	return 0;
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h
index 70fcbc9..e162c61 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h
@@ -37,6 +37,8 @@
 
 #include <linux/export.h>
 
+#define FILE_DATA(_file) ((_file)->f_path.dentry->d_inode)
+
 struct t4_debugfs_entry {
 	const char *name;
 	const struct file_operations *ops;
@@ -60,5 +62,6 @@ int t4_setup_debugfs(struct adapter *adap);
 void add_debugfs_files(struct adapter *adap,
 		       struct t4_debugfs_entry *files,
 		       unsigned int nfiles);
+int mem_open(struct inode *inode, struct file *file);
 
 #endif
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 734d33e..73da6f5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -835,8 +835,8 @@ static int flash_wait_op(struct adapter *adapter, int attempts, int delay)
  *	(i.e., big-endian), otherwise as 32-bit words in the platform's
  *	natural endianess.
  */
-static int t4_read_flash(struct adapter *adapter, unsigned int addr,
-			 unsigned int nwords, u32 *data, int byte_oriented)
+int t4_read_flash(struct adapter *adapter, unsigned int addr,
+		  unsigned int nwords, u32 *data, int byte_oriented)
 {
 	int ret;
 
@@ -1239,6 +1239,30 @@ out:
 	return ret;
 }
 
+/**
+ *	t4_fwcache - firmware cache operation
+ *	@adap: the adapter
+ *	@op  : the operation (flush or flush and invalidate)
+ */
+int t4_fwcache(struct adapter *adap, enum fw_params_param_dev_fwcache op)
+{
+	struct fw_params_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_vfn =
+		cpu_to_be32(FW_CMD_OP_V(FW_PARAMS_CMD) |
+			    FW_CMD_REQUEST_F | FW_CMD_WRITE_F |
+			    FW_PARAMS_CMD_PFN_V(adap->fn) |
+			    FW_PARAMS_CMD_VFN_V(0));
+	c.retval_len16 = cpu_to_be32(FW_LEN16(c));
+	c.param[0].mnem =
+		cpu_to_be32(FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
+			    FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_FWCACHE));
+	c.param[0].val = (__force __be32)op;
+
+	return t4_wr_mbox(adap, adap->mbox, &c, sizeof(c), NULL);
+}
+
 #define ADVERT_MASK (FW_PORT_CAP_SPEED_100M | FW_PORT_CAP_SPEED_1G |\
 		     FW_PORT_CAP_SPEED_10G | FW_PORT_CAP_SPEED_40G | \
 		     FW_PORT_CAP_ANEG)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index de82833..1e72cda 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -1062,6 +1062,7 @@ enum fw_params_param_dev {
 	FW_PARAMS_PARAM_DEV_MAXORDIRD_QP = 0x13, /* max supported QP IRD/ORD */
 	FW_PARAMS_PARAM_DEV_MAXIRD_ADAPTER = 0x14, /* max supported adap IRD */
 	FW_PARAMS_PARAM_DEV_ULPTX_MEMWRITE_DSGL = 0x17,
+	FW_PARAMS_PARAM_DEV_FWCACHE = 0x18,
 };
 
 /*
@@ -1121,6 +1122,11 @@ enum fw_params_param_dmaq {
 	FW_PARAMS_PARAM_DMAQ_EQ_DCBPRIO_ETH = 0x13,
 };
 
+enum fw_params_param_dev_fwcache {
+	FW_PARAM_DEV_FWCACHE_FLUSH      = 0x00,
+	FW_PARAM_DEV_FWCACHE_FLUSHINV   = 0x01,
+};
+
 #define FW_PARAMS_MNEM_S	24
 #define FW_PARAMS_MNEM_V(x)	((x) << FW_PARAMS_MNEM_S)
 
-- 
1.7.1
