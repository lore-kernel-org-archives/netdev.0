From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.6.5 4/4] pcnet32 add led blink capability
Date: Mon, 5 Apr 2004 14:29:11 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404052129.i35LTBY11014@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please apply this patch to 2.6.5 to include the capability of blinking
the LED's for device identification.  Ethtool -p support.

--- linux-2.6.5/drivers/net/mac.pcnet32.c	Mon Apr  5 13:37:22 2004
+++ linux-2.6.5/drivers/net/pcnet32.c	Mon Apr  5 13:37:44 2004
@@ -102,6 +102,7 @@
 #define PCNET32_DMA_MASK 0xffffffff
 
 #define PCNET32_WATCHDOG_TIMEOUT (jiffies + (2 * HZ))
+#define PCNET32_BLINK_TIMEOUT	(jiffies + (HZ/4))
 
 /*
  * table to translate option values from tulip
@@ -232,6 +233,8 @@
  *	   length errors, and transmit hangs.  Cleans up after errors in open.
  *	   Jim Lewis <jklewis@us.ibm.com> added ethernet loopback test.
  *	   Thomas Munck Steenholdt <tmus@tmus.dk> non-mii ioctl corrections.
+ * v1.29   6 Apr 2004 Jim Lewis <jklewis@us.ibm.com> added physical
+ *	   identification code (blink led's).
  */
 
 
@@ -342,6 +345,7 @@
     struct net_device	*next;
     struct mii_if_info	mii_if;
     struct timer_list	watchdog_timer;
+    struct timer_list	blink_timer;
     u32			msg_enable;	/* debug message level */
 };
 
@@ -365,6 +369,8 @@
 static void pcnet32_ethtool_test(struct net_device *dev,
 	struct ethtool_test *eth_test, u64 *data);
 static int pcnet32_loopback_test(struct net_device *dev, uint64_t *data1);
+static int pcnet32_phys_id(struct net_device *dev, u32 data);
+static void pcnet32_led_blink_callback(struct net_device *dev);
 
 enum pci_flags_bit {
     PCI_USES_IO=1, PCI_USES_MEM=2, PCI_USES_MASTER=4,
@@ -746,6 +752,63 @@
     return(rc);
 } /* end pcnet32_loopback_test  */
 
+static void pcnet32_led_blink_callback(struct net_device *dev)
+{
+    struct pcnet32_private *lp = dev->priv;
+    struct pcnet32_access *a = &lp->a;
+    ulong ioaddr = dev->base_addr;
+    unsigned long flags;
+    int i;
+
+    spin_lock_irqsave(&lp->lock, flags);
+    for (i=4; i<8; i++) {
+	a->write_bcr(ioaddr, i, a->read_bcr(ioaddr, i) ^ 0x4000);
+    }
+    spin_unlock_irqrestore(&lp->lock, flags);
+
+    mod_timer(&lp->blink_timer, PCNET32_BLINK_TIMEOUT);
+}
+
+static int pcnet32_phys_id(struct net_device *dev, u32 data)
+{
+    struct pcnet32_private *lp = dev->priv;
+    struct pcnet32_access *a = &lp->a;
+    ulong ioaddr = dev->base_addr;
+    unsigned long flags;
+    int i, regs[4];
+
+    if (!lp->blink_timer.function) {
+	init_timer(&lp->blink_timer);
+	lp->blink_timer.function = (void *) pcnet32_led_blink_callback;
+	lp->blink_timer.data = (unsigned long) dev;
+    }
+
+    /* Save the current value of the bcrs */
+    spin_lock_irqsave(&lp->lock, flags);
+    for (i=4; i<8; i++) {
+	regs[i-4] = a->read_bcr(ioaddr, i);
+    }
+    spin_unlock_irqrestore(&lp->lock, flags);
+
+    mod_timer(&lp->blink_timer, jiffies);
+    set_current_state(TASK_INTERRUPTIBLE);
+
+    if ((!data) || (data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ)))
+    data = (u32)(MAX_SCHEDULE_TIMEOUT / HZ);
+
+    schedule_timeout(data * HZ);
+    del_timer_sync(&lp->blink_timer);
+
+    /* Restore the original value of the bcrs */
+    spin_lock_irqsave(&lp->lock, flags);
+    for (i=4; i<8; i++) {
+	a->write_bcr(ioaddr, i, regs[i-4]);
+    }
+    spin_unlock_irqrestore(&lp->lock, flags);
+
+    return 0;
+}
+
 static struct ethtool_ops pcnet32_ethtool_ops = {
     .get_settings	= pcnet32_get_settings,
     .set_settings	= pcnet32_set_settings,
@@ -761,6 +824,7 @@
     .get_strings	= pcnet32_get_strings,
     .self_test_count	= pcnet32_self_test_count,
     .self_test		= pcnet32_ethtool_test,
+    .phys_id		= pcnet32_phys_id,
 };
 
 /* only probes for non-PCI devices, the rest are handled by
@@ -1152,6 +1216,9 @@
     if (pcnet32_debug & NETIF_MSG_PROBE)
 	printk(KERN_INFO "%s: registered as %s\n", dev->name, lp->name);
     cards_found++;
+
+    a->write_bcr(ioaddr, 2, 0x1002);	/* enable LED writes */
+
     return 0;
 
 err_free_consistent:

-- 
Don Fry
brazilnut@us.ibm.com
