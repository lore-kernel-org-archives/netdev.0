From: chas williams (contractor) <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [nicstar] convert to new style pci module (by "Jorge Boncompte [DTI2]" <jorge@dti2.net>)
Date: Tue, 13 Jan 2004 00:03:50 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401130503.i0D53nRr019754@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com, "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.4

--thanks

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1382  -> 1.1383 
#	drivers/atm/nicstar.c	1.12    -> 1.13   
#	drivers/atm/atmdev_init.c	1.5     -> 1.6    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/01/12	chas@relax.cmf.nrl.navy.mil	1.1383
# [ATM]: [nicstar] convert to new style pci module (by "Jorge Boncompte [DTI2]" <jorge@dti2.net>)
# --------------------------------------------
#
diff -Nru a/drivers/atm/atmdev_init.c b/drivers/atm/atmdev_init.c
--- a/drivers/atm/atmdev_init.c	Mon Jan 12 20:11:48 2004
+++ b/drivers/atm/atmdev_init.c	Mon Jan 12 20:11:48 2004
@@ -10,9 +10,6 @@
 #ifdef CONFIG_ATM_ZATM
 extern int zatm_detect(void);
 #endif
-#ifdef CONFIG_ATM_NICSTAR
-extern int nicstar_detect(void);
-#endif
 #ifdef CONFIG_ATM_AMBASSADOR
 extern int amb_detect(void);
 #endif
@@ -40,9 +37,6 @@
 	devs = 0;
 #ifdef CONFIG_ATM_ZATM
 	devs += zatm_detect();
-#endif
-#ifdef CONFIG_ATM_NICSTAR
-	devs += nicstar_detect();
 #endif
 #ifdef CONFIG_ATM_AMBASSADOR
 	devs += amb_detect();
diff -Nru a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
--- a/drivers/atm/nicstar.c	Mon Jan 12 20:11:48 2004
+++ b/drivers/atm/nicstar.c	Mon Jan 12 20:11:48 2004
@@ -214,8 +214,8 @@
 
 static u32 ns_read_sram(ns_dev *card, u32 sram_address);
 static void ns_write_sram(ns_dev *card, u32 sram_address, u32 *value, int count);
