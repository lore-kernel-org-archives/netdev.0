From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] kill acient compat cruft from acenic
Date: Fri, 27 Feb 2004 21:25:10 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040227202510.GA19947@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jes@wildopensource.com, jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Kills lots of really old cruft and adds a little cruft to actually
make the driver work with recent 2.4 again.


--- 1.42/drivers/net/acenic.c	Sat Feb  7 06:04:18 2004
+++ edited/drivers/net/acenic.c	Fri Feb 27 15:04:04 2004
@@ -131,7 +131,6 @@
 #define PCI_DEVICE_ID_SGI_ACENIC	0x0009
 #endif
 
-#if LINUX_VERSION_CODE >= 0x20400
 static struct pci_device_id acenic_pci_tbl[] = {
 	{ PCI_VENDOR_ID_ALTEON, PCI_DEVICE_ID_ALTEON_ACENIC_FIBRE,
 	  PCI_ANY_ID, PCI_ANY_ID, PCI_CLASS_NETWORK_ETHERNET << 8, 0xffff00, },
@@ -156,37 +155,6 @@
 	{ }
 };
 MODULE_DEVICE_TABLE(pci, acenic_pci_tbl);
-#endif
-
-
-#ifndef MODULE_LICENSE
-#define MODULE_LICENSE(a)
-#endif
-
-#ifndef wmb
-#define wmb()	mb()
-#endif
-
-#ifndef __exit
-#define __exit
-#endif
-
-#ifndef __devinit
-#define __devinit	__init
-#endif
-
-#ifndef SMP_CACHE_BYTES
-#define SMP_CACHE_BYTES	L1_CACHE_BYTES
-#endif
-
-#ifndef SET_MODULE_OWNER
-#define SET_MODULE_OWNER(dev)		do{} while(0)
-#define ACE_MOD_INC_USE_COUNT		MOD_INC_USE_COUNT
-#define ACE_MOD_DEC_USE_COUNT		MOD_DEC_USE_COUNT
-#else
-#define ACE_MOD_INC_USE_COUNT		do{} while(0)
-#define ACE_MOD_DEC_USE_COUNT		do{} while(0)
-#endif
 
 #ifndef SET_NETDEV_DEV
 #define SET_NETDEV_DEV(net, pdev)	do{} while(0)
@@ -198,151 +166,8 @@
 #define ace_sync_irq(irq)	synchronize_irq()
 #endif
 
