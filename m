From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: Re: converting fore200e driver to use request_firmware()
Date: Thu, 07 Feb 2008 14:20:19 -0500
Message-ID: <200802071920.m17JKJMb029314@cmf.nrl.navy.mil>
References: <20080206.160542.07994571.davem@davemloft.net>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:39302 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760251AbYBGTUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 14:20:46 -0500
In-reply-to: <20080206.160542.07994571.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <20080206.160542.07994571.davem@davemloft.net>,David Miller writes:
>> however, i ran into a little problem with the sbus interface.  what should
>> i pass for 'struct device *' for an sbus device?
>
>"&sdev->ofdev.dev" should work

thanks!  that is what i needed.  so what i have works on pci and is
quite a bit cleaner than the current mess for the firmware.  the only
iffy part is the conversion of the struct fore_200e to a struct device
which is depends your bus.  perhaps it should be a seperate routine.

any comments on the following?

diff --git a/drivers/atm/Kconfig b/drivers/atm/Kconfig
index 1c7ae30..a5303ee 100644
--- a/drivers/atm/Kconfig
+++ b/drivers/atm/Kconfig
@@ -325,81 +325,21 @@ config ATM_IA_DEBUG
 	  speed of the driver, and the size of your syslog files! When
 	  inactive, they will have only a modest impact on performance.
 
-config ATM_FORE200E_MAYBE
+config ATM_FORE200E
 	tristate "FORE Systems 200E-series"
-	depends on PCI || SBUS
+	depends on (PCI || SBUS)
 	---help---
 	  This is a driver for the FORE Systems 200E-series ATM adapter
 	  cards. It simultaneously supports PCA-200E and SBA-200E models
 	  on PCI and SBUS hosts. Say Y (or M to compile as a module
 	  named fore_200e) here if you have one of these ATM adapters.
 
-	  Note that the driver will actually be compiled only if you
-	  additionally enable the support for PCA-200E and/or SBA-200E
-	  cards.
-
 	  See the file <file:Documentation/networking/fore200e.txt> for
 	  further details.
 
-config ATM_FORE200E_PCA
-	bool "PCA-200E support"
-	depends on ATM_FORE200E_MAYBE && PCI
-	help
-	  Say Y here if you want your PCA-200E cards to be probed.
-
-config ATM_FORE200E_PCA_DEFAULT_FW
-	bool "Use default PCA-200E firmware (normally enabled)"
-	depends on ATM_FORE200E_PCA
-	help
-	  Use the default PCA-200E firmware data shipped with the driver.
-
-	  Normal users do not have to deal with the firmware stuff, so
-	  they should say Y here.
-
-config ATM_FORE200E_PCA_FW
-	string "Pathname of user-supplied binary firmware"
-	depends on ATM_FORE200E_PCA && !ATM_FORE200E_PCA_DEFAULT_FW
-	default ""
-	help
-	  This defines the pathname of an alternative PCA-200E binary
-	  firmware image supplied by the user. This pathname may be
-	  absolute or relative to the drivers/atm directory.
-
-	  The driver comes with an adequate firmware image, so normal users do
-	  not have to supply an alternative one. They just say Y to "Use
-	  default PCA-200E firmware" instead.
-
-config ATM_FORE200E_SBA
-	bool "SBA-200E support"
-	depends on ATM_FORE200E_MAYBE && SBUS
-	help
-	  Say Y here if you want your SBA-200E cards to be probed.
-
-config ATM_FORE200E_SBA_DEFAULT_FW
-	bool "Use default SBA-200E firmware (normally enabled)"
-	depends on ATM_FORE200E_SBA
-	help
-	  Use the default SBA-200E firmware data shipped with the driver.
-
-	  Normal users do not have to deal with the firmware stuff, so
-	  they should say Y here.
-
-config ATM_FORE200E_SBA_FW
-	string "Pathname of user-supplied binary firmware"
-	depends on ATM_FORE200E_SBA && !ATM_FORE200E_SBA_DEFAULT_FW
-	default ""
-	help
-	  This defines the pathname of an alternative SBA-200E binary
-	  firmware image supplied by the user. This pathname may be
-	  absolute or relative to the drivers/atm directory.
-
-	  The driver comes with an adequate firmware image, so normal users do
-	  not have to supply an alternative one. They just say Y to "Use
-	  default SBA-200E firmware", above.
-
 config ATM_FORE200E_USE_TASKLET
 	bool "Defer interrupt work to a tasklet"
