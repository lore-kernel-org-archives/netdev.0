From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: [E1000-devel] Transmission limit
Date: Tue, 30 Nov 2004 17:09:59 -0800
Message-ID: <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	 <41A73826.3000109@draigBrady.com> <16807.20052.569125.686158@robur.slu.se>
	 <1101484740.24742.213.camel@mellia.lipar.polito.it>
	 <41A76085.7000105@draigBrady.com>
	 <1101499285.1079.45.camel@jzny.localdomain>
	 <16811.8052.678955.795327@robur.slu.se>
	 <1101821501.1043.43.camel@jzny.localdomain>
	 <20041130134600.GA31515@xi.wantstofly.org>
	 <1101824754.1044.126.camel@jzny.localdomain>
	 <20041201001107.GE4203@xi.wantstofly.org>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Robert Olsson <Robert.Olsson@data.slu.se>,
        P@draigBrady.com, mellia@prezzemolo.polito.it,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041201001107.GE4203@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hey, turns out, I know some e1000 tricks that might help get the kpps
numbers up.  

My problem is I only have a P4 desktop system with a 82544 nic running
at PCI 32/33Mhz, so I can't play with the big boys.  But, attached is a
rework of the Tx path to eliminate 1) Tx interrupts, and 2) Tx
descriptor write-backs.  For me, I see a nice jump in kpps, but I'd like
others to try with their setups.  We should be able to get to wire speed
with 60-byte packets.

I'm using pktgen in linux-2.6.9, count = 1000000.

System: Intel 865 (HT 2.6Ghz)
Nic: 82544 PCI 32-bit/33Mhz
Driver: linux-2.6.9 e1000 (5.3.19-k2-NAPI), no Interrupt Delays
                                                                                BEFORE

256 descs
  pkt_size = 60:   253432pps 129Mb/sec errors: 0
  pkt_size = 1500: 56356pps  678Mb/sec errors: 499791
4096 descs
  pkt_size = 60:   254222pps 130Mb/sec errors: 0
  pkt_size = 1500: 52693pps  634Mb/sec errors: 497556
                                                                                
AFTER

Modified driver to turn off Tx interrupts and descriptor write-backs.
Uses a timer to schedule Tx cleanup.  The timer runs at 1ms.  This would
work poorly where HZ=100.  Needed to bump Tx descriptors up to 4096
because 1ms is a lot of time with 60-byte packets at 1GbE.  Every time
the timer expires, there is only one PIO read to get HW head pointer. 
This wouldn't work at lower media speeds like 10Mbps or 100Mbps because
the ring isn't large enough (or we would need a higher resolution
timer).  This also get Tx cleanup out of the NAPI path.

4096 descs
  pkt_size = 60:   541618pps 277Mb/sec errors: 914
  pkt_size = 1500: 76198pps  916Mb/sec errors: 12419
                                                                               
This doubles the kpps numbers for 60-byte packets.  I'd like to see what
happens on higher bus bandwidth systems.  Anyone?

-scott

diff -Naurp linux-2.6.9/drivers/net/e1000/e1000.h linux-2.6.9/drivers/net/e1000.mod/e1000.h
--- linux-2.6.9/drivers/net/e1000/e1000.h	2004-10-18 14:53:06.000000000 -0700
+++ linux-2.6.9/drivers/net/e1000.mod/e1000.h	2004-11-30 14:41:07.045391488 -0800
@@ -103,7 +103,7 @@ struct e1000_adapter;
 #define E1000_MAX_INTR 10
 
 /* TX/RX descriptor defines */
-#define E1000_DEFAULT_TXD                  256
+#define E1000_DEFAULT_TXD                 4096
 #define E1000_MAX_TXD                      256
 #define E1000_MIN_TXD                       80
 #define E1000_MAX_82544_TXD               4096
