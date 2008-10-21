From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Tue, 21 Oct 2008 02:18:51 -0400
Message-ID: <20081021061851.GA6293@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:51881 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751694AbYJUGSx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 02:18:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


BIG FAT WARNING:  This requires upstream's PCIE_LINK_STATE_L0S from
include/linux/pci-aspm.h in order to build properly.  It should build
if you pull the latest Linus tree into net-2.6, to update net-2.6.

Please pull from 'davem-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-fixes

to receive the following updates:

 drivers/net/Kconfig             |    7 ++-
 drivers/net/ax88796.c           |    6 +-
 drivers/net/cxgb3/l2t.c         |    1 +
 drivers/net/dm9000.c            |    9 ---
 drivers/net/ehea/ehea.h         |    2 +-
 drivers/net/ehea/ehea_main.c    |   25 +++++---
 drivers/net/ehea/ehea_qmr.c     |  131 ++++++++++++++++++++++++++++++---------
 drivers/net/ehea/ehea_qmr.h     |    2 +
 drivers/net/gianfar.c           |   24 +++++--
 drivers/net/igb/igb_main.c      |   59 ++++++++++++-----
 drivers/net/myri10ge/myri10ge.c |    6 ++-
 drivers/net/r8169.c             |   38 +++++++++---
 drivers/net/smc911x.c           |    2 +-
 drivers/net/smc911x.h           |    6 +-
 14 files changed, 227 insertions(+), 91 deletions(-)

Alexander Duyck (1):
      igb: fix tx data corruption with transition to L0s on 82575

Atsushi Nemoto (1):
      net: Make SMC91X selectable on other MIPS boards

Brice Goglin (1):
      myri10ge: disable NAPI on failure to setup the interface

Bryan Wu (1):
      netdev: DM9000: remove BLACKFIN hacking in DM9000 netdev driver

Dmitry Baryshkov (1):
      SMC911x: unbreak PXA builds

Francois Romieu (2):
      r8169: verbose mac address init
      r8169: checks against wrong mac addresse init

Hannes Hering (1):
      ehea: Fix memory hotplug support

Jeff Kirsher (1):
      igb: add IGB_DCA instead of selecting INTEL_IOATDMA

Roland Dreier (1):
      cxgb3: Fix kernel crash caused by uninitialized l2t_entry.arpq

roel kluin (2):
      gianfar: fix handle errors returned by platform_get_irq*()
      AX88796: ax_probe() fix irq assignment

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index ad301ac..c7f020c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -888,7 +888,7 @@ config SMC91X
 	select CRC32
 	select MII
 	depends on ARM || REDWOOD_5 || REDWOOD_6 || M32R || SUPERH || \
-		SOC_AU1X00 || BLACKFIN || MN10300
+		MIPS || BLACKFIN || MN10300
 	help
 	  This is a driver for SMC's 91x series of Ethernet chipsets,
 	  including the SMC91C94 and the SMC91C111. Say Y if you want it
@@ -2003,6 +2003,11 @@ config IGB_LRO
 
 	  If in doubt, say N.
 
+config IGB_DCA
+	bool "Enable DCA"
+	default y
+	depends on IGB && DCA && !(IGB=y && DCA=m)
+
 source "drivers/net/ixp2000/Kconfig"
 
 config MYRI_SBUS
diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index 4207d6e..9a314d8 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -838,12 +838,12 @@ static int ax_probe(struct platform_device *pdev)
 
 	/* find the platform resources */
 
