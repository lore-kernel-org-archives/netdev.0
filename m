From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH] jumbo frame support for forcedeth, wol updates
Date: Wed, 28 Jul 2004 22:24:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41080B83.7060707@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030408080100030105050308"
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030408080100030105050308
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

the attached patch adds jumbo frame support for the gigabit ethernet 
nForce nic.
I've also found a critical bug that might affect all nForce nics: there 
is a race in nv_close, it seems the rx ring entries are kfreed while the 
nic is still active. At least ifdown with wol enabled is affected. I've 
tried to fix it, but the fix might have broken wol.

Please test it - it works on my nForce-250Gb board.

--
    Manfred

--------------030408080100030105050308
Content-Type: text/plain;
 name="patch-forcedeth-jumbo"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-jumbo"

// $Header$
// Kernel Version:
//  VERSION = 2
//  PATCHLEVEL = 6
//  SUBLEVEL = 8
//  EXTRAVERSION =-rc1-mm1
--- 2.6/drivers/net/forcedeth.c	2004-07-19 22:00:27.000000000 +0200
+++ build-2.6/drivers/net/forcedeth.c	2004-07-28 21:37:51.684357344 +0200
@@ -75,6 +75,8 @@
  *			   added CK804/MCP04 device IDs, code fixes
  *			   for registers, link status and other minor fixes.
  *	0.28: 21 Jun 2004: Big cleanup, making driver mostly endian safe
+ *	0.29: 28 Jul 2004: Add jumbo frame support. Add reset into nv_close,
+ *			   previous code clobbered kfree'd memory.
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -86,7 +88,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.28"
+#define FORCEDETH_VERSION		"0.29"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -361,9 +363,13 @@ struct ring_desc {
 #define TX_LIMIT_START	62
 
 /* rx/tx mac addr + type + vlan + align + slack*/
-#define RX_NIC_BUFSIZE		(ETH_DATA_LEN + 64)
-/* even more slack */
-#define RX_ALLOC_BUFSIZE	(ETH_DATA_LEN + 128)
+#define NV_RX_HEADERS		(64)
+/* even more slack. */
+#define NV_RX_ALLOC_PAD		(64)
+
+/* maximum mtu size */
+#define NV_PKTLIMIT_1	ETH_DATA_LEN	/* hard limit not known */
+#define NV_PKTLIMIT_2	9100	/* Actual limit according to NVidia: 9202 */
 
 #define OOM_REFILL	(1+HZ/20)
 #define POLL_WAIT	(1+HZ/100)
