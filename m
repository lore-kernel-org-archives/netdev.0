From: Marc Zyngier <mzyngier@freesurf.fr>
Subject: [PATCH][2.6] depca update
Date: Tue, 16 Sep 2003 21:12:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <wrpad94r1j3.fsf@hina.wild-wind.fr.eu.org>
Reply-To: mzyngier@freesurf.fr
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: Andrew Morton <akpm@osdl.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=-=-=

Jeff, Andrew,

I finally found some time to hack the depca driver, in basically the
same way I did with the de4x5 driver. The patch is quite big (shuffles
a lot of code around, removes lots of global variables), mainly in
order to use the driver model on every bus supported by this driver.

I also removed the probing from Space.c, so the usual warning about
device renumbering applies.

Tested on alpha (DE422, EISA) and i386 (two DE201, ISA), built-in and
modular. The MCA part is completly untested, since I lack the hardware
(no, I do not own every single piece of junk hardware out
there... ;-).

Thanks,

        M.


--=-=-=
Content-Type: text/x-patch
Content-Disposition: attachment; filename=depca.patch

--- ../vanilla/linux-2.5/drivers/net/depca.c	2003-05-12 06:53:34.000000000 +0200
+++ linux-2.5/drivers/net/depca.c	2003-09-16 20:40:18.000000000 +0200
@@ -1,4 +1,4 @@
-/*  depca.c: A DIGITAL DEPCA  & EtherWORKS ethernet driver for linux.
+/*  depca.c: A DIGITAL DEPCA & EtherWORKS ethernet driver for linux.
 
     Written 1994, 1995 by David C. Davies.
 
@@ -253,7 +253,8 @@
 #include <linux/types.h>
 #include <linux/unistd.h>
 #include <linux/ctype.h>
-#include <linux/mca-legacy.h>
+#include <linux/moduleparam.h>
+#include <linux/device.h>
 
 #include <asm/uaccess.h>
 #include <asm/bitops.h>
@@ -265,7 +266,6 @@
 #endif
 
 #ifdef CONFIG_EISA
-#include <linux/device.h>
 #include <linux/eisa.h>
 #endif
 
@@ -305,21 +305,21 @@
 ** EISA bus defines
 */
 #define DEPCA_EISA_IO_PORTS 0x0c00	/* I/O port base address, slot 0 */
-#define MAX_EISA_SLOTS 16
-#define EISA_SLOT_INC 0x1000
 
 /*
 ** ISA Bus defines
 */
 #define DEPCA_RAM_BASE_ADDRESSES {0xc0000,0xd0000,0xe0000,0x00000}
-#define DEPCA_IO_PORTS {0x300, 0x200, 0}
 #define DEPCA_TOTAL_SIZE 0x10
-static short mem_chkd;
 
-/*
-** Adapter ID for the MCA EtherWORKS DE210/212 adapter
-*/
-#define DE212_ID 0x6def
+static struct {
+	u_long iobase;
+	struct platform_device *device;
+} depca_io_ports[] = {
+	{ 0x300, NULL },
+	{ 0x200, NULL },
+	{ 0    , NULL },
+};
 
 /*
 ** Name <-> Adapter mapping
@@ -330,34 +330,86 @@
 			 "DE210","DE212",\
                          "DE422",\
                          ""}
-static enum {
+
+static char* __initdata depca_signature[] = DEPCA_SIGNATURE;
+
+enum depca_type {
 	DEPCA, de100, de101, de200, de201, de202, de210, de212, de422, unknown
-} adapter;
+};
+
+static char depca_string[] = "depca";
+
+static int depca_device_remove (struct device *device);
 
 #ifdef CONFIG_EISA
 struct eisa_device_id depca_eisa_ids[] = {
-	{ "DEC4220" },
+	{ "DEC4220", de422 },
 	{ "" }
 };
 
 static int depca_eisa_probe  (struct device *device);
-static int depca_eisa_remove (struct device *device);
 
 struct eisa_driver depca_eisa_driver = {
 	.id_table = depca_eisa_ids,
 	.driver   = {
-		.name    = "depca",
+		.name    = depca_string,
 		.probe   = depca_eisa_probe,
-		.remove  = __devexit_p (depca_eisa_remove)
+		.remove  = __devexit_p (depca_device_remove)
 	}
 };
 #endif
 
+#ifdef CONFIG_MCA
+/*
+** Adapter ID for the MCA EtherWORKS DE210/212 adapter
+*/
+#define DE210_ID 0x628d
+#define DE212_ID 0x6def
+
+static short depca_mca_adapter_ids[] = {
+	DE210_ID,
+	DE212_ID,
+	0x0000
+};
+
+static char *depca_mca_adapter_name[] = {
+	"DEC EtherWORKS MC Adapter (DE210)",
+	"DEC EtherWORKS MC Adapter (DE212)",
+	NULL
+};
+
+static enum depca_type depca_mca_adapter_type[] = {
+	de210,
+	de212,
+	0
+};
+
+static int depca_mca_probe (struct device *);
+
+static struct mca_driver depca_mca_driver = {
+	.id_table = depca_mca_adapter_ids,
+	.driver   = {
+		.name   = depca_string,
+		.bus    = &mca_bus_type,
+		.probe  = depca_mca_probe,
+		.remove = __devexit_p(depca_device_remove),
+	},
+};
+#endif
+
+static int depca_isa_probe (struct device *);
+
+static struct device_driver depca_isa_driver = {
+	.name   = depca_string,
+	.bus    = &platform_bus_type,
+	.probe  = depca_isa_probe,
+	.remove = __devexit_p(depca_device_remove),
+};
+	
 /*
 ** Miscellaneous info...
 */
 #define DEPCA_STRLEN 16