@@ -189,6 +189,7 @@ struct e1000_desc_ring {
 /* board specific private data structure */
 
 struct e1000_adapter {
+	struct timer_list tx_cleanup_timer;
 	struct timer_list tx_fifo_stall_timer;
 	struct timer_list watchdog_timer;
 	struct timer_list phy_info_timer;
@@ -224,6 +225,7 @@ struct e1000_adapter {
 	uint32_t tx_fifo_size;
 	atomic_t tx_fifo_stall;
 	boolean_t pcix_82544;
+	boolean_t tx_cleanup_scheduled;
 
 	/* RX */
 	struct e1000_desc_ring rx_ring;
diff -Naurp linux-2.6.9/drivers/net/e1000/e1000_hw.h linux-2.6.9/drivers/net/e1000.mod/e1000_hw.h
--- linux-2.6.9/drivers/net/e1000/e1000_hw.h	2004-10-18 14:55:06.000000000 -0700
+++ linux-2.6.9/drivers/net/e1000.mod/e1000_hw.h	2004-11-30 13:48:07.983682328 -0800
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
diff -Naurp linux-2.6.9/drivers/net/e1000/e1000_main.c linux-2.6.9/drivers/net/e1000.mod/e1000_main.c
--- linux-2.6.9/drivers/net/e1000/e1000_main.c	2004-10-18 14:53:50.000000000 -0700
+++ linux-2.6.9/drivers/net/e1000.mod/e1000_main.c	2004-11-30 16:15:13.777957656 -0800
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
@@ -533,6 +534,10 @@ e1000_probe(struct pci_dev *pdev,
 
 	e1000_get_bus_info(&adapter->hw);
 
+	init_timer(&adapter->tx_cleanup_timer);
+	adapter->tx_cleanup_timer.function = &e1000_clean_tx;
+	adapter->tx_cleanup_timer.data = (unsigned long) adapter;
+
 	init_timer(&adapter->tx_fifo_stall_timer);
 	adapter->tx_fifo_stall_timer.function = &e1000_82547_tx_fifo_stall;
 	adapter->tx_fifo_stall_timer.data = (unsigned long) adapter;
@@ -893,14 +898,9 @@ e1000_configure_tx(struct e1000_adapter 
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
@@ -1820,6 +1820,11 @@ e1000_xmit_frame(struct sk_buff *skb, st
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
@@ -1856,6 +1861,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	netdev->trans_start = jiffies;
 
 	spin_unlock_irqrestore(&adapter->tx_lock, flags);
+
 	return NETDEV_TX_OK;
 }
 
@@ -2151,8 +2157,7 @@ e1000_intr(int irq, void *data, struct p
 	}
 #else
 	for(i = 0; i < E1000_MAX_INTR; i++)
-		if(unlikely(!e1000_clean_rx_irq(adapter) &
-		   !e1000_clean_tx_irq(adapter)))
+		if(unlikely(!e1000_clean_rx_irq(adapter)))
 			break;
 #endif
 
@@ -2170,18 +2175,15 @@ e1000_clean(struct net_device *netdev, i
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
@@ -2192,66 +2194,74 @@ e1000_clean(struct net_device *netdev, i
 
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
+	tx_head = E1000_READ_REG(&adapter->hw, TDH);
 
-			if(likely(buffer_info->dma)) {
-				pci_unmap_page(pdev,
-					       buffer_info->dma,
-					       buffer_info->length,
-					       PCI_DMA_TODEVICE);
-				buffer_info->dma = 0;
-			}
+	i = next = tx_ring->next_to_clean;
 
-			if(buffer_info->skb) {
-				dev_kfree_skb_any(buffer_info->skb);
-				buffer_info->skb = NULL;
-			}
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
 
-			tx_desc->buffer_addr = 0;
-			tx_desc->lower.data = 0;
-			tx_desc->upper.data = 0;
+	i = tx_ring->next_to_clean;
+	while(count--) {
+		buffer_info = &tx_ring->buffer_info[i];
 
-			cleaned = (i == eop);
-			if(unlikely(++i == tx_ring->count)) i = 0;
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