-	depends on (PCI || SBUS) && (ATM_FORE200E_PCA || ATM_FORE200E_SBA)
+	depends on ATM_FORE200E
 	default n
 	help
 	  This defers work to be done by the interrupt handler to a
@@ -408,7 +348,7 @@ config ATM_FORE200E_USE_TASKLET
 
 config ATM_FORE200E_TX_RETRY
 	int "Maximum number of tx retries"
-	depends on (PCI || SBUS) && (ATM_FORE200E_PCA || ATM_FORE200E_SBA)
+	depends on ATM_FORE200E
 	default "16"
 	---help---
 	  Specifies the number of times the driver attempts to transmit
@@ -425,7 +365,7 @@ config ATM_FORE200E_TX_RETRY
 
 config ATM_FORE200E_DEBUG
 	int "Debugging level (0-3)"
-	depends on (PCI || SBUS) && (ATM_FORE200E_PCA || ATM_FORE200E_SBA)
+	depends on ATM_FORE200E
 	default "0"
 	help
 	  Specifies the level of debugging messages issued by the driver.
@@ -436,12 +376,6 @@ config ATM_FORE200E_DEBUG
 	  the performances of the driver, and the size of your syslog files!
 	  Keep the debugging level to 0 during normal operations.
 
-config ATM_FORE200E
-	tristate
-	depends on (PCI || SBUS) && (ATM_FORE200E_PCA || ATM_FORE200E_SBA)
-	default m if ATM_FORE200E_MAYBE!=y
-	default y if ATM_FORE200E_MAYBE=y
-
 config ATM_HE
 	tristate "ForeRunner HE Series"
 	depends on PCI
diff --git a/drivers/atm/Makefile b/drivers/atm/Makefile
index e4fa996..4109583 100644
--- a/drivers/atm/Makefile
+++ b/drivers/atm/Makefile
@@ -3,14 +3,11 @@
 #
 
 fore_200e-objs	:= fore200e.o
-hostprogs-y	:= fore200e_mkfirm
 
 # Files generated that shall be removed upon make clean
 clean-files := atmsar11.bin atmsar11.bin1 atmsar11.bin2 pca200e.bin \
 	pca200e.bin1 pca200e.bin2 pca200e_ecd.bin pca200e_ecd.bin1 \
 	pca200e_ecd.bin2 sba200e_ecd.bin sba200e_ecd.bin1 sba200e_ecd.bin2
-# Firmware generated that shall be removed upon make clean
-clean-files += fore200e_pca_fw.c fore200e_sba_fw.c
 
 obj-$(CONFIG_ATM_ZATM)		+= zatm.o uPD98402.o
 obj-$(CONFIG_ATM_NICSTAR)	+= nicstar.o
@@ -36,37 +33,11 @@ obj-$(CONFIG_ATM_TCP)		+= atmtcp.o
 obj-$(CONFIG_ATM_FIRESTREAM)	+= firestream.o
 obj-$(CONFIG_ATM_LANAI)		+= lanai.o
 
-ifeq ($(CONFIG_ATM_FORE200E_PCA),y)
-  fore_200e-objs		+= fore200e_pca_fw.o
-  # guess the target endianess to choose the right PCA-200E firmware image
-  ifeq ($(CONFIG_ATM_FORE200E_PCA_DEFAULT_FW),y)
-    byteorder.h			:= include$(if $(patsubst $(srctree),,$(objtree)),2)/asm/byteorder.h
-    CONFIG_ATM_FORE200E_PCA_FW	:= $(obj)/pca200e$(if $(shell $(CC) $(KBUILD_CPPFLAGS) -E -dM $(byteorder.h) | grep ' __LITTLE_ENDIAN '),.bin,_ecd.bin2)
-  endif
-endif
-
-ifeq ($(CONFIG_ATM_FORE200E_SBA),y)
-  fore_200e-objs		+= fore200e_sba_fw.o
-  ifeq ($(CONFIG_ATM_FORE200E_SBA_DEFAULT_FW),y)
-    CONFIG_ATM_FORE200E_SBA_FW	:= $(obj)/sba200e_ecd.bin2
-  endif
-endif
 obj-$(CONFIG_ATM_HE)		+= he.o
 ifeq ($(CONFIG_ATM_HE_USE_SUNI),y)
   obj-$(CONFIG_ATM_HE)		+= suni.o
 endif
 
