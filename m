From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: 1.03Mpps on e1000 (was: Re: [E1000-devel] Transmission limit)
Date: Sun, 5 Dec 2004 16:42:34 +0100 (CET)
Message-ID: <Pine.LNX.4.58.0412051638290.29474@tux.rsn.bth.se>
References: <1101499285.1079.45.camel@jzny.localdomain>
 <16811.8052.678955.795327@robur.slu.se> <1101821501.1043.43.camel@jzny.localdomain>
 <20041130134600.GA31515@xi.wantstofly.org> <1101824754.1044.126.camel@jzny.localdomain>
 <20041201001107.GE4203@xi.wantstofly.org> <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net>
 <20041201182943.GA14470@xi.wantstofly.org> <20041201213550.GF14470@xi.wantstofly.org>
 <1101967983.4782.9.camel@localhost.localdomain> <20041205145051.GA647@xi.wantstofly.org>
 <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Scott Feldman <sfeldma@pobox.com>, jamal <hadi@cyberus.ca>,
        Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
        mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 5 Dec 2004, Martin Josefsson wrote:

[snip]
> BUT if I use the above + prefetching I get this:
>
> 60      1483890
[snip]
> This is on one port of a 82546GB
>
> The hardware is a dual Athlon MP 2000+ in an Asus A7M266-D motherboard and
> the nic is located in a 64/66 slot.
>
> I won't post any patch until I've tested some more and cleaned up a few
> things.
>
> BTW, I also get some transmit timouts with Scotts patch sometimes, not
> often but it does happen.

Here's the patch, not much more tested (it still gives some transmit
timeouts since it's scotts patch + prefetching and delayed TDT updating).
And it's not cleaned up, but hey, that's development :)

The delayed TDT updating was a test and currently it delays the first tx'd
packet after a timerrun 1ms.

Would be interesting to see what other people get with this thing.
Lennert?

diff -X /home/gandalf/dontdiff.ny -urNp linux-2.6.10-rc3.orig/drivers/net/e1000/e1000.h linux-2.6.10-rc3.labbrouter/drivers/net/e1000/e1000.h
--- linux-2.6.10-rc3.orig/drivers/net/e1000/e1000.h	2004-12-04 18:16:53.000000000 +0100
+++ linux-2.6.10-rc3.labbrouter/drivers/net/e1000/e1000.h	2004-12-05 15:12:25.000000000 +0100
@@ -101,7 +101,7 @@ struct e1000_adapter;
 #define E1000_MAX_INTR 10

 /* TX/RX descriptor defines */
-#define E1000_DEFAULT_TXD                  256
+#define E1000_DEFAULT_TXD                 4096
 #define E1000_MAX_TXD                      256
 #define E1000_MIN_TXD                       80
 #define E1000_MAX_82544_TXD               4096
