From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [fore200e] 0.3e version (1 of 2)
Date: Fri, 23 Apr 2004 17:01:44 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404232101.i3NL1hGG002420@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

dave,

this is an update for the fore200e driver in the 2.4
kernels.  part 2 of 2 of this patches makes tasklet
use configurable.  please apply to the 2.4 kernel.

thanks!

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1331  -> 1.1331.3.1
#	drivers/atm/fore200e.h	1.1     -> 1.2    
#	drivers/atm/fore200e.c	1.10    -> 1.11   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/03/30	chas@relax.cmf.nrl.navy.mil	1.1331.3.1
# [ATM]: [fore200e] 0.3e version by Christophe Lizzi (lizzi@cnam.fr)
# --------------------------------------------
#
diff -Nru a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
--- a/drivers/atm/fore200e.c	Fri Apr 16 10:44:36 2004
+++ b/drivers/atm/fore200e.c	Fri Apr 16 10:44:36 2004
@@ -2,7 +2,7 @@
   $Id: fore200e.c,v 1.5 2000/04/14 10:10:34 davem Exp $
 
   A FORE Systems 200E-series driver for ATM on Linux.
-  Christophe Lizzi (lizzi@cnam.fr), October 1999-March 2000.
+  Christophe Lizzi (lizzi@cnam.fr), October 1999-March 2003.
 
   Based on the PCA-200E driver from Uwe Dannowski (Uwe.Dannowski@inf.tu-dresden.de).
 
@@ -34,6 +34,8 @@
 #include <linux/sched.h>
 #include <linux/interrupt.h>
 #include <linux/bitops.h>
+#include <linux/pci.h>
+#include <linux/module.h>
 #include <linux/atmdev.h>
 #include <linux/sonet.h>
 #include <linux/atm_suni.h>
@@ -46,7 +48,6 @@
 #include <asm/byteorder.h>
 #include <asm/uaccess.h>
 #include <asm/atomic.h>
-#include <linux/pci.h>
 
 #ifdef CONFIG_ATM_FORE200E_SBA
 #include <asm/idprom.h>
@@ -56,25 +57,33 @@
 #include <asm/pgtable.h>
 #endif
 
-#include <linux/module.h>
+#if 0 /* defer interrupt work to a tasklet */
+#define FORE200E_USE_TASKLET
+#endif
 
-#include "fore200e.h"
-#include "suni.h"
+#if 0 /* enable the debugging code of the buffer supply queues */
+#define FORE200E_BSQ_DEBUG
+#endif
 
-#if 1   /* ensure correct handling of 52-byte AAL0 SDUs used by atmdump-like apps */
+#if 1 /* ensure correct handling of 52-byte AAL0 SDUs expected by atmdump-like apps */
 #define FORE200E_52BYTE_AAL0_SDU
 #endif
 
-#define FORE200E_VERSION "0.2d"
+#include "fore200e.h"
+#include "suni.h"
 
+#define FORE200E_VERSION "0.3e"
 
 #define FORE200E         "fore200e: "
 
+#if 0 /* override .config */
+#define CONFIG_ATM_FORE200E_DEBUG 1
+#endif
 #if defined(CONFIG_ATM_FORE200E_DEBUG) && (CONFIG_ATM_FORE200E_DEBUG > 0)
 #define DPRINTK(level, format, args...)  do { if (CONFIG_ATM_FORE200E_DEBUG >= (level)) \
-                                                  printk(FORE200E format, ##args); } while(0)
+                                                  printk(FORE200E format, ##args); } while (0)
 #else
-#define DPRINTK(level, format, args...)  while(0)
+#define DPRINTK(level, format, args...)  do {} while (0)
 #endif
 
 
@@ -85,18 +94,28 @@
 
 #define FORE200E_INDEX(virt_addr, type, index)     (&((type *)(virt_addr))[ index ])
 
-#define FORE200E_NEXT_ENTRY(index, modulo)    (index = ++(index) % (modulo))
+#define FORE200E_NEXT_ENTRY(index, modulo)         (index = ++(index) % (modulo))
 
 
 #define MSECS(ms)  (((ms)*HZ/1000)+1)
 
 
+#if 1
+#define ASSERT(expr)     if (!(expr)) { \
+                             printk(FORE200E "assertion failed! %s[%d]: %s\n", \
+			            __FUNCTION__, __LINE__, #expr); \
+                             panic(FORE200E "%s", __FUNCTION__); \
+                         }
+#else
+#define ASSERT(expr)     do {} while (0)
+#endif
+
+
 extern const struct atmdev_ops   fore200e_ops;
 extern const struct fore200e_bus fore200e_bus[];
 
 static struct fore200e* fore200e_boards = NULL;
 
-
 #ifdef MODULE
 MODULE_AUTHOR("Christophe Lizzi - credits to Uwe Dannowski and Heikki Vatiainen");
 MODULE_DESCRIPTION("FORE Systems 200E-series ATM driver - version " FORE200E_VERSION);
@@ -225,29 +244,6 @@
 }
 
 
-
-#if 0 /* currently unused */
-static int
-fore200e_checkup(struct fore200e* fore200e)
-{
-    u32 hb1, hb2;
-
-    hb1 = fore200e->bus->read(&fore200e->cp_queues->heartbeat);
-    fore200e_spin(10);
-    hb2 = fore200e->bus->read(&fore200e->cp_queues->heartbeat);
-    
-    if (hb2 <= hb1) {
-	printk(FORE200E "device %s heartbeat is not counting upwards, hb1 = %x; hb2 = %x\n",
-	       fore200e->name, hb1, hb2);
-	return -EIO;
-    }
-    printk(FORE200E "device %s heartbeat is ok\n", fore200e->name);
-    
-    return 0;
-}
-#endif 
-
-
 static void
 fore200e_spin(int msecs)
 {
@@ -444,7 +440,6 @@
 }
 
 
-
 #ifdef CONFIG_ATM_FORE200E_PCA
 
 static u32 fore200e_pca_read(volatile u32* addr)
@@ -501,20 +496,16 @@
 fore200e_pca_dma_chunk_alloc(struct fore200e* fore200e, struct chunk* chunk,
 			     int size, int nbr, int alignment)
 {
-#if defined(__sparc_v9__)
     /* returned chunks are page-aligned */
+    chunk->alloc_size = size * nbr;
     chunk->alloc_addr = pci_alloc_consistent((struct pci_dev*)fore200e->bus_dev,
 					     chunk->alloc_size,
 					     &chunk->dma_addr);
     
-    if (chunk->alloc_addr == NULL || chunk->dma_addr == 0)
+    if ((chunk->alloc_addr == NULL) || (chunk->dma_addr == 0))
 	return -ENOMEM;
 
     chunk->align_addr = chunk->alloc_addr;
-#else
-    if (fore200e_chunk_alloc(fore200e, chunk, size * nbr, alignment, FORE200E_DMA_BIDIRECTIONAL) < 0)
-	return -ENOMEM;
-#endif
     
     return 0;
 }
@@ -525,14 +516,10 @@
 static void
 fore200e_pca_dma_chunk_free(struct fore200e* fore200e, struct chunk* chunk)
 {
-#if defined(__sparc_v9__)
     pci_free_consistent((struct pci_dev*)fore200e->bus_dev,
 			chunk->alloc_size,
 			chunk->alloc_addr,
 			chunk->dma_addr);
-#else
-    fore200e_chunk_free(fore200e, chunk);
-#endif
 }
 
 
@@ -540,7 +527,15 @@
 fore200e_pca_irq_check(struct fore200e* fore200e)
 {
     /* this is a 1 bit register */
-    return readl(fore200e->regs.pca.psr);
+    int irq_posted = readl(fore200e->regs.pca.psr);
+
+#if defined(CONFIG_ATM_FORE200E_DEBUG) && (CONFIG_ATM_FORE200E_DEBUG == 2)
+    if (irq_posted && (readl(fore200e->regs.pca.hcr) & PCA200E_HCR_OUTFULL)) {
+	DPRINTK(2,"FIFO OUT full, device %d\n", fore200e->atm_dev->number);
+    }
+#endif
+
+    return irq_posted;
 }
 
 
@@ -574,7 +569,7 @@
 
     DPRINTK(1, "device %s mapped to 0x%p\n", fore200e->name, fore200e->virt_base);
 
-    /* gain access to the PCA-200E specific registers  */
+    /* gain access to the PCA specific registers  */
     fore200e->regs.pca.hcr = (u32*)(fore200e->virt_base + PCA200E_HCR_OFFSET);
     fore200e->regs.pca.imr = (u32*)(fore200e->virt_base + PCA200E_IMR_OFFSET);
     fore200e->regs.pca.psr = (u32*)(fore200e->virt_base + PCA200E_PSR_OFFSET);
@@ -589,8 +584,6 @@
 {
     DPRINTK(2, "device %s being unmapped from memory\n", fore200e->name);
 
-    /* XXX iounmap() does nothing on PowerPC (at least in 2.2.12 and 2.3.41),
-       this leads to a kernel panic if the module is loaded and unloaded several times */
     if (fore200e->virt_base != NULL)
 	iounmap(fore200e->virt_base);
 }
@@ -600,7 +593,7 @@
 fore200e_pca_configure(struct fore200e* fore200e)
 {
     struct pci_dev* pci_dev = (struct pci_dev*)fore200e->bus_dev;
-    u8              master_ctrl;
+    u8              master_ctrl, latency;
 
     DPRINTK(2, "device %s being configured\n", fore200e->name);
 
@@ -609,21 +602,29 @@
 	return -EIO;
     }
 
-	pci_read_config_byte(pci_dev, PCA200E_PCI_MASTER_CTRL, &master_ctrl);
+    pci_read_config_byte(pci_dev, PCA200E_PCI_MASTER_CTRL, &master_ctrl);
 
     master_ctrl = master_ctrl
-#if 0
-	| PCA200E_CTRL_DIS_CACHE_RD
-        | PCA200E_CTRL_DIS_WRT_INVAL
-#endif
 #if defined(__BIG_ENDIAN)
 	/* request the PCA board to convert the endianess of slave RAM accesses */
 	| PCA200E_CTRL_CONVERT_ENDIAN
 #endif
+#if 0
+        | PCA200E_CTRL_DIS_CACHE_RD
+        | PCA200E_CTRL_DIS_WRT_INVAL
+        | PCA200E_CTRL_ENA_CONT_REQ_MODE
+        | PCA200E_CTRL_2_CACHE_WRT_INVAL
+#endif
 	| PCA200E_CTRL_LARGE_PCI_BURSTS;
     
     pci_write_config_byte(pci_dev, PCA200E_PCI_MASTER_CTRL, master_ctrl);
 
+    /* raise latency from 32 (default) to 192, as this seems to prevent NIC
+       lockups (under heavy rx loads) due to continuous 'FIFO OUT full' condition.
+       this may impact the performances of other PCI devices on the same bus, though */
+    latency = 192;
+    pci_write_config_byte(pci_dev, PCI_LATENCY_TIMER, latency);
+
     fore200e->state = FORE200E_STATE_CONFIGURE;
     return 0;
 }
