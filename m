From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH v3 1/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Fri, 31 Aug 2007 15:36:25 -0700
Message-ID: <1188599785.5176.11.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: anilgv@broadcom.com, talm@broadcom.com, lusinsky@broadcom.com,
	uri@broadcom.com
To: davem@davemloft.net, mchristi@redhat.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2233 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965875AbXHaVjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 17:39:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index b92b7dc..bde67a2 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2253,6 +2253,16 @@ config BNX2
 	  To compile this driver as a module, choose M here: the module
 	  will be called bnx2.  This is recommended.
 
+config CNIC
+	tristate "Broadcom CNIC support"
+	depends on BNX2
+	help
+	  This driver supports offload features of Broadcom NetXtremeII
+	  gigabit Ethernet cards.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called cnic.  This is recommended.
+
 config SPIDER_NET
 	tristate "Spider Gigabit Ethernet driver"
 	depends on PCI && (PPC_IBM_CELL_BLADE || PPC_CELLEB)
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index c964c7b..b5d8d00 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -59,6 +59,7 @@ obj-$(CONFIG_STNIC) += stnic.o 8390.o
 obj-$(CONFIG_FEALNX) += fealnx.o
 obj-$(CONFIG_TIGON3) += tg3.o
 obj-$(CONFIG_BNX2) += bnx2.o
+obj-$(CONFIG_CNIC) += cnic.o
 spidernet-y += spider_net.o spider_net_ethtool.o
 obj-$(CONFIG_SPIDER_NET) += spidernet.o sungem_phy.o
 obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index e4aede6..706def2 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -242,7 +242,7 @@ static inline u32 bnx2_tx_avail(struct bnx2 *bp)
 	return (bp->tx_ring_size - diff);
 }
 
-static u32
+u32
 bnx2_reg_rd_ind(struct bnx2 *bp, u32 offset)
 {
 	u32 val;
@@ -254,7 +254,7 @@ bnx2_reg_rd_ind(struct bnx2 *bp, u32 offset)
 	return val;
 }
 
-static void
+void
 bnx2_reg_wr_ind(struct bnx2 *bp, u32 offset, u32 val)
 {
 	spin_lock_bh(&bp->indirect_lock);
@@ -263,7 +263,7 @@ bnx2_reg_wr_ind(struct bnx2 *bp, u32 offset, u32 val)
 	spin_unlock_bh(&bp->indirect_lock);
 }
 
-static void
+void
 bnx2_ctx_wr(struct bnx2 *bp, u32 cid_addr, u32 offset, u32 val)
 {
 	offset += cid_addr;
@@ -447,6 +447,26 @@ bnx2_netif_start(struct bnx2 *bp)
 }
 
 static void
+bnx2_cnic_stop(struct bnx2 *bp)
+{
+	struct cnic_ops *c_ops;
+
+	c_ops = rcu_dereference(bp->cnic_ops);
+	if (c_ops)
+		c_ops->cnic_stop(bp->cnic_data);
+}
+
+static void
+bnx2_cnic_start(struct bnx2 *bp)
+{
+	struct cnic_ops *c_ops;
+
+	c_ops = rcu_dereference(bp->cnic_ops);
+	if (c_ops)
+		c_ops->cnic_start(bp->cnic_data);
+}
+
+static void
 bnx2_free_mem(struct bnx2 *bp)
 {
 	int i;
@@ -2628,6 +2648,9 @@ bnx2_has_work(struct bnx2 *bp)
 	    (sblk->status_attn_bits_ack & STATUS_ATTN_EVENTS))
 		return 1;
 
+	if (rcu_dereference(bp->cnic_ops) && (bp->cnic_tag != sblk->status_idx))
+		return 1;
+
 	return 0;
 }
 
@@ -2640,6 +2663,7 @@ bnx2_poll(struct napi_struct *napi, int budget)
 	u32 status_attn_bits = sblk->status_attn_bits;
 	u32 status_attn_bits_ack = sblk->status_attn_bits_ack;
 	int work_done = 0;
+ 	struct cnic_ops *c_ops;
 
 	if ((status_attn_bits & STATUS_ATTN_EVENTS) !=
 	    (status_attn_bits_ack & STATUS_ATTN_EVENTS)) {
@@ -2660,6 +2684,13 @@ bnx2_poll(struct napi_struct *napi, int budget)
 	if (bp->status_blk->status_rx_quick_consumer_index0 != bp->hw_rx_cons)
 		work_done = bnx2_rx_int(bp, budget);
 
+	rcu_read_lock();
+	c_ops = rcu_dereference(bp->cnic_ops);
+	if (c_ops)
+		bp->cnic_tag = c_ops->cnic_handler(bp->cnic_data,
+						   bp->status_blk);
+	rcu_read_unlock();
+
 	bp->last_status_idx = bp->status_blk->status_idx;
 	rmb();
 
@@ -2684,6 +2715,52 @@ bnx2_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
+int bnx2_register_cnic(struct net_device *dev, struct cnic_ops *ops, void *data)
+{
+	struct bnx2 *bp = netdev_priv(dev);
+
+	if (ops == NULL)
+		return -EINVAL;
+
+	if (netif_running(bp->dev)) {
+		struct status_block *status_blk = bp->status_blk;
+		int i = 0;
+
+		while (status_blk->status_completion_producer_index && i < 10) {
+			REG_WR(bp, BNX2_HC_COMMAND,
+			       bp->hc_cmd | BNX2_HC_COMMAND_COAL_NOW_WO_INT);
+			udelay(10);
+			i++;
+			barrier();
+		}
+		if (status_blk->status_completion_producer_index) {
+			printk(KERN_ERR PFX "%s: "
+			       "KCQ index not resetting to 0.\n",
+			       bp->dev->name);
+			return -EBUSY;
+		}
+	}
+
+	if (!try_module_get(ops->cnic_owner))
+		return -EBUSY;
+
+	bp->cnic_tag = bp->last_status_idx;
+	bp->cnic_data = data;
+	rcu_assign_pointer(bp->cnic_ops, ops);
+
+	return 0;
+}
+
+int bnx2_unregister_cnic(struct net_device *dev)
+{
+	struct bnx2 *bp = netdev_priv(dev);
+
+	module_put(bp->cnic_ops->cnic_owner);
+	rcu_assign_pointer(bp->cnic_ops, NULL);
+	synchronize_rcu();
+	return 0;
+}
+
 /* Called with rtnl_lock from vlan functions and also netif_tx_lock
  * from set_multicast.
  */
@@ -2759,7 +2836,7 @@ bnx2_set_rx_mode(struct net_device *dev)
 	spin_unlock_bh(&bp->phy_lock);
 }
 
-#define FW_BUF_SIZE	0x8000
+#define FW_BUF_SIZE	0x10000
 
 static int
 bnx2_gunzip_init(struct bnx2 *bp)
@@ -3099,13 +3176,15 @@ bnx2_init_cpus(struct bnx2 *bp)
 	cpu_reg.spad_base = BNX2_CP_SCRATCH;
 	cpu_reg.mips_view_base = 0x8000000;
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+	if (CHIP_NUM(bp) == CHIP_NUM_5709)
 		fw = &bnx2_cp_fw_09;
+	else
+		fw = &bnx2_cp_fw_06;
+
+	rc = load_cpu_fw(bp, &cpu_reg, fw);
+	if (rc)
+		goto init_cpu_err;
 
-		rc = load_cpu_fw(bp, &cpu_reg, fw);
-		if (rc)
-			goto init_cpu_err;
-	}
 init_cpu_err:
 	bnx2_gunzip_end(bp);
 	return rc;
@@ -5109,12 +5188,14 @@ bnx2_reset_task(struct work_struct *work)
 		return;
 
 	bp->in_reset_task = 1;
+	bnx2_cnic_stop(bp);
 	bnx2_netif_stop(bp);
 
 	bnx2_init_nic(bp);
 
 	atomic_set(&bp->intr_sem, 1);
 	bnx2_netif_start(bp);
+	bnx2_cnic_start(bp);
 	bp->in_reset_task = 0;
 }
 
@@ -5801,9 +5882,11 @@ bnx2_set_coalesce(struct net_device *dev, struct ethtool_coalesce *coal)
 	bp->stats_ticks &= BNX2_HC_STATS_TICKS_HC_STAT_TICKS;
 
 	if (netif_running(bp->dev)) {
+		bnx2_cnic_stop(bp);
 		bnx2_netif_stop(bp);
 		bnx2_init_nic(bp);
 		bnx2_netif_start(bp);
+		bnx2_cnic_start(bp);
 	}
 
 	return 0;
@@ -5837,7 +5920,9 @@ bnx2_set_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
 
 		return -EINVAL;
 	}
+
 	if (netif_running(bp->dev)) {
+		bnx2_cnic_stop(bp);
 		bnx2_netif_stop(bp);
 		bnx2_reset_chip(bp, BNX2_DRV_MSG_CODE_RESET);
 		bnx2_free_skbs(bp);
@@ -5855,6 +5940,7 @@ bnx2_set_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
 			return rc;
 		bnx2_init_nic(bp);
 		bnx2_netif_start(bp);
+		bnx2_cnic_start(bp);
 	}
 
 	return 0;
@@ -6080,6 +6166,7 @@ bnx2_self_test(struct net_device *dev, struct ethtool_test *etest, u64 *buf)
 	if (etest->flags & ETH_TEST_FL_OFFLINE) {
 		int i;
 
+		bnx2_cnic_stop(bp);
 		bnx2_netif_stop(bp);
 		bnx2_reset_chip(bp, BNX2_DRV_MSG_CODE_DIAG);
 		bnx2_free_skbs(bp);
@@ -6101,6 +6188,7 @@ bnx2_self_test(struct net_device *dev, struct ethtool_test *etest, u64 *buf)
 		else {
 			bnx2_init_nic(bp);
 			bnx2_netif_start(bp);
+			bnx2_cnic_start(bp);
 		}
 
 		/* wait for link up */
@@ -6352,11 +6440,13 @@ bnx2_change_mtu(struct net_device *dev, int new_mtu)
 
 	dev->mtu = new_mtu;
 	if (netif_running(dev)) {
+		bnx2_cnic_stop(bp);
 		bnx2_netif_stop(bp);
 
 		bnx2_init_nic(bp);
 
 		bnx2_netif_start(bp);
+		bnx2_cnic_start(bp);
 	}
 	return 0;
 }
@@ -6943,6 +7033,7 @@ bnx2_suspend(struct pci_dev *pdev, pm_message_t state)
 		return 0;
 
 	flush_scheduled_work();
+ 	bnx2_cnic_stop(bp);
 	bnx2_netif_stop(bp);
 	netif_device_detach(dev);
 	del_timer_sync(&bp->timer);
@@ -6972,6 +7063,7 @@ bnx2_resume(struct pci_dev *pdev)
 	netif_device_attach(dev);
 	bnx2_init_nic(bp);
 	bnx2_netif_start(bp);
+	bnx2_cnic_start(bp);
 	return 0;
 }
 
@@ -6997,5 +7089,8 @@ static void __exit bnx2_cleanup(void)
 module_init(bnx2_init);
 module_exit(bnx2_cleanup);
 
-
-
+EXPORT_SYMBOL(bnx2_register_cnic);
+EXPORT_SYMBOL(bnx2_unregister_cnic);
+EXPORT_SYMBOL(bnx2_reg_rd_ind);
+EXPORT_SYMBOL(bnx2_reg_wr_ind);
+EXPORT_SYMBOL(bnx2_ctx_wr);
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index fbae439..4230b4b 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6465,6 +6465,16 @@ struct flash_spec {
 	u8  *name;
 };
 
