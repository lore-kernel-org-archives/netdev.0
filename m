From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.4 6/16] e1000: Delay clean-up of last
 Tx packet
Date: Thu, 28 Apr 2005 20:12:30 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504282001030.30085-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Delay clean-up of last Tx packet to fix pre-mature writeback issue of Tx descriptors only when TSO is enabled

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.4/drivers/net/e1000/e1000_main.c net-drivers-2.4/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.4/drivers/net/e1000/e1000_main.c	2005-04-12 23:00:53.000000000 -0700
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_main.c	2005-04-12 23:00:55.000000000 -0700
@@ -2341,11 +2341,10 @@ e1000_clean_tx_irq(struct e1000_adapter 
 	eop_desc = E1000_TX_DESC(*tx_ring, eop);
 
 	while(eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) {
-		/* pre-mature writeback of Tx descriptors     */
-		/* clear (free buffers and unmap pci_mapping) */
-		/* previous_buffer_info                       */
+		/* Premature writeback of Tx descriptors clear (free buffers
+		 * and unmap pci_mapping) previous_buffer_info */
 		if (likely(adapter->previous_buffer_info.skb != NULL)) {
-			e1000_unmap_and_free_tx_resource(adapter, 
+			e1000_unmap_and_free_tx_resource(adapter,
 					&adapter->previous_buffer_info);
 		}
 
@@ -2354,20 +2725,25 @@ e1000_clean_tx_irq(struct e1000_adapter 
 			buffer_info = &tx_ring->buffer_info[i];
 			cleaned = (i == eop);
 
-			/* pre-mature writeback of Tx descriptors */
-			/* save the cleaning of the this for the  */
-			/* next iteration                         */
-			if (cleaned) {
-				memcpy(&adapter->previous_buffer_info,
-					buffer_info,
-					sizeof(struct e1000_buffer));
-				memset(buffer_info,
-					0,
-					sizeof(struct e1000_buffer));
+#ifdef NETIF_F_TSO
+			if (!(netdev->features & NETIF_F_TSO)) {
+#endif
+				e1000_unmap_and_free_tx_resource(adapter,
+				                                 buffer_info);
+#ifdef NETIF_F_TSO
 			} else {
-				e1000_unmap_and_free_tx_resource(adapter, 
-							buffer_info);
+				if (cleaned) {
+					memcpy(&adapter->previous_buffer_info,
+					       buffer_info,
+					       sizeof(struct e1000_buffer));
+					memset(buffer_info, 0,
+					       sizeof(struct e1000_buffer));
+				} else {
+					e1000_unmap_and_free_tx_resource(
+					    adapter, buffer_info);
+				}
 			}
+#endif
 
 			tx_desc->buffer_addr = 0;
 			tx_desc->lower.data = 0;
@@ -2400,7 +2760,14 @@ e1000_clean_tx_irq(struct e1000_adapter 
 		   !(E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_TXOFF))
 			netif_stop_queue(netdev);
 	}
+#ifdef NETIF_F_TSO
+
+	if( unlikely(!(eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) &&
+	    time_after(jiffies, adapter->previous_buffer_info.time_stamp + HZ)))
+		e1000_unmap_and_free_tx_resource(
+		    adapter, &adapter->previous_buffer_info);
 
+#endif
 	return cleaned;
 }
 
