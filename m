From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [drivers] fix warnings related to readl/writel changes
Date: Tue, 21 Sep 2004 16:27:03 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409212027.i8LKR2Ja010520@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

dave,

this patch gets rid of warnings from some of the atm drivers related to
the recent readl/writel changes.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/17 19:50:46-04:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [drivers] fix warnings related to readl/writel changes
# 
# 
diff -Nru a/drivers/atm/firestream.c b/drivers/atm/firestream.c
--- a/drivers/atm/firestream.c	2004-09-21 12:47:06 -04:00
+++ b/drivers/atm/firestream.c	2004-09-21 12:47:06 -04:00
@@ -1667,7 +1667,7 @@
 
 	dev->hw_base = pci_resource_start(pci_dev, 0);
 
-	dev->base = (ulong) ioremap(dev->hw_base, 0x1000);
+	dev->base = ioremap(dev->hw_base, 0x1000);
 
 	reset_chip (dev);
   
diff -Nru a/drivers/atm/firestream.h b/drivers/atm/firestream.h
--- a/drivers/atm/firestream.h	2004-09-21 12:47:06 -04:00
+++ b/drivers/atm/firestream.h	2004-09-21 12:47:06 -04:00
@@ -477,7 +477,7 @@
 	struct timer_list timer;
 
 	unsigned long hw_base;		/* mem base address */
-	unsigned long base;             /* Mapping of base address */
+	void *base;             /* Mapping of base address */
 	int channo;
 	unsigned long channel_mask;
 
