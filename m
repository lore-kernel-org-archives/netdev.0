From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (20/42) hp100-T10
Date: Wed, 12 Nov 2003 16:43:38 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130043.hAD0hcm30797@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE44-hp100
	* convert to dynamic allocation
	* use device model for PCI and EISA
	* use pci id's to find PCI devices
	* fix missing id's for 10 Mbit only PCI boards

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Wed Nov 12 14:44:05 2003
+++ b/drivers/net/Space.c	Wed Nov 12 14:44:05 2003
@@ -41,7 +41,7 @@
    */
 
 extern int ne2_probe(struct net_device *dev);
-extern int hp100_probe(struct net_device *dev);
+extern struct net_device *hp100_probe(int unit);
 extern struct net_device *ultra_probe(int unit);
 extern int ultra32_probe(struct net_device *dev);
 extern struct net_device *wd_probe(int unit);
@@ -197,14 +197,10 @@
  * ISA probes that touch addresses < 0x400 (including those that also
  * look for EISA/PCI/MCA cards in addition to ISA cards).
  */
-static struct devprobe isa_probes[] __initdata = {
+static struct devprobe2 isa_probes2[] __initdata = {
 #ifdef CONFIG_HP100 		/* ISA, EISA & PCI */
 	{hp100_probe, 0},
 #endif	
-	{NULL, 0},
-};
-
-static struct devprobe2 isa_probes2[] __initdata = {
 #ifdef CONFIG_3C515
 	{tc515_probe, 0},
 #endif
@@ -382,8 +378,7 @@
 	if (probe_list(dev, m68k_probes) == 0 ||
 	    probe_list(dev, mips_probes) == 0 ||
 	    probe_list(dev, eisa_probes) == 0 ||
-	    probe_list(dev, mca_probes) == 0 ||
-	    probe_list(dev, isa_probes) == 0)
+	    probe_list(dev, mca_probes) == 0)
 		err = register_netdev(dev);
 
 	if (err)
diff -Nru a/drivers/net/hp100.c b/drivers/net/hp100.c
--- a/drivers/net/hp100.c	Wed Nov 12 14:44:05 2003
+++ b/drivers/net/hp100.c	Wed Nov 12 14:44:05 2003
@@ -118,8 +118,6 @@
 #include <asm/bitops.h>
 #include <asm/io.h>
 
-typedef struct net_device_stats hp100_stats_t;
-
 #include "hp100.h"
 
 /*
@@ -130,23 +128,8 @@
 #define HP100_BUS_EISA    1
 #define HP100_BUS_PCI     2
 
-#ifndef PCI_DEVICE_ID_HP_J2585B
-#define PCI_DEVICE_ID_HP_J2585B 0x1031
-#endif
-#ifndef PCI_VENDOR_ID_COMPEX
-#define PCI_VENDOR_ID_COMPEX 0x11f6
-#endif
-#ifndef PCI_DEVICE_ID_COMPEX_ENET100VG4
-#define PCI_DEVICE_ID_COMPEX_ENET100VG4 0x0112
-#endif
-#ifndef PCI_VENDOR_ID_COMPEX2
-#define PCI_VENDOR_ID_COMPEX2 0x101a
-#endif
-#ifndef PCI_DEVICE_ID_COMPEX2_100VG
-#define PCI_DEVICE_ID_COMPEX2_100VG 0x0005
-#endif
-
 #define HP100_REGION_SIZE	0x20	/* for ioports */
+#define HP100_SIG_LEN		8	/* same as EISA_SIG_LEN */
 
 #define HP100_MAX_PACKET_SIZE	(1536+4)
 #define HP100_MIN_PACKET_SIZE	60
@@ -165,20 +148,9 @@
  *  structures
  */
 
-struct hp100_eisa_id {
-	u_int id;
-	const char *name;
-	u_char bus;
-};
-
-struct hp100_pci_id {
-	u_short vendor;
-	u_short device;
-};
-
 struct hp100_private {
-	struct hp100_eisa_id *id;
 	spinlock_t lock;
+	char id[HP100_SIG_LEN];
 	u_short chip;
 	u_short soft_model;
 	u_int memory_size;
@@ -196,7 +168,7 @@
 	u_char mac1_mode;
 	u_char mac2_mode;
 	u_char hash_bytes[8];
-	hp100_stats_t stats;
+	struct net_device_stats stats;
 
 	/* Rings for busmaster mode: */
 	hp100_ring_t *rxrhead;	/* Head (oldest) index into rxring */
@@ -216,83 +188,36 @@
 /*
  *  variables
  */
-
-static struct hp100_eisa_id hp100_eisa_ids[] = {
-
-	/* 10/100 EISA card with revision A Cascade chip */
-	{0x80F1F022, "HP J2577 rev A", HP100_BUS_EISA},
-
-	/* 10/100 ISA card with revision A Cascade chip */
-	{0x50F1F022, "HP J2573 rev A", HP100_BUS_ISA},
-
-	/* 10 only EISA card with Cascade chip */
-	{0x2019F022, "HP 27248B", HP100_BUS_EISA},
-
-	/* 10/100 EISA card with Cascade chip */
-	{0x4019F022, "HP J2577", HP100_BUS_EISA},
-
-	/* 10/100 ISA card with Cascade chip */
-	{0x5019F022, "HP J2573", HP100_BUS_ISA},
-
-	/* 10/100 EISA card with AT&T chip */
-	{0x9019f022, "HP J2577", HP100_BUS_EISA },
-
-	/* 10/100 PCI card - old J2585A */
-	{0x1030103c, "HP J2585A", HP100_BUS_PCI},
-
-	/* 10/100 PCI card - new J2585B - master capable */
-	{0x1041103c, "HP J2585B", HP100_BUS_PCI},
-
-	/* 10 Mbit Combo Adapter */
-	{0x1042103c, "HP J2970", HP100_BUS_PCI},
-
-	/* 10 Mbit 10baseT Adapter */
-	{0x1040103c, "HP J2973", HP100_BUS_PCI},
-
-	/* 10/100 EISA card from Compex */
-	{0x0103180e, "ReadyLink ENET100-VG4", HP100_BUS_EISA},
-
-	/* 10/100 EISA card from Compex - FreedomLine (sq5bpf) */
-	/* Note: plhbrod@mbox.vol.cz reported that same ID have ISA */
-	/*       version of adapter, too... */
-	{0x0104180e, "FreedomLine 100/VG", HP100_BUS_EISA},
-
-	/* 10/100 PCI card from Compex - FreedomLine
-	 *
-	 * I think this card doesn't like aic7178 scsi controller, but
-	 * I haven't tested this much. It works fine on diskless machines.
-	 *                            Jacek Lipkowski <sq5bpf@acid.ch.pw.edu.pl>
-	 */
-	{0x021211f6, "FreedomLine 100/VG", HP100_BUS_PCI},
-
-	/* 10/100 PCI card from Compex (J2585A compatible) */
-	{0x011211f6, "ReadyLink ENET100-VG4", HP100_BUS_PCI},
-	
-	/* 10/100 PCI card from KTI */
-	{0x40008e2e, "KTI DP-200", HP100_BUS_PCI }
+static const char *hp100_isa_tbl[] = {
+	"HWPF150", /* HP J2573 rev A */
+	"HWP1950", /* HP J2573 */
 };
 
-#define HP100_EISA_IDS_SIZE	(sizeof(hp100_eisa_ids)/sizeof(struct hp100_eisa_id))
-
-#ifdef CONFIG_PCI
-static struct hp100_pci_id hp100_pci_ids[] = {
-	{PCI_VENDOR_ID_HP, PCI_DEVICE_ID_HP_J2585A},
-	{PCI_VENDOR_ID_HP, PCI_DEVICE_ID_HP_J2585B},
-	{PCI_VENDOR_ID_COMPEX, PCI_DEVICE_ID_COMPEX_ENET100VG4},
-	{PCI_VENDOR_ID_COMPEX2, PCI_DEVICE_ID_COMPEX2_100VG}
+#ifdef CONFIG_EISA
+static struct eisa_device_id hp100_eisa_tbl[] = {
+	{ "HWPF180" }, /* HP J2577 rev A */
+	{ "HWP1920" }, /* HP 27248B */
+	{ "HWP1940" }, /* HP J2577 */
+	{ "HWP1990" }, /* HP J2577 */
+	{ "CPX0301" }, /* ReadyLink ENET100-VG4 */
+	{ "CPX0401" }, /* FreedomLine 100/VG */
 };
+MODULE_DEVICE_TABLE(eisa, hp100_eisa_tbl);
 #endif
 
-#define HP100_PCI_IDS_SIZE	(sizeof(hp100_pci_ids)/sizeof(struct hp100_pci_id))
-
+#ifdef CONFIG_PCI
 static struct pci_device_id hp100_pci_tbl[] = {
 	{PCI_VENDOR_ID_HP, PCI_DEVICE_ID_HP_J2585A, PCI_ANY_ID, PCI_ANY_ID,},
 	{PCI_VENDOR_ID_HP, PCI_DEVICE_ID_HP_J2585B, PCI_ANY_ID, PCI_ANY_ID,},
+	{PCI_VENDOR_ID_HP, PCI_DEVICE_ID_HP_J2970A, PCI_ANY_ID, PCI_ANY_ID,},
+	{PCI_VENDOR_ID_HP, PCI_DEVICE_ID_HP_J2973A, PCI_ANY_ID, PCI_ANY_ID,},
 	{PCI_VENDOR_ID_COMPEX, PCI_DEVICE_ID_COMPEX_ENET100VG4, PCI_ANY_ID, PCI_ANY_ID,},
 	{PCI_VENDOR_ID_COMPEX2, PCI_DEVICE_ID_COMPEX2_100VG, PCI_ANY_ID, PCI_ANY_ID,},
+/*	{PCI_VENDOR_ID_KTI, PCI_DEVICE_ID_KTI_DP200, PCI_ANY_ID, PCI_ANY_ID }, */
 	{}			/* Terminating entry */
 };
 MODULE_DEVICE_TABLE(pci, hp100_pci_tbl);
+#endif
 
 static int hp100_rx_ratio = HP100_DEFAULT_RX_RATIO;
 static int hp100_priority_tx = HP100_DEFAULT_PRIORITY_TX;
@@ -316,7 +241,7 @@
 static int hp100_start_xmit_bm(struct sk_buff *skb,
 			       struct net_device *dev);
 static void hp100_rx(struct net_device *dev);
-static hp100_stats_t *hp100_get_stats(struct net_device *dev);
+static struct net_device_stats *hp100_get_stats(struct net_device *dev);
 static void hp100_misc_interrupt(struct net_device *dev);
 static void hp100_update_stats(struct net_device *dev);
 static void hp100_clear_stats(struct hp100_private *lp, int ioaddr);
@@ -370,196 +295,180 @@
  *  since this could cause problems when the card is not installed.
  */
 
-int __init hp100_probe(struct net_device *dev)
+/*
+ * Read board id and convert to string.
+ * Effectively same code as decode_eisa_sig
+ */
+static __init const char *hp100_read_id(int ioaddr)
 {
-	int base_addr = dev ? dev->base_addr : 0;
-	int ioaddr = 0;
-	int pci_start_index = 0;
+	int i;
+	static char str[HP100_SIG_LEN];
+	unsigned char sig[4], sum;
+        unsigned short rev;
 
-#ifdef HP100_DEBUG_B
-	hp100_outw(0x4200, TRACE);
-	printk("hp100: %s: probe\n", dev->name);
-#endif
+	hp100_page(ID_MAC_ADDR);
+	sum = 0;
+	for (i = 0; i < 4; i++) {
+		sig[i] = hp100_inb(BOARD_ID + i);
+		sum += sig[i];
+	}
 
-	if (base_addr > 0xff) {	/* Check a single specified location. */
-		if (check_region(base_addr, HP100_REGION_SIZE))
-			return -EINVAL;
-		if (base_addr < 0x400)
-			return hp100_probe1(dev, base_addr, HP100_BUS_ISA,
-					    NULL);
-		if (EISA_bus && base_addr >= 0x1c38 && ((base_addr - 0x1c38) & 0x3ff) == 0)
-			return hp100_probe1(dev, base_addr, HP100_BUS_EISA, NULL);
-#ifdef CONFIG_PCI
-		printk("hp100: %s: You must specify card # in i/o address parameter for PCI bus...", dev->name);
-#else
-		return -ENODEV;
-#endif
-	} else
-#ifdef CONFIG_PCI
-		if (base_addr > 0 && base_addr < 8 + 1)
-			pci_start_index = 0x100 | (base_addr - 1);
-	  else
-#endif
-		if (base_addr != 0)
-			return -ENXIO;
+	sum += hp100_inb(BOARD_ID + i);
+	if (sum != 0xff)
+		return NULL;	/* bad checksum */
 
-	/* First: scan PCI bus(es) */
+        str[0] = ((sig[0] >> 2) & 0x1f) + ('A' - 1);
+        str[1] = (((sig[0] & 3) << 3) | (sig[1] >> 5)) + ('A' - 1);
+        str[2] = (sig[1] & 0x1f) + ('A' - 1);
+        rev = (sig[2] << 8) | sig[3];
+        sprintf(str + 3, "%04X", rev);
 
-#ifdef CONFIG_PCI
-	{
-		int pci_index;
-		struct pci_dev *pci_dev = NULL;
-		int pci_id_index;
-		u_short pci_command;
-
-#ifdef HP100_DEBUG_PCI
-		printk("hp100: %s: PCI BIOS is present, checking for devices..\n", dev->name);
-#endif
-		pci_index = 0;
-		for (pci_id_index = 0; pci_id_index < HP100_PCI_IDS_SIZE;
-		     pci_id_index++) {
-			while ((pci_dev = pci_find_device(hp100_pci_ids[pci_id_index].vendor,
-							  hp100_pci_ids[pci_id_index].device,
-							  pci_dev)) != NULL) {
-				if (pci_index < (pci_start_index & 7)) {
-					pci_index++;
-					continue;
-				}
-				if (pci_enable_device(pci_dev))
-					continue;
-				/* found... */
-				ioaddr = pci_resource_start(pci_dev, 0);
-				if (check_region(ioaddr, HP100_REGION_SIZE))
-					continue;
-				pci_read_config_word(pci_dev, PCI_COMMAND, &pci_command);
-				if (!(pci_command & PCI_COMMAND_IO)) {
-#ifdef HP100_DEBUG
-					printk("hp100: %s: PCI I/O Bit has not been set. Setting...\n", dev->name);
-#endif
-					pci_command |= PCI_COMMAND_IO;
-					pci_write_config_word(pci_dev, PCI_COMMAND, pci_command);
-				}
-				if (!(pci_command & PCI_COMMAND_MASTER)) {
-#ifdef HP100_DEBUG
-					printk("hp100: %s: PCI Master Bit has not been set. Setting...\n", dev->name);
-#endif
-					pci_command |= PCI_COMMAND_MASTER;
-					pci_write_config_word(pci_dev, PCI_COMMAND, pci_command);
-				}
-#ifdef HP100_DEBUG
-				printk("hp100: %s: PCI adapter found at 0x%x\n", dev->name, ioaddr);
-#endif
-				if (hp100_probe1(dev, ioaddr, HP100_BUS_PCI, pci_dev) == 0)
-					return 0;
-			}
-		}
-	}
-	if (pci_start_index > 0)
-		return -ENODEV;
-#endif /* CONFIG_PCI */
+	return str;
+}
 
-	/* Second: Probe all EISA possible port regions (if EISA bus present) */
-	for (ioaddr = 0x1c38; EISA_bus && ioaddr < 0x10000; ioaddr += 0x400) {
-		if (check_region(ioaddr, HP100_REGION_SIZE))
-			continue;
-		if (hp100_probe1(dev, ioaddr, HP100_BUS_EISA, NULL) == 0)
-			return 0;
-	}
+static __init int hp100_isa_probe1(struct net_device *dev, int addr)
+{
+	const char *sig;
+	int i;
+
+	if (!request_region(addr, HP100_REGION_SIZE, "hp100"))
+		goto err;
+
+	sig = hp100_read_id(addr);
+	release_region(addr, HP100_REGION_SIZE);
+
+	if (sig == NULL)
+		goto err;
+
+	for (i = 0; i < ARRAY_SIZE(hp100_isa_tbl); i++) {
+		if (!strcmp(hp100_isa_tbl[i], sig)) 
+			break;
 
-	/* Third: Probe all ISA possible port regions */
-	for (ioaddr = 0x100; ioaddr < 0x400; ioaddr += 0x20) {
-		if (check_region(ioaddr, HP100_REGION_SIZE))
-			continue;
-		if (hp100_probe1(dev, ioaddr, HP100_BUS_ISA, NULL) == 0)
-			return 0;
 	}
 
+	if (i < ARRAY_SIZE(hp100_isa_tbl))
+		return hp100_probe1(dev, addr, HP100_BUS_ISA, NULL);
+ err:
 	return -ENODEV;
+
+}
+/*
+ * Probe for ISA board.
+ * EISA and PCI are handled by device infrastructure.
+ */
+
+static int  __init hp100_isa_probe(struct net_device *dev, int addr)
+{
+	int err = -ENODEV;
+
+	/* Probe for a specific ISA address */		
+	if (addr > 0xff && addr < 0x400)
+		err = hp100_isa_probe1(dev, addr);
+
+	else if (addr != 0) 
+		err = -ENXIO;
+
+	else {
+		/* Probe all ISA possible port regions */
+		for (addr = 0x100; addr < 0x400; addr += 0x20) {
+			err = hp100_isa_probe1(dev, addr);
+			if (!err)
+				break;
+		}
+	}
+	return err;
+}
+
+
+struct net_device * __init hp100_probe(int unit)
+{
+	struct net_device *dev = alloc_etherdev(sizeof(struct hp100_private));
+	int err;
+
+	if (!dev)
+		return ERR_PTR(-ENODEV);
+
+	SET_MODULE_OWNER(dev);
+
+#ifdef HP100_DEBUG_B
+	hp100_outw(0x4200, TRACE);
+	printk("hp100: %s: probe\n", dev->name);
+#endif
+
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+	}
+
+	err = hp100_isa_probe(dev, dev->base_addr);
+	if (err)
+		goto out;
+
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	return dev;
+ out1:
+	release_region(dev->base_addr, HP100_REGION_SIZE);
+ out:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 static int __init hp100_probe1(struct net_device *dev, int ioaddr,
 			       u_char bus, struct pci_dev *pci_dev)
 {
 	int i;
-
-	u_char uc, uc_1;
-	u_int eisa_id;
+	int err = -ENODEV;
+	const char *eid;
 	u_int chip;
+	u_char uc;
 	u_int memory_size = 0, virt_memory_size = 0;
 	u_short local_mode, lsw;
 	short mem_mapped;
 	unsigned long mem_ptr_phys;
 	void **mem_ptr_virt;
 	struct hp100_private *lp;
-	struct hp100_eisa_id *eid;
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4201, TRACE);
 	printk("hp100: %s: probe1\n", dev->name);
 #endif
 
-	if (dev == NULL) {
-#ifdef HP100_DEBUG
-		printk("hp100_probe1: %s: dev == NULL ?\n", dev->name);
-#endif
-		return -EIO;
-	}
+	/* memory region for programmed i/o */
+	if (!request_region(ioaddr, HP100_REGION_SIZE, "hp100"))
+		goto out1;
 
-	if (hp100_inw(HW_ID) != HP100_HW_ID_CASCADE) {
-		return -ENODEV;
-	} else {
-		chip = hp100_inw(PAGING) & HP100_CHIPID_MASK;
+	if (hp100_inw(HW_ID) != HP100_HW_ID_CASCADE) 
+		goto out2;
+
+	chip = hp100_inw(PAGING) & HP100_CHIPID_MASK;
 #ifdef HP100_DEBUG
-		if (chip == HP100_CHIPID_SHASTA)
-			printk("hp100: %s: Shasta Chip detected. (This is a pre 802.12 chip)\n", dev->name);
-		else if (chip == HP100_CHIPID_RAINIER)
-			printk("hp100: %s: Rainier Chip detected. (This is a pre 802.12 chip)\n", dev->name);
-		else if (chip == HP100_CHIPID_LASSEN)
-			printk("hp100: %s: Lassen Chip detected.\n", dev->name);
-		else
-			printk("hp100: %s: Warning: Unknown CASCADE chip (id=0x%.4x).\n", dev->name, chip);
+	if (chip == HP100_CHIPID_SHASTA)
+		printk("hp100: %s: Shasta Chip detected. (This is a pre 802.12 chip)\n", dev->name);
+	else if (chip == HP100_CHIPID_RAINIER)
+		printk("hp100: %s: Rainier Chip detected. (This is a pre 802.12 chip)\n", dev->name);
+	else if (chip == HP100_CHIPID_LASSEN)
+		printk("hp100: %s: Lassen Chip detected.\n", dev->name);
+	else
+		printk("hp100: %s: Warning: Unknown CASCADE chip (id=0x%.4x).\n", dev->name, chip);
 #endif
-	}
 
 	dev->base_addr = ioaddr;
 
-	hp100_page(ID_MAC_ADDR);
-	for (i = uc = eisa_id = 0; i < 4; i++) {
-		eisa_id >>= 8;
-		uc_1 = hp100_inb(BOARD_ID + i);
-		eisa_id |= uc_1 << 24;
-		uc += uc_1;
-	}
-	uc += hp100_inb(BOARD_ID + 4);
-
-	if (uc != 0xff) {	/* bad checksum? */
-		printk("hp100_probe: %s: bad EISA ID checksum at base port 0x%x\n", dev->name, ioaddr);
-		return -ENODEV;
-	}
-
-	for (i = 0; i < HP100_EISA_IDS_SIZE; i++)
-		if (hp100_eisa_ids[i].id == eisa_id)
-			break;
-	if (i >= HP100_EISA_IDS_SIZE) {
-		for (i = 0; i < HP100_EISA_IDS_SIZE; i++)
-			if ((hp100_eisa_ids[i].id & 0xf0ffffff) == (eisa_id & 0xf0ffffff))
-				break;
-		if (i >= HP100_EISA_IDS_SIZE) {
-			printk ("hp100_probe: %s: card at port 0x%x isn't known (id = 0x%x)\n", dev->name, ioaddr, eisa_id);
-			return -ENODEV;
-		}
-	}
-	eid = &hp100_eisa_ids[i];
-	if ((eid->id & 0x0f000000) < (eisa_id & 0x0f000000)) {
-		printk("hp100_probe: %s: newer version of card %s at port 0x%x - unsupported\n", dev->name, eid->name, ioaddr);
-		return -ENODEV;
+	eid = hp100_read_id(ioaddr);
+	if (eid == NULL) {	/* bad checksum? */
+		printk(KERN_WARNING "hp100_probe: bad ID checksum at base port 0x%x\n", ioaddr);
+		goto out2;
 	}
 
+	hp100_page(ID_MAC_ADDR);
 	for (i = uc = 0; i < 7; i++)
 		uc += hp100_inb(LAN_ADDR + i);
 	if (uc != 0xff) {
-		printk("hp100_probe: %s: bad lan address checksum (card %s at port 0x%x)\n", dev->name, eid->name, ioaddr);
-		return -EIO;
+		printk(KERN_WARNING "hp100_probe: bad lan address checksum at port 0x%x)\n", ioaddr);
+		err = -EIO;
+		goto out2;
 	}
 
 	/* Make sure, that all registers are correctly updated... */
@@ -607,17 +516,17 @@
 		hp100_outw(HP100_MEM_EN | HP100_RESET_LB, OPTION_LSW);
 		hp100_outw(HP100_IO_EN | HP100_SET_LB, OPTION_LSW);
 		hp100_outw(HP100_BM_WRITE | HP100_BM_READ | HP100_RESET_HB, OPTION_LSW);
-		printk("hp100: %s: IO mapped mode forced.\n", dev->name);
+		printk("hp100: IO mapped mode forced.\n");
 	} else if (local_mode == 2) {
 		hp100_outw(HP100_MEM_EN | HP100_SET_LB, OPTION_LSW);
 		hp100_outw(HP100_IO_EN | HP100_SET_LB, OPTION_LSW);
 		hp100_outw(HP100_BM_WRITE | HP100_BM_READ | HP100_RESET_HB, OPTION_LSW);
-		printk("hp100: %s: Shared memory mode requested.\n", dev->name);
+		printk("hp100: Shared memory mode requested.\n");
 	} else if (local_mode == 4) {
 		if (chip == HP100_CHIPID_LASSEN) {
 			hp100_outw(HP100_BM_WRITE | HP100_BM_READ | HP100_SET_HB, OPTION_LSW);
 			hp100_outw(HP100_IO_EN | HP100_MEM_EN | HP100_RESET_LB, OPTION_LSW);
-			printk("hp100: %s: Busmaster mode requested.\n", dev->name);
+			printk("hp100: Busmaster mode requested.\n");
 		}
 		local_mode = 1;
 	}
@@ -643,7 +552,7 @@
 				/* Gracefully fallback to shared memory */
 				goto busmasterfail;
 			}
-			printk("hp100: %s: Busmaster mode enabled.\n", dev->name);
+			printk("hp100: Busmaster mode enabled.\n");
 			hp100_outw(HP100_MEM_EN | HP100_IO_EN | HP100_RESET_LB, OPTION_LSW);
 		} else {
 		busmasterfail:
@@ -675,7 +584,7 @@
 		mem_ptr_phys &= ~0x1fff;	/* 8k alignment */
 
 		if (bus == HP100_BUS_ISA && (mem_ptr_phys & ~0xfffff) != 0) {
-			printk("hp100: %s: Can only use programmed i/o mode.\n", dev->name);
+			printk("hp100: Can only use programmed i/o mode.\n");
 			mem_ptr_phys = 0;
 			mem_mapped = 0;
 			local_mode = 3;	/* Use programmed i/o */
@@ -699,7 +608,7 @@
 			}
 
 			if (mem_ptr_virt == NULL) {	/* all ioremap tries failed */
-				printk("hp100: %s: Failed to ioremap the PCI card memory. Will have to use i/o mapped mode.\n", dev->name);
+				printk("hp100: Failed to ioremap the PCI card memory. Will have to use i/o mapped mode.\n");
 				local_mode = 3;
 				virt_memory_size = 0;
 			}
@@ -710,17 +619,14 @@
 		mem_mapped = 0;
 		mem_ptr_phys = 0;
 		mem_ptr_virt = NULL;
-		printk("hp100: %s: Using (slow) programmed i/o mode.\n", dev->name);
+		printk("hp100: Using (slow) programmed i/o mode.\n");
 	}
 
 	/* Initialise the "private" data structure for this card. */
-	if ((dev->priv = kmalloc(sizeof(struct hp100_private), GFP_KERNEL)) == NULL)
-		return -ENOMEM;
-
 	lp = (struct hp100_private *) dev->priv;
-	memset(lp, 0, sizeof(struct hp100_private));
+
 	spin_lock_init(&lp->lock);
-	lp->id = eid;
+	strlcpy(lp->id, eid, HP100_SIG_LEN);
 	lp->chip = chip;
 	lp->mode = local_mode;
 	lp->bus = bus;
@@ -741,9 +647,6 @@
 	lp->virt_memory_size = virt_memory_size;
 	lp->rx_ratio = hp100_rx_ratio;	/* can be conf'd with insmod */
 
-	/* memory region for programmed i/o */
-	request_region(dev->base_addr, HP100_REGION_SIZE, eid->name);
-
 	dev->open = hp100_open;
 	dev->stop = hp100_close;
 
@@ -776,10 +679,6 @@
 	/* Reset statistics (counters) */
 	hp100_clear_stats(lp, ioaddr);
 
-	SET_MODULE_OWNER(dev);
-	SET_NETDEV_DEV(dev, &pci_dev->dev);
-	ether_setup(dev);
-
 	/* If busmaster mode is wanted, a dma-capable memory area is needed for
 	 * the rx and tx PDLs 
 	 * PCI cards can access the whole PC memory. Therefore GFP_DMA is not
@@ -795,8 +694,10 @@
 		/* Conversion to new PCI API :
 		 * Pages are always aligned and zeroed, no need to it ourself.
 		 * Doc says should be OK for EISA bus as well - Jean II */
-		if ((lp->page_vaddr_algn = pci_alloc_consistent(lp->pci_dev, MAX_RINGSIZE, &page_baddr)) == NULL)
-			return -ENOMEM;
+		if ((lp->page_vaddr_algn = pci_alloc_consistent(lp->pci_dev, MAX_RINGSIZE, &page_baddr)) == NULL) {
+			err = -ENOMEM;
+			goto out2;
+		}
 		lp->whatever_offset = ((u_long) page_baddr) - ((u_long) lp->page_vaddr_algn);
 
 #ifdef HP100_DEBUG_BM
@@ -818,7 +719,7 @@
 	lp->lan_type = hp100_sense_lan(dev);
 
 	/* Print out a message what about what we think we have probed. */
-	printk("hp100: %s: %s at 0x%x, IRQ %d, ", dev->name, lp->id->name, ioaddr, dev->irq);
+	printk("hp100: at 0x%x, IRQ %d, ", ioaddr, dev->irq);
 	switch (bus) {
 	case HP100_BUS_EISA:
 		printk("EISA");
@@ -833,7 +734,7 @@
 	printk(" bus, %dk SRAM (rx/tx %d%%).\n", lp->memory_size >> 10, lp->rx_ratio);
 
 	if (lp->mode == 2) {	/* memory mapped */
-		printk("hp100: %s: Memory area at 0x%lx-0x%lx", dev->name, mem_ptr_phys,
+		printk("hp100: Memory area at 0x%lx-0x%lx", mem_ptr_phys,
 				(mem_ptr_phys + (mem_ptr_phys > 0x100000 ? (u_long) lp->memory_size : 16 * 1024)) - 1);
 		if (mem_ptr_virt)
 			printk(" (virtual base %p)", mem_ptr_virt);
@@ -843,7 +744,8 @@
 		dev->mem_start = mem_ptr_phys;
 		dev->mem_end = mem_ptr_phys + lp->memory_size;
 	}
-	printk("hp100: %s: ", dev->name);
+
+	printk("hp100: ");
 	if (lp->lan_type != HP100_LAN_ERR)
 		printk("Adapter is attached to ");
 	switch (lp->lan_type) {
@@ -861,6 +763,10 @@
 	}
 
 	return 0;
+out2:
+	release_region(ioaddr, HP100_REGION_SIZE);
+out1:
+	return -ENODEV;
 }
 
 /* This procedure puts the card into a stable init state */
@@ -950,6 +856,7 @@
 	/* Finally try to log in the Hub if there may be a VG connection. */
 	if ((lp->lan_type == HP100_LAN_100) || (lp->lan_type == HP100_LAN_ERR))
 		hp100_login_to_vg_hub(dev, 0);	/* relogin */
+
 }
 
 
@@ -1152,7 +1059,7 @@
 	if (request_irq(dev->irq, hp100_interrupt,
 			lp->bus == HP100_BUS_PCI || lp->bus ==
 			HP100_BUS_EISA ? SA_SHIRQ : SA_INTERRUPT,
-			lp->id->name, dev)) {
+			"hp100", dev)) {
 		printk("hp100: %s: unable to get IRQ %d\n", dev->name, dev->irq);
 		return -EAGAIN;
 	}
@@ -2054,7 +1961,7 @@
 /*
  *  statistics
  */
-static hp100_stats_t *hp100_get_stats(struct net_device *dev)
+static struct net_device_stats *hp100_get_stats(struct net_device *dev)
 {
 	unsigned long flags;
 	int ioaddr = dev->base_addr;
@@ -2558,10 +2465,14 @@
 		return HP100_LAN_COAX;
 	}
 
-	if ((lp->id->id == 0x02019F022) ||
-	    (lp->id->id == 0x01042103c) || (lp->id->id == 0x01040103c))
-		return HP100_LAN_ERR;	/* Those cards don't have a 100 Mbit connector */
-
+	/* Those cards don't have a 100 Mbit connector */
+	if ( !strcmp(lp->id, "HWP1920")  ||
+	     (lp->pci_dev && 
+	      lp->pci_dev->vendor == PCI_VENDOR_ID && 
+	      (lp->pci_dev->device == PCI_DEVICE_ID_HP_J2970A ||
+	       lp->pci_dev->device == PCI_DEVICE_ID_HP_J2973A)))
+		return HP100_LAN_ERR;
+	
 	if (val_VG & HP100_LINK_CABLE_ST)	/* Can hear the HUBs tone. */
 		return HP100_LAN_100;
 	return HP100_LAN_ERR;
@@ -2915,121 +2826,247 @@
 #endif
 
 
+static void cleanup_dev(struct net_device *d)
+{
+	struct hp100_private *p = (struct hp100_private *) d->priv;
+
+	unregister_netdev(d);
+	release_region(d->base_addr, HP100_REGION_SIZE);
+
+	if (p->mode == 1)	/* busmaster */
+		pci_free_consistent(p->pci_dev, MAX_RINGSIZE + 0x0f, 
+				    p->page_vaddr_algn, 
+				    virt_to_whatever(d, p->page_vaddr_algn));
+	if (p->mem_ptr_virt)
+		iounmap(p->mem_ptr_virt);
+
+	free_netdev(d);
+}
+
+#ifdef CONFIG_EISA
+static int __init hp100_eisa_probe (struct device *gendev)
+{
+	struct net_device *dev = alloc_etherdev(sizeof(struct hp100_private));
+	struct eisa_device *edev = to_eisa_device(gendev);
+	int err;
+
+	if (!dev)
+		return -ENOMEM;
+
+	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &edev->dev);
+
+	err = hp100_probe1(dev, edev->base_addr, HP100_BUS_EISA, NULL);
+	if (err)
+		goto out1;
+
+	err = register_netdev(dev);
+	if (err)
+		goto out2;
+	
+#ifdef HP100_DEBUG
+	printk("hp100: %s: EISA adapter found at 0x%x\n", dev->name, 
+	       dev->base_addr);
+#endif
+	gendev->driver_data = dev;
+	return 0;
+ out2:
+	release_region(dev->base_addr, HP100_REGION_SIZE);
+ out1:
+	free_netdev(dev);
+	return err;
+}
+
+static int __devexit hp100_eisa_remove (struct device *gendev)
+{
+	struct net_device *dev = gendev->driver_data;
+	cleanup_dev(dev);
+	return 0;
+}
+
+static struct eisa_driver hp100_eisa_driver = {
+        .id_table = hp100_eisa_tbl,
+        .driver   = {
+                .name    = "hp100",
+                .probe   = hp100_eisa_probe,
+                .remove  = __devexit_p (hp100_eisa_remove),
+        }
+};
+#endif
+
+#ifdef CONFIG_PCI
+static int __devinit hp100_pci_probe (struct pci_dev *pdev,
+				     const struct pci_device_id *ent)
+{
+	struct net_device *dev = alloc_etherdev(sizeof(struct hp100_private));
+	int ioaddr = pci_resource_start(pdev, 0);
+	u_short pci_command;
+	int err;
+	
+	if (!dev)
+		return -ENOMEM;
+
+	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
+
+	pci_read_config_word(pdev, PCI_COMMAND, &pci_command);
+	if (!(pci_command & PCI_COMMAND_IO)) {
+#ifdef HP100_DEBUG
+		printk("hp100: %s: PCI I/O Bit has not been set. Setting...\n", dev->name);
+#endif
+		pci_command |= PCI_COMMAND_IO;
+		pci_write_config_word(pdev, PCI_COMMAND, pci_command);
+	}
+
+	if (!(pci_command & PCI_COMMAND_MASTER)) {
+#ifdef HP100_DEBUG
+		printk("hp100: %s: PCI Master Bit has not been set. Setting...\n", dev->name);
+#endif
+		pci_command |= PCI_COMMAND_MASTER;
+		pci_write_config_word(pdev, PCI_COMMAND, pci_command);
+	}
+	
+
+	err = hp100_probe1(dev, ioaddr, HP100_BUS_PCI, pdev);
+	if (err) 
+		goto out1;
+	err = register_netdev(dev);
+	if (err)
+		goto out2;
+	
+#ifdef HP100_DEBUG
+	printk("hp100: %s: PCI adapter found at 0x%x\n", dev->name, ioaddr);
+#endif
+	pci_set_drvdata(pdev, dev);
+	return 0;
+ out2:
+	release_region(dev->base_addr, HP100_REGION_SIZE);
+ out1:
+	free_netdev(dev);
+	return err;
+}
+
+static void __devexit hp100_pci_remove (struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+
+	cleanup_dev(dev);
+}
+
+
+static struct pci_driver hp100_pci_driver = {
+	.name		= "hp100",
+	.id_table	= hp100_pci_tbl,
+	.probe		= hp100_pci_probe,
+	.remove		= __devexit_p(hp100_pci_remove),
+};
+#endif
+
 /*
  *  module section
  */
 
-#ifdef MODULE
-
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jaroslav Kysela <perex@suse.cz>, "
               "Siegfried \"Frieder\" Loeffler (dg1sek) <floeff@mathematik.uni-stuttgart.de>");
 MODULE_DESCRIPTION("HP CASCADE Architecture Driver for 100VG-AnyLan Network Adapters");
 
 /*
- * Note: if you have more than five 100vg cards in your pc, feel free to
- * increase this value 
- */
-
-#define HP100_DEVICES 5
-
-/*
- * Note: to register three eisa or pci devices, use:
+ * Note: to register three isa devices, use:
  * option hp100 hp100_port=0,0,0
  *        to register one card at io 0x280 as eth239, use:
- * option hp100 hp100_port=0x280 hp100_name=eth239
+ * option hp100 hp100_port=0x280
  */
