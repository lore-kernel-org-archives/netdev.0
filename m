From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] skfddi - convert to new pci model.
Date: Thu, 4 Dec 2003 16:39:28 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031204163928.0f34d5d1.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Alexander Viro <aviro@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1502  -> 1.1503 
#	drivers/net/skfp/skfddi.c	1.20    -> 1.21   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/12/04	shemminger@osdl.org	1.1503
# Convert skfddi device to 2.6.
#  * use new pci device bus initialization
#  * allocate network device with alloc_fddidev
#    and use dev->priv
#  * get rid of special module/non module distinctions.
#  * fix error unwinds and return values on initialization
# --------------------------------------------
#
diff -Nru a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
--- a/drivers/net/skfp/skfddi.c	Thu Dec  4 16:36:03 2003
+++ b/drivers/net/skfp/skfddi.c	Thu Dec  4 16:36:03 2003
@@ -58,6 +58,7 @@
  *		07-May-00	DM	64 bit fixes, new dma interface
  *		31-Jul-03	DB	Audit copy_*_user in skfp_ioctl
  *					  Daniele Bellucci <bellucda@tiscali.it>
+ *		03-Dec-03	SH	Convert to PCI device model
  *
  * Compilation options (-Dxxx):
  *              DRIVERDEBUG     print lots of messages to log file
@@ -70,7 +71,7 @@
 
 /* Version information string - should be updated prior to */
 /* each new release!!! */
-#define VERSION		"2.06"
+#define VERSION		"2.07"
 
 static const char *boot_msg = 
 	"SysKonnect FDDI PCI Adapter driver v" VERSION " for\n"
@@ -80,15 +81,11 @@
 
 #include <linux/module.h>
 #include <linux/kernel.h>
-#include <linux/string.h>
-#include <linux/ptrace.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
 #include <linux/slab.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
-#include <linux/delay.h>
-#include <linux/ctype.h>	// isdigit
 #include <linux/netdevice.h>
 #include <linux/fddidevice.h>
 #include <linux/skbuff.h>
@@ -107,11 +104,6 @@
 
 
 // Define module-wide (static) routines
-static struct net_device *alloc_device(struct net_device *dev, u_long iobase);
-static struct net_device *insert_device(struct net_device *dev);
-static int fddi_dev_index(unsigned char *s);
-static void init_dev(struct net_device *dev, u_long iobase);
-static void link_modules(struct net_device *dev, struct net_device *tmp);
 static int skfp_driver_init(struct net_device *dev);
 static int skfp_open(struct net_device *dev);
 static int skfp_close(struct net_device *dev);
@@ -188,15 +180,6 @@
 // Define module-wide (static) variables
 
 static int num_boards;	/* total number of adapters configured */
-static int num_fddi;
-static int autoprobed;
-
-#ifdef MODULE
-static struct net_device *unlink_modules(struct net_device *p);
-static int loading_module = 1;
-#else
-static int loading_module;
-#endif				// MODULE
 
 #ifdef DRIVERDEBUG
 #define PRINTK(s, args...) printk(s, ## args)