@@ -187,6 +187,7 @@ struct e1000_desc_ring {
 /* board specific private data structure */

 struct e1000_adapter {
+	struct timer_list tx_cleanup_timer;
 	struct timer_list tx_fifo_stall_timer;
 	struct timer_list watchdog_timer;
 	struct timer_list phy_info_timer;
@@ -222,6 +223,7 @@ struct e1000_adapter {
 	uint32_t tx_fifo_size;
 	atomic_t tx_fifo_stall;
 	boolean_t pcix_82544;
+	boolean_t tx_cleanup_scheduled;

 	/* RX */
 	struct e1000_desc_ring rx_ring;
diff -X /home/gandalf/dontdiff.ny -urNp linux-2.6.10-rc3.orig/drivers/net/e1000/e1000_hw.h linux-2.6.10-rc3.labbrouter/drivers/net/e1000/e1000_hw.h
--- linux-2.6.10-rc3.orig/drivers/net/e1000/e1000_hw.h	2004-12-04 18:16:53.000000000 +0100
+++ linux-2.6.10-rc3.labbrouter/drivers/net/e1000/e1000_hw.h	2004-12-05 15:37:50.000000000 +0100
@@ -417,14 +417,12 @@ int32_t e1000_set_d3_lplu_state(struct e
 /* This defines the bits that are set in the Interrupt Mask
  * Set/Read Register.  Each bit is documented below:
  *   o RXT0   = Receiver Timer Interrupt (ring 0)
- *   o TXDW   = Transmit Descriptor Written Back
  *   o RXDMT0 = Receive Descriptor Minimum Threshold hit (ring 0)
  *   o RXSEQ  = Receive Sequence Error
  *   o LSC    = Link Status Change
  */
 #define IMS_ENABLE_MASK ( \
     E1000_IMS_RXT0   |    \
-    E1000_IMS_TXDW   |    \
     E1000_IMS_RXDMT0 |    \
     E1000_IMS_RXSEQ  |    \
     E1000_IMS_LSC)
diff -X /home/gandalf/dontdiff.ny -urNp linux-2.6.10-rc3.orig/drivers/net/e1000/e1000_main.c linux-2.6.10-rc3.labbrouter/drivers/net/e1000/e1000_main.c
--- linux-2.6.10-rc3.orig/drivers/net/e1000/e1000_main.c	2004-12-05 14:59:19.000000000 +0100
+++ linux-2.6.10-rc3.labbrouter/drivers/net/e1000/e1000_main.c	2004-12-05 15:40:11.000000000 +0100
@@ -131,7 +131,7 @@ static int e1000_set_mac(struct net_devi
 static void e1000_irq_disable(struct e1000_adapter *adapter);
 static void e1000_irq_enable(struct e1000_adapter *adapter);
 static irqreturn_t e1000_intr(int irq, void *data, struct pt_regs *regs);
-static boolean_t e1000_clean_tx_irq(struct e1000_adapter *adapter);
+static void e1000_clean_tx(unsigned long data);
 #ifdef CONFIG_E1000_NAPI
 static int e1000_clean(struct net_device *netdev, int *budget);
 static boolean_t e1000_clean_rx_irq(struct e1000_adapter *adapter,
@@ -286,6 +286,7 @@ e1000_down(struct e1000_adapter *adapter

 	e1000_irq_disable(adapter);
 	free_irq(adapter->pdev->irq, netdev);
+	del_timer_sync(&adapter->tx_cleanup_timer);
 	del_timer_sync(&adapter->tx_fifo_stall_timer);
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_info_timer);
@@ -522,6 +523,10 @@ e1000_probe(struct pci_dev *pdev,

 	e1000_get_bus_info(&adapter->hw);

+	init_timer(&adapter->tx_cleanup_timer);
+	adapter->tx_cleanup_timer.function = &e1000_clean_tx;
+	adapter->tx_cleanup_timer.data = (unsigned long) adapter;
+
 	init_timer(&adapter->tx_fifo_stall_timer);
 	adapter->tx_fifo_stall_timer.function = &e1000_82547_tx_fifo_stall;
 	adapter->tx_fifo_stall_timer.data = (unsigned long) adapter;
@@ -882,19 +887,16 @@ e1000_configure_tx(struct e1000_adapter
 	e1000_config_collision_dist(&adapter->hw);

 	/* Setup Transmit Descriptor Settings for eop descriptor */
-	adapter->txd_cmd = E1000_TXD_CMD_IDE | E1000_TXD_CMD_EOP |
+	adapter->txd_cmd = E1000_TXD_CMD_EOP |
 		E1000_TXD_CMD_IFCS;

-	if(adapter->hw.mac_type < e1000_82543)
-		adapter->txd_cmd |= E1000_TXD_CMD_RPS;
-	else
-		adapter->txd_cmd |= E1000_TXD_CMD_RS;
-
 	/* Cache if we're 82544 running in PCI-X because we'll
 	 * need this to apply a workaround later in the send path. */
 	if(adapter->hw.mac_type == e1000_82544 &&
 	   adapter->hw.bus_type == e1000_bus_type_pcix)
 		adapter->pcix_82544 = 1;
+
+	E1000_WRITE_REG(&adapter->hw, TXDMAC, 0);
 }

 /**
@@ -1707,7 +1709,7 @@ e1000_tx_queue(struct e1000_adapter *ada
 	wmb();

 	tx_ring->next_to_use = i;
-	E1000_WRITE_REG(&adapter->hw, TDT, i);
+	/* E1000_WRITE_REG(&adapter->hw, TDT, i); */
 }

 /**
@@ -1809,6 +1811,11 @@ e1000_xmit_frame(struct sk_buff *skb, st
  		return NETDEV_TX_LOCKED;
  	}

+	if(!adapter->tx_cleanup_scheduled) {
+		adapter->tx_cleanup_scheduled = TRUE;
+		mod_timer(&adapter->tx_cleanup_timer, jiffies + 1);
+	}
+
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
 	if(E1000_DESC_UNUSED(&adapter->tx_ring) < count + 2) {
@@ -1845,6 +1852,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	netdev->trans_start = jiffies;

 	spin_unlock_irqrestore(&adapter->tx_lock, flags);
+
 	return NETDEV_TX_OK;
 }

@@ -2140,8 +2148,7 @@ e1000_intr(int irq, void *data, struct p
 	}
 #else
 	for(i = 0; i < E1000_MAX_INTR; i++)
-		if(unlikely(!e1000_clean_rx_irq(adapter) &
-		   !e1000_clean_tx_irq(adapter)))
+		if(unlikely(!e1000_clean_rx_irq(adapter)))
 			break;
 #endif

@@ -2159,18 +2166,15 @@ e1000_clean(struct net_device *netdev, i
 {
 	struct e1000_adapter *adapter = netdev->priv;
 	int work_to_do = min(*budget, netdev->quota);
-	int tx_cleaned;
 	int work_done = 0;

-	tx_cleaned = e1000_clean_tx_irq(adapter);
 	e1000_clean_rx_irq(adapter, &work_done, work_to_do);

 	*budget -= work_done;
 	netdev->quota -= work_done;

-	/* if no Rx and Tx cleanup work was done, exit the polling mode */
-	if(!tx_cleaned || (work_done < work_to_do) ||
-				!netif_running(netdev)) {
+	/* if no Rx cleanup work was done, exit the polling mode */
+	if((work_done < work_to_do) || !netif_running(netdev)) {
 		netif_rx_complete(netdev);
 		e1000_irq_enable(adapter);
 		return 0;
@@ -2181,66 +2185,76 @@ e1000_clean(struct net_device *netdev, i

 #endif
 /**
- * e1000_clean_tx_irq - Reclaim resources after transmit completes
- * @adapter: board private structure
+ * e1000_clean_tx - Reclaim resources after transmit completes
+ * @data: timer callback data (board private structure)
  **/

-static boolean_t
-e1000_clean_tx_irq(struct e1000_adapter *adapter)
+static void
+e1000_clean_tx(unsigned long data)
 {
+	struct e1000_adapter *adapter = (struct e1000_adapter *)data;
 	struct e1000_desc_ring *tx_ring = &adapter->tx_ring;
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
-	struct e1000_tx_desc *tx_desc, *eop_desc;
 	struct e1000_buffer *buffer_info;
-	unsigned int i, eop;
-	boolean_t cleaned = FALSE;
+	unsigned int i, next;
+	int size = 0, count = 0;
+	uint32_t tx_head;

-	i = tx_ring->next_to_clean;
-	eop = tx_ring->buffer_info[i].next_to_watch;
-	eop_desc = E1000_TX_DESC(*tx_ring, eop);
+	spin_lock(&adapter->tx_lock);

-	while(eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) {
-		for(cleaned = FALSE; !cleaned; ) {
-			tx_desc = E1000_TX_DESC(*tx_ring, i);
-			buffer_info = &tx_ring->buffer_info[i];
+	E1000_WRITE_REG(&adapter->hw, TDT, tx_ring->next_to_use);

-			if(likely(buffer_info->dma)) {
-				pci_unmap_page(pdev,
-					       buffer_info->dma,
-					       buffer_info->length,
-					       PCI_DMA_TODEVICE);
-				buffer_info->dma = 0;
-			}
+	tx_head = E1000_READ_REG(&adapter->hw, TDH);

-			if(buffer_info->skb) {
-				dev_kfree_skb_any(buffer_info->skb);
-				buffer_info->skb = NULL;
-			}
+	i = next = tx_ring->next_to_clean;

-			tx_desc->buffer_addr = 0;
-			tx_desc->lower.data = 0;
-			tx_desc->upper.data = 0;
+	while(i != tx_head) {
+		size++;
+		if(i == tx_ring->buffer_info[next].next_to_watch) {
+			count += size;
+			size = 0;
+			if(unlikely(++i == tx_ring->count))
+				i = 0;
+			next = i;
+		} else {
+			if(unlikely(++i == tx_ring->count))
+				i = 0;
+		}
+	}

-			cleaned = (i == eop);
-			if(unlikely(++i == tx_ring->count)) i = 0;
+	i = tx_ring->next_to_clean;
+	while(count--) {
+		buffer_info = &tx_ring->buffer_info[i];
+
+		if(likely(buffer_info->dma)) {
+			pci_unmap_page(pdev,
+				       buffer_info->dma,
+				       buffer_info->length,
+				       PCI_DMA_TODEVICE);
+			buffer_info->dma = 0;
 		}
-
-		eop = tx_ring->buffer_info[i].next_to_watch;
-		eop_desc = E1000_TX_DESC(*tx_ring, eop);
+
+		if(buffer_info->skb) {
+			dev_kfree_skb_any(buffer_info->skb);
+			buffer_info->skb = NULL;
+		}
+
+		if(unlikely(++i == tx_ring->count))
+			i = 0;
 	}

 	tx_ring->next_to_clean = i;

-	spin_lock(&adapter->tx_lock);
+	if(E1000_DESC_UNUSED(tx_ring) != tx_ring->count)
+		mod_timer(&adapter->tx_cleanup_timer, jiffies + 1);
+	else
+		adapter->tx_cleanup_scheduled = FALSE;

-	if(unlikely(cleaned && netif_queue_stopped(netdev) &&
-		    netif_carrier_ok(netdev)))
+	if(unlikely(netif_queue_stopped(netdev) && netif_carrier_ok(netdev)))
 		netif_wake_queue(netdev);

 	spin_unlock(&adapter->tx_lock);
-
-	return cleaned;
 }

 /**

/Martin
