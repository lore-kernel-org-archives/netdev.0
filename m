From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.4.25] pcnet32.c adds loopback test
Date: Fri, 20 Feb 2004 17:06:14 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402210106.i1L16FR07593@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This adds the ability to do a local loopback test for the adapter.  This
source was submitted by James Lewis <jklewis@us.ibm.com>.  Tested on IA32.

--- linux-2.4.25/drivers/net/pci.pcnet32.c	Fri Feb 20 16:56:52 2004
+++ linux-2.4.25/drivers/net/pcnet32.c	Fri Feb 20 17:03:20 2004
@@ -126,6 +126,11 @@
     PCNET32_PORT_ASEL			   /* 15 not supported	  */
 };
 
+static const char pcnet32_gstrings_test[][ETH_GSTRING_LEN] = {
+    "Loopback test  (offline)"
+};
+#define PCNET32_TEST_LEN (sizeof(pcnet32_gstrings_test) / ETH_GSTRING_LEN)
+
 #define MAX_UNITS 8	/* More are supported, limit only on options */
 static int options[MAX_UNITS];
 static int full_duplex[MAX_UNITS];
@@ -348,6 +353,10 @@
 static int  pcnet32_ioctl(struct net_device *, struct ifreq *, int);
 static int mdio_read(struct net_device *dev, int phy_id, int reg_num);
 static void mdio_write(struct net_device *dev, int phy_id, int reg_num, int val);
+static void pcnet32_restart(struct net_device *dev, unsigned int csr0_bits);
+static void pcnet32_ethtool_test(struct net_device *dev,
+	struct ethtool_test *eth_test, u64 *data);
+static int pcnet32_loopback_test(struct net_device *dev, uint64_t *data1);
 
 enum pci_flags_bit {
     PCI_USES_IO=1, PCI_USES_MEM=2, PCI_USES_MASTER=4,
@@ -558,17 +567,175 @@
 	ering->rx_pending = lp->cur_rx & RX_RING_MOD_MASK;
 }
 
