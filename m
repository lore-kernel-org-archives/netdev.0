From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.6 3/10] e1000: Avoid race between e1000_watchdog and e1000_clean_tx_irq
Date: Tue, 15 Feb 2005 13:25:48 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0502151112390.30336-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

3 Avoid race condition between e1000_watchdog and e1000_clean_tx_irq
Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/e1000/e1000.h net-drivers-2.6/drivers/net/e1000.new/e1000.h
--- net-drivers-2.6/drivers/net/e1000/e1000.h	2005-02-01 23:10:24.986106336 -0800
+++ net-drivers-2.6/drivers/net/e1000.new/e1000.h	2005-02-01 23:10:26.474880008 -0800
@@ -222,6 +222,7 @@ struct e1000_adapter {
 	uint32_t tx_fifo_size;
 	atomic_t tx_fifo_stall;
 	boolean_t pcix_82544;
+	boolean_t detect_tx_hung;
 
 	/* RX */
 	struct e1000_desc_ring rx_ring;
diff -up net-drivers-2.6/drivers/net/e1000/e1000_main.c net-drivers-2.6/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.6/drivers/net/e1000/e1000_main.c	2005-02-01 23:10:24.989105880 -0800
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_main.c	2005-02-01 23:10:26.709844288 -0800
@@ -1432,7 +1432,6 @@ e1000_watchdog(unsigned long data)
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_desc_ring *txdr = &adapter->tx_ring;
-	unsigned int i;
 	uint32_t link;
 
 	e1000_check_for_link(&adapter->hw);
@@ -1512,12 +1511,8 @@ e1000_watchdog(unsigned long data)
 	/* Cause software interrupt to ensure rx ring is cleaned */
 	E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_RXDMT0);
 
-	/* Early detection of hung controller */
-	i = txdr->next_to_clean;
-	if(txdr->buffer_info[i].dma &&
-	   time_after(jiffies, txdr->buffer_info[i].time_stamp + HZ) &&
-	   !(E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_TXOFF))
-		netif_stop_queue(netdev);
+	/* Force detection of hung controller every watchdog period*/
+	adapter->detect_tx_hung = TRUE;
 
 	/* Reset the timer */
 	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
@@ -2245,6 +2240,16 @@ e1000_clean_tx_irq(struct e1000_adapter 
 		netif_wake_queue(netdev);
 
 	spin_unlock(&adapter->tx_lock);
+ 
+	if(adapter->detect_tx_hung) {
+		/* detect a transmit hang in hardware, this serializes the
+		 * check with the clearing of time_stamp and movement of i */
+		adapter->detect_tx_hung = FALSE;
+		if(tx_ring->buffer_info[i].dma &&
+		   time_after(jiffies, tx_ring->buffer_info[i].time_stamp + HZ) &&
+		   !(E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_TXOFF))
+			netif_stop_queue(netdev);
+	}
 
 	return cleaned;
 }
	
