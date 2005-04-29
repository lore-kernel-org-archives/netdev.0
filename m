From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.6 9/11] ixgb: Code optimization
Date: Thu, 28 Apr 2005 19:04:54 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281900040.28003-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Code optimization

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2005-04-05 23:06:36.332229456 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2005-04-05 23:06:38.283932752 -0700
@@ -1822,7 +1822,6 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 	struct pci_dev *pdev = adapter->pdev;
 	struct ixgb_rx_desc *rx_desc, *next_rxd;
 	struct ixgb_buffer *buffer_info, *next_buffer, *next2_buffer;
-	struct sk_buff *skb, *next_skb;
 	uint32_t length;
 	unsigned int i, j;
 	boolean_t cleaned = FALSE;
@@ -1832,6 +1831,8 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 	buffer_info = &rx_ring->buffer_info[i];
 
 	while(rx_desc->status & IXGB_RX_DESC_STATUS_DD) {
+		struct sk_buff *skb, *next_skb;
+		u8 status;
 
 #ifdef CONFIG_IXGB_NAPI
 		if(*work_done >= work_to_do)
@@ -1839,7 +1840,9 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 
 		(*work_done)++;
 #endif
+		status = rx_desc->status;
 		skb = buffer_info->skb;
+
 		prefetch(skb->data);
 
 		if(++i == rx_ring->count) i = 0;
@@ -1864,7 +1835,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 
 		length = le16_to_cpu(rx_desc->length);
 
-		if(unlikely(!(rx_desc->status & IXGB_RX_DESC_STATUS_EOP))) {
+		if(unlikely(!(status & IXGB_RX_DESC_STATUS_EOP))) {
 
 			/* All receives must fit into a single buffer */
 
@@ -1872,12 +1835,7 @@ 
 					 "length<%x>\n", length);
 
 			dev_kfree_skb_irq(skb);
-			rx_desc->status = 0;
-			buffer_info->skb = NULL;
-
-			rx_desc = next_rxd;
-			buffer_info = next_buffer;
-			continue;
+			goto rxdesc_done;
 		}
 
 		if (unlikely(rx_desc->errors
@@ -1886,12 +1835,7 @@ 
 				IXGB_RX_DESC_ERRORS_RXE))) {
 
 			dev_kfree_skb_irq(skb);
-			rx_desc->status = 0;
-			buffer_info->skb = NULL;
-
-			rx_desc = next_rxd;
-			buffer_info = next_buffer;
-			continue;
+			goto rxdesc_done;
 		}
 
 		/* Good Receive */
@@ -1902,7 +1879,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 
 		skb->protocol = eth_type_trans(skb, netdev);
 #ifdef CONFIG_IXGB_NAPI
-		if(adapter->vlgrp && (rx_desc->status & IXGB_RX_DESC_STATUS_VP)) {
+		if(adapter->vlgrp && (status & IXGB_RX_DESC_STATUS_VP)) {
 			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
 				le16_to_cpu(rx_desc->special) &
 					IXGB_RX_DESC_SPECIAL_VLAN_MASK);
@@ -1910,7 +1879,7 @@ 
 			netif_receive_skb(skb);
 		}
 #else /* CONFIG_IXGB_NAPI */
-		if(adapter->vlgrp && (rx_desc->status & IXGB_RX_DESC_STATUS_VP)) {
+		if(adapter->vlgrp && (status & IXGB_RX_DESC_STATUS_VP)) {
 			vlan_hwaccel_rx(skb, adapter->vlgrp,
 				le16_to_cpu(rx_desc->special) &
 					IXGB_RX_DESC_SPECIAL_VLAN_MASK);
@@ -1920,9 +1913,12 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 #endif /* CONFIG_IXGB_NAPI */
 		netdev->last_rx = jiffies;
 
+rxdesc_done:
+		/* clean up descriptor, might be written over by hw */
 		rx_desc->status = 0;
 		buffer_info->skb = NULL;
 
+		/* use prefetched values */
 		rx_desc = next_rxd;
 		buffer_info = next_buffer;
 	}