-
+#if defined(MODULE) && defined(CONFIG_ISA)
+#define HP100_DEVICES 5
 /* Parameters set by insmod */
 static int hp100_port[HP100_DEVICES] = { 0, [1 ... (HP100_DEVICES-1)] = -1 };
 MODULE_PARM(hp100_port, "1-" __MODULE_STRING(HP100_DEVICES) "i");
 
-/* Allocate HP100_DEVICES strings of length IFNAMSIZ, one string for each device */
-static char hp100_name[HP100_DEVICES][IFNAMSIZ] = { "", "", "", "", "" };
-/* Allow insmod to write those HP100_DEVICES strings individually */
-MODULE_PARM(hp100_name, "1-" __MODULE_STRING(HP100_DEVICES) "c" __MODULE_STRING(IFNAMSIZ));
-
 /* List of devices */
 static struct net_device *hp100_devlist[HP100_DEVICES];
 
-static void release_dev(int i)
+static int __init hp100_isa_init(void)
 {
-	struct net_device *d = hp100_devlist[i];
-	struct hp100_private *p = (struct hp100_private *) d->priv;
+	struct net_device *dev;
+	int i, err, cards = 0;
 
-	unregister_netdev(d);
-	release_region(d->base_addr, HP100_REGION_SIZE);
+	/* Don't autoprobe ISA bus */
+	if (hp100_port[0] == 0)
+		return -ENODEV;
 
-	if (p->mode == 1)	/* busmaster */
-		pci_free_consistent(p->pci_dev, MAX_RINGSIZE + 0x0f, p->page_vaddr_algn, virt_to_whatever(d, p->page_vaddr_algn));
-	if (p->mem_ptr_virt)
-		iounmap(p->mem_ptr_virt);
-	kfree(d->priv);
-	d->priv = NULL;
-	free_netdev(d);
-	hp100_devlist[i] = NULL;
+	/* Loop on all possible base addresses */
+	for (i = 0; i < HP100_DEVICES && hp100_port[i] != -1; ++i) {
+		dev = alloc_etherdev(sizeof(struct hp100_private));
+		if (!dev) {
+			printk(KERN_WARNING "hp100: no memory for network device\n");
+			while (cards > 0)
+				cleanup_dev(hp100_devlist[--cards]);
+
+			return -ENOMEM;
+		}
+		SET_MODULE_OWNER(dev);
+
+		err = hp100_isa_probe(dev, hp100_port[i]);
+		if (!err) {
+			err = register_netdev(dev);
+			if (!err) 
+				hp100_devlist[cards++] = dev;
+			else
+				release_region(dev->base_addr, HP100_REGION_SIZE);
+		}
+
+		if (err)
+			free_netdev(dev);
+	}
+
+	return cards > 0 ? 0 : -ENODEV;
 }
 
