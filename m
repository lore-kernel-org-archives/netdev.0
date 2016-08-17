From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next] xen-netback: create a debugfs node for hash information
Date: Wed, 17 Aug 2016 16:13:29 +0100
Message-ID: <1471446809-4845-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:56862 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752106AbcHQPbb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2016 11:31:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is useful to be able to see the hash configuration when running tests.
This patch adds a debugfs node for that purpose.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h |  4 +++
 drivers/net/xen-netback/hash.c   | 68 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/xen-netback/xenbus.c | 37 ++++++++++++++++++++--
 3 files changed, 107 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 84d6cbd..3a56268 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -412,4 +412,8 @@ u32 xenvif_set_hash_mapping(struct xenvif *vif, u32 gref, u32 len,
 
 void xenvif_set_skb_hash(struct xenvif *vif, struct sk_buff *skb);
 
+#ifdef CONFIG_DEBUG_FS
+void xenvif_dump_hash_info(struct xenvif *vif, struct seq_file *m);
+#endif
+
 #endif /* __XEN_NETBACK__COMMON_H__ */
diff --git a/drivers/net/xen-netback/hash.c b/drivers/net/xen-netback/hash.c
index fb87cb3..282b16d 100644
--- a/drivers/net/xen-netback/hash.c
+++ b/drivers/net/xen-netback/hash.c
@@ -369,6 +369,74 @@ u32 xenvif_set_hash_mapping(struct xenvif *vif, u32 gref, u32 len,
 	return XEN_NETIF_CTRL_STATUS_SUCCESS;
 }
 
+#ifdef CONFIG_DEBUG_FS
+void xenvif_dump_hash_info(struct xenvif *vif, struct seq_file *m)
+{
+	unsigned int i;
+
+	switch (vif->hash.alg) {
+	case XEN_NETIF_CTRL_HASH_ALGORITHM_TOEPLITZ:
+		seq_puts(m, "Hash Algorithm: TOEPLITZ\n");
+		break;
+
+	case XEN_NETIF_CTRL_HASH_ALGORITHM_NONE:
+		seq_puts(m, "Hash Algorithm: NONE\n");
+		/* FALLTHRU */
+	default:
+		return;
+	}
+
+	if (vif->hash.flags) {
+		seq_puts(m, "\nHash Flags:\n");
+
+		if (vif->hash.flags & XEN_NETIF_CTRL_HASH_TYPE_IPV4)
+			seq_puts(m, "- IPv4\n");
+		if (vif->hash.flags & XEN_NETIF_CTRL_HASH_TYPE_IPV4_TCP)
+			seq_puts(m, "- IPv4 + TCP\n");
+		if (vif->hash.flags & XEN_NETIF_CTRL_HASH_TYPE_IPV6)
+			seq_puts(m, "- IPv6\n");
+		if (vif->hash.flags & XEN_NETIF_CTRL_HASH_TYPE_IPV6_TCP)
+			seq_puts(m, "- IPv6 + TCP\n");
+	}
+
+	seq_puts(m, "\nHash Key:\n");
+
+	for (i = 0; i < XEN_NETBK_MAX_HASH_KEY_SIZE; ) {
+		unsigned int j, n;
+
+		n = 8;
+		if (i + n >= XEN_NETBK_MAX_HASH_KEY_SIZE)
+			n = XEN_NETBK_MAX_HASH_KEY_SIZE - i;
+
+		seq_printf(m, "[%2u - %2u]: ", i, i + n - 1);
+
+		for (j = 0; j < n; j++, i++)
+			seq_printf(m, "%02x ", vif->hash.key[i]);
+
+		seq_puts(m, "\n");
+	}
+
+	if (vif->hash.size != 0) {
+		seq_puts(m, "\nHash Mapping:\n");
+
+		for (i = 0; i < vif->hash.size; ) {
+			unsigned int j, n;
+
+			n = 8;
+			if (i + n >= vif->hash.size)
+				n = vif->hash.size - i;
+
+			seq_printf(m, "[%4u - %4u]: ", i, i + n - 1);
+
+			for (j = 0; j < n; j++, i++)
+				seq_printf(m, "%4u ", vif->hash.mapping[i]);
+
+			seq_puts(m, "\n");
+		}
+	}
+}
+#endif /* CONFIG_DEBUG_FS */
+
 void xenvif_init_hash(struct xenvif *vif)
 {
 	if (xenvif_hash_cache_size == 0)
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 6a31f26..bacf6e0 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -165,7 +165,7 @@ xenvif_write_io_ring(struct file *filp, const char __user *buf, size_t count,
 	return count;
 }
 
-static int xenvif_dump_open(struct inode *inode, struct file *filp)
+static int xenvif_io_ring_open(struct inode *inode, struct file *filp)
 {
 	int ret;
 	void *queue = NULL;
@@ -179,13 +179,35 @@ static int xenvif_dump_open(struct inode *inode, struct file *filp)
 
 static const struct file_operations xenvif_dbg_io_ring_ops_fops = {
 	.owner = THIS_MODULE,
-	.open = xenvif_dump_open,
+	.open = xenvif_io_ring_open,
 	.read = seq_read,
 	.llseek = seq_lseek,
 	.release = single_release,
 	.write = xenvif_write_io_ring,
 };
 
+static int xenvif_read_ctrl(struct seq_file *m, void *v)
+{
+	struct xenvif *vif = m->private;
+
+	xenvif_dump_hash_info(vif, m);
+
+	return 0;
+}
+
+static int xenvif_ctrl_open(struct inode *inode, struct file *filp)
+{
+	return single_open(filp, xenvif_read_ctrl, inode->i_private);
+}
+
+static const struct file_operations xenvif_dbg_ctrl_ops_fops = {
+	.owner = THIS_MODULE,
+	.open = xenvif_ctrl_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
 static void xenvif_debugfs_addif(struct xenvif *vif)
 {
 	struct dentry *pfile;
@@ -210,6 +232,17 @@ static void xenvif_debugfs_addif(struct xenvif *vif)
 				pr_warn("Creation of io_ring file returned %ld!\n",
 					PTR_ERR(pfile));
 		}
+
+		if (vif->ctrl_task) {
+			pfile = debugfs_create_file("ctrl",
+						    S_IRUSR,
+						    vif->xenvif_dbg_root,
+						    vif,
+						    &xenvif_dbg_ctrl_ops_fops);
+			if (IS_ERR_OR_NULL(pfile))
+				pr_warn("Creation of ctrl file returned %ld!\n",
+					PTR_ERR(pfile));
+		}
 	} else
 		netdev_warn(vif->dev,
 			    "Creation of vif debugfs dir returned %ld!\n",
-- 
2.1.4