@@ -657,11 +658,7 @@
     fore200e->bus       = bus;
     fore200e->bus_dev   = pci_dev;    
     fore200e->irq       = pci_dev->irq;
-    fore200e->phys_base = pci_resource_start (pci_dev, 0);
-
-#if defined(__powerpc__)
-    fore200e->phys_base += KERNELBASE;
-#endif
+    fore200e->phys_base = pci_resource_start(pci_dev, 0);
 
     sprintf(fore200e->name, "%s-%d", bus->model_name, index - 1);
 
@@ -729,8 +726,6 @@
 #endif /* CONFIG_ATM_FORE200E_PCA */
 
 
-
-
 #ifdef CONFIG_ATM_FORE200E_SBA
 
 static u32
@@ -792,7 +787,7 @@
 					      chunk->alloc_size,
 					      &chunk->dma_addr);
 
-    if (chunk->alloc_addr == NULL || chunk->dma_addr == 0)
+    if ((chunk->alloc_addr == NULL) || (chunk->dma_addr == 0))
 	return -ENOMEM;
 
     chunk->align_addr = chunk->alloc_addr;
@@ -851,8 +846,7 @@
     struct sbus_dev* sbus_dev = (struct sbus_dev*)fore200e->bus_dev;
     unsigned int bursts;
 
-    /* gain access to the SBA-200E specific registers  */
-    
+    /* gain access to the SBA specific registers  */
     fore200e->regs.sba.hcr = (u32*)sbus_ioremap(&sbus_dev->resource[0], 0, SBA200E_HCR_LENGTH, "SBA HCR");
     fore200e->regs.sba.bsr = (u32*)sbus_ioremap(&sbus_dev->resource[1], 0, SBA200E_BSR_LENGTH, "SBA BSR");
     fore200e->regs.sba.isr = (u32*)sbus_ioremap(&sbus_dev->resource[2], 0, SBA200E_ISR_LENGTH, "SBA ISR");
@@ -873,17 +867,6 @@
     if (sbus_can_dma_64bit(sbus_dev))
 	sbus_set_sbus64(sbus_dev, bursts);
 
-#if 0
-    if (bursts & DMA_BURST16)
-	fore200e->bus->write(SBA200E_BSR_BURST16, fore200e->regs.sba.bsr);
-    else
-    if (bursts & DMA_BURST8)
-       fore200e->bus->write(SBA200E_BSR_BURST8, fore200e->regs.sba.bsr);
-    else
-    if (bursts & DMA_BURST4)
-        fore200e->bus->write(SBA200E_BSR_BURST4, fore200e->regs.sba.bsr);
-#endif
-
     fore200e->state = FORE200E_STATE_MAP;
     return 0;
 }
@@ -928,13 +911,11 @@
     return NULL;
     
   found:
-#if 1
     if (sbus_dev->num_registers != 4) {
 	printk(FORE200E "this %s device has %d instead of 4 registers\n",
 	       bus->model_name, sbus_dev->num_registers);
 	return NULL;
     }
-#endif
 
     fore200e = fore200e_kmalloc(sizeof(struct fore200e), GFP_KERNEL);
     if (fore200e == NULL)
@@ -987,46 +968,143 @@
 
 
 static void
