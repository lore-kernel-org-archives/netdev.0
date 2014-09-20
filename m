From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH v2 27/29] fm10k: Add support for debugfs
Date: Sat, 20 Sep 2014 19:53:23 -0400
Message-ID: <20140920235315.2977.7766.stgit@ahduyck-bv4.jf.intel.com>
References: <20140920234342.2977.21667.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:6713 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751212AbaIUACS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Sep 2014 20:02:18 -0400
In-Reply-To: <20140920234342.2977.21667.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds limited debugfs support for the driver.  Most of the
functionality needed for dumping registers is already provided via ethtool.
The only thing we saw that we really neeed was the ability to dump the
descriptor rings so as such this patch will add a fm10k directory containing a
listing of directories each one with a unique PCI Bus, Device, and Function
number.  Each of those BDF directories will have a list of q_vectors, and
the q_vectors will contain a file for each of the Rx/Tx rings that are a part
of the vector.  For example:

# ls -RD /sys/kernel/debug/fm10k/
/sys/kernel/debug/fm10k/:
0000:01:00.0

/sys/kernel/debug/fm10k/0000:01:00.0:
q_vector.000  q_vector.001  q_vector.002  q_vector.003

/sys/kernel/debug/fm10k/0000:01:00.0/q_vector.000:
rx_ring.000  tx_ring.000

/sys/kernel/debug/fm10k/0000:01:00.0/q_vector.001:
rx_ring.001  tx_ring.001

/sys/kernel/debug/fm10k/0000:01:00.0/q_vector.002:
rx_ring.002  tx_ring.002

/sys/kernel/debug/fm10k/0000:01:00.0/q_vector.003:
rx_ring.003  tx_ring.003

# cat /sys/kernel/debug/fm10k/0000:01:00.0/q_vector.000/rx_ring.000
DES DATA       RSS        STATERR    LENGTH VLAN   DGLORT SGLORT TIMESTAMP
---------------------------------------------------------------------------
000 0x00000000 0x00000000 0x00000003 0x002a 0x0000 0x0000 0x0000 0x13951807dc4fedf0
001 0x00000000 0x00000000 0x00000003 0x002a 0x0000 0x0000 0x0000 0x1395180906c9f2c8
002 0x3731c000 0x00000000 0x00000000 0x0000 0x0000 0x0000 0x0000 0x0000000000000000
003 0x3731d000 0x00000000 0x00000000 0x0000 0x0000 0x0000 0x0000 0x0000000000000000
004 0xaab3a000 0x00000000 0x00000000 0x0000 0x0000 0x0000 0x0000 0x0000000000000000
...

# cat /sys/kernel/debug/fm10k/0000:01:00.0/q_vector.000/tx_ring.000
DES BUFFER_ADDRESS     LENGTH VLAN   MSS    HDRLEN FLAGS
---------------------------------------------------------
000 0x00000000aa8a1002 0x005a 0x0000 0x0000 0x0000 0xc0
001 0x00000000aa8a2002 0x005a 0x0000 0x0000 0x0000 0xc0
002 0x000000006bc13202 0x004e 0x0000 0x0000 0x0000 0xc0
003 0x000000006bc13c02 0x002a 0x0000 0x0000 0x0000 0xe1
004 0x000000006bc13602 0x0062 0x0000 0x0000 0x0000 0xc0

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/fm10k/Makefile        |    2 
 drivers/net/ethernet/intel/fm10k/fm10k.h         |   24 ++
 drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c |  259 ++++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    |    8 +
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     |    6 +
 5 files changed, 298 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c

diff --git a/drivers/net/ethernet/intel/fm10k/Makefile b/drivers/net/ethernet/intel/fm10k/Makefile
index 5023625..fbc0e09 100644
--- a/drivers/net/ethernet/intel/fm10k/Makefile
+++ b/drivers/net/ethernet/intel/fm10k/Makefile
@@ -30,4 +30,4 @@ obj-$(CONFIG_FM10K) += fm10k.o
 fm10k-objs := fm10k_main.o fm10k_common.o fm10k_pci.o \
 	      fm10k_netdev.o fm10k_ethtool.o fm10k_pf.o fm10k_vf.o \
 	      fm10k_mbx.o fm10k_iov.o fm10k_tlv.o \
