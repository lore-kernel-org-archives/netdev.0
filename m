From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [atmdrvr lanai] PATCH: update to modern DMA/PCI api, etc
Date: Mon, 28 Jul 2003 09:50:35 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307281353.h6SDrHsG009681@ginger.cmf.nrl.navy.mil>
References: <20030728045620.GJ32831@gaz.sfgoth.com>
Reply-To: chas3@users.sourceforge.net
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-reply-to: Your message of "Sun, 27 Jul 2003 21:56:20 PDT."
             <20030728045620.GJ32831@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

dave, please apply the following patch from mitch:

In message <20030728045620.GJ32831@gaz.sfgoth.com>,Mitchell Blank Jr writes:
>This patch updates my lanai driver to use the modern PCI and DMA APIs (along
>with a few other trivial things).  With this patch the driver should work
>on non-i386 platforms - I personally have it working on my sparc64 box now.
>Hopefully that means I'll be able to do some ATM work now.
>
>The patch doesn't remove the MOD_{INC,DEC}_USE_COUNT stuff pending the
>mass-conversion of ATM drivers.
>
>This is versus 2.6.0-test1 but nothing changed in this file for -test2 so it
>will apply cleanly.  Chas - if this looks ok to you please push it upstream.


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1473.1.2 -> 1.1473.1.3
#	 drivers/atm/lanai.c	1.10    -> 1.11   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/07/28	chas@relax.cmf.nrl.navy.mil	1.1473.1.3
# update lanai driver to use the modern PCI and DMA APIs (from mitch@sfgoth.com)
# --------------------------------------------
#
diff -Nru a/drivers/atm/lanai.c b/drivers/atm/lanai.c
--- a/drivers/atm/lanai.c	Mon Jul 28 09:51:13 2003
+++ b/drivers/atm/lanai.c	Mon Jul 28 09:51:13 2003
@@ -1,4 +1,4 @@
-/* lanai.c -- Copyright 1999 by Mitchell Blank Jr <mitch@sfgoth.com>
+/* lanai.c -- Copyright 1999-2003 by Mitchell Blank Jr <mitch@sfgoth.com>
  *
  *  This program is free software; you can redistribute it and/or
  *  modify it under the terms of the GNU General Public License
@@ -55,6 +55,7 @@
  */
 
 /* Version history:
+ *   v.1.00 -- 26-JUL-2003 -- PCI/DMA updates
  *   v.0.02 -- 11-JAN-2000 -- Endian fixes
  *   v.0.01 -- 30-NOV-1999 -- Initial release
  */