@@ -207,9 +190,9 @@
 #define PRIV(dev) (&(((struct s_smc *)dev->priv)->os))
 
 /*
- * ==============
- * = skfp_probe =
- * ==============
+ * =================
+ * = skfp_init_one =
+ * =================
  *   
  * Overview:
  *   Probes for supported FDDI PCI controllers
@@ -218,30 +201,11 @@
  *   Condition code
  *       
  * Arguments:
- *   dev - pointer to device information
+ *   pdev - pointer to PCI device information
  *
  * Functional Description:
- *   This routine is called by the OS for each FDDI device name (fddi0,
- *   fddi1,...,fddi6, fddi7) specified in drivers/net/Space.c.
- *   If loaded as a module, it will detect and initialize all 
- *   adapters the first time it is called.
- *
- *   Let's say that skfp_probe() is getting called to initialize fddi0.
- *   Furthermore, let's say there are three supported controllers in the
- *   system.  Before skfp_probe() leaves, devices fddi0, fddi1, and fddi2
- *   will be initialized and a global flag will be set to indicate that
- *   skfp_probe() has already been called.
- *
- *   However...the OS doesn't know that we've already initialized
- *   devices fddi1 and fddi2 so skfp_probe() gets called again and again
- *   until it reaches the end of the device list for FDDI (presently,
- *   fddi7).  It's important that the driver "pretend" to probe for
- *   devices fddi1 and fddi2 and return success.  Devices fddi3
- *   through fddi7 will return failure since they weren't initialized.
- *
- *   This algorithm seems to work for the time being.  As other FDDI
- *   drivers are written for Linux, a more generic approach (perhaps
- *   similar to the Ethernet card approach) may need to be implemented.
+ *   This is now called by PCI driver registration process
+ *   for each board found.
  *   
  * Return Codes:
  *   0           - This device (fddi0, fddi1, etc) configured successfully
@@ -254,370 +218,166 @@
  *   initialized and the board resources are read and stored in
  *   the device structure.
  */
