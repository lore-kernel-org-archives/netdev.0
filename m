From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.6 2/5] ixgb: Avoid race e1000_watchdog and
 ixgb_clean_tx_irq
Date: Tue, 15 Feb 2005 13:37:38 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0502151200480.30336-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

2 Avoid race between e1000_watchdog and ixgb_clean_tx_irq
Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb.h net-drivers-2.6/drivers/net/ixgb.new/ixgb.h
--- net-drivers-2.6/drivers/net/ixgb/ixgb.h	2005-02-06 23:33:00.651031496 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb.h	2005-02-06 23:33:01.521899104 -0800
@@ -176,6 +176,7 @@ struct ixgb_adapter {
 	uint64_t hw_csum_tx_error;
 	uint32_t tx_int_delay;
 	boolean_t tx_int_delay_enable;
+	boolean_t detect_tx_hung;
 
 	/* RX */
 	struct ixgb_desc_ring rx_ring;
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2005-02-06 23:33:00.652031344 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2005-02-06 23:33:01.617884512 -0800
@@ -1100,7 +1100,6 @@ ixgb_watchdog(unsigned long data)
 	struct ixgb_adapter *adapter = (struct ixgb_adapter *)data;
 	struct net_device *netdev = adapter->netdev;
 	struct ixgb_desc_ring *txdr = &adapter->tx_ring;
-	unsigned int i;
 
 	ixgb_check_for_link(&adapter->hw);
 
@@ -1143,12 +1140,8 @@ ixgb_watchdog(unsigned long data)
 		}
 	}
 
-	/* Early detection of hung controller */
-	i = txdr->next_to_clean;
-	if(txdr->buffer_info[i].dma &&
-	   time_after(jiffies, txdr->buffer_info[i].time_stamp + HZ) &&
-	   !(IXGB_READ_REG(&adapter->hw, STATUS) & IXGB_STATUS_TXOFF))
-		netif_stop_queue(netdev);
+	/* Force detection of hung controller every watchdog period */
+	adapter->detect_tx_hung = TRUE;
 
 	/* generate an interrupt to force clean up of any stragglers */
 	IXGB_WRITE_REG(&adapter->hw, ICS, IXGB_INT_TXDW);
@@ -1748,6 +1748,17 @@ ixgb_clean_tx_irq(struct ixgb_adapter *a
 	}
 	spin_unlock(&adapter->tx_lock);
 
+	if(adapter->detect_tx_hung) {
+		/* detect a transmit hang in hardware, this serializes the
+		 * check with the clearing of time_stamp and movement of i */
+		adapter->detect_tx_hung = FALSE;
+		if(tx_ring->buffer_info[i].dma &&
+		   time_after(jiffies, tx_ring->buffer_info[i].time_stamp + HZ)
+		   && !(IXGB_READ_REG(&adapter->hw, STATUS) &
+			IXGB_STATUS_TXOFF))
+			netif_stop_queue(netdev);
+	}
+
 	return cleaned;
 }
 
	
