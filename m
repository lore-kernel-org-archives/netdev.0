From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.4 3/13] e1000: Fix ethtool diagnostics -- specifically for
 blade server implementations
Date: Thu, 6 Jan 2005 17:07:11 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061501320.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>

diff -up net-drivers-2.4/drivers/net/e1000/e1000_ethtool.c net-drivers-2.4/drivers/net/e1000.new/e1000_ethtool.c
--- net-drivers-2.4/drivers/net/e1000/e1000_ethtool.c	2004-12-06 08:43:11.617384656 -0800
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_ethtool.c	2004-12-06 08:43:12.382268376 -0800
@@ -776,7 +776,7 @@ static int
 e1000_intr_test(struct e1000_adapter *adapter, uint64_t *data)
 {
 	struct net_device *netdev = adapter->netdev;
- 	uint32_t icr, mask, i=0, shared_int = TRUE;
+ 	uint32_t mask, i=0, shared_int = TRUE;
  	uint32_t irq = adapter->pdev->irq;
 
 	*data = 0;
@@ -784,7 +784,8 @@ e1000_intr_test(struct e1000_adapter *ad
 	/* Hook up test interrupt handler just for this test */
  	if(!request_irq(irq, &e1000_test_intr, 0, netdev->name, netdev)) {
  		shared_int = FALSE;
- 	} else if(request_irq(irq, &e1000_test_intr, SA_SHIRQ, netdev->name, netdev)){
+ 	} else if(request_irq(irq, &e1000_test_intr, SA_SHIRQ, 
+			netdev->name, netdev)){
 		*data = 1;
 		return -1;
 	}
@@ -793,21 +794,6 @@ e1000_intr_test(struct e1000_adapter *ad
 	E1000_WRITE_REG(&adapter->hw, IMC, 0xFFFFFFFF);
 	msec_delay(10);
 
-	/* Interrupts are disabled, so read interrupt cause
-	 * register (icr) twice to verify that there are no interrupts
-	 * pending.  icr is clear on read.
-	 */
-	icr = E1000_READ_REG(&adapter->hw, ICR);
-	icr = E1000_READ_REG(&adapter->hw, ICR);
-
-	if(icr != 0) {
-		/* if icr is non-zero, there is no point
-		 * running other interrupt tests.
-		 */
-		*data = 2;
-		i = 10;
-	}
-
 	/* Test each interrupt */
 	for(; i < 10; i++) {
 
@@ -856,8 +842,10 @@ e1000_intr_test(struct e1000_adapter *ad
 			 * test failed.
 			 */
 			adapter->test_icr = 0;
-			E1000_WRITE_REG(&adapter->hw, IMC, ~mask);
-			E1000_WRITE_REG(&adapter->hw, ICS, ~mask);
+			E1000_WRITE_REG(&adapter->hw, IMC, 
+					(~mask & 0x00007FFF));
+			E1000_WRITE_REG(&adapter->hw, ICS, 
+					(~mask & 0x00007FFF));
 			msec_delay(10);
 
 			if(adapter->test_icr) {
@@ -1335,10 +1333,17 @@ e1000_run_loopback_test(struct e1000_ada
 
 	msec_delay(200);
 
-	pci_dma_sync_single(pdev, rxdr->buffer_info[0].dma,
-			    rxdr->buffer_info[0].length, PCI_DMA_FROMDEVICE);
+	i = 0;
+	do {
+		pci_dma_sync_single(pdev, rxdr->buffer_info[i].dma,
+					    rxdr->buffer_info[i].length,
+					    PCI_DMA_FROMDEVICE);
+
+		if (!e1000_check_lbtest_frame(rxdr->buffer_info[i++].skb, 1024))
+			return 0;
+	} while (i < 64);
 
-	return e1000_check_lbtest_frame(rxdr->buffer_info[0].skb, 1024);
+	return 13;
 }
 
 static int
@@ -1357,10 +1352,27 @@ static int
 e1000_link_test(struct e1000_adapter *adapter, uint64_t *data)
 {
 	*data = 0;
-	e1000_check_for_link(&adapter->hw);
 
-	if(!(E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_LU)) {
-		*data = 1;
+	if (adapter->hw.media_type == e1000_media_type_internal_serdes) {
+		int i = 0;
+		adapter->hw.serdes_link_down = TRUE;
+
+		/* on some blade server designs link establishment */
+		/* could take as long as 2-3 minutes.              */
+		do {
+			e1000_check_for_link(&adapter->hw);
+			if (adapter->hw.serdes_link_down == FALSE)
+				return *data;
+			msec_delay(20);
+		} while (i++ < 3750);
+
+		*data = 1; 
+	} else {
+		e1000_check_for_link(&adapter->hw);
+
+		if(!(E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_LU)) {
+			*data = 1;
+		}
 	}
 	return *data;
 }