-# FORE Systems 200E-series firmware magic
-$(obj)/fore200e_pca_fw.c: $(patsubst "%", %, $(CONFIG_ATM_FORE200E_PCA_FW)) \
-			  $(obj)/fore200e_mkfirm
-	$(obj)/fore200e_mkfirm -k -b _fore200e_pca_fw \
-	  -i $(CONFIG_ATM_FORE200E_PCA_FW) -o $@
-
-$(obj)/fore200e_sba_fw.c: $(patsubst "%", %, $(CONFIG_ATM_FORE200E_SBA_FW)) \
-			  $(obj)/fore200e_mkfirm
-	$(obj)/fore200e_mkfirm -k -b _fore200e_sba_fw \
-	  -i $(CONFIG_ATM_FORE200E_SBA_FW) -o $@
-
 # deal with the various suffixes of the binary firmware images
 $(obj)/%.bin $(obj)/%.bin1 $(obj)/%.bin2: $(src)/%.data
 	objcopy -Iihex $< -Obinary $@.gz
diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index 6b4512c..f365174 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -36,6 +36,7 @@
 #include <linux/atm_suni.h>
 #include <linux/dma-mapping.h>
 #include <linux/delay.h>
+#include <linux/firmware.h>
 #include <asm/io.h>
 #include <asm/string.h>
 #include <asm/page.h>
@@ -45,7 +46,7 @@
 #include <asm/uaccess.h>
 #include <asm/atomic.h>
 
-#ifdef CONFIG_ATM_FORE200E_SBA
+#ifdef CONFIG_SBUS
 #include <asm/idprom.h>
 #include <asm/sbus.h>
 #include <asm/openprom.h>
@@ -382,9 +383,6 @@ fore200e_shutdown(struct fore200e* fore200e)
     case FORE200E_STATE_START_FW:
 	/* nothing to do for that state */
 
-    case FORE200E_STATE_LOAD_FW:
-	/* nothing to do for that state */
-
     case FORE200E_STATE_RESET:
 	/* nothing to do for that state */
 
@@ -405,7 +403,7 @@ fore200e_shutdown(struct fore200e* fore200e)
 }
 
 
-#ifdef CONFIG_ATM_FORE200E_PCA
+#ifdef CONFIG_PCI
 
 static u32 fore200e_pca_read(volatile u32 __iomem *addr)
 {
@@ -658,10 +656,10 @@ fore200e_pca_proc_read(struct fore200e* fore200e, char *page)
 		   pci_dev->bus->number, PCI_SLOT(pci_dev->devfn), PCI_FUNC(pci_dev->devfn));
 }
 
-#endif /* CONFIG_ATM_FORE200E_PCA */
+#endif /* CONFIG_PCI */
 
 
-#ifdef CONFIG_ATM_FORE200E_SBA
+#ifdef CONFIG_SBUS
 
 static u32
 fore200e_sba_read(volatile u32 __iomem *addr)
@@ -909,7 +907,7 @@ fore200e_sba_proc_read(struct fore200e* fore200e, char *page)
 
     return sprintf(page, "   SBUS slot/device:\t\t%d/'%s'\n", sbus_dev->slot, sbus_dev->prom_name);
 }
-#endif /* CONFIG_ATM_FORE200E_SBA */
+#endif /* CONFIG_SBUS */
 
 
 static void
@@ -2556,11 +2554,45 @@ fore200e_monitor_puts(struct fore200e* fore200e, char* str)
 
 
 static int __devinit
