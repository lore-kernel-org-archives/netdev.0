From: Catherine Sullivan <catherine.sullivan@intel.com>
Subject: [NET_NEXT RFC PATCH 2/3] ixgbe: added netdev_ops file to debugfs
Date: Wed, 09 May 2012 16:09:45 -0700
Message-ID: <20120509230945.31910.48302.stgit@localhost6.localdomain6>
References: <20120509230814.31910.80709.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:23540 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750971Ab2EIXGn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 19:06:43 -0400
In-Reply-To: <20120509230814.31910.80709.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added the netdev_ops file to debugfs with a command to call the
ndo_tx_timeout function to give users the ability to simulate a
tx_timeout call made by the kernel.

Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c |  103 ++++++++++++++++++++++
 1 files changed, 101 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
index 423700f..dfe68a9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
@@ -34,6 +34,103 @@
 
 static struct dentry *ixgbe_dbg_root;
 
+static char ixgbe_dbg_netdev_ops_buf[256] = "";
+
+/**
+ * ixgbe_dbg_netdev_ops_open - prep the debugfs netdev_ops data item
+ *			       when opened
+ * @inode: inode that was opened
+ * @filp: file info
+ *
+ * Stash the adapter pointer hiding in the inode into the file pointer
+ * where we can find it later in the read and write calls
+ **/
+static int ixgbe_dbg_netdev_ops_open(struct inode *inode, struct file *filp)
+{
+	filp->private_data = inode->i_private;
+	return 0;
+}
+
+/**
+ * ixgbe_dbg_netdev_ops_read - read for netdev_ops datum
+ * @filp: the opened file
+ * @buffer: where to write the data for the user to read
+ * @count: the size of the user's buffer
+ * @ppos: file position offset
+ **/
+static ssize_t ixgbe_dbg_netdev_ops_read(struct file *filp,
+					 char __user *buffer,
+					 size_t count, loff_t *ppos)
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
+		       adapter->netdev->name, ixgbe_dbg_netdev_ops_buf);
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
+ * ixgbe_dbg_netdev_ops_write - write into netdev_ops datum
+ * @filp: the opened file
+ * @buffer: where to find the user's data
+ * @count: the length of the user's data
+ * @ppos: file position offset
+ **/
+static ssize_t ixgbe_dbg_netdev_ops_write(struct file *filp,
+					  const char __user *buffer,
+					  size_t count, loff_t *ppos)
+{
+	struct ixgbe_adapter *adapter = filp->private_data;
+	int bytes_not_copied;
+
+	/* don't allow partial writes */
+	if (*ppos != 0)
+		return 0;
+	if (count >= sizeof(ixgbe_dbg_netdev_ops_buf))
+		return -ENOSPC;
+
+	bytes_not_copied = copy_from_user(ixgbe_dbg_netdev_ops_buf,
+					  buffer, count);
+	if (bytes_not_copied < 0)
+		return bytes_not_copied;
+	else if (bytes_not_copied > 0)
+		count -= bytes_not_copied;
+	if (count < 0)
+		return -ENOSPC;
+	ixgbe_dbg_netdev_ops_buf[count] = '\0';
+
+	if (strncmp(ixgbe_dbg_netdev_ops_buf, "tx_timeout", 10) == 0) {
+		adapter->netdev->netdev_ops->ndo_tx_timeout(adapter->netdev);
+		e_dev_info("tx_timeout called\n");
+	} else {
+		e_dev_info("Unkown command: %s\n", ixgbe_dbg_netdev_ops_buf);
+		e_dev_info("Available commands:\n");
+		e_dev_info("    tx_timeout\n");
+	}
+	return count;
+}
+
+static const struct file_operations ixgbe_dbg_netdev_ops_fops = {
+	.owner = THIS_MODULE,
+	.open = ixgbe_dbg_netdev_ops_open,
+	.read = ixgbe_dbg_netdev_ops_read,
+	.write = ixgbe_dbg_netdev_ops_write,
+};
+
 /**
  * ixgbe_dbg_adapter_init - setup the debugfs directory for the adapter
  * @adapter: the adapter that is starting up
@@ -41,10 +138,12 @@ static struct dentry *ixgbe_dbg_root;
 void ixgbe_dbg_adapter_init(struct ixgbe_adapter *adapter)
 {
 	const char *name = pci_name(adapter->pdev);
-
+	struct dentry *pfile;
 	adapter->ixgbe_dbg_adapter = debugfs_create_dir(name, ixgbe_dbg_root);
 	if (adapter->ixgbe_dbg_adapter) {
-		/* create files here */
+		pfile = debugfs_create_file("netdev_ops", 0600,
+					    adapter->ixgbe_dbg_adapter, adapter,
+					    &ixgbe_dbg_netdev_ops_fops);
 	} else {
 		e_dev_err("debugfs entry for %s failed\n", name);
 	}