@@ -443,6 +449,7 @@ struct fe_priv {
 	struct sk_buff *rx_skbuff[RX_RING];
 	dma_addr_t rx_dma[RX_RING];
 	unsigned int rx_buf_sz;
+	unsigned int pkt_limit;
 	struct timer_list oom_kick;
 	struct timer_list nic_poll;
 
@@ -842,7 +849,7 @@ static int nv_alloc_rx(struct net_device
 		nr = refill_rx % RX_RING;
 		if (np->rx_skbuff[nr] == NULL) {
 
-			skb = dev_alloc_skb(RX_ALLOC_BUFSIZE);
+			skb = dev_alloc_skb(np->rx_buf_sz + NV_RX_ALLOC_PAD);
 			if (!skb)
 				break;
 
@@ -855,7 +862,7 @@ static int nv_alloc_rx(struct net_device
 						PCI_DMA_FROMDEVICE);
 		np->rx_ring[nr].PacketBuffer = cpu_to_le32(np->rx_dma[nr]);
 		wmb();
-		np->rx_ring[nr].FlagLen = cpu_to_le32(RX_NIC_BUFSIZE | NV_RX_AVAIL);
+		np->rx_ring[nr].FlagLen = cpu_to_le32(np->rx_buf_sz | NV_RX_AVAIL);
 		dprintk(KERN_DEBUG "%s: nv_alloc_rx: Packet %d marked as Available\n",
 					dev->name, refill_rx);
 		refill_rx++;
@@ -881,19 +888,31 @@ static void nv_do_rx_refill(unsigned lon
 	enable_irq(dev->irq);
 }
 
-static int nv_init_ring(struct net_device *dev)
+static void nv_init_rx(struct net_device *dev) 
 {
 	struct fe_priv *np = get_nvpriv(dev);
 	int i;
 
-	np->next_tx = np->nic_tx = 0;
-	for (i = 0; i < TX_RING; i++)
-		np->tx_ring[i].FlagLen = 0;
-
 	np->cur_rx = RX_RING;
 	np->refill_rx = 0;
 	for (i = 0; i < RX_RING; i++)
 		np->rx_ring[i].FlagLen = 0;
+}
+
+static void nv_init_tx(struct net_device *dev)
+{
+	struct fe_priv *np = get_nvpriv(dev);
+	int i;
+
+	np->next_tx = np->nic_tx = 0;
+	for (i = 0; i < TX_RING; i++)
+		np->tx_ring[i].FlagLen = 0;
+}
+
+static int nv_init_ring(struct net_device *dev)
+{
+	nv_init_tx(dev);
+	nv_init_rx(dev);
 	return nv_alloc_rx(dev);
 }
 
@@ -1191,15 +1210,82 @@ next_pkt:
 	}
 }
 
+static void set_bufsize(struct net_device *dev)
+{
+	struct fe_priv *np = netdev_priv(dev);
+
+	if (dev->mtu <= ETH_DATA_LEN)
+		np->rx_buf_sz = ETH_DATA_LEN + NV_RX_HEADERS;
+	else
+		np->rx_buf_sz = dev->mtu + NV_RX_HEADERS;
+}
+
 /*
  * nv_change_mtu: dev->change_mtu function
  * Called with dev_base_lock held for read.
  */
 static int nv_change_mtu(struct net_device *dev, int new_mtu)
 {
-	if (new_mtu > ETH_DATA_LEN)
+	struct fe_priv *np = get_nvpriv(dev);
+	int old_mtu;
+
+	if (new_mtu < 64 || new_mtu > np->pkt_limit)
 		return -EINVAL;
+
+	old_mtu = dev->mtu;
 	dev->mtu = new_mtu;
+
+	/* return early if the buffer sizes will not change */
+	if (old_mtu <= ETH_DATA_LEN && new_mtu <= ETH_DATA_LEN)
+		return 0;
+	if (old_mtu == new_mtu)
+		return 0;
+
+	/* synchronized against open : rtnl_lock() held by caller */
+	if (netif_running(dev)) {
+		u8 *base = get_hwbase(dev);
+		/*
+		 * It seems that the nic preloads valid ring entries into an
+		 * internal buffer. The procedure for flushing everything is
+		 * guessed, there is probably a simpler approach.
+		 * Changing the MTU is a rare event, it shouldn't matter.
+		 */
+		disable_irq(dev->irq);
+		spin_lock_bh(&dev->xmit_lock);
+		spin_lock(&np->lock);
+		/* stop engines */
+		nv_stop_rx(dev);
+		nv_stop_tx(dev);
+		nv_txrx_reset(dev);
+		/* drain rx queue */
+		nv_drain_rx(dev);
+		nv_drain_tx(dev);
+		/* reinit driver view of the rx queue */
+		nv_init_rx(dev);
+		nv_init_tx(dev);
+		/* alloc new rx buffers */
+		set_bufsize(dev);
+		if (nv_alloc_rx(dev)) {
+			if (!np->in_shutdown)
+				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
+		}
+		/* reinit nic view of the rx queue */
+		writel(np->rx_buf_sz, base + NvRegOffloadConfig);
+		writel((u32) np->ring_addr, base + NvRegRxRingPhysAddr);
+		writel((u32) (np->ring_addr + RX_RING*sizeof(struct ring_desc)), base + NvRegTxRingPhysAddr);
+		writel( ((RX_RING-1) << NVREG_RINGSZ_RXSHIFT) + ((TX_RING-1) << NVREG_RINGSZ_TXSHIFT),
+			base + NvRegRingSizes);
+		pci_push(base);
+		writel(NVREG_TXRXCTL_KICK|np->desc_ver, get_hwbase(dev) + NvRegTxRxControl);
+		pci_push(base);
+
+		/* restart rx engine */
+		nv_start_rx(dev);
+		nv_start_tx(dev);
+		spin_unlock(&np->lock);
+		spin_unlock_bh(&dev->xmit_lock);
+		enable_irq(dev->irq);
+	}
 	return 0;
 }
 
@@ -1519,6 +1605,7 @@ static int nv_open(struct net_device *de
 	writel(0, base + NvRegAdapterControl);
 
 	/* 2) initialize descriptor rings */
+	set_bufsize(dev);
 	oom = nv_init_ring(dev);
 
 	writel(0, base + NvRegLinkSpeed);
@@ -1567,7 +1654,7 @@ static int nv_open(struct net_device *de
 	writel(NVREG_MISC1_FORCE | NVREG_MISC1_HD, base + NvRegMisc1);
 	writel(readl(base + NvRegTransmitterStatus), base + NvRegTransmitterStatus);
 	writel(NVREG_PFF_ALWAYS, base + NvRegPacketFilterFlags);
-	writel(NVREG_OFFLOAD_NORMAL, base + NvRegOffloadConfig);
+	writel(np->rx_buf_sz, base + NvRegOffloadConfig);
 
 	writel(readl(base + NvRegReceiverStatus), base + NvRegReceiverStatus);
 	get_random_bytes(&i, sizeof(i));
@@ -1655,9 +1742,10 @@ static int nv_close(struct net_device *d
 	spin_lock_irq(&np->lock);
 	nv_stop_tx(dev);
 	nv_stop_rx(dev);
-	base = get_hwbase(dev);
+	nv_txrx_reset(dev);
 
 	/* disable interrupts on the nic or we will lock up */
+	base = get_hwbase(dev);
 	writel(0, base + NvRegIrqMask);
 	pci_push(base);
 	dprintk(KERN_INFO "%s: Irqmask is zero again\n", dev->name);
@@ -1736,11 +1824,14 @@ static int __devinit nv_probe(struct pci
 
 	/* handle different descriptor versions */
 	if (pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_1 ||
-		pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_2 ||
-		pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_3)
+			pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_2 ||
+			pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_3) {
 		np->desc_ver = DESC_VER_1;
-	else
+		np->pkt_limit = NV_PKTLIMIT_1;
+	} else {
 		np->desc_ver = DESC_VER_2;
+		np->pkt_limit = NV_PKTLIMIT_2;
+	}
 
 	err = -ENOMEM;
 	dev->base_addr = (unsigned long) ioremap(addr, NV_PCI_REGSZ);

--------------030408080100030105050308--
