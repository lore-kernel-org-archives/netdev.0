From: Vinay K Nallamothu <vinay-rc@naturesoft.net>
Subject: [PATCH 2.6.0-test3-bk8][ATM] fix ambassador.c
Date: 21 Aug 2003 20:45:05 +0530
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1061478906.1069.23.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Kernel List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: linux-atm-general@lists.sourceforge.net, netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

drivers/atm/ambassador.c: 
This patch cleans up sti/cli usage as well as minor timer cleanups.

ambassador.c |   34 ++++++++++++++--------------------
 1 files changed, 14 insertions(+), 20 deletions(-)


diff -urN linux-2.6.0-test3-bk8/drivers/atm/ambassador.c linux-2.6.0-test3-nvk/drivers/atm/ambassador.c
--- linux-2.6.0-test3-bk8/drivers/atm/ambassador.c	2003-08-21 20:21:53.000000000 +0530
+++ linux-2.6.0-test3-nvk/drivers/atm/ambassador.c	2003-08-21 20:04:04.000000000 +0530
@@ -310,10 +310,12 @@
   0xdeadbeef
 };
 
+static void do_housekeeping (unsigned long arg);
 /********** globals **********/
 
+
 static amb_dev * amb_devs = NULL;
-static struct timer_list housekeeping;
+static struct timer_list housekeeping = TIMER_INITIALIZER(do_housekeeping, 0, 1);
 
 static unsigned short debug = 0;
 static unsigned int cmds = 8;
@@ -952,8 +954,9 @@
   rx_in * rx;
   
   unsigned long flags;
-  save_flags (flags);
-  cli();
+  
+  txq = &dev->txq;
+  spin_lock_irqsave(&txq->lock, flags);
   
   PRINTK (KERN_INFO, "don't panic - putting adapter into reset");
   wr_plain (dev, offsetof(amb_mem, reset_control),
@@ -964,7 +967,7 @@
     cmd->request = cpu_to_be32 (SRB_COMPLETE);
 
   PRINTK (KERN_INFO, "completing all TXs");
-  txq = &dev->txq;
+
   tx = txq->in.ptr;
   while (txq->pending--) {
     if (tx == txq->in.start)
@@ -978,6 +981,7 @@
   PRINTK (KERN_INFO, "freeing all RX buffers");
   for (pool = 0; pool < NUM_RX_POOLS; ++pool) {
     rxq = &dev->rxq[pool];
+    spin_lock(&rxq->lock);
     rx = rxq->in.ptr;
     while (rxq->pending--) {
       if (rx == rxq->in.start)
@@ -985,11 +989,12 @@
       --rx;
       dev_kfree_skb_any (bus_to_virt (rx->handle));
     }
+    spin_unlock(&rxq->lock);
   }
   
   PRINTK (KERN_INFO, "don't panic over - close all VCs and rmmod");
   set_bit (dead, &dev->flags);
-  restore_flags (flags);
+  spin_unlock_irqrestore(&txq->lock, flags);
   return;
 }
 #endif
@@ -1671,13 +1676,6 @@
 };
 
 /********** housekeeping **********/
-
-static inline void set_timer (struct timer_list * timer, unsigned long delay) {
-  timer->expires = jiffies + delay;
-  add_timer (timer);
-  return;
-}
-
 static void do_housekeeping (unsigned long arg) {
   amb_dev * dev = amb_devs;
   // data is set to zero at module unload
@@ -1693,7 +1691,7 @@
       
       dev = dev->prev;
     }
-    set_timer (&housekeeping, 10*HZ);
+    mod_timer(&housekeeping, jiffies + 10*HZ);
   }
   
   return;
@@ -2559,7 +2557,7 @@
 
 /********** module entry **********/
 
-static int __init amb_module_init (void) {
+static int __devinit amb_module_init (void) {
   int devs;
   
   PRINTD (DBG_FLOW|DBG_INIT, "init_module");
@@ -2579,11 +2577,7 @@
   devs = amb_probe();
   
   if (devs) {
-    init_timer (&housekeeping);
-    housekeeping.function = do_housekeeping;
-    // paranoia
-    housekeeping.data = 1;
-    set_timer (&housekeeping, 0);
+    mod_timer (&housekeeping, jiffies);
   } else {
     PRINTK (KERN_INFO, "no (usable) adapters found");
   }
@@ -2593,7 +2587,7 @@
 
 /********** module exit **********/
 
-static void __exit amb_module_exit (void) {
+static void __devexit amb_module_exit (void) {
   amb_dev * dev;
   
   PRINTD (DBG_FLOW|DBG_INIT, "cleanup_module");