-static int __init hp100_module_init(void)
+static void __exit hp100_isa_cleanup(void) 
 {
-	int i, cards;
+	int i;
 
-#ifndef CONFIG_PCI
-	if (hp100_port == 0 && !EISA_bus)
-		printk("hp100: You should not use auto-probing with insmod!\n");
+	for (i = 0; i < HP100_DEVICES; i++) {
+		struct net_device *dev = hp100_devlist[i];
+		if (dev)
+			cleanup_dev(dev);
+	}
+}
+#else
+#define hp100_isa_init()	(0)
+#define hp100_isa_cleanup()	do { } while(0)
 #endif
 
-	/* Loop on all possible base addresses */
-	i = -1;
-	cards = 0;
-	while ((hp100_port[++i] != -1) && (i < HP100_DEVICES)) {
-		/* Create device and set basics args */
-		hp100_devlist[i] = kmalloc(sizeof(struct net_device), GFP_KERNEL);
-		if (!hp100_devlist[i])
-			goto fail;
-		memset(hp100_devlist[i], 0x00, sizeof(struct net_device));
-#if LINUX_VERSION_CODE >= 0x020362	/* 2.3.99-pre7 */
-		memcpy(hp100_devlist[i]->name, hp100_name[i], IFNAMSIZ);	/* Copy name */
-#else
-		hp100_devlist[i]->name = hp100_name[i];
-#endif				/* LINUX_VERSION_CODE >= 0x020362 */
-		hp100_devlist[i]->base_addr = hp100_port[i];
-		hp100_devlist[i]->init = &hp100_probe;
-
-		/* Try to create the device */
-		if (register_netdev(hp100_devlist[i]) != 0) {
-			/* DeAllocate everything */
-			/* Note: if dev->priv is mallocated, there is no way to fail */
-			kfree(hp100_devlist[i]);
-			hp100_devlist[i] = (struct net_device *) NULL;
-		} else
-			cards++;
-	}			/* Loop over all devices */
+static int __init hp100_module_init(void)
+{
+	int err;
 
-	return cards > 0 ? 0 : -ENODEV;
-      fail:
-	while (cards && --i)
-		if (hp100_devlist[i]) {
-			release_dev(i);
-			--cards;
-		}
-	return -ENOMEM;
+	err = hp100_isa_init();
+
+#ifdef CONFIG_EISA
+	err |= eisa_driver_register(&hp100_eisa_driver);
+#endif
+#ifdef CONFIG_PCI
+	err |= pci_module_init(&hp100_pci_driver);
+#endif
+	return err;
 }
 
