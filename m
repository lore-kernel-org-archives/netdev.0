From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 7/8 2.4.26-bk1] pcnet32 add register dump capability
Date: Tue, 20 Apr 2004 13:18:01 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404202018.i3KKI2H13698@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please apply this patch to include the capability to dump chip registers.
Ethtool -d support.

--- linux-2.4.26-bk1/drivers/net/read.pcnet32.c	Tue Apr 20 12:48:18 2004
+++ linux-2.4.26-bk1/drivers/net/pcnet32.c	Tue Apr 20 12:54:21 2004
@@ -132,6 +132,8 @@
 };
 #define PCNET32_TEST_LEN (sizeof(pcnet32_gstrings_test) / ETH_GSTRING_LEN)
 
+#define PCNET32_NUM_REGS 146
+
 #define MAX_UNITS 8	/* More are supported, limit only on options */
 static int options[MAX_UNITS];
 static int full_duplex[MAX_UNITS];
@@ -234,7 +236,7 @@
  *	   Jim Lewis <jklewis@us.ibm.com> added ethernet loopback test.
  *	   Thomas Munck Steenholdt <tmus@tmus.dk> non-mii ioctl corrections.
  * v1.29   6 Apr 2004 Jim Lewis <jklewis@us.ibm.com> added physical
- *	   identification code (blink led's).
+ *	   identification code (blink led's) and register dump.
  */
 
 
@@ -372,6 +374,9 @@
 static int pcnet32_loopback_test(struct net_device *dev, uint64_t *data1);
 static int pcnet32_phys_id(struct net_device *dev, u32 data);
 static void pcnet32_led_blink_callback(struct net_device *dev);
+static int pcnet32_get_regs_len(struct net_device *dev);
+static void pcnet32_get_regs(struct net_device *dev, struct ethtool_regs *regs,
+	void *ptr);
 
 enum pci_flags_bit {
     PCI_USES_IO=1, PCI_USES_MEM=2, PCI_USES_MASTER=4,
@@ -837,6 +842,72 @@
     return 0;
 }
 
+int pcnet32_get_regs_len(struct net_device *dev)
+{
+    return(PCNET32_NUM_REGS * sizeof(u16));
+}
+
+void pcnet32_get_regs(struct net_device *dev, struct ethtool_regs *regs,
+	void *ptr)
+{
+    int i, csr0;
+    u16 *buff = ptr;
+    struct pcnet32_private *lp = dev->priv;
+    struct pcnet32_access *a = &lp->a;
+    ulong ioaddr = dev->base_addr;
+    int ticks;
+    unsigned long flags;
+
+    spin_lock_irqsave(&lp->lock, flags);
+
+    csr0 = a->read_csr(ioaddr, 0);
+    if (!(csr0 & 0x0004)) {	/* If not stopped */
+	/* set SUSPEND (SPND) - CSR5 bit 0 */
+	a->write_csr(ioaddr, 5, 0x0001);
+
+	/* poll waiting for bit to be set */
+	ticks = 0;
+	while (!(a->read_csr(ioaddr, 5) & 0x0001)) {
+	    spin_unlock_irqrestore(&lp->lock, flags);
+	    mdelay(1);
+	    spin_lock_irqsave(&lp->lock, flags);
+	    ticks++;
+	    if (ticks > 200) {
+		if (netif_msg_hw(lp))
+		    printk(KERN_DEBUG "%s: Error getting into suspend!\n",
+			    dev->name);
+		break;
+	    }
+	}
+    }
+
+    /* read address PROM */
+    for (i=0; i<16; i += 2)
+	*buff++ = inw(ioaddr + i);
+
+    for (i = 0; i <= 89; i++) {
+	*buff++ = a->read_csr(ioaddr, i);
+    }
+
+    *buff++ = a->read_csr(ioaddr, 112);
+    *buff++ = a->read_csr(ioaddr, 114);
+
+    for (i = 0; i <= 35; i++) {
+	*buff++ = a->read_bcr(ioaddr, i);
+    }
+
+    if (!(csr0 & 0x0004)) {	/* If not stopped */
+	/* clear SUSPEND (SPND) - CSR5 bit 0 */
+	a->write_csr(ioaddr, 5, 0x0000);
+    }
+
+    i = buff - (u16 *)ptr;
+    for (; i < PCNET32_NUM_REGS; i++)
+	*buff++ = 0;
+
+    spin_unlock_irqrestore(&lp->lock, flags);
+}
+
 static struct ethtool_ops pcnet32_ethtool_ops = {
     .get_settings	= pcnet32_get_settings,
     .set_settings	= pcnet32_set_settings,
@@ -852,6 +923,8 @@
     .self_test_count	= pcnet32_self_test_count,
     .self_test		= pcnet32_ethtool_test,
     .phys_id		= pcnet32_phys_id,
+    .get_regs_len	= pcnet32_get_regs_len,
+    .get_regs		= pcnet32_get_regs,
 };
 
 /* only probes for non-PCI devices, the rest are handled by

-- 
Don Fry
brazilnut@us.ibm.com