-#if LINUX_VERSION_CODE < 0x2051e
-#define local_irq_save(flags)		do{__save_flags(flags) ; \
-					   __cli();} while(0)
-#define local_irq_restore(flags)	__restore_flags(flags)
-#endif
-
-#if (LINUX_VERSION_CODE < 0x02030d)
-#define pci_resource_start(dev, bar)	dev->base_address[bar]
-#elif (LINUX_VERSION_CODE < 0x02032c)
-#define pci_resource_start(dev, bar)	dev->resource[bar].start
-#endif
-
-#if (LINUX_VERSION_CODE < 0x02030e)
-#define net_device device
-#endif
-
-
-#if (LINUX_VERSION_CODE < 0x02032a)
-typedef u32 dma_addr_t;
-
-static inline void *pci_alloc_consistent(struct pci_dev *hwdev, size_t size,
-					 dma_addr_t *dma_handle)
-{
-	void *virt_ptr;
-
-	virt_ptr = kmalloc(size, GFP_KERNEL);
-	if (!virt_ptr)
-		return NULL;
-	*dma_handle = virt_to_bus(virt_ptr);
-	return virt_ptr;
-}
-
-#define pci_free_consistent(cookie, size, ptr, dma_ptr)	kfree(ptr)
-#define pci_map_page(cookie, page, off, size, dir)	\
-	virt_to_bus(page_address(page)+(off))
-#define pci_unmap_page(cookie, address, size, dir)
-#define pci_set_dma_mask(dev, mask)		\
-	(((u64)(mask) & 0xffffffff00000000) == 0 ? 0 : -EIO)
-#define pci_dma_supported(dev, mask)		\
-	(((u64)(mask) & 0xffffffff00000000) == 0 ? 1 : 0)
-
-#elif (LINUX_VERSION_CODE < 0x02040d)
-
-/*
- * 2.4.13 introduced pci_map_page()/pci_unmap_page() - for 2.4.12 and prior,
- * fall back on pci_map_single()/pci_unnmap_single().
- *
- * We are guaranteed that the page is mapped at this point since
- * pci_map_page() is only used upon valid struct skb's.
- */
-static inline dma_addr_t
-pci_map_page(struct pci_dev *cookie, struct page *page, unsigned long off,
-	     size_t size, int dir)
-{
-	void *page_virt;
-
-	page_virt = page_address(page);
-	if (!page_virt)
-		BUG();
-	return pci_map_single(cookie, (page_virt + off), size, dir);
-}
-#define pci_unmap_page(cookie, dma_addr, size, dir)	\
-	pci_unmap_single(cookie, dma_addr, size, dir)
-#endif
-
-#if (LINUX_VERSION_CODE < 0x020412)
-#define DECLARE_PCI_UNMAP_ADDR(ADDR_NAME)
-#define DECLARE_PCI_UNMAP_LEN(LEN_NAME)
-#define pci_unmap_addr(PTR, ADDR_NAME)		0
-#define pci_unmap_addr_set(PTR, ADDR_NAME, VAL)	do{} while(0)
-#define pci_unmap_len(PTR, LEN_NAME)		0
-#define pci_unmap_len_set(PTR, LEN_NAME, VAL)	do{} while(0)
-#endif
-
-
-#if (LINUX_VERSION_CODE < 0x02032b)
-/*
- * SoftNet
- *
- * For pre-softnet kernels we need to tell the upper layer not to
- * re-enter start_xmit() while we are in there. However softnet
- * guarantees not to enter while we are in there so there is no need
- * to do the netif_stop_queue() dance unless the transmit queue really
- * gets stuck. This should also improve performance according to tests
- * done by Aman Singla.
- */
-#define dev_kfree_skb_irq(a)			dev_kfree_skb(a)
-#define netif_wake_queue(dev)			clear_bit(0, &dev->tbusy)
-#define netif_stop_queue(dev)			set_bit(0, &dev->tbusy)
-#define late_stop_netif_stop_queue(dev)		do{} while(0)
-#define early_stop_netif_stop_queue(dev)	test_and_set_bit(0,&dev->tbusy)
-#define early_stop_netif_wake_queue(dev)	netif_wake_queue(dev)
-
-static inline void netif_start_queue(struct net_device *dev)
-{
-	dev->tbusy = 0;
-	dev->interrupt = 0;
-	dev->start = 1;
-}
-
-#define ace_mark_net_bh()			mark_bh(NET_BH)
-#define netif_queue_stopped(dev)		dev->tbusy
-#define netif_running(dev)			dev->start
-#define ace_if_down(dev)			do{dev->start = 0;} while(0)
-
-#define tasklet_struct				tq_struct
-static inline void tasklet_schedule(struct tasklet_struct *tasklet)
-{
-	queue_task(tasklet, &tq_immediate);
-	mark_bh(IMMEDIATE_BH);
-}
-
-static inline void tasklet_init(struct tasklet_struct *tasklet,
-				void (*func)(unsigned long),
-				unsigned long data)
-{
-	tasklet->next = NULL;
-	tasklet->sync = 0;
-	tasklet->routine = (void (*)(void *))func;
-	tasklet->data = (void *)data;
-}
-#define tasklet_kill(tasklet)			do{} while(0)
-#else
-#define late_stop_netif_stop_queue(dev)		netif_stop_queue(dev)
-#define early_stop_netif_stop_queue(dev)	0
-#define early_stop_netif_wake_queue(dev)	do{} while(0)
-#define ace_mark_net_bh()			do{} while(0)
-#define ace_if_down(dev)			do{} while(0)
-#endif
-
-#if (LINUX_VERSION_CODE >= 0x02031b)
-#define NEW_NETINIT
-#define ACE_PROBE_ARG				void
-#else
-#define ACE_PROBE_ARG				struct net_device *dev
-#endif
-
-#ifndef min_t
-#define min_t(type,a,b)	(((a)<(b))?(a):(b))
-#endif
-
-#ifndef ARCH_HAS_PREFETCHW
-#ifndef prefetchw
-#define prefetchw(x)				do{} while(0)
-#endif
+#ifndef offset_in_page
+#define offset_in_page(ptr)	((unsigned long)(ptr) & ~PAGE_MASK)
 #endif
 
 #define ACE_MAX_MOD_PARMS	8