+
 static void __exit hp100_module_exit(void)
 {
-	int i;
-
-	/* TODO: Check if all skb's are released/freed. */
-	for (i = 0; i < HP100_DEVICES; i++)
-		if (hp100_devlist[i] != (struct net_device *) NULL)
-			release_dev(i);
+	hp100_isa_cleanup();
+#ifdef CONFIG_EISA
+	eisa_driver_unregister (&hp100_eisa_driver);
+#endif
+#ifdef CONFIG_PCI
+	pci_unregister_driver (&hp100_pci_driver);
+#endif
 }
 
 module_init(hp100_module_init)
 module_exit(hp100_module_exit)
-
-#endif				/* MODULE */
 
 
 /*
diff -Nru a/include/linux/pci_ids.h b/include/linux/pci_ids.h
--- a/include/linux/pci_ids.h	Wed Nov 12 14:44:05 2003
+++ b/include/linux/pci_ids.h	Wed Nov 12 14:44:05 2003
@@ -626,6 +626,8 @@
 #define PCI_DEVICE_ID_HP_TACHLITE	0x1029
 #define PCI_DEVICE_ID_HP_J2585A		0x1030
 #define PCI_DEVICE_ID_HP_J2585B		0x1031
+#define PCI_DEVICE_ID_HP_J2973A		0x1040
+#define PCI_DEVICE_ID_HP_J2970A		0x1042
 #define PCI_DEVICE_ID_HP_DIVA		0x1048
 #define PCI_DEVICE_ID_HP_DIVA_TOSCA1	0x1049
 #define PCI_DEVICE_ID_HP_DIVA_TOSCA2	0x104A
