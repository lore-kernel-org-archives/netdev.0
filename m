From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.6 4/10] e1000: Delay clean-up of last Tx buffer
Date: Tue, 15 Feb 2005 13:27:43 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0502151113391.30336-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

4 Delay clean-up of last Tx buffer to fix pre-mature writeback of Tx descriptors.
Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/e1000/e1000.h net-drivers-2.6/drivers/net/e1000.new/e1000.h
--- net-drivers-2.6/drivers/net/e1000/e1000.h	2005-02-01 23:10:24.986106336 -0800
+++ net-drivers-2.6/drivers/net/e1000.new/e1000.h	2005-02-01 23:10:26.474880008 -0800
@@ -209,6 +209,7 @@ struct e1000_adapter {
 
 	/* TX */
 	struct e1000_desc_ring tx_ring;
+	struct e1000_buffer previous_buffer_info;
 	spinlock_t tx_lock;
 	uint32_t txd_cmd;
 	uint32_t tx_int_delay;
diff -up net-drivers-2.6/drivers/net/e1000/e1000_main.c net-drivers-2.6/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.6/drivers/net/e1000/e1000_main.c	2005-02-01 23:10:24.989105880 -0800
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_main.c	2005-02-01 23:10:26.709844288 -0800
@@ -1103,6 +1103,7 @@ e1000_unmap_and_free_tx_resource(struct 
 			struct e1000_buffer *buffer_info)
 {
 	struct pci_dev *pdev = adapter->pdev;
+
 	if(buffer_info->dma) {
 		pci_unmap_page(pdev,
 			       buffer_info->dma,
@@ -1131,6 +1132,11 @@ e1000_clean_tx_ring(struct e1000_adapter
 
 	/* Free all the Tx ring sk_buffs */
 
+	if (likely(adapter->previous_buffer_info.skb != NULL)) {
+		e1000_unmap_and_free_tx_resource(adapter, 
+				&adapter->previous_buffer_info);
+	}
+
 	for(i = 0; i < tx_ring->count; i++) {
 		buffer_info = &tx_ring->buffer_info[i];
 		e1000_unmap_and_free_tx_resource(adapter, buffer_info);
@@ -2214,11 +2220,34 @@ e1000_clean_tx_irq(struct e1000_adapter 
 	eop_desc = E1000_TX_DESC(*tx_ring, eop);
 
 	while(eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) {
+		/* pre-mature writeback of Tx descriptors     */
+		/* clear (free buffers and unmap pci_mapping) */
+		/* previous_buffer_info                       */
+		if (likely(adapter->previous_buffer_info.skb != NULL)) {
+			e1000_unmap_and_free_tx_resource(adapter, 
+					&adapter->previous_buffer_info);
+		}
+
 		for(cleaned = FALSE; !cleaned; ) {
 			tx_desc = E1000_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
+			cleaned = (i == eop);
+
+			/* pre-mature writeback of Tx descriptors */
+			/* save the cleaning of the this for the  */
+			/* next iteration                         */
+			if (cleaned) {
+				memcpy(&adapter->previous_buffer_info,
+					buffer_info,
+					sizeof(struct e1000_buffer));
+				memset(buffer_info,
+					0,
+					sizeof(struct e1000_buffer));
+			} else {
+				e1000_unmap_and_free_tx_resource(adapter, 
+							buffer_info);
+			}
 
-			e1000_unmap_and_free_tx_resource(adapter, buffer_info);
 			tx_desc->buffer_addr = 0;
 			tx_desc->lower.data = 0;
 			tx_desc->upper.data = 0;
	
