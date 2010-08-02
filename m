From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers/net/wan/farsync.c: Use standard pr_<level>
Date: Sun, 01 Aug 2010 20:20:17 -0700
Message-ID: <1280719217.1752.6.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Kevin Curtis <kevin.curtis@farsite.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove locally defined equivalents

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wan/farsync.c |  111 +++++++++++++++++++++-----------------------
 1 files changed, 53 insertions(+), 58 deletions(-)

diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index 43b7727..06965a0 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -15,6 +15,8 @@
  *      Maintainer:  Kevin Curtis  <kevin.curtis@farsite.co.uk>
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/version.h>
@@ -511,21 +513,19 @@ static int fst_debug_mask = { FST_DEBUG };
  * support variable numbers of macro parameters. The inverted if prevents us
  * eating someone else's else clause.
  */
-#define dbg(F,fmt,A...) if ( ! ( fst_debug_mask & (F))) \
-                                ; \
-                        else \
-                                printk ( KERN_DEBUG FST_NAME ": " fmt, ## A )
-
+#define dbg(F, fmt, args...)					\
+do {								\
+	if (fst_debug_mask & (F))				\
+		printk(KERN_DEBUG pr_fmt(fmt), ##args);		\
+} while (0)
 #else
-#define dbg(X...)		/* NOP */
+#define dbg(F, fmt, args...)					\
+do {								\
+	if (0)							\
+		printk(KERN_DEBUG pr_fmt(fmt), ##args);		\
+} while (0)
 #endif
 
-/*      Printing short cuts
- */
-#define printk_err(fmt,A...)    printk ( KERN_ERR     FST_NAME ": " fmt, ## A )
-#define printk_warn(fmt,A...)   printk ( KERN_WARNING FST_NAME ": " fmt, ## A )
-#define printk_info(fmt,A...)   printk ( KERN_INFO    FST_NAME ": " fmt, ## A )
-
 /*
  *      PCI ID lookup table
  */
@@ -961,7 +961,7 @@ fst_issue_cmd(struct fst_port_info *port, unsigned short cmd)
 		spin_lock_irqsave(&card->card_lock, flags);
 
 		if (++safety > 2000) {
-			printk_err("Mailbox safety timeout\n");
+			pr_err("Mailbox safety timeout\n");
 			break;
 		}
 
@@ -1241,8 +1241,8 @@ fst_intr_rx(struct fst_card_info *card, struct fst_port_info *port)
 		 * This seems to happen on the TE1 interface sometimes
 		 * so throw the frame away and log the event.
 		 */
-		printk_err("Frame received with 0 length. Card %d Port %d\n",
-			   card->card_no, port->index);
+		pr_err("Frame received with 0 length. Card %d Port %d\n",
+		       card->card_no, port->index);
 		/* Return descriptor to card */
 		FST_WRB(card, rxDescrRing[pi][rxp].bits, DMA_OWN);
 
@@ -1486,9 +1486,8 @@ fst_intr(int dummy, void *dev_id)
 	 */
 	dbg(DBG_INTR, "intr: %d %p\n", card->irq, card);
 	if (card->state != FST_RUNNING) {
-		printk_err
-		    ("Interrupt received for card %d in a non running state (%d)\n",
-		     card->card_no, card->state);
+		pr_err("Interrupt received for card %d in a non running state (%d)\n",
+		       card->card_no, card->state);
 
 		/* 
 		 * It is possible to really be running, i.e. we have re-loaded
@@ -1614,8 +1613,7 @@ fst_intr(int dummy, void *dev_id)
 			break;
 
 		default:
-			printk_err("intr: unknown card event %d. ignored\n",
-				   event);
+			pr_err("intr: unknown card event %d. ignored\n", event);
 			break;
 		}
 
@@ -1637,13 +1635,13 @@ check_started_ok(struct fst_card_info *card)
 
 	/* Check structure version and end marker */
 	if (FST_RDW(card, smcVersion) != SMC_VERSION) {
-		printk_err("Bad shared memory version %d expected %d\n",
-			   FST_RDW(card, smcVersion), SMC_VERSION);
+		pr_err("Bad shared memory version %d expected %d\n",
+		       FST_RDW(card, smcVersion), SMC_VERSION);
 		card->state = FST_BADVERSION;
 		return;
 	}
 	if (FST_RDL(card, endOfSmcSignature) != END_SIG) {
-		printk_err("Missing shared memory signature\n");
+		pr_err("Missing shared memory signature\n");
 		card->state = FST_BADVERSION;
 		return;
 	}
@@ -1651,11 +1649,11 @@ check_started_ok(struct fst_card_info *card)
 	if ((i = FST_RDB(card, taskStatus)) == 0x01) {
 		card->state = FST_RUNNING;
 	} else if (i == 0xFF) {
-		printk_err("Firmware initialisation failed. Card halted\n");
+		pr_err("Firmware initialisation failed. Card halted\n");
 		card->state = FST_HALTED;
 		return;
 	} else if (i != 0x00) {
-		printk_err("Unknown firmware status 0x%x\n", i);
+		pr_err("Unknown firmware status 0x%x\n", i);
 		card->state = FST_HALTED;
 		return;
 	}
@@ -1665,9 +1663,10 @@ check_started_ok(struct fst_card_info *card)
 	 * existing firmware etc so we just report it for the moment.
 	 */
 	if (FST_RDL(card, numberOfPorts) != card->nports) {
-		printk_warn("Port count mismatch on card %d."
-			    " Firmware thinks %d we say %d\n", card->card_no,
-			    FST_RDL(card, numberOfPorts), card->nports);
+		pr_warning("Port count mismatch on card %d. "
+			   "Firmware thinks %d we say %d\n",
+			   card->card_no,
+			   FST_RDL(card, numberOfPorts), card->nports);
 	}
 }
 
@@ -2090,9 +2089,8 @@ fst_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		 */
 
 		if (card->state != FST_RUNNING) {
-			printk_err
-			    ("Attempt to configure card %d in non-running state (%d)\n",
-			     card->card_no, card->state);
+			pr_err("Attempt to configure card %d in non-running state (%d)\n",
+			       card->card_no, card->state);
 			return -EIO;
 		}
 		if (copy_from_user(&info, ifr->ifr_data, sizeof (info))) {
@@ -2384,8 +2382,8 @@ fst_init_card(struct fst_card_info *card)
                 err = register_hdlc_device(card->ports[i].dev);
                 if (err < 0) {
 			int j;
-                        printk_err ("Cannot register HDLC device for port %d"
-                                    " (errno %d)\n", i, -err );
+			pr_err("Cannot register HDLC device for port %d (errno %d)\n",
+			       i, -err);
 			for (j = i; j < card->nports; j++) {
 				free_netdev(card->ports[j].dev);
 				card->ports[j].dev = NULL;
@@ -2395,10 +2393,10 @@ fst_init_card(struct fst_card_info *card)
                 }
 	}
 
-	printk_info("%s-%s: %s IRQ%d, %d ports\n",
-	       port_to_dev(&card->ports[0])->name,
-	       port_to_dev(&card->ports[card->nports - 1])->name,
-	       type_strings[card->type], card->irq, card->nports);
+	pr_info("%s-%s: %s IRQ%d, %d ports\n",
+		port_to_dev(&card->ports[0])->name,
+		port_to_dev(&card->ports[card->nports - 1])->name,
+		type_strings[card->type], card->irq, card->nports);
 }
 
 static const struct net_device_ops fst_ops = {
@@ -2417,19 +2415,17 @@ static const struct net_device_ops fst_ops = {
 static int __devinit
 fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
-	static int firsttime_done = 0;
 	static int no_of_cards_added = 0;
 	struct fst_card_info *card;
 	int err = 0;
 	int i;
 
-	if (!firsttime_done) {
-		printk_info("FarSync WAN driver " FST_USER_VERSION
-		       " (c) 2001-2004 FarSite Communications Ltd.\n");
-		firsttime_done = 1;
-		dbg(DBG_ASS, "The value of debug mask is %x\n", fst_debug_mask);
-	}
-
+	printk_once(KERN_INFO
+		    pr_fmt("FarSync WAN driver " FST_USER_VERSION
+			   " (c) 2001-2004 FarSite Communications Ltd.\n"));
+#if FST_DEBUG
+	dbg(DBG_ASS, "The value of debug mask is %x\n", fst_debug_mask);
+#endif
 	/*
 	 * We are going to be clever and allow certain cards not to be
 	 * configured.  An exclude list can be provided in /etc/modules.conf
@@ -2441,8 +2437,8 @@ fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		 */
 		for (i = 0; i < fst_excluded_cards; i++) {
 			if ((pdev->devfn) >> 3 == fst_excluded_list[i]) {
-				printk_info("FarSync PCI device %d not assigned\n",
-				       (pdev->devfn) >> 3);
+				pr_info("FarSync PCI device %d not assigned\n",
+					(pdev->devfn) >> 3);
 				return -EBUSY;
 			}
 		}
@@ -2451,20 +2447,19 @@ fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* Allocate driver private data */
 	card = kzalloc(sizeof (struct fst_card_info), GFP_KERNEL);
 	if (card == NULL) {
-		printk_err("FarSync card found but insufficient memory for"
-			   " driver storage\n");
+		pr_err("FarSync card found but insufficient memory for driver storage\n");
 		return -ENOMEM;
 	}
 
 	/* Try to enable the device */
 	if ((err = pci_enable_device(pdev)) != 0) {
-		printk_err("Failed to enable card. Err %d\n", -err);
+		pr_err("Failed to enable card. Err %d\n", -err);
 		kfree(card);
 		return err;
 	}
 
 	if ((err = pci_request_regions(pdev, "FarSync")) !=0) {
-	        printk_err("Failed to allocate regions. Err %d\n", -err);
+		pr_err("Failed to allocate regions. Err %d\n", -err);
 		pci_disable_device(pdev);
 		kfree(card);
 	        return err;
@@ -2475,14 +2470,14 @@ fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	card->phys_mem = pci_resource_start(pdev, 2);
 	card->phys_ctlmem = pci_resource_start(pdev, 3);
 	if ((card->mem = ioremap(card->phys_mem, FST_MEMSIZE)) == NULL) {
-		printk_err("Physical memory remap failed\n");
+		pr_err("Physical memory remap failed\n");
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
 		kfree(card);
 		return -ENODEV;
 	}
 	if ((card->ctlmem = ioremap(card->phys_ctlmem, 0x10)) == NULL) {
-		printk_err("Control memory remap failed\n");
+		pr_err("Control memory remap failed\n");
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
 		kfree(card);
@@ -2492,7 +2487,7 @@ fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* Register the interrupt handler */
 	if (request_irq(pdev->irq, fst_intr, IRQF_SHARED, FST_DEV_NAME, card)) {
-		printk_err("Unable to register interrupt %d\n", card->irq);
+		pr_err("Unable to register interrupt %d\n", card->irq);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
 		iounmap(card->ctlmem);
@@ -2523,7 +2518,7 @@ fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		if (!dev) {
 			while (i--)
 				free_netdev(card->ports[i].dev);
-			printk_err ("FarSync: out of memory\n");
+			pr_err("FarSync: out of memory\n");
                         free_irq(card->irq, card);
                         pci_release_regions(pdev);
                         pci_disable_device(pdev);
@@ -2587,7 +2582,7 @@ fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		    pci_alloc_consistent(card->device, FST_MAX_MTU,
 					 &card->rx_dma_handle_card);
 		if (card->rx_dma_handle_host == NULL) {
-			printk_err("Could not allocate rx dma buffer\n");
+			pr_err("Could not allocate rx dma buffer\n");
 			fst_disable_intr(card);
 			pci_release_regions(pdev);
 			pci_disable_device(pdev);
@@ -2600,7 +2595,7 @@ fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		    pci_alloc_consistent(card->device, FST_MAX_MTU,
 					 &card->tx_dma_handle_card);
 		if (card->tx_dma_handle_host == NULL) {
-			printk_err("Could not allocate tx dma buffer\n");
+			pr_err("Could not allocate tx dma buffer\n");
 			fst_disable_intr(card);
 			pci_release_regions(pdev);
 			pci_disable_device(pdev);
@@ -2672,7 +2667,7 @@ fst_init(void)
 static void __exit
 fst_cleanup_module(void)
 {
-	printk_info("FarSync WAN driver unloading\n");
+	pr_info("FarSync WAN driver unloading\n");
 	pci_unregister_driver(&fst_driver);
 }
 