-fore200e_start_fw(struct fore200e* fore200e)
-{
-    int               ok;
-    char              cmd[ 48 ];
-    struct fw_header* fw_header = (struct fw_header*) fore200e->bus->fw_data;
+fore200e_load_and_start_fw(struct fore200e* fore200e)
+{
+    const struct firmware *firmware;
+    struct device *device;
+    struct fw_header *fw_header;
+    u32 *fw_data, fw_size;
+    u32 __iomem *load_addr;
+    char buf[48];
+    int err = -ENODEV;
+
+    if (strcmp(fore200e->bus->model_name, "PCA-200E") == 0)
+	device = &((struct pci_dev *) fore200e->bus_dev)->dev;
+#ifdef CONFIG_SBUS
+    else if (strcmp(fore200e->bus->model_name, "SBA-200E") == 0)
+	device = &((struct sbus_dev *) fore200e->bus_dev)->ofdev.dev;
+#endif
+    else
+	return err;
+
+    sprintf(buf, "%s.bin", fore200e->bus->proc_name);
+    if (request_firmware(&firmware, buf, device) == 1) {
+	return err;
+    }
+
+    fw_data = (u32 *) firmware->data;
+    fw_size = firmware->size / sizeof(u32);
+    fw_header = (struct fw_header*) fw_data;
+    load_addr = fore200e->virt_base + le32_to_cpu(fw_header->load_offset);
+
+    DPRINTK(2, "device %s firmware being loaded at 0x%p (%d words)\n", 
+	    fore200e->name, load_addr, fw_size);
+
+    if (le32_to_cpu(fw_header->magic) != FW_HEADER_MAGIC) {
+	printk(FORE200E "corrupted %s firmware image\n", fore200e->bus->model_name);
+	goto release;
+    }
+
+    for (; fw_size--; fw_data++, load_addr++)
+	fore200e->bus->write(le32_to_cpu(*fw_data), load_addr);
 
     DPRINTK(2, "device %s firmware being started\n", fore200e->name);
 
@@ -2569,46 +2601,22 @@ fore200e_start_fw(struct fore200e* fore200e)
     fore200e_spin(100);
 #endif
 
-    sprintf(cmd, "\rgo %x\r", le32_to_cpu(fw_header->start_offset));
-
-    fore200e_monitor_puts(fore200e, cmd);
+    sprintf(buf, "\rgo %x\r", le32_to_cpu(fw_header->start_offset));
+    fore200e_monitor_puts(fore200e, buf);
 
-    ok = fore200e_io_poll(fore200e, &fore200e->cp_monitor->bstat, BSTAT_CP_RUNNING, 1000);
-    if (ok == 0) {
+    if (fore200e_io_poll(fore200e, &fore200e->cp_monitor->bstat, BSTAT_CP_RUNNING, 1000) == 0) {
 	printk(FORE200E "device %s firmware didn't start\n", fore200e->name);
-	return -ENODEV;
+	goto release;
     }
 
     printk(FORE200E "device %s firmware started\n", fore200e->name);
 
     fore200e->state = FORE200E_STATE_START_FW;
-    return 0;
-}
-
+    err = 0;
 
-static int __devinit
-fore200e_load_fw(struct fore200e* fore200e)
-{
-    u32* fw_data = (u32*) fore200e->bus->fw_data;
-    u32  fw_size = (u32) *fore200e->bus->fw_size / sizeof(u32);
-
-    struct fw_header* fw_header = (struct fw_header*) fw_data;
-
-    u32 __iomem *load_addr = fore200e->virt_base + le32_to_cpu(fw_header->load_offset);
-
-    DPRINTK(2, "device %s firmware being loaded at 0x%p (%d words)\n", 
-	    fore200e->name, load_addr, fw_size);
-
-    if (le32_to_cpu(fw_header->magic) != FW_HEADER_MAGIC) {
-	printk(FORE200E "corrupted %s firmware image\n", fore200e->bus->model_name);
-	return -ENODEV;
-    }
-
-    for (; fw_size--; fw_data++, load_addr++)
-	fore200e->bus->write(le32_to_cpu(*fw_data), load_addr);
-
-    fore200e->state = FORE200E_STATE_LOAD_FW;
-    return 0;
+release:
+    release_firmware(firmware);
+    return err;
 }
 
 
@@ -2654,10 +2662,7 @@ fore200e_init(struct fore200e* fore200e)
     if (fore200e_reset(fore200e, 1) < 0)
 	return -ENODEV;
 
-    if (fore200e_load_fw(fore200e) < 0)
-	return -ENODEV;
-
-    if (fore200e_start_fw(fore200e) < 0)
+    if (fore200e_load_and_start_fw(fore200e) < 0)
 	return -ENODEV;
 
     if (fore200e_initialize(fore200e) < 0)
@@ -2691,7 +2696,7 @@ fore200e_init(struct fore200e* fore200e)
     return 0;
 }
 
-#ifdef CONFIG_ATM_FORE200E_PCA
+#ifdef CONFIG_PCI
 static int __devinit
 fore200e_pca_detect(struct pci_dev *pci_dev, const struct pci_device_id *pci_ent)
 {
@@ -2806,7 +2811,7 @@ fore200e_module_init(void)
 	}
     }
 