-static int skfp_probe(struct net_device *dev)
+static __init int skfp_init_one(struct pci_dev *pdev,
+				const struct pci_device_id *ent)
 {
-	int i;			/* used in for loops */
-	struct pci_dev *pdev = NULL;	/* PCI device structure */
-#ifndef MEM_MAPPED_IO
-	u16 port;		/* temporary I/O (port) address */
-	int port_len;		/* length of port address range (in bytes) */
-#else
-	unsigned long port;
-#endif
-	u16 command;	/* PCI Configuration space Command register val */
+	struct net_device *dev;
 	struct s_smc *smc;	/* board pointer */
-	struct net_device *tmp = dev;
-	u8 first_dev_used = 0;
-	u16 SubSysId;
+	u32 port, len;
+	int err;
 
 	PRINTK(KERN_INFO "entering skfp_probe\n");
 
-	/*
-	 * Verify whether we're going through skfp_probe() again
-	 *
-	 * If so, see if we're going through for a subsequent fddi device that
-	 * we've already initialized.  If we are, return success (0).  If not,
-	 * return failure (-ENODEV).
-	 */
+	if (num_boards == 0) 
+		printk("%s\n", boot_msg);
 
-	if (autoprobed) {
-		PRINTK(KERN_INFO "Already entered skfp_probe\n");
-		if (dev != NULL) {
-			if ((strncmp(dev->name, "fddi", 4) == 0) &&
-			    (dev->base_addr != 0)) {
-				return (0);
-			}
-			return (-ENODEV);
-		}
+	err = pci_enable_device(pdev);
+	if (err)
+		goto err_out1;
+
+
+#ifdef MEM_MAPPED_IO
+	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
+		printk(KERN_ERR "skfp: region is not an MMIO resource\n");
+		err = -EIO;
+		goto err_out1;
+	}
+	port = pci_resource_start(pdev, 0);
+	len = pci_resource_len(pdev, 0);
+
+	if (len < 0x4000) {
+		printk(KERN_ERR "skfp: Invalid PCI region size: %d\n", len);
+		err = -EIO;
+		goto err_out1;
 	}
-	autoprobed = 1;		/* set global flag */
-
-	printk("%s\n", boot_msg);
-
-	/* Scan for Syskonnect FDDI PCI controllers */
-	for (i = 0; i < SKFP_MAX_NUM_BOARDS; i++) {	// scan for PCI cards
-		PRINTK(KERN_INFO "Check device %d\n", i);
-		if ((pdev=pci_find_device(PCI_VENDOR_ID_SK, PCI_DEVICE_ID_SK_FP,
-			pdev)) == 0) {
-			break;
-		}
-		if (pci_enable_device(pdev))
-			continue;
-
-#ifndef MEM_MAPPED_IO
-		/* Verify that I/O enable bit is set (PCI slot is enabled) */
-		pci_read_config_word(pdev, PCI_COMMAND, &command);
-		if ((command & PCI_COMMAND_IO) == 0) {
-			PRINTK("I/O enable bit not set!");
-			PRINTK(" Verify that slot is enabled\n");
-			continue;
-		}
-
-		/* Turn off memory mapped space and enable mastering */
-
-		PRINTK(KERN_INFO "Command Reg: %04x\n", command);
-		command |= PCI_COMMAND_MASTER;
-		command &= ~PCI_COMMAND_MEMORY;
-		pci_write_config_word(pdev, PCI_COMMAND, command);
-
-		/* Read I/O base address from PCI Configuration Space */
-
-		pci_read_config_word(pdev, PCI_BASE_ADDRESS_1, &port);
-		port &= PCI_BASE_ADDRESS_IO_MASK; // clear I/O bit (bit 0)
-
-		/* Verify port address range is not already being used */
-
-		port_len = FP_IO_LEN;
-		if (check_region(port, port_len) != 0) {
-			printk("I/O range allocated to adapter");
-			printk(" (0x%X-0x%X) is already being used!\n", port,
-			       (port + port_len - 1));
-			continue;
-		}
 #else
-		/* Verify that MEM enable bit is set (PCI slot is enabled) */
-		pci_read_config_word(pdev, PCI_COMMAND, &command);
-		if ((command & PCI_COMMAND_MEMORY) == 0) {
-			PRINTK("MEMORY-I/O enable bit not set!");
-			PRINTK(" Verify that slot is enabled\n");
-			continue;
-		}
-
-		/* Turn off IO mapped space and enable mastering */
-
-		PRINTK(KERN_INFO "Command Reg: %04x\n", command);
-		command |= PCI_COMMAND_MASTER;
-		command &= ~PCI_COMMAND_IO;
-		pci_write_config_word(pdev, PCI_COMMAND, command);
-
-		port = pci_resource_start(pdev, 0);
-
-		port = (unsigned long)ioremap(port, 0x4000);
-		if (!port){
-			printk("skfp:  Unable to map MEMORY register, "
-			"FDDI adapter will be disabled.\n");
-			break;
-		}
-#endif
-
-		if ((!loading_module) || first_dev_used) {
-			/* Allocate a device structure for this adapter */
-			tmp = alloc_device(dev, port);
-		}
-		first_dev_used = 1;	// only significant first time
-
-		pci_read_config_word(pdev, PCI_SUBSYSTEM_ID, &SubSysId);
-
-		if (tmp != NULL) {
-			if (loading_module)
-				link_modules(dev, tmp);
-			dev = tmp;
-			init_dev(dev, port);
-			dev->irq = pdev->irq;
-
-			/* Initialize board structure with bus-specific info */
-
-			smc = (struct s_smc *) dev->priv;
-			smc->os.dev = dev;
-			smc->os.bus_type = SK_BUS_TYPE_PCI;
-			smc->os.pdev = *pdev;
-			smc->os.QueueSkb = MAX_TX_QUEUE_LEN;
-			smc->os.MaxFrameSize = MAX_FRAME_SIZE;
-			smc->os.dev = dev;
-			smc->hw.slot = -1;
-			smc->os.ResetRequested = FALSE;
-			skb_queue_head_init(&smc->os.SendSkbQueue);
-
-			if (skfp_driver_init(dev) == 0) {
-				int SubSysId = pdev->subsystem_device;
-				// only increment global board 
-				// count on success
-				num_boards++;
-				if ((SubSysId & 0xff00) == 0x5500 ||
-					(SubSysId & 0xff00) == 0x5800) {
-				printk("%s: SysKonnect FDDI PCI adapter"
-				       " found (SK-%04X)\n", dev->name,
-					SubSysId);
-				} else {
-					printk("%s: FDDI PCI adapter found\n",
-					       dev->name);
-				}
-			} else {
-				kfree(dev);
-				i = SKFP_MAX_NUM_BOARDS;	// stop search
-			}
-		}		// if (dev != NULL)
-	}			// for SKFP_MAX_NUM_BOARDS
-
-	/*
-	 * If we're at this point we're going through skfp_probe() for the
-	 * first time. Return success (0) if we've initialized 1 or more
-	 * boards. Otherwise, return failure (-ENODEV).
-	 */
-
-	if (num_boards > 0)
-		return (0);
-	else {
-		release_region (dev->base_addr, FP_IO_LEN);
-		printk("no SysKonnect FDDI adapter found\n");
-		return (-ENODEV);
+	if (!(pci_resource_flags(pdev, 1) & IO_RESOURCE_IO)) {
+		printk(KERN_ERR "skfp: region is not PIO resource\n");
+		err = -EIO;
+		goto err_out1;
 	}
-}				// skfp_probe
-
-
-/************************
- *
- * Search the entire 'fddi' device list for a fixed probe. If a match isn't
- * found then check for an autoprobe or unused device location. If they
- * are not available then insert a new device structure at the end of
- * the current list.
- *
- ************************/
-static struct net_device *alloc_device(struct net_device *dev, u_long iobase)
-{
-	struct net_device *adev = NULL;
-	int fixed = 0, new_dev = 0;
 
-	PRINTK(KERN_INFO "entering alloc_device\n");
-	if (!dev)
-		return dev;
-
-	num_fddi = fddi_dev_index(dev->name);
-	if (loading_module) {
-		num_fddi++;
-		dev = insert_device(dev);
-		return dev;
+	port = pci_resource_start(pdev, 1);
+	len = pci_resource_len(pdev, 1);
+	if (len < FP_IO_LEN) {
+		printk(KERN_ERR "skfp: Invalid PCI region size: %d\n",
+		       io_len);
+		err = -EIO;
+		goto err_out1;
 	}
-	while (1) {
-		if (((dev->base_addr == NO_ADDRESS) ||
-		     (dev->base_addr == 0)) && !adev) {
-			adev = dev;
-		} else if ((dev->priv == NULL) && (dev->base_addr == iobase)) {
-			fixed = 1;
-		} else {
-			if (dev->next == NULL) {
-				new_dev = 1;
-			} else if (strncmp(dev->next->name, "fddi", 4) != 0) {
-				new_dev = 1;
-			}
-		}
-		if ((dev->next == NULL) || new_dev || fixed)
-			break;
-		dev = dev->next;
-		num_fddi++;
-	}			// while (1)
-
-	if (adev && !fixed) {
-		dev = adev;
-		num_fddi = fddi_dev_index(dev->name);
-		new_dev = 0;
-	}
-	if (((dev->next == NULL) && ((dev->base_addr != NO_ADDRESS) &&
-				     (dev->base_addr != 0)) && !fixed) ||
-	    new_dev) {
-		num_fddi++;	/* New device */
-		dev = insert_device(dev);
-	}
-	if (dev) {
-		if (!dev->priv) {
-			/* Allocate space for private board structure */
-			dev->priv = (void *) kmalloc(sizeof(struct s_smc),
-						     GFP_KERNEL);
-			if (dev->priv == NULL) {
-				printk("%s: Could not allocate memory for",
-					dev->name);
-				printk(" private board structure!\n");
-				return (NULL);
-			}
-			/* clear structure */
-			memset(dev->priv, 0, sizeof(struct s_smc));
-		}
+#endif
+	err = pci_request_regions(pdev, "skfddi");
+	if (err)
+		goto err_out1;
+
+	pci_set_master(pdev);
+
+	dev = alloc_fddidev(sizeof(struct s_smc));
+	if (!dev) {
+		printk(KERN_ERR "skfp: Unable to allocate fddi device, "
+				"FDDI adapter will be disabled.\n");
+		err = -ENOMEM;
+		goto err_out2;
+	}
+
+#ifdef MEM_MAPPED_IO
+	dev->base_addr = (unsigned long) ioremap(port, len);
+	if (!dev->base_addr) {
+		printk(KERN_ERR "skfp:  Unable to map MEMORY register, "
+				"FDDI adapter will be disabled.\n");
+		err = -EIO;
+		goto err_out3;
 	}
-	return dev;
-}				// alloc_device
-
-
-
-/************************
- *
- * Initialize device structure
- *
- ************************/
-static void init_dev(struct net_device *dev, u_long iobase)
-{
-	/* Initialize new device structure */
-
-	dev->mem_end = 0;	/* shared memory isn't used */
-	dev->mem_start = 0;	/* shared memory isn't used */
-	dev->base_addr = iobase;	/* save port (I/O) base address */
-	dev->if_port = 0;	/* not applicable to FDDI adapters */
-	dev->dma = 0;		/* Bus Master DMA doesn't require channel */
-	dev->irq = 0;
-
-	netif_start_queue(dev);
+#else
+	dev->base_addr = port;
+#endif
 
+	dev->irq = pdev->irq;
 	dev->get_stats = &skfp_ctl_get_stats;
 	dev->open = &skfp_open;
 	dev->stop = &skfp_close;
+	dev->init = &skfp_driver_init;
 	dev->hard_start_xmit = &skfp_send_pkt;
-	dev->hard_header = NULL;	/* set in fddi_setup() */
-	dev->rebuild_header = NULL;	/* set in fddi_setup() */
 	dev->set_multicast_list = &skfp_ctl_set_multicast_list;
 	dev->set_mac_address = &skfp_ctl_set_mac_address;
 	dev->do_ioctl = &skfp_ioctl;
-	dev->set_config = NULL;	/* not supported for now &&& */
 	dev->header_cache_update = NULL;	/* not supported */
-	dev->change_mtu = NULL;	/* set in fddi_setup() */
 
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	/* Initialize remaining device structure information */
-	fddi_setup(dev);
-}				// init_device
+	/* Initialize board structure with bus-specific info */
+	smc = (struct s_smc *) dev->priv;
+	smc->os.dev = dev;
+	smc->os.bus_type = SK_BUS_TYPE_PCI;
+	smc->os.pdev = *pdev;
+	smc->os.QueueSkb = MAX_TX_QUEUE_LEN;
+	smc->os.MaxFrameSize = MAX_FRAME_SIZE;
+	smc->os.dev = dev;
+	smc->hw.slot = -1;
+	smc->os.ResetRequested = FALSE;
+	skb_queue_head_init(&smc->os.SendSkbQueue);
+
+	err = register_netdev(dev);
+	if (err)
+		goto err_out4;
+
+	++num_boards;
+	pci_set_drvdata(pdev, dev);
+
+	if ((pdev->subsystem_device & 0xff00) == 0x5500 ||
+	    (pdev->subsystem_device & 0xff00) == 0x5800) 
+		printk("%s: SysKonnect FDDI PCI adapter"
+		       " found (SK-%04X)\n", dev->name,	
+		       pdev->subsystem_device);
+	else
+		printk("%s: FDDI PCI adapter found\n", dev->name);
 
+	return 0;
+err_out4:
+#ifdef MEM_MAPPED_IO
+	iounmap((void *) dev->base_addr);
+#endif
+err_out3:
+	free_netdev(dev);
+err_out2:
+	pci_release_regions(pdev);
+err_out1:
+	return err;
+}
 
-/************************
- *
- * If at end of fddi device list and can't use current entry, malloc
- * one up. If memory could not be allocated, print an error message.
- *
-************************/
-static struct net_device *insert_device(struct net_device *dev)
+/*
+ * Called for each adapter board from pci_unregister_driver
+ */
+static void __devexit skfp_remove_one(struct pci_dev *pdev)
 {
-	struct net_device *new;
-	int len;
+	struct net_device *p = pci_get_drvdata(pdev);
+	struct s_smc *lp = p->priv;
 
-	PRINTK(KERN_INFO "entering insert_device\n");
-	len = sizeof(struct net_device) + sizeof(struct s_smc);
-	new = (struct net_device *) kmalloc(len, GFP_KERNEL);
-	if (new == NULL) {
-		printk("fddi%d: Device not initialised, insufficient memory\n",
-		       num_fddi);
-		return NULL;
-	} else {
-		memset((char *) new, 0, len);
-		new->priv = (struct s_smc *) (new + 1);
-		new->init = skfp_probe;
-		if (!loading_module) {
-			new->next = dev->next;
-			dev->next = new;
-		}
-		/* create new device name */
-		if (num_fddi > 999) {
-			sprintf(new->name, "fddi????");
-		} else {
-			sprintf(new->name, "fddi%d", num_fddi);
-		}
-	}
-	return new;
-}				// insert_device
-
-
-/************************
- *
- * Get the number of a "fddiX" string
- *
- ************************/
-static int fddi_dev_index(unsigned char *s)
-{
-	int i = 0, j = 0;
+	unregister_netdev(p);
 
-	for (; *s; s++) {
-		if (isdigit(*s)) {
-			j = 1;
-			i = (i * 10) + (*s - '0');
-		} else if (j)
-			break;
+	if (lp->os.SharedMemAddr) {
+		pci_free_consistent(&lp->os.pdev,
+				    lp->os.SharedMemSize,
+				    lp->os.SharedMemAddr,
+				    lp->os.SharedMemDMA);
+		lp->os.SharedMemAddr = NULL;
+	}
+	if (lp->os.LocalRxBuffer) {
+		pci_free_consistent(&lp->os.pdev,
+				    MAX_FRAME_SIZE,
+				    lp->os.LocalRxBuffer,
+				    lp->os.LocalRxBufferDMA);
+		lp->os.LocalRxBuffer = NULL;
 	}
-	return i;
-}				// fddi_dev_index
-
-
-/************************
- *
- * Used if loaded as module only. Link the device structures
- * together. Needed to release them all at unload.
- *
-************************/
-static void link_modules(struct net_device *dev, struct net_device *tmp)
-{
-	struct net_device *p = dev;
-
-	if (p) {
-		while (((struct s_smc *) (p->priv))->os.next_module) {
-			p = ((struct s_smc *) (p->priv))->os.next_module;
-		}
-
-		if (dev != tmp) {
-			((struct s_smc *) (p->priv))->os.next_module = tmp;
-		} else {
-			((struct s_smc *) (p->priv))->os.next_module = NULL;
-		}
-	}
-	return;
-}				// link_modules
-
+#ifdef MEM_MAPPED_IO
+	iounmap((void *) p->base_addr);
+#endif
+	pci_release_regions(pdev);
+	free_netdev(p);
 
+	pci_set_drvdata(pdev, NULL);
+}
 
 /*
  * ====================
@@ -644,11 +404,12 @@
  *    0 - initialization succeeded
  *   -1 - initialization failed
  */
-static int skfp_driver_init(struct net_device *dev)
+static __init int skfp_driver_init(struct net_device *dev)
 {
 	struct s_smc *smc = (struct s_smc *) dev->priv;
 	skfddi_priv *bp = PRIV(dev);
 	u8 val;			/* used for I/O read/writes */
+	int err = -EIO;
 
 	PRINTK(KERN_INFO "entering skfp_driver_init\n");
 
@@ -729,7 +490,7 @@
 				    bp->LocalRxBuffer, bp->LocalRxBufferDMA);
 		bp->LocalRxBuffer = NULL;
 	}
-	return (-1);
+	return err;
 }				// skfp_driver_init
 
 