@@ -604,11 +429,9 @@
 static int probed __initdata = 0;
 
 
-int __devinit acenic_probe (ACE_PROBE_ARG)
+static int __init acenic_probe(void)
 {
-#ifdef NEW_NETINIT
 	struct net_device *dev;
-#endif
 	struct ace_private *ap;
 	struct pci_dev *pdev = NULL;
 	int boards_found = 0;
@@ -844,7 +667,6 @@
 }
 
 
-#ifdef MODULE
 MODULE_AUTHOR("Jes Sorensen <jes@trained-monkey.org>");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("AceNIC/3C985/GA620 Gigabit Ethernet driver");
@@ -862,7 +684,6 @@
 MODULE_PARM_DESC(rx_coal_tick, "AceNIC/3C985/GA620 max clock ticks to wait from first rx descriptor arrives");
 MODULE_PARM_DESC(max_rx_desc, "AceNIC/3C985/GA620 max number of receive descriptors to wait");
 MODULE_PARM_DESC(tx_ratio, "AceNIC/3C985/GA620 ratio of NIC memory used for TX/RX descriptors (range 0-63)");
-#endif
 
 
 static void __exit ace_module_cleanup(void)
@@ -962,39 +783,8 @@
 	}
 }
 
-
-int __init ace_module_init(void)
-{
-	int status;
-
-	root_dev = NULL;
-
-#ifdef NEW_NETINIT
-	status = acenic_probe();
-#else
-	status = acenic_probe(NULL);
-#endif
-	return status;
-}
-
-
-#if (LINUX_VERSION_CODE < 0x02032a)
-#ifdef MODULE
-int init_module(void)
-{
-	return ace_module_init();
-}
-
-
-void cleanup_module(void)
-{
-	ace_module_cleanup();
-}
-#endif
-#else
-module_init(ace_module_init);
+module_init(acenic_probe);
 module_exit(ace_module_cleanup);
-#endif
 
 
 static void ace_free_descriptors(struct net_device *dev)
@@ -2642,8 +2432,6 @@
 
 	netif_start_queue(dev);
 
-	ACE_MOD_INC_USE_COUNT;
-
 	/*
 	 * Setup the bottom half rx ring refill handler
 	 */
@@ -2660,8 +2448,6 @@
 	unsigned long flags;
 	short i;
 
-	ace_if_down(dev);
-
 	/*
 	 * Without (or before) releasing irq and stopping hardware, this
 	 * is an absolute non-sense, by the way. It will be reset instantly
@@ -2733,7 +2519,6 @@
 	ace_unmask_irq(dev);
 	local_irq_restore(flags);
 
-	ACE_MOD_DEC_USE_COUNT;
 	return 0;
 }
 
@@ -2789,12 +2574,6 @@
 	struct ace_regs *regs = ap->regs;
 	struct tx_desc *desc;
 	u32 idx, flagsize;
-
- 	/*
-	 * This only happens with pre-softnet, ie. 2.2.x kernels.
- 	 */
-	if (early_stop_netif_stop_queue(dev))
- 		return 1;
 
 restart:
 	idx = ap->tx_prd;
