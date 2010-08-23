From: Anton Blanchard <anton@samba.org>
Subject: [patch 10/20] ibmveth: remove procfs code
Date: Mon, 23 Aug 2010 10:09:40 +1000
Message-ID: <20100823001239.235329193@samba.org>
References: <20100823000930.546065833@samba.org>
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51830 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751249Ab0HWA2d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 20:28:33 -0400
Content-Disposition: inline; filename=veth_remove_proc
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We export all the driver specific statistics via ethtool, so there is no need
to duplicate this in procfs.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.c	2010-08-23 08:52:31.363678383 +1000
+++ net-next-2.6/drivers/net/ibmveth.c	2010-08-23 08:52:31.723652837 +1000
@@ -26,11 +26,6 @@
 /* ethernet NICs that are presented to the partition by the hypervisor.   */
 /*                                                                        */
 /**************************************************************************/
-/*
-  TODO:
-  - add support for sysfs
-  - possibly remove procfs support
-*/
 
 #include <linux/module.h>
 #include <linux/moduleparam.h>
@@ -47,18 +42,15 @@
 #include <linux/mm.h>
 #include <linux/pm.h>
 #include <linux/ethtool.h>
-#include <linux/proc_fs.h>
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/slab.h>
-#include <net/net_namespace.h>
 #include <asm/hvcall.h>
 #include <asm/atomic.h>
 #include <asm/vio.h>
 #include <asm/iommu.h>
 #include <asm/uaccess.h>
 #include <asm/firmware.h>
-#include <linux/seq_file.h>
 
 #include "ibmveth.h"
 