-	      fm10k_dcbnl.o
+	      fm10k_debugfs.o fm10k_dcbnl.o
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 7025b91..307335a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -199,6 +199,9 @@ struct fm10k_q_vector {
 	struct napi_struct napi;
 	char name[IFNAMSIZ + 9];
 
+#ifdef CONFIG_DEBUG_FS
+	struct dentry *dbg_q_vector;
+#endif /* CONFIG_DEBUG_FS */
 	struct rcu_head rcu;	/* to avoid race with update stats on free */
 
 	/* for dynamic allocation of rings associated with this q_vector */
@@ -307,6 +310,10 @@ struct fm10k_intfc {
 	/* VXLAN port tracking information */
 	struct list_head vxlan_port;
 
+#ifdef CONFIG_DEBUG_FS
+	struct dentry *dbg_intfc;
+
+#endif /* CONFIG_DEBUG_FS */
 #ifdef CONFIG_DCB
 	u8 pfc_en;
 #endif
@@ -468,6 +475,23 @@ int fm10k_ndo_set_vf_bw(struct net_device *netdev, int vf_idx, int rate,
 int fm10k_ndo_get_vf_config(struct net_device *netdev,
 			    int vf_idx, struct ifla_vf_info *ivi);
 
+/* DebugFS */
+#ifdef CONFIG_DEBUG_FS
+void fm10k_dbg_q_vector_init(struct fm10k_q_vector *q_vector);
+void fm10k_dbg_q_vector_exit(struct fm10k_q_vector *q_vector);
+void fm10k_dbg_intfc_init(struct fm10k_intfc *interface);
+void fm10k_dbg_intfc_exit(struct fm10k_intfc *interface);
+void fm10k_dbg_init(void);
+void fm10k_dbg_exit(void);
+#else
+static inline void fm10k_dbg_q_vector_init(struct fm10k_q_vector *q_vector) {}
+static inline void fm10k_dbg_q_vector_exit(struct fm10k_q_vector *q_vector) {}
+static inline void fm10k_dbg_intfc_init(struct fm10k_intfc *interface) {}
+static inline void fm10k_dbg_intfc_exit(struct fm10k_intfc *interface) {}
+static inline void fm10k_dbg_init(void) {}
+static inline void fm10k_dbg_exit(void) {}
+#endif /* CONFIG_DEBUG_FS */
+
 /* DCB */
 void fm10k_dcbnl_set_ops(struct net_device *dev);
 #endif /* _FM10K_H_ */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c b/drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c
new file mode 100644
index 0000000..4327f86
--- /dev/null
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c
@@ -0,0 +1,259 @@
+/* Intel Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
+
+#ifdef CONFIG_DEBUG_FS
+
+#include "fm10k.h"
+
+#include <linux/debugfs.h>
+#include <linux/seq_file.h>
+
+static struct dentry *dbg_root;
+
+/* Descriptor Seq Functions */
+
+static void *fm10k_dbg_desc_seq_start(struct seq_file *s, loff_t *pos)
+{
+	struct fm10k_ring *ring = s->private;
+
+	return (*pos < ring->count) ? pos : NULL;
+}
+
+static void *fm10k_dbg_desc_seq_next(struct seq_file *s, void *v, loff_t *pos)
+{
+	struct fm10k_ring *ring = s->private;
+
+	return (++(*pos) < ring->count) ? pos : NULL;
+}
+
+static void fm10k_dbg_desc_seq_stop(struct seq_file *s, void *v)
+{
+	/* Do nothing. */
+}
+
+static void fm10k_dbg_desc_break(struct seq_file *s, int i)
+{
+	while (i--)
+		seq_puts(s, "-");
+
+	seq_puts(s, "\n");
+}
+
+static int fm10k_dbg_tx_desc_seq_show(struct seq_file *s, void *v)
+{
+	struct fm10k_ring *ring = s->private;
+	int i = *(loff_t *)v;
+	static const char tx_desc_hdr[] =
+		"DES BUFFER_ADDRESS     LENGTH VLAN   MSS    HDRLEN FLAGS\n";
+
+	/* Generate header */
+	if (!i) {
+		seq_printf(s, tx_desc_hdr);
+		fm10k_dbg_desc_break(s, sizeof(tx_desc_hdr) - 1);
+	}
+
+	/* Validate descriptor allocation */
+	if (!ring->desc) {
+		seq_printf(s, "%03X Descriptor ring not allocated.\n", i);
+	} else {
+		struct fm10k_tx_desc *txd = FM10K_TX_DESC(ring, i);
+
+		seq_printf(s, "%03X %#018llx %#06x %#06x %#06x %#06x %#04x\n",
+			   i, txd->buffer_addr, txd->buflen, txd->vlan,
+			   txd->mss, txd->hdrlen, txd->flags);
+	}
+
+	return 0;
+}
+
+static int fm10k_dbg_rx_desc_seq_show(struct seq_file *s, void *v)
+{
+	struct fm10k_ring *ring = s->private;
+	int i = *(loff_t *)v;
+	static const char rx_desc_hdr[] =
+	"DES DATA       RSS        STATERR    LENGTH VLAN   DGLORT SGLORT TIMESTAMP\n";
+
+	/* Generate header */
+	if (!i) {
+		seq_printf(s, rx_desc_hdr);
+		fm10k_dbg_desc_break(s, sizeof(rx_desc_hdr) - 1);
+	}
+
+	/* Validate descriptor allocation */
+	if (!ring->desc) {
+		seq_printf(s, "%03X Descriptor ring not allocated.\n", i);
+	} else {
+		union fm10k_rx_desc *rxd = FM10K_RX_DESC(ring, i);
+
+		seq_printf(s,
+			   "%03X %#010x %#010x %#010x %#06x %#06x %#06x %#06x %#018llx\n",
+			   i, rxd->d.data, rxd->d.rss, rxd->d.staterr,
+			   rxd->w.length, rxd->w.vlan, rxd->w.dglort,
+			   rxd->w.sglort, rxd->q.timestamp);
+	}
+
+	return 0;
+}
+
+static const struct seq_operations fm10k_dbg_tx_desc_seq_ops = {
+	.start = fm10k_dbg_desc_seq_start,
+	.next  = fm10k_dbg_desc_seq_next,
+	.stop  = fm10k_dbg_desc_seq_stop,
+	.show  = fm10k_dbg_tx_desc_seq_show,
+};
+
+static const struct seq_operations fm10k_dbg_rx_desc_seq_ops = {
+	.start = fm10k_dbg_desc_seq_start,
+	.next  = fm10k_dbg_desc_seq_next,
+	.stop  = fm10k_dbg_desc_seq_stop,
+	.show  = fm10k_dbg_rx_desc_seq_show,
+};
+
+static int fm10k_dbg_desc_open(struct inode *inode, struct file *filep)
+{
+	struct fm10k_ring *ring = inode->i_private;
+	struct fm10k_q_vector *q_vector = ring->q_vector;
+	const struct seq_operations *desc_seq_ops;
+	int err;
+
+	if (ring < q_vector->rx.ring)
+		desc_seq_ops = &fm10k_dbg_tx_desc_seq_ops;
+	else
+		desc_seq_ops = &fm10k_dbg_rx_desc_seq_ops;
+
+	err = seq_open(filep, desc_seq_ops);
+	if (err)
+		return err;
+
+	((struct seq_file *)filep->private_data)->private = ring;
+
+	return 0;
+}
+
+static const struct file_operations fm10k_dbg_desc_fops = {
+	.owner   = THIS_MODULE,
+	.open    = fm10k_dbg_desc_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
+
+/**
+ * fm10k_dbg_q_vector_init - setup debugfs for the q_vectors
+ * @q_vector: q_vector to allocate directories for
+ *
+ * A folder is created for each q_vector found. In each q_vector
+ * folder, a debugfs file is created for each tx and rx ring
+ * allocated to the q_vector.
+ **/
+void fm10k_dbg_q_vector_init(struct fm10k_q_vector *q_vector)
+{
+	struct fm10k_intfc *interface = q_vector->interface;
+	char name[16];
+	int i;
+
+	if (!interface->dbg_intfc)
+		return;
+
+	/* Generate a folder for each q_vector */
+	sprintf(name, "q_vector.%03d", q_vector->v_idx);
+
+	q_vector->dbg_q_vector = debugfs_create_dir(name, interface->dbg_intfc);
+	if (!q_vector->dbg_q_vector)
+		return;
+
+	/* Generate a file for each rx ring in the q_vector */
+	for (i = 0; i < q_vector->tx.count; i++) {
+		struct fm10k_ring *ring = &q_vector->tx.ring[i];
+
+		sprintf(name, "tx_ring.%03d", ring->queue_index);
+
+		debugfs_create_file(name, 0600,
+				    q_vector->dbg_q_vector, ring,
+				    &fm10k_dbg_desc_fops);
+	}
+
+	/* Generate a file for each rx ring in the q_vector */
+	for (i = 0; i < q_vector->rx.count; i++) {
+		struct fm10k_ring *ring = &q_vector->rx.ring[i];
+
+		sprintf(name, "rx_ring.%03d", ring->queue_index);
+
+		debugfs_create_file(name, 0600,
+				    q_vector->dbg_q_vector, ring,
+				    &fm10k_dbg_desc_fops);
+	}
+}
+
+/**
+ * fm10k_dbg_free_q_vector_dir - setup debugfs for the q_vectors
+ * @q_vector: q_vector to allocate directories for
+ **/
+void fm10k_dbg_q_vector_exit(struct fm10k_q_vector *q_vector)
+{
+	struct fm10k_intfc *interface = q_vector->interface;
+
+	if (interface->dbg_intfc)
+		debugfs_remove_recursive(q_vector->dbg_q_vector);
+	q_vector->dbg_q_vector = NULL;
+}
+
+/**
+ * fm10k_dbg_intfc_init - setup the debugfs directory for the intferface
+ * @interface: the interface that is starting up
+ **/
+
+void fm10k_dbg_intfc_init(struct fm10k_intfc *interface)
+{
+	const char *name = pci_name(interface->pdev);
+
+	if (dbg_root)
+		interface->dbg_intfc = debugfs_create_dir(name, dbg_root);
+}
+
+/**
+ * fm10k_dbg_intfc_exit - clean out the interface's debugfs entries
+ * @interface: the interface that is stopping
+ **/
+void fm10k_dbg_intfc_exit(struct fm10k_intfc *interface)
+{
+	if (dbg_root)
+		debugfs_remove_recursive(interface->dbg_intfc);
+	interface->dbg_intfc = NULL;
+}
+
+/**
+ * fm10k_dbg_init - start up debugfs for the driver
+ **/
+void fm10k_dbg_init(void)
+{
+	dbg_root = debugfs_create_dir(fm10k_driver_name, NULL);
+}
+
+/**
+ * fm10k_dbg_exit - clean out the driver's debugfs entries
+ **/
+void fm10k_dbg_exit(void)
+{
+	debugfs_remove_recursive(dbg_root);
+	dbg_root = NULL;
+}
+
+#endif /* CONFIG_DEBUG_FS */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 525dfc9..33da585 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -51,6 +51,8 @@ static int __init fm10k_init_module(void)
 	pr_info("%s - version %s\n", fm10k_driver_string, fm10k_driver_version);
 	pr_info("%s\n", fm10k_copyright);
 
+	fm10k_dbg_init();
+
 	return fm10k_register_pci_driver();
 }
 module_init(fm10k_init_module);
@@ -64,6 +66,8 @@ module_init(fm10k_init_module);
 static void __exit fm10k_exit_module(void)
 {
 	fm10k_unregister_pci_driver();
+
+	fm10k_dbg_exit();
 }
 module_exit(fm10k_exit_module);
 
@@ -1616,6 +1620,8 @@ static int fm10k_alloc_q_vector(struct fm10k_intfc *interface,
 		ring++;
 	}
 
+	fm10k_dbg_q_vector_init(q_vector);
+
 	return 0;
 }
 
@@ -1633,6 +1639,8 @@ static void fm10k_free_q_vector(struct fm10k_intfc *interface, int v_idx)
 	struct fm10k_q_vector *q_vector = interface->q_vector[v_idx];
 	struct fm10k_ring *ring;
 
+	fm10k_dbg_q_vector_exit(q_vector);
+
 	fm10k_for_each_ring(ring, q_vector->tx)
 		interface->tx_ring[ring->queue_index] = NULL;
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 8485d59..77c2d36 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1690,6 +1690,9 @@ static int fm10k_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_sw_init;
 
+	/* enable debugfs support */
+	fm10k_dbg_intfc_init(interface);
+
 	err = fm10k_init_queueing_scheme(interface);
 	if (err)
 		goto err_sw_init;
@@ -1786,6 +1789,9 @@ static void fm10k_remove(struct pci_dev *pdev)
 	/* free interrupts */
 	fm10k_clear_queueing_scheme(interface);
 
+	/* remove any debugfs interfaces */
+	fm10k_dbg_intfc_exit(interface);
+
 	iounmap(interface->uc_addr);
 
 	free_netdev(netdev);
