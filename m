From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: Remove debugfs interface
Date: Thu, 23 Mar 2017 11:14:24 +0100
Message-ID: <1490264064-4888-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36333 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752034AbdCWKO2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 06:14:28 -0400
Received: by mail-wr0-f195.google.com with SMTP id l37so30349119wrc.3
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 03:14:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We don't use it during development and we can't extend it either, so
remove it.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 177 -----------------------------
 drivers/net/ethernet/mellanox/mlxsw/pci.c  | 138 ----------------------
 2 files changed, 315 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index a4c0784..fb8187d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -40,9 +40,6 @@
 #include <linux/export.h>
 #include <linux/err.h>
 #include <linux/if_link.h>
-#include <linux/debugfs.h>
-#include <linux/seq_file.h>
-#include <linux/u64_stats_sync.h>
 #include <linux/netdevice.h>
 #include <linux/completion.h>
 #include <linux/skbuff.h>
@@ -74,23 +71,9 @@ static DEFINE_SPINLOCK(mlxsw_core_driver_list_lock);
 
 static const char mlxsw_core_driver_name[] = "mlxsw_core";
 
-static struct dentry *mlxsw_core_dbg_root;
-
 static struct workqueue_struct *mlxsw_wq;
 static struct workqueue_struct *mlxsw_owq;
 