@@ -757,14 +518,15 @@
 static int skfp_open(struct net_device *dev)
 {
 	struct s_smc *smc = (struct s_smc *) dev->priv;
+	int err;
 
 	PRINTK(KERN_INFO "entering skfp_open\n");
 	/* Register IRQ - support shared interrupts by passing device ptr */
-	if (request_irq(dev->irq, (void *) skfp_interrupt, SA_SHIRQ,
-			dev->name, dev)) {
-		printk("%s: Requested IRQ %d is busy\n", dev->name, dev->irq);
-		return (-EAGAIN);
-	}
+	err = request_irq(dev->irq, (void *) skfp_interrupt, SA_SHIRQ,
+			  dev->name, dev);
+	if (err)
+		return err;
+
 	/*
 	 * Set current address to factory MAC address
 	 *
@@ -788,6 +550,7 @@
 	/* Disable promiscuous filter settings */
 	mac_drv_rx_mode(smc, RX_DISABLE_PROMISC);
 
+	netif_start_queue(dev);
 	return (0);
 }				// skfp_open
 
@@ -822,7 +585,6 @@
 static int skfp_close(struct net_device *dev)
 {
 	struct s_smc *smc = (struct s_smc *) dev->priv;
-	struct sk_buff *skb;
 	skfddi_priv *bp = PRIV(dev);
 
 	CLI_FBI();
@@ -835,13 +597,7 @@
 	/* Deregister (free) IRQ */
 	free_irq(dev->irq, dev);
 
-	for (;;) {
-		skb = skb_dequeue(&bp->SendSkbQueue);
-		if (skb == NULL)
-			break;
-		bp->QueueSkb++;
-		dev_kfree_skb(skb);
-	}
+	skb_queue_purge(&bp->SendSkbQueue);
 
 	return (0);
 }				// skfp_close
