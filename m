From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e100 netdev-2.6]
Date: Sat, 21 Feb 2004 23:05:39 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402212250500.1228-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Response to Jeff's review plus some minor fixes.

* define dump stats complete constant
* add mwb() to keep order straight with HW when appending
  new resources to Rx and Tx queues
* increment stats for rx_dropped and rx_over_errors

------------

--- netdev-2.6/drivers/net/e100.c	2004-02-20 15:18:24.000000000 -0800
+++ netdev-2.6/drivers/net/e100.c.mod	2004-02-21 22:04:34.000000000 -0800
@@ -132,6 +132,10 @@
  *
  * 	Thanks to JC (jchapman@katalix.com) for helping with
  * 	testing/troubleshooting the development driver.
+ *
+ * 	TODO:
+ * 	o several entry points race with dev->close
+ * 	o check for tx-no-resources/stop Q races with tx clean/wake Q
  */
 
 #include <linux/config.h>
@@ -154,12 +158,12 @@
 
 
 #define DRV_NAME		"e100"
-#define DRV_VERSION		"3.0.13_dev"
+#define DRV_VERSION		"3.0.15"
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network Driver"
 #define DRV_COPYRIGHT		"Copyright(c) 1999-2004 Intel Corporation"
 #define PFX			DRV_NAME ": "
 
-#define E100_WATCHDOG_PERIOD	2 * HZ
+#define E100_WATCHDOG_PERIOD	(2 * HZ)
 #define E100_NAPI_WEIGHT	16
 
 MODULE_DESCRIPTION(DRV_DESCRIPTION);
@@ -293,6 +297,11 @@ enum scb_cmd_lo {
 	cuc_dump_reset = 0x70,
 };
 
+enum cuc_dump {
+	cuc_dump_complete       = 0x0000A005,
+	cuc_dump_reset_complete = 0x0000A007,
+};
+		
 enum port {
 	software_reset  = 0x0000,
 	selftest        = 0x0001,
@@ -645,6 +654,7 @@ static void e100_eeprom_write(struct nic
 				eecs | eedi : eecs;
 			writeb(ctrl, &nic->csr->eeprom_ctrl_lo);
 			e100_write_flush(nic); udelay(4);
+
 			writeb(ctrl | eesk, &nic->csr->eeprom_ctrl_lo);
 			e100_write_flush(nic); udelay(4);
 		}
@@ -678,8 +688,10 @@ static u16 e100_eeprom_read(struct nic *
 		ctrl = (cmd_addr_data & (1 << i)) ? eecs | eedi : eecs;
 		writeb(ctrl, &nic->csr->eeprom_ctrl_lo);
 		e100_write_flush(nic); udelay(4);
+		
 		writeb(ctrl | eesk, &nic->csr->eeprom_ctrl_lo);
 		e100_write_flush(nic); udelay(4);
+		
 		/* Eeprom drives a dummy zero to EEDO after receiving
 		 * complete address.  Use this to adjust addr_len. */
 		ctrl = readb(&nic->csr->eeprom_ctrl_lo);
@@ -687,6 +699,7 @@ static u16 e100_eeprom_read(struct nic *
 			*addr_len -= (i - 16);
 			i = 17;
 		}
+		
 		data = (data << 1) | (ctrl & eedo ? 1 : 0);
 	}
 
@@ -807,6 +820,7 @@ static inline int e100_exec_cb(struct ni
 	/* Order is important otherwise we'll be in a race with h/w:
 	 * set S-bit in current first, then clear S-bit in previous. */
 	cb->command |= cpu_to_le16(cb_s);
+	wmb();
 	cb->prev->command &= cpu_to_le16(~cb_s);
 
 	while(nic->cb_to_send != nic->cb_to_use) {
@@ -1113,7 +1127,7 @@ static void e100_update_stats(struct nic
 	 * complete, so where always waiting for results of the
 	 * previous command. */
 
-	if(*complete == le32_to_cpu(0x0000A007)) {
+	if(*complete == le32_to_cpu(cuc_dump_reset_complete)) {
 		*complete = 0;
 		nic->tx_frames = le32_to_cpu(s->tx_good_frames);
 		nic->tx_collisions = le32_to_cpu(s->tx_total_collisions);
@@ -1126,7 +1140,6 @@ static void e100_update_stats(struct nic
 			le32_to_cpu(s->tx_lost_crs);
 		ns->rx_dropped += le32_to_cpu(s->rx_resource_errors);
 		ns->rx_length_errors += le32_to_cpu(s->rx_short_frame_errors);
-		ns->rx_over_errors += le32_to_cpu(s->rx_resource_errors);
 		ns->rx_crc_errors += le32_to_cpu(s->rx_crc_errors);
 		ns->rx_frame_errors += le32_to_cpu(s->rx_alignment_errors);
 		ns->rx_fifo_errors += le32_to_cpu(s->rx_overrun_errors);
@@ -1262,7 +1275,7 @@ static inline int e100_tx_clean(struct n
 	for(cb = nic->cb_to_clean;
 	    cb->status & cpu_to_le16(cb_complete);
 	    cb = nic->cb_to_clean = cb->next) {
-		if(likely(cb->skb)) {
+		if(likely(cb->skb != NULL)) {
 			nic->net_stats.tx_packets++;
 			nic->net_stats.tx_bytes += cb->skb->len;
 
@@ -1371,6 +1384,7 @@ static inline int e100_rx_alloc_skb(stru
 		struct rfd *prev_rfd = (struct rfd *)rx->prev->skb->data;
 		put_unaligned(cpu_to_le32(rx->dma_addr),
 			(u32 *)&prev_rfd->link);
+		wmb();
 		prev_rfd->command &= ~cpu_to_le16(cb_el);
 		pci_dma_sync_single(nic->pdev, rx->prev->dma_addr,
 			sizeof(struct rfd), PCI_DMA_TODEVICE);
@@ -1417,9 +1431,14 @@ static inline int e100_rx_indicate(struc
 	skb_put(skb, actual_size);
 	skb->protocol = eth_type_trans(skb, nic->netdev);
 
-	if(unlikely(!(rfd_status & cb_ok)) ||
-	   actual_size > nic->netdev->mtu + VLAN_ETH_HLEN) {
-		/* Don't indicate if errors */
+	if(unlikely(!(rfd_status & cb_ok))) {
+		/* Don't indicate if hardware indicates errors */
+		nic->net_stats.rx_dropped++;
+		dev_kfree_skb_any(skb);
+	} else if(actual_size > nic->netdev->mtu + VLAN_ETH_HLEN) {
+		/* Don't indicate oversized frames */
+		nic->net_stats.rx_over_errors++;
+		nic->net_stats.rx_dropped++;
 		dev_kfree_skb_any(skb);
 	} else {
 		nic->net_stats.rx_packets++;