-struct mlxsw_core_pcpu_stats {
-	u64			trap_rx_packets[MLXSW_TRAP_ID_MAX];
-	u64			trap_rx_bytes[MLXSW_TRAP_ID_MAX];
-	u64			port_rx_packets[MLXSW_PORT_MAX_PORTS];
-	u64			port_rx_bytes[MLXSW_PORT_MAX_PORTS];
-	struct u64_stats_sync	syncp;
-	u32			trap_rx_dropped[MLXSW_TRAP_ID_MAX];
-	u32			port_rx_dropped[MLXSW_PORT_MAX_PORTS];
-	u32			trap_rx_invalid;
-	u32			port_rx_invalid;
-};
-
 struct mlxsw_core_port {
 	struct devlink_port devlink_port;
 	void *port_driver_priv;
@@ -121,12 +104,6 @@ struct mlxsw_core {
 		spinlock_t trans_list_lock; /* protects trans_list writes */
 		bool use_emad;
 	} emad;
-	struct mlxsw_core_pcpu_stats __percpu *pcpu_stats;
-	struct dentry *dbg_dir;
-	struct {
-		struct debugfs_blob_wrapper vsd_blob;
-		struct debugfs_blob_wrapper psid_blob;
-	} dbg;
 	struct {
 		u8 *mapping; /* lag_id+port_index to local_port mapping */
 	} lag;
@@ -703,91 +680,6 @@ static int mlxsw_emad_reg_access(struct mlxsw_core *mlxsw_core,
  * Core functions
  *****************/
 
-static int mlxsw_core_rx_stats_dbg_read(struct seq_file *file, void *data)
-{
-	struct mlxsw_core *mlxsw_core = file->private;
-	struct mlxsw_core_pcpu_stats *p;
-	u64 rx_packets, rx_bytes;
-	u64 tmp_rx_packets, tmp_rx_bytes;
-	u32 rx_dropped, rx_invalid;
-	unsigned int start;
-	int i;
-	int j;
-	static const char hdr[] =
-		"     NUM   RX_PACKETS     RX_BYTES RX_DROPPED\n";
-
-	seq_printf(file, hdr);
-	for (i = 0; i < MLXSW_TRAP_ID_MAX; i++) {
-		rx_packets = 0;
-		rx_bytes = 0;
-		rx_dropped = 0;
-		for_each_possible_cpu(j) {
-			p = per_cpu_ptr(mlxsw_core->pcpu_stats, j);
-			do {
-				start = u64_stats_fetch_begin(&p->syncp);
-				tmp_rx_packets = p->trap_rx_packets[i];
-				tmp_rx_bytes = p->trap_rx_bytes[i];
-			} while (u64_stats_fetch_retry(&p->syncp, start));
-
-			rx_packets += tmp_rx_packets;
-			rx_bytes += tmp_rx_bytes;
-			rx_dropped += p->trap_rx_dropped[i];
-		}
-		seq_printf(file, "trap %3d %12llu %12llu %10u\n",
-			   i, rx_packets, rx_bytes, rx_dropped);
-	}
-	rx_invalid = 0;
-	for_each_possible_cpu(j) {
-		p = per_cpu_ptr(mlxsw_core->pcpu_stats, j);
-		rx_invalid += p->trap_rx_invalid;
-	}
-	seq_printf(file, "trap INV                           %10u\n",
-		   rx_invalid);
-
-	for (i = 0; i < MLXSW_PORT_MAX_PORTS; i++) {
-		rx_packets = 0;
-		rx_bytes = 0;
-		rx_dropped = 0;
-		for_each_possible_cpu(j) {
-			p = per_cpu_ptr(mlxsw_core->pcpu_stats, j);
-			do {
-				start = u64_stats_fetch_begin(&p->syncp);
-				tmp_rx_packets = p->port_rx_packets[i];
-				tmp_rx_bytes = p->port_rx_bytes[i];
-			} while (u64_stats_fetch_retry(&p->syncp, start));
-
-			rx_packets += tmp_rx_packets;
-			rx_bytes += tmp_rx_bytes;
-			rx_dropped += p->port_rx_dropped[i];
-		}
-		seq_printf(file, "port %3d %12llu %12llu %10u\n",
-			   i, rx_packets, rx_bytes, rx_dropped);
-	}
-	rx_invalid = 0;
-	for_each_possible_cpu(j) {
-		p = per_cpu_ptr(mlxsw_core->pcpu_stats, j);
-		rx_invalid += p->port_rx_invalid;
-	}
-	seq_printf(file, "port INV                           %10u\n",
-		   rx_invalid);
-	return 0;
-}
-
-static int mlxsw_core_rx_stats_dbg_open(struct inode *inode, struct file *f)
-{
-	struct mlxsw_core *mlxsw_core = inode->i_private;
-
-	return single_open(f, mlxsw_core_rx_stats_dbg_read, mlxsw_core);
-}
-
-static const struct file_operations mlxsw_core_rx_stats_dbg_ops = {
-	.owner = THIS_MODULE,
-	.open = mlxsw_core_rx_stats_dbg_open,
-	.release = single_release,
-	.read = seq_read,
-	.llseek = seq_lseek
-};
-
 int mlxsw_core_driver_register(struct mlxsw_driver *mlxsw_driver)
 {
 	spin_lock(&mlxsw_core_driver_list_lock);
@@ -835,32 +727,6 @@ static void mlxsw_core_driver_put(const char *kind)
 	spin_unlock(&mlxsw_core_driver_list_lock);
 }
 
-static int mlxsw_core_debugfs_init(struct mlxsw_core *mlxsw_core)
-{
-	const struct mlxsw_bus_info *bus_info = mlxsw_core->bus_info;
-
-	mlxsw_core->dbg_dir = debugfs_create_dir(bus_info->device_name,
-						 mlxsw_core_dbg_root);
-	if (!mlxsw_core->dbg_dir)
-		return -ENOMEM;
-	debugfs_create_file("rx_stats", S_IRUGO, mlxsw_core->dbg_dir,
-			    mlxsw_core, &mlxsw_core_rx_stats_dbg_ops);
-	mlxsw_core->dbg.vsd_blob.data = (void *) &bus_info->vsd;
-	mlxsw_core->dbg.vsd_blob.size = sizeof(bus_info->vsd);
-	debugfs_create_blob("vsd", S_IRUGO, mlxsw_core->dbg_dir,
-			    &mlxsw_core->dbg.vsd_blob);
-	mlxsw_core->dbg.psid_blob.data = (void *) &bus_info->psid;
-	mlxsw_core->dbg.psid_blob.size = sizeof(bus_info->psid);
-	debugfs_create_blob("psid", S_IRUGO, mlxsw_core->dbg_dir,
-			    &mlxsw_core->dbg.psid_blob);
-	return 0;
-}
-
-static void mlxsw_core_debugfs_fini(struct mlxsw_core *mlxsw_core)
-{
-	debugfs_remove_recursive(mlxsw_core->dbg_dir);
-}
-
 static int mlxsw_devlink_port_split(struct devlink *devlink,
 				    unsigned int port_index,
 				    unsigned int count)
@@ -1101,13 +967,6 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 	mlxsw_core->bus_priv = bus_priv;
 	mlxsw_core->bus_info = mlxsw_bus_info;
 
-	mlxsw_core->pcpu_stats =
-		netdev_alloc_pcpu_stats(struct mlxsw_core_pcpu_stats);
-	if (!mlxsw_core->pcpu_stats) {
-		err = -ENOMEM;
-		goto err_alloc_stats;
-	}
-
 	err = mlxsw_bus->init(bus_priv, mlxsw_core, mlxsw_driver->profile,
 			      &mlxsw_core->res);
 	if (err)
@@ -1148,15 +1007,8 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 			goto err_driver_init;
 	}
 
-	err = mlxsw_core_debugfs_init(mlxsw_core);
-	if (err)
-		goto err_debugfs_init;
-
 	return 0;
 
-err_debugfs_init:
-	if (mlxsw_core->driver->fini)
-		mlxsw_core->driver->fini(mlxsw_core);
 err_driver_init:
 	mlxsw_thermal_fini(mlxsw_core->thermal);
 err_thermal_init:
@@ -1169,8 +1021,6 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 err_alloc_lag_mapping:
 	mlxsw_bus->fini(bus_priv);
 err_bus_init:
-	free_percpu(mlxsw_core->pcpu_stats);
-err_alloc_stats:
 	devlink_free(devlink);
 err_devlink_alloc:
 	mlxsw_core_driver_put(device_kind);
@@ -1183,7 +1033,6 @@ void mlxsw_core_bus_device_unregister(struct mlxsw_core *mlxsw_core)
 	const char *device_kind = mlxsw_core->bus_info->device_kind;
 	struct devlink *devlink = priv_to_devlink(mlxsw_core);
 
-	mlxsw_core_debugfs_fini(mlxsw_core);
 	if (mlxsw_core->driver->fini)
 		mlxsw_core->driver->fini(mlxsw_core);
 	mlxsw_thermal_fini(mlxsw_core->thermal);
@@ -1191,7 +1040,6 @@ void mlxsw_core_bus_device_unregister(struct mlxsw_core *mlxsw_core)
 	mlxsw_emad_fini(mlxsw_core);
 	kfree(mlxsw_core->lag.mapping);
 	mlxsw_core->bus->fini(mlxsw_core->bus_priv);
-	free_percpu(mlxsw_core->pcpu_stats);
 	devlink_free(devlink);
 	mlxsw_core_driver_put(device_kind);
 }