diff -Nru a/drivers/atm/he.c b/drivers/atm/he.c
--- a/drivers/atm/he.c	2004-09-21 12:47:06 -04:00
+++ b/drivers/atm/he.c	2004-09-21 12:47:06 -04:00
@@ -1007,6 +1007,7 @@
 {
 	struct he_dev *he_dev;
 	struct pci_dev *pci_dev;
+	unsigned long membase;
 
 	u16 command;
 	u32 gen_cntl_0, host_cntl, lb_swap;
@@ -1019,8 +1020,8 @@
 	he_dev = HE_DEV(dev);
 	pci_dev = he_dev->pci_dev;
 
-	he_dev->membase = pci_dev->resource[0].start;
-	HPRINTK("membase = 0x%lx  irq = %d.\n", he_dev->membase, pci_dev->irq);
+	membase = pci_resource_start(pci_dev, 0);
+	HPRINTK("membase = 0x%lx  irq = %d.\n", membase, pci_dev->irq);
 
 	/*
 	 * pci bus controller initialization 
@@ -1080,7 +1081,7 @@
 			hprintk("can't set latency timer to %d\n", timer);
 	}
 
-	if (!(he_dev->membase = (unsigned long) ioremap(he_dev->membase, HE_REGMAP_SIZE))) {
+	if (!(he_dev->membase = ioremap(membase, HE_REGMAP_SIZE))) {
 		hprintk("can't set up page mapping\n");
 		return -EINVAL;
 	}
diff -Nru a/drivers/atm/he.h b/drivers/atm/he.h
--- a/drivers/atm/he.h	2004-09-21 12:47:06 -04:00
+++ b/drivers/atm/he.h	2004-09-21 12:47:06 -04:00
@@ -265,7 +265,7 @@
 struct he_dev {
 	unsigned int number;
 	unsigned int irq;
-	unsigned long membase;
+	void *membase;
 
 	char prod_id[30];
 	char mac_addr[6];
diff -Nru a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
--- a/drivers/atm/idt77252.c	2004-09-21 12:47:06 -04:00
+++ b/drivers/atm/idt77252.c	2004-09-21 12:47:06 -04:00
@@ -3164,7 +3164,7 @@
 
 	for (i = 0; i < 4; i++) {
 		if (card->fbq[i])
-			iounmap((void *) card->fbq[i]);
+			iounmap(card->fbq[i]);
 	}
 
 	if (card->membase)
@@ -3722,7 +3722,7 @@
 	card->tst_timer.function = tst_timer;
 
 	/* Do the I/O remapping... */
-	card->membase = (unsigned long) ioremap(membase, 1024);
+	card->membase = ioremap(membase, 1024);
 	if (!card->membase) {
 		printk("%s: can't ioremap() membase\n", card->name);
 		err = -EIO;
@@ -3756,8 +3756,7 @@
 	card->sramsize = probe_sram(card);
 
 	for (i = 0; i < 4; i++) {
-		card->fbq[i] = (unsigned long)
-			    ioremap(srambase | 0x200000 | (i << 18), 4);
+		card->fbq[i] = ioremap(srambase | 0x200000 | (i << 18), 4);
 		if (!card->fbq[i]) {
 			printk("%s: can't ioremap() FBQ%d\n", card->name, i);
 			err = -EIO;
diff -Nru a/drivers/atm/idt77252.h b/drivers/atm/idt77252.h
--- a/drivers/atm/idt77252.h	2004-09-21 12:47:06 -04:00
+++ b/drivers/atm/idt77252.h	2004-09-21 12:47:06 -04:00
@@ -355,9 +355,9 @@
 	struct pci_dev		*pcidev;	/* PCI handle (desriptor) */
 	struct atm_dev		*atmdev;	/* ATM device desriptor */
 
-	unsigned long		membase;	/* SAR's memory base address */
+	void			*membase;	/* SAR's memory base address */
 	unsigned long		srambase;	/* SAR's sram  base address */
-	unsigned long		fbq[4];		/* FBQ fill addresses */
+	void 			*fbq[4];	/* FBQ fill addresses */
 
 	struct semaphore	mutex;
 	spinlock_t		cmd_lock;	/* for r/w utility/sram */
diff -Nru a/drivers/atm/lanai.c b/drivers/atm/lanai.c
--- a/drivers/atm/lanai.c	2004-09-21 12:47:06 -04:00
+++ b/drivers/atm/lanai.c	2004-09-21 12:47:06 -04:00
@@ -191,7 +191,7 @@
 #define LANAI_EEPROM_SIZE	(128)
 
 typedef int vci_t;
-typedef unsigned long bus_addr_t;
+typedef void *bus_addr_t;
 
 /* DMA buffer in host memory for TX, RX, or service list. */
 struct lanai_buffer {
@@ -471,7 +471,7 @@
 static inline bus_addr_t reg_addr(const struct lanai_dev *lanai,
 	enum lanai_register reg)
 {
-	return lanai->base + (bus_addr_t) reg;
+	return lanai->base + reg;
 }
 
 static inline u32 reg_read(const struct lanai_dev *lanai,
@@ -651,7 +651,7 @@
 {
 	u32 val;
 	APRINTK(lvcc->vbase != 0, "cardvcc_read: unbound vcc!\n");
-	val= readl(lvcc->vbase + (bus_addr_t) offset);
+	val= readl(lvcc->vbase + offset);
 	RWDEBUG("VR vci=%04d 0x%02X = 0x%08X\n",
 	    lvcc->vci, (int) offset, val);
 	return val;
@@ -666,7 +666,7 @@
 	    (unsigned int) val, lvcc->vci, (unsigned int) offset);
 	RWDEBUG("VW vci=%04d 0x%02X > 0x%08X\n",
 	    lvcc->vci, (unsigned int) offset, (unsigned int) val);
-	writel(val, lvcc->vbase + (bus_addr_t) offset);
+	writel(val, lvcc->vbase + offset);
 }
 
 /* -------------------- COMPUTE SIZE OF AN AAL5 PDU: */
@@ -2177,7 +2177,7 @@
 	/* 3.2: PCI initialization */
 	if ((result = lanai_pci_start(lanai)) != 0)
 		goto error;
-	raw_base = (bus_addr_t) lanai->pci->resource[0].start;
+	raw_base = lanai->pci->resource[0].start;
 	lanai->base = (bus_addr_t) ioremap(raw_base, LANAI_MAPPING_SIZE);
 	if (lanai->base == 0) {
 		printk(KERN_ERR DEV_LABEL ": couldn't remap I/O space\n");
diff -Nru a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
--- a/drivers/atm/nicstar.c	2004-09-21 12:47:06 -04:00
+++ b/drivers/atm/nicstar.c	2004-09-21 12:47:06 -04:00
@@ -467,6 +467,7 @@
    u32 u32d[4];
    u32 ns_cfg_rctsize;
    int bcount;
+   unsigned long membase;
 
    error = 0;
 
@@ -494,8 +495,8 @@
    card->index = i;
    card->atmdev = NULL;
    card->pcidev = pcidev;
-   card->membase = pci_resource_start(pcidev, 1);
-   card->membase = (unsigned long) ioremap(card->membase, NS_IOREMAP_SIZE);
+   membase = pci_resource_start(pcidev, 1);
+   card->membase = ioremap(membase, NS_IOREMAP_SIZE);
    if (card->membase == 0)
    {
       printk("nicstar%d: can't ioremap() membase.\n",i);
diff -Nru a/drivers/atm/nicstar.h b/drivers/atm/nicstar.h
--- a/drivers/atm/nicstar.h	2004-09-21 12:47:06 -04:00
+++ b/drivers/atm/nicstar.h	2004-09-21 12:47:06 -04:00
@@ -763,7 +763,7 @@
 {
    int index;				/* Card ID to the device driver */
    int sram_size;			/* In k x 32bit words. 32 or 128 */
-   unsigned long membase;			/* Card's memory base address */
+   void *membase;			/* Card's memory base address */
    unsigned long max_pcr;
    int rct_size;			/* Number of entries */
    int vpibits;
diff -Nru a/drivers/atm/nicstarmac.c b/drivers/atm/nicstarmac.c
--- a/drivers/atm/nicstarmac.c	2004-09-21 12:47:06 -04:00
+++ b/drivers/atm/nicstarmac.c	2004-09-21 12:47:06 -04:00
@@ -162,7 +162,7 @@
  */
  
 static u_int8_t 
-read_eprom_byte(u_int32_t base, u_int8_t offset)
+read_eprom_byte(virt_addr_t base, u_int8_t offset)
 {
    u_int32_t val = 0;
    int i,j=0;
diff -Nru a/drivers/atm/nicstarmac.h b/drivers/atm/nicstarmac.h
--- a/drivers/atm/nicstarmac.h	2004-09-21 12:47:05 -04:00
+++ b/drivers/atm/nicstarmac.h	2004-09-21 12:47:05 -04:00
@@ -7,7 +7,7 @@
  ******************************************************************************/
 
 
-typedef unsigned int virt_addr_t;
+typedef void * virt_addr_t;
 
 u_int32_t nicstar_read_eprom_status( virt_addr_t base );
 void nicstar_init_eprom( virt_addr_t base );
