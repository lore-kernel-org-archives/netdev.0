From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.6 7/10] e1000: Checks for desc ring/rx data bufs spanning 64k boundary
Date: Tue, 15 Feb 2005 13:30:52 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0502151116580.30336-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

7 Add checks for desc ring/rx data bufs spanning 64k address boundary
Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/e1000/e1000_main.c net-drivers-2.6/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.6/drivers/net/e1000/e1000_main.c	2005-02-01 23:10:24.989105880 -0800
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_main.c	2005-02-01 23:10:26.709844288 -0800
@@ -820,6 +820,31 @@ e1000_close(struct net_device *netdev)
 }
 
 /**
+ * e1000_check_64k_bound - check that memory doesn't cross 64kB boundary
+ * @adapter: address of board private structure
+ * @begin: address of beginning of memory
+ * @end: address of end of memory
+ **/
+static inline boolean_t
+e1000_check_64k_bound(struct e1000_adapter *adapter,
+		      void *start, unsigned long len)
+{
+	unsigned long begin = (unsigned long) start;
+	unsigned long end = begin + len;
+
+	/* first rev 82545 and 82546 need to not allow any memory
+	 * write location to cross a 64k boundary due to errata 23 */
+	if (adapter->hw.mac_type == e1000_82545 ||
+	    adapter->hw.mac_type == e1000_82546 ) {
+
+		/* check buffer doesn't cross 64kB */
+		return ((begin ^ (end - 1)) >> 16) != 0 ? FALSE : TRUE;
+	}
+
+	return TRUE;
+}
+
+/**
  * e1000_setup_tx_resources - allocate Tx resources (Descriptors)
  * @adapter: board private structure
  *
@@ -849,11 +873,42 @@ e1000_setup_tx_resources(struct e1000_ad
 
 	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
 	if(!txdr->desc) {
+setup_tx_desc_die:
 		DPRINTK(PROBE, ERR, 
 		"Unble to Allocate Memory for the Transmit descriptor ring\n");
 		vfree(txdr->buffer_info);
 		return -ENOMEM;
 	}
+
+	/* fix for errata 23, cant cross 64kB boundary */
+	if (!e1000_check_64k_bound(adapter, txdr->desc, txdr->size)) {
+		void *olddesc = txdr->desc;
+		dma_addr_t olddma = txdr->dma;
+		DPRINTK(TX_ERR,ERR,"txdr align check failed: %u bytes at %p\n",
+		        txdr->size, txdr->desc);
+		/* try again, without freeing the previous */
+		txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
+		/* failed allocation, critial failure */
+		if(!txdr->desc) {
+			pci_free_consistent(pdev, txdr->size, olddesc, olddma);
+			goto setup_tx_desc_die;
+		}
+
+		if (!e1000_check_64k_bound(adapter, txdr->desc, txdr->size)) {
+			/* give up */
+			pci_free_consistent(pdev, txdr->size,
+			     txdr->desc, txdr->dma);
+			pci_free_consistent(pdev, txdr->size, olddesc, olddma);
+			DPRINTK(PROBE, ERR,
+			 "Unable to Allocate aligned Memory for the Transmit"
+		         " descriptor ring\n");
+			vfree(txdr->buffer_info);
+			return -ENOMEM;
+		} else {
+			/* free old, move on with the new one since its okay */
+			pci_free_consistent(pdev, txdr->size, olddesc, olddma);
+		}
+	}
 	memset(txdr->desc, 0, txdr->size);
 
 	txdr->next_to_use = 0;