-#define MAX_NUM_DEPCAS 2
 
 /*
 ** Memory Alignment. Each descriptor is 4 longwords long. To force a
@@ -402,10 +454,13 @@
 #define DEPCA_PKT_BIN_SZ  128	/* Should be >=100 unless you
 				   increase DEPCA_PKT_STAT_SZ */
 struct depca_private {
-	char devname[DEPCA_STRLEN];	/* Device Product String                  */
 	char adapter_name[DEPCA_STRLEN];	/* /proc/ioports string                  */
-	char adapter;		/* Adapter type                           */
-	char mca_slot;		/* MCA slot, if MCA else -1               */
+	enum depca_type adapter;		/* Adapter type */
+	enum {
+                DEPCA_BUS_MCA = 1,
+                DEPCA_BUS_ISA,
+                DEPCA_BUS_EISA,
+        } depca_bus;	        /* type of bus */
 	struct depca_init init_block;	/* Shadow Initialization block            */
 /* CPU address space fields */
 	struct depca_rx_desc *rx_ring;	/* Pointer to start of RX descriptor ring */
@@ -467,45 +522,39 @@
 /*
 ** Private functions
 */
-static int depca_hw_init(struct net_device *dev, u_long ioaddr, int mca_slot);
 static void depca_init_ring(struct net_device *dev);
 static int depca_rx(struct net_device *dev);
 static int depca_tx(struct net_device *dev);
 
 static void LoadCSRs(struct net_device *dev);
 static int InitRestartDepca(struct net_device *dev);
-static void DepcaSignature(char *name, u_long paddr);
+static int DepcaSignature(char *name, u_long paddr);
 static int DevicePresent(u_long ioaddr);
 static int get_hw_addr(struct net_device *dev);
 static void SetMulticastFilter(struct net_device *dev);
-static void isa_probe(struct net_device *dev, u_long iobase);
-#ifdef CONFIG_MCA
-static void mca_probe(struct net_device *dev, u_long iobase);
-#endif
-static struct net_device *alloc_device(struct net_device *dev, u_long iobase);
-static int depca_dev_index(char *s);
-static struct net_device *insert_device(struct net_device *dev, u_long iobase, int (*init) (struct net_device *));
 static int load_packet(struct net_device *dev, struct sk_buff *skb);
 static void depca_dbg_open(struct net_device *dev);
 
-#ifdef MODULE
-static int autoprobed = 1, loading_module = 1;
-# else
 static u_char de1xx_irq[] __initdata = { 2, 3, 4, 5, 7, 9, 0 };
 static u_char de2xx_irq[] __initdata = { 5, 9, 10, 11, 15, 0 };
 static u_char de422_irq[] __initdata = { 5, 9, 10, 11, 0 };
 static u_char *depca_irq;
-static int autoprobed, loading_module;
-#endif				/* MODULE */
 
-static char name[DEPCA_STRLEN];
-static int num_depcas, num_eth;
+static int irq;
+static int io;
+static char *adapter_name;
 static int mem;			/* For loadable module assignment
 				   use insmod mem=0x????? .... */
-static char *adapter_name;	/* = '\0';     If no PROM when loadable module
-				   use insmod adapter_name=DE??? ...
-				   bss initializes this to zero
-				 */
+module_param (irq, int, 0);
+module_param (io, int, 0);
+module_param (adapter_name, charp, 0);
+module_param (mem, int, 0);
+MODULE_PARM_DESC(irq, "DEPCA IRQ number");
+MODULE_PARM_DESC(io, "DEPCA I/O base address");
+MODULE_PARM_DESC(adapter_name, "DEPCA adapter name");
+MODULE_PARM_DESC(mem, "DEPCA shared memory address");
+MODULE_LICENSE("GPL");
+
 /*
 ** Miscellaneous defines...
 */
@@ -513,52 +562,30 @@
     outw(CSR0, DEPCA_ADDR);\
     outw(STOP, DEPCA_DATA)
 
-int __init depca_probe(struct net_device *dev)
-{
-	int tmp = num_depcas, status = -ENODEV;
-	u_long iobase = dev->base_addr;
-
-	SET_MODULE_OWNER(dev);
-
-	if ((iobase == 0) && loading_module) {
-		printk("Autoprobing is not supported when loading a module based driver.\n");
-		status = -EIO;
-	} else {
-#ifdef CONFIG_MCA
-		mca_probe(dev, iobase);
-#endif
-		isa_probe(dev, iobase);
-#ifdef CONFIG_EISA
-		eisa_driver_register (&depca_eisa_driver);
-#endif
-
-		if ((tmp == num_depcas) && (iobase != 0) && loading_module) {
-			printk("%s: depca_probe() cannot find device at 0x%04lx.\n", dev->name, iobase);
-		}
-
-		/*
-		   ** Walk the device list to check that at least one device
-		   ** initialised OK
-		 */
-		for (; (dev->priv == NULL) && (dev->next != NULL); dev = dev->next);
-
-		if (dev->priv)
-			status = 0;
-		if (iobase == 0)
-			autoprobed = 1;
-	}
-
-	return status;
-}
-
-static int __init depca_hw_init(struct net_device *dev, u_long ioaddr, int mca_slot)
+static int __init depca_hw_init (struct net_device *dev, struct device *device)
 {
 	struct depca_private *lp;
 	int i, j, offset, netRAM, mem_len, status = 0;
 	s16 nicsr;
-	u_long mem_start = 0, mem_base[] = DEPCA_RAM_BASE_ADDRESSES;
-	int is_eisa = ((ioaddr & 0x0fff) == DEPCA_EISA_IO_PORTS);
+	u_long ioaddr;
+	u_long mem_start;
+
+	/*
+	 * We are now supposed to enter this function with the
+	 * following fields filled with proper values :
+	 *
+	 * dev->base_addr
+	 * lp->mem_start
+	 * lp->depca_bus
+	 * lp->adapter
+	 *
+	 * dev->irq can be set if known from device configuration (on
+	 * MCA or EISA) or module option. Otherwise, it will be auto
+	 * detected.
+	 */
 
+	ioaddr = dev->base_addr;
+	
 	STOP_DEPCA;
 
 	nicsr = inb(DEPCA_NICSR);
@@ -569,24 +596,34 @@
 		return -ENXIO;
 	}
 
-	do {
-		strcpy(name, (adapter_name ? adapter_name : ""));
-		mem_start = (mem ? mem & 0xf0000 : mem_base[mem_chkd++]);
-		DepcaSignature(name, mem_start);
-	} while (!mem && mem_base[mem_chkd] && (adapter == unknown));
+	lp = (struct depca_private *) dev->priv;
+	mem_start = lp->mem_start;
 
-	if ((adapter == unknown) || !mem_start) {	/* DEPCA device not found */
+	if (!mem_start || lp->adapter < DEPCA || lp->adapter >=unknown)
 		return -ENXIO;
-	}
 
-	dev->base_addr = ioaddr;
+	printk ("%s: %s at 0x%04lx",
+	        device->bus_id, depca_signature[lp->adapter], ioaddr);
+	
+	switch (lp->depca_bus) {
+#ifdef CONFIG_MCA
+	case DEPCA_BUS_MCA:
+		printk(" (MCA slot %d)", to_mca_device(device)->slot + 1);
+		break;
+#endif
+
+#ifdef CONFIG_EISA
+	case DEPCA_BUS_EISA:
+		printk(" (EISA slot %d)", to_eisa_device(device)->slot);
+		break;
+#endif
 
-	if (mca_slot != -1) {
-		printk("%s: %s at 0x%04lx (MCA slot %d)", dev->name, name, ioaddr, mca_slot);
-	} else if (is_eisa) {	/* EISA slot address */
-		printk("%s: %s at 0x%04lx (EISA slot %d)", dev->name, name, ioaddr, (int) ((ioaddr >> 12) & 0x0f));
-	} else {		/* ISA port address */
-		printk("%s: %s at 0x%04lx", dev->name, name, ioaddr);
+	case DEPCA_BUS_ISA:
+		break;
+
+	default:
+		printk("Unknown DEPCA bus %d\n", lp->depca_bus);
+		return -ENXIO;
 	}
 
 	printk(", h/w address ");
@@ -601,18 +638,20 @@
 	printk("%2.2x", dev->dev_addr[i]);
 
 	/* Set up the maximum amount of network RAM(kB) */
-	netRAM = ((adapter != DEPCA) ? 64 : 48);
-	if ((nicsr & _128KB) && (adapter == de422))
+	netRAM = ((lp->adapter != DEPCA) ? 64 : 48);
+	if ((nicsr & _128KB) && (lp->adapter == de422))
 		netRAM = 128;
-	offset = 0x0000;
 
 	/* Shared Memory Base Address */
 	if (nicsr & BUF) {
-		offset = 0x8000;	/* 32kbyte RAM offset */
 		nicsr &= ~BS;	/* DEPCA RAM in top 32k */
 		netRAM -= 32;
+
+		/* Only EISA/ISA needs start address to be re-computed */
+		if (lp->depca_bus != DEPCA_BUS_MCA)
+			mem_start += 0x8000;
 	}
-	mem_start += offset;	/* (E)ISA start address */
+	
 	if ((mem_len = (NUM_RX_DESC * (sizeof(struct depca_rx_desc) + RX_BUFF_SZ) + NUM_TX_DESC * (sizeof(struct depca_tx_desc) + TX_BUFF_SZ) + sizeof(struct depca_init)))
 	    > (netRAM << 10)) {
 		printk(",\n       requests %dkB RAM: only %dkB is available!\n", (mem_len >> 10), netRAM);
@@ -622,23 +661,14 @@
 	printk(",\n      has %dkB RAM at 0x%.5lx", netRAM, mem_start);
 
 	/* Enable the shadow RAM. */
-	if (adapter != DEPCA) {
+	if (lp->adapter != DEPCA) {
 		nicsr |= SHE;
 		outb(nicsr, DEPCA_NICSR);
 	}
 
-	/* Define the device private memory */
-	if (!is_eisa) {
-		dev->priv = (void *) kmalloc(sizeof(struct depca_private), GFP_KERNEL);
-		if (dev->priv == NULL)
-			return -ENOMEM;
-	}
-	lp = (struct depca_private *) dev->priv;
-	memset((char *) dev->priv, 0, sizeof(struct depca_private));
-	lp->adapter = adapter;
-	lp->mca_slot = mca_slot;
 	lp->lock = SPIN_LOCK_UNLOCKED;
-	sprintf(lp->adapter_name, "%s (%s)", name, dev->name);
+	sprintf(lp->adapter_name, "%s (%s)",
+		depca_signature[lp->adapter], device->bus_id);
 	status = -EBUSY;
 
 	/* Initialisation Block */
@@ -702,7 +732,6 @@
 	/* To auto-IRQ we enable the initialization-done and DMA err,
 	   interrupts. For now we will always get a DMA error. */
 	if (dev->irq < 2) {
-#ifndef MODULE
 		unsigned char irqnum;
 		unsigned long irq_mask, delay;
 
@@ -725,6 +754,9 @@
 		case de422:
 			depca_irq = de422_irq;
 			break;
+
+		default:
+			break;	/* Not reached */
 		}
 
 		/* Trigger an initialization just for the interrupt. */
@@ -733,6 +765,7 @@
 		delay = jiffies + HZ/50;
 		while (time_before(jiffies, delay))
 			yield();
+
 		irqnum = probe_irq_off(irq_mask);
 
 		status = -ENXIO;
@@ -746,13 +779,11 @@
 					printk(" and uses IRQ%d.\n", dev->irq);
 				}
 
-			status = -ENXIO;
 			if (!dev->irq) {
 				printk(" but incorrect IRQ line detected.\n");
-				goto out_priv;
+				return -ENXIO;
 			}
 		}
-#endif				/* MODULE */
 	} else {
 		printk(" and assigned IRQ%d.\n", dev->irq);
 	}
@@ -773,17 +804,14 @@
 
 	dev->mem_start = 0;
 
-	/* Fill in the generic field of the device structure. */
-	if (!is_eisa)
-		ether_setup(dev);
+	device->driver_data = dev;
+	SET_NETDEV_DEV (dev, device);
+	
+	register_netdev (dev);
 	return 0;
-      out_priv:
-	if (!is_eisa) {
-		kfree(dev->priv);
-		dev->priv = NULL;
-	} else {
-		unregister_netdev (dev);
-	}
+
+ out_priv:
+	
 	return status;
 }
 
