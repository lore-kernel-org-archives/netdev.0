From: Catherine Sullivan <catherine.sullivan@intel.com>
Subject: [NET_NEXT RFC PATCH 3/3] ixgbe: added reg_ops file to debugfs
Date: Wed, 09 May 2012 16:09:50 -0700
Message-ID: <20120509230950.31910.6032.stgit@localhost6.localdomain6>
References: <20120509230814.31910.80709.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56859 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759092Ab2EIXGn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 19:06:43 -0400
In-Reply-To: <20120509230814.31910.80709.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added the reg_ops file to debugfs with commands to read and write
a register to give users the ability to read and write individual
registers on the fly.

Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c |  112 ++++++++++++++++++++++
 1 files changed, 112 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
index dfe68a9..2558014 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
@@ -34,6 +34,115 @@
 
 static struct dentry *ixgbe_dbg_root;
 
+static char ixgbe_dbg_reg_ops_buf[256] = "";
+
+/**
+ * ixgbe_dbg_reg_ops_open - prep the debugfs pokee data item when opened
+ * @inode: inode that was opened
+ * @filp:  file info
+ *
+ * Stash the adapter pointer hiding in the inode into the file pointer where
+ * we can find it later in the read and write calls
+ **/
+static int ixgbe_dbg_reg_ops_open(struct inode *inode, struct file *filp)
+{
+	filp->private_data = inode->i_private;
+	return 0;
+}
+
+/**
+ * ixgbe_dbg_reg_ops_read - read for reg_ops datum
+ * @filp: the opened file
+ * @buffer: where to write the data for the user to read
+ * @count: the size of the user's buffer
+ * @ppos: file position offset
+ **/
+static ssize_t ixgbe_dbg_reg_ops_read(struct file *filp, char __user *buffer,
+				    size_t count, loff_t *ppos)
+{
+	struct ixgbe_adapter *adapter = filp->private_data;
+	char buf[256];
+	int bytes_not_copied;
+	int len;
+
+	/* don't allow partial reads */
+	if (*ppos != 0)
+		return 0;
+
+	len = snprintf(buf, sizeof(buf), "%s: %s\n",
+		       adapter->netdev->name, ixgbe_dbg_reg_ops_buf);
+	if (count < len)
+		return -ENOSPC;
+	bytes_not_copied = copy_to_user(buffer, buf, len);
+	if (bytes_not_copied < 0)
+		return bytes_not_copied;
+
+	*ppos = len;
+	return len;
+}
+
+/**
+ * ixgbe_dbg_reg_ops_write - write into reg_ops datum
+ * @filp: the opened file
+ * @buffer: where to find the user's data
+ * @count: the length of the user's data
+ * @ppos: file position offset
+ **/
+static ssize_t ixgbe_dbg_reg_ops_write(struct file *filp,
+				     const char __user *buffer,
+				     size_t count, loff_t *ppos)
+{
+	struct ixgbe_adapter *adapter = filp->private_data;
+	int bytes_not_copied;
+
+	/* don't allow partial writes */
+	if (*ppos != 0)
+		return 0;
+	if (count >= sizeof(ixgbe_dbg_reg_ops_buf))
+		return -ENOSPC;
+
+	bytes_not_copied = copy_from_user(ixgbe_dbg_reg_ops_buf, buffer, count);
+	if (bytes_not_copied < 0)
+		return bytes_not_copied;
+	ixgbe_dbg_reg_ops_buf[count] = '\0';
+
+	if (strncmp(ixgbe_dbg_reg_ops_buf, "write", 5) == 0) {
+		u32 reg, value;
+		int cnt;
+		cnt = sscanf(&ixgbe_dbg_reg_ops_buf[5], "%x %x", &reg, &value);
+		if (cnt == 2) {
+			IXGBE_WRITE_REG(&adapter->hw, reg, value);
+			value = IXGBE_READ_REG(&adapter->hw, reg);
+			e_dev_info("write: 0x%08x = 0x%08x\n", reg, value);
+		} else {
+			e_dev_info("write reg value\n");
+		}
+	} else if (strncmp(ixgbe_dbg_reg_ops_buf, "read", 4) == 0) {
+		u32 reg, value;
+		int cnt;
+		cnt = sscanf(&ixgbe_dbg_reg_ops_buf[4], "%x", &reg);
+		if (cnt == 1) {
+			value = IXGBE_READ_REG(&adapter->hw, reg);
+			e_dev_info("read 0x%08x = 0x%08x\n", reg, value);
+		} else {
+			e_dev_info("read reg\n");
+		}
+	} else {
+		e_dev_info("Unknown command %s\n", ixgbe_dbg_reg_ops_buf);
+		e_dev_info("Available commands:\n");
+		e_dev_info("   read reg\n");
+		e_dev_info("   write reg value\n");
+	}
+	return count;
+}
+
+static const struct file_operations ixgbe_dbg_reg_ops_fops = {
+	.owner = THIS_MODULE,
+	.open =  ixgbe_dbg_reg_ops_open,
+	.read =  ixgbe_dbg_reg_ops_read,
+	.write = ixgbe_dbg_reg_ops_write,
+};
+
 static char ixgbe_dbg_netdev_ops_buf[256] = "";
 
 /**
@@ -141,6 +250,9 @@ void ixgbe_dbg_adapter_init(struct ixgbe_adapter *adapter)
 	struct dentry *pfile;
 	adapter->ixgbe_dbg_adapter = debugfs_create_dir(name, ixgbe_dbg_root);
 	if (adapter->ixgbe_dbg_adapter) {
+		pfile = debugfs_create_file("reg_ops", 0600,
+					    adapter->ixgbe_dbg_adapter, adapter,
+					    &ixgbe_dbg_reg_ops_fops);
 		pfile = debugfs_create_file("netdev_ops", 0600,
 					    adapter->ixgbe_dbg_adapter, adapter,
 					    &ixgbe_dbg_netdev_ops_fops);