@@ -178,7 +179,7 @@
 	printk(KERN_DEBUG DEV_LABEL ": " format, ##args)
 #define APRINTK(truth, format, args...) \
 	do { \
-		if (!(truth)) \
+		if (unlikely(!(truth))) \
 			printk(KERN_ERR DEV_LABEL ": " format, ##args); \
 	} while (0)
 
@@ -215,7 +216,7 @@
 	u32 *start;	/* From get_free_pages */
 	u32 *end;	/* One past last byte */
 	u32 *ptr;	/* Pointer to current host location */
-	int order;	/* log2(size/PAGE_SIZE) */
+	dma_addr_t dmaaddr;
 };
 
 struct lanai_vcc_stats {
@@ -373,89 +374,76 @@
 
 /*
  * Lanai needs DMA buffers aligned to 256 bytes of at least 1024 bytes -
- * we assume that any page allocation will do.  I'm sure this is
- * never going to be a problem, but it's good to document assumtions
+ * usually any page allocation will do.  Just to be safe in case
+ * PAGE_SIZE is insanely tiny, though...
  */
-#if PAGE_SIZE < 1024
-#error PAGE_SIZE too small to support LANAI chipset
-#endif
-/*
- * We also assume that the maximum buffer size will be some number
- * of whole pages, although that wouldn't be too hard to fix
- */
-#if PAGE_SIZE > (128 * 1024)
-#error PAGE_SIZE too large to support LANAI chipset
-#endif
-
-/* Convert a size to "order" for __get_free_pages */
-static int bytes_to_order(int bytes)
-{
-	int order = 0;
-	if (bytes > (128 * 1024))
-		bytes = 128 * 1024;	/* Max buffer size for lanai */
-	while ((PAGE_SIZE << order) < bytes)
-		order++;
-	return order;
-}
+#define LANAI_PAGE_SIZE   ((PAGE_SIZE >= 1024) ? PAGE_SIZE : 1024)
 
 /*
  * Allocate a buffer in host RAM for service list, RX, or TX
- * Returns buf->order<0 if no memory
- * Note that the size will be rounded up to an "order" of pages, and
+ * Returns buf->start==NULL if no memory
+ * Note that the size will be rounded up 2^n bytes, and
  * if we can't allocate that we'll settle for something smaller
  * until minbytes
- *
- * NOTE: buffer must be 32-bit DMA capable - when linux can
- *	 make distinction, this will need tweaking for this
- *	 to work on BIG memory machines.
  */
 static void lanai_buf_allocate(struct lanai_buffer *buf,
-	int bytes, int minbytes)
+	size_t bytes, size_t minbytes, struct pci_dev *pci)
 {
-	unsigned long address;
-	int order = bytes_to_order(bytes);
+	int size;
+
+	if (bytes > (128 * 1024))	/* max lanai buffer size */
+		bytes = 128 * 1024;
+	for (size = LANAI_PAGE_SIZE; size < bytes; size *= 2)
+		;
+	if (minbytes < LANAI_PAGE_SIZE)
+		minbytes = LANAI_PAGE_SIZE;
 	do {
-		address = __get_free_pages(GFP_KERNEL, order);
-		if (address != 0) {	/* Success */
-			bytes = PAGE_SIZE << order;
-			buf->start = buf->ptr = (u32 *) address;
-			buf->end = (u32 *) (address + bytes);
-			memset((void *) address, 0, bytes);
+		/*
+		 * Technically we could use non-consistent mappings for
+		 * everything, but the way the lanai uses DMA memory would
+		 * make that a terrific pain.  This is much simpler.
+		 */
+		buf->start = pci_alloc_consistent(pci, size, &buf->dmaaddr);
+		if (buf->start != NULL) {	/* Success */
+			/* Lanai requires 256-byte alignment of DMA bufs */
+			APRINTK((buf->dmaaddr & ~0xFFFFFF00) == 0,
+			    "bad dmaaddr: 0x%lx\n",
+			    (unsigned long) buf->dmaaddr);
+			buf->ptr = buf->start;
+			buf->end = (u32 *)
+			    (&((unsigned char *) buf->start)[size]);
+			memset(buf->start, 0, size);
 			break;
 		}
-		if ((PAGE_SIZE << --order) < minbytes)
-			order = -1;	/* Too small - give up */
-	} while (order >= 0);
-	buf->order = order;
-}
-
-static inline void lanai_buf_deallocate(struct lanai_buffer *buf)
-{
-	if (buf->order >= 0) {
-		APRINTK(buf->start != 0, "lanai_buf_deallocate: start==0!\n");
-		free_pages((unsigned long) buf->start, buf->order);
-		buf->start = buf->end = buf->ptr = 0;
-	}
+		size /= 2;
+	} while (size >= minbytes);
 }
 
 /* size of buffer in bytes */
-static inline int lanai_buf_size(const struct lanai_buffer *buf)
+static inline size_t lanai_buf_size(const struct lanai_buffer *buf)
 {
 	return ((unsigned long) buf->end) - ((unsigned long) buf->start);
 }
 
-/* size of buffer as "card order" (0=1k .. 7=128k) */
-static inline int lanai_buf_size_cardorder(const struct lanai_buffer *buf)
+static void lanai_buf_deallocate(struct lanai_buffer *buf,
+	struct pci_dev *pci)
 {
-	return buf->order + PAGE_SHIFT - 10;
+	if (buf->start != NULL) {
+		pci_free_consistent(pci, lanai_buf_size(buf),
+		    buf->start, buf->dmaaddr);
+		buf->start = buf->end = buf->ptr = NULL;
+	}
 }
 
-/* DMA-able address for this buffer */
-static unsigned long lanai_buf_dmaaddr(const struct lanai_buffer *buf)
+/* size of buffer as "card order" (0=1k .. 7=128k) */
+static int lanai_buf_size_cardorder(const struct lanai_buffer *buf)
 {
-	unsigned long r = virt_to_bus(buf->start);
-	APRINTK((r & ~0xFFFFFF00) == 0, "bad dmaaddr: 0x%lx\n", (long) r);
-	return r;
+	int order = get_order(lanai_buf_size(buf)) + (PAGE_SHIFT - 10);
+
+	/* This can only happen if PAGE_SIZE is gigantic, but just in case */
+	if (order > 7)
+		order = 7;
+	return order;
 }
 
 /* -------------------- HANDLE BACKLOG_VCCS BITFIELD: */
@@ -492,7 +480,7 @@
 	Reset_Reg		= 0x00,	/* Reset; read for chip type; bits: */
 #define   RESET_GET_BOARD_REV(x)    (((x)>> 0)&0x03)	/* Board revision */
 #define   RESET_GET_BOARD_ID(x)	    (((x)>> 2)&0x03)	/* Board ID */
-#define     BOARD_ID_LANAI256		(0)	/* 25.6M adaptor card */
+#define     BOARD_ID_LANAI256		(0)	/* 25.6M adapter card */
 	Endian_Reg		= 0x04,	/* Endian setting */
 	IntStatus_Reg		= 0x08,	/* Interrupt status */
 	IntStatusMasked_Reg	= 0x0C,	/* Interrupt status (masked) */
@@ -850,7 +838,7 @@
 {
 	u32 addr1;
 	if (lvcc->rx.atmvcc->qos.aal == ATM_AAL5) {
-		unsigned long dmaaddr = lanai_buf_dmaaddr(&lvcc->rx.buf);
+		dma_addr_t dmaaddr = lvcc->rx.buf.dmaaddr;
 		cardvcc_write(lvcc, 0xFFFF, vcc_rxcrc1);
 		cardvcc_write(lvcc, 0xFFFF, vcc_rxcrc2);
 		cardvcc_write(lvcc, 0, vcc_rxwriteptr);
@@ -872,7 +860,7 @@
 
 static void host_vcc_start_tx(const struct lanai_vcc *lvcc)
 {
-	unsigned long dmaaddr = lanai_buf_dmaaddr(&lvcc->tx.buf);
+	dma_addr_t dmaaddr = lvcc->tx.buf.dmaaddr;
 	cardvcc_write(lvcc, 0, vcc_txicg);
 	cardvcc_write(lvcc, 0xFFFF, vcc_txcrc1);
 	cardvcc_write(lvcc, 0xFFFF, vcc_txcrc2);
@@ -971,14 +959,15 @@
 static inline int aal0_buffer_allocate(struct lanai_dev *lanai)
 {
 	DPRINTK("aal0_buffer_allocate: allocating AAL0 RX buffer\n");
-	lanai_buf_allocate(&lanai->aal0buf, AAL0_RX_BUFFER_SIZE, 80);
-	return (lanai->aal0buf.order < 0) ? -ENOMEM : 0;
+	lanai_buf_allocate(&lanai->aal0buf, AAL0_RX_BUFFER_SIZE, 80,
+			   lanai->pci);
+	return (lanai->aal0buf.start == NULL) ? -ENOMEM : 0;
 }
 
 static inline void aal0_buffer_free(struct lanai_dev *lanai)
 {
 	DPRINTK("aal0_buffer_allocate: freeing AAL0 RX buffer\n");
-	lanai_buf_deallocate(&lanai->aal0buf);
+	lanai_buf_deallocate(&lanai->aal0buf, lanai->pci);
 }
 
 /* -------------------- EEPROM UTILITIES: */
@@ -1678,36 +1667,37 @@
 	return lvcc;
 }
 
-static int lanai_get_sized_buffer(int number, struct lanai_buffer *buf,
-	int max_sdu, int multiplier, int min, const char *name)
+static int lanai_get_sized_buffer(struct lanai_dev *lanai,
+	struct lanai_buffer *buf, int max_sdu, int multiplier,
+	int min, const char *name)
 {
 	int size;
 	if (max_sdu < 1)
 		max_sdu = 1;
 	max_sdu = aal5_size(max_sdu);
 	size = (max_sdu + 16) * multiplier + 16;
-	lanai_buf_allocate(buf, size, min);
-	if (buf->order < 0)
+	lanai_buf_allocate(buf, size, min, lanai->pci);
+	if (buf->start == NULL)
 		return -ENOMEM;
 	if (lanai_buf_size(buf) < size)
 		printk(KERN_WARNING DEV_LABEL "(itf %d): wanted %d bytes "
-		    "for %s buffer, got only %d\n", number, size, name,
+		    "for %s buffer, got only %d\n", lanai->number, size, name,
 		    lanai_buf_size(buf));
 	DPRINTK("Allocated %d byte %s buffer\n", lanai_buf_size(buf), name);
 	return 0;
 }
 
 /* Setup a RX buffer for a currently unbound AAL5 vci */
-static inline int lanai_setup_rx_vci_aal5(int number, struct lanai_vcc *lvcc,
-	const struct atm_qos *qos)
+static inline int lanai_setup_rx_vci_aal5(struct lanai_dev *lanai,
+	struct lanai_vcc *lvcc, const struct atm_qos *qos)
 {
-	return lanai_get_sized_buffer(number, &lvcc->rx.buf,
+	return lanai_get_sized_buffer(lanai, &lvcc->rx.buf,
 	    qos->rxtp.max_sdu, AAL5_RX_MULTIPLIER, qos->rxtp.max_sdu + 32,
 	    "RX");
 }
 
 /* Setup a TX buffer for a currently unbound AAL5 vci */
-static int lanai_setup_tx_vci(int number, struct lanai_vcc *lvcc,
+static int lanai_setup_tx_vci(struct lanai_dev *lanai, struct lanai_vcc *lvcc,
 	const struct atm_qos *qos)
 {
 	int max_sdu, multiplier;
@@ -1720,7 +1710,7 @@
 		max_sdu = qos->txtp.max_sdu;
 		multiplier = AAL5_TX_MULTIPLIER;
 	}
-	return lanai_get_sized_buffer(number, &lvcc->tx.buf, max_sdu,
+	return lanai_get_sized_buffer(lanai, &lvcc->tx.buf, max_sdu,
 	    multiplier, 80, "TX");
 }
 
@@ -1781,8 +1771,9 @@
  */
 static int __init service_buffer_allocate(struct lanai_dev *lanai)
 {
-	lanai_buf_allocate(&lanai->service, SERVICE_ENTRIES * 4, 0);
-	if (lanai->service.order < 0)
+	lanai_buf_allocate(&lanai->service, SERVICE_ENTRIES * 4, 8,
+	    lanai->pci);
+	if (lanai->service.start == NULL)
 		return -ENOMEM;
 	DPRINTK("allocated service buffer at 0x%08lX, size %d(%d)\n",
 	    (unsigned long) lanai->service.start,
@@ -1793,14 +1784,14 @@
 	/* ServiceStuff register contains size and address of buffer */
 	reg_write(lanai,
 	    SSTUFF_SET_SIZE(lanai_buf_size_cardorder(&lanai->service)) |
-	    SSTUFF_SET_ADDR(lanai_buf_dmaaddr(&lanai->service)),
+	    SSTUFF_SET_ADDR(lanai->service.dmaaddr),
 	    ServiceStuff_Reg);
 	return 0;
 }
 
 static inline void service_buffer_deallocate(struct lanai_dev *lanai)
 {
-	lanai_buf_deallocate(&lanai->service);
+	lanai_buf_deallocate(&lanai->service, lanai->pci);
 }
 
 /* Bitfields in service list */
@@ -2098,11 +2089,28 @@
 
 /* -------------------- PCI INITIALIZATION/SHUTDOWN: */
 
-static inline int __init lanai_pci_start(struct lanai_dev *lanai)
+static int __init lanai_pci_start(struct lanai_dev *lanai)
 {
 	struct pci_dev *pci = lanai->pci;
 	int result;
 	u16 w;
+
+	if (pci_enable_device(pci) != 0) {
+		printk(KERN_ERR DEV_LABEL "(itf %d): can't enable "
+		    "PCI device", lanai->number);
+		return -ENXIO;
+	}
+	pci_set_master(pci);
+	if (pci_set_dma_mask(pci, 0xFFFFFFFF) != 0) {
+		printk(KERN_WARNING DEV_LABEL
+		    "(itf %d): No suitable DMA available.\n", lanai->number);
+		return -EBUSY;
+	}
+	if (pci_set_consistent_dma_mask(pci, 0xFFFFFFFF) != 0) {
+		printk(KERN_WARNING DEV_LABEL
+		    "(itf %d): No suitable DMA available.\n", lanai->number);
+		return -EBUSY;
+	}
 	/* Get the pci revision byte */
 	result = pci_read_config_byte(pci, PCI_REVISION_ID,
 	    &lanai->pci_revision);
@@ -2113,7 +2121,8 @@
 	}
 	result = pci_read_config_word(pci, PCI_SUBSYSTEM_ID, &w);
 	if (result != PCIBIOS_SUCCESSFUL) {
-		printk(KERN_ERR DEV_LABEL "(itf %d): can't read PCI_SUBSYSTEM_ID: %d\n", lanai->number, result);
+		printk(KERN_ERR DEV_LABEL "(itf %d): can't read "
+		    "PCI_SUBSYSTEM_ID: %d\n", lanai->number, result);
 		return -EINVAL;
 	}
 	if ((result = check_board_id_and_rev("PCI", w, NULL)) != 0)
@@ -2125,43 +2134,11 @@
 		    "PCI_LATENCY_TIMER: %d\n", lanai->number, result);
 		return -EINVAL;
 	}
-	result = pci_read_config_word(pci, PCI_COMMAND, &w);
-	if (result != PCIBIOS_SUCCESSFUL) {
-		printk(KERN_ERR DEV_LABEL "(itf %d): can't read "
-		    "PCI_COMMAND: %d\n", lanai->number, result);
-		return -EINVAL;
-	}
-	w |= (PCI_COMMAND_MEMORY | PCI_COMMAND_MASTER | PCI_COMMAND_SERR |
-	    PCI_COMMAND_PARITY);
-	result = pci_write_config_word(pci, PCI_COMMAND, w);
-	if (result != PCIBIOS_SUCCESSFUL) {
-		printk(KERN_ERR DEV_LABEL "(itf %d): can't "
-			"write PCI_COMMAND: %d\n", lanai->number, result);
-		return -EINVAL;
-	}
 	pcistatus_check(lanai, 1);
 	pcistatus_check(lanai, 0);
 	return 0;
 }
 
-static void lanai_pci_stop(struct lanai_dev *lanai)
-{
-	struct pci_dev *pci = lanai->pci;
-	int result;
-	u16 pci_command;
-	result = pci_read_config_word(pci, PCI_COMMAND, &pci_command);
-	if (result != PCIBIOS_SUCCESSFUL) {
-		printk(KERN_ERR DEV_LABEL "(itf %d): can't "
-			"read PCI_COMMAND: %d\n", lanai->number, result);
-		return;
-	}
-	pci_command &= ~(PCI_COMMAND_MEMORY | PCI_COMMAND_MASTER);
-	result = pci_write_config_word(pci, PCI_COMMAND, pci_command);
-	if (result != PCIBIOS_SUCCESSFUL)
-		printk(KERN_ERR DEV_LABEL "(itf %d): can't "
-			"write PCI_COMMAND: %d\n", lanai->number, result);
-}
-
 /* -------------------- VPI/VCI ALLOCATION: */
 
 /*
@@ -2445,7 +2422,7 @@
 #endif
 	iounmap((void *) lanai->base);
     error_pci:
-	lanai_pci_stop(lanai);
+	pci_disable_device(lanai->pci);
     error:
 	return result;
 }
@@ -2470,7 +2447,7 @@
 	lanai->conf1 |= CONFIG1_POWERDOWN;
 	conf1_write(lanai);
 #endif
-	lanai_pci_stop(lanai);
+	pci_disable_device(lanai->pci);
 	vcc_table_deallocate(lanai);
 	service_buffer_deallocate(lanai);
 	iounmap((void *) lanai->base);
@@ -2493,7 +2470,7 @@
 			if (--lanai->naal0 <= 0)
 				aal0_buffer_free(lanai);
 		} else
-			lanai_buf_deallocate(&lvcc->rx.buf);
+			lanai_buf_deallocate(&lvcc->rx.buf, lanai->pci);
 		lvcc->rx.atmvcc = NULL;
 	}
 	if (lvcc->tx.atmvcc == atmvcc) {
@@ -2503,7 +2480,7 @@
 			lanai->cbrvcc = NULL;
 		}
 		lanai_shutdown_tx_vci(lanai, lvcc);
-		lanai_buf_deallocate(&lvcc->tx.buf);
+		lanai_buf_deallocate(&lvcc->tx.buf, lanai->pci);
 		lvcc->tx.atmvcc = NULL;
 	}
 	if (--lvcc->nref == 0) {
@@ -2551,7 +2528,7 @@
 				result = aal0_buffer_allocate(lanai);
 		} else
 			result = lanai_setup_rx_vci_aal5(
-			    lanai->number, lvcc, &atmvcc->qos);
+			    lanai, lvcc, &atmvcc->qos);
 		if (result != 0)
 			goto out_free;
 		lvcc->rx.atmvcc = atmvcc;
@@ -2566,7 +2543,7 @@
 	if (atmvcc->qos.txtp.traffic_class != ATM_NONE) {
 		APRINTK(lvcc->tx.atmvcc == NULL, "tx.atmvcc!=NULL, vci=%d\n",
 		    vci);
-		result = lanai_setup_tx_vci(lanai->number, lvcc, &atmvcc->qos);
+		result = lanai_setup_tx_vci(lanai, lvcc, &atmvcc->qos);
 		if (result != 0)
 			goto out_free;
 		lvcc->tx.atmvcc = atmvcc;
@@ -2849,49 +2826,69 @@
 	.proc_read	= lanai_proc_read
 };
 
-/* detect one type of card LANAI2 or LANAIHB */
-static int __init lanai_detect_1(unsigned int vendor, unsigned int device)
+/* initialize one probed card */
+static int __devinit lanai_init_one(struct pci_dev *pci,
+				    const struct pci_device_id *ident)
 {
-	struct pci_dev *pci = NULL;
 	struct lanai_dev *lanai;
 	struct atm_dev *atmdev;
-	int count = 0, result;
-	while ((pci = pci_find_device(vendor, device, pci)) != NULL) {
-		lanai = (struct lanai_dev *)
-		    kmalloc(sizeof *lanai, GFP_KERNEL);
-		if (lanai == NULL) {
-			printk(KERN_ERR DEV_LABEL ": couldn't allocate "
-			    "dev_data structure!\n");
-			break;
-		}
-		atmdev = atm_dev_register(DEV_LABEL, &ops, -1, 0);
-		if (atmdev == NULL) {
-			printk(KERN_ERR DEV_LABEL ": couldn't register "
-			    "atm device!\n");
-			kfree(lanai);
-			break;
-		}
-		atmdev->dev_data = lanai;
-		lanai->pci = pci;
-		lanai->type = (enum lanai_type) device;
-		if ((result = lanai_dev_open(atmdev)) != 0) {
-			DPRINTK("lanai_start() failed, err=%d\n", -result);
-			atm_dev_deregister(atmdev);
-			kfree(lanai);
-			continue;
-		}
-		count++;
+	int result;
+
+	lanai = (struct lanai_dev *) kmalloc(sizeof(*lanai), GFP_KERNEL);
+	if (lanai == NULL) {
+		printk(KERN_ERR DEV_LABEL
+		       ": couldn't allocate dev_data structure!\n");
+		return -ENOMEM;
+	}
+
+	atmdev = atm_dev_register(DEV_LABEL, &ops, -1, 0);
+	if (atmdev == NULL) {
+		printk(KERN_ERR DEV_LABEL
+		    ": couldn't register atm device!\n");
+		kfree(lanai);
+		return -EBUSY;
+	}
+
+	atmdev->dev_data = lanai;
+	lanai->pci = pci;
+	lanai->type = (enum lanai_type) ident->device;
+
+	result = lanai_dev_open(atmdev);
+	if (result != 0) {
+		DPRINTK("lanai_start() failed, err=%d\n", -result);
+		atm_dev_deregister(atmdev);
+		kfree(lanai);
 	}
-	return count;
+	return result;
 }
 
+static struct pci_device_id lanai_pci_tbl[] __devinitdata = {
+	{
+		PCI_VENDOR_ID_EF, PCI_VENDOR_ID_EF_ATM_LANAI2,
+		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0
+	},
+	{
+		PCI_VENDOR_ID_EF, PCI_VENDOR_ID_EF_ATM_LANAIHB,
+		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0
+	},
+	{ 0, }	/* terminal entry */
+};
+MODULE_DEVICE_TABLE(pci, lanai_pci_tbl);
+
+static struct pci_driver lanai_driver = {
+	.name     = DEV_LABEL,
+	.id_table = lanai_pci_tbl,
+	.probe    = lanai_init_one,
+};
+
 static int __init lanai_module_init(void)
 {
-	if (lanai_detect_1(PCI_VENDOR_ID_EF, PCI_VENDOR_ID_EF_ATM_LANAI2) +
-	    lanai_detect_1(PCI_VENDOR_ID_EF, PCI_VENDOR_ID_EF_ATM_LANAIHB))
-		return 0;
-	printk(KERN_ERR DEV_LABEL ": no adaptor found\n");
-	return -ENODEV;
+	int x;
+
+	x = pci_module_init(&lanai_driver);
+	if (x != 0)
+		printk(KERN_ERR DEV_LABEL ": no adapter found\n");
+	return x;
 }
 
 static void __exit lanai_module_exit(void)