@@ -1284,215 +1312,265 @@
 	return;
 }
 
+static int __init depca_common_init (u_long ioaddr, struct net_device **devp)
+{
+	int status = 0;
+	
+	if (!request_region (ioaddr, DEPCA_TOTAL_SIZE, depca_string)) {
+		status = -EBUSY;
+		goto out;
+	}
+	
+	if (DevicePresent(ioaddr)) {
+		status = -ENODEV;
+		goto out_release;
+	}
+
+	if (!(*devp = alloc_etherdev (sizeof (struct depca_private)))) {
+		status = -ENOMEM;
+		goto out_release;
+	}
+
+	return 0;
+	
+ out_release:
+	release_region (ioaddr, DEPCA_TOTAL_SIZE);
+ out:
+	return status;
+}
+
 #ifdef CONFIG_MCA
 /*
 ** Microchannel bus I/O device probe
 */
-static void __init mca_probe(struct net_device *dev, u_long ioaddr)
+static int __init depca_mca_probe(struct device *device)
 {
 	unsigned char pos[2];
 	unsigned char where;
-	unsigned long iobase;
-	int irq;
-	int slot = 0;
+	unsigned long iobase, mem_start;
+	int irq, err;
+	struct mca_device *mdev = to_mca_device (device);
+	struct net_device *dev;
+	struct depca_private *lp;
 
 	/*
-	   ** See if we've been here before.
-	 */
-	if ((!ioaddr && autoprobed) || (ioaddr && !loading_module))
-		return;
-
-	if (MCA_bus) {
-		/*
-		   ** Search for the adapter.  If an address has been given, search 
-		   ** specifically for the card at that address.  Otherwise find the
-		   ** first card in the system.
-		 */
-		while ((dev != NULL) && ((slot = mca_find_adapter(DE212_ID, slot)) != MCA_NOTFOUND)) {
-			pos[0] = mca_read_stored_pos(slot, 2);
-			pos[1] = mca_read_stored_pos(slot, 3);
-
-			/*
-			   ** IO of card is handled by bits 1 and 2 of pos0.    
-			   **
-			   **    bit2 bit1    IO
-			   **       0    0    0x2c00
-			   **       0    1    0x2c10
-			   **       1    0    0x2c20
-			   **       1    1    0x2c30
-			 */
-			where = (pos[0] & 6) >> 1;
-			iobase = 0x2c00 + (0x10 * where);
-
-			if ((ioaddr) && (ioaddr != iobase)) {
-				/*
-				   ** Card was found, but not at the right IO location. Continue 
-				   ** scanning from the next MCA slot up for another card.
-				 */
-				slot++;
-				continue;
-			}
-
-			/*
-			   ** Found the adapter we were looking for. Now start setting it up.
-			   ** 
-			   ** First work on decoding the IRQ.  It's stored in the lower 4 bits
-			   ** of pos1.  Bits are as follows (from the ADF file):
-			   **
-			   **      Bits           
-			   **   3   2   1   0    IRQ 
-			   **   --------------------
-			   **   0   0   1   0     5
-			   **   0   0   0   1     9
-			   **   0   1   0   0    10
-			   **   1   0   0   0    11
-			   * */
-			where = pos[1] & 0x0f;
-			switch (where) {
-			case 1:
-				irq = 9;
-				break;
-			case 2:
-				irq = 5;
-				break;
-			case 4:
-				irq = 10;
-				break;
-			case 8:
-				irq = 11;
-				break;
-			default:
-				printk("%s: mca_probe IRQ error.  You should never get here (%d).\n", dev->name, where);
-				return;
-			}
-
-			/*
-			   ** Shared memory address of adapter is stored in bits 3-5 of pos0.
-			   ** They are mapped as follows:
-			   **
-			   **    Bit
-			   **   5  4  3       Memory Addresses
-			   **   0  0  0       C0000-CFFFF (64K)
-			   **   1  0  0       C8000-CFFFF (32K)
-			   **   0  0  1       D0000-DFFFF (64K)
-			   **   1  0  1       D8000-DFFFF (32K)
-			   **   0  1  0       E0000-EFFFF (64K)
-			   **   1  1  0       E8000-EFFFF (32K)
-			 */
-			where = (pos[0] & 0x18) >> 3;
-			mem = 0xc0000 + (where * 0x10000);
-			if (pos[0] & 0x20) {
-				mem += 0x8000;
-			}
+	** Search for the adapter.  If an address has been given, search 
+	** specifically for the card at that address.  Otherwise find the
+	** first card in the system.
+	*/
+	
+	pos[0] = mca_device_read_stored_pos(mdev, 2);
+	pos[1] = mca_device_read_stored_pos(mdev, 3);
 
-			/*
-			   ** Get everything allocated and initialized...  (almost just
-			   ** like the ISA and EISA probes)
-			 */
-			if (!request_region (iobase, DEPCA_TOTAL_SIZE, "depca")) {
-				if (autoprobed)
-					printk(KERN_WARNING "%s: region already allocated at 0x%04lx.\n", dev->name, iobase);
-				goto next;
-			}
-			if (DevicePresent(iobase) != 0) {
-				/*
-				   ** If the MCA configuration says the card should be here,
-				   ** it really should be here.
-				 */
-				printk(KERN_ERR "%s: MCA reports card at 0x%lx but it is not responding.\n", dev->name, iobase);
-				goto release_next;
-			}
+	/*
+	** IO of card is handled by bits 1 and 2 of pos0.    
+	**
+	**    bit2 bit1    IO
+	**       0    0    0x2c00
+	**       0    1    0x2c10
+	**       1    0    0x2c20
+	**       1    1    0x2c30
+	*/
+	where = (pos[0] & 6) >> 1;
+	iobase = 0x2c00 + (0x10 * where);
 
-			if (!(dev = alloc_device(dev, iobase)))
-				goto release_next;
+	/*
+	** Found the adapter we were looking for. Now start setting it up.
+	** 
+	** First work on decoding the IRQ.  It's stored in the lower 4 bits
+	** of pos1.  Bits are as follows (from the ADF file):
+	**
+	**      Bits           
+	**   3   2   1   0    IRQ 
+	**   --------------------
+	**   0   0   1   0     5
+	**   0   0   0   1     9
+	**   0   1   0   0    10
+	**   1   0   0   0    11
+	*/
+	where = pos[1] & 0x0f;
+	switch (where) {
+	case 1:
+		irq = 9;
+		break;
+	case 2:
+		irq = 5;
+		break;
+	case 4:
+		irq = 10;
+		break;
+	case 8:
+		irq = 11;
+		break;
+	default:
+		printk("%s: mca_probe IRQ error.  You should never get here (%d).\n", dev->name, where);
+		return -EINVAL;
+	}
 
-			num_eth++;
-			dev->irq = irq;
-			if (depca_hw_init(dev, iobase, slot))
-				goto release_next;
+	/*
+	** Shared memory address of adapter is stored in bits 3-5 of pos0.
+	** They are mapped as follows:
+	**
+	**    Bit
+	**   5  4  3       Memory Addresses
+	**   0  0  0       C0000-CFFFF (64K)
+	**   1  0  0       C8000-CFFFF (32K)
+	**   0  0  1       D0000-DFFFF (64K)
+	**   1  0  1       D8000-DFFFF (32K)
+	**   0  1  0       E0000-EFFFF (64K)
+	**   1  1  0       E8000-EFFFF (32K)
+	*/
+	where = (pos[0] & 0x18) >> 3;
+	mem_start = 0xc0000 + (where * 0x10000);
+	if (pos[0] & 0x20) {
+		mem_start += 0x8000;
+	}
+
+	/* claim the slot */
+	strncpy(mdev->name, depca_mca_adapter_name[mdev->index],
+		sizeof(mdev->name));
+	mca_device_set_claim(mdev, 1);
+	
+        /*
+	** Get everything allocated and initialized...  (almost just
+	** like the ISA and EISA probes)
+	*/
+	irq = mca_device_transform_irq(mdev, irq);
+	iobase = mca_device_transform_ioport(mdev, iobase);
+
+	if ((err = depca_common_init (iobase, &dev)))
+		goto out_unclaim;
+
+	dev->irq = irq;
+	dev->base_addr = iobase;
+	lp = dev->priv;
+	lp->depca_bus = DEPCA_BUS_MCA;
+	lp->adapter = depca_mca_adapter_type[mdev->index];
+	lp->mem_start = mem_start;
+	
+	if ((err = depca_hw_init(dev, device)))
+		goto out_free;
 			
-			/*
-			** Adapter initialized correctly:  Name it in
-			** /proc/mca.
-			*/
-			mca_set_adapter_name(slot, "DE210/212 Ethernet Adapter");
-			mca_mark_as_used(slot);
-			num_depcas++;
-
-			/*
-			   ** If this is a probe by a module, return after setting up the
-			   ** given card.
-			 */
-			if (ioaddr)
-				return;
-
-			/*
-			** Set up to check the next slot and loop.
-			 */
-			slot++;
-			continue;
+	return 0;
 
-	release_next:
-			release_region (iobase, DEPCA_TOTAL_SIZE);
-	next:
-			slot++;
-		}
-	}
+ out_free:
+	free_netdev (dev);
+	release_region (iobase, DEPCA_TOTAL_SIZE);
+ out_unclaim:
+	mca_device_set_claim(mdev, 0);
 
-	return;
+	return err;;
 }
 #endif
 
 /*
 ** ISA bus I/O device probe
 */