@@ -1639,7 +1487,6 @@ void mlxsw_core_skb_receive(struct mlxsw_core *mlxsw_core, struct sk_buff *skb,
 {
 	struct mlxsw_rx_listener_item *rxl_item;
 	const struct mlxsw_rx_listener *rxl;
-	struct mlxsw_core_pcpu_stats *pcpu_stats;
 	u8 local_port;
 	bool found = false;
 
@@ -1678,26 +1525,10 @@ void mlxsw_core_skb_receive(struct mlxsw_core *mlxsw_core, struct sk_buff *skb,
 	if (!found)
 		goto drop;
 
-	pcpu_stats = this_cpu_ptr(mlxsw_core->pcpu_stats);
-	u64_stats_update_begin(&pcpu_stats->syncp);
-	pcpu_stats->port_rx_packets[local_port]++;
-	pcpu_stats->port_rx_bytes[local_port] += skb->len;
-	pcpu_stats->trap_rx_packets[rx_info->trap_id]++;
-	pcpu_stats->trap_rx_bytes[rx_info->trap_id] += skb->len;
-	u64_stats_update_end(&pcpu_stats->syncp);
-
 	rxl->func(skb, local_port, rxl_item->priv);
 	return;
 
 drop:
-	if (rx_info->trap_id >= MLXSW_TRAP_ID_MAX)
-		this_cpu_inc(mlxsw_core->pcpu_stats->trap_rx_invalid);
-	else
-		this_cpu_inc(mlxsw_core->pcpu_stats->trap_rx_dropped[rx_info->trap_id]);
-	if (local_port >= MLXSW_PORT_MAX_PORTS)
-		this_cpu_inc(mlxsw_core->pcpu_stats->port_rx_invalid);
-	else
-		this_cpu_inc(mlxsw_core->pcpu_stats->port_rx_dropped[local_port]);
 	dev_kfree_skb(skb);
 }
 EXPORT_SYMBOL(mlxsw_core_skb_receive);
@@ -1926,15 +1757,8 @@ static int __init mlxsw_core_module_init(void)
 		err = -ENOMEM;
 		goto err_alloc_ordered_workqueue;
 	}
-	mlxsw_core_dbg_root = debugfs_create_dir(mlxsw_core_driver_name, NULL);
-	if (!mlxsw_core_dbg_root) {
-		err = -ENOMEM;
-		goto err_debugfs_create_dir;
-	}
 	return 0;
 
-err_debugfs_create_dir:
-	destroy_workqueue(mlxsw_owq);
 err_alloc_ordered_workqueue:
 	destroy_workqueue(mlxsw_wq);
 	return err;
@@ -1942,7 +1766,6 @@ static int __init mlxsw_core_module_init(void)
 
 static void __exit mlxsw_core_module_exit(void)
 {
-	debugfs_remove_recursive(mlxsw_core_dbg_root);
 	destroy_workqueue(mlxsw_owq);
 	destroy_workqueue(mlxsw_wq);
 }
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index ffeb746..eaa3e3b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -44,8 +44,6 @@
 #include <linux/skbuff.h>
 #include <linux/if_vlan.h>
 #include <linux/log2.h>
-#include <linux/debugfs.h>
-#include <linux/seq_file.h>
 #include <linux/string.h>
 
 #include "pci_hw.h"
@@ -57,8 +55,6 @@
 
 static const char mlxsw_pci_driver_name[] = "mlxsw_pci";
 
-static struct dentry *mlxsw_pci_dbg_root;
-
 #define mlxsw_pci_write32(mlxsw_pci, reg, val) \
 	iowrite32be(val, (mlxsw_pci)->hw_addr + (MLXSW_PCI_ ## reg))
 #define mlxsw_pci_read32(mlxsw_pci, reg) \
@@ -71,21 +67,6 @@ enum mlxsw_pci_queue_type {
 	MLXSW_PCI_QUEUE_TYPE_EQ,
 };
 
-static const char *mlxsw_pci_queue_type_str(enum mlxsw_pci_queue_type q_type)
-{
-	switch (q_type) {
-	case MLXSW_PCI_QUEUE_TYPE_SDQ:
-		return "sdq";
-	case MLXSW_PCI_QUEUE_TYPE_RDQ:
-		return "rdq";
-	case MLXSW_PCI_QUEUE_TYPE_CQ:
-		return "cq";
-	case MLXSW_PCI_QUEUE_TYPE_EQ:
-		return "eq";
-	}
-	BUG();
-}
-
 #define MLXSW_PCI_QUEUE_TYPE_COUNT	4
 
 static const u16 mlxsw_pci_doorbell_type_offset[] = {
@@ -174,7 +155,6 @@ struct mlxsw_pci {
 		} comp;
 	} cmd;
 	struct mlxsw_bus_info bus_info;
-	struct dentry *dbg_dir;
 };
 
 static void mlxsw_pci_queue_tasklet_schedule(struct mlxsw_pci_queue *q)
@@ -261,21 +241,11 @@ static u8 mlxsw_pci_sdq_count(struct mlxsw_pci *mlxsw_pci)
 	return __mlxsw_pci_queue_count(mlxsw_pci, MLXSW_PCI_QUEUE_TYPE_SDQ);
 }
 
-static u8 mlxsw_pci_rdq_count(struct mlxsw_pci *mlxsw_pci)
-{
-	return __mlxsw_pci_queue_count(mlxsw_pci, MLXSW_PCI_QUEUE_TYPE_RDQ);
-}
-
 static u8 mlxsw_pci_cq_count(struct mlxsw_pci *mlxsw_pci)
 {
 	return __mlxsw_pci_queue_count(mlxsw_pci, MLXSW_PCI_QUEUE_TYPE_CQ);
 }
 
-static u8 mlxsw_pci_eq_count(struct mlxsw_pci *mlxsw_pci)
-{
-	return __mlxsw_pci_queue_count(mlxsw_pci, MLXSW_PCI_QUEUE_TYPE_EQ);
-}
-
 static struct mlxsw_pci_queue *
 __mlxsw_pci_queue_get(struct mlxsw_pci *mlxsw_pci,
 		      enum mlxsw_pci_queue_type q_type, u8 q_num)
@@ -390,26 +360,6 @@ static void mlxsw_pci_sdq_fini(struct mlxsw_pci *mlxsw_pci,
 	mlxsw_cmd_hw2sw_sdq(mlxsw_pci->core, q->num);
 }
 
-static int mlxsw_pci_sdq_dbg_read(struct seq_file *file, void *data)
-{
-	struct mlxsw_pci *mlxsw_pci = dev_get_drvdata(file->private);
-	struct mlxsw_pci_queue *q;
-	int i;
-	static const char hdr[] =
-		"NUM PROD_COUNT CONS_COUNT COUNT\n";
-
-	seq_printf(file, hdr);
-	for (i = 0; i < mlxsw_pci_sdq_count(mlxsw_pci); i++) {
-		q = mlxsw_pci_sdq_get(mlxsw_pci, i);
-		spin_lock_bh(&q->lock);
-		seq_printf(file, "%3d %10d %10d %5d\n",
-			   i, q->producer_counter, q->consumer_counter,
-			   q->count);
-		spin_unlock_bh(&q->lock);
-	}
-	return 0;
-}
-
 static int mlxsw_pci_wqe_frag_map(struct mlxsw_pci *mlxsw_pci, char *wqe,
 				  int index, char *frag_data, size_t frag_len,
 				  int direction)
@@ -544,26 +494,6 @@ static void mlxsw_pci_rdq_fini(struct mlxsw_pci *mlxsw_pci,
 	}
 }
 