+struct cnic_ops {
+	struct module		*cnic_owner;
+	void			(*cnic_stop)(void *);
+	void			(*cnic_start)(void *);
+	int			(*cnic_handler)(void *, struct status_block *);
+};
+
+extern int bnx2_register_cnic(struct net_device *, struct cnic_ops *, void *) __attribute__((weak));
+extern int bnx2_unregister_cnic(struct net_device *) __attribute__((weak));
+
 struct bnx2 {
 	/* Fields used in the tx and intr/napi performance paths are grouped */
 	/* together in the beginning of the structure. */
@@ -6526,6 +6536,10 @@ struct bnx2 {
 	int		tx_ring_size;
 	u32		tx_wake_thresh;
 
+	struct cnic_ops		*cnic_ops;
+	void			*cnic_data;
+	int			cnic_tag;
+
 	/* End of fields used in the performance code paths. */
 
 	char			*name;
@@ -6637,6 +6651,7 @@ struct bnx2 {
 
 	u16			req_line_speed;
 	u8			req_duplex;
+	u8			req_port;
 
 	u8			phy_port;
 	u8			link_up;
@@ -6686,8 +6701,8 @@ struct bnx2 {
 	void			*gunzip_buf;
 };
 
-static u32 bnx2_reg_rd_ind(struct bnx2 *bp, u32 offset);
-static void bnx2_reg_wr_ind(struct bnx2 *bp, u32 offset, u32 val);
+extern u32 bnx2_reg_rd_ind(struct bnx2 *bp, u32 offset) __attribute__((weak));
+extern void bnx2_reg_wr_ind(struct bnx2 *bp, u32 offset, u32 val) __attribute__((weak));
 
 #define REG_RD(bp, offset)					\
 	readl(bp->regview + offset)
@@ -6706,7 +6721,7 @@ static void bnx2_reg_wr_ind(struct bnx2 *bp, u32 offset, u32 val);
 
 /* Indirect context access.  Unlike the MBQ_WR, these macros will not
  * trigger a chip event. */
-static void bnx2_ctx_wr(struct bnx2 *bp, u32 cid_addr, u32 offset, u32 val);
+extern void bnx2_ctx_wr(struct bnx2 *bp, u32 cid_addr, u32 offset, u32 val) __attribute__((weak));
 
 #define CTX_WR(bp, cid_addr, offset, val)			\
 	bnx2_ctx_wr(bp, cid_addr, offset, val)
diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
new file mode 100644
index 0000000..b8817c3
--- /dev/null
+++ b/drivers/net/cnic.c
@@ -0,0 +1,1881 @@
+/* cnic.c: Broadcom CNIC core network driver.
+ *
+ * Copyright (c) 2006-2007 Broadcom Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Written by: John(Zongxi) Chen (zongxi@broadcom.com)
+ * Modified and maintained by: Michael Chan <mchan@broadcom.com>
+ */
+
+#include <linux/module.h>
+
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/list.h>
+#include <linux/slab.h>
+#include <linux/pci.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/inetdevice.h>
+#include <linux/in.h>
+#include <linux/dma-mapping.h>
+#include <asm/byteorder.h>
+#include <linux/delay.h>
+#include <linux/ethtool.h>
+#include <linux/if_vlan.h>
+#define BCM_VLAN 1
+#include <net/ip.h>
+#include <net/tcp.h>
+#include <linux/workqueue.h>
+#include <net/arp.h>
+#include <net/neighbour.h>
+#include <net/route.h>
+#include <net/netevent.h>
+
+#include "bnx2.h"
+#include "cnic_if.h"
+#include "cnic.h"
+#include "cnic_cm.h"
+
+#define DRV_MODULE_NAME 	"cnic"
+#define PFX DRV_MODULE_NAME ": "
+
+static char version[] __devinitdata =
+	"Broadcom NetXtreme II CNIC Driver " DRV_MODULE_NAME " v" CNIC_MODULE_VERSION " (" CNIC_MODULE_RELDATE ")\n";
+
+MODULE_AUTHOR("John(Zongxi) Chen <zongxic@broadcom.com>");
+MODULE_DESCRIPTION("Broadcom NetXtreme II CNIC Driver");
+MODULE_LICENSE("GPL");
+MODULE_VERSION(CNIC_MODULE_VERSION);
+
+static LIST_HEAD(cnic_dev_list);
+static DEFINE_RWLOCK(cnic_dev_lock);
+static DEFINE_MUTEX(cnic_lock);
+
+struct cnic_ulp_ops *cnic_ulp_tbl[MAX_CNIC_ULP_TYPE];
+
+static int cnic_service_kq(void *, struct status_block *);
+static void cnic_service_stop(void *);
+static void cnic_service_start(void *);
+
+static struct cnic_ops my_cnic_ops = {
+	.cnic_owner	= THIS_MODULE,
+	.cnic_handler	= cnic_service_kq,
+	.cnic_stop	= cnic_service_stop,
+	.cnic_start	= cnic_service_start,
+};
+
+static inline void cnic_hold(struct cnic_dev *dev)
+{
+	atomic_inc(&dev->ref_count);
+}
+
+static inline void cnic_put(struct cnic_dev *dev)
+{
+	atomic_dec(&dev->ref_count);
+}
+
+int cnic_register_driver(int ulp_type, struct cnic_ulp_ops *ulp_ops)
+{
+	struct cnic_dev *dev;
+
+	if (ulp_type >= MAX_CNIC_ULP_TYPE) {
+		printk(KERN_ERR PFX "cnic_register_driver: Bad type %d\n",
+		       ulp_type);
+		return -EINVAL;
+	}
+	mutex_lock(&cnic_lock);
+	if (cnic_ulp_tbl[ulp_type]) {
+		printk(KERN_ERR PFX "cnic_register_driver: Type %d has already "
+				    "been registered\n", ulp_type);
+		mutex_unlock(&cnic_lock);
+		return -EBUSY;
+	}
+
+	read_lock(&cnic_dev_lock);
+	list_for_each_entry(dev, &cnic_dev_list, list) {
+		struct cnic_local *cp = dev->cnic_priv;
+
+		clear_bit(ULP_F_INIT, &cp->ulp_flags[ulp_type]);
+	}
+	read_unlock(&cnic_dev_lock);
+
+	rcu_assign_pointer(cnic_ulp_tbl[ulp_type], ulp_ops);
+	mutex_unlock(&cnic_lock);
+
+	read_lock(&cnic_dev_lock);
+	list_for_each_entry(dev, &cnic_dev_list, list) {
+		struct cnic_local *cp = dev->cnic_priv;
+
+		/* Prevent race conditions with netdev_event */
+		rtnl_lock();
+		if (!test_and_set_bit(ULP_F_INIT, &cp->ulp_flags[ulp_type]))
+			ulp_ops->cnic_init(dev);
+		rtnl_unlock();
+	}
+	read_unlock(&cnic_dev_lock);
+
+	return 0;
+}
+
+int cnic_unregister_driver(int ulp_type)
+{
+	struct cnic_dev *dev;
+
+	if (ulp_type >= MAX_CNIC_ULP_TYPE) {
+		printk(KERN_ERR PFX "cnic_unregister_driver: Bad type %d\n",
+		       ulp_type);
+		return -EINVAL;
+	}
+	mutex_lock(&cnic_lock);
+	if (!cnic_ulp_tbl[ulp_type]) {
+		printk(KERN_ERR PFX "cnic_unregister_driver: Type %d has not "
+				    "been registered\n", ulp_type);
+		goto out_unlock;
+	}
+	read_lock(&cnic_dev_lock);
+	list_for_each_entry(dev, &cnic_dev_list, list) {
+		struct cnic_local *cp = dev->cnic_priv;
+		
+		if (rcu_dereference(cp->ulp_ops[ulp_type])) {
+			printk(KERN_ERR PFX "cnic_unregister_driver: Type %d "
+			       "still has devices registered\n", ulp_type);
+			read_unlock(&cnic_dev_lock);
+			goto out_unlock;
+		}
+	}
+	read_unlock(&cnic_dev_lock);
+
+	rcu_assign_pointer(cnic_ulp_tbl[ulp_type], NULL);
+
+	mutex_unlock(&cnic_lock);
+	synchronize_rcu();
+	return 0;
+
+out_unlock:
+	mutex_unlock(&cnic_lock);
+	return -EINVAL;
+}
+
+EXPORT_SYMBOL(cnic_register_driver);
+EXPORT_SYMBOL(cnic_unregister_driver);
+
+static int cnic_start_hw(struct cnic_dev *);
+static void cnic_stop_hw(struct cnic_dev *);
+
+static int cnic_register_device(struct cnic_dev *dev, int ulp_type,
+				void *ulp_ctx)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_ulp_ops *ulp_ops;
+
+	if (ulp_type >= MAX_CNIC_ULP_TYPE) {
+		printk(KERN_ERR PFX "cnic_register_device: Bad type %d\n",
+		       ulp_type);
+		return -EINVAL;
+	}
+	mutex_lock(&cnic_lock);
+	if (cnic_ulp_tbl[ulp_type] == NULL) {
+		printk(KERN_ERR PFX "cnic_register_device: Driver with type %d "
+				    "has not been registered\n", ulp_type);
+		mutex_unlock(&cnic_lock);
+		return -EAGAIN;
+	}
+	if (rcu_dereference(cp->ulp_ops[ulp_type])) {
+		printk(KERN_ERR PFX "cnic_register_device: Type %d has already "
+		       "been registered to this device\n", ulp_type);
+		mutex_unlock(&cnic_lock);
+		return -EBUSY;
+	}
+	if (!try_module_get(cnic_ulp_tbl[ulp_type]->owner)) {
+		mutex_unlock(&cnic_lock);
+		return -EBUSY;
+	}
+
+	clear_bit(ULP_F_START, &cp->ulp_flags[ulp_type]);
+	cp->ulp_handle[ulp_type] = ulp_ctx;
+	ulp_ops = cnic_ulp_tbl[ulp_type];
+	rcu_assign_pointer(cp->ulp_ops[ulp_type], ulp_ops);
+	cnic_hold(dev);
+	dev->use_count++;
+
+	if (dev->use_count == 1) {
+		if (test_bit(CNIC_F_IF_UP, &dev->flags))
+			cnic_start_hw(dev);
+	}
+
+	if (test_bit(CNIC_F_CNIC_UP, &dev->flags))
+		if (!test_and_set_bit(ULP_F_START, &cp->ulp_flags[ulp_type]))
+			ulp_ops->cnic_start(cp->ulp_handle[ulp_type]);
+
+	mutex_unlock(&cnic_lock);
+
+	return 0;
+
+}
+
+static int cnic_unregister_device(struct cnic_dev *dev, int ulp_type)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+
+	if (ulp_type >= MAX_CNIC_ULP_TYPE) {
+		printk(KERN_ERR PFX "cnic_unregister_device: Bad type %d\n",
+		       ulp_type);
+		return -EINVAL;
+	}
+	mutex_lock(&cnic_lock);
+	if (rcu_dereference(cp->ulp_ops[ulp_type])) {
+		dev->use_count--;
+		module_put(cp->ulp_ops[ulp_type]->owner);
+		rcu_assign_pointer(cp->ulp_ops[ulp_type], NULL);
+		if (dev->use_count == 0)
+			cnic_stop_hw(dev);
+		cnic_put(dev);
+	} else {
+		printk(KERN_ERR PFX "cnic_unregister_device: device not "
+		       "registered to this ulp type %d\n", ulp_type);
+		mutex_unlock(&cnic_lock);
+		return -EINVAL;
+	}
+	mutex_unlock(&cnic_lock);
+
+	synchronize_rcu();
+
+	return 0;
+}
+
+static ssize_t show_pci_bar(struct class_device *cdev, char *buf)
+{
+	struct cnic_dev *dev = container_of(cdev, struct cnic_dev, class_dev);
+
+	return sprintf(buf, "0x%.8x\n", (u32)pci_resource_start(dev->pcidev, 0));
+}
+
+static ssize_t show_kq_intr_coal(struct class_device *cdev, char *buf)
+{
+	struct cnic_dev *dev = container_of(cdev, struct cnic_dev, class_dev);
+
+	return sprintf(buf, "0x%.8x\n", REG_RD(dev, BNX2_HC_COMP_PROD_TRIP));
+}
+
+static ssize_t set_kq_intr_coal(struct class_device *cdev, const char *buf,
+			      size_t count)
+{
+	struct cnic_dev *dev = container_of(cdev, struct cnic_dev, class_dev);
+	u32 val;
+
+	if (sscanf(buf, " 0x%x ", &val) > 0)
+		REG_WR(dev, BNX2_HC_COMP_PROD_TRIP, val);
+	return count;
+}
+
+static ssize_t show_kq_com_ticks(struct class_device *cdev, char *buf)
+{
+	struct cnic_dev *dev = container_of(cdev, struct cnic_dev, class_dev);
+
+	return sprintf(buf, "0x%.8x\n", REG_RD(dev, BNX2_HC_COM_TICKS));
+}
+
+static ssize_t set_kq_com_ticks(struct class_device *cdev, const char *buf,
+			      size_t count)
+{
+	struct cnic_dev *dev = container_of(cdev, struct cnic_dev, class_dev);
+	u32 val;
+
+	if (sscanf(buf, " 0x%x ", &val) > 0)
+		REG_WR(dev, BNX2_HC_COM_TICKS, val);
+	return count;
+}
+
+static ssize_t show_kq_cmd_ticks(struct class_device *cdev, char *buf)
+{
+	struct cnic_dev *dev = container_of(cdev, struct cnic_dev, class_dev);
+
+	return sprintf(buf, "0x%.8x\n", REG_RD(dev, BNX2_HC_CMD_TICKS));
+}
+
+static ssize_t set_kq_cmd_ticks(struct class_device *cdev, const char *buf,
+			      size_t count)
+{
+	struct cnic_dev *dev = container_of(cdev, struct cnic_dev, class_dev);
+	u32 val;
+
+	if (sscanf(buf, " 0x%x ", &val) > 0)
+		REG_WR(dev, BNX2_HC_CMD_TICKS, val);
+	return count;
+}
+
+static CLASS_DEVICE_ATTR(pci_bar, S_IRUGO, show_pci_bar, NULL);
+static CLASS_DEVICE_ATTR(kq_intr_coal, S_IRUGO | S_IWUSR, show_kq_intr_coal,
+			 set_kq_intr_coal);
+static CLASS_DEVICE_ATTR(kq_com_ticks, S_IRUGO | S_IWUSR, show_kq_com_ticks,
+			 set_kq_com_ticks);
+static CLASS_DEVICE_ATTR(kq_cmd_ticks, S_IRUGO | S_IWUSR, show_kq_cmd_ticks,
+			 set_kq_cmd_ticks);
+
+static struct class_device_attribute *cnic_class_attributes[] = {
+	&class_device_attr_pci_bar,
+	&class_device_attr_kq_intr_coal,
+	&class_device_attr_kq_com_ticks,
+	&class_device_attr_kq_cmd_ticks
+};
+
+static void cnic_sysfs_release(struct class_device *class_dev)
+{
+}
+
+static struct class cnic_class = {
+	.name    = "cnic",
+	.release = cnic_sysfs_release,
+};
+
+static int cnic_register_sysfs(struct cnic_dev *device)
+{
+	struct class_device *class_dev = &device->class_dev;
+	char dev_name[BUS_ID_SIZE];
+	int ret;
+	int i;
+
+	class_dev->class      = &cnic_class;
+	class_dev->class_data = device;
+	snprintf(dev_name, BUS_ID_SIZE, "%.2x:%.2x.%.1x",
+		 device->pcidev->bus->number, PCI_SLOT(device->pcidev->devfn),
+		 PCI_FUNC(device->pcidev->devfn));
+	strlcpy(class_dev->class_id, dev_name, BUS_ID_SIZE);
+
+	ret = class_device_register(class_dev);
+	if (ret)
+		goto err;
+
+	for (i = 0; i < ARRAY_SIZE(cnic_class_attributes); ++i) {
+		ret = class_device_create_file(class_dev,
+					       cnic_class_attributes[i]);
+		if (ret)
+			goto err_unregister;
+	}
+
+	return 0;
+
+err_unregister:
+	class_device_unregister(class_dev);
+err:
+	return ret;
+}
+
+static void cnic_unregister_sysfs(struct cnic_dev *device)
+{
+	class_device_unregister(&device->class_dev);
+}
+
+static int cnic_sysfs_setup(void)
+{
+	return class_register(&cnic_class);
+}
+
+static void cnic_sysfs_cleanup(void)
+{
+	class_unregister(&cnic_class);
+}
+
+static void cnic_free_resc(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	int i;
+
+	if (cp->kwq_pgtbl) {
+		pci_free_consistent(dev->pcidev, cp->kwq_pgtbl_size,
+				    cp->kwq_pgtbl, cp->kwq_pgtbl_mapping);
+		cp->kwq_pgtbl = NULL;
+	}
+	for (i = 0; i < KWQ_PAGE_CNT; i++) {
+		if (cp->kwq[i]) {
+			pci_free_consistent(dev->pcidev, BCM_PAGE_SIZE,
+					    cp->kwq[i], cp->kwq_mapping[i]);
+			cp->kwq[i] = NULL;
+		}
+	}
+	if (cp->kcq_pgtbl) {
+		pci_free_consistent(dev->pcidev, cp->kcq_pgtbl_size,
+				    cp->kcq_pgtbl, cp->kcq_pgtbl_mapping);
+		cp->kcq_pgtbl = NULL;
+	}
+	for (i = 0; i < KCQ_PAGE_CNT; i++) {
+		if (cp->kcq[i]) {
+			pci_free_consistent(dev->pcidev, BCM_PAGE_SIZE,
+					    cp->kcq[i], cp->kcq_mapping[i]);
+			cp->kcq[i] = NULL;
+		}
+	}
+
+	return;
+}
+
+static int cnic_alloc_resc(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	int i;
+
+	cp->kwq_pgtbl_size = ((KWQ_PAGE_CNT * 8) + BCM_PAGE_SIZE - 1) &
+			      (BCM_PAGE_SIZE - 1);
+	cp->kwq_pgtbl = pci_alloc_consistent(dev->pcidev, cp->kwq_pgtbl_size,
+					     &cp->kwq_pgtbl_mapping);
+	if (cp->kwq_pgtbl == NULL)
+		goto error;
+
+	for (i = 0; i < KWQ_PAGE_CNT; i++) {
+		cp->kwq[i] = pci_alloc_consistent(dev->pcidev, BCM_PAGE_SIZE,
+						  &cp->kwq_mapping[i]);
+		if (cp->kwq[i] == NULL)
+			goto error;
+	}
+
+	cp->kcq_pgtbl_size = ((KCQ_PAGE_CNT * 8) + BCM_PAGE_SIZE - 1) &
+			     (BCM_PAGE_SIZE - 1);
+	cp->kcq_pgtbl = pci_alloc_consistent(dev->pcidev, cp->kcq_pgtbl_size,
+					     &cp->kcq_pgtbl_mapping);
+	if (cp->kcq_pgtbl == NULL)
+		goto error;
+
+	for (i = 0; i < KCQ_PAGE_CNT; i++) {
+		cp->kcq[i] = pci_alloc_consistent(dev->pcidev, BCM_PAGE_SIZE,
+						  &cp->kcq_mapping[i]);
+		if (cp->kcq[i] == NULL)
+			goto error;
+	}
+
+	return 0;
+	
+error:
+	cnic_free_resc(dev);
+	return -ENOMEM;
+}
+
+static void cnic_setup_page_tbl(u32 *page_table, u32 page_cnt,
+				dma_addr_t base_mapping[])
+{
+	int i;
+
+	for (i = 0; i < page_cnt; i++) {
+		/* Each entry needs to be in big endian format. */
+		*page_table = (u32) ((u64) base_mapping[i] >> 32);
+		page_table++;
+		*page_table = (u32) base_mapping[i];
+		page_table++;
+	}
+}
+
+static inline u32 cnic_kwq_avail(struct cnic_local *cp)
+{
+	return (MAX_KWQ_IDX -
+		((cp->kwq_prod_idx - cp->kwq_con_idx) & MAX_KWQ_IDX));
+}
+
+static int cnic_submit_kernel_wqes(struct cnic_dev *dev, struct kwqe *wqes[],
+			    u32 num_wqes)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct kwqe *prod_qe;
+	u16 prod, sw_prod, i;
+
+	if (!test_bit(CNIC_F_CNIC_UP, &dev->flags))
+		return -EAGAIN;		/* bnx2 is down */
+
+	spin_lock_bh(&cp->cnic_ulp_lock);
+	if (num_wqes > cnic_kwq_avail(cp)) {
+		spin_unlock_bh(&cp->cnic_ulp_lock);
+		return -EAGAIN;
+	}
+
+	prod = cp->kwq_prod_idx;
+	sw_prod = prod & MAX_KWQ_IDX;
+	for (i = 0; i < num_wqes; i++) {
+		prod_qe = &cp->kwq[KWQ_PG(sw_prod)][KWQ_IDX(sw_prod)];
+		memcpy(prod_qe, wqes[i], sizeof(struct kwqe));
+		prod++;
+		sw_prod = prod & MAX_KWQ_IDX;
+	}
+	cp->kwq_prod_idx = prod;
+
+	REG_WR16(dev, cp->kwq_io_addr, cp->kwq_prod_idx);
+
+	spin_unlock_bh(&cp->cnic_ulp_lock);
+	return 0;
+}
+
+static void service_kcqes(struct cnic_dev *dev, int num_cqes)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	int i, j;
+
+	i = 0;
+	j = 1;
+	while (num_cqes) {
+		struct cnic_ulp_ops *ulp_ops;
+		int ulp_type;
+		u32 kcqe_op_flag = cp->completed_kcq[i]->kcqe_op_flag &
+				   KCQE_FLAGS_LAYER_MASK;
+
+		while (j < num_cqes) {
+			if ((cp->completed_kcq[i + j]->kcqe_op_flag &
+			     KCQE_FLAGS_LAYER_MASK) != kcqe_op_flag) {
+				break;
+			}
+			j++;
+		}
+
+		if (kcqe_op_flag == KCQE_FLAGS_LAYER_MASK_L5_RDMA)
+			ulp_type = CNIC_ULP_RDMA;
+		else if (kcqe_op_flag == KCQE_FLAGS_LAYER_MASK_L5_ISCSI)
+			ulp_type = CNIC_ULP_ISCSI;
+		else if (kcqe_op_flag == KCQE_FLAGS_LAYER_MASK_L4)
+			ulp_type = CNIC_ULP_L4;
+		else {
+			printk(KERN_ERR PFX "%s: Unknown type of KCQE(0x%x)\n",
+			       dev->netdev->name, kcqe_op_flag);
+			goto end;
+		}
+
+		rcu_read_lock();
+		ulp_ops = rcu_dereference(cp->ulp_ops[ulp_type]);
+		if (likely(ulp_ops)) {
+			ulp_ops->indicate_kcqes(cp->ulp_handle[ulp_type],
+						  cp->completed_kcq + i, j);
+		}
+		rcu_read_unlock();
+end:
+		num_cqes -= j;
+		i += j;
+		j = 1;
+	}
+	return;
+}
+
+static int cnic_service_kq(void *data, struct status_block *status_blk)
+{
+	struct cnic_dev *dev = data;
+	struct cnic_local *cp = dev->cnic_priv;
+	u32 status_idx = status_blk->status_idx;
+	u16 hw_prod, sw_prod;
+
+	cp->kwq_con_idx = status_blk->status_rx_quick_consumer_index15;
+
+	hw_prod = status_blk->status_completion_producer_index;
+	sw_prod = cp->kcq_prod_idx;
+	while (sw_prod != hw_prod) {
+		u16 i, max;
+		struct kcqe *kcqe;
+		int kcqe_cnt = 0;
+
+		i = sw_prod & MAX_KCQ_IDX;
+		max = hw_prod & MAX_KCQ_IDX;
+		while ((i != max) && (kcqe_cnt < MAX_COMPLETED_KCQE)) {
+			cp->completed_kcq[kcqe_cnt++] =
+				&cp->kcq[KCQ_PG(i)][KCQ_IDX(i)];
+			i = (i + 1) & MAX_KCQ_IDX;
+		}
+
+		kcqe = cp->completed_kcq[kcqe_cnt - 1];
+		while (kcqe->kcqe_op_flag & KCQE_FLAGS_NEXT) {
+			kcqe_cnt--;
+			if (kcqe_cnt == 0)
+				goto done;
+			kcqe = cp->completed_kcq[kcqe_cnt - 1];
+		}
+		sw_prod += kcqe_cnt;
+
+		service_kcqes(dev, kcqe_cnt);
+
+		/* Tell compiler that status_blk fields can change. */
+		barrier();
+		if (status_idx != status_blk->status_idx) {
+			status_idx = status_blk->status_idx;
+			cp->kwq_con_idx =
+				status_blk->status_rx_quick_consumer_index15;
+			hw_prod = status_blk->status_completion_producer_index;
+		} else
+			break;
+	}
+
+done:
+	REG_WR16(dev, cp->kcq_io_addr, sw_prod);
+
+	cp->kcq_prod_idx = sw_prod;
+	return status_idx;
+}
+
+static void cnic_ulp_stop(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	int if_type;
+
+	rcu_read_lock();
+	for (if_type = 0; if_type < MAX_CNIC_ULP_TYPE; if_type++) {
+		struct cnic_ulp_ops *ulp_ops;
+
+		ulp_ops = rcu_dereference(cp->ulp_ops[if_type]);
+		if (!ulp_ops)
+			continue;
+
+		if (test_and_clear_bit(ULP_F_START, &cp->ulp_flags[if_type]))
+			ulp_ops->cnic_stop(cp->ulp_handle[if_type]);
+	}
+	rcu_read_unlock();
+}
+
+static void cnic_ulp_start(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	int if_type;
+
+	rcu_read_lock();
+	for (if_type = 0; if_type < MAX_CNIC_ULP_TYPE; if_type++) {
+		struct cnic_ulp_ops *ulp_ops;
+
+		ulp_ops = rcu_dereference(cp->ulp_ops[if_type]);
+		if (!ulp_ops)
+			continue;
+
+		if (!test_and_set_bit(ULP_F_START, &cp->ulp_flags[if_type]))
+			ulp_ops->cnic_start(cp->ulp_handle[if_type]);
+	}
+	rcu_read_unlock();
+}
+
+static void cnic_service_start(void *data)
+{
+	struct cnic_dev *dev = data;
+
+	cnic_hold(dev);
+	mutex_lock(&cnic_lock);
+	set_bit(CNIC_F_IF_UP, &dev->flags);
+	if (dev->use_count) {
+		if (!cnic_start_hw(dev))
+			cnic_ulp_start(dev);
+	}
+	mutex_unlock(&cnic_lock);
+	cnic_put(dev);
+}
+
+static void cnic_service_stop(void *data)
+{
+	struct cnic_dev *dev = data;
+
+	cnic_hold(dev);
+	mutex_lock(&cnic_lock);
+	clear_bit(CNIC_F_IF_UP, &dev->flags);
+	cnic_ulp_stop(dev);
+	cnic_stop_hw(dev);
+	mutex_unlock(&cnic_lock);
+	cnic_put(dev);
+}
+
+static void cnic_ulp_init(struct cnic_dev *dev)
+{
+	int i;
+	struct cnic_local *cp = dev->cnic_priv;
+
+	rcu_read_lock();
+	for (i = 0; i < MAX_CNIC_ULP_TYPE_EXT; i++) {
+		struct cnic_ulp_ops *ulp_ops;
+
+		ulp_ops = rcu_dereference(cnic_ulp_tbl[i]);
+		if (!ulp_ops || !try_module_get(ulp_ops->owner))
+			continue;
+
+		if (!test_and_set_bit(ULP_F_INIT, &cp->ulp_flags[i]))
+			ulp_ops->cnic_init(dev);
+
+		module_put(ulp_ops->owner);
+	}
+	rcu_read_unlock();
+}
+
+static void cnic_ulp_exit(struct cnic_dev *dev)
+{
+	int i;
+	struct cnic_local *cp = dev->cnic_priv;
+
+	rcu_read_lock();
+	for (i = 0; i < MAX_CNIC_ULP_TYPE_EXT; i++) {
+		struct cnic_ulp_ops *ulp_ops;
+
+		ulp_ops = rcu_dereference(cnic_ulp_tbl[i]);
+		if (!ulp_ops || !try_module_get(ulp_ops->owner))
+			continue;
+
+		if (test_and_clear_bit(ULP_F_INIT, &cp->ulp_flags[i]))
+			ulp_ops->cnic_exit(dev);
+
+		module_put(ulp_ops->owner);
+	}
+	rcu_read_unlock();
+}
+
+static int cnic_queue_work(struct cnic_local *cp, u32 work_type, void *data)
+{
+	struct cnic_work_node *node;
+	int bytes = sizeof(u32 *);
+
+	spin_lock_bh(&cp->cm_lock);
+
+	node = &cp->cnic_work_ring[cp->cnic_wr_prod];
+	node->work_type = work_type;
+	if (work_type == WORK_TYPE_KCQE)
+		bytes = sizeof(struct kcqe);
+	if (work_type == WORK_TYPE_REDIRECT)
+		bytes = sizeof(struct cnic_redirect_entry);
+	memcpy(&node->work_data, data, bytes);
+	cp->cnic_wr_prod++;
+	cp->cnic_wr_prod &= WORK_RING_SIZE_MASK;
+
+	spin_unlock_bh(&cp->cm_lock);
+	return 0;
+}
+
+static int cnic_cm_offload_pg(struct cnic_sock *csk)
+{
+	struct cnic_dev *dev = csk->dev;
+	struct l4_kwq_offload_pg *l4kwqe;
+	struct kwqe *wqes[1];
+	struct neighbour *neigh = csk->dst->neighbour;
+	struct net_device *netdev = neigh->dev;
+
+	l4kwqe = (struct l4_kwq_offload_pg *) &csk->kwqe1;
+	memset(l4kwqe, 0, sizeof(*l4kwqe));
+	wqes[0] = (struct kwqe *) l4kwqe;
+
+	l4kwqe->op_code = L4_KWQE_OPCODE_VALUE_OFFLOAD_PG;
+	l4kwqe->flags =
+		L4_LAYER_CODE << L4_KWQ_OFFLOAD_PG_LAYER_CODE_SHIFT;
+	l4kwqe->l2hdr_nbytes = ETH_HLEN;
+	l4kwqe->da0 = neigh->ha[0];
+	l4kwqe->da1 = neigh->ha[1];
+	l4kwqe->da2 = neigh->ha[2];
+	l4kwqe->da3 = neigh->ha[3];
+	l4kwqe->da4 = neigh->ha[4];
+	l4kwqe->da5 = neigh->ha[5];
+
+	l4kwqe->sa0 = netdev->dev_addr[0];
+	l4kwqe->sa1 = netdev->dev_addr[1];
+	l4kwqe->sa2 = netdev->dev_addr[2];
+	l4kwqe->sa3 = netdev->dev_addr[3];
+	l4kwqe->sa4 = netdev->dev_addr[4];
+	l4kwqe->sa5 = netdev->dev_addr[5];
+
+	l4kwqe->etype = ETH_P_IP;
+	l4kwqe->ipid_count = DEF_IPID_COUNT;
+	l4kwqe->host_opaque = csk->l5_cid;
+
+	if (csk->vlan_id) {
+		l4kwqe->pg_flags |= L4_KWQ_OFFLOAD_PG_VLAN_TAGGING;
+		l4kwqe->vlan_tag = csk->vlan_id;
+		l4kwqe->l2hdr_nbytes += 4;
+	}
+
+	return (dev->submit_kwqes(dev, wqes, 1));
+}
+
+static int cnic_cm_update_pg(struct cnic_sock *csk)
+{
+	struct cnic_dev *dev = csk->dev;
+	struct l4_kwq_update_pg *l4kwqe;
+	struct kwqe *wqes[1];
+	struct neighbour *neigh = csk->dst->neighbour;
+
+	l4kwqe = (struct l4_kwq_update_pg *) &csk->kwqe1;
+	memset(l4kwqe, 0, sizeof(*l4kwqe));
+	wqes[0] = (struct kwqe *) l4kwqe;
+
+	l4kwqe->opcode = L4_KWQE_OPCODE_VALUE_UPDATE_PG;
+	l4kwqe->flags =
+		L4_LAYER_CODE << L4_KWQ_UPDATE_PG_LAYER_CODE_SHIFT;
+	l4kwqe->pg_cid = csk->pg_cid;
+	l4kwqe->da0 = neigh->ha[0];
+	l4kwqe->da1 = neigh->ha[1];
+	l4kwqe->da2 = neigh->ha[2];
+	l4kwqe->da3 = neigh->ha[3];
+	l4kwqe->da4 = neigh->ha[4];
+	l4kwqe->da5 = neigh->ha[5];
+
+	l4kwqe->pg_host_opaque = 0;
+	l4kwqe->pg_valids = L4_KWQ_UPDATE_PG_VALIDS_DA;
+
+	return (dev->submit_kwqes(dev, wqes, 1));
+}
+
+static int cnic_cm_upload_pg(struct cnic_sock *csk)
+{
+	struct cnic_dev *dev = csk->dev;
+	struct l4_kwq_upload *l4kwqe;
+	struct kwqe *wqes[1];
+
+	l4kwqe = (struct l4_kwq_upload *) &csk->kwqe1;
+	memset(l4kwqe, 0, sizeof(*l4kwqe));
+	wqes[0] = (struct kwqe *) l4kwqe;
+
+	l4kwqe->opcode = L4_KWQE_OPCODE_VALUE_UPLOAD_PG;
+	l4kwqe->flags =
+		L4_LAYER_CODE << L4_KWQ_UPLOAD_LAYER_CODE_SHIFT;
+	l4kwqe->cid = csk->pg_cid;
+
+	return (dev->submit_kwqes(dev, wqes, 1));
+}
+
+static void cnic_redirect(struct cnic_local *cp, struct dst_entry *new,
+			  struct dst_entry *old)
+{
+	int i, found = 0;
+
+	spin_lock_bh(&cp->cm_lock);
+	for (i = 0; i < MAX_CM_SK_TBL_SZ; i++) {
+		struct cnic_sock *csk;
+
+		csk = &cp->csk_tbl[i];
+		if (test_bit(SK_F_INUSE, &csk->flags) && csk->dst == old)
+			found = 1;
+	}
+	spin_unlock_bh(&cp->cm_lock);
+
+	if (found) {
+		struct cnic_redirect_entry cnic_redir;
+
+		dst_hold(new);
+		cnic_redir.old_dst = old;
+		cnic_redir.new_dst = new;
+		cnic_queue_work(cp, WORK_TYPE_REDIRECT, &cnic_redir);
+		schedule_work(&cp->cnic_task);
+	}
+}
+
+static void cnic_update_neigh(struct cnic_local *cp, struct neighbour *neigh)
+{
+	int i, found = 0;
+
+	spin_lock_bh(&cp->cm_lock);
+	for (i = 0; i < MAX_CM_SK_TBL_SZ; i++) {
+		struct cnic_sock *csk;
+
+		csk = &cp->csk_tbl[i];
+		if (test_bit(SK_F_INUSE, &csk->flags) && csk->dst) {
+			if (csk->dst->neighbour == neigh)
+				found = 1;
+		}
+	}
+	spin_unlock_bh(&cp->cm_lock);
+
+	if (!found)
+		return;
+
+	neigh_hold(neigh);
+
+	cnic_queue_work(cp, WORK_TYPE_NEIGH_UPDATE, &neigh);
+	schedule_work(&cp->cnic_task);
+}
+
+static int cnic_net_callback(struct notifier_block *this, unsigned long event,
+	void *ptr)
+{
+	struct cnic_local *cp = container_of(this, struct cnic_local, cm_nb);
+
+	if (event == NETEVENT_NEIGH_UPDATE) {
+		struct neighbour *neigh = ptr;
+
+		cnic_update_neigh(cp, neigh);
+
+	} else if (event == NETEVENT_REDIRECT) {
+		struct netevent_redirect *netevent = ptr;
+		struct dst_entry *old_dst = netevent->old;
+		struct dst_entry *new_dst = netevent->new;
+
+		cnic_redirect(cp, new_dst, old_dst);
+	}
+	return 0;
+}
+
+static int cnic_ok_to_connect(struct cnic_sock *csk)
+{
+	if (test_bit(SK_F_INUSE, &csk->flags) &&
+	    !test_bit(SK_F_OFFLD_PENDING, &csk->flags) &&
+	    !test_bit(SK_F_OFFLD_COMPLETE, &csk->flags) &&
+	    test_bit(SK_F_PG_OFFLD_COMPLETE, &csk->flags))
+		return 1;
+	return 0;
+}
+
+static int cnic_cm_conn_req(struct cnic_sock *csk)
+{
+	struct cnic_dev *dev = csk->dev;
+	struct l4_kwq_connect_req1 *l4kwqe1;
+	struct l4_kwq_connect_req3 *l4kwqe3;
+	struct kwqe *wqes[2];
+	u8 tcp_flags = 0;
+
+	l4kwqe1 = (struct l4_kwq_connect_req1 *) &csk->kwqe2;
+	l4kwqe3 = (struct l4_kwq_connect_req3 *) &csk->kwqe3;
+	memset(l4kwqe1, 0, sizeof(*l4kwqe1));
+	memset(l4kwqe3, 0, sizeof(*l4kwqe3));
+	wqes[0] = (struct kwqe *) l4kwqe1;
+	wqes[1] = (struct kwqe *) l4kwqe3;
+
+	l4kwqe1->op_code = L4_KWQE_OPCODE_VALUE_CONNECT1;
+	l4kwqe1->flags =
+		(L4_LAYER_CODE << L4_KWQ_CONNECT_REQ1_LAYER_CODE_SHIFT) |
+		 L4_KWQ_CONNECT_REQ3_LINKED_WITH_NEXT;
+	l4kwqe1->cid = csk->cid;
+	l4kwqe1->pg_cid = csk->pg_cid;
+	l4kwqe1->src_ip = be32_to_cpu(csk->src_ip);
+	l4kwqe1->dst_ip = be32_to_cpu(csk->dst_ip);
+	l4kwqe1->src_port = be16_to_cpu(csk->src_port);
+	l4kwqe1->dst_port = be16_to_cpu(csk->dst_port);
+	if (test_bit(SK_TCP_NO_DELAY_ACK, &csk->tcp_flags))
+		tcp_flags |= L4_KWQ_CONNECT_REQ1_NO_DELAY_ACK;
+	if (test_bit(SK_TCP_KEEP_ALIVE, &csk->tcp_flags))
+		tcp_flags |= L4_KWQ_CONNECT_REQ1_KEEP_ALIVE;
+	if (test_bit(SK_TCP_NAGLE, &csk->tcp_flags))
+		tcp_flags |= L4_KWQ_CONNECT_REQ1_NAGLE_ENABLE;
+	if (test_bit(SK_TCP_TIMESTAMP, &csk->tcp_flags))
+		tcp_flags |= L4_KWQ_CONNECT_REQ1_TIME_STAMP;
+	if (test_bit(SK_TCP_SACK, &csk->tcp_flags))
+		tcp_flags |= L4_KWQ_CONNECT_REQ1_SACK;
+	if (test_bit(SK_TCP_SEG_SCALING, &csk->tcp_flags))
+		tcp_flags |= L4_KWQ_CONNECT_REQ1_SEG_SCALING;
+	
+	l4kwqe1->tcp_flags = tcp_flags;
+
+	l4kwqe3->op_code = L4_KWQE_OPCODE_VALUE_CONNECT3;
+	l4kwqe3->flags =
+		L4_LAYER_CODE << L4_KWQ_CONNECT_REQ3_LAYER_CODE_SHIFT;
+	l4kwqe3->ka_timeout = csk->ka_timeout;
+	l4kwqe3->ka_interval = csk->ka_interval;
+	l4kwqe3->ka_max_probe_count = csk->ka_max_probe_count;
+	l4kwqe3->tos = csk->tos;
+	l4kwqe3->ttl = csk->ttl;
+	l4kwqe3->snd_seq_scale = csk->snd_seq_scale;
+	l4kwqe3->pmtu = dst_mtu(csk->dst);
+	l4kwqe3->mss = l4kwqe3->pmtu - 40;
+	l4kwqe3->rcv_buf = csk->rcv_buf;
+	l4kwqe3->snd_buf = csk->snd_buf;
+	l4kwqe3->seed = csk->seed;
+
+	return (dev->submit_kwqes(dev, wqes, 2));
+}
+
+static int cnic_cm_close_req(struct cnic_sock *csk)
+{
+	struct cnic_dev *dev = csk->dev;
+	struct l4_kwq_close_req *l4kwqe;
+	struct kwqe *wqes[1];
+
+	l4kwqe = (struct l4_kwq_close_req *) &csk->kwqe2;
+	memset(l4kwqe, 0, sizeof(*l4kwqe));
+	wqes[0] = (struct kwqe *) l4kwqe;
+
+	l4kwqe->op_code = L4_KWQE_OPCODE_VALUE_CLOSE;
+	l4kwqe->flags = L4_LAYER_CODE << L4_KWQ_CLOSE_REQ_LAYER_CODE_SHIFT;
+	l4kwqe->cid = csk->cid;
+
+	return (dev->submit_kwqes(dev, wqes, 1));
+}
+
+static int cnic_cm_abort_req(struct cnic_sock *csk)
+{
+	struct cnic_dev *dev = csk->dev;
+	struct l4_kwq_reset_req *l4kwqe;
+	struct kwqe *wqes[1];
+
+	l4kwqe = (struct l4_kwq_reset_req *) &csk->kwqe2;
+	memset(l4kwqe, 0, sizeof(*l4kwqe));
+	wqes[0] = (struct kwqe *) l4kwqe;
+
+	l4kwqe->op_code = L4_KWQE_OPCODE_VALUE_RESET;
+	l4kwqe->flags = L4_LAYER_CODE << L4_KWQ_RESET_REQ_LAYER_CODE_SHIFT;
+	l4kwqe->cid = csk->cid;
+
+	return (dev->submit_kwqes(dev, wqes, 1));
+}
+
+static int cnic_cm_create(struct cnic_dev *dev, int ulp_type, u32 cid,
+			  u32 l5_cid, struct cnic_sock **csk, void *context)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_sock *csk1;
+
+	if (l5_cid >= MAX_CM_SK_TBL_SZ)
+		return -EINVAL;
+		
+	csk1 = &cp->csk_tbl[l5_cid];
+	if (test_and_set_bit(SK_F_INUSE, &csk1->flags))
+		return -EINVAL;
+
+	csk1->dev = dev;
+	csk1->cid = cid;
+	csk1->l5_cid = l5_cid;
+	csk1->ulp_type = ulp_type;
+	csk1->context = context;
+
+	csk1->ka_timeout = DEF_KA_TIMEOUT;
+	csk1->ka_interval = DEF_KA_INTERVAL;
+	csk1->ka_max_probe_count = DEF_KA_MAX_PROBE_COUNT;
+	csk1->tos = DEF_TOS;
+	csk1->ttl = DEF_TTL;
+	csk1->snd_seq_scale = DEF_SND_SEQ_SCALE;
+	csk1->rcv_buf = DEF_RCV_BUF;
+	csk1->snd_buf = DEF_SND_BUF;
+	csk1->seed = DEF_SEED;
+
+	*csk = csk1;
+
+	return 0;
+}
+
+static int cnic_cm_destroy(struct cnic_sock *csk)
+{
+	struct cnic_local *cp = csk->dev->cnic_priv;
+
+	if (!test_bit(SK_F_INUSE, &csk->flags))
+		return -EINVAL;
+
+	spin_lock_bh(&cp->cm_lock);
+	if (csk->dst) {
+		if (csk->dst->neighbour)
+			neigh_release(csk->dst->neighbour);
+		dst_release(csk->dst);
+		csk->dst = NULL;
+	}
+	csk->flags = 0;
+	spin_unlock_bh(&cp->cm_lock);
+	return 0;
+}
+
+static inline struct net_device *get_real_netdev(struct net_device *netdev)
+{
+	return netdev->priv_flags & IFF_802_1Q_VLAN ?
+		VLAN_DEV_INFO(netdev)->real_dev : netdev;
+}
+
+static struct cnic_dev *cnic_cm_select_dev(struct sockaddr_in *dst_addr,
+					   int ulp_type)
+{
+	u32 dst_ip = dst_addr->sin_addr.s_addr;
+	struct flowi fl;
+	struct rtable *rt;
+	struct net_device *netdev;
+	struct cnic_dev *dev;
+	int err, found;
+
+	memset(&fl, 0, sizeof(fl));
+	fl.nl_u.ip4_u.daddr = dst_ip;
+
+	err = ip_route_output_key(&rt, &fl);
+	if (err)
+		return NULL;
+
+	netdev = get_real_netdev(rt->idev->dev);
+
+	found = 0;
+	read_lock(&cnic_dev_lock);
+	list_for_each_entry(dev, &cnic_dev_list, list) {
+		if (netdev == dev->netdev) {
+			found = 1;
+			cnic_hold(dev);
+			break;
+		}
+	}
+	read_unlock(&cnic_dev_lock);
+
+	ip_rt_put(rt);
+
+	if (found) {
+		struct cnic_local *cp = dev->cnic_priv;
+
+		if (rcu_dereference(cp->ulp_ops[ulp_type])) {
+			cnic_put(dev);
+			return dev;
+		}
+		cnic_put(dev);
+	}
+
+	return NULL;
+}
+
+static int cnic_cm_connect(struct cnic_sock *csk, struct cnic_sockaddr *saddr)
+{
+	struct cnic_dev *dev = csk->dev;
+	struct net_device *realdev;
+	u32 dst_ip = saddr->remote_addr.sin_addr.s_addr;
+	u32 src_ip = saddr->local_addr.sin_addr.s_addr;
+	struct flowi fl;
+	struct rtable *rt;
+	struct neighbour *neigh;
+	int err = 0, retry = 0;
+
+	if (!test_bit(SK_F_INUSE, &csk->flags))
+		return -EINVAL;
+
+	memset(&fl, 0, sizeof(fl));
+	fl.nl_u.ip4_u.daddr = dst_ip;
+	fl.nl_u.ip4_u.saddr = src_ip;
+	err = ip_route_output_key(&rt, &fl);
+	if (err)
+		return err;
+
+	realdev = get_real_netdev(rt->idev->dev);
+	if (realdev != dev->netdev)
+		goto err;
+
+	if (src_ip == 0)
+		src_ip = inet_select_addr(rt->idev->dev, dst_ip, RT_SCOPE_LINK);
+
+	csk->dst = &rt->u.dst;
+	csk->src_ip = src_ip;
+	csk->dst_ip = dst_ip;
+	csk->src_port = saddr->local_addr.sin_port;
+	csk->dst_port = saddr->remote_addr.sin_port;
+
+	neigh = csk->dst->neighbour;
+	if (!csk->dst->neighbour)
+		goto err;
+
+	neigh_hold(neigh);
+
+	if (realdev != rt->idev->dev)
+		csk->vlan_id = VLAN_DEV_INFO(rt->idev->dev)->vlan_id;
+	else
+		csk->vlan_id = 0;
+
+
+	if (neigh->nud_state & NUD_VALID)
+		err = cnic_cm_offload_pg(csk);
+
+	while (!(neigh->nud_state & NUD_VALID) && (retry < 3)) {
+		arp_send(ARPOP_REQUEST, ETH_P_ARP, rt->rt_gateway,
+			 rt->idev->dev, rt->rt_src, NULL,
+			 rt->idev->dev->dev_addr, NULL);
+		msleep(1000);
+		retry++;
+	}
+	if (!(neigh->nud_state & NUD_VALID))
+		err = -ENODATA;
+
+	if (!err)
+		return 0;
+
+	neigh_release(neigh);
+
+err:
+	csk->dst = NULL;
+
+	ip_rt_put(rt);
+	return err;
+}
+
+static int cnic_cm_abort(struct cnic_sock *csk)
+{
+	if (!test_bit(SK_F_INUSE, &csk->flags))
+		return -EINVAL;
+
+	return (cnic_cm_abort_req(csk));
+}
+
+static int cnic_cm_close(struct cnic_sock *csk)
+{
+	if (!test_bit(SK_F_INUSE, &csk->flags))
+		return -EINVAL;
+
+	return (cnic_cm_close_req(csk));
+}
+
+static void cnic_cm_process_neigh(struct cnic_dev *dev, struct neighbour *neigh)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	int i;
+
+	for (i = 0; i < MAX_CM_SK_TBL_SZ; i++) {
+		struct cnic_sock *csk;
+
+		csk = &cp->csk_tbl[i];
+		spin_lock_bh(&cp->cm_lock);
+		if (test_bit(SK_F_INUSE, &csk->flags) && csk->dst &&
+		    csk->dst->neighbour == neigh) {
+			if (test_bit(SK_F_PG_OFFLD_COMPLETE, &csk->flags))
+				cnic_cm_update_pg(csk);
+			else
+				cnic_cm_offload_pg(csk);
+		}
+		spin_unlock_bh(&cp->cm_lock);
+	}
+	neigh_release(neigh);
+}
+
+static void cnic_cm_process_redirect(struct cnic_dev *dev,
+				     struct cnic_redirect_entry *redir)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	int i;
+
+	for (i = 0; i < MAX_CM_SK_TBL_SZ; i++) {
+		struct cnic_sock *csk;
+
+		spin_lock_bh(&cp->cm_lock);
+		csk = &cp->csk_tbl[i];
+		if (test_bit(SK_F_INUSE, &csk->flags) &&
+		    csk->dst == redir->old_dst) {
+			csk->dst = redir->new_dst;
+			dst_hold(csk->dst);
+			neigh_hold(csk->dst->neighbour);
+			if (redir->old_dst->neighbour);
+				neigh_release(redir->old_dst->neighbour);
+			dst_release(redir->old_dst);
+			if (test_bit(SK_F_PG_OFFLD_COMPLETE, &csk->flags))
+				cnic_cm_update_pg(csk);
+			else
+				cnic_cm_offload_pg(csk);
+		}
+		spin_unlock_bh(&cp->cm_lock);
+	}
+
+	dst_release(redir->new_dst);
+}
+
+static void cnic_cm_upcall(struct cnic_local *cp, struct cnic_sock *csk,
+			   u8 opcode)
+{
+	struct cnic_ulp_ops *ulp_ops;
+	int ulp_type = csk->ulp_type;
+
+	rcu_read_lock();
+	ulp_ops = rcu_dereference(cp->ulp_ops[ulp_type]);
+	if (ulp_ops) {
+		if (opcode == L4_KCQE_OPCODE_VALUE_CONNECT_COMPLETE)
+			ulp_ops->cm_connect_complete(csk);
+		else if (opcode == L4_KCQE_OPCODE_VALUE_CONNECT_CLOSE)
+			ulp_ops->cm_close_complete(csk);
+		else if (opcode == L4_KCQE_OPCODE_VALUE_RESET_RECEIVED)
+			ulp_ops->cm_remote_abort(csk);
+		else if (opcode == L4_KCQE_OPCODE_VALUE_RESET_COMP)
+			ulp_ops->cm_abort_complete(csk);
+		else if (opcode == L4_KCQE_OPCODE_VALUE_CLOSE_RECEIVED)
+			ulp_ops->cm_remote_close(csk);
+	}
+	rcu_read_unlock();
+}
+
+static void cnic_cm_process_kcqe(struct cnic_dev *dev, struct kcqe *kcqe)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct l4_kcq *l4kcqe = (struct l4_kcq *) kcqe;
+	u8 opcode = l4kcqe->op_code;
+
+	if (opcode == L4_KCQE_OPCODE_VALUE_OFFLOAD_PG) {
+		u32 l5_cid = l4kcqe->pg_host_opaque;
+		struct cnic_sock *csk = &cp->csk_tbl[l5_cid];
+
+		if (!test_bit(SK_F_INUSE, &csk->flags))
+			return;
+
+		csk->pg_cid = l4kcqe->pg_cid;
+		set_bit(SK_F_PG_OFFLD_COMPLETE, &csk->flags);
+		if (cnic_ok_to_connect(csk)) {
+			set_bit(SK_F_OFFLD_PENDING, &csk->flags);
+			cnic_cm_conn_req(csk);
+		}
+
+	} else if (opcode == L4_KCQE_OPCODE_VALUE_CONNECT_RESP) {
+
+	} else if (opcode == L4_KCQE_OPCODE_VALUE_CONNECT_COMPLETE) {
+		u32 l5_cid = l4kcqe->conn_id;
+		struct cnic_sock *csk = &cp->csk_tbl[l5_cid];
+
+		if (test_bit(SK_F_INUSE, &csk->flags)) {
+			if (l4kcqe->status == 0)
+				set_bit(SK_F_OFFLD_COMPLETE, &csk->flags);
+			clear_bit(SK_F_OFFLD_PENDING, &csk->flags);
+			cnic_cm_upcall(cp, csk, opcode);
+		}
+
+	} else if (opcode == L4_KCQE_OPCODE_VALUE_CONNECT_CLOSE ||
+		   opcode == L4_KCQE_OPCODE_VALUE_RESET_RECEIVED ||
+		   opcode == L4_KCQE_OPCODE_VALUE_RESET_COMP) {
+		u32 l5_cid = l4kcqe->conn_id;
+		struct cnic_sock *csk = &cp->csk_tbl[l5_cid];
+
+		if (test_bit(SK_F_INUSE, &csk->flags)) {
+			clear_bit(SK_F_OFFLD_COMPLETE, &csk->flags);
+			clear_bit(SK_F_OFFLD_PENDING, &csk->flags);
+			cnic_cm_upload_pg(csk);
+			clear_bit(SK_F_PG_OFFLD_COMPLETE, &csk->flags);
+			cnic_cm_upcall(cp, csk, opcode);
+		}
+	} else if (opcode == L4_KCQE_OPCODE_VALUE_CLOSE_RECEIVED) {
+		u32 l5_cid = l4kcqe->conn_id;
+		struct cnic_sock *csk = &cp->csk_tbl[l5_cid];
+
+		if (test_bit(SK_F_INUSE, &csk->flags))
+			cnic_cm_upcall(cp, csk, opcode);
+	}
+}
+
+static void cnic_cm_indicate_kcqe(void *data, struct kcqe *kcqe[], u32 num_cqe)
+{
+	struct cnic_dev *dev = data;
+	int i;
+	struct cnic_local *cp = dev->cnic_priv;
+
+	for (i = 0; i < num_cqe; i++)
+		cnic_queue_work(cp, WORK_TYPE_KCQE, kcqe[i]);
+
+	schedule_work(&cp->cnic_task);
+}
+
+static void cnic_cm_indicate_event(void *data, unsigned long event)
+{
+}
+
+static void cnic_cm_dummy(void *data)
+{
+}
+
+static struct cnic_ulp_ops cm_ulp_ops = {
+	.cnic_start		= cnic_cm_dummy,
+	.cnic_stop		= cnic_cm_dummy,
+	.indicate_kcqes		= cnic_cm_indicate_kcqe,
+	.indicate_netevent	= cnic_cm_indicate_event,
+	.indicate_inetevent	= cnic_cm_indicate_event,
+};
+
+static void cnic_task(struct work_struct *work)
+{
+	struct cnic_local *cp =
+		container_of(work, struct cnic_local, cnic_task);
+	struct cnic_dev *dev = cp->dev;
+	u32 cons = cp->cnic_wr_cons;
+	u32 prod = cp->cnic_wr_prod;
+
+	while (cons != prod) {
+		struct cnic_work_node *node;
+
+		node = &cp->cnic_work_ring[cons];
+		if (node->work_type == WORK_TYPE_KCQE)
+			cnic_cm_process_kcqe(dev, &node->work_data.kcqe);
+		else if (node->work_type == WORK_TYPE_NEIGH_UPDATE)
+			cnic_cm_process_neigh(dev, node->work_data.neigh);
+		else if (node->work_type == WORK_TYPE_REDIRECT)
+			cnic_cm_process_redirect(dev,
+				&node->work_data.cnic_redir);
+		cons++;
+		cons &= WORK_RING_SIZE_MASK;
+	}
+	cp->cnic_wr_cons = cons;
+}
+
+static void cnic_free_dev(struct cnic_dev *dev)
+{
+	printk(KERN_INFO PFX "Removed CNIC device: %s\n", dev->netdev->name);
+	cnic_free_resc(dev);
+	cnic_unregister_sysfs(dev);
+	pci_dev_put(dev->pcidev);
+	dev_put(dev->netdev);
+	kfree(dev);
+}
+
+static void cnic_cm_free_mem(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+
+	kfree(cp->csk_tbl);
+	cp->csk_tbl = NULL;
+}
+
+static int cnic_cm_alloc_mem(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+
+	cp->csk_tbl = kmalloc(sizeof(struct cnic_sock) * MAX_CM_SK_TBL_SZ,
+			      GFP_KERNEL);
+	if (!cp->csk_tbl)
+		return -ENOMEM;
+	memset(cp->csk_tbl, 0, sizeof(struct cnic_sock) * MAX_CM_SK_TBL_SZ);
+	return 0;
+}
+
+static int cnic_cm_open(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	u32 seed;
+	int err;
+
+	get_random_bytes(&seed, 4);
+	bnx2_ctx_wr(dev->bp, 45, 0, seed);
+
+	err = cnic_cm_alloc_mem(dev);
+	if (err) {
+		cnic_cm_free_mem(dev);
+		return err;
+	}
+
+	spin_lock_init(&cp->cm_lock);
+
+	INIT_WORK(&cp->cnic_task, cnic_task);
+
+	cp->cm_nb.notifier_call = cnic_net_callback;
+	register_netevent_notifier(&cp->cm_nb);
+
+	dev->cm_create = cnic_cm_create;
+	dev->cm_destroy = cnic_cm_destroy;
+	dev->cm_connect = cnic_cm_connect;
+	dev->cm_abort = cnic_cm_abort;
+	dev->cm_close = cnic_cm_close;
+	dev->cm_select_dev = cnic_cm_select_dev;
+
+	cp->ulp_handle[CNIC_ULP_L4] = dev;
+	rcu_assign_pointer(cp->ulp_ops[CNIC_ULP_L4], &cm_ulp_ops);
+	return 0;
+}
+
+static void cnic_cm_cleanup(struct cnic_sock *csk)
+{
+	clear_bit(SK_F_INUSE, &csk->flags);
+	if (csk->dst) {
+		if (csk->dst->neighbour)
+			neigh_release(csk->dst->neighbour);
+		dst_release(csk->dst);
+		csk->dst = NULL;
+	}
+}
+
+static int cnic_cm_shutdown(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	int i;
+
+	unregister_netevent_notifier(&cp->cm_nb);
+
+	cancel_work_sync(&cp->cnic_task);
+
+	if (!cp->csk_tbl)
+		return 0;
+
+	for (i = 0; i < MAX_CM_SK_TBL_SZ; i++) {
+		struct cnic_sock *csk = &cp->csk_tbl[i];
+
+		cnic_cm_cleanup(csk);
+	}
+	cnic_cm_free_mem(dev);
+
+	return 0;
+}
+
+static void cnic_init_context(struct cnic_dev *dev, u32 cid)
+{
+	u32 cid_addr;
+	int i;
+
+	cid_addr = GET_CID_ADDR(cid);
+
+	for (i = 0; i < CTX_SIZE; i += 4)
+		bnx2_ctx_wr(dev->bp, cid_addr, i, 0);
+}
+
+static int cnic_start_hw(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	u32 val;
+	int err;
+
+	if (test_bit(CNIC_F_CNIC_UP, &dev->flags))
+		return -EALREADY;
+
+	val = REG_RD(dev, BNX2_MQ_CONFIG);
+	val &= ~BNX2_MQ_CONFIG_KNL_BYP_BLK_SIZE;
+	if (BCM_PAGE_BITS > 12)
+		val |= (12 - 8)  << 4;
+	else
+		val |= (BCM_PAGE_BITS - 8)  << 4;
+
+	REG_WR(dev, BNX2_MQ_CONFIG, val);
+
+	REG_WR(dev, BNX2_HC_COMP_PROD_TRIP, (2 << 16) | 8);
+	REG_WR(dev, BNX2_HC_COM_TICKS, (64 << 16) | 220);
+	REG_WR(dev, BNX2_HC_CMD_TICKS, (64 << 16) | 220);
+
+	cnic_init_context(dev, KWQ_CID);
+	cnic_init_context(dev, KCQ_CID);
+
+	cp->kwq_cid_addr = GET_CID_ADDR(KWQ_CID);
+	cp->kwq_io_addr = MB_GET_CID_ADDR(KWQ_CID) + L5_KRNLQ_HOST_QIDX;
+
+	cnic_setup_page_tbl(cp->kwq_pgtbl, KWQ_PAGE_CNT, cp->kwq_mapping);
+	
+	cp->kwq_prod_idx = 0;
+	cp->kwq_con_idx = 0;
+	
+	/* Initialize the kernel work queue context. */
+	val = KRNLQ_TYPE_TYPE_KRNLQ | KRNLQ_SIZE_TYPE_SIZE |
+	      (BCM_PAGE_BITS - 8) | KRNLQ_FLAGS_QE_SELF_SEQ;
+	bnx2_ctx_wr(dev->bp, cp->kwq_cid_addr, L5_KRNLQ_TYPE, val);
+	
+	val = (PAGE_SIZE / sizeof(struct kwqe) - 1) << 16;
+	bnx2_ctx_wr(dev->bp, cp->kwq_cid_addr, L5_KRNLQ_QE_SELF_SEQ_MAX, val);
+	
+	val = ((PAGE_SIZE / sizeof(struct kwqe)) << 16) | KWQ_PAGE_CNT;
+	bnx2_ctx_wr(dev->bp, cp->kwq_cid_addr, L5_KRNLQ_PGTBL_NPAGES, val);
+	
+	val = (u32) ((u64) cp->kwq_pgtbl_mapping >> 32);
+	bnx2_ctx_wr(dev->bp, cp->kwq_cid_addr, L5_KRNLQ_PGTBL_HADDR_HI, val);
+	
+	val = (u32) cp->kwq_pgtbl_mapping;
+	bnx2_ctx_wr(dev->bp, cp->kwq_cid_addr, L5_KRNLQ_PGTBL_HADDR_LO, val);
+
+	cp->kcq_cid_addr = GET_CID_ADDR(KCQ_CID);
+	cp->kcq_io_addr = MB_GET_CID_ADDR(KCQ_CID) + L5_KRNLQ_HOST_QIDX;
+	
+	cnic_setup_page_tbl(cp->kcq_pgtbl, KCQ_PAGE_CNT, cp->kcq_mapping);
+	
+	cp->kcq_prod_idx = 0;
+	
+	/* Initialize the kernel complete queue context. */
+	val = KRNLQ_TYPE_TYPE_KRNLQ | KRNLQ_SIZE_TYPE_SIZE |
+	      (BCM_PAGE_BITS - 8) | KRNLQ_FLAGS_QE_SELF_SEQ;
+	bnx2_ctx_wr(dev->bp, cp->kcq_cid_addr, L5_KRNLQ_TYPE, val);
+	
+	val = (BCM_PAGE_SIZE / sizeof(struct kcqe) - 1) << 16;
+	bnx2_ctx_wr(dev->bp, cp->kcq_cid_addr, L5_KRNLQ_QE_SELF_SEQ_MAX, val);
+	
+	val = ((BCM_PAGE_SIZE / sizeof(struct kcqe)) << 16) | KCQ_PAGE_CNT;
+	bnx2_ctx_wr(dev->bp, cp->kcq_cid_addr, L5_KRNLQ_PGTBL_NPAGES, val);
+	
+	val = (u32) ((u64) cp->kcq_pgtbl_mapping >> 32);
+	bnx2_ctx_wr(dev->bp, cp->kcq_cid_addr, L5_KRNLQ_PGTBL_HADDR_HI, val);
+	
+	val = (u32) cp->kcq_pgtbl_mapping;
+	bnx2_ctx_wr(dev->bp, cp->kcq_cid_addr, L5_KRNLQ_PGTBL_HADDR_LO, val);
+
+	/* Enable Commnad Scheduler notification when we write to the
+	 * host producer index of the kernel contexts. */
+	REG_WR(dev, BNX2_MQ_KNL_CMD_MASK1, 2);
+
+	/* Enable Command Scheduler notification when we write to either
+	 * the Send Queue or Receive Queue producer indexes of the kernel
+	 * bypass contexts. */
+	REG_WR(dev, BNX2_MQ_KNL_BYP_CMD_MASK1, 7);
+	REG_WR(dev, BNX2_MQ_KNL_BYP_WRITE_MASK1, 7);
+
+	/* Notify COM when the driver post an application buffer. */
+	REG_WR(dev, BNX2_MQ_KNL_RX_V2P_MASK2, 0x2000);
+
+	/* Set the CP and COM doorbells.  These two processors polls the
+	 * doorbell for a non zero value before running.  This must be done
+	 * after setting up the kernel queue contexts. */
+	bnx2_reg_wr_ind(dev->bp, BNX2_CP_SCRATCH + 0x20, 1);
+	bnx2_reg_wr_ind(dev->bp, BNX2_COM_SCRATCH + 0x20, 1);
+
+	err = bnx2_register_cnic(dev->netdev, &my_cnic_ops, dev);
+	if (err) {
+		printk(KERN_ERR PFX "%s: bnx2_register_cnic failed\n",
+		       dev->netdev->name);
+		return -EBUSY;
+	}
+
+	set_bit(CNIC_F_CNIC_UP, &dev->flags);
+	cnic_cm_open(dev);
+
+	return 0;
+}
+
+static void cnic_stop_hw(struct cnic_dev *dev)
+{
+	if (test_bit(CNIC_F_CNIC_UP, &dev->flags)) {
+		struct cnic_local *cp = dev->cnic_priv;
+
+		cnic_cm_shutdown(dev);
+		bnx2_unregister_cnic(dev->netdev);
+		rcu_assign_pointer(cp->ulp_ops[CNIC_ULP_L4], NULL);
+		clear_bit(CNIC_F_CNIC_UP, &dev->flags);
+		synchronize_rcu();
+
+		bnx2_reg_wr_ind(dev->bp, BNX2_CP_SCRATCH + 0x20, 0);
+		bnx2_reg_wr_ind(dev->bp, BNX2_COM_SCRATCH + 0x20, 0);
+
+		cnic_init_context(dev, KWQ_CID);
+		cnic_init_context(dev, KCQ_CID);
+	}
+}
+
+static struct cnic_dev *init_cnic(struct net_device *dev)
+{
+	struct cnic_dev *cdev;
+	struct cnic_local *bp;
+	struct bnx2 *bnx2_bp = netdev_priv(dev);
+	struct pci_dev *pdev = bnx2_bp->pdev;
+	int alloc_size;
+
+	if (!pdev)
+		return NULL;
+
+	pci_dev_get(pdev);
+	if (pdev->device == PCI_DEVICE_ID_NX2_5709 ||
+	    pdev->device == PCI_DEVICE_ID_NX2_5709S) {
+		pci_dev_put(pdev);
+		return NULL;
+	}
+
+	alloc_size = sizeof(struct cnic_dev) + sizeof(struct cnic_local);
+
+	cdev = kmalloc(alloc_size , GFP_KERNEL);
+	if (cdev == NULL) {
+		printk(KERN_ERR PFX "%s: allocate dev struct failure\n",
+		       dev->name);
+		pci_dev_put(pdev);
+		return cdev;
+	}
+	memset(cdev, 0, alloc_size);
+
+	cdev->netdev = dev;
+	cdev->bp = bnx2_bp;
+	cdev->pcidev = pdev;
+	cdev->regview = bnx2_bp->regview;
+	cdev->cnic_priv = (char *)cdev + sizeof(struct cnic_dev);
+	cdev->submit_kwqes = cnic_submit_kernel_wqes;
+	cdev->register_device = cnic_register_device;
+	cdev->unregister_device = cnic_unregister_device;
+
+	if (cnic_alloc_resc(cdev)) {
+		printk(KERN_ERR PFX "%s: allocate resource failure\n",
+		       dev->name);
+		kfree(cdev);
+		pci_dev_put(pdev);
+		return NULL;
+	}
+	bp = cdev->cnic_priv;
+	bp->dev = cdev;
+	spin_lock_init(&bp->cnic_ulp_lock);
+	dev_hold(cdev->netdev);
+	printk(KERN_INFO PFX "Added CNIC device: %s\n", dev->name);
+
+	return cdev;
+}
+
+static struct cnic_dev *is_cnic_dev(struct net_device *dev)
+{
+	struct ethtool_drvinfo drvinfo;
+	struct cnic_dev *cdev = NULL;
+
+	if (dev->ethtool_ops && dev->ethtool_ops->get_drvinfo) {
+		memset(&drvinfo, 0, sizeof(drvinfo));
+		dev->ethtool_ops->get_drvinfo(dev, &drvinfo);
+		
+		if (!strcmp(drvinfo.driver, "bnx2")) {
+			cdev = init_cnic(dev);
+			if (cdev) {
+				cnic_register_sysfs(cdev);
+				write_lock(&cnic_dev_lock);
+				list_add(&cdev->list, &cnic_dev_list);
+				write_unlock(&cnic_dev_lock);
+			}
+		}
+	}
+	return cdev;
+}
+
+/**
+ * IP event handler
+ */
+static int cnic_ip_event(struct notifier_block *this, unsigned long event,
+						 void *ptr)
+{
+	struct in_ifaddr *ifa = (struct in_ifaddr *) ptr;
+	struct net_device *netdev = (struct net_device *) ifa->ifa_dev->dev;
+	struct cnic_dev *dev;
+	int if_type;
+	u32 my_dev = 0;
+
+	read_lock(&cnic_dev_lock);
+	list_for_each_entry(dev, &cnic_dev_list, list) {
+		if (netdev == dev->netdev) {
+			my_dev = 1;
+			cnic_hold(dev);
+			break;
+		}
+	}
+	read_unlock(&cnic_dev_lock);
+
+	if (my_dev) {
+		struct cnic_local *cp = dev->cnic_priv;
+
+		rcu_read_lock();
+		for (if_type = 0; if_type < MAX_CNIC_ULP_TYPE; if_type++) {
+			struct cnic_ulp_ops *ulp_ops;
+
+			ulp_ops = rcu_dereference(cp->ulp_ops[if_type]);
+			if (ulp_ops) {
+				void *ctx = cp->ulp_handle[if_type];
+
+				ulp_ops->indicate_inetevent(ctx, event);
+			}
+		}
+		rcu_read_unlock();
+
+		cnic_put(dev);
+	}
+
+	return NOTIFY_DONE;
+}
+
+/**
+ * netdev event handler
+ */
+static int cnic_netdev_event(struct notifier_block *this, unsigned long event,
+							 void *ptr)
+{
+	struct net_device *netdev = ptr;
+	struct cnic_dev *dev;
+	int if_type;
+	u32 my_dev = 0;
+
+	read_lock(&cnic_dev_lock);
+	list_for_each_entry(dev, &cnic_dev_list, list) {
+		if (netdev == dev->netdev) {
+			my_dev = 1;
+			cnic_hold(dev);
+			break;
+		}
+	}
+	read_unlock(&cnic_dev_lock);
+
+	if (!my_dev && event == NETDEV_REGISTER) {
+		/* Check for the hot-plug device */
+		dev = is_cnic_dev(netdev);
+		if (dev) {
+			my_dev = 1;
+			cnic_hold(dev);
+		}
+	}
+	if (my_dev) {
+		struct cnic_local *cp = dev->cnic_priv;
+
+		if (event == NETDEV_REGISTER)
+			cnic_ulp_init(dev);
+		else if (event == NETDEV_UNREGISTER)
+			cnic_ulp_exit(dev);
+		else if (event == NETDEV_UP) {
+			mutex_lock(&cnic_lock);
+			set_bit(CNIC_F_IF_UP, &dev->flags);
+			if (dev->use_count) {
+				if (!cnic_start_hw(dev))
+					cnic_ulp_start(dev);
+			}
+			mutex_unlock(&cnic_lock);
+		}
+
+		rcu_read_lock();
+		for (if_type = 0; if_type < MAX_CNIC_ULP_TYPE; if_type++) {
+			struct cnic_ulp_ops *ulp_ops;
+			void *ctx;
+
+			ulp_ops = rcu_dereference(cp->ulp_ops[if_type]);
+			if (!ulp_ops)
+				continue;
+
+			ctx = cp->ulp_handle[if_type];
+
+			ulp_ops->indicate_netevent(ctx, event);
+		}
+		rcu_read_unlock();
+
+		if (event == NETDEV_GOING_DOWN) {
+			mutex_lock(&cnic_lock);
+			clear_bit(CNIC_F_IF_UP, &dev->flags);
+			cnic_ulp_stop(dev);
+			cnic_stop_hw(dev);
+			mutex_unlock(&cnic_lock);
+		} else if (event == NETDEV_UNREGISTER) {
+			int i = 0;
+
+			write_lock(&cnic_dev_lock);
+			list_del_init(&dev->list);
+			write_unlock(&cnic_dev_lock);
+			while ((atomic_read(&dev->ref_count) != 1) &&
+			       i < 10) {
+				msleep(100);
+				i++;
+			}
+			if (atomic_read(&dev->ref_count) != 1)
+				printk(KERN_ERR PFX "%s: Failed waiting"
+				       " for ref count to go zero\n",
+				       dev->netdev->name);
+
+			cnic_free_dev(dev);
+			goto done;
+		}
+		cnic_put(dev);
+	}
+done:
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block cnic_ip_notifier = {
+	cnic_ip_event,
+	0
+};
+
+static struct notifier_block cnic_netdev_notifier = {
+	cnic_netdev_event,
+	0
+};
+
+static void cnic_release(void)
+{
+	struct cnic_dev *dev;
+
+	while (!list_empty(&cnic_dev_list)) {
+		dev = list_entry(cnic_dev_list.next, struct cnic_dev, list);
+		if (test_bit(CNIC_F_CNIC_UP, &dev->flags))
+			cnic_stop_hw(dev);
+
+		list_del_init(&dev->list);
+		cnic_free_dev(dev);
+	}
+}
+
+static int __init cnic_init(void)
+{
+	int rc = 0;
+	struct net_device *dev;
+
+	printk(KERN_INFO "%s", version);
+
+	cnic_sysfs_setup();
+
+	read_lock(&dev_base_lock);
+	/* Find Teton devices */
+	for_each_netdev(dev)
+		is_cnic_dev(dev);
+
+	read_unlock(&dev_base_lock);
+
+	rc = register_inetaddr_notifier(&cnic_ip_notifier);
+	if (rc)
+		cnic_release();
+	rc = register_netdevice_notifier(&cnic_netdev_notifier);
+	if (rc) {
+		unregister_inetaddr_notifier(&cnic_ip_notifier);
+		cnic_release();
+	}
+	return rc;
+}
+
+static void __exit cnic_exit(void)
+{
+	unregister_inetaddr_notifier(&cnic_ip_notifier);
+	unregister_netdevice_notifier(&cnic_netdev_notifier);
+	cnic_release();
+	cnic_sysfs_cleanup();
+
+	return;
+}
+
+module_init(cnic_init);
+module_exit(cnic_exit);
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
new file mode 100644
index 0000000..6ba1f4e
--- /dev/null
+++ b/drivers/net/cnic.h
@@ -0,0 +1,163 @@
+/* cnic.h: Broadcom CNIC core network driver.
+ *
+ * Copyright (c) 2006 Broadcom Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Written by: John(Zongxi) Chen (zongxic@broadcom.com)
+ */
+
+
+#ifndef CNIC_H
+#define CNIC_H
+
+#if !defined(__LITTLE_ENDIAN) && !defined(__BIG_ENDIAN)
+	#error "Missing either LITTLE_ENDIAN or BIG_ENDIAN definition."
+#endif
+
+#define KWQ_PAGE_CNT	4
+#define KCQ_PAGE_CNT	16
+
+#define KWQ_CID 		24
+#define KCQ_CID 		25
+
+/*
+ *	krnlq_context definition
+ */
+#define L5_KRNLQ_FLAGS	0x00000000
+#define L5_KRNLQ_SIZE	0x00000000
+#define L5_KRNLQ_TYPE	0x00000000
+#define KRNLQ_FLAGS_PG_SZ					(0xf<<0)
+#define KRNLQ_FLAGS_PG_SZ_256					(0<<0)
+#define KRNLQ_FLAGS_PG_SZ_512					(1<<0)
+#define KRNLQ_FLAGS_PG_SZ_1K					(2<<0)
+#define KRNLQ_FLAGS_PG_SZ_2K					(3<<0)
+#define KRNLQ_FLAGS_PG_SZ_4K					(4<<0)
+#define KRNLQ_FLAGS_PG_SZ_8K					(5<<0)
+#define KRNLQ_FLAGS_PG_SZ_16K					(6<<0)
+#define KRNLQ_FLAGS_PG_SZ_32K					(7<<0)
+#define KRNLQ_FLAGS_PG_SZ_64K					(8<<0)
+#define KRNLQ_FLAGS_PG_SZ_128K					(9<<0)
+#define KRNLQ_FLAGS_PG_SZ_256K					(10<<0)
+#define KRNLQ_FLAGS_PG_SZ_512K					(11<<0)
+#define KRNLQ_FLAGS_PG_SZ_1M					(12<<0)
+#define KRNLQ_FLAGS_PG_SZ_2M					(13<<0)
+#define KRNLQ_FLAGS_QE_SELF_SEQ					(1<<15)
+#define KRNLQ_SIZE_TYPE_SIZE	((((0x28 + 0x1f) & ~0x1f) / 0x20) << 16)
+#define KRNLQ_TYPE_TYPE						(0xf<<28)
+#define KRNLQ_TYPE_TYPE_EMPTY					(0<<28)
+#define KRNLQ_TYPE_TYPE_KRNLQ					(6<<28)
+
+#define L5_KRNLQ_HOST_QIDX		0x00000004
+#define L5_KRNLQ_HOST_FW_QIDX		0x00000008
+#define L5_KRNLQ_NX_QE_SELF_SEQ 	0x0000000c
+#define L5_KRNLQ_QE_SELF_SEQ_MAX	0x0000000c
+#define L5_KRNLQ_NX_QE_HADDR_HI 	0x00000010
+#define L5_KRNLQ_NX_QE_HADDR_LO 	0x00000014
+#define L5_KRNLQ_PGTBL_PGIDX		0x00000018
+#define L5_KRNLQ_NX_PG_QIDX 		0x00000018
+#define L5_KRNLQ_PGTBL_NPAGES		0x0000001c
+#define L5_KRNLQ_QIDX_INCR		0x0000001c
+#define L5_KRNLQ_PGTBL_HADDR_HI 	0x00000020
+#define L5_KRNLQ_PGTBL_HADDR_LO 	0x00000024
+
+struct cnic_redirect_entry {
+	struct dst_entry *old_dst;
+	struct dst_entry *new_dst;
+};
+
+struct cnic_work_node {
+	u32			work_type;
+#define	WORK_TYPE_KCQE			1
+#define	WORK_TYPE_NEIGH_UPDATE		2
+#define	WORK_TYPE_REDIRECT		3
+	union {
+		struct kcqe		kcqe;
+		struct neighbour	*neigh;
+		struct cnic_redirect_entry cnic_redir;
+	} work_data;
+};
+
+#define WORK_RING_SIZE		128
+#define WORK_RING_SIZE_MASK	127
+#define MAX_CM_SK_TBL_SZ	128
+#define MAX_COMPLETED_KCQE	64
+
+#define KWQE_CNT (BCM_PAGE_SIZE / sizeof(struct kwqe))
+#define KCQE_CNT (BCM_PAGE_SIZE / sizeof(struct kcqe))
+#define MAX_KWQE_CNT (KWQE_CNT - 1)
+#define MAX_KCQE_CNT (KCQE_CNT - 1)
+
+#define MAX_KWQ_IDX	((KWQ_PAGE_CNT * KWQE_CNT) - 1)
+#define MAX_KCQ_IDX	((KCQ_PAGE_CNT * KCQE_CNT) - 1)
+
+#define KWQ_PG(x) (((x) & ~MAX_KWQE_CNT) >> (BCM_PAGE_BITS - 5))
+#define KWQ_IDX(x) ((x) & MAX_KWQE_CNT)
+
+#define KCQ_PG(x) (((x) & ~MAX_KCQE_CNT) >> (BCM_PAGE_BITS - 5))
+#define KCQ_IDX(x) ((x) & MAX_KCQE_CNT)
+
+#define DEF_IPID_COUNT		0xc001
+
+#define DEF_KA_TIMEOUT		10000
+#define DEF_KA_INTERVAL		300000
+#define DEF_KA_MAX_PROBE_COUNT	3
+#define DEF_TOS			0
+#define DEF_TTL			0xfe
+#define DEF_SND_SEQ_SCALE	0
+#define DEF_RCV_BUF		0xffff
+#define DEF_SND_BUF		0xffff
+#define DEF_SEED		0
+
+struct cnic_local {
+
+	spinlock_t cnic_ulp_lock;
+	void *ulp_handle[MAX_CNIC_ULP_TYPE];
+	unsigned long ulp_flags[MAX_CNIC_ULP_TYPE];
+#define ULP_F_INIT	0
+#define ULP_F_START	1
+	struct cnic_ulp_ops *ulp_ops[MAX_CNIC_ULP_TYPE];
+
+	struct cnic_dev *dev;
+
+	u32 kwq_cid_addr;
+	u32 kcq_cid_addr;
+
+	struct kwqe	*kwq[KWQ_PAGE_CNT];
+	dma_addr_t	kwq_mapping[KWQ_PAGE_CNT];
+	u16		kwq_prod_idx;
+	u32		kwq_io_addr;
+
+	u16		kwq_con_idx;
+
+	void		*kwq_pgtbl;
+	dma_addr_t	kwq_pgtbl_mapping;
+	int		kwq_pgtbl_size;
+
+	struct kcqe	*kcq[KCQ_PAGE_CNT];
+	dma_addr_t	kcq_mapping[KCQ_PAGE_CNT];
+	u16		kcq_prod_idx;
+	u32		kcq_io_addr;
+
+	void		*kcq_pgtbl;
+	dma_addr_t	kcq_pgtbl_mapping;
+	int		kcq_pgtbl_size;
+
+	struct kcqe	*completed_kcq[MAX_COMPLETED_KCQE];
+
+	struct cnic_sock *csk_tbl;
+	spinlock_t	cm_lock;
+
+	struct notifier_block cm_nb;
+
+	struct cnic_work_node	cnic_work_ring[WORK_RING_SIZE];
+	int			cnic_wr_cons;
+	int			cnic_wr_prod;
+
+	struct work_struct	cnic_task;
+
+};
+
+#endif
diff --git a/drivers/net/cnic_cm.h b/drivers/net/cnic_cm.h
new file mode 100644
index 0000000..d6ea01d
--- /dev/null
+++ b/drivers/net/cnic_cm.h
@@ -0,0 +1,555 @@
+#ifndef __57XX_L5CM_HSI_LINUX_LE__
+#define __57XX_L5CM_HSI_LINUX_LE__
+
+/* KWQ (kernel work queue) request op codes */
+#define L4_KWQE_OPCODE_VALUE_CONNECT1               (50)
+#define L4_KWQE_OPCODE_VALUE_CONNECT2               (51)
+#define L4_KWQE_OPCODE_VALUE_CONNECT3               (52)
+#define L4_KWQE_OPCODE_VALUE_RESET                  (53)
+#define L4_KWQE_OPCODE_VALUE_CLOSE                  (54)
+#define L4_KWQE_OPCODE_VALUE_UPDATE_SECRET          (60)
+#define L4_KWQE_OPCODE_VALUE_INIT_ULP               (61)
+
+#define L4_KWQE_OPCODE_VALUE_OFFLOAD_PG             (1)
+#define L4_KWQE_OPCODE_VALUE_UPDATE_PG              (9)
+#define L4_KWQE_OPCODE_VALUE_UPLOAD_PG              (14)
+
+/* KCQ (kernel completion queue) response op codes */
+#define L4_KCQE_OPCODE_VALUE_CONNECT_RESP           (52)
+#define L4_KCQE_OPCODE_VALUE_CLOSE_COMP             (53)
+#define L4_KCQE_OPCODE_VALUE_RESET_COMP             (54)
+#define L4_KCQE_OPCODE_VALUE_FW_TCP_UPDATE          (55)
+#define L4_KCQE_OPCODE_VALUE_CONNECT_COMPLETE       (56)
+#define L4_KCQE_OPCODE_VALUE_RESET_RECEIVED         (57)
+#define L4_KCQE_OPCODE_VALUE_CLOSE_RECEIVED         (58)
+#define L4_KCQE_OPCODE_VALUE_CONNECT_CLOSE	        (59)
+#define L4_KCQE_OPCODE_VALUE_CONNECT_RESET          (60)
+#define L4_KCQE_OPCODE_VALUE_INIT_ULP               (61)
+
+#define L4_KCQE_OPCODE_VALUE_OFFLOAD_PG             (1)
+#define L4_KCQE_OPCODE_VALUE_UPLOAD_PG              (14)
+
+/* KCQ (kernel completion queue) completion status */
+#define L4_KCQE_COMPLETION_STATUS_SUCCESS		    (0)
+#define L4_KCQE_COMPLETION_STATUS_TIMEOUT        (0x93)
+
+#define L4_LAYER_CODE (4)
+
+/*
+ * L4 KCQ CQE
+ */
+struct l4_kcq {
+	u32 cid;
+	u32 pg_cid;
+	u32 conn_id;
+	u32 pg_host_opaque;
+#if defined(__BIG_ENDIAN)
+	u16 status;
+	u16 reserved1;
+#elif defined(__LITTLE_ENDIAN)
+	u16 reserved1;
+	u16 status;
+#endif
+	u32 reserved2[2];
+#if defined(__BIG_ENDIAN)
+	u8 flags;
+#define L4_KCQ_RESERVED3 (0xF<<0)
+#define L4_KCQ_RESERVED3_SHIFT 0
+#define L4_KCQ_LAYER_CODE (0x7<<4)
+#define L4_KCQ_LAYER_CODE_SHIFT 4
+#define L4_KCQ_RESERVED4 (0x1<<7)
+#define L4_KCQ_RESERVED4_SHIFT 7
+	u8 op_code;
+	u16 qe_self_seq;
+#elif defined(__LITTLE_ENDIAN)
+	u16 qe_self_seq;
+	u8 op_code;
+	u8 flags;
+#define L4_KCQ_RESERVED3 (0xF<<0)
+#define L4_KCQ_RESERVED3_SHIFT 0
+#define L4_KCQ_LAYER_CODE (0x7<<4)
+#define L4_KCQ_LAYER_CODE_SHIFT 4
+#define L4_KCQ_RESERVED4 (0x1<<7)
+#define L4_KCQ_RESERVED4_SHIFT 7
+#endif
+};
+
+
+/*
+ * L4 KCQ CQE PG upload
+ */
+struct l4_kcq_upload_pg {
+	u32 pg_cid;
+#if defined(__BIG_ENDIAN)
+	u16 pg_status;
+	u16 pg_ipid_count;
+#elif defined(__LITTLE_ENDIAN)
+	u16 pg_ipid_count;
+	u16 pg_status;
+#endif
+	u32 reserved1[5];
+#if defined(__BIG_ENDIAN)
+	u8 flags;
+#define L4_KCQ_UPLOAD_PG_RESERVED3 (0xF<<0)
+#define L4_KCQ_UPLOAD_PG_RESERVED3_SHIFT 0
+#define L4_KCQ_UPLOAD_PG_LAYER_CODE (0x7<<4)
+#define L4_KCQ_UPLOAD_PG_LAYER_CODE_SHIFT 4
+#define L4_KCQ_UPLOAD_PG_RESERVED4 (0x1<<7)
+#define L4_KCQ_UPLOAD_PG_RESERVED4_SHIFT 7
+	u8 op_code;
+	u16 qe_self_seq;
+#elif defined(__LITTLE_ENDIAN)
+	u16 qe_self_seq;
+	u8 op_code;
+	u8 flags;
+#define L4_KCQ_UPLOAD_PG_RESERVED3 (0xF<<0)
+#define L4_KCQ_UPLOAD_PG_RESERVED3_SHIFT 0
+#define L4_KCQ_UPLOAD_PG_LAYER_CODE (0x7<<4)
+#define L4_KCQ_UPLOAD_PG_LAYER_CODE_SHIFT 4
+#define L4_KCQ_UPLOAD_PG_RESERVED4 (0x1<<7)
+#define L4_KCQ_UPLOAD_PG_RESERVED4_SHIFT 7
+#endif
+};
+
+
+/*
+ * Gracefully close the connection request
+ */
+struct l4_kwq_close_req {
+#if defined(__BIG_ENDIAN)
+	u8 flags;
+#define L4_KWQ_CLOSE_REQ_RESERVED1 (0xF<<0)
+#define L4_KWQ_CLOSE_REQ_RESERVED1_SHIFT 0
+#define L4_KWQ_CLOSE_REQ_LAYER_CODE (0x7<<4)
+#define L4_KWQ_CLOSE_REQ_LAYER_CODE_SHIFT 4
+#define L4_KWQ_CLOSE_REQ_LINKED_WITH_NEXT (0x1<<7)
+#define L4_KWQ_CLOSE_REQ_LINKED_WITH_NEXT_SHIFT 7
+	u8 op_code;
+	u16 reserved0;
+#elif defined(__LITTLE_ENDIAN)
+	u16 reserved0;
+	u8 op_code;
+	u8 flags;
+#define L4_KWQ_CLOSE_REQ_RESERVED1 (0xF<<0)
+#define L4_KWQ_CLOSE_REQ_RESERVED1_SHIFT 0
+#define L4_KWQ_CLOSE_REQ_LAYER_CODE (0x7<<4)
+#define L4_KWQ_CLOSE_REQ_LAYER_CODE_SHIFT 4
+#define L4_KWQ_CLOSE_REQ_LINKED_WITH_NEXT (0x1<<7)
+#define L4_KWQ_CLOSE_REQ_LINKED_WITH_NEXT_SHIFT 7
+#endif
+	u32 cid;
+	u32 reserved2[6];
+};
+
+
+/*
+ * The first request to be passed in order to establish connection in option2
+ */
+struct l4_kwq_connect_req1 {
+#if defined(__BIG_ENDIAN)
+	u8 flags;
+#define L4_KWQ_CONNECT_REQ1_RESERVED1 (0xF<<0)
+#define L4_KWQ_CONNECT_REQ1_RESERVED1_SHIFT 0
+#define L4_KWQ_CONNECT_REQ1_LAYER_CODE (0x7<<4)
+#define L4_KWQ_CONNECT_REQ1_LAYER_CODE_SHIFT 4
+#define L4_KWQ_CONNECT_REQ1_LINKED_WITH_NEXT (0x1<<7)
+#define L4_KWQ_CONNECT_REQ1_LINKED_WITH_NEXT_SHIFT 7
+	u8 op_code;
+	u8 reserved0;
+	u8 conn_flags;
+#define L4_KWQ_CONNECT_REQ1_IS_PG_HOST_OPAQUE (0x1<<0)
+#define L4_KWQ_CONNECT_REQ1_IS_PG_HOST_OPAQUE_SHIFT 0
+#define L4_KWQ_CONNECT_REQ1_IP_V6 (0x1<<1)
+#define L4_KWQ_CONNECT_REQ1_IP_V6_SHIFT 1
+#define L4_KWQ_CONNECT_REQ1_PASSIVE_FLAG (0x1<<2)
+#define L4_KWQ_CONNECT_REQ1_PASSIVE_FLAG_SHIFT 2
+#define L4_KWQ_CONNECT_REQ1_RSRV (0x1F<<3)
+#define L4_KWQ_CONNECT_REQ1_RSRV_SHIFT 3
+#elif defined(__LITTLE_ENDIAN)
+	u8 conn_flags;
+#define L4_KWQ_CONNECT_REQ1_IS_PG_HOST_OPAQUE (0x1<<0)
+#define L4_KWQ_CONNECT_REQ1_IS_PG_HOST_OPAQUE_SHIFT 0
+#define L4_KWQ_CONNECT_REQ1_IP_V6 (0x1<<1)
+#define L4_KWQ_CONNECT_REQ1_IP_V6_SHIFT 1
+#define L4_KWQ_CONNECT_REQ1_PASSIVE_FLAG (0x1<<2)
+#define L4_KWQ_CONNECT_REQ1_PASSIVE_FLAG_SHIFT 2
+#define L4_KWQ_CONNECT_REQ1_RSRV (0x1F<<3)
+#define L4_KWQ_CONNECT_REQ1_RSRV_SHIFT 3
+	u8 reserved0;
+	u8 op_code;
+	u8 flags;
+#define L4_KWQ_CONNECT_REQ1_RESERVED1 (0xF<<0)
+#define L4_KWQ_CONNECT_REQ1_RESERVED1_SHIFT 0
+#define L4_KWQ_CONNECT_REQ1_LAYER_CODE (0x7<<4)
+#define L4_KWQ_CONNECT_REQ1_LAYER_CODE_SHIFT 4
+#define L4_KWQ_CONNECT_REQ1_LINKED_WITH_NEXT (0x1<<7)
+#define L4_KWQ_CONNECT_REQ1_LINKED_WITH_NEXT_SHIFT 7
+#endif
+	u32 cid;
+	u32 pg_cid;
+	u32 src_ip;
+	u32 dst_ip;
+#if defined(__BIG_ENDIAN)
+	u16 dst_port;
+	u16 src_port;
+#elif defined(__LITTLE_ENDIAN)
+	u16 src_port;
+	u16 dst_port;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 rsrv1[3];
+	u8 tcp_flags;
+#define L4_KWQ_CONNECT_REQ1_NO_DELAY_ACK (0x1<<0)
+#define L4_KWQ_CONNECT_REQ1_NO_DELAY_ACK_SHIFT 0
+#define L4_KWQ_CONNECT_REQ1_KEEP_ALIVE (0x1<<1)
+#define L4_KWQ_CONNECT_REQ1_KEEP_ALIVE_SHIFT 1
+#define L4_KWQ_CONNECT_REQ1_NAGLE_ENABLE (0x1<<2)
+#define L4_KWQ_CONNECT_REQ1_NAGLE_ENABLE_SHIFT 2
+#define L4_KWQ_CONNECT_REQ1_TIME_STAMP (0x1<<3)
+#define L4_KWQ_CONNECT_REQ1_TIME_STAMP_SHIFT 3
+#define L4_KWQ_CONNECT_REQ1_SACK (0x1<<4)
+#define L4_KWQ_CONNECT_REQ1_SACK_SHIFT 4
+#define L4_KWQ_CONNECT_REQ1_SEG_SCALING (0x1<<5)
+#define L4_KWQ_CONNECT_REQ1_SEG_SCALING_SHIFT 5
+#define L4_KWQ_CONNECT_REQ1_RESERVED2 (0x3<<6)
+#define L4_KWQ_CONNECT_REQ1_RESERVED2_SHIFT 6
+#elif defined(__LITTLE_ENDIAN)
+	u8 tcp_flags;
+#define L4_KWQ_CONNECT_REQ1_NO_DELAY_ACK (0x1<<0)
+#define L4_KWQ_CONNECT_REQ1_NO_DELAY_ACK_SHIFT 0
+#define L4_KWQ_CONNECT_REQ1_KEEP_ALIVE (0x1<<1)
+#define L4_KWQ_CONNECT_REQ1_KEEP_ALIVE_SHIFT 1
+#define L4_KWQ_CONNECT_REQ1_NAGLE_ENABLE (0x1<<2)
+#define L4_KWQ_CONNECT_REQ1_NAGLE_ENABLE_SHIFT 2
+#define L4_KWQ_CONNECT_REQ1_TIME_STAMP (0x1<<3)
+#define L4_KWQ_CONNECT_REQ1_TIME_STAMP_SHIFT 3
+#define L4_KWQ_CONNECT_REQ1_SACK (0x1<<4)
+#define L4_KWQ_CONNECT_REQ1_SACK_SHIFT 4
+#define L4_KWQ_CONNECT_REQ1_SEG_SCALING (0x1<<5)
+#define L4_KWQ_CONNECT_REQ1_SEG_SCALING_SHIFT 5
+#define L4_KWQ_CONNECT_REQ1_RESERVED2 (0x3<<6)
+#define L4_KWQ_CONNECT_REQ1_RESERVED2_SHIFT 6
+	u8 rsrv1[3];
+#endif
+	u32 rsrv2;
+};
+
+
+/*
+ * The second ( optional )request to be passed in order to establish connection in option2 - for IPv6 only
+ */
+struct l4_kwq_connect_req2 {
+#if defined(__BIG_ENDIAN)
+	u8 flags;
+#define L4_KWQ_CONNECT_REQ2_RESERVED1 (0xF<<0)
+#define L4_KWQ_CONNECT_REQ2_RESERVED1_SHIFT 0
+#define L4_KWQ_CONNECT_REQ2_LAYER_CODE (0x7<<4)
+#define L4_KWQ_CONNECT_REQ2_LAYER_CODE_SHIFT 4
+#define L4_KWQ_CONNECT_REQ2_LINKED_WITH_NEXT (0x1<<7)
+#define L4_KWQ_CONNECT_REQ2_LINKED_WITH_NEXT_SHIFT 7
+	u8 op_code;
+	u8 reserved0;
+	u8 rsrv;
+#elif defined(__LITTLE_ENDIAN)
+	u8 rsrv;
+	u8 reserved0;
+	u8 op_code;
+	u8 flags;
+#define L4_KWQ_CONNECT_REQ2_RESERVED1 (0xF<<0)
+#define L4_KWQ_CONNECT_REQ2_RESERVED1_SHIFT 0
+#define L4_KWQ_CONNECT_REQ2_LAYER_CODE (0x7<<4)
+#define L4_KWQ_CONNECT_REQ2_LAYER_CODE_SHIFT 4
+#define L4_KWQ_CONNECT_REQ2_LINKED_WITH_NEXT (0x1<<7)
+#define L4_KWQ_CONNECT_REQ2_LINKED_WITH_NEXT_SHIFT 7
+#endif
+	u32 reserved2;
+	u32 src_ip_v6_2;
+	u32 src_ip_v6_3;
+	u32 src_ip_v6_4;
+	u32 dst_ip_v6_2;
+	u32 dst_ip_v6_3;
+	u32 dst_ip_v6_4;
+};
+
+
+/*
+ * The third ( and last )request to be passed in order to establish connection in option2
+ */
+struct l4_kwq_connect_req3 {
+#if defined(__BIG_ENDIAN)
+	u8 flags;
+#define L4_KWQ_CONNECT_REQ3_RESERVED1 (0xF<<0)
+#define L4_KWQ_CONNECT_REQ3_RESERVED1_SHIFT 0
+#define L4_KWQ_CONNECT_REQ3_LAYER_CODE (0x7<<4)
+#define L4_KWQ_CONNECT_REQ3_LAYER_CODE_SHIFT 4
+#define L4_KWQ_CONNECT_REQ3_LINKED_WITH_NEXT (0x1<<7)
+#define L4_KWQ_CONNECT_REQ3_LINKED_WITH_NEXT_SHIFT 7
+	u8 op_code;
+	u16 reserved0;
+#elif defined(__LITTLE_ENDIAN)
+	u16 reserved0;
+	u8 op_code;
+	u8 flags;
+#define L4_KWQ_CONNECT_REQ3_RESERVED1 (0xF<<0)
+#define L4_KWQ_CONNECT_REQ3_RESERVED1_SHIFT 0
+#define L4_KWQ_CONNECT_REQ3_LAYER_CODE (0x7<<4)
+#define L4_KWQ_CONNECT_REQ3_LAYER_CODE_SHIFT 4
+#define L4_KWQ_CONNECT_REQ3_LINKED_WITH_NEXT (0x1<<7)
+#define L4_KWQ_CONNECT_REQ3_LINKED_WITH_NEXT_SHIFT 7
+#endif
+	u32 ka_timeout;
+	u32 ka_interval ;
+#if defined(__BIG_ENDIAN)
+	u8 snd_seq_scale;
+	u8 ttl;
+	u8 tos;
+	u8 ka_max_probe_count;
+#elif defined(__LITTLE_ENDIAN)
+	u8 ka_max_probe_count;
+	u8 tos;
+	u8 ttl;
+	u8 snd_seq_scale;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 pmtu;
+	u16 mss;
+#elif defined(__LITTLE_ENDIAN)
+	u16 mss;
+	u16 pmtu;
+#endif
+	u32 rcv_buf;
+	u32 snd_buf;
+	u32 seed;
+};
+
+
+/*
+ * a KWQE request to offload a PG connection
+ */
+struct l4_kwq_offload_pg {
+#if defined(__BIG_ENDIAN)
+	u8 flags;
+#define L4_KWQ_OFFLOAD_PG_RESERVED1 (0xF<<0)
+#define L4_KWQ_OFFLOAD_PG_RESERVED1_SHIFT 0
+#define L4_KWQ_OFFLOAD_PG_LAYER_CODE (0x7<<4)
+#define L4_KWQ_OFFLOAD_PG_LAYER_CODE_SHIFT 4
+#define L4_KWQ_OFFLOAD_PG_LINKED_WITH_NEXT (0x1<<7)
+#define L4_KWQ_OFFLOAD_PG_LINKED_WITH_NEXT_SHIFT 7
+	u8 op_code;
+	u16 reserved0;
+#elif defined(__LITTLE_ENDIAN)
+	u16 reserved0;
+	u8 op_code;
+	u8 flags;
+#define L4_KWQ_OFFLOAD_PG_RESERVED1 (0xF<<0)
+#define L4_KWQ_OFFLOAD_PG_RESERVED1_SHIFT 0
+#define L4_KWQ_OFFLOAD_PG_LAYER_CODE (0x7<<4)
+#define L4_KWQ_OFFLOAD_PG_LAYER_CODE_SHIFT 4
+#define L4_KWQ_OFFLOAD_PG_LINKED_WITH_NEXT (0x1<<7)
+#define L4_KWQ_OFFLOAD_PG_LINKED_WITH_NEXT_SHIFT 7
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 l2hdr_nbytes;
+	u8 pg_flags;
+#define L4_KWQ_OFFLOAD_PG_SNAP_ENCAP (0x1<<0)
+#define L4_KWQ_OFFLOAD_PG_SNAP_ENCAP_SHIFT 0
+#define L4_KWQ_OFFLOAD_PG_VLAN_TAGGING (0x1<<1)
+#define L4_KWQ_OFFLOAD_PG_VLAN_TAGGING_SHIFT 1
+#define L4_KWQ_OFFLOAD_PG_RESERVED2 (0x3F<<2)
+#define L4_KWQ_OFFLOAD_PG_RESERVED2_SHIFT 2
+	u8 da0;
+	u8 da1;
+#elif defined(__LITTLE_ENDIAN)
+	u8 da1;
+	u8 da0;
+	u8 pg_flags;
+#define L4_KWQ_OFFLOAD_PG_SNAP_ENCAP (0x1<<0)
+#define L4_KWQ_OFFLOAD_PG_SNAP_ENCAP_SHIFT 0
+#define L4_KWQ_OFFLOAD_PG_VLAN_TAGGING (0x1<<1)
+#define L4_KWQ_OFFLOAD_PG_VLAN_TAGGING_SHIFT 1
+#define L4_KWQ_OFFLOAD_PG_RESERVED2 (0x3F<<2)
+#define L4_KWQ_OFFLOAD_PG_RESERVED2_SHIFT 2
+	u8 l2hdr_nbytes;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 da2;
+	u8 da3;
+	u8 da4;
+	u8 da5;
+#elif defined(__LITTLE_ENDIAN)
+	u8 da5;
+	u8 da4;
+	u8 da3;
+	u8 da2;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 sa0;
+	u8 sa1;
+	u8 sa2;
+	u8 sa3;
+#elif defined(__LITTLE_ENDIAN)
+	u8 sa3;
+	u8 sa2;
+	u8 sa1;
+	u8 sa0;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 sa4;
+	u8 sa5;
+	u16 etype;
+#elif defined(__LITTLE_ENDIAN)
+	u16 etype;
+	u8 sa5;
+	u8 sa4;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 vlan_tag;
+	u16 ipid_start;
+#elif defined(__LITTLE_ENDIAN)
+	u16 ipid_start;
+	u16 vlan_tag;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 ipid_count;
+	u16 reserved3;
+#elif defined(__LITTLE_ENDIAN)
+	u16 reserved3;
+	u16 ipid_count;
+#endif
+	u32 host_opaque;
+};
+
+
+/*
+ * Abortively close the connection request
+ */
+struct l4_kwq_reset_req {
+#if defined(__BIG_ENDIAN)
+	u8 flags;
+#define L4_KWQ_RESET_REQ_RESERVED1 (0xF<<0)
+#define L4_KWQ_RESET_REQ_RESERVED1_SHIFT 0
+#define L4_KWQ_RESET_REQ_LAYER_CODE (0x7<<4)
+#define L4_KWQ_RESET_REQ_LAYER_CODE_SHIFT 4
+#define L4_KWQ_RESET_REQ_LINKED_WITH_NEXT (0x1<<7)
+#define L4_KWQ_RESET_REQ_LINKED_WITH_NEXT_SHIFT 7
+	u8 op_code;
+	u16 reserved0;
+#elif defined(__LITTLE_ENDIAN)
+	u16 reserved0;
+	u8 op_code;
+	u8 flags;
+#define L4_KWQ_RESET_REQ_RESERVED1 (0xF<<0)
+#define L4_KWQ_RESET_REQ_RESERVED1_SHIFT 0
+#define L4_KWQ_RESET_REQ_LAYER_CODE (0x7<<4)
+#define L4_KWQ_RESET_REQ_LAYER_CODE_SHIFT 4
+#define L4_KWQ_RESET_REQ_LINKED_WITH_NEXT (0x1<<7)
+#define L4_KWQ_RESET_REQ_LINKED_WITH_NEXT_SHIFT 7
+#endif
+	u32 cid;
+	u32 reserved2[6];
+};
+
+
+/*
+ * a KWQE request to update a PG connection
+ */
+struct l4_kwq_update_pg {
+#if defined(__BIG_ENDIAN)
+	u8 flags;
+#define L4_KWQ_UPDATE_PG_RESERVED1 (0xF<<0)
+#define L4_KWQ_UPDATE_PG_RESERVED1_SHIFT 0
+#define L4_KWQ_UPDATE_PG_LAYER_CODE (0x7<<4)
+#define L4_KWQ_UPDATE_PG_LAYER_CODE_SHIFT 4
+#define L4_KWQ_UPDATE_PG_LINKED_WITH_NEXT (0x1<<7)
+#define L4_KWQ_UPDATE_PG_LINKED_WITH_NEXT_SHIFT 7
+	u8 opcode;
+	u16 oper16;
+#elif defined(__LITTLE_ENDIAN)
+	u16 oper16;
+	u8 opcode;
+	u8 flags;
+#define L4_KWQ_UPDATE_PG_RESERVED1 (0xF<<0)
+#define L4_KWQ_UPDATE_PG_RESERVED1_SHIFT 0
+#define L4_KWQ_UPDATE_PG_LAYER_CODE (0x7<<4)
+#define L4_KWQ_UPDATE_PG_LAYER_CODE_SHIFT 4
+#define L4_KWQ_UPDATE_PG_LINKED_WITH_NEXT (0x1<<7)
+#define L4_KWQ_UPDATE_PG_LINKED_WITH_NEXT_SHIFT 7
+#endif
+	u32 pg_cid;
+	u32 pg_host_opaque;
+#if defined(__BIG_ENDIAN)
+	u8 pg_valids;
+#define L4_KWQ_UPDATE_PG_VALIDS_IPID_COUNT (0x1<<0)
+#define L4_KWQ_UPDATE_PG_VALIDS_IPID_COUNT_SHIFT 0
+#define L4_KWQ_UPDATE_PG_VALIDS_DA (0x1<<1)
+#define L4_KWQ_UPDATE_PG_VALIDS_DA_SHIFT 1
+#define L4_KWQ_UPDATE_PG_RESERVERD2 (0x3F<<2)
+#define L4_KWQ_UPDATE_PG_RESERVERD2_SHIFT 2
+	u8 pg_unused_a;
+	u16 pg_ipid_count;
+#elif defined(__LITTLE_ENDIAN)
+	u16 pg_ipid_count;
+	u8 pg_unused_a;
+	u8 pg_valids;
+#define L4_KWQ_UPDATE_PG_VALIDS_IPID_COUNT (0x1<<0)
+#define L4_KWQ_UPDATE_PG_VALIDS_IPID_COUNT_SHIFT 0
+#define L4_KWQ_UPDATE_PG_VALIDS_DA (0x1<<1)
+#define L4_KWQ_UPDATE_PG_VALIDS_DA_SHIFT 1
+#define L4_KWQ_UPDATE_PG_RESERVERD2 (0x3F<<2)
+#define L4_KWQ_UPDATE_PG_RESERVERD2_SHIFT 2
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 reserverd3;
+	u8 da0;
+	u8 da1;
+#elif defined(__LITTLE_ENDIAN)
+	u8 da1;
+	u8 da0;
+	u16 reserverd3;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 da2;
+	u8 da3;
+	u8 da4;
+	u8 da5;
+#elif defined(__LITTLE_ENDIAN)
+	u8 da5;
+	u8 da4;
+	u8 da3;
+	u8 da2;
+#endif
+	u32 reserved4;
+	u32 reserved5;
+};
+
+
+/*
+ * a KWQE request to upload a PG or L4 context
+ */
+struct l4_kwq_upload {
+#if defined(__BIG_ENDIAN)
+	u8 flags;
+#define L4_KWQ_UPLOAD_RESERVED1 (0xF<<0)
+#define L4_KWQ_UPLOAD_RESERVED1_SHIFT 0
+#define L4_KWQ_UPLOAD_LAYER_CODE (0x7<<4)
+#define L4_KWQ_UPLOAD_LAYER_CODE_SHIFT 4
+#define L4_KWQ_UPLOAD_LINKED_WITH_NEXT (0x1<<7)
+#define L4_KWQ_UPLOAD_LINKED_WITH_NEXT_SHIFT 7
+	u8 opcode;
+	u16 oper16;
+#elif defined(__LITTLE_ENDIAN)
+	u16 oper16;
+	u8 opcode;
+	u8 flags;
+#define L4_KWQ_UPLOAD_RESERVED1 (0xF<<0)
+#define L4_KWQ_UPLOAD_RESERVED1_SHIFT 0
+#define L4_KWQ_UPLOAD_LAYER_CODE (0x7<<4)
+#define L4_KWQ_UPLOAD_LAYER_CODE_SHIFT 4
+#define L4_KWQ_UPLOAD_LINKED_WITH_NEXT (0x1<<7)
+#define L4_KWQ_UPLOAD_LINKED_WITH_NEXT_SHIFT 7
+#endif
+	u32 cid;
+	u32 reserved2[6];
+};
+
+#endif /* __57XX_L5CM_HSI_LINUX_LE__ */
diff --git a/drivers/net/cnic_if.h b/drivers/net/cnic_if.h
new file mode 100644
index 0000000..6ec8f1a
--- /dev/null
+++ b/drivers/net/cnic_if.h
@@ -0,0 +1,152 @@
+/* cnic_if.h: Broadcom CNIC core network driver.
+ *
+ * Copyright (c) 2006 Broadcom Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Written by: John(Zongxi) Chen  (zongxic@broadcom.com)
+ */
+
+
+#ifndef CNIC_IF_H
+#define CNIC_IF_H
+
+#define CNIC_MODULE_VERSION	"1.1.12"
+#define CNIC_MODULE_RELDATE	"Aug 24, 2007"
+
+#define CNIC_ULP_RDMA		0
+#define CNIC_ULP_ISCSI		1
+#define CNIC_ULP_L4		2
+#define MAX_CNIC_ULP_TYPE_EXT	2
+#define MAX_CNIC_ULP_TYPE	3
+
+struct kwqe {
+	u32 kwqe_op_flag;
+
+	u32 kwqe_info0;
+	u32 kwqe_info1;
+	u32 kwqe_info2;
+	u32 kwqe_info3;
+	u32 kwqe_info4;
+	u32 kwqe_info5;
+	u32 kwqe_info6;
+};
+
+struct kcqe {
+	u32 kcqe_info0;
+	u32 kcqe_info1;
+	u32 kcqe_info2;
+	u32 kcqe_info3;
+	u32 kcqe_info4;
+	u32 kcqe_info5;
+	u32 kcqe_info6;
+	u32 kcqe_op_flag;
+		#define KCQE_FLAGS_LAYER_MASK		(0x7<<28)
+		#define KCQE_FLAGS_LAYER_MASK_MISC	(0<<28)
+		#define KCQE_FLAGS_LAYER_MASK_L2	(2<<28)
+		#define KCQE_FLAGS_LAYER_MASK_L3	(3<<28)
+		#define KCQE_FLAGS_LAYER_MASK_L4	(4<<28)
+		#define KCQE_FLAGS_LAYER_MASK_L5_RDMA	(5<<28)
+		#define KCQE_FLAGS_LAYER_MASK_L5_ISCSI	(6<<28)
+		#define KCQE_FLAGS_NEXT 		(1<<31)
+};
+
+struct cnic_sockaddr {
+	struct sockaddr_in	local_addr;
+	struct sockaddr_in	remote_addr;
+};
+
+struct cnic_sock {
+	struct cnic_dev *dev;
+	void	*context;
+	u32	src_ip;
+	u32	dst_ip;
+	u16	src_port;
+	u16	dst_port;
+	u16	vlan_id;
+	struct dst_entry *dst;
+	u32	cid;
+	u32	l5_cid;
+	u32	pg_cid;
+	int	ulp_type;
+
+	u32	ka_timeout;
+	u32	ka_interval;
+	u8	ka_max_probe_count;
+	u8	tos;
+	u8	ttl;
+	u8	snd_seq_scale;
+	u32	rcv_buf;
+	u32	snd_buf;
+	u32	seed;
+
+	unsigned long	tcp_flags;
+#define SK_TCP_NO_DELAY_ACK	0
+#define SK_TCP_KEEP_ALIVE	1
+#define SK_TCP_NAGLE		2
+#define SK_TCP_TIMESTAMP	3
+#define SK_TCP_SACK		4
+#define SK_TCP_SEG_SCALING	5
+	unsigned long	flags;
+#define SK_F_INUSE		0
+#define SK_F_OFFLD_COMPLETE	1
+#define SK_F_OFFLD_PENDING	2
+#define SK_F_PG_OFFLD_COMPLETE	3
+	struct kwqe kwqe1;
+	struct kwqe kwqe2;
+	struct kwqe kwqe3;
+};
+
+struct cnic_dev {
+	struct net_device	*netdev;
+	struct bnx2		*bp;
+	struct pci_dev		*pcidev;
+	void __iomem		*regview;
+	struct list_head	list;
+	struct class_device	class_dev;
+
+	int (*register_device)(struct cnic_dev *dev, int ulp_type,
+			       void *ulp_ctx);
+	int (*unregister_device)(struct cnic_dev *dev, int ulp_type);
+	int (*submit_kwqes)(struct cnic_dev *dev, struct kwqe *wqes[],
+				u32 num_wqes);
+
+	int (*cm_create)(struct cnic_dev *, int, u32, u32, struct cnic_sock **,
+			 void *);
+	int (*cm_destroy)(struct cnic_sock *);
+	int (*cm_connect)(struct cnic_sock *, struct cnic_sockaddr *);
+	int (*cm_abort)(struct cnic_sock *);
+	int (*cm_close)(struct cnic_sock *);
+	struct cnic_dev *(*cm_select_dev)(struct sockaddr_in *, int ulp_type);
+	unsigned long flags;
+#define CNIC_F_IF_UP		0
+#define CNIC_F_CNIC_UP		1
+	atomic_t ref_count;
+	int use_count;
+	void *cnic_priv;
+};
+
+struct cnic_ulp_ops {
+	void (*cnic_init)(struct cnic_dev *dev);
+	void (*cnic_exit)(struct cnic_dev *dev);
+	void (*cnic_start)(void *ulp_ctx);
+	void (*cnic_stop)(void *ulp_ctx);
+	void (*indicate_kcqes)(void *ulp_ctx, struct kcqe *cqes[],
+				u32 num_cqes);
+	void (*indicate_netevent)(void *ulp_ctx, unsigned long event);
+	void (*indicate_inetevent)(void *ulp_ctx, unsigned long event);
+	void (*cm_connect_complete)(struct cnic_sock *);
+	void (*cm_close_complete)(struct cnic_sock *);
+	void (*cm_abort_complete)(struct cnic_sock *);
+	void (*cm_remote_close)(struct cnic_sock *);
+	void (*cm_remote_abort)(struct cnic_sock *);
+	struct module *owner;
+};
+
+extern int cnic_register_driver(int ulp_type, struct cnic_ulp_ops *ulp_ops);
+
+extern int cnic_unregister_driver(int ulp_type);
+
+#endif