@@ -1276,6 +1032,8 @@
 		break;
 	default:
 		printk("ioctl for %s: unknow cmd: %04x\n", dev->name, ioc.cmd);
+		status = -EOPNOTSUPP;
+
 	}			// switch
 
 	return status;
@@ -2529,63 +2287,21 @@
 
 }				// drv_reset_indication
 
-
-static struct net_device *mdev;
+static struct pci_driver skfddi_pci_driver = {
+	.name		= "skfddi",
+	.id_table	= skfddi_pci_tbl,
+	.probe		= skfp_init_one,
+	.remove		= __devexit_p(skfp_remove_one),
+};
 
 static int __init skfd_init(void)
 {
-	struct net_device *p;
-
-	if ((mdev = insert_device(NULL)) == NULL)
-		return -ENOMEM;
-
-	for (p = mdev; p != NULL; p = ((struct s_smc *)p->priv)->os.next_module) {
-		if (register_netdev(p) != 0) {
-			printk("skfddi init_module failed\n");
-			return -EIO;
-		}
-	}
-
-	return 0;
+	return pci_module_init(&skfddi_pci_driver);
 }
 
-static struct net_device *unlink_modules(struct net_device *p)
-{
-	struct net_device *next = NULL;
-
-	if (p->priv) {		/* Private areas allocated? */
-		struct s_smc *lp = (struct s_smc *) p->priv;
-
-		next = lp->os.next_module;
-
-		if (lp->os.SharedMemAddr) {
-			pci_free_consistent(&lp->os.pdev,
-					    lp->os.SharedMemSize,
-					    lp->os.SharedMemAddr,
-					    lp->os.SharedMemDMA);
-			lp->os.SharedMemAddr = NULL;
-		}
-		if (lp->os.LocalRxBuffer) {
-			pci_free_consistent(&lp->os.pdev,
-					    MAX_FRAME_SIZE,
-					    lp->os.LocalRxBuffer,
-					    lp->os.LocalRxBufferDMA);
-			lp->os.LocalRxBuffer = NULL;
-		}
-		release_region(p->base_addr, 
-			(lp->os.bus_type == SK_BUS_TYPE_PCI ? FP_IO_LEN : 0));
-	}
-	unregister_netdev(p);
-	printk("%s: unloaded\n", p->name);
-	free_netdev(p);		/* Free the device structure */
-
-	return next;
-}				// unlink_modules
-
 static void __exit skfd_exit(void)
 {
-	while (mdev)
-		mdev = unlink_modules(mdev);
+	pci_unregister_driver(&skfddi_pci_driver);
 }
 
 module_init(skfd_init);