-static int mlxsw_pci_rdq_dbg_read(struct seq_file *file, void *data)
-{
-	struct mlxsw_pci *mlxsw_pci = dev_get_drvdata(file->private);
-	struct mlxsw_pci_queue *q;
-	int i;
-	static const char hdr[] =
-		"NUM PROD_COUNT CONS_COUNT COUNT\n";
-
-	seq_printf(file, hdr);
-	for (i = 0; i < mlxsw_pci_rdq_count(mlxsw_pci); i++) {
-		q = mlxsw_pci_rdq_get(mlxsw_pci, i);
-		spin_lock_bh(&q->lock);
-		seq_printf(file, "%3d %10d %10d %5d\n",
-			   i, q->producer_counter, q->consumer_counter,
-			   q->count);
-		spin_unlock_bh(&q->lock);
-	}
-	return 0;
-}
-
 static int mlxsw_pci_cq_init(struct mlxsw_pci *mlxsw_pci, char *mbox,
 			     struct mlxsw_pci_queue *q)
 {
@@ -601,27 +531,6 @@ static void mlxsw_pci_cq_fini(struct mlxsw_pci *mlxsw_pci,
 	mlxsw_cmd_hw2sw_cq(mlxsw_pci->core, q->num);
 }
 
-static int mlxsw_pci_cq_dbg_read(struct seq_file *file, void *data)
-{
-	struct mlxsw_pci *mlxsw_pci = dev_get_drvdata(file->private);
-
-	struct mlxsw_pci_queue *q;
-	int i;
-	static const char hdr[] =
-		"NUM CONS_INDEX  SDQ_COUNT  RDQ_COUNT COUNT\n";
-
-	seq_printf(file, hdr);
-	for (i = 0; i < mlxsw_pci_cq_count(mlxsw_pci); i++) {
-		q = mlxsw_pci_cq_get(mlxsw_pci, i);
-		spin_lock_bh(&q->lock);
-		seq_printf(file, "%3d %10d %10d %10d %5d\n",
-			   i, q->consumer_counter, q->u.cq.comp_sdq_count,
-			   q->u.cq.comp_rdq_count, q->count);
-		spin_unlock_bh(&q->lock);
-	}
-	return 0;
-}
-
 static void mlxsw_pci_cqe_sdq_handle(struct mlxsw_pci *mlxsw_pci,
 				     struct mlxsw_pci_queue *q,
 				     u16 consumer_counter_limit,
@@ -775,27 +684,6 @@ static void mlxsw_pci_eq_fini(struct mlxsw_pci *mlxsw_pci,
 	mlxsw_cmd_hw2sw_eq(mlxsw_pci->core, q->num);
 }
 
-static int mlxsw_pci_eq_dbg_read(struct seq_file *file, void *data)
-{
-	struct mlxsw_pci *mlxsw_pci = dev_get_drvdata(file->private);
-	struct mlxsw_pci_queue *q;
-	int i;
-	static const char hdr[] =
-		"NUM CONS_COUNT     EV_CMD    EV_COMP   EV_OTHER COUNT\n";
-
-	seq_printf(file, hdr);
-	for (i = 0; i < mlxsw_pci_eq_count(mlxsw_pci); i++) {
-		q = mlxsw_pci_eq_get(mlxsw_pci, i);
-		spin_lock_bh(&q->lock);
-		seq_printf(file, "%3d %10d %10d %10d %10d %5d\n",
-			   i, q->consumer_counter, q->u.eq.ev_cmd_count,
-			   q->u.eq.ev_comp_count, q->u.eq.ev_other_count,
-			   q->count);
-		spin_unlock_bh(&q->lock);
-	}
-	return 0;
-}
-
 static void mlxsw_pci_eq_cmd_event(struct mlxsw_pci *mlxsw_pci, char *eqe)
 {
 	mlxsw_pci->cmd.comp.status = mlxsw_pci_eqe_cmd_status_get(eqe);
@@ -866,7 +754,6 @@ struct mlxsw_pci_queue_ops {
 	void (*fini)(struct mlxsw_pci *mlxsw_pci,
 		     struct mlxsw_pci_queue *q);
 	void (*tasklet)(unsigned long data);
-	int (*dbg_read)(struct seq_file *s, void *data);
 	u16 elem_count;
 	u8 elem_size;
 };
@@ -875,7 +762,6 @@ static const struct mlxsw_pci_queue_ops mlxsw_pci_sdq_ops = {
 	.type		= MLXSW_PCI_QUEUE_TYPE_SDQ,
 	.init		= mlxsw_pci_sdq_init,
 	.fini		= mlxsw_pci_sdq_fini,
-	.dbg_read	= mlxsw_pci_sdq_dbg_read,
 	.elem_count	= MLXSW_PCI_WQE_COUNT,
 	.elem_size	= MLXSW_PCI_WQE_SIZE,
 };
@@ -884,7 +770,6 @@ static const struct mlxsw_pci_queue_ops mlxsw_pci_rdq_ops = {
 	.type		= MLXSW_PCI_QUEUE_TYPE_RDQ,
 	.init		= mlxsw_pci_rdq_init,
 	.fini		= mlxsw_pci_rdq_fini,
-	.dbg_read	= mlxsw_pci_rdq_dbg_read,
 	.elem_count	= MLXSW_PCI_WQE_COUNT,
 	.elem_size	= MLXSW_PCI_WQE_SIZE
 };
@@ -894,7 +779,6 @@ static const struct mlxsw_pci_queue_ops mlxsw_pci_cq_ops = {
 	.init		= mlxsw_pci_cq_init,
 	.fini		= mlxsw_pci_cq_fini,
 	.tasklet	= mlxsw_pci_cq_tasklet,
-	.dbg_read	= mlxsw_pci_cq_dbg_read,
 	.elem_count	= MLXSW_PCI_CQE_COUNT,
 	.elem_size	= MLXSW_PCI_CQE_SIZE
 };
@@ -904,7 +788,6 @@ static const struct mlxsw_pci_queue_ops mlxsw_pci_eq_ops = {
 	.init		= mlxsw_pci_eq_init,
 	.fini		= mlxsw_pci_eq_fini,
 	.tasklet	= mlxsw_pci_eq_tasklet,
-	.dbg_read	= mlxsw_pci_eq_dbg_read,
 	.elem_count	= MLXSW_PCI_EQE_COUNT,
 	.elem_size	= MLXSW_PCI_EQE_SIZE
 };
@@ -982,9 +865,7 @@ static int mlxsw_pci_queue_group_init(struct mlxsw_pci *mlxsw_pci, char *mbox,
 				      const struct mlxsw_pci_queue_ops *q_ops,
 				      u8 num_qs)
 {
-	struct pci_dev *pdev = mlxsw_pci->pdev;
 	struct mlxsw_pci_queue_type_group *queue_group;
-	char tmp[16];
 	int i;
 	int err;
 
@@ -1001,10 +882,6 @@ static int mlxsw_pci_queue_group_init(struct mlxsw_pci *mlxsw_pci, char *mbox,
 	}
 	queue_group->count = num_qs;
 
-	sprintf(tmp, "%s_stats", mlxsw_pci_queue_type_str(q_ops->type));
-	debugfs_create_devm_seqfile(&pdev->dev, tmp, mlxsw_pci->dbg_dir,
-				    q_ops->dbg_read);
-
 	return 0;
 
 err_queue_init:
@@ -1850,14 +1727,6 @@ static int mlxsw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	mlxsw_pci->bus_info.device_name = pci_name(mlxsw_pci->pdev);
 	mlxsw_pci->bus_info.dev = &pdev->dev;
 
-	mlxsw_pci->dbg_dir = debugfs_create_dir(mlxsw_pci->bus_info.device_name,
-						mlxsw_pci_dbg_root);
-	if (!mlxsw_pci->dbg_dir) {
-		dev_err(&pdev->dev, "Failed to create debugfs dir\n");
-		err = -ENOMEM;
-		goto err_dbg_create_dir;
-	}
-
 	err = mlxsw_core_bus_device_register(&mlxsw_pci->bus_info,
 					     &mlxsw_pci_bus, mlxsw_pci);
 	if (err) {
@@ -1868,8 +1737,6 @@ static int mlxsw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	return 0;
 
 err_bus_device_register:
-	debugfs_remove_recursive(mlxsw_pci->dbg_dir);
-err_dbg_create_dir:
 	pci_disable_msix(mlxsw_pci->pdev);
 err_msix_init:
 err_sw_reset:
@@ -1890,7 +1757,6 @@ static void mlxsw_pci_remove(struct pci_dev *pdev)
 	struct mlxsw_pci *mlxsw_pci = pci_get_drvdata(pdev);
 
 	mlxsw_core_bus_device_unregister(mlxsw_pci->core);
-	debugfs_remove_recursive(mlxsw_pci->dbg_dir);
 	pci_disable_msix(mlxsw_pci->pdev);
 	iounmap(mlxsw_pci->hw_addr);
 	pci_release_regions(mlxsw_pci->pdev);
@@ -1914,15 +1780,11 @@ EXPORT_SYMBOL(mlxsw_pci_driver_unregister);
 
 static int __init mlxsw_pci_module_init(void)
 {
-	mlxsw_pci_dbg_root = debugfs_create_dir(mlxsw_pci_driver_name, NULL);
-	if (!mlxsw_pci_dbg_root)
-		return -ENOMEM;
 	return 0;
 }
 
 static void __exit mlxsw_pci_module_exit(void)
 {
-	debugfs_remove_recursive(mlxsw_pci_dbg_root);
 }
 
 module_init(mlxsw_pci_module_init);
-- 
2.7.4