-	dev->irq  = platform_get_irq(pdev, 0);
-	if (dev->irq < 0) {
+	ret  = platform_get_irq(pdev, 0);
+	if (ret < 0) {
 		dev_err(&pdev->dev, "no IRQ specified\n");
-		ret = -ENXIO;
 		goto exit_mem;
 	}
+	dev->irq = ret;
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (res == NULL) {
diff --git a/drivers/net/cxgb3/l2t.c b/drivers/net/cxgb3/l2t.c
index 4407ac9..ff1611f 100644
--- a/drivers/net/cxgb3/l2t.c
+++ b/drivers/net/cxgb3/l2t.c
@@ -431,6 +431,7 @@ struct l2t_data *t3_init_l2t(unsigned int l2t_capacity)
 	for (i = 0; i < l2t_capacity; ++i) {
 		d->l2tab[i].idx = i;
 		d->l2tab[i].state = L2T_STATE_UNUSED;
+		__skb_queue_head_init(&d->l2tab[i].arpq);
 		spin_lock_init(&d->l2tab[i].lock);
 		atomic_set(&d->l2tab[i].refcnt, 0);
 	}
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index f42c23f..5a9083e 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -47,15 +47,6 @@
 #define CARDNAME	"dm9000"
 #define DRV_VERSION	"1.31"
 
-#ifdef CONFIG_BLACKFIN
-#define readsb	insb
-#define readsw	insw
-#define readsl	insl
-#define writesb	outsb
-#define writesw	outsw
-#define writesl	outsl
-#endif
-
 /*
  * Transmit timeout, default 5 seconds.
  */
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 5524271..82dd1a8 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0093"
+#define DRV_VERSION	"EHEA_0094"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index b70c531..422fcb9 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -2863,7 +2863,7 @@ static void ehea_rereg_mrs(struct work_struct *work)
 	struct ehea_adapter *adapter;
 
 	mutex_lock(&dlpar_mem_lock);
-	ehea_info("LPAR memory enlarged - re-initializing driver");
+	ehea_info("LPAR memory changed - re-initializing driver");
 
 	list_for_each_entry(adapter, &adapter_list, list)
 		if (adapter->active_ports) {
@@ -2900,13 +2900,6 @@ static void ehea_rereg_mrs(struct work_struct *work)
 			}
 		}
 
-	ehea_destroy_busmap();
-	ret = ehea_create_busmap();
-	if (ret) {
-		ehea_error("creating ehea busmap failed");
-		goto out;
-	}
-
 	clear_bit(__EHEA_STOP_XFER, &ehea_driver_flags);
 
 	list_for_each_entry(adapter, &adapter_list, list)
@@ -3519,9 +3512,21 @@ void ehea_crash_handler(void)
 static int ehea_mem_notifier(struct notifier_block *nb,
                              unsigned long action, void *data)
 {
+	struct memory_notify *arg = data;
 	switch (action) {
-	case MEM_OFFLINE:
-		ehea_info("memory has been removed");
+	case MEM_CANCEL_OFFLINE:
+		ehea_info("memory offlining canceled");
+		/* Readd canceled memory block */
+	case MEM_ONLINE:
+		ehea_info("memory is going online");
+		if (ehea_add_sect_bmap(arg->start_pfn, arg->nr_pages))
+			return NOTIFY_BAD;
+		ehea_rereg_mrs(NULL);
+		break;
+	case MEM_GOING_OFFLINE:
+		ehea_info("memory is going offline");
+		if (ehea_rem_sect_bmap(arg->start_pfn, arg->nr_pages))
+			return NOTIFY_BAD;
 		ehea_rereg_mrs(NULL);
 		break;
 	default:
diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ehea/ehea_qmr.c
index db8a925..9b61dc9 100644
--- a/drivers/net/ehea/ehea_qmr.c
+++ b/drivers/net/ehea/ehea_qmr.c
@@ -567,7 +567,7 @@ static inline int ehea_calc_index(unsigned long i, unsigned long s)
 static inline int ehea_init_top_bmap(struct ehea_top_bmap *ehea_top_bmap,
 				     int dir)
 {
-	if(!ehea_top_bmap->dir[dir]) {
+	if (!ehea_top_bmap->dir[dir]) {
 		ehea_top_bmap->dir[dir] =
 			kzalloc(sizeof(struct ehea_dir_bmap), GFP_KERNEL);
 		if (!ehea_top_bmap->dir[dir])
@@ -578,7 +578,7 @@ static inline int ehea_init_top_bmap(struct ehea_top_bmap *ehea_top_bmap,
 
 static inline int ehea_init_bmap(struct ehea_bmap *ehea_bmap, int top, int dir)
 {
-	if(!ehea_bmap->top[top]) {
+	if (!ehea_bmap->top[top]) {
 		ehea_bmap->top[top] =
 			kzalloc(sizeof(struct ehea_top_bmap), GFP_KERNEL);
 		if (!ehea_bmap->top[top])
@@ -587,53 +587,124 @@ static inline int ehea_init_bmap(struct ehea_bmap *ehea_bmap, int top, int dir)
 	return ehea_init_top_bmap(ehea_bmap->top[top], dir);
 }
 
-static int ehea_create_busmap_callback(unsigned long pfn,
-				       unsigned long nr_pages, void *arg)
-{
-	unsigned long i, mr_len, start_section, end_section;
-	start_section = (pfn * PAGE_SIZE) / EHEA_SECTSIZE;
-	end_section = start_section + ((nr_pages * PAGE_SIZE) / EHEA_SECTSIZE);
-	mr_len = *(unsigned long *)arg;
+static DEFINE_MUTEX(ehea_busmap_mutex);
+static unsigned long ehea_mr_len;
 
-	if (!ehea_bmap)
-		ehea_bmap = kzalloc(sizeof(struct ehea_bmap), GFP_KERNEL);
-	if (!ehea_bmap)
-		return -ENOMEM;
+#define EHEA_BUSMAP_ADD_SECT 1
+#define EHEA_BUSMAP_REM_SECT 0
 
-	for (i = start_section; i < end_section; i++) {
-		int ret;
-		int top, dir, idx;
-		u64 vaddr;
+static void ehea_rebuild_busmap(void)
+{
+	u64 vaddr = EHEA_BUSMAP_START;
+	int top, dir, idx;
+
+	for (top = 0; top < EHEA_MAP_ENTRIES; top++) {
+		struct ehea_top_bmap *ehea_top;
+		int valid_dir_entries = 0;
 
-		top = ehea_calc_index(i, EHEA_TOP_INDEX_SHIFT);
-		dir = ehea_calc_index(i, EHEA_DIR_INDEX_SHIFT);
+		if (!ehea_bmap->top[top])
+			continue;
+		ehea_top = ehea_bmap->top[top];
+		for (dir = 0; dir < EHEA_MAP_ENTRIES; dir++) {
+			struct ehea_dir_bmap *ehea_dir;
+			int valid_entries = 0;
 
-		ret = ehea_init_bmap(ehea_bmap, top, dir);
-		if(ret)
-			return ret;
+			if (!ehea_top->dir[dir])
+				continue;
+			valid_dir_entries++;
+			ehea_dir = ehea_top->dir[dir];
+			for (idx = 0; idx < EHEA_MAP_ENTRIES; idx++) {
+				if (!ehea_dir->ent[idx])
+					continue;
+				valid_entries++;
+				ehea_dir->ent[idx] = vaddr;
+				vaddr += EHEA_SECTSIZE;
+			}
+			if (!valid_entries) {
+				ehea_top->dir[dir] = NULL;
+				kfree(ehea_dir);
+			}
+		}
+		if (!valid_dir_entries) {
+			ehea_bmap->top[top] = NULL;
+			kfree(ehea_top);
+		}
+	}
+}
 
-		idx = i & EHEA_INDEX_MASK;
-		vaddr = EHEA_BUSMAP_START + mr_len + i * EHEA_SECTSIZE;
+static int ehea_update_busmap(unsigned long pfn, unsigned long pgnum, int add)
+{
+	unsigned long i, start_section, end_section;
 
-		ehea_bmap->top[top]->dir[dir]->ent[idx] = vaddr;
+	if (!ehea_bmap) {
+		ehea_bmap = kzalloc(sizeof(struct ehea_bmap), GFP_KERNEL);
+		if (!ehea_bmap)
+			return -ENOMEM;
 	}
 
-	mr_len += nr_pages * PAGE_SIZE;
-	*(unsigned long *)arg = mr_len;
+	start_section = (pfn * PAGE_SIZE) / EHEA_SECTSIZE;
+	end_section = start_section + ((pgnum * PAGE_SIZE) / EHEA_SECTSIZE);
+	/* Mark entries as valid or invalid only; address is assigned later */
+	for (i = start_section; i < end_section; i++) {
+		u64 flag;
+		int top = ehea_calc_index(i, EHEA_TOP_INDEX_SHIFT);
+		int dir = ehea_calc_index(i, EHEA_DIR_INDEX_SHIFT);
+		int idx = i & EHEA_INDEX_MASK;
+		
+		if (add) {
+			int ret = ehea_init_bmap(ehea_bmap, top, dir);
+			if (ret)
+				return ret;
+			flag = 1; /* valid */
+			ehea_mr_len += EHEA_SECTSIZE;
+		} else {
+			if (!ehea_bmap->top[top])
+				continue;
+			if (!ehea_bmap->top[top]->dir[dir])
+				continue;
+			flag = 0; /* invalid */
+			ehea_mr_len -= EHEA_SECTSIZE;
+		}
 
+		ehea_bmap->top[top]->dir[dir]->ent[idx] = flag;
+	}
+	ehea_rebuild_busmap(); /* Assign contiguous addresses for mr */
 	return 0;
 }
 
-static unsigned long ehea_mr_len;
+int ehea_add_sect_bmap(unsigned long pfn, unsigned long nr_pages)
+{
+	int ret;
 
-static DEFINE_MUTEX(ehea_busmap_mutex);
+	mutex_lock(&ehea_busmap_mutex);
+	ret = ehea_update_busmap(pfn, nr_pages, EHEA_BUSMAP_ADD_SECT);
+	mutex_unlock(&ehea_busmap_mutex);
+	return ret;
+}
+
+int ehea_rem_sect_bmap(unsigned long pfn, unsigned long nr_pages)
+{
+	int ret;
+
+	mutex_lock(&ehea_busmap_mutex);
+	ret = ehea_update_busmap(pfn, nr_pages, EHEA_BUSMAP_REM_SECT);
+	mutex_unlock(&ehea_busmap_mutex);
+	return ret;
+}
+
+static int ehea_create_busmap_callback(unsigned long pfn,
+				       unsigned long nr_pages, void *arg)
+{
+	return ehea_update_busmap(pfn, nr_pages, EHEA_BUSMAP_ADD_SECT);
+}
 
 int ehea_create_busmap(void)
 {
 	int ret;
+
 	mutex_lock(&ehea_busmap_mutex);
 	ehea_mr_len = 0;
-	ret = walk_memory_resource(0, 1ULL << MAX_PHYSMEM_BITS, &ehea_mr_len,
+	ret = walk_memory_resource(0, 1ULL << MAX_PHYSMEM_BITS, NULL,
 				   ehea_create_busmap_callback);
 	mutex_unlock(&ehea_busmap_mutex);
 	return ret;
diff --git a/drivers/net/ehea/ehea_qmr.h b/drivers/net/ehea/ehea_qmr.h
index 0bb6f92..1e58dc0 100644
--- a/drivers/net/ehea/ehea_qmr.h
+++ b/drivers/net/ehea/ehea_qmr.h
@@ -378,6 +378,8 @@ int ehea_rem_mr(struct ehea_mr *mr);
 
 void ehea_error_data(struct ehea_adapter *adapter, u64 res_handle);
 
+int ehea_add_sect_bmap(unsigned long pfn, unsigned long nr_pages);
+int ehea_rem_sect_bmap(unsigned long pfn, unsigned long nr_pages);
 int ehea_create_busmap(void);
 void ehea_destroy_busmap(void);
 u64 ehea_map_vaddr(void *caddr);
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index b5bb7ae..64b2011 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -161,7 +161,7 @@ static int gfar_probe(struct platform_device *pdev)
 	struct gfar_private *priv = NULL;
 	struct gianfar_platform_data *einfo;
 	struct resource *r;
-	int err = 0;
+	int err = 0, irq;
 	DECLARE_MAC_BUF(mac);
 
 	einfo = (struct gianfar_platform_data *) pdev->dev.platform_data;
@@ -187,15 +187,25 @@ static int gfar_probe(struct platform_device *pdev)
 
 	/* fill out IRQ fields */
 	if (einfo->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
-		priv->interruptTransmit = platform_get_irq_byname(pdev, "tx");
-		priv->interruptReceive = platform_get_irq_byname(pdev, "rx");
-		priv->interruptError = platform_get_irq_byname(pdev, "error");
-		if (priv->interruptTransmit < 0 || priv->interruptReceive < 0 || priv->interruptError < 0)
+		irq = platform_get_irq_byname(pdev, "tx");
+		if (irq < 0)
+			goto regs_fail;
+		priv->interruptTransmit = irq;
+
+		irq = platform_get_irq_byname(pdev, "rx");
+		if (irq < 0)
+			goto regs_fail;
+		priv->interruptReceive = irq;
+
+		irq = platform_get_irq_byname(pdev, "error");
+		if (irq < 0)
 			goto regs_fail;
+		priv->interruptError = irq;
 	} else {
-		priv->interruptTransmit = platform_get_irq(pdev, 0);
-		if (priv->interruptTransmit < 0)
+		irq = platform_get_irq(pdev, 0);
+		if (irq < 0)
 			goto regs_fail;
+		priv->interruptTransmit = irq;
 	}
 
 	/* get a pointer to the register memory */
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 93d02ef..2bd3629 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -41,7 +41,7 @@
 #include <linux/delay.h>
 #include <linux/interrupt.h>
 #include <linux/if_ether.h>
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 #include <linux/dca.h>
 #endif
 #include "igb.h"
@@ -106,11 +106,11 @@ static irqreturn_t igb_msix_other(int irq, void *);
 static irqreturn_t igb_msix_rx(int irq, void *);
 static irqreturn_t igb_msix_tx(int irq, void *);
 static int igb_clean_rx_ring_msix(struct napi_struct *, int);
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 static void igb_update_rx_dca(struct igb_ring *);
 static void igb_update_tx_dca(struct igb_ring *);
 static void igb_setup_dca(struct igb_adapter *);
-#endif /* CONFIG_DCA */
+#endif /* CONFIG_IGB_DCA */
 static bool igb_clean_tx_irq(struct igb_ring *);
 static int igb_poll(struct napi_struct *, int);
 static bool igb_clean_rx_irq_adv(struct igb_ring *, int *, int);
@@ -131,7 +131,7 @@ static int igb_suspend(struct pci_dev *, pm_message_t);
 static int igb_resume(struct pci_dev *);
 #endif
 static void igb_shutdown(struct pci_dev *);
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 static int igb_notify_dca(struct notifier_block *, unsigned long, void *);
 static struct notifier_block dca_notifier = {
 	.notifier_call	= igb_notify_dca,
@@ -207,7 +207,7 @@ static int __init igb_init_module(void)
 	global_quad_port_a = 0;
 
 	ret = pci_register_driver(&igb_driver);
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 	dca_register_notify(&dca_notifier);
 #endif
 	return ret;
@@ -223,7 +223,7 @@ module_init(igb_init_module);
  **/
 static void __exit igb_exit_module(void)
 {
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 	dca_unregister_notify(&dca_notifier);
 #endif
 	pci_unregister_driver(&igb_driver);
@@ -966,10 +966,11 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	struct net_device *netdev;
 	struct igb_adapter *adapter;
 	struct e1000_hw *hw;
+	struct pci_dev *us_dev;
 	const struct e1000_info *ei = igb_info_tbl[ent->driver_data];
 	unsigned long mmio_start, mmio_len;
-	int i, err, pci_using_dac;
-	u16 eeprom_data = 0;
+	int i, err, pci_using_dac, pos;
+	u16 eeprom_data = 0, state = 0;
 	u16 eeprom_apme_mask = IGB_EEPROM_APME;
 	u32 part_num;
 	int bars, need_ioport;
@@ -1004,6 +1005,28 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		}
 	}
 
+	/* 82575 requires that the pci-e link partner disable the L0s state */
+	switch (pdev->device) {
+	case E1000_DEV_ID_82575EB_COPPER:
+	case E1000_DEV_ID_82575EB_FIBER_SERDES:
+	case E1000_DEV_ID_82575GB_QUAD_COPPER:
+		us_dev = pdev->bus->self;
+		pos = pci_find_capability(us_dev, PCI_CAP_ID_EXP);
+		if (pos) {
+			pci_read_config_word(us_dev, pos + PCI_EXP_LNKCTL,
+			                     &state);
+			state &= ~PCIE_LINK_STATE_L0S;
+			pci_write_config_word(us_dev, pos + PCI_EXP_LNKCTL,
+			                      state);
+			printk(KERN_INFO "Disabling ASPM L0s upstream switch "
+			       "port %x:%x.%x\n", us_dev->bus->number,
+			       PCI_SLOT(us_dev->devfn),
+			       PCI_FUNC(us_dev->devfn));
+		}
+	default:
+		break;
+	}
+
 	err = pci_request_selected_regions(pdev, bars, igb_driver_name);
 	if (err)
 		goto err_pci_reg;
@@ -1237,7 +1260,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_register;
 
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 	if ((adapter->flags & IGB_FLAG_HAS_DCA) &&
 	    (dca_add_requester(&pdev->dev) == 0)) {
 		adapter->flags |= IGB_FLAG_DCA_ENABLED;
@@ -1311,7 +1334,7 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct igb_adapter *adapter = netdev_priv(netdev);
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 	struct e1000_hw *hw = &adapter->hw;
 #endif
 
@@ -1323,7 +1346,7 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 
 	flush_scheduled_work();
 
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 	if (adapter->flags & IGB_FLAG_DCA_ENABLED) {
 		dev_info(&pdev->dev, "DCA disabled\n");
 		dca_remove_requester(&pdev->dev);
@@ -3271,7 +3294,7 @@ static irqreturn_t igb_msix_tx(int irq, void *data)
 	struct igb_adapter *adapter = tx_ring->adapter;
 	struct e1000_hw *hw = &adapter->hw;
 
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 		igb_update_tx_dca(tx_ring);
 #endif
@@ -3323,14 +3346,14 @@ static irqreturn_t igb_msix_rx(int irq, void *data)
 	if (netif_rx_schedule_prep(adapter->netdev, &rx_ring->napi))
 		__netif_rx_schedule(adapter->netdev, &rx_ring->napi);
 
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 		igb_update_rx_dca(rx_ring);
 #endif
 		return IRQ_HANDLED;
 }
 
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 static void igb_update_rx_dca(struct igb_ring *rx_ring)
 {
 	u32 dca_rxctrl;
@@ -3450,7 +3473,7 @@ static int igb_notify_dca(struct notifier_block *nb, unsigned long event,
 
 	return ret_val ? NOTIFY_BAD : NOTIFY_DONE;
 }
-#endif /* CONFIG_DCA */
+#endif /* CONFIG_IGB_DCA */
 
 /**
  * igb_intr_msi - Interrupt Handler
@@ -3529,13 +3552,13 @@ static int igb_poll(struct napi_struct *napi, int budget)
 	int tx_clean_complete, work_done = 0;
 
 	/* this poll routine only supports one tx and one rx queue */
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 		igb_update_tx_dca(&adapter->tx_ring[0]);
 #endif
 	tx_clean_complete = igb_clean_tx_irq(&adapter->tx_ring[0]);
 
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 		igb_update_rx_dca(&adapter->rx_ring[0]);
 #endif
@@ -3563,7 +3586,7 @@ static int igb_clean_rx_ring_msix(struct napi_struct *napi, int budget)
 	struct net_device *netdev = adapter->netdev;
 	int work_done = 0;
 
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 		igb_update_rx_dca(rx_ring);
 #endif
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index a9aebad..b1556b2 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.4.3-1.369"
+#define MYRI10GE_VERSION_STR "1.4.3-1.371"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -2497,6 +2497,10 @@ static int myri10ge_open(struct net_device *dev)
 	return 0;
 
 abort_with_rings:
+	while (slice) {
+		slice--;
+		napi_disable(&mgp->ss[slice].napi);
+	}
 	for (i = 0; i < mgp->num_slices; i++)
 		myri10ge_free_rings(&mgp->ss[i]);
 
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c821da2..2b4e975 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -81,6 +81,10 @@ static const int multicast_filter_limit = 32;
 #define RTL8169_TX_TIMEOUT	(6*HZ)
 #define RTL8169_PHY_TIMEOUT	(10*HZ)
 
+#define RTL_EEPROM_SIG		cpu_to_le32(0x8129)
+#define RTL_EEPROM_SIG_MASK	cpu_to_le32(0xffff)
+#define RTL_EEPROM_SIG_ADDR	0x0000
+
 /* write/read MMIO register */
 #define RTL_W8(reg, val8)	writeb ((val8), ioaddr + (reg))
 #define RTL_W16(reg, val16)	writew ((val16), ioaddr + (reg))
@@ -1944,14 +1948,15 @@ static void rtl_init_mac_address(struct rtl8169_private *tp,
 				 void __iomem *ioaddr)
 {
 	struct pci_dev *pdev = tp->pci_dev;
-	u8 cfg1;
 	int vpd_cap;
+	__le32 sig;
 	u8 mac[8];
-	DECLARE_MAC_BUF(buf);
+	u8 cfg1;
 
 	cfg1 = RTL_R8(Config1);
 	if (!(cfg1  & VPD)) {
-		dprintk("VPD access not enabled, enabling\n");
+		if (netif_msg_probe(tp))
+			dev_info(&pdev->dev, "VPD access disabled, enabling\n");
 		RTL_W8(Cfg9346, Cfg9346_Unlock);
 		RTL_W8(Config1, cfg1 | VPD);
 		RTL_W8(Cfg9346, Cfg9346_Lock);
@@ -1961,7 +1966,16 @@ static void rtl_init_mac_address(struct rtl8169_private *tp,
 	if (!vpd_cap)
 		return;
 
-	/* MAC address is stored in EEPROM at offset 0x0e
+	if (rtl_eeprom_read(pdev, vpd_cap, RTL_EEPROM_SIG_ADDR, &sig) < 0)
+		return;
+
+	if ((sig & RTL_EEPROM_SIG_MASK) != RTL_EEPROM_SIG) {
+		dev_info(&pdev->dev, "Missing EEPROM signature: %08x\n", sig);
+		return;
+	}
+
+	/*
+	 * MAC address is stored in EEPROM at offset 0x0e
 	 * Realtek says: "The VPD address does not have to be a DWORD-aligned
 	 * address as defined in the PCI 2.2 Specifications, but the VPD data
 	 * is always consecutive 4-byte data starting from the VPD address
@@ -1969,14 +1983,22 @@ static void rtl_init_mac_address(struct rtl8169_private *tp,
 	 */
 	if (rtl_eeprom_read(pdev, vpd_cap, 0x000e, (__le32*)&mac[0]) < 0 ||
 	    rtl_eeprom_read(pdev, vpd_cap, 0x0012, (__le32*)&mac[4]) < 0) {
-		dprintk("Reading MAC address from EEPROM failed\n");
+		if (netif_msg_probe(tp)) {
+			dev_warn(&pdev->dev,
+				 "reading MAC address from EEPROM failed\n");
+		}
 		return;
 	}
 
-	dprintk("MAC address found in EEPROM: %s\n", print_mac(buf, mac));
+	if (netif_msg_probe(tp)) {
+		DECLARE_MAC_BUF(buf);
+
+		dev_info(&pdev->dev, "MAC address found in EEPROM: %s\n",
+			 print_mac(buf, mac));
+	}
 
-	/* Write MAC address */
-	rtl_rar_set(tp, mac);
+	if (is_valid_ether_addr(mac))
+		rtl_rar_set(tp, mac);
 }
 
 static int __devinit
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 8aa7460..ec32b5d 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -1242,7 +1242,7 @@ smc911x_rx_dma_irq(int dma, void *data)
 	netif_rx(skb);
 
 	spin_lock_irqsave(&lp->lock, flags);
-	pkts = (SMC_GET_RX_FIFO_INF() & RX_FIFO_INF_RXSUSED_) >> 16;
+	pkts = (SMC_GET_RX_FIFO_INF(lp) & RX_FIFO_INF_RXSUSED_) >> 16;
 	if (pkts != 0) {
 		smc911x_rcv(dev);
 	}else {
diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
index bf6240f..cc7d85b 100644
--- a/drivers/net/smc911x.h
+++ b/drivers/net/smc911x.h
@@ -50,6 +50,10 @@
 #define SMC_DYNAMIC_BUS_CONFIG
 #endif
 
+#ifdef SMC_USE_PXA_DMA
+#define SMC_USE_DMA
+#endif
+
 /* store this information for the driver.. */
 struct smc911x_local {
 	/*
@@ -196,8 +200,6 @@ static inline void SMC_outsl(struct smc911x_local *lp, int reg,
 
 
 #ifdef SMC_USE_PXA_DMA
-#define SMC_USE_DMA
-
 /*
  * Define the request and free functions
  * These are unfortunately architecture specific as no generic allocation
