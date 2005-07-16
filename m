From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH] forcedeth: jumbo frame support
Date: Sat, 16 Jul 2005 20:14:45 +0200
Message-ID: <42D94E95.1060303@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020905030206060006040904"
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020905030206060006040904
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

Attached is the missing 0.36 patch that adds jumbo frame support for the 
nForce versions that support it.
The performance difference is quite huge:
- MTU 1500: 57 MB/sec, around 85% cpu load
- MTU 7200: 92 MB/sec, around 37% cpu load

Signed-Off-By: Manfred Spraul <manfred@colorfullife.com>

--------------020905030206060006040904
Content-Type: text/plain;
 name="patch-forcedeth-036-jumbo"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-036-jumbo"

--- 2.6/drivers/net/forcedeth.c	2005-06-28 22:51:26.000000000 +0200
+++ build-2.6/drivers/net/forcedeth.c	2005-06-28 22:51:40.000000000 +0200
@@ -85,6 +85,7 @@
  *	0.33: 16 May 2005: Support for MCP51 added.
  *	0.34: 18 Jun 2005: Add DEV_NEED_LINKTIMER to all nForce nics.
  *	0.35: 26 Jun 2005: Support for MCP55 added.
+ *	0.36: 28 Jul 2005: Add jumbo frame support.
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -96,7 +97,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.35"
+#define FORCEDETH_VERSION		"0.36"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -379,9 +380,13 @@
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
@@ -473,6 +478,7 @@
 	struct sk_buff *rx_skbuff[RX_RING];
 	dma_addr_t rx_dma[RX_RING];
 	unsigned int rx_buf_sz;
+	unsigned int pkt_limit;
 	struct timer_list oom_kick;
 	struct timer_list nic_poll;
 
@@ -792,7 +798,7 @@
 		nr = refill_rx % RX_RING;
 		if (np->rx_skbuff[nr] == NULL) {
 
-			skb = dev_alloc_skb(RX_ALLOC_BUFSIZE);
+			skb = dev_alloc_skb(np->rx_buf_sz + NV_RX_ALLOC_PAD);
 			if (!skb)
 				break;
 
@@ -805,7 +811,7 @@
 						PCI_DMA_FROMDEVICE);
 		np->rx_ring[nr].PacketBuffer = cpu_to_le32(np->rx_dma[nr]);
 		wmb();
-		np->rx_ring[nr].FlagLen = cpu_to_le32(RX_NIC_BUFSIZE | NV_RX_AVAIL);
+		np->rx_ring[nr].FlagLen = cpu_to_le32(np->rx_buf_sz | NV_RX_AVAIL);
 		dprintk(KERN_DEBUG "%s: nv_alloc_rx: Packet %d marked as Available\n",
 					dev->name, refill_rx);
 		refill_rx++;
@@ -831,19 +837,31 @@
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
 
@@ -1207,15 +1225,82 @@
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
 
@@ -1792,6 +1877,7 @@
 	writel(0, base + NvRegAdapterControl);
 
 	/* 2) initialize descriptor rings */
+	set_bufsize(dev);
 	oom = nv_init_ring(dev);
 
 	writel(0, base + NvRegLinkSpeed);
@@ -1837,7 +1923,7 @@
 	writel(NVREG_MISC1_FORCE | NVREG_MISC1_HD, base + NvRegMisc1);
 	writel(readl(base + NvRegTransmitterStatus), base + NvRegTransmitterStatus);
 	writel(NVREG_PFF_ALWAYS, base + NvRegPacketFilterFlags);
-	writel(NVREG_OFFLOAD_NORMAL, base + NvRegOffloadConfig);
+	writel(np->rx_buf_sz, base + NvRegOffloadConfig);
 
 	writel(readl(base + NvRegReceiverStatus), base + NvRegReceiverStatus);
 	get_random_bytes(&i, sizeof(i));
@@ -2007,13 +2093,16 @@
 
 	/* handle different descriptor versions */
 	if (pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_1 ||
-		pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_2 ||
-		pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_3 ||    
-		pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_12 ||
-		pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_13)
+			pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_2 ||
+			pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_3 ||    
+			pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_12 ||
+			pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_13) {
 		np->desc_ver = DESC_VER_1;
-	else
+ 		np->pkt_limit = NV_PKTLIMIT_1;
+	} else {
 		np->desc_ver = DESC_VER_2;
+ 		np->pkt_limit = NV_PKTLIMIT_1;
+	}
 
 	err = -ENOMEM;
 	np->base = ioremap(addr, NV_PCI_REGSZ);

--------------020905030206060006040904--