-static void __init isa_probe(struct net_device *dev, u_long ioaddr)
+
+static void depca_platform_release (struct device *device)
 {
-	int i = num_depcas, maxSlots;
-	s32 ports[] = DEPCA_IO_PORTS;
+	struct platform_device *pldev;
 
-	if (!ioaddr && autoprobed)
-		return;		/* Been here before ! */
-	if (ioaddr > 0x400)
-		return;		/* EISA Address */
-	if (i >= MAX_NUM_DEPCAS)
-		return;		/* Too many ISA adapters */
-
-	if (ioaddr == 0) {	/* Autoprobing */
-		maxSlots = MAX_NUM_DEPCAS;
-	} else {		/* Probe a specific location */
-		ports[i] = ioaddr;
-		maxSlots = i + 1;
-	}
-
-	for (; (i < maxSlots) && (dev != NULL) && ports[i]; i++) {
-		if (!request_region (ports[i], DEPCA_TOTAL_SIZE, "depca")) {
-			if (autoprobed)
-				printk("%s: region already allocated at 0x%04x.\n", dev->name, ports[i]);
+	/* free device */
+	pldev = to_platform_device (device);
+	kfree (pldev);
+}
+
+static void __init depca_platform_probe (void)
+{
+	int i;
+	struct platform_device *pldev;
+
+	for (i = 0; depca_io_ports[i].iobase; i++) {
+		depca_io_ports[i].device = NULL;
+		
+		/* if an address has been specified on the command
+		 * line, use it (if valid) */
+		if (io && io != depca_io_ports[i].iobase)
+			continue;
+		
+		if (!(pldev = kmalloc (sizeof (*pldev), GFP_KERNEL)))
 			continue;
-		}
 
-		if (DevicePresent(ports[i])) {
-			release_region (ports[i], DEPCA_TOTAL_SIZE);
+		memset (pldev, 0, sizeof (*pldev));
+		pldev->name = depca_string;
+		pldev->id   = i;
+		pldev->dev.platform_data = (void *) depca_io_ports[i].iobase;
+		pldev->dev.release       = depca_platform_release;
+		depca_io_ports[i].device = pldev;
+
+		if (platform_device_register (pldev)) {
+			kfree (pldev);
+			depca_io_ports[i].device = NULL;
 			continue;
 		}
 
-		if (!(dev = alloc_device(dev, ports[i]))) {
-			release_region (ports[i], DEPCA_TOTAL_SIZE);
-			continue;
+		if (!pldev->dev.driver) {
+		/* The driver was not bound to this device, there was
+		 * no hardware at this address. Unregister it, as the
+		 * release fuction will take care of freeing the
+		 * allocated structure */
+			
+			depca_io_ports[i].device = NULL;
+			platform_device_unregister (pldev);
 		}
+	}
+}
 
-		num_eth++;
+static enum depca_type __init depca_shmem_probe (ulong *mem_start)
+{
+	u_long mem_base[] = DEPCA_RAM_BASE_ADDRESSES;
+	enum depca_type adapter = unknown;
+	int i;
 
-		if (depca_hw_init(dev, ports[i], -1)) {
-			release_region (ports[i], DEPCA_TOTAL_SIZE);
-			continue;
-		}
+	for (i = 0; mem_base[i]; i++) {
+		*mem_start = mem ? mem : mem_base[i];
+		adapter = DepcaSignature (adapter_name, *mem_start);
+		if (adapter != unknown)
+			break;
+	}
+
+	return adapter;
+}
 
-		num_depcas++;
+static int __init depca_isa_probe (struct device *device)
+{
+	struct net_device *dev;
+	struct depca_private *lp;
+	u_long ioaddr, mem_start = 0;
+	enum depca_type adapter = unknown;
+	int status = 0;
+
+	ioaddr = (u_long) device->platform_data;
+
+	if ((status = depca_common_init (ioaddr, &dev)))
+		goto out;
+
+	adapter = depca_shmem_probe (&mem_start);
+	
+	if (adapter == unknown) {
+		status = -ENODEV;
+		goto out_free;
 	}
 
-	return;
+	dev->base_addr = ioaddr;
+	dev->irq = irq;		/* Use whatever value the user gave
+				 * us, and 0 if he didn't. */
+	lp = dev->priv;
+	lp->depca_bus = DEPCA_BUS_ISA;
+	lp->adapter = adapter;
+	lp->mem_start = mem_start;
+	
+	if ((status = depca_hw_init(dev, device)))
+		goto out_free;
+	
+	return 0;
+
+ out_free:
+	free_netdev (dev);
+	release_region (ioaddr, DEPCA_TOTAL_SIZE);
+ out:
+	return status;
 }
 
 /*
@@ -1504,202 +1582,120 @@
 {
 	struct eisa_device *edev;
 	struct net_device *dev;
-	u_long iobase;
+	struct depca_private *lp;
+	u_long ioaddr, mem_start;
 	int status = 0;
 
 	edev = to_eisa_device (device);
-	iobase = edev->base_addr + DEPCA_EISA_IO_PORTS;
+	ioaddr = edev->base_addr + DEPCA_EISA_IO_PORTS;
 
-	if (!request_region (iobase, DEPCA_TOTAL_SIZE, "depca")) {
-		status = -EBUSY;
+	if ((status = depca_common_init (ioaddr, &dev)))
 		goto out;
-	}
-	
-	if (DevicePresent(iobase)) {
-		status = -ENODEV;
-		goto out_release;
-	}
 
-	if (!(dev = init_etherdev (NULL, sizeof (struct depca_private)))) {
-		status = -ENOMEM;
-		goto out_release;
-	}
-		
-	eisa_set_drvdata (edev, dev);
+	/* It would have been nice to get card configuration from the
+	 * card. Unfortunately, this register is write-only (shares
+	 * it's address with the ethernet prom)... As we don't parse
+	 * the EISA configuration structures (yet... :-), just rely on
+	 * the ISA probing to sort it out... */
+	
+	depca_shmem_probe (&mem_start);
 
-	if ((status = depca_hw_init(dev, iobase, -1)))
+	dev->base_addr = ioaddr;
+	dev->irq = irq;
+	lp = dev->priv;
+	lp->depca_bus = DEPCA_BUS_EISA;
+	lp->adapter = edev->id.driver_data;
+	lp->mem_start = mem_start;
+	
+	if ((status = depca_hw_init(dev, device)))
 		goto out_free;
-
-	num_depcas++;
+	
 	return 0;
 
  out_free:
-	kfree (dev);
- out_release:
-	release_region (iobase, DEPCA_TOTAL_SIZE);
+	free_netdev (dev);
+	release_region (ioaddr, DEPCA_TOTAL_SIZE);
  out:
 	return status;
 }
+#endif
 
-static int __devexit depca_eisa_remove (struct device *device)
+static int __devexit depca_device_remove (struct device *device)
 {
 	struct net_device *dev;
-	struct eisa_device *edev;
 	struct depca_private *lp;
+	int bus;
 
-	edev = to_eisa_device (device);
-	dev  = eisa_get_drvdata (edev);
+	dev  = device->driver_data;
 	lp   = dev->priv;
 
 	unregister_netdev (dev);
 	iounmap (lp->sh_mem);
 	release_mem_region (lp->mem_start, lp->mem_len);
 	release_region (dev->base_addr, DEPCA_TOTAL_SIZE);
-	kfree (dev);
+	bus = lp->depca_bus;
+	free_netdev (dev);
 
 	return 0;
 }
-#endif
-
-/*
-** Search the entire 'eth' device list for a fixed probe. If a match isn't
-** found then check for an autoprobe or unused device location. If they
-** are not available then insert a new device structure at the end of
-** the current list.
-*/
-static struct net_device *__init alloc_device(struct net_device *dev, u_long iobase)
-{
-	struct net_device *adev = NULL;
-	int fixed = 0, new_dev = 0;
-
-	num_eth = depca_dev_index(dev->name);
-	if (loading_module)
-		return dev;
-
-	while (1) {
-		if (((dev->base_addr == DEPCA_NDA) || (dev->base_addr == 0)) && !adev) {
-			adev = dev;
-		} else if ((dev->priv == NULL) && (dev->base_addr == iobase)) {
-			fixed = 1;
-		} else {
-			if (dev->next == NULL) {
-				new_dev = 1;
-			} else if (strncmp(dev->next->name, "eth", 3) != 0) {
-				new_dev = 1;
-			}
-		}
-		if ((dev->next == NULL) || new_dev || fixed)
-			break;
-		dev = dev->next;
-		num_eth++;
-	}
-	if (adev && !fixed) {
-		dev = adev;
-		num_eth = depca_dev_index(dev->name);
-		new_dev = 0;
-	}
-
-	if (((dev->next == NULL) && ((dev->base_addr != DEPCA_NDA) && (dev->base_addr != 0)) && !fixed) || new_dev) {
-		num_eth++;	/* New device */
-		dev = insert_device(dev, iobase, depca_probe);
-	}
-
-	return dev;
-}
-
-/*
-** If at end of eth device list and can't use current entry, malloc
-** one up. If memory could not be allocated, print an error message.
-*/
-static struct net_device *__init insert_device(struct net_device *dev, u_long iobase, int (*init) (struct net_device *))
-{
-	struct net_device *new;
-
-	new = (struct net_device *) kmalloc(sizeof(struct net_device), GFP_KERNEL);
-	if (new == NULL) {
-		printk("eth%d: Device not initialised, insufficient memory\n", num_eth);
-		return NULL;
-	} else {
-		new->next = dev->next;
-		dev->next = new;
-		dev = dev->next;	/* point to the new device */
-		if (num_eth > 9999) {
-			sprintf(dev->name, "eth????");	/* New device name */
-		} else {
-			sprintf(dev->name, "eth%d", num_eth);	/* New device name */
-		}
-		dev->base_addr = iobase;	/* assign the io address */
-		dev->init = init;	/* initialisation routine */
-	}
-
-	return dev;
-}
-
-static int __init depca_dev_index(char *s)
-{
-	int i = 0, j = 0;
-
-	for (; *s; s++) {
-		if (isdigit(*s)) {
-			j = 1;
-			i = (i * 10) + (*s - '0');
-		} else if (j)
-			break;
-	}
-
-	return i;
-}
 
 /*
 ** Look for a particular board name in the on-board Remote Diagnostics
 ** and Boot (readb) ROM. This will also give us a clue to the network RAM
 ** base address.
 */
-static void __init DepcaSignature(char *name, u_long paddr)
+static int __init DepcaSignature(char *name, u_long base_addr)
 {
 	u_int i, j, k;
-	const char *signatures[] = DEPCA_SIGNATURE;
 	void *ptr;
 	char tmpstr[16];
+	u_long prom_addr = base_addr + 0xc000;
+	u_long mem_addr = base_addr + 0x8000; /* 32KB */
+
+	/* Can't reserve the prom region, it is already marked as
+	 * used, at least on x86. Instead, reserve a memory region a
+	 * board would certainly use. If it works, go ahead. If not,
+	 * run like hell... */
+	
+	if (!request_mem_region (mem_addr, 16, depca_string))
+		return unknown;
 
 	/* Copy the first 16 bytes of ROM */
-	ptr = ioremap(paddr + 0xc000, 16);
+
+	ptr = ioremap(prom_addr, 16);
 	if (ptr == NULL) {
-		printk(KERN_ERR "depca: I/O remap failed at %lx\n", paddr + 0xc000);
-		adapter = unknown;
-		return;
+		printk(KERN_ERR "depca: I/O remap failed at %lx\n", prom_addr);
+		return unknown;
 	}
 	for (i = 0; i < 16; i++) {
 		tmpstr[i] = readb(ptr + i);
 	}
 	iounmap(ptr);
 
+	release_mem_region (mem_addr, 16);
+
 	/* Check if PROM contains a valid string */
-	for (i = 0; *signatures[i] != '\0'; i++) {
-		for (j = 0, k = 0; j < 16 && k < strlen(signatures[i]); j++) {
-			if (signatures[i][k] == tmpstr[j]) {	/* track signature */
+	for (i = 0; *depca_signature[i] != '\0'; i++) {
+		for (j = 0, k = 0; j < 16 && k < strlen(depca_signature[i]); j++) {
+			if (depca_signature[i][k] == tmpstr[j]) {	/* track signature */
 				k++;
 			} else {	/* lost signature; begin search again */
 				k = 0;
 			}
 		}
-		if (k == strlen(signatures[i]))
+		if (k == strlen(depca_signature[i]))
 			break;
 	}
 
 	/* Check if name string is valid, provided there's no PROM */
-	if (*name && (i == unknown)) {
-		for (i = 0; *signatures[i] != '\0'; i++) {
-			if (strcmp(name, signatures[i]) == 0)
+	if (name && *name && (i == unknown)) {
+		for (i = 0; *depca_signature[i] != '\0'; i++) {
+			if (strcmp(name, depca_signature[i]) == 0)
 				break;
 		}
 	}
 
-	/* Update search results */
-	strcpy(name, signatures[i]);
-	adapter = i;
-
-	return;
+	return i;
 }
 
 /*
@@ -1773,10 +1769,11 @@
 static int __init get_hw_addr(struct net_device *dev)
 {
 	u_long ioaddr = dev->base_addr;
+	struct depca_private *lp = dev->priv;
 	int i, k, tmp, status = 0;
 	u_short j, x, chksum;
 
-	x = (((adapter == de100) || (adapter == de101)) ? 1 : 0);
+	x = (((lp->adapter == de100) || (lp->adapter == de101)) ? 1 : 0);
 
 	for (i = 0, k = 0, j = 0; j < 3; j++) {
 		k <<= 1;
@@ -2083,55 +2080,40 @@
 	return status;
 }
 
-#ifdef MODULE
-static struct net_device thisDepca;
-static int irq = 7;		/* EDIT THESE LINE FOR YOUR CONFIGURATION */
-static int io = 0x200;		/* Or use the irq= io= options to insmod */
-MODULE_PARM(irq, "i");
-MODULE_PARM(io, "i");
-MODULE_PARM_DESC(irq, "DEPCA IRQ number");
-MODULE_PARM_DESC(io, "DEPCA I/O base address");
-
-/* See depca_probe() for autoprobe messages when a module */
-int init_module(void)
+static int __init depca_module_init (void)
 {
-	thisDepca.irq = irq;
-	thisDepca.base_addr = io;
-	thisDepca.init = depca_probe;
+        int err = 0;
 
-	if (register_netdev(&thisDepca) != 0)
-		return -EIO;
-
-	return 0;
+#if CONFIG_MCA
+        err = mca_register_driver (&depca_mca_driver);
+#endif
+#ifdef CONFIG_EISA
+        err |= eisa_driver_register (&depca_eisa_driver);
+#endif
+	err |= driver_register (&depca_isa_driver);
+	depca_platform_probe ();
+	
+        return err;
 }
 
-void cleanup_module(void)
+static void __exit depca_module_exit (void)
 {
-	struct depca_private *lp = thisDepca.priv;
-
-	unregister_netdev(&thisDepca);
-	if (lp) {
-		iounmap(lp->sh_mem);
-		release_mem_region (lp->mem_start, lp->mem_len);
-#ifdef CONFIG_MCA
-		if (lp->mca_slot != -1)
-			mca_mark_as_unused(lp->mca_slot);
+	int i;
+#if CONFIG_MCA
+        mca_unregister_driver (&depca_mca_driver);
 #endif
-		kfree(lp);
-		thisDepca.priv = NULL;
-	}
-	thisDepca.irq = 0;
+#ifdef CONFIG_EISA
+        eisa_driver_unregister (&depca_eisa_driver);
+#endif
+	driver_unregister (&depca_isa_driver);
 
-	release_region(thisDepca.base_addr, DEPCA_TOTAL_SIZE);
+	for (i = 0; depca_io_ports[i].iobase; i++) {
+		if (depca_io_ports[i].device) {
+			platform_device_unregister (depca_io_ports[i].device);
+			depca_io_ports[i].device = NULL;
+		}
+	}
 }
-#endif				/* MODULE */
-MODULE_LICENSE("GPL");
-
 
-/*
- * Local variables:
- *  compile-command: "gcc -D__KERNEL__ -I/linux/include -Wall -Wstrict-prototypes -fomit-frame-pointer -fno-strength-reduce -malign-loops=2 -malign-jumps=2 -malign-functions=2 -O2 -m486 -c depca.c"
- *
- *  compile-command: "gcc -D__KERNEL__ -DMODULE -I/linux/include -Wall -Wstrict-prototypes -fomit-frame-pointer -fno-strength-reduce -malign-loops=2 -malign-jumps=2 -malign-functions=2 -O2 -m486 -c depca.c"
- * End:
- */
+module_init (depca_module_init);
+module_exit (depca_module_exit);
--- ../vanilla/linux-2.5/drivers/net/Space.c	2003-09-16 21:01:02.000000000 +0200
+++ linux-2.5/drivers/net/Space.c	2003-09-12 19:40:26.000000000 +0200
@@ -58,7 +58,6 @@
 extern int at1700_probe(struct net_device *);
 extern int fmv18x_probe(struct net_device *);
 extern int eth16i_probe(struct net_device *);
-extern int depca_probe(struct net_device *);
 extern int i82596_probe(struct net_device *);
 extern int ewrk3_probe(struct net_device *);
 extern int el1_probe(struct net_device *);
@@ -252,9 +247,6 @@
 #ifdef CONFIG_EEXPRESS_PRO	/* Intel EtherExpress Pro/10 */
 	{eepro_probe, 0},
 #endif
-#ifdef CONFIG_DEPCA		/* DEC DEPCA */
-	{depca_probe, 0},
-#endif
 #ifdef CONFIG_EWRK3             /* DEC EtherWORKS 3 */
     	{ewrk3_probe, 0},
 #endif

--=-=-=


-- 
Places change, faces change. Life is so very strange.

--=-=-=--