-fore200e_irq_tx(struct fore200e* fore200e)
+fore200e_tx_irq(struct fore200e* fore200e)
 {
-    struct host_txq_entry* entry;
-    int i;
-    
-    entry = fore200e->host_txq.host_entry;
+    struct host_txq*        txq = &fore200e->host_txq;
+    struct host_txq_entry*  entry;
+    struct atm_vcc*         vcc;
+    struct fore200e_vc_map* vc_map;
 
-    for (i = 0; i < QUEUE_SIZE_TX; i++) {
+    if (fore200e->host_txq.txing == 0)
+	return;
+
+    for (;;) {
+	
+	entry = &txq->host_entry[ txq->tail ];
 
-	if (*entry->status & STATUS_COMPLETE) {
+        if ((*entry->status & STATUS_COMPLETE) == 0) {
+	    break;
+	}
 
-	    DPRINTK(3, "TX COMPLETED: entry = %p, vcc = %p, skb = %p\n", entry, entry->vcc, entry->skb);
+	DPRINTK(3, "TX COMPLETED: entry = %p [tail = %d], vc_map = %p, skb = %p\n", 
+		entry, txq->tail, entry->vc_map, entry->skb);
 
-	    /* free copy of misaligned data */
-	    if (entry->data)
-		kfree(entry->data);
+	/* free copy of misaligned data */
+	if (entry->data)
+	    kfree(entry->data);
+	
+	/* remove DMA mapping */
+	fore200e->bus->dma_unmap(fore200e, entry->tpd->tsd[ 0 ].buffer, entry->tpd->tsd[ 0 ].length,
+				 FORE200E_DMA_TODEVICE);
 
-	    /* remove DMA mapping */
-	    fore200e->bus->dma_unmap(fore200e, entry->tpd->tsd[ 0 ].buffer, entry->tpd->tsd[ 0 ].length,
-				     FORE200E_DMA_TODEVICE);
+	vc_map = entry->vc_map;
 
-	    /* notify tx completion */
-	    if (entry->vcc->pop)
-		entry->vcc->pop(entry->vcc, entry->skb);
-	    else
-		dev_kfree_skb_irq(entry->skb);
+	/* vcc closed since the time the entry was submitted for tx? */
+	if ((vc_map->vcc == NULL) ||
+	    (test_bit(ATM_VF_READY, &vc_map->vcc->flags) == 0)) {
 
-	    /* check error condition */
-	    if (*entry->status & STATUS_ERROR)
-		atomic_inc(&entry->vcc->stats->tx_err);
-	    else
-		atomic_inc(&entry->vcc->stats->tx);
+	    DPRINTK(1, "no ready vcc found for PDU sent on device %d\n",
+		    fore200e->atm_dev->number);
 
-	    *entry->status = STATUS_FREE;
-	    
-	    fore200e->host_txq.txing--;
+	    dev_kfree_skb_any(entry->skb);
+	}
+	else {
+	    ASSERT(vc_map->vcc);
+
+	    /* vcc closed then immediately re-opened? */
+	    if (vc_map->incarn != entry->incarn) {
+
+		/* when a vcc is closed, some PDUs may be still pending in the tx queue.
+		   if the same vcc is immediately re-opened, those pending PDUs must
+		   not be popped after the completion of their emission, as they refer
+		   to the prior incarnation of that vcc. otherwise, vcc->sk->wmem_alloc
+		   would be decremented by the size of the (unrelated) skb, possibly
+		   leading to a negative sk->wmem_alloc count, ultimately freezing the vcc.
+		   we thus bind the tx entry to the current incarnation of the vcc
+		   when the entry is submitted for tx. When the tx later completes,
+		   if the incarnation number of the tx entry does not match the one
+		   of the vcc, then this implies that the vcc has been closed then re-opened.
+		   we thus just drop the skb here. */
+
+		DPRINTK(1, "vcc closed-then-re-opened; dropping PDU sent on device %d\n",
+			fore200e->atm_dev->number);
+
+		dev_kfree_skb_any(entry->skb);
+	    }
+	    else {
+		vcc = vc_map->vcc;
+		ASSERT(vcc);
+
+		/* notify tx completion */
+		if (vcc->pop) {
+		    vcc->pop(vcc, entry->skb);
+		}
+		else {
+		    dev_kfree_skb_any(entry->skb);
+		}
+#if 1
+		/* race fixed by the above incarnation mechanism, but... */
+		if (atomic_read(&vcc->sk->wmem_alloc) < 0) {
+		    atomic_set(&vcc->sk->wmem_alloc, 0);
+		}
+#endif
+		/* check error condition */
+		if (*entry->status & STATUS_ERROR)
+		    atomic_inc(&vcc->stats->tx_err);
+		else
+		    atomic_inc(&vcc->stats->tx);
+	    }
+	}
+
+	*entry->status = STATUS_FREE;
+
+	fore200e->host_txq.txing--;
+
+	FORE200E_NEXT_ENTRY(txq->tail, QUEUE_SIZE_TX);
+    }
+}
+
+
+#ifdef FORE200E_BSQ_DEBUG
+int bsq_audit(int where, struct host_bsq* bsq, int scheme, int magn)
+{
+    struct buffer* buffer;
+    int count = 0;
+
+    buffer = bsq->freebuf;
+    while (buffer) {
+
+	if (buffer->supplied) {
+	    printk(FORE200E "bsq_audit(%d): queue %d.%d, buffer %ld supplied but in free list!\n",
+		   where, scheme, magn, buffer->index);
+	}
+
+	if (buffer->magn != magn) {
+	    printk(FORE200E "bsq_audit(%d): queue %d.%d, buffer %ld, unexpected magn = %d\n",
+		   where, scheme, magn, buffer->index, buffer->magn);
+	}
+
+	if (buffer->scheme != scheme) {
+	    printk(FORE200E "bsq_audit(%d): queue %d.%d, buffer %ld, unexpected scheme = %d\n",
+		   where, scheme, magn, buffer->index, buffer->scheme);
+	}
+
+	if ((buffer->index < 0) || (buffer->index >= fore200e_rx_buf_nbr[ scheme ][ magn ])) {
+	    printk(FORE200E "bsq_audit(%d): queue %d.%d, out of range buffer index = %ld !\n",
+		   where, scheme, magn, buffer->index);
 	}
-	entry++;
+
+	count++;
+	buffer = buffer->next;
+    }
+
+    if (count != bsq->freebuf_count) {
+	printk(FORE200E "bsq_audit(%d): queue %d.%d, %d bufs in free list, but freebuf_count = %d\n",
+	       where, scheme, magn, count, bsq->freebuf_count);
     }
+    return 0;
 }
+#endif
 
 
 static void
@@ -1043,28 +1121,42 @@
 
 	    bsq = &fore200e->host_bsq[ scheme ][ magn ];
 
-	    if (fore200e_rx_buf_nbr[ scheme ][ magn ] - bsq->count > RBD_BLK_SIZE) {
+#ifdef FORE200E_BSQ_DEBUG
+	    bsq_audit(1, bsq, scheme, magn);
+#endif
+	    while (bsq->freebuf_count >= RBD_BLK_SIZE) {
 
-		DPRINTK(2, "supplying rx buffers to queue %d / %d, count = %d\n",
-			scheme, magn, bsq->count);
+		DPRINTK(2, "supplying %d rx buffers to queue %d / %d, freebuf_count = %d\n",
+			RBD_BLK_SIZE, scheme, magn, bsq->freebuf_count);
 
 		entry = &bsq->host_entry[ bsq->head ];
-		
-		FORE200E_NEXT_ENTRY(bsq->head, QUEUE_SIZE_BS);
 
 		for (i = 0; i < RBD_BLK_SIZE; i++) {
 
-		    buffer = &bsq->buffer[ bsq->free ];
-		    
-		    FORE200E_NEXT_ENTRY(bsq->free, fore200e_rx_buf_nbr[ scheme ][ magn ]);
+		    /* take the first buffer in the free buffer list */
+		    buffer = bsq->freebuf;
+		    if (!buffer) {
+			printk(FORE200E "no more free bufs in queue %d.%d, but freebuf_count = %d\n",
+			       scheme, magn, bsq->freebuf_count);
+			return;
+		    }
+		    bsq->freebuf = buffer->next;
 		    
+#ifdef FORE200E_BSQ_DEBUG
+		    if (buffer->supplied)
+			printk(FORE200E "queue %d.%d, buffer %lu already supplied\n",
+			       scheme, magn, buffer->index);
+		    buffer->supplied = 1;
+#endif
 		    entry->rbd_block->rbd[ i ].buffer_haddr = buffer->data.dma_addr;
 		    entry->rbd_block->rbd[ i ].handle       = FORE200E_BUF2HDL(buffer);
 		}
 
-		/* increase the number of supplied rx buffers */
-		bsq->count += RBD_BLK_SIZE;
-		
+		FORE200E_NEXT_ENTRY(bsq->head, QUEUE_SIZE_BS);
+
+ 		/* decrease accordingly the number of free rx buffers */
+		bsq->freebuf_count -= RBD_BLK_SIZE;
+
 		*entry->status = STATUS_PENDING;
 		fore200e->bus->write(entry->rbd_block_dma, &entry->cp_entry->rbd_block_haddr);
 	    }
@@ -1073,33 +1165,9 @@
 }
 
 
-
-static struct atm_vcc* 
-fore200e_find_vcc(struct fore200e* fore200e, struct rpd* rpd)
-{
-    struct sock *s;
-    struct atm_vcc* vcc;
-
-    read_lock(&vcc_sklist_lock);
-    for(s = vcc_sklist; s; s = s->next) {
-	vcc = s->protinfo.af_atm;
-	if (vcc->dev != fore200e->atm_dev)
-		continue;
-	if (vcc->vpi == rpd->atm_header.vpi && vcc->vci == rpd->atm_header.vci) {
-            read_unlock(&vcc_sklist_lock);
-	    return vcc;
-	}
-    }
-    read_unlock(&vcc_sklist_lock);
-
-    return NULL;
-}
-
-
-static void
-fore200e_push_rpd(struct fore200e* fore200e, struct rpd* rpd)
+static int
+fore200e_push_rpd(struct fore200e* fore200e, struct atm_vcc* vcc, struct rpd* rpd)
 {
-    struct atm_vcc*      vcc;
     struct sk_buff*      skb;
     struct buffer*       buffer;
     struct fore200e_vcc* fore200e_vcc;
@@ -1108,15 +1176,10 @@
     u32                  cell_header = 0;
 #endif
 
-    vcc = fore200e_find_vcc(fore200e, rpd);
-    if (vcc == NULL) {
-	
-	printk(FORE200E "no vcc found for PDU received on %d.%d.%d\n",
-	       fore200e->atm_dev->number, rpd->atm_header.vpi, rpd->atm_header.vci);
-	return;
-    }
-
+    ASSERT(vcc);
+    
     fore200e_vcc = FORE200E_VCC(vcc);
+    ASSERT(fore200e_vcc);
 
 #ifdef FORE200E_52BYTE_AAL0_SDU
     if ((vcc->qos.aal == ATM_AAL0) && (vcc->qos.rxtp.max_sdu == ATM_AAL0_SDU)) {
@@ -1136,10 +1199,10 @@
     
     skb = alloc_skb(pdu_len, GFP_ATOMIC);
     if (skb == NULL) {
-	
-	printk(FORE200E "unable to alloc new skb, rx PDU length = %d\n", pdu_len);
+	DPRINTK(2, "unable to alloc new skb, rx PDU length = %d\n", pdu_len);
+
 	atomic_inc(&vcc->stats->rx_drop);
-	return;
+	return -ENOMEM;
     } 
 
     skb->stamp = xtime;
@@ -1161,13 +1224,14 @@
 	
 	memcpy(skb_put(skb, rpd->rsd[ i ].length), buffer->data.align_addr, rpd->rsd[ i ].length);
     }
-    
+
     DPRINTK(3, "rx skb: len = %d, truesize = %d\n", skb->len, skb->truesize);
     
     if (pdu_len < fore200e_vcc->rx_min_pdu)
 	fore200e_vcc->rx_min_pdu = pdu_len;
     if (pdu_len > fore200e_vcc->rx_max_pdu)
 	fore200e_vcc->rx_max_pdu = pdu_len;
+    fore200e_vcc->rx_pdu++;
 
     /* push PDU */
     if (atm_charge(vcc, skb->truesize) == 0) {
@@ -1175,37 +1239,63 @@
 	DPRINTK(2, "receive buffers saturated for %d.%d.%d - PDU dropped\n",
 		vcc->itf, vcc->vpi, vcc->vci);
 
-	dev_kfree_skb_irq(skb);
-	return;
+	dev_kfree_skb_any(skb);
+
+	atomic_inc(&vcc->stats->rx_drop);
+	return -ENOMEM;
     }
 
+    ASSERT(atomic_read(&vcc->sk->wmem_alloc) >= 0);
+
     vcc->push(vcc, skb);
     atomic_inc(&vcc->stats->rx);
+
+    ASSERT(atomic_read(&vcc->sk->wmem_alloc) >= 0);
+
+    return 0;
 }
 
 
 static void
 fore200e_collect_rpd(struct fore200e* fore200e, struct rpd* rpd)
 {
-    struct buffer* buffer;
-    int            i;
+    struct host_bsq* bsq;
+    struct buffer*   buffer;
+    int              i;
     
     for (i = 0; i < rpd->nseg; i++) {
 
 	/* rebuild rx buffer address from rsd handle */
 	buffer = FORE200E_HDL2BUF(rpd->rsd[ i ].handle);
 
-	/* decrease the number of supplied rx buffers */
-	fore200e->host_bsq[ buffer->scheme ][ buffer->magn ].count--;
+	bsq = &fore200e->host_bsq[ buffer->scheme ][ buffer->magn ];
+
+#ifdef FORE200E_BSQ_DEBUG
+	bsq_audit(2, bsq, buffer->scheme, buffer->magn);
+
+	if (buffer->supplied == 0)
+	    printk(FORE200E "queue %d.%d, buffer %ld was not supplied\n",
+		   buffer->scheme, buffer->magn, buffer->index);
+	buffer->supplied = 0;
+#endif
+
+	/* re-insert the buffer into the free buffer list */
+	buffer->next = bsq->freebuf;
+	bsq->freebuf = buffer;
+
+	/* then increment the number of free rx buffers */
+	bsq->freebuf_count++;
     }
 }
 
 
 static void
-fore200e_irq_rx(struct fore200e* fore200e)
+fore200e_rx_irq(struct fore200e* fore200e)
 {
-    struct host_rxq*       rxq = &fore200e->host_rxq;
-    struct host_rxq_entry* entry;
+    struct host_rxq*        rxq = &fore200e->host_rxq;
+    struct host_rxq_entry*  entry;
+    struct atm_vcc*         vcc;
+    struct fore200e_vc_map* vc_map;
 
     for (;;) {
 	
@@ -1215,28 +1305,59 @@
 	if ((*entry->status & STATUS_COMPLETE) == 0)
 	    break;
 
-	FORE200E_NEXT_ENTRY(rxq->head, QUEUE_SIZE_RX);
+	vc_map = FORE200E_VC_MAP(fore200e, entry->rpd->atm_header.vpi, entry->rpd->atm_header.vci);
 
-	if ((*entry->status & STATUS_ERROR) == 0) {
+	if ((vc_map->vcc == NULL) || 
+	    (test_bit(ATM_VF_READY, &vc_map->vcc->flags) == 0)) {
 
-	    fore200e_push_rpd(fore200e, entry->rpd);
+	    DPRINTK(1, "no ready VC found for PDU received on %d.%d.%d\n",
+		    fore200e->atm_dev->number,
+		    entry->rpd->atm_header.vpi, entry->rpd->atm_header.vci);
 	}
 	else {
-	    printk(FORE200E "damaged PDU on %d.%d.%d\n", 
-		   fore200e->atm_dev->number, entry->rpd->atm_header.vpi, entry->rpd->atm_header.vci);
+	    vcc = vc_map->vcc;
+	    ASSERT(vcc);
+
+	    if ((*entry->status & STATUS_ERROR) == 0) {
+
+		fore200e_push_rpd(fore200e, vcc, entry->rpd);
+	    }
+	    else {
+		DPRINTK(2, "damaged PDU on %d.%d.%d\n", 
+			fore200e->atm_dev->number,
+			entry->rpd->atm_header.vpi, entry->rpd->atm_header.vci);
+		atomic_inc(&vcc->stats->rx_err);
+	    }
 	}
 
-	fore200e_collect_rpd(fore200e, entry->rpd);
+	FORE200E_NEXT_ENTRY(rxq->head, QUEUE_SIZE_RX);
 
-	fore200e_supply(fore200e);
+	fore200e_collect_rpd(fore200e, entry->rpd);
 
 	/* rewrite the rpd address to ack the received PDU */
 	fore200e->bus->write(entry->rpd_dma, &entry->cp_entry->rpd_haddr);
 	*entry->status = STATUS_FREE;
+
+	fore200e_supply(fore200e);
     }
 }
 
 
+static void 
+fore200e_irq(struct fore200e* fore200e)
+{
+    unsigned long flags;
+
+    spin_lock_irqsave(&fore200e->q_lock, flags);
+    fore200e_rx_irq(fore200e);
+    spin_unlock_irqrestore(&fore200e->q_lock, flags);
+    
+    spin_lock_irqsave(&fore200e->q_lock, flags);
+    fore200e_tx_irq(fore200e);
+    spin_unlock_irqrestore(&fore200e->q_lock, flags);
+}
+
+
 static void
 fore200e_interrupt(int irq, void* dev, struct pt_regs* regs)
 {
@@ -1244,57 +1365,64 @@
 
     if (fore200e->bus->irq_check(fore200e) == 0) {
 	
-	DPRINTK(3, "unexpected interrupt on device %c\n", fore200e->name[9]);
+	DPRINTK(3, "interrupt NOT triggered by device %d\n", fore200e->atm_dev->number);
 	return;
     }
-    DPRINTK(3, "valid interrupt on device %c\n", fore200e->name[9]);
+    DPRINTK(3, "interrupt triggered by device %d\n", fore200e->atm_dev->number);
 
-    tasklet_schedule(&fore200e->tasklet);
+#ifdef FORE200E_USE_TASKLET
+    tasklet_schedule(&fore200e->tx_tasklet);
+    tasklet_schedule(&fore200e->rx_tasklet);
+#else
+    fore200e_irq(fore200e);
+#endif
     
     fore200e->bus->irq_ack(fore200e);
 }
 
 
+#ifdef FORE200E_USE_TASKLET
 static void
-fore200e_tasklet(unsigned long data)
+fore200e_tx_tasklet(unsigned long data)
 {
     struct fore200e* fore200e = (struct fore200e*) data;
+    unsigned long    flags;
 
-    fore200e_irq_rx(fore200e);
-    
-    if (fore200e->host_txq.txing)
-	fore200e_irq_tx(fore200e);
+    DPRINTK(3, "tx tasklet scheduled for device %d\n", fore200e->atm_dev->number);
+
+    spin_lock_irqsave(&fore200e->q_lock, flags);
+    fore200e_tx_irq(fore200e);
+    spin_unlock_irqrestore(&fore200e->q_lock, flags);
 }
 
 
+fore200e_rx_tasklet(unsigned long data)
+{
+    struct fore200e* fore200e = (struct fore200e*) data;
+    unsigned long    flags;
+
+    DPRINTK(3, "rx tasklet scheduled for device %d\n", fore200e->atm_dev->number);
+
+    spin_lock_irqsave(&fore200e->q_lock, flags);
+    fore200e_rx_irq((struct fore200e*) data);
+    spin_unlock_irqrestore(&fore200e->q_lock, flags);
+}
+#endif
+
 
 static int
 fore200e_select_scheme(struct atm_vcc* vcc)
 {
-    int scheme;
-
-#if 1
-    /* fairly balance VCs over (identical) buffer schemes */
-    scheme =  vcc->vci % 2 ? BUFFER_SCHEME_ONE : BUFFER_SCHEME_TWO;
-#else
-    /* bit 7 of VPI magically selects the second buffer scheme */
-    if (vcc->vpi & (1<<7)) {
-	vcc->vpi &= ((1<<7) - 1);    /* reset the magic bit */
-	scheme = BUFFER_SCHEME_TWO;
-    }
-    else {
-	scheme = BUFFER_SCHEME_ONE;
-    }
-#endif
+    /* fairly balance the VCs over (identical) buffer schemes */
+    int scheme = vcc->vci % 2 ? BUFFER_SCHEME_ONE : BUFFER_SCHEME_TWO;
     
-    DPRINTK(1, "vpvc %d.%d.%d uses the %s buffer scheme\n",
-	    vcc->itf, vcc->vpi, vcc->vci, scheme == BUFFER_SCHEME_ONE ? "first" : "second");
+    DPRINTK(1, "VC %d.%d.%d uses buffer scheme %d\n",
+	    vcc->itf, vcc->vpi, vcc->vci, scheme);
 
     return scheme;
 }
 
 
-
 static int 
 fore200e_activate_vcin(struct fore200e* fore200e, int activate, struct atm_vcc* vcc, int mtu)
 {
@@ -1331,7 +1459,7 @@
 #ifdef FORE200E_52BYTE_AAL0_SDU
 	mtu = 48;
 #endif
-	/* the MTU is unused by the cp, except in the case of AAL0 */
+	/* the MTU is not used by the cp, except in the case of AAL0 */
 	fore200e->bus->write(mtu,                        &entry->cp_entry->cmd.activate_block.mtu);
 	fore200e->bus->write(*(u32*)&vpvc,         (u32*)&entry->cp_entry->cmd.activate_block.vpvc);
 	fore200e->bus->write(*(u32*)&activ_opcode, (u32*)&entry->cp_entry->cmd.activate_block.opcode);
@@ -1346,13 +1474,13 @@
     *entry->status = STATUS_FREE;
 
     if (ok == 0) {
-	printk(FORE200E "unable to %s vpvc %d.%d on device %s\n",
-	       activate ? "open" : "close", vcc->vpi, vcc->vci, fore200e->name);
+	printk(FORE200E "unable to %s VC %d.%d.%d\n",
+	       activate ? "open" : "close", vcc->itf, vcc->vpi, vcc->vci);
 	return -EIO;
     }
 
-    DPRINTK(1, "vpvc %d.%d %sed on device %s\n", vcc->vpi, vcc->vci, 
-	    activate ? "open" : "clos", fore200e->name);
+    DPRINTK(1, "VC %d.%d.%d %sed\n", vcc->itf, vcc->vpi, vcc->vci, 
+	    activate ? "open" : "clos");
 
     return 0;
 }
@@ -1410,7 +1538,7 @@
 {
     if (qos->txtp.max_pcr < ATM_OC3_PCR) {
     
-	/* compute the data cells to idle cells ratio from the PCR */
+	/* compute the data cells to idle cells ratio from the tx PCR */
 	rate->data_cells = qos->txtp.max_pcr * FORE200E_MAX_BACK2BACK_CELLS / ATM_OC3_PCR;
 	rate->idle_cells = FORE200E_MAX_BACK2BACK_CELLS - rate->data_cells;
     }
@@ -1424,21 +1552,38 @@
 static int
 fore200e_open(struct atm_vcc *vcc, short vpi, int vci)
 {
-    struct fore200e*     fore200e = FORE200E_DEV(vcc->dev);
-    struct fore200e_vcc* fore200e_vcc;
-    
-    /* find a free VPI/VCI */
+    struct fore200e*        fore200e = FORE200E_DEV(vcc->dev);
+    struct fore200e_vcc*    fore200e_vcc;
+    struct fore200e_vc_map* vc_map;
+    unsigned long           flags;
+
     fore200e_walk_vccs(vcc, &vpi, &vci);
+	
+    ASSERT((vpi >= 0) && (vpi < 1<<FORE200E_VPI_BITS));
+    ASSERT((vci >= 0) && (vci < 1<<FORE200E_VCI_BITS));
 
-    vcc->vpi = vpi;
-    vcc->vci = vci;
+    spin_lock_irqsave(&fore200e->q_lock, flags);
 
-    /* ressource checking only? */
-    if (vci == ATM_VCI_UNSPEC || vpi == ATM_VPI_UNSPEC)
-	return 0;
+    vc_map = FORE200E_VC_MAP(fore200e, vpi, vci);
+    if (vc_map->vcc) {
 
-    set_bit(ATM_VF_ADDR, &vcc->flags);
-    vcc->itf    = vcc->dev->number;
+	spin_unlock_irqrestore(&fore200e->q_lock, flags);
+
+	printk(FORE200E "VC %d.%d.%d already in use\n",
+	       fore200e->atm_dev->number, vpi, vci);
+
+	return -EINVAL;
+    }
+
+    vc_map->vcc = vcc;
+
+    spin_unlock_irqrestore(&fore200e->q_lock, flags);
+
+    fore200e_vcc = fore200e_kmalloc(sizeof(struct fore200e_vcc), GFP_ATOMIC);
+    if (fore200e_vcc == NULL) {
+	vc_map->vcc = NULL;
+	return -ENOMEM;
+    }
 
     DPRINTK(2, "opening %d.%d.%d:%d QoS = (tx: cl=%s, pcr=%d-%d, cdv=%d, max_sdu=%d; "
 	    "rx: cl=%s, pcr=%d-%d, cdv=%d, max_sdu=%d)\n",
@@ -1448,44 +1593,52 @@
 	    fore200e_traffic_class[ vcc->qos.rxtp.traffic_class ],
 	    vcc->qos.rxtp.min_pcr, vcc->qos.rxtp.max_pcr, vcc->qos.rxtp.max_cdv, vcc->qos.rxtp.max_sdu);
     
+    /* pseudo-CBR bandwidth requested? */
     if ((vcc->qos.txtp.traffic_class == ATM_CBR) && (vcc->qos.txtp.max_pcr > 0)) {
 	
 	down(&fore200e->rate_sf);
 	if (fore200e->available_cell_rate < vcc->qos.txtp.max_pcr) {
 	    up(&fore200e->rate_sf);
+
+	    fore200e_kfree(fore200e_vcc);
+	    vc_map->vcc = NULL;
 	    return -EAGAIN;
 	}
-	/* reserving the pseudo-CBR bandwidth at this point grants us
-	   to reduce the length of the critical section protected
-	   by 'rate_sf'. in counterpart, we have to reset the available
-	   bandwidth if we later encounter an error */
 
+	/* reserve bandwidth */
 	fore200e->available_cell_rate -= vcc->qos.txtp.max_pcr;
 	up(&fore200e->rate_sf);
     }
-    
-    fore200e_vcc = fore200e_kmalloc(sizeof(struct fore200e_vcc), GFP_KERNEL);
-    if (fore200e_vcc == NULL) {
-	down(&fore200e->rate_sf);
-	fore200e->available_cell_rate += vcc->qos.txtp.max_pcr;
-	up(&fore200e->rate_sf);
-	return -ENOMEM;
-    }
+
+    vcc->itf = vcc->dev->number;
+    vcc->vpi = vpi;
+    vcc->vci = vci;
+
+    set_bit(ATM_VF_PARTIAL,&vcc->flags);
+    set_bit(ATM_VF_ADDR, &vcc->flags);
 
     FORE200E_VCC(vcc) = fore200e_vcc;
-    
+
     if (fore200e_activate_vcin(fore200e, 1, vcc, vcc->qos.rxtp.max_sdu) < 0) {
-	kfree(fore200e_vcc);
-	down(&fore200e->rate_sf);
+
+	vc_map->vcc = NULL;
+
+	clear_bit(ATM_VF_ADDR, &vcc->flags);
+	clear_bit(ATM_VF_PARTIAL,&vcc->flags);
+
+	FORE200E_VCC(vcc) = NULL;
+
 	fore200e->available_cell_rate += vcc->qos.txtp.max_pcr;
-	up(&fore200e->rate_sf);
-	return -EBUSY;
+
+	fore200e_kfree(fore200e_vcc);
+	return -EINVAL;
     }
     
     /* compute rate control parameters */
     if ((vcc->qos.txtp.traffic_class == ATM_CBR) && (vcc->qos.txtp.max_pcr > 0)) {
 	
 	fore200e_rate_ctrl(&vcc->qos, &fore200e_vcc->rate);
+	set_bit(ATM_VF_HASQOS, &vcc->flags);
 
 	DPRINTK(3, "tx on %d.%d.%d:%d, tx PCR = %d, rx PCR = %d, data_cells = %u, idle_cells = %u\n",
 		vcc->itf, vcc->vpi, vcc->vci, fore200e_atm2fore_aal(vcc->qos.aal),
@@ -1493,57 +1646,99 @@
 		fore200e_vcc->rate.data_cells, fore200e_vcc->rate.idle_cells);
     }
     
-    fore200e_vcc->tx_min_pdu = fore200e_vcc->rx_min_pdu = 65536;
+    fore200e_vcc->tx_min_pdu = fore200e_vcc->rx_min_pdu = MAX_PDU_SIZE + 1;
     fore200e_vcc->tx_max_pdu = fore200e_vcc->rx_max_pdu = 0;
-    
+    fore200e_vcc->tx_pdu     = fore200e_vcc->rx_pdu     = 0;
+
+    /* new incarnation of the vcc */
+    vc_map->incarn = ++fore200e->incarn_count;
+
+    /* VC unusable before this flag is set */
     set_bit(ATM_VF_READY, &vcc->flags);
+
     return 0;
 }
 
 
-
 static void
 fore200e_close(struct atm_vcc* vcc)
 {
-    struct fore200e* fore200e = FORE200E_DEV(vcc->dev);
-    
+    struct fore200e*        fore200e = FORE200E_DEV(vcc->dev);
+    struct fore200e_vcc*    fore200e_vcc;
+    struct fore200e_vc_map* vc_map;
+    unsigned long           flags;
+
+    ASSERT(vcc);
+    ASSERT((vcc->vpi >= 0) && (vcc->vpi < 1<<FORE200E_VPI_BITS));
+    ASSERT((vcc->vci >= 0) && (vcc->vci < 1<<FORE200E_VCI_BITS));
+
     DPRINTK(2, "closing %d.%d.%d:%d\n", vcc->itf, vcc->vpi, vcc->vci, fore200e_atm2fore_aal(vcc->qos.aal));
-    
+
+    clear_bit(ATM_VF_READY, &vcc->flags);
+
     fore200e_activate_vcin(fore200e, 0, vcc, 0);
-    
-    kfree(FORE200E_VCC(vcc));
-	
+
+    spin_lock_irqsave(&fore200e->q_lock, flags);
+
+    vc_map = FORE200E_VC_MAP(fore200e, vcc->vpi, vcc->vci);
+
+    /* the vc is no longer considered as "in use" by fore200e_open() */
+    vc_map->vcc = NULL;
+
+    vcc->itf = vcc->vci = vcc->vpi = 0;
+
+    fore200e_vcc = FORE200E_VCC(vcc);
+    FORE200E_VCC(vcc) = NULL;
+
+    spin_unlock_irqrestore(&fore200e->q_lock, flags);
+
+    /* release reserved bandwidth, if any */
     if ((vcc->qos.txtp.traffic_class == ATM_CBR) && (vcc->qos.txtp.max_pcr > 0)) {
+
 	down(&fore200e->rate_sf);
 	fore200e->available_cell_rate += vcc->qos.txtp.max_pcr;
 	up(&fore200e->rate_sf);
-    }
 
-    clear_bit(ATM_VF_READY, &vcc->flags);
-}
+	clear_bit(ATM_VF_HASQOS, &vcc->flags);
+    }
 
+    clear_bit(ATM_VF_ADDR, &vcc->flags);
+    clear_bit(ATM_VF_PARTIAL,&vcc->flags);
 
-#if 0
-#define FORE200E_SYNC_SEND    /* wait tx completion before returning */
-#endif
+    ASSERT(fore200e_vcc);
+    fore200e_kfree(fore200e_vcc);
+}
 
 
 static int
 fore200e_send(struct atm_vcc *vcc, struct sk_buff *skb)
 {
-    struct fore200e*       fore200e     = FORE200E_DEV(vcc->dev);
-    struct fore200e_vcc*   fore200e_vcc = FORE200E_VCC(vcc);
-    struct host_txq*       txq          = &fore200e->host_txq;
-    struct host_txq_entry* entry;
-    struct tpd*            tpd;
-    struct tpd_haddr       tpd_haddr;
-    //unsigned long          flags;
-    int                    retry        = CONFIG_ATM_FORE200E_TX_RETRY;
-    int                    tx_copy      = 0;
-    int                    tx_len       = skb->len;
-    u32*                   cell_header  = NULL;
-    unsigned char*         skb_data;
-    int                    skb_len;
+    struct fore200e*        fore200e     = FORE200E_DEV(vcc->dev);
+    struct fore200e_vcc*    fore200e_vcc = FORE200E_VCC(vcc);
+    struct fore200e_vc_map* vc_map;
+    struct host_txq*        txq          = &fore200e->host_txq;
+    struct host_txq_entry*  entry;
+    struct tpd*             tpd;
+    struct tpd_haddr        tpd_haddr;
+    int                     retry        = CONFIG_ATM_FORE200E_TX_RETRY;
+    int                     tx_copy      = 0;
+    int                     tx_len       = skb->len;
+    u32*                    cell_header  = NULL;
+    unsigned char*          skb_data;
+    int                     skb_len;
+    unsigned char*          data;
+    unsigned long           flags;
+
+    ASSERT(vcc);
+    ASSERT(atomic_read(&vcc->sk->wmem_alloc) >= 0);
+    ASSERT(fore200e);
+    ASSERT(fore200e_vcc);
+
+    if (!test_bit(ATM_VF_READY, &vcc->flags)) {
+	DPRINTK(1, "VC %d.%d.%d not ready for tx\n", vcc->itf, vcc->vpi, vcc->vpi);
+	dev_kfree_skb_any(skb);
+	return -EINVAL;
+    }
 
 #ifdef FORE200E_52BYTE_AAL0_SDU
     if ((vcc->qos.aal == ATM_AAL0) && (vcc->qos.txtp.max_sdu == ATM_AAL0_SDU)) {
@@ -1551,7 +1746,7 @@
 	skb_data    = skb->data + 4;    /* skip 4-byte cell header */
 	skb_len     = tx_len = skb->len  - 4;
 
-	DPRINTK(3, "skipping user-supplied cell header 0x%08x", *cell_header);
+	DPRINTK(3, "user-supplied cell header = 0x%08x\n", *cell_header);
     }
     else 
 #endif
@@ -1560,39 +1755,6 @@
 	skb_len  = skb->len;
     }
     
-  retry_here:
-    
-    tasklet_disable(&fore200e->tasklet);
-
-    entry = &txq->host_entry[ txq->head ];
-    
-    if (*entry->status != STATUS_FREE) {
-	
-	/* try to free completed tx queue entries */
-	fore200e_irq_tx(fore200e);
-	
-	if (*entry->status != STATUS_FREE) {
-	    
-	    tasklet_enable(&fore200e->tasklet);
-
-	    /* retry once again? */
-	    if(--retry > 0)
-		goto retry_here;
-	    
-	    atomic_inc(&vcc->stats->tx_err);
-	    
-	    printk(FORE200E "tx queue of device %s is saturated, PDU dropped - heartbeat is %08x\n",
-		   fore200e->name, fore200e->cp_queues->heartbeat);
-	    if (vcc->pop)
-		vcc->pop(vcc, skb);
-	    else
-		dev_kfree_skb(skb);
-	    return -EIO;
-	}
-    }
-
-    tpd = entry->tpd;
-
     if (((unsigned long)skb_data) & 0x3) {
 
 	DPRINTK(2, "misaligned tx PDU on device %s\n", fore200e->name);
@@ -1602,43 +1764,87 @@
 
     if ((vcc->qos.aal == ATM_AAL0) && (skb_len % ATM_CELL_PAYLOAD)) {
 
-	/* this simply NUKES the PCA-200E board */
+	/* this simply NUKES the PCA board */
 	DPRINTK(2, "incomplete tx AAL0 PDU on device %s\n", fore200e->name);
 	tx_copy = 1;
 	tx_len  = ((skb_len / ATM_CELL_PAYLOAD) + 1) * ATM_CELL_PAYLOAD;
     }
     
     if (tx_copy) {
-	
-	entry->data = kmalloc(tx_len, GFP_ATOMIC | GFP_DMA);
-	if (entry->data == NULL) {
-	    
-	    tasklet_enable(&fore200e->tasklet);
-	    if (vcc->pop)
+	data = kmalloc(tx_len, GFP_ATOMIC | GFP_DMA);
+	if (data == NULL) {
+	    if (vcc->pop) {
 		vcc->pop(vcc, skb);
-	    else
-		dev_kfree_skb(skb);
+	    }
+	    else {
+		dev_kfree_skb_any(skb);
+	    }
 	    return -ENOMEM;
 	}
 
-	memcpy(entry->data, skb_data, skb_len);
+	memcpy(data, skb_data, skb_len);
 	if (skb_len < tx_len)
-	    memset(entry->data + skb_len, 0x00, tx_len - skb_len);
-	
-	tpd->tsd[ 0 ].buffer = fore200e->bus->dma_map(fore200e, entry->data, tx_len, FORE200E_DMA_TODEVICE);
+	    memset(data + skb_len, 0x00, tx_len - skb_len);
     }
     else {
-	entry->data = NULL;
-	tpd->tsd[ 0 ].buffer = fore200e->bus->dma_map(fore200e, skb_data, tx_len, FORE200E_DMA_TODEVICE);
+	data = skb_data;
     }
 
+    vc_map = FORE200E_VC_MAP(fore200e, vcc->vpi, vcc->vci);
+    ASSERT(vc_map->vcc == vcc);
+
+  retry_here:
+    
+    spin_lock_irqsave(&fore200e->q_lock, flags);
+
+    entry = &txq->host_entry[ txq->head ];
+    
+    if ((*entry->status != STATUS_FREE) || (txq->txing >= QUEUE_SIZE_TX - 2)) {
+	
+	/* try to free completed tx queue entries */
+	fore200e_tx_irq(fore200e);
+	
+	if (*entry->status != STATUS_FREE) {
+	    
+	    spin_unlock_irqrestore(&fore200e->q_lock, flags);
+
+	    /* retry once again? */
+	    if(--retry > 0) {
+		schedule();
+		goto retry_here;
+	    }
+	    
+	    atomic_inc(&vcc->stats->tx_err);
+	    
+	    fore200e->tx_sat++;
+	    DPRINTK(2, "tx queue of device %s is saturated, PDU dropped - heartbeat is %08x\n",
+		   fore200e->name, fore200e->cp_queues->heartbeat);
+	    if (vcc->pop) {
+		vcc->pop(vcc, skb);
+	    }
+	    else {
+		dev_kfree_skb_any(skb);
+	    }
+
+	    if (tx_copy)
+		kfree(data);
+
+	    return -ENOBUFS;
+	}
+    }
+
+    entry->incarn = vc_map->incarn;
+    entry->vc_map = vc_map;
+    entry->skb    = skb;
+    entry->data   = tx_copy ? data : NULL;
+
+    tpd = entry->tpd;
+    tpd->tsd[ 0 ].buffer = fore200e->bus->dma_map(fore200e, data, tx_len, FORE200E_DMA_TODEVICE);
     tpd->tsd[ 0 ].length = tx_len;
 
     FORE200E_NEXT_ENTRY(txq->head, QUEUE_SIZE_TX);
     txq->txing++;
 
-    tasklet_enable(&fore200e->tasklet);
-
     /* ensure DMA synchronisation */
     fore200e->bus->dma_sync(fore200e, tpd->tsd[ 0 ].buffer, tpd->tsd[ 0 ].length, FORE200E_DMA_TODEVICE);
     
@@ -1650,9 +1856,7 @@
 	fore200e_vcc->tx_min_pdu = skb_len;
     if (skb_len > fore200e_vcc->tx_max_pdu)
 	fore200e_vcc->tx_max_pdu = skb_len;
-    
-    entry->vcc = vcc;
-    entry->skb = skb;
+    fore200e_vcc->tx_pdu++;
 
     /* set tx rate control information */
     tpd->rate.data_cells = fore200e_vcc->rate.data_cells;
@@ -1677,49 +1881,16 @@
     tpd->spec.length = tx_len;
     tpd->spec.nseg   = 1;
     tpd->spec.aal    = fore200e_atm2fore_aal(vcc->qos.aal);
-#ifdef FORE200E_SYNC_SEND
-    tpd->spec.intr   = 0;
-#else
     tpd->spec.intr   = 1;
-#endif
 
-    tpd_haddr.size  = sizeof(struct tpd) / 32;    /* size is expressed in 32 byte blocks */
+    tpd_haddr.size  = sizeof(struct tpd) / (1<<TPD_HADDR_SHIFT);  /* size is expressed in 32 byte blocks */
     tpd_haddr.pad   = 0;
-    tpd_haddr.haddr = entry->tpd_dma >> 5;        /* shift the address, as we are in a bitfield */
+    tpd_haddr.haddr = entry->tpd_dma >> TPD_HADDR_SHIFT;          /* shift the address, as we are in a bitfield */
 
     *entry->status = STATUS_PENDING;
     fore200e->bus->write(*(u32*)&tpd_haddr, (u32*)&entry->cp_entry->tpd_haddr);
 
-
-#ifdef FORE200E_SYNC_SEND
-    {
-	int ok = fore200e_poll(fore200e, entry->status, STATUS_COMPLETE, 10);
-
-	fore200e->bus->dma_unmap(fore200e, entry->tpd->tsd[ 0 ].buffer, entry->tpd->tsd[ 0 ].length,
-				 FORE200E_DMA_TODEVICE);
-	
-	/* free tmp copy of misaligned data */
-	if (entry->data)
-	    kfree(entry->data);
-
-	/* notify tx completion */
-	if (vcc->pop)
-	    vcc->pop(vcc, skb);
-	else
-	    dev_kfree_skb(skb);
-
-	if (ok == 0) {
-	    printk(FORE200E "synchronous tx on %d:%d:%d failed\n", vcc->itf, vcc->vpi, vcc->vci);
-
-	    atomic_inc(&entry->vcc->stats->tx_err);
-	    return -EIO;
-	}
-	atomic_inc(&entry->vcc->stats->tx);
-
-	DPRINTK(3, "synchronous tx on %d:%d:%d succeeded\n", vcc->itf, vcc->vpi, vcc->vci);
-
-    }
-#endif
+    spin_unlock_irqrestore(&fore200e->q_lock, flags);
 
     return 0;
 }
@@ -1740,7 +1911,8 @@
 	    return -ENOMEM;
     }
     
-    stats_dma_addr = fore200e->bus->dma_map(fore200e, fore200e->stats, sizeof(struct stats), FORE200E_DMA_FROMDEVICE);
+    stats_dma_addr = fore200e->bus->dma_map(fore200e, fore200e->stats,
+					    sizeof(struct stats), FORE200E_DMA_FROMDEVICE);
     
     FORE200E_NEXT_ENTRY(cmdq->head, QUEUE_SIZE_CMD);
 
@@ -1769,9 +1941,9 @@
 
 
 static int
-fore200e_getsockopt (struct atm_vcc* vcc, int level, int optname, void* optval, int optlen)
+fore200e_getsockopt(struct atm_vcc* vcc, int level, int optname, void* optval, int optlen)
 {
-    // struct fore200e* fore200e = FORE200E_DEV(vcc->dev);
+    /* struct fore200e* fore200e = FORE200E_DEV(vcc->dev); */
 
     DPRINTK(2, "getsockopt %d.%d.%d, level = %d, optname = 0x%x, optval = 0x%p, optlen = %d\n",
 	    vcc->itf, vcc->vpi, vcc->vci, level, optname, optval, optlen);
@@ -1783,7 +1955,7 @@
 static int
 fore200e_setsockopt(struct atm_vcc* vcc, int level, int optname, void* optval, int optlen)
 {
-    // struct fore200e* fore200e = FORE200E_DEV(vcc->dev);
+    /* struct fore200e* fore200e = FORE200E_DEV(vcc->dev); */
     
     DPRINTK(2, "setsockopt %d.%d.%d, level = %d, optname = 0x%x, optval = 0x%p, optlen = %d\n",
 	    vcc->itf, vcc->vpi, vcc->vci, level, optname, optval, optlen);
@@ -1841,6 +2013,8 @@
     struct oc3_opcode       opcode;
     int                     ok;
 
+    DPRINTK(2, "set OC-3 reg = 0x%02x, value = 0x%02x, mask = 0x%02x\n", reg, value, mask);
+
     FORE200E_NEXT_ENTRY(cmdq->head, QUEUE_SIZE_CMD);
 
     opcode.opcode = OPCODE_SET_OC3;
@@ -1896,7 +2070,7 @@
     }
 
     error = fore200e_set_oc3(fore200e, SUNI_MCT, mct_value, mct_mask);
-    if ( error == 0)
+    if (error == 0)
 	fore200e->loop_mode = loop_mode;
 
     return error;
@@ -1978,6 +2152,11 @@
     struct fore200e_vcc* fore200e_vcc = FORE200E_VCC(vcc);
     struct fore200e*     fore200e     = FORE200E_DEV(vcc->dev);
 
+    if (!test_bit(ATM_VF_READY, &vcc->flags)) {
+	DPRINTK(1, "VC %d.%d.%d not ready for QoS change\n", vcc->itf, vcc->vpi, vcc->vpi);
+	return -EINVAL;
+    }
+
     DPRINTK(2, "change_qos %d.%d.%d, "
 	    "(tx: cl=%s, pcr=%d-%d, cdv=%d, max_sdu=%d; "
 	    "rx: cl=%s, pcr=%d-%d, cdv=%d, max_sdu=%d), flags = 0x%x\n"
@@ -1999,6 +2178,7 @@
 
 	fore200e->available_cell_rate += vcc->qos.txtp.max_pcr;
 	fore200e->available_cell_rate -= qos->txtp.max_pcr;
+
 	up(&fore200e->rate_sf);
 	
 	memcpy(&vcc->qos, qos, sizeof(struct atm_qos));
@@ -2007,6 +2187,7 @@
 	fore200e_rate_ctrl(qos, &fore200e_vcc->rate);
 
 	set_bit(ATM_VF_HASQOS, &vcc->flags);
+
 	return 0;
     }
     
@@ -2027,7 +2208,10 @@
     printk(FORE200E "IRQ %s reserved for device %s\n",
 	   fore200e_irq_itoa(fore200e->irq), fore200e->name);
 
-    tasklet_init(&fore200e->tasklet, fore200e_tasklet, (unsigned long)fore200e);
+#ifdef FORE200E_USE_TASKLET
+    tasklet_init(&fore200e->tx_tasklet, fore200e_tx_tasklet, (unsigned long)fore200e);
+    tasklet_init(&fore200e->rx_tasklet, fore200e_rx_tasklet, (unsigned long)fore200e);
+#endif
 
     fore200e->state = FORE200E_STATE_IRQ;
     return 0;
@@ -2042,6 +2226,7 @@
 
     if (!prom)
 	return -ENOMEM;
+
     ok = fore200e->bus->prom_read(fore200e, prom);
     if (ok < 0) {
 	fore200e_kfree(prom);
@@ -2089,10 +2274,16 @@
 	    if (buffer == NULL)
 		return -ENOMEM;
 
+	    bsq->freebuf = NULL;
+
 	    for (i = 0; i < nbr; i++) {
 
 		buffer[ i ].scheme = scheme;
 		buffer[ i ].magn   = magn;
+#ifdef FORE200E_BSQ_DEBUG
+		buffer[ i ].index  = i;
+		buffer[ i ].supplied = 0;
+#endif
 
 		/* allocate the receive buffer body */
 		if (fore200e_chunk_alloc(fore200e,
@@ -2105,9 +2296,17 @@
 		    
 		    return -ENOMEM;
 		}
+
+		/* insert the buffer into the free buffer list */
+		buffer[ i ].next = bsq->freebuf;
+		bsq->freebuf = &buffer[ i ];
 	    }
-	    /* set next free buffer index */
-	    bsq->free = 0;
+	    /* all the buffers are free, initially */
+	    bsq->freebuf_count = nbr;
+
+#ifdef FORE200E_BSQ_DEBUG
+	    bsq_audit(3, bsq, scheme, magn);
+#endif
 	}
     }
 
@@ -2164,9 +2363,9 @@
 		                     FORE200E_INDEX(bsq->rbd_block.align_addr, struct rbd_block, i);
 		bsq->host_entry[ i ].rbd_block_dma =
 		                     FORE200E_DMA_INDEX(bsq->rbd_block.dma_addr, struct rbd_block, i);
-		bsq->host_entry[ i ].cp_entry      = &cp_entry[ i ];
+		bsq->host_entry[ i ].cp_entry = &cp_entry[ i ];
 		
-		*bsq->host_entry[ i ].status   = STATUS_FREE;
+		*bsq->host_entry[ i ].status = STATUS_FREE;
 		
 		fore200e->bus->write(FORE200E_DMA_INDEX(bsq->status.dma_addr, enum status, i), 
 				     &cp_entry[ i ].status_haddr);
@@ -2293,10 +2492,11 @@
 	   we do not write here the DMA (physical) base address of each tpd into
 	   the related cp resident entry, because the cp relies on this write
 	   operation to detect that a new pdu has been submitted for tx */
-}
+    }
 
-    /* set the head entry of the queue */
+    /* set the head and tail entries of the queue */
     txq->head = 0;
+    txq->tail = 0;
 
     fore200e->state = FORE200E_STATE_INIT_TXQ;
     return 0;
@@ -2315,9 +2515,9 @@
     /* allocate and align the array of status words */
     if (fore200e->bus->dma_chunk_alloc(fore200e,
 				       &cmdq->status,
-				 sizeof(enum status), 
-				 QUEUE_SIZE_CMD,
-				 fore200e->bus->status_alignment) < 0) {
+				       sizeof(enum status), 
+				       QUEUE_SIZE_CMD,
+				       fore200e->bus->status_alignment) < 0) {
 	return -ENOMEM;
     }
     
