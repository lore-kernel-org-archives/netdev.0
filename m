From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next] xen-netback: Adding debugfs "io_ring_qX" files
Date: Mon, 30 Jun 2014 21:33:31 +0100
Message-ID: <1404160411-23747-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds debugfs capabilities to netback. There used to be a similar
patch floating around for classic kernel, but it used procfs. It is based on a
very similar blkback patch.
It creates xen-netback/[vifname]/io_ring_q[queueno] files, reading them output
various ring variables etc. Writing "kick" into it imitates an interrupt
happened, it can be useful to check whether the ring is just stalled due to a
missed interrupt.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org


diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 2532ce8..b510aba 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -44,6 +44,7 @@
 #include <xen/interface/grant_table.h>
 #include <xen/grant_table.h>
 #include <xen/xenbus.h>
+#include <linux/debugfs.h>
 
 typedef unsigned int pending_ring_idx_t;
 #define INVALID_PENDING_RING_IDX (~0U)
@@ -224,6 +225,8 @@ struct xenvif {
 	struct xenvif_queue *queues;
 	unsigned int num_queues; /* active queues, resource allocated */
 
+	struct dentry *xenvif_dbg_root;
+
 	/* Miscellaneous private stuff. */
 	struct net_device *dev;
 };
@@ -303,4 +306,6 @@ extern unsigned int rx_drain_timeout_msecs;
 extern unsigned int rx_drain_timeout_jiffies;
 extern unsigned int xenvif_max_queues;
 
