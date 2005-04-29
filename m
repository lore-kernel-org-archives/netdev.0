From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.4 1/16] e1000: made loopback diags
 robust
Date: Thu, 28 Apr 2005 20:09:29 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281956440.30085-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Added enhanced functionality to the loopback diags to wrap the descriptor rings.

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.4/drivers/net/e1000/e1000_ethtool.c net-drivers-2.4/drivers/net/e1000.new/e1000_ethtool.c
--- net-drivers-2.4/drivers/net/e1000/e1000_ethtool.c	2005-04-12 23:00:53.000000000 -0700
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_ethtool.c	2005-04-12 23:00:55.000000000 -0700
@@ -919,7 +919,8 @@ e1000_setup_desc_rings(struct e1000_adap
 
 	/* Setup Tx descriptor ring and Tx buffers */
 
-	txdr->count = 80;
+	if(!txdr->count)
+		txdr->count = E1000_DEFAULT_TXD;   
 
 	size = txdr->count * sizeof(struct e1000_buffer);
 	if(!(txdr->buffer_info = kmalloc(size, GFP_KERNEL))) {
@@ -974,7 +975,8 @@ e1000_setup_desc_rings(struct e1000_adap
 
 	/* Setup Rx descriptor ring and Rx buffers */
 
-	rxdr->count = 80;
+	if(!rxdr->count)
+		rxdr->count = E1000_DEFAULT_RXD;   
 
 	size = rxdr->count * sizeof(struct e1000_buffer);
 	if(!(rxdr->buffer_info = kmalloc(size, GFP_KERNEL))) {
@@ -1309,31 +1311,62 @@ e1000_run_loopback_test(struct e1000_ada
 	struct e1000_desc_ring *txdr = &adapter->test_tx_ring;
 	struct e1000_desc_ring *rxdr = &adapter->test_rx_ring;
 	struct pci_dev *pdev = adapter->pdev;
-	int i, ret_val;
+	int i, j, k, l, lc, good_cnt, ret_val=0;
+	unsigned long time;
 
 	E1000_WRITE_REG(&adapter->hw, RDT, rxdr->count - 1);
 
-	for(i = 0; i < 64; i++) {
-		e1000_create_lbtest_frame(txdr->buffer_info[i].skb, 1024);
-		pci_dma_sync_single(pdev, txdr->buffer_info[i].dma,
-				    txdr->buffer_info[i].length,
-				    PCI_DMA_TODEVICE);
-	}
-	E1000_WRITE_REG(&adapter->hw, TDT, i);
-
-	msec_delay(200);
-
-	i = 0;
-	do {
-		pci_dma_sync_single(pdev, rxdr->buffer_info[i].dma,
-					    rxdr->buffer_info[i].length,
-					    PCI_DMA_FROMDEVICE);
-
-		ret_val = e1000_check_lbtest_frame(rxdr->buffer_info[i].skb,
-						   1024);
-		i++;
-	} while (ret_val != 0 && i < 64);
+	/* Calculate the loop count based on the largest descriptor ring 
+	 * The idea is to wrap the largest ring a number of times using 64
+	 * send/receive pairs during each loop
+	 */
+
+	if(rxdr->count <= txdr->count)
+		lc = ((txdr->count / 64) * 2) + 1;
+	else
+		lc = ((rxdr->count / 64) * 2) + 1;
 
+	k = l = 0;
+	for(j = 0; j <= lc; j++) { /* loop count loop */
+		for(i = 0; i < 64; i++) { /* send the packets */
+			e1000_create_lbtest_frame(txdr->buffer_info[i].skb, 
+					1024);
+			pci_dma_sync_single(pdev, 
+					txdr->buffer_info[k].dma,
+				    	txdr->buffer_info[k].length,
+				    	PCI_DMA_TODEVICE);
+			if(unlikely(++k == txdr->count)) k = 0;
+		}
+		E1000_WRITE_REG(&adapter->hw, TDT, k);
+		msec_delay(200);
+		time = jiffies; /* set the start time for the receive */
+		good_cnt = 0;
+		do { /* receive the sent packets */
+			pci_dma_sync_single(pdev, 
+					rxdr->buffer_info[l].dma,
+				    	rxdr->buffer_info[l].length,
+				    	PCI_DMA_FROMDEVICE);
+	
+			ret_val = e1000_check_lbtest_frame(
+					rxdr->buffer_info[l].skb,
+				   	1024);
+			if(!ret_val)
+				good_cnt++;
+			if(unlikely(++l == rxdr->count)) l = 0;
+			/* time + 20 msecs (200 msecs on 2.4) is more than 
+			 * enough time to complete the receives, if it's 
+			 * exceeded, break and error off
+			 */
+		} while (good_cnt < 64 && jiffies < (time + 20));
+		if(good_cnt != 64) {
+			ret_val = 13; /* ret_val is the same as mis-compare */
+			break; 
+		}
+		if(jiffies >= (time + 2)) {
+			ret_val = 14; /* error code for time out error */
+			break;
+		}
+	} /* end loop count loop */
 	return ret_val;
 }
 
@@ -1370,6 +1404,8 @@ e1000_link_test(struct e1000_adapter *ad
 		*data = 1; 
 	} else {
 		e1000_check_for_link(&adapter->hw);
+		if(adapter->hw.autoneg)  /* if auto_neg is set wait for it */
+			msec_delay(4000);
 
 		if(!(E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_LU)) {
 			*data = 1;