@@ -971,11 +1027,43 @@ e1000_setup_rx_resources(struct e1000_ad
 	rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
 
 	if(!rxdr->desc) {
+setup_rx_desc_die:
 		DPRINTK(PROBE, ERR, 
 		"Unble to Allocate Memory for the Recieve descriptor ring\n");
 		vfree(rxdr->buffer_info);
 		return -ENOMEM;
 	}
+
+	/* fix for errata 23, cant cross 64kB boundary */
+	if (!e1000_check_64k_bound(adapter, rxdr->desc, rxdr->size)) {
+		void *olddesc = rxdr->desc;
+		dma_addr_t olddma = rxdr->dma;
+		DPRINTK(RX_ERR,ERR,
+			"rxdr align check failed: %u bytes at %p\n",
+			rxdr->size, rxdr->desc);
+		/* try again, without freeing the previous */
+		rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
+		/* failed allocation, critial failure */
+		if(!rxdr->desc) {
+			pci_free_consistent(pdev, rxdr->size, olddesc, olddma);
+			goto setup_rx_desc_die;
+		}
+
+		if (!e1000_check_64k_bound(adapter, rxdr->desc, rxdr->size)) {
+			/* give up */
+			pci_free_consistent(pdev, rxdr->size,
+			     rxdr->desc, rxdr->dma);
+			pci_free_consistent(pdev, rxdr->size, olddesc, olddma);
+			DPRINTK(PROBE, ERR, 
+				"Unable to Allocate aligned Memory for the"
+				" Receive descriptor ring\n");
+			vfree(rxdr->buffer_info);
+			return -ENOMEM;
+		} else {
+			/* free old, move on with the new one since its okay */
+			pci_free_consistent(pdev, rxdr->size, olddesc, olddma);
+		}
+	}
 	memset(rxdr->desc, 0, rxdr->size);
 
 	rxdr->next_to_clean = 0;
@@ -2469,19 +2557,43 @@ e1000_alloc_rx_buffers(struct e1000_adap
 	struct e1000_rx_desc *rx_desc;
 	struct e1000_buffer *buffer_info;
 	struct sk_buff *skb;
-	unsigned int i;
+	unsigned int i, bufsz;
 
 	i = rx_ring->next_to_use;
 	buffer_info = &rx_ring->buffer_info[i];
 
 	while(!buffer_info->skb) {
-		skb = dev_alloc_skb(adapter->rx_buffer_len + NET_IP_ALIGN);
+		bufsz = adapter->rx_buffer_len + NET_IP_ALIGN;
 
+		skb = dev_alloc_skb(bufsz);
 		if(unlikely(!skb)) {
 			/* Better luck next round */
 			break;
 		}
 
+		/* fix for errata 23, cant cross 64kB boundary */
+		if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
+			struct sk_buff *oldskb = skb;
+			DPRINTK(RX_ERR,ERR,
+				"skb align check failed: %u bytes at %p\n",
+				bufsz, skb->data);
+			/* try again, without freeing the previous */
+			skb = dev_alloc_skb(bufsz);
+			if (!skb) {
+				dev_kfree_skb(oldskb);
+				break;
+			}
+			if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
+				/* give up */
+				dev_kfree_skb(skb);
+				dev_kfree_skb(oldskb);
+				break; /* while !buffer_info->skb */
+			} else {
+				/* move on with the new one */
+				dev_kfree_skb(oldskb);
+			}
+		}
+
 		/* Make buffer alignment 2 beyond a 16 byte boundary
 		 * this will result in a 16 byte aligned IP header after
 		 * the 14 byte MAC header is removed
@@ -2497,6 +2609,25 @@ e1000_alloc_rx_buffers(struct e1000_adap
 						  adapter->rx_buffer_len,
 						  PCI_DMA_FROMDEVICE);
 
+		/* fix for errata 23, cant cross 64kB boundary */
+		if(!e1000_check_64k_bound(adapter,
+			                       (void *)(unsigned long)buffer_info->dma,
+			                       adapter->rx_buffer_len)) {
+			DPRINTK(RX_ERR,ERR,
+				"dma align check failed: %u bytes at %ld\n",
+				adapter->rx_buffer_len, (unsigned long)buffer_info->dma);
+
+			dev_kfree_skb(skb);
+			buffer_info->skb = NULL;
+
+			pci_unmap_single(pdev,
+					 buffer_info->dma,
+					 adapter->rx_buffer_len,
+					 PCI_DMA_FROMDEVICE);
+
+			break; /* while !buffer_info->skb */
+		}
+
 		rx_desc = E1000_RX_DESC(*rx_ring, i);
 		rx_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
 
	