@@ -2353,12 +2553,6 @@
 {
     struct bs_spec* bs_spec = &fore200e->cp_queues->init.bs_spec[ scheme ][ magn ];
 
-    /* dumb value; the firmware doesn't allow us to activate a VC while
-       selecting a buffer scheme with zero-sized rbd pools */
-
-    if (pool_size == 0)
-	pool_size = 64;
-
     fore200e->bus->write(queue_length,                           &bs_spec->queue_length);
     fore200e->bus->write(fore200e_rx_buf_size[ scheme ][ magn ], &bs_spec->buffer_size);
     fore200e->bus->write(pool_size,                              &bs_spec->pool_size);
@@ -2375,7 +2569,8 @@
     DPRINTK(2, "device %s being initialized\n", fore200e->name);
 
     init_MUTEX(&fore200e->rate_sf);
-    
+    spin_lock_init(&fore200e->q_lock);
+
     cpq = fore200e->cp_queues = (struct cp_queues*) (fore200e->virt_base + FORE200E_CP_QUEUES_OFFSET);
 
     /* enable cp to host interrupts */
@@ -2457,7 +2652,7 @@
 static void __init
 fore200e_monitor_puts(struct fore200e* fore200e, char* str)
 {
-    while(*str) {
+    while (*str) {
 
 	/* the i960 monitor doesn't accept any new character if it has something to say */
 	while (fore200e_monitor_getc(fore200e) >= 0);
@@ -2478,6 +2673,11 @@
 
     DPRINTK(2, "device %s firmware being started\n", fore200e->name);
 
+#if defined(__sparc_v9__)
+    /* reported to be required by SBA cards on some sparc64 hosts */
+    fore200e_spin(100);
+#endif
+
     sprintf(cmd, "\rgo %x\r", le32_to_cpu(fw_header->start_offset));
 
     fore200e_monitor_puts(fore200e, cmd);
@@ -2508,12 +2708,10 @@
     DPRINTK(2, "device %s firmware being loaded at 0x%p (%d words)\n", 
 	    fore200e->name, load_addr, fw_size);
 
-#if 1
     if (le32_to_cpu(fw_header->magic) != FW_HEADER_MAGIC) {
 	printk(FORE200E "corrupted %s firmware image\n", fore200e->bus->model_name);
 	return -ENODEV;
     }
-#endif
 
     for (; fw_size--; fw_data++, load_addr++)
 	fore200e->bus->write(le32_to_cpu(*fw_data), load_addr);
@@ -2540,8 +2738,8 @@
     FORE200E_DEV(atm_dev) = fore200e;
     fore200e->atm_dev = atm_dev;
 
-    atm_dev->ci_range.vpi_bits = 8;
-    atm_dev->ci_range.vci_bits = 10;
+    atm_dev->ci_range.vpi_bits = FORE200E_VPI_BITS;
+    atm_dev->ci_range.vci_bits = FORE200E_VCI_BITS;
 
     fore200e->available_cell_rate = ATM_OC3_PCR;
 
@@ -2610,7 +2808,7 @@
     struct       fore200e*     fore200e;
     int                        index, link;
 
-    printk(FORE200E "FORE Systems 200E-series driver - version " FORE200E_VERSION "\n");
+    printk(FORE200E "FORE Systems 200E-series ATM driver - version " FORE200E_VERSION "\n");
 
     /* for each configured bus interface */
     for (link = 0, bus = fore200e_bus; bus->model_name; bus++) {
@@ -2657,11 +2855,13 @@
 
 
 static int
-fore200e_proc_read(struct atm_dev *dev,loff_t* pos,char* page)
+fore200e_proc_read(struct atm_dev *dev, loff_t* pos, char* page)
 {
-    struct sock *s;
-    struct fore200e* fore200e  = FORE200E_DEV(dev);
-    int              len, left = *pos;
+    struct fore200e*     fore200e  = FORE200E_DEV(dev);
+    struct fore200e_vcc* fore200e_vcc;
+    struct atm_vcc*      vcc;
+    int                  i, len, left = *pos;
+    unsigned long        flags;
 
     if (!left--) {
 
@@ -2694,14 +2894,15 @@
 
     if (!left--)
 	return sprintf(page,
-		       "   supplied small bufs (1):\t%d\n"
-		       "   supplied large bufs (1):\t%d\n"
-		       "   supplied small bufs (2):\t%d\n"
-		       "   supplied large bufs (2):\t%d\n",
-		       fore200e->host_bsq[ BUFFER_SCHEME_ONE ][ BUFFER_MAGN_SMALL ].count,
-		       fore200e->host_bsq[ BUFFER_SCHEME_ONE ][ BUFFER_MAGN_LARGE ].count,
-		       fore200e->host_bsq[ BUFFER_SCHEME_TWO ][ BUFFER_MAGN_SMALL ].count,
-		       fore200e->host_bsq[ BUFFER_SCHEME_TWO ][ BUFFER_MAGN_LARGE ].count);
+		       "   free small bufs, scheme 1:\t%d\n"
+		       "   free large bufs, scheme 1:\t%d\n"
+		       "   free small bufs, scheme 2:\t%d\n"
+		       "   free large bufs, scheme 2:\t%d\n",
+		       fore200e->host_bsq[ BUFFER_SCHEME_ONE ][ BUFFER_MAGN_SMALL ].freebuf_count,
+		       fore200e->host_bsq[ BUFFER_SCHEME_ONE ][ BUFFER_MAGN_LARGE ].freebuf_count,
+		       fore200e->host_bsq[ BUFFER_SCHEME_TWO ][ BUFFER_MAGN_SMALL ].freebuf_count,
+		       fore200e->host_bsq[ BUFFER_SCHEME_TWO ][ BUFFER_MAGN_LARGE ].freebuf_count);
+
     if (!left--) {
 	u32 hb = fore200e->bus->read(&fore200e->cp_queues->heartbeat);
 
@@ -2740,7 +2941,7 @@
 	u32 media_index    = FORE200E_MEDIA_INDEX(fore200e->bus->read(&fore200e->cp_queues->media_type));
 	u32 oc3_index;
 
-	if (media_index < 0 || media_index > 4)
+	if ((media_index < 0) || (media_index > 4))
 	    media_index = 5;
 	
 	switch (fore200e->loop_mode) {
@@ -2887,49 +3088,60 @@
 		       "     large b1:\t\t\t%10u\n"
 		       "     small b2:\t\t\t%10u\n"
 		       "     large b2:\t\t\t%10u\n"
-		       "     RX PDUs:\t\t\t%10u\n",
+		       "     RX PDUs:\t\t\t%10u\n"
+		       "     TX PDUs:\t\t\t%10lu\n",
 		       fore200e_swap(fore200e->stats->aux.small_b1_failed),
 		       fore200e_swap(fore200e->stats->aux.large_b1_failed),
 		       fore200e_swap(fore200e->stats->aux.small_b2_failed),
 		       fore200e_swap(fore200e->stats->aux.large_b2_failed),
-		       fore200e_swap(fore200e->stats->aux.rpd_alloc_failed));
-    
+		       fore200e_swap(fore200e->stats->aux.rpd_alloc_failed),
+                       fore200e->tx_sat);
+
     if (!left--)
 	return sprintf(page,"\n"
 		       " receive carrier:\t\t\t%s\n",
 		       fore200e->stats->aux.receive_carrier ? "ON" : "OFF!");
     
     if (!left--) {
-	struct atm_vcc *vcc;
-	struct fore200e_vcc* fore200e_vcc;
-	
-	len = sprintf(page,"\n"    
-		      " VCCs:\n  address\tVPI.VCI:AAL\t(min/max tx PDU size) (min/max rx PDU size)\n");
-	
-	read_lock(&vcc_sklist_lock);
-	for (s = vcc_sklist; s; s = s->next) {
-	    vcc = s->protinfo.af_atm;
+	return sprintf(page,"\n"    
+		       " VCCs:\n  address   VPI VCI   AAL "
+		       "TX PDUs   TX min/max size  RX PDUs   RX min/max size\n");
+    }
 
-	    if (vcc->dev != fore200e->atm_dev)
-		    continue;
+
+    for (i = 0; i < NBR_CONNECT; i++) {
+
+	vcc = fore200e->vc_map[i].vcc;
+
+	if (vcc == NULL) 
+	    continue;
+
+	spin_lock_irqsave(&fore200e->q_lock, flags);
+
+	if (vcc && test_bit(ATM_VF_READY, &vcc->flags) && !left--) {
 
 	    fore200e_vcc = FORE200E_VCC(vcc);
-	    
-	    len += sprintf(page + len,
-			   "  %x\t%d.%d:%d\t\t(%d/%d)\t(%d/%d)\n",
+	    ASSERT(fore200e_vcc);
+	
+	    len = sprintf(page,
+			   "  %08x  %03d %05d %1d   %09lu %05d/%05d      %09lu %05d/%05d\n",
 			   (u32)(unsigned long)vcc,
 			   vcc->vpi, vcc->vci, fore200e_atm2fore_aal(vcc->qos.aal),
+			   fore200e_vcc->tx_pdu,
 			   fore200e_vcc->tx_min_pdu > 0xFFFF ? 0 : fore200e_vcc->tx_min_pdu,
 			   fore200e_vcc->tx_max_pdu,
+			   fore200e_vcc->rx_pdu,
 			   fore200e_vcc->rx_min_pdu > 0xFFFF ? 0 : fore200e_vcc->rx_min_pdu,
 			   fore200e_vcc->rx_max_pdu
 		);
+
+	    spin_unlock_irqrestore(&fore200e->q_lock, flags);
+	    return len;
 	}
-	read_unlock(&vcc_sklist_lock);
 
-	return len;
+	spin_unlock_irqrestore(&fore200e->q_lock, flags);
     }
-    
+
     return 0;
 }
 
@@ -2966,7 +3178,7 @@
 	send:         fore200e_send,
 	change_qos:   fore200e_change_qos,
 	proc_read:    fore200e_proc_read,
-	owner:        THIS_MODULE,
+	owner:        THIS_MODULE
 };
 
 
@@ -3027,4 +3239,6 @@
     {}
 };
 
+#ifdef MODULE_LICENSE
 MODULE_LICENSE("GPL");
+#endif
diff -Nru a/drivers/atm/fore200e.h b/drivers/atm/fore200e.h
--- a/drivers/atm/fore200e.h	Fri Apr 16 10:44:36 2004
+++ b/drivers/atm/fore200e.h	Fri Apr 16 10:44:36 2004
@@ -23,19 +23,21 @@
 #define BUFFER_S2_SIZE       SMALL_BUFFER_SIZE    /* size of small buffers, scheme 2 */
 #define BUFFER_L2_SIZE       LARGE_BUFFER_SIZE    /* size of large buffers, scheme 2 */
 
-#define BUFFER_S1_NBR        (RBD_BLK_SIZE * 2)
-#define BUFFER_L1_NBR        (RBD_BLK_SIZE * 2)
+#define BUFFER_S1_NBR        (RBD_BLK_SIZE * 6)
+#define BUFFER_L1_NBR        (RBD_BLK_SIZE * 4)
 
-#define BUFFER_S2_NBR        (RBD_BLK_SIZE * 2)
-#define BUFFER_L2_NBR        (RBD_BLK_SIZE * 2)
+#define BUFFER_S2_NBR        (RBD_BLK_SIZE * 6)
+#define BUFFER_L2_NBR        (RBD_BLK_SIZE * 4)
 
 
 #define QUEUE_SIZE_CMD       16	     /* command queue capacity       */
 #define QUEUE_SIZE_RX	     64	     /* receive queue capacity       */
 #define QUEUE_SIZE_TX	     256     /* transmit queue capacity      */
-#define QUEUE_SIZE_BS        16	     /* buffer supply queue capacity */
+#define QUEUE_SIZE_BS        32	     /* buffer supply queue capacity */
 
-#define NBR_CONNECT          1024    /* number of ATM connections     */
+#define FORE200E_VPI_BITS     0
+#define FORE200E_VCI_BITS    10
+#define NBR_CONNECT          (1 << (FORE200E_VPI_BITS + FORE200E_VCI_BITS)) /* number of connections */
 
 
 #define TSD_FIXED            2
@@ -207,6 +209,7 @@
     )
 } tpd_haddr_t;
 
+#define TPD_HADDR_SHIFT 5  /* addr aligned on 32 byte boundary */
 
 /* cp resident transmit queue entry */
 
@@ -517,13 +520,15 @@
 /* host resident transmit queue entry */
 
 typedef struct host_txq_entry {
-    struct cp_txq_entry*   cp_entry;    /* addr of cp resident tx queue entry */
-    enum   status*         status;      /* addr of host resident status       */
-    struct tpd*            tpd;         /* addr of transmit PDU descriptor    */
-    u32                    tpd_dma;     /* DMA address of tpd                 */
-    struct sk_buff*        skb;         /* related skb                        */
-    struct atm_vcc*        vcc;         /* related vcc                        */
-    void*                  data;        /* copy of misaligned data            */
+    struct cp_txq_entry*    cp_entry;    /* addr of cp resident tx queue entry       */
+    enum   status*          status;      /* addr of host resident status             */
+    struct tpd*             tpd;         /* addr of transmit PDU descriptor          */
+    u32                     tpd_dma;     /* DMA address of tpd                       */
+    struct sk_buff*         skb;         /* related skb                              */
+    void*                   data;        /* copy of misaligned data                  */
+    unsigned long           incarn;      /* vc_map incarnation when submitted for tx */
+    struct fore200e_vc_map* vc_map;
+
 } host_txq_entry_t;
 
 
@@ -576,6 +581,10 @@
     enum   buffer_scheme scheme;      /* buffer scheme           */
     enum   buffer_magn   magn;        /* buffer magnitude        */
     struct chunk         data;        /* data buffer             */
+#ifdef FORE200E_BSQ_DEBUG
+    unsigned long        index;       /* buffer # in queue       */
+    int                  supplied;    /* 'buffer supplied' flag  */
+#endif
 } buffer_t;
 
 
@@ -602,6 +611,7 @@
 typedef struct host_txq {
     struct host_txq_entry host_entry[ QUEUE_SIZE_TX ];    /* host resident tx queue entries         */
     int                   head;                           /* head of tx queue                       */
+    int                   tail;                           /* tail of tx queue                       */
     struct chunk          tpd;                            /* array of tpds                          */
     struct chunk          status;                         /* arry of completion status              */
     int                   txing;                          /* number of pending PDUs in tx queue     */
@@ -626,8 +636,8 @@
     struct chunk          rbd_block;                      /* array of rbds                             */
     struct chunk          status;                         /* array of completion status                */
     struct buffer*        buffer;                         /* array of rx buffers                       */
-    int                   free;                           /* index of first free rx buffer             */
-    volatile int          count;                          /* count of supplied rx buffers              */
+    struct buffer*        freebuf;                        /* list of free rx buffers                   */
+    volatile int          freebuf_count;                  /* count of free rx buffers                  */
 } host_bsq_t;
 
 
@@ -846,6 +856,17 @@
 #endif
 
 
+/* vc mapping */
+
+typedef struct fore200e_vc_map {
+    struct atm_vcc* vcc;       /* vcc entry              */
+    unsigned long   incarn;    /* vcc incarnation number */
+} fore200e_vc_map_t;
+
+#define FORE200E_VC_MAP(fore200e, vpi, vci)  \
+        (& (fore200e)->vc_map[ ((vpi) << FORE200E_VCI_BITS) | (vci) ])
+
+
 /* per-device data */
 
 typedef struct fore200e {
@@ -879,20 +900,29 @@
     struct stats*              stats;                  /* last snapshot of the stats         */
     
     struct semaphore           rate_sf;                /* protects rate reservation ops      */
-    struct tasklet_struct      tasklet;                /* performs interrupt work            */
+    spinlock_t                 q_lock;                 /* protects queue ops                 */
+#ifdef FORE200E_USE_TASKLET
+    struct tasklet_struct      tx_tasklet;             /* performs tx interrupt work         */
+    struct tasklet_struct      rx_tasklet;             /* performs rx interrupt work         */
+#endif
+    unsigned long              tx_sat;                 /* tx queue saturation count          */
 
+    unsigned long              incarn_count;
+    struct fore200e_vc_map     vc_map[ NBR_CONNECT ];  /* vc mapping                         */
 } fore200e_t;
 
 
 /* per-vcc data */
 
 typedef struct fore200e_vcc {
-    enum buffer_scheme scheme;        /* rx buffer scheme                   */
-    struct tpd_rate    rate;          /* tx rate control data               */
-    int                rx_min_pdu;    /* size of smallest PDU received      */
-    int                rx_max_pdu;    /* size of largest PDU received       */
-    int                tx_min_pdu;    /* size of smallest PDU transmitted   */
-    int                tx_max_pdu;    /* size of largest PDU transmitted    */
+    enum buffer_scheme     scheme;             /* rx buffer scheme                   */
+    struct tpd_rate        rate;               /* tx rate control data               */
+    int                    rx_min_pdu;         /* size of smallest PDU received      */
+    int                    rx_max_pdu;         /* size of largest PDU received       */
+    int                    tx_min_pdu;         /* size of smallest PDU transmitted   */
+    int                    tx_max_pdu;         /* size of largest PDU transmitted    */
+    unsigned long          tx_pdu;             /* nbr of tx pdus                     */
+    unsigned long          rx_pdu;             /* nbr of rx pdus                     */
 } fore200e_vcc_t;
 
 
