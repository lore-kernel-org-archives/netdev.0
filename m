From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] move dmascc away from setup.c
Date: Tue, 3 Jun 2003 10:23:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030603082326.GA22946@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Yeah, it's a isa driver but it already was in the setup.c
pci probes list.

Also use SET_MODULE_OWNER instead of MOD_{INC,DEC}_USE_COUNT.


--- 1.15/drivers/net/setup.c	Thu May 29 11:57:13 2003
+++ edited/drivers/net/setup.c	Mon Jun  2 12:16:07 2003
@@ -9,8 +9,6 @@
 #include <linux/init.h>
 #include <linux/netlink.h>
 
-extern int dmascc_init(void);
-
 extern int scc_enet_init(void); 
 extern int fec_enet_init(void); 
 
@@ -29,10 +27,6 @@
 	/*
 	 *	Early setup devices
 	 */
-
-#if defined(CONFIG_DMASCC)
-	{dmascc_init, 0},
-#endif	
 #if defined(CONFIG_SCC_ENET)
         {scc_enet_init, 0},
 #endif
--- 1.15/drivers/net/hamradio/dmascc.c	Fri May 30 08:50:31 2003
+++ edited/drivers/net/hamradio/dmascc.c	Mon Jun  2 12:31:48 2003
@@ -250,8 +250,6 @@
 
 
 /* Function declarations */
-
-int dmascc_init(void) __init;
 static int setup_adapter(int card_base, int type, int n) __init;
 
 static void write_scc(struct scc_priv *priv, int reg, int val);
@@ -299,23 +297,12 @@
 static unsigned long rand;
 
 
-/* Module functions */
-
-#ifdef MODULE
-
-
 MODULE_AUTHOR("Klaus Kudielka");
 MODULE_DESCRIPTION("Driver for high-speed SCC boards");
 MODULE_PARM(io, "1-" __MODULE_STRING(MAX_NUM_DEVS) "i");
 MODULE_LICENSE("GPL");
 
-
-int init_module(void) {
-  return dmascc_init();
-}
-
-
-void cleanup_module(void) {
+static void __exit dmascc_exit(void) {
   int i;
   struct scc_info *info;
 
@@ -341,24 +328,16 @@
   }
 }
 
-
-#else
-
-
+#ifndef MODULE
 void __init dmascc_setup(char *str, int *ints) {
    int i;
 
    for (i = 0; i < MAX_NUM_DEVS && i < ints[0]; i++)
       io[i] = ints[i+1];
 }
-
-
 #endif
 
-
-/* Initialization functions */
-
-int __init dmascc_init(void) {
+static int __init dmascc_init(void) {
   int h, i, j, n;
   int base[MAX_NUM_DEVS], tcmd[MAX_NUM_DEVS], t0[MAX_NUM_DEVS],
     t1[MAX_NUM_DEVS];
@@ -461,6 +440,9 @@
   return -EIO;
 }
 
+module_init(dmascc_init);
+module_exit(dmascc_exit);
+
 
 int __init setup_adapter(int card_base, int type, int n) {
   int i, irq, chip;
@@ -580,6 +562,7 @@
     if (sizeof(dev->name) == sizeof(char *)) dev->name = priv->name;
 #endif
     sprintf(dev->name, "dmascc%i", 2*n+i);
+    SET_MODULE_OWNER(dev);
     dev->base_addr = card_base;
     dev->irq = irq;
     dev->open = scc_open;
@@ -707,12 +690,9 @@
   struct scc_info *info = priv->info;
   int card_base = priv->card_base;
 
-  MOD_INC_USE_COUNT;
-
   /* Request IRQ if not already used by other channel */
   if (!info->irq_used) {
     if (request_irq(dev->irq, scc_isr, 0, "dmascc", info)) {
-      MOD_DEC_USE_COUNT;
       return -EAGAIN;
     }
   }
@@ -722,7 +702,6 @@
   if (priv->param.dma >= 0) {
     if (request_dma(priv->param.dma, "dmascc")) {
       if (--info->irq_used == 0) free_irq(dev->irq, info);
-      MOD_DEC_USE_COUNT;
       return -EAGAIN;
     } else {
       unsigned long flags = claim_dma_lock();
@@ -866,7 +845,6 @@
   }
   if (--info->irq_used == 0) free_irq(dev->irq, info);
 
-  MOD_DEC_USE_COUNT;
   return 0;
 }
 