-static int __init ns_init_card(int i, struct pci_dev *pcidev);
-static void __init ns_init_card_error(ns_dev *card, int error);
+static int __devinit ns_init_card(int i, struct pci_dev *pcidev);
+static void __devinit ns_init_card_error(ns_dev *card, int error);
 static scq_info *get_scq(int size, u32 scd);
 static void free_scq(scq_info *scq, struct atm_vcc *vcc);
 static void push_rxbufs(ns_dev *card, u32 type, u32 handle1, u32 addr1,
@@ -276,198 +276,152 @@
 
 /* Functions*******************************************************************/
 
-#ifdef MODULE
-
-int __init init_module(void)
+static int __devinit nicstar_init_one(struct pci_dev *pcidev,
+					 const struct pci_device_id *ent)
 {
-   int i;
-   unsigned error = 0;	/* Initialized to remove compile warning */
-   struct pci_dev *pcidev;
-
-   XPRINTK("nicstar: init_module() called.\n");
-   if(!pci_present())
-   {
-      printk("nicstar: no PCI subsystem found.\n");
-      return -EIO;
-   }
+   static int index = -1;
+   unsigned int error;
 
-   for(i = 0; i < NS_MAX_CARDS; i++)
-      cards[i] = NULL;
+   index++;
+   cards[index] = NULL;
 
-   pcidev = NULL;
-   for(i = 0; i < NS_MAX_CARDS; i++)
-   {
-      if ((pcidev = pci_find_device(PCI_VENDOR_ID_IDT,
-                                    PCI_DEVICE_ID_IDT_IDT77201,
-                                    pcidev)) == NULL)
-         break;
-
-      error = ns_init_card(i, pcidev);
-      if (error)
-         cards[i--] = NULL;	/* Try to find another card but don't increment index */
+   error = ns_init_card(index, pcidev);
+   if (error) {
+      cards[index--] = NULL;	/* don't increment index */
+      goto err_out;
    }
 
-   if (i == 0)
-   {
-      if (!error)
-      {
-         printk("nicstar: no cards found.\n");
-         return -ENXIO;
-      }
-      else
-         return -EIO;
-   }
-   TXPRINTK("nicstar: TX debug enabled.\n");
-   RXPRINTK("nicstar: RX debug enabled.\n");
-   PRINTK("nicstar: General debug enabled.\n");
-#ifdef PHY_LOOPBACK
-   printk("nicstar: using PHY loopback.\n");
-#endif /* PHY_LOOPBACK */
-   XPRINTK("nicstar: init_module() returned.\n");
-
-   init_timer(&ns_timer);
-   ns_timer.expires = jiffies + NS_POLL_PERIOD;
-   ns_timer.data = 0UL;
-   ns_timer.function = ns_poll;
-   add_timer(&ns_timer);
    return 0;
+err_out:
+   return -ENODEV;
 }
 
 
 
-void cleanup_module(void)
+static void __devexit nicstar_remove_one(struct pci_dev *pcidev)
 {
    int i, j;
-   unsigned short pci_command;
-   ns_dev *card;
+   ns_dev *card = pci_get_drvdata(pcidev);
    struct sk_buff *hb;
    struct sk_buff *iovb;
    struct sk_buff *lb;
    struct sk_buff *sb;
    
-   XPRINTK("nicstar: cleanup_module() called.\n");
-
-   if (MOD_IN_USE)
-      printk("nicstar: module in use, remove delayed.\n");
+   i = card->index;
 
-   del_timer(&ns_timer);
-
-   for (i = 0; i < NS_MAX_CARDS; i++)
-   {
-      if (cards[i] == NULL)
-         continue;
-
-      card = cards[i];
+   if (cards[i] == NULL)
+      return;
 
-      if (card->atmdev->phy && card->atmdev->phy->stop)
-        card->atmdev->phy->stop(card->atmdev);
+   if (card->atmdev->phy && card->atmdev->phy->stop)
+      card->atmdev->phy->stop(card->atmdev);
 
-      /* Stop everything */
-      writel(0x00000000, card->membase + CFG);
+   /* Stop everything */
+   writel(0x00000000, card->membase + CFG);
 
-      /* De-register device */
-      atm_dev_deregister(card->atmdev);
+   /* De-register device */
+   atm_dev_deregister(card->atmdev);
 
-      /* Disable memory mapping and busmastering */
-      if (pci_read_config_word(card->pcidev, PCI_COMMAND, &pci_command) != 0)
-      {
-         printk("nicstar%d: can't read PCI_COMMAND.\n", i);
-      }
-      pci_command &= ~(PCI_COMMAND_MEMORY | PCI_COMMAND_MASTER);
-      if (pci_write_config_word(card->pcidev, PCI_COMMAND, pci_command) != 0)
-      {
-         printk("nicstar%d: can't write PCI_COMMAND.\n", i);
-      }
-      
-      /* Free up resources */
-      j = 0;
-      PRINTK("nicstar%d: freeing %d huge buffers.\n", i, card->hbpool.count);
-      while ((hb = skb_dequeue(&card->hbpool.queue)) != NULL)
-      {
-         dev_kfree_skb_any(hb);
-	 j++;
-      }
-      PRINTK("nicstar%d: %d huge buffers freed.\n", i, j);
-      j = 0;
-      PRINTK("nicstar%d: freeing %d iovec buffers.\n", i, card->iovpool.count);
-      while ((iovb = skb_dequeue(&card->iovpool.queue)) != NULL)
-      {
-         dev_kfree_skb_any(iovb);
-         j++;
-      }
-      PRINTK("nicstar%d: %d iovec buffers freed.\n", i, j);
-      while ((lb = skb_dequeue(&card->lbpool.queue)) != NULL)
-         dev_kfree_skb_any(lb);
-      while ((sb = skb_dequeue(&card->sbpool.queue)) != NULL)
-         dev_kfree_skb_any(sb);
-      free_scq(card->scq0, NULL);
-      for (j = 0; j < NS_FRSCD_NUM; j++)
-      {
-         if (card->scd2vc[j] != NULL)
-	    free_scq(card->scd2vc[j]->scq, card->scd2vc[j]->tx_vcc);
-      }
-      kfree(card->rsq.org);
-      kfree(card->tsq.org);
-      free_irq(card->pcidev->irq, card);
-      iounmap((void *) card->membase);
-      kfree(card);
-      
+   /* Disable PCI device */
+   pci_disable_device(pcidev);
+   
+   /* Free up resources */
+   j = 0;
+   PRINTK("nicstar%d: freeing %d huge buffers.\n", i, card->hbpool.count);
+   while ((hb = skb_dequeue(&card->hbpool.queue)) != NULL)
+   {
+      dev_kfree_skb_any(hb);
+      j++;
    }
-   XPRINTK("nicstar: cleanup_module() returned.\n");
+   PRINTK("nicstar%d: %d huge buffers freed.\n", i, j);
+   j = 0;
+   PRINTK("nicstar%d: freeing %d iovec buffers.\n", i, card->iovpool.count);
+   while ((iovb = skb_dequeue(&card->iovpool.queue)) != NULL)
+   {
+      dev_kfree_skb_any(iovb);
+      j++;
+   }
+   PRINTK("nicstar%d: %d iovec buffers freed.\n", i, j);
+   while ((lb = skb_dequeue(&card->lbpool.queue)) != NULL)
+      dev_kfree_skb_any(lb);
+   while ((sb = skb_dequeue(&card->sbpool.queue)) != NULL)
+      dev_kfree_skb_any(sb);
+   free_scq(card->scq0, NULL);
+   for (j = 0; j < NS_FRSCD_NUM; j++)
+   {
+      if (card->scd2vc[j] != NULL)
+         free_scq(card->scd2vc[j]->scq, card->scd2vc[j]->tx_vcc);
+   }
+   kfree(card->rsq.org);
+   kfree(card->tsq.org);
+   free_irq(card->pcidev->irq, card);
+   iounmap((void *) card->membase);
+   kfree(card);
 }
 
 
-#else
 
-int __init nicstar_detect(void)
+static struct pci_device_id nicstar_pci_tbl[] __devinitdata =
 {
-   int i;
-   unsigned error = 0;	/* Initialized to remove compile warning */
-   struct pci_dev *pcidev;
+	{PCI_VENDOR_ID_IDT, PCI_DEVICE_ID_IDT_IDT77201,
+	    PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0,}			/* terminate list */
+};
+MODULE_DEVICE_TABLE(pci, nicstar_pci_tbl);
 
-   if(!pci_present())
-   {
-      printk("nicstar: no PCI subsystem found.\n");
-      return -EIO;
-   }
 
-   for(i = 0; i < NS_MAX_CARDS; i++)
-      cards[i] = NULL;
 
-   pcidev = NULL;
-   for(i = 0; i < NS_MAX_CARDS; i++)
-   {
-      if ((pcidev = pci_find_device(PCI_VENDOR_ID_IDT,
-                                    PCI_DEVICE_ID_IDT_IDT77201,
-                                    pcidev)) == NULL)
-         break;
+static struct pci_driver nicstar_driver = {
+	.name		= "nicstar",
+	.id_table	= nicstar_pci_tbl,
+	.probe		= nicstar_init_one,
+	.remove		= __devexit_p(nicstar_remove_one),
+};
 
-      error = ns_init_card(i, pcidev);
-      if (error)
-         cards[i--] = NULL;	/* Try to find another card but don't increment index */
-   }
 
-   if (i == 0 && error)
-      return -EIO;
 
+static int __init nicstar_init(void)
+{
+   unsigned error = 0;	/* Initialized to remove compile warning */
+
+   XPRINTK("nicstar: nicstar_init() called.\n");
+
+   error = pci_module_init(&nicstar_driver);
+   
    TXPRINTK("nicstar: TX debug enabled.\n");
    RXPRINTK("nicstar: RX debug enabled.\n");
    PRINTK("nicstar: General debug enabled.\n");
 #ifdef PHY_LOOPBACK
    printk("nicstar: using PHY loopback.\n");
 #endif /* PHY_LOOPBACK */
-   XPRINTK("nicstar: init_module() returned.\n");
+   XPRINTK("nicstar: nicstar_init() returned.\n");
 
-   init_timer(&ns_timer);
-   ns_timer.expires = jiffies + NS_POLL_PERIOD;
-   ns_timer.data = 0UL;
-   ns_timer.function = ns_poll;
-   add_timer(&ns_timer);
-   return i;
+   if (!error) {
+      init_timer(&ns_timer);
+      ns_timer.expires = jiffies + NS_POLL_PERIOD;
+      ns_timer.data = 0UL;
+      ns_timer.function = ns_poll;
+      add_timer(&ns_timer);
+   }
+   
+   return error;
 }
 
 
-#endif /* MODULE */
+
+static void __exit nicstar_cleanup(void)
+{
+   XPRINTK("nicstar: nicstar_cleanup() called.\n");
+
+   if (MOD_IN_USE)
+      printk("nicstar: module in use, remove delayed.\n");
+
+   del_timer(&ns_timer);
+
+   pci_unregister_driver(&nicstar_driver);
+
+   XPRINTK("nicstar: nicstar_cleanup() returned.\n");
+}
+
 
 
 static u32 ns_read_sram(ns_dev *card, u32 sram_address)
@@ -509,11 +463,10 @@
 }
 
 
-static int __init ns_init_card(int i, struct pci_dev *pcidev)
+static int __devinit ns_init_card(int i, struct pci_dev *pcidev)
 {
    int j;
    struct ns_dev *card = NULL;
-   unsigned short pci_command;
    unsigned char pci_latency;
    unsigned error;
    u32 data;
@@ -542,6 +495,8 @@
    spin_lock_init(&card->int_lock);
    spin_lock_init(&card->res_lock);
       
+   pci_set_drvdata(pcidev, card);
+   
    card->index = i;
    card->atmdev = NULL;
    card->pcidev = pcidev;
@@ -556,21 +511,7 @@
    }
    PRINTK("nicstar%d: membase at 0x%x.\n", i, card->membase);
 
-   if (pci_read_config_word(pcidev, PCI_COMMAND, &pci_command) != 0)
-   {
-      printk("nicstar%d: can't read PCI_COMMAND.\n", i);
-      error = 4;
-      ns_init_card_error(card, error);
-      return error;
-   }
-   pci_command |= (PCI_COMMAND_MEMORY | PCI_COMMAND_MASTER);
-   if (pci_write_config_word(pcidev, PCI_COMMAND, pci_command) != 0)
-   {
-      printk("nicstar%d: can't write PCI_COMMAND.\n", i);
-      error = 5;
-      ns_init_card_error(card, error);
-      return error;
-   }
+   pci_set_master(pcidev);
 
    if (pci_read_config_byte(pcidev, PCI_LATENCY_TIMER, &pci_latency) != 0)
    {
@@ -996,7 +937,7 @@
 
 
 
-static void __init ns_init_card_error(ns_dev *card, int error)
+static void __devinit ns_init_card_error(ns_dev *card, int error)
 {
    if (error >= 17)
    {
@@ -1045,6 +986,7 @@
    }
    if (error >= 3)
    {
+      pci_disable_device(card->pcidev);
       kfree(card);
    }
 }
@@ -3148,3 +3090,8 @@
    spin_unlock_irqrestore(&card->res_lock, flags);
    return (unsigned char) data;
 }
+
+
+
+module_init(nicstar_init);
+module_exit(nicstar_cleanup);