+extern struct dentry *xen_netback_dbg_root
+
 #endif /* __XEN_NETBACK__COMMON_H__ */
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 9e97c7c..ef75b45 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -102,7 +102,7 @@ static irqreturn_t xenvif_rx_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
+irqreturn_t xenvif_interrupt(int irq, void *dev_id)
 {
 	xenvif_tx_interrupt(irq, dev_id);
 	xenvif_rx_interrupt(irq, dev_id);
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 1844a47..dc289ed 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1987,6 +1987,10 @@ static int __init netback_init(void)
 
 	rx_drain_timeout_jiffies = msecs_to_jiffies(rx_drain_timeout_msecs);
 
+	xen_netback_dbg_root = debugfs_create_dir("xen-netback", NULL);
+	if (IS_ERR(xen_netback_dbg_root))
+		pr_warn("Init of debugfs failed!\n");
+
 	return 0;
 
 failed_init:
@@ -1997,6 +2001,8 @@ module_init(netback_init);
 
 static void __exit netback_fini(void)
 {
+	if (!IS_ERR(xen_netback_dbg_root))
+		debugfs_remove_recursive(xen_netback_dbg_root);
 	xenvif_xenbus_fini();
 }
 module_exit(netback_fini);
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 3d85acd..e6cdb80 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -36,6 +36,10 @@ struct backend_info {
 	u8 have_hotplug_status_watch:1;
 };
 
+struct dentry *xen_netback_dbg_root = NULL;
+#define XEN_NETBACK_DBG_IORING_BUF_SIZE 1024
+static char xen_netback_dbg_ioring_buf[XEN_NETBACK_DBG_IORING_BUF_SIZE] = "";
+
 static int connect_rings(struct backend_info *be, struct xenvif_queue *queue);
 static void connect(struct backend_info *be);
 static int read_xenbus_vif_flags(struct backend_info *be);
@@ -44,6 +48,205 @@ static void unregister_hotplug_status_watch(struct backend_info *be);
 static void set_backend_state(struct backend_info *be,
 			      enum xenbus_state state);
 
+static ssize_t
+xenvif_read_io_ring(struct file *filp,
+		    char __user *buffer,
+		    size_t count,
+		    loff_t *ppos)
+{
+	struct xenvif_queue *queue = filp->private_data;
+	struct xenvif *vif = queue->vif;
+	struct xen_netif_tx_back_ring *tx_ring = &queue->tx;
+	struct xen_netif_rx_back_ring *rx_ring = &queue->rx;
+	ssize_t err, rv = 0;
+	char *buf = xen_netback_dbg_ioring_buf;
+	int len, i;
+
+	/* don't allow partial reads and enforce a minimum buffer size */
+	if (*ppos != 0 || count < XEN_NETBACK_DBG_IORING_BUF_SIZE)
+		return 0;
+
+	if (tx_ring->sring) {
+		struct xen_netif_tx_sring *sring = tx_ring->sring;
+
+		err = snprintf(buf + rv, XEN_NETBACK_DBG_IORING_BUF_SIZE - rv,
+			       "TX queue %d: nr_ents %u\n", i,
+			       tx_ring->nr_ents);
+		if (err >= XEN_NETBACK_DBG_IORING_BUF_SIZE - rv)
+			return XEN_NETBACK_DBG_IORING_BUF_SIZE;
+		else
+			rv += err;
+
+		err = snprintf(buf + rv, XEN_NETBACK_DBG_IORING_BUF_SIZE - rv,
+			       "req prod %u (%d) cons %u (%d) event %u (%d)\n",
+			       sring->req_prod,
+			       sring->req_prod - sring->rsp_prod,
+			       tx_ring->req_cons,
+			       tx_ring->req_cons - sring->rsp_prod,
+			       sring->req_event,
+			       sring->req_event - sring->rsp_prod);
+		if (err >= XEN_NETBACK_DBG_IORING_BUF_SIZE - rv)
+			return XEN_NETBACK_DBG_IORING_BUF_SIZE;
+		else
+			rv += err;
+
+		err = snprintf(buf + rv, XEN_NETBACK_DBG_IORING_BUF_SIZE - rv,
+			       "rsp prod %u (base) pvt %u (%d) event %u (%d)\n",
+			       sring->rsp_prod,
+			       tx_ring->rsp_prod_pvt,
+			       tx_ring->rsp_prod_pvt - sring->rsp_prod,
+			       sring->rsp_event,
+			       sring->rsp_event - sring->rsp_prod);
+		if (err >= XEN_NETBACK_DBG_IORING_BUF_SIZE - rv)
+			return XEN_NETBACK_DBG_IORING_BUF_SIZE;
+		else
+			rv += err;
+
+		err = snprintf(buf + rv, XEN_NETBACK_DBG_IORING_BUF_SIZE - rv,
+			       "pending prod %u pending cons %u nr_pending_reqs %u\n",
+			       queue->pending_prod,
+			       queue->pending_cons,
+			       nr_pending_reqs(vif));
+		if (err >= XEN_NETBACK_DBG_IORING_BUF_SIZE - rv)
+			return XEN_NETBACK_DBG_IORING_BUF_SIZE;
+		else
+			rv += err;
+
+		err = snprintf(buf + rv, XEN_NETBACK_DBG_IORING_BUF_SIZE - rv,
+			       "dealloc prod %u dealloc cons %u dealloc_queue %u\n\n",
+			       queue->dealloc_prod,
+			       queue->dealloc_cons,
+			       queue->dealloc_prod - queue->dealloc_cons);
+		if (err >= XEN_NETBACK_DBG_IORING_BUF_SIZE - rv)
+			return XEN_NETBACK_DBG_IORING_BUF_SIZE;
+		else
+			rv += err;
+	}
+
+	if (rx_ring->sring) {
+		struct xen_netif_rx_sring *sring = rx_ring->sring;
+
+		err = snprintf(buf + rv, XEN_NETBACK_DBG_IORING_BUF_SIZE - rv,
+			       "RX: nr_ents %u\n", rx_ring->nr_ents);
+		if (err >= XEN_NETBACK_DBG_IORING_BUF_SIZE - rv)
+			return XEN_NETBACK_DBG_IORING_BUF_SIZE;
+		else
+			rv += err;
+
+		err = snprintf(buf + rv, XEN_NETBACK_DBG_IORING_BUF_SIZE - rv,
+			       "req prod %u (%d) cons %u (%d) event %u (%d)\n",
+			       sring->req_prod,
+			       sring->req_prod - sring->rsp_prod,
+			       rx_ring->req_cons,
+			       rx_ring->req_cons - sring->rsp_prod,
+			       sring->req_event,
+			       sring->req_event - sring->rsp_prod);
+		if (err >= XEN_NETBACK_DBG_IORING_BUF_SIZE - rv)
+			return XEN_NETBACK_DBG_IORING_BUF_SIZE;
+		else
+			rv += err;
+
+		err = snprintf(buf + rv, XEN_NETBACK_DBG_IORING_BUF_SIZE - rv,
+			       "rsp prod %u (base) pvt %u (%d) event %u (%d)\n\n",
+			       sring->rsp_prod,
+			       rx_ring->rsp_prod_pvt,
+			       rx_ring->rsp_prod_pvt - sring->rsp_prod,
+			       sring->rsp_event,
+			       sring->rsp_event - sring->rsp_prod);
+		if (err >= XEN_NETBACK_DBG_IORING_BUF_SIZE - rv)
+			return XEN_NETBACK_DBG_IORING_BUF_SIZE;
+		else
+			rv += err;
+	}
+
+	err = snprintf(buf + rv, XEN_NETBACK_DBG_IORING_BUF_SIZE - rv,
+	      "NAPI state: %lx NAPI weight: %d TX queue len %u\n"
+	      "Credit timer_pending: %d, credit: %lu, usec: %lu\n"
+	      "remaining: %lu, expires: %lu, now: %lu\n",
+	      queue->napi.state, queue->napi.weight,
+	      skb_queue_len(&queue->tx_queue),
+	      timer_pending(&queue->credit_timeout),
+	      queue->credit_bytes,
+	      queue->credit_usec,
+	      queue->remaining_credit,
+	      queue->credit_timeout.expires,
+	      jiffies);
+	if (err >= XEN_NETBACK_DBG_IORING_BUF_SIZE - rv)
+		return XEN_NETBACK_DBG_IORING_BUF_SIZE;
+	else
+		rv += err;
+
+	len = simple_read_from_buffer(buffer, count, ppos, buf, rv);
+	return len;
+}
+
+static ssize_t
+xenvif_write_io_ring(struct file *filp, const char __user *buf, size_t count,
+		     loff_t *ppos)
+{
+	struct xenvif_queue *queue = filp->private_data;
+	int len;
+
+	/* don't allow partial writes and check the length */
+	if (*ppos != 0)
+		return 0;
+	if (count != sizeof("kick"))
+		return -ENOSPC;
+
+	len = simple_write_to_buffer(xen_netback_dbg_ioring_buf,
+				     sizeof(xen_netback_dbg_ioring_buf)-1,
+				     ppos,
+				     buf,
+				     count);
+	if (len < 0)
+		return len;
+
+	if (!strncmp(xen_netback_dbg_ioring_buf, "kick", count))
+		xenvif_interrupt(0,(void*)queue);
+	else
+		pr_warn("Unknown command to io_ring. Available: kick\n");
+	return count;
+}
+
+static const struct file_operations xenvif_dbg_io_ring_ops_fops = {
+	.owner = THIS_MODULE,
+	.open = simple_open,
+	.read = xenvif_read_io_ring,
+	.write = xenvif_write_io_ring,
+};
+
+static void xenvif_debugfs_addif(struct xenvif_queue *queue)
+{
+	struct dentry *pfile;
+	struct xenvif *vif = queue->vif;
+	int i;
+
+	vif->xenvif_dbg_root = debugfs_create_dir(vif->dev->name,
+						  xen_netback_dbg_root);
+	if (!IS_ERR(vif->xenvif_dbg_root)) {
+		for (i = 0; i < vif->num_queues; ++i) {
+			char filename[sizeof("io_ring_q") + 4];
+
+			snprintf(filename, sizeof(filename), "io_ring_q%d", i);
+			pfile = debugfs_create_file(filename,
+						    0600,
+						    vif->xenvif_dbg_root,
+						    vif->queues[i],
+						    &xenvif_dbg_io_ring_ops_fops);
+			if (IS_ERR(pfile))
+				pr_warn("Failed to create io_ring file\n");
+		}
+	} else
+		netdev_warn(vif->dev,"Failed to create vif debugfs dir\n");
+}
+
+static void xenvif_debugfs_delif(struct xenvif *vif)
+{
+	if (vif->xenvif_dbg_root)
+		debugfs_remove_recursive(vif->xenvif_dbg_root);
+	vif->xenvif_dbg_root = NULL;
+}
+
 static int netback_remove(struct xenbus_device *dev)
 {
 	struct backend_info *be = dev_get_drvdata(&dev->dev);
@@ -246,8 +449,11 @@ static void backend_create_xenvif(struct backend_info *be)
 
 static void backend_disconnect(struct backend_info *be)
 {
-	if (be->vif)
+	if (be->vif) {
+		if (xen_netback_dbg_root)
+			xenvif_debugfs_delif(be->vif);
 		xenvif_disconnect(be->vif);
+	}
 }
 
 static void backend_connect(struct backend_info *be)
@@ -560,6 +766,9 @@ static void connect(struct backend_info *be)
 			be->vif->num_queues = queue_index;
 			goto err;
 		}
+		if (xen_netback_dbg_root)
+			xenvif_debugfs_addif(queue);
+
 	}
 
 	/* Initialisation completed, tell core driver the number of