@@ -93,21 +85,12 @@ static int ibmveth_poll(struct napi_stru
 static int ibmveth_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static void ibmveth_set_multicast_list(struct net_device *dev);
 static int ibmveth_change_mtu(struct net_device *dev, int new_mtu);
-static void ibmveth_proc_register_driver(void);
-static void ibmveth_proc_unregister_driver(void);
-static void ibmveth_proc_register_adapter(struct ibmveth_adapter *adapter);
-static void ibmveth_proc_unregister_adapter(struct ibmveth_adapter *adapter);
 static irqreturn_t ibmveth_interrupt(int irq, void *dev_instance);
 static void ibmveth_rxq_harvest_buffer(struct ibmveth_adapter *adapter);
 static unsigned long ibmveth_get_desired_dma(struct vio_dev *vdev);
 static struct kobj_type ktype_veth_pool;
 
 
-#ifdef CONFIG_PROC_FS
-#define IBMVETH_PROC_DIR "ibmveth"
-static struct proc_dir_entry *ibmveth_proc_dir;
-#endif
-
 static const char ibmveth_driver_name[] = "ibmveth";
 static const char ibmveth_driver_string[] = "IBM i/pSeries Virtual Ethernet Driver";
 #define ibmveth_driver_version "1.03"
@@ -1451,8 +1434,6 @@ static int __devinit ibmveth_probe(struc
 
 	ibmveth_debug_printk("registered\n");
 
-	ibmveth_proc_register_adapter(adapter);
-
 	return 0;
 }
 
@@ -1467,103 +1448,12 @@ static int __devexit ibmveth_remove(stru
 
 	unregister_netdev(netdev);
 
-	ibmveth_proc_unregister_adapter(adapter);
-
 	free_netdev(netdev);
 	dev_set_drvdata(&dev->dev, NULL);
 
 	return 0;
 }
 
-#ifdef CONFIG_PROC_FS
-static void ibmveth_proc_register_driver(void)
-{
-	ibmveth_proc_dir = proc_mkdir(IBMVETH_PROC_DIR, init_net.proc_net);
-	if (ibmveth_proc_dir) {
-	}
-}
-
-static void ibmveth_proc_unregister_driver(void)
-{
-	remove_proc_entry(IBMVETH_PROC_DIR, init_net.proc_net);
-}
-
-static int ibmveth_show(struct seq_file *seq, void *v)
-{
-	struct ibmveth_adapter *adapter = seq->private;
-	char *current_mac = (char *) adapter->netdev->dev_addr;
-	char *firmware_mac = (char *) &adapter->mac_addr;
-
-	seq_printf(seq, "%s %s\n\n", ibmveth_driver_string, ibmveth_driver_version);
-
-	seq_printf(seq, "Unit Address:    0x%x\n", adapter->vdev->unit_address);
-	seq_printf(seq, "Current MAC:     %pM\n", current_mac);
-	seq_printf(seq, "Firmware MAC:    %pM\n", firmware_mac);
-
-	seq_printf(seq, "\nAdapter Statistics:\n");
-	seq_printf(seq, "  TX:  vio_map_single failres:      %lld\n", adapter->tx_map_failed);
-	seq_printf(seq, "       send failures:               %lld\n", adapter->tx_send_failed);
-	seq_printf(seq, "  RX:  replenish task cycles:       %lld\n", adapter->replenish_task_cycles);
-	seq_printf(seq, "       alloc_skb_failures:          %lld\n", adapter->replenish_no_mem);
-	seq_printf(seq, "       add buffer failures:         %lld\n", adapter->replenish_add_buff_failure);
-	seq_printf(seq, "       invalid buffers:             %lld\n", adapter->rx_invalid_buffer);
-	seq_printf(seq, "       no buffers:                  %lld\n", adapter->rx_no_buffer);
-
-	return 0;
-}
-
-static int ibmveth_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, ibmveth_show, PDE(inode)->data);
-}
-
-static const struct file_operations ibmveth_proc_fops = {
-	.owner	 = THIS_MODULE,
-	.open    = ibmveth_proc_open,
-	.read    = seq_read,
-	.llseek  = seq_lseek,
-	.release = single_release,
-};
-
-static void ibmveth_proc_register_adapter(struct ibmveth_adapter *adapter)
-{
-	struct proc_dir_entry *entry;
-	if (ibmveth_proc_dir) {
-		char u_addr[10];
-		sprintf(u_addr, "%x", adapter->vdev->unit_address);
-		entry = proc_create_data(u_addr, S_IFREG, ibmveth_proc_dir,
-					 &ibmveth_proc_fops, adapter);
-		if (!entry)
-			ibmveth_error_printk("Cannot create adapter proc entry");
-	}
-}
-
-static void ibmveth_proc_unregister_adapter(struct ibmveth_adapter *adapter)
-{
-	if (ibmveth_proc_dir) {
-		char u_addr[10];
-		sprintf(u_addr, "%x", adapter->vdev->unit_address);
-		remove_proc_entry(u_addr, ibmveth_proc_dir);
-	}
-}
-
-#else /* CONFIG_PROC_FS */
-static void ibmveth_proc_register_adapter(struct ibmveth_adapter *adapter)
-{
-}
-
-static void ibmveth_proc_unregister_adapter(struct ibmveth_adapter *adapter)
-{
-}
-static void ibmveth_proc_register_driver(void)
-{
-}
-
-static void ibmveth_proc_unregister_driver(void)
-{
-}
-#endif /* CONFIG_PROC_FS */
-
 static struct attribute veth_active_attr;
 static struct attribute veth_num_attr;
 static struct attribute veth_size_attr;
@@ -1736,15 +1626,12 @@ static int __init ibmveth_module_init(vo
 {
 	ibmveth_printk("%s: %s %s\n", ibmveth_driver_name, ibmveth_driver_string, ibmveth_driver_version);
 
-	ibmveth_proc_register_driver();
-
 	return vio_register_driver(&ibmveth_driver);
 }
 
 static void __exit ibmveth_module_exit(void)
 {
 	vio_unregister_driver(&ibmveth_driver);
-	ibmveth_proc_unregister_driver();
 }
 
 module_init(ibmveth_module_init);