-#ifdef CONFIG_ATM_FORE200E_PCA
+#ifdef CONFIG_PCI
     if (!pci_register_driver(&fore200e_pca_driver))
 	return 0;
 #endif
@@ -2823,7 +2828,7 @@ fore200e_module_cleanup(void)
 {
     struct fore200e *fore200e, *next;
 
-#ifdef CONFIG_ATM_FORE200E_PCA
+#ifdef CONFIG_PCI
     pci_unregister_driver(&fore200e_pca_driver);
 #endif
 
@@ -3142,19 +3147,9 @@ static const struct atmdev_ops fore200e_ops =
 };
 
 
-#ifdef CONFIG_ATM_FORE200E_PCA
-extern const unsigned char _fore200e_pca_fw_data[];
-extern const unsigned int  _fore200e_pca_fw_size;
-#endif
-#ifdef CONFIG_ATM_FORE200E_SBA
-extern const unsigned char _fore200e_sba_fw_data[];
-extern const unsigned int  _fore200e_sba_fw_size;
-#endif
-
 static const struct fore200e_bus fore200e_bus[] = {
-#ifdef CONFIG_ATM_FORE200E_PCA
+#ifdef CONFIG_PCI
     { "PCA-200E", "pca200e", 32, 4, 32, 
-      _fore200e_pca_fw_data, &_fore200e_pca_fw_size,
       fore200e_pca_read,
       fore200e_pca_write,
       fore200e_pca_dma_map,
@@ -3175,9 +3170,8 @@ static const struct fore200e_bus fore200e_bus[] = {
       fore200e_pca_proc_read,
     },
 #endif
-#ifdef CONFIG_ATM_FORE200E_SBA
+#ifdef CONFIG_SBUS
     { "SBA-200E", "sba200e", 32, 64, 32,
-      _fore200e_sba_fw_data, &_fore200e_sba_fw_size,
       fore200e_sba_read,
       fore200e_sba_write,
       fore200e_sba_dma_map,
diff --git a/drivers/atm/fore200e.h b/drivers/atm/fore200e.h
index b85a546..73a185d 100644
--- a/drivers/atm/fore200e.h
+++ b/drivers/atm/fore200e.h
@@ -755,7 +755,6 @@ typedef enum fore200e_state {
     FORE200E_STATE_CONFIGURE,     /* bus interface configured          */
     FORE200E_STATE_MAP,           /* board space mapped in host memory */
     FORE200E_STATE_RESET,         /* board resetted                    */
-    FORE200E_STATE_LOAD_FW,       /* firmware loaded                   */
     FORE200E_STATE_START_FW,      /* firmware started                  */
     FORE200E_STATE_INITIALIZE,    /* initialize command successful     */
     FORE200E_STATE_INIT_CMDQ,     /* command queue initialized         */
@@ -804,8 +803,6 @@ typedef struct fore200e_bus {
     int                  descr_alignment;     /* tpd/rpd/rbd DMA alignment requirement  */
     int                  buffer_alignment;    /* rx buffers DMA alignment requirement   */
     int                  status_alignment;    /* status words DMA alignment requirement */
-    const unsigned char* fw_data;             /* address of firmware data start         */
-    const unsigned int*  fw_size;             /* address of firmware data size          */
     u32                  (*read)(volatile u32 __iomem *);
     void                 (*write)(u32, volatile u32 __iomem *);
     u32                  (*dma_map)(struct fore200e*, void*, int, int);