+static void pcnet32_get_strings(struct net_device *dev, u32 stringset, u8 *data)
+{
+    memcpy(data, pcnet32_gstrings_test, sizeof(pcnet32_gstrings_test));
+}
+
+static int pcnet32_self_test_count(struct net_device *dev)
+{
+    return PCNET32_TEST_LEN;
+}
+
+static void pcnet32_ethtool_test(struct net_device *dev,
+	struct ethtool_test *test, u64 *data)
+{
+    struct pcnet32_private *lp = dev->priv;
+    int rc;
+
+    if (test->flags == ETH_TEST_FL_OFFLINE) {
+	rc = pcnet32_loopback_test(dev, data);
+	if (rc) {
+	    if (netif_msg_hw(lp))
+		printk(KERN_DEBUG "%s: Loopback test failed.\n", dev->name);
+	    test->flags |= ETH_TEST_FL_FAILED;
+	} else if (netif_msg_hw(lp))
+	    printk(KERN_DEBUG "%s: Loopback test passed.\n", dev->name);
+    } else
+	printk(KERN_DEBUG "%s: No tests to run (specify 'Offline' on ethtool).",	    dev->name);
+} /* end pcnet32_ethtool_test */
+
+static int pcnet32_loopback_test(struct net_device *dev, uint64_t *data1)
+{
+    struct pcnet32_private *lp = dev->priv;
+    struct pcnet32_access *a = &lp->a;	/* access to registers */
+    ulong ioaddr = dev->base_addr;	/* card base I/O address */
+    struct sk_buff *skb;		/* sk buff */
+    int x, y, i;			/* counters */
+    int numbuffs = 4;			/* number of TX/RX buffers and descs */
+    u16 status = 0x8300;		/* TX ring status */
+    int rc;				/* return code */
+    int size;				/* size of packets */
+    unsigned char *packet;		/* source packet data */
+    static int data_len = 60;		/* length of source packets */
+    unsigned long flags;
+
+    *data1 = 1;			/* status of test, default to fail */
+    rc = 1;			/* default to fail */
+
+    spin_lock_irqsave(&lp->lock, flags);
+    lp->a.write_csr(ioaddr, 0, 0x7904);
+
+    netif_stop_queue(dev);
+
+    /* purge & init rings but don't actually restart */
+    pcnet32_restart(dev, 0x0000);
+
+    lp->a.write_csr(ioaddr, 0, 0x0004);	/* Set STOP bit */
+
+    x = a->read_bcr(ioaddr, 32);	/* set internal loopback in BSR32 */
+    x = x | 0x00000002;
+    a->write_bcr(ioaddr, 32, x);
+
+    /* Initialize Transmit buffers. */
+    size = data_len + 15;
+    for (x=0; x<numbuffs; x++) {
+	if (!(skb = dev_alloc_skb(size))) {
+	    if (netif_msg_hw(lp))
+		printk(KERN_DEBUG "%s: Cannot allocate skb at line: %d!\n",
+		    dev->name, __LINE__);
+	    goto clean_up;
+	} else {
+	    packet = skb->data;
+	    skb_put(skb, size);		/* create space for data */
+	    lp->tx_skbuff[x] = skb;
+	    lp->tx_ring[x].length = le16_to_cpu(-skb->len);
+	    lp->tx_ring[x].misc = 0x00000000;
+
+	    /* put DA and SA into the skb */
+	    for (i=0; i<12; i++)
+		*packet++ = 0xff;
+	    /* type */
+	    *packet++ = 0x08;
+	    *packet++ = 0x06;
+	    /* packet number */
+	    *packet++ = x;
+	    /* fill packet with data */
+	    for (y=0; y<data_len; y++)
+		*packet++ = y;
+
+	    lp->tx_dma_addr[x] = pci_map_single(lp->pci_dev, skb->data,
+		    skb->len, PCI_DMA_TODEVICE);
+	    lp->tx_ring[x].base = (u32)le32_to_cpu(lp->tx_dma_addr[x]);
+	    wmb(); /* Make sure owner changes after all others are visible */
+	    lp->tx_ring[x].status = le16_to_cpu(status);
+	}
+    }
+
+    lp->a.write_csr(ioaddr, 0, 0x0002);	/* Set STRT bit */
+    spin_unlock_irqrestore(&lp->lock, flags);
+
+    mdelay(50);				/* wait a bit */
+
+    spin_lock_irqsave(&lp->lock, flags);
+    lp->a.write_csr(ioaddr, 0, 0x0004);	/* Set STOP bit */
+
+    if (netif_msg_hw(lp) && netif_msg_pktdata(lp)) {
+	printk(KERN_DEBUG "%s: RX loopback packets:\n", dev->name);
+
+	for (x=0; x<numbuffs; x++) {
+	    printk(KERN_DEBUG "%s: Packet %d:\n", dev->name, x);
+	    skb=lp->rx_skbuff[x];
+	    for (i=0; i<size; i++) {
+		printk("%02x ", *(skb->data+i));
+	    }
+	    printk("\n");
+	}
+    }
+
+    x = 0;
+    rc = 0;
+    while (x<numbuffs && !rc) {
+	skb = lp->rx_skbuff[x];
+	packet = lp->tx_skbuff[x]->data;
+	for (i=0; i<size; i++) {
+	    if (*(skb->data+i) != packet[i]) {
+		if (netif_msg_hw(lp))
+		    printk(KERN_DEBUG "%s: Error in compare! %2x - %02x %02x\n",
+			    dev->name, i, *(skb->data+i), packet[i]);
+		rc = 1;
+		break;
+	    }
+	}
+	x++;
+    }
+    if (!rc) {
+	*data1 = 0;
+    }
+
+clean_up:
+    x = a->read_csr(ioaddr, 15) & 0xFFFF;
+    a->write_csr(ioaddr, 15, (x & ~0x0044));	/* reset bits 6 and 2 */
+
+    x = a->read_bcr(ioaddr, 32);		/* reset internal loopback */
+    x = x & ~0x00000002;
+    a->write_bcr(ioaddr, 32, x);
+
+    pcnet32_restart(dev, 0x0042);		/* resume normal operation */
+
+    netif_wake_queue(dev);
+
+    /* Clear interrupts, and set interrupt enable. */
+    lp->a.write_csr(ioaddr, 0, 0x7940);
+    spin_unlock_irqrestore(&lp->lock, flags);
+
+    return(rc);
+} /* end pcnet32_loopback_test  */
+
 static struct ethtool_ops pcnet32_ethtool_ops = {
-	.get_settings		= pcnet32_get_settings,
-	.set_settings		= pcnet32_set_settings,
-	.get_drvinfo		= pcnet32_get_drvinfo,
-	.get_msglevel		= pcnet32_get_msglevel,
-	.set_msglevel		= pcnet32_set_msglevel,
-	.nway_reset		= pcnet32_nway_reset,
-	.get_link		= pcnet32_get_link,
-	.get_ringparam		= pcnet32_get_ringparam,
-	.get_tx_csum		= ethtool_op_get_tx_csum,
-	.get_sg			= ethtool_op_get_sg,
+    .get_settings	= pcnet32_get_settings,
+    .set_settings	= pcnet32_set_settings,
+    .get_drvinfo	= pcnet32_get_drvinfo,
+    .get_msglevel	= pcnet32_get_msglevel,
+    .set_msglevel	= pcnet32_set_msglevel,
+    .nway_reset		= pcnet32_nway_reset,
+    .get_link		= pcnet32_get_link,
+    .get_ringparam	= pcnet32_get_ringparam,
+    .get_tx_csum	= ethtool_op_get_tx_csum,
+    .get_sg		= ethtool_op_get_sg,
+    .get_strings	= pcnet32_get_strings,
+    .self_test_count	= pcnet32_self_test_count,
+    .self_test		= pcnet32_ethtool_test,
 };
 
 /* only probes for non-PCI devices, the rest are handled by 

-- 
Don Fry
brazilnut@us.ibm.com
